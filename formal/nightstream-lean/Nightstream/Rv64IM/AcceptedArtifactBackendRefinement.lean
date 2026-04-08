import Nightstream.ChunkLayout
import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.Checks
import Nightstream.Rv64IM.Kernel.RequiredBackendPayloadSurface
import Nightstream.Rv64IM.ProofBoundaryChecks

/-!
Executable audit for the missing RV64IM last-mile refinement into the proved
SuperNeo backend statements `Π_CCS / Π_RLC / Π_DEC`. This owner is intentionally
strict: it treats schedule/chunk parity as recomputable from low-level inputs
and reports the current absence of theorem-bearing backend payloads as a hard
closure failure.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive BackendRefinementField where
  | foldScheduleAlignment
  | chunkCountAlignment
  | publicStepCountAlignment
  | chunkLayoutRecomputed
  | replayedPublicStepCount
  | scheduleOwnedChunkRoutingRecomputed
  | lowLevelChunkPayloadSurface
  | mainLanePayloadSurface
  | stageClaimPayloadSurface
  | stagePackagePayloadSurface
  | kernelOpeningPayloadSurface
  | piCCSContextReconstructible
  | piRLCContextReconstructible
  | piDECContextReconstructible
  | piCCSPayload
  | piRLCPayload
  | piDECPayload
  | piCCSRefinement
  | piRLCRefinement
  | piDECRefinement
deriving DecidableEq, Repr

def backendRefinementFieldName : BackendRefinementField → String
  | .foldScheduleAlignment => "fold_schedule_alignment"
  | .chunkCountAlignment => "chunk_count_alignment"
  | .publicStepCountAlignment => "public_step_count_alignment"
  | .chunkLayoutRecomputed => "chunk_layout_recomputed"
  | .replayedPublicStepCount => "replayed_public_step_count"
  | .scheduleOwnedChunkRoutingRecomputed =>
      "schedule_owned_chunk_routing_recomputed"
  | .lowLevelChunkPayloadSurface => "low_level_chunk_payload_surface"
  | .mainLanePayloadSurface => "main_lane_payload_surface"
  | .stageClaimPayloadSurface => "stage_claim_payload_surface"
  | .stagePackagePayloadSurface => "stage_package_payload_surface"
  | .kernelOpeningPayloadSurface => "kernel_opening_payload_surface"
  | .piCCSContextReconstructible => "pi_ccs_context_reconstructible"
  | .piRLCContextReconstructible => "pi_rlc_context_reconstructible"
  | .piDECContextReconstructible => "pi_dec_context_reconstructible"
  | .piCCSPayload => "pi_ccs_payload"
  | .piRLCPayload => "pi_rlc_payload"
  | .piDECPayload => "pi_dec_payload"
  | .piCCSRefinement => "pi_ccs_refinement"
  | .piRLCRefinement => "pi_rlc_refinement"
  | .piDECRefinement => "pi_dec_refinement"

def requiredBackendRefinementFields : List BackendRefinementField :=
  [ .foldScheduleAlignment
  , .chunkCountAlignment
  , .publicStepCountAlignment
  , .chunkLayoutRecomputed
  , .replayedPublicStepCount
  , .scheduleOwnedChunkRoutingRecomputed
  , .lowLevelChunkPayloadSurface
  , .mainLanePayloadSurface
  , .stageClaimPayloadSurface
  , .stagePackagePayloadSurface
  , .kernelOpeningPayloadSurface
  , .piCCSContextReconstructible
  , .piRLCContextReconstructible
  , .piDECContextReconstructible
  , .piCCSPayload
  , .piRLCPayload
  , .piDECPayload
  , .piCCSRefinement
  , .piRLCRefinement
  , .piDECRefinement
  ]

private def replayedPreparedStepCount? (artifact : AcceptedProofArtifactView) : Option Nat :=
  recomputeDerivedCase? artifact.source |>.map fun derived => derived.executionRows.length

