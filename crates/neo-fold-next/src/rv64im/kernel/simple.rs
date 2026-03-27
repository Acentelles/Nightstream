//! Owns the RV64IM simple-kernel proof/output boundary and the live root main-lane prove/verify path.

use neo_ajtai::{s_mul_add, scale_commitment_add_inplace, set_global_pp_seeded, AjtaiSModule, Commitment};
use neo_ccs::{traits::SModuleHomomorphism, Mat};
use neo_math::ring::{cf_inv, Rq as RqEl};
use neo_math::{D, F};
use neo_memory::ajtai::{commit_cols_for_ccs_m, encode_vector_for_ccs_m};
use neo_params::NeoParams;
use neo_reductions::{api::FoldingMode, error::PiCcsError};
use neo_transcript::{Poseidon2Transcript, Transcript, TranscriptProtocol};
use p3_field::PrimeCharacteristicRing;
use serde::{Deserialize, Serialize};
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

use super::{
    build_parity_case_from_source,
    perf_diagnostics::{
        PackagedSimpleKernelVerifyPerf, Rv64imProofProvePerf, SimpleKernelBuildPerf, SimpleKernelVerifyPerf,
    },
    simple_openings::{SimpleKernelOpeningBundle, SimpleKernelStagePackageBundle},
    stage_artifacts::{
        build_kernel_opening_bundle_with_perf, build_stage_claim_bundle_from_parts,
        build_stage_claim_bundle_from_parts_with_perf, verify_kernel_opening_bundle_with_perf,
        SimpleKernelStageClaimBundle,
    },
    stage_package_perf::{build_stage_package_bundle_with_perf, verify_stage_package_bundle_with_perf},
    Rv64imKernelSummary, Rv64imParityCaseManifest, Rv64imParityDerivedCase, Rv64imParitySourceCase, TranscriptRecord,
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
    pub prepared_step_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct PreparedStepBindingSummary {
    pub bindings: Vec<PreparedStepBinding>,
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
pub struct ExactCommitmentArtifact {
    pub label: String,
    pub logical_width: usize,
    pub packed_cols: usize,
    pub commitment: Commitment,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ExactOpeningArtifact {
    pub label: String,
    pub logical_values: Vec<F>,
    pub packed_witness: Mat<F>,
    pub digest: [u8; 32],
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
    pub prepared_steps: Vec<StepInput>,
    pub public_steps: Vec<PublicStep>,
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
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelPackagedProof {
    pub kernel: SimpleKernelProof,
    pub main_lane: PackagedProof,
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
    ccs: neo_ccs::CcsStructure<F>,
}

struct SimpleKernelExpectedCore {
    trace: SimpleKernelTraceWitness,
    stages: SimpleKernelStageWitnessBundle,
    stage_claims: SimpleKernelStageClaimBundle,
    kernel_claims: SimpleKernelKernelClaimBundle,
    prepared_steps: Vec<StepInput>,
    public_steps: Vec<PublicStep>,
}

impl PreparedStepBinding {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/prepared_step_binding");
        tr.append_u64s(b"rv64im/prepared_step_binding/trace_index", &[self.trace_index as u64]);
        tr.append_message(b"rv64im/prepared_step_binding/row_digest", &self.row_digest);
        tr.append_message(
            b"rv64im/prepared_step_binding/prepared_step_digest",
            &self.prepared_step_digest,
        );
        tr.digest32()
    }
}

impl PreparedStepBindingSummary {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/prepared_step_binding_summary");
        tr.append_u64s(
            b"rv64im/prepared_step_binding_summary/len",
            &[self.bindings.len() as u64],
        );
        for binding in &self.bindings {
            tr.append_message(b"rv64im/prepared_step_binding_summary/binding_digest", &binding.digest);
        }
        tr.digest32()
    }
}

impl ExactCommitmentArtifact {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/exact_commitment_artifact");
        tr.append_message(b"rv64im/exact_commitment_artifact/label", self.label.as_bytes());
        tr.append_u64s(
            b"rv64im/exact_commitment_artifact/meta",
            &[self.logical_width as u64, self.packed_cols as u64],
        );
        tr.absorb_commit_coords(&self.commitment.data);
        tr.digest32()
    }
}

impl ExactOpeningArtifact {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/exact_opening_artifact");
        tr.append_message(b"rv64im/exact_opening_artifact/label", self.label.as_bytes());
        append_f_vec(
            &mut tr,
            b"rv64im/exact_opening_artifact/logical_values",
            &self.logical_values,
        );
        append_matrix(
            &mut tr,
            b"rv64im/exact_opening_artifact/packed_witness",
            self.packed_witness.as_slice(),
            self.packed_witness.rows(),
            self.packed_witness.cols(),
        );
        tr.digest32()
    }
}
impl SimpleKernelRootContext {
    fn new() -> Result<Self, SimpleKernelError> {
        let params = rv64im_simple_root_params();
        let m = commit_cols_for_ccs_m(RV64IM_ROOT_ROW_WIDTH);
        set_global_pp_seeded(D, params.kappa as usize, m, SIMPLE_KERNEL_PP_SEED)
            .map_err(|err| SimpleKernelError::Bridge(format!("canonical RV64IM root seed setup failed: {err}")))?;
        let log = AjtaiSModule::from_global_for_dims(D, m)
            .map_err(|err| SimpleKernelError::Bridge(format!("canonical RV64IM root module failed: {err}")))?;
        let ccs = rv64im_root_main_lane_ccs()
            .map_err(|err| SimpleKernelError::Bridge(format!("RV64IM root CCS build failed: {err}")))?;
        Ok(Self { params, log, ccs })
    }

