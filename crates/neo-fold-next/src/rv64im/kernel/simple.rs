//! Owns the RV64IM simple-kernel proof/output boundary and the live root main-lane prove/verify path.

use neo_ajtai::{
    get_global_pp_for_dims, get_global_pp_seeded_params_for_dims, has_global_pp_for_dims, s_lincomb, s_mul,
    set_global_pp_seeded, AjtaiSModule, Commitment,
};
use neo_ccs::{traits::SModuleHomomorphism, Mat};
use neo_math::ring::{cf_inv, Rq as RqEl};
use neo_math::{D, F};
use neo_memory::ajtai::{commit_cols_for_ccs_m, encode_vector_for_ccs_m};
use neo_params::NeoParams;
use neo_reductions::{api::FoldingMode, error::PiCcsError};
use neo_transcript::{Poseidon2Transcript, Transcript, TranscriptProtocol};
use p3_field::PrimeCharacteristicRing;
use serde::{Deserialize, Serialize};

use crate::proof::{PackagedProof, PublicStep, StepInput};
use crate::prover::CommitmentMixers;
use crate::run::{prove_and_package, verify_packaged};
use crate::rv64im::ccs::{rv64im_root_main_lane_ccs, semantic_row_from_execution_row, RV64IM_ROOT_ROW_WIDTH};
use crate::rv64im::isa::Rv64BuildError;
use crate::rv64im::lower::Rv64ExpandedRow;
use crate::rv64im::stage1::Stage1Summary;
use crate::rv64im::stage2::Stage2Summary;
use crate::rv64im::stage3::Stage3Summary;
use crate::vm::r1cs_builder::R1csBuilder;

use super::{
    artifacts::{flatten_stage1, flatten_stage2, flatten_stage3},
    build_parity_case_from_source, Rv64imKernelSummary, Rv64imParityCaseManifest, Rv64imParityDerivedCase,
    Rv64imParitySourceCase, TranscriptRecord,
};

