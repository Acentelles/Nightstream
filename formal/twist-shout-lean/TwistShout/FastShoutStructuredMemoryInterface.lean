import TwistShout.FastShoutStructuredMemory

/-!
# FastShoutStructuredMemoryInterface

Thin theorem-facing boundary for the Section 7 fast Shout prover on structured memories.
-/

namespace TwistShout

namespace FastShoutStructuredMemoryInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev CycleCube := @TwistShout.CycleCube
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev PublicTable := @TwistShout.PublicTable
abbrev StructuredTableOracle := @TwistShout.StructuredTableOracle
abbrev batchedTable := @TwistShout.batchedTable
abbrev structuredReadCheckFinalRoundTarget := @TwistShout.structuredReadCheckFinalRoundTarget
abbrev structuredReadValueEvalLeadingCost := @TwistShout.structuredReadValueEvalLeadingCost
abbrev structuredReadCheckLeadingCost := @TwistShout.structuredReadCheckLeadingCost
abbrev structuredBooleanityLeadingCost := @TwistShout.structuredBooleanityLeadingCost
abbrev structuredRafLeadingCost := @TwistShout.structuredRafLeadingCost
abbrev structuredHammingLeadingCost := @TwistShout.structuredHammingLeadingCost
abbrev structuredShoutLeadingCost := @TwistShout.structuredShoutLeadingCost

def StructuredTableOracle.ofTableMLE
  {K : Type*} [Field K]
  {d m : Nat}
  (val : PublicTable (K := K) d m) :
  StructuredTableOracle (K := K) val :=
  TwistShout.StructuredTableOracle.ofTableMLE (K := K) val

theorem StructuredTableOracle.eval_eq
  {K : Type*} [Field K]
  {d m : Nat}
  {val : PublicTable (K := K) d m}
  (oracle : StructuredTableOracle (K := K) val)
  (rAddress : Fin d → Point (K := K) m) :
  oracle.eval rAddress = tableMLE (K := K) val rAddress :=
  TwistShout.StructuredTableOracle.eval_eq (K := K) oracle rAddress

theorem StructuredTableOracle.eval_at_bitAddress
  {K : Type*} [Field K]
  {d m : Nat}
  {val : PublicTable (K := K) d m}
  (oracle : StructuredTableOracle (K := K) val)
  (a : Address d m) :
  oracle.eval (bitAddress (K := K) a) = val a :=
  TwistShout.StructuredTableOracle.eval_at_bitAddress (K := K) oracle a

def StructuredTableOracle.batched
  {K : Type*} [Field K]
  {d m : Nat}
  {val : PublicTable (K := K) d m}
  (oracle : StructuredTableOracle (K := K) val)
  (z : K) :
  StructuredTableOracle (K := K) (batchedTable (K := K) z val) :=
  TwistShout.StructuredTableOracle.batched (K := K) oracle z

theorem StructuredTableOracle.batched_eval
  {K : Type*} [Field K]
  {d m : Nat}
  {val : PublicTable (K := K) d m}
  (oracle : StructuredTableOracle (K := K) val)
  (z : K)
  (rAddress : Fin d → Point (K := K) m) :
  (oracle.batched z).eval rAddress =
    oracle.eval rAddress + z * tableMLE (K := K) (addressValue (K := K)) rAddress :=
  TwistShout.StructuredTableOracle.batched_eval (K := K) oracle z rAddress

theorem StructuredTableOracle.batched_eval_at_bitAddress
  {K : Type*} [Field K]
  {d m : Nat}
  {val : PublicTable (K := K) d m}
  (oracle : StructuredTableOracle (K := K) val)
  (z : K)
  (a : Address d m) :
  (oracle.batched z).eval (bitAddress (K := K) a) =
    val a + z * addressValue (K := K) a :=
  TwistShout.StructuredTableOracle.batched_eval_at_bitAddress (K := K) oracle z a

theorem StructuredTableOracle.structuredReadCheckFinalRoundTarget_eq
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  (oracle : StructuredTableOracle (K := K) val)
  (queryCycle : Point (K := K) t)
  (ra : AddressColumns (K := K) d m t)
  (rAddress : Fin d → Point (K := K) m)
  (boundCycle : Point (K := K) t) :
  structuredReadCheckFinalRoundTarget (K := K) queryCycle ra oracle rAddress boundCycle =
    readCheckFinalRoundTarget (K := K) queryCycle ra val rAddress boundCycle :=
  TwistShout.StructuredTableOracle.structuredReadCheckFinalRoundTarget_eq
    (K := K) oracle queryCycle ra rAddress boundCycle

theorem StructuredTableOracle.readCheckFinalRoundTarget_atBooleanPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (oracle : StructuredTableOracle (K := K) val)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  structuredReadCheckFinalRoundTarget (K := K) queryCycle ra oracle
    (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
    chiWeight (K := K) queryCycle j * val (addr j) :=
  TwistShout.StructuredTableOracle.readCheckFinalRoundTarget_atBooleanPoint
    (K := K) oracle hvalid queryCycle j

theorem StructuredTableOracle.batched_readCheckFinalRoundTarget_atBooleanPoint
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (oracle : StructuredTableOracle (K := K) val)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (z : K)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  structuredReadCheckFinalRoundTarget (K := K) queryCycle ra (oracle.batched z)
    (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
    chiWeight (K := K) queryCycle j *
      (val (addr j) + z * addressValue (K := K) (addr j)) :=
  TwistShout.StructuredTableOracle.batched_readCheckFinalRoundTarget_atBooleanPoint
    (K := K) oracle hvalid z queryCycle j

theorem structuredBooleanityLeadingCost_eq_chunked
  (c d t : Nat) :
  structuredBooleanityLeadingCost (c * d) d t =
    (4 * c * d + 3 * d) * cycleSpaceSize t :=
  TwistShout.structuredBooleanityLeadingCost_eq_chunked c d t

theorem structuredReadCheckLeadingCost_eq_chunked
  (c d t : Nat) :
  structuredReadCheckLeadingCost (c * d) d t =
    (2 * c * d + d * d) * cycleSpaceSize t :=
  TwistShout.structuredReadCheckLeadingCost_eq_chunked c d t

theorem structuredShoutLeadingCost_eq_sum
  (C c d t : Nat) :
  structuredShoutLeadingCost C c d t =
    structuredReadValueEvalLeadingCost t +
      structuredReadCheckLeadingCost C d t +
      structuredBooleanityLeadingCost C d t +
      structuredRafLeadingCost C t +
      structuredHammingLeadingCost c t :=
  TwistShout.structuredShoutLeadingCost_eq_sum C c d t

theorem structuredShoutLeadingCost_eq_chunked
  (c d t : Nat) :
  structuredShoutLeadingCost (c * d) c d t =
    (7 * c * d + d * d + 3 * d + c + 2) * cycleSpaceSize t :=
  TwistShout.structuredShoutLeadingCost_eq_chunked c d t

end FastShoutStructuredMemoryInterface

end TwistShout
