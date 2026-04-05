//! Owns the CHIP-8 chunk-relation boundary: main-lane replay plus bridge obligation.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsStructure, CeClaim};
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::engines::utils::build_dims_and_policy;
use neo_reductions::optimized_engine::PiCcsReplayProofWitness;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{
    advance_chip8_bridge_state, prepared_step_digest, Chip8BridgeChunkHandoff, Chip8PreparedStepBridgeBinding,
    SimpleKernelError, CHIP8_BRIDGE_ROWS_PER_CHUNK,
};
use crate::chunk_relation::{
    verify_chunk_relation_with_witness, ChunkRelationArtifacts, ChunkReplayWitness, CommitmentMixers,
};
use crate::finalize::fixed_shape_recursive_step_handle;
use crate::proof::{Carry, ChunkInput, PublicChunk, PublicStep};

pub const CHIP8_CCS_ELL_D: usize = 6;
pub const CHIP8_CCS_ELL_N: usize = 5;
pub const CHIP8_CCS_ELL_M: usize = 5;
pub const CHIP8_CCS_SUMCHECK_DEGREE_BOUND: usize = 4;
pub const CHIP8_CCS_ROUND_COEFFS: usize = CHIP8_CCS_SUMCHECK_DEGREE_BOUND + 1;
pub const CHIP8_CCS_FE_ROUNDS: usize = CHIP8_CCS_ELL_N + CHIP8_CCS_ELL_D;
pub const CHIP8_CCS_NC_ROUNDS: usize = CHIP8_CCS_ELL_M + CHIP8_CCS_ELL_D;
pub const CHIP8_CCS_OUTPUT_SLOTS: usize = 18;

#[derive(Clone, Debug)]
pub struct Chip8ReplayRoundWitness {
    pub coeff_len: u8,
    pub coeffs: [K; CHIP8_CCS_ROUND_COEFFS],
}

#[derive(Clone, Debug)]
pub struct Chip8ChunkReplayWitness {
    pub ccs_output_slots: [Option<CeClaim<Commitment, F, K>>; CHIP8_CCS_OUTPUT_SLOTS],
    pub fe_rounds: [Chip8ReplayRoundWitness; CHIP8_CCS_FE_ROUNDS],
    pub nc_rounds: [Chip8ReplayRoundWitness; CHIP8_CCS_NC_ROUNDS],
    pub header_digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub(crate) struct Chip8ChunkRelationArtifacts {
    pub main: ChunkRelationArtifacts,
    pub bridge_chunk_digest: [u8; 32],
    pub boundary_digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub(crate) struct Chip8ChunkRelationResult {
    pub next_main: Carry,
    pub next_bridge_state: [u8; 32],
    pub artifacts: Chip8ChunkRelationArtifacts,
}

impl Chip8ReplayRoundWitness {
    fn from_coeffs(coeffs: &[K], context: &str) -> Result<Self, SimpleKernelError> {
        if coeffs.is_empty() {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "{context}: empty CHIP-8 replay round polynomial"
            )));
        }
        if coeffs.len() > CHIP8_CCS_ROUND_COEFFS {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "{context}: coeff count {} exceeds frozen CHIP-8 bound {}",
                coeffs.len(),
                CHIP8_CCS_ROUND_COEFFS
            )));
        }
        let mut padded = [K::ZERO; CHIP8_CCS_ROUND_COEFFS];
        padded[..coeffs.len()].copy_from_slice(coeffs);
        Ok(Self {
            coeff_len: coeffs.len() as u8,
            coeffs: padded,
        })
    }

    fn to_coeffs(&self, context: &str) -> Result<Vec<K>, SimpleKernelError> {
        let coeff_len = self.coeff_len as usize;
        if coeff_len == 0 || coeff_len > CHIP8_CCS_ROUND_COEFFS {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "{context}: coeff_len {} is outside 1..={}",
                coeff_len, CHIP8_CCS_ROUND_COEFFS
            )));
        }
        Ok(self.coeffs[..coeff_len].to_vec())
    }
}