    fn params(&self) -> &NeoParams {
        &self.params
    }

    fn log(&self) -> &AjtaiSModule {
        &self.log
    }

    fn ccs(&self) -> &neo_ccs::CcsStructure<F> {
        &self.ccs
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

fn root_encode_execution_row(
    root_context: &SimpleKernelRootContext,
    row: &Rv64ExpandedRow,
) -> Result<(Vec<F>, Mat<F>), SimpleKernelError> {
    let semantic_row = semantic_row_from_execution_row(row);
    let witness = semantic_row[1..].to_vec();
    let packed = encode_vector_for_ccs_m(root_context.params(), RV64IM_ROOT_ROW_WIDTH, &semantic_row)
        .map_err(|err| SimpleKernelError::Bridge(format!("root encoding failed for row {}: {err}", row.trace_index)))?;
    Ok((witness, packed))
}

fn build_prepared_step_from_execution_row(
    root_context: &SimpleKernelRootContext,
    row: &Rv64ExpandedRow,
) -> Result<StepInput, SimpleKernelError> {
    let (witness, z_mat) = root_encode_execution_row(root_context, row)?;
    Ok(StepInput {
        label: format!("rv64im/simple/trace_{}", row.trace_index),
        mcs: neo_ccs::CcsClaim {
            c: root_context.log().commit(&z_mat),
            x: vec![F::ONE],
            m_in: 1,
        },
        witness: neo_ccs::CcsWitness { w: witness, Z: z_mat },
    })
}

fn append_f_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[F]) {
    tr.append_u64s(b"rv64im/prepared_step/f_len", &[values.len() as u64]);
    tr.append_fields(label, values);
}

fn append_matrix(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[F], rows: usize, cols: usize) {
    tr.append_u64s(b"rv64im/prepared_step/matrix_meta", &[rows as u64, cols as u64]);
    tr.append_fields(label, values);
}

fn append_public_step(tr: &mut Poseidon2Transcript, step: &PublicStep) {
    tr.append_message(b"rv64im/prepared_step/label", step.label.as_bytes());
    tr.append_u64s(
        b"rv64im/prepared_step/public_meta",
        &[step.mcs.m_in as u64, step.mcs.x.len() as u64],
    );
    tr.append_u64s(
        b"rv64im/prepared_step/public_commitment_meta",
        &[step.mcs.c.d as u64, step.mcs.c.kappa as u64],
    );
    tr.absorb_commit_coords(&step.mcs.c.data);
    tr.append_fields(b"rv64im/prepared_step/public_x", &step.mcs.x);
}

fn same_public_step(lhs: &PublicStep, rhs: &PublicStep) -> bool {
    lhs.label == rhs.label
        && lhs.mcs.m_in == rhs.mcs.m_in
        && lhs.mcs.x == rhs.mcs.x
        && lhs.mcs.c.d == rhs.mcs.c.d
        && lhs.mcs.c.kappa == rhs.mcs.c.kappa
        && lhs.mcs.c.data == rhs.mcs.c.data
}

pub fn prepared_step_digest(step: &StepInput) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/prepared_step");
    append_public_step(&mut tr, &step.instance());
    append_f_vec(&mut tr, b"rv64im/prepared_step/witness_w", &step.witness.w);
    append_matrix(
        &mut tr,
        b"rv64im/prepared_step/witness_Z",
        step.witness.Z.as_slice(),
        step.witness.Z.rows(),
        step.witness.Z.cols(),
    );
    tr.digest32()
}

