//! Route-A sparse decoded columns, time oracles, and preproof payloads.
//!
//! This module owns the sparse-oracle and preproof data that is carried between
//! address preprocessing, oracle construction, and Route-A verification.

use super::*;

pub(crate) struct ShoutDecodedColsSparse {
    pub lanes: Vec<ShoutLaneSparseCols>,
}

pub(crate) struct ShoutLaneSparseCols {
    pub addr_bits: Vec<SparseIdxVec<K>>,
    pub has_lookup: SparseIdxVec<K>,
    pub val: SparseIdxVec<K>,
}

pub(crate) struct TwistDecodedColsSparse {
    pub lanes: Vec<TwistLaneSparseCols>,
}

pub(crate) struct SumRoundOracle {
    oracles: Vec<Box<dyn RoundOracle + Send>>,
    num_rounds: usize,
    degree_bound: usize,
}

impl SumRoundOracle {
    pub(crate) fn new(oracles: Vec<Box<dyn RoundOracle + Send>>) -> Result<Self, PiCcsError> {
        if oracles.is_empty() {
            return Err(PiCcsError::ProtocolError(
                "SumRoundOracle requires at least one oracle".into(),
            ));
        }

        let num_rounds = oracles[0].num_rounds();
        let degree_bound = oracles[0].degree_bound();
        for (idx, o) in oracles.iter().enumerate().skip(1) {
            if o.num_rounds() != num_rounds {
                return Err(PiCcsError::ProtocolError(format!(
                    "SumRoundOracle num_rounds mismatch at idx={idx} (got {}, expected {num_rounds})",
                    o.num_rounds()
                )));
            }
            if o.degree_bound() != degree_bound {
                return Err(PiCcsError::ProtocolError(format!(
                    "SumRoundOracle degree_bound mismatch at idx={idx} (got {}, expected {degree_bound})",
                    o.degree_bound()
                )));
            }
        }

        Ok(Self {
            oracles,
            num_rounds,
            degree_bound,
        })
    }
}

impl RoundOracle for SumRoundOracle {
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        let mut acc = vec![K::ZERO; points.len()];
        for o in self.oracles.iter_mut() {
            let ys = o.evals_at(points);
            if ys.len() != acc.len() {
                let n = core::cmp::min(ys.len(), acc.len());
                for i in 0..n {
                    acc[i] += ys[i];
                }
                continue;
            }
            for (a, y) in acc.iter_mut().zip(ys) {
                *a += y;
            }
        }
        acc
    }

    fn num_rounds(&self) -> usize {
        self.num_rounds
    }

    fn degree_bound(&self) -> usize {
        self.degree_bound
    }

    fn fold(&mut self, r: K) {
        for o in self.oracles.iter_mut() {
            o.fold(r);
        }
        self.num_rounds = self.oracles[0].num_rounds();
    }
}

#[inline]
pub(crate) fn interp(a0: K, a1: K, x: K) -> K {
    a0 + (a1 - a0) * x
}

pub(crate) fn log2_pow2(n: usize) -> usize {
    if n == 0 {
        return 0;
    }
    debug_assert!(n.is_power_of_two(), "expected power of two, got {n}");
    n.trailing_zeros() as usize
}

pub(crate) fn gather_pairs_from_sparse(entries: &[(usize, K)]) -> Vec<usize> {
    let mut out: Vec<usize> = Vec::with_capacity(entries.len());
    let mut prev: Option<usize> = None;
    for &(idx, _v) in entries {
        let p = idx >> 1;
        if prev != Some(p) {
            out.push(p);
            prev = Some(p);
        }
    }
    out
}

/// Sparse time-domain oracle for event-table RV32 Shout hash linkage.
pub(crate) struct ShoutEventTableHashOracleSparseTime {
    degree_bound: usize,
    r_addr: Vec<K>,
    time_bits: Vec<SparseIdxVec<K>>,
    has_lookup: SparseIdxVec<K>,
    val: SparseIdxVec<K>,
    lhs: SparseIdxVec<K>,
    rhs_terms: Vec<(SparseIdxVec<K>, K)>,
    alpha: K,
    beta: K,
    gamma: K,
}