const SIMPLE_KERNEL_PP_SEED: [u8; 32] = [
    0x40, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
];
// The RV64IM root row carries 32-bit limbs directly, so the root packaged proof needs
// a wider Ajtai bound than the CHIP-8 kernel to keep RLC/DEC within range.
const SIMPLE_KERNEL_K_RHO: u32 = 48;
const SIMPLE_KERNEL_B: u64 = 1 << 48;
// Ajtai public parameters are global per dimension bucket, so the exact stage surfaces
// must share one canonical seed and rely on local labels/digests for domain separation.
const EXACT_STAGE_PP_SEED: [u8; 32] = SIMPLE_KERNEL_PP_SEED;

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
pub struct StageDigestCommitment {
    pub digest: [u8; 32],
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
pub struct ExactOpeningClaim {
    pub label: String,
    pub logical_width: usize,
    pub packed_rows: usize,
    pub packed_cols: usize,
    pub commitment_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ExactOpeningManifest {
    pub claims: Vec<ExactOpeningClaim>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct ExactOpeningProof {
    pub claim_digest: [u8; 32],
    pub opening: ExactOpeningArtifact,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1ClaimSurface {
    pub row_count: usize,
    pub effect_row_count: usize,
    pub commit_row_count: usize,
    pub real_row_count: usize,
    pub preserves_x0_count: usize,
    pub mix: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2ClaimSurface {
    pub register_read_count: usize,
    pub register_write_count: usize,
    pub ram_event_count: usize,
    pub twist_link_count: usize,
    pub ram_read_count: usize,
    pub ram_write_count: usize,
    pub reg_mix: u64,
    pub ram_mix: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage3ClaimSurface {
    pub continuity_count: usize,
    pub final_step_count: usize,
    pub halted: bool,
    pub all_continuity_hold: bool,
    pub continuity_mix: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptClaimSurface {
    pub final_digest: [u8; 32],
    pub event_count: usize,
    pub kernel_final_mix: u64,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1ArtifactSurface {
    pub commitment: ExactCommitmentArtifact,
    pub opening_manifest: ExactOpeningManifest,
    pub opening_proof: ExactOpeningProof,
    pub claim: Stage1ClaimSurface,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage2ArtifactSurface {
    pub commitment: ExactCommitmentArtifact,
    pub opening_manifest: ExactOpeningManifest,
    pub opening_proof: ExactOpeningProof,
    pub claim: Stage2ClaimSurface,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage3ArtifactSurface {
    pub commitment: ExactCommitmentArtifact,
    pub opening_manifest: ExactOpeningManifest,
    pub opening_proof: ExactOpeningProof,
    pub claim: Stage3ClaimSurface,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct TranscriptArtifactSurface {
    pub commitment: StageDigestCommitment,
    pub claim: TranscriptClaimSurface,
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelStageClaimBundle {
    pub stage1: Stage1ArtifactSurface,
    pub stage2: Stage2ArtifactSurface,
    pub stage3: Stage3ArtifactSurface,
    pub transcript: TranscriptArtifactSurface,
    pub execution_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelKernelClaimBundle {
    pub kernel: Rv64imKernelSummary,
    pub prepared_step_bindings: PreparedStepBindingSummary,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct StagePackagedOpeningProof {
    pub exact_opening_proof_digest: [u8; 32],
    pub packaged: PackagedProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelStagePackageBundle {
    pub stage1: StagePackagedOpeningProof,
    pub stage2: StagePackagedOpeningProof,
    pub stage3: StagePackagedOpeningProof,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelOutput {
    pub trace: SimpleKernelTraceWitness,
    pub stages: SimpleKernelStageWitnessBundle,
    pub stage_claims: SimpleKernelStageClaimBundle,
    pub stage_packages: SimpleKernelStagePackageBundle,
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

struct ExactVectorCommitmentContext {
    params: NeoParams,
    log: AjtaiSModule,
}

struct ExactVectorPackageContext {
    params: NeoParams,
    log: AjtaiSModule,
    ccs: neo_ccs::CcsStructure<F>,
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

impl StageDigestCommitment {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_digest_commitment");
        tr.append_message(b"rv64im/stage_digest_commitment/digest", &self.digest);
        tr.digest32()
    }
}

impl ExactCommitmentArtifact {
    fn expected_digest(&self) -> [u8; 32] {
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
    fn expected_digest(&self) -> [u8; 32] {
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

impl Stage1ClaimSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage1_claim_surface");
        tr.append_u64s(
            b"rv64im/stage1_claim_surface/counts",
            &[
                self.row_count as u64,
                self.effect_row_count as u64,
                self.commit_row_count as u64,
                self.real_row_count as u64,
                self.preserves_x0_count as u64,
                self.mix,
            ],
        );
        tr.digest32()
    }
}

impl ExactOpeningClaim {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/exact_opening_claim");
        tr.append_message(b"rv64im/exact_opening_claim/label", self.label.as_bytes());
        tr.append_u64s(
            b"rv64im/exact_opening_claim/meta",
            &[
                self.logical_width as u64,
                self.packed_rows as u64,
                self.packed_cols as u64,
            ],
        );
        tr.append_message(b"rv64im/exact_opening_claim/commitment_digest", &self.commitment_digest);
        tr.digest32()
    }
}

impl ExactOpeningManifest {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/exact_opening_manifest");
        tr.append_u64s(b"rv64im/exact_opening_manifest/len", &[self.claims.len() as u64]);
        for claim in &self.claims {
            tr.append_message(b"rv64im/exact_opening_manifest/claim_digest", &claim.digest);
        }
        tr.digest32()
    }
}

impl ExactOpeningProof {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/exact_opening_proof");
        tr.append_message(b"rv64im/exact_opening_proof/claim_digest", &self.claim_digest);
        tr.append_message(
            b"rv64im/exact_opening_proof/opening_digest",
            &self.opening.expected_digest(),
        );
        tr.digest32()
    }
}

impl Stage2ClaimSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_claim_surface");
        tr.append_u64s(
            b"rv64im/stage2_claim_surface/counts",
            &[
                self.register_read_count as u64,
                self.register_write_count as u64,
                self.ram_event_count as u64,
                self.twist_link_count as u64,
                self.ram_read_count as u64,
                self.ram_write_count as u64,
                self.reg_mix,
                self.ram_mix,
            ],
        );
        tr.digest32()
    }
}

impl Stage3ClaimSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage3_claim_surface");
        tr.append_u64s(
            b"rv64im/stage3_claim_surface/counts",
            &[
                self.continuity_count as u64,
                self.final_step_count as u64,
                self.continuity_mix,
            ],
        );
        tr.append_u64s(
            b"rv64im/stage3_claim_surface/flags",
            &[self.halted as u64, self.all_continuity_hold as u64],
        );
        tr.digest32()
    }
}

impl TranscriptClaimSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/transcript_claim_surface");
        tr.append_message(b"rv64im/transcript_claim_surface/final_digest", &self.final_digest);
        tr.append_u64s(
            b"rv64im/transcript_claim_surface/meta",
            &[self.event_count as u64, self.kernel_final_mix],
        );
        tr.digest32()
    }
}

impl Stage1ArtifactSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage1_artifact_surface");
        tr.append_message(
            b"rv64im/stage1_artifact_surface/commitment",
            &self.commitment.expected_digest(),
        );
        tr.append_message(
            b"rv64im/stage1_artifact_surface/opening_manifest",
            &self.opening_manifest.expected_digest(),
        );
        tr.append_message(
            b"rv64im/stage1_artifact_surface/opening_proof",
            &self.opening_proof.expected_digest(),
        );
        tr.append_message(b"rv64im/stage1_artifact_surface/claim", &self.claim.expected_digest());
        tr.digest32()
    }
}

impl Stage2ArtifactSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage2_artifact_surface");
        tr.append_message(
            b"rv64im/stage2_artifact_surface/commitment",
            &self.commitment.expected_digest(),
        );
        tr.append_message(
            b"rv64im/stage2_artifact_surface/opening_manifest",
            &self.opening_manifest.expected_digest(),
        );
        tr.append_message(
            b"rv64im/stage2_artifact_surface/opening_proof",
            &self.opening_proof.expected_digest(),
        );
        tr.append_message(b"rv64im/stage2_artifact_surface/claim", &self.claim.expected_digest());
        tr.digest32()
    }
}

impl Stage3ArtifactSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage3_artifact_surface");
        tr.append_message(
            b"rv64im/stage3_artifact_surface/commitment",
            &self.commitment.expected_digest(),
        );
        tr.append_message(
            b"rv64im/stage3_artifact_surface/opening_manifest",
            &self.opening_manifest.expected_digest(),
        );
        tr.append_message(
            b"rv64im/stage3_artifact_surface/opening_proof",
            &self.opening_proof.expected_digest(),
        );
        tr.append_message(b"rv64im/stage3_artifact_surface/claim", &self.claim.expected_digest());
        tr.digest32()
    }
}

impl TranscriptArtifactSurface {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/transcript_artifact_surface");
        tr.append_message(
            b"rv64im/transcript_artifact_surface/commitment",
            &self.commitment.expected_digest(),
        );
        tr.append_message(
            b"rv64im/transcript_artifact_surface/claim",
            &self.claim.expected_digest(),
        );
        tr.digest32()
    }
}

impl SimpleKernelStageClaimBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_claim_bundle");
        tr.append_message(b"rv64im/stage_claim_bundle/stage1", &self.stage1.expected_digest());
        tr.append_message(b"rv64im/stage_claim_bundle/stage2", &self.stage2.expected_digest());
        tr.append_message(b"rv64im/stage_claim_bundle/stage3", &self.stage3.expected_digest());
        tr.append_message(
            b"rv64im/stage_claim_bundle/transcript",
            &self.transcript.expected_digest(),
        );
        tr.append_message(b"rv64im/stage_claim_bundle/execution_digest", &self.execution_digest);
        tr.digest32()
    }
}

