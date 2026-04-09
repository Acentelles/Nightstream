//! Owns transcript labels for the WASM Stage 1 Shout channels.

use neo_math::F;
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::super::isa::WasmShoutOpcode;
use super::proof::Stage1LookupRowBinding;

pub fn stage1_channel_label(channel: WasmShoutOpcode) -> &'static [u8] {
    match channel {
        WasmShoutOpcode::I32Eqz => b"wasm/stage1/i32_eqz",
        WasmShoutOpcode::I32Eq => b"wasm/stage1/i32_eq",
        WasmShoutOpcode::I32Ne => b"wasm/stage1/i32_ne",
        WasmShoutOpcode::I32LtS => b"wasm/stage1/i32_lt_s",
        WasmShoutOpcode::I32LtU => b"wasm/stage1/i32_lt_u",
        WasmShoutOpcode::I32And => b"wasm/stage1/i32_and",
        WasmShoutOpcode::I32Or => b"wasm/stage1/i32_or",
        WasmShoutOpcode::I32Xor => b"wasm/stage1/i32_xor",
        WasmShoutOpcode::I32Mul => b"wasm/stage1/i32_mul",
    }
}

pub fn stage1_mix_label(channel: WasmShoutOpcode) -> &'static [u8] {
    match channel {
        WasmShoutOpcode::I32Eqz => b"wasm/stage1/i32_eqz/mix",
        WasmShoutOpcode::I32Eq => b"wasm/stage1/i32_eq/mix",
        WasmShoutOpcode::I32Ne => b"wasm/stage1/i32_ne/mix",
        WasmShoutOpcode::I32LtS => b"wasm/stage1/i32_lt_s/mix",
        WasmShoutOpcode::I32LtU => b"wasm/stage1/i32_lt_u/mix",
        WasmShoutOpcode::I32And => b"wasm/stage1/i32_and/mix",
        WasmShoutOpcode::I32Or => b"wasm/stage1/i32_or/mix",
        WasmShoutOpcode::I32Xor => b"wasm/stage1/i32_xor/mix",
        WasmShoutOpcode::I32Mul => b"wasm/stage1/i32_mul/mix",
    }
}

pub(crate) fn append_stage1_row_bindings<Tr: Transcript>(
    transcript: &mut Tr,
    label: &'static [u8],
    rows: &[Stage1LookupRowBinding],
) {
    transcript.append_message(label, b"begin");
    transcript.append_fields(b"wasm/stage1/row_count", &[F::from_u64(rows.len() as u64)]);
    for row in rows {
        transcript.append_fields(
            b"wasm/stage1/row_binding",
            &[
                F::from_u64(row.trace_index as u64),
                F::from_u64(row.cycle),
                F::from_u64(row.pc_before),
                F::from_u64(row.shout_id as u64),
                F::from_u64(row.input0 as u64),
                F::from_u64(row.input1 as u64),
                F::from_u64(row.output as u64),
            ],
        );
    }
}
