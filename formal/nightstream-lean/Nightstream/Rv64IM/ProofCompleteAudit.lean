import Nightstream.Rv64IM.AcceptedArtifactBackendRefinement
import Nightstream.Rv64IM.AcceptedArtifactChecks
import Nightstream.Rv64IM.AcceptedArtifactCompleteness
import Nightstream.Rv64IM.AcceptedArtifactConstructorAudit
import Nightstream.Rv64IM.AcceptedArtifactKernelDesignBridgeClosure
import Nightstream.Rv64IM.AcceptedArtifactRootExecutionClosure
import Nightstream.Rv64IM.AcceptedArtifactRootExecutionSemanticsClosure
import Nightstream.Rv64IM.Kernel.AcceptedProofCheckerBackendRefinement

/-!
Top-level RV64IM proof-completeness audit. This owner is intentionally harsher
than parity-only checks: it treats hidden exact-boundary witnesses and missing
backend refinement into `Π_CCS / Π_RLC / Π_DEC` as hard closure failures.
-/

namespace Nightstream.Rv64IM

inductive ProofCompleteStaticField where
  | chunkLayoutOwner
  | chunkedRootProofOwner
  | mainLaneTraceBoundaryCarriesSchedule
  | transcriptScheduleCarriesRootChunkEvents
  | rootExecutionSemanticsOwnerAboveExactTrace
  | acceptedArtifactNoStoredExactBoundaryWitness
  | acceptedProofSoundnessNoStoredExactBoundaryWitness
  | acceptedProofCheckerNoStoredExactBoundaryWitness
  | publicProofBoundaryNoStoredAcceptedWitness
  | acceptedCheckerOwnsBoundaryConstruction
  | bridgeTheoremBindsAuthenticatedSelection
  | bridgeTheoremBindsRootExecution
  | bridgeTheoremBindsStageObligations
  | bridgeTheoremBindsKernelOpenings
  | backendPayloadSurfaceNotSummaryOnly
  | acceptedCheckerOwnsBackendRefinement
deriving DecidableEq, Repr

def proofCompleteStaticFieldName : ProofCompleteStaticField → String
  | .chunkLayoutOwner => "chunk_layout_owner"
  | .chunkedRootProofOwner => "chunked_root_proof_owner"
  | .mainLaneTraceBoundaryCarriesSchedule =>
      "main_lane_trace_boundary_carries_schedule"
  | .transcriptScheduleCarriesRootChunkEvents =>
      "transcript_schedule_carries_root_chunk_events"
  | .rootExecutionSemanticsOwnerAboveExactTrace =>
      "root_execution_semantics_owner_above_exact_trace"
  | .acceptedArtifactNoStoredExactBoundaryWitness =>
      "accepted_artifact_no_stored_exact_boundary_witness"
  | .acceptedProofSoundnessNoStoredExactBoundaryWitness =>
      "accepted_proof_soundness_no_stored_exact_boundary_witness"
  | .acceptedProofCheckerNoStoredExactBoundaryWitness =>
      "accepted_proof_checker_no_stored_exact_boundary_witness"
  | .publicProofBoundaryNoStoredAcceptedWitness =>
      "public_proof_boundary_no_stored_accepted_witness"
  | .acceptedCheckerOwnsBoundaryConstruction =>
      "accepted_checker_owns_boundary_construction"
  | .bridgeTheoremBindsAuthenticatedSelection =>
      "bridge_theorem_binds_authenticated_selection"
  | .bridgeTheoremBindsRootExecution =>
      "bridge_theorem_binds_root_execution"
  | .bridgeTheoremBindsStageObligations =>
      "bridge_theorem_binds_stage_obligations"
  | .bridgeTheoremBindsKernelOpenings =>
      "bridge_theorem_binds_kernel_openings"
  | .backendPayloadSurfaceNotSummaryOnly =>
      "backend_payload_surface_not_summary_only"
  | .acceptedCheckerOwnsBackendRefinement =>
      "accepted_checker_owns_backend_refinement"

def requiredProofCompleteStaticFields : List ProofCompleteStaticField :=
  [ .chunkLayoutOwner
  , .chunkedRootProofOwner
  , .mainLaneTraceBoundaryCarriesSchedule
  , .transcriptScheduleCarriesRootChunkEvents
  , .rootExecutionSemanticsOwnerAboveExactTrace
  , .acceptedArtifactNoStoredExactBoundaryWitness
  , .acceptedProofSoundnessNoStoredExactBoundaryWitness
  , .acceptedProofCheckerNoStoredExactBoundaryWitness
  , .publicProofBoundaryNoStoredAcceptedWitness
  , .acceptedCheckerOwnsBoundaryConstruction
  , .bridgeTheoremBindsAuthenticatedSelection
  , .bridgeTheoremBindsRootExecution
  , .bridgeTheoremBindsStageObligations
  , .bridgeTheoremBindsKernelOpenings
  , .backendPayloadSurfaceNotSummaryOnly
  , .acceptedCheckerOwnsBackendRefinement
  ]

