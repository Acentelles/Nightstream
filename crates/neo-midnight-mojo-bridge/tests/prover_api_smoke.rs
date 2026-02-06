use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::circuit::Value;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_midnight_bridge::goldilocks::host_mul_quotient_and_remainder;
use neo_midnight_bridge::relations::{GoldilocksMulInstance, GoldilocksMulRelation};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::process::Command;

#[test]
fn mojo_prover_api_goldilocks_mul_no_snapshot_roundtrip() -> anyhow::Result<()> {
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

    let x = 7u64;
    let y = 9u64;
    let (_kq, r) = host_mul_quotient_and_remainder(x, y);
    let instance = GoldilocksMulInstance { x, y, z: r };

    let proof = neo_midnight_mojo_bridge::prover::prove_goldilocks_mul(&pkg.to_bytes(), x, y, r)
        .context("prove_goldilocks_mul")?;

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params: ParamsKZG<Bls12> = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;
    let params_v = params.verifier_params();
    let vk = midnight_zk_stdlib::setup_vk(&params, &rel);

    midnight_zk_stdlib::verify::<GoldilocksMulRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
        .context("verify")?;
    Ok(())
}

#[test]
fn mojo_prover_api_snapshot_roundtrip() -> anyhow::Result<()> {
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
        Value::known(instance.clone()),
        Value::known(()),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    let proof = neo_midnight_mojo_bridge::prover::prove_from_snapshot(&pkg.to_bytes(), &ws.to_bytes())
        .context("prove_from_snapshot")?;

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params: ParamsKZG<Bls12> = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;
    let params_v = params.verifier_params();
    let vk = midnight_zk_stdlib::setup_vk(&params, &rel);

    midnight_zk_stdlib::verify::<GoldilocksMulRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
        .context("verify")?;
    Ok(())
}
