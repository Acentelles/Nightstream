//! Owns RV64IM exact stage artifacts and compact selected-claim stage packages.

use neo_ajtai::{
    get_global_pp_for_dims, get_global_pp_seeded_params_for_dims, has_global_pp_for_dims, set_global_pp_seeded,
    AjtaiSModule,
};
use neo_ccs::traits::SModuleHomomorphism;
use neo_math::{D, F};
use neo_memory::ajtai::{commit_cols_for_ccs_m, encode_vector_for_ccs_m};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;
use serde::{Deserialize, Serialize};
use std::time::Instant;

use crate::proof::{PackagedProof, PublicStep, StepInput};
use crate::run::{prove_and_package, verify_packaged};
use crate::rv64im::stage1::{Stage1RowBinding, Stage1Summary};
use crate::rv64im::stage2::{
    RamAccessKind, RamEvent, RegisterReadEvent, RegisterWriteEvent, Stage2Summary, TwistLinkEvent,
};
use crate::rv64im::stage3::{ContinuityEvent, Stage3Summary};
use crate::vm::r1cs_builder::R1csBuilder;

use super::{
    artifacts::{flatten_stage1, flatten_stage2, flatten_stage3, Rv64imKernelSummary},
    perf_diagnostics::{
        ExactStageVectorBuildPerf, KernelOpeningBundleBuildPerf, KernelOpeningBundleVerifyPerf,
        PackagedOpeningBuildPerf, StageClaimBundleBuildPerf,
    },
    simple::{
        prepared_step_digest, rv64im_ajtai_mixers, ExactCommitmentArtifact, ExactOpeningArtifact, SimpleKernelError,
        SimpleKernelKernelClaimBundle, EXACT_STAGE_PP_SEED, SIMPLE_KERNEL_B, SIMPLE_KERNEL_K_RHO,
    },
    simple_openings::{
        DigestPoint, KernelBindingOpeningClaim, KernelBindingOpeningPoints, KernelBindingPackagedOpeningProof,
        KernelPreparedStepOpeningClaim, KernelPreparedStepOpeningPoints, KernelPreparedStepPackagedOpeningProof,
        SimpleKernelOpeningBundle, SimpleKernelOpeningClaim, SimpleKernelStagePackageBundle, Stage1OpeningPoints,
        Stage1PackagedOpeningProof, Stage1SelectedOpeningClaim, Stage2OpeningPoints, Stage2PackagedOpeningProof,
        Stage2SelectedOpeningClaim, Stage3OpeningPoints, Stage3PackagedOpeningProof, Stage3SelectedOpeningClaim,
    },
    transcript::TranscriptRecord,
};