impl StagePackagedOpeningProof {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_packaged_opening_proof");
        tr.append_message(
            b"rv64im/stage_packaged_opening_proof/exact_opening_proof_digest",
            &self.exact_opening_proof_digest,
        );
        tr.append_message(
            b"rv64im/stage_packaged_opening_proof/statement_digest",
            &self.packaged.statement.digest,
        );
        tr.append_message(
            b"rv64im/stage_packaged_opening_proof/proof_digest",
            &self.packaged.proof.proof_digest,
        );
        tr.digest32()
    }
}

impl SimpleKernelStagePackageBundle {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_package_bundle");
        tr.append_message(b"rv64im/stage_package_bundle/stage1", &self.stage1.digest);
        tr.append_message(b"rv64im/stage_package_bundle/stage2", &self.stage2.digest);
        tr.append_message(b"rv64im/stage_package_bundle/stage3", &self.stage3.digest);
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

impl ExactVectorCommitmentContext {
    fn new(logical_width: usize, seed: [u8; 32], label: &str) -> Result<Self, SimpleKernelError> {
        let mut params = NeoParams::goldilocks_auto_r1cs_ccs(logical_width)
            .map_err(|err| SimpleKernelError::Bridge(format!("{label} params failed: {err}")))?;
        params.k_rho = SIMPLE_KERNEL_K_RHO;
        params.B = SIMPLE_KERNEL_B;
        let m = commit_cols_for_ccs_m(logical_width);
        let want_kappa = params.kappa as usize;
        if has_global_pp_for_dims(D, m) {
            if let Ok((kappa, registered_seed)) = get_global_pp_seeded_params_for_dims(D, m) {
                if kappa != want_kappa || registered_seed != seed {
                    return Err(SimpleKernelError::Bridge(format!(
                        "{label} exact commitment PP mismatch for (d,m)=({D},{m})"
                    )));
                }
            } else {
                let pp = get_global_pp_for_dims(D, m).map_err(|err| {
                    SimpleKernelError::Bridge(format!(
                        "{label} exact commitment PP lookup failed for (d,m)=({D},{m}): {err}"
                    ))
                })?;
                if pp.kappa != want_kappa {
                    return Err(SimpleKernelError::Bridge(format!(
                        "{label} exact commitment PP kappa mismatch for (d,m)=({D},{m})"
                    )));
                }
            }
        } else {
            set_global_pp_seeded(D, want_kappa, m, seed).map_err(|err| {
                SimpleKernelError::Bridge(format!("{label} exact commitment seed setup failed: {err}"))
            })?;
        }
        let log = AjtaiSModule::from_global_for_dims(D, m)
            .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact commitment module failed: {err}")))?;
        Ok(Self { params, log })
    }

