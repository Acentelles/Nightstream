//! Owns the exact Stage 3 row-local export surface used by the Lean staged digest.

use neo_math::{from_complex, F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::{Chip8Program, CHIP8_PROGRAM_START, COL_BURST_LAST, COL_IS_MEMOP, COL_PC_NEXT, COL_X_IDX};
use crate::chip8::tables::{build_alu_table, build_decode_table, build_eq4_table, build_rom_table};
use crate::chip8::{stage1, stage2};
use crate::proof::StepInput;

use super::bridge_binding::prepared_step_digest;
use super::public_meta::{absorb_root0, new_simple_kernel_transcript};
use super::root_context::build_prepared_steps_from_frames;
use super::{
    build_kernel_exact_frames, CommitmentId, KernelExactFrame, RowBindingClaim, SimpleKernelError, SimpleKernelOutput,
    SimpleKernelProof, SimpleKernelPublicInput,
};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KernelStage3LaneColumn {
    Pc,
    XIdx,
    IsMemOp,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum KernelStage3ShiftedColumn {
    ShiftPc,
    ShiftXIdx,
    ShiftIsMemOp,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3ShiftClaim {
    pub source_commitment: CommitmentId,
    pub source_point: Vec<K>,
    pub source_columns: [KernelStage3LaneColumn; 3],
    pub shifted_columns: [KernelStage3ShiftedColumn; 3],
    pub claimed_shift_values: [K; 3],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3ShiftWitness {
    pub shift_pc: K,
    pub shift_x_idx: K,
    pub shift_is_memop: K,
    pub reduction_rounds: Vec<Vec<K>>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3CurrentRow {
    pub row_index: usize,
    pub pair_mask: F,
    pub pc_next: F,
    pub x_idx: F,
    pub is_memop: F,
    pub burst_last: F,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage3RowClaim {
    pub row_index: usize,
    pub row_bits: Vec<bool>,
    pub opened_values: Vec<K>,
}

#[derive(Clone, Debug)]
pub struct KernelStage3DigestSurface {
    pub step_idx: usize,
    pub n: usize,
    pub beta1: K,
    pub beta2: K,
    pub shift_claim: KernelStage3ShiftClaim,
    pub shift_proof: KernelStage3ShiftWitness,
    pub current_row: KernelStage3CurrentRow,
    pub row_claim: KernelStage3RowClaim,
    pub prepared_step: StepInput,
}

impl PartialEq for KernelStage3DigestSurface {
    fn eq(&self, other: &Self) -> bool {
        self.step_idx == other.step_idx
            && self.n == other.n
            && self.beta1 == other.beta1
            && self.beta2 == other.beta2
            && self.shift_claim == other.shift_claim
            && self.shift_proof == other.shift_proof
            && self.current_row == other.current_row
            && self.row_claim == other.row_claim
            && prepared_step_digest(&self.prepared_step) == prepared_step_digest(&other.prepared_step)
    }
}

pub fn build_kernel_stage3_digest_surfaces(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
) -> Result<Vec<KernelStage3DigestSurface>, SimpleKernelError> {
    let frames = build_kernel_exact_frames(public, proof)?;
    build_kernel_stage3_digest_surfaces_from_frames(public, proof, output, &frames)
}

pub(crate) fn build_kernel_stage3_digest_surfaces_from_frames(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    frames: &[KernelExactFrame],
) -> Result<Vec<KernelStage3DigestSurface>, SimpleKernelError> {
    let prepared_steps = build_prepared_steps_from_frames(&frames)?;
    assert_prepared_steps_match_output(&prepared_steps, &output.prepared_steps)?;
    let (beta1, beta2, expected_shift_point) = replay_stage3_challenges(public, proof)?;
    if proof.stage3.shift_proof.source_point != expected_shift_point {
        return Err(SimpleKernelError::ContinuityFailed(
            "stage3 digest shift point does not match canonical transcript replay".into(),
        ));
    }
    if proof.stage3.row_bindings.len() != frames.len() {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "stage3 digest row-binding count {} != frame count {}",
            proof.stage3.row_bindings.len(),
            frames.len()
        )));
    }

    let n = proof.meta_pub.semantic_rows;
    let shift_claim = build_shift_claim(proof);
    let shift_proof = build_shift_witness(proof);
    frames
        .iter()
        .zip(proof.stage3.row_bindings.iter())
        .zip(prepared_steps.into_iter())
        .map(|((frame, row_claim), prepared_step)| {
            build_stage3_digest_surface(
                frame,
                n,
                beta1,
                beta2,
                &shift_claim,
                &shift_proof,
                row_claim,
                prepared_step,
            )
        })
        .collect()
}

pub fn verify_kernel_stage3_digest_surfaces(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    surfaces: &[KernelStage3DigestSurface],
) -> Result<(), String> {
    let expected = build_kernel_stage3_digest_surfaces(public, proof, output)
        .map_err(|err| format!("stage3 digest build failed: {err}"))?;
    if surfaces != expected.as_slice() {
        return Err("stage3 digest surface mismatch".into());
    }
    Ok(())
}

fn build_stage3_digest_surface(
    frame: &KernelExactFrame,
    n: usize,
    beta1: K,
    beta2: K,
    shift_claim: &KernelStage3ShiftClaim,
    shift_proof: &KernelStage3ShiftWitness,
    row_claim: &RowBindingClaim,
    prepared_step: StepInput,
) -> Result<KernelStage3DigestSurface, SimpleKernelError> {
    if row_claim.row_index != frame.step_idx {
        return Err(SimpleKernelError::ContinuityFailed(format!(
            "stage3 digest row claim index {} != frame step {}",
            row_claim.row_index, frame.step_idx
        )));
    }
    Ok(KernelStage3DigestSurface {
        step_idx: frame.step_idx,
        n,
        beta1,
        beta2,
        shift_claim: shift_claim.clone(),
        shift_proof: shift_proof.clone(),
        current_row: KernelStage3CurrentRow {
            row_index: frame.step_idx,
            pair_mask: pair_mask(n, frame.step_idx),
            pc_next: frame.row[COL_PC_NEXT],
            x_idx: frame.row[COL_X_IDX],
            is_memop: frame.row[COL_IS_MEMOP],
            burst_last: frame.row[COL_BURST_LAST],
        },
        row_claim: KernelStage3RowClaim {
            row_index: row_claim.row_index,
            row_bits: row_claim.row_bits.clone(),
            opened_values: row_claim.opened_values.clone(),
        },
        prepared_step,
    })
}

fn build_shift_claim(proof: &SimpleKernelProof) -> KernelStage3ShiftClaim {
    KernelStage3ShiftClaim {
        source_commitment: CommitmentId::Lane,
        source_point: proof.stage3.shift_proof.source_point.clone(),
        source_columns: [
            KernelStage3LaneColumn::Pc,
            KernelStage3LaneColumn::XIdx,
            KernelStage3LaneColumn::IsMemOp,
        ],
        shifted_columns: [
            KernelStage3ShiftedColumn::ShiftPc,
            KernelStage3ShiftedColumn::ShiftXIdx,
            KernelStage3ShiftedColumn::ShiftIsMemOp,
        ],
        claimed_shift_values: proof.stage3.shift_proof.claimed_shift_values,
    }
}

fn build_shift_witness(proof: &SimpleKernelProof) -> KernelStage3ShiftWitness {
    KernelStage3ShiftWitness {
        shift_pc: proof.stage3.shift_proof.claimed_shift_values[0],
        shift_x_idx: proof.stage3.shift_proof.claimed_shift_values[1],
        shift_is_memop: proof.stage3.shift_proof.claimed_shift_values[2],
        reduction_rounds: proof.stage3.shift_proof.reduction_rounds.clone(),
    }
}

fn replay_stage3_challenges(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
) -> Result<(K, K, Vec<K>), SimpleKernelError> {
    let program = Chip8Program {
        bytes: public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let rom_table = build_rom_table(&program, proof.meta_pub.pad_pc_word);
    let decode_table = build_decode_table();
    let alu_table = build_alu_table();
    let eq4_table = build_eq4_table();

    let mut transcript = new_simple_kernel_transcript(&public.transcript_seed);
    absorb_root0(&mut transcript, &proof.commitments, &proof.meta_pub);
    stage1::verify_stage1(
        &proof.stage1,
        &rom_table,
        &decode_table,
        &alu_table,
        &eq4_table,
        proof.meta_pub.cycle_bits,
        None,
        &mut transcript,
    )
    .map_err(SimpleKernelError::ContinuityFailed)?;
    stage2::verify_stage2(
        &proof.stage2,
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
        proof.meta_pub.cycle_bits,
        &mut transcript,
    )?;
    let beta1 = squeeze_k(&mut transcript, b"stage3/beta1");
    let beta2 = squeeze_k(&mut transcript, b"stage3/beta2");
    let shift_point = squeeze_point(&mut transcript, b"stage3/r_shift", proof.meta_pub.cycle_bits);
    Ok((beta1, beta2, shift_point))
}

fn pair_mask(n: usize, row_index: usize) -> F {
    if row_index + 1 < n {
        F::ONE
    } else {
        F::ZERO
    }
}

fn assert_prepared_steps_match_output(expected: &[StepInput], actual: &[StepInput]) -> Result<(), SimpleKernelError> {
    if expected.len() != actual.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 digest prepared-step count {} != output {}",
            expected.len(),
            actual.len()
        )));
    }
    for (step_idx, (expected_step, actual_step)) in expected.iter().zip(actual.iter()).enumerate() {
        if prepared_step_digest(expected_step) != prepared_step_digest(actual_step) {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "stage3 digest prepared step {} mismatches output",
                step_idx
            )));
        }
    }
    Ok(())
}

fn squeeze_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

fn squeeze_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n).map(|_| squeeze_k(tr, label)).collect()
}
