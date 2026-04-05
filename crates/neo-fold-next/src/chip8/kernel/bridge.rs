//! Owns row-binding projection and prepared-step bridge binding for the CHIP-8 kernel.

use neo_math::{KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::WITNESS_WIDTH;
use crate::chip8::stage3::RowBindingClaim;
use crate::proof::{FoldSchedule, PublicStep, StepInput};

use super::artifacts::{
    build_prepared_step_from_row_binding, build_prepared_step_from_semantic_row, build_semantic_row_from_row_binding,
    SimpleKernelRootContext,
};
use super::openings::{find_refinement_by_claim_digest, KernelOpeningClaim, KernelOpeningRefinementSummary};
use super::{
    expect_digest32, expect_equal_k_slice, find_manifest_claim, CommitmentId, KernelOpeningManifest, SimpleKernelError,
};

#[derive(Clone, Debug, PartialEq)]
pub struct KernelRowProjection {
    pub row_index: usize,
    pub row_binding_claim_digest: [u8; 32],
    pub row_binding_refinement_digest: [u8; 32],
    pub semantic_row_digest: [u8; 32],
    pub semantic_view_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelRowProjectionSummary {
    pub projections: Vec<KernelRowProjection>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelBridgeBindingClaim {
    pub row_index: usize,
    pub row_binding_claim_digest: [u8; 32],
    pub row_binding_refinement_digest: [u8; 32],
    pub prepared_step_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelBridgeBindingSummary {
    pub claims: Vec<KernelBridgeBindingClaim>,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct KernelBridgeRowAuth {
    pub row_index: usize,
    pub row_binding_claim_digest: [u8; 32],
    pub row_binding_refinement_digest: [u8; 32],
}

#[derive(Clone, Debug, PartialEq, Eq)]
pub(crate) struct KernelBridgeChunkAuthSource {
    pub chunk_index: usize,
    pub chunk_start_index: usize,
    pub row_count: usize,
    pub row_auths: Vec<KernelBridgeRowAuth>,
}

pub const CHIP8_BRIDGE_ROWS_PER_CHUNK: usize = 2;
pub const CHIP8_BRIDGE_FOLD_SCHEDULE: FoldSchedule = FoldSchedule::RowsPerChunk(CHIP8_BRIDGE_ROWS_PER_CHUNK);

#[derive(Clone, Debug)]
pub struct Chip8BridgeRowWitness {
    pub row_binding: RowBindingClaim,
    pub digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct Chip8BridgeChunkWitness {
    pub row_slots: [Option<Chip8BridgeRowWitness>; CHIP8_BRIDGE_ROWS_PER_CHUNK],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct Chip8BridgeChunkClaim {
    pub previous_state: [u8; 32],
    pub next_state: [u8; 32],
    pub witness_digest: [u8; 32],
    pub digest: [u8; 32],
}

#[derive(Clone, Debug)]
pub struct Chip8BridgeChunkRelationWitness {
    pub previous_state: [u8; 32],
    pub next_state: [u8; 32],
    pub row_slots: [Option<Chip8BridgeRowWitness>; CHIP8_BRIDGE_ROWS_PER_CHUNK],
}

#[derive(Clone, Debug)]
pub struct Chip8BridgeChunkProofBundle {
    pub fold_schedule: FoldSchedule,
    pub chunk_transitions: Vec<Chip8BridgeChunkRelationWitness>,
    pub row_projection_summary_digest: [u8; 32],
    pub bridge_binding_summary_digest: [u8; 32],
    pub final_state: [u8; 32],
    pub digest: [u8; 32],
}

impl Chip8BridgeRowWitness {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_chunk_row");
        tr.append_message(
            b"neo.fold.next/chip8/bridge_chunk_row/row_binding",
            &digest_row_binding_claim(&self.row_binding),
        );
        tr.digest32()
    }
}

impl Chip8BridgeChunkWitness {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_chunk_witness");
        tr.append_u64s(
            b"neo.fold.next/chip8/bridge_chunk_witness/slot_count",
            &[CHIP8_BRIDGE_ROWS_PER_CHUNK as u64],
        );
        for row_slot in &self.row_slots {
            tr.append_u64s(
                b"neo.fold.next/chip8/bridge_chunk_witness/occupied",
                &[row_slot.is_some() as u64],
            );
            if let Some(row) = row_slot {
                tr.append_message(b"neo.fold.next/chip8/bridge_chunk_witness/row", &row.digest);
            }
        }
        tr.digest32()
    }
}

impl Chip8BridgeChunkClaim {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_chunk_claim");
        tr.append_message(
            b"neo.fold.next/chip8/bridge_chunk_claim/previous_state",
            &self.previous_state,
        );
        tr.append_message(b"neo.fold.next/chip8/bridge_chunk_claim/next_state", &self.next_state);
        tr.append_message(
            b"neo.fold.next/chip8/bridge_chunk_claim/witness_digest",
            &self.witness_digest,
        );
        tr.digest32()
    }
}

impl Chip8BridgeChunkRelationWitness {
    pub fn from_native_parts(
        claim: &Chip8BridgeChunkClaim,
        witness: &Chip8BridgeChunkWitness,
    ) -> Result<Self, SimpleKernelError> {
        if witness.digest != witness.expected_digest() {
            return Err(SimpleKernelError::BridgeFailed(
                "CHIP-8 bridge relation witness source has invalid witness digest".into(),
            ));
        }
        if claim.witness_digest != witness.digest {
            return Err(SimpleKernelError::BridgeFailed(
                "CHIP-8 bridge relation witness source has invalid claim/witness binding".into(),
            ));
        }
        if claim.digest != claim.expected_digest() {
            return Err(SimpleKernelError::BridgeFailed(
                "CHIP-8 bridge relation witness source has invalid claim digest".into(),
            ));
        }
        Ok(Self {
            previous_state: claim.previous_state,
            next_state: claim.next_state,
            row_slots: witness.row_slots.clone(),
        })
    }

    pub fn native_witness(&self) -> Chip8BridgeChunkWitness {
        let witness = Chip8BridgeChunkWitness {
            row_slots: self.row_slots.clone(),
            digest: [0; 32],
        };
        Chip8BridgeChunkWitness {
            digest: witness.expected_digest(),
            ..witness
        }
    }

    pub fn native_claim(&self) -> Chip8BridgeChunkClaim {
        let witness = self.native_witness();
        let claim = Chip8BridgeChunkClaim {
            previous_state: self.previous_state,
            next_state: self.next_state,
            witness_digest: witness.digest,
            digest: [0; 32],
        };
        Chip8BridgeChunkClaim {
            digest: claim.expected_digest(),
            ..claim
        }
    }

    pub fn expected_digest(&self) -> [u8; 32] {
        self.native_claim().digest
    }
}

impl Chip8BridgeChunkProofBundle {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_chunk_bundle");
        tr.append_u64s(
            b"neo.fold.next/chip8/bridge_chunk_bundle/schedule",
            &self.fold_schedule.meta_words(),
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/bridge_chunk_bundle/counts",
            &[self.chunk_transitions.len() as u64],
        );
        tr.append_message(
            b"neo.fold.next/chip8/bridge_chunk_bundle/row_projection_summary",
            &self.row_projection_summary_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/bridge_chunk_bundle/bridge_binding_summary",
            &self.bridge_binding_summary_digest,
        );
        for transition in &self.chunk_transitions {
            tr.append_message(
                b"neo.fold.next/chip8/bridge_chunk_bundle/transition",
                &transition.expected_digest(),
            );
        }
        tr.append_message(
            b"neo.fold.next/chip8/bridge_chunk_bundle/final_state",
            &self.final_state,
        );
        tr.digest32()
    }
}

impl KernelRowProjection {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/row_projection");
        tr.append_u64s(b"neo.fold.next/chip8/row_projection/meta", &[self.row_index as u64]);
        tr.append_message(
            b"neo.fold.next/chip8/row_projection/row_binding_claim_digest",
            &self.row_binding_claim_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/row_projection/row_binding_refinement_digest",
            &self.row_binding_refinement_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/row_projection/semantic_row_digest",
            &self.semantic_row_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/row_projection/semantic_view_digest",
            &self.semantic_view_digest,
        );
        tr.digest32()
    }
}

impl KernelRowProjectionSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/row_projection_summary");
        tr.append_u64s(
            b"neo.fold.next/chip8/row_projection_summary/len",
            &[self.projections.len() as u64],
        );
        for projection in &self.projections {
            tr.append_message(
                b"neo.fold.next/chip8/row_projection_summary/projection_digest",
                &projection.digest,
            );
        }
        tr.digest32()
    }
}

