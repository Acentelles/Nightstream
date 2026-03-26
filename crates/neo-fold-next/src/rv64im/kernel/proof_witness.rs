//! Owns RV64IM-owned witness-facing wrappers above the simple-kernel export.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use super::{
    rv64im_simple_root_context_id, Rv64imParityCaseManifest, SimpleKernelKernelClaimBundle, SimpleKernelOpeningBundle,
    SimpleKernelOutput, SimpleKernelStageClaimBundle, SimpleKernelStagePackageBundle, SimpleKernelStageWitnessBundle,
    SimpleKernelTraceWitness,
};
use crate::rv64im::tables::Rv64FamilyTag;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imProofWitnessBundle {
    pub root_params_id: [u8; 32],
    pub trace: Rv64imTraceProofBundle,
    pub stages: Rv64imStageWitnessProofBundle,
    pub stage_claims: Rv64imStageClaimProofBundle,
    pub stage_packages: Rv64imStagePackageProofBundle,
    pub kernel_opening: Rv64imKernelOpeningProofBundle,
    pub kernel_claims: Rv64imKernelClaimProofBundle,
    pub public_step_count: u64,
    pub final_pc: u64,
    pub halted: bool,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningBindingBundle {
    pub claim_digest: [u8; 32],
    pub bindings_digest: [u8; 32],
    pub prepared_steps_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningProofBundle {
    pub opening_digest: [u8; 32],
    pub bindings: Rv64imKernelOpeningBindingBundle,
    pub digest: [u8; 32],
    pub(crate) opening: SimpleKernelOpeningBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelOpeningSummaryBundle {
    pub opening_digest: [u8; 32],
    pub bindings: Rv64imKernelOpeningBindingBundle,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelClaimTerminalBundle {
    pub root0_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub final_state_digest: [u8; 32],
    pub transcript_final_digest: [u8; 32],
    pub final_pc: u64,
    pub halted: bool,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelClaimSummaryBundle {
    pub prepared_step_bindings_digest: [u8; 32],
    pub terminal: Rv64imKernelClaimTerminalBundle,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imKernelClaimProofBundle {
    pub summary: Rv64imKernelClaimSummaryBundle,
    pub digest: [u8; 32],
    pub(crate) claims: SimpleKernelKernelClaimBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStageClaimDigestBundle {
    pub claim_bundle_digest: [u8; 32],
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub transcript_digest: [u8; 32],
    pub execution_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStageClaimProofBundle {
    pub summary: Rv64imStageClaimDigestBundle,
    pub digest: [u8; 32],
    pub(crate) claims: SimpleKernelStageClaimBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStagePackageDigestBundle {
    pub package_bundle_digest: [u8; 32],
    pub stage1_digest: [u8; 32],
    pub stage2_digest: [u8; 32],
    pub stage3_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStagePackageProofBundle {
    pub summary: Rv64imStagePackageDigestBundle,
    pub digest: [u8; 32],
    pub(crate) packages: SimpleKernelStagePackageBundle,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imTraceShapeBundle {
    pub execution_row_count: u64,
    pub real_row_count: u64,
    pub effect_row_count: u64,
    pub commit_row_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imTraceProofBundle {
    pub manifest: Rv64imParityCaseManifest,
    pub execution_digest: [u8; 32],
    pub shape: Rv64imTraceShapeBundle,
    pub digest: [u8; 32],
    pub(crate) trace: SimpleKernelTraceWitness,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStageWitnessSummaryBundle {
    pub stage1_row_count: u64,
    pub stage2_register_read_count: u64,
    pub stage2_register_write_count: u64,
    pub stage2_ram_event_count: u64,
    pub stage2_twist_link_count: u64,
    pub stage3_continuity_count: u64,
    pub stage3_halted: bool,
    pub transcript_event_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Rv64imStageWitnessProofBundle {
    pub summary: Rv64imStageWitnessSummaryBundle,
    pub digest: [u8; 32],
    pub(crate) stages: SimpleKernelStageWitnessBundle,
}

impl Rv64imProofWitnessBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/proof_witness_bundle");
        tr.append_message(b"rv64im/proof_witness_bundle/root_params_id", &self.root_params_id);
        tr.append_message(b"rv64im/proof_witness_bundle/trace_digest", &self.trace.digest);
        tr.append_message(b"rv64im/proof_witness_bundle/stages_digest", &self.stages.digest);
        tr.append_message(
            b"rv64im/proof_witness_bundle/stage_claims_digest",
            &self.stage_claims.digest,
        );
        tr.append_message(
            b"rv64im/proof_witness_bundle/stage_packages_digest",
            &self.stage_packages.digest,
        );
        tr.append_message(
            b"rv64im/proof_witness_bundle/kernel_opening_digest",
            &self.kernel_opening.digest,
        );
        tr.append_message(
            b"rv64im/proof_witness_bundle/kernel_claims_digest",
            &self.kernel_claims.digest,
        );
        tr.append_u64s(
            b"rv64im/proof_witness_bundle/meta",
            &[self.public_step_count, self.final_pc, self.halted as u64],
        );
        tr.digest32()
    }
}

impl Rv64imKernelOpeningBindingBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_binding_bundle");
        tr.append_message(b"rv64im/kernel_opening_binding_bundle/claim_digest", &self.claim_digest);
        tr.append_message(
            b"rv64im/kernel_opening_binding_bundle/bindings_digest",
            &self.bindings_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_binding_bundle/prepared_steps_digest",
            &self.prepared_steps_digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelOpeningProofBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_proof_bundle");
        tr.append_message(
            b"rv64im/kernel_opening_proof_bundle/opening_digest",
            &self.opening_digest,
        );
        tr.append_message(b"rv64im/kernel_opening_proof_bundle/bindings", &self.bindings.digest);
        tr.digest32()
    }

    pub fn claim_digest(&self) -> [u8; 32] {
        self.bindings.claim_digest
    }

    pub fn opening_digest(&self) -> [u8; 32] {
        self.opening_digest
    }

    pub fn bindings_digest(&self) -> [u8; 32] {
        self.bindings.bindings_digest
    }

    pub fn prepared_steps_digest(&self) -> [u8; 32] {
        self.bindings.prepared_steps_digest
    }

    pub fn summary(&self) -> Rv64imKernelOpeningSummaryBundle {
        let summary = Rv64imKernelOpeningSummaryBundle {
            opening_digest: self.opening_digest,
            bindings: self.bindings.clone(),
            digest: [0; 32],
        };
        Rv64imKernelOpeningSummaryBundle {
            digest: summary.expected_digest(),
            ..summary
        }
    }
}

impl Rv64imKernelOpeningSummaryBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_opening_summary_bundle");
        tr.append_message(
            b"rv64im/kernel_opening_summary_bundle/opening_digest",
            &self.opening_digest,
        );
        tr.append_message(
            b"rv64im/kernel_opening_summary_bundle/bindings_digest",
            &self.bindings.digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelClaimTerminalBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_claim_terminal_bundle");
        tr.append_message(b"rv64im/kernel_claim_terminal_bundle/root0_digest", &self.root0_digest);
        tr.append_message(
            b"rv64im/kernel_claim_terminal_bundle/execution_digest",
            &self.execution_digest,
        );
        tr.append_message(
            b"rv64im/kernel_claim_terminal_bundle/final_state_digest",
            &self.final_state_digest,
        );
        tr.append_message(
            b"rv64im/kernel_claim_terminal_bundle/transcript_final_digest",
            &self.transcript_final_digest,
        );
        tr.append_u64s(
            b"rv64im/kernel_claim_terminal_bundle/meta",
            &[self.final_pc, self.halted as u64],
        );
        tr.digest32()
    }
}

impl Rv64imKernelClaimSummaryBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_claim_summary_bundle");
        tr.append_message(
            b"rv64im/kernel_claim_summary_bundle/prepared_step_bindings_digest",
            &self.prepared_step_bindings_digest,
        );
        tr.append_message(
            b"rv64im/kernel_claim_summary_bundle/terminal_digest",
            &self.terminal.digest,
        );
        tr.digest32()
    }
}

impl Rv64imKernelClaimProofBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/kernel_claim_proof_bundle");
        tr.append_message(b"rv64im/kernel_claim_proof_bundle/summary", &self.summary.digest);
        tr.digest32()
    }

    pub fn prepared_step_bindings_digest(&self) -> [u8; 32] {
        self.summary.prepared_step_bindings_digest
    }

    pub fn root0_digest(&self) -> [u8; 32] {
        self.summary.terminal.root0_digest
    }

    pub fn final_state_digest(&self) -> [u8; 32] {
        self.summary.terminal.final_state_digest
    }

    pub fn execution_digest(&self) -> [u8; 32] {
        self.summary.terminal.execution_digest
    }

    pub fn transcript_final_digest(&self) -> [u8; 32] {
        self.summary.terminal.transcript_final_digest
    }

    pub fn final_pc(&self) -> u64 {
        self.summary.terminal.final_pc
    }

    pub fn halted(&self) -> bool {
        self.summary.terminal.halted
    }

    pub fn terminal_digest(&self) -> [u8; 32] {
        self.summary.terminal.digest
    }
}

impl Rv64imStageClaimDigestBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_claim_digest_bundle");
        tr.append_message(
            b"rv64im/stage_claim_digest_bundle/claim_bundle_digest",
            &self.claim_bundle_digest,
        );
        tr.append_message(b"rv64im/stage_claim_digest_bundle/stage1_digest", &self.stage1_digest);
        tr.append_message(b"rv64im/stage_claim_digest_bundle/stage2_digest", &self.stage2_digest);
        tr.append_message(b"rv64im/stage_claim_digest_bundle/stage3_digest", &self.stage3_digest);
        tr.append_message(
            b"rv64im/stage_claim_digest_bundle/transcript_digest",
            &self.transcript_digest,
        );
        tr.append_message(
            b"rv64im/stage_claim_digest_bundle/execution_digest",
            &self.execution_digest,
        );
        tr.digest32()
    }
}

impl Rv64imStageClaimProofBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_claim_proof_bundle");
        tr.append_message(b"rv64im/stage_claim_proof_bundle/summary", &self.summary.digest);
        tr.digest32()
    }

    pub fn stage1_digest(&self) -> [u8; 32] {
        self.summary.stage1_digest
    }

    pub fn claim_bundle_digest(&self) -> [u8; 32] {
        self.summary.claim_bundle_digest
    }

    pub fn stage2_digest(&self) -> [u8; 32] {
        self.summary.stage2_digest
    }

    pub fn stage3_digest(&self) -> [u8; 32] {
        self.summary.stage3_digest
    }
}

impl Rv64imStagePackageDigestBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_package_digest_bundle");
        tr.append_message(
            b"rv64im/stage_package_digest_bundle/package_bundle_digest",
            &self.package_bundle_digest,
        );
        tr.append_message(b"rv64im/stage_package_digest_bundle/stage1_digest", &self.stage1_digest);
        tr.append_message(b"rv64im/stage_package_digest_bundle/stage2_digest", &self.stage2_digest);
        tr.append_message(b"rv64im/stage_package_digest_bundle/stage3_digest", &self.stage3_digest);
        tr.digest32()
    }
}

