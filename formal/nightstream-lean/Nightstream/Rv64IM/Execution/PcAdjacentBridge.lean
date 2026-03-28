namespace Nightstream.Rv64IM

def PcAdjacentBridge (Pc : Type _) (postPc prePc : Nat → Pc) (semanticRows : Nat) : Prop :=
  ∀ j, j + 1 < semanticRows → postPc j = prePc (j + 1)

structure PcAdjacentBridgeProofPackage (Pc : Type _) where
  semanticRows : Nat
  postPc : Nat → Pc
  prePc : Nat → Pc
  bridge : PcAdjacentBridge Pc postPc prePc semanticRows

end Nightstream.Rv64IM
