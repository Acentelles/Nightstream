//! Owns transcript absorption for the WASM Stage 3 boundary rows.

use neo_math::F;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::proof::Stage3BoundaryRowBinding;

pub(crate) fn append_stage3_rows<Tr: Transcript>(transcript: &mut Tr, rows: &[Stage3BoundaryRowBinding]) {
    transcript.append_message(b"wasm/stage3/boundaries", b"begin");
    transcript.append_fields(b"wasm/stage3/row_count", &[F::from_u64(rows.len() as u64)]);
    for row in rows {
        transcript.append_fields(
            b"wasm/stage3/row",
            &[
                F::from_u64(row.trace_index as u64),
                F::from_u64(row.cycle),
                F::from_u64(row.pc_before),
                F::from_u64(row.pc_after),
                F::from_u64(row.sp_before),
                F::from_u64(row.sp_after),
                F::from_bool(row.halted),
            ],
        );
    }
}
