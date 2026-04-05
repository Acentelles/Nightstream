import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus

/-!
Owns the theorem-facing RV64IM export surface required to construct the full
kernel-design bridge owner. This file states which authenticated-selection,
stage, and opening provenance objects must exist before Lean can bind
authenticated selection, root execution, and kernel openings into one theorem
surface.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive RequiredKernelDesignBridgeField where
  | authenticatedSelectionPayload
  | selectedRowPreparedStepBinding
  | selectedRowScheduledChunkRouting
  | stage1ObligationPayload
  | stage2ObligationPayload
  | stage3ObligationPayload
  | kernelOpeningProvenance
deriving DecidableEq, Repr

def requiredKernelDesignBridgeFieldName :
    RequiredKernelDesignBridgeField → String
  | .authenticatedSelectionPayload => "authenticated_selection_payload_surface"
  | .selectedRowPreparedStepBinding => "selected_row_prepared_step_binding_surface"
  | .selectedRowScheduledChunkRouting =>
      "selected_row_scheduled_chunk_routing_surface"
  | .stage1ObligationPayload => "stage1_obligation_payload_surface"
  | .stage2ObligationPayload => "stage2_obligation_payload_surface"
  | .stage3ObligationPayload => "stage3_obligation_payload_surface"
  | .kernelOpeningProvenance => "kernel_opening_provenance_surface"

def requiredKernelDesignBridgeFields :
    List RequiredKernelDesignBridgeField :=
  [ .authenticatedSelectionPayload
  , .selectedRowPreparedStepBinding
  , .selectedRowScheduledChunkRouting
  , .stage1ObligationPayload
  , .stage2ObligationPayload
  , .stage3ObligationPayload
  , .kernelOpeningProvenance
  ]

def requiredKernelDesignBridgeFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : RequiredKernelDesignBridgeField) : Bool :=
  match field with
  | .authenticatedSelectionPayload =>
      artifact.stage1.selectedOpening.digest ≠ [] &&
        artifact.stage2.selectedOpening.digest ≠ [] &&
        artifact.stage3.selectedOpening.digest ≠ []
  | .selectedRowPreparedStepBinding =>
      !artifact.rootExecution.preparedStepBindings.bindings.isEmpty &&
        artifact.rootExecution.preparedStepBindings.bindingCount =
          artifact.rootExecution.preparedStepBindings.bindings.length &&
        artifact.rootExecution.preparedStepBindings.digest ≠ []
  | .selectedRowScheduledChunkRouting =>
      !artifact.rootExecution.rowChunkRoutes.isEmpty &&
        artifact.rootExecution.rowChunkRoutes.length =
          artifact.rootExecution.executionRows.length &&
        artifact.rootExecution.rowChunkRoutesDigest ≠ []
  | .stage1ObligationPayload =>
      !artifact.stage1.semInputs.isEmpty &&
        !artifact.stage1.rowBindings.isEmpty &&
        artifact.stage1.semantics.digest ≠ [] &&
        artifact.stage1.digest ≠ []
  | .stage2ObligationPayload =>
      !artifact.stage2.temporal.twistLinks.isEmpty &&
        artifact.stage2.semantics.digest ≠ [] &&
        artifact.stage2.digest ≠ []
  | .stage3ObligationPayload =>
      !artifact.stage3.continuity.isEmpty &&
        artifact.stage3.semantics.digest ≠ [] &&
        artifact.stage3.digest ≠ []
  | .kernelOpeningProvenance =>
      let opening := artifact.kernelOpeningBundle
      opening.digest ≠ [] &&
        opening.digest = artifact.kernelProof.kernelOpening.openingDigest &&
        opening.claim.digest = artifact.kernelProof.kernelOpening.bindings.claimDigest &&
        opening.bindings.digest = artifact.kernelProof.kernelOpening.bindings.bindingsDigest &&
        opening.preparedSteps.digest =
          artifact.kernelProof.kernelOpening.bindings.preparedStepsDigest &&
        opening.bindings.claim = opening.claim.bindings &&
        opening.preparedSteps.claim = opening.claim.preparedSteps &&
        opening.claim.bindings.stageClaimBundleDigest =
          artifact.kernelProof.stageClaims.summary.claimBundleDigest &&
        opening.claim.bindings.stagePackageBundleDigest =
          artifact.kernelProof.stagePackages.summary.packageBundleDigest &&
        opening.claim.bindings.stage1PackageDigest =
          artifact.kernelProof.stagePackages.summary.stage1Digest &&
        opening.claim.bindings.stage2PackageDigest =
          artifact.kernelProof.stagePackages.summary.stage2Digest &&
        opening.claim.bindings.stage3PackageDigest =
          artifact.kernelProof.stagePackages.summary.stage3Digest &&
        artifact.kernelProof.stagePackages.summary.stage1Digest =
          artifact.stage1.selectedOpening.digest &&
        artifact.kernelProof.stagePackages.summary.stage2Digest =
          artifact.stage2.selectedOpening.digest &&
        artifact.kernelProof.stagePackages.summary.stage3Digest =
          artifact.stage3.selectedOpening.digest &&
        opening.claim.bindings.preparedStepBindingsDigest =
          artifact.rootExecution.preparedStepBindings.digest

def requiredKernelDesignBridgeChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredKernelDesignBridgeFields.map fun field =>
    (requiredKernelDesignBridgeFieldName field,
      requiredKernelDesignBridgeFieldPresent artifact field)

def requiredKernelDesignBridgeSurfacePresent
    (artifact : AcceptedProofArtifactView) : Bool :=
  (requiredKernelDesignBridgeChecks artifact).all Prod.snd

def missingRequiredKernelDesignBridgeFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (requiredKernelDesignBridgeChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

def uniqueMissingRequiredKernelDesignBridgeFields : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      (missingRequiredKernelDesignBridgeFields artifact).foldl
        (fun acc field => if field ∈ acc then acc else acc ++ [field])
        acc)
    []

def requiredKernelDesignBridgeRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  let blockers : List (String × Bool) :=
    [ ( "twist_shout_selected_rows_missing_authenticated_selection_payloads"
      , requiredKernelDesignBridgeFieldPresent artifact .authenticatedSelectionPayload
      )
    , ( "twist_shout_selected_rows_missing_selected_row_prepared_step_bindings"
      , requiredKernelDesignBridgeFieldPresent artifact .selectedRowPreparedStepBinding
      )
    , ( "selected_rows_missing_schedule_owned_root_chunk_routing_bindings"
      , requiredKernelDesignBridgeFieldPresent artifact .selectedRowScheduledChunkRouting
      )
    , ( "stage1_missing_theorem_bearing_obligation_payloads"
      , requiredKernelDesignBridgeFieldPresent artifact .stage1ObligationPayload
      )
    , ( "stage2_missing_theorem_bearing_obligation_payloads"
      , requiredKernelDesignBridgeFieldPresent artifact .stage2ObligationPayload
      )
    , ( "stage3_missing_theorem_bearing_obligation_payloads"
      , requiredKernelDesignBridgeFieldPresent artifact .stage3ObligationPayload
      )
    , ( "kernel_openings_missing_provenance_chains"
      , requiredKernelDesignBridgeFieldPresent artifact .kernelOpeningProvenance
      )
    ]
  blockers.filterMap fun (name, ok) =>
    if ok then none else some name

private def appendUniqueStrings
    (acc : List String)
    (xs : List String) : List String :=
  xs.foldl (fun acc x => if x ∈ acc then acc else acc ++ [x]) acc

def uniqueRequiredKernelDesignBridgeRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      appendUniqueStrings acc (requiredKernelDesignBridgeRustExportBlockers artifact))
    []

structure Rv64imRequiredKernelDesignBridgeReport where
  name : String
  checks : List (String × Bool)
  missing : List String
  rustExportBlockers : List String
deriving Repr

def rv64imRequiredKernelDesignBridgeChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map requiredKernelDesignBridgeSurfacePresent

def validGeneratedRv64imRequiredKernelDesignBridgeCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all requiredKernelDesignBridgeSurfacePresent

def rv64imRequiredKernelDesignBridgeReports :
    List Rv64imRequiredKernelDesignBridgeReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := requiredKernelDesignBridgeChecks artifact
    , missing := missingRequiredKernelDesignBridgeFields artifact
    , rustExportBlockers := requiredKernelDesignBridgeRustExportBlockers artifact
    }

end Nightstream.Rv64IM
