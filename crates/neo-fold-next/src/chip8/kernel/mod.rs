//! Owns the CHIP-8 simple-kernel proof boundary and root bridge.
//! It defines the proof/output types, binds `root0`, builds the opening manifest, and reconstructs the root bridge.

mod artifacts;
mod bridge;
mod evidence;
mod execution_relation;
mod export_relation;
mod joint_opening;
mod lane_commitment;
mod openings;
mod public_meta;
mod soundness_accounting;
mod stage_terminal;
mod transcript;
mod types;
mod verify_artifact;
mod verify_common;
use super::spec::{Chip8Program, CommitmentId, CHIP8_PROGRAM_START, COL_PC};
use super::tables::{build_alu_table, build_decode_table, build_eq4_table, build_rom_table};
use super::{stage1, stage2, stage3};
use crate::time_opening::{prove_time_opening, verify_time_opening};
pub(crate) use artifacts::build_prepared_step_from_row_binding;
pub use artifacts::chip8_simple_root_params;
pub(crate) use artifacts::SimpleKernelRootContext;
pub use artifacts::{
    build_kernel_exact_frames, build_kernel_exact_frames_from_relation_witness, KernelExactFrame, KernelFrameDecodeView,
};
#[cfg(feature = "chip8-audit")]
pub use artifacts::{
    build_kernel_external_release_artifact, build_kernel_release_artifact, verify_kernel_external_release_artifact,
    verify_kernel_release_artifact, KernelExternalReleaseArtifact, KernelReleaseArtifact, KernelRoot0CommitmentBinding,
    KernelTraceDigestSource,
};
pub use artifacts::{
    build_kernel_staged_execution_digest_bundle, verify_kernel_staged_execution_digest_bundle,
    KernelDigestPublicSurface, KernelExecutionResultSurface, KernelStage1DigestSurface, KernelStage2DigestSurface,
    KernelStagedExecutionDigest, KernelStagedExecutionDigestBundle,
};
pub use bridge::chip8_bridge_state_seed;
pub use bridge::prepared_step_digest;
use bridge::recover_prepared_steps_from_row_bindings;
pub(crate) use bridge::{
    advance_chip8_bridge_state, build_chip8_bridge_final_state_from_auths, build_kernel_bridge_binding_summary,
    build_kernel_bridge_chunk_auth_sources, build_kernel_bridge_row_auths, build_kernel_row_projection_summary,
    recover_row_bindings_from_bridge_chunk_transitions,
};
pub use bridge::{
    build_chip8_bridge_chunk_proof_bundle, verify_chip8_bridge_chunk_proof_bundle, Chip8BridgeChunkClaim,
    Chip8BridgeChunkProofBundle, Chip8BridgeChunkRelationWitness, Chip8BridgeChunkWitness, Chip8BridgeRowWitness,
    KernelBridgeBindingClaim, KernelBridgeBindingSummary, KernelRowProjection, KernelRowProjectionSummary,
    CHIP8_BRIDGE_FOLD_SCHEDULE, CHIP8_BRIDGE_ROWS_PER_CHUNK,
};
pub(crate) use bridge::{verify_kernel_bridge_binding_summary, verify_kernel_row_projection_summary};
pub(crate) use evidence::verify_kernel_semantic_evidence_summary;
pub use evidence::KernelSemanticEvidenceSummary;
pub use evidence::{
    build_kernel_execution_digest, build_kernel_execution_digest_from_relation_witness, verify_kernel_execution_digest,
    KernelAuditSurface, KernelExecutionDigest, KernelExportSurface, KernelManifestSurface, KernelTraceSurface,
};
pub(crate) use evidence::{build_kernel_semantic_evidence_summary, KernelSemanticEvidenceInputs};
pub use evidence::{
    build_kernel_stage3_digest_surfaces, verify_kernel_stage3_digest_surfaces, KernelStage3CurrentRow,
    KernelStage3DigestSurface, KernelStage3LaneColumn, KernelStage3RowClaim, KernelStage3ShiftClaim,
    KernelStage3ShiftWitness, KernelStage3ShiftedColumn,
};
pub use execution_relation::{
    build_chip8_bridge_final_state_from_relation_witness,
    build_kernel_opening_refinement_summary_from_relation_witness, rebuild_kernel_joint_opening_from_relation_witness,
    rebuild_kernel_opening_manifest_from_relation_witness, verify_kernel_execution_relation,
    verify_kernel_execution_relation_output, Chip8BridgeChunkHandoff, Chip8PreparedStepBridgeBinding,
    KernelExecutionRelationResult, VerifiedKernelChunkHandoff,
};
pub(crate) use execution_relation::{
    build_kernel_commitment_sets_from_relation_witness, build_stage1_proof_from_relation_witness,
    build_stage2_proof_from_relation_witness, build_stage3_proof_from_relation_witness,
};
pub(crate) use export_relation::{
    build_kernel_export_proof_from_verified_execution_relation,
    build_kernel_export_relation_digest_from_verified_execution_relation, verify_kernel_export_proof,
    verify_kernel_export_relation, KernelExportRelationResult,
};
pub use export_relation::{KernelExportChunkHandoff, KernelExportProof};
use joint_opening::{build_kernel_joint_opening_fold_bucket_proofs, verify_kernel_joint_opening_fold_bucket_proofs};
use joint_opening::{build_kernel_joint_opening_summary, verify_kernel_joint_opening_summary};
pub use joint_opening::{KernelJointOpeningFoldBucketProof, KernelJointOpeningFoldShape};
pub use joint_opening::{KernelJointOpeningGroupSummary, KernelJointOpeningSummary};
use lane_commitment::{
    proof_exact_opening_artifacts, verify_expected_commitments, KernelCommitmentSets, KernelOpeningProofSets,
};
pub use lane_commitment::{
    AluRaCommitmentSet, AluRaOpeningProof, AluTableCommitmentSet, AluTableOpeningProof, DecodeHandoffCommitmentSet,
    DecodeHandoffOpeningProof, DecodeRaCommitmentSet, DecodeRaOpeningProof, DecodeTableCommitmentSet,
    DecodeTableOpeningProof, Eq4RaCommitmentSet, Eq4RaOpeningProof, Eq4TableCommitmentSet, Eq4TableOpeningProof,
    FetchRaCommitmentSet, FetchRaOpeningProof, LaneCommitmentSet, LaneOpeningProof, RamTwistCommitmentSet,
    RamTwistOpeningProof, RegTwistCommitmentSet, RegTwistOpeningProof, RomTableCommitmentSet, RomTableOpeningProof,
};
use neo_math::F;
pub(crate) use openings::{
    as_time_opening_claim, build_kernel_opening_manifest, is_kernel_commitment_id, is_root_commitment_id,
    kernel_opening_claim_cmp, kernel_read_opening_surface, kernel_read_opening_surface_from_execution,
    kernel_shift_opening_surface, kernel_shift_opening_surface_from_execution, kernel_twist_opening_surface,
    kernel_twist_opening_surface_from_execution, normalize_opening_pairs, normalize_polynomial_ids,
    opening_commitment_id_key, time_opening_claims,
};
use openings::{build_kernel_opening_refinement_summary, verify_kernel_opening_refinement_summary};
pub use openings::{KernelOpeningClaim, KernelOpeningManifest, KernelOpeningSource, RootOpeningManifest};
pub use openings::{KernelOpeningRefinement, KernelOpeningRefinementSummary};
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use public_meta::validate_public_input;
pub use public_meta::{absorb_root0, build_kernel_meta_pub, new_simple_kernel_transcript, KernelMetaPub};
pub use soundness_accounting::{
    AddressFamily, KernelErrorSurface, KernelErrorTerm, Stage1ShoutChannel, TwistMemoryFamily, TwistReadFamily,
};
use stage_terminal::{
    verify_kernel_stage1_sumcheck_terminals, verify_kernel_stage2_sumcheck_terminals,
    verify_kernel_stage3_sumcheck_terminal,
};
use transcript::emit_kernel_opening_artifacts_to_transcript;
pub use transcript::{
    KernelExactOpeningTranscriptEntry, KernelJointOpeningTranscriptUnification, KernelOpeningTranscriptSource,
    KernelOpeningTranscriptSurface, KernelTimeOpeningTranscriptGroup, KernelTimeOpeningTranscriptUnification,
};
pub use transcript::{KernelTranscriptEvent, KernelTranscriptSurface};
pub use types::{
    KernelCommitments, KernelExecutionRelationWitness, KernelReadWitness, KernelShiftWitness, KernelStepAux,
    KernelTwistWitness, SimpleKernelError, SimpleKernelOutput, SimpleKernelProof, SimpleKernelProverInput,
    SimpleKernelPublicInput, SimpleKernelVerifierInput, SimpleKernelWitness,
};
pub(crate) use verify_artifact::{authenticate_kernel_openings, pad_semantic_witness, reconstruct_trace_rows_and_aux};
pub(crate) use verify_common::{
    assert_manifest_canonical, assert_root_manifest_canonical, batch_values, expect_digest32, expect_equal_k,
    expect_equal_k_slice, find_manifest_claim, replay_sumcheck_unchecked, split_round_groups, verify_sumcheck_known,
};