impl KernelBridgeBindingClaim {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_binding_claim");
        tr.append_u64s(
            b"neo.fold.next/chip8/bridge_binding_claim/meta",
            &[self.row_index as u64],
        );
        tr.append_message(
            b"neo.fold.next/chip8/bridge_binding_claim/row_digest",
            &self.row_binding_claim_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/bridge_binding_claim/refinement_digest",
            &self.row_binding_refinement_digest,
        );
        tr.append_message(
            b"neo.fold.next/chip8/bridge_binding_claim/step_digest",
            &self.prepared_step_digest,
        );
        tr.digest32()
    }
}

impl KernelBridgeBindingSummary {
    pub fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_binding_summary");
        tr.append_u64s(
            b"neo.fold.next/chip8/bridge_binding_summary/len",
            &[self.claims.len() as u64],
        );
        for claim in &self.claims {
            tr.append_message(
                b"neo.fold.next/chip8/bridge_binding_summary/claim_digest",
                &claim.digest,
            );
        }
        tr.digest32()
    }
}

pub(crate) fn build_kernel_row_projection_summary(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
    semantic_rows: &[[F; WITNESS_WIDTH]],
) -> Result<KernelRowProjectionSummary, SimpleKernelError> {
    if row_bindings.len() != semantic_rows.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row projection row-binding count {} != semantic row count {}",
            row_bindings.len(),
            semantic_rows.len()
        )));
    }

    let projections = row_bindings
        .iter()
        .zip(semantic_rows.iter())
        .enumerate()
        .map(|(expected_index, (row_binding, semantic_row))| {
            build_row_projection(manifest, refinement_summary, row_binding, semantic_row, expected_index)
        })
        .collect::<Result<Vec<_>, _>>()?;
    let summary = KernelRowProjectionSummary {
        projections,
        digest: [0; 32],
    };
    Ok(KernelRowProjectionSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

pub(crate) fn verify_kernel_row_projection_summary(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
    semantic_rows: &[[F; WITNESS_WIDTH]],
    summary: &KernelRowProjectionSummary,
) -> Result<(), SimpleKernelError> {
    let expected = build_kernel_row_projection_summary(manifest, refinement_summary, row_bindings, semantic_rows)?;
    if summary.projections != expected.projections {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel row projection summary mismatch".into(),
        ));
    }
    if summary.digest != summary.expected_digest() {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel row projection summary digest mismatch".into(),
        ));
    }
    Ok(())
}

