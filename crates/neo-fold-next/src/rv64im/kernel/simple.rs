//! Owns the RV64IM simple-kernel proof/output boundary and the live root main-lane prove/verify path.

use neo_ajtai::{s_mul_add, scale_commitment_add_inplace, set_global_pp_seeded, AjtaiSModule, Commitment};
use neo_ccs::{traits::SModuleHomomorphism, Mat};
use neo_math::ring::{cf_inv, Rq as RqEl};
use neo_math::{D, F};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_reductions::error::PiCcsError;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;
use serde::{Deserialize, Serialize};
use std::ops::Deref;
use std::time::Instant;

use crate::proof::{PackagedProof, PublicStep, StepInput};
use crate::prover::CommitmentMixers;
use crate::run::{prove_and_package, verify_packaged};
use crate::rv64im::ccs::{rv64im_root_main_lane_ccs, semantic_row_from_execution_row, RV64IM_ROOT_ROW_WIDTH};
use crate::rv64im::isa::Rv64BuildError;
use crate::rv64im::lower::Rv64ExpandedRow;
use crate::rv64im::stage1::Stage1Summary;
use crate::rv64im::stage2::Stage2Summary;
use crate::rv64im::stage3::Stage3Summary;
use crate::witness_layout::{commit_cols_for_ccs_m, encode_vector_for_ccs_m};

use super::{
    build_parity_case_from_source,
    main_lane_artifact::{
        build_simple_kernel_main_lane_artifact, validate_simple_kernel_main_lane_artifact, SimpleKernelMainLaneArtifact,
    },
    perf_diagnostics::{
        PackagedSimpleKernelVerifyPerf, Rv64imProofProvePerf, SimpleKernelBuildPerf, SimpleKernelVerifyPerf,
    },
    proof_witness::{
        stage_witness_projection_bundle_from_summaries, trace_projection_bundle_from_rows,
        Rv64imStageWitnessProjectionBundle, Rv64imTraceProjectionBundle,
    },
    root_lane_columns::{build_root_lane_columns_from_public_witness, build_root_lane_columns_from_witness},
    root_lane_commitment::{
        build_root_lane_commitment_artifact_from_witness,
        build_root_lane_commitment_summary_artifact_from_public_witness,
    },
    root_lane_witness::{
        build_root_lane_witness, next_power_of_two_len, root_lane_column_digest, root_lane_family_digest,
        root_lane_row_digest, RootLanePublicWitness, RootLaneWitness,
    },
    simple_openings::{SimpleKernelOpeningBundle, SimpleKernelStagePackageBundle},
    stage_artifacts::{
        build_kernel_opening_bundle_with_perf, build_public_kernel_opening_bundle_with_perf,
        build_stage_claim_bundle_from_parts, build_stage_claim_bundle_from_parts_with_perf,
        verify_kernel_opening_bundle_with_perf, SimpleKernelStageClaimBundle,
    },
    stage_package_perf::{
        build_public_stage_package_bundle_with_perf, build_stage_package_bundle_with_perf,
        verify_stage_package_bundle_with_perf,
    },
    RootLaneColumns, RootLaneCommitmentArtifact, RootLaneCommitmentSummaryArtifact, Rv64imKernelSummary,
    Rv64imParityCaseManifest, Rv64imParityDerivedCase, Rv64imParitySourceCase, TranscriptRecord,
};

fn millis_since(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1_000.0
}