impl Chip8ChunkReplayWitness {
    pub fn from_chunk_replay_witness(
        params: &NeoParams,
        structure: &CcsStructure<F>,
        witness: ChunkReplayWitness,
    ) -> Result<Self, SimpleKernelError> {
        ensure_chip8_replay_shape(params, structure)?;
        let ccs_replay_proof = witness.ccs_replay_proof;
        if ccs_replay_proof.sumcheck_rounds.len() != CHIP8_CCS_FE_ROUNDS {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "CHIP-8 replay witness FE round count {} != frozen bound {}",
                ccs_replay_proof.sumcheck_rounds.len(),
                CHIP8_CCS_FE_ROUNDS
            )));
        }
        if ccs_replay_proof.sumcheck_rounds_nc.len() != CHIP8_CCS_NC_ROUNDS {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "CHIP-8 replay witness NC round count {} != frozen bound {}",
                ccs_replay_proof.sumcheck_rounds_nc.len(),
                CHIP8_CCS_NC_ROUNDS
            )));
        }

        let fe_rounds = ccs_replay_proof
            .sumcheck_rounds
            .iter()
            .enumerate()
            .map(|(idx, coeffs)| Chip8ReplayRoundWitness::from_coeffs(coeffs, &format!("CHIP-8 FE round {idx}")))
            .collect::<Result<Vec<_>, _>>()?
            .try_into()
            .map_err(|rounds: Vec<_>| {
                SimpleKernelError::BridgeFailed(format!(
                    "CHIP-8 replay witness FE round vec len {} != frozen bound {}",
                    rounds.len(),
                    CHIP8_CCS_FE_ROUNDS
                ))
            })?;
        let nc_rounds = ccs_replay_proof
            .sumcheck_rounds_nc
            .iter()
            .enumerate()
            .map(|(idx, coeffs)| Chip8ReplayRoundWitness::from_coeffs(coeffs, &format!("CHIP-8 NC round {idx}")))
            .collect::<Result<Vec<_>, _>>()?
            .try_into()
            .map_err(|rounds: Vec<_>| {
                SimpleKernelError::BridgeFailed(format!(
                    "CHIP-8 replay witness NC round vec len {} != frozen bound {}",
                    rounds.len(),
                    CHIP8_CCS_NC_ROUNDS
                ))
            })?;
        if witness.ccs_outputs.len() > CHIP8_CCS_OUTPUT_SLOTS {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "CHIP-8 replay witness CCS output count {} exceeds frozen bound {}",
                witness.ccs_outputs.len(),
                CHIP8_CCS_OUTPUT_SLOTS
            )));
        }
        let ccs_output_slots = std::array::from_fn(|slot| witness.ccs_outputs.get(slot).cloned());

        Ok(Self {
            ccs_output_slots,
            fe_rounds,
            nc_rounds,
            header_digest: ccs_replay_proof.header_digest,
        })
    }

    pub fn to_chunk_replay_witness(
        &self,
        params: &NeoParams,
        structure: &CcsStructure<F>,
        active_outputs: usize,
    ) -> Result<ChunkReplayWitness, SimpleKernelError> {
        ensure_chip8_replay_shape(params, structure)?;
        if active_outputs > CHIP8_CCS_OUTPUT_SLOTS {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "CHIP-8 replay witness active output count {} exceeds frozen bound {}",
                active_outputs, CHIP8_CCS_OUTPUT_SLOTS
            )));
        }
        let sumcheck_rounds = self
            .fe_rounds
            .iter()
            .enumerate()
            .map(|(idx, round)| round.to_coeffs(&format!("CHIP-8 FE round {idx}")))
            .collect::<Result<Vec<_>, _>>()?;
        let sumcheck_rounds_nc = self
            .nc_rounds
            .iter()
            .enumerate()
            .map(|(idx, round)| round.to_coeffs(&format!("CHIP-8 NC round {idx}")))
            .collect::<Result<Vec<_>, _>>()?;
        let mut ccs_outputs = Vec::with_capacity(active_outputs);
        for (slot_index, output_slot) in self.ccs_output_slots.iter().enumerate() {
            if slot_index < active_outputs {
                let output = output_slot.clone().ok_or_else(|| {
                    SimpleKernelError::BridgeFailed(format!(
                        "CHIP-8 replay witness active output slot {} missing",
                        slot_index
                    ))
                })?;
                ccs_outputs.push(output);
            } else if output_slot.is_some() {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "CHIP-8 replay witness inactive output slot {} must be empty",
                    slot_index
                )));
            }
        }
        Ok(ChunkReplayWitness {
            ccs_outputs,
            ccs_replay_proof: PiCcsReplayProofWitness {
                sumcheck_rounds,
                sumcheck_rounds_nc,
                header_digest: self.header_digest,
            },
        })
    }
}

