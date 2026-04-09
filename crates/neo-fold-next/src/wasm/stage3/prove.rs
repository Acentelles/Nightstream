//! Owns the first WASM Stage 3 prover slice: boundary continuity.

use neo_math::{from_complex, F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::proof::{Stage3BoundaryProof, Stage3BoundaryRowBinding, Stage3BoundarySummary};
use super::transcript::append_stage3_rows;

pub fn prove_stage3_boundaries<Tr: Transcript>(
    summary: &Stage3BoundarySummary,
    transcript: &mut Tr,
) -> Result<Stage3BoundaryProof, String> {
    append_stage3_rows(transcript, &summary.rows);
    let alpha = sample_k(transcript, b"wasm/stage3/boundaries/mix");
    let continuity_batched_claim = batched_boundary_claim(&summary.rows, alpha)?;
    if continuity_batched_claim != K::ZERO {
        return Err("wasm stage3 boundary continuity batch failed".into());
    }
    Ok(Stage3BoundaryProof {
        rows: summary.rows.clone(),
        continuity_batched_claim,
        start_boundary: summary
            .rows
            .first()
            .map(|row| (row.pc_before, row.sp_before)),
        final_boundary: summary
            .rows
            .last()
            .map(|row| (row.pc_after, row.sp_after, row.halted)),
    })
}

pub(crate) fn batched_boundary_claim(rows: &[Stage3BoundaryRowBinding], alpha: K) -> Result<K, String> {
    let mut claim = K::ZERO;
    let mut alpha_pow = K::ONE;

    for pair in rows.windows(2) {
        let current = &pair[0];
        let next = &pair[1];
        if current.halted {
            return Err(format!(
                "wasm stage3 row {} is halted before the terminal boundary",
                current.trace_index
            ));
        }
        let cycle_delta = next.cycle.saturating_sub(current.cycle);
        let trace_delta = next.trace_index.saturating_sub(current.trace_index) as u64;
        let terms = [
            current.pc_after as i128 - next.pc_before as i128,
            current.sp_after as i128 - next.sp_before as i128,
            cycle_delta as i128 - 1,
            trace_delta as i128 - 1,
        ];
        for term in terms {
            claim += alpha_pow * signed_term(term);
            alpha_pow *= alpha;
        }
    }

    Ok(claim)
}

fn signed_term(value: i128) -> K {
    if value >= 0 {
        K::from(F::from_u64(value as u64))
    } else {
        -K::from(F::from_u64((-value) as u64))
    }
}

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}