pub(super) const SIMPLE_KERNEL_PP_SEED: [u8; 32] = [
    0x40, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
];
// The RV64IM root row carries 32-bit limbs directly, so the root packaged proof needs
// a wider Ajtai bound than the CHIP-8 kernel to keep RLC/DEC within range.
pub(super) const SIMPLE_KERNEL_K_RHO: u32 = 48;
pub(super) const SIMPLE_KERNEL_B: u64 = 1 << 48;
// Ajtai public parameters are global per dimension bucket, so the exact stage surfaces
// must share one canonical seed and rely on local labels/digests for domain separation.
pub(super) const EXACT_STAGE_PP_SEED: [u8; 32] = SIMPLE_KERNEL_PP_SEED;

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelPublicInput {
    pub source: Rv64imParitySourceCase,
    pub max_steps: usize,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelProverInput {
    pub public: SimpleKernelPublicInput,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelVerifierInput {
    pub public: SimpleKernelPublicInput,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct PreparedStepBinding {
    pub trace_index: usize,
    pub row_digest: [u8; 32],
    pub row_opening_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct PreparedStepBindingSummary {
    pub bindings: Vec<PreparedStepBinding>,
    pub binding_count: u64,
    pub first_binding_digest: Option<[u8; 32]>,
    pub last_binding_digest: Option<[u8; 32]>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelTraceWitness {
    pub manifest: Rv64imParityCaseManifest,
    pub execution_rows: Vec<Rv64ExpandedRow>,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelStageWitnessBundle {
    pub stage1: Stage1Summary,
    pub stage2: Stage2Summary,
    pub stage3: Stage3Summary,
    pub transcript: TranscriptRecord,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelKernelClaimBundle {
    pub kernel: Rv64imKernelSummary,
    pub prepared_step_bindings: PreparedStepBindingSummary,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelOutput {
    pub trace: SimpleKernelTraceWitness,
    pub stages: SimpleKernelStageWitnessBundle,
    pub stage_claims: SimpleKernelStageClaimBundle,
    pub stage_packages: SimpleKernelStagePackageBundle,
    pub kernel_opening: SimpleKernelOpeningBundle,
    pub kernel_claims: SimpleKernelKernelClaimBundle,
    pub root_lane_columns: RootLaneColumns,
    pub root_lane_commitment: RootLaneCommitmentArtifact,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelAuditOutput {
    pub kernel: SimpleKernelOutput,
    pub prepared_steps: Vec<StepInput>,
}

impl Deref for SimpleKernelAuditOutput {
    type Target = SimpleKernelOutput;

    fn deref(&self) -> &Self::Target {
        &self.kernel
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub(super) struct PublicSimpleKernelOutput {
    pub trace: Rv64imTraceProjectionBundle,
    pub stages: Rv64imStageWitnessProjectionBundle,
    pub stage_claims: SimpleKernelStageClaimBundle,
    pub stage_packages: SimpleKernelStagePackageBundle,
    pub kernel_opening: SimpleKernelOpeningBundle,
    pub kernel_claims: SimpleKernelKernelClaimBundle,
    pub root_lane_columns: RootLaneColumns,
    pub root_lane_commitment: RootLaneCommitmentSummaryArtifact,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelProof {
    pub root_params_id: [u8; 32],
    pub trace: SimpleKernelTraceWitness,
    pub stages: SimpleKernelStageWitnessBundle,
    pub stage_claims: SimpleKernelStageClaimBundle,
    pub stage_packages: SimpleKernelStagePackageBundle,
    pub kernel_opening: SimpleKernelOpeningBundle,
    pub kernel_claims: SimpleKernelKernelClaimBundle,
    pub root_lane_columns: RootLaneColumns,
    pub root_lane_commitment: RootLaneCommitmentArtifact,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelPackagedProof {
    pub kernel: SimpleKernelProof,
    pub main_lane: SimpleKernelMainLaneArtifact,
}

#[derive(Debug)]
pub enum SimpleKernelError {
    Build(String),
    Bridge(String),
    Proof(String),
}

impl core::fmt::Display for SimpleKernelError {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        match self {
            Self::Build(s) => write!(f, "build failed: {s}"),
            Self::Bridge(s) => write!(f, "bridge failed: {s}"),
            Self::Proof(s) => write!(f, "proof failed: {s}"),
        }
    }
}

impl std::error::Error for SimpleKernelError {}

impl From<Rv64BuildError> for SimpleKernelError {
    fn from(value: Rv64BuildError) -> Self {
        Self::Build(value.to_string())
    }
}

impl From<PiCcsError> for SimpleKernelError {
    fn from(value: PiCcsError) -> Self {
        Self::Proof(value.to_string())
    }
}

struct SimpleKernelRootContext {
    params: NeoParams,
    log: AjtaiSModule,
}

pub(super) struct SimpleKernelExpectedSeed {
    trace: SimpleKernelTraceWitness,
    stages: SimpleKernelStageWitnessBundle,
    stage_claims: SimpleKernelStageClaimBundle,
    kernel_claims: SimpleKernelKernelClaimBundle,
    root_lane_columns: RootLaneColumns,
    root_lane_commitment: RootLaneCommitmentArtifact,
    root_lane_witness: RootLaneWitness,
}

struct SimpleKernelBuildSeed {
    trace: SimpleKernelTraceWitness,
    stages: SimpleKernelStageWitnessBundle,
    stage_claims: SimpleKernelStageClaimBundle,
    stage_packages: SimpleKernelStagePackageBundle,
    kernel_opening: SimpleKernelOpeningBundle,
    kernel_claims: SimpleKernelKernelClaimBundle,
    root_lane_columns: RootLaneColumns,
    root_lane_commitment: RootLaneCommitmentArtifact,
}

struct PublicSimpleKernelBuildSeed {
    trace: Rv64imTraceProjectionBundle,
    stages: Rv64imStageWitnessProjectionBundle,
    stage_claims: SimpleKernelStageClaimBundle,
    stage_packages: SimpleKernelStagePackageBundle,
    kernel_opening: SimpleKernelOpeningBundle,
    kernel_claims: SimpleKernelKernelClaimBundle,
    root_lane_columns: RootLaneColumns,
    root_lane_commitment: RootLaneCommitmentSummaryArtifact,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub(super) struct PublicSimpleKernelWitnessSidecar {
    pub trace: SimpleKernelTraceWitness,
    pub stages: SimpleKernelStageWitnessBundle,
}

fn selected_opening_ref_digest(object_digest: [u8; 32], logical_index: u64, value_digest: [u8; 32]) -> [u8; 32] {
    let mut opening_id = Poseidon2Transcript::new(b"neo.fold.next/rv64im/ajtai_opening_id");
    opening_id.append_message(b"rv64im/ajtai_opening_id/object_digest", &object_digest);
    opening_id.append_u64s(b"rv64im/ajtai_opening_id/logical_index", &[logical_index]);
    let opening_id_digest = opening_id.digest32();

    let mut selected_opening = Poseidon2Transcript::new(b"neo.fold.next/rv64im/selected_opening_ref");
    selected_opening.append_message(b"rv64im/selected_opening_ref/opening_id", &opening_id_digest);
    selected_opening.append_message(b"rv64im/selected_opening_ref/value_digest", &value_digest);
    selected_opening.digest32()
}

fn prepared_step_binding_digest(
    logical_index: usize,
    trace_index: usize,
    semantic_row: &[F; RV64IM_ROOT_ROW_WIDTH],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/prepared_step_binding");
    tr.append_u64s(
        b"rv64im/prepared_step_binding/meta",
        &[logical_index as u64, trace_index as u64],
    );
    tr.append_fields(b"rv64im/prepared_step_binding/semantic_row", semantic_row);
    tr.digest32()
}

impl SimpleKernelRootContext {
    fn new() -> Result<Self, SimpleKernelError> {
        let params = rv64im_simple_root_params();
        let m = commit_cols_for_ccs_m(RV64IM_ROOT_ROW_WIDTH);
        set_global_pp_seeded(D, params.kappa as usize, m, SIMPLE_KERNEL_PP_SEED)
            .map_err(|err| SimpleKernelError::Bridge(format!("canonical RV64IM root seed setup failed: {err}")))?;
        let log = AjtaiSModule::from_global_for_dims(D, m)
            .map_err(|err| SimpleKernelError::Bridge(format!("canonical RV64IM root module failed: {err}")))?;
        Ok(Self { params, log })
    }

    fn params(&self) -> &NeoParams {
        &self.params
    }

    fn log(&self) -> &AjtaiSModule {
        &self.log
    }
}

pub fn rv64im_simple_root_params() -> NeoParams {
    let mut params = NeoParams::goldilocks_auto_r1cs_ccs(RV64IM_ROOT_ROW_WIDTH).expect("valid RV64IM root params");
    params.k_rho = SIMPLE_KERNEL_K_RHO;
    params.B = SIMPLE_KERNEL_B;
    params
}

pub fn rv64im_simple_root_context_id() -> [u8; 32] {
    let params = rv64im_simple_root_params();
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_context");
    tr.append_u64s(
        b"rv64im/root_context/values",
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
            RV64IM_ROOT_ROW_WIDTH as u64,
            commit_cols_for_ccs_m(RV64IM_ROOT_ROW_WIDTH) as u64,
        ],
    );
    tr.append_message(b"rv64im/root_context/seed", &SIMPLE_KERNEL_PP_SEED);
    tr.digest32()
}

fn root_encode_semantic_row(
    root_context: &SimpleKernelRootContext,
    trace_index: usize,
    semantic_row: &[F; RV64IM_ROOT_ROW_WIDTH],
) -> Result<(Vec<F>, Mat<F>), SimpleKernelError> {
    let witness = semantic_row[1..].to_vec();
    let packed = encode_vector_for_ccs_m(root_context.params(), RV64IM_ROOT_ROW_WIDTH, semantic_row)
        .map_err(|err| SimpleKernelError::Bridge(format!("root encoding failed for row {trace_index}: {err}")))?;
    Ok((witness, packed))
}

fn build_prepared_step_from_semantic_row(
    root_context: &SimpleKernelRootContext,
    trace_index: usize,
    semantic_row: &[F; RV64IM_ROOT_ROW_WIDTH],
) -> Result<StepInput, SimpleKernelError> {
    let (witness, z_mat) = root_encode_semantic_row(root_context, trace_index, semantic_row)?;
    Ok(StepInput {
        label: format!("rv64im/simple/trace_{trace_index}"),
        mcs: neo_ccs::CcsClaim {
            c: root_context.log().commit(&z_mat),
            x: vec![F::ONE],
            m_in: 1,
        },
        witness: neo_ccs::CcsWitness { w: witness, Z: z_mat },
    })
}

fn build_prepared_steps_from_root_lane_witness(
    root_context: &SimpleKernelRootContext,
    rows: &[Rv64ExpandedRow],
    root_lane_witness: &RootLaneWitness,
) -> Result<Vec<StepInput>, SimpleKernelError> {
    if rows.len() != root_lane_witness.semantic_rows.len() {
        return Err(SimpleKernelError::Bridge(format!(
            "root lane semantic row count {} != execution row count {}",
            root_lane_witness.semantic_rows.len(),
            rows.len()
        )));
    }
    rows.iter()
        .zip(root_lane_witness.semantic_rows.iter())
        .map(|(row, semantic_row)| build_prepared_step_from_semantic_row(root_context, row.trace_index, semantic_row))
        .collect()
}

pub(super) fn build_prepared_steps_from_execution_rows(
    rows: &[Rv64ExpandedRow],
) -> Result<Vec<StepInput>, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    rows.iter()
        .map(|row| {
            let semantic_row = semantic_row_from_execution_row(row);
            build_prepared_step_from_semantic_row(&root_context, row.trace_index, &semantic_row)
        })
        .collect()
}

fn same_public_step(lhs: &PublicStep, rhs: &PublicStep) -> bool {
    lhs.label == rhs.label
        && lhs.mcs.m_in == rhs.mcs.m_in
        && lhs.mcs.x == rhs.mcs.x
        && lhs.mcs.c.d == rhs.mcs.c.d
        && lhs.mcs.c.kappa == rhs.mcs.c.kappa
        && lhs.mcs.c.data == rhs.mcs.c.data
}

pub(super) fn build_root_main_lane_packaged_proof(
    rows: &[Rv64ExpandedRow],
) -> Result<PackagedProof, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    let ccs = rv64im_root_main_lane_ccs().map_err(SimpleKernelError::Proof)?;
    let steps = build_prepared_steps_from_execution_rows(rows)?;
    Ok(prove_and_package(
        FoldingMode::Optimized,
        root_context.params(),
        &ccs,
        steps,
        root_context.log(),
        rv64im_ajtai_mixers(),
    )?)
}

pub(super) fn verify_root_main_lane_packaged_proof(
    rows: &[Rv64ExpandedRow],
    packaged: &PackagedProof,
) -> Result<(), SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    let ccs = rv64im_root_main_lane_ccs().map_err(SimpleKernelError::Proof)?;
    let steps = build_prepared_steps_from_execution_rows(rows)?;
    if packaged.statement.steps.len() != steps.len() {
        return Err(SimpleKernelError::Bridge(format!(
            "RV64IM root main-lane packaged proof step count {} != execution row count {}",
            packaged.statement.steps.len(),
            steps.len()
        )));
    }
    for (idx, (actual, expected)) in packaged
        .statement
        .steps
        .iter()
        .zip(steps.iter().map(StepInput::instance))
        .enumerate()
    {
        if !same_public_step(actual, &expected) {
            return Err(SimpleKernelError::Bridge(format!(
                "RV64IM root main-lane packaged proof public step {idx} mismatch"
            )));
        }
    }
    verify_packaged(
        FoldingMode::Optimized,
        root_context.params(),
        &ccs,
        packaged,
        rv64im_ajtai_mixers(),
    )?;
    Ok(())
}

fn build_prepared_step_binding_summary(
    rows: &[Rv64ExpandedRow],
    semantic_rows: &[[F; RV64IM_ROOT_ROW_WIDTH]],
    root_lane_columns: &RootLaneColumns,
    materialize_bindings: bool,
) -> Result<PreparedStepBindingSummary, SimpleKernelError> {
    if rows.len() != semantic_rows.len() {
        return Err(SimpleKernelError::Bridge(format!(
            "prepared step row count {} != semantic row count {}",
            rows.len(),
            semantic_rows.len(),
        )));
    }
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/prepared_step_binding_summary");
    tr.append_u64s(b"rv64im/prepared_step_binding_summary/len", &[rows.len() as u64]);
    let mut bindings = if materialize_bindings {
        Vec::with_capacity(rows.len())
    } else {
        Vec::new()
    };
    let mut first_binding_digest = None;
    let mut last_binding_digest = None;
    for (logical_index, (row, semantic_row)) in rows.iter().zip(semantic_rows.iter()).enumerate() {
        let binding_digest = prepared_step_binding_digest(logical_index, row.trace_index, semantic_row);
        if first_binding_digest.is_none() {
            first_binding_digest = Some(binding_digest);
        }
        last_binding_digest = Some(binding_digest);
        tr.append_message(b"rv64im/prepared_step_binding_summary/binding_digest", &binding_digest);
        if materialize_bindings {
            let row_digest = root_lane_row_digest(logical_index as u64, semantic_row);
            let row_opening_digest =
                selected_opening_ref_digest(root_lane_columns.object.digest, logical_index as u64, row_digest);
            bindings.push(PreparedStepBinding {
                trace_index: row.trace_index,
                row_digest,
                row_opening_digest,
                digest: binding_digest,
            });
        }
    }
    Ok(PreparedStepBindingSummary {
        bindings,
        binding_count: rows.len() as u64,
        first_binding_digest,
        last_binding_digest,
        digest: tr.digest32(),
    })
}

pub(super) fn build_public_root_lane_witness_and_binding_summary(
    rows: &[Rv64ExpandedRow],
) -> (RootLanePublicWitness, PreparedStepBindingSummary) {
    let time_len = rows.len();
    let padded_time_len = next_power_of_two_len(time_len);
    let mut columns = (0..RV64IM_ROOT_ROW_WIDTH)
        .map(|_| Vec::with_capacity(time_len))
        .collect::<Vec<_>>();
    let mut binding_tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/prepared_step_binding_summary");
    binding_tr.append_u64s(b"rv64im/prepared_step_binding_summary/len", &[time_len as u64]);

    let mut first_row_digest = None;
    let mut last_row_digest = None;
    let mut first_binding_digest = None;
    let mut last_binding_digest = None;
    for (logical_index, row) in rows.iter().enumerate() {
        let semantic_row = semantic_row_from_execution_row(row);
        if logical_index == 0 {
            first_row_digest = Some(root_lane_row_digest(logical_index as u64, &semantic_row));
        }
        if logical_index + 1 == time_len {
            last_row_digest = Some(root_lane_row_digest(logical_index as u64, &semantic_row));
        }
        let binding_digest = prepared_step_binding_digest(logical_index, row.trace_index, &semantic_row);
        if first_binding_digest.is_none() {
            first_binding_digest = Some(binding_digest);
        }
        last_binding_digest = Some(binding_digest);
        binding_tr.append_message(b"rv64im/prepared_step_binding_summary/binding_digest", &binding_digest);
        for (column_index, value) in semantic_row.iter().enumerate() {
            columns[column_index].push(*value);
        }
    }

    let column_digests = columns
        .iter()
        .enumerate()
        .map(|(column_index, values)| root_lane_column_digest(column_index as u64, values))
        .collect::<Vec<_>>();
    let family_digest = root_lane_family_digest(&column_digests);

    (
        RootLanePublicWitness {
            columns,
            time_len,
            padded_time_len,
            first_row_digest,
            last_row_digest,
            column_digests,
            family_digest,
        },
        PreparedStepBindingSummary {
            bindings: Vec::new(),
            binding_count: time_len as u64,
            first_binding_digest,
            last_binding_digest,
            digest: binding_tr.digest32(),
        },
    )
}

fn trace_witness_from_derived(derived: &Rv64imParityDerivedCase) -> SimpleKernelTraceWitness {
    SimpleKernelTraceWitness {
        manifest: derived.manifest.clone(),
        execution_rows: derived.execution_rows.clone(),
    }
}

fn stage_witness_bundle_from_derived(derived: &Rv64imParityDerivedCase) -> SimpleKernelStageWitnessBundle {
    SimpleKernelStageWitnessBundle {
        stage1: derived.stage1.clone(),
        stage2: derived.stage2.clone(),
        stage3: derived.stage3.clone(),
        transcript: derived.transcript.clone(),
    }
}

fn kernel_claim_bundle_from_parts(
    derived: &Rv64imParityDerivedCase,
    prepared_step_bindings: PreparedStepBindingSummary,
) -> SimpleKernelKernelClaimBundle {
    SimpleKernelKernelClaimBundle {
        kernel: derived.kernel.clone(),
        prepared_step_bindings,
    }
}

fn build_simple_kernel_expected_seed(
    public: &SimpleKernelPublicInput,
    materialize_bindings: bool,
) -> Result<SimpleKernelExpectedSeed, SimpleKernelError> {
    let (_, derived) = build_parity_case_from_source(public.source.clone(), public.max_steps)?;
    let root_context = SimpleKernelRootContext::new()?;
    let root_lane_witness = build_root_lane_witness(&derived.execution_rows);
    let root_lane_columns = build_root_lane_columns_from_witness(&root_lane_witness);
    let root_lane_commitment =
        build_root_lane_commitment_artifact_from_witness(root_context.params(), &root_lane_witness)?;
    let prepared_step_bindings = build_prepared_step_binding_summary(
        &derived.execution_rows,
        &root_lane_witness.semantic_rows,
        &root_lane_columns,
        materialize_bindings,
    )?;
    let trace = trace_witness_from_derived(&derived);
    let stages = stage_witness_bundle_from_derived(&derived);
    let stage_claims = build_stage_claim_bundle_from_parts(
        &stages.stage1,
        &stages.stage2,
        &stages.stage3,
        &stages.transcript,
        &derived.kernel,
    )?;
    let kernel_claims = kernel_claim_bundle_from_parts(&derived, prepared_step_bindings);
    Ok(SimpleKernelExpectedSeed {
        trace,
        stages,
        stage_claims,
        kernel_claims,
        root_lane_columns,
        root_lane_commitment,
        root_lane_witness,
    })
}

fn build_simple_kernel_seed_and_witness_with_perf(
    public: &SimpleKernelPublicInput,
    materialize_bindings: bool,
) -> Result<((SimpleKernelBuildSeed, RootLaneWitness), SimpleKernelBuildPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let (_, derived) = build_parity_case_from_source(public.source.clone(), public.max_steps)?;
    let root_context = SimpleKernelRootContext::new()?;

    let root_lane_witness_started = Instant::now();
    let root_lane_witness = build_root_lane_witness(&derived.execution_rows);
    let root_lane_witness_ms = millis_since(root_lane_witness_started);

    let root_lane_columns_started = Instant::now();
    let root_lane_columns = build_root_lane_columns_from_witness(&root_lane_witness);
    let root_lane_columns_ms = millis_since(root_lane_columns_started);

    let root_lane_commitment_started = Instant::now();
    let root_lane_commitment =
        build_root_lane_commitment_artifact_from_witness(root_context.params(), &root_lane_witness)?;
    let root_lane_commitment_ms = millis_since(root_lane_commitment_started);

    let bindings_started = Instant::now();
    let prepared_step_bindings = build_prepared_step_binding_summary(
        &derived.execution_rows,
        &root_lane_witness.semantic_rows,
        &root_lane_columns,
        materialize_bindings,
    )?;
    let prepared_step_bindings_ms = millis_since(bindings_started);

    let trace = trace_witness_from_derived(&derived);
    let stages = stage_witness_bundle_from_derived(&derived);
    let (stage_claims, stage_claim_bundle) = build_stage_claim_bundle_from_parts_with_perf(
        &stages.stage1,
        &stages.stage2,
        &stages.stage3,
        &stages.transcript,
        &derived.kernel,
    )?;
    let kernel_claims = kernel_claim_bundle_from_parts(&derived, prepared_step_bindings);
    let (stage_packages, stage_package_bundle) =
        build_stage_package_bundle_with_perf(&stages.stage1, &stages.stage2, &stages.stage3, &stage_claims)?;
    let (kernel_opening, kernel_opening_bundle) =
        build_kernel_opening_bundle_with_perf(&stage_claims, &stage_packages, &kernel_claims, &root_lane_commitment)?;
    Ok((
        (
            SimpleKernelBuildSeed {
                trace,
                stages,
                stage_claims,
                stage_packages,
                kernel_opening,
                kernel_claims,
                root_lane_columns,
                root_lane_commitment,
            },
            root_lane_witness,
        ),
        SimpleKernelBuildPerf {
            root_lane_witness_ms,
            root_lane_columns_ms,
            root_lane_commitment_ms,
            public_steps_ms: 0.0,
            prepared_steps_ms: 0.0,
            prepared_step_bindings_ms,
            stage_claim_bundle,
            stage_package_bundle,
            kernel_opening_bundle,
            total_ms: millis_since(total_started),
        },
    ))
}

fn build_simple_kernel_seed_with_perf(
    public: &SimpleKernelPublicInput,
) -> Result<(SimpleKernelBuildSeed, SimpleKernelBuildPerf), SimpleKernelError> {
    let ((seed, _root_lane_witness), perf) = build_simple_kernel_seed_and_witness_with_perf(public, false)?;
    Ok((seed, perf))
}

pub fn build_simple_kernel_witness(
    public: &SimpleKernelPublicInput,
) -> Result<SimpleKernelAuditOutput, SimpleKernelError> {
    Ok(build_simple_kernel_witness_with_perf(public)?.0)
}

pub fn build_simple_kernel_witness_with_perf(
    public: &SimpleKernelPublicInput,
) -> Result<(SimpleKernelAuditOutput, SimpleKernelBuildPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let ((seed, root_lane_witness), mut perf) = build_simple_kernel_seed_and_witness_with_perf(public, true)?;
    let prepared_steps_started = Instant::now();
    let root_context = SimpleKernelRootContext::new()?;
    let prepared_steps =
        build_prepared_steps_from_root_lane_witness(&root_context, &seed.trace.execution_rows, &root_lane_witness)?;
    perf.prepared_steps_ms = millis_since(prepared_steps_started);
    perf.total_ms = millis_since(total_started);
    Ok((
        SimpleKernelAuditOutput {
            kernel: SimpleKernelOutput {
                trace: seed.trace,
                stages: seed.stages,
                stage_claims: seed.stage_claims,
                stage_packages: seed.stage_packages,
                kernel_opening: seed.kernel_opening,
                kernel_claims: seed.kernel_claims,
                root_lane_columns: seed.root_lane_columns,
                root_lane_commitment: seed.root_lane_commitment,
            },
            prepared_steps,
        },
        perf,
    ))
}

fn build_packaged_simple_kernel_output_with_perf(
    public: &SimpleKernelPublicInput,
) -> Result<(SimpleKernelOutput, SimpleKernelBuildPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let (seed, mut perf) = build_simple_kernel_seed_with_perf(public)?;
    perf.total_ms = millis_since(total_started);
    Ok((
        SimpleKernelOutput {
            trace: seed.trace,
            stages: seed.stages,
            stage_claims: seed.stage_claims,
            stage_packages: seed.stage_packages,
            kernel_opening: seed.kernel_opening,
            kernel_claims: seed.kernel_claims,
            root_lane_columns: seed.root_lane_columns,
            root_lane_commitment: seed.root_lane_commitment,
        },
        perf,
    ))
}

fn build_public_simple_kernel_seed_from_derived_with_perf(
    derived: &Rv64imParityDerivedCase,
) -> Result<(PublicSimpleKernelBuildSeed, SimpleKernelBuildPerf), SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;

    let root_lane_witness_started = Instant::now();
    let (root_lane_witness, prepared_step_bindings) =
        build_public_root_lane_witness_and_binding_summary(&derived.execution_rows);
    let root_lane_witness_ms = millis_since(root_lane_witness_started);

    let root_lane_columns_started = Instant::now();
    let root_lane_columns = build_root_lane_columns_from_public_witness(&root_lane_witness);
    let root_lane_columns_ms = millis_since(root_lane_columns_started);

    let root_lane_commitment_started = Instant::now();
    let root_lane_commitment =
        build_root_lane_commitment_summary_artifact_from_public_witness(root_context.params(), &root_lane_witness)?;
    let root_lane_commitment_ms = millis_since(root_lane_commitment_started);

    let prepared_step_bindings_ms = 0.0;

    let trace = trace_projection_bundle_from_rows(
        &derived.manifest,
        &derived.execution_rows,
        derived.kernel.execution_digest,
    );
    let stages = stage_witness_projection_bundle_from_summaries(
        &derived.stage1,
        &derived.stage2,
        &derived.stage3,
        &derived.transcript,
    );
    let (stage_claims, stage_claim_bundle) = build_stage_claim_bundle_from_parts_with_perf(
        &derived.stage1,
        &derived.stage2,
        &derived.stage3,
        &derived.transcript,
        &derived.kernel,
    )?;
    let kernel_claims = kernel_claim_bundle_from_parts(&derived, prepared_step_bindings);
    let (stage_packages, stage_package_bundle) =
        build_public_stage_package_bundle_with_perf(&derived.stage1, &derived.stage2, &derived.stage3, &stage_claims)?;
    let (kernel_opening, kernel_opening_bundle) = build_public_kernel_opening_bundle_with_perf(
        &stage_claims,
        &stage_packages,
        &kernel_claims,
        &root_lane_commitment,
    )?;
    Ok((
        PublicSimpleKernelBuildSeed {
            trace,
            stages,
            stage_claims,
            stage_packages,
            kernel_opening,
            kernel_claims,
            root_lane_columns,
            root_lane_commitment,
        },
        SimpleKernelBuildPerf {
            root_lane_witness_ms,
            root_lane_columns_ms,
            root_lane_commitment_ms,
            public_steps_ms: 0.0,
            prepared_steps_ms: 0.0,
            prepared_step_bindings_ms,
            stage_claim_bundle,
            stage_package_bundle,
            kernel_opening_bundle,
            total_ms: 0.0,
        },
    ))
}

pub(super) fn simple_kernel_output_from_expected_seed(
    expected: SimpleKernelExpectedSeed,
    stage_packages: SimpleKernelStagePackageBundle,
    kernel_opening: SimpleKernelOpeningBundle,
) -> SimpleKernelOutput {
    SimpleKernelOutput {
        trace: expected.trace,
        stages: expected.stages,
        stage_claims: expected.stage_claims,
        stage_packages,
        kernel_opening,
        kernel_claims: expected.kernel_claims,
        root_lane_columns: expected.root_lane_columns,
        root_lane_commitment: expected.root_lane_commitment,
    }
}

fn public_simple_kernel_output_from_seed(seed: PublicSimpleKernelBuildSeed) -> PublicSimpleKernelOutput {
    PublicSimpleKernelOutput {
        trace: seed.trace,
        stages: seed.stages,
        stage_claims: seed.stage_claims,
        stage_packages: seed.stage_packages,
        kernel_opening: seed.kernel_opening,
        kernel_claims: seed.kernel_claims,
        root_lane_columns: seed.root_lane_columns,
        root_lane_commitment: seed.root_lane_commitment,
    }
}

pub(super) fn build_public_simple_kernel_output_and_witness_with_perf(
    public: &SimpleKernelPublicInput,
) -> Result<
    (
        (PublicSimpleKernelOutput, PublicSimpleKernelWitnessSidecar),
        SimpleKernelBuildPerf,
    ),
    SimpleKernelError,
> {
    let total_started = Instant::now();
    let (_, derived) = build_parity_case_from_source(public.source.clone(), public.max_steps)?;
    let (seed, mut perf) = build_public_simple_kernel_seed_from_derived_with_perf(&derived)?;
    perf.total_ms = millis_since(total_started);
    let sidecar = PublicSimpleKernelWitnessSidecar {
        trace: trace_witness_from_derived(&derived),
        stages: stage_witness_bundle_from_derived(&derived),
    };
    Ok(((public_simple_kernel_output_from_seed(seed), sidecar), perf))
}

pub(super) fn simple_kernel_proof_from_output(output: &SimpleKernelOutput) -> SimpleKernelProof {
    SimpleKernelProof {
        root_params_id: rv64im_simple_root_context_id(),
        trace: output.trace.clone(),
        stages: output.stages.clone(),
        stage_claims: output.stage_claims.clone(),
        stage_packages: output.stage_packages.clone(),
        kernel_opening: output.kernel_opening.clone(),
        kernel_claims: output.kernel_claims.clone(),
        root_lane_columns: output.root_lane_columns.clone(),
        root_lane_commitment: output.root_lane_commitment.clone(),
    }
}

pub fn prove_simple_kernel(
    input: &SimpleKernelProverInput,
) -> Result<(SimpleKernelAuditOutput, SimpleKernelProof), SimpleKernelError> {
    let output = build_simple_kernel_witness(&input.public)?;
    let proof = simple_kernel_proof_from_output(&output.kernel);
    Ok((output, proof))
}

pub fn verify_simple_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<SimpleKernelAuditOutput, SimpleKernelError> {
    Ok(verify_simple_kernel_with_perf(input, proof)?.0)
}

pub fn verify_simple_kernel_with_perf(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<(SimpleKernelAuditOutput, SimpleKernelVerifyPerf), SimpleKernelError> {
    let (expected, perf) = verify_simple_kernel_seed_with_perf(input, proof)?;
    let root_context = SimpleKernelRootContext::new()?;
    let prepared_steps = build_prepared_steps_from_root_lane_witness(
        &root_context,
        &expected.trace.execution_rows,
        &expected.root_lane_witness,
    )?;
    Ok((
        SimpleKernelAuditOutput {
            kernel: simple_kernel_output_from_expected_seed(
                expected,
                proof.stage_packages.clone(),
                proof.kernel_opening.clone(),
            ),
            prepared_steps,
        },
        perf,
    ))
}

pub(super) fn verify_simple_kernel_core_seed_with_perf(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<(SimpleKernelExpectedSeed, SimpleKernelVerifyPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let expected_root = rv64im_simple_root_context_id();
    if proof.root_params_id != expected_root {
        return Err(SimpleKernelError::Bridge("RV64IM root context id mismatch".into()));
    }
    let expected_started = Instant::now();
    let expected = build_simple_kernel_expected_seed(&input.public, true)?;
    let expected_core_ms = millis_since(expected_started);
    let trace_match_started = Instant::now();
    if proof.trace != expected.trace {
        return Err(SimpleKernelError::Bridge("RV64IM kernel trace witness mismatch".into()));
    }
    let trace_match_ms = millis_since(trace_match_started);
    let stages_match_started = Instant::now();
    if proof.stages != expected.stages {
        return Err(SimpleKernelError::Bridge("RV64IM stage witness bundle mismatch".into()));
    }
    let stages_match_ms = millis_since(stages_match_started);
    let stage_claims_match_started = Instant::now();
    if proof.stage_claims != expected.stage_claims {
        return Err(SimpleKernelError::Bridge("RV64IM stage claim bundle mismatch".into()));
    }
    let stage_claims_match_ms = millis_since(stage_claims_match_started);
    let kernel_claims_match_started = Instant::now();
    if proof.kernel_claims != expected.kernel_claims {
        return Err(SimpleKernelError::Bridge("RV64IM kernel claim bundle mismatch".into()));
    }
    let kernel_claims_match_ms = millis_since(kernel_claims_match_started);
    let root_lane_columns_match_started = Instant::now();
    if proof.root_lane_columns != expected.root_lane_columns {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root lane column family mismatch".into(),
        ));
    }
    let root_lane_columns_match_ms = millis_since(root_lane_columns_match_started);
    let root_lane_commitment_match_started = Instant::now();
    if proof.root_lane_commitment != expected.root_lane_commitment {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root lane commitment artifact mismatch".into(),
        ));
    }
    let root_lane_commitment_match_ms = millis_since(root_lane_commitment_match_started);
    Ok((
        expected,
        SimpleKernelVerifyPerf {
            expected_core_ms,
            trace_match_ms,
            stages_match_ms,
            stage_claims_match_ms,
            kernel_claims_match_ms,
            root_lane_columns_match_ms,
            root_lane_commitment_match_ms,
            stage_package_bundle: Default::default(),
            kernel_opening_bundle: Default::default(),
            total_ms: millis_since(total_started),
        },
    ))
}

fn verify_simple_kernel_seed_with_perf(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<(SimpleKernelExpectedSeed, SimpleKernelVerifyPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let (expected, mut perf) = verify_simple_kernel_core_seed_with_perf(input, proof)?;
    let stage_package_bundle = verify_stage_package_bundle_with_perf(
        &expected.stages.stage1,
        &expected.stages.stage2,
        &expected.stages.stage3,
        &proof.stage_packages,
        &expected.stage_claims,
    )?;
    let kernel_opening_bundle = verify_kernel_opening_bundle_with_perf(
        &proof.kernel_opening,
        &expected.stage_claims,
        &proof.stage_packages,
        &expected.kernel_claims,
        &expected.root_lane_commitment,
    )?;
    perf.stage_package_bundle = stage_package_bundle;
    perf.kernel_opening_bundle = kernel_opening_bundle;
    perf.total_ms = millis_since(total_started);
    Ok((expected, perf))
}

fn verify_packaged_simple_kernel_seed_with_perf(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<(SimpleKernelExpectedSeed, SimpleKernelVerifyPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let expected_root = rv64im_simple_root_context_id();
    if proof.root_params_id != expected_root {
        return Err(SimpleKernelError::Bridge("RV64IM root context id mismatch".into()));
    }
    let expected_started = Instant::now();
    let expected = build_simple_kernel_expected_seed(&input.public, false)?;
    let expected_core_ms = millis_since(expected_started);
    let trace_match_started = Instant::now();
    if proof.trace != expected.trace {
        return Err(SimpleKernelError::Bridge("RV64IM kernel trace witness mismatch".into()));
    }
    let trace_match_ms = millis_since(trace_match_started);
    let stages_match_started = Instant::now();
    if proof.stages != expected.stages {
        return Err(SimpleKernelError::Bridge("RV64IM stage witness bundle mismatch".into()));
    }
    let stages_match_ms = millis_since(stages_match_started);
    let stage_claims_match_started = Instant::now();
    if proof.stage_claims != expected.stage_claims {
        return Err(SimpleKernelError::Bridge("RV64IM stage claim bundle mismatch".into()));
    }
    let stage_claims_match_ms = millis_since(stage_claims_match_started);
    let kernel_claims_match_started = Instant::now();
    if proof.kernel_claims != expected.kernel_claims {
        return Err(SimpleKernelError::Bridge("RV64IM kernel claim bundle mismatch".into()));
    }
    let kernel_claims_match_ms = millis_since(kernel_claims_match_started);
    let root_lane_columns_match_started = Instant::now();
    if proof.root_lane_columns != expected.root_lane_columns {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root lane column family mismatch".into(),
        ));
    }
    let root_lane_columns_match_ms = millis_since(root_lane_columns_match_started);
    let root_lane_commitment_match_started = Instant::now();
    if proof.root_lane_commitment != expected.root_lane_commitment {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root lane commitment artifact mismatch".into(),
        ));
    }
    let root_lane_commitment_match_ms = millis_since(root_lane_commitment_match_started);
    let stage_package_bundle = verify_stage_package_bundle_with_perf(
        &expected.stages.stage1,
        &expected.stages.stage2,
        &expected.stages.stage3,
        &proof.stage_packages,
        &expected.stage_claims,
    )?;
    let kernel_opening_bundle = verify_kernel_opening_bundle_with_perf(
        &proof.kernel_opening,
        &expected.stage_claims,
        &proof.stage_packages,
        &expected.kernel_claims,
        &expected.root_lane_commitment,
    )?;
    Ok((
        expected,
        SimpleKernelVerifyPerf {
            expected_core_ms,
            trace_match_ms,
            stages_match_ms,
            stage_claims_match_ms,
            kernel_claims_match_ms,
            root_lane_columns_match_ms,
            root_lane_commitment_match_ms,
            stage_package_bundle,
            kernel_opening_bundle,
            total_ms: millis_since(total_started),
        },
    ))
}

fn rot_matrix_to_rq(mat: &Mat<F>) -> RqEl {
    let mut coeffs = [F::ZERO; D];
    for i in 0..D {
        coeffs[i] = mat[(i, 0)];
    }
    cf_inv(coeffs)
}

fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Commitment]) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    for (rho, c) in rhos.iter().zip(cs.iter()) {
        let rq = rot_matrix_to_rq(rho);
        s_mul_add(&mut acc, &rq, c);
    }
    acc
}

fn combine_b_pows(cs: &[Commitment], b: u32) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    let base = F::from_u64(b as u64);
    let mut pow = F::ONE;
    for c in cs {
        scale_commitment_add_inplace(&mut acc, pow, c);
        pow *= base;
    }
    acc
}

