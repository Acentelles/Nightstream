use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_midnight_bridge::relations::{GoldilocksMulInstance, GoldilocksMulRelation};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

#[test]
fn mojo_plonk_proof_from_corrupted_snapshot_rejects_in_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let rel = GoldilocksMulRelation;
    let pkg = export_package_v3(
        RelationKind::GoldilocksMul,
        &RelationParamsV1::GoldilocksMul { version: 1 },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    let instance = GoldilocksMulInstance { x: 7, y: 9, z: 63 };
    let pi = GoldilocksMulRelation::format_instance(&instance).expect("format_instance");
    let com_inst = GoldilocksMulRelation::format_committed_instances(&());
    let circuit = midnight_zk_stdlib::MidnightCircuit::new(
        &rel,
        midnight_proofs::circuit::Value::known(instance.clone()),
        midnight_proofs::circuit::Value::known(()),
        None,
    );
    let mut ws =
        export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    // Flip one non-zero advice cell inside usable rows.
    let usable_rows = ws.usable_rows as usize;
    let zero = [0u8; 32];
    let mut corrupted = false;
    'outer: for col in 0..ws.advice_cols.len() {
        for row in 0..usable_rows.min(ws.advice_cols[col].len()) {
            if ws.advice_cols[col][row] != zero {
                ws.advice_cols[col][row] = zero;
                corrupted = true;
                break 'outer;
            }
        }
    }
    anyhow::ensure!(corrupted, "expected at least one non-zero advice cell to corrupt");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("goldilocks_mul.nmbp");
    let ws_path = dir.join("goldilocks_mul_corrupt.nmbws");
    let proof_path = dir.join("goldilocks_mul_corrupt.proof.bin");
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

    let res = midnight_zk_stdlib::verify::<GoldilocksMulRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof);
    assert!(res.is_err(), "expected verification to fail for corrupted snapshot");
    Ok(())
}

