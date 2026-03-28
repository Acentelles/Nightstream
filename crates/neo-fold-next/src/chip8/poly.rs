//! Owns pure CHIP-8-local MLE and one-hot helpers shared by stage and kernel modules.
//! It does not own transcript scheduling or proof semantics.

use neo_math::{F, K};
use p3_field::PrimeCharacteristicRing;

pub(crate) fn build_eq_table(point_le: &[K]) -> Vec<K> {
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
                let value = out[idx + j];
                out[idx + j] = value * one_minus;
            }
            for j in 0..stride {
                let value = out[idx + stride + j];
                out[idx + stride + j] = value * ri;
            }
            idx += 2 * stride;
        }
    }
    out
}

pub(crate) fn mle_eval_f_le(values: &[F], point_le: &[K]) -> K {
    let eq = build_eq_table(point_le);
    debug_assert_eq!(values.len(), eq.len());
    values
        .iter()
        .zip(eq.iter())
        .fold(K::ZERO, |acc, (&value, &weight)| acc + K::from(value) * weight)
}

pub(crate) fn mle_eval_k_le(values: &[K], point_le: &[K]) -> K {
    let eq = build_eq_table(point_le);
    debug_assert_eq!(values.len(), eq.len());
    values
        .iter()
        .zip(eq.iter())
        .fold(K::ZERO, |acc, (&value, &weight)| acc + value * weight)
}

pub(crate) fn mle_eval_f_be(values: &[F], point_be: &[K]) -> K {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_f_le(values, &point_le)
}

pub(crate) fn mle_eval_k_be(values: &[K], point_be: &[K]) -> K {
    let point_le: Vec<K> = point_be.iter().rev().copied().collect();
    mle_eval_k_le(values, &point_le)
}

pub(crate) fn eq_eval_le(point_a_le: &[K], point_b_le: &[K]) -> K {
    point_a_le
        .iter()
        .zip(point_b_le.iter())
        .fold(K::ONE, |acc, (&a, &b)| acc * ((K::ONE - a) * (K::ONE - b) + a * b))
}

pub(crate) fn open_onehot_at_point_be(addresses: &[usize], addr_point_be: &[K], cycle_point_le: &[K]) -> K {
    let addr_point_le: Vec<K> = addr_point_be.iter().rev().copied().collect();
    let eq_addr = build_eq_table(&addr_point_le);
    let eq_cycle = build_eq_table(cycle_point_le);
    addresses
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (cycle, &addr)| acc + eq_cycle[cycle] * eq_addr[addr])
}

pub(crate) fn open_onehot_at_point_be_be(addresses: &[usize], addr_point_be: &[K], cycle_point_be: &[K]) -> K {
    let cycle_point_le: Vec<K> = cycle_point_be.iter().rev().copied().collect();
    open_onehot_at_point_be(addresses, addr_point_be, &cycle_point_le)
}

pub(crate) fn open_onehot_at_point_le(addresses: &[usize], addr_point_le: &[K], cycle_point_le: &[K]) -> K {
    let eq_addr = build_eq_table(addr_point_le);
    let eq_cycle = build_eq_table(cycle_point_le);
    addresses
        .iter()
        .enumerate()
        .fold(K::ZERO, |acc, (cycle, &addr)| acc + eq_cycle[cycle] * eq_addr[addr])
}
