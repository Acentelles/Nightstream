import Nightstream.Rv64IM.AcceptedArtifactRootExecutionClosure
import Nightstream.Rv64IM.AcceptedArtifactRootLane
import Nightstream.ChunkLayout
import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.Checks
import Nightstream.Rv64IM.Kernel.RequiredRootExecutionSemanticsSurface

/-!
Executable audit for whether the exported RV64IM accepted artifact is strong
enough to close the root execution semantics step of the kernel design. This is
stricter than chunk/root payload presence: Lean must be able to replay the
semantic row embedding and then see theorem-bearing row-local root execution
acceptance objects, not only digests.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive RootExecutionSemanticsClosureField where
  | replayedExecutionRows
  | semanticRowEmbeddingRecomputed
  | rootLaneProtocolBindingsRecomputed
  | scheduleOwnedChunkRoutingRecomputed
  | rowLocalRootEncodeWitnessSurface
  | rowLocalCCSAcceptanceSurface
  | executionSemanticsRefinementSurface
  | rootExecutionSemanticsConstructible
deriving DecidableEq, Repr

def rootExecutionSemanticsClosureFieldName :
    RootExecutionSemanticsClosureField → String
  | .replayedExecutionRows => "replayed_execution_rows"
  | .semanticRowEmbeddingRecomputed => "semantic_row_embedding_recomputed"
  | .rootLaneProtocolBindingsRecomputed =>
      "root_lane_protocol_bindings_recomputed"
  | .scheduleOwnedChunkRoutingRecomputed =>
      "schedule_owned_chunk_routing_recomputed"
  | .rowLocalRootEncodeWitnessSurface =>
      "row_local_root_encode_witness_surface"
  | .rowLocalCCSAcceptanceSurface =>
      "row_local_ccs_acceptance_surface"
  | .executionSemanticsRefinementSurface =>
      "execution_semantics_refinement_surface"
  | .rootExecutionSemanticsConstructible =>
      "root_execution_semantics_constructible"

def requiredRootExecutionSemanticsClosureFields :
    List RootExecutionSemanticsClosureField :=
  [ .replayedExecutionRows
  , .semanticRowEmbeddingRecomputed
  , .rootLaneProtocolBindingsRecomputed
  , .scheduleOwnedChunkRoutingRecomputed
  , .rowLocalRootEncodeWitnessSurface
  , .rowLocalCCSAcceptanceSurface
  , .executionSemanticsRefinementSurface
  , .rootExecutionSemanticsConstructible
  ]

private def recomputedRootLane? (artifact : AcceptedProofArtifactView) :
    Option RecomputedRootLaneView :=
  recomputeDerivedCase? artifact.source |>.map fun derived =>
    recomputeRootLaneView derived.executionRows

private def replayedExecutionRowsPresent (artifact : AcceptedProofArtifactView) : Bool :=
  (recomputeDerivedCase? artifact.source).isSome

private def semanticRowEmbeddingRecomputedFromSource
    (artifact : AcceptedProofArtifactView) : Bool :=
  match recomputeDerivedCase? artifact.source with
  | none => false
  | some derived =>
      let recomputed := recomputeRootLaneView derived.executionRows
      recomputed.semanticRows.length = derived.executionRows.length &&
        recomputed.rowDigests.length = recomputed.semanticRows.length

private def rootLaneProtocolBindingsRecomputedFromSource
    (artifact : AcceptedProofArtifactView) : Bool :=
  match recomputedRootLane? artifact with
  | none => false
  | some recomputed =>
      recomputedRootLaneProtocolBindingsMatchArtifact recomputed artifact

private def scheduleOwnedChunkRoutingRecomputedFromSource
    (artifact : AcceptedProofArtifactView) : Bool :=
  match recomputeDerivedCase? artifact.source with
  | none => false
  | some derived =>
      let preparedStepCount := derived.executionRows.length
      let schedule := artifact.kernelProof.mainLane.binding.foldSchedule
      let chunkCount := artifact.kernelProof.mainLane.binding.chunkCount
      rootLaneProtocolBindingsRecomputedFromSource artifact &&
        artifact.exportedStatement.foldSchedule = schedule &&
        artifact.exportedStatement.chunkCount = chunkCount &&
        artifact.exportedKernelProof.mainLane.binding.foldSchedule = schedule &&
        artifact.exportedKernelProof.mainLane.binding.chunkCount = chunkCount &&
        (List.range preparedStepCount).all fun rowIndex =>
          decide (Nightstream.ChunkLayout.chunkIndexOf schedule rowIndex < chunkCount)