pub fn simple_kernel_root_opening_manifest() -> RootOpeningManifest {
    RootOpeningManifest::new()
}

pub(crate) fn cycle_bits_and_padded_trace_length_from_row_bindings(
    row_bindings: &[stage3::RowBindingClaim],
) -> Result<(usize, usize), SimpleKernelError> {
    let first = row_bindings.first().ok_or_else(|| {
        SimpleKernelError::InvalidWitness("kernel proof must contain at least one semantic row".into())
    })?;
    let cycle_bits = first.row_bits.len();
    for row_binding in row_bindings.iter().skip(1) {
        if row_binding.row_bits.len() != cycle_bits {
            return Err(SimpleKernelError::InvalidWitness(format!(
                "row {} has {} row bits, expected {}",
                row_binding.row_index,
                row_binding.row_bits.len(),
                cycle_bits
            )));
        }
    }
    let padded_trace_length = 1usize.checked_shl(cycle_bits as u32).ok_or_else(|| {
        SimpleKernelError::InvalidWitness(format!("cycle_bits {cycle_bits} does not fit in padded trace length"))
    })?;
    Ok((cycle_bits, padded_trace_length))
}

struct KernelProgramContext {
    word_count: usize,
    pad_pc_word: u16,
    rom_table: Vec<F>,
    decode_table: Vec<Vec<F>>,
    alu_table: Vec<F>,
    eq4_table: Vec<F>,
}

