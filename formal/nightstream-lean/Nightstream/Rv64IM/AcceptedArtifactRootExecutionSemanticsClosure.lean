import Nightstream.Rv64IM.AcceptedArtifactRootExecutionClosure
import Nightstream.Rv64IM.AcceptedArtifactRootLane
import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.Checks

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

/-
The current RV64IM accepted artifact still stops short of the theorem-bearing
execution-semantics bridge required by the kernel spec:

* Lean can replay execution rows and rebuild semantic-row/root-lane bindings.
* The artifact still does not expose row-local `RootEncode(z_j)` witnesses.
* The artifact still does not expose theorem-bearing row-local CCS acceptance
  objects for the unique chunk under the carried `FoldSchedule`.
* The artifact still does not expose a theorem-bearing refinement from those
  accepted row-local root execution objects back to RV64IM `ExecutionCorrect`.
-/
private def rowLocalRootEncodeWitnessSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def rowLocalCCSAcceptanceSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def executionSemanticsRefinementSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

def rootExecutionSemanticsClosureFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : RootExecutionSemanticsClosureField) : Bool :=
  match field with
  | .replayedExecutionRows => replayedExecutionRowsPresent artifact
  | .semanticRowEmbeddingRecomputed =>
      semanticRowEmbeddingRecomputedFromSource artifact
  | .rootLaneProtocolBindingsRecomputed =>
      rootLaneProtocolBindingsRecomputedFromSource artifact
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
  let blockers : List (String × Bool) :=
    [ ( "root_execution_rows_missing_row_local_root_encode_witnesses"
      , rowLocalRootEncodeWitnessSurfacePresent artifact
      )
    , ( "root_execution_rows_missing_row_local_ccs_acceptance_objects"
      , rowLocalCCSAcceptanceSurfacePresent artifact
      )
    , ( "root_execution_rows_missing_execution_correct_refinement_objects"
      , executionSemanticsRefinementSurfacePresent artifact
      )
    ]
  blockers.filterMap fun (name, ok) =>
    if ok then none else some name

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
