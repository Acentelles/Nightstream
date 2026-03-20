import TwistShout.EqPoly

/-!
# MLE

Multilinear extensions over the Boolean cube.
-/

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Boolean cube of dimension `n`. -/
abbrev Cube (n : Nat) := Fin n → Bool

/-- Field-valued points of dimension `n`. -/
abbrev Point (n : Nat) := Fin n → K

/-- Boolean bit embedded in the ambient field. -/
def bitToField : Bool → K
  | false => 0
  | true => 1

@[simp] theorem bitToField_false :
    bitToField (K := K) false = 0 := rfl

@[simp] theorem bitToField_true :
    bitToField (K := K) true = 1 := rfl

theorem bitToField_injective :
    Function.Injective (bitToField (K := K)) := by
  intro b c h
  cases b <;> cases c <;> simp [bitToField] at h ⊢

/-- Boolean cube embedded as a field-valued bit vector. -/
def bitVec {n : Nat} (b : Cube n) : Point (K := K) n :=
  fun i => bitToField (K := K) (b i)

@[simp] theorem bitVec_apply
    {n : Nat}
    (b : Cube n)
    (i : Fin n) :
    bitVec (K := K) b i = bitToField (K := K) (b i) := rfl

theorem bitVec_isBitVec
    {n : Nat}
    (b : Cube n) :
    IsBitVec (bitVec (K := K) b) := by
  intro i
  cases h : b i <;> simp [bitVec, IsBit, bitToField, h]

theorem bitVec_injective
    {n : Nat} :
    Function.Injective (bitVec (K := K) (n := n)) := by
  intro a b h
  funext i
  apply bitToField_injective (K := K)
  exact congrArg (fun v => v i) h

/-- Basis weight `eq~(r, b)` for the Boolean cube point `b`. -/
def chiWeight {n : Nat} (r : Point (K := K) n) (b : Cube n) : K :=
  eqPoly r (bitVec (K := K) b)

/-- Multilinear extension of a Boolean-cube table. -/
def mle {n : Nat} (f : Cube n → K) (r : Point (K := K) n) : K :=
  ∑ b, f b * chiWeight r b

/-- Tail of a field-valued point in `n + 1` variables. -/
def tailPoint {n : Nat} (r : Point (K := K) (n + 1)) : Point (K := K) n :=
  fun i => r i.succ

/-- Restriction of a Boolean-cube table to a fixed head bit. -/
def restrictHead {n : Nat} (head : Bool) (f : Cube (n + 1) → K) : Cube n → K :=
  fun tail => f (Fin.cons head tail)

/-- Fold the first variable to a field challenge `c`. -/
def foldTable {n : Nat} (c : K) (f : Cube (n + 1) → K) : Cube n → K :=
  fun tail =>
    (1 - c) * restrictHead false f tail + c * restrictHead true f tail

/-- Decompose the Boolean cube in `n + 1` variables into its head bit and tail. -/
def cubeSuccEquiv (n : Nat) : Cube (n + 1) ≃ Bool × Cube n where
  toFun b := (b 0, fun i => b i.succ)
  invFun p := Fin.cons p.1 p.2
  left_inv b := by
    funext i
    refine Fin.cases ?_ ?_ i
    · rfl
    · intro j
      rfl
  right_inv p := by
    cases p
    rfl

omit [Field K] in
@[simp] theorem tailPoint_cons
    {n : Nat}
    (c : K)
    (r : Point (K := K) n) :
    tailPoint (K := K) (Fin.cons c r) = r := by
  funext i
  rfl

omit [Field K] in
@[simp] theorem restrictHead_apply
    {n : Nat}
    (head : Bool)
    (f : Cube (n + 1) → K)
    (tail : Cube n) :
    restrictHead head f tail = f (Fin.cons head tail) := rfl

@[simp] theorem foldTable_apply
    {n : Nat}
    (c : K)
    (f : Cube (n + 1) → K)
    (tail : Cube n) :
    foldTable c f tail =
      (1 - c) * f (Fin.cons false tail) + c * f (Fin.cons true tail) := rfl

