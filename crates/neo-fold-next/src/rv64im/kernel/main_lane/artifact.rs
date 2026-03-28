//! Owns the RV64IM packaged main-lane artifact bound to the committed root lane exports.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use super::{RootLaneColumns, RootLaneCommitmentArtifact, RootLaneCommitmentSummaryArtifact, SimpleKernelError};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct SimpleKernelMainLaneBinding {
    pub root_lane_columns_digest: [u8; 32],
    pub root_lane_commitment_digest: [u8; 32],
    pub public_step_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SimpleKernelMainLaneArtifact {
    pub binding: SimpleKernelMainLaneBinding,
    pub digest: [u8; 32],
}

impl SimpleKernelMainLaneBinding {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/simple_kernel_main_lane_binding");
        tr.append_message(
            b"rv64im/simple_kernel_main_lane_binding/root_lane_columns_digest",
            &self.root_lane_columns_digest,
        );
        tr.append_message(
            b"rv64im/simple_kernel_main_lane_binding/root_lane_commitment_digest",
            &self.root_lane_commitment_digest,
        );
        tr.append_u64s(
            b"rv64im/simple_kernel_main_lane_binding/meta",
            &[self.public_step_count],
        );
        tr.digest32()
    }
}

impl SimpleKernelMainLaneArtifact {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/simple_kernel_main_lane_artifact");
        tr.append_message(
            b"rv64im/simple_kernel_main_lane_artifact/binding_digest",
            &self.binding.digest,
        );
        tr.digest32()
    }
}

fn build_simple_kernel_main_lane_artifact_from_binding(
    root_lane_columns_digest: [u8; 32],
    root_lane_commitment_digest: [u8; 32],
    public_step_count: u64,
) -> SimpleKernelMainLaneArtifact {
    let binding = SimpleKernelMainLaneBinding {
        root_lane_columns_digest,
        root_lane_commitment_digest,
        public_step_count,
        digest: [0; 32],
    };
    let binding = SimpleKernelMainLaneBinding {
        digest: binding.expected_digest(),
        ..binding
    };
    let artifact = SimpleKernelMainLaneArtifact {
        binding,
        digest: [0; 32],
    };
    SimpleKernelMainLaneArtifact {
        digest: artifact.expected_digest(),
        ..artifact
    }
}

pub fn build_simple_kernel_main_lane_artifact(
    root_lane_columns: &RootLaneColumns,
    root_lane_commitment: &RootLaneCommitmentArtifact,
) -> Result<SimpleKernelMainLaneArtifact, SimpleKernelError> {
    Ok(build_simple_kernel_main_lane_artifact_from_binding(
        root_lane_columns.digest,
        root_lane_commitment.digest,
        root_lane_columns.time_len,
    ))
}

pub fn build_simple_kernel_main_lane_artifact_from_summary(
    root_lane_columns: &RootLaneColumns,
    root_lane_commitment: &RootLaneCommitmentSummaryArtifact,
) -> Result<SimpleKernelMainLaneArtifact, SimpleKernelError> {
    Ok(build_simple_kernel_main_lane_artifact_from_binding(
        root_lane_columns.digest,
        root_lane_commitment.digest,
        root_lane_columns.time_len,
    ))
}

pub fn validate_simple_kernel_main_lane_artifact(
    root_lane_columns: &RootLaneColumns,
    root_lane_commitment: &RootLaneCommitmentArtifact,
    artifact: &SimpleKernelMainLaneArtifact,
) -> Result<(), SimpleKernelError> {
    if artifact.binding.digest != artifact.binding.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM packaged main-lane binding digest mismatch".into(),
        ));
    }
    if artifact.binding.root_lane_columns_digest != root_lane_columns.digest
        || artifact.binding.root_lane_commitment_digest != root_lane_commitment.digest
        || artifact.binding.public_step_count != root_lane_columns.time_len
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM packaged main-lane binding does not match the root lane exports".into(),
        ));
    }
    if artifact.digest != artifact.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM packaged main-lane artifact digest mismatch".into(),
        ));
    }
    Ok(())
}
