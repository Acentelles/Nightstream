use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use neo_midnight_bridge::goldilocks::{host_mul_quotient_and_remainder, GOLDILOCKS_P_U64};
use neo_midnight_bridge::relations::{GoldilocksMulInstance, GoldilocksMulRelation};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn run_case(x: u64, y: u64) -> anyhow::Result<()> {
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

    let (_kq, r) = host_mul_quotient_and_remainder(x, y);
    let instance = GoldilocksMulInstance { x, y, z: r };

    let dir = std::env::temp_dir().join(format!(
        "neo-midnight-mojo-bridge-{}-goldilocks-mul-x{}-y{}",
        std::process::id(),
        x,
        y
    ));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("goldilocks_mul.nmbp");
    let proof_path = dir.join("goldilocks_mul_no_snapshot.proof.bin");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/plonk_prove_goldilocks_mul.mojo");

    let status = Command::new("mojo")
        .args([
            "run",
            mojo_prog.to_str().unwrap(),
            pkg_path.to_str().unwrap(),
            &instance.x.to_string(),
            &instance.y.to_string(),
            &instance.z.to_string(),
            proof_path.to_str().unwrap(),
        ])
        .status()
        .context("run mojo plonk_prove_goldilocks_mul")?;
    assert!(status.success(), "mojo plonk_prove_goldilocks_mul failed");

    let proof = fs::read(&proof_path).context("read proof")?;

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params: ParamsKZG<Bls12> = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;
    let params_v = params.verifier_params();
    let vk = midnight_zk_stdlib::setup_vk(&params, &rel);

    midnight_zk_stdlib::verify::<GoldilocksMulRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
        .expect("verify");
    Ok(())
}

#[test]
fn mojo_plonk_goldilocks_mul_no_snapshot_small() -> anyhow::Result<()> {
    run_case(7, 9)
}

#[test]
fn mojo_plonk_goldilocks_mul_no_snapshot_large_nonzero_k() -> anyhow::Result<()> {
    // Exercise the b=0 path in `assert_lower_than_fixed` + non-zero quotient witness.
    let x = GOLDILOCKS_P_U64 - 1;
    let y = GOLDILOCKS_P_U64 - 1;
    run_case(x, y)
}