impl Rv64imStagePackageProofBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_package_proof_bundle");
        tr.append_message(b"rv64im/stage_package_proof_bundle/summary", &self.summary.digest);
        tr.digest32()
    }

    pub fn stage1_digest(&self) -> [u8; 32] {
        self.summary.stage1_digest
    }

    pub fn package_bundle_digest(&self) -> [u8; 32] {
        self.summary.package_bundle_digest
    }

    pub fn stage2_digest(&self) -> [u8; 32] {
        self.summary.stage2_digest
    }

    pub fn stage3_digest(&self) -> [u8; 32] {
        self.summary.stage3_digest
    }
}

fn family_word(family: Rv64FamilyTag) -> u64 {
    match family {
        Rv64FamilyTag::NativeAlu => 0,
        Rv64FamilyTag::AlignedMemory => 1,
        Rv64FamilyTag::ControlFlow => 2,
        Rv64FamilyTag::NarrowMemory => 3,
        Rv64FamilyTag::Multiply => 4,
        Rv64FamilyTag::UnsignedDivRem => 5,
        Rv64FamilyTag::SignedDivRem => 6,
    }
}

impl Rv64imTraceShapeBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/trace_shape_bundle");
        tr.append_u64s(
            b"rv64im/trace_shape_bundle/meta",
            &[
                self.execution_row_count,
                self.real_row_count,
                self.effect_row_count,
                self.commit_row_count,
            ],
        );
        tr.digest32()
    }
}

