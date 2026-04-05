//! Owns the witness-backed CHIP-8 kernel execution relation rebuild and verification path.

use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::chip8::spec::COL_PC;
use crate::chip8::stage3::RowBindingClaim;
use crate::chip8::Chip8State;
use crate::chip8::{stage1, stage2, stage3};
use crate::proof::{ChunkInput, PublicChunk, StepInput};
use crate::time_opening::prove_time_opening;

use super::artifacts::build_prepared_step_from_row_binding;
use super::bridge::{
    expected_row_binding_claim_digest, Chip8BridgeChunkRelationWitness, Chip8BridgeRowWitness,
    KernelBridgeChunkAuthSource,
};
use super::joint_opening::{build_kernel_joint_opening_fold_bucket_proofs, build_kernel_joint_opening_summary};
use super::lane_commitment::{KernelCommitmentSets, KernelOpeningProofSets};
use super::openings::{build_kernel_opening_refinement_summary, time_opening_claims};
use super::public_meta::{absorb_root0, new_simple_kernel_transcript};
use super::stage_terminal::{
    verify_kernel_stage1_sumcheck_terminals_from_execution, verify_kernel_stage2_sumcheck_terminals_from_execution,
    verify_kernel_stage3_sumcheck_terminal_from_execution,
};
use super::transcript::emit_kernel_opening_artifacts_to_transcript;
use super::{
    advance_chip8_bridge_state, build_chip8_bridge_final_state_from_bridge_source,
    build_kernel_bridge_chunk_auth_sources, build_kernel_exact_frames_from_relation_witness,
    build_kernel_opening_manifest, chip8_bridge_state_seed, cycle_bits_and_padded_trace_length_from_row_bindings,
    kernel_read_opening_surface_from_execution, kernel_shift_opening_surface_from_execution,
    kernel_twist_opening_surface_from_execution, reconstruct_trace_rows_and_aux,
    recover_row_bindings_from_bridge_chunk_transitions, simple_kernel_root_opening_manifest,
    KernelExecutionRelationWitness, KernelJointOpeningFoldBucketProof, KernelJointOpeningSummary,
    KernelOpeningManifest, KernelOpeningRefinementSummary, KernelStepAux, SimpleKernelError, SimpleKernelOutput,
    SimpleKernelPublicInput, SimpleKernelRootContext, SimpleKernelVerifierInput, CHIP8_BRIDGE_ROWS_PER_CHUNK,
};

