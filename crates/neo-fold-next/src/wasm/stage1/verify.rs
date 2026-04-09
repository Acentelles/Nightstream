//! Owns verifier-side replay for the first WASM Stage 1 channels.

use neo_math::{from_complex, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::proof::{Stage1BinaryProof, Stage1EqzProof, Stage1Summary};
use super::prove::{batched_binary_claim, batched_eqz_claim, channel_rows, eqz_rows};
use super::transcript::{append_stage1_row_bindings, stage1_channel_label, stage1_mix_label};
use crate::wasm::WasmShoutOpcode;

pub fn verify_stage1_eqz<Tr: Transcript>(
    summary: &Stage1Summary,
    proof: &Stage1EqzProof,
    transcript: &mut Tr,
) -> Result<(), String> {
    let expected_rows = eqz_rows(summary);
    if proof.rows != expected_rows {
        return Err("wasm stage1 eqz row binding mismatch".into());
    }
    append_stage1_row_bindings(transcript, stage1_channel_label(WasmShoutOpcode::I32Eqz), &proof.rows);
    let alpha = sample_k(transcript, stage1_mix_label(WasmShoutOpcode::I32Eqz));
    let expected_claim = batched_eqz_claim(&proof.rows, alpha)?;
    if proof.batched_claim != expected_claim {
        return Err("wasm stage1 eqz batched claim mismatch".into());
    }
    if proof.batched_claim != K::ZERO {
        return Err("wasm stage1 eqz semantic batch failed".into());
    }
    Ok(())
}

pub fn verify_stage1_binary<Tr: Transcript>(
    summary: &Stage1Summary,
    proof: &Stage1BinaryProof,
    transcript: &mut Tr,
) -> Result<(), String> {
    if matches!(proof.channel, WasmShoutOpcode::I32Eqz) {
        return Err("wasm stage1 binary verifier does not accept unary channels".into());
    }
    let expected_rows = channel_rows(summary, proof.channel);
    if proof.rows != expected_rows {
        return Err(format!("wasm stage1 {} row binding mismatch", proof.channel.name()));
    }
    append_stage1_row_bindings(transcript, stage1_channel_label(proof.channel), &proof.rows);
    let alpha = sample_k(transcript, stage1_mix_label(proof.channel));
    let expected_claim = batched_binary_claim(proof.channel, &proof.rows, alpha)?;
    if proof.batched_claim != expected_claim {
        return Err(format!("wasm stage1 {} batched claim mismatch", proof.channel.name()));
    }
    if proof.batched_claim != K::ZERO {
        return Err(format!("wasm stage1 {} semantic batch failed", proof.channel.name()));
    }
    Ok(())
}

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}