pub(crate) fn build_kernel_bridge_binding_summary(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
    prepared_steps: &[StepInput],
) -> Result<KernelBridgeBindingSummary, SimpleKernelError> {
    if row_bindings.len() != prepared_steps.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge binding row count {} != prepared step count {}",
            row_bindings.len(),
            prepared_steps.len()
        )));
    }
    let claims = row_bindings
        .iter()
        .zip(prepared_steps.iter())
        .map(|(row_binding, prepared_step)| {
            build_bridge_binding_claim(manifest, refinement_summary, row_binding, prepared_step)
        })
        .collect::<Result<Vec<_>, _>>()?;
    let summary = KernelBridgeBindingSummary {
        claims,
        digest: [0; 32],
    };
    Ok(KernelBridgeBindingSummary {
        digest: summary.expected_digest(),
        ..summary
    })
}

pub(crate) fn verify_kernel_bridge_binding_summary(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
    prepared_steps: &[StepInput],
    summary: &KernelBridgeBindingSummary,
) -> Result<(), SimpleKernelError> {
    let expected = build_kernel_bridge_binding_summary(manifest, refinement_summary, row_bindings, prepared_steps)?;
    if summary.claims != expected.claims {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel bridge binding summary mismatch".into(),
        ));
    }
    if summary.digest != summary.expected_digest() {
        return Err(SimpleKernelError::BridgeFailed(
            "kernel bridge binding summary digest mismatch".into(),
        ));
    }
    Ok(())
}

pub fn build_chip8_bridge_chunk_proof_bundle(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
) -> Result<Chip8BridgeChunkProofBundle, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    let rows_per_chunk = match CHIP8_BRIDGE_FOLD_SCHEDULE {
        FoldSchedule::WholeTrace => row_bindings.len().max(1),
        FoldSchedule::RowsPerChunk(rows) => rows,
    };
    let mut chunk_transitions = Vec::new();
    let mut projections = Vec::with_capacity(row_bindings.len());
    let mut bridge_bindings = Vec::with_capacity(row_bindings.len());
    let mut previous_state = bridge_state_seed();

    for (chunk_index, row_binding_chunk) in row_bindings.chunks(rows_per_chunk).enumerate() {
        let chunk_start_index = row_binding_chunk
            .first()
            .map(|row_binding| row_binding.row_index)
            .unwrap_or(0);
        let rows = row_binding_chunk
            .iter()
            .enumerate()
            .map(|(chunk_local_index, row_binding)| {
                let expected_row_index = chunk_start_index + chunk_local_index;
                let (row, projection, binding) = build_bridge_row_witness(
                    manifest,
                    refinement_summary,
                    &root_context,
                    row_binding,
                    expected_row_index,
                )?;
                projections.push(projection);
                bridge_bindings.push(binding);
                Ok(row)
            })
            .collect::<Result<Vec<_>, SimpleKernelError>>()?;
        let witness = Chip8BridgeChunkWitness {
            row_slots: bridge_chunk_row_slots(rows)?,
            digest: [0; 32],
        };
        let witness = Chip8BridgeChunkWitness {
            digest: witness.expected_digest(),
            ..witness
        };
        let row_count = bridge_chunk_witness_active_len(&witness)?;
        let next_state = advance_bridge_state(
            previous_state,
            chunk_index,
            chunk_start_index,
            row_count,
            witness.digest,
        );
        let claim = Chip8BridgeChunkClaim {
            previous_state,
            next_state,
            witness_digest: witness.digest,
            digest: [0; 32],
        };
        let claim = Chip8BridgeChunkClaim {
            digest: claim.expected_digest(),
            ..claim
        };
        previous_state = claim.next_state;
        chunk_transitions.push(Chip8BridgeChunkRelationWitness::from_native_parts(&claim, &witness)?);
    }

    let row_projection_summary = KernelRowProjectionSummary {
        projections,
        digest: [0; 32],
    };
    let row_projection_summary = KernelRowProjectionSummary {
        digest: row_projection_summary.expected_digest(),
        ..row_projection_summary
    };
    let bridge_binding_summary = KernelBridgeBindingSummary {
        claims: bridge_bindings,
        digest: [0; 32],
    };
    let bridge_binding_summary = KernelBridgeBindingSummary {
        digest: bridge_binding_summary.expected_digest(),
        ..bridge_binding_summary
    };

    let bundle = Chip8BridgeChunkProofBundle {
        fold_schedule: CHIP8_BRIDGE_FOLD_SCHEDULE,
        chunk_transitions,
        row_projection_summary_digest: row_projection_summary.digest,
        bridge_binding_summary_digest: bridge_binding_summary.digest,
        final_state: previous_state,
        digest: [0; 32],
    };
    Ok(Chip8BridgeChunkProofBundle {
        digest: bundle.expected_digest(),
        ..bundle
    })
}