#[derive(Clone, Debug)]
pub struct VerifiedKernelChunkHandoff {
    pub chunk_input: ChunkInput,
    pub public_chunk: PublicChunk,
    pub bridge_handoff: Chip8BridgeChunkHandoff,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Chip8PreparedStepBridgeBinding {
    pub row_index: usize,
    pub row_binding_claim_digest: [u8; 32],
    pub prepared_step_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Chip8BridgeChunkHandoff {
    pub previous_state: [u8; 32],
    pub next_state: [u8; 32],
    pub witness_digest: [u8; 32],
    pub step_bindings: [Option<Chip8PreparedStepBridgeBinding>; CHIP8_BRIDGE_ROWS_PER_CHUNK],
}

#[derive(Clone, Debug)]
pub struct KernelExecutionRelationResult {
    pub prepared_steps: Vec<StepInput>,
    pub final_state: Chip8State,
    pub chunk_handoffs: Vec<VerifiedKernelChunkHandoff>,
    pub kernel_opening_manifest: KernelOpeningManifest,
    pub opening_refinement_summary: KernelOpeningRefinementSummary,
    pub joint_opening_fold_bucket_proofs: Vec<KernelJointOpeningFoldBucketProof>,
    pub bridge_final_state: [u8; 32],
}

impl KernelExecutionRelationResult {
    pub fn export_output(&self) -> SimpleKernelOutput {
        let public_steps = self
            .prepared_steps
            .iter()
            .map(StepInput::instance)
            .collect();
        SimpleKernelOutput {
            prepared_steps: self.prepared_steps.clone(),
            public_steps,
            kernel_opening_manifest: self.kernel_opening_manifest.clone(),
            root_opening_manifest: simple_kernel_root_opening_manifest(),
            joint_opening_fold_bucket_proofs: self.joint_opening_fold_bucket_proofs.clone(),
        }
    }
}

impl Chip8PreparedStepBridgeBinding {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/prepared_step_bridge_binding");
        tr.append_u64s(
            b"neo.fold.next/chip8/prepared_step_bridge_binding/meta",
            &[self.row_index as u64],
        );
        tr.append_message(
            b"neo.fold.next/chip8/prepared_step_bridge_binding/row_binding_claim_digest",
            &self.row_binding_claim_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/prepared_step_bridge_binding/prepared_step_digest",
            &self.prepared_step_digest,
        );
        tr.digest32()
    }
}

struct KernelExecutionRelationContext {
    row_bindings: Vec<RowBindingClaim>,
    semantic_rows: usize,
    cycle_bits: usize,
    padded_trace_length: usize,
    program_context: super::KernelProgramContext,
    trace_rows: Vec<[F; 24]>,
    aux_data: Vec<KernelStepAux>,
    expected_meta_pub: super::public_meta::KernelMetaPub,
    commitment_sets: KernelCommitmentSets,
}

struct KernelVerifiedStages {
    kernel_opening_manifest: KernelOpeningManifest,
}

pub fn verify_kernel_execution_relation_output(
    input: &SimpleKernelVerifierInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    Ok(verify_kernel_execution_relation(input, relation_witness)?.export_output())
}

fn build_kernel_execution_relation_context(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<KernelExecutionRelationContext, SimpleKernelError> {
    let row_bindings = recover_row_bindings_from_bridge_chunk_transitions(relation_witness.bridge_chunk_transitions())?;
    let semantic_rows = row_bindings.len();
    let (cycle_bits, padded_trace_length) = cycle_bits_and_padded_trace_length_from_row_bindings(&row_bindings)?;
    if semantic_rows > padded_trace_length {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic row count {semantic_rows} exceeds padded trace length {padded_trace_length}"
        )));
    }
    let program_context = super::build_kernel_program_context(public)?;
    let (trace_rows, aux_data) = reconstruct_trace_rows_and_aux(
        &row_bindings,
        semantic_rows,
        padded_trace_length,
        cycle_bits,
        program_context.pad_pc_word,
        &program_context.rom_table,
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
    )?;
    if trace_rows[0][COL_PC] != F::from_u64(public.initial_pc_word as u64) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "first semantic row PC {} != public initial_pc_word {}",
            trace_rows[0][COL_PC].as_canonical_u64(),
            public.initial_pc_word
        )));
    }
    let expected_meta_pub = program_context.meta_pub(public, semantic_rows, padded_trace_length, cycle_bits);
    let root_context = SimpleKernelRootContext::new()?;
    let commitment_sets = KernelCommitmentSets::build(
        root_context.params(),
        &trace_rows,
        &aux_data,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
    )?;
    Ok(KernelExecutionRelationContext {
        row_bindings,
        semantic_rows,
        cycle_bits,
        padded_trace_length,
        program_context,
        trace_rows,
        aux_data,
        expected_meta_pub,
        commitment_sets,
    })
}

