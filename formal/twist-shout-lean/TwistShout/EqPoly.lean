import Mathlib

/-!
# EqPoly

Multilinear equality polynomial over the Boolean cube.
-/

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Bit predicate for field elements. -/
def IsBit (x : K) : Prop :=
  x = 0 ∨ x = 1

/-- Pointwise Boolean-cube membership for fixed-length tuples. -/
def IsBitVec {n : Nat} (v : Fin n → K) : Prop :=
  ∀ i, IsBit (v i)

/-- Single-coordinate factor of the multilinear equality polynomial. -/
def eqTerm (x y : K) : K :=
  x * y + (1 - x) * (1 - y)

/-- Multilinear equality polynomial on fixed-length tuples. -/
def eqPoly {n : Nat} (x y : Fin n → K) : K :=
  ∏ i, eqTerm (x i) (y i)

@[simp] theorem isBit_zero :
    IsBit (0 : K) := by
  exact Or.inl rfl

@[simp] theorem isBit_one :
    IsBit (1 : K) := by
  exact Or.inr rfl

open Classical in
theorem eqTerm_eq_delta_of_isBit
    {x y : K}
    (hx : IsBit x)
    (hy : IsBit y) :
    eqTerm x y = (if x = y then 1 else 0) := by
  rcases hx with rfl | rfl <;> rcases hy with rfl | rfl <;> simp [eqTerm]

@[simp] theorem eqPoly_zero
    (x y : Fin 0 → K) :
    eqPoly x y = 1 := by
  simp [eqPoly]

theorem eqPoly_succ
    {n : Nat}
    (x y : Fin (n + 1) → K) :
    eqPoly x y =
      eqTerm (x 0) (y 0) * eqPoly (fun i => x i.succ) (fun i => y i.succ) := by
  simp [eqPoly, Fin.prod_univ_succ]

theorem eqPoly_eq_one_of_eq_of_isBitVec
    {n : Nat}
    {x y : Fin n → K}
    (hxy : x = y)
    (hx : IsBitVec x) :
    eqPoly x y = 1 := by
  subst hxy
  unfold eqPoly
  apply Finset.prod_eq_one
  intro i _
  have hTerm := eqTerm_eq_delta_of_isBit (hx i) (hx i)
  simpa using hTerm

open Classical in
theorem eqPoly_eq_zero_of_ne_of_isBitVec
    {n : Nat}
    {x y : Fin n → K}
    (hxy : x ≠ y)
    (hx : IsBitVec x)
    (hy : IsBitVec y) :
    eqPoly x y = 0 := by
  have hCoord : ∃ i, x i ≠ y i := by
    by_contra hNo
    apply hxy
    funext i
    by_cases hEq : x i = y i
    · exact hEq
    · exfalso
      exact hNo ⟨i, hEq⟩
  rcases hCoord with ⟨i, hi⟩
  unfold eqPoly
  exact Finset.prod_eq_zero_iff.mpr ⟨i, by simp, by
    have hTerm := eqTerm_eq_delta_of_isBit (hx i) (hy i)
    simpa [hi] using hTerm⟩

open Classical in
theorem eqPoly_eq_delta_of_isBitVec
    {n : Nat}
    {x y : Fin n → K}
    (hx : IsBitVec x)
    (hy : IsBitVec y) :
    eqPoly x y = (if x = y then 1 else 0) := by
  by_cases hxy : x = y
  · simpa [hxy] using eqPoly_eq_one_of_eq_of_isBitVec hxy hx
  · simpa [hxy] using eqPoly_eq_zero_of_ne_of_isBitVec hxy hx hy

end

end TwistShout
