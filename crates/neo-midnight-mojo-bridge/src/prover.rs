use anyhow::{anyhow, Context};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};

fn mojo_program_path(rel: &str) -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("mojo").join(rel)
}

fn mojo_base_dir() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("mojo")
}

fn ensure_mojo_installed() -> anyhow::Result<()> {
    if Command::new("mojo").arg("--version").output().is_err() {
        anyhow::bail!("`mojo` not found in PATH");
    }
    Ok(())
}

fn run_mojo(args: &[&str]) -> anyhow::Result<Output> {
    ensure_mojo_installed()?;
    Command::new("mojo")
        .args(args)
        .output()
        .with_context(|| format!("spawn `mojo {}`", args.join(" ")))
}

fn unique_temp_dir(prefix: &str) -> anyhow::Result<PathBuf> {
    let dir = std::env::temp_dir().join(format!(
        "{prefix}-{}-{}",
        std::process::id(),
        std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_nanos()
    ));
    fs::create_dir_all(&dir).with_context(|| format!("create temp dir {}", dir.display()))?;
    Ok(dir)
}

pub fn prove_from_snapshot(pkg_bytes: &[u8], snapshot_bytes: &[u8]) -> anyhow::Result<Vec<u8>> {
    let dir = unique_temp_dir("neo-midnight-mojo-bridge-prove-snapshot")?;
    let pkg_path = dir.join("pkg.nmbp");
    let ws_path = dir.join("snapshot.nmbws");
    let proof_path = dir.join("proof.bin");
    fs::write(&pkg_path, pkg_bytes).context("write pkg")?;
    fs::write(&ws_path, snapshot_bytes).context("write snapshot")?;

    let prog = mojo_program_path("cli/prove.mojo");
    let include_dir = mojo_base_dir();
    let output = run_mojo(&[
        "run",
        "-I",
        include_dir.to_str().expect("utf-8 path"),
        prog.to_str().expect("utf-8 path"),
        "snapshot",
        pkg_path.to_str().unwrap(),
        ws_path.to_str().unwrap(),
        proof_path.to_str().unwrap(),
    ])?;
    if !output.status.success() {
        return Err(anyhow!(
            "mojo prove snapshot failed\nstdout:\n{}\nstderr:\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    fs::read(&proof_path).context("read proof")
}

pub fn prove_goldilocks_mul(pkg_bytes: &[u8], x: u64, y: u64, z: u64) -> anyhow::Result<Vec<u8>> {
    let dir = unique_temp_dir("neo-midnight-mojo-bridge-prove-goldilocks-mul")?;
    let pkg_path = dir.join("pkg.nmbp");
    let proof_path = dir.join("proof.bin");
    fs::write(&pkg_path, pkg_bytes).context("write pkg")?;

    let prog = mojo_program_path("cli/prove.mojo");
    let include_dir = mojo_base_dir();
    let output = run_mojo(&[
        "run",
        "-I",
        include_dir.to_str().expect("utf-8 path"),
        prog.to_str().expect("utf-8 path"),
        "goldilocks_mul",
        pkg_path.to_str().unwrap(),
        &x.to_string(),
        &y.to_string(),
        &z.to_string(),
        proof_path.to_str().unwrap(),
    ])?;
    if !output.status.success() {
        return Err(anyhow!(
            "mojo prove goldilocks_mul failed\nstdout:\n{}\nstderr:\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    fs::read(&proof_path).context("read proof")
}

pub fn prove_sumcheck_single_round(
    pkg_bytes: &[u8],
    coeffs: &[(u64, u64)],
    challenge: (u64, u64),
    claimed_sum: (u64, u64),
    next_sum: (u64, u64),
) -> anyhow::Result<Vec<u8>> {
    let dir = unique_temp_dir("neo-midnight-mojo-bridge-prove-sumcheck-single-round")?;
    let pkg_path = dir.join("pkg.nmbp");
    let proof_path = dir.join("proof.bin");
    fs::write(&pkg_path, pkg_bytes).context("write pkg")?;

    let prog = mojo_program_path("cli/prove.mojo");
    let include_dir = mojo_base_dir();

    let mut args: Vec<String> = Vec::new();
    args.push("run".into());
    args.push("-I".into());
    args.push(include_dir.to_str().expect("utf-8 path").to_owned());
    args.push(prog.to_str().expect("utf-8 path").to_owned());
    args.push("sumcheck_single_round".into());
    args.push(pkg_path.to_str().unwrap().to_owned());
    args.push(coeffs.len().to_string());
    for (c0, c1) in coeffs {
        args.push(c0.to_string());
        args.push(c1.to_string());
    }
    args.push(challenge.0.to_string());
    args.push(challenge.1.to_string());
    args.push(claimed_sum.0.to_string());
    args.push(claimed_sum.1.to_string());
    args.push(next_sum.0.to_string());
    args.push(next_sum.1.to_string());
    args.push(proof_path.to_str().unwrap().to_owned());

    let arg_refs: Vec<&str> = args.iter().map(|s| s.as_str()).collect();
    let output = run_mojo(&arg_refs)?;
    if !output.status.success() {
        return Err(anyhow!(
            "mojo prove sumcheck_single_round failed\nstdout:\n{}\nstderr:\n{}",
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    fs::read(&proof_path).context("read proof")
}

pub fn write_proof_file(path: impl AsRef<Path>, proof: &[u8]) -> anyhow::Result<()> {
    fs::write(path.as_ref(), proof).with_context(|| format!("write proof {}", path.as_ref().display()))
}