fn verify_kernel_execution_stages(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
    context: &KernelExecutionRelationContext,
    transcript: &mut Poseidon2Transcript,
) -> Result<KernelVerifiedStages, SimpleKernelError> {
    let mut stage1_challenge_transcript = transcript.clone();
    let stage1 = stage1::derive_stage1_execution_surface(
        relation_witness.reads().fetch(),
        relation_witness.reads().decode(),
        relation_witness.reads().alu(),
        relation_witness.reads().eq4(),
        &context.trace_rows,
        &context.aux_data,
        &context.program_context.rom_table,
        &context.program_context.decode_table,
        &context.program_context.alu_table,
        &context.program_context.eq4_table,
        context.cycle_bits,
        &mut stage1_challenge_transcript,
    )?;
    let mut stage1_terminal_transcript = transcript.clone();
    stage1::verify_stage1_execution(
        relation_witness.reads().fetch(),
        relation_witness.reads().decode(),
        relation_witness.reads().alu(),
        relation_witness.reads().eq4(),
        &stage1,
        &context.program_context.rom_table,
        &context.program_context.decode_table,
        &context.program_context.alu_table,
        &context.program_context.eq4_table,
        context.cycle_bits,
        Some(stage1::stage1_alu_expected_claim(
            &context.aux_data,
            &stage1.cycle_point,
        )),
        transcript,
    )?;
    verify_kernel_stage1_sumcheck_terminals_from_execution(
        relation_witness.reads().fetch(),
        relation_witness.reads().decode(),
        relation_witness.reads().alu(),
        relation_witness.reads().eq4(),
        &stage1,
        &context.aux_data,
        &context.program_context.rom_table,
        &context.program_context.alu_table,
        &context.program_context.eq4_table,
        &mut stage1_terminal_transcript,
    )?;

    let mut stage2_challenge_transcript = transcript.clone();
    let stage2 = stage2::derive_stage2_execution_surface(
        relation_witness.twists().register(),
        relation_witness.twists().memory(),
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
        &context.trace_rows,
        &context.aux_data,
        context.cycle_bits,
        &mut stage2_challenge_transcript,
    )?;
    let mut stage2_terminal_transcript = transcript.clone();
    stage2::verify_stage2_execution(
        relation_witness.twists().register(),
        relation_witness.twists().memory(),
        &stage2,
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
        context.cycle_bits,
        transcript,
    )?;
    verify_kernel_stage2_sumcheck_terminals_from_execution(
        relation_witness.twists().register(),
        relation_witness.twists().memory(),
        &stage2,
        &context.trace_rows,
        &context.aux_data,
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
        &mut stage2_terminal_transcript,
    )?;

    let mut stage3_challenge_transcript = transcript.clone();
    let stage3_challenges = stage3::sample_stage3_challenges(&mut stage3_challenge_transcript, context.cycle_bits);
    let stage3 = stage3::derive_stage3_execution_surface(
        &context.row_bindings,
        &stage3_challenges,
        context.program_context.pad_pc_word,
    )?;
    let mut stage3_terminal_transcript = transcript.clone();
    stage3::verify_stage3_execution(
        relation_witness.shift().reduction_rounds(),
        &stage3,
        &context.row_bindings,
        context.semantic_rows,
        context.padded_trace_length,
        context.program_context.pad_pc_word,
        context.cycle_bits,
        transcript,
    )?;
    verify_kernel_stage3_sumcheck_terminal_from_execution(
        relation_witness.shift().reduction_rounds(),
        &stage3.source_point,
        &stage3.claimed_shift_values,
        &context.trace_rows,
        &mut stage3_terminal_transcript,
    )?;

    let read_openings = kernel_read_opening_surface_from_execution(&stage1);
    let twist_openings = kernel_twist_opening_surface_from_execution(&stage2);
    let shift_openings = kernel_shift_opening_surface_from_execution(&stage3, &context.row_bindings);
    Ok(KernelVerifiedStages {
        kernel_opening_manifest: build_kernel_opening_manifest(
            &context.aux_data,
            context.semantic_rows,
            context.cycle_bits,
            &read_openings,
            &twist_openings,
            &shift_openings,
        ),
    })
}

