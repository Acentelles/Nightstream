import Init
import Nightstream.Chip8.Checks
import Nightstream.Rv64IM.Checks
import Nightstream.Rv64IM.AcceptedArtifactChecks
import Nightstream.Rv64IM.AcceptedArtifactCompleteness
import Nightstream.Rv64IM.AcceptedArtifactConstructorAudit

def main : IO UInt32 := do
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
  if Nightstream.Chip8.validGeneratedChip8ProtocolCases &&
      Nightstream.Rv64IM.validGeneratedRv64imParityCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactNegativeCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactCompletenessCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactTraceConstructorCases &&
      Nightstream.Rv64IM.validGeneratedRv64imAcceptedArtifactKernelConstructorCases then
    pure 0
  else
    pure 1
