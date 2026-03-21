//! Owns the explicit bridge summary from authenticated row-binding claims to canonical prepared steps.

use neo_math::{F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::proof::{PublicStep, StepInput};

use super::opening_refinement::{find_refinement_by_claim_digest, KernelOpeningRefinementSummary};
use super::{find_manifest_claim, CommitmentId, KernelOpeningManifest, RowBindingClaim, SimpleKernelError};

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

pub(crate) fn prepared_step_digest(step: &StepInput) -> [u8; 32] {
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

fn build_bridge_binding_claim(
    manifest: &KernelOpeningManifest,
    refinement_summary: &KernelOpeningRefinementSummary,
    row_binding: &RowBindingClaim,
    prepared_step: &StepInput,
) -> Result<KernelBridgeBindingClaim, SimpleKernelError> {
    let row_binding_point: Vec<K> = row_binding
        .row_bits
        .iter()
        .map(|&bit| if bit { K::ONE } else { K::ZERO })
        .collect();
    let row_binding_ids: Vec<usize> = (1..=23).collect();
    let row_binding_claim_digest = find_manifest_claim(
        manifest,
        CommitmentId::Lane,
        &row_binding_point,
        &row_binding_ids,
        &format!("bridge row binding {}", row_binding.row_index),
    )?
    .digest;
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
