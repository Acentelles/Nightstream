import TwistShout.LessThanPoly

/-!
# LessThanPolyInterface

Thin theorem-facing boundary for the multilinear less-than polynomial used by Twist.
-/

namespace TwistShout

namespace LessThanPolyInterface

abbrev Cube := @TwistShout.Cube
abbrev Point := @TwistShout.Point
abbrev bitVec := @TwistShout.bitVec
abbrev mle := @TwistShout.mle
abbrev cubeValue := @TwistShout.cubeValue
abbrev ltCube := @TwistShout.ltCube
abbrev ltTable := @TwistShout.ltTable
abbrev ltPoly := @TwistShout.ltPoly
abbrev ltWeight := @TwistShout.ltWeight
abbrev prefixTable := @TwistShout.prefixTable
abbrev prefixExpression := @TwistShout.prefixExpression

theorem ltPoly_at_bitVec
  {K : Type*} [Field K]
  {n : Nat}
  (x y : Cube n) :
  ltPoly (K := K) x (bitVec (K := K) y) = (if ltCube x y then 1 else 0) :=
  TwistShout.ltPoly_at_bitVec (K := K) x y

theorem ltWeight_at_bitVec_left
  {K : Type*} [Field K]
  {n : Nat}
  (x : Cube n)
  (r : Point (K := K) n) :
  ltWeight (K := K) (bitVec (K := K) x) r = ltPoly (K := K) x r :=
  TwistShout.ltWeight_at_bitVec_left (K := K) x r

theorem ltWeight_at_bitVec
  {K : Type*} [Field K]
  {n : Nat}
  (x y : Cube n) :
  ltWeight (K := K) (bitVec (K := K) x) (bitVec (K := K) y) =
    (if ltCube x y then 1 else 0) :=
  TwistShout.ltWeight_at_bitVec (K := K) x y

theorem mle_prefixTable
  {K : Type*} [Field K]
  {n : Nat}
  (f : Cube n → K)
  (r : Point (K := K) n) :
  mle (K := K) (prefixTable (K := K) f) r =
    prefixExpression (K := K) f r :=
  TwistShout.mle_prefixTable (K := K) f r

theorem prefixExpression_at_bitVec
  {K : Type*} [Field K]
  {n : Nat}
  (f : Cube n → K)
  (y : Cube n) :
  prefixExpression (K := K) f (bitVec (K := K) y) =
    prefixTable (K := K) f y :=
  TwistShout.prefixExpression_at_bitVec (K := K) f y

end LessThanPolyInterface

end TwistShout
