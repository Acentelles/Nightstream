use neo_math::{F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::poly::{mle_eval_f_be, mle_eval_f_le, open_onehot_at_point_be, open_onehot_at_point_be_be};
use crate::chip8::stage1::{
    stage1_execution_surface_from_proof, ShoutChannelExecutionProof, Stage1DerivedChannelSurface,
    Stage1DerivedExecutionSurface, Stage1ShoutProof,
};

use super::super::verify_common::{split_round_groups, verify_sumcheck_known_with_terminal};
use super::super::{batch_values, expect_equal_k, expect_equal_k_slice, KernelStepAux, SimpleKernelError};
use super::{build_alu_mixed_table, raw_index_mle_be, sample_k, sample_point, ROM_ADDR_BITS};

fn stage1_eq4_claim(lane_values_at_lookup: &[K], decode_values: &[K]) -> K {
    let sixteen = K::from(F::from_u64(16));
    sixteen * lane_values_at_lookup[14] + decode_values[21]
}

fn verify_stage1_channel_terminals_from_execution<Tr: Transcript>(
    transcript: &mut Tr,
    execution: &ShoutChannelExecutionProof,
    surface: &Stage1DerivedChannelSurface,
    initial_sum: K,
    addr_bits: usize,
    cycle_bits: usize,
    decode_consistency_claim: K,
    addresses: &[usize],
    core_table_value: K,
    cycle_point: &[K],
    label: &str,
) -> Result<(), SimpleKernelError> {
    let (core_point, core_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        initial_sum,
        &execution.sumcheck_rounds,
        &format!("{label} core"),
    )?;
    expect_equal_k_slice(&core_point, &surface.addr_point, &format!("{label} addr point"))?;
    expect_equal_k(
        core_terminal,
        surface.address_opening_value * core_table_value,
        &format!("{label} core terminal"),
    )?;

    let total_bits = addr_bits + cycle_bits;
    let (bool_rounds, hamming_rounds, decode_rounds) = split_round_groups(
        &execution.addr_correctness_rounds,
        total_bits,
        addr_bits,
        addr_bits,
        &format!("{label} address correctness"),
    )?;
    let (bool_point, bool_terminal) =
        verify_sumcheck_known_with_terminal(transcript, 2, K::ZERO, bool_rounds, &format!("{label} booleanity"))?;
    let (bool_addr_point, bool_cycle_point) = bool_point.split_at(addr_bits);
    let bool_onehot = open_onehot_at_point_be_be(addresses, bool_addr_point, bool_cycle_point);
    expect_equal_k(
        bool_terminal,
        bool_onehot * (bool_onehot - K::ONE),
        &format!("{label} booleanity terminal"),
    )?;

    let (hamming_point, hamming_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        1,
        K::ONE,
        hamming_rounds,
        &format!("{label} hamming weight"),
    )?;
    let hamming_onehot = open_onehot_at_point_be(addresses, &hamming_point, cycle_point);
    expect_equal_k(hamming_terminal, hamming_onehot, &format!("{label} hamming terminal"))?;

    let (decode_point, decode_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        decode_consistency_claim,
        decode_rounds,
        &format!("{label} decode consistency"),
    )?;
    let decode_onehot = open_onehot_at_point_be(addresses, &decode_point, cycle_point);
    expect_equal_k(
        decode_terminal,
        decode_onehot * raw_index_mle_be(&decode_point),
        &format!("{label} decode terminal"),
    )?;
    Ok(())
}

pub(crate) fn verify_kernel_stage1_sumcheck_terminals_from_execution(
    fetch: &ShoutChannelExecutionProof,
    decode: &ShoutChannelExecutionProof,
    alu: &ShoutChannelExecutionProof,
    eq4: &ShoutChannelExecutionProof,
    surface: &Stage1DerivedExecutionSurface,
    aux: &[KernelStepAux],
    rom_table: &[F],
    alu_table: &[F],
    eq4_table: &[F],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
    let cycle_bits = surface.cycle_point.len();
    let cycle_point = sample_point(transcript, b"stage1/r_lookup", cycle_bits);
    expect_equal_k_slice(&cycle_point, &surface.cycle_point, "stage1 cycle point")?;

    let fetch_addrs: Vec<_> = aux.iter().map(|step| step.fetch_addr).collect();
    verify_stage1_channel_terminals_from_execution(
        transcript,
        fetch,
        &surface.fetch,
        surface.fetch.read_values_at_cycle[0],
        ROM_ADDR_BITS,
        cycle_bits,
        surface.lane_values_at_lookup[0],
        &fetch_addrs,
        mle_eval_f_be(rom_table, &surface.fetch.addr_point),
        &surface.cycle_point,
        "stage1 fetch",
    )?;

    let decode_alpha = sample_k(transcript, b"shout/decode_alpha");
    let decode_addrs: Vec<_> = aux.iter().map(|step| step.decode_addr as usize).collect();
    verify_stage1_channel_terminals_from_execution(
        transcript,
        decode,
        &surface.decode,
        batch_values(&surface.decode.read_values_at_cycle, decode_alpha),
        16,
        cycle_bits,
        surface.fetch.read_values_at_cycle[0],
        &decode_addrs,
        batch_values(&surface.decode.table_opening_values, decode_alpha),
        &surface.cycle_point,
        "stage1 decode",
    )?;

    let alu_addrs: Vec<_> = aux.iter().map(|step| step.alu_key as usize).collect();
    let alu_mixed_table = build_alu_mixed_table(alu_table);
    let alu_expected: Vec<F> = aux
        .iter()
        .map(|step| F::from_u64(step.alu_key as u64))
        .collect();
    verify_stage1_channel_terminals_from_execution(
        transcript,
        alu,
        &surface.alu,
        surface.alu.read_values_at_cycle[0],
        18,
        cycle_bits,
        mle_eval_f_le(&alu_expected, &surface.cycle_point),
        &alu_addrs,
        mle_eval_f_be(&alu_mixed_table, &surface.alu.addr_point),
        &surface.cycle_point,
        "stage1 alu",
    )?;

    let eq4_addrs: Vec<_> = aux.iter().map(|step| step.eq4_key as usize).collect();
    verify_stage1_channel_terminals_from_execution(
        transcript,
        eq4,
        &surface.eq4,
        surface.eq4.read_values_at_cycle[0],
        8,
        cycle_bits,
        stage1_eq4_claim(&surface.lane_values_at_lookup, &surface.decode.read_values_at_cycle),
        &eq4_addrs,
        mle_eval_f_be(eq4_table, &surface.eq4.addr_point),
        &surface.cycle_point,
        "stage1 eq4",
    )?;

    Ok(())
}

pub(crate) fn verify_kernel_stage1_sumcheck_terminals(
    proof: &Stage1ShoutProof,
    aux: &[KernelStepAux],
    rom_table: &[F],
    alu_table: &[F],
    eq4_table: &[F],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
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
    verify_kernel_stage1_sumcheck_terminals_from_execution(
        &fetch, &decode, &alu, &eq4, &surface, aux, rom_table, alu_table, eq4_table, transcript,
    )
}