impl Rv64imTraceProofBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/trace_proof_bundle");
        tr.append_message(b"rv64im/trace_proof_bundle/name", self.manifest.name.as_bytes());
        tr.append_message(
            b"rv64im/trace_proof_bundle/fixture_id",
            self.manifest.fixture_id.as_bytes(),
        );
        tr.append_u64s(
            b"rv64im/trace_proof_bundle/meta",
            &[self.manifest.protocol_version_id, self.manifest.lowering_version_id],
        );
        tr.append_u64s(
            b"rv64im/trace_proof_bundle/family_tag_len",
            &[self.manifest.family_tags.len() as u64],
        );
        for family in &self.manifest.family_tags {
            tr.append_u64s(b"rv64im/trace_proof_bundle/family_tag", &[family_word(*family)]);
        }
        tr.append_message(b"rv64im/trace_proof_bundle/execution_digest", &self.execution_digest);
        tr.append_message(b"rv64im/trace_proof_bundle/shape_digest", &self.shape.digest);
        tr.digest32()
    }

    pub fn execution_row_count(&self) -> u64 {
        self.shape.execution_row_count
    }

    pub fn execution_digest(&self) -> [u8; 32] {
        self.execution_digest
    }

    pub fn real_row_count(&self) -> u64 {
        self.shape.real_row_count
    }

    pub fn effect_row_count(&self) -> u64 {
        self.shape.effect_row_count
    }

    pub fn commit_row_count(&self) -> u64 {
        self.shape.commit_row_count
    }
}

