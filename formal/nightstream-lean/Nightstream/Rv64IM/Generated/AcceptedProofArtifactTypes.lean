import Nightstream.Rv64IM.Generated.ParityTypes
import Nightstream.Rv64IM.Generated.PublicProofVectorTypes

/-!
Generated-case surface for RV64IM accepted-proof artifact parity. This owner
packages the lowest practical exported RV64IM proof inputs currently available
to Lean: the source case, the imported derived case used as a replay target,
and the proof-bearing kernel bundle. The exported public proof shape remains
only an exact-parity projection target.
-/

namespace Nightstream.Rv64IM.Generated

structure PackagedProofDigestView where
  statementDigest : List Byte
  proofDigest : List Byte
deriving DecidableEq, Repr

structure SemInView where
  traceIndex : Nat
  stepIndex : Nat
  sequenceIndex : Nat
  pc : Nat
  opcode : Opcode
  traceOpcode : Option Opcode
  traceVirtualOpcode : Option TraceVirtualOpcode
  family : FamilyTag
  archRs1 : Nat
  archRs1Value : Nat
  archRs2 : Nat
  archRs2Value : Nat
  archRd : Nat
  archRdBefore : Nat
  archImm : Int
  rs1 : Nat
  rs1Value : Nat
  rs2 : Nat
  rs2Value : Nat
  rd : Nat
  rdBefore : Nat
  rdAfter : Nat
  imm : Int
  effectiveAddr : Option Nat
  memoryBefore : Option Nat
  memoryAfter : Option Nat
  memWidthBytes : Option Nat
  memUnsigned : Option Bool
  writesRd : Bool
  writesRam : Bool
  isFirstInSequence : Bool
  virtualSequenceRemaining : Option Nat
  isEffectRow : Bool
  isCommitRow : Bool
  isReal : Bool
deriving DecidableEq, Repr

structure Stage1SemanticsProofView where
  semInputsDigest : List Byte
  rowBindingsDigest : List Byte
  sequenceCount : Nat
  helperRowCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure Stage1OpeningPointsView where
  first : SelectedOpeningRefView
  effect : SelectedOpeningRefView
  commit : SelectedOpeningRefView
  last : SelectedOpeningRefView
deriving DecidableEq, Repr

structure Stage1SelectedOpeningClaimView where
  rowsFamilyDigest : List Byte
  rowCount : Nat
  effectRowCount : Nat
  commitRowCount : Nat
  realRowCount : Nat
  preservesX0Count : Nat
  firstTraceIndex : Nat
  effectTraceIndex : Nat
  commitTraceIndex : Nat
  lastTraceIndex : Nat
  mix : Nat
  points : Stage1OpeningPointsView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage1PackagedOpeningProofView where
  claim : Stage1SelectedOpeningClaimView
  packaged : PackagedProofDigestView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage1ProofBundleView where
  semInputs : List SemInView
  rowBindings : List Stage1RowBindingView
  bytecodeDigest : List Byte
  aluDigest : List Byte
  branchDigest : List Byte
  semantics : Stage1SemanticsProofView
  addressCorrectnessDigest : List Byte
  linkageDigest : List Byte
  selectedOpening : Stage1PackagedOpeningProofView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage2SemanticsProofView where
  registerReadsFamilyDigest : List Byte
  registerWritesFamilyDigest : List Byte
  ramEventsFamilyDigest : List Byte
  twistLinksFamilyDigest : List Byte
  rowCount : Nat
  registerEventCount : Nat
  ramEventCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure Stage2TemporalContextView where
  twistLinks : List TwistLinkEventView
  registerTimelineDigest : List Byte
  ramTimelineDigest : List Byte
  twistLinksDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure Stage2OpeningPointsView where
  firstRead : Option SelectedOpeningRefView
  lastRead : Option SelectedOpeningRefView
  firstWrite : Option SelectedOpeningRefView
  lastWrite : Option SelectedOpeningRefView
  firstRam : Option SelectedOpeningRefView
  lastRam : Option SelectedOpeningRefView
  firstTwist : Option SelectedOpeningRefView
  lastTwist : Option SelectedOpeningRefView
deriving DecidableEq, Repr

