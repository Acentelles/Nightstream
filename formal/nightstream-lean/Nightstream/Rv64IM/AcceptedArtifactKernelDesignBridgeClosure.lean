import Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus
import Nightstream.Rv64IM.AcceptedArtifactRootExecutionSemanticsClosure

/-!
Executable audit for whether the exported RV64IM accepted artifact is strong
enough to construct the full kernel-design bridge owner. This is intentionally
strict: digest-level parity is irrelevant if Lean cannot construct theorem-
bearing authenticated selection, routing, stage, and opening surfaces.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

inductive KernelDesignBridgeClosureField where
  | rootExecutionSemanticsClosure
  | authenticatedSelectionPayloadSurface
  | selectedRowPreparedStepBindingSurface
  | selectedRowChunkRoutingSurface
  | stage1ObligationPayloadSurface
  | stage2ObligationPayloadSurface
  | stage3ObligationPayloadSurface
  | kernelOpeningProvenanceSurface
  | kernelDesignBridgeConstructible
deriving DecidableEq, Repr

def kernelDesignBridgeClosureFieldName : KernelDesignBridgeClosureField → String
  | .rootExecutionSemanticsClosure => "root_execution_semantics_closure"
  | .authenticatedSelectionPayloadSurface =>
      "authenticated_selection_payload_surface"
  | .selectedRowPreparedStepBindingSurface =>
      "selected_row_prepared_step_binding_surface"
  | .selectedRowChunkRoutingSurface =>
      "selected_row_chunk_routing_surface"
  | .stage1ObligationPayloadSurface => "stage1_obligation_payload_surface"
  | .stage2ObligationPayloadSurface => "stage2_obligation_payload_surface"
  | .stage3ObligationPayloadSurface => "stage3_obligation_payload_surface"
  | .kernelOpeningProvenanceSurface => "kernel_opening_provenance_surface"
  | .kernelDesignBridgeConstructible => "kernel_design_bridge_constructible"

def requiredKernelDesignBridgeClosureFields :
    List KernelDesignBridgeClosureField :=
  [ .rootExecutionSemanticsClosure
  , .authenticatedSelectionPayloadSurface
  , .selectedRowPreparedStepBindingSurface
  , .selectedRowChunkRoutingSurface
  , .stage1ObligationPayloadSurface
  , .stage2ObligationPayloadSurface
  , .stage3ObligationPayloadSurface
  , .kernelOpeningProvenanceSurface
  , .kernelDesignBridgeConstructible
  ]

/-
The current exported accepted artifact is still summary-shaped:

* authenticated selected-row bindings are visible only as digests and selected
  opening summaries,
* root execution payloads are summary-only unless the stricter root-execution-
  semantics closure audit says otherwise,
* Stage 1 / Stage 2 / Stage 3 are exported as replay summaries and digest
  bundles, not theorem-bearing proof packages,
* kernel openings are exported as digest bundles, not opening provenance chains.

This audit therefore hard-fails the missing theorem-bearing bridge surfaces.
-/
private def authenticatedSelectionPayloadSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def selectedRowPreparedStepBindingSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def selectedRowChunkRoutingSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def stage1ObligationPayloadSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def stage2ObligationPayloadSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def stage3ObligationPayloadSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

private def kernelOpeningProvenanceSurfacePresent
    (_artifact : AcceptedProofArtifactView) : Bool :=
  false

def kernelDesignBridgeClosureFieldPresent
    (artifact : AcceptedProofArtifactView)
    (field : KernelDesignBridgeClosureField) : Bool :=
  match field with
  | .rootExecutionSemanticsClosure =>
      rootExecutionSemanticsClosureAccepted artifact
  | .authenticatedSelectionPayloadSurface =>
      authenticatedSelectionPayloadSurfacePresent artifact
  | .selectedRowPreparedStepBindingSurface =>
      selectedRowPreparedStepBindingSurfacePresent artifact
  | .selectedRowChunkRoutingSurface =>
      selectedRowChunkRoutingSurfacePresent artifact
  | .stage1ObligationPayloadSurface =>
      stage1ObligationPayloadSurfacePresent artifact
  | .stage2ObligationPayloadSurface =>
      stage2ObligationPayloadSurfacePresent artifact
  | .stage3ObligationPayloadSurface =>
      stage3ObligationPayloadSurfacePresent artifact
  | .kernelOpeningProvenanceSurface =>
      kernelOpeningProvenanceSurfacePresent artifact
  | .kernelDesignBridgeConstructible =>
      rootExecutionSemanticsClosureAccepted artifact &&
        authenticatedSelectionPayloadSurfacePresent artifact &&
        selectedRowPreparedStepBindingSurfacePresent artifact &&
        selectedRowChunkRoutingSurfacePresent artifact &&
        stage1ObligationPayloadSurfacePresent artifact &&
        stage2ObligationPayloadSurfacePresent artifact &&
        stage3ObligationPayloadSurfacePresent artifact &&
        kernelOpeningProvenanceSurfacePresent artifact

