//! Owns the authenticated row-local projection summary used by semantic extraction.

use neo_math::{KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::WITNESS_WIDTH;

use super::opening_refinement::{find_refinement_by_claim_digest, KernelOpeningRefinementSummary};
use super::{find_manifest_claim, CommitmentId, KernelOpeningManifest, RowBindingClaim, SimpleKernelError};

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

    let row_point: Vec<K> = row_binding
        .row_bits
        .iter()
        .map(|&bit| if bit { K::ONE } else { K::ZERO })
        .collect();
    let row_binding_ids: Vec<usize> = (1..WITNESS_WIDTH).collect();
    let row_binding_claim_digest = find_manifest_claim(
        manifest,
        CommitmentId::Lane,
        &row_point,
        &row_binding_ids,
        &format!("row projection {}", row_binding.row_index),
    )?
    .digest;
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
