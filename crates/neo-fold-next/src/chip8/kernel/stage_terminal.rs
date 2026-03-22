//! Owns kernel-only terminal closure for Stage 1/2/3 sumchecks after witness reconstruction.

use neo_math::{from_complex, KExtensions, F, K};
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::{
    COL_IS_MEMOP, COL_I_NEXT, COL_MEM_VALUE, COL_PC, COL_REG_X, COL_REG_X_NEXT, COL_WRITES_LOOKUP_TO_X,
    COL_WRITES_MEM_TO_X, COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX, WITNESS_WIDTH,
};
use crate::chip8::tables::{build_unmap_ram, build_unmap_reg, RAM_SINK_ADDR, REG_SINK_ADDR};

use super::verify_support::{split_round_groups, verify_sumcheck_known_with_terminal};
use super::{batch_values, expect_equal_k, expect_equal_k_slice, KernelStepAux, SimpleKernelError};
use super::{Stage1ShoutProof, Stage2TwistProof, Stage3Proof};

const ROM_ADDR_BITS: usize = 11;
const ADDR_REG_BITS: usize = 5;
const ADDR_RAM_BITS: usize = 13;

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

fn sample_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n).map(|_| sample_k(tr, label)).collect()
}

fn build_eq_table(point_le: &[K]) -> Vec<K> {
    let ell = point_le.len();
    let n = 1usize << ell;
    let mut out = vec![K::ONE; n];
    for (i, &ri) in point_le.iter().enumerate() {
        let stride = 1usize << i;
        let block = 1usize << (ell - i - 1);
        let one_minus = K::ONE - ri;
        let mut idx = 0usize;
        for _ in 0..block {
            for j in 0..stride {
                out[idx + j] *= one_minus;
            }
            for j in 0..stride {
                out[idx + stride + j] *= ri;
            }
            idx += 2 * stride;
        }
    }
    out
}

fn mle_eval_f_le(values: &[F], point_le: &[K]) -> K {
    let eq = build_eq_table(point_le);
    values
        .iter()
        .zip(eq.iter())
        .fold(K::ZERO, |acc, (&value, &weight)| acc + K::from(value) * weight)
}

fn mle_eval_k_le(values: &[K], point_le: &[K]) -> K {
    let eq = build_eq_table(point_le);
    values
        .iter()
        .zip(eq.iter())
        .fold(K::ZERO, |acc, (&value, &weight)| acc + value * weight)
}

fn mle_eval_f_be(values: &[F], point_be: &[K]) -> K {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_f_le(values, &point_le)
}

fn mle_eval_k_be(values: &[K], point_be: &[K]) -> K {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_k_le(values, &point_le)
}

fn eq_eval_le(point_a_le: &[K], point_b_le: &[K]) -> K {
    point_a_le
        .iter()
        .zip(point_b_le.iter())
        .fold(K::ONE, |acc, (&a, &b)| acc * ((K::ONE - a) * (K::ONE - b) + a * b))
}

fn eq_eval_be(point_a_be: &[K], point_b_be: &[K]) -> K {
    point_a_be
        .iter()
        .zip(point_b_be.iter())
        .fold(K::ONE, |acc, (&a, &b)| acc * ((K::ONE - a) * (K::ONE - b) + a * b))
}

fn open_onehot_at_point_be(addresses: &[usize], addr_point_be: &[K], cycle_point_le: &[K]) -> K {
    let addr_point_le: Vec<K> = addr_point_be.iter().rev().copied().collect();
    let eq_addr = build_eq_table(&addr_point_le);
    let eq_cycle = build_eq_table(cycle_point_le);
    addresses
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (cycle, &addr)| acc + eq_cycle[cycle] * eq_addr[addr])
}

fn open_onehot_at_point_be_be(addresses: &[usize], addr_point_be: &[K], cycle_point_be: &[K]) -> K {
    let addr_point_le: Vec<K> = addr_point_be.iter().rev().copied().collect();
    let cycle_point_le: Vec<K> = cycle_point_be.iter().rev().copied().collect();
    let eq_addr = build_eq_table(&addr_point_le);
    let eq_cycle = build_eq_table(&cycle_point_le);
    addresses
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (cycle, &addr)| acc + eq_cycle[cycle] * eq_addr[addr])
}