pub fn verify_kernel_execution_relation(
    input: &SimpleKernelVerifierInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<KernelExecutionRelationResult, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    let root_params = root_context.params();
    let context = build_kernel_execution_relation_context(&input.public, relation_witness)?;
    let mut transcript = new_simple_kernel_transcript(&input.public.transcript_seed);
    let root_opening_manifest = simple_kernel_root_opening_manifest();
    let expected_commitments = context.commitment_sets.commitments();
    absorb_root0(&mut transcript, &expected_commitments, &context.expected_meta_pub);
    let verified_stages = verify_kernel_execution_stages(&input.public, relation_witness, &context, &mut transcript)?;
    let expected_kernel_manifest = verified_stages.kernel_opening_manifest.clone();
    let expected_opening_proof_sets = KernelOpeningProofSets::build(
        root_params,
        &context.trace_rows,
        &context.aux_data,
        &context.program_context.rom_table,
        &context.program_context.decode_table,
        &context.program_context.alu_table,
        &context.program_context.eq4_table,
        &expected_kernel_manifest,
    )?;
    let time_claims = time_opening_claims(&expected_kernel_manifest, &root_opening_manifest);
    let time_opening_summary = prove_time_opening(&[], &time_claims)
        .map_err(|err| SimpleKernelError::OpeningFailed(format!("kernel time-opening rebuild failed: {err}")))?;
    let opening_refinement_summary = build_kernel_opening_refinement_summary(
        &expected_kernel_manifest,
        context
            .commitment_sets
            .exact_opening_artifacts(&expected_opening_proof_sets),
    )?;
    let joint_opening_summary = build_kernel_joint_opening_summary(
        root_params,
        &expected_kernel_manifest,
        &opening_refinement_summary,
        &time_opening_summary,
        context
            .commitment_sets
            .exact_opening_artifacts(&expected_opening_proof_sets),
    )?;
    let joint_opening_fold_bucket_proofs =
        build_kernel_joint_opening_fold_bucket_proofs(context.padded_trace_length, &joint_opening_summary)?;

    let bridge_chunk_sources = build_kernel_bridge_chunk_auth_sources(
        &expected_kernel_manifest,
        &opening_refinement_summary,
        &context.row_bindings,
    )?;
    let bridge_chunk_transitions =
        build_bridge_chunk_transitions_from_verified_sources(&context.row_bindings, &bridge_chunk_sources)?;
    if !same_bridge_chunk_transitions(relation_witness.bridge_chunk_transitions(), &bridge_chunk_transitions) {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel execution relation bridge chunk transitions mismatch".into(),
        ));
    }
    let bridge_final_state = build_chip8_bridge_final_state_from_bridge_source(
        &expected_kernel_manifest,
        &context.row_bindings,
        &opening_refinement_summary,
    )?;
    let transition_final_state = bridge_chunk_transitions
        .last()
        .map(|transition| transition.next_state)
        .unwrap_or_else(chip8_bridge_state_seed);
    if transition_final_state != bridge_final_state {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel execution relation bridge transition final state mismatch".into(),
        ));
    }
    let chunk_handoffs = build_verified_chunk_handoffs(context.cycle_bits, &bridge_chunk_transitions)?;
    let prepared_steps = chunk_handoffs
        .iter()
        .flat_map(|handoff| handoff.chunk_input.steps.clone())
        .collect();
    let final_state = build_kernel_exact_frames_from_relation_witness(&input.public, relation_witness)?
        .last()
        .map(|frame| frame.post.clone())
        .ok_or_else(|| SimpleKernelError::BridgeFailed("missing final CHIP-8 frame".into()))?;
    emit_kernel_opening_artifacts_to_transcript(
        &mut transcript,
        &expected_kernel_manifest,
        &root_opening_manifest,
        &opening_refinement_summary,
        &time_opening_summary,
        &joint_opening_summary,
        &joint_opening_fold_bucket_proofs,
        context
            .commitment_sets
            .exact_opening_artifacts(&expected_opening_proof_sets),
    )?;

    Ok(KernelExecutionRelationResult {
        prepared_steps,
        final_state,
        chunk_handoffs,
        kernel_opening_manifest: expected_kernel_manifest,
        opening_refinement_summary,
        joint_opening_fold_bucket_proofs,
        bridge_final_state,
    })
}

