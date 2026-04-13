//! Owns transcript absorption for the WASM Stage 2 stack rows.

use neo_math::{KExtensions, F};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::proof::{Stage2FamilyClaim, Stage2StackAccessFamily, Stage2StackRowBinding};

pub(crate) fn append_stage2_rows<Tr: Transcript>(transcript: &mut Tr, rows: &[Stage2StackRowBinding]) {
    transcript.append_message(b"wasm/stage2/stack", b"begin");
    transcript.append_fields(b"wasm/stage2/row_count", &[F::from_u64(rows.len() as u64)]);
    for row in rows {
        transcript.append_fields(
            b"wasm/stage2/row",
            &[
                F::from_u64(row.trace_index as u64),
                F::from_u64(row.cycle),
                lane_addr(row.read0),
                lane_value(row.read0),
                lane_addr(row.read1),
                lane_value(row.read1),
                lane_addr(row.read2),
                lane_value(row.read2),
                lane_addr(row.write1),
                lane_value(row.write1),
                lane_addr(row.local_read),
                lane_value(row.local_read),
                lane_addr(row.local_write),
                lane_value(row.local_write),
            ],
        );
    }
}

pub(crate) fn append_stage2_family_claims<Tr: Transcript>(transcript: &mut Tr, claims: &[Stage2FamilyClaim]) {
    transcript.append_message(b"wasm/stage2/families", b"begin");
    transcript.append_fields(b"wasm/stage2/family_count", &[F::from_u64(claims.len() as u64)]);
    for claim in claims {
        transcript.append_fields(
            b"wasm/stage2/family_claim",
            &[
                F::from_u64(family_tag(claim.family)),
                claim.claim.as_coeffs()[0],
                claim.claim.as_coeffs()[1],
            ],
        );
    }
}

fn family_tag(family: Stage2StackAccessFamily) -> u64 {
    match family {
        Stage2StackAccessFamily::Read0 => 0,
        Stage2StackAccessFamily::Read1 => 1,
        Stage2StackAccessFamily::Read2 => 2,
        Stage2StackAccessFamily::Write1 => 3,
    }
}

fn lane_addr(lane: Option<super::super::ir::StackLaneAccess>) -> F {
    F::from_u64(lane.map(|lane| lane.addr).unwrap_or(0))
}

fn lane_value(lane: Option<super::super::ir::StackLaneAccess>) -> F {
    F::from_u64(u64::from(lane.map(|lane| lane.value).unwrap_or(0)))
}
