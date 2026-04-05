//! Owns the Stage 1 verifier entrypoint.

use neo_math::{F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::{batch_values, expect_equal_k_slice, SimpleKernelError};
use crate::chip8::tables::ROM_ADDR_BITS;

use super::proof::{ShoutChannelExecutionProof, Stage1ShoutProof};
use super::transcript::replay_stage1_channel_transcript;
use super::{
    mle_eval_k_be, mle_eval_many_k_be, sample_challenge, sample_stage1_cycle_point, sample_stage1_decode_alpha,
    stage1_decode_claim, stage1_eq4_claim, stage1_execution_surface_from_proof, stage1_fetch_claim,
    Stage1DerivedExecutionSurface,
};

fn verify_stage1_surface<Tr: Transcript>(
    fetch: &ShoutChannelExecutionProof,
    decode: &ShoutChannelExecutionProof,
    alu: &ShoutChannelExecutionProof,
    eq4: &ShoutChannelExecutionProof,
    surface: &Stage1DerivedExecutionSurface,
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
    cycle_bits: usize,
    alu_decode_consistency_claim: Option<K>,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    let expected_cycle_point = sample_stage1_cycle_point(transcript, cycle_bits);
    expect_equal_k_slice(&surface.cycle_point, &expected_cycle_point, "stage1 cycle point")?;
    if surface.decode_handoff_values.len() != 3 || surface.lane_values_at_lookup.len() != 17 {
        return Err(SimpleKernelError::OpeningFailed(
            "stage1 opening surface has the wrong shape".into(),
        ));
    }
    if surface.decode.read_values_at_cycle.len() <= 21 {
        return Err(SimpleKernelError::OpeningFailed(
            "stage1 decode proof is missing required output columns".into(),
        ));
    }

    let fetch_addr_point = replay_stage1_channel_transcript(
        transcript,
        fetch,
        *surface
            .fetch
            .read_values_at_cycle
            .first()
            .ok_or_else(|| SimpleKernelError::OpeningFailed("stage1 fetch read value missing".into()))?,
        ROM_ADDR_BITS,
        cycle_bits,
        Some(stage1_fetch_claim(&surface.lane_values_at_lookup)),
        "stage1 fetch",
    )?;
    expect_equal_k_slice(&surface.fetch.addr_point, &fetch_addr_point, "stage1 fetch addr point")?;

    let decode_alpha = sample_stage1_decode_alpha(transcript);
    let decode_addr_point = replay_stage1_channel_transcript(
        transcript,
        decode,
        batch_values(&surface.decode.read_values_at_cycle, decode_alpha),
        16,
        cycle_bits,
        Some(stage1_decode_claim(
            *surface
                .fetch
                .read_values_at_cycle
                .first()
                .ok_or_else(|| SimpleKernelError::OpeningFailed("stage1 fetch read value missing".into()))?,
        )),
        "stage1 decode",
    )?;
    expect_equal_k_slice(
        &surface.decode.addr_point,
        &decode_addr_point,
        "stage1 decode addr point",
    )?;

    let alu_addr_point = replay_stage1_channel_transcript(
        transcript,
        alu,
        *surface
            .alu
            .read_values_at_cycle
            .first()
            .ok_or_else(|| SimpleKernelError::OpeningFailed("stage1 ALU read value missing".into()))?,
        18,
        cycle_bits,
        alu_decode_consistency_claim,
        "stage1 alu",
    )?;
    expect_equal_k_slice(&surface.alu.addr_point, &alu_addr_point, "stage1 alu addr point")?;

    let eq4_addr_point = replay_stage1_channel_transcript(
        transcript,
        eq4,
        *surface
            .eq4
            .read_values_at_cycle
            .first()
            .ok_or_else(|| SimpleKernelError::OpeningFailed("stage1 Eq4 read value missing".into()))?,
        8,
        cycle_bits,
        Some(stage1_eq4_claim(
            &surface.lane_values_at_lookup,
            &surface.decode.read_values_at_cycle,
        )),
        "stage1 eq4",
    )?;
    expect_equal_k_slice(&surface.eq4.addr_point, &eq4_addr_point, "stage1 eq4 addr point")?;

    if surface.fetch.table_opening_values != vec![mle_eval_k_be(rom_table, &surface.fetch.addr_point)] {
        return Err(SimpleKernelError::OpeningFailed(
            "stage1 ROM table opening mismatch".into(),
        ));
    }
    if surface.decode.table_opening_values != mle_eval_many_k_be(decode_table, &surface.decode.addr_point) {
        return Err(SimpleKernelError::OpeningFailed(
            "stage1 decode table opening mismatch".into(),
        ));
    }
    if surface.alu.table_opening_values != vec![mle_eval_k_be(alu_table, &surface.alu.addr_point[2..])] {
        return Err(SimpleKernelError::OpeningFailed(
            "stage1 ALU table opening mismatch".into(),
        ));
    }
    if surface.eq4.table_opening_values != vec![mle_eval_k_be(eq4_table, &surface.eq4.addr_point)] {
        return Err(SimpleKernelError::OpeningFailed(
            "stage1 Eq4 table opening mismatch".into(),
        ));
    }
    if surface.decode.read_values_at_cycle[0] != K::ONE {
        return Err(SimpleKernelError::OpeningFailed(
            "stage1 decode valid column must equal 1 at r_lookup".into(),
        ));
    }

    let gamma_lookup_link = sample_challenge(transcript, b"stage1/gamma_lookup_link");
    let linkage_terms = super::stage1_linkage_terms(
        &surface.lane_values_at_lookup,
        &surface.decode.read_values_at_cycle,
        &surface.decode_handoff_values,
        surface.alu.read_values_at_cycle[0],
        surface.eq4.read_values_at_cycle[0],
    );
    if batch_values(&linkage_terms, gamma_lookup_link) != K::ZERO {
        return Err(SimpleKernelError::SumcheckFailed(
            "stage1 linkage batch failed at r_lookup".into(),
        ));
    }

    Ok(())
}

pub(crate) fn verify_stage1_execution<Tr: Transcript>(
    fetch: &ShoutChannelExecutionProof,
    decode: &ShoutChannelExecutionProof,
    alu: &ShoutChannelExecutionProof,
    eq4: &ShoutChannelExecutionProof,
    surface: &Stage1DerivedExecutionSurface,
    rom_table: &[F],
    decode_table: &[Vec<F>],
    alu_table: &[F],
    eq4_table: &[F],
    cycle_bits: usize,
    alu_decode_consistency_claim: Option<K>,
    transcript: &mut Tr,
) -> Result<(), SimpleKernelError> {
    verify_stage1_surface(
        fetch,
        decode,
        alu,
        eq4,
        surface,
        rom_table,
        decode_table,
        alu_table,
        eq4_table,
        cycle_bits,
        alu_decode_consistency_claim,
        transcript,
    )
}

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
    let surface = stage1_execution_surface_from_proof(proof);
    let fetch = ShoutChannelExecutionProof {
        sumcheck_rounds: proof.fetch_proof.sumcheck_rounds.clone(),
        addr_correctness_rounds: proof.fetch_proof.addr_correctness_rounds.clone(),
    };
    let decode = ShoutChannelExecutionProof {
        sumcheck_rounds: proof.decode_proof.sumcheck_rounds.clone(),
        addr_correctness_rounds: proof.decode_proof.addr_correctness_rounds.clone(),
    };
    let alu = ShoutChannelExecutionProof {
        sumcheck_rounds: proof.alu_proof.sumcheck_rounds.clone(),
        addr_correctness_rounds: proof.alu_proof.addr_correctness_rounds.clone(),
    };
    let eq4 = ShoutChannelExecutionProof {
        sumcheck_rounds: proof.eq4_proof.sumcheck_rounds.clone(),
        addr_correctness_rounds: proof.eq4_proof.addr_correctness_rounds.clone(),
    };
    verify_stage1_surface(
        &fetch,
        &decode,
        &alu,
        &eq4,
        &surface,
        rom_table,
        decode_table,
        alu_table,
        eq4_table,
        cycle_bits,
        alu_decode_consistency_claim,
        transcript,
    )
    .map_err(|err| err.to_string())
}
