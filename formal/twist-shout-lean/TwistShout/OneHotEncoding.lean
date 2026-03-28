import TwistShout.EqPoly

/-!
# OneHotEncoding

Plain and `d`-dimensional one-hot encodings for paper-level address representations.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*}

/-- Tuple-valued address digits for a `d`-dimensional address of side length `n`. -/
abbrev AddressDigits (d n : Nat) := Fin d → Fin n

private def indicator {α : Type*} [DecidableEq α] [Zero K] [One K] (a : α) : α → K :=
  fun x => if x = a then 1 else 0

/-- Plain one-hot encoding of an address in `[n]`. -/
def oneHot {n : Nat} [Zero K] [One K] (z : Fin n) : Fin n → K :=
  indicator (K := K) z

/-- One-hot encoding of a tuple-valued address in `[n]^d`. -/
def tupleOneHot {d n : Nat} [Zero K] [One K] (z : AddressDigits d n) :
    AddressDigits d n → K :=
  indicator (K := K) z

/-- `d`-dimensional one-hot factor vectors for a tuple-valued address. -/
def dOneHot {d n : Nat} [Zero K] [One K] (z : AddressDigits d n) :
    Fin d → Fin n → K :=
  fun i => oneHot (K := K) (z i)

/-- Product of per-digit one-hot factors at a tuple index. -/
def productEncoding {d n : Nat} [CommMonoidWithZero K] (v : Fin d → Fin n → K)
    (k : AddressDigits d n) : K :=
  ∏ i, v i (k i)

/-- A vector is a valid one-hot encoding of some address in `[n]`. -/
def IsOneHotEncoding {n : Nat} [Zero K] [One K] (v : Fin n → K) : Prop :=
  ∃ z : Fin n, v = oneHot (K := K) z

/-- A family of vectors is a valid `d`-dimensional one-hot encoding of some address in `[n]^d`. -/
def IsDOneHotEncoding {d n : Nat} [Zero K] [One K] (v : Fin d → Fin n → K) : Prop :=
  ∃ z : AddressDigits d n, v = dOneHot (K := K) z

@[simp] theorem oneHot_apply
    {n : Nat} [Zero K] [One K]
    (z k : Fin n) :
    oneHot (K := K) z k = if k = z then 1 else 0 := rfl

@[simp] theorem tupleOneHot_apply
    {d n : Nat} [Zero K] [One K]
    (z k : AddressDigits d n) :
    tupleOneHot (K := K) z k = if k = z then 1 else 0 := rfl

@[simp] theorem dOneHot_apply
    {d n : Nat} [Zero K] [One K]
    (z : AddressDigits d n)
    (i : Fin d)
    (k : Fin n) :
    dOneHot (K := K) z i k = oneHot (K := K) (z i) k := rfl

@[simp] theorem oneHot_self
    {n : Nat} [Zero K] [One K]
    (z : Fin n) :
    oneHot (K := K) z z = 1 := by
  simp [oneHot, indicator]

@[simp] theorem tupleOneHot_self
    {d n : Nat} [Zero K] [One K]
    (z : AddressDigits d n) :
    tupleOneHot (K := K) z z = 1 := by
  simp [tupleOneHot, indicator]

theorem oneHot_eq_zero_of_ne
    {n : Nat} [Zero K] [One K]
    {z k : Fin n}
    (hzk : k ≠ z) :
    oneHot (K := K) z k = 0 := by
  have hkz : ¬ k = z := hzk
  simp [oneHot, indicator, hkz]

theorem tupleOneHot_eq_zero_of_ne
    {d n : Nat} [Zero K] [One K]
    {z k : AddressDigits d n}
    (hzk : k ≠ z) :
    tupleOneHot (K := K) z k = 0 := by
  have hkz : ¬ k = z := hzk
  simp [tupleOneHot, indicator, hkz]

private theorem sum_indicator
    {α : Type*} [Fintype α] [DecidableEq α] [CommSemiring K]
    (a : α) :
    ∑ x, indicator (K := K) a x = 1 := by
  classical
  rw [Finset.sum_eq_single a]
  · simp [indicator]
  · intro x _ hxa
    simp [indicator, hxa]
  · simp [indicator]

private theorem indicator_injective
    {α : Type*} [DecidableEq α] [Semiring K] [Nontrivial K] :
    Function.Injective (indicator (K := K) (α := α)) := by
  intro a b hab
  by_contra hne
  have hval := congrArg (fun v => v a) hab
  simp [indicator, hne] at hval

theorem sum_oneHot
    {n : Nat} [CommSemiring K]
    (z : Fin n) :
    ∑ k, oneHot (K := K) z k = 1 := by
  simpa [oneHot] using sum_indicator (K := K) z

theorem sum_tupleOneHot
    {d n : Nat} [CommSemiring K]
    (z : AddressDigits d n) :
    ∑ k, tupleOneHot (K := K) z k = 1 := by
  simpa [tupleOneHot] using sum_indicator (K := K) z

theorem dOneHot_sum
    {d n : Nat} [CommSemiring K]
    (z : AddressDigits d n)
    (i : Fin d) :
    ∑ k, dOneHot (K := K) z i k = 1 := by
  change ∑ k, oneHot (K := K) (z i) k = 1
  exact sum_oneHot (K := K) (z := z i)

theorem oneHot_injective
    {n : Nat} [Semiring K] [Nontrivial K] :
    Function.Injective (oneHot (K := K) (n := n)) :=
  indicator_injective (K := K)

