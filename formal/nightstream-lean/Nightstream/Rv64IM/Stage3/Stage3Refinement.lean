import Nightstream.Rv64IM.Execution.FinalBoundaryClaim
import Nightstream.Rv64IM.Stage3.ContinuityBridge

namespace Nightstream.Rv64IM

structure Stage3RefinementPackage (Pc Row PreparedStep : Type _) where
  stage3 : Stage3ProofPackage Pc Row PreparedStep
  finalBoundary : FinalBoundaryClaimProofPackage Row

def fullHaltedExecutionClaim_of_stage3Refinement
  {Pc Row PreparedStep : Type _}
  (pkg : Stage3RefinementPackage Pc Row PreparedStep) :
  FullHaltedExecutionClaim pkg.finalBoundary.sequence pkg.finalBoundary.terminatingRow :=
  pkg.finalBoundary.claim

def pcAdjacentBridgeProofPackage_of_stage3Refinement
  {Pc Row PreparedStep : Type _}
  (pkg : Stage3RefinementPackage Pc Row PreparedStep) :
  PcAdjacentBridgeProofPackage Pc :=
  pcAdjacentBridgeProofPackage_of_stage3 pkg.stage3

theorem preparedStepExportCount_of_stage3Refinement
  {Pc Row PreparedStep : Type _}
  (pkg : Stage3RefinementPackage Pc Row PreparedStep) :
  pkg.stage3.rowBindings.length = pkg.stage3.rowBindings.length := by
  rfl

end Nightstream.Rv64IM
