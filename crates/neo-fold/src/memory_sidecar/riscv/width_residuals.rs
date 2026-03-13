use super::*;

#[inline]
pub(crate) fn rv64_fullword_width_stage_required_from_proof(
    _step: &StepInstanceBundle<Cmt, F, K>,
    _batched_time: &crate::shard_proof_types::BatchedTimeProof,
) -> bool {
    false
}

pub(crate) fn build_route_a_width_time_claims(
    _params: &NeoParams,
    _step: &StepWitnessBundle<Cmt, F, K>,
    _r_cycle: &[K],
) -> Result<WidthResidualTimeClaims, PiCcsError> {
    Ok((None, None, None, None, None))
}

pub(crate) fn verify_route_a_width_terminals(
    _cpu_bus: &BusLayout,
    _step: &StepInstanceBundle<Cmt, F, K>,
    _r_time: &[K],
    _r_cycle: &[K],
    _batched_final_values: &[K],
    claim_plan: &RouteATimeClaimPlan,
    _mem_proof: &MemSidecarProof<Cmt, F, K>,
    _step_time_openings: &[crate::shard_proof_types::TimePointOpening],
    _rv64_fullword_width_stage_from_proof: bool,
) -> Result<(), PiCcsError> {
    let any_width_claim = claim_plan.width_bitness.is_some()
        || claim_plan.width_quiescence.is_some()
        || claim_plan.width_selector_linkage.is_some()
        || claim_plan.width_load_semantics.is_some()
        || claim_plan.width_store_semantics.is_some();
    if any_width_claim {
        return Err(PiCcsError::ProtocolError(
            "width stage is unsupported in RV64-only neo-fold".into(),
        ));
    }
    Ok(())
}
