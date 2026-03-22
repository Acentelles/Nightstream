import Nightstream.Chip8.Generated.TranscriptVectors
import Nightstream.Chip8.Generated.StagedExecutionDigestBundleVectors
import Nightstream.Chip8.Generated.ReleaseArtifactVectors
import Nightstream.Chip8.Kernel.ExternalReleaseArtifactAudit

/-!
Executable parity checks for Rust-generated CHIP-8 vectors. This owner checks
the concrete `root0` cursor/digest slice plus the shared Stage 1/2/3 challenge
groups that Lean can now recompute exactly from exported cursor snapshots, and
it checks the staged chunk-bundle export against the Lean-owned raw bundle-view
rebuild from independent exact-frame and Stage-3 sources. It also checks the
combined release-artifact package against the same frame, Stage-3, root0, and
grouped-surface invariants that the Lean release checker expects downstream.
-/

namespace Nightstream.Chip8

open Nightstream.Chip8.Generated
open Nightstream.Chip8.ConcreteTranscriptParity
open Nightstream.Chip8.Poseidon2GoldilocksCore

private def idBytes (xs : List Generated.Byte) : List Generated.Byte := xs

private def cursorSnapshotWords (cursor : Cursor) : CursorSnapshotWords :=
  { stateWords := stateWords cursor.st
  , absorbed := cursor.absorbed }

private def cursorStateOfWords? : List Nat → Option State
  | [x0, x1, x2, x3, x4, x5, x6, x7] =>
      some (mkState x0 x1 x2 x3 x4 x5 x6 x7)
  | _ => none

private def cursorOfSnapshot? (snapshot : CursorSnapshotWords) : Option Cursor := do
  let st <- cursorStateOfWords? snapshot.stateWords
  pure { st := st, absorbed := snapshot.absorbed }

private def root0TranscriptCursorWords (case : TranscriptVectorCase) : CursorSnapshotWords :=
  cursorSnapshotWords
    (root0TranscriptCursor
      idBytes idBytes idBytes
      case.transcriptSeed
      case.commitmentBindings
      case.metaPub)

private def root0DigestCursorWords (case : TranscriptVectorCase) : CursorSnapshotWords :=
  cursorSnapshotWords
    (root0DigestCursor
      idBytes idBytes idBytes
      case.transcriptSeed
      case.commitmentBindings
      case.metaPub)

private def stage1LookupPointWords (case : TranscriptVectorCase) : List ChallengePairWords :=
  pointOfChallenges
    ((sampleStage1LookupPointFromRoot0
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub
        case.metaPub.cycleBits).1)

private def pairWordsAtSnapshot?
    (snapshot : CursorSnapshotWords)
    (sampler : Cursor → ChallengePair × Cursor) : Option ChallengePairWords := do
  let cursor <- cursorOfSnapshot? snapshot
  pure (pairOfChallenge (sampler cursor).1)

private def pointWordsAtSnapshot?
    (snapshot : CursorSnapshotWords)
    (sampler : Cursor → Nat → List ChallengePair × Cursor)
    (n : Nat) : Option (List ChallengePairWords) := do
  let cursor <- cursorOfSnapshot? snapshot
  pure (pointOfChallenges (sampler cursor n).1)

private def matchesOption [DecidableEq α] (actual? : Option α) (expected : α) : Bool :=
  match actual? with
  | some actual => actual == expected
  | none => false

private def stage1GammaLookupLinkWords? (case : TranscriptVectorCase) : Option ChallengePairWords :=
  pairWordsAtSnapshot? case.expectedStage1GammaLookupLinkCursor sampleStage1GammaLookupLink

private def stage2TwistCyclePointWords? (case : TranscriptVectorCase) : Option (List ChallengePairWords) :=
  pointWordsAtSnapshot? case.expectedStage2TwistCycleCursor sampleStage2TwistCyclePoint case.metaPub.cycleBits

private def stage2GammaRegWords? (case : TranscriptVectorCase) : Option ChallengePairWords :=
  pairWordsAtSnapshot? case.expectedStage2GammaRegCursor sampleStage2GammaReg