    fn params(&self) -> &NeoParams {
        &self.params
    }

    fn log(&self) -> &AjtaiSModule {
        &self.log
    }
}

impl ExactVectorPackageContext {
    fn new(logical_width: usize, seed: [u8; 32], label: &str) -> Result<Self, SimpleKernelError> {
        let full_width = logical_width
            .checked_add(1)
            .ok_or_else(|| SimpleKernelError::Bridge(format!("{label} exact package width overflow")))?;
        let mut params = NeoParams::goldilocks_auto_r1cs_ccs(full_width)
            .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact package params failed: {err}")))?;
        params.k_rho = SIMPLE_KERNEL_K_RHO;
        params.B = SIMPLE_KERNEL_B;
        let m = commit_cols_for_ccs_m(full_width);
        let want_kappa = params.kappa as usize;
        if has_global_pp_for_dims(D, m) {
            if let Ok((kappa, registered_seed)) = get_global_pp_seeded_params_for_dims(D, m) {
                if kappa != want_kappa || registered_seed != seed {
                    return Err(SimpleKernelError::Bridge(format!(
                        "{label} exact package PP mismatch for (d,m)=({D},{m})"
                    )));
                }
            } else {
                let pp = get_global_pp_for_dims(D, m).map_err(|err| {
                    SimpleKernelError::Bridge(format!(
                        "{label} exact package PP lookup failed for (d,m)=({D},{m}): {err}"
                    ))
                })?;
                if pp.kappa != want_kappa {
                    return Err(SimpleKernelError::Bridge(format!(
                        "{label} exact package PP kappa mismatch for (d,m)=({D},{m})"
                    )));
                }
            }
        } else {
            set_global_pp_seeded(D, want_kappa, m, seed)
                .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact package seed setup failed: {err}")))?;
        }
        let log = AjtaiSModule::from_global_for_dims(D, m)
            .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact package module failed: {err}")))?;
        let mut builder = R1csBuilder::new(full_width, 0)
            .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact package CCS builder failed: {err}")))?;
        builder.push_row([(0, F::ONE)], [(0, F::ONE)], [(0, F::ONE)]);
        let ccs = builder
            .build()
            .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact package CCS build failed: {err}")))?;
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

fn split_u64_to_fields(value: u64, out: &mut Vec<F>) {
    out.push(F::from_u64(value as u32 as u64));
    out.push(F::from_u64((value >> 32) as u32 as u64));
}

fn u64_vector_to_field_limbs(values: &[u64]) -> Vec<F> {
    let mut out = Vec::with_capacity(values.len() * 2);
    for &value in values {
        split_u64_to_fields(value, &mut out);
    }
    out
}

fn build_exact_stage_vector_artifacts(
    label: &str,
    values: &[u64],
    seed: [u8; 32],
) -> Result<(ExactCommitmentArtifact, ExactOpeningArtifact), SimpleKernelError> {
    let logical_values = u64_vector_to_field_limbs(values);
    let context = ExactVectorCommitmentContext::new(logical_values.len(), seed, label)?;
    let packed_witness = encode_vector_for_ccs_m(context.params(), logical_values.len(), &logical_values)
        .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact opening encoding failed: {err}")))?;
    let opening = ExactOpeningArtifact {
        label: label.into(),
        logical_values,
        packed_witness,
        digest: [0; 32],
    };
    let opening = ExactOpeningArtifact {
        digest: opening.expected_digest(),
        ..opening
    };
    let commitment = ExactCommitmentArtifact {
        label: label.into(),
        logical_width: opening.logical_values.len(),
        packed_cols: opening.packed_witness.cols(),
        commitment: context.log().commit(&opening.packed_witness),
        digest: [0; 32],
    };
    let commitment = ExactCommitmentArtifact {
        digest: commitment.expected_digest(),
        ..commitment
    };
    Ok((commitment, opening))
}

fn build_exact_opening_manifest(
    label: &str,
    commitment: &ExactCommitmentArtifact,
    opening: &ExactOpeningArtifact,
) -> ExactOpeningManifest {
    let claim = ExactOpeningClaim {
        label: label.into(),
        logical_width: opening.logical_values.len(),
        packed_rows: opening.packed_witness.rows(),
        packed_cols: opening.packed_witness.cols(),
        commitment_digest: commitment.digest,
        digest: [0; 32],
    };
    let claim = ExactOpeningClaim {
        digest: claim.expected_digest(),
        ..claim
    };
    let manifest = ExactOpeningManifest {
        claims: vec![claim],
        digest: [0; 32],
    };
    ExactOpeningManifest {
        digest: manifest.expected_digest(),
        ..manifest
    }
}

fn build_exact_opening_proof(
    manifest: &ExactOpeningManifest,
    opening: ExactOpeningArtifact,
) -> Result<ExactOpeningProof, SimpleKernelError> {
    let claim = manifest
        .claims
        .first()
        .ok_or_else(|| SimpleKernelError::Bridge("exact opening manifest must contain one claim".into()))?;
    let proof = ExactOpeningProof {
        claim_digest: claim.digest,
        opening,
        digest: [0; 32],
    };
    Ok(ExactOpeningProof {
        digest: proof.expected_digest(),
        ..proof
    })
}

fn build_exact_opening_package_step(
    label: &str,
    opening: &ExactOpeningArtifact,
) -> Result<StepInput, SimpleKernelError> {
    let context = ExactVectorPackageContext::new(opening.logical_values.len(), EXACT_STAGE_PP_SEED, label)?;
    let mut full_vector = Vec::with_capacity(opening.logical_values.len() + 1);
    full_vector.push(F::ONE);
    full_vector.extend_from_slice(&opening.logical_values);
    let packed = encode_vector_for_ccs_m(context.params(), full_vector.len(), &full_vector)
        .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact package encoding failed: {err}")))?;
    Ok(StepInput {
        label: label.into(),
        mcs: neo_ccs::CcsClaim {
            c: context.log().commit(&packed),
            x: vec![F::ONE],
            m_in: 1,
        },
        witness: neo_ccs::CcsWitness {
            w: opening.logical_values.clone(),
            Z: packed,
        },
    })
}

fn build_stage_packaged_opening_proof(
    label: &str,
    opening_proof: &ExactOpeningProof,
) -> Result<StagePackagedOpeningProof, SimpleKernelError> {
    let step = build_exact_opening_package_step(label, &opening_proof.opening)?;
    let context =
        ExactVectorPackageContext::new(opening_proof.opening.logical_values.len(), EXACT_STAGE_PP_SEED, label)?;
    let packaged = prove_and_package(
        FoldingMode::Optimized,
        context.params(),
        context.ccs(),
        [step],
        context.log(),
        rv64im_ajtai_mixers(),
    )?;
    let proof = StagePackagedOpeningProof {
        exact_opening_proof_digest: opening_proof.digest,
        packaged,
        digest: [0; 32],
    };
    Ok(StagePackagedOpeningProof {
        digest: proof.expected_digest(),
        ..proof
    })
}

fn verify_stage_packaged_opening_proof(
    label: &str,
    stage_package: &StagePackagedOpeningProof,
    opening_proof: &ExactOpeningProof,
) -> Result<(), SimpleKernelError> {
    if stage_package.digest != stage_package.expected_digest() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} stage packaged opening digest mismatch"
        )));
    }
    if stage_package.exact_opening_proof_digest != opening_proof.digest {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} stage packaged opening binding mismatch"
        )));
    }
    let expected_step = build_exact_opening_package_step(label, &opening_proof.opening)?;
    if stage_package.packaged.statement.steps.len() != 1
        || !same_public_step(&stage_package.packaged.statement.steps[0], &expected_step.instance())
    {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} stage packaged opening public step mismatch"
        )));
    }
    let context =
        ExactVectorPackageContext::new(opening_proof.opening.logical_values.len(), EXACT_STAGE_PP_SEED, label)?;
    verify_packaged(
        FoldingMode::Optimized,
        context.params(),
        context.ccs(),
        &stage_package.packaged,
        rv64im_ajtai_mixers(),
    )?;
    Ok(())
}