fn ensure_chip8_replay_shape(params: &NeoParams, structure: &CcsStructure<F>) -> Result<(), SimpleKernelError> {
    let dims = build_dims_and_policy(params, structure)
        .map_err(|err| SimpleKernelError::BridgeFailed(format!("CHIP-8 replay dims failed: {err}")))?;
    if dims.ell_d != CHIP8_CCS_ELL_D
        || dims.ell_n != CHIP8_CCS_ELL_N
        || dims.ell_m != CHIP8_CCS_ELL_M
        || dims.d_sc != CHIP8_CCS_SUMCHECK_DEGREE_BOUND
    {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "CHIP-8 replay witness shape mismatch: dims=(ell_d={}, ell_n={}, ell_m={}, d_sc={}), frozen=({}, {}, {}, {})",
            dims.ell_d,
            dims.ell_n,
            dims.ell_m,
            dims.d_sc,
            CHIP8_CCS_ELL_D,
            CHIP8_CCS_ELL_N,
            CHIP8_CCS_ELL_M,
            CHIP8_CCS_SUMCHECK_DEGREE_BOUND
        )));
    }
    Ok(())
}

pub(crate) fn public_step_digest(step: &PublicStep) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/public_step_digest");
    tr.append_u64s(
        b"neo.fold.next/chip8/public_step_digest/meta",
        &[
            step.mcs.c.d as u64,
            step.mcs.c.kappa as u64,
            step.mcs.c.data.len() as u64,
            step.mcs.x.len() as u64,
            step.mcs.m_in as u64,
        ],
    );
    tr.append_fields_iter(
        b"neo.fold.next/chip8/public_step_digest/commitment",
        step.mcs.c.data.len(),
        step.mcs.c.data.iter().copied(),
    );
    tr.append_fields_iter(
        b"neo.fold.next/chip8/public_step_digest/x",
        step.mcs.x.len(),
        step.mcs.x.iter().copied(),
    );
    tr.digest32()
}

pub(crate) fn public_chunk_digest(chunk: &PublicChunk) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/public_chunk_digest");
    tr.append_u64s(
        b"neo.fold.next/chip8/public_chunk_digest/meta",
        &[chunk.start_index as u64, chunk.steps.len() as u64],
    );
    for step in &chunk.steps {
        tr.append_message(
            b"neo.fold.next/chip8/public_chunk_digest/step",
            &public_step_digest(step),
        );
    }
    tr.digest32()
}

pub(crate) fn chunk_boundary_digest(chunk: &PublicChunk) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/chunk_boundary_digest");
    tr.append_u64s(
        b"neo.fold.next/chip8/chunk_boundary_digest/meta",
        &[chunk.start_index as u64, chunk.steps.len() as u64],
    );
    if let Some(first) = chunk.steps.first() {
        tr.append_message(
            b"neo.fold.next/chip8/chunk_boundary_digest/first",
            &public_step_digest(first),
        );
    }
    if let Some(last) = chunk.steps.last() {
        tr.append_message(
            b"neo.fold.next/chip8/chunk_boundary_digest/last",
            &public_step_digest(last),
        );
    }
    tr.digest32()
}

