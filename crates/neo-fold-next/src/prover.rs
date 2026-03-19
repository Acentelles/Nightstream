//! Owns the explicit SuperNeo shard prove script.
//!
//! Ownership:
//! - sequences `Π_CCS -> Π_RLC -> Π_DEC`
//! - does not build VM/frontend step relations
//! - does not own sibling-family proofs

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsStructure, Mat};
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::api::{
    dec_children_with_commit, prove, rlc_with_commit, sample_rot_rhos_n_typed, split_b_matrix_k_with_nonzero_flags,
    FoldingMode, PiCcsProof, RotRing,
};
use neo_reductions::engines::utils;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::proof::{Carry, PiDecArtifact, PiRlcArtifact, StepInput, StepProof, StepResult};

#[derive(Clone, Copy)]
pub struct CommitmentMixers<MR, MB>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    pub mix_rhos_commits: MR,
    pub combine_b_pows: MB,
}

pub struct ShardProver;

impl ShardProver {
    pub fn prove_step<L, MR, MB>(
        mode: FoldingMode,
        tr: &mut Poseidon2Transcript,
        params: &NeoParams,
        s: &CcsStructure<F>,
        step: &StepInput,
        incoming_main: &Carry,
        log: &L,
        mixers: CommitmentMixers<MR, MB>,
    ) -> Result<StepResult, PiCcsError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
        MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
        MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
    {
        validate_main_carry("prove_step", incoming_main)?;
        tr.append_message(b"neo.fold.next/step", step.label.as_bytes());

        let (ccs_outputs, ccs_proof) = prove(
            mode.clone(),
            tr,
            params,
            s,
            core::slice::from_ref(&step.mcs),
            core::slice::from_ref(&step.witness),
            &incoming_main.claims,
            &incoming_main.witnesses,
            log,
        )?;
        validate_ccs_outputs(step, incoming_main, &ccs_outputs, &ccs_proof)?;

        let dims = utils::build_dims_and_policy(params, s)?;
        let rlc_rhos = sample_rlc_rhos(tr, params, ccs_outputs.len())?;

        let mut rlc_inputs_wit = Vec::with_capacity(1 + incoming_main.witnesses.len());
        rlc_inputs_wit.push(step.witness.Z.clone());
        rlc_inputs_wit.extend(incoming_main.witnesses.iter().cloned());

        let (parent, z_mix) = rlc_with_commit(
            mode.clone(),
            s,
            params,
            &rlc_rhos,
            &ccs_outputs,
            &rlc_inputs_wit,
            dims.ell_d,
            mixers.mix_rhos_commits,
        )?;

        let k_dec = params.k_rho as usize;
        let (z_split, digit_nonzero) = split_b_matrix_k_with_nonzero_flags(&z_mix, k_dec, params.b)?;
        let child_commitments = commit_split_children(log, &z_split, &digit_nonzero)?;
        let (children, ok_y, ok_x, ok_c) = dec_children_with_commit(
            mode,
            s,
            params,
            &parent,
            &z_split,
            dims.ell_d,
            &child_commitments,
            mixers.combine_b_pows,
        );
        if !(ok_y && ok_x && ok_c) {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_DEC public checks failed for step '{}': y={}, X={}, c={}",
                step.label, ok_y, ok_x, ok_c
            )));
        }

        Ok(StepResult {
            proof: StepProof {
                step: step.instance(),
                ccs_outputs,
                ccs_proof,
                rlc: PiRlcArtifact { rhos: rlc_rhos, parent },
                dec: PiDecArtifact {
                    children: children.clone(),
                },
            },
            next_main: Carry {
                claims: children,
                witnesses: z_split,
            },
        })
    }
}

fn validate_main_carry(context: &str, carry: &Carry) -> Result<(), PiCcsError> {
    if carry.claims.len() != carry.witnesses.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "{context}: |claims|={} != |witnesses|={}",
            carry.claims.len(),
            carry.witnesses.len()
        )));
    }
    Ok(())
}

fn validate_ccs_outputs(
    step: &StepInput,
    incoming_main: &Carry,
    ccs_outputs: &[neo_ccs::CeClaim<Commitment, F, K>],
    ccs_proof: &PiCcsProof,
) -> Result<(), PiCcsError> {
    let expected = 1usize
        .checked_add(incoming_main.claims.len())
        .ok_or_else(|| PiCcsError::InvalidInput("Π_CCS output count overflow".into()))?;
    if ccs_outputs.len() != expected {
        return Err(PiCcsError::ProtocolError(format!(
            "Π_CCS returned {} outputs for step '{}', expected {}",
            ccs_outputs.len(),
            step.label,
            expected
        )));
    }
    let digest: [u8; 32] = ccs_proof
        .header_digest
        .as_slice()
        .try_into()
        .map_err(|_| PiCcsError::ProtocolError("Π_CCS header digest must be 32 bytes".into()))?;
    for (idx, out) in ccs_outputs.iter().enumerate() {
        if out.fold_digest != digest {
            return Err(PiCcsError::ProtocolError(format!(
                "Π_CCS output[{idx}] fold_digest mismatch for step '{}'",
                step.label
            )));
        }
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

fn commit_split_children<L>(log: &L, z_split: &[Mat<F>], digit_nonzero: &[bool]) -> Result<Vec<Commitment>, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
{
    if z_split.len() != digit_nonzero.len() {
        return Err(PiCcsError::InvalidInput(format!(
            "DEC split mismatch: |Z_split|={} != |digit_nonzero|={}",
            z_split.len(),
            digit_nonzero.len()
        )));
    }
    if z_split.is_empty() {
        return Err(PiCcsError::InvalidInput(
            "DEC requires at least one child witness".into(),
        ));
    }

    let zero = log.commit(&Mat::zero(z_split[0].rows(), z_split[0].cols(), F::ZERO));
    let mut child_commitments = vec![zero.clone(); z_split.len()];
    let nonzero_idx: Vec<usize> = digit_nonzero
        .iter()
        .enumerate()
        .filter_map(|(idx, &nz)| nz.then_some(idx))
        .collect();
    if nonzero_idx.is_empty() {
        return Ok(child_commitments);
    }

    let mats: Vec<&Mat<F>> = nonzero_idx.iter().map(|&idx| &z_split[idx]).collect();
    let commits = log.commit_many(&mats);
    if commits.len() != mats.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "DEC commit_many returned {} commitments for {} matrices",
            commits.len(),
            mats.len()
        )));
    }
    for (pos, &idx) in nonzero_idx.iter().enumerate() {
        child_commitments[idx] = commits[pos].clone();
    }
    Ok(child_commitments)
}
