use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};

fn repo_root() -> Result<PathBuf, String> {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .and_then(Path::parent)
        .map(Path::to_path_buf)
        .ok_or_else(|| "failed to resolve repository root from CARGO_MANIFEST_DIR".to_string())
}

fn guest_dir(name: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("riscv-tests")
        .join("guests")
        .join(name)
}

pub fn build_note_spend_rv64im_elf() -> Result<Vec<u8>, String> {
    build_guest_rv64im_elf("circuit-l2-transfer", "circuit_l2_transfer")
}

pub fn build_note_deposit_rv64im_elf() -> Result<Vec<u8>, String> {
    build_guest_rv64im_elf("note-deposit", "note_deposit")
}

fn build_guest_rv64im_elf(guest_name: &str, binary_name: &str) -> Result<Vec<u8>, String> {
    let repo_root = repo_root()?;
    let guest_dir = guest_dir(guest_name);
    let manifest = guest_dir.join("Cargo.toml");
    let guest_support_dir = repo_root
        .join("crates")
        .join("nightstream-sdk")
        .join("guest");
    let linker = guest_support_dir.join("riscv64im-unknown-none-elf.ld");
    let target_json = guest_support_dir.join("riscv64im-unknown-none-elf.json");
    let target_dir = repo_root
        .join("target")
        .join("rv64-guests")
        .join(guest_name);
    let rustflags = format!("-C link-arg=-T{}", linker.display());
    let numeric_target_json = write_numeric_pointer_width_target_json(&target_json, &target_dir)?;
    let mut build_target = target_json.clone();
    let mut use_json_target_flag = false;
    let output = loop {
        let output = run_guest_build(&manifest, &build_target, &target_dir, &rustflags, use_json_target_flag)?;
        if output.status.success() {
            break output;
        }
        if !use_json_target_flag && guest_build_output_needs_json_target_flag(&output) {
            use_json_target_flag = true;
            continue;
        }
        if build_target == target_json && guest_build_output_needs_numeric_pointer_width(&output) {
            build_target = numeric_target_json.clone();
            continue;
        }
        break output;
    };

    if !output.status.success() {
        let stdout = String::from_utf8_lossy(&output.stdout);
        let stderr = String::from_utf8_lossy(&output.stderr);
        return Err(format!(
            "RV64 guest build failed\nstdout:\n{}\nstderr:\n{}",
            stdout, stderr
        ));
    }

    let elf_path = resolve_guest_elf_path(&target_dir, binary_name)?;
    fs::read(&elf_path).map_err(|e| format!("failed to read {}: {e}", elf_path.display()))
}

fn resolve_guest_elf_path(target_dir: &Path, binary_name: &str) -> Result<PathBuf, String> {
    let canonical = target_dir
        .join("riscv64im-unknown-none-elf")
        .join("release")
        .join(binary_name);
    if canonical.is_file() {
        return Ok(canonical);
    }

    let numeric_pointer_width = target_dir
        .join("riscv64im-unknown-none-elf.u16")
        .join("release")
        .join(binary_name);
    if numeric_pointer_width.is_file() {
        return Ok(numeric_pointer_width);
    }

    Err(format!(
        "failed to locate built RV64 guest ELF {}; checked {} and {}",
        binary_name,
        canonical.display(),
        numeric_pointer_width.display()
    ))
}

fn run_guest_build(
    manifest: &Path,
    target_json: &Path,
    target_dir: &Path,
    rustflags: &str,
    use_json_target_flag: bool,
) -> Result<Output, String> {
    let mut cmd = Command::new("cargo");
    cmd.arg("+nightly")
        .arg("build")
        .arg("-Z")
        .arg("build-std=core,alloc");
    if use_json_target_flag {
        cmd.arg("-Zjson-target-spec");
    }
    cmd.arg("-Z")
        .arg("build-std-features=compiler-builtins-mem")
        .arg("--manifest-path")
        .arg(manifest)
        .arg("--release")
        .arg("--target")
        .arg(target_json)
        .env("CARGO_TARGET_DIR", target_dir)
        .env("RUSTFLAGS", rustflags);

    cmd.output()
        .map_err(|e| format!("failed to invoke cargo for RV64 guest build: {e}"))
}

fn guest_build_output_needs_json_target_flag(output: &Output) -> bool {
    let stderr = String::from_utf8_lossy(&output.stderr);
    stderr.contains("target specs require -Zjson-target-spec")
        || stderr.contains("target specs require -Z json-target-spec")
}

fn guest_build_output_needs_numeric_pointer_width(output: &Output) -> bool {
    let stderr = String::from_utf8_lossy(&output.stderr);
    stderr.contains("target-pointer-width: invalid type: string") && stderr.contains("expected u16")
}

fn write_numeric_pointer_width_target_json(target_json: &Path, target_dir: &Path) -> Result<PathBuf, String> {
    let spec = fs::read_to_string(target_json)
        .map_err(|e| format!("failed to read target spec {}: {e}", target_json.display()))?;
    let numeric_spec = spec.replace("\"target-pointer-width\": \"64\"", "\"target-pointer-width\": 64");
    let numeric_path = target_dir.join("riscv64im-unknown-none-elf.u16.json");
    fs::create_dir_all(target_dir).map_err(|e| format!("failed to create target dir {}: {e}", target_dir.display()))?;
    fs::write(&numeric_path, numeric_spec)
        .map_err(|e| format!("failed to write target spec {}: {e}", numeric_path.display()))?;
    Ok(numeric_path)
}
