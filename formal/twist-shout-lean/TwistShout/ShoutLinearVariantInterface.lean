import TwistShout.ShoutLinearVariant

/-!
# ShoutLinearVariantInterface

Thin theorem-facing boundary for the Appendix C Shout variation.
-/

namespace TwistShout

namespace ShoutLinearVariantInterface

abbrev DigitCube := @TwistShout.DigitCube
abbrev CycleCube := @TwistShout.CycleCube
abbrev CycleTuple := @TwistShout.CycleTuple
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev PublicTable := @TwistShout.PublicTable
abbrev ReadOnlyMemoryRelation := @TwistShout.ReadOnlyMemoryRelation
abbrev cubeOneHot := @TwistShout.cubeOneHot
abbrev bitAddress := @TwistShout.bitAddress
abbrev readOracleTable := @TwistShout.readOracleTable
abbrev readCheckExpression := @TwistShout.readCheckExpression
abbrev tableMLE := @TwistShout.tableMLE
abbrev diagonalCycleTuple := @TwistShout.diagonalCycleTuple
abbrev diagonalEqWeight := @TwistShout.diagonalEqWeight
abbrev linearReadValueAtTuple := @TwistShout.linearReadValueAtTuple
abbrev linearReadCheckExpression := @TwistShout.linearReadCheckExpression
abbrev diagonalEqPointWeight := @TwistShout.diagonalEqPointWeight
abbrev linearReadCheckFinalRoundTarget := @TwistShout.linearReadCheckFinalRoundTarget
abbrev standardShoutRoundCount := @TwistShout.standardShoutRoundCount
abbrev linearVariantRoundCount := @TwistShout.linearVariantRoundCount
abbrev linearVariantEqArrayCost := @TwistShout.linearVariantEqArrayCost
abbrev linearVariantProductCost := @TwistShout.linearVariantProductCost
abbrev linearVariantPrefixRoundCost := @TwistShout.linearVariantPrefixRoundCost
abbrev linearVariantLastRoundCost := @TwistShout.linearVariantLastRoundCost
abbrev linearVariantBaseCost := @TwistShout.linearVariantBaseCost
abbrev linearVariantGruenSaving := @TwistShout.linearVariantGruenSaving
abbrev linearVariantGruenCost := @TwistShout.linearVariantGruenCost
abbrev standardShoutFinalRoundsQuadraticCost := @TwistShout.standardShoutFinalRoundsQuadraticCost

theorem linearReadValueAtTuple_diagonal
  {K : Type*} [Field K]
  {d m t : Nat}
  (ra : AddressColumns (K := K) d m t)
  (val : PublicTable (K := K) d m)
  (j : CycleCube t) :
  linearReadValueAtTuple (K := K) ra val (diagonalCycleTuple (d := d) j) =
    readValueAtCycle (K := K) ra val j :=
  TwistShout.linearReadValueAtTuple_diagonal (K := K) ra val j

theorem diagonalEqWeight_at_diagonalCycleTuple
  {K : Type*} [Field K]
  {d t : Nat} [NeZero d]
  (rCycle : Point (K := K) t)
  (j : CycleCube t) :
  diagonalEqWeight (K := K) rCycle (diagonalCycleTuple (d := d) j) =
    chiWeight (K := K) rCycle j :=
  TwistShout.diagonalEqWeight_at_diagonalCycleTuple (K := K) rCycle j

theorem linearReadCheckExpression_eq_readCheckExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  (ra : AddressColumns (K := K) d m t)
  (val : PublicTable (K := K) d m)
  (rCycle : Point (K := K) t) :
  linearReadCheckExpression (K := K) ra val rCycle =
    readCheckExpression (K := K) ra val rCycle :=
  TwistShout.linearReadCheckExpression_eq_readCheckExpression (K := K) ra val rCycle

theorem ValidAddressColumns.linearReadCheckExpression
  {K : Type*} [Field K]
  {d m t : Nat}
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : PublicTable (K := K) d m)
  (rCycle : Point (K := K) t) :
  linearReadCheckExpression (K := K) ra val rCycle =
    mle (K := K) (readOracleTable (K := K) val addr) rCycle :=
  TwistShout.ValidAddressColumns.linearReadCheckExpression (K := K) hvalid val rCycle