private def exportedFoldScheduleAligned (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.exportedProof.statement.foldSchedule = artifact.exportedStatement.foldSchedule &&
    artifact.exportedStatement.foldSchedule = artifact.exportedKernelProof.mainLane.binding.foldSchedule &&
    artifact.exportedKernelProof.mainLane.binding.foldSchedule = artifact.kernelProof.mainLane.binding.foldSchedule

private def exportedChunkCountAligned (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.exportedProof.statement.chunkCount = artifact.exportedStatement.chunkCount &&
    artifact.exportedStatement.chunkCount = artifact.exportedKernelProof.mainLane.binding.chunkCount &&
    artifact.exportedKernelProof.mainLane.binding.chunkCount = artifact.kernelProof.mainLane.binding.chunkCount

private def exportedPublicStepCountAligned (artifact : AcceptedProofArtifactView) : Bool :=
  artifact.exportedProof.statement.publicStepCount = artifact.exportedStatement.publicStepCount &&
    artifact.exportedStatement.publicStepCount =
      artifact.exportedKernelProof.mainLane.binding.publicStepCount &&
    artifact.exportedKernelProof.mainLane.binding.publicStepCount =
      artifact.kernelProof.mainLane.binding.publicStepCount

private def replayedPublicStepCountMatchesExported (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedPreparedStepCount? artifact with
  | none => false
  | some preparedStepCount =>
      exportedPublicStepCountAligned artifact &&
        preparedStepCount = artifact.exportedStatement.publicStepCount &&
        preparedStepCount = artifact.kernelProof.mainLane.binding.publicStepCount

private def recomputedChunkLayoutMatchesExported (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedPreparedStepCount? artifact with
  | none => false
  | some preparedStepCount =>
      let schedule := artifact.kernelProof.mainLane.binding.foldSchedule
      let layout := Nightstream.ChunkLayout.layout schedule preparedStepCount
      let count := Nightstream.ChunkLayout.layout schedule preparedStepCount |>.length
      exportedFoldScheduleAligned artifact &&
        exportedChunkCountAligned artifact &&
        replayedPublicStepCountMatchesExported artifact &&
        count = artifact.kernelProof.mainLane.binding.chunkCount &&
        count = artifact.exportedStatement.chunkCount &&
        layout.length = Nightstream.FoldSchedule.chunkCount schedule preparedStepCount

private def scheduleOwnedChunkRoutingRecomputedFromSource
    (artifact : AcceptedProofArtifactView) : Bool :=
  match replayedPreparedStepCount? artifact with
  | none => false
  | some preparedStepCount =>
      let schedule := artifact.kernelProof.mainLane.binding.foldSchedule
      let chunkCount := artifact.kernelProof.mainLane.binding.chunkCount
      recomputedChunkLayoutMatchesExported artifact &&
        (List.range preparedStepCount).all fun rowIndex =>
          decide (Nightstream.ChunkLayout.chunkIndexOf schedule rowIndex < chunkCount)

private def lowLevelChunkPayloadSurfacePresent (artifact : AcceptedProofArtifactView) : Bool :=
  requiredBackendPayloadFieldPresent artifact .chunkPayloadList

private def mainLanePayloadSurfacePresent (artifact : AcceptedProofArtifactView) : Bool :=
  requiredBackendPayloadFieldPresent artifact .mainLanePiCCSPayload

private def stageClaimPayloadSurfacePresent (artifact : AcceptedProofArtifactView) : Bool :=
  requiredBackendPayloadFieldPresent artifact .stageClaimPiRLCPayload

private def stagePackagePayloadSurfacePresent (artifact : AcceptedProofArtifactView) : Bool :=
  requiredBackendPayloadFieldPresent artifact .stagePackagePiRLCPayload

private def kernelOpeningPayloadSurfacePresent (artifact : AcceptedProofArtifactView) : Bool :=
  requiredBackendPayloadFieldPresent artifact .kernelOpeningPiDECPayload

private def piCCSContextReconstructible (artifact : AcceptedProofArtifactView) : Bool :=
  scheduleOwnedChunkRoutingRecomputedFromSource artifact &&
    lowLevelChunkPayloadSurfacePresent artifact &&
    mainLanePayloadSurfacePresent artifact

private def piRLCContextReconstructible (artifact : AcceptedProofArtifactView) : Bool :=
  piCCSContextReconstructible artifact &&
    stageClaimPayloadSurfacePresent artifact &&
    stagePackagePayloadSurfacePresent artifact

private def piDECContextReconstructible (artifact : AcceptedProofArtifactView) : Bool :=
  piRLCContextReconstructible artifact &&
    kernelOpeningPayloadSurfacePresent artifact

def backendRefinementFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : BackendRefinementField) : Bool :=
  match field with
  | .foldScheduleAlignment => exportedFoldScheduleAligned artifact
  | .chunkCountAlignment => exportedChunkCountAligned artifact
  | .publicStepCountAlignment => exportedPublicStepCountAligned artifact
  | .chunkLayoutRecomputed => recomputedChunkLayoutMatchesExported artifact
  | .replayedPublicStepCount => replayedPublicStepCountMatchesExported artifact
  | .scheduleOwnedChunkRoutingRecomputed =>
      scheduleOwnedChunkRoutingRecomputedFromSource artifact
  | .lowLevelChunkPayloadSurface => lowLevelChunkPayloadSurfacePresent artifact
  | .mainLanePayloadSurface => mainLanePayloadSurfacePresent artifact
  | .stageClaimPayloadSurface => stageClaimPayloadSurfacePresent artifact
  | .stagePackagePayloadSurface => stagePackagePayloadSurfacePresent artifact
  | .kernelOpeningPayloadSurface => kernelOpeningPayloadSurfacePresent artifact
  | .piCCSContextReconstructible => piCCSContextReconstructible artifact
  | .piRLCContextReconstructible => piRLCContextReconstructible artifact
  | .piDECContextReconstructible => piDECContextReconstructible artifact
  | .piCCSPayload => mainLanePayloadSurfacePresent artifact
  | .piRLCPayload =>
      stageClaimPayloadSurfacePresent artifact &&
        stagePackagePayloadSurfacePresent artifact
  | .piDECPayload => kernelOpeningPayloadSurfacePresent artifact
  | .piCCSRefinement => piCCSContextReconstructible artifact
  | .piRLCRefinement => piRLCContextReconstructible artifact
  | .piDECRefinement => piDECContextReconstructible artifact

def backendRefinementChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredBackendRefinementFields.map fun field =>
    (backendRefinementFieldName field, backendRefinementFieldPresent artifact field)

def backendRefinementAccepted (artifact : AcceptedProofArtifactView) : Bool :=
  (backendRefinementChecks artifact).all Prod.snd

def missingBackendRefinementFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (backendRefinementChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

structure Rv64imBackendRefinementReport where
  name : String
  checks : List (String × Bool)
  missing : List String
  rustExportBlockers : List String
deriving Repr

def backendRefinementRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  requiredBackendPayloadRustExportBlockers artifact

def uniqueBackendRefinementRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      (backendRefinementRustExportBlockers artifact).foldl
        (fun acc blocker => if blocker ∈ acc then acc else acc ++ [blocker])
        acc)
    []

def rv64imAcceptedArtifactBackendRefinementChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map backendRefinementAccepted

def validGeneratedRv64imAcceptedArtifactBackendRefinementCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all backendRefinementAccepted

def rv64imAcceptedArtifactBackendRefinementReports : List Rv64imBackendRefinementReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := backendRefinementChecks artifact
    , missing := missingBackendRefinementFields artifact
    , rustExportBlockers := backendRefinementRustExportBlockers artifact
    }

end Nightstream.Rv64IM
