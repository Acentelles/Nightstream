use super::*;

pub struct RouteAShoutTimeClaimsGuard<'a> {
    pub lane_ranges: Vec<core::ops::Range<usize>>,
    pub lanes: Vec<RouteAShoutTimeLaneClaims<'a>>,
    pub gamma_groups: Vec<RouteAShoutTimeGammaGroupClaims<'a>>,
    pub bitness: Vec<Vec<Box<dyn RoundOracle + Send>>>,
}

pub struct RouteAShoutTimeLaneClaims<'a> {
    pub value_prefix: RoundOraclePrefix<'a>,
    pub adapter_prefix: RoundOraclePrefix<'a>,
    pub value_claim: K,
    pub adapter_claim: K,
    pub gamma_group: Option<usize>,
}

pub struct RouteAShoutTimeGammaGroupClaims<'a> {
    pub value_prefix: RoundOraclePrefix<'a>,
    pub adapter_prefix: RoundOraclePrefix<'a>,
    pub bitness_prefix: RoundOraclePrefix<'a>,
    pub value_claim: K,
    pub adapter_claim: K,
}

pub fn build_route_a_shout_time_claims_guard<'a>(
    shout_oracles: &'a mut [RouteAShoutTimeOracles],
    shout_gamma_groups: &'a mut [RouteAShoutGammaGroupOracles],
    ell_n: usize,
) -> RouteAShoutTimeClaimsGuard<'a> {
    let mut lane_ranges: Vec<core::ops::Range<usize>> = Vec::with_capacity(shout_oracles.len());
    let mut lanes: Vec<RouteAShoutTimeLaneClaims<'a>> = Vec::new();
    let mut gamma_groups: Vec<RouteAShoutTimeGammaGroupClaims<'a>> = Vec::with_capacity(shout_gamma_groups.len());
    let mut bitness: Vec<Vec<Box<dyn RoundOracle + Send>>> = Vec::with_capacity(shout_oracles.len());

    for o in shout_oracles.iter_mut() {
        bitness.push(core::mem::take(&mut o.bitness));
        let start = lanes.len();
        for lane in o.lanes.iter_mut() {
            lanes.push(RouteAShoutTimeLaneClaims {
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

    for g in shout_gamma_groups.iter_mut() {
        gamma_groups.push(RouteAShoutTimeGammaGroupClaims {
            value_prefix: RoundOraclePrefix::new(g.value.as_mut(), ell_n),
            adapter_prefix: RoundOraclePrefix::new(g.adapter.as_mut(), ell_n),
            bitness_prefix: RoundOraclePrefix::new(g.bitness.as_mut(), ell_n),
            value_claim: g.value_claim,
            adapter_claim: g.adapter_claim,
        });
    }

    RouteAShoutTimeClaimsGuard {
        lane_ranges,
        lanes,
        gamma_groups,
        bitness,
    }
}

pub struct ShoutRouteAProtocol<'a> {
    guard: RouteAShoutTimeClaimsGuard<'a>,
}

impl<'a> ShoutRouteAProtocol<'a> {
    pub fn new(
        shout_oracles: &'a mut [RouteAShoutTimeOracles],
        shout_gamma_groups: &'a mut [RouteAShoutGammaGroupOracles],
        ell_n: usize,
    ) -> Self {
        Self {
            guard: build_route_a_shout_time_claims_guard(shout_oracles, shout_gamma_groups, ell_n),
        }
    }
}

impl<'o> TimeBatchedClaims for ShoutRouteAProtocol<'o> {
    fn append_time_claims<'a>(
        &'a mut self,
        _ell_n: usize,
        claimed_sums: &mut Vec<K>,
        degree_bounds: &mut Vec<usize>,
        labels: &mut Vec<&'static [u8]>,
        claim_is_dynamic: &mut Vec<bool>,
        claims: &mut Vec<BatchedClaim<'a>>,
    ) -> Result<(), PiCcsError> {
        append_route_a_shout_time_claims(
            &mut self.guard,
            claimed_sums,
            degree_bounds,
            labels,
            claim_is_dynamic,
            claims,
        )
    }
}

pub fn append_route_a_shout_time_claims<'a>(
    guard: &'a mut RouteAShoutTimeClaimsGuard<'_>,
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
            "shout bitness count mismatch (bitness={}, lane_ranges={})",
            guard.bitness.len(),
            guard.lane_ranges.len()
        )));
    }

    let mut lane_ranges_iter = guard.lane_ranges.iter();
    let mut next_end = lane_ranges_iter
        .next()
        .ok_or_else(|| PiCcsError::ProtocolError("shout lane_ranges unexpectedly empty".into()))?
        .end;
    let mut bitness_iter = guard.bitness.iter_mut();

    for (lane_idx, lane) in guard.lanes.iter_mut().enumerate() {
        if lane.gamma_group.is_none() {
            claimed_sums.push(lane.value_claim);
            degree_bounds.push(lane.value_prefix.degree_bound());
            labels.push(b"shout/value");
            claim_is_dynamic.push(true);
            claims.push(BatchedClaim {
                oracle: &mut lane.value_prefix,
                claimed_sum: lane.value_claim,
                label: b"shout/value",
            });

            claimed_sums.push(lane.adapter_claim);
            degree_bounds.push(lane.adapter_prefix.degree_bound());
            labels.push(b"shout/adapter");
            claim_is_dynamic.push(true);
            claims.push(BatchedClaim {
                oracle: &mut lane.adapter_prefix,
                claimed_sum: lane.adapter_claim,
                label: b"shout/adapter",
            });
        }

        if lane_idx + 1 == next_end {
            let bitness_vec = bitness_iter.next().ok_or_else(|| {
                PiCcsError::ProtocolError(format!(
                    "shout bitness idx drift at lane_idx={lane_idx} (missing bitness vector)"
                ))
            })?;
            for bit_oracle in bitness_vec.iter_mut() {
                claimed_sums.push(K::ZERO);
                degree_bounds.push(bit_oracle.degree_bound());
                labels.push(b"shout/bitness");
                claim_is_dynamic.push(false);
                claims.push(BatchedClaim {
                    oracle: bit_oracle.as_mut(),
                    claimed_sum: K::ZERO,
                    label: b"shout/bitness",
                });
            }

            next_end = lane_ranges_iter.next().map(|r| r.end).unwrap_or(usize::MAX);
        }
    }

    for group in guard.gamma_groups.iter_mut() {
        claimed_sums.push(group.value_claim);
        degree_bounds.push(group.value_prefix.degree_bound());
        labels.push(b"shout/value");
        claim_is_dynamic.push(true);
        claims.push(BatchedClaim {
            oracle: &mut group.value_prefix,
            claimed_sum: group.value_claim,
            label: b"shout/value",
        });

        claimed_sums.push(group.adapter_claim);
        degree_bounds.push(group.adapter_prefix.degree_bound());
        labels.push(b"shout/adapter");
        claim_is_dynamic.push(true);
        claims.push(BatchedClaim {
            oracle: &mut group.adapter_prefix,
            claimed_sum: group.adapter_claim,
            label: b"shout/adapter",
        });

        claimed_sums.push(K::ZERO);
        degree_bounds.push(group.bitness_prefix.degree_bound());
        labels.push(b"shout/bitness");
        claim_is_dynamic.push(false);
        claims.push(BatchedClaim {
            oracle: &mut group.bitness_prefix,
            claimed_sum: K::ZERO,
            label: b"shout/bitness",
        });
    }

    if bitness_iter.next().is_some() {
        return Err(PiCcsError::ProtocolError(
            "shout bitness not fully consumed after lane claim assembly".into(),
        ));
    }
    Ok(())
}

