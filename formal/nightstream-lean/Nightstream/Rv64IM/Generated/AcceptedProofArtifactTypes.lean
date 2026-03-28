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

structure AcceptedProofArtifactView where
  name : String
  source : ParitySourceCase
  derived : ParityDerivedCase
  kernelProof : KernelProofBundleView
  exportedProof : ProofView
  exportedStatement : ProofStatementView
  exportedClaims : KernelClaimBundleView
  exportedKernelProof : KernelProofBundleView
deriving DecidableEq, Repr

end Nightstream.Rv64IM.Generated