fn verify_exact_stage_vector_artifact(
    label: &str,
    commitment: &ExactCommitmentArtifact,
    opening_manifest: &ExactOpeningManifest,
    opening_proof: &ExactOpeningProof,
    seed: [u8; 32],
) -> Result<(), SimpleKernelError> {
    if commitment.digest != commitment.expected_digest() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact commitment digest mismatch"
        )));
    }
    if opening_manifest.digest != opening_manifest.expected_digest() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening manifest digest mismatch"
        )));
    }
    if opening_proof.digest != opening_proof.expected_digest() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening proof digest mismatch"
        )));
    }
    if opening_manifest.claims.len() != 1 {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening manifest claim count {} != 1",
            opening_manifest.claims.len()
        )));
    }
    let claim = &opening_manifest.claims[0];
    if claim.digest != claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening claim digest mismatch"
        )));
    }
    if opening_proof.claim_digest != claim.digest {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening proof claim binding mismatch"
        )));
    }
    let opening = &opening_proof.opening;
    if opening.digest != opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening digest mismatch"
        )));
    }
    if commitment.label != label || opening.label != label || claim.label != label {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact artifact label mismatch"
        )));
    }
    if commitment.logical_width != opening.logical_values.len() || claim.logical_width != opening.logical_values.len() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact logical width mismatch"
        )));
    }
    if claim.commitment_digest != commitment.digest {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening claim commitment binding mismatch"
        )));
    }

    let context = ExactVectorCommitmentContext::new(opening.logical_values.len(), seed, label)?;
    let expected_witness =
        encode_vector_for_ccs_m(context.params(), opening.logical_values.len(), &opening.logical_values)
            .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact opening encoding failed: {err}")))?;
    if expected_witness.rows() != opening.packed_witness.rows()
        || expected_witness.cols() != opening.packed_witness.cols()
        || expected_witness.as_slice() != opening.packed_witness.as_slice()
    {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening witness mismatch"
        )));
    }
    if commitment.packed_cols != expected_witness.cols() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} packed column count {} != expected {}",
            commitment.packed_cols,
            expected_witness.cols()
        )));
    }
    if claim.packed_rows != expected_witness.rows() || claim.packed_cols != expected_witness.cols() {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact opening claim witness shape mismatch"
        )));
    }
    if context.log().commit(&expected_witness) != commitment.commitment {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} exact commitment/opening mismatch"
        )));
    }
    Ok(())
}

