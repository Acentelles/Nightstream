use std::env;
use std::path::PathBuf;
use std::process::Command;

fn main() {
    let manifest_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"));
    let mojo_src = manifest_dir.join("mojo").join("host").join("reduce_u192.mojo");
    println!("cargo:rerun-if-changed={}", mojo_src.display());

    // Keep the workspace buildable without Mojo by default. Opt-in with `--features build-mojo`.
    if env::var_os("CARGO_FEATURE_BUILD_MOJO").is_none() {
        return;
    }

    let out_dir = PathBuf::from(env::var("OUT_DIR").expect("OUT_DIR"));
    let target_os = env::var("CARGO_CFG_TARGET_OS").unwrap_or_else(|_| "unknown".to_string());
    let lib_filename = match target_os.as_str() {
        "macos" => "libneo_midnight_bridge_mojo.dylib",
        "windows" => "neo_midnight_bridge_mojo.dll",
        _ => "libneo_midnight_bridge_mojo.so",
    };
    let lib_path = out_dir.join(lib_filename);

    let status = Command::new("mojo")
        .args([
            "build",
            "--emit",
            "shared-lib",
            "-O",
            "3",
            "-o",
            lib_path.to_str().expect("OUT_DIR path should be valid UTF-8"),
            mojo_src.to_str().expect("mojo src path should be valid UTF-8"),
        ])
        .status()
        .expect("failed to spawn `mojo build` (is `mojo` in PATH?)");

    if !status.success() {
        panic!("`mojo build` failed with status: {status}");
    }

    // Used by `env!()` in the Rust-side shim.
    println!("cargo:rustc-env=NEO_MIDNIGHT_BRIDGE_MOJO_LIB_PATH={}", lib_path.display());
}