private def stage2RegAddrPointWords? (case : TranscriptVectorCase) : Option (List ChallengePairWords) :=
  pointWordsAtSnapshot? case.expectedStage2RegAddrCursor sampleStage2RegAddrPoint regAddrBits

private def stage2GammaRamWords? (case : TranscriptVectorCase) : Option ChallengePairWords :=
  pairWordsAtSnapshot? case.expectedStage2GammaRamCursor sampleStage2GammaRam

private def stage2RamAddrPointWords? (case : TranscriptVectorCase) : Option (List ChallengePairWords) :=
  pointWordsAtSnapshot? case.expectedStage2RamAddrCursor sampleStage2RamAddrPoint ramAddrBits

private def stage2GammaTwistLinkWords? (case : TranscriptVectorCase) : Option ChallengePairWords :=
  pairWordsAtSnapshot? case.expectedStage2GammaTwistLinkCursor sampleStage2GammaTwistLink

private def stage3Beta1Words? (case : TranscriptVectorCase) : Option ChallengePairWords :=
  pairWordsAtSnapshot? case.expectedStage3Beta1Cursor sampleStage3Beta1

private def stage3Beta2Words? (case : TranscriptVectorCase) : Option ChallengePairWords :=
  pairWordsAtSnapshot? case.expectedStage3Beta2Cursor sampleStage3Beta2

private def stage3ShiftPointWords? (case : TranscriptVectorCase) : Option (List ChallengePairWords) :=
  pointWordsAtSnapshot? case.expectedStage3ShiftCursor sampleStage3ShiftPoint case.metaPub.cycleBits

private def stage3GammaShiftWords? (case : TranscriptVectorCase) : Option ChallengePairWords :=
  pairWordsAtSnapshot? case.expectedStage3GammaShiftCursor sampleStage3GammaShift

private def checkResults (case : TranscriptVectorCase) : List (String × Bool) :=
  [ ("root0TranscriptCursor", root0TranscriptCursorWords case == case.expectedRoot0TranscriptCursor)
  , ("root0DigestCursor", root0DigestCursorWords case == case.expectedRoot0DigestCursor)
  , ( "root0DigestWords"
    , root0DigestWords
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub ==
      case.expectedRoot0DigestWords)
  , ( "root0DigestBytes"
    , root0DigestBytes
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub ==
      case.expectedRoot0DigestBytes)
  , ("stage1LookupPoint", stage1LookupPointWords case == case.expectedStage1LookupPoint)
  , ("stage1GammaLookupLink", matchesOption (stage1GammaLookupLinkWords? case) case.expectedStage1GammaLookupLink)
  , ("stage2TwistCyclePoint", matchesOption (stage2TwistCyclePointWords? case) case.expectedStage2TwistCyclePoint)
  , ("stage2GammaReg", matchesOption (stage2GammaRegWords? case) case.expectedStage2GammaReg)
  , ("stage2RegAddrPoint", matchesOption (stage2RegAddrPointWords? case) case.expectedStage2RegAddrPoint)
  , ("stage2GammaRam", matchesOption (stage2GammaRamWords? case) case.expectedStage2GammaRam)
  , ("stage2RamAddrPoint", matchesOption (stage2RamAddrPointWords? case) case.expectedStage2RamAddrPoint)
  , ("stage2GammaTwistLink", matchesOption (stage2GammaTwistLinkWords? case) case.expectedStage2GammaTwistLink)
  , ("stage3Beta1", matchesOption (stage3Beta1Words? case) case.expectedStage3Beta1)
  , ("stage3Beta2", matchesOption (stage3Beta2Words? case) case.expectedStage3Beta2)
  , ("stage3ShiftPoint", matchesOption (stage3ShiftPointWords? case) case.expectedStage3ShiftPoint)
  , ("stage3GammaShift", matchesOption (stage3GammaShiftWords? case) case.expectedStage3GammaShift)
  ]

structure TranscriptVectorReport where
  name : String
  checks : List (String × Bool)
deriving Repr