fn execution_row_digest(row: &Rv64ExpandedRow) -> [u8; 32] {
    let semantic_row = semantic_row_from_execution_row(row);
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/root_row");
    tr.append_u64s(b"rv64im/root_row/meta", &[row.trace_index as u64]);
    tr.append_fields(b"rv64im/root_row/semantic", &semantic_row);
    tr.digest32()
}

fn build_prepared_step_binding_summary(
    rows: &[Rv64ExpandedRow],
    prepared_steps: &[StepInput],
) -> Result<PreparedStepBindingSummary, SimpleKernelError> {
    if rows.len() != prepared_steps.len() {
        return Err(SimpleKernelError::Bridge(format!(
            "prepared step row count {} != prepared step count {}",
            rows.len(),
            prepared_steps.len()
        )));
    }

    let bindings = rows
        .iter()
        .zip(prepared_steps.iter())
        .map(|(row, step)| {
            let binding = PreparedStepBinding {
                trace_index: row.trace_index,
                row_digest: execution_row_digest(row),
                prepared_step_digest: prepared_step_digest(step),
                digest: [0; 32],
            };
            Ok(PreparedStepBinding {
                digest: binding.expected_digest(),
                ..binding
            })
        })
        .collect::<Result<Vec<_>, SimpleKernelError>>()?;
    let summary = PreparedStepBindingSummary {
        bindings,
        digest: [0; 32],
    };
    Ok(PreparedStepBindingSummary {
        digest: summary.expected_digest(),
        ..summary
    })
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

fn build_simple_kernel_expected_core(
    public: &SimpleKernelPublicInput,
) -> Result<SimpleKernelExpectedCore, SimpleKernelError> {
    let (_, derived) = build_parity_case_from_source(public.source.clone(), public.max_steps)?;
    let root_context = SimpleKernelRootContext::new()?;
    let prepared_steps = derived
        .execution_rows
        .iter()
        .map(|row| build_prepared_step_from_execution_row(&root_context, row))
        .collect::<Result<Vec<_>, _>>()?;
    let public_steps = prepared_steps
        .iter()
        .map(StepInput::instance)
        .collect::<Vec<_>>();
    let prepared_step_bindings = build_prepared_step_binding_summary(&derived.execution_rows, &prepared_steps)?;
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
    Ok(SimpleKernelExpectedCore {
        trace,
        stages,
        stage_claims,
        kernel_claims,
        prepared_steps,
        public_steps,
    })
}

pub fn build_simple_kernel_witness(public: &SimpleKernelPublicInput) -> Result<SimpleKernelOutput, SimpleKernelError> {
    Ok(build_simple_kernel_witness_with_perf(public)?.0)
}

pub fn build_simple_kernel_witness_with_perf(
    public: &SimpleKernelPublicInput,
) -> Result<(SimpleKernelOutput, SimpleKernelBuildPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let (_, derived) = build_parity_case_from_source(public.source.clone(), public.max_steps)?;
    let root_context = SimpleKernelRootContext::new()?;

    let prepared_steps_started = Instant::now();
    let prepared_steps = derived
        .execution_rows
        .iter()
        .map(|row| build_prepared_step_from_execution_row(&root_context, row))
        .collect::<Result<Vec<_>, _>>()?;
    let prepared_steps_ms = millis_since(prepared_steps_started);

    let public_steps_started = Instant::now();
    let public_steps = prepared_steps
        .iter()
        .map(StepInput::instance)
        .collect::<Vec<_>>();
    let public_steps_ms = millis_since(public_steps_started);

    let bindings_started = Instant::now();
    let prepared_step_bindings = build_prepared_step_binding_summary(&derived.execution_rows, &prepared_steps)?;
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
    let core = SimpleKernelExpectedCore {
        trace,
        stages,
        stage_claims,
        kernel_claims,
        prepared_steps,
        public_steps,
    };

    let (stage_packages, stage_package_bundle) = build_stage_package_bundle_with_perf(
        &core.stages.stage1,
        &core.stages.stage2,
        &core.stages.stage3,
        &core.stage_claims,
    )?;
    let (kernel_opening, kernel_opening_bundle) = build_kernel_opening_bundle_with_perf(
        &core.stage_claims,
        &stage_packages,
        &core.kernel_claims,
        &core.prepared_steps,
    )?;
    Ok((
        SimpleKernelOutput {
            trace: core.trace,
            stages: core.stages,
            stage_claims: core.stage_claims,
            stage_packages,
            kernel_opening,
            kernel_claims: core.kernel_claims,
            prepared_steps: core.prepared_steps,
            public_steps: core.public_steps,
        },
        SimpleKernelBuildPerf {
            prepared_steps_ms,
            public_steps_ms,
            prepared_step_bindings_ms,
            stage_claim_bundle,
            stage_package_bundle,
            kernel_opening_bundle,
            total_ms: millis_since(total_started),
        },
    ))
}

pub fn prove_simple_kernel(
    input: &SimpleKernelProverInput,
) -> Result<(SimpleKernelOutput, SimpleKernelProof), SimpleKernelError> {
    let output = build_simple_kernel_witness(&input.public)?;
    let proof = SimpleKernelProof {
        root_params_id: rv64im_simple_root_context_id(),
        trace: output.trace.clone(),
        stages: output.stages.clone(),
        stage_claims: output.stage_claims.clone(),
        stage_packages: output.stage_packages.clone(),
        kernel_opening: output.kernel_opening.clone(),
        kernel_claims: output.kernel_claims.clone(),
    };
    Ok((output, proof))
}

pub fn verify_simple_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    Ok(verify_simple_kernel_with_perf(input, proof)?.0)
}