pub struct RouteATwistTimeClaimsGuard<'a> {
    pub read_check_prefixes: Vec<RoundOraclePrefix<'a>>,
    pub write_check_prefixes: Vec<RoundOraclePrefix<'a>>,
    pub read_check_claims: Vec<K>,
    pub write_check_claims: Vec<K>,
    pub bitness: Vec<Vec<Box<dyn RoundOracle + Send>>>,
    pub virtual_write_domain_prefixes: Vec<Option<RoundOraclePrefix<'a>>>,
    pub nonvirtual_arch_domain_prefixes: Vec<Option<RoundOraclePrefix<'a>>>,
}

pub fn build_route_a_twist_time_claims_guard<'a>(
    twist_oracles: &'a mut [RouteATwistTimeOracles],
    ell_n: usize,
    read_check_claims: Vec<K>,
    write_check_claims: Vec<K>,
) -> Result<RouteATwistTimeClaimsGuard<'a>, PiCcsError> {
    let mut read_check_prefixes: Vec<RoundOraclePrefix<'a>> = Vec::with_capacity(twist_oracles.len());
    let mut write_check_prefixes: Vec<RoundOraclePrefix<'a>> = Vec::with_capacity(twist_oracles.len());
    let mut bitness: Vec<Vec<Box<dyn RoundOracle + Send>>> = Vec::with_capacity(twist_oracles.len());
    let mut virtual_write_domain_prefixes: Vec<Option<RoundOraclePrefix<'a>>> = Vec::with_capacity(twist_oracles.len());
    let mut nonvirtual_arch_domain_prefixes: Vec<Option<RoundOraclePrefix<'a>>> =
        Vec::with_capacity(twist_oracles.len());

    if read_check_claims.len() != twist_oracles.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "twist read-check claim count mismatch (claims={}, oracles={})",
            read_check_claims.len(),
            twist_oracles.len()
        )));
    }
    if write_check_claims.len() != twist_oracles.len() {
        return Err(PiCcsError::ProtocolError(format!(
            "twist write-check claim count mismatch (claims={}, oracles={})",
            write_check_claims.len(),
            twist_oracles.len()
        )));
    }

    for o in twist_oracles.iter_mut() {
        bitness.push(core::mem::take(&mut o.bitness));
        read_check_prefixes.push(RoundOraclePrefix::new(o.read_check.as_mut(), ell_n));
        write_check_prefixes.push(RoundOraclePrefix::new(o.write_check.as_mut(), ell_n));
        let vd_prefix = o
            .virtual_write_domain
            .as_mut()
            .map(|oracle| RoundOraclePrefix::new(oracle.as_mut(), ell_n));
        virtual_write_domain_prefixes.push(vd_prefix);
        let nvd_prefix = o
            .nonvirtual_arch_domain
            .as_mut()
            .map(|oracle| RoundOraclePrefix::new(oracle.as_mut(), ell_n));
        nonvirtual_arch_domain_prefixes.push(nvd_prefix);
    }

    Ok(RouteATwistTimeClaimsGuard {
        read_check_prefixes,
        write_check_prefixes,
        read_check_claims,
        write_check_claims,
        bitness,
        virtual_write_domain_prefixes,
        nonvirtual_arch_domain_prefixes,
    })
}

