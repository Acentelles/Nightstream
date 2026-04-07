//! Owns exact frame reconstruction, root context, staged digest export, and release artifact packaging.

use neo_ajtai::{set_global_pp_seeded, AjtaiSModule};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsWitness, Mat};
use neo_math::{KExtensions, D, F, K};
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::chip8::spec::{
    decode_opcode, Chip8DecodedStep, Chip8Program, Chip8State, CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START, COL_BURST_LAST,
    COL_IS_MEMOP, COL_I_NEXT, COL_I_REG, COL_MEM_VALUE, COL_PC, COL_PC_NEXT, COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT,
    COL_REG_Y, COL_X_IDX, COL_Y_IDX, WITNESS_WIDTH,
};
use crate::chip8::stage3::RowBindingClaim;
use crate::chip8::tables::{
    build_rom_table, decode_to_output, flatten_alu_key, flatten_eq4_key, OperandSelector, RAM_SINK_ADDR, REG_SINK_ADDR,
};
use crate::proof::StepInput;
use crate::witness_layout::{commit_cols_for_full_width, encode_vector_for_full_width};

use super::evidence::{build_kernel_stage3_digest_surfaces_from_frames, KernelStage3DigestSurface};
#[cfg(feature = "chip8-audit")]
use super::{build_kernel_execution_digest, verify_kernel_execution_digest, KernelCommitments};
use super::{
    cycle_bits_and_padded_trace_length_from_row_bindings, reconstruct_trace_rows_and_aux,
    recover_row_bindings_from_bridge_chunk_transitions, CommitmentId, KernelExecutionDigest,
    KernelExecutionRelationWitness, KernelMetaPub, KernelOpeningTranscriptSource, KernelOpeningTranscriptSurface,
    KernelStepAux, SimpleKernelError, SimpleKernelOutput, SimpleKernelProof, SimpleKernelPublicInput,
};
#[cfg(feature = "chip8-audit")]
use crate::chip8::proof::Chip8AuditBundle;