impl Rv64imStageWitnessSummaryBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_witness_summary_bundle");
        tr.append_u64s(
            b"rv64im/stage_witness_summary_bundle/meta",
            &[
                self.stage1_row_count,
                self.stage2_register_read_count,
                self.stage2_register_write_count,
                self.stage2_ram_event_count,
                self.stage2_twist_link_count,
                self.stage3_continuity_count,
                self.stage3_halted as u64,
                self.transcript_event_count,
            ],
        );
        tr.digest32()
    }
}

impl Rv64imStageWitnessProofBundle {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage_witness_proof_bundle");
        tr.append_message(b"rv64im/stage_witness_proof_bundle/summary", &self.summary.digest);
        tr.digest32()
    }

    pub fn stage1_row_count(&self) -> u64 {
        self.summary.stage1_row_count
    }

    pub fn stage3_continuity_count(&self) -> u64 {
        self.summary.stage3_continuity_count
    }

    pub fn stage3_halted(&self) -> bool {
        self.summary.stage3_halted
    }
}

pub(crate) fn trace_proof_bundle_from_trace(
    trace: &SimpleKernelTraceWitness,
    execution_digest: [u8; 32],
) -> Rv64imTraceProofBundle {
    let rows = &trace.execution_rows;
    let shape = Rv64imTraceShapeBundle {
        execution_row_count: rows.len() as u64,
        real_row_count: rows.iter().filter(|row| row.is_real).count() as u64,
        effect_row_count: rows.iter().filter(|row| row.is_effect_row).count() as u64,
        commit_row_count: rows.iter().filter(|row| row.is_commit_row).count() as u64,
        digest: [0; 32],
    };
    let shape = Rv64imTraceShapeBundle {
        digest: shape.expected_digest(),
        ..shape
    };
    let bundle = Rv64imTraceProofBundle {
        manifest: trace.manifest.clone(),
        execution_digest,
        shape,
        digest: [0; 32],
        trace: trace.clone(),
    };
    Rv64imTraceProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

pub(crate) fn stage_witness_proof_bundle_from_stages(
    stages: &SimpleKernelStageWitnessBundle,
) -> Rv64imStageWitnessProofBundle {
    let summary = Rv64imStageWitnessSummaryBundle {
        stage1_row_count: stages.stage1.rows.len() as u64,
        stage2_register_read_count: stages.stage2.register_reads.len() as u64,
        stage2_register_write_count: stages.stage2.register_writes.len() as u64,
        stage2_ram_event_count: stages.stage2.ram_events.len() as u64,
        stage2_twist_link_count: stages.stage2.twist_links.len() as u64,
        stage3_continuity_count: stages.stage3.continuity.len() as u64,
        stage3_halted: stages.stage3.halted,
        transcript_event_count: stages.transcript.events.len() as u64,
        digest: [0; 32],
    };
    let summary = Rv64imStageWitnessSummaryBundle {
        digest: summary.expected_digest(),
        ..summary
    };
    let bundle = Rv64imStageWitnessProofBundle {
        summary,
        digest: [0; 32],
        stages: stages.clone(),
    };
    Rv64imStageWitnessProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

pub(crate) fn stage_claim_proof_bundle_from_claims(
    claims: &SimpleKernelStageClaimBundle,
) -> Rv64imStageClaimProofBundle {
    let summary = Rv64imStageClaimDigestBundle {
        claim_bundle_digest: claims.digest,
        stage1_digest: claims.stage1.commitment.digest,
        stage2_digest: claims.stage2.commitment.digest,
        stage3_digest: claims.stage3.commitment.digest,
        transcript_digest: claims.transcript.commitment.digest,
        execution_digest: claims.execution_digest,
        digest: [0; 32],
    };
    let summary = Rv64imStageClaimDigestBundle {
        digest: summary.expected_digest(),
        ..summary
    };
    let bundle = Rv64imStageClaimProofBundle {
        summary,
        digest: [0; 32],
        claims: claims.clone(),
    };
    Rv64imStageClaimProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

pub(crate) fn stage_package_proof_bundle_from_packages(
    packages: &SimpleKernelStagePackageBundle,
) -> Rv64imStagePackageProofBundle {
    let summary = Rv64imStagePackageDigestBundle {
        package_bundle_digest: packages.digest,
        stage1_digest: packages.stage1.digest,
        stage2_digest: packages.stage2.digest,
        stage3_digest: packages.stage3.digest,
        digest: [0; 32],
    };
    let summary = Rv64imStagePackageDigestBundle {
        digest: summary.expected_digest(),
        ..summary
    };
    let bundle = Rv64imStagePackageProofBundle {
        summary,
        digest: [0; 32],
        packages: packages.clone(),
    };
    Rv64imStagePackageProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

pub(crate) fn kernel_opening_proof_bundle_from_opening(
    opening: &SimpleKernelOpeningBundle,
) -> Rv64imKernelOpeningProofBundle {
    let bindings = Rv64imKernelOpeningBindingBundle {
        claim_digest: opening.claim.digest,
        bindings_digest: opening.bindings.digest,
        prepared_steps_digest: opening.prepared_steps.digest,
        digest: [0; 32],
    };
    let bindings = Rv64imKernelOpeningBindingBundle {
        digest: bindings.expected_digest(),
        ..bindings
    };
    let bundle = Rv64imKernelOpeningProofBundle {
        opening_digest: opening.digest,
        bindings,
        digest: [0; 32],
        opening: opening.clone(),
    };
    Rv64imKernelOpeningProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

pub(crate) fn kernel_claim_proof_bundle_from_claims(
    claims: &SimpleKernelKernelClaimBundle,
) -> Rv64imKernelClaimProofBundle {
    let summary = &claims.kernel;
    let terminal = Rv64imKernelClaimTerminalBundle {
        root0_digest: summary.root0_digest,
        execution_digest: summary.execution_digest,
        final_state_digest: summary.final_state_digest,
        transcript_final_digest: summary.transcript_final_digest,
        final_pc: summary.final_pc,
        halted: summary.halted,
        digest: [0; 32],
    };
    let terminal = Rv64imKernelClaimTerminalBundle {
        digest: terminal.expected_digest(),
        ..terminal
    };
    let summary = Rv64imKernelClaimSummaryBundle {
        prepared_step_bindings_digest: claims.prepared_step_bindings.digest,
        terminal,
        digest: [0; 32],
    };
    let summary = Rv64imKernelClaimSummaryBundle {
        digest: summary.expected_digest(),
        ..summary
    };
    let bundle = Rv64imKernelClaimProofBundle {
        summary,
        digest: [0; 32],
        claims: claims.clone(),
    };
    Rv64imKernelClaimProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}

pub(crate) fn proof_witness_bundle_from_kernel_output(kernel: &SimpleKernelOutput) -> Rv64imProofWitnessBundle {
    let trace = trace_proof_bundle_from_trace(&kernel.trace, kernel.kernel_claims.kernel.execution_digest);
    let stages = stage_witness_proof_bundle_from_stages(&kernel.stages);
    let stage_claims = stage_claim_proof_bundle_from_claims(&kernel.stage_claims);
    let stage_packages = stage_package_proof_bundle_from_packages(&kernel.stage_packages);
    let kernel_opening = kernel_opening_proof_bundle_from_opening(&kernel.kernel_opening);
    let kernel_claims = kernel_claim_proof_bundle_from_claims(&kernel.kernel_claims);
    let bundle = Rv64imProofWitnessBundle {
        root_params_id: rv64im_simple_root_context_id(),
        trace,
        stages,
        stage_claims,
        stage_packages,
        kernel_opening,
        kernel_claims,
        public_step_count: kernel.public_steps.len() as u64,
        final_pc: kernel.kernel_claims.kernel.final_pc,
        halted: kernel.kernel_claims.kernel.halted,
        digest: [0; 32],
    };
    Rv64imProofWitnessBundle {
        digest: bundle.expected_digest(),
        ..bundle
    }
}