impl KernelProgramContext {
    fn meta_pub(
        &self,
        public_input: &SimpleKernelPublicInput,
        semantic_rows: usize,
        padded_trace_length: usize,
        cycle_bits: usize,
    ) -> KernelMetaPub {
        build_kernel_meta_pub(
            public_input,
            &self.rom_table,
            &self.decode_table,
            &self.alu_table,
            &self.eq4_table,
            self.word_count,
            semantic_rows,
            padded_trace_length,
            self.pad_pc_word,
            cycle_bits,
        )
    }
}

fn build_kernel_program_context(
    public_input: &SimpleKernelPublicInput,
) -> Result<KernelProgramContext, SimpleKernelError> {
    let word_count = validate_public_input(public_input)?;
    let program = Chip8Program {
        bytes: public_input.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let base_word = (program.start_pc / 2) as usize;
    if public_input.initial_pc_word as usize != base_word {
        return Err(SimpleKernelError::InvalidProgram(format!(
            "public initial_pc_word {} != standard loader base word {}",
            public_input.initial_pc_word, base_word
        )));
    }
    let pad_pc_word = (base_word + word_count) as u16;
    Ok(KernelProgramContext {
        word_count,
        pad_pc_word,
        rom_table: build_rom_table(&program, pad_pc_word),
        decode_table: build_decode_table(),
        alu_table: build_alu_table(),
        eq4_table: build_eq4_table(),
    })
}

// ---------------------------------------------------------------------------
// Entry point stubs
// ---------------------------------------------------------------------------

pub fn prove_simple_kernel(
    input: &SimpleKernelProverInput,
) -> Result<(SimpleKernelOutput, SimpleKernelProof), SimpleKernelError> {
    let mut transcript = new_simple_kernel_transcript(&input.public.transcript_seed);
    let root_context = SimpleKernelRootContext::new()?;
    let root_params = root_context.params();
    let semantic_rows = input.witness.semantic_trace_rows.len();
    let program_context = build_kernel_program_context(&input.public)?;
    if semantic_rows == 0 {
        return Err(SimpleKernelError::InvalidWitness(
            "semantic trace must contain at least one row".into(),
        ));
    }
    if input.witness.semantic_trace_rows[0][COL_PC] != F::from_u64(input.public.initial_pc_word as u64) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "first semantic row PC {} != public initial_pc_word {}",
            input.witness.semantic_trace_rows[0][COL_PC].as_canonical_u64(),
            input.public.initial_pc_word
        )));
    }
    let (trace_rows, aux_data) = pad_semantic_witness(
        &input.witness.semantic_trace_rows,
        &input.witness.semantic_aux_data,
        &input.public.initial_registers,
        input.public.initial_i,
        program_context.pad_pc_word,
    )?;
    let padded_trace_length = trace_rows.len();
    let cycle_bits = padded_trace_length.trailing_zeros() as usize;
    let meta_pub = program_context.meta_pub(&input.public, semantic_rows, padded_trace_length, cycle_bits);

    let commitment_sets = KernelCommitmentSets::build(
        root_params,
        &trace_rows,
        &aux_data,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
    )?;
    let commitments = commitment_sets.commitments();
    absorb_root0(&mut transcript, &commitments, &meta_pub);

    // Stage 1: Shout (read-only lookup proofs).
    let stage1_proof = stage1::prove_stage1(
        &trace_rows,
        &aux_data,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
        cycle_bits,
        &mut transcript,
    )
    .map_err(SimpleKernelError::SumcheckFailed)?;

    // Stage 2: Twist (read-write memory checking).
    let stage2_proof = stage2::prove_stage2(
        &trace_rows,
        &aux_data,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        cycle_bits,
        &mut transcript,
    )?;

    // Stage 3: Continuity + bridge binding.
    let active_rows = semantic_rows;
    let stage3_proof = stage3::prove_stage3(&trace_rows, active_rows, cycle_bits, &mut transcript)?;

    let read_openings = kernel_read_opening_surface(&stage1_proof);
    let twist_openings = kernel_twist_opening_surface(&stage2_proof);
    let shift_openings = kernel_shift_opening_surface(&stage3_proof);
    let manifest = build_kernel_opening_manifest(
        &aux_data,
        active_rows,
        cycle_bits,
        &read_openings,
        &twist_openings,
        &shift_openings,
    );
    let root_opening_manifest = simple_kernel_root_opening_manifest();
    let opening_proofs = KernelOpeningProofSets::build(
        root_params,
        &trace_rows,
        &aux_data,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
        &manifest,
    )?;
    let opening_refinement_summary =
        build_kernel_opening_refinement_summary(&manifest, commitment_sets.exact_opening_artifacts(&opening_proofs))?;
    let time_opening_claims = time_opening_claims(&manifest, &root_opening_manifest);
    let time_opening_summary = prove_time_opening(&[], &time_opening_claims)
        .map_err(|err| SimpleKernelError::OpeningFailed(format!("kernel time-opening failed: {err}")))?;
    let joint_opening_summary = build_kernel_joint_opening_summary(
        root_params,
        &manifest,
        &opening_refinement_summary,
        &time_opening_summary,
        commitment_sets.exact_opening_artifacts(&opening_proofs),
    )?;
    if stage3_proof.row_bindings.len() != semantic_rows {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 exported {} row bindings for {} semantic rows",
            stage3_proof.row_bindings.len(),
            semantic_rows
        )));
    }
    let prepared_steps: Vec<_> = stage3_proof
        .row_bindings
        .iter()
        .map(|row_binding| build_prepared_step_from_row_binding(&root_context, row_binding, cycle_bits))
        .collect::<Result<_, _>>()?;
    let public_steps = prepared_steps
        .iter()
        .map(crate::proof::StepInput::instance)
        .collect();
    let bridge_chunk_proof =
        build_chip8_bridge_chunk_proof_bundle(&manifest, &opening_refinement_summary, &stage3_proof.row_bindings)?;
    let joint_opening_fold_bucket_proofs =
        build_kernel_joint_opening_fold_bucket_proofs(meta_pub.padded_trace_length, &joint_opening_summary)?;
    emit_kernel_opening_artifacts_to_transcript(
        &mut transcript,
        &manifest,
        &root_opening_manifest,
        &opening_refinement_summary,
        &time_opening_summary,
        &joint_opening_summary,
        &joint_opening_fold_bucket_proofs,
        commitment_sets.exact_opening_artifacts(&opening_proofs),
    )?;

    let KernelCommitmentSets {
        lane_commitments,
        fetch_ra_commitments,
        decode_ra_commitments,
        alu_ra_commitments,
        eq4_ra_commitments,
        rom_table_commitments,
        decode_table_commitments,
        alu_table_commitments,
        eq4_table_commitments,
        decode_handoff_commitments,
        reg_twist_commitments,
        ram_twist_commitments,
    } = commitment_sets;
    let KernelOpeningProofSets {
        lane_opening_proofs,
        fetch_ra_opening_proofs,
        decode_ra_opening_proofs,
        alu_ra_opening_proofs,
        eq4_ra_opening_proofs,
        rom_table_opening_proofs,
        decode_table_opening_proofs,
        alu_table_opening_proofs,
        eq4_table_opening_proofs,
        decode_handoff_opening_proofs,
        reg_twist_opening_proofs,
        ram_twist_opening_proofs,
    } = opening_proofs;

    let output = SimpleKernelOutput {
        prepared_steps,
        public_steps,
        kernel_opening_manifest: manifest.clone(),
        root_opening_manifest: root_opening_manifest.clone(),
        joint_opening_fold_bucket_proofs: joint_opening_fold_bucket_proofs.clone(),
    };

    let proof = SimpleKernelProof {
        commitments,
        lane_commitments,
        fetch_ra_commitments,
        decode_ra_commitments,
        alu_ra_commitments,
        eq4_ra_commitments,
        rom_table_commitments,
        decode_table_commitments,
        alu_table_commitments,
        eq4_table_commitments,
        decode_handoff_commitments,
        reg_twist_commitments,
        ram_twist_commitments,
        meta_pub,
        stage1: stage1_proof,
        stage2: stage2_proof,
        stage3: stage3_proof,
        kernel_opening_manifest: manifest,
        root_opening_manifest,
        lane_opening_proofs,
        fetch_ra_opening_proofs,
        decode_ra_opening_proofs,
        alu_ra_opening_proofs,
        eq4_ra_opening_proofs,
        rom_table_opening_proofs,
        decode_table_opening_proofs,
        alu_table_opening_proofs,
        eq4_table_opening_proofs,
        decode_handoff_opening_proofs,
        reg_twist_opening_proofs,
        ram_twist_opening_proofs,
        opening_refinement_summary,
        joint_opening_summary,
        joint_opening_fold_bucket_proofs,
        bridge_chunk_proof,
        time_opening_summary,
    };

    Ok((output, proof))
}