const CHIP8_SIMPLE_ROOT_PP_SEED: [u8; 32] = [
    0x09, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
];
const CHIP8_SIMPLE_ROOT_K_RHO: u32 = 16;
const CHIP8_SIMPLE_ROOT_B: u64 = 1 << 16;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct KernelFrameDecodeView {
    pub core: Chip8DecodedStep,
    pub opcode_word: u16,
    pub pc_word: u16,
    pub row_x_idx: u8,
    pub row_y_idx: u8,
    pub is_memop: bool,
    pub burst_last: bool,
    pub ram_addr: u16,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelExactFrame {
    pub step_idx: usize,
    pub dec: KernelFrameDecodeView,
    pub pre: Chip8State,
    pub post: Chip8State,
    pub row: [F; WITNESS_WIDTH],
    pub kernel_aux: KernelStepAux,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelDigestPublicSurface {
    pub public: SimpleKernelPublicInput,
    pub meta_pub: KernelMetaPub,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage1DigestSurface {
    pub pre: Chip8State,
    pub dec: KernelFrameDecodeView,
    pub row: [neo_math::F; WITNESS_WIDTH],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStage2DigestSurface {
    pub pre: Chip8State,
    pub post: Chip8State,
    pub dec: KernelFrameDecodeView,
    pub row: [neo_math::F; WITNESS_WIDTH],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelExecutionResultSurface {
    pub step_idx: usize,
    pub pre: Chip8State,
    pub post: Chip8State,
    pub dec: KernelFrameDecodeView,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStagedExecutionDigest {
    pub stage1: KernelStage1DigestSurface,
    pub stage2: KernelStage2DigestSurface,
    pub stage3: KernelStage3DigestSurface,
    pub result: KernelExecutionResultSurface,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelStagedExecutionDigestBundle {
    pub public: KernelDigestPublicSurface,
    pub digests: Vec<KernelStagedExecutionDigest>,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelReleaseArtifact {
    pub kernel_digest: KernelExecutionDigest,
    pub staged_bundle: KernelStagedExecutionDigestBundle,
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct KernelRoot0CommitmentBinding {
    pub id: CommitmentId,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelTraceDigestSource {
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub semantic_evidence_summary_digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelExternalReleaseArtifact {
    pub root0_bindings: Vec<KernelRoot0CommitmentBinding>,
    pub trace_digests: KernelTraceDigestSource,
    pub frames: Vec<KernelExactFrame>,
    pub stage3s: Vec<KernelStage3DigestSurface>,
    pub opening_transcript_source: KernelOpeningTranscriptSource,
    pub opening_transcript_surface: KernelOpeningTranscriptSurface,
    pub artifact: KernelReleaseArtifact,
}

pub(crate) struct SimpleKernelRootContext {
    params: NeoParams,
    log: AjtaiSModule,
}

impl KernelExactFrame {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_exact_frame");
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_exact_frame/meta",
            &[
                self.step_idx as u64,
                self.dec.opcode_word as u64,
                self.dec.pc_word as u64,
                self.dec.row_x_idx as u64,
                self.dec.row_y_idx as u64,
                self.dec.is_memop as u64,
                self.dec.burst_last as u64,
                self.dec.ram_addr as u64,
            ],
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_exact_frame/core_decode",
            &[
                self.dec.core.opcode_id as u64,
                self.dec.core.x as u64,
                self.dec.core.y as u64,
                self.dec.core.kk as u64,
                self.dec.core.nnn as u64,
            ],
        );
        append_state(&mut tr, b"neo.fold.next/chip8/kernel_exact_frame/pre", &self.pre);
        append_state(&mut tr, b"neo.fold.next/chip8/kernel_exact_frame/post", &self.post);
        tr.append_fields_iter(
            b"neo.fold.next/chip8/kernel_exact_frame/row",
            self.row.len(),
            self.row.iter().copied(),
        );
        append_kernel_aux(&mut tr, &self.kernel_aux);
        tr.digest32()
    }
}

impl SimpleKernelRootContext {
    pub(crate) fn new() -> Result<Self, SimpleKernelError> {
        let params = chip8_simple_root_params();
        let m = commit_cols_for_full_width(WITNESS_WIDTH);
        set_global_pp_seeded(D, params.kappa as usize, m, CHIP8_SIMPLE_ROOT_PP_SEED).map_err(|err| {
            SimpleKernelError::BridgeFailed(format!("canonical CHIP-8 root seed setup failed: {err}"))
        })?;
        Ok(Self {
            params,
            log: AjtaiSModule::from_global_for_dims(D, m).map_err(|err| {
                SimpleKernelError::BridgeFailed(format!("canonical CHIP-8 root module failed: {err}"))
            })?,
        })
    }

    pub(crate) fn params(&self) -> &NeoParams {
        &self.params
    }

    pub(crate) fn log(&self) -> &AjtaiSModule {
        &self.log
    }
}

pub fn chip8_simple_root_params() -> NeoParams {
    let mut params = NeoParams::goldilocks_auto_r1cs_ccs(WITNESS_WIDTH).expect("valid CHIP-8 root params");
    params.k_rho = CHIP8_SIMPLE_ROOT_K_RHO;
    params.B = CHIP8_SIMPLE_ROOT_B;
    params
}

pub(crate) fn chip8_simple_root_context_id() -> [u8; 32] {
    let params = chip8_simple_root_params();
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/root_context");
    tr.append_u64s(
        b"neo.fold.next/chip8/root_context/values",
        &[
            params.q,
            params.eta as u64,
            params.d as u64,
            params.kappa as u64,
            params.m,
            params.b as u64,
            params.k_rho as u64,
            params.B,
            params.T as u64,
            params.s as u64,
            params.lambda as u64,
            WITNESS_WIDTH as u64,
            commit_cols_for_full_width(WITNESS_WIDTH) as u64,
        ],
    );
    tr.append_message(b"neo.fold.next/chip8/root_context/seed", &CHIP8_SIMPLE_ROOT_PP_SEED);
    tr.digest32()
}

pub(crate) fn root_encode_semantic_row(
    root_context: &SimpleKernelRootContext,
    semantic_row: &[F; WITNESS_WIDTH],
) -> Result<(Vec<F>, Mat<F>), SimpleKernelError> {
    let witness = semantic_row[1..].to_vec();
    let packed = encode_vector_for_full_width(root_context.params(), WITNESS_WIDTH, semantic_row)
        .map_err(SimpleKernelError::BridgeFailed)?;
    Ok((witness, packed))
}

pub(crate) fn build_prepared_step_from_semantic_row(
    root_context: &SimpleKernelRootContext,
    row_index: usize,
    semantic_row: &[F; WITNESS_WIDTH],
) -> Result<StepInput, SimpleKernelError> {
    if semantic_row[0] != F::ONE {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "semantic row {row_index} must have ONE = 1"
        )));
    }
    let (witness, z_mat) = root_encode_semantic_row(root_context, semantic_row)?;
    Ok(StepInput {
        label: format!("chip8/simple/{row_index}"),
        mcs: CcsClaim {
            c: root_context.log().commit(&z_mat),
            x: vec![F::ONE],
            m_in: 1,
        },
        witness: CcsWitness { w: witness, Z: z_mat },
    })
}

pub(crate) fn build_semantic_row_from_row_binding(
    row_binding: &RowBindingClaim,
    cycle_bits: usize,
) -> Result<[F; WITNESS_WIDTH], SimpleKernelError> {
    if row_binding.row_bits.len() != cycle_bits {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} has {} row bits, expected {}",
            row_binding.row_index,
            row_binding.row_bits.len(),
            cycle_bits
        )));
    }
    if !row_index_matches_bits(row_binding.row_index, &row_binding.row_bits) {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} bits do not match its row index",
            row_binding.row_index
        )));
    }
    if row_binding.opened_values.len() != WITNESS_WIDTH - 1 {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row {} has {} opened values, expected {}",
            row_binding.row_index,
            row_binding.opened_values.len(),
            WITNESS_WIDTH - 1
        )));
    }

    let mut row = [F::ZERO; WITNESS_WIDTH];
    row[0] = F::ONE;
    for (col, &value) in row_binding.opened_values.iter().enumerate() {
        row[col + 1] = base_value(value, &format!("row {} column {}", row_binding.row_index, col + 1))?;
    }
    Ok(row)
}