pub fn verify_chip8_bridge_chunk_proof_bundle(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
    bundle: &Chip8BridgeChunkProofBundle,
) -> Result<(), SimpleKernelError> {
    if bundle.fold_schedule != CHIP8_BRIDGE_FOLD_SCHEDULE {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge chunk proof bundle schedule mismatch".into(),
        ));
    }
    let rows_per_chunk = match CHIP8_BRIDGE_FOLD_SCHEDULE {
        FoldSchedule::WholeTrace => row_bindings.len().max(1),
        FoldSchedule::RowsPerChunk(rows) => rows,
    };
    let root_context = SimpleKernelRootContext::new()?;
    let mut previous_state = bridge_state_seed();
    let mut next_row_index = 0usize;
    let mut projections = Vec::with_capacity(row_bindings.len());
    let mut bridge_bindings = Vec::with_capacity(row_bindings.len());

    for (chunk_index, transition) in bundle.chunk_transitions.iter().enumerate() {
        let claim = transition.native_claim();
        let witness = transition.native_witness();
        let row_count = bridge_chunk_witness_active_len(&witness)?;
        if row_count == 0 {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {chunk_index} must contain at least one row"
            )));
        }
        if row_count > rows_per_chunk {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {chunk_index} has {} rows, exceeds schedule bound {rows_per_chunk}",
                row_count
            )));
        }
        if claim.previous_state != previous_state {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {chunk_index} previous state mismatch"
            )));
        }
        if witness.digest != witness.expected_digest() {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {chunk_index} witness digest mismatch"
            )));
        }
        if claim.witness_digest != witness.digest {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {chunk_index} witness digest binding mismatch"
            )));
        }
        let chunk_start_index = next_row_index;
        for chunk_local_index in 0..row_count {
            let row = witness.row_slots[chunk_local_index]
                .as_ref()
                .ok_or_else(|| {
                    SimpleKernelError::BridgeFailed(format!(
                        "bridge chunk {chunk_index} active row slot {chunk_local_index} missing"
                    ))
                })?;
            let row_binding = row_bindings.get(next_row_index).ok_or_else(|| {
                SimpleKernelError::BridgeFailed(format!(
                    "bridge chunk bundle has more witness rows than stage3 row bindings: extra row {}",
                    row.row_binding.row_index
                ))
            })?;
            if &row.row_binding != row_binding {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "bridge chunk bundle row {} does not match exported stage3 row binding",
                    row.row_binding.row_index
                )));
            }
            let row_auth = build_kernel_bridge_row_auth(manifest, refinement_summary, row_binding, next_row_index)?;
            let (projection, binding, _prepared_step) =
                verify_bridge_row_witness(&root_context, &row_auth, row, next_row_index)?;
            projections.push(projection);
            bridge_bindings.push(binding);
            next_row_index += 1;
        }
        let expected_next_state = advance_bridge_state(
            previous_state,
            chunk_index,
            chunk_start_index,
            row_count,
            witness.digest,
        );
        if claim.next_state != expected_next_state {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {chunk_index} next state mismatch"
            )));
        }
        if claim.digest != claim.expected_digest() {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "bridge chunk {chunk_index} claim digest mismatch"
            )));
        }
        previous_state = expected_next_state;
    }

    if next_row_index != row_bindings.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge chunk bundle covers {} rows, expected {}",
            next_row_index,
            row_bindings.len()
        )));
    }

    let row_projection_summary = KernelRowProjectionSummary {
        projections,
        digest: [0; 32],
    };
    let row_projection_summary = KernelRowProjectionSummary {
        digest: row_projection_summary.expected_digest(),
        ..row_projection_summary
    };
    if bundle.row_projection_summary_digest != row_projection_summary.digest {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge chunk row projection summary digest mismatch".into(),
        ));
    }
    let bridge_binding_summary = KernelBridgeBindingSummary {
        claims: bridge_bindings,
        digest: [0; 32],
    };
    let bridge_binding_summary = KernelBridgeBindingSummary {
        digest: bridge_binding_summary.expected_digest(),
        ..bridge_binding_summary
    };
    if bundle.bridge_binding_summary_digest != bridge_binding_summary.digest {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge chunk bridge binding summary digest mismatch".into(),
        ));
    }
    if bundle.final_state != previous_state {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge chunk final state mismatch".into(),
        ));
    }
    if bundle.digest != bundle.expected_digest() {
        return Err(SimpleKernelError::BridgeFailed(
            "bridge chunk proof bundle digest mismatch".into(),
        ));
    }
    Ok(())
}

pub fn chip8_bridge_state_seed() -> [u8; 32] {
    bridge_state_seed()
}

pub(crate) fn advance_chip8_bridge_state(
    previous_state: [u8; 32],
    chunk_index: usize,
    chunk_start_index: usize,
    row_count: usize,
    witness_digest: [u8; 32],
) -> [u8; 32] {
    advance_bridge_state(
        previous_state,
        chunk_index,
        chunk_start_index,
        row_count,
        witness_digest,
    )
}

fn build_bridge_row_witness(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    root_context: &SimpleKernelRootContext,
    row_binding: &RowBindingClaim,
    expected_row_index: usize,
) -> Result<(Chip8BridgeRowWitness, KernelRowProjection, KernelBridgeBindingClaim), SimpleKernelError> {
    let row_auth = build_kernel_bridge_row_auth(manifest, refinement_summary, row_binding, expected_row_index)?;
    build_bridge_row_witness_with_auth(root_context, &row_auth, row_binding, expected_row_index)
}

fn build_bridge_row_witness_with_auth(
    root_context: &SimpleKernelRootContext,
    row_auth: &KernelBridgeRowAuth,
    row_binding: &RowBindingClaim,
    _expected_row_index: usize,
) -> Result<(Chip8BridgeRowWitness, KernelRowProjection, KernelBridgeBindingClaim), SimpleKernelError> {
    let (_expected_semantic_row, _expected_prepared_step, projection, binding) =
        derive_bridge_row_material_with_auth(root_context, row_auth, row_binding)?;
    let row = Chip8BridgeRowWitness {
        row_binding: row_binding.clone(),
        digest: [0; 32],
    };
    let row = Chip8BridgeRowWitness {
        digest: row.expected_digest(),
        ..row
    };
    Ok((row, projection, binding))
}

