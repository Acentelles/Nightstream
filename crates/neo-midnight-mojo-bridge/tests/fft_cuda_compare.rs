use anyhow::Context;
use std::path::PathBuf;
use std::process::Command;

#[test]
#[ignore = "requires GPU-capable `mojo` toolchain (CUDA or Metal)"]
fn mojo_fft_cuda_matches_cpu() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/fft_cuda_compare.mojo");

    let mut cmd = Command::new("mojo");
    cmd.arg("run");
    #[cfg(target_os = "macos")]
    cmd.args(["-D", "NMB_ENABLE_METAL_GPU=true"]);
    cmd.arg(mojo_prog.to_str().unwrap());

    let output = cmd
        .output()
        .context("run mojo fft_cuda_compare")?;
    if !output.status.success() {
        anyhow::bail!(
            "mojo fft_cuda_compare failed\nstdout:\n{}\nstderr:\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        );
    }
    Ok(())
}