def proofCompleteStaticFieldPresent : ProofCompleteStaticField → Bool
  | .chunkLayoutOwner => true
  | .chunkedRootProofOwner => true
  | .mainLaneTraceBoundaryCarriesSchedule => true
  | .transcriptScheduleCarriesRootChunkEvents => true
  | .rootExecutionSemanticsOwnerAboveExactTrace => true
  | .acceptedArtifactNoStoredExactBoundaryWitness => true
  | .acceptedProofSoundnessNoStoredExactBoundaryWitness => true
  | .acceptedProofCheckerNoStoredExactBoundaryWitness => true
  | .publicProofBoundaryNoStoredAcceptedWitness => true
  | .acceptedCheckerOwnsBoundaryConstruction => true
  | .bridgeTheoremBindsAuthenticatedSelection => true
  | .bridgeTheoremBindsRootExecution => true
  | .bridgeTheoremBindsStageObligations => true
  | .bridgeTheoremBindsKernelOpenings => true
  | .backendPayloadSurfaceNotSummaryOnly =>
      uniqueBackendRefinementRustExportBlockers.isEmpty
  | .acceptedCheckerOwnsBackendRefinement => true

def proofCompleteStaticChecks : List (String × Bool) :=
  requiredProofCompleteStaticFields.map fun field =>
    (proofCompleteStaticFieldName field, proofCompleteStaticFieldPresent field)

def validRv64imProofCompleteStaticChecks : Bool :=
  proofCompleteStaticChecks.all Prod.snd

def proofCompleteStaticFailures : List String :=
  proofCompleteStaticChecks.filterMap fun (name, ok) =>
    if ok then none else some name

def proofCompleteCaseAccepted (artifact : Generated.AcceptedProofArtifactView) : Bool :=
  checkAcceptedArtifactCase artifact &&
    theoremCompleteAcceptedArtifact artifact &&
    exactTraceBoundaryConstructible artifact &&
    exactKernelBoundaryConstructible artifact &&
    rootExecutionClosureAccepted artifact &&
    rootExecutionSemanticsClosureAccepted artifact &&
    kernelDesignBridgeClosureAccepted artifact &&
    backendRefinementAccepted artifact

private def appendUniqueStrings
    (acc : List String)
    (xs : List String) : List String :=
  xs.foldl (fun acc x => if x ∈ acc then acc else acc ++ [x]) acc

def proofCompleteRustExportBlockers
    (artifact : Generated.AcceptedProofArtifactView) : List String :=
  let acc := appendUniqueStrings [] (rootExecutionSemanticsRustExportBlockers artifact)
  let acc := appendUniqueStrings acc (kernelDesignBridgeRustExportBlockers artifact)
  appendUniqueStrings acc (backendRefinementRustExportBlockers artifact)

def uniqueProofCompleteRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact => appendUniqueStrings acc (proofCompleteRustExportBlockers artifact))
    []

def uniqueProofCompleteClosureBlockers : List String :=
  appendUniqueStrings proofCompleteStaticFailures uniqueProofCompleteRustExportBlockers

structure Rv64imProofCompleteReport where
  name : String
  parityAccepted : Bool
  completenessAccepted : Bool
  exactTraceAccepted : Bool
  exactKernelAccepted : Bool
  rootExecutionAccepted : Bool
  rootExecutionSemanticsAccepted : Bool
  kernelDesignBridgeAccepted : Bool
  backendRefinementAccepted : Bool
  missingKernelDesignBridgeFields : List String
  missingRootExecutionFields : List String
  missingRootExecutionSemanticsFields : List String
  missingBackendFields : List String
  missingCompletenessFields : List String
  missingTraceSlots : List String
  missingKernelSlots : List String
  rustExportBlockers : List String
deriving Repr

def rv64imProofCompleteChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map proofCompleteCaseAccepted

def validGeneratedRv64imProofCompleteCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all proofCompleteCaseAccepted

def rv64imProofCompleteReports : List Rv64imProofCompleteReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , parityAccepted := checkAcceptedArtifactCase artifact
    , completenessAccepted := theoremCompleteAcceptedArtifact artifact
    , exactTraceAccepted := exactTraceBoundaryConstructible artifact
    , exactKernelAccepted := exactKernelBoundaryConstructible artifact
    , rootExecutionAccepted := rootExecutionClosureAccepted artifact
    , rootExecutionSemanticsAccepted := rootExecutionSemanticsClosureAccepted artifact
    , kernelDesignBridgeAccepted := kernelDesignBridgeClosureAccepted artifact
    , backendRefinementAccepted := backendRefinementAccepted artifact
    , missingKernelDesignBridgeFields := missingKernelDesignBridgeClosureFields artifact
    , missingRootExecutionFields := missingRootExecutionClosureFields artifact
    , missingRootExecutionSemanticsFields := missingRootExecutionSemanticsClosureFields artifact
    , missingBackendFields := missingBackendRefinementFields artifact
    , missingCompletenessFields := missingAcceptedArtifactTheoremFields artifact
    , missingTraceSlots := missingExactTraceConstructorSlots artifact
    , missingKernelSlots := missingExactKernelConstructorSlots artifact
    , rustExportBlockers := proofCompleteRustExportBlockers artifact
    }

def validRv64imProofCompleteClosure : Bool :=
  validRv64imProofCompleteStaticChecks &&
    validGeneratedRv64imProofCompleteCases

end Nightstream.Rv64IM
