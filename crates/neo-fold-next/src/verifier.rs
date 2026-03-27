//! Owns the explicit SuperNeo shard verify script.
//!
//! This mirrors the real `Π_CCS -> Π_RLC -> Π_DEC` spine.

use neo_ajtai::Commitment;
use neo_ccs::CcsStructure;
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::api::{
    rlc_public_matches, sample_rot_rhos_n_typed, verify, verify_dec_public, FoldingMode, RotRing,
};
use neo_reductions::engines::utils;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::proof::{PublicStep, StepProof};
use crate::prover::CommitmentMixers;

pub struct ShardVerifier;

impl ShardVerifier {
    pub fn verify_step<'a, MR, MB>(
        mode: FoldingMode,
        tr: &mut Poseidon2Transcript,
        params: &NeoParams,
        s: &CcsStructure<F>,
        step: &PublicStep,
        incoming_main: &[neo_ccs::CeClaim<Commitment, F, K>],
        proof: &'a StepProof,
        mixers: CommitmentMixers<MR, MB>,
    ) -> Result<&'a [neo_ccs::CeClaim<Commitment, F, K>], PiCcsError>
    where
        MR: Fn(&[neo_ccs::Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
        MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
    {
        validate_step_metadata(step, proof)?;
        tr.append_message(b"neo.fold.next/step", step.label.as_bytes());

        let ok_ccs = verify(
            mode,
            tr,
            params,
            s,
            core::slice::from_ref(&step.mcs),
            incoming_main,
            &proof.ccs_outputs,
            &proof.ccs_proof,
        )?;
        if !ok_ccs {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_CCS verification failed for step '{}'",
                step.label
            )));
        }

        let observed_digest = tr.digest32();
        if proof.ccs_proof.header_digest.as_slice() != observed_digest {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_CCS header digest mismatch for step '{}'",
                step.label
            )));
        }
        for (idx, out) in proof.ccs_outputs.iter().enumerate() {
            if out.fold_digest != observed_digest {
                return Err(PiCcsError::ProtocolError(format!(
                    "Π_CCS output[{idx}] fold_digest mismatch for step '{}'",
                    step.label
                )));
            }
        }

        let dims = utils::build_dims_and_policy(params, s)?;
        let expected_rhos = sample_rlc_rhos(tr, params, proof.ccs_outputs.len())?;
        if expected_rhos != proof.rlc.rhos {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_RLC challenge mismatch for step '{}'",
                step.label
            )));
        }

        let parent_matches = rlc_public_matches(
            s,
            params,
            &proof.rlc.rhos,
            &proof.ccs_outputs,
            &proof.rlc.parent,
            mixers.mix_rhos_commits,
            dims.ell_d,
        )?;
        if !parent_matches {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_RLC public recompute mismatch for step '{}'",
                step.label
            )));
        }

        if !verify_dec_public(
            s,
            params,
            &proof.rlc.parent,
            &proof.dec.children,
            mixers.combine_b_pows,
            dims.ell_d,
        ) {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_DEC public verification failed for step '{}'",
                step.label
            )));
        }

        Ok(&proof.dec.children)
    }
}

fn validate_step_metadata(step: &PublicStep, proof: &StepProof) -> Result<(), PiCcsError> {
    if proof.step.label != step.label {
        return Err(PiCcsError::InvalidInput(format!(
            "proof step label mismatch: expected '{}', got '{}'",
            step.label, proof.step.label
        )));
    }
    if proof.step.mcs.m_in != step.mcs.m_in || proof.step.mcs.x != step.mcs.x || proof.step.mcs.c != step.mcs.c {
        return Err(PiCcsError::InvalidInput(format!(
            "public MCS mismatch for step '{}'",
            step.label
        )));
    }
    if proof.ccs_outputs.is_empty() {
        return Err(PiCcsError::InvalidInput(format!(
            "missing Π_CCS outputs for step '{}'",
            step.label
        )));
    }
    Ok(())
}

fn sample_rlc_rhos(
    tr: &mut Poseidon2Transcript,
    params: &NeoParams,
    input_count: usize,
) -> Result<Vec<neo_reductions::api::RotRho>, PiCcsError> {
    let ring = RotRing::goldilocks();
    sample_rot_rhos_n_typed(tr, params, &ring, input_count)
}