theorem tupleOneHot_injective
    {d n : Nat} [Semiring K] [Nontrivial K] :
    Function.Injective (tupleOneHot (K := K) (d := d) (n := n)) :=
  indicator_injective (K := K)

theorem productEncoding_dOneHot
    {d n : Nat} [CommSemiring K]
    (z k : AddressDigits d n) :
    productEncoding (K := K) (dOneHot (K := K) z) k =
      tupleOneHot (K := K) z k := by
  by_cases hkz : k = z
  · subst hkz
    simp [productEncoding, dOneHot, tupleOneHot, oneHot, indicator]
  · have hcoord : ∃ i, k i ≠ z i := by
      by_contra hNo
      apply hkz
      funext i
      by_contra hi
      exact hNo ⟨i, hi⟩
    rcases hcoord with ⟨i, hi⟩
    have hprod :
        productEncoding (K := K) (dOneHot (K := K) z) k = 0 := by
      unfold productEncoding dOneHot oneHot indicator
      show ∏ j ∈ Finset.univ, (if k j = z j then 1 else 0 : K) = 0
      exact Finset.prod_eq_zero (s := Finset.univ)
        (i := i) (f := fun j => (if k j = z j then 1 else 0 : K))
        (by simp) (by simp [hi])
    rw [hprod]
    simp [tupleOneHot, indicator, hkz]

open Classical in
theorem productEncoding_eq_delta
    {d n : Nat} [CommSemiring K]
    (z k : AddressDigits d n) :
    productEncoding (K := K) (dOneHot (K := K) z) k =
      (if k = z then 1 else 0) := by
  rw [productEncoding_dOneHot]
  simp [tupleOneHot, indicator]

theorem productEncoding_eq_one_of_eq
    {d n : Nat} [CommSemiring K]
    {z k : AddressDigits d n}
    (hzk : k = z) :
    productEncoding (K := K) (dOneHot (K := K) z) k = 1 := by
  simpa [hzk] using productEncoding_eq_delta (K := K) z k

theorem productEncoding_eq_zero_of_ne
    {d n : Nat} [CommSemiring K]
    {z k : AddressDigits d n}
    (hzk : k ≠ z) :
    productEncoding (K := K) (dOneHot (K := K) z) k = 0 := by
  simpa [hzk] using productEncoding_eq_delta (K := K) z k

theorem oneHot_isBitVec
    {n : Nat} [Field K]
    (z : Fin n) :
    IsBitVec (oneHot (K := K) z) := by
  intro k
  by_cases hkz : k = z
  · simp [oneHot, indicator, IsBit, hkz]
  · simp [oneHot, indicator, IsBit, hkz]

theorem dOneHot_isBitVec
    {d n : Nat} [Field K]
    (z : AddressDigits d n)
    (i : Fin d) :
    IsBitVec (dOneHot (K := K) z i) := by
  simpa [dOneHot] using oneHot_isBitVec (K := K) (z := z i)

theorem IsOneHotEncoding.isBitVec
    {n : Nat} [Field K]
    {v : Fin n → K}
    (hv : IsOneHotEncoding (K := K) v) :
    IsBitVec v := by
  rcases hv with ⟨z, rfl⟩
  exact oneHot_isBitVec (K := K) z

theorem IsOneHotEncoding.sum_eq_one
    {n : Nat} [Field K]
    {v : Fin n → K}
    (hv : IsOneHotEncoding (K := K) v) :
    ∑ k, v k = 1 := by
  rcases hv with ⟨z, rfl⟩
  exact sum_oneHot (K := K) z

theorem IsDOneHotEncoding.coord_isBitVec
    {d n : Nat} [Field K]
    {v : Fin d → Fin n → K}
    (hv : IsDOneHotEncoding (K := K) v)
    (i : Fin d) :
    IsBitVec (v i) := by
  rcases hv with ⟨z, rfl⟩
  exact dOneHot_isBitVec (K := K) z i

theorem IsDOneHotEncoding.coord_sum_eq_one
    {d n : Nat} [Field K]
    {v : Fin d → Fin n → K}
    (hv : IsDOneHotEncoding (K := K) v)
    (i : Fin d) :
    ∑ k, v i k = 1 := by
  rcases hv with ⟨z, rfl⟩
  exact dOneHot_sum (K := K) z i

theorem IsDOneHotEncoding.product_eq_tupleOneHot
    {d n : Nat} [Field K]
    {v : Fin d → Fin n → K}
    (hv : IsDOneHotEncoding (K := K) v) :
    ∃ z : AddressDigits d n,
      ∀ k, productEncoding (K := K) v k = tupleOneHot (K := K) z k := by
  rcases hv with ⟨z, rfl⟩
  exact ⟨z, productEncoding_dOneHot (K := K) z⟩

theorem dOneHot_unique
    {d n : Nat} [Field K]
    {v : Fin d → Fin n → K}
    {z : AddressDigits d n}
    (hv : IsDOneHotEncoding (K := K) v)
    (hprod : ∀ k, productEncoding (K := K) v k = tupleOneHot (K := K) z k) :
    v = dOneHot (K := K) z := by
  rcases hv with ⟨z', rfl⟩
  have htuple : tupleOneHot (K := K) z' = tupleOneHot (K := K) z := by
    funext k
    rw [← productEncoding_dOneHot (K := K) z' k]
    exact hprod k
  have hz : z' = z := tupleOneHot_injective (K := K) htuple
  subst hz
  rfl

end

end TwistShout
