import Nightstream.Rv64IM.Execution.PcAdjacentBridge
import Nightstream.Rv64IM.Execution.Stage2TemporalClosure
import Nightstream.Rv64IM.Trace.RegisterTimeline
import Nightstream.Rv64IM.Trace.RamTimeline

namespace Nightstream.Rv64IM

def TemporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pcOf : State → Pc)
  (stage2 :
    Stage2TemporalClosureProofPackage State RegisterTimeline RamTimeline RowLinks)
  (pcBridge : PcAdjacentBridgeProofPackage Pc)
  (registers : RegisterTimelineProofPackage Pc RegIdx RamAddr Word)
  (ram : RamTimelineProofPackage Pc RegIdx RamAddr Word) : Prop :=
  AdjacentStateClosed State stage2.preState stage2.postState stage2.semanticRows ∧
    PcAdjacentBridge Pc pcBridge.postPc pcBridge.prePc pcBridge.semanticRows ∧
    RegisterTimelineBound
      registers.timeline
      registers.preState
      registers.postState
      registers.semanticRows ∧
    RamTimelineBound
      ram.timeline
      ram.preState
      ram.postState
      ram.semanticRows ∧
    registers.semanticRows = stage2.semanticRows ∧
    ram.semanticRows = stage2.semanticRows ∧
    pcBridge.semanticRows = stage2.semanticRows ∧
    (∀ j, j < stage2.semanticRows → pcBridge.prePc j = pcOf (stage2.preState j)) ∧
    (∀ j, j < stage2.semanticRows → pcBridge.postPc j = pcOf (stage2.postState j))

structure TemporalConsistencyProofPackage
  (State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _) where
  pcOf : State → Pc
  stage2 : Stage2TemporalClosureProofPackage State RegisterTimeline RamTimeline RowLinks
  pcBridge : PcAdjacentBridgeProofPackage Pc
  registers : RegisterTimelineProofPackage Pc RegIdx RamAddr Word
  ram : RamTimelineProofPackage Pc RegIdx RamAddr Word
  consistent : TemporalConsistency pcOf stage2 pcBridge registers ram

theorem adjacentStateClosed_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks) :
  AdjacentStateClosed State pkg.stage2.preState pkg.stage2.postState pkg.stage2.semanticRows :=
  by
    rcases pkg.consistent with
      ⟨hAdjacent, _, _, _, _, _, _, _, _⟩
    exact hAdjacent

theorem pcAdjacentBridge_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks) :
  PcAdjacentBridge
    Pc
    pkg.pcBridge.postPc
    pkg.pcBridge.prePc
    pkg.pcBridge.semanticRows :=
  by
    rcases pkg.consistent with
      ⟨_, hBridge, _, _, _, _, _, _, _⟩
    exact hBridge

theorem registerTimelineBound_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks) :
  RegisterTimelineBound
    pkg.registers.timeline
    pkg.registers.preState
    pkg.registers.postState
    pkg.registers.semanticRows :=
  by
    rcases pkg.consistent with
      ⟨_, _, hRegisterTimeline, _, _, _, _, _, _⟩
    exact hRegisterTimeline

theorem ramTimelineBound_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks) :
  RamTimelineBound
    pkg.ram.timeline
    pkg.ram.preState
    pkg.ram.postState
    pkg.ram.semanticRows :=
  by
    rcases pkg.consistent with
      ⟨_, _, _, hRamTimeline, _, _, _, _, _⟩
    exact hRamTimeline

theorem registerSemanticRows_eq_stage2_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks) :
  pkg.registers.semanticRows = pkg.stage2.semanticRows :=
  by
    rcases pkg.consistent with
      ⟨_, _, _, _, hRows, _, _, _, _⟩
    exact hRows

theorem ramSemanticRows_eq_stage2_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks) :
  pkg.ram.semanticRows = pkg.stage2.semanticRows :=
  by
    rcases pkg.consistent with
      ⟨_, _, _, _, _, hRows, _, _, _⟩
    exact hRows

theorem pcSemanticRows_eq_stage2_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks) :
  pkg.pcBridge.semanticRows = pkg.stage2.semanticRows :=
  by
    rcases pkg.consistent with
      ⟨_, _, _, _, _, _, hRows, _, _⟩
    exact hRows

theorem prePc_eq_stage2PreStatePc_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks)
  {j : Nat}
  (h : j < pkg.stage2.semanticRows) :
  pkg.pcBridge.prePc j = pkg.pcOf (pkg.stage2.preState j) := by
  rcases pkg.consistent with
    ⟨_, _, _, _, _, _, _, hPrePc, _⟩
  exact hPrePc j h

theorem postPc_eq_stage2PostStatePc_of_temporalConsistency
  {State Pc RegIdx RamAddr Word RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg :
    TemporalConsistencyProofPackage
      State
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      RowLinks)
  {j : Nat}
  (h : j < pkg.stage2.semanticRows) :
  pkg.pcBridge.postPc j = pkg.pcOf (pkg.stage2.postState j) := by
  rcases pkg.consistent with
    ⟨_, _, _, _, _, _, _, _, hPostPc⟩
  exact hPostPc j h

end Nightstream.Rv64IM