pub(crate) fn build_chip8_bridge_final_state_from_auths(
    row_auths: &[KernelBridgeRowAuth],
    row_bindings: &[RowBindingClaim],
) -> Result<[u8; 32], SimpleKernelError> {
    if row_auths.len() != row_bindings.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge auth row count {} != row-binding count {}",
            row_auths.len(),
            row_bindings.len()
        )));
    }

    let root_context = SimpleKernelRootContext::new()?;
    let rows_per_chunk = match CHIP8_BRIDGE_FOLD_SCHEDULE {
        FoldSchedule::WholeTrace => row_auths.len().max(1),
        FoldSchedule::RowsPerChunk(rows) => rows,
    };
    let mut previous_state = bridge_state_seed();

    for (chunk_index, (row_auth_chunk, row_binding_chunk)) in row_auths
        .chunks(rows_per_chunk)
        .zip(row_bindings.chunks(rows_per_chunk))
        .enumerate()
    {
        let chunk_start_index = row_binding_chunk
            .first()
            .map(|row_binding| row_binding.row_index)
            .unwrap_or(0);
        let rows = row_auth_chunk
            .iter()
            .zip(row_binding_chunk.iter())
            .enumerate()
            .map(|(_chunk_local_index, (row_auth, row_binding))| {
                let (_semantic_row, _prepared_step, _projection, _binding) =
                    derive_bridge_row_material_with_auth(&root_context, row_auth, row_binding)?;
                let row = Chip8BridgeRowWitness {
                    row_binding: row_binding.clone(),
                    digest: [0; 32],
                };
                Ok(Chip8BridgeRowWitness {
                    digest: row.expected_digest(),
                    ..row
                })
            })
            .collect::<Result<Vec<_>, SimpleKernelError>>()?;
        let witness = Chip8BridgeChunkWitness {
            row_slots: bridge_chunk_row_slots(rows)?,
            digest: [0; 32],
        };
        let witness = Chip8BridgeChunkWitness {
            digest: witness.expected_digest(),
            ..witness
        };
        let row_count = bridge_chunk_witness_active_len(&witness)?;
        previous_state = advance_bridge_state(
            previous_state,
            chunk_index,
            chunk_start_index,
            row_count,
            witness.digest,
        );
    }

    Ok(previous_state)
}

fn verify_bridge_row_witness(
    root_context: &SimpleKernelRootContext,
    row_auth: &KernelBridgeRowAuth,
    row: &Chip8BridgeRowWitness,
    expected_row_index: usize,
) -> Result<(KernelRowProjection, KernelBridgeBindingClaim, StepInput), SimpleKernelError> {
    if row.row_binding.row_index != expected_row_index {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge row witness index {} != expected {}",
            row.row_binding.row_index, expected_row_index
        )));
    }
    let (_semantic_row, prepared_step, projection, binding) =
        derive_bridge_row_material_with_auth(root_context, row_auth, &row.row_binding)?;
    if row.digest != row.expected_digest() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge row {} digest mismatch",
            row.row_binding.row_index
        )));
    }
    Ok((projection, binding, prepared_step))
}

fn bridge_chunk_row_slots(
    rows: Vec<Chip8BridgeRowWitness>,
) -> Result<[Option<Chip8BridgeRowWitness>; CHIP8_BRIDGE_ROWS_PER_CHUNK], SimpleKernelError> {
    if rows.len() > CHIP8_BRIDGE_ROWS_PER_CHUNK {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge chunk row count {} exceeds fixed slot bound {}",
            rows.len(),
            CHIP8_BRIDGE_ROWS_PER_CHUNK
        )));
    }
    let mut rows_iter = rows.into_iter();
    Ok(std::array::from_fn(|slot| {
        if slot < CHIP8_BRIDGE_ROWS_PER_CHUNK {
            rows_iter.next()
        } else {
            None
        }
    }))
}

fn bridge_chunk_witness_active_len(witness: &Chip8BridgeChunkWitness) -> Result<usize, SimpleKernelError> {
    let mut saw_empty = false;
    let mut active_len = 0usize;
    for (slot_index, row_slot) in witness.row_slots.iter().enumerate() {
        match row_slot {
            Some(_) if saw_empty => {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "bridge chunk inactive slot {} must be empty suffix",
                    slot_index
                )));
            }
            Some(_) => active_len += 1,
            None => saw_empty = true,
        }
    }
    Ok(active_len)
}

fn derive_bridge_row_material_with_auth(
    root_context: &SimpleKernelRootContext,
    row_auth: &KernelBridgeRowAuth,
    row_binding: &RowBindingClaim,
) -> Result<
    (
        [F; WITNESS_WIDTH],
        StepInput,
        KernelRowProjection,
        KernelBridgeBindingClaim,
    ),
    SimpleKernelError,
> {
    let expected_row_index = row_auth.row_index;
    if row_binding.row_index != expected_row_index {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge row {expected_row_index} row_binding.row_index {} mismatch",
            row_binding.row_index
        )));
    }
    let semantic_row = build_semantic_row_from_row_binding(row_binding, row_binding.row_bits.len())?;
    if semantic_row[0] != F::ONE {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge row {expected_row_index} semantic row must have ONE = 1"
        )));
    }
    if row_binding.opened_values.len() != WITNESS_WIDTH - 1 {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge row {expected_row_index} opened_values len {} != expected {}",
            row_binding.opened_values.len(),
            WITNESS_WIDTH - 1
        )));
    }
    for (col, (&opened, &expected_value)) in row_binding
        .opened_values
        .iter()
        .zip(semantic_row.iter().skip(1))
        .enumerate()
    {
        expect_equal_k_slice(
            &[opened],
            &[K::from(expected_value)],
            &format!("bridge row {expected_row_index} column {}", col + 1),
        )?;
    }
    let recomputed_claim_digest = expected_row_binding_claim_digest(row_binding);
    expect_digest32(
        row_auth.row_binding_claim_digest,
        recomputed_claim_digest,
        &format!("bridge row {expected_row_index} claim digest"),
    )?;
    let projection = kernel_row_projection_from_auth(
        expected_row_index,
        recomputed_claim_digest,
        row_auth.row_binding_refinement_digest,
        &semantic_row,
    );
    let prepared_step = build_prepared_step_from_semantic_row(root_context, expected_row_index, &semantic_row)?;
    let binding = kernel_bridge_binding_claim_from_auth(
        row_binding,
        &prepared_step,
        recomputed_claim_digest,
        row_auth.row_binding_refinement_digest,
    );
    Ok((semantic_row, prepared_step, projection, binding))
}

