import TwistShout.MLE

/-!
# LessThanPoly

Multilinear less-than polynomial used by Twist's time-prefix reasoning.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Interpret a Boolean cube point as a natural number, with index `0` as the low-order bit. -/
def cubeValue {n : Nat} (b : Cube n) : Nat :=
  ∑ i : Fin n, if b i then 2 ^ i.1 else 0

/-- Boolean strict less-than on time indices. -/
def ltCube {n : Nat} (x y : Cube n) : Prop :=
  cubeValue x < cubeValue y

instance ltCubeDecidable {n : Nat} (x y : Cube n) : Decidable (ltCube x y) := by
  unfold ltCube
  infer_instance

/-- Truth table of the Boolean less-than predicate for a fixed left input. -/
def ltTable {n : Nat} (x : Cube n) : Cube n → K :=
  fun y => if ltCube x y then 1 else 0

/-- `\widetilde{LT}(x, r)`: multilinear extension of the Boolean less-than predicate in `r`. -/
def ltPoly {n : Nat} (x : Cube n) (r : Point (K := K) n) : K :=
  mle (K := K) (ltTable (K := K) x) r

/-- Multilinear extension of `x ↦ \widetilde{LT}(x, r)` in the left argument. -/
def ltWeight {n : Nat} (x : Point (K := K) n) (r : Point (K := K) n) : K :=
  mle (K := K) (fun b : Cube n => ltPoly (K := K) b r) x

/-- Boolean strict-prefix sum table `Σ_{x < y} f(x)`. -/
def prefixTable {n : Nat} (f : Cube n → K) : Cube n → K :=
  fun y => ∑ x : Cube n, if ltCube x y then f x else 0

/-- Formal multilinear expression `Σ_x f(x) * \widetilde{LT}(x, r)`. -/
def prefixExpression {n : Nat} (f : Cube n → K) (r : Point (K := K) n) : K :=
  ∑ x : Cube n, f x * ltPoly (K := K) x r

theorem ltPoly_at_bitVec
    {n : Nat}
    (x y : Cube n) :
    ltPoly (K := K) x (bitVec (K := K) y) = (if ltCube x y then 1 else 0) := by
  unfold ltPoly ltTable
  simpa using
    (mle_at_bitVec (K := K)
      (f := fun z : Cube n => if ltCube x z then 1 else 0)
      (a := y))

theorem ltWeight_at_bitVec_left
    {n : Nat}
    (x : Cube n)
    (r : Point (K := K) n) :
    ltWeight (K := K) (bitVec (K := K) x) r = ltPoly (K := K) x r := by
  unfold ltWeight
  exact mle_at_bitVec (K := K)
    (f := fun b : Cube n => ltPoly (K := K) b r)
    x

theorem ltWeight_at_bitVec
    {n : Nat}
    (x y : Cube n) :
    ltWeight (K := K) (bitVec (K := K) x) (bitVec (K := K) y) =
      (if ltCube x y then 1 else 0) := by
  rw [ltWeight_at_bitVec_left (K := K) x (bitVec (K := K) y)]
  exact ltPoly_at_bitVec (K := K) x y

theorem mle_prefixTable
    {n : Nat}
    (f : Cube n → K)
    (r : Point (K := K) n) :
    mle (K := K) (prefixTable (K := K) f) r =
      prefixExpression (K := K) f r := by
  unfold mle prefixTable prefixExpression ltPoly ltTable
  calc
    ∑ y : Cube n, (∑ x : Cube n, if ltCube x y then f x else 0) * chiWeight (K := K) r y
      = ∑ y : Cube n, ∑ x : Cube n, (if ltCube x y then f x else 0) * chiWeight (K := K) r y := by
          apply Finset.sum_congr rfl
          intro y _
          rw [Finset.sum_mul]
    _ = ∑ x : Cube n, ∑ y : Cube n, (if ltCube x y then f x else 0) * chiWeight (K := K) r y := by
          rw [Finset.sum_comm]
    _ = ∑ x : Cube n, f x *
          ∑ y : Cube n, (if ltCube x y then (1 : K) else 0) * chiWeight (K := K) r y := by
          apply Finset.sum_congr rfl
          intro x _
          calc
            ∑ y : Cube n, (if ltCube x y then f x else 0) * chiWeight (K := K) r y
              = ∑ y : Cube n,
                  f x * ((if ltCube x y then (1 : K) else 0) * chiWeight (K := K) r y) := by
                    apply Finset.sum_congr rfl
                    intro y _
                    by_cases hxy : ltCube x y <;> simp [hxy]
            _ = f x * ∑ y : Cube n,
                  (if ltCube x y then (1 : K) else 0) * chiWeight (K := K) r y := by
                    rw [Finset.mul_sum]
    _ = ∑ x : Cube n, f x * mle (K := K) (fun y : Cube n => if ltCube x y then 1 else 0) r := by
          simp [mle]
    _ = prefixExpression (K := K) f r := by
          rfl

theorem prefixExpression_at_bitVec
    {n : Nat}
    (f : Cube n → K)
    (y : Cube n) :
    prefixExpression (K := K) f (bitVec (K := K) y) =
      prefixTable (K := K) f y := by
  rw [← mle_prefixTable (K := K) (f := f) (r := bitVec (K := K) y)]
  exact mle_at_bitVec (K := K) (prefixTable (K := K) f) y

end

end TwistShout
