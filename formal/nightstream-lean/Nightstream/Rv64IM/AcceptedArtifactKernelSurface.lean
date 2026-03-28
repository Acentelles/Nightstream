import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.ProofBoundaryChecks

/-!
Owns exact recomputation of the RV64IM kernel trace and stage-witness surface
from the lowest practical accepted-artifact inputs available to Lean. This
owner covers only the trace/stage projection bundles; it does not own
root-lane row authentication or opening provenance.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

structure RecomputedKernelSurfaceView where
  traceShape : TraceShapeBundleView
  traceProjection : TraceProjectionBundleView
  stageWitnessSummary : StageWitnessSummaryBundleView
  stageWitnessProjection : StageWitnessProjectionBundleView
deriving DecidableEq, Repr

def traceShapeOfAcceptedArtifact
    (artifact : AcceptedProofArtifactView) : TraceShapeBundleView :=
  let shape : TraceShapeBundleView :=
    { executionRowCount := artifact.derived.executionRows.length
    , realRowCount := artifact.derived.executionRows.countP ExpandedRowView.isReal
    , effectRowCount := artifact.derived.executionRows.countP ExpandedRowView.isEffectRow
    , commitRowCount := artifact.derived.executionRows.countP ExpandedRowView.isCommitRow
    , digest := []
    }
  { shape with digest := traceShapeBundleDigest shape }

def traceProjectionOfAcceptedArtifact
    (artifact : AcceptedProofArtifactView) : TraceProjectionBundleView :=
  let traceShape := traceShapeOfAcceptedArtifact artifact
  let bundle : TraceProjectionBundleView :=
    { manifest := artifact.source.manifest
    , executionDigest := artifact.derived.kernel.executionDigest
    , shape := traceShape
    , digest := []
    }
  { bundle with digest := traceProjectionBundleDigest bundle }

def stageWitnessSummaryOfAcceptedArtifact
    (artifact : AcceptedProofArtifactView) : StageWitnessSummaryBundleView :=
  let summary : StageWitnessSummaryBundleView :=
    { stage1RowCount := artifact.derived.stage1.rows.length
    , stage2RegisterReadCount := artifact.derived.stage2.registerReads.length
    , stage2RegisterWriteCount := artifact.derived.stage2.registerWrites.length
    , stage2RamEventCount := artifact.derived.stage2.ramEvents.length
    , stage2TwistLinkCount := artifact.derived.stage2.twistLinks.length
    , stage3ContinuityCount := artifact.derived.stage3.continuity.length
    , stage3Halted := artifact.derived.stage3.halted
    , transcriptEventCount := artifact.derived.transcript.events.length
    , digest := []
    }
  { summary with digest := stageWitnessSummaryBundleDigest summary }

def stageWitnessProjectionOfAcceptedArtifact
    (artifact : AcceptedProofArtifactView) : StageWitnessProjectionBundleView :=
  let summary := stageWitnessSummaryOfAcceptedArtifact artifact
  let bundle : StageWitnessProjectionBundleView :=
    { summary := summary
    , digest := []
    }
  { bundle with digest := stageWitnessProjectionBundleDigest bundle }

def recomputeKernelSurfaceView
    (artifact : AcceptedProofArtifactView) : RecomputedKernelSurfaceView :=
  let traceShape := traceShapeOfAcceptedArtifact artifact
  let traceProjection := traceProjectionOfAcceptedArtifact artifact
  let stageWitnessSummary := stageWitnessSummaryOfAcceptedArtifact artifact
  let stageWitnessProjection := stageWitnessProjectionOfAcceptedArtifact artifact
  { traceShape := traceShape
  , traceProjection := traceProjection
  , stageWitnessSummary := stageWitnessSummary
  , stageWitnessProjection := stageWitnessProjection
  }

def recomputedTraceProjectionMatchesArtifact
    (recomputed : RecomputedKernelSurfaceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.traceProjection = artifact.kernelProof.trace &&
    recomputed.traceProjection = artifact.exportedKernelProof.trace

def recomputedStageWitnessProjectionMatchesArtifact
    (recomputed : RecomputedKernelSurfaceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.stageWitnessProjection = artifact.kernelProof.stages &&
    recomputed.stageWitnessProjection = artifact.exportedKernelProof.stages

def recomputedKernelSurfaceMatchesArtifact
    (recomputed : RecomputedKernelSurfaceView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputedTraceProjectionMatchesArtifact recomputed artifact &&
    recomputedStageWitnessProjectionMatchesArtifact recomputed artifact

end Nightstream.Rv64IM
