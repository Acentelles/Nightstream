use anyhow::Context;
use neo_midnight_bridge::relations::GoldilocksMulRelation;
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use midnight_proofs::poly::commitment::PolynomialCommitmentScheme;
use midnight_proofs::poly::{kzg::KZGCommitmentScheme, LagrangeCoeff, Polynomial};
use midnight_proofs::utils::SerdeFormat;
use midnight_curves::pairing::group::ff::PrimeField;
use midnight_curves::pairing::group::GroupEncoding;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

type E = midnight_curves::Bls12;
type ParamsKZG = midnight_proofs::poly::kzg::params::ParamsKZG<E>;

#[test]
fn mojo_kzg_commit_lagrange_matches_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    // Export a small package (GoldilocksMul has a small k).
    let rel = GoldilocksMulRelation;
    let pkg = export_package_v3(
        RelationKind::GoldilocksMul,
        &RelationParamsV1::GoldilocksMul { version: 1 },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;

    let n = 1usize << pkg.k;
    assert_eq!(params.g_lagrange().len(), n);

    // Deterministic scalars in Lagrange form.
    let mut poly = Polynomial::<midnight_curves::Fq, LagrangeCoeff>::init(n);
    poly[0] = midnight_curves::Fq::from(1u64);

    // Write inputs/outputs to a temp dir.
    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("goldilocks_mul.nmbp");
    let scalars_path = dir.join("scalars.bin");
    let out_path = dir.join("commitment.bin");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;

    // scalars.bin: u32 count + count*32 bytes (Fq::to_repr()).
    let mut scalars_bytes = Vec::with_capacity(4 + n * 32);
    scalars_bytes.extend_from_slice(&(n as u32).to_le_bytes());
    for s in poly.iter() {
        scalars_bytes.extend_from_slice(s.to_repr().as_ref());
    }
    fs::write(&scalars_path, scalars_bytes).context("write scalars")?;

    // Run Mojo to compute commitment using g_lagrange.
    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/kzg_commit_lagrange.mojo");

    let status = Command::new("mojo")
        .args([
            "run",
            mojo_prog.to_str().unwrap(),
            pkg_path.to_str().unwrap(),
            scalars_path.to_str().unwrap(),
            out_path.to_str().unwrap(),
        ])
        .status()
        .context("run mojo kzg_commit_lagrange")?;
    assert!(status.success(), "mojo kzg_commit_lagrange failed");

    let mojo_commit = fs::read(&out_path).context("read mojo output")?;
    assert_eq!(mojo_commit.len(), 48, "expected compressed G1 (48 bytes)");

    // Rust reference commitment.
    let rust_commit = KZGCommitmentScheme::<E>::commit_lagrange(&params, &poly);
    let rust_bytes = rust_commit.to_bytes();

    assert_eq!(mojo_commit.as_slice(), rust_bytes.as_ref());
    Ok(())
}
