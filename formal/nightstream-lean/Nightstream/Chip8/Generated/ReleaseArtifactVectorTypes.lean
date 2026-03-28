import Nightstream.Chip8.Generated.StagedExecutionDigestBundleVectorTypes
import Nightstream.Chip8.Kernel.SoundnessAccounting

/-!
Owns the generated-case surface for CHIP-8 release-artifact parity. These
views package the grouped kernel digest together with the staged bundle under
one proof-free external shape so Lean can check the live Rust export against
its existing theorem-facing owners and source-derived rebuilds.
-/

namespace Nightstream.Chip8.Generated

open Nightstream.Chip8.ExactOpeningBoundary
open Nightstream.Chip8.SoundnessAccounting

structure TraceDigestSourceView where
  stage1Digest : List Byte
  stage2Digest : List Byte
  stage3Digest : List Byte
  semanticEvidenceSummaryDigest : List Byte
deriving DecidableEq, Repr

structure KernelTraceSurfaceView where
  frames : List FrameSourceView
  stage1Digest : List Byte
  stage2Digest : List Byte
  stage3Digest : List Byte
  semanticEvidenceSummaryDigest : List Byte
deriving DecidableEq, Repr

structure KernelExportSurfaceView where
  semanticRows : Nat
  preparedStepDigests : List (List Byte)
deriving DecidableEq, Repr

structure KernelRowProjectionView where
  rowIndex : Nat
  rowBindingClaimDigest : List Byte
  rowBindingRefinementDigest : List Byte
  semanticRowDigest : List Byte
  semanticViewDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure KernelRowProjectionSummaryView where
  projections : List KernelRowProjectionView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelBridgeBindingClaimView where
  rowIndex : Nat
  rowBindingClaimDigest : List Byte
  rowBindingRefinementDigest : List Byte
  preparedStepDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure KernelBridgeBindingSummaryView where
  claims : List KernelBridgeBindingClaimView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelAuditSurfaceView where
  rowProjectionSummary : KernelRowProjectionSummaryView
  bridgeBindingSummary : KernelBridgeBindingSummaryView
deriving DecidableEq, Repr

inductive KernelOpeningSourceView where
  | kernel
  | root
deriving DecidableEq, Repr

structure KernelOpeningClaimView where
  source : KernelOpeningSourceView
  commitmentId : CommitmentId
  point : List ChallengePairWords
  polynomialIds : List Nat
  claimedValues : List ChallengePairWords
  digest : List Byte
deriving DecidableEq, Repr

structure KernelOpeningManifestView where
  claims : List KernelOpeningClaimView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelManifestSurfaceView where
  root0CommitmentIds : List CommitmentId
  kernelManifest : KernelOpeningManifestView
  rootManifest : KernelOpeningManifestView
deriving DecidableEq, Repr

inductive KernelTranscriptEventView where
  | absorbCommitment (id : CommitmentId)
  | absorbMetaPub
  | sampleStage1Cycle
  | stage1FetchSumcheck
  | stage1DecodeSumcheck
  | stage1AluSumcheck
  | stage1Eq4Sumcheck
  | stage1AddrCheckFetch
  | stage1AddrCheckDecode
  | stage1AddrCheckAlu
  | stage1AddrCheckEq4
  | recordFetchAddr
  | recordDecodeAddr
  | recordAluAddr
  | deriveAdd8LoAddr
  | recordEq4Addr
  | sampleGammaLookupLink
  | stage1LinkageBatch
  | sampleStage2Cycle
  | sampleGammaReg
  | stage2RegRwBatched
  | stage2RegValFromInc
  | sampleGammaRam
  | stage2RamRwBatched
  | stage2RamValFromInc
  | stage2RamRafRead
  | stage2RamRafWrite
  | stage2AddrCheckRegRaX
  | stage2AddrCheckRegRaY
  | stage2AddrCheckRegRaI
  | stage2AddrCheckRegWa
  | stage2AddrCheckRamRa
  | stage2AddrCheckRamWa
  | recordRegAddr
  | recordRamAddr
  | sampleGammaTwistLink
  | stage2LinkageBatch
  | sampleBeta1
  | sampleBeta2
  | sampleStage3Cycle
  | laneShiftReduction
  | stage3Continuity
  | stage3StartBoundaryOpening
  | stage3FinalBoundaryOpening
  | rowBinding (j : Nat)
  | emitKernelOpeningClaims
deriving DecidableEq, Repr

structure KernelTranscriptSurfaceView where
  events : List KernelTranscriptEventView
deriving DecidableEq, Repr