def checkTranscriptVectorCase (case : TranscriptVectorCase) : Bool :=
  (checkResults case).all Prod.snd

def transcriptVectorChecks : List Bool :=
  Generated.transcriptVectorCases.map checkTranscriptVectorCase

def validGeneratedTranscriptVectorCases : Bool :=
  Generated.transcriptVectorCases.all checkTranscriptVectorCase

def transcriptVectorReports : List TranscriptVectorReport :=
  Generated.transcriptVectorCases.map fun case =>
    { name := case.name
    , checks := checkResults case }

private def rowPcNextIdx : Nat := 2
private def rowIsMemOpIdx : Nat := 19
private def rowXIdxIdx : Nat := 20
private def rowBurstLastIdx : Nat := 22

private def rowWord? (row : List Nat) (idx : Nat) : Option Nat :=
  row[idx]?

private def claimedShiftValuesMatch (stage3 : Stage3View) : Bool :=
  match stage3.shiftClaim.claimedShiftValues with
  | [shiftPc, shiftXIdx, shiftIsMemOp] =>
      stage3.shiftProof.shiftPc == shiftPc &&
        stage3.shiftProof.shiftXIdx == shiftXIdx &&
        stage3.shiftProof.shiftIsMemOp == shiftIsMemOp
  | _ => false

private def stage3ViewMatchesFrame (frame : FrameSourceView) (stage3 : Stage3View) : Bool :=
  stage3.stepIdx == frame.stepIdx &&
    stage3.currentRow.rowIndex == frame.stepIdx &&
    stage3.rowClaim.rowIndex == frame.stepIdx &&
    stage3.currentRow.pairMask == ContinuityBridge.PairMaskN stage3.n frame.stepIdx &&
    rowWord? frame.row rowPcNextIdx == some stage3.currentRow.pcNext &&
    rowWord? frame.row rowXIdxIdx == some stage3.currentRow.xIdx &&
    rowWord? frame.row rowIsMemOpIdx == some stage3.currentRow.isMemOp &&
    rowWord? frame.row rowBurstLastIdx == some stage3.currentRow.burstLast &&
    stage3.shiftClaim.sourceCommitment == .lane &&
    stage3.shiftClaim.sourceColumns == [.pc, .xIdx, .isMemOp] &&
    stage3.shiftClaim.shiftedColumns == [.shiftPc, .shiftXIdx, .shiftIsMemOp] &&
    claimedShiftValuesMatch stage3 &&
    stage3.rowClaim.openedValues.length == 23

private def allStage3ViewsMatchFrames :
    List FrameSourceView → List Stage3View → Bool
  | [], [] => true
  | frame :: frames, stage3 :: stage3s =>
      stage3ViewMatchesFrame frame stage3 &&
        allStage3ViewsMatchFrames frames stage3s
  | _, _ => false

private def bundleRebuilt (case : StagedExecutionDigestBundleVectorCase) :
    StagedExecutionDigestBundleView :=
  stagedExecutionDigestBundleViewOfSources case.publicSurface case.frames case.stage3s

private def bundleCheckResults
    (case : StagedExecutionDigestBundleVectorCase) : List (String × Bool) :=
  [ ("publicSurface", case.expectedBundle.publicSurface == case.publicSurface)
  , ("sourceLengthsAgree", case.frames.length == case.stage3s.length)
  , ("bundleLengthMatchesFrames", case.expectedBundle.digests.length == case.frames.length)
  , ("semanticRowsMatchFrames", case.publicSurface.metaPub.semanticRows == case.frames.length)
  , ("stage3SourcesMatchFrames", allStage3ViewsMatchFrames case.frames case.stage3s)
  , ("rebuiltBundle", bundleRebuilt case == case.expectedBundle)
  ]

structure BundleVectorReport where
  name : String
  checks : List (String × Bool)
deriving Repr

def checkBundleVectorCase (case : StagedExecutionDigestBundleVectorCase) : Bool :=
  (bundleCheckResults case).all Prod.snd

def bundleVectorChecks : List Bool :=
  Generated.stagedExecutionDigestBundleVectorCases.map checkBundleVectorCase