pub(crate) fn build_prepared_step_from_row_binding(
    root_context: &SimpleKernelRootContext,
    row_binding: &RowBindingClaim,
    cycle_bits: usize,
) -> Result<StepInput, SimpleKernelError> {
    let semantic_row = build_semantic_row_from_row_binding(row_binding, cycle_bits)?;
    build_prepared_step_from_semantic_row(root_context, row_binding.row_index, &semantic_row)
}

pub(crate) fn build_prepared_steps_from_frames(
    frames: &[KernelExactFrame],
) -> Result<Vec<StepInput>, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    frames
        .iter()
        .map(|frame| build_prepared_step_from_semantic_row(&root_context, frame.step_idx, &frame.row))
        .collect()
}

fn row_index_matches_bits(row_index: usize, row_bits: &[bool]) -> bool {
    row_bits
        .iter()
        .enumerate()
        .all(|(bit, &is_one)| ((row_index >> bit) & 1 == 1) == is_one)
}

fn base_value(value: K, label: &str) -> Result<F, SimpleKernelError> {
    let [real, imag] = value.as_coeffs();
    if imag != F::ZERO {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "{label} must be a base-field opening"
        )));
    }
    Ok(real)
}

pub fn build_kernel_exact_frames(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
) -> Result<Vec<KernelExactFrame>, SimpleKernelError> {
    let program = Chip8Program {
        bytes: public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let (semantic_rows, aux_data) =
        reconstruct_semantic_rows_and_aux_from_meta(public, &proof.meta_pub, &proof.stage3.row_bindings, &program)?;
    build_kernel_exact_frames_from_rows(public, semantic_rows, aux_data, &program)
}

pub fn build_kernel_exact_frames_from_relation_witness(
    public: &SimpleKernelPublicInput,
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<Vec<KernelExactFrame>, SimpleKernelError> {
    let row_bindings = recover_row_bindings_from_bridge_chunk_transitions(relation_witness.bridge_chunk_transitions())?;
    let program = Chip8Program {
        bytes: public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let (_, padded_trace_length) = cycle_bits_and_padded_trace_length_from_row_bindings(&row_bindings)?;
    let (semantic_rows, aux_data) = reconstruct_semantic_rows_and_aux_from_padded_trace_length(
        public,
        padded_trace_length,
        &row_bindings,
        &program,
    )?;
    build_kernel_exact_frames_from_rows(public, semantic_rows, aux_data, &program)
}

fn build_kernel_exact_frames_from_rows(
    public: &SimpleKernelPublicInput,
    semantic_rows: Vec<[F; WITNESS_WIDTH]>,
    aux_data: Vec<KernelStepAux>,
    program: &Chip8Program,
) -> Result<Vec<KernelExactFrame>, SimpleKernelError> {
    let mut current = initial_state_from_public(public)?;
    let mut frames = Vec::with_capacity(semantic_rows.len());

    for (step_idx, (row, kernel_aux)) in semantic_rows
        .into_iter()
        .zip(aux_data.into_iter())
        .enumerate()
    {
        let frame = build_exact_frame(step_idx, &program, &current, row, kernel_aux)?;
        current = frame.post.clone();
        frames.push(frame);
    }

    Ok(frames)
}

pub fn build_kernel_staged_execution_digest_bundle(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
) -> Result<KernelStagedExecutionDigestBundle, SimpleKernelError> {
    let frames = build_kernel_exact_frames(public, proof)?;
    let stage3_surfaces = build_kernel_stage3_digest_surfaces_from_frames(public, proof, output, &frames)?;
    if frames.len() != stage3_surfaces.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "staged digest frame count {} != stage3 digest count {}",
            frames.len(),
            stage3_surfaces.len()
        )));
    }

    let digests = frames
        .into_iter()
        .zip(stage3_surfaces.into_iter())
        .map(|(frame, stage3)| KernelStagedExecutionDigest {
            stage1: KernelStage1DigestSurface {
                pre: frame.pre.clone(),
                dec: frame.dec.clone(),
                row: frame.row,
            },
            stage2: KernelStage2DigestSurface {
                pre: frame.pre.clone(),
                post: frame.post.clone(),
                dec: frame.dec.clone(),
                row: frame.row,
            },
            result: KernelExecutionResultSurface {
                step_idx: frame.step_idx,
                pre: frame.pre,
                post: frame.post,
                dec: frame.dec,
            },
            stage3,
        })
        .collect();

    Ok(KernelStagedExecutionDigestBundle {
        public: KernelDigestPublicSurface {
            public: public.clone(),
            meta_pub: proof.meta_pub.clone(),
        },
        digests,
    })
}

