import Nightstream.ReleaseBridge
import Nightstream.Rv64IM.ExtensionFamily

namespace Nightstream.Rv64IM

inductive ReleaseStage where
  | readonlyBatch
  | registerHistory
  | ramHistory
deriving DecidableEq, Repr

def releaseStageOrder : List ReleaseStage :=
  [.readonlyBatch, .registerHistory, .ramHistory]

def familyStage : ExtensionFamily → ReleaseStage
  | .fetch => .readonlyBatch
  | .executionRow => .readonlyBatch
  | .aluSubtables => .readonlyBatch
  | .branchCondition => .readonlyBatch
  | .registerHistory => .registerHistory
  | .ramHistory => .ramHistory

def stageFamilies : ReleaseStage → List ExtensionFamily
  | .readonlyBatch => [.fetch, .executionRow, .aluSubtables, .branchCondition]
  | .registerHistory => [.registerHistory]
  | .ramHistory => [.ramHistory]

theorem familyStage_fetch :
  familyStage .fetch = .readonlyBatch := rfl

theorem familyStage_executionRow :
  familyStage .executionRow = .readonlyBatch := rfl

theorem familyStage_aluSubtables :
  familyStage .aluSubtables = .readonlyBatch := rfl

theorem familyStage_branchCondition :
  familyStage .branchCondition = .readonlyBatch := rfl

theorem familyStage_registerHistory :
  familyStage .registerHistory = .registerHistory := rfl

theorem familyStage_ramHistory :
  familyStage .ramHistory = .ramHistory := rfl

theorem mem_stageFamilies_iff
  {stage : ReleaseStage}
  {family : ExtensionFamily} :
  family ∈ stageFamilies stage ↔ familyStage family = stage := by
  cases stage <;> cases family <;> simp [stageFamilies, familyStage]

theorem family_mem_stageFamilies (family : ExtensionFamily) :
  family ∈ stageFamilies (familyStage family) := by
  exact (mem_stageFamilies_iff).2 rfl

def releaseShape : Nightstream.ReleaseShape ReleaseStage ExtensionFamily :=
  { stageOrder := releaseStageOrder
    familyStage := familyStage
    stageFamilies := stageFamilies }

theorem releaseShape_stageInventoryConsistent :
  Nightstream.StageInventoryConsistent releaseShape := by
  intro family stage
  exact mem_stageFamilies_iff

end Nightstream.Rv64IM
