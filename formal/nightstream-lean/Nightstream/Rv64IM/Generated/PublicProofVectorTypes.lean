import Nightstream.Rv64IM.Generated.ParityTypes

/-!
Generated-case surface for RV64IM public-proof boundary parity. These views
mirror the shipped Rust `statement / claims / kernelProof` boundary without the
private simple-kernel transport fields.
-/

namespace Nightstream.Rv64IM.Generated

structure ProofStatementView where
  rootParamsId : List Byte
  stageClaimsDigest : List Byte
  stagePackagesDigest : List Byte
  kernelOpeningDigest : List Byte
  preparedStepBindingsDigest : List Byte
  executionDigest : List Byte
  finalStateDigest : List Byte
  transcriptFinalDigest : List Byte
  mainLaneStatementDigest : List Byte
  publicStepCount : Nat
  finalPc : Nat
  halted : Bool
  digest : List Byte
deriving DecidableEq, Repr

structure AcceptedProofStatementBindingView where
  proofStatementDigest : List Byte
  kernelOpeningDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure AcceptedProofMainLaneBindingView where
  mainLaneStatementDigest : List Byte
  mainLaneProofDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure AcceptedProofTerminalBindingView where
  finalStateDigest : List Byte
  publicStepCount : Nat
  finalPc : Nat
  halted : Bool
  digest : List Byte
deriving DecidableEq, Repr

structure AcceptedProofClaimView where
  rootParamsId : List Byte
  statement : AcceptedProofStatementBindingView
  mainLane : AcceptedProofMainLaneBindingView
  terminal : AcceptedProofTerminalBindingView
  digest : List Byte
deriving DecidableEq, Repr

structure MainLaneClaimBindingView where
  statementDigest : List Byte
  proofDigest : List Byte
  publicStepCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure MainLaneClaimView where
  rootParamsId : List Byte
  binding : MainLaneClaimBindingView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelOpeningStageClaimBindingView where
  stageClaimsDigest : List Byte
  stagePackagesDigest : List Byte
  kernelOpeningDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure KernelOpeningTerminalClaimBindingView where
  preparedStepBindingsDigest : List Byte
  executionDigest : List Byte
  transcriptFinalDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure KernelOpeningClaimView where
  rootParamsId : List Byte
  stages : KernelOpeningStageClaimBindingView
  terminal : KernelOpeningTerminalClaimBindingView
  publicStepCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure JointOpeningClaimBindingView where
  proofStatementDigest : List Byte
  mainLaneClaimDigest : List Byte
  kernelOpeningClaimDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure JointOpeningClaimView where
  rootParamsId : List Byte
  binding : JointOpeningClaimBindingView
  publicStepCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure Root0StageClaimBindingView where
  stage1Digest : List Byte
  stage2Digest : List Byte
  stage3Digest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure Root0TerminalClaimBindingView where
  root0Digest : List Byte
  executionDigest : List Byte
  finalStateDigest : List Byte
  transcriptFinalDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure Root0ClaimView where
  rootParamsId : List Byte
  stages : Root0StageClaimBindingView
  terminal : Root0TerminalClaimBindingView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelClaimBundleView where
  accepted : AcceptedProofClaimView
  mainLane : MainLaneClaimView
  opening : KernelOpeningClaimView
  jointOpening : JointOpeningClaimView
  root0 : Root0ClaimView
  digest : List Byte
deriving DecidableEq, Repr

structure MainLaneProofBindingView where
  statementDigest : List Byte
  proofDigest : List Byte
  publicStepCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure MainLaneProofBundleView where
  binding : MainLaneProofBindingView
  digest : List Byte
deriving DecidableEq, Repr

structure MainLaneProofSummaryBundleView where
  binding : MainLaneProofBindingView
  digest : List Byte
deriving DecidableEq, Repr

structure TraceShapeBundleView where
  executionRowCount : Nat
  realRowCount : Nat
  effectRowCount : Nat
  commitRowCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure TraceProofBundleView where
  manifest : ParityCaseManifest
  executionDigest : List Byte
  shape : TraceShapeBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure StageWitnessSummaryBundleView where
  stage1RowCount : Nat
  stage2RegisterReadCount : Nat
  stage2RegisterWriteCount : Nat
  stage2RamEventCount : Nat
  stage2TwistLinkCount : Nat
  stage3ContinuityCount : Nat
  stage3Halted : Bool
  transcriptEventCount : Nat
  digest : List Byte
deriving DecidableEq, Repr

structure StageWitnessProofBundleView where
  summary : StageWitnessSummaryBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure StageClaimDigestBundleView where
  claimBundleDigest : List Byte
  stage1Digest : List Byte
  stage2Digest : List Byte
  stage3Digest : List Byte
  transcriptDigest : List Byte
  executionDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure StageClaimProofBundleView where
  summary : StageClaimDigestBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure StagePackageDigestBundleView where
  packageBundleDigest : List Byte
  stage1Digest : List Byte
  stage2Digest : List Byte
  stage3Digest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure StagePackageProofBundleView where
  summary : StagePackageDigestBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelOpeningBindingBundleView where
  claimDigest : List Byte
  bindingsDigest : List Byte
  preparedStepsDigest : List Byte
  digest : List Byte
deriving DecidableEq, Repr

structure KernelOpeningProofBundleView where
  openingDigest : List Byte
  bindings : KernelOpeningBindingBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelOpeningSummaryBundleView where
  openingDigest : List Byte
  bindings : KernelOpeningBindingBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelClaimTerminalBundleView where
  root0Digest : List Byte
  executionDigest : List Byte
  finalStateDigest : List Byte
  transcriptFinalDigest : List Byte
  finalPc : Nat
  halted : Bool
  digest : List Byte
deriving DecidableEq, Repr

structure KernelClaimSummaryBundleView where
  preparedStepBindingsDigest : List Byte
  terminal : KernelClaimTerminalBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelClaimProofBundleView where
  summary : KernelClaimSummaryBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure JointOpeningProofBundleView where
  proofStatementDigest : List Byte
  publicStepCount : Nat
  mainLane : MainLaneProofSummaryBundleView
  kernelOpening : KernelOpeningSummaryBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure Root0CommitmentBundleView where
  stageClaims : StageClaimDigestBundleView
  stagePackages : StagePackageDigestBundleView
  kernelOpening : KernelOpeningSummaryBundleView
  kernelClaims : KernelClaimSummaryBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure KernelProofBundleView where
  rootParamsId : List Byte
  trace : TraceProofBundleView
  stages : StageWitnessProofBundleView
  stageClaims : StageClaimProofBundleView
  stagePackages : StagePackageProofBundleView
  kernelOpening : KernelOpeningProofBundleView
  kernelClaims : KernelClaimProofBundleView
  mainLane : MainLaneProofBundleView
  jointOpening : JointOpeningProofBundleView
  root0Commitment : Root0CommitmentBundleView
  digest : List Byte
deriving DecidableEq, Repr

structure PublicProofVectorCase where
  name : String
  statement : ProofStatementView
  claims : KernelClaimBundleView
  kernelProof : KernelProofBundleView
deriving DecidableEq, Repr

end Nightstream.Rv64IM.Generated