pub fn rv64im_ajtai_mixers(
) -> CommitmentMixers<fn(&[Mat<F>], &[Commitment]) -> Commitment, fn(&[Commitment], u32) -> Commitment> {
    CommitmentMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

pub fn prove_packaged_simple_kernel(
    input: &SimpleKernelProverInput,
) -> Result<(SimpleKernelOutput, SimpleKernelPackagedProof), SimpleKernelError> {
    Ok(prove_packaged_simple_kernel_with_perf(input)?.0)
}

pub fn prove_packaged_simple_kernel_with_perf(
    input: &SimpleKernelProverInput,
) -> Result<((SimpleKernelOutput, SimpleKernelPackagedProof), Rv64imProofProvePerf), SimpleKernelError> {
    let total_started = Instant::now();
    let (output, simple_kernel) = build_packaged_simple_kernel_output_with_perf(&input.public)?;
    let kernel = simple_kernel_proof_from_output(&output);
    let main_lane_started = Instant::now();
    let main_lane = build_simple_kernel_main_lane_artifact(&output.root_lane_columns, &output.root_lane_commitment)?;
    Ok((
        (output, SimpleKernelPackagedProof { kernel, main_lane }),
        Rv64imProofProvePerf {
            simple_kernel,
            main_lane_ms: millis_since(main_lane_started),
            public_export_ms: 0.0,
            total_ms: millis_since(total_started),
        },
    ))
}

pub fn verify_packaged_simple_kernel(
    input: &SimpleKernelVerifierInput,
    packaged: &SimpleKernelPackagedProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    Ok(verify_packaged_simple_kernel_with_perf(input, packaged)?.0)
}

pub fn verify_packaged_simple_kernel_with_perf(
    input: &SimpleKernelVerifierInput,
    packaged: &SimpleKernelPackagedProof,
) -> Result<(SimpleKernelOutput, PackagedSimpleKernelVerifyPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let (expected, simple_kernel) = verify_packaged_simple_kernel_seed_with_perf(input, &packaged.kernel)?;
    let main_lane_artifact_match_started = Instant::now();
    validate_simple_kernel_main_lane_artifact(
        &expected.root_lane_columns,
        &expected.root_lane_commitment,
        &packaged.main_lane,
    )?;
    let main_lane_artifact_match_ms = millis_since(main_lane_artifact_match_started);
    Ok((
        simple_kernel_output_from_expected_seed(
            expected,
            packaged.kernel.stage_packages.clone(),
            packaged.kernel.kernel_opening.clone(),
        ),
        PackagedSimpleKernelVerifyPerf {
            simple_kernel,
            main_lane_artifact_match_ms,
            total_ms: millis_since(total_started),
        },
    ))
}
