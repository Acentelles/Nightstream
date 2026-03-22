import Nightstream.Chip8.Kernel.ExternalReleaseArtifact

/-!
Owns the executable Lean checker over the proof-free external CHIP-8 release
artifact imported from Rust. This file validates the imported schema against
the source-derived expectations fixed by `ExternalReleaseArtifact`; it does not
own raw file serialization.
-/

namespace Nightstream.Chip8.ExternalReleaseArtifactAudit

open Nightstream.Chip8.ExternalReleaseArtifact

def checkTraceSurface (artifact : ImportedArtifact) : Bool :=
  TraceSurfaceBound artifact

def checkExportSurface (artifact : ImportedArtifact) : Bool :=
  ExportSurfaceBound artifact

def checkBundleSurface (artifact : ImportedArtifact) : Bool :=
  BundleSurfaceBound artifact

def checkStage3SourceLengths (artifact : ImportedArtifact) : Bool :=
  Stage3SourceLengthsAgree artifact

def checkStage3SourcesMatchFrames (artifact : ImportedArtifact) : Bool :=
  Stage3SourcesMatchFrames artifact

def checkBundleLengthMatchesFrames (artifact : ImportedArtifact) : Bool :=
  BundleLengthMatchesFrames artifact

def checkExportMatchesBundleLength (artifact : ImportedArtifact) : Bool :=
  ExportMatchesBundleLength artifact

def checkSemanticRowsMatchBundleLength (artifact : ImportedArtifact) : Bool :=
  SemanticRowsMatchBundleLength artifact

def checkTranscriptSurface (artifact : ImportedArtifact) : Bool :=
  TranscriptSurfaceBound artifact

def checkErrorSurfaceLists (artifact : ImportedArtifact) : Bool :=
  ErrorSurfaceListsConform artifact

def checkRoot0IdsMatchBindings (artifact : ImportedArtifact) : Bool :=
  Root0IdsMatchBindings artifact

def checkRootManifestEmpty (artifact : ImportedArtifact) : Bool :=
  RootManifestEmpty artifact

def checkKernelManifestSources (artifact : ImportedArtifact) : Bool :=
  KernelManifestSources artifact

def checkKernelManifestCount (artifact : ImportedArtifact) : Bool :=
  KernelManifestCount artifact

def checkAuditLengths (artifact : ImportedArtifact) : Bool :=
  AuditLengthsConform artifact

def checkAuditRowsMatchFrames (artifact : ImportedArtifact) : Bool :=
  AuditRowsMatchFrames artifact

def checkAuditReuseRowBinding (artifact : ImportedArtifact) : Bool :=
  AuditReuseRowBinding artifact

def checkAuditPreparedSteps (artifact : ImportedArtifact) : Bool :=
  AuditPreparedStepsMatchStage3 artifact

def checkImportedReleaseArtifact (artifact : ImportedArtifact) : Bool :=
  checkTraceSurface artifact &&
    checkExportSurface artifact &&
    checkBundleSurface artifact &&
    checkStage3SourceLengths artifact &&
    checkStage3SourcesMatchFrames artifact &&
    checkBundleLengthMatchesFrames artifact &&
    checkExportMatchesBundleLength artifact &&
    checkSemanticRowsMatchBundleLength artifact &&
    checkTranscriptSurface artifact &&
    checkErrorSurfaceLists artifact &&
    checkRoot0IdsMatchBindings artifact &&
    checkRootManifestEmpty artifact &&
    checkKernelManifestSources artifact &&
    checkKernelManifestCount artifact &&
    checkAuditLengths artifact &&
    checkAuditRowsMatchFrames artifact &&
    checkAuditReuseRowBinding artifact &&
    checkAuditPreparedSteps artifact

def ImportedReleaseArtifactAccepted (artifact : ImportedArtifact) : Prop :=
  checkImportedReleaseArtifact artifact = true

