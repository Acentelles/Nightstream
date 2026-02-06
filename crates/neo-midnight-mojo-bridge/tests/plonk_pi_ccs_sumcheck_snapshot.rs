use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_midnight_bridge::k_field::{host_k_eval_horner, KRepr, K_DELTA_U64};
use neo_midnight_bridge::relations::{PiCcsSumcheckInstance, PiCcsSumcheckRelation, PiCcsSumcheckWitness};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn k(c0: u64, c1: u64) -> KRepr {
    KRepr { c0, c1 }
}

#[test]
fn mojo_plonk_pi_ccs_sumcheck_proof_from_snapshot_verifies_in_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let n_rounds: usize = 3;
    let poly_len: usize = 2;

    // Build a trivially-consistent sumcheck chain:
    // - round poly is p_i(x) = claim_i * x (so coeffs = [0, claim_i])
    // - claim_{i+1} = p_i(challenge_i)
    let challenges = vec![k(2, 0), k(3, 0), k(5, 0)];
    assert_eq!(challenges.len(), n_rounds);

    let mut claim = k(11, 13);
    let mut rounds = Vec::<Vec<KRepr>>::with_capacity(n_rounds);
    for i in 0..n_rounds {
        let coeffs = vec![KRepr::ZERO, claim];
        let next = host_k_eval_horner(&coeffs, challenges[i], K_DELTA_U64);
        rounds.push(coeffs);
        claim = next;
    }

    let instance = PiCcsSumcheckInstance {
        bundle_digest: [0u128; 2],
        initial_sum: k(11, 13),
        final_sum: claim,
        challenges: challenges.clone(),
    };
    let witness = PiCcsSumcheckWitness { rounds };

    let rel = PiCcsSumcheckRelation { n_rounds, poly_len };
    let pkg = export_package_v3(
        RelationKind::PiCcsSumcheck,
        &RelationParamsV1::PiCcsSumcheck {
            version: 1,
            n_rounds,
            poly_len,
        },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    let pi = PiCcsSumcheckRelation::format_instance(&instance).expect("format_instance");
    let com_inst = PiCcsSumcheckRelation::format_committed_instances(&witness);
    let circuit = midnight_zk_stdlib::MidnightCircuit::new(
        &rel,
        midnight_proofs::circuit::Value::known(instance.clone()),
        midnight_proofs::circuit::Value::known(witness.clone()),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("pi_ccs_sumcheck.nmbp");
    let ws_path = dir.join("pi_ccs_sumcheck.nmbws");
    let proof_path = dir.join("pi_ccs_sumcheck.proof.bin");
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

    midnight_zk_stdlib::verify::<PiCcsSumcheckRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
        .expect("verify");
    Ok(())
}

