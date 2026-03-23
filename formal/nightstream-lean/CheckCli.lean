import Init
import Nightstream.Chip8.Checks

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
  if Nightstream.Chip8.validGeneratedChip8ProtocolCases then
    pure 0
  else
    pure 1