def validGeneratedBundleVectorCases : Bool :=
  Generated.stagedExecutionDigestBundleVectorCases.all checkBundleVectorCase

def bundleVectorReports : List BundleVectorReport :=
  Generated.stagedExecutionDigestBundleVectorCases.map fun case =>
    { name := case.name
    , checks := bundleCheckResults case }

private def rebuiltBundleOfSources
    (publicSurface : DigestPublicView)
    (frames : List FrameSourceView)
    (stage3s : List Stage3View) : StagedExecutionDigestBundleView :=
  stagedExecutionDigestBundleViewOfSources publicSurface frames stage3s

private def releaseArtifactCheckResults
    (case : KernelReleaseArtifactVectorCase) : List (String × Bool) :=
  let imported := ExternalReleaseArtifact.ofVectorCase case
  [ ("traceSurface", ExternalReleaseArtifactAudit.checkTraceSurface imported)
  , ("exportSurface", ExternalReleaseArtifactAudit.checkExportSurface imported)
  , ("bundleSurface", ExternalReleaseArtifactAudit.checkBundleSurface imported)
  , ("stage3SourceLengthsAgree", ExternalReleaseArtifactAudit.checkStage3SourceLengths imported)
  , ("stage3SourcesMatchFrames", ExternalReleaseArtifactAudit.checkStage3SourcesMatchFrames imported)
  , ("bundleLengthMatchesFrames", ExternalReleaseArtifactAudit.checkBundleLengthMatchesFrames imported)
  , ("exportMatchesBundleLength", ExternalReleaseArtifactAudit.checkExportMatchesBundleLength imported)
  , ("semanticRowsMatchMetaPub", ExternalReleaseArtifactAudit.checkSemanticRowsMatchBundleLength imported)
  , ("transcriptSurface", ExternalReleaseArtifactAudit.checkTranscriptSurface imported)
  , ("errorSurfaceLists", ExternalReleaseArtifactAudit.checkErrorSurfaceLists imported)
  , ("root0IdsMatchBindings", ExternalReleaseArtifactAudit.checkRoot0IdsMatchBindings imported)
  , ("rootManifestEmpty", ExternalReleaseArtifactAudit.checkRootManifestEmpty imported)
  , ("kernelManifestSources", ExternalReleaseArtifactAudit.checkKernelManifestSources imported)
  , ("kernelManifestCount", ExternalReleaseArtifactAudit.checkKernelManifestCount imported)
  , ("auditLengths", ExternalReleaseArtifactAudit.checkAuditLengths imported)
  , ("auditRowsMatchFrames", ExternalReleaseArtifactAudit.checkAuditRowsMatchFrames imported)
  , ("auditReuseRowBinding", ExternalReleaseArtifactAudit.checkAuditReuseRowBinding imported)
  , ("auditPreparedSteps", ExternalReleaseArtifactAudit.checkAuditPreparedSteps imported)
  ]

structure ReleaseArtifactVectorReport where
  name : String
  checks : List (String × Bool)
deriving Repr

def checkReleaseArtifactVectorCase (case : KernelReleaseArtifactVectorCase) : Bool :=
  ExternalReleaseArtifactAudit.checkImportedReleaseArtifact
    (ExternalReleaseArtifact.ofVectorCase case)

def releaseArtifactVectorChecks : List Bool :=
  Generated.releaseArtifactVectorCases.map checkReleaseArtifactVectorCase

def validGeneratedReleaseArtifactVectorCases : Bool :=
  Generated.releaseArtifactVectorCases.all checkReleaseArtifactVectorCase

def releaseArtifactVectorReports : List ReleaseArtifactVectorReport :=
  Generated.releaseArtifactVectorCases.map fun case =>
    { name := case.name
    , checks := releaseArtifactCheckResults case }

def validGeneratedChip8ProtocolCases : Bool :=
  validGeneratedTranscriptVectorCases &&
    validGeneratedBundleVectorCases &&
    validGeneratedReleaseArtifactVectorCases

end Nightstream.Chip8