pub fn rebuild_kernel_opening_manifest_from_relation_witness(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<KernelOpeningManifest, SimpleKernelError> {
    let context = build_kernel_execution_relation_context(public, relation_witness)?;
    let mut transcript = new_simple_kernel_transcript(&public.transcript_seed);
    absorb_root0(
        &mut transcript,
        &context.commitment_sets.commitments(),
        &context.expected_meta_pub,
    );
    Ok(verify_kernel_execution_stages(public, relation_witness, &context, &mut transcript)?.kernel_opening_manifest)
}

pub fn rebuild_kernel_joint_opening_from_relation_witness(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<(KernelJointOpeningSummary, Vec<KernelJointOpeningFoldBucketProof>), SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    let context = build_kernel_execution_relation_context(public, relation_witness)?;
    let mut transcript = new_simple_kernel_transcript(&public.transcript_seed);
    absorb_root0(
        &mut transcript,
        &context.commitment_sets.commitments(),
        &context.expected_meta_pub,
    );
    let verified_stages = verify_kernel_execution_stages(public, relation_witness, &context, &mut transcript)?;
    let kernel_opening_manifest = verified_stages.kernel_opening_manifest;
    let root_opening_manifest = simple_kernel_root_opening_manifest();
    let time_claims = time_opening_claims(&kernel_opening_manifest, &root_opening_manifest);
    let time_opening_summary = prove_time_opening(&[], &time_claims)
        .map_err(|err| SimpleKernelError::OpeningFailed(format!("kernel time-opening rebuild failed: {err}")))?;
    let opening_proof_sets = build_kernel_opening_proof_sets_from_context(&context, &kernel_opening_manifest)?;
    let opening_refinement_summary = build_kernel_opening_refinement_summary(
        &kernel_opening_manifest,
        context
            .commitment_sets
            .exact_opening_artifacts(&opening_proof_sets),
    )?;
    let joint_opening_summary = build_kernel_joint_opening_summary(
        root_context.params(),
        &kernel_opening_manifest,
        &opening_refinement_summary,
        &time_opening_summary,
        context
            .commitment_sets
            .exact_opening_artifacts(&opening_proof_sets),
    )?;
    let joint_opening_fold_bucket_proofs =
        build_kernel_joint_opening_fold_bucket_proofs(context.padded_trace_length, &joint_opening_summary)?;
    Ok((joint_opening_summary, joint_opening_fold_bucket_proofs))
}

pub fn build_chip8_bridge_final_state_from_relation_witness(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<[u8; 32], SimpleKernelError> {
    let context = build_kernel_execution_relation_context(public, relation_witness)?;
    let mut transcript = new_simple_kernel_transcript(&public.transcript_seed);
    absorb_root0(
        &mut transcript,
        &context.commitment_sets.commitments(),
        &context.expected_meta_pub,
    );
    let verified_stages = verify_kernel_execution_stages(public, relation_witness, &context, &mut transcript)?;
    let manifest = verified_stages.kernel_opening_manifest;
    let opening_proof_sets = build_kernel_opening_proof_sets_from_context(&context, &manifest)?;
    let opening_refinement_summary = build_kernel_opening_refinement_summary(
        &manifest,
        context
            .commitment_sets
            .exact_opening_artifacts(&opening_proof_sets),
    )?;
    build_chip8_bridge_final_state_from_bridge_source(&manifest, &context.row_bindings, &opening_refinement_summary)
}

pub(crate) fn build_stage3_proof_from_relation_witness(
    execution: &super::KernelShiftWitness,
    row_bindings: &[stage3::RowBindingClaim],
    challenges: &stage3::Stage3Challenges,
    pad_pc_word: u16,
) -> Result<stage3::Stage3Proof, SimpleKernelError> {
    stage3::rebuild_stage3_proof_from_execution(execution.reduction_rounds(), row_bindings, challenges, pad_pc_word)
}

pub(crate) fn build_stage1_proof_from_relation_witness<Tr: Transcript>(
    execution: &super::KernelReadWitness,
    public: &SimpleKernelPublicInput,
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<stage1::Stage1ShoutProof, SimpleKernelError> {
    let program_context = super::build_kernel_program_context(public)
        .expect("export witness uses validated public input when rebuilding stage1 proof");
    let surface = stage1::derive_stage1_execution_surface(
        execution.fetch(),
        execution.decode(),
        execution.alu(),
        execution.eq4(),
        trace_rows,
        aux,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
        cycle_bits,
        transcript,
    )?;
    Ok(stage1::rebuild_stage1_proof_from_execution(
        execution.fetch(),
        execution.decode(),
        execution.alu(),
        execution.eq4(),
        &surface,
    ))
}

pub(crate) fn build_stage2_proof_from_relation_witness<Tr: Transcript>(
    execution: &super::KernelTwistWitness,
    public: &SimpleKernelPublicInput,
    trace_rows: &[[F; 24]],
    aux: &[KernelStepAux],
    cycle_bits: usize,
    transcript: &mut Tr,
) -> Result<stage2::Stage2TwistProof, SimpleKernelError> {
    let surface = stage2::derive_stage2_execution_surface(
        execution.register(),
        execution.memory(),
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
        trace_rows,
        aux,
        cycle_bits,
        transcript,
    )?;
    Ok(stage2::rebuild_stage2_proof_from_execution(
        execution.register(),
        execution.memory(),
        &surface,
    ))
}

pub fn build_kernel_opening_refinement_summary_from_relation_witness(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<KernelOpeningRefinementSummary, SimpleKernelError> {
    let context = build_kernel_execution_relation_context(public, relation_witness)?;
    let mut transcript = new_simple_kernel_transcript(&public.transcript_seed);
    absorb_root0(
        &mut transcript,
        &context.commitment_sets.commitments(),
        &context.expected_meta_pub,
    );
    let verified_stages = verify_kernel_execution_stages(public, relation_witness, &context, &mut transcript)?;
    let manifest = verified_stages.kernel_opening_manifest;
    let opening_proof_sets = build_kernel_opening_proof_sets_from_context(&context, &manifest)?;
    build_kernel_opening_refinement_summary(
        &manifest,
        context
            .commitment_sets
            .exact_opening_artifacts(&opening_proof_sets),
    )
}

pub(crate) fn build_kernel_commitment_sets_from_relation_witness(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<KernelCommitmentSets, SimpleKernelError> {
    Ok(build_kernel_execution_relation_context(public, relation_witness)?.commitment_sets)
}

fn build_kernel_opening_proof_sets_from_context(
    context: &KernelExecutionRelationContext,
    manifest: &KernelOpeningManifest,
) -> Result<KernelOpeningProofSets, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    KernelOpeningProofSets::build(
        root_context.params(),
        &context.trace_rows,
        &context.aux_data,
        &context.program_context.rom_table,
        &context.program_context.decode_table,
        &context.program_context.alu_table,
        &context.program_context.eq4_table,
        manifest,
    )
}

fn build_bridge_chunk_transitions_from_verified_sources(
    row_bindings: &[RowBindingClaim],
    bridge_chunk_sources: &[KernelBridgeChunkAuthSource],
) -> Result<Vec<Chip8BridgeChunkRelationWitness>, SimpleKernelError> {
    let mut next_row_index = 0usize;
    let mut previous_state = chip8_bridge_state_seed();
    let mut transitions = Vec::with_capacity(bridge_chunk_sources.len());

    for (expected_chunk_index, chunk_source) in bridge_chunk_sources.iter().enumerate() {
        if chunk_source.chunk_index != expected_chunk_index {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel execution relation bridge chunk {} has source chunk index {}",
                expected_chunk_index, chunk_source.chunk_index
            )));
        }
        if chunk_source.row_count == 0 || chunk_source.row_count > CHIP8_BRIDGE_ROWS_PER_CHUNK {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel execution relation bridge chunk {} row count {} is outside 1..={}",
                expected_chunk_index, chunk_source.row_count, CHIP8_BRIDGE_ROWS_PER_CHUNK
            )));
        }
        if chunk_source.row_auths.len() != chunk_source.row_count {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel execution relation bridge chunk {} auth row count {} != source row count {}",
                expected_chunk_index,
                chunk_source.row_auths.len(),
                chunk_source.row_count
            )));
        }
        if next_row_index + chunk_source.row_count > row_bindings.len() {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel execution relation bridge chunk {} overruns row bindings",
                expected_chunk_index
            )));
        }

        let chunk_row_bindings = &row_bindings[next_row_index..next_row_index + chunk_source.row_count];
        let row_slots = std::array::from_fn(|slot| {
            if slot >= chunk_source.row_count {
                return None;
            }
            let row_binding = chunk_row_bindings[slot].clone();
            let row = Chip8BridgeRowWitness {
                row_binding,
                digest: [0; 32],
            };
            Some(Chip8BridgeRowWitness {
                digest: row.expected_digest(),
                ..row
            })
        });

        for (chunk_local_index, (row_binding, row_auth)) in chunk_row_bindings
            .iter()
            .zip(chunk_source.row_auths.iter())
            .enumerate()
        {
            let expected_row_index = chunk_source.chunk_start_index + chunk_local_index;
            if row_binding.row_index != expected_row_index {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "kernel execution relation bridge chunk {} row slot {} has row_index {}, expected {}",
                    expected_chunk_index, chunk_local_index, row_binding.row_index, expected_row_index
                )));
            }
            if row_auth.row_index != row_binding.row_index {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "kernel execution relation bridge chunk {} row slot {} auth row_index {} != row binding row_index {}",
                    expected_chunk_index, chunk_local_index, row_auth.row_index, row_binding.row_index
                )));
            }
            if row_auth.row_binding_claim_digest != expected_row_binding_claim_digest(row_binding) {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "kernel execution relation bridge chunk {} row slot {} row-binding digest mismatch",
                    expected_chunk_index, chunk_local_index
                )));
            }
        }

        let witness = Chip8BridgeChunkRelationWitness {
            previous_state,
            next_state: [0; 32],
            row_slots: row_slots.clone(),
        }
        .native_witness();
        let next_state = advance_chip8_bridge_state(
            previous_state,
            expected_chunk_index,
            chunk_source.chunk_start_index,
            chunk_source.row_count,
            witness.digest,
        );
        transitions.push(Chip8BridgeChunkRelationWitness {
            previous_state,
            next_state,
            row_slots,
        });
        previous_state = next_state;
        next_row_index += chunk_source.row_count;
    }

    if next_row_index != row_bindings.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "kernel execution relation bridge transitions cover {} rows, expected {}",
            next_row_index,
            row_bindings.len()
        )));
    }

    Ok(transitions)
}

