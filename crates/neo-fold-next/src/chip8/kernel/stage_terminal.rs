//! Owns kernel-only terminal closure for Stage 1/2/3 sumchecks after witness reconstruction.

mod stage1;
mod stage2;
mod stage3;

use neo_math::{from_complex, F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use crate::chip8::poly::{build_eq_table, mle_eval_f_le};

use super::{KernelStepAux, SimpleKernelError};

const ROM_ADDR_BITS: usize = 11;
const ADDR_REG_BITS: usize = 5;
const ADDR_RAM_BITS: usize = 13;

pub(crate) use stage1::{
    verify_kernel_stage1_sumcheck_terminals, verify_kernel_stage1_sumcheck_terminals_from_execution,
};
pub(crate) use stage2::{
    verify_kernel_stage2_sumcheck_terminals, verify_kernel_stage2_sumcheck_terminals_from_execution,
};
pub(crate) use stage3::{
    verify_kernel_stage3_sumcheck_terminal, verify_kernel_stage3_sumcheck_terminal_from_execution,
};

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}

fn sample_point<Tr: Transcript>(tr: &mut Tr, label: &'static [u8], n: usize) -> Vec<K> {
    (0..n).map(|_| sample_k(tr, label)).collect()
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

fn lane_col<const WIDTH: usize>(trace_rows: &[[F; WIDTH]], col: usize) -> Vec<F> {
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