structure Stage2SelectedOpeningClaimView where
  registerReadsFamilyDigest : List Byte
  registerWritesFamilyDigest : List Byte
  ramEventsFamilyDigest : List Byte
  twistLinksFamilyDigest : List Byte
  registerReadCount : Nat
  registerWriteCount : Nat
  ramEventCount : Nat
  twistLinkCount : Nat
  ramReadCount : Nat
  ramWriteCount : Nat
  regMix : Nat
  ramMix : Nat
  points : Stage2OpeningPointsView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage2PackagedOpeningProofView where
  claim : Stage2SelectedOpeningClaimView
  packaged : PackagedProofDigestView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage2ProofBundleView where
  registerReads : List RegisterReadEventView
  registerWrites : List RegisterWriteEventView
  ramEvents : List RamEventView
  registerDigest : List Byte
  ramDigest : List Byte
  temporal : Stage2TemporalContextView
  semantics : Stage2SemanticsProofView
  linkageDigest : List Byte
  selectedOpening : Stage2PackagedOpeningProofView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage3SemanticsProofView where
  continuityDigest : List Byte
  rootSemanticRowsDigest : List Byte
  rowChunkRoutesDigest : List Byte
  preparedStepBindingsDigest : List Byte
  stage2TemporalDigest : List Byte
  initialPc : Nat
  finalPc : Nat
  realRowCount : Nat
  firstRealStepIndex : Nat
  lastRealStepIndex : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure Stage3OpeningPointsView where
  firstContinuity : Option SelectedOpeningRefView
  lastContinuity : Option SelectedOpeningRefView
deriving DecidableEq, Repr

structure Stage3SelectedOpeningClaimView where
  continuityFamilyDigest : List Byte
  continuityCount : Nat
  finalStepCount : Nat
  halted : Bool
  allContinuityHold : Bool
  continuityMix : Nat
  points : Stage3OpeningPointsView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage3PackagedOpeningProofView where
  claim : Stage3SelectedOpeningClaimView
  packaged : PackagedProofDigestView
  digest : List Byte
deriving DecidableEq, Repr

structure Stage3ProofBundleView where
  continuity : List ContinuityEventView
  halted : Bool
  bridgeDigest : List Byte
  semantics : Stage3SemanticsProofView
  linkageDigest : List Byte
  selectedOpening : Stage3PackagedOpeningProofView
  digest : List Byte
deriving DecidableEq, Repr

structure PreparedStepBindingView where
  traceIndex : Nat
  rowDigest : List Byte
  rowOpeningDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure PreparedStepBindingSummaryView where
  bindings : List PreparedStepBindingView
  bindingCount : Nat
  firstBindingDigest : Option (List Byte)
  lastBindingDigest : Option (List Byte)
  digest : List Byte
deriving DecidableEq, Repr

structure RootSemanticRowView where
  traceIndex : Nat
  values : List Nat
  rowDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure RowChunkRouteView where
  logicalIndex : Nat
  chunkIndex : Nat
  chunkStartIndex : Nat
  chunkLocalIndex : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure RootRowLocalCcsAcceptanceView where
  traceIndex : Nat
  logicalIndex : Nat
  rowDigest : List Byte
  rowOpeningDigest : List Byte
  preparedStepBindingDigest : List Byte
  rowChunkRouteDigest : List Byte
  publicStepDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure RootRowLocalCcsAcceptanceSummaryView where
  acceptances : List RootRowLocalCcsAcceptanceView
  acceptanceCount : Nat
  firstAcceptanceDigest : Option (List Byte)
  lastAcceptanceDigest : Option (List Byte)
  digest : List Byte
deriving DecidableEq, Repr

structure RootExecutionSemanticsRefinementView where
  traceIndex : Nat
  logicalIndex : Nat
  semanticRowDigest : List Byte
  rowLocalCcsAcceptanceDigest : List Byte
  preparedStepBindingDigest : List Byte
  publicStepDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure RootExecutionSemanticsRefinementSummaryView where
  refinements : List RootExecutionSemanticsRefinementView
  refinementCount : Nat
  firstRefinementDigest : Option (List Byte)
  lastRefinementDigest : Option (List Byte)
  digest : List Byte
deriving DecidableEq, Repr

