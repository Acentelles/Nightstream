//! Owns row-binding projection and prepared-step bridge binding for the CHIP-8 kernel.

use neo_math::{KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::WITNESS_WIDTH;
use crate::chip8::stage3::RowBindingClaim;
use crate::proof::{PublicStep, StepInput};

use super::artifacts::{build_prepared_step_from_row_binding, SimpleKernelRootContext};
use super::openings::{find_refinement_by_claim_digest, KernelOpeningRefinementSummary};
use super::{expect_equal_k_slice, find_manifest_claim, CommitmentId, KernelOpeningManifest, SimpleKernelError};

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