pub(crate) fn chip8_chunk_relation_digest(
    public_chunk: &PublicChunk,
    artifacts: &Chip8ChunkRelationArtifacts,
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/chunk_relation_digest");
    tr.append_message(
        b"neo.fold.next/chip8/chunk_relation_digest/public_chunk",
        &public_chunk_digest(public_chunk),
    );
    tr.append_message(
        b"neo.fold.next/chip8/chunk_relation_digest/main",
        &artifacts.main.relation_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/chunk_relation_digest/bridge",
        &artifacts.bridge_chunk_digest,
    );
    tr.append_message(
        b"neo.fold.next/chip8/chunk_relation_digest/boundary",
        &artifacts.boundary_digest,
    );
    tr.digest32()
}

pub(crate) fn step_handle(
    previous_handle: [u8; 32],
    chunk_index: usize,
    chunk_start_index: usize,
    chunk_len: usize,
    chunk_relation_digest: [u8; 32],
) -> [u8; 32] {
    fixed_shape_recursive_step_handle(
        previous_handle,
        chunk_index,
        chunk_start_index,
        chunk_len,
        chunk_relation_digest,
    )
}

pub(crate) fn synthesize_chip8_chunk_relation_artifacts(
    public_chunk: &PublicChunk,
    main: ChunkRelationArtifacts,
    bridge_chunk_digest: [u8; 32],
) -> Chip8ChunkRelationArtifacts {
    Chip8ChunkRelationArtifacts {
        main,
        bridge_chunk_digest,
        boundary_digest: chunk_boundary_digest(public_chunk),
    }
}

pub(crate) fn verify_chip8_chunk_relation_with_witness<L, MR, MB>(
    expected_chunk_index: usize,
    chunk_input: &ChunkInput,
    incoming_main: &Carry,
    main_replay_witness: &Chip8ChunkReplayWitness,
    expected_bridge_handoff: &Chip8BridgeChunkHandoff,
    expected_bridge_bindings: &[Option<Chip8PreparedStepBridgeBinding>; CHIP8_BRIDGE_ROWS_PER_CHUNK],
    previous_bridge_state: [u8; 32],
    transcript: &mut Poseidon2Transcript,
    params: &NeoParams,
    structure: &CcsStructure<F>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
    optimized_cache: &neo_reductions::optimized_engine::OptimizedStructureCache,
) -> Result<Chip8ChunkRelationResult, SimpleKernelError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[neo_ccs::Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let public_chunk = chunk_input.public();
    let next_bridge_state = verify_preverified_bridge_transition(
        expected_chunk_index,
        &public_chunk,
        chunk_input,
        expected_bridge_handoff,
        expected_bridge_bindings,
        previous_bridge_state,
    )?;

    if incoming_main.claims.len() != incoming_main.witnesses.len() {
        return Err(SimpleKernelError::BridgeFailed(
            "incoming carried main witness count does not match carried claims".into(),
        ));
    }
    let active_outputs = chunk_input
        .steps
        .len()
        .checked_add(incoming_main.claims.len())
        .ok_or_else(|| SimpleKernelError::BridgeFailed("CHIP-8 replay witness output count overflow".into()))?;
    let main_replay_witness = main_replay_witness.to_chunk_replay_witness(params, structure, active_outputs)?;
    let main = verify_chunk_relation_with_witness(
        transcript,
        params,
        structure,
        chunk_input,
        incoming_main,
        &main_replay_witness,
        log,
        mixers,
        optimized_cache,
    )
    .map_err(|err| {
        SimpleKernelError::BridgeFailed(format!(
            "recursive main chunk transition {} failed: {err}",
            expected_chunk_index
        ))
    })?;

    Ok(Chip8ChunkRelationResult {
        next_main: main.next_main,
        next_bridge_state,
        artifacts: synthesize_chip8_chunk_relation_artifacts(
            &public_chunk,
            main.artifacts,
            expected_bridge_handoff.witness_digest,
        ),
    })
}

