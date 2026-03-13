use super::*;

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