@[simp] theorem chiWeight_zero
    (r : Point (K := K) 0)
    (b : Cube 0) :
    chiWeight r b = 1 := by
  unfold chiWeight
  simp [eqPoly_zero]

theorem chiWeight_cons_false
    {n : Nat}
    (r : Point (K := K) (n + 1))
    (b : Cube n) :
    chiWeight r (Fin.cons false b) =
      (1 - r 0) * chiWeight (tailPoint (K := K) r) b := by
  unfold chiWeight tailPoint bitVec
  rw [eqPoly_succ]
  simp [eqTerm, bitToField]

theorem chiWeight_cons_true
    {n : Nat}
    (r : Point (K := K) (n + 1))
    (b : Cube n) :
    chiWeight r (Fin.cons true b) =
      r 0 * chiWeight (tailPoint (K := K) r) b := by
  unfold chiWeight tailPoint bitVec
  rw [eqPoly_succ]
  simp [eqTerm, bitToField]

open Classical in
theorem chiWeight_at_bitVec
    {n : Nat}
    (a b : Cube n) :
    chiWeight (bitVec (K := K) a) b = (if a = b then 1 else 0) := by
  unfold chiWeight
  have hDelta :=
    eqPoly_eq_delta_of_isBitVec
      (K := K)
      (x := bitVec (K := K) a)
      (y := bitVec (K := K) b)
      (bitVec_isBitVec (K := K) a)
      (bitVec_isBitVec (K := K) b)
  have hEq : bitVec (K := K) a = bitVec (K := K) b ↔ a = b := by
    constructor
    · intro hab
      exact bitVec_injective (K := K) hab
    · intro hab
      simp [hab]
  simpa [hEq] using hDelta

open Classical in
theorem mle_at_bitVec
    {n : Nat}
    (f : Cube n → K)
    (a : Cube n) :
    mle (K := K) f (bitVec (K := K) a) = f a := by
  unfold mle
  rw [Finset.sum_eq_single a]
  · simp [chiWeight_at_bitVec]
  · intro b _ hba
    have hab : a ≠ b := by
      intro habEq
      exact hba habEq.symm
    simp [chiWeight_at_bitVec, hab]
  · simp

theorem mle_foldTable_linear
    {n : Nat}
    (c : K)
    (f : Cube (n + 1) → K)
    (r : Point (K := K) n) :
    mle (K := K) (foldTable c f) r =
      (1 - c) * mle (K := K) (restrictHead false f) r +
      c * mle (K := K) (restrictHead true f) r := by
  unfold mle foldTable restrictHead
  calc
    ∑ tail, (((1 - c) * f (Fin.cons false tail) + c * f (Fin.cons true tail)) * chiWeight r tail)
        =
      ∑ tail, ((1 - c) * (f (Fin.cons false tail) * chiWeight r tail) +
        c * (f (Fin.cons true tail) * chiWeight r tail)) := by
          apply Finset.sum_congr rfl
          intro tail _
          ring
    _ =
      (∑ tail, (1 - c) * (f (Fin.cons false tail) * chiWeight r tail)) +
      ∑ tail, c * (f (Fin.cons true tail) * chiWeight r tail) := by
        rw [Finset.sum_add_distrib]
    _ =
      (1 - c) * ∑ tail, f (Fin.cons false tail) * chiWeight r tail +
      c * ∑ tail, f (Fin.cons true tail) * chiWeight r tail := by
        rw [Finset.mul_sum, Finset.mul_sum]

