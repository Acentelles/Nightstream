use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::circuit::Value;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_math::{F, K, KExtensions, D};
use neo_midnight_bridge::k_field::KRepr;
use neo_midnight_bridge::relations::{PiCcsNcChunkInstance, PiCcsNcChunkRelation, PiCcsNcChunkWitness};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use p3_field::PrimeCharacteristicRing;
use std::cmp;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

const MIDNIGHT_MAX_K: u32 = 14;

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

fn host_chunk_sum(y_zcols: &[Vec<K>], alpha: &[K], gamma: K, b: u32, start_exp: usize) -> K {
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

/// Find the maximum `count` in `[1..=max_count]` that fits `k <= MIDNIGHT_MAX_K`.
fn choose_max_count_under_k(
    max_count: usize,
    mut model_for_count: impl FnMut(usize) -> (u32, usize),
) -> usize {
    let mut lo = 1usize;
    let mut hi = max_count;
    let mut best = 1usize;

    while lo <= hi {
        let mid = (lo + hi) / 2;
        let (k, _rows) = model_for_count(mid);
        if k <= MIDNIGHT_MAX_K {
            best = mid;
            lo = mid + 1;
        } else {
            hi = mid - 1;
        }
    }

    best
}

#[test]
#[ignore = "benchmark-style parity; run with --ignored --nocapture"]
fn mojo_plonk_pi_ccs_nc_chunk_poseidon2_batch_1_from_snapshot_verifies_in_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let json_path = manifest_dir.join("../neo-fold/poseidon2-tests/poseidon2_ic_circuit_batch_1.json");
    let json = fs::read_to_string(&json_path).context("read poseidon2 batch-1 json")?;
    let export = neo_fold::test_export::parse_test_export_json(&json).context("parse test-export json")?;

    let target_folding_steps: usize = 2;
    let mut session = neo_fold::test_export::TestExportSession::new_from_circuit_json(&json)
        .map_err(|e| anyhow::anyhow!("session init failed: {e}"))?;
    for i in 0..target_folding_steps {
        let z = &export.witness[i % export.witness.len()];
        session
            .add_step_witness_u64(z)
            .map_err(|e| anyhow::anyhow!("add witness step failed: {e}"))?;
    }

    let (fold_run, _step_ms) = session
        .fold_and_prove_with_step_timings()
        .map_err(|e| anyhow::anyhow!("fold_and_prove failed: {e}"))?;
    assert_eq!(fold_run.steps.len(), target_folding_steps);
    assert!(session
        .verify(&fold_run)
        .map_err(|e| anyhow::anyhow!("verify failed: {e}"))?);

    let s = session.ccs();
    let m_pad = s.m.next_power_of_two().max(2);
    let ell_m = m_pad.trailing_zeros() as usize;
    let d_pad = D.next_power_of_two();
    let ell_d = d_pad.trailing_zeros() as usize;
    let params_b = session.params().b;

    let step1 = &fold_run.steps[1];
    let pi = &step1.fold.ccs_proof;
    let k_total = step1.fold.ccs_out.len();
    assert!(k_total > 1, "expected step1 k_total > 1");

    let want_nc_chals = ell_m + ell_d;
    assert_eq!(pi.sumcheck_challenges_nc.len(), want_nc_chals);
    let (_s_col_prime, alpha_prime_nc) = pi.sumcheck_challenges_nc.split_at(ell_m);
    let gamma = pi.challenges_public.gamma;

    // Choose a chunk size that fits under Midnight's cap.
    let chunk_size = choose_max_count_under_k(k_total, |count| {
        use midnight_proofs::dev::cost_model::circuit_model;
        let rel_try = PiCcsNcChunkRelation {
            ell_d,
            b: params_b,
            start_exp: k_total, // worst-case exponent
            count,
        };
        let circuit_try = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel_try);
        let model_try = circuit_model::<_, 48, 32>(&circuit_try);
        (model_try.k, model_try.rows)
    });

    let y_zcols_all: Vec<Vec<K>> = step1
        .fold
        .ccs_out
        .iter()
        .map(|out| out.y_zcol.clone())
        .collect();
    assert_eq!(y_zcols_all.len(), k_total);

    // Prove the first chunk (start_exp=1).
    let start_i = 0usize;
    let count = cmp::min(chunk_size, k_total - start_i);
    let start_exp = start_i + 1;
    let yz_slice = &y_zcols_all[start_i..start_i + count];

    let chunk_sum = host_chunk_sum(yz_slice, alpha_prime_nc, gamma, params_b, start_exp);

    let rel = PiCcsNcChunkRelation {
        ell_d,
        b: params_b,
        start_exp,
        count,
    };
    let instance = PiCcsNcChunkInstance {
        bundle_digest: [0u128; 2],
        chunk_sum: k_to_repr(&chunk_sum),
        alpha_prime: alpha_prime_nc.iter().map(k_to_repr).collect(),
        gamma: k_to_repr(&gamma),
    };
    let witness = PiCcsNcChunkWitness {
        y_zcol: yz_slice
            .iter()
            .map(|yz| yz.iter().map(k_to_repr).collect())
            .collect(),
    };

    let pkg = export_package_v3(
        RelationKind::PiCcsNcChunk,
        &RelationParamsV1::PiCcsNcChunk {
            version: 1,
            ell_d,
            b: params_b,
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

