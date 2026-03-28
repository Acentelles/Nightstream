import Nightstream.Rv64IM.Trace.TemporalConsistency
import Nightstream.Rv64IM.Stage2.TwistConcreteBinding

/-!
Owns theorem-facing Stage 2 authenticated-history semantics on actual proof
packages. This packages temporal closure, register/RAM timelines, and twist
linkage; it does not re-own imported row-summary checks.
-/

namespace Nightstream.Rv64IM

def Stage2AuthenticatedHistorySemantics
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    (temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks)
    (twist : TwistConcreteBindingProofPackage Limb) : Prop :=
  AdjacentStateClosed
      State
      temporal.stage2.preState
      temporal.stage2.postState
      temporal.stage2.semanticRows ∧
    RegisterTimelineBound
      temporal.registers.timeline
      temporal.registers.preState
      temporal.registers.postState
      temporal.registers.semanticRows ∧
    RamTimelineBound
      temporal.ram.timeline
      temporal.ram.preState
      temporal.ram.postState
      temporal.ram.semanticRows ∧
    Stage2LinkageBound
      twist.registerLane
      twist.registerTwist
      twist.ramLane
      twist.ramTwist

theorem adjacentStateClosed_of_stage2AuthenticatedHistorySemantics
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    {temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks}
    {twist : TwistConcreteBindingProofPackage Limb}
    (h : Stage2AuthenticatedHistorySemantics temporal twist) :
    AdjacentStateClosed
      State
      temporal.stage2.preState
      temporal.stage2.postState
      temporal.stage2.semanticRows :=
  h.1

theorem registerTimelineBound_of_stage2AuthenticatedHistorySemantics
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    {temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks}
    {twist : TwistConcreteBindingProofPackage Limb}
    (h : Stage2AuthenticatedHistorySemantics temporal twist) :
    RegisterTimelineBound
      temporal.registers.timeline
      temporal.registers.preState
      temporal.registers.postState
      temporal.registers.semanticRows :=
  h.2.1

theorem ramTimelineBound_of_stage2AuthenticatedHistorySemantics
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    {temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks}
    {twist : TwistConcreteBindingProofPackage Limb}
    (h : Stage2AuthenticatedHistorySemantics temporal twist) :
    RamTimelineBound
      temporal.ram.timeline
      temporal.ram.preState
      temporal.ram.postState
      temporal.ram.semanticRows :=
  h.2.2.1

theorem stage2LinkageBound_of_stage2AuthenticatedHistorySemantics
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    {temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks}
    {twist : TwistConcreteBindingProofPackage Limb}
    (h : Stage2AuthenticatedHistorySemantics temporal twist) :
    Stage2LinkageBound
      twist.registerLane
      twist.registerTwist
      twist.ramLane
      twist.ramTwist :=
  h.2.2.2

theorem registerLinkageBound_of_stage2AuthenticatedHistorySemantics
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    {temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks}
    {twist : TwistConcreteBindingProofPackage Limb}
    (h : Stage2AuthenticatedHistorySemantics temporal twist) :
    RegisterLinkageBound
      twist.registerLane
      twist.registerTwist :=
  (stage2LinkageBound_of_stage2AuthenticatedHistorySemantics h).1

theorem ramLinkageBound_of_stage2AuthenticatedHistorySemantics
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    {temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks}
    {twist : TwistConcreteBindingProofPackage Limb}
    (h : Stage2AuthenticatedHistorySemantics temporal twist) :
    RamLinkageBound
      twist.ramLane
      twist.ramTwist :=
  (stage2LinkageBound_of_stage2AuthenticatedHistorySemantics h).2

theorem stage2AuthenticatedHistorySemantics_of_temporalConsistency_and_twistConcreteBinding
    {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks Limb : Type _}
    [OfNat Limb 0]
    (temporal :
      TemporalConsistencyProofPackage
        State
        Pc
        RegIdx
        RamAddr
        Word
        RegisterTimeline
        RamTimeline
        RowLinks)
    (twist : TwistConcreteBindingProofPackage Limb) :
    Stage2AuthenticatedHistorySemantics temporal twist := by
  exact
    ⟨ adjacentStateClosed_of_temporalConsistency temporal
    , registerTimelineBound_of_temporalConsistency temporal
    , ramTimelineBound_of_temporalConsistency temporal
    , twist.linkageBound
    ⟩

end Nightstream.Rv64IM
