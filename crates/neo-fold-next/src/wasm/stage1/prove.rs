//! Owns the first real WASM Stage 1 prover slices.

use neo_math::{from_complex, F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::proof::{Stage1BinaryProof, Stage1EqzProof, Stage1LookupRowBinding, Stage1Summary};
use super::transcript::{append_stage1_row_bindings, stage1_channel_label, stage1_mix_label};
use crate::wasm::WasmShoutOpcode;

pub fn prove_stage1_eqz<Tr: Transcript>(
    summary: &Stage1Summary,
    transcript: &mut Tr,
) -> Result<Stage1EqzProof, String> {
    let rows = eqz_rows(summary);
    append_stage1_row_bindings(transcript, stage1_channel_label(WasmShoutOpcode::I32Eqz), &rows);
    let alpha = sample_k(transcript, stage1_mix_label(WasmShoutOpcode::I32Eqz));
    let batched_claim = batched_eqz_claim(&rows, alpha)?;
    if batched_claim != K::ZERO {
        return Err("wasm stage1 eqz semantic batch failed".into());
    }
    Ok(Stage1EqzProof { rows, batched_claim })
}

pub fn prove_stage1_binary<Tr: Transcript>(
    summary: &Stage1Summary,
    channel: WasmShoutOpcode,
    transcript: &mut Tr,
) -> Result<Stage1BinaryProof, String> {
    if matches!(channel, WasmShoutOpcode::I32Eqz) {
        return Err("wasm stage1 binary prover does not accept unary channels".into());
    }
    let rows = channel_rows(summary, channel);
    append_stage1_row_bindings(transcript, stage1_channel_label(channel), &rows);
    let alpha = sample_k(transcript, stage1_mix_label(channel));
    let batched_claim = batched_binary_claim(channel, &rows, alpha)?;
    if batched_claim != K::ZERO {
        return Err(format!("wasm stage1 {} semantic batch failed", channel.name()));
    }
    Ok(Stage1BinaryProof {
        channel,
        rows,
        batched_claim,
    })
}

pub(crate) fn batched_eqz_claim(rows: &[Stage1LookupRowBinding], alpha: K) -> Result<K, String> {
    let mut acc = K::ZERO;
    let mut alpha_pow = K::ONE;
    for row in rows {
        let expected = if row.input0 == 0 { F::ONE } else { F::ZERO };
        let actual = F::from_u64(u64::from(row.output));
        if row.input1 != 0 {
            return Err("wasm stage1 eqz row unexpectedly carried a second input".into());
        }
        acc += alpha_pow * (K::from(actual) - K::from(expected));
        alpha_pow *= alpha;
    }
    Ok(acc)
}

pub(crate) fn eqz_rows(summary: &Stage1Summary) -> Vec<Stage1LookupRowBinding> {
    channel_rows(summary, WasmShoutOpcode::I32Eqz)
}

pub(crate) fn channel_rows(summary: &Stage1Summary, channel: WasmShoutOpcode) -> Vec<Stage1LookupRowBinding> {
    summary
        .channels
        .iter()
        .find(|summary_channel| summary_channel.channel == channel)
        .map(|summary_channel| summary_channel.rows.clone())
        .unwrap_or_default()
}

pub(crate) fn batched_binary_claim(
    channel: WasmShoutOpcode,
    rows: &[Stage1LookupRowBinding],
    alpha: K,
) -> Result<K, String> {
    let mut acc = K::ZERO;
    let mut alpha_pow = K::ONE;
    for row in rows {
        if row.input1 == 0
            && !matches!(
                channel,
                WasmShoutOpcode::I32Mul
                    | WasmShoutOpcode::I32And
                    | WasmShoutOpcode::I32Or
                    | WasmShoutOpcode::I32Xor
                    | WasmShoutOpcode::I32Eq
                    | WasmShoutOpcode::I32Ne
                    | WasmShoutOpcode::I32LtS
                    | WasmShoutOpcode::I32LtU
            )
        {
            return Err(format!("wasm stage1 {} row shape is not binary", channel.name()));
        }
        let expected = expected_binary_output(channel, row.input0, row.input1);
        let actual = F::from_u64(u64::from(row.output));
        acc += alpha_pow * (K::from(actual) - K::from(expected));
        alpha_pow *= alpha;
    }
    Ok(acc)
}

fn expected_binary_output(channel: WasmShoutOpcode, lhs: u32, rhs: u32) -> F {
    let out = match channel {
        WasmShoutOpcode::I32Eqz => unreachable!("unary channel"),
        WasmShoutOpcode::I32Eq => u32::from(lhs == rhs),
        WasmShoutOpcode::I32Ne => u32::from(lhs != rhs),
        WasmShoutOpcode::I32LtS => u32::from((lhs as i32) < (rhs as i32)),
        WasmShoutOpcode::I32LtU => u32::from(lhs < rhs),
        WasmShoutOpcode::I32And => lhs & rhs,
        WasmShoutOpcode::I32Or => lhs | rhs,
        WasmShoutOpcode::I32Xor => lhs ^ rhs,
        WasmShoutOpcode::I32Mul => lhs.wrapping_mul(rhs),
    };
    F::from_u64(u64::from(out))
}

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}