fn same_bridge_chunk_transitions(
    lhs: &[Chip8BridgeChunkRelationWitness],
    rhs: &[Chip8BridgeChunkRelationWitness],
) -> bool {
    lhs.len() == rhs.len()
        && lhs
            .iter()
            .zip(rhs.iter())
            .all(|(left, right)| left.expected_digest() == right.expected_digest())
}

fn build_verified_chunk_handoffs(
    cycle_bits: usize,
    bridge_chunk_transitions: &[Chip8BridgeChunkRelationWitness],
) -> Result<Vec<VerifiedKernelChunkHandoff>, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    let mut next_row_index = 0usize;
    let mut handoffs = Vec::with_capacity(bridge_chunk_transitions.len());

    for (chunk_index, bridge_transition) in bridge_chunk_transitions.iter().enumerate() {
        let (chunk_start_index, chunk_steps, step_bindings) =
            build_verified_chunk_steps(chunk_index, bridge_transition, &root_context, cycle_bits)?;
        if chunk_start_index != next_row_index {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel execution relation chunk {} starts at row {}, expected {}",
                chunk_index, chunk_start_index, next_row_index
            )));
        }
        next_row_index = chunk_start_index + chunk_steps.len();
        let chunk_input = ChunkInput {
            start_index: chunk_start_index,
            steps: chunk_steps,
        };
        handoffs.push(VerifiedKernelChunkHandoff {
            public_chunk: chunk_input.public(),
            chunk_input,
            bridge_handoff: Chip8BridgeChunkHandoff {
                previous_state: bridge_transition.previous_state,
                next_state: bridge_transition.next_state,
                witness_digest: bridge_transition.native_claim().witness_digest,
                step_bindings,
            },
        });
    }

    Ok(handoffs)
}

