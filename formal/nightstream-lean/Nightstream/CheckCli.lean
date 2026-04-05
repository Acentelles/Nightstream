import Init
import Nightstream.Chip8.Checks
import Nightstream.Rv64IM.Checks
import Nightstream.Rv64IM.AcceptedArtifactChecks
import Nightstream.Rv64IM.AcceptedArtifactCompleteness
import Nightstream.Rv64IM.AcceptedArtifactConstructorAudit
import Nightstream.Rv64IM.AcceptedArtifactKernelDesignBridgeClosure
import Nightstream.Rv64IM.AcceptedArtifactRootExecutionClosure
import Nightstream.Rv64IM.AcceptedArtifactRootExecutionSemanticsClosure
import Nightstream.Rv64IM.AcceptedArtifactBackendRefinement
import Nightstream.Rv64IM.Kernel.RequiredBackendPayloadSurface
import Nightstream.Rv64IM.Kernel.RequiredRootExecutionSemanticsSurface
import Nightstream.Rv64IM.Kernel.RequiredKernelDesignBridgeSurface
import Nightstream.Rv64IM.Kernel.RequiredProofCompleteRustExportSurface
import Nightstream.Rv64IM.ProofCompleteAudit

namespace Nightstream.CheckCli

def main : IO UInt32 := do
  let allChecks :=
    Nightstream.Chip8.validGeneratedChip8ProtocolCases &&
      Nightstream.Rv64IM.validGeneratedRv64imParityCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactNegativeCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactCompletenessCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactTraceConstructorCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactKernelConstructorCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactRootExecutionClosureCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactKernelDesignBridgeClosureCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactRootExecutionSemanticsClosureCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactBackendRefinementCases &&
      Nightstream.Rv64IM.validRv64imProofCompleteClosure
  IO.println s!"chip8_transcript_vector_checks={Nightstream.Chip8.transcriptVectorChecks}"
  IO.println s!"chip8_transcript_vector_reports={reprStr Nightstream.Chip8.transcriptVectorReports}"
  IO.println s!"chip8_bundle_vector_checks={Nightstream.Chip8.bundleVectorChecks}"
  IO.println s!"chip8_bundle_vector_reports={reprStr Nightstream.Chip8.bundleVectorReports}"
  IO.println s!"chip8_release_artifact_vector_checks={Nightstream.Chip8.releaseArtifactVectorChecks}"
  IO.println s!"chip8_release_artifact_vector_reports={reprStr Nightstream.Chip8.releaseArtifactVectorReports}"
  IO.println s!"chip8_imported_opening_transcript_checks={Nightstream.Chip8.importedOpeningTranscriptChecks}"
  IO.println s!"chip8_imported_opening_transcript_reports={reprStr Nightstream.Chip8.importedOpeningTranscriptReports}"
  IO.println s!"chip8_imported_release_artifact_core_check={Nightstream.Chip8.validImportedReleaseArtifactCore}"
  IO.println s!"chip8_imported_release_artifact_core_checks={Nightstream.Chip8.importedReleaseArtifactCoreChecks}"
  IO.println s!"chip8_imported_release_artifact_core_reports={reprStr Nightstream.Chip8.importedReleaseArtifactCoreReports}"
  IO.println s!"chip8_imported_release_artifact_check={Nightstream.Chip8.validImportedReleaseArtifact}"
  IO.println s!"chip8_imported_release_artifact_checks={Nightstream.Chip8.importedReleaseArtifactChecks}"
  IO.println s!"chip8_imported_release_artifact_report={reprStr Nightstream.Chip8.importedReleaseArtifactReport}"
  IO.println s!"rv64im_parity_checks={Nightstream.Rv64IM.rv64imParityChecks}"
  IO.println s!"rv64im_parity_reports={reprStr Nightstream.Rv64IM.rv64imParityReports}"
  IO.println s!"rv64im_accepted_artifact_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactChecks}"
  IO.println s!"rv64im_accepted_artifact_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactReports}"
  IO.println s!"rv64im_accepted_artifact_negative_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactNegativeChecks}"
  IO.println s!"rv64im_accepted_artifact_negative_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactNegativeReports}"
  IO.println s!"rv64im_accepted_artifact_completeness_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactCompletenessChecks}"
  IO.println s!"rv64im_accepted_artifact_completeness_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactCompletenessReports}"
  IO.println s!"rv64im_accepted_artifact_trace_constructor_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactTraceConstructorChecks}"
  IO.println s!"rv64im_accepted_artifact_kernel_constructor_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactKernelConstructorChecks}"
  IO.println s!"rv64im_accepted_artifact_constructor_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactConstructorReports}"
  IO.println s!"rv64im_accepted_artifact_root_execution_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactRootExecutionClosureChecks}"
  IO.println s!"rv64im_accepted_artifact_root_execution_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactRootExecutionClosureReports}"
  IO.println s!"rv64im_accepted_artifact_root_execution_closure={Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactRootExecutionClosureCases}"
  IO.println s!"rv64im_accepted_artifact_kernel_design_bridge_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactKernelDesignBridgeClosureChecks}"
  IO.println s!"rv64im_accepted_artifact_kernel_design_bridge_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactKernelDesignBridgeClosureReports}"
  IO.println s!"rv64im_accepted_artifact_kernel_design_bridge_closure={Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactKernelDesignBridgeClosureCases}"
  IO.println s!"rv64im_accepted_artifact_kernel_design_bridge_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueKernelDesignBridgeRustExportBlockers}"
  IO.println s!"rv64im_required_kernel_design_bridge_checks={Nightstream.Rv64IM.rv64imRequiredKernelDesignBridgeChecks}"
  IO.println s!"rv64im_required_kernel_design_bridge_reports={reprStr Nightstream.Rv64IM.rv64imRequiredKernelDesignBridgeReports}"
  IO.println s!"rv64im_required_kernel_design_bridge_closure={Nightstream.Rv64IM.validGeneratedRv64imRequiredKernelDesignBridgeCases}"
  IO.println s!"rv64im_required_kernel_design_bridge_missing_fields={reprStr Nightstream.Rv64IM.uniqueMissingRequiredKernelDesignBridgeFields}"
  IO.println s!"rv64im_required_kernel_design_bridge_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRequiredKernelDesignBridgeRustExportBlockers}"
  IO.println s!"rv64im_accepted_artifact_root_execution_semantics_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactRootExecutionSemanticsClosureChecks}"
  IO.println s!"rv64im_accepted_artifact_root_execution_semantics_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactRootExecutionSemanticsClosureReports}"
  IO.println s!"rv64im_accepted_artifact_root_execution_semantics_closure={Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactRootExecutionSemanticsClosureCases}"
  IO.println s!"rv64im_accepted_artifact_root_execution_semantics_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRootExecutionSemanticsRustExportBlockers}"
  IO.println s!"rv64im_required_root_execution_semantics_checks={Nightstream.Rv64IM.rv64imRequiredRootExecutionSemanticsChecks}"
  IO.println s!"rv64im_required_root_execution_semantics_reports={reprStr Nightstream.Rv64IM.rv64imRequiredRootExecutionSemanticsReports}"
  IO.println s!"rv64im_required_root_execution_semantics_closure={Nightstream.Rv64IM.validGeneratedRv64imRequiredRootExecutionSemanticsCases}"
  IO.println s!"rv64im_required_root_execution_semantics_missing_fields={reprStr Nightstream.Rv64IM.uniqueMissingRequiredRootExecutionSemanticsFields}"
  IO.println s!"rv64im_required_root_execution_semantics_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRequiredRootExecutionSemanticsRustExportBlockers}"
  IO.println s!"rv64im_required_backend_payload_checks={Nightstream.Rv64IM.rv64imRequiredBackendPayloadChecks}"
  IO.println s!"rv64im_required_backend_payload_reports={reprStr Nightstream.Rv64IM.rv64imRequiredBackendPayloadReports}"
  IO.println s!"rv64im_required_backend_payload_closure={Nightstream.Rv64IM.validGeneratedRv64imRequiredBackendPayloadCases}"
  IO.println s!"rv64im_required_backend_payload_missing_fields={reprStr Nightstream.Rv64IM.uniqueMissingRequiredBackendPayloadFields}"
  IO.println s!"rv64im_required_backend_payload_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRequiredBackendPayloadRustExportBlockers}"
  IO.println s!"rv64im_required_proof_complete_rust_export_checks={Nightstream.Rv64IM.rv64imRequiredProofCompleteRustExportChecks}"
  IO.println s!"rv64im_required_proof_complete_rust_export_reports={reprStr Nightstream.Rv64IM.rv64imRequiredProofCompleteRustExportReports}"
  IO.println s!"rv64im_required_proof_complete_backend_surface_ok={Nightstream.Rv64IM.validGeneratedRv64imRequiredProofCompleteBackendSurfaceCases}"
  IO.println s!"rv64im_required_proof_complete_root_execution_semantics_surface_ok={Nightstream.Rv64IM.validGeneratedRv64imRequiredProofCompleteRootExecutionSemanticsSurfaceCases}"
  IO.println s!"rv64im_required_proof_complete_kernel_design_bridge_surface_ok={Nightstream.Rv64IM.validGeneratedRv64imRequiredProofCompleteKernelDesignBridgeSurfaceCases}"
  IO.println s!"rv64im_required_proof_complete_rust_export_closure={Nightstream.Rv64IM.validGeneratedRv64imRequiredProofCompleteRustExportCases}"
  IO.println s!"rv64im_required_proof_complete_backend_missing_fields={reprStr Nightstream.Rv64IM.uniqueRequiredProofCompleteBackendMissingFields}"
  IO.println s!"rv64im_required_proof_complete_root_execution_semantics_missing_fields={reprStr Nightstream.Rv64IM.uniqueRequiredProofCompleteRootExecutionSemanticsMissingFields}"
  IO.println s!"rv64im_required_proof_complete_kernel_design_bridge_missing_fields={reprStr Nightstream.Rv64IM.uniqueRequiredProofCompleteKernelDesignBridgeMissingFields}"
  IO.println s!"rv64im_required_proof_complete_rust_export_missing_fields={reprStr Nightstream.Rv64IM.uniqueMissingRequiredProofCompleteRustExportFields}"
  IO.println s!"rv64im_required_proof_complete_backend_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRequiredProofCompleteBackendRustExportBlockers}"
  IO.println s!"rv64im_required_proof_complete_root_execution_semantics_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRequiredProofCompleteRootExecutionSemanticsRustExportBlockers}"
  IO.println s!"rv64im_required_proof_complete_kernel_design_bridge_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRequiredProofCompleteKernelDesignBridgeRustExportBlockers}"
  IO.println s!"rv64im_required_proof_complete_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueRequiredProofCompleteRustExportBlockers}"
  IO.println s!"rv64im_accepted_artifact_backend_refinement_checks={Nightstream.Rv64IM.rv64imAcceptedArtifactBackendRefinementChecks}"
  IO.println s!"rv64im_accepted_artifact_backend_refinement_reports={reprStr Nightstream.Rv64IM.rv64imAcceptedArtifactBackendRefinementReports}"
  IO.println s!"rv64im_accepted_artifact_backend_refinement_closure={Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactBackendRefinementCases}"
  IO.println s!"rv64im_accepted_artifact_backend_refinement_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueBackendRefinementRustExportBlockers}"
  IO.println s!"rv64im_proof_complete_static_checks={reprStr Nightstream.Rv64IM.proofCompleteStaticChecks}"
  IO.println s!"rv64im_proof_complete_static_failures={reprStr Nightstream.Rv64IM.proofCompleteStaticFailures}"
  IO.println s!"rv64im_proof_complete_static_failure_reports={reprStr Nightstream.Rv64IM.proofCompleteStaticFailureReports}"
  IO.println s!"rv64im_proof_complete_static_failure_missing_required_fields={reprStr Nightstream.Rv64IM.uniqueProofCompleteStaticFailureMissingRequiredFields}"
  IO.println s!"rv64im_proof_complete_static_failure_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueProofCompleteStaticFailureRustExportBlockers}"
  IO.println s!"rv64im_proof_complete_static_ok={Nightstream.Rv64IM.validRv64imProofCompleteStaticChecks}"
  IO.println s!"rv64im_proof_complete_case_checks={Nightstream.Rv64IM.rv64imProofCompleteChecks}"
  IO.println s!"rv64im_proof_complete_reports={reprStr Nightstream.Rv64IM.rv64imProofCompleteReports}"
  IO.println s!"rv64im_proof_complete_cases_ok={Nightstream.Rv64IM.validGeneratedRv64imProofCompleteCases}"
  IO.println s!"rv64im_proof_complete_required_backend_payload_surface_ok={Nightstream.Rv64IM.validProofCompleteRequiredBackendPayloadSurface}"
  IO.println s!"rv64im_proof_complete_required_root_execution_semantics_surface_ok={Nightstream.Rv64IM.validProofCompleteRequiredRootExecutionSemanticsSurface}"
  IO.println s!"rv64im_proof_complete_required_kernel_design_bridge_surface_ok={Nightstream.Rv64IM.validProofCompleteRequiredKernelDesignBridgeSurface}"
  IO.println s!"rv64im_proof_complete_required_rust_export_surface_ok={Nightstream.Rv64IM.validProofCompleteRequiredRustExportSurface}"
  IO.println s!"rv64im_proof_complete_required_backend_payload_fields={reprStr Nightstream.Rv64IM.uniqueProofCompleteRequiredBackendPayloadFields}"
  IO.println s!"rv64im_proof_complete_required_root_execution_semantics_fields={reprStr Nightstream.Rv64IM.uniqueProofCompleteRequiredRootExecutionSemanticsFields}"
  IO.println s!"rv64im_proof_complete_required_kernel_design_bridge_fields={reprStr Nightstream.Rv64IM.uniqueProofCompleteRequiredKernelDesignBridgeFields}"
  IO.println s!"rv64im_proof_complete_required_rust_export_fields={reprStr Nightstream.Rv64IM.uniqueProofCompleteRequiredRustExportFields}"
  IO.println s!"rv64im_proof_complete_backend_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueProofCompleteBackendRustExportBlockers}"
  IO.println s!"rv64im_proof_complete_root_execution_semantics_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueProofCompleteRootExecutionSemanticsRustExportBlockers}"
  IO.println s!"rv64im_proof_complete_kernel_design_bridge_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueProofCompleteKernelDesignBridgeRustExportBlockers}"
  IO.println s!"rv64im_proof_complete_rust_export_blockers={reprStr Nightstream.Rv64IM.uniqueProofCompleteRustExportBlockers}"
  IO.println s!"rv64im_proof_complete_closure_blockers={reprStr Nightstream.Rv64IM.uniqueProofCompleteClosureBlockers}"
  IO.println s!"rv64im_proof_complete_closure={Nightstream.Rv64IM.validRv64imProofCompleteClosure}"
  IO.println s!"all_checks={allChecks}"
  if allChecks then
    pure 0
  else
    pure 1

end Nightstream.CheckCli