theorem importedReleaseArtifactAccepted_iff_bound
    {artifact : ImportedArtifact} :
    ImportedReleaseArtifactAccepted artifact ↔ ImportedReleaseArtifactBound artifact := by
  simpa [and_assoc] using
    (show
      ImportedReleaseArtifactAccepted artifact ↔ ImportedReleaseArtifactBound artifact from by
        simp [ImportedReleaseArtifactAccepted, checkImportedReleaseArtifact, ImportedReleaseArtifactBound,
          checkTraceSurface, checkExportSurface, checkBundleSurface, checkStage3SourceLengths,
          checkStage3SourcesMatchFrames, checkBundleLengthMatchesFrames, checkExportMatchesBundleLength,
          checkSemanticRowsMatchBundleLength, checkTranscriptSurface, checkErrorSurfaceLists,
          checkRoot0IdsMatchBindings, checkRootManifestEmpty, checkKernelManifestSources,
          checkKernelManifestCount, checkAuditLengths, checkAuditRowsMatchFrames,
          checkAuditReuseRowBinding, checkAuditPreparedSteps])

theorem importedReleaseArtifactAccepted_of_bound
    {artifact : ImportedArtifact}
    (h : ImportedReleaseArtifactBound artifact) :
    ImportedReleaseArtifactAccepted artifact :=
  importedReleaseArtifactAccepted_iff_bound.mpr h

theorem importedReleaseArtifactAuditSound
    {artifact : ImportedArtifact}
    (h : ImportedReleaseArtifactAccepted artifact) :
    ImportedReleaseArtifactBound artifact :=
  importedReleaseArtifactAccepted_iff_bound.mp h

private theorem acceptedChecksFlat
    {artifact : ImportedArtifact}
    (h : ImportedReleaseArtifactAccepted artifact) :
    TraceSurfaceBound artifact = true ∧
      ExportSurfaceBound artifact = true ∧
        BundleSurfaceBound artifact = true ∧
          Stage3SourceLengthsAgree artifact = true ∧
            Stage3SourcesMatchFrames artifact = true ∧
              BundleLengthMatchesFrames artifact = true ∧
                ExportMatchesBundleLength artifact = true ∧
                  SemanticRowsMatchBundleLength artifact = true ∧
                    TranscriptSurfaceBound artifact = true ∧
                      ErrorSurfaceListsConform artifact = true ∧
                        Root0IdsMatchBindings artifact = true ∧
                          RootManifestEmpty artifact = true ∧
                            KernelManifestSources artifact = true ∧
                              KernelManifestCount artifact = true ∧
                                AuditLengthsConform artifact = true ∧
                                  AuditRowsMatchFrames artifact = true ∧
                                    AuditReuseRowBinding artifact = true ∧
                                      AuditPreparedStepsMatchStage3 artifact = true := by
  simpa [ImportedReleaseArtifactBound, and_assoc] using importedReleaseArtifactAuditSound h

theorem importedReleaseArtifactAuditImpliesBundleLength_eq_semanticRows
    {artifact : ImportedArtifact}
    (h : ImportedReleaseArtifactAccepted artifact) :
    artifact.artifact.stagedBundle.digests.length = semanticRows artifact := by
  have hSemanticRows := (acceptedChecksFlat h).2.2.2.2.2.2.2.1
  exact (Nat.eq_of_beq_eq_true (by simpa [SemanticRowsMatchBundleLength] using hSemanticRows)).symm

theorem importedReleaseArtifactAuditImpliesPreparedStepCount_eq_bundleLength
    {artifact : ImportedArtifact}
    (h : ImportedReleaseArtifactAccepted artifact) :
    artifact.artifact.kernelDigest.exportSurface.semanticRows =
      artifact.artifact.stagedBundle.digests.length := by
  have hExportLen := (acceptedChecksFlat h).2.2.2.2.2.2.1
  exact Nat.eq_of_beq_eq_true (by simpa [ExportMatchesBundleLength] using hExportLen)

theorem importedReleaseArtifactAuditImpliesAuditReuseRowBinding
    {artifact : ImportedArtifact}
    (h : ImportedReleaseArtifactAccepted artifact) :
    AuditReuseRowBinding artifact = true := by
  exact (acceptedChecksFlat h).2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1

end Nightstream.Chip8.ExternalReleaseArtifactAudit