fn millis_since(started: Instant) -> f64 {
    started.elapsed().as_secs_f64() * 1_000.0
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
pub struct StageDigestCommitment {
    pub digest: [u8; 32],
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

struct ExactVectorCommitmentContext {
    params: NeoParams,
    log: AjtaiSModule,
}

struct ExactVectorPackageContext {
    params: NeoParams,
    log: AjtaiSModule,
    ccs: neo_ccs::CcsStructure<F>,
}

fn digest_words(app_label: &'static [u8], section_label: &'static [u8], words: &[u64]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(app_label);
    tr.append_u64s(section_label, words);
    tr.digest32()
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

fn same_public_step(lhs: &PublicStep, rhs: &PublicStep) -> bool {
    lhs.label == rhs.label
        && lhs.mcs.m_in == rhs.mcs.m_in
        && lhs.mcs.x == rhs.mcs.x
        && lhs.mcs.c.d == rhs.mcs.c.d
        && lhs.mcs.c.kappa == rhs.mcs.c.kappa
        && lhs.mcs.c.data == rhs.mcs.c.data
}

impl StageDigestCommitment {
    fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_digest_commitment");
        tr.append_message(b"rv64im/stage_digest_commitment/digest", &self.digest);
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

fn build_exact_stage_vector_artifacts_with_perf(
    label: &str,
    values: &[u64],
    seed: [u8; 32],
) -> Result<
    (
        (ExactCommitmentArtifact, ExactOpeningArtifact),
        ExactStageVectorBuildPerf,
    ),
    SimpleKernelError,
> {
    let mut perf = ExactStageVectorBuildPerf {
        flatten_u64_words: values.len(),
        ..ExactStageVectorBuildPerf::default()
    };

    let limb_started = Instant::now();
    let logical_values = u64_vector_to_field_limbs(values);
    perf.limb_encode_ms = millis_since(limb_started);

    let context_started = Instant::now();
    let context = ExactVectorCommitmentContext::new(logical_values.len(), seed, label)?;
    perf.context_setup_ms = millis_since(context_started);

    let ccs_started = Instant::now();
    let packed_witness = encode_vector_for_ccs_m(context.params(), logical_values.len(), &logical_values)
        .map_err(|err| SimpleKernelError::Bridge(format!("{label} exact opening encoding failed: {err}")))?;
    perf.ccs_encode_ms = millis_since(ccs_started);

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

    let commit_started = Instant::now();
    let commitment = ExactCommitmentArtifact {
        label: label.into(),
        logical_width: opening.logical_values.len(),
        packed_cols: opening.packed_witness.cols(),
        commitment: context.log().commit(&opening.packed_witness),
        digest: [0; 32],
    };
    perf.ajtai_commit_ms = millis_since(commit_started);
    perf.field_limb_width = opening.logical_values.len();
    perf.packed_rows = opening.packed_witness.rows();
    perf.packed_cols = opening.packed_witness.cols();

    let commitment = ExactCommitmentArtifact {
        digest: commitment.expected_digest(),
        ..commitment
    };
    Ok(((commitment, opening), perf))
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

fn build_exact_stage_surface_with_perf(
    label: &str,
    values: &[u64],
    seed: [u8; 32],
) -> Result<
    (
        ExactCommitmentArtifact,
        ExactOpeningManifest,
        ExactOpeningProof,
        ExactStageVectorBuildPerf,
    ),
    SimpleKernelError,
> {
    let ((commitment, opening), mut perf) = build_exact_stage_vector_artifacts_with_perf(label, values, seed)?;
    let manifest_started = Instant::now();
    let manifest = build_exact_opening_manifest(label, &commitment, &opening);
    perf.opening_manifest_ms = millis_since(manifest_started);
    let proof_started = Instant::now();
    let proof = build_exact_opening_proof(&manifest, opening)?;
    perf.opening_prove_ms = millis_since(proof_started);
    Ok((commitment, manifest, proof, perf))
}

fn build_exact_vector_package_step(label: &str, logical_values: &[F]) -> Result<StepInput, SimpleKernelError> {
    let context = ExactVectorPackageContext::new(logical_values.len(), EXACT_STAGE_PP_SEED, label)?;
    let mut full_vector = Vec::with_capacity(logical_values.len() + 1);
    full_vector.push(F::ONE);
    full_vector.extend_from_slice(logical_values);
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
            w: logical_values.to_vec(),
            Z: packed,
        },
    })
}

fn stage1_row_digest(row: &Stage1RowBinding) -> [u8; 32] {
    digest_words(
        b"neo.fold.next/rv64im/stage1_selected_row",
        b"stage1/row",
        &flatten_stage1(&Stage1Summary {
            rows: vec![row.clone()],
        }),
    )
}

fn register_read_event_digest(event: &RegisterReadEvent) -> [u8; 32] {
    digest_words(
        b"neo.fold.next/rv64im/stage2_selected_register_read",
        b"stage2/read",
        &flatten_stage2(&Stage2Summary {
            register_reads: vec![event.clone()],
            register_writes: Vec::new(),
            ram_events: Vec::new(),
            twist_links: Vec::new(),
        }),
    )
}

fn register_write_event_digest(event: &RegisterWriteEvent) -> [u8; 32] {
    digest_words(
        b"neo.fold.next/rv64im/stage2_selected_register_write",
        b"stage2/write",
        &flatten_stage2(&Stage2Summary {
            register_reads: Vec::new(),
            register_writes: vec![event.clone()],
            ram_events: Vec::new(),
            twist_links: Vec::new(),
        }),
    )
}

fn ram_event_digest(event: &RamEvent) -> [u8; 32] {
    digest_words(
        b"neo.fold.next/rv64im/stage2_selected_ram_event",
        b"stage2/ram",
        &flatten_stage2(&Stage2Summary {
            register_reads: Vec::new(),
            register_writes: Vec::new(),
            ram_events: vec![event.clone()],
            twist_links: Vec::new(),
        }),
    )
}

fn twist_link_event_digest(event: &TwistLinkEvent) -> [u8; 32] {
    digest_words(
        b"neo.fold.next/rv64im/stage2_selected_twist_link",
        b"stage2/twist",
        &flatten_stage2(&Stage2Summary {
            register_reads: Vec::new(),
            register_writes: Vec::new(),
            ram_events: Vec::new(),
            twist_links: vec![event.clone()],
        }),
    )
}

fn continuity_event_digest(event: &ContinuityEvent) -> [u8; 32] {
    digest_words(
        b"neo.fold.next/rv64im/stage3_selected_continuity",
        b"stage3/continuity",
        &flatten_stage3(&Stage3Summary {
            continuity: vec![event.clone()],
            halted: event.final_step,
        }),
    )
}

fn first_last_digests<T>(items: &[T], digest_fn: impl Fn(&T) -> [u8; 32]) -> ([u8; 32], [u8; 32]) {
    let Some(first) = items.first() else {
        return ([0; 32], [0; 32]);
    };
    let last = items.last().unwrap_or(first);
    (digest_fn(first), digest_fn(last))
}

pub(super) fn build_stage1_selected_opening_claim(
    stage1: &Stage1Summary,
    surface: &Stage1ArtifactSurface,
) -> Result<Stage1SelectedOpeningClaim, SimpleKernelError> {
    let first = stage1
        .rows
        .first()
        .ok_or_else(|| SimpleKernelError::Bridge("rv64im/stage1 selected claim missing first row".into()))?;
    let effect = stage1
        .rows
        .iter()
        .find(|row| row.is_effect_row)
        .ok_or_else(|| SimpleKernelError::Bridge("rv64im/stage1 selected claim missing effect row".into()))?;
    let commit = stage1
        .rows
        .iter()
        .find(|row| row.is_commit_row)
        .ok_or_else(|| SimpleKernelError::Bridge("rv64im/stage1 selected claim missing commit row".into()))?;
    let last = stage1
        .rows
        .last()
        .ok_or_else(|| SimpleKernelError::Bridge("rv64im/stage1 selected claim missing last row".into()))?;
    let meta_words = vec![
        surface.claim.row_count as u64,
        surface.claim.effect_row_count as u64,
        surface.claim.commit_row_count as u64,
        surface.claim.real_row_count as u64,
        surface.claim.preserves_x0_count as u64,
        first.trace_index as u64,
        effect.trace_index as u64,
        commit.trace_index as u64,
        last.trace_index as u64,
        surface.claim.mix,
    ];
    let claim = Stage1SelectedOpeningClaim {
        source_commitment_digest: surface.commitment.digest,
        source_opening_manifest_digest: surface.opening_manifest.digest,
        source_opening_proof_digest: surface.opening_proof.digest,
        row_count: meta_words[0],
        effect_row_count: meta_words[1],
        commit_row_count: meta_words[2],
        real_row_count: meta_words[3],
        preserves_x0_count: meta_words[4],
        first_trace_index: meta_words[5],
        effect_trace_index: meta_words[6],
        commit_trace_index: meta_words[7],
        last_trace_index: meta_words[8],
        mix: meta_words[9],
        points: Stage1OpeningPoints {
            first: DigestPoint {
                digest: stage1_row_digest(first),
            },
            effect: DigestPoint {
                digest: stage1_row_digest(effect),
            },
            commit: DigestPoint {
                digest: stage1_row_digest(commit),
            },
            last: DigestPoint {
                digest: stage1_row_digest(last),
            },
        },
        digest: [0; 32],
    };
    Ok(Stage1SelectedOpeningClaim {
        digest: claim.expected_digest(),
        ..claim
    })
}

pub(super) fn build_stage2_selected_opening_claim(
    stage2: &Stage2Summary,
    surface: &Stage2ArtifactSurface,
) -> Stage2SelectedOpeningClaim {
    let (first_read, last_read) = first_last_digests(&stage2.register_reads, register_read_event_digest);
    let (first_write, last_write) = first_last_digests(&stage2.register_writes, register_write_event_digest);
    let (first_ram, last_ram) = first_last_digests(&stage2.ram_events, ram_event_digest);
    let (first_twist, last_twist) = first_last_digests(&stage2.twist_links, twist_link_event_digest);
    let claim = Stage2SelectedOpeningClaim {
        source_commitment_digest: surface.commitment.digest,
        source_opening_manifest_digest: surface.opening_manifest.digest,
        source_opening_proof_digest: surface.opening_proof.digest,
        register_read_count: surface.claim.register_read_count as u64,
        register_write_count: surface.claim.register_write_count as u64,
        ram_event_count: surface.claim.ram_event_count as u64,
        twist_link_count: surface.claim.twist_link_count as u64,
        ram_read_count: surface.claim.ram_read_count as u64,
        ram_write_count: surface.claim.ram_write_count as u64,
        reg_mix: surface.claim.reg_mix,
        ram_mix: surface.claim.ram_mix,
        points: Stage2OpeningPoints {
            first_read: DigestPoint { digest: first_read },
            last_read: DigestPoint { digest: last_read },
            first_write: DigestPoint { digest: first_write },
            last_write: DigestPoint { digest: last_write },
            first_ram: DigestPoint { digest: first_ram },
            last_ram: DigestPoint { digest: last_ram },
            first_twist: DigestPoint { digest: first_twist },
            last_twist: DigestPoint { digest: last_twist },
        },
        digest: [0; 32],
    };
    Stage2SelectedOpeningClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

pub(super) fn build_stage3_selected_opening_claim(
    stage3: &Stage3Summary,
    surface: &Stage3ArtifactSurface,
) -> Stage3SelectedOpeningClaim {
    let (first_continuity, last_continuity) = first_last_digests(&stage3.continuity, continuity_event_digest);
    let claim = Stage3SelectedOpeningClaim {
        source_commitment_digest: surface.commitment.digest,
        source_opening_manifest_digest: surface.opening_manifest.digest,
        source_opening_proof_digest: surface.opening_proof.digest,
        continuity_count: surface.claim.continuity_count as u64,
        final_step_count: surface.claim.final_step_count as u64,
        halted: surface.claim.halted,
        all_continuity_hold: surface.claim.all_continuity_hold,
        continuity_mix: surface.claim.continuity_mix,
        points: Stage3OpeningPoints {
            first_continuity: DigestPoint {
                digest: first_continuity,
            },
            last_continuity: DigestPoint {
                digest: last_continuity,
            },
        },
        digest: [0; 32],
    };
    Stage3SelectedOpeningClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn build_claim_package_step(label: &str, words: &[u64]) -> Result<StepInput, SimpleKernelError> {
    let logical_values = u64_vector_to_field_limbs(&words);
    build_exact_vector_package_step(&format!("{label}/selected_claim_package"), &logical_values)
}

fn build_kernel_binding_opening_package_step(
    claim: &KernelBindingOpeningClaim,
) -> Result<StepInput, SimpleKernelError> {
    let words = claim.claim_words();
    let logical_values = u64_vector_to_field_limbs(&words);
    build_exact_vector_package_step("rv64im/kernel_opening_bundle/bindings", &logical_values)
}

fn build_kernel_prepared_step_opening_package_step(
    claim: &KernelPreparedStepOpeningClaim,
) -> Result<StepInput, SimpleKernelError> {
    let words = claim.claim_words();
    let logical_values = u64_vector_to_field_limbs(&words);
    build_exact_vector_package_step("rv64im/kernel_opening_bundle/prepared_steps", &logical_values)
}

pub(super) fn build_claim_packaged_proof(label: &str, words: &[u64]) -> Result<PackagedProof, SimpleKernelError> {
    let step = build_claim_package_step(label, words)?;
    let context = ExactVectorPackageContext::new(
        step.witness.w.len(),
        EXACT_STAGE_PP_SEED,
        &format!("{label}/selected_claim_package"),
    )?;
    Ok(prove_and_package(
        FoldingMode::Optimized,
        context.params(),
        context.ccs(),
        [step],
        context.log(),
        rv64im_ajtai_mixers(),
    )?)
}

fn verify_claim_packaged_proof(label: &str, words: &[u64], packaged: &PackagedProof) -> Result<(), SimpleKernelError> {
    let expected_step = build_claim_package_step(label, words)?;
    if packaged.statement.steps.len() != 1 || !same_public_step(&packaged.statement.steps[0], &expected_step.instance())
    {
        return Err(SimpleKernelError::Bridge(format!(
            "{label} selected-claim package public step mismatch"
        )));
    }
    let context = ExactVectorPackageContext::new(
        expected_step.witness.w.len(),
        EXACT_STAGE_PP_SEED,
        &format!("{label}/selected_claim_package"),
    )?;
    verify_packaged(
        FoldingMode::Optimized,
        context.params(),
        context.ccs(),
        packaged,
        rv64im_ajtai_mixers(),
    )?;
    Ok(())
}

pub(super) fn verify_stage1_packaged_opening_proof(
    stage_package: &Stage1PackagedOpeningProof,
    expected_claim: &Stage1SelectedOpeningClaim,
) -> Result<(), SimpleKernelError> {
    if stage_package.digest != stage_package.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "rv64im/stage1 selected-claim package digest mismatch".into(),
        ));
    }
    if &stage_package.claim != expected_claim {
        return Err(SimpleKernelError::Bridge(
            "rv64im/stage1 selected-claim package claim mismatch".into(),
        ));
    }
    verify_claim_packaged_proof("rv64im/stage1", &expected_claim.claim_words(), &stage_package.packaged)
}

pub(super) fn verify_stage2_packaged_opening_proof(
    stage_package: &Stage2PackagedOpeningProof,
    expected_claim: &Stage2SelectedOpeningClaim,
) -> Result<(), SimpleKernelError> {
    if stage_package.digest != stage_package.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "rv64im/stage2 selected-claim package digest mismatch".into(),
        ));
    }
    if &stage_package.claim != expected_claim {
        return Err(SimpleKernelError::Bridge(
            "rv64im/stage2 selected-claim package claim mismatch".into(),
        ));
    }
    verify_claim_packaged_proof("rv64im/stage2", &expected_claim.claim_words(), &stage_package.packaged)
}