structure RootExecutionBundleView where
  executionRows : List ExpandedRowView
  semanticRows : List RootSemanticRowView
  semanticRowsDigest : List Byte
  preparedStepBindings : PreparedStepBindingSummaryView
  rowChunkRoutes : List RowChunkRouteView
  rowChunkRoutesDigest : List Byte
  rowLocalCcsAcceptance : RootRowLocalCcsAcceptanceSummaryView
  executionSemanticsRefinement : RootExecutionSemanticsRefinementSummaryView
  familyDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure StepCompositionSurfaceView where
  stage1SemanticsDigest : List Byte
  stage2SemanticsDigest : List Byte
  stage2TemporalDigest : List Byte
  stage3SemanticsDigest : List Byte
  rootExecutionDigest : List Byte
  preparedStepBindingsDigest : List Byte
  rowChunkRoutesDigest : List Byte
  realRowCount : Nat
  preparedStepCount : Nat
  firstRealStepIndex : Nat
  lastRealStepIndex : Nat
  initialPc : Nat
  finalPc : Nat
  halted : Bool
  digest : List Byte
deriving DecidableEq, Repr

structure KernelSoundnessAccountingSurfaceView where
  schemaVersion : Nat
  stage1ShoutChannels : List String
  stage1AddressFamilies : List String
  stage2AddressFamilies : List String
  twistMemoryFamilies : List String
  scalarTerms : List String
  schemaDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure KernelBindingOpeningPointsView where
  firstBinding : Option SelectedOpeningRefView
  lastBinding : Option SelectedOpeningRefView
deriving DecidableEq, Repr

structure KernelPreparedStepOpeningPointsView where
  firstPreparedStep : Option SelectedOpeningRefView
  lastPreparedStep : Option SelectedOpeningRefView
deriving DecidableEq, Repr

structure KernelBindingOpeningClaimView where
  stageClaimBundleDigest : List Byte
  stagePackageBundleDigest : List Byte
  stage1PackageDigest : List Byte
  stage2PackageDigest : List Byte
  stage3PackageDigest : List Byte
  preparedStepBindingsDigest : List Byte
  bindingCount : Nat
  stage1RowCount : Nat
  stage2RegisterReadCount : Nat
  stage2RegisterWriteCount : Nat
  stage2RamEventCount : Nat
  stage3ContinuityCount : Nat
  points : KernelBindingOpeningPointsView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelPreparedStepOpeningClaimView where
  executionDigest : List Byte
  finalStateDigest : List Byte
  transcriptFinalDigest : List Byte
  preparedStepCount : Nat
  finalPc : Nat
  halted : Bool
  points : KernelPreparedStepOpeningPointsView
  digest : List Byte
deriving DecidableEq, Repr

structure SimpleKernelOpeningClaimView where
  bindings : KernelBindingOpeningClaimView
  preparedSteps : KernelPreparedStepOpeningClaimView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelBindingPackagedOpeningProofView where
  claim : KernelBindingOpeningClaimView
  packaged : PackagedProofDigestView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelPreparedStepPackagedOpeningProofView where
  claim : KernelPreparedStepOpeningClaimView
  packaged : PackagedProofDigestView
  digest : List Byte
deriving DecidableEq, Repr

structure SimpleKernelOpeningBundleView where
  claim : SimpleKernelOpeningClaimView
  bindings : KernelBindingPackagedOpeningProofView
  preparedSteps : KernelPreparedStepPackagedOpeningProofView
  digest : List Byte
deriving DecidableEq, Repr

structure AcceptedProofArtifactView where
  name : String
  source : ParitySourceCase
  derived : ParityDerivedCase
  kernelProof : KernelProofBundleView
  exportedProof : ProofView
  exportedStatement : ProofStatementView
  exportedClaims : KernelClaimBundleView
  exportedKernelProof : KernelProofBundleView
  transcript : TranscriptView
  stage1 : Stage1ProofBundleView
  stage2 : Stage2ProofBundleView
  stage3 : Stage3ProofBundleView
  rootExecution : RootExecutionBundleView
  stepComposition : StepCompositionSurfaceView
  soundnessAccounting : KernelSoundnessAccountingSurfaceView
  kernelOpeningBundle : SimpleKernelOpeningBundleView
  digest : List Byte
deriving DecidableEq, Repr

end Nightstream.Rv64IM.Generated
