use anyhow::Context;
use neo_midnight_bridge::relations::{GoldilocksMulInstance, GoldilocksMulRelation};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use midnight_zk_stdlib::Relation;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

#[test]
fn mojo_can_parse_exported_package_and_snapshot() -> anyhow::Result<()> {
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
        midnight_proofs::circuit::Value::known(instance),
        midnight_proofs::circuit::Value::known(()),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("goldilocks_mul.nmbp");
    let ws_path = dir.join("goldilocks_mul.nmbws");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;
    fs::write(&ws_path, ws.to_bytes()).context("write ws")?;

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let inspect = manifest_dir.join("mojo/cli/inspect.mojo");

    let status = Command::new("mojo")
        .args(["run", inspect.to_str().unwrap(), pkg_path.to_str().unwrap(), ws_path.to_str().unwrap()])
        .status()
        .context("run mojo inspect")?;
    assert!(status.success(), "mojo inspect failed");
    Ok(())
}