pub fn verify_kernel_staged_execution_digest_bundle(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    bundle: &KernelStagedExecutionDigestBundle,
) -> Result<(), String> {
    let expected = build_kernel_staged_execution_digest_bundle(public, proof, output)
        .map_err(|err| format!("staged execution digest build failed: {err}"))?;
    if bundle != &expected {
        return Err("staged execution digest bundle mismatch".into());
    }
    Ok(())
}

#[cfg(feature = "chip8-audit")]
pub fn build_kernel_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    audit: &Chip8AuditBundle,
) -> Result<KernelReleaseArtifact, SimpleKernelError> {
    Ok(KernelReleaseArtifact {
        kernel_digest: build_kernel_execution_digest(public, proof, output, audit)?,
        staged_bundle: build_kernel_staged_execution_digest_bundle(public, proof, output)?,
    })
}

#[cfg(feature = "chip8-audit")]
pub fn verify_kernel_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    audit: &Chip8AuditBundle,
    artifact: &KernelReleaseArtifact,
) -> Result<(), String> {
    verify_kernel_execution_digest(public, proof, output, audit, &artifact.kernel_digest)?;
    verify_kernel_staged_execution_digest_bundle(public, proof, output, &artifact.staged_bundle)?;
    Ok(())
}

#[cfg(feature = "chip8-audit")]
pub fn build_kernel_external_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    audit: &Chip8AuditBundle,
) -> Result<KernelExternalReleaseArtifact, SimpleKernelError> {
    let artifact = build_kernel_release_artifact(public, proof, output, audit)?;
    let opening_transcript_source = super::transcript::build_kernel_opening_transcript_source(
        &output.kernel_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.time_opening_summary,
        &proof.joint_opening_summary,
        &proof.joint_opening_fold_bucket_proofs,
        super::lane_commitment::proof_exact_opening_artifacts(proof),
    )?;
    assert_eq!(
        opening_transcript_source
            .exact_openings
            .iter()
            .map(|entry| entry.claim_digest)
            .collect::<Vec<_>>(),
        artifact
            .kernel_digest
            .manifest_surface
            .kernel_manifest
            .claims
            .iter()
            .map(|claim| claim.digest)
            .collect::<Vec<_>>(),
        "opening transcript exact-opening claim digests must follow the kernel manifest order",
    );
    let opening_transcript_surface = super::transcript::build_kernel_opening_transcript_surface(
        &output.kernel_opening_manifest,
        &output.root_opening_manifest,
        &proof.opening_refinement_summary,
        &proof.time_opening_summary,
        &proof.joint_opening_summary,
        &proof.joint_opening_fold_bucket_proofs,
        super::lane_commitment::proof_exact_opening_artifacts(proof),
    )?;
    let frames = artifact.kernel_digest.trace_surface.frames.clone();
    let stage3s = artifact
        .staged_bundle
        .digests
        .iter()
        .map(|digest| digest.stage3.clone())
        .collect();
    Ok(KernelExternalReleaseArtifact {
        root0_bindings: build_kernel_root0_commitment_bindings(&proof.commitments),
        trace_digests: KernelTraceDigestSource {
            stage1_digest: artifact.kernel_digest.trace_surface.stage1_digest,
            stage2_digest: artifact.kernel_digest.trace_surface.stage2_digest,
            stage3_digest: artifact.kernel_digest.trace_surface.stage3_digest,
            semantic_evidence_summary_digest: artifact
                .kernel_digest
                .trace_surface
                .semantic_evidence_summary_digest,
        },
        frames,
        stage3s,
        opening_transcript_source,
        opening_transcript_surface,
        artifact,
    })
}

