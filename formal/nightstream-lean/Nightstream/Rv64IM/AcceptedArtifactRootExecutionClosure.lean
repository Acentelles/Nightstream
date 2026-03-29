import Nightstream.Rv64IM.AcceptedArtifactBackendRefinement
import Nightstream.Rv64IM.AcceptedArtifactRootLane
import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.Checks

/-!
Executable audit for whether a low-level RV64IM artifact can instantiate the
theorem-owned `ChunkedRootProofPackage`. This owner is intentionally strict: a
summary-shaped main-lane bundle does not count as a root execution proof.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive RootExecutionClosureField where
  | replayedExecutionRows
  | rootLaneProtocolBindingsRecomputed
  | chunkLayoutAlignment
  | lowLevelChunkPayloadSurface
  | mainLanePayloadSurface
  | piCCSContextReconstructible
  | piRLCContextReconstructible
  | piDECContextReconstructible
  | chunkedRootProofConstructible
deriving DecidableEq, Repr

def rootExecutionClosureFieldName : RootExecutionClosureField → String
  | .replayedExecutionRows => "replayed_execution_rows"
  | .rootLaneProtocolBindingsRecomputed => "root_lane_protocol_bindings_recomputed"
  | .chunkLayoutAlignment => "chunk_layout_alignment"
  | .lowLevelChunkPayloadSurface => "low_level_chunk_payload_surface"
  | .mainLanePayloadSurface => "main_lane_payload_surface"
  | .piCCSContextReconstructible => "pi_ccs_context_reconstructible"
  | .piRLCContextReconstructible => "pi_rlc_context_reconstructible"
  | .piDECContextReconstructible => "pi_dec_context_reconstructible"
  | .chunkedRootProofConstructible => "chunked_root_proof_constructible"

def requiredRootExecutionClosureFields : List RootExecutionClosureField :=
  [ .replayedExecutionRows
  , .rootLaneProtocolBindingsRecomputed
  , .chunkLayoutAlignment
  , .lowLevelChunkPayloadSurface
  , .mainLanePayloadSurface
  , .piCCSContextReconstructible
  , .piRLCContextReconstructible
  , .piDECContextReconstructible
  , .chunkedRootProofConstructible
  ]

private def replayedExecutionRowsPresent (artifact : AcceptedProofArtifactView) : Bool :=
  (recomputeDerivedCase? artifact.source).isSome

private def rootLaneProtocolBindingsRecomputed
    (artifact : AcceptedProofArtifactView) : Bool :=
  match recomputeDerivedCase? artifact.source with
  | none => false
  | some derived =>
      recomputedRootLaneProtocolBindingsMatchArtifact
        (recomputeRootLaneView derived.executionRows)
        artifact

private def chunkedRootProofConstructible
    (artifact : AcceptedProofArtifactView) : Bool :=
  replayedExecutionRowsPresent artifact &&
    rootLaneProtocolBindingsRecomputed artifact &&
    backendRefinementFieldPresent artifact .chunkLayoutRecomputed &&
    backendRefinementFieldPresent artifact .lowLevelChunkPayloadSurface &&
    backendRefinementFieldPresent artifact .mainLanePayloadSurface &&
    backendRefinementFieldPresent artifact .piCCSContextReconstructible &&
    backendRefinementFieldPresent artifact .piRLCContextReconstructible &&
    backendRefinementFieldPresent artifact .piDECContextReconstructible

def rootExecutionClosureFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : RootExecutionClosureField) : Bool :=
  match field with
  | .replayedExecutionRows => replayedExecutionRowsPresent artifact
  | .rootLaneProtocolBindingsRecomputed => rootLaneProtocolBindingsRecomputed artifact
  | .chunkLayoutAlignment =>
      backendRefinementFieldPresent artifact .chunkLayoutRecomputed
  | .lowLevelChunkPayloadSurface =>
      backendRefinementFieldPresent artifact .lowLevelChunkPayloadSurface
  | .mainLanePayloadSurface =>
      backendRefinementFieldPresent artifact .mainLanePayloadSurface
  | .piCCSContextReconstructible =>
      backendRefinementFieldPresent artifact .piCCSContextReconstructible
  | .piRLCContextReconstructible =>
      backendRefinementFieldPresent artifact .piRLCContextReconstructible
  | .piDECContextReconstructible =>
      backendRefinementFieldPresent artifact .piDECContextReconstructible
  | .chunkedRootProofConstructible =>
      chunkedRootProofConstructible artifact

def rootExecutionClosureChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredRootExecutionClosureFields.map fun field =>
    (rootExecutionClosureFieldName field, rootExecutionClosureFieldPresent artifact field)

def rootExecutionClosureAccepted (artifact : AcceptedProofArtifactView) : Bool :=
  (rootExecutionClosureChecks artifact).all Prod.snd

def missingRootExecutionClosureFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (rootExecutionClosureChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

structure Rv64imRootExecutionClosureReport where
  name : String
  checks : List (String × Bool)
  missing : List String
deriving Repr

def rv64imAcceptedArtifactRootExecutionClosureChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map rootExecutionClosureAccepted

def validGeneratedRv64imAcceptedArtifactRootExecutionClosureCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all rootExecutionClosureAccepted

def rv64imAcceptedArtifactRootExecutionClosureReports :
    List Rv64imRootExecutionClosureReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := rootExecutionClosureChecks artifact
    , missing := missingRootExecutionClosureFields artifact
    }

end Nightstream.Rv64IM
