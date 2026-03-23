use neo_math::K;
use neo_reductions::sumcheck::{BatchedClaim, RoundOracle};
use p3_field::PrimeCharacteristicRing;

use crate::memory_sidecar::memory::{
    InstructionLookupGammaGroupOracles, InstructionLookupTimeOracles, TimeBatchedClaims,
};
use crate::memory_sidecar::utils::RoundOraclePrefix;
use crate::PiCcsError;

pub struct InstructionLookupTimeClaimsGuard<'a> {
    pub lane_ranges: Vec<core::ops::Range<usize>>,
    pub lanes: Vec<InstructionLookupTimeLaneClaims<'a>>,
    pub gamma_groups: Vec<InstructionLookupTimeGammaGroupClaims<'a>>,
    pub bitness: Vec<Vec<Box<dyn RoundOracle + Send>>>,
}

pub struct InstructionLookupTimeLaneClaims<'a> {
    pub value_prefix: RoundOraclePrefix<'a>,
    pub adapter_prefix: RoundOraclePrefix<'a>,
    pub value_claim: K,
    pub adapter_claim: K,
    pub gamma_group: Option<usize>,
}

pub struct InstructionLookupTimeGammaGroupClaims<'a> {
    pub value_prefix: RoundOraclePrefix<'a>,
    pub adapter_prefix: RoundOraclePrefix<'a>,
    pub bitness_prefix: RoundOraclePrefix<'a>,
    pub value_claim: K,
    pub adapter_claim: K,
}

pub fn build_instruction_lookup_time_claims_guard<'a>(
    instruction_lookup_oracles: &'a mut [InstructionLookupTimeOracles],
    instruction_lookup_gamma_groups: &'a mut [InstructionLookupGammaGroupOracles],
    ell_n: usize,
) -> InstructionLookupTimeClaimsGuard<'a> {
    let mut lane_ranges = Vec::with_capacity(instruction_lookup_oracles.len());
    let mut lanes = Vec::new();
    let mut gamma_groups = Vec::with_capacity(instruction_lookup_gamma_groups.len());
    let mut bitness = Vec::with_capacity(instruction_lookup_oracles.len());

    for o in instruction_lookup_oracles.iter_mut() {
        bitness.push(core::mem::take(&mut o.bitness));
        let start = lanes.len();
        for lane in o.lanes.iter_mut() {
            lanes.push(InstructionLookupTimeLaneClaims {
                value_prefix: RoundOraclePrefix::new(lane.value.as_mut(), ell_n),
                adapter_prefix: RoundOraclePrefix::new(lane.adapter.as_mut(), ell_n),
                value_claim: lane.value_claim,
                adapter_claim: lane.adapter_claim,
                gamma_group: lane.gamma_group,
            });
        }
        let end = lanes.len();
        lane_ranges.push(start..end);
    }

    for g in instruction_lookup_gamma_groups.iter_mut() {
        gamma_groups.push(InstructionLookupTimeGammaGroupClaims {
            value_prefix: RoundOraclePrefix::new(g.value.as_mut(), ell_n),
            adapter_prefix: RoundOraclePrefix::new(g.adapter.as_mut(), ell_n),
            bitness_prefix: RoundOraclePrefix::new(g.bitness.as_mut(), ell_n),
            value_claim: g.value_claim,
            adapter_claim: g.adapter_claim,
        });
    }

    InstructionLookupTimeClaimsGuard {
        lane_ranges,
        lanes,
        gamma_groups,
        bitness,
    }
}

pub struct InstructionLookupTimeProtocol<'a> {
    guard: InstructionLookupTimeClaimsGuard<'a>,
}

impl<'a> InstructionLookupTimeProtocol<'a> {
    pub fn new(
        instruction_lookup_oracles: &'a mut [InstructionLookupTimeOracles],
        instruction_lookup_gamma_groups: &'a mut [InstructionLookupGammaGroupOracles],
        ell_n: usize,
    ) -> Self {
        Self {
            guard: build_instruction_lookup_time_claims_guard(
                instruction_lookup_oracles,
                instruction_lookup_gamma_groups,
                ell_n,
            ),
        }
    }
}

impl<'o> TimeBatchedClaims for InstructionLookupTimeProtocol<'o> {
    fn append_time_claims<'a>(
        &'a mut self,
        _ell_n: usize,
        claimed_sums: &mut Vec<K>,
        degree_bounds: &mut Vec<usize>,
        labels: &mut Vec<&'static [u8]>,
        claim_is_dynamic: &mut Vec<bool>,
        claims: &mut Vec<BatchedClaim<'a>>,
    ) -> Result<(), PiCcsError> {
        append_instruction_lookup_time_claims(
            &mut self.guard,
            claimed_sums,
            degree_bounds,
            labels,
            claim_is_dynamic,
            claims,
        )
    }
}

