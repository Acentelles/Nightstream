use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_midnight_bridge::k_field::{host_k_eval_horner, host_sumcheck_round_claim, KRepr, K_DELTA_U64};
use neo_midnight_bridge::relations::{SumcheckSingleRoundRelation, SumcheckSingleRoundWitness};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

#[test]
fn mojo_plonk_sumcheck_single_round_from_snapshot_verifies_in_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let rel = SumcheckSingleRoundRelation { n_coeffs: 4 };
    let pkg = export_package_v3(
        RelationKind::SumcheckSingleRound,
        &RelationParamsV1::SumcheckSingleRound {
            version: 1,
            n_coeffs: rel.n_coeffs,
        },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    let coeffs = vec![
        KRepr { c0: 1, c1: 2 },
        KRepr { c0: 3, c1: 4 },
        KRepr { c0: 5, c1: 6 },
        KRepr { c0: 7, c1: 8 },
    ];
    let challenge = KRepr { c0: 9, c1: 10 };
    let claimed_sum = host_sumcheck_round_claim(&coeffs);
    let next_sum = host_k_eval_horner(&coeffs, challenge, K_DELTA_U64);
    let witness = SumcheckSingleRoundWitness {
        coeffs,
        challenge,
        claimed_sum,
        next_sum,
    };

    let pi = SumcheckSingleRoundRelation::format_instance(&()).expect("format_instance");
    let com_inst = SumcheckSingleRoundRelation::format_committed_instances(&witness);
    let circuit = midnight_zk_stdlib::MidnightCircuit::new(
        &rel,
        midnight_proofs::circuit::Value::known(()),
        midnight_proofs::circuit::Value::known(witness.clone()),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("sumcheck_single_round.nmbp");
    let ws_path = dir.join("sumcheck_single_round.nmbws");
    let proof_path = dir.join("sumcheck_single_round.proof.bin");
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

    midnight_zk_stdlib::verify::<SumcheckSingleRoundRelation, TranscriptHash>(&params_v, &vk, &(), None, &proof)
        .expect("verify");
    Ok(())
}
