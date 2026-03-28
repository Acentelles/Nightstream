import SuperNeo.Field

namespace SuperNeo.Generated

structure ProtocolArtifactCase where
  matrix : Array (Array Nat)
  r : Array Nat
  rho1 : Nat
  rho2 : Nat
  splitScalar : Nat
  kSplit : Nat
  samplingBound : Nat
  carrierLeft : Array Nat
  carrierRight : Array Nat
  cset : Array (Array Nat)
  samples : Array (Array Nat)
  xs : Array Nat
  ys : Array Nat
  qVals : Array Nat
  coeffs : Array Nat
  xEval : Nat
  expectedEval : Nat
  transcriptChallenges : Array Nat
  transcriptRoundPolys : Array (Array Nat)
deriving Repr, Inhabited

structure FinalProtocolArtifactCase where
  messageLength : Nat
  protocol : ProtocolArtifactCase
deriving Repr, Inhabited

end SuperNeo.Generated
