import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.AcceptedArtifactLocalTrace
import Nightstream.Rv64IM.AcceptedArtifactStage3Refinement

/-!
Owns constructive replay of the accepted-artifact step-composition surface.
This owner does not recover the full theorem-level `StepCompositionProofPackage`;
it replays the exact exported bridge surface that ties Stage 1/2/3 semantics to
the root-execution bundle and the prepared-step projection.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

structure RecomputedStepCompositionSurfaceView where
  stage1SemanticsDigest : List Byte
  stage2SemanticsDigest : List Byte
  stage2TemporalDigest : List Byte
  stage3SemanticsDigest : List Byte
  rootExecutionDigest : List Byte
  preparedStepBindingsDigest : List Byte
  rowChunkRoutesDigest : List Byte
  realRowCount : Nat
  preparedStepCount : Nat
  firstRealStepIndex : Nat
  lastRealStepIndex : Nat
  initialPc : Nat
  finalPc : Nat
  halted : Bool
deriving DecidableEq, Repr

private def realRowsOfArtifact (artifact : AcceptedProofArtifactView) : List ExpandedRowView :=
  realExecutionRows artifact.derived.executionRows

def recomputeStepCompositionSurfaceView
    (artifact : AcceptedProofArtifactView) : RecomputedStepCompositionSurfaceView :=
  let realRows := realRowsOfArtifact artifact
  { stage1SemanticsDigest := artifact.stage1.semantics.digest
  , stage2SemanticsDigest := artifact.stage2.semantics.digest
  , stage2TemporalDigest := artifact.stage2.temporal.digest
  , stage3SemanticsDigest := artifact.stage3.semantics.digest
  , rootExecutionDigest := artifact.rootExecution.digest
  , preparedStepBindingsDigest := artifact.rootExecution.preparedStepBindings.digest
  , rowChunkRoutesDigest := artifact.rootExecution.rowChunkRoutesDigest
  , realRowCount := realRows.length
  , preparedStepCount := artifact.rootExecution.preparedStepBindings.bindingCount
  , firstRealStepIndex := realRows.head?.map ExpandedRowView.stepIndex |>.getD 0
  , lastRealStepIndex := realRows.getLast?.map ExpandedRowView.stepIndex |>.getD 0
  , initialPc := artifact.exportedStatement.initialPc
  , finalPc := artifact.exportedStatement.finalPc
  , halted := artifact.stage3.halted
  }

def recomputedStepCompositionSurfaceMatchesArtifact
    (recomputed : RecomputedStepCompositionSurfaceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  let recomputedLocalTrace := recomputeLocalTraceView artifact
  let recoveredStage3 := recoverStage3Refinement? artifact
  recomputed.stage1SemanticsDigest = artifact.stepComposition.stage1SemanticsDigest &&
    recomputed.stage2SemanticsDigest = artifact.stepComposition.stage2SemanticsDigest &&
    recomputed.stage2TemporalDigest = artifact.stepComposition.stage2TemporalDigest &&
    recomputed.stage3SemanticsDigest = artifact.stepComposition.stage3SemanticsDigest &&
    recomputed.rootExecutionDigest = artifact.stepComposition.rootExecutionDigest &&
    recomputed.preparedStepBindingsDigest = artifact.stepComposition.preparedStepBindingsDigest &&
    recomputed.rowChunkRoutesDigest = artifact.stepComposition.rowChunkRoutesDigest &&
    recomputed.realRowCount = artifact.stepComposition.realRowCount &&
    recomputed.preparedStepCount = artifact.stepComposition.preparedStepCount &&
    recomputed.firstRealStepIndex = artifact.stepComposition.firstRealStepIndex &&
    recomputed.lastRealStepIndex = artifact.stepComposition.lastRealStepIndex &&
    recomputed.initialPc = artifact.stepComposition.initialPc &&
    recomputed.finalPc = artifact.stepComposition.finalPc &&
    recomputed.halted = artifact.stepComposition.halted &&
    recomputed.preparedStepCount = recomputedLocalTrace.mainLane.preparedSteps.length &&
    recomputed.realRowCount = recomputedLocalTrace.rowBindings.length &&
    recomputed.rowChunkRoutesDigest = artifact.rootExecution.rowChunkRoutesDigest &&
    recomputed.preparedStepBindingsDigest = artifact.rootExecution.preparedStepBindings.digest &&
    match recoveredStage3 with
    | some pkg =>
        recoveredStage3RefinementMatchesArtifact pkg artifact &&
          decide (pkg.stage3.semanticRows = recomputed.realRowCount)
    | none => false

end Nightstream.Rv64IM