pub fn verify_simple_kernel_with_perf(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<(SimpleKernelOutput, SimpleKernelVerifyPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let expected_root = rv64im_simple_root_context_id();
    if proof.root_params_id != expected_root {
        return Err(SimpleKernelError::Bridge("RV64IM root context id mismatch".into()));
    }
    let expected_started = Instant::now();
    let expected = build_simple_kernel_expected_core(&input.public)?;
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
        &expected.prepared_steps,
    )?;
    Ok((
        SimpleKernelOutput {
            trace: expected.trace,
            stages: expected.stages,
            stage_claims: expected.stage_claims,
            stage_packages: proof.stage_packages.clone(),
            kernel_opening: proof.kernel_opening.clone(),
            kernel_claims: expected.kernel_claims,
            prepared_steps: expected.prepared_steps,
            public_steps: expected.public_steps,
        },
        SimpleKernelVerifyPerf {
            expected_core_ms,
            trace_match_ms,
            stages_match_ms,
            stage_claims_match_ms,
            kernel_claims_match_ms,
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
    let (output, simple_kernel) = build_simple_kernel_witness_with_perf(&input.public)?;
    let kernel = SimpleKernelProof {
        root_params_id: rv64im_simple_root_context_id(),
        trace: output.trace.clone(),
        stages: output.stages.clone(),
        stage_claims: output.stage_claims.clone(),
        stage_packages: output.stage_packages.clone(),
        kernel_opening: output.kernel_opening.clone(),
        kernel_claims: output.kernel_claims.clone(),
    };
    let root_context = SimpleKernelRootContext::new()?;
    let main_lane_started = Instant::now();
    let main_lane = prove_and_package(
        FoldingMode::Optimized,
        root_context.params(),
        root_context.ccs(),
        output.prepared_steps.clone(),
        root_context.log(),
        rv64im_ajtai_mixers(),
    )?;
    Ok((
        (output, SimpleKernelPackagedProof { kernel, main_lane }),
        Rv64imProofProvePerf {
            simple_kernel,
            packaged_main_lane_ms: millis_since(main_lane_started),
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
    let (output, simple_kernel) = verify_simple_kernel_with_perf(input, &packaged.kernel)?;
    let public_step_match_started = Instant::now();
    if packaged.main_lane.statement.steps.len() != output.public_steps.len()
        || packaged
            .main_lane
            .statement
            .steps
            .iter()
            .zip(output.public_steps.iter())
            .any(|(lhs, rhs)| !same_public_step(lhs, rhs))
    {
        return Err(SimpleKernelError::Proof(
            "RV64IM packaged public steps do not match kernel export".into(),
        ));
    }
    let public_step_match_ms = millis_since(public_step_match_started);
    let root_context = SimpleKernelRootContext::new()?;
    let main_lane_verify_started = Instant::now();
    verify_packaged(
        FoldingMode::Optimized,
        root_context.params(),
        root_context.ccs(),
        &packaged.main_lane,
        rv64im_ajtai_mixers(),
    )?;
    Ok((
        output,
        PackagedSimpleKernelVerifyPerf {
            simple_kernel,
            public_step_match_ms,
            main_lane_verify_ms: millis_since(main_lane_verify_started),
            total_ms: millis_since(total_started),
        },
    ))
}