/-!
This closure layer combines three ingredients:

* replayed execution rows and semantic-row/root-lane recomputation,
* schedule-owned owning-chunk routing recovered from the carried fold schedule,
* exported row-local root-execution surfaces at the accepted-artifact boundary.

The accepted artifact only clears this closure when all three surfaces are
present together: row-local root-encode witnesses, row-local CCS-acceptance
objects, and row-local execution-semantics refinement objects.
-/
private def rowLocalRootEncodeWitnessSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  requiredRootExecutionSemanticsFieldPresent artifact .rowLocalRootEncodeWitness

private def rowLocalCCSAcceptanceSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  requiredRootExecutionSemanticsFieldPresent artifact .rowLocalCCSAcceptance

private def executionSemanticsRefinementSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  requiredRootExecutionSemanticsFieldPresent artifact .executionSemanticsRefinement

def rootExecutionSemanticsClosureFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : RootExecutionSemanticsClosureField) : Bool :=
  match field with
  | .replayedExecutionRows => replayedExecutionRowsPresent artifact
  | .semanticRowEmbeddingRecomputed =>
      semanticRowEmbeddingRecomputedFromSource artifact
  | .rootLaneProtocolBindingsRecomputed =>
      rootLaneProtocolBindingsRecomputedFromSource artifact
  | .scheduleOwnedChunkRoutingRecomputed =>
      scheduleOwnedChunkRoutingRecomputedFromSource artifact
  | .rowLocalRootEncodeWitnessSurface =>
      rowLocalRootEncodeWitnessSurfacePresent artifact
  | .rowLocalCCSAcceptanceSurface =>
      rowLocalCCSAcceptanceSurfacePresent artifact
  | .executionSemanticsRefinementSurface =>
      executionSemanticsRefinementSurfacePresent artifact
  | .rootExecutionSemanticsConstructible =>
      rootExecutionClosureAccepted artifact &&
        semanticRowEmbeddingRecomputedFromSource artifact &&
        rootLaneProtocolBindingsRecomputedFromSource artifact &&
        scheduleOwnedChunkRoutingRecomputedFromSource artifact &&
        rowLocalRootEncodeWitnessSurfacePresent artifact &&
        rowLocalCCSAcceptanceSurfacePresent artifact &&
        executionSemanticsRefinementSurfacePresent artifact

def rootExecutionSemanticsClosureChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredRootExecutionSemanticsClosureFields.map fun field =>
    (rootExecutionSemanticsClosureFieldName field,
      rootExecutionSemanticsClosureFieldPresent artifact field)

def rootExecutionSemanticsClosureAccepted
    (artifact : AcceptedProofArtifactView) : Bool :=
  (rootExecutionSemanticsClosureChecks artifact).all Prod.snd

def missingRootExecutionSemanticsClosureFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (rootExecutionSemanticsClosureChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

structure Rv64imRootExecutionSemanticsClosureReport where
  name : String
  checks : List (String × Bool)
  missing : List String
  rustExportBlockers : List String
deriving Repr

def rootExecutionSemanticsRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  requiredRootExecutionSemanticsRustExportBlockers artifact

def uniqueRootExecutionSemanticsRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      (rootExecutionSemanticsRustExportBlockers artifact).foldl
        (fun acc blocker => if blocker ∈ acc then acc else acc ++ [blocker])
        acc)
    []

def rv64imAcceptedArtifactRootExecutionSemanticsClosureChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map rootExecutionSemanticsClosureAccepted

def validGeneratedRv64imAcceptedArtifactRootExecutionSemanticsClosureCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all rootExecutionSemanticsClosureAccepted

def rv64imAcceptedArtifactRootExecutionSemanticsClosureReports :
    List Rv64imRootExecutionSemanticsClosureReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := rootExecutionSemanticsClosureChecks artifact
    , missing := missingRootExecutionSemanticsClosureFields artifact
    , rustExportBlockers := rootExecutionSemanticsRustExportBlockers artifact
    }

end Nightstream.Rv64IM
