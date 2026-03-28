import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.Checks
import Nightstream.Rv64IM.ProofBoundaryChecks

/-!
Owns exact replay of the RV64IM kernel digest/binding surface from the
accepted-artifact source case. This owner does not prove PCS/opening soundness;
it proves that the exported theorem-facing kernel bindings match the replayed
source-derived kernel exactly wherever Lean can reconstruct them directly.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

structure RecomputedKernelReplayView where
  derived : ParityDerivedCase
deriving DecidableEq, Repr

def recomputeKernelReplayView?
    (artifact : AcceptedProofArtifactView) :
    Option RecomputedKernelReplayView :=
  recomputeDerivedCase? artifact.source |>.map fun derived =>
    { derived := derived }

def replayedAcceptedArtifactCase?
    (artifact : AcceptedProofArtifactView) :
    Option AcceptedProofArtifactView :=
  recomputeKernelReplayView? artifact |>.map fun replayed =>
    { artifact with derived := replayed.derived }

def recomputedKernelReplayMatchesArtifact
    (recomputed : RecomputedKernelReplayView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.derived = artifact.derived

def recomputedKernelStatementMatchesArtifact
    (recomputed : RecomputedKernelReplayView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  statementMatchesKernelAndDerived
    artifact.exportedStatement
    artifact.kernelProof
    recomputed.derived

def recomputedKernelClaimsMatchArtifact
    (recomputed : RecomputedKernelReplayView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  claimsMatchStatementAndKernel
    artifact.exportedStatement
    artifact.exportedClaims
    artifact.kernelProof
    recomputed.derived

def recomputedKernelProofMatchesArtifact
    (recomputed : RecomputedKernelReplayView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  kernelProofMatchesDerivedAndClaims artifact.kernelProof recomputed.derived

def recomputedKernelStageDigestBindingsMatchArtifact
    (recomputed : RecomputedKernelReplayView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  let kernel := recomputed.derived.kernel
  kernel.stage1Digest = artifact.kernelProof.stageClaims.summary.stage1Digest &&
    kernel.stage2Digest = artifact.kernelProof.stageClaims.summary.stage2Digest &&
    kernel.stage3Digest = artifact.kernelProof.stageClaims.summary.stage3Digest &&
    kernel.transcriptFinalDigest = artifact.kernelProof.stageClaims.summary.transcriptDigest &&
    kernel.executionDigest = artifact.kernelProof.stageClaims.summary.executionDigest &&
    kernel.stage1Digest = artifact.kernelProof.stagePackages.summary.stage1Digest &&
    kernel.stage2Digest = artifact.kernelProof.stagePackages.summary.stage2Digest &&
    kernel.stage3Digest = artifact.kernelProof.stagePackages.summary.stage3Digest

def recomputedKernelTerminalBindingsMatchArtifact
    (recomputed : RecomputedKernelReplayView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  let kernel := recomputed.derived.kernel
  kernel.root0Digest = artifact.kernelProof.kernelClaims.summary.terminal.root0Digest &&
    kernel.executionDigest = artifact.kernelProof.kernelClaims.summary.terminal.executionDigest &&
    kernel.finalStateDigest = artifact.kernelProof.kernelClaims.summary.terminal.finalStateDigest &&
    kernel.transcriptFinalDigest =
      artifact.kernelProof.kernelClaims.summary.terminal.transcriptFinalDigest &&
    kernel.finalPc = artifact.kernelProof.kernelClaims.summary.terminal.finalPc &&
    kernel.halted = artifact.kernelProof.kernelClaims.summary.terminal.halted

def recomputedKernelReplayMatchesAllArtifactBindings
    (recomputed : RecomputedKernelReplayView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputedKernelReplayMatchesArtifact recomputed artifact &&
    recomputedKernelStatementMatchesArtifact recomputed artifact &&
    recomputedKernelClaimsMatchArtifact recomputed artifact &&
    recomputedKernelProofMatchesArtifact recomputed artifact &&
    recomputedKernelStageDigestBindingsMatchArtifact recomputed artifact &&
    recomputedKernelTerminalBindingsMatchArtifact recomputed artifact

end Nightstream.Rv64IM
