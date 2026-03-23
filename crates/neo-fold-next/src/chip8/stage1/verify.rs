//! Owns the Stage 1 verifier entrypoint.

use neo_math::{F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::batch_values;
use crate::chip8::tables::ROM_ADDR_BITS;

use super::proof::Stage1ShoutProof;
use super::transcript::verify_stage1_channel_transcript;
use super::{
    mle_eval_k_be, mle_eval_many_k_be, sample_challenge, sample_challenge_vec, stage1_decode_claim, stage1_eq4_claim,
    stage1_fetch_claim,
};

pub fn verify_stage1<Tr: Transcript>(
    proof: &Stage1ShoutProof,
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
    cycle_bits: usize,
    alu_decode_consistency_claim: Option<K>,
    transcript: &mut Tr,
) -> Result<(), String> {
    let expected_cycle_point = sample_challenge_vec(transcript, b"stage1/r_lookup", cycle_bits);
    if proof.cycle_point != expected_cycle_point {
        return Err("stage1 cycle point mismatch".into());
    }
    if proof.decode_handoff_values.len() != 3 || proof.lane_values_at_lookup.len() != 17 {
        return Err("stage1 opening surface has the wrong shape".into());
    }
    if proof.decode_proof.read_values_at_cycle.len() <= 21 {
        return Err("stage1 decode proof is missing required output columns".into());
    }

    verify_stage1_channel_transcript(
        transcript,
        &proof.fetch_proof,
        *proof
            .fetch_proof
            .read_values_at_cycle
            .first()
            .ok_or_else(|| "stage1 fetch read value missing".to_string())?,
        ROM_ADDR_BITS,
        cycle_bits,
        Some(stage1_fetch_claim(&proof.lane_values_at_lookup)),
        "stage1 fetch",
    )
    .map_err(|err| err.to_string())?;

    let decode_alpha = sample_challenge(transcript, b"shout/decode_alpha");
    verify_stage1_channel_transcript(
        transcript,
        &proof.decode_proof,
        batch_values(&proof.decode_proof.read_values_at_cycle, decode_alpha),
        16,
        cycle_bits,
        Some(stage1_decode_claim(
            *proof
                .fetch_proof
                .read_values_at_cycle
                .first()
                .ok_or_else(|| "stage1 fetch read value missing".to_string())?,
        )),
        "stage1 decode",
    )
    .map_err(|err| err.to_string())?;

    verify_stage1_channel_transcript(
        transcript,
        &proof.alu_proof,
        *proof
            .alu_proof
            .read_values_at_cycle
            .first()
            .ok_or_else(|| "stage1 ALU read value missing".to_string())?,
        18,
        cycle_bits,
        alu_decode_consistency_claim,
        "stage1 alu",
    )
    .map_err(|err| err.to_string())?;

    verify_stage1_channel_transcript(
        transcript,
        &proof.eq4_proof,
        *proof
            .eq4_proof
            .read_values_at_cycle
            .first()
            .ok_or_else(|| "stage1 Eq4 read value missing".to_string())?,
        8,
        cycle_bits,
        Some(stage1_eq4_claim(
            &proof.lane_values_at_lookup,
            &proof.decode_proof.read_values_at_cycle,
        )),
        "stage1 eq4",
    )
    .map_err(|err| err.to_string())?;

    if proof.fetch_proof.table_opening_values != vec![mle_eval_k_be(rom_table, &proof.fetch_proof.addr_point)] {
        return Err("stage1 ROM table opening mismatch".into());
    }
    if proof.decode_proof.table_opening_values != mle_eval_many_k_be(decode_table, &proof.decode_proof.addr_point) {
        return Err("stage1 decode table opening mismatch".into());
    }
    if proof.alu_proof.table_opening_values != vec![mle_eval_k_be(alu_table, &proof.alu_proof.addr_point[2..])] {
        return Err("stage1 ALU table opening mismatch".into());
    }
    if proof.eq4_proof.table_opening_values != vec![mle_eval_k_be(eq4_table, &proof.eq4_proof.addr_point)] {
        return Err("stage1 Eq4 table opening mismatch".into());
    }
    if proof.decode_proof.read_values_at_cycle[0] != K::ONE {
        return Err("stage1 decode valid column must equal 1 at r_lookup".into());
    }

    let gamma_lookup_link = sample_challenge(transcript, b"stage1/gamma_lookup_link");
    let decode = &proof.decode_proof.read_values_at_cycle;
    let lane = &proof.lane_values_at_lookup;
    let handoff = &proof.decode_handoff_values;
    let linkage_terms = super::stage1_linkage_terms(
        lane,
        decode,
        handoff,
        proof.alu_proof.read_values_at_cycle[0],
        proof.eq4_proof.read_values_at_cycle[0],
    );
    if batch_values(&linkage_terms, gamma_lookup_link) != K::ZERO {
        return Err("stage1 linkage batch failed at r_lookup".into());
    }

    Ok(())
}