pub fn append_instruction_lookup_time_claims<'a>(
    guard: &'a mut InstructionLookupTimeClaimsGuard<'_>,
    claimed_sums: &mut Vec<K>,
    degree_bounds: &mut Vec<usize>,
    labels: &mut Vec<&'static [u8]>,
    claim_is_dynamic: &mut Vec<bool>,
    claims: &mut Vec<BatchedClaim<'a>>,
) -> Result<(), PiCcsError> {
    if guard.lane_ranges.is_empty() {
        return Ok(());
    }
    if guard.bitness.len() != guard.lane_ranges.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "instruction lookup bitness count mismatch (bitness={}, lane_ranges={})",
            guard.bitness.len(),
            guard.lane_ranges.len()
        )));
    }

    let mut lane_ranges_iter = guard.lane_ranges.iter();
    let mut next_end = lane_ranges_iter
        .next()
        .ok_or_else(|| PiCcsError::ProtocolError("instruction lookup lane_ranges unexpectedly empty".into()))?
        .end;
    let mut bitness_iter = guard.bitness.iter_mut();

    for (lane_idx, lane) in guard.lanes.iter_mut().enumerate() {
        if lane.gamma_group.is_none() {
            claimed_sums.push(lane.value_claim);
            degree_bounds.push(lane.value_prefix.degree_bound());
            labels.push(b"instruction_lookup/value");
            claim_is_dynamic.push(true);
            claims.push(BatchedClaim {
                oracle: &mut lane.value_prefix,
                claimed_sum: lane.value_claim,
                label: b"instruction_lookup/value",
            });

            claimed_sums.push(lane.adapter_claim);
            degree_bounds.push(lane.adapter_prefix.degree_bound());
            labels.push(b"instruction_lookup/adapter");
            claim_is_dynamic.push(true);
            claims.push(BatchedClaim {
                oracle: &mut lane.adapter_prefix,
                claimed_sum: lane.adapter_claim,
                label: b"instruction_lookup/adapter",
            });
        }

        if lane_idx + 1 == next_end {
            let bitness_vec = bitness_iter.next().ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "instruction lookup bitness idx drift at lane_idx={lane_idx} (missing bitness vector)"
                ))
            })?;
            for bit_oracle in bitness_vec.iter_mut() {
                claimed_sums.push(K::ZERO);
                degree_bounds.push(bit_oracle.degree_bound());
                labels.push(b"instruction_lookup/bitness");
                claim_is_dynamic.push(false);
                claims.push(BatchedClaim {
                    oracle: bit_oracle.as_mut(),
                    claimed_sum: K::ZERO,
                    label: b"instruction_lookup/bitness",
                });
            }
            next_end = lane_ranges_iter.next().map(|r| r.end).unwrap_or(usize::MAX);
        }
    }

    for group in guard.gamma_groups.iter_mut() {
        claimed_sums.push(group.value_claim);
        degree_bounds.push(group.value_prefix.degree_bound());
        labels.push(b"instruction_lookup/value");
        claim_is_dynamic.push(true);
        claims.push(BatchedClaim {
            oracle: &mut group.value_prefix,
            claimed_sum: group.value_claim,
            label: b"instruction_lookup/value",
        });

        claimed_sums.push(group.adapter_claim);
        degree_bounds.push(group.adapter_prefix.degree_bound());
        labels.push(b"instruction_lookup/adapter");
        claim_is_dynamic.push(true);
        claims.push(BatchedClaim {
            oracle: &mut group.adapter_prefix,
            claimed_sum: group.adapter_claim,
            label: b"instruction_lookup/adapter",
        });

        claimed_sums.push(K::ZERO);
        degree_bounds.push(group.bitness_prefix.degree_bound());
        labels.push(b"instruction_lookup/bitness");
        claim_is_dynamic.push(false);
        claims.push(BatchedClaim {
            oracle: &mut group.bitness_prefix,
            claimed_sum: K::ZERO,
            label: b"instruction_lookup/bitness",
        });
    }

    if bitness_iter.next().is_some() {
        return Err(PiCcsError::ProtocolError(
            "instruction lookup bitness not fully consumed after lane claim assembly".into(),
        ));
    }
    Ok(())
}
