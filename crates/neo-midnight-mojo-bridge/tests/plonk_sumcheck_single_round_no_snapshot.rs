use anyhow::Context;
use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use midnight_proofs::utils::SerdeFormat;
use neo_midnight_bridge::goldilocks::GOLDILOCKS_P_U64;
use neo_midnight_bridge::k_field::{host_k_eval_horner, host_sumcheck_round_claim, KRepr, K_DELTA_U64};
use neo_midnight_bridge::relations::SumcheckSingleRoundRelation;
use neo_midnight_bridge_artifacts::nmbp::export_package_v3;
use neo_midnight_bridge_artifacts::relation::{RelationKind, RelationParamsV1};
use std::process::Command;

#[test]
fn mojo_plonk_sumcheck_single_round_no_snapshot_verifies_in_rust() -> anyhow::Result<()> {
    // Skip if Mojo is not installed.
    if Command::new("mojo").arg("--version").output().is_err() {
        eprintln!("skipping: `mojo` not found in PATH");
        return Ok(());
    }

    let rel = SumcheckSingleRoundRelation { n_coeffs: 4 };
    let pkg = export_package_v3(
        RelationKind::SumcheckSingleRound,
        &RelationParamsV1::SumcheckSingleRound {
            version: 1,
            n_coeffs: rel.n_coeffs,
        },
        &rel,
        [0x42u8; 32],
    )
    .expect("export_package_v3");

    // Exercise carries + non-trivial quotient limbs.
    let coeffs: Vec<KRepr> = vec![
        KRepr {
            c0: GOLDILOCKS_P_U64 - 1,
            c1: 2,
        },
        KRepr {
            c0: 3,
            c1: GOLDILOCKS_P_U64 - 2,
        },
        KRepr {
            c0: GOLDILOCKS_P_U64 - 3,
            c1: 4,
        },
        KRepr {
            c0: 5,
            c1: GOLDILOCKS_P_U64 - 4,
        },
    ];
    let challenge = KRepr {
        c0: GOLDILOCKS_P_U64 - 5,
        c1: 6,
    };
    let claimed_sum = host_sumcheck_round_claim(&coeffs);
    let next_sum = host_k_eval_horner(&coeffs, challenge, K_DELTA_U64);

    let coeffs_pairs: Vec<(u64, u64)> = coeffs.iter().map(|c| (c.c0, c.c1)).collect();
    let proof = neo_midnight_mojo_bridge::prover::prove_sumcheck_single_round(
        &pkg.to_bytes(),
        &coeffs_pairs,
        (challenge.c0, challenge.c1),
        (claimed_sum.c0, claimed_sum.c1),
        (next_sum.c0, next_sum.c1),
    )
    .context("mojo prove sumcheck_single_round (no snapshot)")?;

    let mut params_reader: &[u8] = &pkg.params_bytes;
    let params: ParamsKZG<Bls12> = ParamsKZG::read_custom(&mut params_reader, SerdeFormat::RawBytesUnchecked)
        .context("ParamsKZG::read_custom")?;
    let params_v = params.verifier_params();
    let vk = midnight_zk_stdlib::setup_vk(&params, &rel);

    midnight_zk_stdlib::verify::<SumcheckSingleRoundRelation, TranscriptHash>(&params_v, &vk, &(), None, &proof)
        .expect("verify");
    Ok(())
}