fn open_onehot_at_point_le(addresses: &[usize], addr_point_le: &[K], cycle_point_le: &[K]) -> K {
    let eq_addr = build_eq_table(addr_point_le);
    let eq_cycle = build_eq_table(cycle_point_le);
    addresses
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (cycle, &addr)| acc + eq_cycle[cycle] * eq_addr[addr])
}

fn raw_index_mle_be(point_be: &[K]) -> K {
    let bits = point_be.len();
    point_be
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (idx, &bit)| {
            acc + bit * K::from(F::from_u64(1u64 << (bits - idx - 1)))
        })
}

fn raw_index_mle_le(point_le: &[K]) -> K {
    point_le
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (idx, &bit)| {
            acc + bit * K::from(F::from_u64(1u64 << idx))
        })
}

fn initial_reg_domain(initial_registers: &[u8; 16], initial_i: u16) -> Vec<F> {
    let mut values = vec![F::ZERO; 1usize << ADDR_REG_BITS];
    for idx in 0..16 {
        values[idx] = F::from_u64(initial_registers[idx] as u64);
    }
    values[16] = F::from_u64(initial_i as u64);
    values
}

fn initial_ram_domain(initial_ram: &[u8]) -> Vec<F> {
    let mut values = vec![F::ZERO; 1usize << ADDR_RAM_BITS];
    for (idx, &byte) in initial_ram.iter().enumerate().take(4096) {
        values[idx] = F::from_u64(byte as u64);
    }
    values
}

fn build_lt_table(cycle_bits: usize, point_le: &[K]) -> Vec<K> {
    let n = 1usize << cycle_bits;
    let mut lt = vec![K::ZERO; n];
    for idx in 0..n {
        let mut suffix_eq = vec![K::ONE; cycle_bits + 1];
        for bit in (0..cycle_bits).rev() {
            let j_bit = if (idx >> bit) & 1 == 1 { K::ONE } else { K::ZERO };
            let eq_bit = (K::ONE - j_bit) * (K::ONE - point_le[bit]) + j_bit * point_le[bit];
            suffix_eq[bit] = suffix_eq[bit + 1] * eq_bit;
        }
        let mut acc = K::ZERO;
        for bit in 0..cycle_bits {
            let j_bit = if (idx >> bit) & 1 == 1 { K::ONE } else { K::ZERO };
            acc += (K::ONE - j_bit) * point_le[bit] * suffix_eq[bit + 1];
        }
        lt[idx] = acc;
    }
    lt
}

fn lifted_bools(aux: &[KernelStepAux], selector: impl Fn(&KernelStepAux) -> bool) -> Vec<F> {
    aux.iter()
        .map(|row| if selector(row) { F::ONE } else { F::ZERO })
        .collect()
}

fn lane_col(trace_rows: &[[F; WITNESS_WIDTH]], col: usize) -> Vec<F> {
    trace_rows.iter().map(|row| row[col]).collect()
}

fn value_surface_at_point_le(
    addr_point_le: &[K],
    cycle_point_le: &[K],
    initial_domain: &[F],
    write_addrs: &[usize],
    increments: &[F],
) -> K {
    let init_at_addr = mle_eval_f_le(initial_domain, addr_point_le);
    let eq_addr = build_eq_table(addr_point_le);
    let lt_table = build_lt_table(cycle_point_le.len(), cycle_point_le);
    let delta = increments
        .iter()
        .zip(write_addrs.iter())
        .zip(lt_table.iter())
        .fold(K::ZERO, |acc, ((&inc, &addr), &lt)| {
            acc + K::from(inc) * eq_addr[addr] * lt
        });
    init_at_addr + delta
}