inductive ErrorTermView where
  | shoutCore (c : Stage1ShoutChannel)
  | addr (f : AddressFamily)
  | twistRead (f : TwistReadFamily)
  | twistWrite (f : TwistMemoryFamily)
  | twistVal (f : TwistMemoryFamily)
  | ramRafRead
  | ramRafWrite
  | shiftReduce
  | continuity
  | regRwBatch
  | ramRwBatch
  | lookupLink
  | twistLink
  | pcs
  | fs
  | outer
deriving DecidableEq, Repr

structure KernelErrorSurfaceView where
  stage1Channels : List Stage1ShoutChannel
  stage1AddressFamilies : List AddressFamily
  regReadFamilies : List TwistReadFamily
  regAddressFamilies : List AddressFamily
  ramAddressFamilies : List AddressFamily
  twistMemoryFamilies : List TwistMemoryFamily
  stage1Terms : List ErrorTermView
  stage2Terms : List ErrorTermView
  stage3Terms : List ErrorTermView
  batchTerms : List ErrorTermView
  tailTerms : List ErrorTermView
  totalUpperDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure KernelExecutionDigestView where
  traceSurface : KernelTraceSurfaceView
  exportSurface : KernelExportSurfaceView
  auditSurface : KernelAuditSurfaceView
  manifestSurface : KernelManifestSurfaceView
  transcriptSurface : KernelTranscriptSurfaceView
  errorSurface : KernelErrorSurfaceView
deriving DecidableEq, Repr

structure KernelReleaseArtifactView where
  kernelDigest : KernelExecutionDigestView
  stagedBundle : StagedExecutionDigestBundleView
deriving DecidableEq, Repr

structure KernelReleaseArtifactVectorCase where
  name : String
  root0Bindings : List CommitmentBinding
  traceDigests : TraceDigestSourceView
  frames : List FrameSourceView
  stage3s : List Stage3View
  expectedArtifact : KernelReleaseArtifactView
deriving Repr

def mkTraceDigestSourceView
    (stage1Digest stage2Digest stage3Digest semanticEvidenceSummaryDigest : List Byte) :
    TraceDigestSourceView :=
  { stage1Digest := stage1Digest
  , stage2Digest := stage2Digest
  , stage3Digest := stage3Digest
  , semanticEvidenceSummaryDigest := semanticEvidenceSummaryDigest }

def mkKernelTraceSurfaceView
    (frames : List FrameSourceView)
    (stage1Digest stage2Digest stage3Digest semanticEvidenceSummaryDigest : List Byte) :
    KernelTraceSurfaceView :=
  { frames := frames
  , stage1Digest := stage1Digest
  , stage2Digest := stage2Digest
  , stage3Digest := stage3Digest
  , semanticEvidenceSummaryDigest := semanticEvidenceSummaryDigest }

def mkKernelExportSurfaceView
    (semanticRows : Nat)
    (preparedStepDigests : List (List Byte)) : KernelExportSurfaceView :=
  { semanticRows := semanticRows, preparedStepDigests := preparedStepDigests }

def mkKernelRowProjectionView
    (rowIndex : Nat)
    (rowBindingClaimDigest rowBindingRefinementDigest semanticRowDigest semanticViewDigest digest :
      List Byte) : KernelRowProjectionView :=
  { rowIndex := rowIndex
  , rowBindingClaimDigest := rowBindingClaimDigest
  , rowBindingRefinementDigest := rowBindingRefinementDigest
  , semanticRowDigest := semanticRowDigest
  , semanticViewDigest := semanticViewDigest
  , digest := digest }

def mkKernelRowProjectionSummaryView
    (projections : List KernelRowProjectionView)
    (digest : List Byte) : KernelRowProjectionSummaryView :=
  { projections := projections, digest := digest }

def mkKernelBridgeBindingClaimView
    (rowIndex : Nat)
    (rowBindingClaimDigest rowBindingRefinementDigest preparedStepDigest digest :
      List Byte) : KernelBridgeBindingClaimView :=
  { rowIndex := rowIndex
  , rowBindingClaimDigest := rowBindingClaimDigest
  , rowBindingRefinementDigest := rowBindingRefinementDigest
  , preparedStepDigest := preparedStepDigest
  , digest := digest }

def mkKernelBridgeBindingSummaryView
    (claims : List KernelBridgeBindingClaimView)
    (digest : List Byte) : KernelBridgeBindingSummaryView :=
  { claims := claims, digest := digest }

def mkKernelAuditSurfaceView
    (rowProjectionSummary : KernelRowProjectionSummaryView)
    (bridgeBindingSummary : KernelBridgeBindingSummaryView) :
    KernelAuditSurfaceView :=
  { rowProjectionSummary := rowProjectionSummary
  , bridgeBindingSummary := bridgeBindingSummary }

