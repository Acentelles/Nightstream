//! Owns the CHIP-8 kernel export relation: one witness-backed side-lane relation digest and its verification result.

use neo_transcript::{Poseidon2Transcript, Transcript};

use crate::chip8::chunk_relation::public_chunk_digest;
use crate::chip8::Chip8State;
use crate::proof::FoldSchedule;
use crate::proof::PublicChunk;

use super::evidence::build_kernel_export_surface_from_prepared_steps;
use super::{
    advance_chip8_bridge_state, verify_kernel_execution_relation, Chip8BridgeChunkHandoff,
    Chip8BridgeChunkRelationWitness, KernelExecutionRelationResult, KernelExecutionRelationWitness, SimpleKernelError,
    SimpleKernelPublicInput, SimpleKernelVerifierInput, CHIP8_BRIDGE_FOLD_SCHEDULE,
};

#[derive(Clone, Debug)]
pub struct KernelExportChunkHandoff {
    pub public_chunk: PublicChunk,
    pub bridge_handoff: Chip8BridgeChunkHandoff,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct KernelExportProof {
    pub public_input_digest: [u8; 32],
    pub final_state: Chip8State,
    pub chunk_handoffs: Vec<KernelExportChunkHandoff>,
    pub digest: [u8; 32],
}

pub(crate) struct KernelExportRelationResult {
    pub final_state: Chip8State,
    pub chunk_handoffs: Vec<KernelExportChunkHandoff>,
    pub bridge_final_state: [u8; 32],
}

pub(crate) fn build_kernel_export_relation_result_from_execution_relation(
    verified: KernelExecutionRelationResult,
) -> KernelExportRelationResult {
    KernelExportRelationResult {
        final_state: verified.final_state,
        chunk_handoffs: verified
            .chunk_handoffs
            .into_iter()
            .map(|handoff| KernelExportChunkHandoff {
                public_chunk: handoff.public_chunk,
                bridge_handoff: handoff.bridge_handoff,
                digest: [0; 32],
            })
            .map(|handoff| KernelExportChunkHandoff {
                digest: handoff.expected_digest(),
                ..handoff
            })
            .collect(),
        bridge_final_state: verified.bridge_final_state,
    }
}

impl KernelExportChunkHandoff {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_export_chunk_handoff");
        tr.append_message(
            b"neo.fold.next/chip8/kernel_export_chunk_handoff/public_chunk",
            &public_chunk_digest(&self.public_chunk),
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_export_chunk_handoff/bridge_handoff",
            &self.bridge_handoff.expected_digest(),
        );
        tr.digest32()
    }
}

impl KernelExportProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_export_proof");
        tr.append_message(
            b"neo.fold.next/chip8/kernel_export_proof/public_input_digest",
            &self.public_input_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/kernel_export_proof/final_state_digest",
            &chip8_state_digest(&self.final_state),
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_export_proof/chunk_count",
            &[self.chunk_handoffs.len() as u64],
        );
        for handoff in &self.chunk_handoffs {
            tr.append_message(
                b"neo.fold.next/chip8/kernel_export_proof/chunk_handoff",
                &handoff.expected_digest(),
            );
        }
        tr.digest32()
    }
}