fn verify_stage_claim_surfaces(stage_claims: &SimpleKernelStageClaimBundle) -> Result<(), SimpleKernelError> {
    verify_exact_stage_vector_artifact(
        "rv64im/stage1",
        &stage_claims.stage1.commitment,
        &stage_claims.stage1.opening_manifest,
        &stage_claims.stage1.opening_proof,
        EXACT_STAGE_PP_SEED,
    )?;
    verify_exact_stage_vector_artifact(
        "rv64im/stage2",
        &stage_claims.stage2.commitment,
        &stage_claims.stage2.opening_manifest,
        &stage_claims.stage2.opening_proof,
        EXACT_STAGE_PP_SEED,
    )?;
    verify_exact_stage_vector_artifact(
        "rv64im/stage3",
        &stage_claims.stage3.commitment,
        &stage_claims.stage3.opening_manifest,
        &stage_claims.stage3.opening_proof,
        EXACT_STAGE_PP_SEED,
    )?;
    if stage_claims.stage1.claim.expected_digest() == [0; 32]
        || stage_claims.stage2.claim.expected_digest() == [0; 32]
        || stage_claims.stage3.claim.expected_digest() == [0; 32]
        || stage_claims.transcript.claim.expected_digest() == [0; 32]
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage claim surface digest unexpectedly zero".into(),
        ));
    }
    if stage_claims.digest != stage_claims.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage claim bundle digest mismatch".into(),
        ));
    }
    Ok(())
}

fn build_stage_package_bundle(
    stage_claims: &SimpleKernelStageClaimBundle,
) -> Result<SimpleKernelStagePackageBundle, SimpleKernelError> {
    let stage1 =
        build_stage_packaged_opening_proof("rv64im/stage1/opening_package", &stage_claims.stage1.opening_proof)?;
    let stage2 =
        build_stage_packaged_opening_proof("rv64im/stage2/opening_package", &stage_claims.stage2.opening_proof)?;
    let stage3 =
        build_stage_packaged_opening_proof("rv64im/stage3/opening_package", &stage_claims.stage3.opening_proof)?;
    let bundle = SimpleKernelStagePackageBundle {
        stage1,
        stage2,
        stage3,
        digest: [0; 32],
    };
    Ok(SimpleKernelStagePackageBundle {
        digest: bundle.expected_digest(),
        ..bundle
    })
}

