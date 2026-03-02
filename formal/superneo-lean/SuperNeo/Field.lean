import SuperNeo.Goldilocks

namespace SuperNeo

/-- Base field carrier for SuperNeo (`F_q`). -/
abbrev F : Type := Fin Goldilocks.q

namespace F

instance : Inhabited F := ⟨⟨0, Goldilocks.q_pos⟩⟩

def ofNat (n : Nat) : F :=
  ⟨n % Goldilocks.q, Nat.mod_lt _ Goldilocks.q_pos⟩

def zero : F := ofNat 0
def one : F := ofNat 1

instance : Zero F := ⟨zero⟩
instance : One F := ⟨one⟩

def pow (a : F) (n : Nat) : F :=
  Id.run do
    let mut acc : F := 1
    let mut base := a
    let mut exp := n
    while exp > 0 do
      if exp % 2 = 1 then
        acc := acc * base
      base := base * base
      exp := exp / 2
    return acc

def inv (a : F) : F :=
  if a.val = 0 then
    0
  else
    pow a (Goldilocks.q - 2)

/-- Canonical representative in `[0, q)`. -/
def canonicalRep (a : F) : Nat := a.val

/-- Canonicality predicate (always true for the `Fin` encoding). -/
def isCanonical (a : F) : Prop := canonicalRep a < Goldilocks.q

instance (a : F) : Decidable (isCanonical a) := by
  unfold isCanonical canonicalRep
  infer_instance

theorem canonical (a : F) : isCanonical a :=
  a.isLt

def canonicalCheck (a : F) : Bool :=
  decide (isCanonical a)

theorem canonicalCheck_true (a : F) : canonicalCheck a = true := by
  unfold canonicalCheck
  exact decide_eq_true (canonical a)

/-- Centered integer representative in `[-q/2, q/2]` shape. -/
def centeredRep (a : F) : Int :=
  if _h : a.val ≤ Goldilocks.halfQ then
    Int.ofNat a.val
  else
    Int.ofNat a.val - Int.ofNat Goldilocks.q

def centeredAbs (a : F) : Nat :=
  Int.natAbs (centeredRep a)

theorem centeredRep_eq_of_le_halfQ {a : F} (h : a.val ≤ Goldilocks.halfQ) :
    centeredRep a = Int.ofNat a.val := by
  simp [centeredRep, h]

theorem centeredRep_eq_sub_q_of_halfQ_lt {a : F} (h : Goldilocks.halfQ < a.val) :
    centeredRep a = Int.ofNat a.val - Int.ofNat Goldilocks.q := by
  have hNot : ¬ a.val ≤ Goldilocks.halfQ := Nat.not_le_of_lt h
  simp [centeredRep, hNot]

@[simp] theorem ofNat_zero : ofNat 0 = (0 : F) := rfl

@[simp] theorem ofNat_one : ofNat 1 = (1 : F) := rfl

@[simp] theorem val_zero : (0 : F).val = 0 := by
  change 0 % Goldilocks.q = 0
  exact Nat.mod_eq_of_lt Goldilocks.q_pos

@[simp] theorem val_one : (1 : F).val = 1 := by
  change 1 % Goldilocks.q = 1
  exact Nat.mod_eq_of_lt Goldilocks.q_gt_one

@[simp] theorem ofNat_val (a : F) : ofNat a.val = a := by
  apply Fin.ext
  simp [ofNat, Nat.mod_eq_of_lt a.isLt]

@[simp] theorem canonicalRep_ofNat (n : Nat) :
    canonicalRep (ofNat n) = n % Goldilocks.q := rfl

@[simp] theorem val_lt_q (a : F) : a.val < Goldilocks.q :=
  a.isLt

@[simp] theorem canonicalRep_eq_val (a : F) :
    canonicalRep a = a.val := rfl

theorem ofNat_canonicalRep (a : F) :
    ofNat (canonicalRep a) = a := by
  simp [canonicalRep]

theorem ofNat_val_eq_of_canonical
    {n : Nat}
    (h : n < Goldilocks.q) :
    (ofNat n).val = n := by
  simp [ofNat, Nat.mod_eq_of_lt h]

theorem canonicalRep_ofNat_eq_of_lt
    {n : Nat}
    (h : n < Goldilocks.q) :
    canonicalRep (ofNat n) = n := by
  simpa [canonicalRep] using ofNat_val_eq_of_canonical h

@[simp] theorem isCanonical_true (a : F) :
    isCanonical a := canonical a

theorem canonicalCheck_iff (a : F) :
    canonicalCheck a = true ↔ isCanonical a := by
  unfold canonicalCheck
  constructor
  · exact decide_eq_true_eq.mp
  · exact decide_eq_true

@[simp] theorem canonicalRep_zero : canonicalRep (0 : F) = 0 := by
  simp [canonicalRep]

@[simp] theorem canonicalRep_one : canonicalRep (1 : F) = 1 := by
  simp [canonicalRep]

theorem isCanonical_zero : isCanonical (0 : F) := by
  exact canonical (0 : F)

theorem isCanonical_one : isCanonical (1 : F) := by
  exact canonical (1 : F)

@[simp] theorem centeredRep_zero : centeredRep (0 : F) = 0 := by
  have h : ((0 : F).val) ≤ Goldilocks.halfQ := by
    simp
  simpa [h] using centeredRep_eq_of_le_halfQ h