theorem mle_foldTable
    {n : Nat}
    (f : Cube (n + 1) → K)
    (r : Point (K := K) (n + 1)) :
    mle (K := K) f r = mle (K := K) (foldTable (r 0) f) (tailPoint (K := K) r) := by
  unfold mle foldTable restrictHead tailPoint
  let g : Bool × Cube n → K :=
    fun p => f (Fin.cons p.1 p.2) * chiWeight r (Fin.cons p.1 p.2)
  have hSplit :
      (∑ b : Cube (n + 1), f b * chiWeight r b) =
        ∑ p : Bool × Cube n, g p := by
    refine Fintype.sum_equiv (cubeSuccEquiv n) (fun b => f b * chiWeight r b) g ?_
    intro b
    have hb : Fin.cons (b 0) (fun i => b i.succ) = b := (cubeSuccEquiv n).left_inv b
    change f b * chiWeight r b =
      f (Fin.cons (b 0) (fun i => b i.succ)) * chiWeight r (Fin.cons (b 0) (fun i => b i.succ))
    simp [hb]
  rw [hSplit]
  rw [show (∑ p : Bool × Cube n, g p) = ∑ tail, ∑ head : Bool, g (head, tail) by
    simpa using (Fintype.sum_prod_type_right' (fun head tail => g (head, tail)))]
  apply Finset.sum_congr rfl
  intro tail _
  dsimp [g]
  simp [chiWeight_cons_true, chiWeight_cons_false]
  have hTail :
      chiWeight (K := K) (tailPoint (K := K) r) tail =
        chiWeight (K := K) (fun i => r i.succ) tail := rfl
  simp_rw [hTail]
  ring_nf

theorem mle_cons
    {n : Nat}
    (f : Cube (n + 1) → K)
    (c : K)
    (r : Point (K := K) n) :
    mle (K := K) f (Fin.cons c r) =
      (1 - c) * mle (K := K) (restrictHead false f) r +
      c * mle (K := K) (restrictHead true f) r := by
  rw [mle_foldTable (K := K) (f := f) (r := Fin.cons c r), tailPoint_cons]
  exact mle_foldTable_linear (K := K) c f r

theorem mle_const
    {n : Nat}
    (c : K)
    (r : Point (K := K) n) :
    mle (K := K) (fun _ : Cube n => c) r = c := by
  induction n with
  | zero =>
      simp [mle, chiWeight_zero]
  | succ n ih =>
      have hr : Fin.cons (r 0) (tailPoint (K := K) r) = r := by
        funext i
        refine Fin.cases ?_ ?_ i
        · rfl
        · intro j
          rfl
      rw [← hr]
      rw [mle_cons (K := K) (f := fun _ : Cube (n + 1) => c) (c := r 0)
        (r := tailPoint (K := K) r)]
      have hFalse : restrictHead false (fun _ : Cube (n + 1) => c) = fun _ : Cube n => c := rfl
      have hTrue : restrictHead true (fun _ : Cube (n + 1) => c) = fun _ : Cube n => c := rfl
      have ihTail : mle (K := K) (fun _ : Cube n => c) (tailPoint (K := K) r) = c :=
        ih (tailPoint (K := K) r)
      rw [hFalse, hTrue]
      simp [ihTail]
      ring_nf

theorem mle_chiWeight
    {n : Nat}
    (q x : Point (K := K) n) :
    mle (K := K) (fun b : Cube n => chiWeight (K := K) q b) x = eqPoly x q := by
  induction n with
  | zero =>
      simp [mle, chiWeight_zero, eqPoly_zero]
  | succ n ih =>
      have hx :
          Fin.cons (x 0) (tailPoint (K := K) x) = x := by
        funext i
        refine Fin.cases ?_ ?_ i
        · rfl
        · intro j
          rfl
      rw [← hx]
      rw [mle_cons (K := K)
        (f := fun b : Cube (n + 1) => chiWeight (K := K) q b)
        (c := x 0) (r := tailPoint (K := K) x)]
      have hFalse :
          restrictHead (K := K) false
            (fun b : Cube (n + 1) => chiWeight (K := K) q b) =
            fun tail : Cube n =>
              (1 - q 0) * chiWeight (K := K) (tailPoint (K := K) q) tail := by
        funext tail
        rw [restrictHead_apply, chiWeight_cons_false]
      have hTrue :
          restrictHead (K := K) true
            (fun b : Cube (n + 1) => chiWeight (K := K) q b) =
            fun tail : Cube n =>
              q 0 * chiWeight (K := K) (tailPoint (K := K) q) tail := by
        funext tail
        rw [restrictHead_apply, chiWeight_cons_true]
      rw [hFalse, hTrue]
      have hFalseEval :
          mle (K := K)
            (fun tail : Cube n =>
              (1 - q 0) * chiWeight (K := K) (tailPoint (K := K) q) tail)
            (tailPoint (K := K) x) =
            (1 - q 0) * eqPoly (tailPoint (K := K) x) (tailPoint (K := K) q) := by
        unfold mle
        calc
          ∑ tail : Cube n,
              ((1 - q 0) * chiWeight (K := K) (tailPoint (K := K) q) tail) *
                chiWeight (K := K) (tailPoint (K := K) x) tail
            = ∑ tail : Cube n,
                (1 - q 0) *
                  (chiWeight (K := K) (tailPoint (K := K) q) tail *
                    chiWeight (K := K) (tailPoint (K := K) x) tail) := by
                      apply Finset.sum_congr rfl
                      intro tail _
                      ring
          _ = (1 - q 0) *
                ∑ tail : Cube n,
                  chiWeight (K := K) (tailPoint (K := K) q) tail *
                    chiWeight (K := K) (tailPoint (K := K) x) tail := by
                      rw [Finset.mul_sum]
          _ = (1 - q 0) * eqPoly (tailPoint (K := K) x) (tailPoint (K := K) q) := by
                      rw [← ih (tailPoint (K := K) q) (tailPoint (K := K) x)]
                      rfl
      have hTrueEval :
          mle (K := K)
            (fun tail : Cube n =>
              q 0 * chiWeight (K := K) (tailPoint (K := K) q) tail)
            (tailPoint (K := K) x) =
            q 0 * eqPoly (tailPoint (K := K) x) (tailPoint (K := K) q) := by
        unfold mle
        calc
          ∑ tail : Cube n,
              (q 0 * chiWeight (K := K) (tailPoint (K := K) q) tail) *
                chiWeight (K := K) (tailPoint (K := K) x) tail
            = ∑ tail : Cube n,
                q 0 *
                  (chiWeight (K := K) (tailPoint (K := K) q) tail *
                    chiWeight (K := K) (tailPoint (K := K) x) tail) := by
                      apply Finset.sum_congr rfl
                      intro tail _
                      ring
          _ = q 0 *
                ∑ tail : Cube n,
                  chiWeight (K := K) (tailPoint (K := K) q) tail *
                    chiWeight (K := K) (tailPoint (K := K) x) tail := by
                      rw [Finset.mul_sum]
          _ = q 0 * eqPoly (tailPoint (K := K) x) (tailPoint (K := K) q) := by
                      rw [← ih (tailPoint (K := K) q) (tailPoint (K := K) x)]
                      rfl
      rw [hFalseEval, hTrueEval]
      rw [eqPoly_succ]
      change
        (1 - x 0) * ((1 - q 0) * eqPoly (tailPoint (K := K) x) (tailPoint (K := K) q)) +
            x 0 * (q 0 * eqPoly (tailPoint (K := K) x) (tailPoint (K := K) q)) =
          eqTerm (x 0) (q 0) * eqPoly (tailPoint (K := K) x) (tailPoint (K := K) q)
      simp [eqTerm]
      ring_nf

theorem sum_chiWeight
    {n : Nat}
    (r : Point (K := K) n) :
    ∑ b : Cube n, chiWeight (K := K) r b = 1 := by
  calc
    ∑ b : Cube n, chiWeight (K := K) r b
      = mle (K := K) (fun _ : Cube n => (1 : K)) r := by
          simp [mle]
    _ = 1 := mle_const (K := K) 1 r

end

end TwistShout