pub fn verify_simple_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    let mut transcript = new_simple_kernel_transcript(&input.public.transcript_seed);
    let root_context = SimpleKernelRootContext::new()?;
    let root_params = root_context.params();
    let semantic_rows = proof.meta_pub.semantic_rows;
    let padded_trace_length = proof.meta_pub.padded_trace_length;
    let cycle_bits = proof.meta_pub.cycle_bits;
    let program_context = build_kernel_program_context(&input.public)?;

    if semantic_rows == 0 {
        return Err(SimpleKernelError::InvalidWitness(
            "kernel proof must contain at least one semantic row".into(),
        ));
    }
    if !padded_trace_length.is_power_of_two() {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "padded trace length {padded_trace_length} must be a power of two"
        )));
    }
    if padded_trace_length != (1usize << cycle_bits) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "padded trace length {padded_trace_length} != 2^{cycle_bits}"
        )));
    }
    if semantic_rows > padded_trace_length {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic row count {semantic_rows} exceeds padded trace length {padded_trace_length}"
        )));
    }
    if proof.stage3.row_bindings.len() != semantic_rows {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "stage3 exported {} row bindings for {} semantic rows",
            proof.stage3.row_bindings.len(),
            semantic_rows
        )));
    }
    let expected_meta_pub = program_context.meta_pub(&input.public, semantic_rows, padded_trace_length, cycle_bits);
    proof.meta_pub.expect_matches(&expected_meta_pub)?;
    let (trace_rows, aux_data) = reconstruct_trace_rows_and_aux(
        &proof.stage3.row_bindings,
        semantic_rows,
        padded_trace_length,
        cycle_bits,
        program_context.pad_pc_word,
        &program_context.rom_table,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
    )?;
    if trace_rows[0][COL_PC] != F::from_u64(input.public.initial_pc_word as u64) {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "first semantic row PC {} != public initial_pc_word {}",
            trace_rows[0][COL_PC].as_canonical_u64(),
            input.public.initial_pc_word
        )));
    }
    assert_manifest_canonical(&proof.kernel_opening_manifest)?;
    assert_root_manifest_canonical(&proof.root_opening_manifest)?;
    if !proof.root_opening_manifest.claims.is_empty() {
        return Err(SimpleKernelError::OpeningFailed(
            "simple kernel proof may not carry root opening claims before root proving".into(),
        ));
    }
    let expected_commitments = verify_expected_commitments(
        root_params,
        proof,
        &trace_rows,
        &aux_data,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
    )?;

    let time_opening_claims = time_opening_claims(&proof.kernel_opening_manifest, &proof.root_opening_manifest);
    verify_time_opening(&[], &time_opening_claims, &Some(proof.time_opening_summary.clone()))
        .map_err(|err| SimpleKernelError::OpeningFailed(format!("kernel time-opening failed: {err}")))?;
    verify_kernel_opening_refinement_summary(
        &proof.kernel_opening_manifest,
        proof_exact_opening_artifacts(proof),
        &proof.opening_refinement_summary,
    )?;
    verify_kernel_joint_opening_summary(
        root_params,
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.time_opening_summary,
        proof_exact_opening_artifacts(proof),
        &proof.joint_opening_summary,
    )?;
    verify_kernel_joint_opening_fold_bucket_proofs(
        proof.meta_pub.padded_trace_length,
        &proof.joint_opening_summary,
        &proof.joint_opening_fold_bucket_proofs,
    )?;
    proof.commitments.expect_matches(&expected_commitments)?;
    absorb_root0(&mut transcript, &expected_commitments, &proof.meta_pub);

    let mut stage1_terminal_transcript = transcript.clone();
    stage1::verify_stage1(
        &proof.stage1,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
        cycle_bits,
        Some(stage1::stage1_alu_expected_claim(&aux_data, &proof.stage1.cycle_point)),
        &mut transcript,
    )
    .map_err(SimpleKernelError::SumcheckFailed)?;
    verify_kernel_stage1_sumcheck_terminals(
        &proof.stage1,
        &aux_data,
        &program_context.rom_table,
        &program_context.alu_table,
        &program_context.eq4_table,
        &mut stage1_terminal_transcript,
    )?;

    let mut stage2_terminal_transcript = transcript.clone();
    stage2::verify_stage2(
        &proof.stage2,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        cycle_bits,
        &mut transcript,
    )?;
    verify_kernel_stage2_sumcheck_terminals(
        &proof.stage2,
        &trace_rows,
        &aux_data,
        &input.public.initial_registers,
        input.public.initial_i,
        &input.public.initial_ram,
        &mut stage2_terminal_transcript,
    )?;

    let mut stage3_terminal_transcript = transcript.clone();
    stage3::verify_stage3(
        &proof.stage3,
        semantic_rows,
        padded_trace_length,
        program_context.pad_pc_word,
        cycle_bits,
        &mut transcript,
    )?;
    verify_kernel_stage3_sumcheck_terminal(&proof.stage3, &trace_rows, &mut stage3_terminal_transcript)?;

    authenticate_kernel_openings(
        proof,
        &trace_rows,
        &aux_data,
        &program_context.rom_table,
        &program_context.decode_table,
        &program_context.alu_table,
        &program_context.eq4_table,
    )?;
    let read_openings = kernel_read_opening_surface(&proof.stage1);
    let twist_openings = kernel_twist_opening_surface(&proof.stage2);
    let shift_openings = kernel_shift_opening_surface(&proof.stage3);
    let expected_kernel_manifest = build_kernel_opening_manifest(
        &aux_data,
        semantic_rows,
        cycle_bits,
        &read_openings,
        &twist_openings,
        &shift_openings,
    );
    expect_digest32(
        proof.kernel_opening_manifest.digest,
        expected_kernel_manifest.digest,
        "kernel opening manifest",
    )?;

    let prepared_steps = recover_prepared_steps_from_row_bindings(
        &proof.kernel_opening_manifest,
        &proof.stage3.row_bindings,
        &root_context,
        cycle_bits,
    )?;
    let public_steps = prepared_steps
        .iter()
        .map(crate::proof::StepInput::instance)
        .collect();
    verify_chip8_bridge_chunk_proof_bundle(
        &proof.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.stage3.row_bindings,
        &proof.bridge_chunk_proof,
    )?;
    emit_kernel_opening_artifacts_to_transcript(
        &mut transcript,
        &proof.kernel_opening_manifest,
        &proof.root_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.time_opening_summary,
        &proof.joint_opening_summary,
        &proof.joint_opening_fold_bucket_proofs,
        proof_exact_opening_artifacts(proof),
    )?;

    Ok(SimpleKernelOutput {
        prepared_steps,
        public_steps,
        kernel_opening_manifest: proof.kernel_opening_manifest.clone(),
        root_opening_manifest: proof.root_opening_manifest.clone(),
        joint_opening_fold_bucket_proofs: proof.joint_opening_fold_bucket_proofs.clone(),
    })
}

pub fn build_chip8_bridge_final_state_from_bridge_source(
    manifest: &KernelOpeningManifest,
    row_bindings: &[stage3::RowBindingClaim],
    opening_refinement_summary: &KernelOpeningRefinementSummary,
) -> Result<[u8; 32], SimpleKernelError> {
    if row_bindings.is_empty() {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge source must contain at least one row".into(),
        ));
    }
    let bridge_row_auths = build_kernel_bridge_row_auths(manifest, &opening_refinement_summary, row_bindings)?;
    build_chip8_bridge_final_state_from_auths(&bridge_row_auths, row_bindings)
}