#[cfg(feature = "chip8-audit")]
pub fn verify_kernel_external_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    audit: &Chip8AuditBundle,
    artifact: &KernelExternalReleaseArtifact,
) -> Result<(), String> {
    let expected = build_kernel_external_release_artifact(public, proof, output, audit)
        .map_err(|err| format!("kernel external release artifact build failed: {err}"))?;
    if artifact != &expected {
        return Err("kernel external release artifact mismatch".into());
    }
    Ok(())
}

fn reconstruct_semantic_rows_and_aux_from_meta(
    public: &SimpleKernelPublicInput,
    meta_pub: &KernelMetaPub,
    row_bindings: &[RowBindingClaim],
    program: &Chip8Program,
) -> Result<(Vec<[F; WITNESS_WIDTH]>, Vec<KernelStepAux>), SimpleKernelError> {
    let pad_pc_word = meta_pub.pad_pc_word;
    let rom_table = build_rom_table(program, pad_pc_word);
    let (trace_rows, aux_data) = reconstruct_trace_rows_and_aux(
        row_bindings,
        meta_pub.semantic_rows,
        meta_pub.padded_trace_length,
        meta_pub.cycle_bits,
        pad_pc_word,
        &rom_table,
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
    )?;
    Ok((
        trace_rows[..meta_pub.semantic_rows].to_vec(),
        aux_data[..meta_pub.semantic_rows].to_vec(),
    ))
}

fn reconstruct_semantic_rows_and_aux_from_padded_trace_length(
    public: &SimpleKernelPublicInput,
    padded_trace_length: usize,
    row_bindings: &[RowBindingClaim],
    program: &Chip8Program,
) -> Result<(Vec<[F; WITNESS_WIDTH]>, Vec<KernelStepAux>), SimpleKernelError> {
    let word_count = program.bytes.len() / 2;
    let pad_pc_word = CHIP8_PROGRAM_START + word_count as u16;
    let semantic_rows = row_bindings.len();
    if semantic_rows == 0 {
        return Err(SimpleKernelError::InvalidWitness(
            "kernel export witness must contain at least one semantic row".into(),
        ));
    }
    if padded_trace_length == 0 || !padded_trace_length.is_power_of_two() {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "padded trace length {padded_trace_length} must be a nonzero power of two"
        )));
    }
    if semantic_rows > padded_trace_length {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "semantic row count {semantic_rows} exceeds padded trace length {padded_trace_length}"
        )));
    }
    let cycle_bits = padded_trace_length.trailing_zeros() as usize;
    let rom_table = build_rom_table(program, pad_pc_word);
    let (trace_rows, aux_data) = reconstruct_trace_rows_and_aux(
        row_bindings,
        semantic_rows,
        padded_trace_length,
        cycle_bits,
        pad_pc_word,
        &rom_table,
        &public.initial_registers,
        public.initial_i,
        &public.initial_ram,
    )?;
    Ok((trace_rows[..semantic_rows].to_vec(), aux_data[..semantic_rows].to_vec()))
}

fn initial_state_from_public(public: &SimpleKernelPublicInput) -> Result<Chip8State, SimpleKernelError> {
    if public.initial_ram.len() != CHIP8_MEMORY_BYTES {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "initial RAM length {} != expected {}",
            public.initial_ram.len(),
            CHIP8_MEMORY_BYTES
        )));
    }
    let pc = public
        .initial_pc_word
        .checked_mul(2)
        .ok_or_else(|| SimpleKernelError::InvalidProgram("initial_pc_word overflows byte PC".into()))?;
    let mut memory = [0u8; CHIP8_MEMORY_BYTES];
    memory.copy_from_slice(&public.initial_ram);
    Ok(Chip8State {
        pc,
        i: public.initial_i,
        v: public.initial_registers,
        memory,
    })
}

