import SuperNeo.Ring

namespace SuperNeo

/-- Infinity norm on field elements via centered representatives. -/
def normInfF (x : F) : Nat :=
  F.centeredAbs x

/-- Infinity norm on coefficient arrays. -/
def normInfCoeffs (a : Coeffs) : Nat :=
  a.foldl (fun acc x => Nat.max acc (normInfF x)) 0

/-- Alias used by protocol-facing statements. -/
def maxRhoNorm (a : Coeffs) : Nat :=
  normInfCoeffs a

@[simp] theorem maxRhoNorm_eq_normInfCoeffs (a : Coeffs) :
    maxRhoNorm a = normInfCoeffs a := rfl

@[simp] theorem normInfF_zero : normInfF (0 : F) = 0 := by
  have hRep : F.centeredRep (0 : F) = Int.ofNat (0 : F).val := by
    apply F.centeredRep_eq_of_le_halfQ
    simp
  simp [normInfF, F.centeredAbs, hRep]

@[simp] theorem normInfCoeffs_empty : normInfCoeffs (#[] : Coeffs) = 0 := by
  simp [normInfCoeffs]

theorem normInfCoeffs_nonneg (a : Coeffs) : 0 ≤ normInfCoeffs a :=
  Nat.zero_le _

theorem maxRhoNorm_nonneg (a : Coeffs) : 0 ≤ maxRhoNorm a :=
  normInfCoeffs_nonneg a

/-- Assumption bundle: vector-add norm bound from operand norms. -/
def vecAddNormBoundFromOperands (BA BB B : Nat) : Prop :=
  ∀ a b : Coeffs, a.size = b.size →
    normInfCoeffs a ≤ BA →
    normInfCoeffs b ≤ BB →
    normInfCoeffs (vecAdd a b) ≤ B

/-- Assumption bundle: vector-scale norm bound from operand norms. -/
def vecScaleNormBoundFromOperands (BS BA B : Nat) : Prop :=
  ∀ s : F, ∀ a : Coeffs,
    normInfF s ≤ BS →
    normInfCoeffs a ≤ BA →
    normInfCoeffs (vecScale s a) ≤ B

/-- Assumption bundle: ring multiplication norm bound from operand norms. -/
def mulRqNormBoundFromOperands (BA BB B : Nat) : Prop :=
  ∀ a b : Coeffs,
    normInfCoeffs a ≤ BA →
    normInfCoeffs b ≤ BB →
    normInfCoeffs (mulRq a b) ≤ B

/-- Assumption bundle: subtraction norm bound from operand norms. -/
def coeffSubNormBoundFromOperands (BA BB B : Nat) : Prop :=
  ∀ a b : Coeffs, a.size = b.size →
    normInfCoeffs a ≤ BA →
    normInfCoeffs b ≤ BB →
    normInfCoeffs (vecAdd a (vecScale (-1) b)) ≤ B

def AllChallengeCoeffs (a : Coeffs) : Prop :=
  ∀ i : Fin a.size, normInfF a[i] ≤ 2

theorem allChallengeCoeffs_empty : AllChallengeCoeffs (#[] : Coeffs) := by
  intro i
  exact False.elim (Nat.not_lt_zero _ i.2)

theorem allChallengeCoeffs_mono
    {a : Coeffs}
    {B C : Nat}
    (hB : ∀ i : Fin a.size, normInfF a[i] ≤ B)
    (hBC : B ≤ C) :
    ∀ i : Fin a.size, normInfF a[i] ≤ C := by
  intro i
  exact Nat.le_trans (hB i) hBC

theorem allChallengeCoeffs_of_bound
    {a : Coeffs}
    (hB : ∀ i : Fin a.size, normInfF a[i] ≤ 2) :
    AllChallengeCoeffs a :=
  hB

theorem allChallengeCoeffs_weaken
    {a : Coeffs}
    (h : AllChallengeCoeffs a) :
    ∀ i : Fin a.size, normInfF a[i] ≤ 2 := h

theorem vecAddNormBoundFromOperands_of_global
    {BA BB B : Nat}
    (hGlobal : ∀ a b : Coeffs, a.size = b.size →
      normInfCoeffs (vecAdd a b) ≤ B) :
    vecAddNormBoundFromOperands BA BB B := by
  intro a b hSize _hA _hB
  exact hGlobal a b hSize

theorem vecScaleNormBoundFromOperands_of_global
    {BS BA B : Nat}
    (hGlobal : ∀ s : F, ∀ a : Coeffs, normInfCoeffs (vecScale s a) ≤ B) :
    vecScaleNormBoundFromOperands BS BA B := by
  intro s a _hS _hA
  exact hGlobal s a

theorem mulRqNormBoundFromOperands_of_global
    {BA BB B : Nat}
    (hGlobal : ∀ a b : Coeffs, normInfCoeffs (mulRq a b) ≤ B) :
    mulRqNormBoundFromOperands BA BB B := by
  intro a b _hA _hB
  exact hGlobal a b

theorem coeffSubNormBoundFromOperands_of_global
    {BA BB B : Nat}
    (hGlobal : ∀ a b : Coeffs, a.size = b.size →
      normInfCoeffs (vecAdd a (vecScale (-1) b)) ≤ B) :
    coeffSubNormBoundFromOperands BA BB B := by
  intro a b hSize _hA _hB
  exact hGlobal a b hSize

end SuperNeo