@[simp] theorem centeredRep_one : centeredRep (1 : F) = 1 := by
  have h : ((1 : F).val) ≤ Goldilocks.halfQ := by
    exact Goldilocks.one_le_halfQ
  calc
    centeredRep (1 : F) = Int.ofNat ((1 : F).val) := centeredRep_eq_of_le_halfQ h
    _ = 1 := by simp

/--
Total case split for centered representatives: every canonical field value
falls in exactly one of the two centered-representation branches.
-/
theorem centeredRep_cases (a : F) :
    (a.val ≤ Goldilocks.halfQ ∧ centeredRep a = Int.ofNat a.val) ∨
    (Goldilocks.halfQ < a.val ∧ centeredRep a = Int.ofNat a.val - Int.ofNat Goldilocks.q) := by
  by_cases h : a.val ≤ Goldilocks.halfQ
  · exact Or.inl ⟨h, centeredRep_eq_of_le_halfQ h⟩
  · have hlt : Goldilocks.halfQ < a.val := Nat.lt_of_not_ge h
    exact Or.inr ⟨hlt, centeredRep_eq_sub_q_of_halfQ_lt hlt⟩

/-- Non-dependent branch-erased centered-representation form. -/
theorem centeredRep_cover (a : F) :
    centeredRep a = Int.ofNat a.val ∨
      centeredRep a = Int.ofNat a.val - Int.ofNat Goldilocks.q := by
  rcases centeredRep_cases a with hL | hR
  · exact Or.inl hL.2
  · exact Or.inr hR.2

@[simp] theorem val_add (a b : F) :
    (a + b).val = (a.val + b.val) % Goldilocks.q := rfl

@[simp] theorem val_sub (a b : F) :
    (a - b).val = (a.val + Goldilocks.q - b.val) % Goldilocks.q := by
  have hEq : Goldilocks.q + a.val - b.val = a.val + (Goldilocks.q - b.val) := by
    omega
  calc
    (a - b).val = (a.val + (Goldilocks.q - b.val)) % Goldilocks.q := by
      simpa [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm] using (Fin.val_sub a b)
    _ = (Goldilocks.q + a.val - b.val) % Goldilocks.q := by
      simp [hEq]
    _ = (a.val + Goldilocks.q - b.val) % Goldilocks.q := by
      simp [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm]

@[simp] theorem val_mul (a b : F) :
    (a * b).val = (a.val * b.val) % Goldilocks.q := rfl

@[simp] theorem val_neg (a : F) :
    (-a).val = (Goldilocks.q - a.val) % Goldilocks.q := rfl

theorem canonicalRep_add (a b : F) :
    canonicalRep (a + b) = (a.val + b.val) % Goldilocks.q := by
  show (a + b).val = (a.val + b.val) % Goldilocks.q
  exact val_add a b

theorem canonicalRep_mul (a b : F) :
    canonicalRep (a * b) = (a.val * b.val) % Goldilocks.q := by
  show (a * b).val = (a.val * b.val) % Goldilocks.q
  exact val_mul a b

theorem canonicalRep_neg (a : F) :
    canonicalRep (-a) = (Goldilocks.q - a.val) % Goldilocks.q := by
  show (-a).val = (Goldilocks.q - a.val) % Goldilocks.q
  exact val_neg a

private theorem eq_of_qmul_pos_lt2q (k : Nat)
    (hpos : 0 < Goldilocks.q * k)
    (hlt : Goldilocks.q * k < 2 * Goldilocks.q) : k = 1 := by
  have hkpos : 0 < k := by
    by_cases hk0 : k = 0
    · subst hk0
      simp at hpos
    · exact Nat.pos_of_ne_zero hk0
  have hklt2 : k < 2 := by
    have hmul : k * Goldilocks.q < 2 * Goldilocks.q := by
      simpa [Nat.mul_comm, Nat.mul_left_comm, Nat.mul_assoc] using hlt
    exact Nat.lt_of_mul_lt_mul_right hmul
  have hkge1 : 1 ≤ k := Nat.succ_le_of_lt hkpos
  have hkle1 : k ≤ 1 := Nat.lt_succ_iff.mp hklt2
  exact Nat.le_antisymm hkle1 hkge1

/-- Field subtraction cancellation in `F_q`. -/
theorem sub_eq_zero_iff (a b : F) : a - b = 0 ↔ a = b := by
  constructor
  · intro h
    apply Fin.ext
    let x := a.val + Goldilocks.q - b.val
    have hmod : x % Goldilocks.q = 0 := by
      have hv : (a - b).val = 0 := by simpa [h] using (val_zero)
      simpa [x, val_sub] using hv
    have hdiv : Goldilocks.q ∣ x := Nat.dvd_of_mod_eq_zero hmod
    rcases hdiv with ⟨k, hk⟩
    have hlt2q : Goldilocks.q * k < 2 * Goldilocks.q := by
      have ha : a.val < Goldilocks.q := a.isLt
      have hb : b.val < Goldilocks.q := b.isLt
      have hxlt : x < 2 * Goldilocks.q := by
        dsimp [x]
        omega
      simpa [hk] using hxlt
    have hpos : 0 < Goldilocks.q * k := by
      have hb : b.val < Goldilocks.q := b.isLt
      have hxpos : 0 < x := by
        dsimp [x]
        omega
      simpa [hk] using hxpos
    have hk1 : k = 1 := eq_of_qmul_pos_lt2q k hpos hlt2q
    have hx : x = Goldilocks.q := by
      simpa [hk1] using hk
    dsimp [x] at hx
    omega
  · intro h
    subst h
    apply Fin.ext
    simp [val_sub]

end F

end SuperNeo