pub(super) fn build_verified_chunk_steps(
    expected_chunk_index: usize,
    bridge_transition: &Chip8BridgeChunkRelationWitness,
    root_context: &SimpleKernelRootContext,
    cycle_bits: usize,
) -> Result<
    (
        usize,
        Vec<StepInput>,
        [Option<Chip8PreparedStepBridgeBinding>; CHIP8_BRIDGE_ROWS_PER_CHUNK],
    ),
    SimpleKernelError,
> {
    let (chunk_start_index, row_count) =
        verified_bridge_transition_step_range(expected_chunk_index, bridge_transition)?;
    let steps = bridge_transition
        .row_slots
        .iter()
        .take(row_count)
        .enumerate()
        .map(|(slot_index, row_slot)| {
            let row = row_slot.as_ref().ok_or_else(|| {
                SimpleKernelError::BridgeFailed(format!(
                    "verified bridge chunk {} missing row slot {} in active prefix",
                    expected_chunk_index, slot_index
                ))
            })?;
            if row.digest != row.expected_digest() {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "verified bridge chunk {} row slot {} digest mismatch",
                    expected_chunk_index, slot_index
                )));
            }
            build_prepared_step_from_row_binding(root_context, &row.row_binding, cycle_bits)
        })
        .collect::<Result<Vec<_>, _>>()?;
    let step_bindings = std::array::from_fn(|slot_index| {
        if slot_index >= row_count {
            return None;
        }
        let row = bridge_transition.row_slots[slot_index]
            .as_ref()
            .expect("active prefix checked by verified_bridge_transition_step_range");
        let step = &steps[slot_index];
        let binding = Chip8PreparedStepBridgeBinding {
            row_index: row.row_binding.row_index,
            row_binding_claim_digest: expected_row_binding_claim_digest(&row.row_binding),
            prepared_step_digest: super::prepared_step_digest(step),
            digest: [0; 32],
        };
        Some(Chip8PreparedStepBridgeBinding {
            digest: binding.expected_digest(),
            ..binding
        })
    });
    Ok((chunk_start_index, steps, step_bindings))
}