pub(super) fn verify_stage3_packaged_opening_proof(
    stage_package: &Stage3PackagedOpeningProof,
    expected_claim: &Stage3SelectedOpeningClaim,
) -> Result<(), SimpleKernelError> {
    if stage_package.digest != stage_package.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "rv64im/stage3 selected-claim package digest mismatch".into(),
        ));
    }
    if &stage_package.claim != expected_claim {
        return Err(SimpleKernelError::Bridge(
            "rv64im/stage3 selected-claim package claim mismatch".into(),
        ));
    }
    verify_claim_packaged_proof("rv64im/stage3", &expected_claim.claim_words(), &stage_package.packaged)
}

fn build_kernel_opening_claim(
    stage_claims: &SimpleKernelStageClaimBundle,
    stage_packages: &SimpleKernelStagePackageBundle,
    kernel_claims: &SimpleKernelKernelClaimBundle,
    prepared_steps: &[StepInput],
) -> SimpleKernelOpeningClaim {
    let first_prepared = prepared_steps
        .first()
        .map(prepared_step_digest)
        .unwrap_or([0; 32]);
    let last_prepared = prepared_steps
        .last()
        .map(prepared_step_digest)
        .unwrap_or([0; 32]);
    let first_binding = kernel_claims
        .prepared_step_bindings
        .bindings
        .first()
        .map(|binding| binding.digest)
        .unwrap_or([0; 32]);
    let last_binding = kernel_claims
        .prepared_step_bindings
        .bindings
        .last()
        .map(|binding| binding.digest)
        .unwrap_or([0; 32]);
    let binding_claim = KernelBindingOpeningClaim {
        stage_claim_bundle_digest: stage_claims.digest,
        stage_package_bundle_digest: stage_packages.digest,
        stage1_package_digest: stage_packages.stage1.digest,
        stage2_package_digest: stage_packages.stage2.digest,
        stage3_package_digest: stage_packages.stage3.digest,
        prepared_step_bindings_digest: kernel_claims.prepared_step_bindings.digest,
        binding_count: kernel_claims.prepared_step_bindings.bindings.len() as u64,
        stage1_row_count: stage_claims.stage1.claim.row_count as u64,
        stage2_register_read_count: stage_claims.stage2.claim.register_read_count as u64,
        stage2_register_write_count: stage_claims.stage2.claim.register_write_count as u64,
        stage2_ram_event_count: stage_claims.stage2.claim.ram_event_count as u64,
        stage3_continuity_count: stage_claims.stage3.claim.continuity_count as u64,
        points: KernelBindingOpeningPoints {
            first_binding: DigestPoint { digest: first_binding },
            last_binding: DigestPoint { digest: last_binding },
        },
        digest: [0; 32],
    };
    let prepared_step_claim = KernelPreparedStepOpeningClaim {
        execution_digest: kernel_claims.kernel.execution_digest,
        final_state_digest: kernel_claims.kernel.final_state_digest,
        transcript_final_digest: kernel_claims.kernel.transcript_final_digest,
        prepared_step_count: prepared_steps.len() as u64,
        final_pc: kernel_claims.kernel.final_pc,
        halted: kernel_claims.kernel.halted,
        points: KernelPreparedStepOpeningPoints {
            first_prepared_step: DigestPoint { digest: first_prepared },
            last_prepared_step: DigestPoint { digest: last_prepared },
        },
        digest: [0; 32],
    };
    let claim = SimpleKernelOpeningClaim {
        bindings: KernelBindingOpeningClaim {
            digest: binding_claim.expected_digest(),
            ..binding_claim
        },
        prepared_steps: KernelPreparedStepOpeningClaim {
            digest: prepared_step_claim.expected_digest(),
            ..prepared_step_claim
        },
        digest: [0; 32],
    };
    SimpleKernelOpeningClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn build_kernel_opening_proof_with_perf(
    claim: SimpleKernelOpeningClaim,
) -> Result<(SimpleKernelOpeningBundle, KernelOpeningBundleBuildPerf), SimpleKernelError> {
    let total_started = Instant::now();
    let bindings_step = build_kernel_binding_opening_package_step(&claim.bindings)?;
    let bindings_claim_words = bindings_step.witness.w.len();
    let bindings_context = ExactVectorPackageContext::new(
        bindings_step.witness.w.len(),
        EXACT_STAGE_PP_SEED,
        "rv64im/kernel_opening_bundle/bindings",
    )?;
    let bindings_started = Instant::now();
    let bindings_packaged = prove_and_package(
        FoldingMode::Optimized,
        bindings_context.params(),
        bindings_context.ccs(),
        [bindings_step],
        bindings_context.log(),
        rv64im_ajtai_mixers(),
    )?;
    let bindings = KernelBindingPackagedOpeningProof {
        claim: claim.bindings.clone(),
        packaged: bindings_packaged,
        digest: [0; 32],
    };
    let bindings = KernelBindingPackagedOpeningProof {
        digest: bindings.expected_digest(),
        ..bindings
    };

    let prepared_steps_step = build_kernel_prepared_step_opening_package_step(&claim.prepared_steps)?;
    let prepared_steps_claim_words = prepared_steps_step.witness.w.len();
    let prepared_steps_context = ExactVectorPackageContext::new(
        prepared_steps_step.witness.w.len(),
        EXACT_STAGE_PP_SEED,
        "rv64im/kernel_opening_bundle/prepared_steps",
    )?;
    let prepared_steps_started = Instant::now();
    let prepared_steps_packaged = prove_and_package(
        FoldingMode::Optimized,
        prepared_steps_context.params(),
        prepared_steps_context.ccs(),
        [prepared_steps_step],
        prepared_steps_context.log(),
        rv64im_ajtai_mixers(),
    )?;
    let prepared_steps = KernelPreparedStepPackagedOpeningProof {
        claim: claim.prepared_steps.clone(),
        packaged: prepared_steps_packaged,
        digest: [0; 32],
    };
    let prepared_steps = KernelPreparedStepPackagedOpeningProof {
        digest: prepared_steps.expected_digest(),
        ..prepared_steps
    };

    let bundle = SimpleKernelOpeningBundle {
        claim,
        bindings,
        prepared_steps,
        digest: [0; 32],
    };
    let bundle = SimpleKernelOpeningBundle {
        digest: bundle.expected_digest(),
        ..bundle
    };
    Ok((
        bundle,
        KernelOpeningBundleBuildPerf {
            bindings: PackagedOpeningBuildPerf {
                selected_labels: 2,
                claim_words: bindings_claim_words,
                package_ms: millis_since(bindings_started),
            },
            prepared_steps: PackagedOpeningBuildPerf {
                selected_labels: 2,
                claim_words: prepared_steps_claim_words,
                package_ms: millis_since(prepared_steps_started),
            },
            total_ms: millis_since(total_started),
        },
    ))
}

fn verify_kernel_opening_proof_with_perf(
    bundle: &SimpleKernelOpeningBundle,
) -> Result<KernelOpeningBundleVerifyPerf, SimpleKernelError> {
    let total_started = Instant::now();
    if bundle.claim.digest != bundle.claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel opening claim digest mismatch".into(),
        ));
    }
    if bundle.digest != bundle.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel opening bundle digest mismatch".into(),
        ));
    }
    if bundle.bindings.digest != bundle.bindings.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel binding opening package digest mismatch".into(),
        ));
    }
    if bundle.bindings.claim != bundle.claim.bindings {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel binding opening claim mismatch".into(),
        ));
    }
    let expected_bindings_step = build_kernel_binding_opening_package_step(&bundle.claim.bindings)?;
    if bundle.bindings.packaged.statement.steps.len() != 1
        || !same_public_step(
            &bundle.bindings.packaged.statement.steps[0],
            &expected_bindings_step.instance(),
        )
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel binding opening package public step mismatch".into(),
        ));
    }
    let bindings_context = ExactVectorPackageContext::new(
        expected_bindings_step.witness.w.len(),
        EXACT_STAGE_PP_SEED,
        "rv64im/kernel_opening_bundle/bindings",
    )?;
    let bindings_started = Instant::now();
    verify_packaged(
        FoldingMode::Optimized,
        bindings_context.params(),
        bindings_context.ccs(),
        &bundle.bindings.packaged,
        rv64im_ajtai_mixers(),
    )?;

    if bundle.prepared_steps.digest != bundle.prepared_steps.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel prepared-step opening package digest mismatch".into(),
        ));
    }
    if bundle.prepared_steps.claim != bundle.claim.prepared_steps {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel prepared-step opening claim mismatch".into(),
        ));
    }
    let expected_prepared_steps_step = build_kernel_prepared_step_opening_package_step(&bundle.claim.prepared_steps)?;
    if bundle.prepared_steps.packaged.statement.steps.len() != 1
        || !same_public_step(
            &bundle.prepared_steps.packaged.statement.steps[0],
            &expected_prepared_steps_step.instance(),
        )
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel prepared-step opening package public step mismatch".into(),
        ));
    }
    let prepared_steps_context = ExactVectorPackageContext::new(
        expected_prepared_steps_step.witness.w.len(),
        EXACT_STAGE_PP_SEED,
        "rv64im/kernel_opening_bundle/prepared_steps",
    )?;
    let prepared_steps_started = Instant::now();
    verify_packaged(
        FoldingMode::Optimized,
        prepared_steps_context.params(),
        prepared_steps_context.ccs(),
        &bundle.prepared_steps.packaged,
        rv64im_ajtai_mixers(),
    )?;
    Ok(KernelOpeningBundleVerifyPerf {
        claim_rebuild_ms: 0.0,
        bindings_ms: millis_since(bindings_started),
        prepared_steps_ms: millis_since(prepared_steps_started),
        total_ms: millis_since(total_started),
    })
}

