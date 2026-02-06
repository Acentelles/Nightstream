use anyhow::Context;
use blake2b_simd::State as Blake2bState;
use neo_midnight_bridge::relations::GoldilocksMulRelation;
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use midnight_proofs::poly::commitment::Guard;
use midnight_proofs::poly::commitment::PolynomialCommitmentScheme;
use midnight_proofs::poly::kzg::KZGCommitmentScheme;
use midnight_proofs::poly::VerifierQuery;
use midnight_proofs::transcript::{CircuitTranscript, Transcript};
use midnight_proofs::utils::SerdeFormat;
use midnight_curves::pairing::Engine;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

type E = midnight_curves::Bls12;
type ParamsKZG = midnight_proofs::poly::kzg::params::ParamsKZG<E>;

#[test]
fn mojo_kzg_gwc_roundtrip_verifies_in_rust() -> anyhow::Result<()> {
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

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;
    let verifier_params = params.verifier_params();

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("goldilocks_mul.nmbp");
    let proof_path = dir.join("kzg_gwc_proof.bin");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/kzg_gwc_roundtrip.mojo");

    let status = Command::new("mojo")
        .args([
            "run",
            mojo_prog.to_str().unwrap(),
            pkg_path.to_str().unwrap(),
            proof_path.to_str().unwrap(),
        ])
        .status()
        .context("run mojo kzg_gwc_roundtrip")?;
    assert!(status.success(), "mojo kzg_gwc_roundtrip failed");

    let proof = fs::read(&proof_path).context("read proof")?;

    // Verify proof using Rust verifier (same transcript + verifier params).
    let mut transcript = CircuitTranscript::<Blake2bState>::init_from_bytes(&proof);

    let a: <E as Engine>::G1 = transcript.read().context("read a")?;
    let b: <E as Engine>::G1 = transcript.read().context("read b")?;
    let c: <E as Engine>::G1 = transcript.read().context("read c")?;

    let x: midnight_curves::Fq = transcript.squeeze_challenge();
    let y: midnight_curves::Fq = transcript.squeeze_challenge();

    let avx: midnight_curves::Fq = transcript.read().context("read avx")?;
    let bvx: midnight_curves::Fq = transcript.read().context("read bvx")?;
    let cvy: midnight_curves::Fq = transcript.read().context("read cvy")?;

    let queries = vec![
        VerifierQuery::new(x, &a, avx),
        VerifierQuery::new(x, &b, bvx),
        VerifierQuery::new(y, &c, cvy),
    ];

    let guard = KZGCommitmentScheme::<E>::multi_prepare(&queries, &mut transcript)
        .map_err(|e| anyhow::anyhow!("multi_prepare failed: {e:?}"))?;
    guard
        .verify(&verifier_params)
        .map_err(|e| anyhow::anyhow!("verify failed: {e:?}"))?;
    transcript.assert_empty().context("assert_empty")?;
    Ok(())
}
