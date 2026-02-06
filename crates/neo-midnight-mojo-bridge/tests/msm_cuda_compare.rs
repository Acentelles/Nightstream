use anyhow::Context;
use neo_midnight_bridge::relations::GoldilocksMulRelation;
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::fs;
use std::path::PathBuf;
use std::process::Command;

#[test]
#[ignore = "requires GPU-capable `mojo` toolchain (CUDA or Metal)"]
fn mojo_msm_cuda_matches_cpu() -> anyhow::Result<()> {
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

    let dir = std::env::temp_dir().join(format!(
        "neo-midnight-mojo-bridge-{}-msm-cuda-compare",
        std::process::id()
    ));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("goldilocks_mul.nmbp");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/msm_cuda_compare.mojo");

    let mut cmd = Command::new("mojo");
    cmd.arg("run");
    #[cfg(target_os = "macos")]
    cmd.args(["-D", "NMB_ENABLE_METAL_GPU=true"]);
    cmd.arg(mojo_prog.to_str().unwrap())
        .arg(pkg_path.to_str().unwrap());

    let output = cmd
        .output()
        .context("run mojo msm_cuda_compare")?;
    if !output.status.success() {
        anyhow::bail!(
            "mojo msm_cuda_compare failed\nstdout:\n{}\nstderr:\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        );
    }
    Ok(())
}