pub(super) fn build_kernel_opening_bundle_with_perf(
    stage_claims: &SimpleKernelStageClaimBundle,
    stage_packages: &SimpleKernelStagePackageBundle,
    kernel_claims: &SimpleKernelKernelClaimBundle,
    prepared_steps: &[StepInput],
) -> Result<(SimpleKernelOpeningBundle, KernelOpeningBundleBuildPerf), SimpleKernelError> {
    build_kernel_opening_proof_with_perf(build_kernel_opening_claim(
        stage_claims,
        stage_packages,
        kernel_claims,
        prepared_steps,
    ))
}

pub(super) fn verify_kernel_opening_bundle_with_perf(
    bundle: &SimpleKernelOpeningBundle,
    stage_claims: &SimpleKernelStageClaimBundle,
    stage_packages: &SimpleKernelStagePackageBundle,
    kernel_claims: &SimpleKernelKernelClaimBundle,
    prepared_steps: &[StepInput],
) -> Result<KernelOpeningBundleVerifyPerf, SimpleKernelError> {
    let claim_started = Instant::now();
    let expected_claim = build_kernel_opening_claim(stage_claims, stage_packages, kernel_claims, prepared_steps);
    let claim_rebuild_ms = millis_since(claim_started);
    if bundle.claim != expected_claim {
        return Err(SimpleKernelError::Bridge("RV64IM kernel opening claim mismatch".into()));
    }
    let mut perf = verify_kernel_opening_proof_with_perf(bundle)?;
    perf.claim_rebuild_ms = claim_rebuild_ms;
    perf.total_ms += claim_rebuild_ms;
    Ok(perf)
}