pub(crate) fn build_kernel_export_proof_from_verified_execution_relation(
    public: &SimpleKernelPublicInput,
    verified: &KernelExecutionRelationResult,
) -> (KernelExportProof, KernelExportRelationResult, [u8; 32]) {
    let result = KernelExportRelationResult {
        final_state: verified.final_state.clone(),
        chunk_handoffs: verified
            .chunk_handoffs
            .iter()
            .map(|handoff| KernelExportChunkHandoff {
                public_chunk: handoff.public_chunk.clone(),
                bridge_handoff: handoff.bridge_handoff.clone(),
                digest: [0; 32],
            })
            .map(|handoff| KernelExportChunkHandoff {
                digest: handoff.expected_digest(),
                ..handoff
            })
            .collect(),
        bridge_final_state: verified.bridge_final_state,
    };
    let proof = KernelExportProof {
        public_input_digest: kernel_public_input_digest(public),
        final_state: result.final_state.clone(),
        chunk_handoffs: result.chunk_handoffs.clone(),
        digest: [0; 32],
    };
    let proof = KernelExportProof {
        digest: proof.expected_digest(),
        ..proof
    };
    let relation_digest = build_kernel_export_relation_digest_from_compact_result(&result);
    (proof, result, relation_digest)
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

pub(crate) fn verify_kernel_export_proof(
    public: &SimpleKernelPublicInput,
    expected_schedule: FoldSchedule,
    relation_digest: [u8; 32],
    proof: &KernelExportProof,
) -> Result<KernelExportRelationResult, SimpleKernelError> {
    if expected_schedule != CHIP8_BRIDGE_FOLD_SCHEDULE {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge chunk schedule does not match frozen CHIP-8 export schedule".into(),
        ));
    }
    if proof.digest != proof.expected_digest() {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel export proof digest mismatch".into(),
        ));
    }
    if proof.public_input_digest != kernel_public_input_digest(public) {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel export proof public input mismatch".into(),
        ));
    }
    let bridge_final_state = verify_compact_chunk_handoffs(&proof.chunk_handoffs)?;
    let result = KernelExportRelationResult {
        final_state: proof.final_state.clone(),
        chunk_handoffs: proof.chunk_handoffs.clone(),
        bridge_final_state,
    };
    let expected_relation_digest = build_kernel_export_relation_digest_from_compact_result(&result);
    if relation_digest != expected_relation_digest {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel export relation digest mismatch".into(),
        ));
    }
    Ok(result)
}

fn kernel_export_surface_digest_from_verified_relation(verified: &KernelExecutionRelationResult) -> [u8; 32] {
    build_kernel_export_surface_from_prepared_steps(&verified.prepared_steps).digest32()
}

fn kernel_export_surface_digest_from_compact_handoffs(handoffs: &[KernelExportChunkHandoff]) -> [u8; 32] {
    let semantic_rows: usize = handoffs
        .iter()
        .map(|handoff| handoff.public_chunk.steps.len())
        .sum();
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_export_surface");
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_export_surface/meta",
        &[semantic_rows as u64, semantic_rows as u64],
    );
    for handoff in handoffs {
        let row_count = active_bridge_binding_count(&handoff.bridge_handoff.step_bindings)
            .expect("compact CHIP-8 export handoff should have canonical bridge binding shape");
        for slot in 0..row_count {
            let binding = handoff.bridge_handoff.step_bindings[slot]
                .as_ref()
                .expect("active compact export binding slot must be present");
            tr.append_message(
                b"neo.fold.next/chip8/kernel_export_surface/prepared_step",
                &binding.prepared_step_digest,
            );
        }
    }
    tr.digest32()
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

fn digest_compact_kernel_bridge_source(handoffs: &[KernelExportChunkHandoff]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_bridge_compact_source");
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_bridge_compact_source/chunk_count",
        &[handoffs.len() as u64],
    );
    for handoff in handoffs {
        tr.append_message(
            b"neo.fold.next/chip8/kernel_bridge_compact_source/chunk_handoff",
            &handoff.bridge_handoff.expected_digest(),
        );
    }
    tr.digest32()
}

fn build_kernel_export_relation_digest_from_compact_result(result: &KernelExportRelationResult) -> [u8; 32] {
    let export_surface_digest = kernel_export_surface_digest_from_compact_handoffs(&result.chunk_handoffs);
    let bridge_source_digest = digest_compact_kernel_bridge_source(&result.chunk_handoffs);
    kernel_export_relation_digest(export_surface_digest, bridge_source_digest, result.bridge_final_state)
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

fn kernel_public_input_digest(public: &SimpleKernelPublicInput) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_export_public_input");
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_export_public_input/meta",
        &[
            public.program_image.len() as u64,
            public.initial_pc_word as u64,
            public.initial_i as u64,
            public.initial_ram.len() as u64,
            public.transcript_seed.len() as u64,
        ],
    );
    tr.append_message(
        b"neo.fold.next/chip8/kernel_export_public_input/program",
        &public.program_image,
    );
    tr.append_message(
        b"neo.fold.next/chip8/kernel_export_public_input/registers",
        &public.initial_registers,
    );
    tr.append_message(
        b"neo.fold.next/chip8/kernel_export_public_input/ram",
        &public.initial_ram,
    );
    tr.append_message(
        b"neo.fold.next/chip8/kernel_export_public_input/transcript_seed",
        &public.transcript_seed,
    );
    tr.digest32()
}

