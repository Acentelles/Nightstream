//! Owns the exact Rust package for the CHIP-8 release-facing kernel artifact.
//! This file does not introduce a new summary layer; it only packages the
//! existing grouped kernel digest and staged bundle under one shared owner,
//! plus the proof-free external view that Lean imports for release checks.

use super::{
    build_kernel_execution_digest, build_kernel_staged_execution_digest_bundle, verify_kernel_execution_digest,
    verify_kernel_staged_execution_digest_bundle, CommitmentId, KernelCommitments, KernelExactFrame,
    KernelExecutionDigest, KernelStage3DigestSurface, KernelStagedExecutionDigestBundle, SimpleKernelError,
    SimpleKernelOutput, SimpleKernelProof, SimpleKernelPublicInput,
};

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
    pub artifact: KernelReleaseArtifact,
}

pub fn build_kernel_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
) -> Result<KernelReleaseArtifact, SimpleKernelError> {
    Ok(KernelReleaseArtifact {
        kernel_digest: build_kernel_execution_digest(public, proof, output)?,
        staged_bundle: build_kernel_staged_execution_digest_bundle(public, proof, output)?,
    })
}

pub fn verify_kernel_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    artifact: &KernelReleaseArtifact,
) -> Result<(), String> {
    verify_kernel_execution_digest(public, proof, output, &artifact.kernel_digest)?;
    verify_kernel_staged_execution_digest_bundle(public, proof, output, &artifact.staged_bundle)?;
    Ok(())
}

pub fn build_kernel_external_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
) -> Result<KernelExternalReleaseArtifact, SimpleKernelError> {
    let artifact = build_kernel_release_artifact(public, proof, output)?;
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
        artifact,
    })
}

pub fn verify_kernel_external_release_artifact(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    output: &SimpleKernelOutput,
    artifact: &KernelExternalReleaseArtifact,
) -> Result<(), String> {
    let expected = build_kernel_external_release_artifact(public, proof, output)
        .map_err(|err| format!("kernel external release artifact build failed: {err}"))?;
    if artifact != &expected {
        return Err("kernel external release artifact mismatch".into());
    }
    Ok(())
}

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
