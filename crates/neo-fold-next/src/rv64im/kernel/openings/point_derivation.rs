//! Owns the frozen Phase 0 real-point derivation helpers for RV64IM eval claims.
//!
//! It owns:
//! - the canonical Phase 0 point-seed formula
//! - deterministic Fiat-Shamir point sampling from that seed
//!
//! It does not own:
//! - claim emission from stage artifacts
//! - synthetic selected-opening `logical_index` points
//! - Phase 1 reduction or Phase 2 accumulation

use neo_math::{from_complex, K};
use neo_transcript::{Poseidon2Transcript, Transcript};

use super::opening_eval_claims::{CommitmentContextId, FamilyEvalSchemaId, OpenedAjtaiObjectId};

fn squeeze_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let real = tr.challenge_field(label);
    let imag = tr.challenge_field(label);
    from_complex(real, imag)
}

pub fn phase0_point_seed(
    opened_object: &OpenedAjtaiObjectId,
    commitment_context: &CommitmentContextId,
    schema: FamilyEvalSchemaId,
    slot: u32,
    binding_digest: [u8; 32],
) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/opening_convergence/phase0/point_seed");
    tr.append_message(
        b"neo.fold.next/rv64im/opening_convergence/phase0/point_seed/opened_object_digest",
        &opened_object.digest,
    );
    tr.append_message(
        b"neo.fold.next/rv64im/opening_convergence/phase0/point_seed/pp_seed_digest",
        &commitment_context.pp_seed_digest,
    );
    tr.append_message(
        b"neo.fold.next/rv64im/opening_convergence/phase0/point_seed/module_shape_digest",
        &commitment_context.module_shape_digest,
    );
    tr.append_u64s(
        b"neo.fold.next/rv64im/opening_convergence/phase0/point_seed/meta",
        &[schema.tag(), slot as u64],
    );
    tr.append_message(
        b"neo.fold.next/rv64im/opening_convergence/phase0/point_seed/binding_digest",
        &binding_digest,
    );
    tr.digest32()
}

pub fn derive_phase0_point_from_seed(seed: [u8; 32], row_domain_log_size: usize) -> Vec<K> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/opening_convergence/phase0/point");
    tr.append_message(b"neo.fold.next/rv64im/opening_convergence/phase0/point/seed", &seed);
    (0..row_domain_log_size)
        .map(|coord_index| {
            tr.append_u64s(
                b"neo.fold.next/rv64im/opening_convergence/phase0/point_coord_index",
                &[coord_index as u64],
            );
            squeeze_k(&mut tr, b"neo.fold.next/rv64im/opening_convergence/phase0/point_coord")
        })
        .collect()
}

pub fn derive_phase0_point(
    opened_object: &OpenedAjtaiObjectId,
    commitment_context: &CommitmentContextId,
    schema: FamilyEvalSchemaId,
    slot: u32,
    binding_digest: [u8; 32],
) -> Vec<K> {
    let seed = phase0_point_seed(opened_object, commitment_context, schema, slot, binding_digest);
    derive_phase0_point_from_seed(seed, opened_object.row_domain_log_size as usize)
}
