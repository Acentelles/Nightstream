import TwistShout.ShoutOneHot

/-!
# ShoutOneHotInterface

Thin theorem-facing boundary for Shout's one-hot checking layer.
-/

namespace TwistShout

namespace ShoutOneHotInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev CycleCube := @TwistShout.CycleCube
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev cubeOneHot := @TwistShout.cubeOneHot
abbrev tupleCubeOneHot := @TwistShout.tupleCubeOneHot
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev addressSelector := @TwistShout.addressSelector
abbrev booleanityDefect := @TwistShout.booleanityDefect
abbrev booleanityExpression := @TwistShout.booleanityExpression
abbrev hammingWeightAtCycle := @TwistShout.hammingWeightAtCycle
abbrev hammingWeightExpression := @TwistShout.hammingWeightExpression
abbrev digitValue := @TwistShout.digitValue
abbrev addressValue := @TwistShout.addressValue
abbrev addressOracleTable := @TwistShout.addressOracleTable
abbrev addressValueExpression := @TwistShout.addressValueExpression

@[simp] theorem cubeOneHot_self
  {K : Type*} [Field K]
  {m : Nat}
  (z : DigitCube m) :
  cubeOneHot (K := K) z z = 1 :=
  TwistShout.cubeOneHot_self (K := K) z

theorem cubeOneHot_eq_zero_of_ne
  {K : Type*} [Field K]
  {m : Nat}
  {z k : DigitCube m}
  (hzk : k ≠ z) :
  cubeOneHot (K := K) z k = 0 :=
  TwistShout.cubeOneHot_eq_zero_of_ne (K := K) hzk

open Classical in
theorem sum_cubeOneHot
  {K : Type*} [Field K]
  {m : Nat}
  (z : DigitCube m) :
  ∑ k : DigitCube m, cubeOneHot (K := K) z k = 1 :=
  TwistShout.sum_cubeOneHot (K := K) z

open Classical in
theorem mle_cubeOneHot
  {K : Type*} [Field K]
  {m : Nat}
  (z : DigitCube m)
  (r : Point (K := K) m) :
  mle (K := K) (cubeOneHot (K := K) z) r = chiWeight (K := K) r z :=
  TwistShout.mle_cubeOneHot (K := K) z r

@[simp] theorem tupleCubeOneHot_self
  {K : Type*} [Field K]
  {d m : Nat}
  (z : Address d m) :
  tupleCubeOneHot (K := K) z z = 1 :=
  TwistShout.tupleCubeOneHot_self (K := K) z

theorem tupleCubeOneHot_eq_zero_of_ne
  {K : Type*} [Field K]
  {d m : Nat}
  {z k : Address d m}
  (hzk : k ≠ z) :
  tupleCubeOneHot (K := K) z k = 0 :=
  TwistShout.tupleCubeOneHot_eq_zero_of_ne (K := K) hzk

open Classical in
theorem weightedSum_tupleCubeOneHot
  {K : Type*} [Field K]
  {d m : Nat}
  (w : Address d m → K)
  (z : Address d m) :
  ∑ k : Address d m, w k * tupleCubeOneHot (K := K) z k = w z :=
  TwistShout.weightedSum_tupleCubeOneHot (K := K) w z

theorem ValidAddressColumns.coord_eq_cubeOneHot
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (j : CycleCube t)
  (i : Fin d) :
  (fun k => ra i k j) = cubeOneHot (K := K) (addr j i) :=
  TwistShout.ValidAddressColumns.coord_eq_cubeOneHot (K := K) hvalid j i

theorem ValidAddressColumns.booleanityAtEntry
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (j : CycleCube t)
  (i : Fin d)
  (k : DigitCube m) :
  booleanityDefect (K := K) ra i k j = 0 :=
  TwistShout.ValidAddressColumns.booleanityAtEntry (K := K) hvalid j i k

theorem ValidAddressColumns.hammingWeightAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (i : Fin d)
  (j : CycleCube t) :
  hammingWeightAtCycle (K := K) ra i j = 1 :=
  TwistShout.ValidAddressColumns.hammingWeightAtCycle (K := K) hvalid i j

open Classical in
theorem ValidAddressColumns.addressSelector_eq_tupleCubeOneHot
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (k : Address d m)
  (j : CycleCube t) :
  addressSelector (K := K) ra k j = tupleCubeOneHot (K := K) (addr j) k :=
  TwistShout.ValidAddressColumns.addressSelector_eq_tupleCubeOneHot (K := K) hvalid k j

open Classical in
theorem ValidAddressColumns.selectorWeightedSumAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (w : Address d m → K)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (j : CycleCube t) :
  ∑ k : Address d m, w k * addressSelector (K := K) ra k j = w (addr j) :=
  TwistShout.ValidAddressColumns.selectorWeightedSumAtCycle (K := K) w hvalid j

open Classical in
theorem ValidAddressColumns.addressValueAtCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (j : CycleCube t) :
  ∑ k : Address d m, addressValue (K := K) k * addressSelector (K := K) ra k j =
    addressValue (K := K) (addr j) :=
  TwistShout.ValidAddressColumns.addressValueAtCycle (K := K) hvalid j

theorem ValidAddressColumns.booleanityExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (i : Fin d)
  (rAddress : Point (K := K) m)
  (rCycle : Point (K := K) t) :
  booleanityExpression (K := K) ra i rAddress rCycle = 0 :=
  TwistShout.ValidAddressColumns.booleanityExpression (K := K) hvalid i rAddress rCycle

theorem ValidAddressColumns.hammingWeightExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (i : Fin d)
  (rCycle : Point (K := K) t) :
  hammingWeightExpression (K := K) ra i rCycle = 1 :=
  TwistShout.ValidAddressColumns.hammingWeightExpression (K := K) hvalid i rCycle

theorem ValidAddressColumns.addressValueExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (rCycle : Point (K := K) t) :
  mle (K := K) (addressOracleTable (K := K) addr) rCycle =
    addressValueExpression (K := K) ra rCycle :=
  TwistShout.ValidAddressColumns.addressValueExpression (K := K) hvalid rCycle

end ShoutOneHotInterface

end TwistShout