fn build_exact_frame(
    step_idx: usize,
    program: &Chip8Program,
    pre: &Chip8State,
    row: [F; WITNESS_WIDTH],
    kernel_aux: KernelStepAux,
) -> Result<KernelExactFrame, SimpleKernelError> {
    let pc_word = decode_u16(row[COL_PC], &format!("exact frame {step_idx} PC"))?;
    let expected_pc_word = pre.pc / 2;
    if pc_word != expected_pc_word {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} row PC {pc_word} != current state PC word {expected_pc_word}"
        )));
    }

    let opcode_word = program
        .opcode_at(pre.pc)
        .ok_or_else(|| SimpleKernelError::InvalidProgram(format!("no opcode at byte pc 0x{:03x}", pre.pc)))?;
    let core = decode_opcode(opcode_word)
        .map_err(|err| SimpleKernelError::InvalidProgram(format!("opcode decode failed: {err}")))?;
    let decode = decode_to_output(opcode_word);
    let row_x_idx = decode_u8(row[COL_X_IDX], &format!("exact frame {step_idx} X_IDX"))?;
    let row_y_idx = decode_u8(row[COL_Y_IDX], &format!("exact frame {step_idx} Y_IDX"))?;
    let burst_last = decode_bool(row[COL_BURST_LAST], &format!("exact frame {step_idx} BURST_LAST"))?;
    let ram_addr = decode_u16(row[COL_RAM_ADDR], &format!("exact frame {step_idx} RAM_ADDR"))?;

    if row_x_idx as usize >= pre.v.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} X_IDX {row_x_idx} escapes V register bank"
        )));
    }
    if decode.uses_y && row_y_idx as usize >= pre.v.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} Y_IDX {row_y_idx} escapes V register bank"
        )));
    }

    expect_row_pre_state(
        step_idx,
        pre,
        &row,
        opcode_word,
        &core,
        row_x_idx,
        row_y_idx,
        burst_last,
        ram_addr,
    )?;
    let post = apply_row_transition(step_idx, pre, &row, &core, row_x_idx, burst_last, ram_addr)?;
    let expected_aux = expected_kernel_aux(pre, &row, row_x_idx, row_y_idx, ram_addr, opcode_word)?;
    if kernel_aux != expected_aux {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} kernel aux mismatch"
        )));
    }

    Ok(KernelExactFrame {
        step_idx,
        dec: KernelFrameDecodeView {
            core,
            opcode_word,
            pc_word,
            row_x_idx,
            row_y_idx,
            is_memop: decode.is_memop,
            burst_last,
            ram_addr,
        },
        pre: pre.clone(),
        post,
        row,
        kernel_aux,
    })
}

fn expect_row_pre_state(
    step_idx: usize,
    pre: &Chip8State,
    row: &[F; WITNESS_WIDTH],
    opcode_word: u16,
    core: &Chip8DecodedStep,
    row_x_idx: u8,
    row_y_idx: u8,
    burst_last: bool,
    ram_addr: u16,
) -> Result<(), SimpleKernelError> {
    let decode = decode_to_output(opcode_word);
    let row_is_memop = decode_bool(row[COL_IS_MEMOP], &format!("exact frame {step_idx} IS_MEMOP"))?;
    if row_is_memop != decode.is_memop {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} IS_MEMOP {row_is_memop} != decoded {}",
            decode.is_memop
        )));
    }
    let reg_x = decode_u8(row[COL_REG_X], &format!("exact frame {step_idx} REG_X"))?;
    if reg_x != pre.v[row_x_idx as usize] {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} REG_X {reg_x} != pre-state V{row_x_idx} {}",
            pre.v[row_x_idx as usize]
        )));
    }
    if decode.uses_y {
        let reg_y = decode_u8(row[COL_REG_Y], &format!("exact frame {step_idx} REG_Y"))?;
        if reg_y != pre.v[row_y_idx as usize] {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} REG_Y {reg_y} != pre-state V{row_y_idx} {}",
                pre.v[row_y_idx as usize]
            )));
        }
    } else if row[COL_REG_Y] != F::ZERO {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} REG_Y must be zero for non-Y opcode"
        )));
    }

    let i_reg = decode_u16(row[COL_I_REG], &format!("exact frame {step_idx} I_REG"))?;
    if i_reg != pre.i {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} I_REG {i_reg} != pre-state I {}",
            pre.i
        )));
    }

    let mem_value = decode_u8(row[COL_MEM_VALUE], &format!("exact frame {step_idx} MEM_VALUE"))?;
    if decode.is_memop {
        let expected_ram_addr = pre.i + row_x_idx as u16;
        if ram_addr != expected_ram_addr {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} RAM_ADDR {ram_addr} != expected {expected_ram_addr}"
            )));
        }
        let expected_mem_value = match core.opcode_id {
            crate::chip8::spec::Chip8Opcode::StoreRegs => pre.v[row_x_idx as usize],
            crate::chip8::spec::Chip8Opcode::LoadRegs => pre.memory[ram_addr as usize],
            _ => {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "exact frame {step_idx} marked memop for non-memory opcode"
                )))
            }
        };
        if mem_value != expected_mem_value {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} MEM_VALUE {mem_value} != expected {expected_mem_value}"
            )));
        }
        let expected_burst_last = row_x_idx == decode.x_bound;
        if burst_last != expected_burst_last {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} BURST_LAST {burst_last} != expected {expected_burst_last}"
            )));
        }
    }

    Ok(())
}