def mkKernelOpeningClaimView
    (source : KernelOpeningSourceView)
    (commitmentId : CommitmentId)
    (point : List ChallengePairWords)
    (polynomialIds : List Nat)
    (claimedValues : List ChallengePairWords)
    (digest : List Byte) : KernelOpeningClaimView :=
  { source := source
  , commitmentId := commitmentId
  , point := point
  , polynomialIds := polynomialIds
  , claimedValues := claimedValues
  , digest := digest }

def mkKernelOpeningManifestView
    (claims : List KernelOpeningClaimView)
    (digest : List Byte) : KernelOpeningManifestView :=
  { claims := claims, digest := digest }

def mkKernelManifestSurfaceView
    (root0CommitmentIds : List CommitmentId)
    (kernelManifest rootManifest : KernelOpeningManifestView) :
    KernelManifestSurfaceView :=
  { root0CommitmentIds := root0CommitmentIds
  , kernelManifest := kernelManifest
  , rootManifest := rootManifest }

def mkKernelTranscriptSurfaceView
    (events : List KernelTranscriptEventView) : KernelTranscriptSurfaceView :=
  { events := events }

def mkKernelErrorSurfaceView
    (stage1Channels : List Stage1ShoutChannel)
    (stage1AddressFamilies : List AddressFamily)
    (regReadFamilies : List TwistReadFamily)
    (regAddressFamilies ramAddressFamilies : List AddressFamily)
    (twistMemoryFamilies : List TwistMemoryFamily)
    (stage1Terms stage2Terms stage3Terms batchTerms tailTerms : List ErrorTermView)
    (totalUpperDigest digest : List Byte) : KernelErrorSurfaceView :=
  { stage1Channels := stage1Channels
  , stage1AddressFamilies := stage1AddressFamilies
  , regReadFamilies := regReadFamilies
  , regAddressFamilies := regAddressFamilies
  , ramAddressFamilies := ramAddressFamilies
  , twistMemoryFamilies := twistMemoryFamilies
  , stage1Terms := stage1Terms
  , stage2Terms := stage2Terms
  , stage3Terms := stage3Terms
  , batchTerms := batchTerms
  , tailTerms := tailTerms
  , totalUpperDigest := totalUpperDigest
  , digest := digest }

def mkKernelExecutionDigestView
    (traceSurface : KernelTraceSurfaceView)
    (exportSurface : KernelExportSurfaceView)
    (auditSurface : KernelAuditSurfaceView)
    (manifestSurface : KernelManifestSurfaceView)
    (transcriptSurface : KernelTranscriptSurfaceView)
    (errorSurface : KernelErrorSurfaceView) :
    KernelExecutionDigestView :=
  { traceSurface := traceSurface
  , exportSurface := exportSurface
  , auditSurface := auditSurface
  , manifestSurface := manifestSurface
  , transcriptSurface := transcriptSurface
  , errorSurface := errorSurface }

def mkKernelReleaseArtifactView
    (kernelDigest : KernelExecutionDigestView)
    (stagedBundle : StagedExecutionDigestBundleView) :
    KernelReleaseArtifactView :=
  { kernelDigest := kernelDigest, stagedBundle := stagedBundle }

def mkKernelReleaseArtifactVectorCase
    (name : String)
    (root0Bindings : List CommitmentBinding)
    (traceDigests : TraceDigestSourceView)
    (frames : List FrameSourceView)
    (stage3s : List Stage3View)
    (expectedArtifact : KernelReleaseArtifactView) :
    KernelReleaseArtifactVectorCase :=
  { name := name
  , root0Bindings := root0Bindings
  , traceDigests := traceDigests
  , frames := frames
  , stage3s := stage3s
  , expectedArtifact := expectedArtifact }

def kernelTraceSurfaceViewOfSources
    (traceDigests : TraceDigestSourceView)
    (frames : List FrameSourceView) : KernelTraceSurfaceView :=
  { frames := frames
  , stage1Digest := traceDigests.stage1Digest
  , stage2Digest := traceDigests.stage2Digest
  , stage3Digest := traceDigests.stage3Digest
  , semanticEvidenceSummaryDigest := traceDigests.semanticEvidenceSummaryDigest }

def preparedStepDigestsOfStage3s (stage3s : List Stage3View) : List (List Byte) :=
  stage3s.map Stage3View.preparedStepDigest

def kernelExportSurfaceViewOfSources
    (frames : List FrameSourceView)
    (stage3s : List Stage3View) : KernelExportSurfaceView :=
  { semanticRows := frames.length
  , preparedStepDigests := preparedStepDigestsOfStage3s stage3s }

def phase0TranscriptEventsView
    (bindings : List CommitmentBinding) : List KernelTranscriptEventView :=
  bindings.map (fun binding => KernelTranscriptEventView.absorbCommitment binding.id) ++
    [.absorbMetaPub]