fn verify_stage_package_bundle(
    stage_packages: &SimpleKernelStagePackageBundle,
    stage_claims: &SimpleKernelStageClaimBundle,
) -> Result<(), SimpleKernelError> {
    verify_stage_packaged_opening_proof(
        "rv64im/stage1/opening_package",
        &stage_packages.stage1,
        &stage_claims.stage1.opening_proof,
    )?;
    verify_stage_packaged_opening_proof(
        "rv64im/stage2/opening_package",
        &stage_packages.stage2,
        &stage_claims.stage2.opening_proof,
    )?;
    verify_stage_packaged_opening_proof(
        "rv64im/stage3/opening_package",
        &stage_packages.stage3,
        &stage_claims.stage3.opening_proof,
    )?;
    if stage_packages.digest != stage_packages.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage package bundle digest mismatch".into(),
        ));
    }
    Ok(())
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

fn stage_claim_bundle_from_parts(
    stages: &SimpleKernelStageWitnessBundle,
    kernel: &Rv64imKernelSummary,
) -> Result<SimpleKernelStageClaimBundle, SimpleKernelError> {
    let stage1_flat = flatten_stage1(&stages.stage1);
    let (stage1_commitment, stage1_opening) =
        build_exact_stage_vector_artifacts("rv64im/stage1", &stage1_flat, EXACT_STAGE_PP_SEED)?;
    let stage1_opening_manifest = build_exact_opening_manifest("rv64im/stage1", &stage1_commitment, &stage1_opening);
    let stage1_opening_proof = build_exact_opening_proof(&stage1_opening_manifest, stage1_opening)?;
    let stage1 = Stage1ArtifactSurface {
        commitment: stage1_commitment,
        opening_manifest: stage1_opening_manifest,
        opening_proof: stage1_opening_proof,
        claim: Stage1ClaimSurface {
            row_count: stages.stage1.rows.len(),
            effect_row_count: stages
                .stage1
                .rows
                .iter()
                .filter(|row| row.is_effect_row)
                .count(),
            commit_row_count: stages
                .stage1
                .rows
                .iter()
                .filter(|row| row.is_commit_row)
                .count(),
            real_row_count: stages.stage1.rows.iter().filter(|row| row.is_real).count(),
            preserves_x0_count: stages
                .stage1
                .rows
                .iter()
                .filter(|row| row.preserves_x0)
                .count(),
            mix: kernel.stage1_mix,
        },
    };
    let stage2_flat = flatten_stage2(&stages.stage2);
    let (stage2_commitment, stage2_opening) =
        build_exact_stage_vector_artifacts("rv64im/stage2", &stage2_flat, EXACT_STAGE_PP_SEED)?;
    let stage2_opening_manifest = build_exact_opening_manifest("rv64im/stage2", &stage2_commitment, &stage2_opening);
    let stage2_opening_proof = build_exact_opening_proof(&stage2_opening_manifest, stage2_opening)?;
    let stage2 = Stage2ArtifactSurface {
        commitment: stage2_commitment,
        opening_manifest: stage2_opening_manifest,
        opening_proof: stage2_opening_proof,
        claim: Stage2ClaimSurface {
            register_read_count: stages.stage2.register_reads.len(),
            register_write_count: stages.stage2.register_writes.len(),
            ram_event_count: stages.stage2.ram_events.len(),
            twist_link_count: stages.stage2.twist_links.len(),
            ram_read_count: stages
                .stage2
                .ram_events
                .iter()
                .filter(|event| matches!(event.kind, crate::rv64im::stage2::RamAccessKind::Read))
                .count(),
            ram_write_count: stages
                .stage2
                .ram_events
                .iter()
                .filter(|event| matches!(event.kind, crate::rv64im::stage2::RamAccessKind::Write))
                .count(),
            reg_mix: kernel.stage2_reg_mix,
            ram_mix: kernel.stage2_ram_mix,
        },
    };
    let stage3_flat = flatten_stage3(&stages.stage3);
    let (stage3_commitment, stage3_opening) =
        build_exact_stage_vector_artifacts("rv64im/stage3", &stage3_flat, EXACT_STAGE_PP_SEED)?;
    let stage3_opening_manifest = build_exact_opening_manifest("rv64im/stage3", &stage3_commitment, &stage3_opening);
    let stage3_opening_proof = build_exact_opening_proof(&stage3_opening_manifest, stage3_opening)?;
    let stage3 = Stage3ArtifactSurface {
        commitment: stage3_commitment,
        opening_manifest: stage3_opening_manifest,
        opening_proof: stage3_opening_proof,
        claim: Stage3ClaimSurface {
            continuity_count: stages.stage3.continuity.len(),
            final_step_count: stages
                .stage3
                .continuity
                .iter()
                .filter(|event| event.final_step)
                .count(),
            halted: stages.stage3.halted,
            all_continuity_hold: stages
                .stage3
                .continuity
                .iter()
                .all(|event| event.continuity_holds),
            continuity_mix: kernel.stage3_continuity_mix,
        },
    };
    let transcript = TranscriptArtifactSurface {
        commitment: StageDigestCommitment {
            digest: kernel.transcript_final_digest,
        },
        claim: TranscriptClaimSurface {
            final_digest: kernel.transcript_final_digest,
            event_count: stages.transcript.events.len(),
            kernel_final_mix: kernel.kernel_final_mix,
        },
    };
    let claims = SimpleKernelStageClaimBundle {
        stage1,
        stage2,
        stage3,
        transcript,
        execution_digest: kernel.execution_digest,
        digest: [0; 32],
    };
    Ok(SimpleKernelStageClaimBundle {
        digest: claims.expected_digest(),
        ..claims
    })
}

