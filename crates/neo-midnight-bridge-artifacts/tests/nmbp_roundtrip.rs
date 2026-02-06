use neo_midnight_bridge::relations::GoldilocksMulRelation;
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};

#[test]
fn export_goldilocks_mul_package_has_header() {
    let rel = GoldilocksMulRelation;
    let pkg = export_package_v3(
        RelationKind::GoldilocksMul,
        &RelationParamsV1::GoldilocksMul { version: 1 },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    let bytes = pkg.to_bytes();
    assert!(bytes.starts_with(b"NMBP"), "missing magic");
    let ver = u32::from_le_bytes(bytes[4..8].try_into().expect("4 bytes"));
    assert_eq!(ver, 3);
}