def stage1TranscriptEventsView : List KernelTranscriptEventView :=
  [ .sampleStage1Cycle
  , .stage1FetchSumcheck
  , .stage1DecodeSumcheck
  , .stage1AluSumcheck
  , .stage1Eq4Sumcheck
  , .stage1AddrCheckFetch
  , .stage1AddrCheckDecode
  , .stage1AddrCheckAlu
  , .stage1AddrCheckEq4
  , .recordFetchAddr
  , .recordDecodeAddr
  , .recordAluAddr
  , .deriveAdd8LoAddr
  , .recordEq4Addr
  , .sampleGammaLookupLink
  , .stage1LinkageBatch
  ]

def stage2TranscriptEventsView : List KernelTranscriptEventView :=
  [ .sampleStage2Cycle
  , .sampleGammaReg
  , .stage2RegRwBatched
  , .stage2RegValFromInc
  , .sampleGammaRam
  , .stage2RamRwBatched
  , .stage2RamValFromInc
  , .stage2RamRafRead
  , .stage2RamRafWrite
  , .stage2AddrCheckRegRaX
  , .stage2AddrCheckRegRaY
  , .stage2AddrCheckRegRaI
  , .stage2AddrCheckRegWa
  , .stage2AddrCheckRamRa
  , .stage2AddrCheckRamWa
  , .recordRegAddr
  , .recordRamAddr
  , .sampleGammaTwistLink
  , .stage2LinkageBatch
  ]

def stage3PrefixTranscriptEventsView : List KernelTranscriptEventView :=
  [ .sampleBeta1
  , .sampleBeta2
  , .sampleStage3Cycle
  , .laneShiftReduction
  , .stage3Continuity
  , .stage3StartBoundaryOpening
  , .stage3FinalBoundaryOpening
  ]

def stage3RowBindingEventsView (exportedRows : Nat) : List KernelTranscriptEventView :=
  List.ofFn (fun j : Fin exportedRows => KernelTranscriptEventView.rowBinding j.1)

def kernelTranscriptEventsView
    (bindings : List CommitmentBinding)
    (exportedRows : Nat) : List KernelTranscriptEventView :=
  phase0TranscriptEventsView bindings ++
    stage1TranscriptEventsView ++
    stage2TranscriptEventsView ++
    stage3PrefixTranscriptEventsView ++
    stage3RowBindingEventsView exportedRows ++
    [.emitKernelOpeningClaims]

def kernelTranscriptSurfaceViewOfSources
    (bindings : List CommitmentBinding)
    (exportedRows : Nat) : KernelTranscriptSurfaceView :=
  { events := kernelTranscriptEventsView bindings exportedRows }

def kernelErrorStage1TermsView : List ErrorTermView :=
  [ .shoutCore .fetch
  , .shoutCore .decode
  , .shoutCore .alu
  , .shoutCore .eq4
  , .addr .fetch
  , .addr .decode
  , .addr .alu
  , .addr .eq4
  ]

def kernelErrorStage2TermsView : List ErrorTermView :=
  [ .twistRead .regX
  , .twistRead .regY
  , .twistRead .regI
  , .twistWrite .reg
  , .twistVal .reg
  , .addr .regRaX
  , .addr .regRaY
  , .addr .regRaI
  , .addr .regWa
  , .twistRead .ram
  , .twistWrite .ram
  , .twistVal .ram
  , .ramRafRead
  , .ramRafWrite
  , .addr .ramRa
  , .addr .ramWa
  ]

def kernelErrorStage3TermsView : List ErrorTermView :=
  [ .shiftReduce, .continuity ]

def kernelErrorBatchTermsView : List ErrorTermView :=
  [ .regRwBatch, .ramRwBatch, .lookupLink, .twistLink ]

def kernelErrorTailTermsView : List ErrorTermView :=
  [ .pcs, .fs, .outer ]

def kernelErrorSurfaceListsConform (error : KernelErrorSurfaceView) : Bool :=
  error.stage1Channels == [.fetch, .decode, .alu, .eq4] &&
    error.stage1AddressFamilies == [.fetch, .decode, .alu, .eq4] &&
    error.regReadFamilies == [.regX, .regY, .regI] &&
    error.regAddressFamilies == [.regRaX, .regRaY, .regRaI, .regWa] &&
    error.ramAddressFamilies == [.ramRa, .ramWa] &&
    error.twistMemoryFamilies == [.reg, .ram] &&
    error.stage1Terms == kernelErrorStage1TermsView &&
    error.stage2Terms == kernelErrorStage2TermsView &&
    error.stage3Terms == kernelErrorStage3TermsView &&
    error.batchTerms == kernelErrorBatchTermsView &&
    error.tailTerms == kernelErrorTailTermsView

end Nightstream.Chip8.Generated
