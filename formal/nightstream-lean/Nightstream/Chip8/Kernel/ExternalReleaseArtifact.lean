import Nightstream.Chip8.Generated.ReleaseArtifactVectorTypes

/-!
Owns the proof-free external CHIP-8 release-artifact schema imported from Rust.
This file fixes the exact imported fields and the source-derived expectations
that later external-artifact audit checks must validate; it does not own the
theorem-facing kernel package itself.
-/

namespace Nightstream.Chip8.ExternalReleaseArtifact

open Nightstream.Chip8.Generated

structure ImportedArtifact where
  root0Bindings : List CommitmentBinding
  traceDigests : TraceDigestSourceView
  frames : List FrameSourceView
  stage3s : List Stage3View
  artifact : KernelReleaseArtifactView
deriving DecidableEq, Repr

def ofVectorCase (case : KernelReleaseArtifactVectorCase) : ImportedArtifact :=
  { root0Bindings := case.root0Bindings
  , traceDigests := case.traceDigests
  , frames := case.frames
  , stage3s := case.stage3s
  , artifact := case.expectedArtifact }

def semanticRows (artifact : ImportedArtifact) : Nat :=
  artifact.artifact.stagedBundle.publicSurface.metaPub.semanticRows

def rowProjections (artifact : ImportedArtifact) : List KernelRowProjectionView :=
  artifact.artifact.kernelDigest.auditSurface.rowProjectionSummary.projections

def bridgeClaims (artifact : ImportedArtifact) : List KernelBridgeBindingClaimView :=
  artifact.artifact.kernelDigest.auditSurface.bridgeBindingSummary.claims

def expectedTraceSurface (artifact : ImportedArtifact) : KernelTraceSurfaceView :=
  kernelTraceSurfaceViewOfSources artifact.traceDigests artifact.frames

def expectedExportSurface (artifact : ImportedArtifact) : KernelExportSurfaceView :=
  kernelExportSurfaceViewOfSources artifact.frames artifact.stage3s

def expectedBundle (artifact : ImportedArtifact) : StagedExecutionDigestBundleView :=
  stagedExecutionDigestBundleViewOfSources
    artifact.artifact.stagedBundle.publicSurface artifact.frames artifact.stage3s

def expectedTranscriptSurface (artifact : ImportedArtifact) : KernelTranscriptSurfaceView :=
  kernelTranscriptSurfaceViewOfSources artifact.root0Bindings (semanticRows artifact)

private def rowPcNextIdx : Nat := 2
private def rowIsMemOpIdx : Nat := 19
private def rowXIdxIdx : Nat := 20
private def rowBurstLastIdx : Nat := 22

def rowWord? (row : List Nat) (idx : Nat) : Option Nat :=
  row[idx]?

def claimedShiftValuesMatch (stage3 : Stage3View) : Bool :=
  match stage3.shiftClaim.claimedShiftValues with
  | [shiftPc, shiftXIdx, shiftIsMemOp] =>
      stage3.shiftProof.shiftPc == shiftPc &&
        stage3.shiftProof.shiftXIdx == shiftXIdx &&
        stage3.shiftProof.shiftIsMemOp == shiftIsMemOp
  | _ => false

def stage3ViewMatchesFrame (frame : FrameSourceView) (stage3 : Stage3View) : Bool :=
  stage3.stepIdx == frame.stepIdx &&
    stage3.currentRow.rowIndex == frame.stepIdx &&
    stage3.rowClaim.rowIndex == frame.stepIdx &&
    stage3.currentRow.pairMask == Nightstream.Chip8.ContinuityBridge.PairMaskN stage3.n frame.stepIdx &&
    rowWord? frame.row rowPcNextIdx == some stage3.currentRow.pcNext &&
    rowWord? frame.row rowXIdxIdx == some stage3.currentRow.xIdx &&
    rowWord? frame.row rowIsMemOpIdx == some stage3.currentRow.isMemOp &&
    rowWord? frame.row rowBurstLastIdx == some stage3.currentRow.burstLast &&
    stage3.shiftClaim.sourceCommitment == .lane &&
    stage3.shiftClaim.sourceColumns == [.pc, .xIdx, .isMemOp] &&
    stage3.shiftClaim.shiftedColumns == [.shiftPc, .shiftXIdx, .shiftIsMemOp] &&
    claimedShiftValuesMatch stage3 &&
    stage3.rowClaim.openedValues.length == 23

def allStage3ViewsMatchFrames :
    List FrameSourceView → List Stage3View → Bool
  | [], [] => true
  | frame :: frames, stage3 :: stage3s =>
      stage3ViewMatchesFrame frame stage3 &&
        allStage3ViewsMatchFrames frames stage3s
  | _, _ => false

def allKernelManifestClaimsAreKernel
    (claims : List KernelOpeningClaimView) : Bool :=
  claims.all fun claim =>
    claim.source == .kernel &&
      match claim.commitmentId with
      | .rootProver _ => false
      | _ => true

def manifestExpectedClaimCount (semanticRows : Nat) : Nat :=
  semanticRows + 17

