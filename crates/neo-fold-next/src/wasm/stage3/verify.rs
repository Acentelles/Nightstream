//! Owns verifier-side replay for the first WASM Stage 3 slice: boundary continuity.

use neo_math::{from_complex, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::proof::{Stage3BoundaryProof, Stage3BoundarySummary};
use super::prove::batched_boundary_claim;
use super::transcript::append_stage3_rows;

pub fn verify_stage3_boundaries<Tr: Transcript>(
    summary: &Stage3BoundarySummary,
    proof: &Stage3BoundaryProof,
    transcript: &mut Tr,
) -> Result<(), String> {
    if proof.rows != summary.rows {
        return Err("wasm stage3 boundary row binding mismatch".into());
    }
    append_stage3_rows(transcript, &proof.rows);
    let alpha = sample_k(transcript, b"wasm/stage3/boundaries/mix");
    let expected_claim = batched_boundary_claim(&proof.rows, alpha)?;
    if proof.continuity_batched_claim != expected_claim {
        return Err("wasm stage3 continuity batched claim mismatch".into());
    }
    if proof.continuity_batched_claim != K::ZERO {
        return Err("wasm stage3 boundary continuity batch failed".into());
    }
    let expected_start = proof.rows.first().map(|row| (row.pc_before, row.sp_before));
    if proof.start_boundary != expected_start {
        return Err("wasm stage3 start boundary mismatch".into());
    }
    let expected_final = proof
        .rows
        .last()
        .map(|row| (row.pc_after, row.sp_after, row.halted));
    if proof.final_boundary != expected_final {
        return Err("wasm stage3 final boundary mismatch".into());
    }
    Ok(())
}

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}