impl ShoutEventTableHashOracleSparseTime {
    #[allow(clippy::too_many_arguments)]
    pub(crate) fn new(
        r_addr: &[K],
        time_bits: Vec<SparseIdxVec<K>>,
        has_lookup: SparseIdxVec<K>,
        val: SparseIdxVec<K>,
        lhs: SparseIdxVec<K>,
        rhs_terms: Vec<(SparseIdxVec<K>, K)>,
        alpha: K,
        beta: K,
        gamma: K,
    ) -> (Self, K) {
        let ell_n = log2_pow2(has_lookup.len());
        debug_assert_eq!(val.len(), 1usize << ell_n);
        debug_assert_eq!(lhs.len(), 1usize << ell_n);
        for (i, col) in time_bits.iter().enumerate() {
            debug_assert_eq!(col.len(), 1usize << ell_n, "time_bits[{i}] length mismatch");
        }
        for (i, (col, _w)) in rhs_terms.iter().enumerate() {
            debug_assert_eq!(col.len(), 1usize << ell_n, "rhs_terms[{i}] length mismatch");
        }
        debug_assert_eq!(time_bits.len(), r_addr.len(), "time_bits/r_addr length mismatch");

        let mut claim = K::ZERO;
        for &(t, gate) in has_lookup.entries() {
            if gate == K::ZERO {
                continue;
            }

            let v_t = val.get(t);
            let lhs_t = lhs.get(t);
            let mut rhs_t = K::ZERO;
            for (col, w) in rhs_terms.iter() {
                rhs_t += *w * col.get(t);
            }

            let hash_t = K::ONE + alpha * v_t + beta * lhs_t + gamma * rhs_t;
            if hash_t == K::ZERO {
                continue;
            }

            let mut eq_addr = K::ONE;
            for (b, col) in time_bits.iter().enumerate() {
                eq_addr *= eq_bit_affine(col.get(t), r_addr[b]);
            }

            claim += gate * hash_t * eq_addr;
        }

        (
            Self {
                degree_bound: 2 + r_addr.len(),
                r_addr: r_addr.to_vec(),
                time_bits,
                has_lookup,
                val,
                lhs,
                rhs_terms,
                alpha,
                beta,
                gamma,
            },
            claim,
        )
    }
}

impl RoundOracle for ShoutEventTableHashOracleSparseTime {
    fn evals_at(&mut self, points: &[K]) -> Vec<K> {
        if self.has_lookup.len() == 1 {
            let gate = self.has_lookup.singleton_value();
            let v = self.val.singleton_value();
            let lhs = self.lhs.singleton_value();
            let mut rhs = K::ZERO;
            for (col, w) in self.rhs_terms.iter() {
                rhs += *w * col.singleton_value();
            }
            let hash = gate * (K::ONE + self.alpha * v + self.beta * lhs + self.gamma * rhs);

            let mut eq_addr = K::ONE;
            for (b, col) in self.time_bits.iter().enumerate() {
                eq_addr *= eq_bit_affine(col.singleton_value(), self.r_addr[b]);
            }

            let out = hash * eq_addr;
            return vec![out; points.len()];
        }

        let pairs = gather_pairs_from_sparse(self.has_lookup.entries());
        let half = self.has_lookup.len() / 2;
        debug_assert!(pairs.iter().all(|&p| p < half));

        let mut ys = vec![K::ZERO; points.len()];
        for &pair in &pairs {
            let child0 = 2 * pair;
            let child1 = child0 + 1;

            let gate0 = self.has_lookup.get(child0);
            let gate1 = self.has_lookup.get(child1);
            if gate0 == K::ZERO && gate1 == K::ZERO {
                continue;
            }

            let v0 = self.val.get(child0);
            let v1 = self.val.get(child1);
            let lhs0 = self.lhs.get(child0);
            let lhs1 = self.lhs.get(child1);

            let mut rhs0 = K::ZERO;
            let mut rhs1 = K::ZERO;
            for (col, w) in self.rhs_terms.iter() {
                rhs0 += *w * col.get(child0);
                rhs1 += *w * col.get(child1);
            }

            let mut eq0s: Vec<K> = Vec::with_capacity(self.time_bits.len());
            let mut d_eqs: Vec<K> = Vec::with_capacity(self.time_bits.len());
            for (b, col) in self.time_bits.iter().enumerate() {
                let e0 = eq_bit_affine(col.get(child0), self.r_addr[b]);
                let e1 = eq_bit_affine(col.get(child1), self.r_addr[b]);
                eq0s.push(e0);
                d_eqs.push(e1 - e0);
            }

            for (i, &x) in points.iter().enumerate() {
                let gate_x = interp(gate0, gate1, x);
                if gate_x == K::ZERO {
                    continue;
                }
                let v_x = interp(v0, v1, x);
                let lhs_x = interp(lhs0, lhs1, x);
                let rhs_x = interp(rhs0, rhs1, x);

                let mut prod = gate_x * (K::ONE + self.alpha * v_x + self.beta * lhs_x + self.gamma * rhs_x);
                for (e0, de) in eq0s.iter().zip(d_eqs.iter()) {
                    prod *= *e0 + *de * x;
                }
                ys[i] += prod;
            }
        }

        ys
    }

    fn num_rounds(&self) -> usize {
        log2_pow2(self.has_lookup.len())
    }

    fn degree_bound(&self) -> usize {
        self.degree_bound
    }

    fn fold(&mut self, r: K) {
        if self.num_rounds() == 0 {
            return;
        }
        self.has_lookup.fold_round_in_place(r);
        self.val.fold_round_in_place(r);
        self.lhs.fold_round_in_place(r);
        for (col, _w) in self.rhs_terms.iter_mut() {
            col.fold_round_in_place(r);
        }
        for col in self.time_bits.iter_mut() {
            col.fold_round_in_place(r);
        }
    }
}