def auditPathsReuseRowBinding
    (projections : List KernelRowProjectionView)
    (claims : List KernelBridgeBindingClaimView) : Bool :=
  match projections, claims with
  | [], [] => true
  | projection :: projections, claim :: claims =>
      projection.rowIndex == claim.rowIndex &&
        projection.rowBindingClaimDigest == claim.rowBindingClaimDigest &&
        projection.rowBindingRefinementDigest == claim.rowBindingRefinementDigest &&
        auditPathsReuseRowBinding projections claims
  | _, _ => false

def auditPreparedStepsMatchStage3
    (claims : List KernelBridgeBindingClaimView)
    (stage3s : List Stage3View) : Bool :=
  match claims, stage3s with
  | [], [] => true
  | claim :: claims, stage3 :: stage3s =>
      claim.rowIndex == stage3.stepIdx &&
        claim.preparedStepDigest == stage3.preparedStepDigest &&
        auditPreparedStepsMatchStage3 claims stage3s
  | _, _ => false

def auditRowsMatchFrames
    (projections : List KernelRowProjectionView)
    (claims : List KernelBridgeBindingClaimView)
    (frames : List FrameSourceView) : Bool :=
  match projections, claims, frames with
  | [], [], [] => true
  | projection :: projections, claim :: claims, frame :: frames =>
      projection.rowIndex == frame.stepIdx &&
        claim.rowIndex == frame.stepIdx &&
        auditRowsMatchFrames projections claims frames
  | _, _, _ => false

def TraceSurfaceBound (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.kernelDigest.traceSurface == expectedTraceSurface artifact

def ExportSurfaceBound (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.kernelDigest.exportSurface == expectedExportSurface artifact

def BundleSurfaceBound (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.stagedBundle == expectedBundle artifact

def Stage3SourceLengthsAgree (artifact : ImportedArtifact) : Bool :=
  artifact.frames.length == artifact.stage3s.length

def Stage3SourcesMatchFrames (artifact : ImportedArtifact) : Bool :=
  allStage3ViewsMatchFrames artifact.frames artifact.stage3s

def BundleLengthMatchesFrames (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.stagedBundle.digests.length == artifact.frames.length

def ExportMatchesBundleLength (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.kernelDigest.exportSurface.semanticRows ==
    artifact.artifact.stagedBundle.digests.length

def SemanticRowsMatchBundleLength (artifact : ImportedArtifact) : Bool :=
  semanticRows artifact == artifact.artifact.stagedBundle.digests.length

def TranscriptSurfaceBound (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.kernelDigest.transcriptSurface == expectedTranscriptSurface artifact

def ErrorSurfaceListsConform (artifact : ImportedArtifact) : Bool :=
  kernelErrorSurfaceListsConform artifact.artifact.kernelDigest.errorSurface

def Root0IdsMatchBindings (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.kernelDigest.manifestSurface.root0CommitmentIds ==
    artifact.root0Bindings.map fun binding => binding.id

def RootManifestEmpty (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.kernelDigest.manifestSurface.rootManifest.claims.isEmpty

def KernelManifestSources (artifact : ImportedArtifact) : Bool :=
  allKernelManifestClaimsAreKernel artifact.artifact.kernelDigest.manifestSurface.kernelManifest.claims

def KernelManifestCount (artifact : ImportedArtifact) : Bool :=
  artifact.artifact.kernelDigest.manifestSurface.kernelManifest.claims.length ==
    manifestExpectedClaimCount (semanticRows artifact)

def AuditLengthsConform (artifact : ImportedArtifact) : Bool :=
  (rowProjections artifact).length == artifact.frames.length &&
    (bridgeClaims artifact).length == artifact.frames.length

def AuditRowsMatchFrames (artifact : ImportedArtifact) : Bool :=
  auditRowsMatchFrames (rowProjections artifact) (bridgeClaims artifact) artifact.frames

def AuditReuseRowBinding (artifact : ImportedArtifact) : Bool :=
  auditPathsReuseRowBinding (rowProjections artifact) (bridgeClaims artifact)

def AuditPreparedStepsMatchStage3 (artifact : ImportedArtifact) : Bool :=
  auditPreparedStepsMatchStage3 (bridgeClaims artifact) artifact.stage3s

def ImportedReleaseArtifactBound (artifact : ImportedArtifact) : Prop :=
  ((((((((((((((((TraceSurfaceBound artifact = true ∧
      ExportSurfaceBound artifact = true) ∧
      BundleSurfaceBound artifact = true) ∧
      Stage3SourceLengthsAgree artifact = true) ∧
      Stage3SourcesMatchFrames artifact = true) ∧
      BundleLengthMatchesFrames artifact = true) ∧
      ExportMatchesBundleLength artifact = true) ∧
      SemanticRowsMatchBundleLength artifact = true) ∧
      TranscriptSurfaceBound artifact = true) ∧
      ErrorSurfaceListsConform artifact = true) ∧
      Root0IdsMatchBindings artifact = true) ∧
      RootManifestEmpty artifact = true) ∧
      KernelManifestSources artifact = true) ∧
      KernelManifestCount artifact = true) ∧
      AuditLengthsConform artifact = true) ∧
      AuditRowsMatchFrames artifact = true) ∧
      AuditReuseRowBinding artifact = true) ∧
      AuditPreparedStepsMatchStage3 artifact = true

end Nightstream.Chip8.ExternalReleaseArtifact
