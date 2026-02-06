use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::circuit::Value;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use midnight_zk_stdlib::Relation;
use neo_math::{KExtensions, D};
use neo_midnight_bridge::k_field::KRepr;
use neo_midnight_bridge::relations::{
    PiCcsFeTerminalK1Instance, PiCcsFeTerminalK1Relation, PiCcsFeTerminalK1Witness, SparsePolyRepr, SparsePolyTermRepr,
};
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::nmbws::export_witness_snapshot_v2;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use p3_field::PrimeField64;
use std::fs;
use std::path::PathBuf;
use std::process::Command;

fn k_to_repr(k: &neo_math::K) -> KRepr {
    let (c0, c1) = k.to_limbs_u64();
    KRepr { c0, c1 }
}

#[test]
#[ignore = "poseidon2 batch_1 snapshot parity; run with --ignored --nocapture"]
fn mojo_plonk_pi_ccs_terminal_fe_k1_poseidon2_batch_1_from_snapshot_verifies_in_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    let json_path = manifest_dir.join("../neo-fold/poseidon2-tests/poseidon2_ic_circuit_batch_1.json");
    let json = fs::read_to_string(&json_path).context("read poseidon2 batch-1 json")?;
    let export = neo_fold::test_export::parse_test_export_json(&json).context("parse test-export json")?;

    // Repeat the single witness vector to keep the overall workload similar to the Rust tests.
    // This relation targets step 0 (k=1, no ME inputs).
    let target_folding_steps: usize = 2;
    let mut session = neo_fold::test_export::TestExportSession::new_from_circuit_json(&json)
        .map_err(|e| anyhow::anyhow!("session init failed: {e}"))?;
    for i in 0..target_folding_steps {
        let z = &export.witness[i % export.witness.len()];
        session
            .add_step_witness_u64(z)
            .map_err(|e| anyhow::anyhow!("add witness step failed: {e}"))?;
    }

    let (fold_run, _step_ms) = session
        .fold_and_prove_with_step_timings()
        .map_err(|e| anyhow::anyhow!("fold_and_prove failed: {e}"))?;
    assert_eq!(fold_run.steps.len(), target_folding_steps);
    assert!(session
        .verify(&fold_run)
        .map_err(|e| anyhow::anyhow!("verify failed: {e}"))?);

    let s = session.ccs();
    let n_pad = s.n.next_power_of_two().max(2);
    let ell_n = n_pad.trailing_zeros() as usize;
    let d_pad = D.next_power_of_two();
    let ell_d = d_pad.trailing_zeros() as usize;
    assert!(ell_n > 0);
    assert!(ell_d > 0);

    // Take the first step (k=1) Pi-CCS proof + its first output ME instance.
    let step0 = &fold_run.steps[0];
    let pi = &step0.fold.ccs_proof;
    assert_eq!(
        step0.fold.ccs_out.len(),
        1,
        "expected k=1 (no initial accumulator) for step 0"
    );
    let out0 = &step0.fold.ccs_out[0];

    // Extract (r', α') from FE sumcheck challenges.
    assert_eq!(
        pi.sumcheck_challenges.len(),
        ell_n + ell_d,
        "expected sumcheck_challenges = r' || α' with lengths (ell_n, ell_d)"
    );
    let (r_prime, alpha_prime) = pi.sumcheck_challenges.split_at(ell_n);
    assert_eq!(alpha_prime.len(), ell_d);

    // Extract β = (β_a, β_r).
    assert_eq!(pi.challenges_public.beta_a.len(), ell_d);
    assert_eq!(pi.challenges_public.beta_r.len(), ell_n);

    // Encode the CCS sparse polynomial f as (u64 coeffs, u32 exps).
    let poly_terms: Vec<SparsePolyTermRepr> =
        s.f.terms()
            .iter()
            .map(|t| SparsePolyTermRepr {
                coeff: t.coeff.as_canonical_u64(),
                exps: t.exps.clone(),
            })
            .collect();
    let poly = SparsePolyRepr {
        t: s.t(),
        terms: poly_terms,
    };

    let rel = PiCcsFeTerminalK1Relation { ell_n, ell_d, poly };

    // Public statement = FE sumcheck final running sum.
    let instance = PiCcsFeTerminalK1Instance {
        final_sum: k_to_repr(&pi.sumcheck_final),
    };

    let witness = PiCcsFeTerminalK1Witness {
        r_prime: r_prime.iter().map(k_to_repr).collect(),
        alpha_prime: alpha_prime.iter().map(k_to_repr).collect(),
        beta_a: pi.challenges_public.beta_a.iter().map(k_to_repr).collect(),
        beta_r: pi.challenges_public.beta_r.iter().map(k_to_repr).collect(),
        y_scalars: out0.y_scalars.iter().map(k_to_repr).collect(),
    };

    let pkg = export_package_v3(
        RelationKind::PiCcsFeTerminalK1,
        &RelationParamsV1::PiCcsFeTerminalK1 {
            version: 1,
            ell_n,
            ell_d,
            poly: rel.poly.clone(),
        },
        &rel,
        [0x42u8; 32],
    )
    .context("export_package_v3")?;

    let pi = PiCcsFeTerminalK1Relation::format_instance(&instance).expect("format_instance");
    let com_inst = PiCcsFeTerminalK1Relation::format_committed_instances(&witness);
    let circuit = midnight_zk_stdlib::MidnightCircuit::new(
        &rel,
        Value::known(instance.clone()),
        Value::known(witness),
        None,
    );
    let ws = export_witness_snapshot_v2(pkg.k, &circuit, vec![com_inst, pi]).expect("export_witness_snapshot_v2");

    let dir = std::env::temp_dir().join(format!("neo-midnight-mojo-bridge-{}", std::process::id()));
    let _ = fs::remove_dir_all(&dir);
    fs::create_dir_all(&dir).context("create temp dir")?;

    let pkg_path = dir.join("pi_ccs_terminal_fe_k1.nmbp");
    let ws_path = dir.join("pi_ccs_terminal_fe_k1.nmbws");
    let proof_path = dir.join("pi_ccs_terminal_fe_k1.proof.bin");
    fs::write(&pkg_path, pkg.to_bytes()).context("write pkg")?;
    fs::write(&ws_path, ws.to_bytes()).context("write ws")?;

    let mojo_prog = manifest_dir.join("mojo/plonk_prove_from_snapshot.mojo");
    let status = Command::new("mojo")
        .args([
            "run",
            mojo_prog.to_str().unwrap(),
            pkg_path.to_str().unwrap(),
            ws_path.to_str().unwrap(),
            proof_path.to_str().unwrap(),
        ])
        .status()
        .context("run mojo plonk_prove_from_snapshot")?;
    assert!(status.success(), "mojo plonk_prove_from_snapshot failed");

    let proof = fs::read(&proof_path).context("read proof")?;

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params: ParamsKZG<Bls12> = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;
    let params_v = params.verifier_params();
    let vk = midnight_zk_stdlib::setup_vk(&params, &rel);

    midnight_zk_stdlib::verify::<PiCcsFeTerminalK1Relation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
        .expect("verify");
    Ok(())
}