fn apply_row_transition(
    step_idx: usize,
    pre: &Chip8State,
    row: &[F; WITNESS_WIDTH],
    core: &Chip8DecodedStep,
    row_x_idx: u8,
    burst_last: bool,
    ram_addr: u16,
) -> Result<Chip8State, SimpleKernelError> {
    let mut post = pre.clone();
    let pc_next_word = decode_u16(row[COL_PC_NEXT], &format!("exact frame {step_idx} PC_NEXT"))?;
    post.pc = pc_next_word
        .checked_mul(2)
        .ok_or_else(|| SimpleKernelError::BridgeFailed(format!("exact frame {step_idx} PC_NEXT overflows byte PC")))?;
    post.i = decode_u16(row[COL_I_NEXT], &format!("exact frame {step_idx} I_NEXT"))?;

    let reg_x_next = decode_u8(row[COL_REG_X_NEXT], &format!("exact frame {step_idx} REG_X_NEXT"))?;
    match core.opcode_id {
        crate::chip8::spec::Chip8Opcode::LdImm
        | crate::chip8::spec::Chip8Opcode::AddImm
        | crate::chip8::spec::Chip8Opcode::Mov
        | crate::chip8::spec::Chip8Opcode::AddReg => {
            post.v[row_x_idx as usize] = reg_x_next;
        }
        crate::chip8::spec::Chip8Opcode::LoadRegs => {
            post.v[row_x_idx as usize] = reg_x_next;
        }
        crate::chip8::spec::Chip8Opcode::StoreRegs => {
            let mem_value = decode_u8(row[COL_MEM_VALUE], &format!("exact frame {step_idx} MEM_VALUE"))?;
            post.memory[ram_addr as usize] = mem_value;
        }
        crate::chip8::spec::Chip8Opcode::SkipEqImm
        | crate::chip8::spec::Chip8Opcode::Jump
        | crate::chip8::spec::Chip8Opcode::LdI => {}
    }

    let _ = burst_last;
    Ok(post)
}

fn expected_kernel_aux(
    pre: &Chip8State,
    row: &[F; WITNESS_WIDTH],
    row_x_idx: u8,
    row_y_idx: u8,
    ram_addr: u16,
    opcode_word: u16,
) -> Result<KernelStepAux, SimpleKernelError> {
    let decode = decode_to_output(opcode_word);
    let reg_x = decode_u8(row[COL_REG_X], "kernel exact frame REG_X")?;
    let reg_y = decode_u8(row[COL_REG_Y], "kernel exact frame REG_Y")?;
    let mem_value = decode_u8(row[COL_MEM_VALUE], "kernel exact frame MEM_VALUE")?;
    let reg_ra_y_addr = if decode.is_memop {
        REG_SINK_ADDR
    } else if decode.uses_y {
        row_y_idx as usize
    } else {
        REG_SINK_ADDR
    };
    let reg_wa_addr = if decode.is_memop {
        if decode.is_load {
            row_x_idx as usize
        } else {
            REG_SINK_ADDR
        }
    } else if decode.writes_lookup_to_x || decode.writes_mem_to_x {
        row_x_idx as usize
    } else if decode.writes_nnn_to_i {
        16
    } else {
        REG_SINK_ADDR
    };
    let (ram_ra_addr, ram_wa_addr) = if decode.is_memop {
        if decode.reads_ram {
            (ram_addr as usize, RAM_SINK_ADDR)
        } else {
            (RAM_SINK_ADDR, ram_addr as usize)
        }
    } else {
        (RAM_SINK_ADDR, RAM_SINK_ADDR)
    };
    let reg_inc = if decode.is_memop {
        if decode.is_load {
            row[COL_REG_X_NEXT] - row[COL_REG_X]
        } else {
            F::ZERO
        }
    } else if decode.writes_lookup_to_x || decode.writes_mem_to_x {
        row[COL_REG_X_NEXT] - row[COL_REG_X]
    } else if decode.writes_nnn_to_i {
        row[COL_I_NEXT] - row[COL_I_REG]
    } else {
        F::ZERO
    };
    let ram_inc = if decode.is_memop && decode.is_store {
        F::from_u64(mem_value as u64) - F::from_u64(pre.memory[ram_addr as usize] as u64)
    } else {
        F::ZERO
    };

    Ok(KernelStepAux {
        fetch_addr: (pre.pc / 2) as usize,
        decode_addr: opcode_word,
        alu_key: flatten_alu_key(
            decode.lookup_kind,
            operand_from_row_selector(decode.lhs_selector, reg_x, reg_y, decode.kk_dec),
            operand_from_row_selector(decode.rhs_selector, reg_x, reg_y, decode.kk_dec),
        ),
        eq4_key: flatten_eq4_key(row_x_idx, decode.x_bound),
        reg_ra_x_addr: row_x_idx as usize,
        reg_ra_y_addr,
        reg_ra_i_addr: 16,
        reg_wa_addr,
        ram_ra_addr,
        ram_wa_addr,
        reg_inc,
        ram_inc,
        uses_y: decode.uses_y,
        reads_ram: decode.reads_ram,
        writes_ram: decode.writes_ram,
    })
}