def kernelDesignBridgeClosureChecks
    (artifact : AcceptedProofArtifactView) : List (String × Bool) :=
  requiredKernelDesignBridgeClosureFields.map fun field =>
    (kernelDesignBridgeClosureFieldName field,
      kernelDesignBridgeClosureFieldPresent artifact field)

def kernelDesignBridgeClosureAccepted (artifact : AcceptedProofArtifactView) : Bool :=
  (kernelDesignBridgeClosureChecks artifact).all Prod.snd

def missingKernelDesignBridgeClosureFields
    (artifact : AcceptedProofArtifactView) : List String :=
  (kernelDesignBridgeClosureChecks artifact).filterMap fun (name, ok) =>
    if ok then none else some name

structure Rv64imKernelDesignBridgeClosureReport where
  name : String
  checks : List (String × Bool)
  missing : List String
  rustExportBlockers : List String
deriving Repr

def kernelDesignBridgeRustExportBlockers
    (artifact : AcceptedProofArtifactView) : List String :=
  let blockers : List (String × Bool) :=
    [ ( "twist_shout_selected_rows_missing_authenticated_selection_payloads"
      , authenticatedSelectionPayloadSurfacePresent artifact
      )
    , ( "twist_shout_selected_rows_missing_selected_row_prepared_step_bindings"
      , selectedRowPreparedStepBindingSurfacePresent artifact
      )
    , ( "selected_rows_missing_root_chunk_routing_bindings"
      , selectedRowChunkRoutingSurfacePresent artifact
      )
    , ( "stage1_missing_theorem_bearing_obligation_payloads"
      , stage1ObligationPayloadSurfacePresent artifact
      )
    , ( "stage2_missing_theorem_bearing_obligation_payloads"
      , stage2ObligationPayloadSurfacePresent artifact
      )
    , ( "stage3_missing_theorem_bearing_obligation_payloads"
      , stage3ObligationPayloadSurfacePresent artifact
      )
    , ( "kernel_openings_missing_provenance_chains"
      , kernelOpeningProvenanceSurfacePresent artifact
      )
    ]
  blockers.filterMap fun (name, ok) =>
    if ok then none else some name

def uniqueKernelDesignBridgeRustExportBlockers : List String :=
  Generated.AcceptedProofArtifacts.cases.foldl
    (fun acc artifact =>
      (kernelDesignBridgeRustExportBlockers artifact).foldl
        (fun acc blocker => if blocker ∈ acc then acc else acc ++ [blocker])
        acc)
    []

def rv64imAcceptedArtifactKernelDesignBridgeClosureChecks : List Bool :=
  Generated.AcceptedProofArtifacts.cases.map kernelDesignBridgeClosureAccepted

def validGeneratedRv64imAcceptedArtifactKernelDesignBridgeClosureCases : Bool :=
  Generated.AcceptedProofArtifacts.cases.all kernelDesignBridgeClosureAccepted

def rv64imAcceptedArtifactKernelDesignBridgeClosureReports :
    List Rv64imKernelDesignBridgeClosureReport :=
  Generated.AcceptedProofArtifacts.cases.map fun artifact =>
    { name := artifact.name
    , checks := kernelDesignBridgeClosureChecks artifact
    , missing := missingKernelDesignBridgeClosureFields artifact
    , rustExportBlockers := kernelDesignBridgeRustExportBlockers artifact
    }

end Nightstream.Rv64IM