pub fn build_simple_kernel_witness(public: &SimpleKernelPublicInput) -> Result<SimpleKernelOutput, SimpleKernelError> {
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
    let stage_claims = stage_claim_bundle_from_parts(&stages, &derived.kernel)?;
    let stage_packages = build_stage_package_bundle(&stage_claims)?;
    let kernel_claims = kernel_claim_bundle_from_parts(&derived, prepared_step_bindings);
    Ok(SimpleKernelOutput {
        trace,
        stages,
        stage_claims,
        stage_packages,
        kernel_claims,
        prepared_steps,
        public_steps,
    })
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
        kernel_claims: output.kernel_claims.clone(),
    };
    Ok((output, proof))
}

pub fn verify_simple_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    let expected_root = rv64im_simple_root_context_id();
    if proof.root_params_id != expected_root {
        return Err(SimpleKernelError::Bridge("RV64IM root context id mismatch".into()));
    }
    verify_stage_claim_surfaces(&proof.stage_claims)?;
    verify_stage_package_bundle(&proof.stage_packages, &proof.stage_claims)?;

    let output = build_simple_kernel_witness(&input.public)?;
    if proof.trace != output.trace {
        return Err(SimpleKernelError::Bridge("RV64IM kernel trace witness mismatch".into()));
    }
    if proof.stages != output.stages {
        return Err(SimpleKernelError::Bridge("RV64IM stage witness bundle mismatch".into()));
    }
    if proof.stage_claims != output.stage_claims {
        return Err(SimpleKernelError::Bridge("RV64IM stage claim bundle mismatch".into()));
    }
    if proof.stage_packages.digest != output.stage_packages.digest {
        return Err(SimpleKernelError::Bridge("RV64IM stage package bundle mismatch".into()));
    }
    if proof.kernel_claims != output.kernel_claims {
        return Err(SimpleKernelError::Bridge("RV64IM kernel claim bundle mismatch".into()));
    }
    Ok(output)
}

fn rot_matrix_to_rq(mat: &Mat<F>) -> RqEl {
    let mut coeffs = [F::ZERO; D];
    for i in 0..D {
        coeffs[i] = mat[(i, 0)];
    }
    cf_inv(coeffs)
}

fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Commitment]) -> Commitment {
    let rq_els: Vec<RqEl> = rhos.iter().map(rot_matrix_to_rq).collect();
    s_lincomb(&rq_els, cs).expect("Ajtai S-linear combination should succeed")
}

fn combine_b_pows(cs: &[Commitment], b: u32) -> Commitment {
    let mut acc = cs[0].clone();
    let mut pow = F::from_u64(b as u64);
    for c in cs.iter().skip(1) {
        let rq_pow = RqEl::from_field_scalar(pow);
        let term = s_mul(&rq_pow, c);
        acc.add_inplace(&term);
        pow *= F::from_u64(b as u64);
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
    let (output, kernel) = prove_simple_kernel(input)?;
    let root_context = SimpleKernelRootContext::new()?;
    let main_lane = prove_and_package(
        FoldingMode::Optimized,
        root_context.params(),
        root_context.ccs(),
        output.prepared_steps.clone(),
        root_context.log(),
        rv64im_ajtai_mixers(),
    )?;
    Ok((output, SimpleKernelPackagedProof { kernel, main_lane }))
}

pub fn verify_packaged_simple_kernel(
    input: &SimpleKernelVerifierInput,
    packaged: &SimpleKernelPackagedProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    let output = verify_simple_kernel(input, &packaged.kernel)?;
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
    let root_context = SimpleKernelRootContext::new()?;
    verify_packaged(
        FoldingMode::Optimized,
        root_context.params(),
        root_context.ccs(),
        &packaged.main_lane,
        rv64im_ajtai_mixers(),
    )?;
    Ok(output)
}
