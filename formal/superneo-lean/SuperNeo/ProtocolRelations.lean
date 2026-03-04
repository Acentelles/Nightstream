import SuperNeo.ProtocolTarget
import SuperNeo.SumCheck

/-!
CCS/CE relation layer.

This module defines paper-facing relation predicates on top of the protocol
context and ties them to the protocol-target and SumCheck boundaries.
-/

namespace SuperNeo

/-- Build a SumCheck instance from protocol-target context fields. -/
def sumcheckInstanceOfContext (ctx : ProtocolTargetContext) : SumCheckInstance :=
  { rounds := ctx.kSplit
    maxDegree := ctx.m.size
    domainSize := ctx.cset.size
    claimedValue := ct ctx.invDelta }

/-- Explicit SumCheck witness carrying the transition facts used by reductions. -/
structure SumCheckTransitionWitness (ctx : ProtocolTargetContext) where
  transcript : SumCheckTranscript
  accepted : SumCheckAccepted (sumcheckInstanceOfContext ctx) transcript
  initialRound :
    sumcheckInitialRoundConsistent (sumcheckInstanceOfContext ctx) transcript
  roundSumStep :
    ∀ i : Nat,
      i + 1 < transcript.roundPolys.size →
        sumcheckEvalPoly (transcript.roundPolys[i + 1]!) 0 +
            sumcheckEvalPoly (transcript.roundPolys[i + 1]!) 1 =
          sumcheckEvalPoly (transcript.roundPolys[i]!) (transcript.challenges[i]!)

theorem SumCheckTransitionWitness.accepted_exists
  {ctx : ProtocolTargetContext}
  (h : SumCheckTransitionWitness ctx) :
  ∃ tr : SumCheckTranscript,
    SumCheckAccepted (sumcheckInstanceOfContext ctx) tr := by
  exact ⟨h.transcript, h.accepted⟩

/-- CCS relation: protocol target holds. -/
def ccsRelation (ctx : ProtocolTargetContext) : Prop :=
  protocolTargetProp ctx

/-- CE relation: CCS relation plus an accepted SumCheck transcript witness. -/
def ceRelation (ctx : ProtocolTargetContext) : Prop :=
  ccsRelation ctx ∧
  ∃ tr : SumCheckTranscript,
    SumCheckAccepted (sumcheckInstanceOfContext ctx) tr

/-- Relaxed CE relation: keep only CCS relation (claim-truth may be deferred). -/
def ceRelaxedRelation (ctx : ProtocolTargetContext) : Prop :=
  ccsRelation ctx

/-- Assumptions needed to derive relation-level statements. -/
structure ProtocolRelationsAssumptions (ctx : ProtocolTargetContext) where
  target : ProtocolTargetAssumptions ctx
  sumcheckSoundness : SumcheckSoundnessAssumption
  sumcheckCompleteness : SumcheckCompletenessAssumption

/-- Native assumption bundle: protocol target closes Theorem-3 via native bar. -/
structure ProtocolRelationsNativeAssumptions (ctx : ProtocolTargetContext) where
  target : ProtocolTargetNativeAssumptions ctx
  sumcheckSoundness : SumcheckSoundnessAssumption
  sumcheckCompleteness : SumcheckCompletenessAssumption

/-- Derive CCS relation from target assumptions. -/
theorem ccsRelation_of_assumptions
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsAssumptions ctx) :
  ccsRelation ctx := by
  exact protocolTargetProp_of_assumptions h.target

/-- Derive CCS relation from native target assumptions. -/
theorem ccsRelation_of_native_assumptions
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsNativeAssumptions ctx) :
  ccsRelation ctx := by
  exact protocolTargetProp_of_native_assumptions h.target

/-- Derive CE relation from explicit transcript acceptance witness. -/
theorem ceRelation_of_assumptions
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsAssumptions ctx)
  (hWitness : SumCheckTransitionWitness ctx) :
  ceRelation ctx := by
  exact ⟨ccsRelation_of_assumptions h, hWitness.accepted_exists⟩

/-- Derive CE relation from claim-truth via SumCheck completeness boundary. -/
theorem ceRelation_of_claimTrue
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsAssumptions ctx)
  (hClaimTrue : SumCheckClaimTrue (sumcheckInstanceOfContext ctx)) :
  ceRelation ctx := by
  rcases h.sumcheckCompleteness _ hClaimTrue with ⟨tr, hAcc⟩
  refine ceRelation_of_assumptions h ?_
  refine
    { transcript := tr
      accepted := hAcc
      initialRound := sumcheckAccepted_initial_round hAcc
      roundSumStep := ?_ }
  intro i hi
  exact sumcheckAccepted_round_sum_step hAcc hi

/-- Derive CE relation from native assumptions and explicit transcript witness. -/
theorem ceRelation_of_native_assumptions
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsNativeAssumptions ctx)
  (hWitness : SumCheckTransitionWitness ctx) :
  ceRelation ctx := by
  exact ⟨ccsRelation_of_native_assumptions h, hWitness.accepted_exists⟩

/-- Derive CE relation from claim-truth via native assumptions. -/
theorem ceRelation_of_native_claimTrue
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsNativeAssumptions ctx)
  (hClaimTrue : SumCheckClaimTrue (sumcheckInstanceOfContext ctx)) :
  ceRelation ctx := by
  rcases h.sumcheckCompleteness _ hClaimTrue with ⟨tr, hAcc⟩
  refine ceRelation_of_native_assumptions h ?_
  refine
    { transcript := tr
      accepted := hAcc
      initialRound := sumcheckAccepted_initial_round hAcc
      roundSumStep := ?_ }
  intro i hi
  exact sumcheckAccepted_round_sum_step hAcc hi

/-- Soundness lift: any CE witness yields SumCheck claim truth. -/
theorem ceClaimTrue_of_ce
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsAssumptions ctx)
  (hCE : ceRelation ctx) :
  SumCheckClaimTrue (sumcheckInstanceOfContext ctx) := by
  rcases hCE.2 with ⟨tr, hAcc⟩
  exact h.sumcheckSoundness _ _ hAcc

/-- Soundness lift on the native assumption path. -/
theorem ceClaimTrue_of_native_ce
  {ctx : ProtocolTargetContext}
  (h : ProtocolRelationsNativeAssumptions ctx)
  (hCE : ceRelation ctx) :
  SumCheckClaimTrue (sumcheckInstanceOfContext ctx) := by
  rcases hCE.2 with ⟨tr, hAcc⟩
  exact h.sumcheckSoundness _ _ hAcc

/-- CE implies relaxed CE. -/
theorem ceRelaxedRelation_of_ce
  {ctx : ProtocolTargetContext}
  (hCE : ceRelation ctx) :
  ceRelaxedRelation ctx := by
  exact hCE.1

end SuperNeo
