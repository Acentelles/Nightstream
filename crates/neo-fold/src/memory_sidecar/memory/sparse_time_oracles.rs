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
    pub gamma_group: Option<usize>,
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
    pub twist: Vec<RouteATwistTimeOracles>,
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
