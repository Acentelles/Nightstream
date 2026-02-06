use anyhow::{anyhow, Context, Result};
use neo_midnight_bridge::goldilocks::{host_mul_quotient_and_remainder, GOLDILOCKS_P_U64};
use neo_midnight_bridge::relations::{GoldilocksMulInstance, GoldilocksMulRelation};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use midnight_zk_stdlib::Relation;
use std::fs;
use std::path::PathBuf;

fn usage() -> &'static str {
    "Usage:\n  \
  nmb_export export-package goldilocks_mul <out.nmbp>\n  \
  nmb_export export-witness-snapshot goldilocks_mul <out.nmbws> <x> <y>\n"
}

fn main() -> Result<()> {
    let mut args = std::env::args().skip(1);
    let Some(cmd) = args.next() else {
        return Err(anyhow!(usage()));
    };
    match cmd.as_str() {
        "export-package" => export_package_cmd(args.collect()),
        "export-witness-snapshot" => export_witness_snapshot_cmd(args.collect()),
        _ => Err(anyhow!(usage())),
    }
}

fn export_package_cmd(args: Vec<String>) -> Result<()> {
    if args.len() != 2 {
        return Err(anyhow!(usage()));
    }
    let rel = args[0].as_str();
    let out_path = PathBuf::from(&args[1]);

    match rel {
        "goldilocks_mul" => {
            let relation = GoldilocksMulRelation;
            let params = RelationParamsV1::GoldilocksMul { version: 1 };
            let pkg = export_package_v3(
                RelationKind::GoldilocksMul,
                &params,
                &relation,
                [0x42u8; 32],
            )?;
            fs::write(&out_path, pkg.to_bytes()).context("write .nmbp")?;
            Ok(())
        }
        _ => Err(anyhow!("unsupported relation for export-package: {rel}")),
    }
}

fn export_witness_snapshot_cmd(args: Vec<String>) -> Result<()> {
    if args.len() != 4 {
        return Err(anyhow!(usage()));
    }
    let rel = args[0].as_str();
    let out_path = PathBuf::from(&args[1]);
    let x: u64 = args[2].parse().context("parse x")?;
    let y: u64 = args[3].parse().context("parse y")?;

    match rel {
        "goldilocks_mul" => {
            let relation = GoldilocksMulRelation;
            let pkg = export_package_v3(
                RelationKind::GoldilocksMul,
                &RelationParamsV1::GoldilocksMul { version: 1 },
                &relation,
                [0x42u8; 32],
            )?;

            let x = x % GOLDILOCKS_P_U64;
            let y = y % GOLDILOCKS_P_U64;
            let (_k, z) = host_mul_quotient_and_remainder(x, y);
            let instance = GoldilocksMulInstance { x, y, z };

            let pi = GoldilocksMulRelation::format_instance(&instance)?;
            let com_inst = GoldilocksMulRelation::format_committed_instances(&());
            let circuit = midnight_zk_stdlib::MidnightCircuit::new(
                &relation,
                midnight_proofs::circuit::Value::known(instance),
                midnight_proofs::circuit::Value::known(()),
                None,
            );

            let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi])?;
            fs::write(&out_path, ws.to_bytes()).context("write .nmbws")?;
            Ok(())
        }
        _ => Err(anyhow!("unsupported relation for export-witness-snapshot: {rel}")),
    }
}