fn verified_bridge_transition_step_range(
    expected_chunk_index: usize,
    bridge_transition: &Chip8BridgeChunkRelationWitness,
) -> Result<(usize, usize), SimpleKernelError> {
    let mut first_row_index = None;
    let mut saw_empty = false;
    let mut row_count = 0usize;
    for (slot_index, row_slot) in bridge_transition.row_slots.iter().enumerate() {
        match row_slot {
            Some(_) if saw_empty => {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "verified bridge chunk {} has nonempty inactive slot {}",
                    expected_chunk_index, slot_index
                )));
            }
            Some(row) => {
                let chunk_start_index = *first_row_index.get_or_insert(row.row_binding.row_index);
                let expected_row_index = chunk_start_index + row_count;
                if row.row_binding.row_index != expected_row_index {
                    return Err(SimpleKernelError::BridgeFailed(format!(
                        "verified bridge chunk {} row {} != expected {}",
                        expected_chunk_index, row.row_binding.row_index, expected_row_index
                    )));
                }
                row_count += 1;
            }
            None => saw_empty = true,
        }
    }
    let chunk_start_index = first_row_index.ok_or_else(|| {
        SimpleKernelError::BridgeFailed(format!(
            "verified bridge chunk {} must contain at least one row",
            expected_chunk_index
        ))
    })?;
    Ok((chunk_start_index, row_count))
}
