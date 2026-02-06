use anyhow::Context;
use midnight_curves::pairing::group::ff::PrimeField;
use midnight_proofs::poly::EvaluationDomain;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

#[test]
fn mojo_fft_lagrange_to_coeff_matches_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let k: u32 = 9;
    let n = 1usize << k;

    let mut evals = Vec::with_capacity(n);
    for i in 0..n {
        let v = (i as u64).wrapping_mul(7).wrapping_add(11);
        evals.push(midnight_curves::Fq::from(v));
    }

    let domain = EvaluationDomain::<midnight_curves::Fq>::new(3, k);
    let coeffs = domain.lagrange_to_coeff(domain.lagrange_from_vec(evals.clone()));

    // Write inputs/outputs to a temp dir.
    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let in_path = dir.join("lagrange.bin");
    let out_path = dir.join("coeff.bin");

    let mut in_bytes = Vec::with_capacity(4 + n * 32);
    in_bytes.extend_from_slice(&(n as u32).to_le_bytes());
    for e in evals.iter() {
        in_bytes.extend_from_slice(e.to_repr().as_ref());
    }
    fs::write(&in_path, in_bytes).context("write lagrange.bin")?;

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let mojo_prog = manifest_dir.join("mojo/fft_lagrange_to_coeff.mojo");

    let status = Command::new("mojo")
        .args([
            "run",
            mojo_prog.to_str().unwrap(),
            in_path.to_str().unwrap(),
            out_path.to_str().unwrap(),
        ])
        .status()
        .context("run mojo fft_lagrange_to_coeff")?;
    assert!(status.success(), "mojo fft_lagrange_to_coeff failed");

    let out = fs::read(&out_path).context("read coeff.bin")?;
    let count_bytes: [u8; 4] = out
        .get(0..4)
        .ok_or_else(|| anyhow::anyhow!("output too short"))?
        .try_into()
        .unwrap();
    let count = u32::from_le_bytes(count_bytes) as usize;
    assert_eq!(count, n, "output count mismatch");

    let payload = out
        .get(4..)
        .ok_or_else(|| anyhow::anyhow!("missing payload"))?;
    assert_eq!(payload.len(), n * 32, "output payload length mismatch");

    // Rust reference output.
    let mut expected = Vec::with_capacity(n * 32);
    for c in coeffs.iter() {
        expected.extend_from_slice(c.to_repr().as_ref());
    }
    assert_eq!(payload, expected.as_slice());
    Ok(())
}