fn chip8_state_digest(state: &Chip8State) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_export_final_state");
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_export_final_state/meta",
        &[state.pc as u64, state.i as u64, state.memory.len() as u64],
    );
    tr.append_message(b"neo.fold.next/chip8/kernel_export_final_state/registers", &state.v);
    tr.append_message(b"neo.fold.next/chip8/kernel_export_final_state/ram", &state.memory);
    tr.digest32()
}

fn active_bridge_binding_count(
    bridge_bindings: &[Option<super::Chip8PreparedStepBridgeBinding>; super::CHIP8_BRIDGE_ROWS_PER_CHUNK],
) -> Result<usize, SimpleKernelError> {
    let mut saw_empty = false;
    let mut active_len = 0usize;
    for (slot_index, binding_slot) in bridge_bindings.iter().enumerate() {
        match binding_slot {
            Some(_) if saw_empty => {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "compact export bridge binding inactive slot {} must be empty suffix",
                    slot_index
                )));
            }
            Some(_) => active_len += 1,
            None => saw_empty = true,
        }
    }
    Ok(active_len)
}

fn verify_compact_chunk_handoffs(handoffs: &[KernelExportChunkHandoff]) -> Result<[u8; 32], SimpleKernelError> {
    let mut previous_state = super::chip8_bridge_state_seed();
    let mut expected_start_index = 0usize;
    for (chunk_index, handoff) in handoffs.iter().enumerate() {
        if handoff.digest != handoff.expected_digest() {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel export compact chunk handoff {} digest mismatch",
                chunk_index
            )));
        }
        let row_count = active_bridge_binding_count(&handoff.bridge_handoff.step_bindings)?;
        if handoff.public_chunk.start_index != expected_start_index {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel export compact chunk handoff {} start index {} != expected {}",
                chunk_index, handoff.public_chunk.start_index, expected_start_index
            )));
        }
        if handoff.public_chunk.steps.len() != row_count {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel export compact chunk handoff {} public chunk len {} != bridge row count {}",
                chunk_index,
                handoff.public_chunk.steps.len(),
                row_count
            )));
        }
        if handoff.bridge_handoff.previous_state != previous_state {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel export compact chunk handoff {} previous bridge state mismatch",
                chunk_index
            )));
        }
        for slot in 0..row_count {
            let binding = handoff.bridge_handoff.step_bindings[slot]
                .as_ref()
                .expect("active compact export binding slot must be present");
            if binding.digest != binding.expected_digest() {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "kernel export compact chunk handoff {} binding slot {} digest mismatch",
                    chunk_index, slot
                )));
            }
            let expected_row_index = handoff.public_chunk.start_index + slot;
            if binding.row_index != expected_row_index {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "kernel export compact chunk handoff {} binding slot {} row_index {} != expected {}",
                    chunk_index, slot, binding.row_index, expected_row_index
                )));
            }
        }
        let expected_next_state = advance_chip8_bridge_state(
            previous_state,
            chunk_index,
            handoff.public_chunk.start_index,
            row_count,
            handoff.bridge_handoff.witness_digest,
        );
        if handoff.bridge_handoff.next_state != expected_next_state {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "kernel export compact chunk handoff {} next bridge state mismatch",
                chunk_index
            )));
        }
        previous_state = expected_next_state;
        expected_start_index += row_count;
    }
    Ok(previous_state)
}