pub(super) fn build_stage_claim_bundle_from_parts(
    stage1_summary: &Stage1Summary,
    stage2_summary: &Stage2Summary,
    stage3_summary: &Stage3Summary,
    transcript: &TranscriptRecord,
    kernel: &Rv64imKernelSummary,
) -> Result<SimpleKernelStageClaimBundle, SimpleKernelError> {
    Ok(build_stage_claim_bundle_from_parts_with_perf(
        stage1_summary,
        stage2_summary,
        stage3_summary,
        transcript,
        kernel,
    )?
    .0)
}

pub(super) fn build_stage_claim_bundle_from_parts_with_perf(
    stage1_summary: &Stage1Summary,
    stage2_summary: &Stage2Summary,
    stage3_summary: &Stage3Summary,
    transcript: &TranscriptRecord,
    kernel: &Rv64imKernelSummary,
) -> Result<(SimpleKernelStageClaimBundle, StageClaimBundleBuildPerf), SimpleKernelError> {
    let total_started = Instant::now();

    let stage1_flat_started = Instant::now();
    let stage1_flat = flatten_stage1(stage1_summary);
    let stage1_flat_ms = millis_since(stage1_flat_started);
    let (stage1_commitment, stage1_opening_manifest, stage1_opening_proof, mut stage1_perf) =
        build_exact_stage_surface_with_perf("rv64im/stage1", &stage1_flat, EXACT_STAGE_PP_SEED)?;
    stage1_perf.flatten_ms = stage1_flat_ms;
    let stage1 = Stage1ArtifactSurface {
        commitment: stage1_commitment,
        opening_manifest: stage1_opening_manifest,
        opening_proof: stage1_opening_proof,
        claim: Stage1ClaimSurface {
            row_count: stage1_summary.rows.len(),
            effect_row_count: stage1_summary
                .rows
                .iter()
                .filter(|row| row.is_effect_row)
                .count(),
            commit_row_count: stage1_summary
                .rows
                .iter()
                .filter(|row| row.is_commit_row)
                .count(),
            real_row_count: stage1_summary.rows.iter().filter(|row| row.is_real).count(),
            preserves_x0_count: stage1_summary
                .rows
                .iter()
                .filter(|row| row.preserves_x0)
                .count(),
            mix: kernel.stage1_mix,
        },
    };

    let stage2_flat_started = Instant::now();
    let stage2_flat = flatten_stage2(stage2_summary);
    let stage2_flat_ms = millis_since(stage2_flat_started);
    let (stage2_commitment, stage2_opening_manifest, stage2_opening_proof, mut stage2_perf) =
        build_exact_stage_surface_with_perf("rv64im/stage2", &stage2_flat, EXACT_STAGE_PP_SEED)?;
    stage2_perf.flatten_ms = stage2_flat_ms;
    let stage2 = Stage2ArtifactSurface {
        commitment: stage2_commitment,
        opening_manifest: stage2_opening_manifest,
        opening_proof: stage2_opening_proof,
        claim: Stage2ClaimSurface {
            register_read_count: stage2_summary.register_reads.len(),
            register_write_count: stage2_summary.register_writes.len(),
            ram_event_count: stage2_summary.ram_events.len(),
            twist_link_count: stage2_summary.twist_links.len(),
            ram_read_count: stage2_summary
                .ram_events
                .iter()
                .filter(|event| matches!(event.kind, RamAccessKind::Read))
                .count(),
            ram_write_count: stage2_summary
                .ram_events
                .iter()
                .filter(|event| matches!(event.kind, RamAccessKind::Write))
                .count(),
            reg_mix: kernel.stage2_reg_mix,
            ram_mix: kernel.stage2_ram_mix,
        },
    };

    let stage3_flat_started = Instant::now();
    let stage3_flat = flatten_stage3(stage3_summary);
    let stage3_flat_ms = millis_since(stage3_flat_started);
    let (stage3_commitment, stage3_opening_manifest, stage3_opening_proof, mut stage3_perf) =
        build_exact_stage_surface_with_perf("rv64im/stage3", &stage3_flat, EXACT_STAGE_PP_SEED)?;
    stage3_perf.flatten_ms = stage3_flat_ms;
    let stage3 = Stage3ArtifactSurface {
        commitment: stage3_commitment,
        opening_manifest: stage3_opening_manifest,
        opening_proof: stage3_opening_proof,
        claim: Stage3ClaimSurface {
            continuity_count: stage3_summary.continuity.len(),
            final_step_count: stage3_summary
                .continuity
                .iter()
                .filter(|event| event.final_step)
                .count(),
            halted: stage3_summary.halted,
            all_continuity_hold: stage3_summary
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
            event_count: transcript.events.len(),
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
    let claims = SimpleKernelStageClaimBundle {
        digest: claims.expected_digest(),
        ..claims
    };
    Ok((
        claims,
        StageClaimBundleBuildPerf {
            stage1: stage1_perf,
            stage2: stage2_perf,
            stage3: stage3_perf,
            total_ms: millis_since(total_started),
        },
    ))
}