pub fn append_route_a_twist_time_claims<'a>(
    guard: &'a mut RouteATwistTimeClaimsGuard<'_>,
    claimed_sums: &mut Vec<K>,
    degree_bounds: &mut Vec<usize>,
    labels: &mut Vec<&'static [u8]>,
    claim_is_dynamic: &mut Vec<bool>,
    claims: &mut Vec<BatchedClaim<'a>>,
) -> Result<(), PiCcsError> {
    for (
        ((((read_check_time, write_check_time), bitness_vec), virtual_write_domain), nonvirtual_arch_domain),
        (read_claim, write_claim),
    ) in guard
        .read_check_prefixes
        .iter_mut()
        .zip(guard.write_check_prefixes.iter_mut())
        .zip(guard.bitness.iter_mut())
        .zip(guard.virtual_write_domain_prefixes.iter_mut())
        .zip(guard.nonvirtual_arch_domain_prefixes.iter_mut())
        .zip(
            guard
                .read_check_claims
                .iter()
                .zip(guard.write_check_claims.iter()),
        )
    {
        claimed_sums.push(*read_claim);
        degree_bounds.push(read_check_time.degree_bound());
        labels.push(b"twist/read_check");
        claim_is_dynamic.push(true);
        claims.push(BatchedClaim {
            oracle: read_check_time,
            claimed_sum: *read_claim,
            label: b"twist/read_check",
        });

        claimed_sums.push(*write_claim);
        degree_bounds.push(write_check_time.degree_bound());
        labels.push(b"twist/write_check");
        claim_is_dynamic.push(true);
        claims.push(BatchedClaim {
            oracle: write_check_time,
            claimed_sum: *write_claim,
            label: b"twist/write_check",
        });

        for bit_oracle in bitness_vec.iter_mut() {
            claimed_sums.push(K::ZERO);
            degree_bounds.push(bit_oracle.degree_bound());
            labels.push(b"twist/bitness");
            claim_is_dynamic.push(false);
            claims.push(BatchedClaim {
                oracle: bit_oracle.as_mut(),
                claimed_sum: K::ZERO,
                label: b"twist/bitness",
            });
        }
        if let Some(virtual_write_domain_oracle) = virtual_write_domain.as_mut() {
            claimed_sums.push(K::ZERO);
            degree_bounds.push(virtual_write_domain_oracle.degree_bound());
            labels.push(b"twist/virtual_write_domain");
            claim_is_dynamic.push(false);
            claims.push(BatchedClaim {
                oracle: virtual_write_domain_oracle,
                claimed_sum: K::ZERO,
                label: b"twist/virtual_write_domain",
            });
        }
        if let Some(nonvirtual_arch_domain_oracle) = nonvirtual_arch_domain.as_mut() {
            claimed_sums.push(K::ZERO);
            degree_bounds.push(nonvirtual_arch_domain_oracle.degree_bound());
            labels.push(b"twist/nonvirtual_arch_domain");
            claim_is_dynamic.push(false);
            claims.push(BatchedClaim {
                oracle: nonvirtual_arch_domain_oracle,
                claimed_sum: K::ZERO,
                label: b"twist/nonvirtual_arch_domain",
            });
        }
    }
    Ok(())
}

