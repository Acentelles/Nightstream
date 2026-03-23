//! Owns the run-level SuperNeo driver.
//!
//! This layer threads the main carry and transcript across prepared steps.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsStructure, CeClaim, Mat};
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_reductions::error::PiCcsError;
use neo_reductions::optimized_engine::OptimizedStructureCache;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::finalize::{package_session_proof, verify_finalized_session};
use crate::proof::{Carry, PackagedProof, PublicStep, RunProof, StepInput};
use crate::prover::{CommitmentMixers, ShardProver};
use crate::verifier::ShardVerifier;

pub fn prove_steps<L, MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    steps: impl IntoIterator<Item = StepInput>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<RunProof, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/session");
    let mut main_carry = Carry::default();
    let mut session = RunProof::default();
    let optimized_cache = if matches!(mode, FoldingMode::Optimized) {
        Some(OptimizedStructureCache::build(s)?)
    } else {
        None
    };

    for step in steps {
        let proved = ShardProver::prove_step(
            mode.clone(),
            &mut tr,
            params,
            s,
            &step,
            &main_carry,
            log,
            mixers,
            optimized_cache.as_ref(),
        )?;
        main_carry = proved.next_main;
        session.steps.push(proved.proof);
        tr.append_message(b"neo.fold.next/step_done", &[1]);
    }

    session.final_main_claims = main_carry.claims;
    Ok(session)
}

pub fn verify_steps<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    steps: impl IntoIterator<Item = PublicStep>,
    proof: &RunProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/session");
    let mut main_carry: Vec<CeClaim<Commitment, F, K>> = Vec::new();
    let mut steps_iter = steps.into_iter();

    for (idx, step_proof) in proof.steps.iter().enumerate() {
        let step = steps_iter
            .next()
            .ok_or_else(|| PiCcsError::InvalidInput(format!("missing public step {idx} during verification")))?;
        main_carry =
            ShardVerifier::verify_step(mode.clone(), &mut tr, params, s, &step, &main_carry, step_proof, mixers)?;
        tr.append_message(b"neo.fold.next/step_done", &[1]);
    }
    if steps_iter.next().is_some() {
        return Err(PiCcsError::InvalidInput(
            "public step list is longer than proof step list".into(),
        ));
    }
    if main_carry != proof.final_main_claims {
        return Err(PiCcsError::ProtocolError(
            "final carried main claims do not match proof footer".into(),
        ));
    }
    Ok(main_carry)
}

pub fn prove_finalized_steps<L, MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    steps: impl IntoIterator<Item = StepInput>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<PackagedProof, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let steps_vec: Vec<StepInput> = steps.into_iter().collect();
    let session = prove_steps(mode, params, s, steps_vec.clone(), log, mixers)?;
    let public_steps = steps_vec.into_iter().map(|step| step.instance()).collect();
    package_session_proof(public_steps, session)
}

pub fn verify_finalized_steps<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    proof: &PackagedProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    verify_finalized_session(mode, params, s, proof, mixers)
}

// Aliases for newer naming convention.
pub use prove_finalized_steps as prove_and_package;
pub use prove_steps as prove_run;
pub use verify_finalized_steps as verify_packaged;
pub use verify_steps as verify_run;
