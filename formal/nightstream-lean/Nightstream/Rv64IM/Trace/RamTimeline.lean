import Nightstream.Rv64IM.Execution.ExecutionSemantics

namespace Nightstream.Rv64IM

def RamTimelineBound
  {Pc RegIdx RamAddr Word : Type _}
  (timeline : Nat → RamWordState RamAddr Word)
  (preState postState : Nat → ArchitecturalState Pc RegIdx RamAddr Word)
  (semanticRows : Nat) : Prop :=
  ∀ j,
    j < semanticRows →
      timeline j = (preState j).ram ∧
        (j + 1 < semanticRows → timeline (j + 1) = (postState j).ram)

structure RamTimelineProofPackage
  (Pc RegIdx RamAddr Word : Type _) where
  semanticRows : Nat
  timeline : Nat → RamWordState RamAddr Word
  preState : Nat → ArchitecturalState Pc RegIdx RamAddr Word
  postState : Nat → ArchitecturalState Pc RegIdx RamAddr Word
  bound : RamTimelineBound timeline preState postState semanticRows

theorem ramTimeline_preState_of_bound
  {Pc RegIdx RamAddr Word : Type _}
  (pkg : RamTimelineProofPackage Pc RegIdx RamAddr Word)
  {j : Nat}
  (h : j < pkg.semanticRows) :
  pkg.timeline j = (pkg.preState j).ram :=
  (pkg.bound j h).1

end Nightstream.Rv64IM
