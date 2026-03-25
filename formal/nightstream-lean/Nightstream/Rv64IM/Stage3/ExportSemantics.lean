import Nightstream.Rv64IM.Stage3.Stage3Refinement

/-!
Owns theorem-facing Stage 3 continuity/export semantics on actual proof
packages. This packages the pc-adjacency bridge and final halted boundary; it
does not re-own imported row-summary checks.
-/

namespace Nightstream.Rv64IM

def Stage3ContinuitySemantics
    {Pc Row PreparedStep : Type _}
    (pkg : Stage3RefinementPackage Pc Row PreparedStep) : Prop :=
  PcAdjacentBridge
      Pc
      pkg.stage3.postPc
      pkg.stage3.prePc
      pkg.stage3.semanticRows ∧
    ActivePrefixContinuity
      pkg.stage3.postPc
      pkg.stage3.prePc
      pkg.stage3.semanticRows

def Stage3ExportSemantics
    {Pc Row PreparedStep : Type _}
    (pkg : Stage3RefinementPackage Pc Row PreparedStep) : Prop :=
  Stage3ContinuitySemantics pkg ∧
    FullHaltedExecutionClaim
      pkg.finalBoundary.sequence
      pkg.finalBoundary.terminatingRow

theorem pcAdjacentBridge_of_stage3ContinuitySemantics
    {Pc Row PreparedStep : Type _}
    {pkg : Stage3RefinementPackage Pc Row PreparedStep}
    (h : Stage3ContinuitySemantics pkg) :
    PcAdjacentBridge
      Pc
      pkg.stage3.postPc
      pkg.stage3.prePc
      pkg.stage3.semanticRows :=
  h.1

theorem activePrefixContinuity_of_stage3ContinuitySemantics
    {Pc Row PreparedStep : Type _}
    {pkg : Stage3RefinementPackage Pc Row PreparedStep}
    (h : Stage3ContinuitySemantics pkg) :
    ActivePrefixContinuity
      pkg.stage3.postPc
      pkg.stage3.prePc
      pkg.stage3.semanticRows :=
  h.2

theorem fullHaltedExecutionClaim_of_stage3ExportSemantics
    {Pc Row PreparedStep : Type _}
    {pkg : Stage3RefinementPackage Pc Row PreparedStep}
    (h : Stage3ExportSemantics pkg) :
    FullHaltedExecutionClaim
      pkg.finalBoundary.sequence
      pkg.finalBoundary.terminatingRow :=
  h.2

theorem stage3ContinuitySemantics_of_stage3Refinement
    {Pc Row PreparedStep : Type _}
    (pkg : Stage3RefinementPackage Pc Row PreparedStep) :
    Stage3ContinuitySemantics pkg := by
  exact
    ⟨ pcAdjacentBridge_of_continuityRowsBound pkg.stage3.continuityBound
    , activePrefixContinuity_of_continuityRowsBound pkg.stage3.continuityBound
    ⟩

theorem stage3ExportSemantics_of_stage3Refinement
    {Pc Row PreparedStep : Type _}
    (pkg : Stage3RefinementPackage Pc Row PreparedStep) :
    Stage3ExportSemantics pkg := by
  exact
    ⟨ stage3ContinuitySemantics_of_stage3Refinement pkg
    , fullHaltedExecutionClaim_of_stage3Refinement pkg
    ⟩

end Nightstream.Rv64IM