fn build_alu_mixed_table(alu_add8lo: &[F]) -> Vec<F> {
    let size = 1usize << 18;
    let mut table = vec![F::ZERO; size];
    for lhs in 0u64..256 {
        for rhs in 0u64..256 {
            let base = (lhs << 8) | rhs;
            table[(1u64 << 16 | base) as usize] = F::from_u64(lhs);
            table[(2u64 << 16 | base) as usize] = if lhs == rhs { F::ONE } else { F::ZERO };
            table[(3u64 << 16 | base) as usize] = alu_add8lo[(lhs * 256 + rhs) as usize];
        }
    }
    table
}

fn stage1_eq4_claim(lane_values_at_lookup: &[K], decode_values: &[K]) -> K {
    let sixteen = K::from(F::from_u64(16));
    sixteen * lane_values_at_lookup[14] + decode_values[21]
}

fn split_stage2_total_point<'a>(
    point: &'a [K],
    cycle_bits: usize,
    addr_bits: usize,
) -> Result<(&'a [K], &'a [K]), SimpleKernelError> {
    if point.len() != cycle_bits + addr_bits {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "stage2 total point has {} coordinates, expected {}",
            point.len(),
            cycle_bits + addr_bits
        )));
    }
    Ok(point.split_at(cycle_bits))
}

fn verify_stage1_channel_terminals<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &super::ShoutChannelProof,
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

fn verify_stage2_address_terminals<Tr: Transcript>(
    transcript: &mut Tr,
    proof: &super::AddressCorrectnessProof,
    cycle_bits: usize,
    addr_bits: usize,
    selector_addrs: &[usize],
    cycle_point: &[K],
    mapped_claim: K,
    raw_claim: K,
    mapped_coeffs: &[F],
    label: &str,
) -> Result<(), SimpleKernelError> {
    let (bool_point, bool_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        K::ZERO,
        &proof.booleanity_rounds,
        &format!("{label} booleanity"),
    )?;
    let (bool_cycle_point, bool_addr_point) = split_stage2_total_point(&bool_point, cycle_bits, addr_bits)?;
    let bool_selector = open_onehot_at_point_le(selector_addrs, bool_addr_point, bool_cycle_point);
    expect_equal_k(
        bool_terminal,
        bool_selector * (bool_selector - K::ONE),
        &format!("{label} booleanity terminal"),
    )?;

    let (hamming_point, hamming_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        1,
        K::ONE,
        &proof.hamming_weight_rounds,
        &format!("{label} hamming weight"),
    )?;
    let hamming_selector = open_onehot_at_point_le(selector_addrs, &hamming_point, cycle_point);
    expect_equal_k(hamming_terminal, hamming_selector, &format!("{label} hamming terminal"))?;

    let (mapped_point, mapped_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        mapped_claim,
        &proof.decode_consistency_rounds,
        &format!("{label} decode consistency"),
    )?;
    let mapped_selector = open_onehot_at_point_le(selector_addrs, &mapped_point, cycle_point);
    expect_equal_k(
        mapped_terminal,
        mapped_selector * mle_eval_f_le(mapped_coeffs, &mapped_point),
        &format!("{label} mapped terminal"),
    )?;

    let (raw_point, raw_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        raw_claim,
        &proof.raw_address_rounds,
        &format!("{label} raw address"),
    )?;
    let raw_selector = open_onehot_at_point_le(selector_addrs, &raw_point, cycle_point);
    expect_equal_k(
        raw_terminal,
        raw_selector * raw_index_mle_le(&raw_point),
        &format!("{label} raw terminal"),
    )?;
    Ok(())
}

