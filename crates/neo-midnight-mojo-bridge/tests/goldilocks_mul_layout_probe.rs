use midnight_zk_stdlib::Relation;
use neo_midnight_bridge::goldilocks::{host_mul_quotient_and_remainder, GOLDILOCKS_P_U64};
use neo_midnight_bridge::relations::{GoldilocksMulInstance, GoldilocksMulRelation};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::fs;

#[test]
#[ignore = "layout probe helper; run manually with --ignored --nocapture"]
fn dump_layout_for_nonzero_k() -> anyhow::Result<()> {
    let rel = GoldilocksMulRelation;
    let pkg = export_package_v3(
        RelationKind::GoldilocksMul,
        &RelationParamsV1::GoldilocksMul { version: 1 },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    let x = GOLDILOCKS_P_U64 - 1;
    let y = GOLDILOCKS_P_U64 - 1;
    let (kq, r) = host_mul_quotient_and_remainder(x, y);
    eprintln!("x={x} y={y} k={kq} r={r}");
    let instance = GoldilocksMulInstance { x, y, z: r };

    let pi = GoldilocksMulRelation::format_instance(&instance).expect("format_instance");
    let com_inst = GoldilocksMulRelation::format_committed_instances(&());
    let circuit = midnight_zk_stdlib::MidnightCircuit::new(
        &rel,
        midnight_proofs::circuit::Value::known(instance.clone()),
        midnight_proofs::circuit::Value::known(()),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-layout-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir)?;

    let ws_path = dir.join("goldilocks_mul_nonzero_k.nmbws");
    fs::write(&ws_path, ws.to_bytes())?;
    eprintln!("wrote snapshot: {}", ws_path.display());
    Ok(())
}
