use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::circuit::Value;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_math::{from_complex, F, K, KExtensions};
use neo_midnight_bridge::k_field::KRepr;
use neo_midnight_bridge::relations::{PiCcsNcChunkInstance, PiCcsNcChunkRelation, PiCcsNcChunkWitness};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use p3_field::PrimeCharacteristicRing;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn k_from_u64(c0: u64, c1: u64) -> K {
    from_complex(F::from_u64(c0), F::from_u64(c1))
}

fn k_to_repr(k: &K) -> KRepr {
    let (c0, c1) = k.to_limbs_u64();
    KRepr { c0, c1 }
}

fn host_mle_eval(values: &[K], alpha: &[K]) -> K {
    assert_eq!(values.len(), 1usize << alpha.len());
    let mut cur = values.to_vec();
    for a in alpha {
        let next_len = cur.len() / 2;
        let mut next = Vec::with_capacity(next_len);
        for j in 0..next_len {
            let v0 = cur[2 * j];
            let v1 = cur[2 * j + 1];
            next.push(v0 + (*a) * (v1 - v0));
        }
        cur = next;
    }
    assert_eq!(cur.len(), 1);
    cur[0]
}

fn host_range_product(val: K, b: u32) -> K {
    let lo = -((b as i64) - 1);
    let hi = (b as i64) - 1;
    let mut prod = K::ONE;
    for t in lo..=hi {
        prod *= val - K::from(F::from_i64(t));
    }
    prod
}

fn host_nc_chunk_sum(y_zcols: &[Vec<K>], alpha: &[K], gamma: K, b: u32, start_exp: usize) -> K {
    let mut g = K::ONE;
    for _ in 0..start_exp {
        g *= gamma;
    }
    let mut acc = K::ZERO;
    for yz in y_zcols {
        let val = host_mle_eval(yz, alpha);
        let rp = host_range_product(val, b);
        acc += g * rp;
        g *= gamma;
    }
    acc
}

#[test]
fn mojo_plonk_pi_ccs_nc_chunk_from_snapshot_verifies_in_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let ell_d: usize = 4;
    let b: u32 = 3;
    let start_exp: usize = 1;
    let count: usize = 2;

    let alpha_prime: Vec<K> = vec![k_from_u64(2, 0), k_from_u64(3, 0), k_from_u64(5, 0), k_from_u64(7, 0)];
    assert_eq!(alpha_prime.len(), ell_d);
    let gamma: K = k_from_u64(11, 1);

    let d_pad = 1usize << ell_d;
    let mut y_zcols: Vec<Vec<K>> = Vec::with_capacity(count);
    for out_idx in 0..count {
        let mut yz = Vec::with_capacity(d_pad);
        for i in 0..d_pad {
            let c0 = 10 + (out_idx as u64) * 100 + (i as u64);
            let c1 = 20 + (out_idx as u64) * 50 + 2 * (i as u64);
            yz.push(k_from_u64(c0, c1));
        }
        y_zcols.push(yz);
    }

    let chunk_sum = host_nc_chunk_sum(&y_zcols, &alpha_prime, gamma, b, start_exp);

    let rel = PiCcsNcChunkRelation {
        ell_d,
        b,
        start_exp,
        count,
    };
    let instance = PiCcsNcChunkInstance {
        bundle_digest: [0u128; 2],
        chunk_sum: k_to_repr(&chunk_sum),
        alpha_prime: alpha_prime.iter().map(k_to_repr).collect(),
        gamma: k_to_repr(&gamma),
    };
    let witness = PiCcsNcChunkWitness {
        y_zcol: y_zcols
            .iter()
            .map(|yz| yz.iter().map(k_to_repr).collect())
            .collect(),
    };

    let pkg = export_package_v3(
        RelationKind::PiCcsNcChunk,
        &RelationParamsV1::PiCcsNcChunk {
            version: 1,
            ell_d,
            b,
            start_exp,
            count,
        },
        &rel,
        [0x42u8; 32],
    )
    .context("export_package_v3")?;

    let pi = PiCcsNcChunkRelation::format_instance(&instance).expect("format_instance");
    let com_inst = PiCcsNcChunkRelation::format_committed_instances(&witness);
    let circuit = midnight_zk_stdlib::MidnightCircuit::new(
        &rel,
        Value::known(instance.clone()),
        Value::known(witness),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("pi_ccs_nc_chunk.nmbp");
    let ws_path = dir.join("pi_ccs_nc_chunk.nmbws");
    let proof_path = dir.join("pi_ccs_nc_chunk.proof.bin");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;
    fs::write(&ws_path, ws.to_bytes()).context("write ws")?;

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/plonk_prove_from_snapshot.mojo");

    let status = Command::new("mojo")
        .args([
            "run",
            mojo_prog.to_str().unwrap(),
            pkg_path.to_str().unwrap(),
            ws_path.to_str().unwrap(),
            proof_path.to_str().unwrap(),
        ])
        .status()
        .context("run mojo plonk_prove_from_snapshot")?;
    assert!(status.success(), "mojo plonk_prove_from_snapshot failed");

    let proof = fs::read(&proof_path).context("read proof")?;

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params: ParamsKZG<Bls12> = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;
    let params_v = params.verifier_params();
    let vk = midnight_zk_stdlib::setup_vk(&params, &rel);

    midnight_zk_stdlib::verify::<PiCcsNcChunkRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
        .expect("verify");
    Ok(())
}