pub struct TwistRouteAProtocol<'a> {
    guard: RouteATwistTimeClaimsGuard<'a>,
}

impl<'a> TwistRouteAProtocol<'a> {
    pub fn new(
        twist_oracles: &'a mut [RouteATwistTimeOracles],
        ell_n: usize,
        read_check_claims: Vec<K>,
        write_check_claims: Vec<K>,
    ) -> Result<Self, PiCcsError> {
        Ok(Self {
            guard: build_route_a_twist_time_claims_guard(twist_oracles, ell_n, read_check_claims, write_check_claims)?,
        })
    }
}

impl<'o> TimeBatchedClaims for TwistRouteAProtocol<'o> {
    fn append_time_claims<'a>(
        &'a mut self,
        _ell_n: usize,
        claimed_sums: &mut Vec<K>,
        degree_bounds: &mut Vec<usize>,
        labels: &mut Vec<&'static [u8]>,
        claim_is_dynamic: &mut Vec<bool>,
        claims: &mut Vec<BatchedClaim<'a>>,
    ) -> Result<(), PiCcsError> {
        append_route_a_twist_time_claims(
            &mut self.guard,
            claimed_sums,
            degree_bounds,
            labels,
            claim_is_dynamic,
            claims,
        )
    }
}

pub(crate) type WidthResidualTimeClaims = (
    Option<(Box<dyn RoundOracle + Send>, K)>,
    Option<(Box<dyn RoundOracle + Send>, K)>,
    Option<(Box<dyn RoundOracle + Send>, K)>,
    Option<(Box<dyn RoundOracle + Send>, K)>,
    Option<(Box<dyn RoundOracle + Send>, K)>,
);