fn kernel_row_projection_from_auth(
    row_index: usize,
    row_binding_claim_digest: [u8; 32],
    row_binding_refinement_digest: [u8; 32],
    semantic_row: &[F; WITNESS_WIDTH],
) -> KernelRowProjection {
    let projection = KernelRowProjection {
        row_index,
        row_binding_claim_digest,
        row_binding_refinement_digest,
        semantic_row_digest: semantic_row_digest(semantic_row),
        semantic_view_digest: semantic_view_digest(semantic_row),
        digest: [0; 32],
    };
    KernelRowProjection {
        digest: projection.expected_digest(),
        ..projection
    }
}

fn kernel_bridge_binding_claim_from_auth(
    row_binding: &RowBindingClaim,
    prepared_step: &StepInput,
    row_binding_claim_digest: [u8; 32],
    row_binding_refinement_digest: [u8; 32],
) -> KernelBridgeBindingClaim {
    let claim = KernelBridgeBindingClaim {
        row_index: row_binding.row_index,
        row_binding_claim_digest,
        row_binding_refinement_digest,
        prepared_step_digest: prepared_step_digest(prepared_step),
        digest: [0; 32],
    };
    KernelBridgeBindingClaim {
        digest: claim.expected_digest(),
        ..claim
    }
}

fn build_kernel_bridge_row_auth(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_binding: &RowBindingClaim,
    expected_row_index: usize,
) -> Result<KernelBridgeRowAuth, SimpleKernelError> {
    if row_binding.row_index != expected_row_index {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "bridge row auth expected row_index {}, found {}",
            expected_row_index, row_binding.row_index
        )));
    }
    let manifest_claim_digest = row_binding_claim_digest(
        manifest,
        row_binding,
        &format!("bridge row auth {}", row_binding.row_index),
    )?;
    let recomputed_claim_digest = expected_row_binding_claim_digest(row_binding);
    expect_digest32(
        manifest_claim_digest,
        recomputed_claim_digest,
        &format!("bridge row auth {} claim digest", row_binding.row_index),
    )?;
    let row_binding_refinement_digest = find_refinement_by_claim_digest(
        refinement_summary,
        manifest_claim_digest,
        &format!("bridge row auth {}", row_binding.row_index),
    )?
    .digest;
    Ok(KernelBridgeRowAuth {
        row_index: row_binding.row_index,
        row_binding_claim_digest: manifest_claim_digest,
        row_binding_refinement_digest,
    })
}

pub(crate) fn build_kernel_bridge_row_auths(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
) -> Result<Vec<KernelBridgeRowAuth>, SimpleKernelError> {
    row_bindings
        .iter()
        .enumerate()
        .map(|(expected_row_index, row_binding)| {
            build_kernel_bridge_row_auth(manifest, refinement_summary, row_binding, expected_row_index)
        })
        .collect()
}

pub(crate) fn build_kernel_bridge_chunk_auth_sources(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_bindings: &[RowBindingClaim],
) -> Result<Vec<KernelBridgeChunkAuthSource>, SimpleKernelError> {
    let row_auths = build_kernel_bridge_row_auths(manifest, refinement_summary, row_bindings)?;
    let rows_per_chunk = match CHIP8_BRIDGE_FOLD_SCHEDULE {
        FoldSchedule::WholeTrace => row_bindings.len().max(1),
        FoldSchedule::RowsPerChunk(rows) => rows,
    };
    row_auths
        .chunks(rows_per_chunk)
        .zip(row_bindings.chunks(rows_per_chunk))
        .enumerate()
        .map(|(chunk_index, (row_auth_chunk, row_binding_chunk))| {
            let chunk_start_index = row_binding_chunk
                .first()
                .map(|row_binding| row_binding.row_index)
                .unwrap_or(0);
            Ok(KernelBridgeChunkAuthSource {
                chunk_index,
                chunk_start_index,
                row_count: row_auth_chunk.len(),
                row_auths: row_auth_chunk.to_vec(),
            })
        })
        .collect()
}

pub(crate) fn expected_row_binding_claim_digest(row_binding: &RowBindingClaim) -> [u8; 32] {
    KernelOpeningClaim::kernel(
        CommitmentId::Lane,
        row_binding
            .row_bits
            .iter()
            .map(|&bit| if bit { K::ONE } else { K::ZERO })
            .collect(),
        (1..WITNESS_WIDTH).collect(),
        row_binding.opened_values.clone(),
    )
    .digest
}

