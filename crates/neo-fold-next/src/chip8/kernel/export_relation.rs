//! Owns the CHIP-8 kernel export relation: one witness-backed side-lane relation digest and its verification result.

use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chip8::Chip8State;
use crate::proof::FoldSchedule;

use super::evidence::build_kernel_export_surface_from_prepared_steps;
use super::{
    verify_kernel_execution_relation, Chip8BridgeChunkRelationWitness, KernelExecutionRelationResult,
    KernelExecutionRelationWitness, SimpleKernelError, SimpleKernelPublicInput, SimpleKernelVerifierInput,
    VerifiedKernelChunkHandoff, CHIP8_BRIDGE_FOLD_SCHEDULE,
};

pub(crate) struct KernelExportRelationResult {
    pub final_state: Chip8State,
    pub chunk_handoffs: Vec<VerifiedKernelChunkHandoff>,
    pub bridge_final_state: [u8; 32],
}

pub(crate) fn build_kernel_export_relation_result_from_execution_relation(
    verified: KernelExecutionRelationResult,
) -> KernelExportRelationResult {
    KernelExportRelationResult {
        final_state: verified.final_state,
        chunk_handoffs: verified.chunk_handoffs,
        bridge_final_state: verified.bridge_final_state,
    }
}

pub(crate) fn build_kernel_export_relation_digest_from_verified_execution_relation(
    verified: &KernelExecutionRelationResult,
    relation_witness: &KernelExecutionRelationWitness,
) -> [u8; 32] {
    let export_surface_digest = kernel_export_surface_digest_from_verified_relation(verified);
    let bridge_source_digest = digest_kernel_bridge_relation_witness(
        relation_witness.bridge_chunk_transitions(),
        verified.kernel_opening_manifest.digest,
    );
    kernel_export_relation_digest(export_surface_digest, bridge_source_digest, verified.bridge_final_state)
}

pub(crate) fn verify_kernel_export_relation(
    public: &SimpleKernelPublicInput,
    expected_schedule: FoldSchedule,
    relation_digest: [u8; 32],
    relation_witness: &KernelExecutionRelationWitness,
) -> Result<KernelExportRelationResult, SimpleKernelError> {
    if expected_schedule != CHIP8_BRIDGE_FOLD_SCHEDULE {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge chunk schedule does not match frozen CHIP-8 export schedule".into(),
        ));
    }
    let verifier_input = SimpleKernelVerifierInput { public: public.clone() };
    let verified = verify_kernel_execution_relation(&verifier_input, relation_witness)?;
    let expected_relation_digest =
        build_kernel_export_relation_digest_from_verified_execution_relation(&verified, relation_witness);
    if relation_digest != expected_relation_digest {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel export relation digest mismatch".into(),
        ));
    }
    Ok(build_kernel_export_relation_result_from_execution_relation(verified))
}

fn kernel_export_surface_digest_from_verified_relation(verified: &KernelExecutionRelationResult) -> [u8; 32] {
    build_kernel_export_surface_from_prepared_steps(&verified.prepared_steps).digest32()
}

fn digest_kernel_bridge_relation_witness(
    transitions: &[Chip8BridgeChunkRelationWitness],
    kernel_opening_manifest_digest: [u8; 32],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_bridge_relation_witness");
    tr.append_message(
        b"neo.fold.next/chip8/kernel_bridge_relation_witness/opening_manifest",
        &kernel_opening_manifest_digest,
    );
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_bridge_relation_witness/chunk_count",
        &[transitions.len() as u64],
    );
    for transition in transitions {
        tr.append_message(
            b"neo.fold.next/chip8/kernel_bridge_relation_witness/chunk_transition",
            &transition.expected_digest(),
        );
    }
    tr.digest32()
}

fn kernel_export_relation_digest(
    export_surface_digest: [u8; 32],
    bridge_source_digest: [u8; 32],
    bridge_final_state: [u8; 32],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_export_relation");
    tr.append_message(
        b"neo.fold.next/chip8/kernel_export_relation/export_surface_digest",
        &export_surface_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/kernel_export_relation/bridge_source_digest",
        &bridge_source_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/kernel_export_relation/bridge_final_state",
        &bridge_final_state,
    );
    tr.digest32()
}