theorem ReadOnlyMemoryRelation.linearReadCheckIdentity
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  {ra : AddressColumns (K := K) d m t}
  (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (rCycle : Point (K := K) t) :
  mle (K := K) rv rCycle = linearReadCheckExpression (K := K) ra val rCycle :=
  TwistShout.ReadOnlyMemoryRelation.linearReadCheckIdentity (K := K) hRel hvalid rCycle

theorem ReadOnlyMemoryRelation.linearReadCheckAtBitCycle
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : PublicTable (K := K) d m}
  {addr : CycleCube t → Address d m}
  {rv : CycleCube t → K}
  {ra : AddressColumns (K := K) d m t}
  (hRel : ReadOnlyMemoryRelation (K := K) val addr rv)
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (j : CycleCube t) :
  rv j = linearReadCheckExpression (K := K) ra val (bitVec (K := K) j) :=
  TwistShout.ReadOnlyMemoryRelation.linearReadCheckAtBitCycle (K := K) hRel hvalid j

theorem diagonalEqPointWeight_at_diagonalBitVec
  {K : Type*} [Field K]
  {d t : Nat} [NeZero d]
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  diagonalEqPointWeight (K := K) queryCycle (fun _ : Fin d => bitVec (K := K) j) =
    chiWeight (K := K) queryCycle j :=
  TwistShout.diagonalEqPointWeight_at_diagonalBitVec (K := K) (d := d) queryCycle j

theorem ValidAddressColumns.linearReadCheckFinalRoundTarget_atDiagonalBooleanPoint
  {K : Type*} [Field K]
  {d m t : Nat} [NeZero d]
  {ra : AddressColumns (K := K) d m t}
  {addr : CycleCube t → Address d m}
  (hvalid : ValidAddressColumns (K := K) ra addr)
  (val : PublicTable (K := K) d m)
  (queryCycle : Point (K := K) t)
  (j : CycleCube t) :
  linearReadCheckFinalRoundTarget (K := K) queryCycle ra val
    (bitAddress (K := K) (addr j))
    (fun _ : Fin d => bitVec (K := K) j) =
    chiWeight (K := K) queryCycle j * val (addr j) :=
  TwistShout.ValidAddressColumns.linearReadCheckFinalRoundTarget_atDiagonalBooleanPoint
    (K := K) hvalid val queryCycle j

theorem linearVariantRoundCount_eq_mul
  (d m t : Nat) :
  linearVariantRoundCount d m t = d * (m + t) :=
  TwistShout.linearVariantRoundCount_eq_mul d m t

theorem linearVariantRoundCount_eq_standardPlus
  {d m t : Nat} [NeZero d] :
  linearVariantRoundCount d m t =
    standardShoutRoundCount d m t + (d - 1) * t :=
  TwistShout.linearVariantRoundCount_eq_standardPlus

theorem linearVariantBaseCost_eq_sum
  (d t : Nat) :
  linearVariantBaseCost d t =
    linearVariantEqArrayCost t +
      linearVariantProductCost d t +
      linearVariantPrefixRoundCost d t +
      linearVariantLastRoundCost t :=
  TwistShout.linearVariantBaseCost_eq_sum d t

theorem linearVariantGruenCost_eq_base_minus_saving
  (d t : Nat) :
  linearVariantGruenCost d t =
    linearVariantBaseCost d t - linearVariantGruenSaving t :=
  TwistShout.linearVariantGruenCost_eq_base_minus_saving d t

theorem linearVariantGruenCost_le_standardQuadratic
  {d t : Nat}
  (hd : 8 ≤ d) :
  linearVariantGruenCost d t ≤ standardShoutFinalRoundsQuadraticCost d t :=
  TwistShout.linearVariantGruenCost_le_standardQuadratic hd

end ShoutLinearVariantInterface

end TwistShout