fn digest_row_binding_claim(claim: &RowBindingClaim) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_chunk_row_binding");
    tr.append_u64s(
        b"neo.fold.next/chip8/bridge_chunk_row_binding/meta",
        &[
            claim.row_index as u64,
            claim.row_bits.len() as u64,
            claim.opened_values.len() as u64,
        ],
    );
    let row_bits: Vec<u64> = claim.row_bits.iter().map(|&bit| bit as u64).collect();
    tr.append_u64s(b"neo.fold.next/chip8/bridge_chunk_row_binding/row_bits", &row_bits);
    let coeffs_per_elem = claim
        .opened_values
        .first()
        .map(|value| value.as_coeffs().len())
        .unwrap_or(0);
    tr.append_fields_iter(
        b"neo.fold.next/chip8/bridge_chunk_row_binding/opened",
        claim.opened_values.len().saturating_mul(coeffs_per_elem),
        claim
            .opened_values
            .iter()
            .flat_map(|value| value.as_coeffs()),
    );
    tr.digest32()
}

pub fn prepared_step_digest(step: &StepInput) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/prepared_step");
    append_public_step(&mut tr, &step.instance());
    append_f_vec(&mut tr, b"neo.fold.next/chip8/prepared_step/witness_w", &step.witness.w);
    append_matrix(
        &mut tr,
        b"neo.fold.next/chip8/prepared_step/witness_Z",
        &step.witness.Z.as_slice(),
        step.witness.Z.rows(),
        step.witness.Z.cols(),
    );
    tr.digest32()
}

pub(crate) fn recover_prepared_steps_from_row_bindings(
    manifest: &KernelOpeningManifest,
    row_bindings: &[RowBindingClaim],
    root_context: &SimpleKernelRootContext,
    cycle_bits: usize,
) -> Result<Vec<StepInput>, SimpleKernelError> {
    let row_binding_ids: Vec<usize> = (1..WITNESS_WIDTH).collect();
    row_bindings
        .iter()
        .map(|row_binding| {
            let claim = find_manifest_claim(
                manifest,
                CommitmentId::Lane,
                &row_binding_point(row_binding),
                &row_binding_ids,
                &format!("stage3 row-binding opening {}", row_binding.row_index),
            )?;
            expect_equal_k_slice(
                &claim.claimed_values,
                &row_binding.opened_values,
                &format!("stage3 row-binding values {}", row_binding.row_index),
            )?;
            build_prepared_step_from_row_binding(root_context, row_binding, cycle_bits)
        })
        .collect()
}

pub(crate) fn recover_row_bindings_from_bridge_chunk_transitions(
    transitions: &[Chip8BridgeChunkRelationWitness],
) -> Result<Vec<RowBindingClaim>, SimpleKernelError> {
    let mut previous_state = bridge_state_seed();
    let mut next_row_index = 0usize;
    let mut row_bindings = Vec::new();

    for (chunk_index, transition) in transitions.iter().enumerate() {
        if transition.previous_state != previous_state {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "relation witness bridge chunk {chunk_index} previous state mismatch"
            )));
        }
        let witness = transition.native_witness();
        let row_count = bridge_chunk_witness_active_len(&witness)?;
        if row_count == 0 {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "relation witness bridge chunk {chunk_index} must contain at least one row"
            )));
        }
        let chunk_start_index = witness
            .row_slots
            .iter()
            .flatten()
            .next()
            .ok_or_else(|| {
                SimpleKernelError::BridgeFailed(format!(
                    "relation witness bridge chunk {chunk_index} missing first row"
                ))
            })?
            .row_binding
            .row_index;
        if chunk_start_index != next_row_index {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "relation witness bridge chunk {chunk_index} starts at row {chunk_start_index}, expected {next_row_index}"
            )));
        }
        for chunk_local_index in 0..row_count {
            let row = witness.row_slots[chunk_local_index]
                .as_ref()
                .ok_or_else(|| {
                    SimpleKernelError::BridgeFailed(format!(
                        "relation witness bridge chunk {chunk_index} active row slot {chunk_local_index} missing"
                    ))
                })?;
            if row.digest != row.expected_digest() {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "relation witness bridge chunk {chunk_index} row slot {chunk_local_index} digest mismatch"
                )));
            }
            let expected_row_index = chunk_start_index + chunk_local_index;
            if row.row_binding.row_index != expected_row_index {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "relation witness bridge chunk {chunk_index} row slot {chunk_local_index} has row_index {}, expected {}",
                    row.row_binding.row_index, expected_row_index
                )));
            }
            row_bindings.push(row.row_binding.clone());
        }
        let expected_next_state = advance_bridge_state(
            previous_state,
            chunk_index,
            chunk_start_index,
            row_count,
            witness.digest,
        );
        if transition.next_state != expected_next_state {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "relation witness bridge chunk {chunk_index} next state mismatch"
            )));
        }
        previous_state = expected_next_state;
        next_row_index += row_count;
    }

    Ok(row_bindings)
}

fn build_row_projection(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_binding: &RowBindingClaim,
    semantic_row: &[F; WITNESS_WIDTH],
    expected_index: usize,
) -> Result<KernelRowProjection, SimpleKernelError> {
    if row_binding.row_index != expected_index {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row projection row {} has row_index {}, expected {expected_index}",
            expected_index, row_binding.row_index
        )));
    }
    if row_binding.opened_values.len() != WITNESS_WIDTH - 1 {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "row projection row {} has {} opened values, expected {}",
            row_binding.row_index,
            row_binding.opened_values.len(),
            WITNESS_WIDTH - 1
        )));
    }
    let semantic_row = canonical_semantic_row(semantic_row);
    for (col, (&opened, &expected_value)) in row_binding
        .opened_values
        .iter()
        .zip(semantic_row.iter().skip(1))
        .enumerate()
    {
        let base = base_value(
            opened,
            &format!("row projection row {} column {}", row_binding.row_index, col + 1),
        )?;
        if base != expected_value {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "row projection row {} column {} mismatch",
                row_binding.row_index,
                col + 1
            )));
        }
    }

    let row_binding_claim_digest = row_binding_claim_digest(
        manifest,
        row_binding,
        &format!("row projection {}", row_binding.row_index),
    )?;
    let row_binding_refinement_digest = find_refinement_by_claim_digest(
        refinement_summary,
        row_binding_claim_digest,
        &format!("row projection {}", row_binding.row_index),
    )?
    .digest;

    let projection = KernelRowProjection {
        row_index: row_binding.row_index,
        row_binding_claim_digest,
        row_binding_refinement_digest,
        semantic_row_digest: semantic_row_digest(&semantic_row),
        semantic_view_digest: semantic_view_digest(&semantic_row),
        digest: [0; 32],
    };
    Ok(KernelRowProjection {
        digest: projection.expected_digest(),
        ..projection
    })
}