fn operand_from_row_selector(selector: OperandSelector, reg_x: u8, reg_y: u8, kk: u8) -> u8 {
    match selector {
        OperandSelector::RegX => reg_x,
        OperandSelector::RegY => reg_y,
        OperandSelector::Kk => kk,
        OperandSelector::Zero => 0,
    }
}

#[cfg(feature = "chip8-audit")]
fn build_kernel_root0_commitment_bindings(commitments: &KernelCommitments) -> Vec<KernelRoot0CommitmentBinding> {
    vec![
        KernelRoot0CommitmentBinding {
            id: CommitmentId::Lane,
            digest: commitments.c_lane,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::FetchRa,
            digest: commitments.c_fetch_ra,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::DecodeRa,
            digest: commitments.c_decode_ra,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::AluRa,
            digest: commitments.c_alu_ra,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::Eq4Ra,
            digest: commitments.c_eq4_ra,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::DecodeHandoff,
            digest: commitments.c_decode_handoff,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::RegTwist,
            digest: commitments.c_reg,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::RamTwist,
            digest: commitments.c_ram,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::RomTable,
            digest: commitments.c_rom_table,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::DecodeTable,
            digest: commitments.c_decode_table,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::AluTable,
            digest: commitments.c_alu_table,
        },
        KernelRoot0CommitmentBinding {
            id: CommitmentId::Eq4Table,
            digest: commitments.c_eq4_table,
        },
    ]
}

fn append_state(tr: &mut Poseidon2Transcript, label: &'static [u8], state: &Chip8State) {
    tr.append_u64s(
        b"neo.fold.next/chip8/state/meta",
        &[
            state.pc as u64,
            state.i as u64,
            state.v.len() as u64,
            state.memory.len() as u64,
        ],
    );
    tr.append_fields_iter(
        label,
        state.v.len(),
        state.v.iter().map(|&value| F::from_u64(value as u64)),
    );
    tr.append_fields_iter(
        b"neo.fold.next/chip8/state/memory",
        state.memory.len(),
        state.memory.iter().map(|&value| F::from_u64(value as u64)),
    );
}

fn append_kernel_aux(tr: &mut Poseidon2Transcript, aux: &KernelStepAux) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_aux",
        &[
            aux.fetch_addr as u64,
            aux.decode_addr as u64,
            aux.alu_key as u64,
            aux.eq4_key as u64,
            aux.reg_ra_x_addr as u64,
            aux.reg_ra_y_addr as u64,
            aux.reg_ra_i_addr as u64,
            aux.reg_wa_addr as u64,
            aux.ram_ra_addr as u64,
            aux.ram_wa_addr as u64,
            aux.uses_y as u64,
            aux.reads_ram as u64,
            aux.writes_ram as u64,
        ],
    );
    tr.append_fields(b"neo.fold.next/chip8/kernel_aux/reg_inc", &[aux.reg_inc]);
    tr.append_fields(b"neo.fold.next/chip8/kernel_aux/ram_inc", &[aux.ram_inc]);
}

fn decode_bool(value: F, label: &str) -> Result<bool, SimpleKernelError> {
    match decode_u64(value, label)? {
        0 => Ok(false),
        1 => Ok(true),
        other => Err(SimpleKernelError::BridgeFailed(format!(
            "{label} boolean value {other} is invalid"
        ))),
    }
}

fn decode_u8(value: F, label: &str) -> Result<u8, SimpleKernelError> {
    u8::try_from(decode_u64(value, label)?)
        .map_err(|_| SimpleKernelError::BridgeFailed(format!("{label} does not fit in u8")))
}

fn decode_u16(value: F, label: &str) -> Result<u16, SimpleKernelError> {
    u16::try_from(decode_u64(value, label)?)
        .map_err(|_| SimpleKernelError::BridgeFailed(format!("{label} does not fit in u16")))
}

fn decode_u64(value: F, _label: &str) -> Result<u64, SimpleKernelError> {
    Ok(value.as_canonical_u64())
}
