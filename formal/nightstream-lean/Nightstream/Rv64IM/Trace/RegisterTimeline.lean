import Nightstream.Rv64IM.Execution.ExecutionSemantics

namespace Nightstream.Rv64IM

def RegisterTimelineBound
  {Pc RegIdx RamAddr Word : Type _}
  (timeline : Nat → RegisterState RegIdx Word)
  (preState postState : Nat → ArchitecturalState Pc RegIdx RamAddr Word)
  (semanticRows : Nat) : Prop :=
  ∀ j,
    j < semanticRows →
      timeline j = (preState j).registers ∧
        (j + 1 < semanticRows → timeline (j + 1) = (postState j).registers)

structure RegisterTimelineProofPackage
  (Pc RegIdx RamAddr Word : Type _) where
  semanticRows : Nat
  timeline : Nat → RegisterState RegIdx Word
  preState : Nat → ArchitecturalState Pc RegIdx RamAddr Word
  postState : Nat → ArchitecturalState Pc RegIdx RamAddr Word
  bound : RegisterTimelineBound timeline preState postState semanticRows

theorem registerTimeline_preState_of_bound
  {Pc RegIdx RamAddr Word : Type _}
  (pkg : RegisterTimelineProofPackage Pc RegIdx RamAddr Word)
  {j : Nat}
  (h : j < pkg.semanticRows) :
  pkg.timeline j = (pkg.preState j).registers :=
  (pkg.bound j h).1

end Nightstream.Rv64IM