fn build_bridge_binding_claim(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_binding: &RowBindingClaim,
    prepared_step: &StepInput,
) -> Result<KernelBridgeBindingClaim, SimpleKernelError> {
    let row_binding_claim_digest = row_binding_claim_digest(
        manifest,
        row_binding,
        &format!("bridge binding {}", row_binding.row_index),
    )?;
    let row_binding_refinement_digest = find_refinement_by_claim_digest(
        refinement_summary,
        row_binding_claim_digest,
        &format!("bridge binding {}", row_binding.row_index),
    )?
    .digest;
    let claim = KernelBridgeBindingClaim {
        row_index: row_binding.row_index,
        row_binding_claim_digest,
        row_binding_refinement_digest,
        prepared_step_digest: prepared_step_digest(prepared_step),
        digest: [0; 32],
    };
    Ok(KernelBridgeBindingClaim {
        digest: claim.expected_digest(),
        ..claim
    })
}

fn row_binding_claim_digest(
    manifest: &KernelOpeningManifest,
    row_binding: &RowBindingClaim,
    label: &str,
) -> Result<[u8; 32], SimpleKernelError> {
    let row_binding_ids: Vec<usize> = (1..WITNESS_WIDTH).collect();
    Ok(find_manifest_claim(
        manifest,
        CommitmentId::Lane,
        &row_binding_point(row_binding),
        &row_binding_ids,
        label,
    )?
    .digest)
}

fn row_binding_point(row_binding: &RowBindingClaim) -> Vec<K> {
    row_binding
        .row_bits
        .iter()
        .map(|&bit| if bit { K::ONE } else { K::ZERO })
        .collect()
}

fn canonical_semantic_row(row: &[F; WITNESS_WIDTH]) -> [F; WITNESS_WIDTH] {
    let mut canonical = *row;
    canonical[0] = F::ONE;
    canonical
}

fn base_value(value: K, label: &str) -> Result<F, SimpleKernelError> {
    let [real, imag] = value.as_coeffs();
    if imag != F::ZERO {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "{label} must be a base-field opening"
        )));
    }
    Ok(real)
}

fn semantic_row_digest(row: &[F; WITNESS_WIDTH]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_row");
    tr.append_fields_iter(
        b"neo.fold.next/chip8/semantic_row/values",
        row.len(),
        row.iter().copied(),
    );
    tr.digest32()
}

fn semantic_view_digest(row: &[F; WITNESS_WIDTH]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/semantic_view");
    tr.append_fields_iter(
        b"neo.fold.next/chip8/semantic_view/values",
        row.len() - 1,
        row.iter().copied().skip(1),
    );
    tr.digest32()
}

fn append_public_step(tr: &mut Poseidon2Transcript, step: &PublicStep) {
    tr.append_u64s(
        b"neo.fold.next/chip8/prepared_step/public_meta",
        &[
            step.mcs.c.d as u64,
            step.mcs.c.kappa as u64,
            step.mcs.c.data.len() as u64,
            step.mcs.x.len() as u64,
            step.mcs.m_in as u64,
        ],
    );
    tr.append_fields_iter(
        b"neo.fold.next/chip8/prepared_step/public_commitment",
        step.mcs.c.data.len(),
        step.mcs.c.data.iter().copied(),
    );
    append_f_vec(tr, b"neo.fold.next/chip8/prepared_step/public_x", &step.mcs.x);
}

fn append_f_vec(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[F]) {
    tr.append_u64s(b"neo.fold.next/chip8/prepared_step/f_len", &[values.len() as u64]);
    tr.append_fields_iter(label, values.len(), values.iter().copied());
}

fn append_matrix(tr: &mut Poseidon2Transcript, label: &'static [u8], values: &[F], rows: usize, cols: usize) {
    tr.append_u64s(
        b"neo.fold.next/chip8/prepared_step/matrix_meta",
        &[rows as u64, cols as u64, values.len() as u64],
    );
    tr.append_fields_iter(label, values.len(), values.iter().copied());
}

fn bridge_state_seed() -> [u8; 32] {
    Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_chunk_state_seed").digest32()
}

fn advance_bridge_state(
    previous_state: [u8; 32],
    chunk_index: usize,
    chunk_start_index: usize,
    row_count: usize,
    witness_digest: [u8; 32],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/bridge_chunk_state");
    tr.append_message(b"neo.fold.next/chip8/bridge_chunk_state/previous", &previous_state);
    tr.append_u64s(
        b"neo.fold.next/chip8/bridge_chunk_state/meta",
        &[chunk_index as u64, chunk_start_index as u64, row_count as u64],
    );
    tr.append_message(b"neo.fold.next/chip8/bridge_chunk_state/witness", &witness_digest);
    tr.digest32()
}