fn verify_preverified_bridge_transition(
    expected_chunk_index: usize,
    public_chunk: &PublicChunk,
    chunk_input: &ChunkInput,
    expected_bridge_handoff: &Chip8BridgeChunkHandoff,
    expected_bridge_bindings: &[Option<Chip8PreparedStepBridgeBinding>; CHIP8_BRIDGE_ROWS_PER_CHUNK],
    previous_bridge_state: [u8; 32],
) -> Result<[u8; 32], SimpleKernelError> {
    let row_count = active_bridge_binding_count(&expected_bridge_handoff.step_bindings)?;

    if row_count == 0 {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge chunk {} must contain at least one row",
            expected_chunk_index
        )));
    }
    if public_chunk.steps.len() != row_count {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge chunk {} public chunk len {} != verified row count {}",
            expected_chunk_index,
            public_chunk.steps.len(),
            row_count
        )));
    }
    if chunk_input.steps.len() != row_count {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge chunk {} main chunk len {} != verified row count {}",
            expected_chunk_index,
            chunk_input.steps.len(),
            row_count
        )));
    }
    if expected_bridge_handoff.previous_state != previous_bridge_state {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge chunk {} previous state mismatch",
            expected_chunk_index
        )));
    }

    for (slot_index, binding_slot) in expected_bridge_bindings.iter().enumerate() {
        if slot_index < row_count {
            if binding_slot.is_none() {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "bridge chunk {} active binding slot {} missing",
                    expected_chunk_index, slot_index
                )));
            }
        } else if binding_slot.is_some() {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {} inactive binding slot {} must be empty",
                expected_chunk_index, slot_index
            )));
        }
    }

    for chunk_local_index in 0..row_count {
        let expected_row_index = public_chunk.start_index + chunk_local_index;
        let binding = expected_bridge_bindings[chunk_local_index]
            .as_ref()
            .expect("active binding slot checked above");
        let authenticated_binding = expected_bridge_handoff.step_bindings[chunk_local_index]
            .as_ref()
            .expect("active authenticated binding slot checked by active_bridge_binding_count");
        if binding != authenticated_binding {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {} binding slot {} does not match the authenticated export handoff",
                expected_chunk_index, chunk_local_index
            )));
        }
        if binding.row_index != expected_row_index {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {} binding slot {} row_index {} != expected {}",
                expected_chunk_index, chunk_local_index, binding.row_index, expected_row_index
            )));
        }
        if binding.digest != binding.expected_digest() {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {} binding slot {} digest mismatch",
                expected_chunk_index, chunk_local_index
            )));
        }
        let expected_prepared_step_digest = prepared_step_digest(&chunk_input.steps[chunk_local_index]);
        if binding.prepared_step_digest != expected_prepared_step_digest {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {} binding slot {} prepared-step digest mismatch",
                expected_chunk_index, chunk_local_index
            )));
        }
    }

    let expected_next_state = advance_chip8_bridge_state(
        previous_bridge_state,
        expected_chunk_index,
        public_chunk.start_index,
        row_count,
        expected_bridge_handoff.witness_digest,
    );
    if expected_bridge_handoff.next_state != expected_next_state {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge chunk {} next state mismatch",
            expected_chunk_index
        )));
    }
    Ok(expected_next_state)
}

fn active_bridge_binding_count(
    bridge_bindings: &[Option<Chip8PreparedStepBridgeBinding>; CHIP8_BRIDGE_ROWS_PER_CHUNK],
) -> Result<usize, SimpleKernelError> {
    let mut saw_empty = false;
    let mut active_len = 0usize;
    for (slot_index, binding_slot) in bridge_bindings.iter().enumerate() {
        match binding_slot {
            Some(_) if saw_empty => {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "bridge binding inactive slot {} must be empty suffix",
                    slot_index
                )));
            }
            Some(_) => active_len += 1,
            None => saw_empty = true,
        }
    }
    Ok(active_len)
}
