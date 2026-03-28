import Nightstream.Rv64IM.Execution.Stage2TemporalClosure
import Nightstream.Rv64IM.Stage2.RegisterHistoryProjection
import Nightstream.Rv64IM.Stage2.RamHistoryProjection

namespace Nightstream.Rv64IM

structure Stage2HistoryBundles
  (RegisterTimeline RamTimeline RegAddr RegValue RamWord : Type _) where
  registers : RegisterHistoryBundle RegisterTimeline RegAddr RegValue
  ram : RamHistoryBundle RamTimeline RamWord

def stage2TemporalContextOfHistoryBundles
  {RegisterTimeline RamTimeline RegAddr RegValue RamWord RowLinks : Type _}
  (history : Stage2HistoryBundles RegisterTimeline RamTimeline RegAddr RegValue RamWord)
  (rowLinks : RowLinks) :
  Stage2TemporalContext RegisterTimeline RamTimeline RowLinks :=
  { regTimeline := history.registers.timeline
    ramTimeline := history.ram.timeline
    rowLinks := rowLinks }

def stage2TemporalClosureProofPackage_of_historyBundles
  {State RegisterTimeline RamTimeline RegAddr RegValue RamWord RowLinks : Type _}
  (history : Stage2HistoryBundles RegisterTimeline RamTimeline RegAddr RegValue RamWord)
  (rowLinks : RowLinks)
  (semanticRows : Nat)
  (preState postState : Nat → State)
  (hClosed : AdjacentStateClosed State preState postState semanticRows) :
  Stage2TemporalClosureProofPackage State RegisterTimeline RamTimeline RowLinks :=
  { context := stage2TemporalContextOfHistoryBundles history rowLinks
    semanticRows := semanticRows
    preState := preState
    postState := postState
    adjacentClosed := hClosed }

theorem adjacentStateClosed_of_stage2TemporalClosureProofPackage
  {State RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg : Stage2TemporalClosureProofPackage State RegisterTimeline RamTimeline RowLinks) :
  AdjacentStateClosed State pkg.preState pkg.postState pkg.semanticRows :=
  pkg.adjacentClosed

def stage2TemporalRowCount
  {State RegisterTimeline RamTimeline RowLinks : Type _}
  (pkg : Stage2TemporalClosureProofPackage State RegisterTimeline RamTimeline RowLinks) : Nat :=
  pkg.semanticRows

end Nightstream.Rv64IM