pub(crate) fn build_twist_inc_terms_at_r_addr(lanes: &[TwistLaneSparseCols], r_addr: &[K]) -> Vec<(usize, K)> {
    let ell_addr = r_addr.len();
    let mut out: Vec<(usize, K)> = Vec::new();

    for lane in lanes {
        debug_assert_eq!(lane.wa_bits.len(), ell_addr, "wa_bits len mismatch");
        for &(t, has_w) in lane.has_write.entries() {
            let inc_t = lane.inc_at_write_addr.get(t);
            if has_w == K::ZERO || inc_t == K::ZERO {
                continue;
            }

            let mut eq_addr = K::ONE;
            for (b, col) in lane.wa_bits.iter().enumerate() {
                let bit = col.get(t);
                eq_addr *= eq_bit_affine(bit, r_addr[b]);
            }

            let inc_at_r_addr = has_w * inc_t * eq_addr;
            if inc_at_r_addr != K::ZERO {
                out.push((t, inc_at_r_addr));
            }
        }
    }

    out
}

pub struct RouteAShoutTimeOracles {
    pub lanes: Vec<RouteAShoutTimeLaneOracles>,
    pub bitness: Vec<Box<dyn RoundOracle + Send>>,
}

pub struct RouteAShoutTimeLaneOracles {
    pub value: Box<dyn RoundOracle + Send>,
    pub value_claim: K,
    pub adapter: Box<dyn RoundOracle + Send>,
    pub adapter_claim: K,
    pub event_table_hash: Option<Box<dyn RoundOracle + Send>>,
    pub event_table_hash_claim: Option<K>,
    pub gamma_group: Option<usize>,
    pub transport_only: bool,
}

pub struct RouteAShoutGammaGroupOracles {
    pub value: Box<dyn RoundOracle + Send>,
    pub value_claim: K,
    pub adapter: Box<dyn RoundOracle + Send>,
    pub adapter_claim: K,
    pub bitness: Box<dyn RoundOracle + Send>,
}

pub struct RouteATwistTimeOracles {
    pub read_check: Box<dyn RoundOracle + Send>,
    pub write_check: Box<dyn RoundOracle + Send>,
    pub bitness: Vec<Box<dyn RoundOracle + Send>>,
    pub virtual_write_domain: Option<Box<dyn RoundOracle + Send>>,
    pub nonvirtual_arch_domain: Option<Box<dyn RoundOracle + Send>>,
}

pub struct RouteAMemoryOracles {
    pub shout: Vec<RouteAShoutTimeOracles>,
    pub shout_gamma_groups: Vec<RouteAShoutGammaGroupOracles>,
    pub shout_event_trace_hash: Option<RouteAShoutEventTraceHashOracle>,
    pub twist: Vec<RouteATwistTimeOracles>,
}

pub struct RouteAShoutEventTraceHashOracle {
    pub oracle: Box<dyn RoundOracle + Send>,
    pub claim: K,
}

pub trait TimeBatchedClaims {
    fn append_time_claims<'a>(
        &'a mut self,
        ell_n: usize,
        claimed_sums: &mut Vec<K>,
        degree_bounds: &mut Vec<usize>,
        labels: &mut Vec<&'static [u8]>,
        claim_is_dynamic: &mut Vec<bool>,
        claims: &mut Vec<BatchedClaim<'a>>,
    ) -> Result<(), PiCcsError>;
}

pub(crate) struct ShoutAddrPreBatchProverData {
    pub addr_pre: ShoutAddrPreProof<K>,
    pub decoded: Vec<ShoutDecodedColsSparse>,
}

#[derive(Clone, Debug)]
pub struct ShoutAddrPreVerifyData {
    pub is_active: bool,
    pub addr_claim_sum: K,
    pub addr_final: K,
    pub r_addr: Vec<K>,
    pub table_eval_at_r_addr: K,
}

pub(crate) struct TwistAddrPreProverData {
    pub addr_pre: BatchedAddrProof<K>,
    pub decoded: TwistDecodedColsSparse,
    pub read_check_claim_sum: K,
    pub write_check_claim_sum: K,
}

pub struct TwistAddrPreVerifyData {
    pub r_addr: Vec<K>,
    pub read_check_claim_sum: K,
    pub write_check_claim_sum: K,
}

#[derive(Clone, Debug)]
pub struct TwistTimeLaneOpeningsLane {
    pub has_read: K,
    pub wa_bits: Vec<K>,
    pub has_write: K,
    pub wv: K,
    pub inc_at_write_addr: K,
}

#[derive(Clone, Debug)]
pub struct TwistTimeLaneOpenings {
    pub lanes: Vec<TwistTimeLaneOpeningsLane>,
}

#[derive(Clone, Debug)]
pub struct RouteAMemoryVerifyOutput {
    pub claim_idx_end: usize,
    pub twist_time_openings: Vec<TwistTimeLaneOpenings>,
}
