import TwistShout.MLE

/-!
# MLEInterface

Thin theorem-facing boundary for multilinear extensions and folding identities.
-/

namespace TwistShout

namespace MLEInterface

abbrev Cube := @TwistShout.Cube
abbrev Point := @TwistShout.Point
abbrev bitToField := @TwistShout.bitToField
abbrev bitVec := @TwistShout.bitVec
abbrev chiWeight := @TwistShout.chiWeight
abbrev mle := @TwistShout.mle
abbrev tailPoint := @TwistShout.tailPoint
abbrev restrictHead := @TwistShout.restrictHead
abbrev foldTable := @TwistShout.foldTable

@[simp] theorem bitToField_false
  {K : Type*} [Field K] :
  bitToField (K := K) false = 0 :=
  TwistShout.bitToField_false

@[simp] theorem bitToField_true
  {K : Type*} [Field K] :
  bitToField (K := K) true = 1 :=
  TwistShout.bitToField_true

theorem bitToField_injective
  {K : Type*} [Field K] :
  Function.Injective (bitToField (K := K)) :=
  TwistShout.bitToField_injective

theorem bitVec_isBitVec
  {K : Type*} [Field K]
  {n : Nat}
  (b : Cube n) :
  IsBitVec (bitVec (K := K) b) :=
  TwistShout.bitVec_isBitVec (K := K) b

theorem bitVec_injective
  {K : Type*} [Field K]
  {n : Nat} :
  Function.Injective (bitVec (K := K) (n := n)) :=
  TwistShout.bitVec_injective (K := K)

theorem chiWeight_at_bitVec
  {K : Type*} [Field K]
  {n : Nat}
  (a b : Cube n) :
  chiWeight (K := K) (bitVec (K := K) a) b = (if a = b then 1 else 0) :=
  TwistShout.chiWeight_at_bitVec (K := K) a b

theorem mle_at_bitVec
  {K : Type*} [Field K]
  {n : Nat}
  (f : Cube n → K)
  (a : Cube n) :
  mle (K := K) f (bitVec (K := K) a) = f a :=
  TwistShout.mle_at_bitVec (K := K) f a

theorem mle_foldTable
  {K : Type*} [Field K]
  {n : Nat}
  (f : Cube (n + 1) → K)
  (r : Point (K := K) (n + 1)) :
  mle (K := K) f r = mle (K := K) (foldTable (K := K) (r 0) f) (tailPoint (K := K) r) :=
  TwistShout.mle_foldTable (K := K) f r

theorem mle_cons
  {K : Type*} [Field K]
  {n : Nat}
  (f : Cube (n + 1) → K)
  (c : K)
  (r : Point (K := K) n) :
  mle (K := K) f (Fin.cons c r) =
    (1 - c) * mle (K := K) (restrictHead (K := K) false f) r +
    c * mle (K := K) (restrictHead (K := K) true f) r :=
  TwistShout.mle_cons (K := K) f c r

theorem mle_const
  {K : Type*} [Field K]
  {n : Nat}
  (c : K)
  (r : Point (K := K) n) :
  mle (K := K) (fun _ : Cube n => c) r = c :=
  TwistShout.mle_const (K := K) c r

theorem mle_chiWeight
  {K : Type*} [Field K]
  {n : Nat}
  (q x : Point (K := K) n) :
  mle (K := K) (fun b : Cube n => chiWeight (K := K) q b) x = eqPoly x q :=
  TwistShout.mle_chiWeight (K := K) q x

theorem sum_chiWeight
  {K : Type*} [Field K]
  {n : Nat}
  (r : Point (K := K) n) :
  ∑ b : Cube n, chiWeight (K := K) r b = 1 :=
  TwistShout.sum_chiWeight (K := K) r

end MLEInterface

end TwistShout
