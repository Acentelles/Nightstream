use neo_math::{F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::poly::{mle_eval_f_be, mle_eval_f_le, open_onehot_at_point_be, open_onehot_at_point_be_be};

use super::super::verify_common::{split_round_groups, verify_sumcheck_known_with_terminal};
use super::super::{
    batch_values, expect_equal_k, expect_equal_k_slice, KernelStepAux, ShoutChannelProof, SimpleKernelError,
    Stage1ShoutProof,
};
use super::{build_alu_mixed_table, raw_index_mle_be, sample_k, sample_point, ROM_ADDR_BITS};

fn stage1_eq4_claim(lane_values_at_lookup: &[K], decode_values: &[K]) -> K {
    let sixteen = K::from(F::from_u64(16));
    sixteen * lane_values_at_lookup[14] + decode_values[21]
}

fn verify_stage1_channel_terminals<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &ShoutChannelProof,
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
        &proof.sumcheck_rounds,
        &format!("{label} core"),
    )?;
    expect_equal_k_slice(&core_point, &proof.addr_point, &format!("{label} addr point"))?;
    expect_equal_k(
        core_terminal,
        proof.address_opening_value * core_table_value,
        &format!("{label} core terminal"),
    )?;

    let total_bits = addr_bits + cycle_bits;
    let (bool_rounds, hamming_rounds, decode_rounds) = split_round_groups(
        &proof.addr_correctness_rounds,
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

pub(crate) fn verify_kernel_stage1_sumcheck_terminals(
    proof: &Stage1ShoutProof,
    aux: &[KernelStepAux],
    rom_table: &[F],
    alu_table: &[F],
    eq4_table: &[F],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
    let cycle_bits = proof.cycle_point.len();
    let cycle_point = sample_point(transcript, b"stage1/r_lookup", cycle_bits);
    expect_equal_k_slice(&cycle_point, &proof.cycle_point, "stage1 cycle point")?;

    let fetch_addrs: Vec<_> = aux.iter().map(|step| step.fetch_addr).collect();
    verify_stage1_channel_terminals(
        transcript,
        &proof.fetch_proof,
        proof.fetch_proof.read_values_at_cycle[0],
        ROM_ADDR_BITS,
        cycle_bits,
        proof.lane_values_at_lookup[0],
        &fetch_addrs,
        mle_eval_f_be(rom_table, &proof.fetch_proof.addr_point),
        &proof.cycle_point,
        "stage1 fetch",
    )?;

    let decode_alpha = sample_k(transcript, b"shout/decode_alpha");
    let decode_addrs: Vec<_> = aux.iter().map(|step| step.decode_addr as usize).collect();
    verify_stage1_channel_terminals(
        transcript,
        &proof.decode_proof,
        batch_values(&proof.decode_proof.read_values_at_cycle, decode_alpha),
        16,
        cycle_bits,
        proof.fetch_proof.read_values_at_cycle[0],
        &decode_addrs,
        batch_values(&proof.decode_proof.table_opening_values, decode_alpha),
        &proof.cycle_point,
        "stage1 decode",
    )?;

    let alu_addrs: Vec<_> = aux.iter().map(|step| step.alu_key as usize).collect();
    let alu_mixed_table = build_alu_mixed_table(alu_table);
    let alu_expected: Vec<F> = aux
        .iter()
        .map(|step| F::from_u64(step.alu_key as u64))
        .collect();
    verify_stage1_channel_terminals(
        transcript,
        &proof.alu_proof,
        proof.alu_proof.read_values_at_cycle[0],
        18,
        cycle_bits,
        mle_eval_f_le(&alu_expected, &proof.cycle_point),
        &alu_addrs,
        mle_eval_f_be(&alu_mixed_table, &proof.alu_proof.addr_point),
        &proof.cycle_point,
        "stage1 alu",
    )?;

    let eq4_addrs: Vec<_> = aux.iter().map(|step| step.eq4_key as usize).collect();
    verify_stage1_channel_terminals(
        transcript,
        &proof.eq4_proof,
        proof.eq4_proof.read_values_at_cycle[0],
        8,
        cycle_bits,
        stage1_eq4_claim(&proof.lane_values_at_lookup, &proof.decode_proof.read_values_at_cycle),
        &eq4_addrs,
        mle_eval_f_be(eq4_table, &proof.eq4_proof.addr_point),
        &proof.cycle_point,
        "stage1 eq4",
    )?;

    Ok(())
}