pub(crate) fn verify_kernel_stage2_sumcheck_terminals(
    proof: &Stage2TwistProof,
    trace_rows: &[[F; WITNESS_WIDTH]],
    aux: &[KernelStepAux],
    initial_registers: &[u8; 16],
    initial_i: u16,
    initial_ram: &[u8],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
    let cycle_bits = proof.cycle_point.len();
    let trace_len = 1usize << cycle_bits;
    if aux.len() != trace_len {
        return Err(SimpleKernelError::SumcheckFailed(format!(
            "stage2 aux length {} != expected trace length {trace_len}",
            aux.len()
        )));
    }

    let reg_initial = initial_reg_domain(initial_registers, initial_i);
    let ram_initial = initial_ram_domain(initial_ram);
    let reg_inc: Vec<F> = aux.iter().map(|step| step.reg_inc).collect();
    let ram_inc: Vec<F> = aux.iter().map(|step| step.ram_inc).collect();
    let reg_ra_x_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_x_addr).collect();
    let reg_ra_y_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_y_addr).collect();
    let reg_ra_i_addrs: Vec<_> = aux.iter().map(|step| step.reg_ra_i_addr).collect();
    let reg_wa_addrs: Vec<_> = aux.iter().map(|step| step.reg_wa_addr).collect();
    let ram_ra_addrs: Vec<_> = aux.iter().map(|step| step.ram_ra_addr).collect();
    let ram_wa_addrs: Vec<_> = aux.iter().map(|step| step.ram_wa_addr).collect();

    let writes_lookup_to_x = lane_col(trace_rows, COL_WRITES_LOOKUP_TO_X);
    let writes_mem_to_x = lane_col(trace_rows, COL_WRITES_MEM_TO_X);
    let writes_nnn_to_i = lane_col(trace_rows, COL_WRITES_NNN_TO_I);
    let x_idx_vals = lane_col(trace_rows, COL_X_IDX);
    let y_idx_vals = lane_col(trace_rows, COL_Y_IDX);
    let reg_x_next_vals = lane_col(trace_rows, COL_REG_X_NEXT);
    let i_next_vals = lane_col(trace_rows, COL_I_NEXT);
    let mem_value_vals = lane_col(trace_rows, COL_MEM_VALUE);
    let reg_x_vals = lane_col(trace_rows, COL_REG_X);
    let uses_y_vals = lifted_bools(aux, |row| row.uses_y);
    let reads_ram_vals = lifted_bools(aux, |row| row.reads_ram);
    let writes_ram_vals = lifted_bools(aux, |row| row.writes_ram);
    let write_x_target_flag: Vec<F> = writes_lookup_to_x
        .iter()
        .zip(writes_mem_to_x.iter())
        .map(|(&lookup, &mem)| lookup + mem)
        .collect();
    let idle_ram_flag: Vec<F> = reads_ram_vals
        .iter()
        .zip(writes_ram_vals.iter())
        .map(|(&reads, &writes)| F::ONE - reads - writes)
        .collect();
    let mem_minus_reg_x: Vec<F> = mem_value_vals
        .iter()
        .zip(reg_x_vals.iter())
        .map(|(&mem, &reg_x)| mem - reg_x)
        .collect();
    let unmap_reg = build_unmap_reg();
    let unmap_ram = build_unmap_ram();

    let _ = sample_point(transcript, b"stage2/r_cycle", cycle_bits);
    let _ = sample_k(transcript, b"stage2/gamma_reg");

    let reg_rw_claim = proof.link_claims.wv_reg
        + proof.gamma_reg * proof.link_claims.rv_x
        + proof.gamma_reg * proof.gamma_reg * proof.link_claims.rv_y
        + proof.gamma_reg * proof.gamma_reg * proof.gamma_reg * proof.link_claims.rv_i;
    transcript.append_fields(b"stage2/reg_rw_claim", &reg_rw_claim.as_coeffs());
    let (reg_rw_point, reg_rw_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        reg_rw_claim,
        &proof.reg_rw_batched_rounds,
        "stage2 register read/write",
    )?;
    let (reg_rw_cycle_point, reg_rw_addr_point) = split_stage2_total_point(&reg_rw_point, cycle_bits, ADDR_REG_BITS)?;
    let reg_val_terminal = value_surface_at_point_le(
        reg_rw_addr_point,
        reg_rw_cycle_point,
        &reg_initial,
        &reg_wa_addrs,
        &reg_inc,
    );
    let reg_inc_terminal = mle_eval_f_le(&reg_inc, reg_rw_cycle_point);
    let reg_wa_terminal = open_onehot_at_point_le(&reg_wa_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_ra_x_terminal = open_onehot_at_point_le(&reg_ra_x_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_ra_y_terminal = open_onehot_at_point_le(&reg_ra_y_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_ra_i_terminal = open_onehot_at_point_le(&reg_ra_i_addrs, reg_rw_addr_point, reg_rw_cycle_point);
    let reg_rw_expected = eq_eval_le(&proof.cycle_point, reg_rw_cycle_point)
        * (reg_wa_terminal * (reg_inc_terminal + reg_val_terminal)
            + proof.gamma_reg * reg_ra_x_terminal * reg_val_terminal
            + proof.gamma_reg * proof.gamma_reg * reg_ra_y_terminal * reg_val_terminal
            + proof.gamma_reg * proof.gamma_reg * proof.gamma_reg * reg_ra_i_terminal * reg_val_terminal);
    expect_equal_k(reg_rw_terminal, reg_rw_expected, "stage2 register read/write terminal")?;

    let _ = sample_point(transcript, b"stage2/r_addr_reg", ADDR_REG_BITS);
    transcript.append_fields(b"stage2/reg_val_inc_claim", &proof.reg_val_from_inc_claim.as_coeffs());
    let (reg_val_point, reg_val_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.reg_val_from_inc_claim,
        &proof.reg_val_from_inc_rounds,
        "stage2 register val-from-inc",
    )?;
    let reg_lt = build_lt_table(cycle_bits, &proof.cycle_point);
    let reg_val_expected = mle_eval_f_le(&reg_inc, &reg_val_point)
        * open_onehot_at_point_be(&reg_wa_addrs, &proof.reg_addr_point, &reg_val_point)
        * mle_eval_k_le(&reg_lt, &reg_val_point);
    expect_equal_k(
        reg_val_terminal,
        reg_val_expected,
        "stage2 register val-from-inc terminal",
    )?;

    transcript.append_fields(
        b"stage2/reg_ra_y_target/claim",
        &proof.reg_ra_y_target_proof.claim.as_coeffs(),
    );
    let (reg_ra_y_target_point, reg_ra_y_target_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.reg_ra_y_target_proof.claim,
        &proof.reg_ra_y_target_proof.rounds,
        "stage2 register ra_y target",
    )?;
    let reg_ra_y_target_expected = eq_eval_le(&proof.cycle_point, &reg_ra_y_target_point)
        * mle_eval_f_le(&uses_y_vals, &reg_ra_y_target_point)
        * mle_eval_f_le(&y_idx_vals, &reg_ra_y_target_point);
    expect_equal_k(
        reg_ra_y_target_terminal,
        reg_ra_y_target_expected,
        "stage2 register ra_y target terminal",
    )?;

    transcript.append_fields(
        b"stage2/reg_wa_x_addr_target/claim",
        &proof.reg_wa_addr_target_proof.claim.as_coeffs(),
    );
    let (reg_wa_target_point, reg_wa_target_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.reg_wa_addr_target_proof.claim,
        &proof.reg_wa_addr_target_proof.rounds,
        "stage2 register wa-address target",
    )?;
    let reg_wa_target_expected = eq_eval_le(&proof.cycle_point, &reg_wa_target_point)
        * mle_eval_f_le(&write_x_target_flag, &reg_wa_target_point)
        * mle_eval_f_le(&x_idx_vals, &reg_wa_target_point);
    expect_equal_k(
        reg_wa_target_terminal,
        reg_wa_target_expected,
        "stage2 register wa-address target terminal",
    )?;

    let reg_wa_mapped_claim =
        proof.reg_wa_addr_target_proof.claim + proof.lane_values_at_twist[9] * K::from(F::from_u64(16u64));
    let mapped_reg_claims = [
        proof.lane_values_at_twist[11],
        proof.reg_ra_y_target_proof.claim,
        K::from(F::from_u64(16u64)),
        reg_wa_mapped_claim,
    ];
    let raw_reg_claims = [
        mapped_reg_claims[0],
        mapped_reg_claims[1] + (K::ONE - proof.handoff_values_at_twist[0]) * K::from(F::from_u64(REG_SINK_ADDR as u64)),
        mapped_reg_claims[2],
        mapped_reg_claims[3]
            + (K::ONE - proof.lane_values_at_twist[6] - proof.lane_values_at_twist[7] - proof.lane_values_at_twist[9])
                * K::from(F::from_u64(REG_SINK_ADDR as u64)),
    ];
    verify_stage2_address_terminals(
        transcript,
        &proof.reg_addr_correctness[0],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_ra_x_addrs,
        &proof.cycle_point,
        mapped_reg_claims[0],
        raw_reg_claims[0],
        &unmap_reg,
        "stage2 register address family 0",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &proof.reg_addr_correctness[1],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_ra_y_addrs,
        &proof.cycle_point,
        mapped_reg_claims[1],
        raw_reg_claims[1],
        &unmap_reg,
        "stage2 register address family 1",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &proof.reg_addr_correctness[2],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_ra_i_addrs,
        &proof.cycle_point,
        mapped_reg_claims[2],
        raw_reg_claims[2],
        &unmap_reg,
        "stage2 register address family 2",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &proof.reg_addr_correctness[3],
        cycle_bits,
        ADDR_REG_BITS,
        &reg_wa_addrs,
        &proof.cycle_point,
        mapped_reg_claims[3],
        raw_reg_claims[3],
        &unmap_reg,
        "stage2 register address family 3",
    )?;

    let _ = sample_k(transcript, b"stage2/gamma_ram");
    let ram_rw_claim = proof.link_claims.rv_ram + proof.gamma_ram * proof.link_claims.wv_ram;
    transcript.append_fields(b"stage2/ram_rw_claim", &ram_rw_claim.as_coeffs());
    let (ram_rw_point, ram_rw_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        ram_rw_claim,
        &proof.ram_rw_batched_rounds,
        "stage2 RAM read/write",
    )?;
    let (ram_rw_cycle_point, ram_rw_addr_point) = split_stage2_total_point(&ram_rw_point, cycle_bits, ADDR_RAM_BITS)?;
    let ram_val_terminal = value_surface_at_point_le(
        ram_rw_addr_point,
        ram_rw_cycle_point,
        &ram_initial,
        &ram_wa_addrs,
        &ram_inc,
    );
    let ram_inc_terminal = mle_eval_f_le(&ram_inc, ram_rw_cycle_point);
    let ram_ra_terminal = open_onehot_at_point_le(&ram_ra_addrs, ram_rw_addr_point, ram_rw_cycle_point);
    let ram_wa_terminal = open_onehot_at_point_le(&ram_wa_addrs, ram_rw_addr_point, ram_rw_cycle_point);
    let ram_rw_expected = eq_eval_le(&proof.cycle_point, ram_rw_cycle_point)
        * (ram_ra_terminal * ram_val_terminal
            + proof.gamma_ram * ram_wa_terminal * (ram_inc_terminal + ram_val_terminal));
    expect_equal_k(ram_rw_terminal, ram_rw_expected, "stage2 RAM read/write terminal")?;

    let _ = sample_point(transcript, b"stage2/r_addr_ram", ADDR_RAM_BITS);
    transcript.append_fields(b"stage2/ram_val_inc_claim", &proof.ram_val_from_inc_claim.as_coeffs());
    let (ram_val_point, ram_val_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.ram_val_from_inc_claim,
        &proof.ram_val_from_inc_rounds,
        "stage2 RAM val-from-inc",
    )?;
    let ram_lt = build_lt_table(cycle_bits, &proof.cycle_point);
    let ram_val_expected = mle_eval_f_le(&ram_inc, &ram_val_point)
        * open_onehot_at_point_be(&ram_wa_addrs, &proof.ram_addr_point, &ram_val_point)
        * mle_eval_k_le(&ram_lt, &ram_val_point);
    expect_equal_k(ram_val_terminal, ram_val_expected, "stage2 RAM val-from-inc terminal")?;

    let (ram_raf_read_point, ram_raf_read_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        proof.ram_raf_read_claim,
        &proof.ram_raf_read_rounds,
        "stage2 RAM raf-read",
    )?;
    let ram_raf_read_expected = open_onehot_at_point_le(&ram_ra_addrs, &ram_raf_read_point, &proof.cycle_point)
        * mle_eval_f_le(&unmap_ram, &ram_raf_read_point);
    expect_equal_k(
        ram_raf_read_terminal,
        ram_raf_read_expected,
        "stage2 RAM raf-read terminal",
    )?;

    let (ram_raf_write_point, ram_raf_write_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        proof.ram_raf_write_claim,
        &proof.ram_raf_write_rounds,
        "stage2 RAM raf-write",
    )?;
    let ram_raf_write_expected = open_onehot_at_point_le(&ram_wa_addrs, &ram_raf_write_point, &proof.cycle_point)
        * mle_eval_f_le(&unmap_ram, &ram_raf_write_point);
    expect_equal_k(
        ram_raf_write_terminal,
        ram_raf_write_expected,
        "stage2 RAM raf-write terminal",
    )?;

    let mapped_ram_claims = [proof.ram_raf_read_claim, proof.ram_raf_write_claim];
    let raw_ram_claims = [
        mapped_ram_claims[0] + (K::ONE - proof.handoff_values_at_twist[1]) * K::from(F::from_u64(RAM_SINK_ADDR as u64)),
        mapped_ram_claims[1] + (K::ONE - proof.handoff_values_at_twist[2]) * K::from(F::from_u64(RAM_SINK_ADDR as u64)),
    ];
    verify_stage2_address_terminals(
        transcript,
        &proof.ram_addr_correctness[0],
        cycle_bits,
        ADDR_RAM_BITS,
        &ram_ra_addrs,
        &proof.cycle_point,
        mapped_ram_claims[0],
        raw_ram_claims[0],
        &unmap_ram,
        "stage2 RAM address family 0",
    )?;
    verify_stage2_address_terminals(
        transcript,
        &proof.ram_addr_correctness[1],
        cycle_bits,
        ADDR_RAM_BITS,
        &ram_wa_addrs,
        &proof.cycle_point,
        mapped_ram_claims[1],
        raw_ram_claims[1],
        &unmap_ram,
        "stage2 RAM address family 1",
    )?;

    transcript.append_fields(
        b"stage2/reg_write_x_target/claim",
        &proof.reg_write_x_target_proof.claim.as_coeffs(),
    );
    let (reg_write_x_point, reg_write_x_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.reg_write_x_target_proof.claim,
        &proof.reg_write_x_target_proof.rounds,
        "stage2 register write-to-x target",
    )?;
    let reg_write_x_expected = eq_eval_le(&proof.cycle_point, &reg_write_x_point)
        * mle_eval_f_le(&write_x_target_flag, &reg_write_x_point)
        * mle_eval_f_le(&reg_x_next_vals, &reg_write_x_point);
    expect_equal_k(
        reg_write_x_terminal,
        reg_write_x_expected,
        "stage2 register write-to-x target terminal",
    )?;

    transcript.append_fields(
        b"stage2/reg_write_i_target/claim",
        &proof.reg_write_i_target_proof.claim.as_coeffs(),
    );
    let (reg_write_i_point, reg_write_i_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.reg_write_i_target_proof.claim,
        &proof.reg_write_i_target_proof.rounds,
        "stage2 register write-to-i target",
    )?;
    let reg_write_i_expected = eq_eval_le(&proof.cycle_point, &reg_write_i_point)
        * mle_eval_f_le(&writes_nnn_to_i, &reg_write_i_point)
        * mle_eval_f_le(&i_next_vals, &reg_write_i_point);
    expect_equal_k(
        reg_write_i_terminal,
        reg_write_i_expected,
        "stage2 register write-to-i target terminal",
    )?;

    transcript.append_fields(
        b"stage2/ram_read_target/claim",
        &proof.ram_read_target_proof.claim.as_coeffs(),
    );
    let (ram_read_point, ram_read_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.ram_read_target_proof.claim,
        &proof.ram_read_target_proof.rounds,
        "stage2 RAM read target",
    )?;
    let ram_read_expected = eq_eval_le(&proof.cycle_point, &ram_read_point)
        * mle_eval_f_le(&reads_ram_vals, &ram_read_point)
        * mle_eval_f_le(&mem_value_vals, &ram_read_point);
    expect_equal_k(ram_read_terminal, ram_read_expected, "stage2 RAM read target terminal")?;

    transcript.append_fields(
        b"stage2/ram_write_target/claim",
        &proof.ram_write_target_proof.claim.as_coeffs(),
    );
    let (ram_write_point, ram_write_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.ram_write_target_proof.claim,
        &proof.ram_write_target_proof.rounds,
        "stage2 RAM write target",
    )?;
    let ram_write_expected = eq_eval_le(&proof.cycle_point, &ram_write_point)
        * mle_eval_f_le(&writes_ram_vals, &ram_write_point)
        * mle_eval_f_le(&mem_value_vals, &ram_write_point);
    expect_equal_k(
        ram_write_terminal,
        ram_write_expected,
        "stage2 RAM write target terminal",
    )?;

    transcript.append_fields(
        b"stage2/ram_write_matches_x_zero/claim",
        &proof.ram_write_matches_x_zero_proof.claim.as_coeffs(),
    );
    let (ram_write_x_point, ram_write_x_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.ram_write_matches_x_zero_proof.claim,
        &proof.ram_write_matches_x_zero_proof.rounds,
        "stage2 RAM write matches REG_X",
    )?;
    let ram_write_x_expected = eq_eval_le(&proof.cycle_point, &ram_write_x_point)
        * mle_eval_f_le(&writes_ram_vals, &ram_write_x_point)
        * mle_eval_f_le(&mem_minus_reg_x, &ram_write_x_point);
    expect_equal_k(
        ram_write_x_terminal,
        ram_write_x_expected,
        "stage2 RAM write matches REG_X terminal",
    )?;

    transcript.append_fields(
        b"stage2/ram_idle_mem_zero/claim",
        &proof.ram_idle_mem_zero_proof.claim.as_coeffs(),
    );
    let (ram_idle_point, ram_idle_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        3,
        proof.ram_idle_mem_zero_proof.claim,
        &proof.ram_idle_mem_zero_proof.rounds,
        "stage2 MEM_VALUE zero on idle rows",
    )?;
    let ram_idle_expected = eq_eval_le(&proof.cycle_point, &ram_idle_point)
        * mle_eval_f_le(&idle_ram_flag, &ram_idle_point)
        * mle_eval_f_le(&mem_value_vals, &ram_idle_point);
    expect_equal_k(
        ram_idle_terminal,
        ram_idle_expected,
        "stage2 MEM_VALUE zero on idle rows terminal",
    )?;

    Ok(())
}

pub(crate) fn verify_kernel_stage3_sumcheck_terminal(
    proof: &Stage3Proof,
    trace_rows: &[[F; WITNESS_WIDTH]],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), SimpleKernelError> {
    let cycle_bits = proof.shift_proof.source_point.len();
    let _ = sample_k(transcript, b"stage3/beta1");
    let _ = sample_k(transcript, b"stage3/beta2");
    let _ = sample_point(transcript, b"stage3/r_shift", cycle_bits);
    let gamma_shift = sample_k(transcript, b"stage3/gamma_shift");

    let batched_shift_claim = proof.shift_proof.claimed_shift_values[0]
        + gamma_shift * proof.shift_proof.claimed_shift_values[1]
        + gamma_shift * gamma_shift * proof.shift_proof.claimed_shift_values[2];
    let (shift_point, shift_terminal) = verify_sumcheck_known_with_terminal(
        transcript,
        2,
        batched_shift_claim,
        &proof.shift_proof.reduction_rounds,
        "stage3 lane shift",
    )?;
    let mut shifted_batched_col = Vec::with_capacity(trace_rows.len());
    for row in trace_rows.iter().skip(1) {
        shifted_batched_col.push(
            K::from(row[COL_PC])
                + gamma_shift * K::from(row[COL_X_IDX])
                + gamma_shift * gamma_shift * K::from(row[COL_IS_MEMOP]),
        );
    }
    shifted_batched_col.push(K::ZERO);
    let expected_terminal =
        eq_eval_be(&proof.shift_proof.source_point, &shift_point) * mle_eval_k_be(&shifted_batched_col, &shift_point);
    expect_equal_k(shift_terminal, expected_terminal, "stage3 lane shift terminal")
}
