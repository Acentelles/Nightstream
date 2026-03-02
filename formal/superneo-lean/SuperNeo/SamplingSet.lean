import SuperNeo.Norm

/-!
Sampling-set norm boundary layer (Theorem 9 style).

This module provides a theorem-native contract for bounding sampling inputs by a
shared norm cap. It is intentionally lightweight and does not encode probability
semantics; that lives in the protocol/security layers.
-/

namespace SuperNeo

/-- Sampling-set carrier over ring elements. -/
abbrev SamplingCarrier := Coeffs → Prop

/-- Difference set `C - C` used in relaxed-binding analyses. -/
def samplingDiffSet (C : SamplingCarrier) : SamplingCarrier :=
  fun δ => ∃ c1 c2 : Coeffs, C c1 ∧ C c2 ∧ δ = vecAdd c1 (vecScale (-1) c2)

/--
Strong-sampling expansion-factor contract (Definition 17 / Theorem 9 style):
every `δ ∈ C-C` scales any bounded vector by at most `4*T*B` in `‖·‖∞`.
-/
def strongSamplingExpansionProp
  (C : SamplingCarrier)
  (T : Nat) : Prop :=
  ∀ δ : Coeffs, samplingDiffSet C δ →
    ∀ z : Coeffs, ∀ B : Nat,
      normInfCoeffs z ≤ B →
      normInfCoeffs (mulRq δ z) ≤ 4 * T * B

/-- Both challenge-set and sample-set blocks are bounded by `B`. -/
def samplingNormBoundProp
  (cset samples : Array Coeffs)
  (B : Nat) : Prop :=
  (∀ i : Fin cset.size, normInfCoeffs cset[i] ≤ B) ∧
  (∀ j : Fin samples.size, normInfCoeffs samples[j] ≤ B)

/-- Existential form used by downstream protocol composition. -/
def samplingExpansionProp
  (cset samples : Array Coeffs) : Prop :=
  ∃ B : Nat, samplingNormBoundProp cset samples B

theorem samplingNormBoundProp_left
  {cset samples : Array Coeffs}
  {B : Nat}
  (h : samplingNormBoundProp cset samples B) :
  ∀ i : Fin cset.size, normInfCoeffs cset[i] ≤ B := h.1

theorem samplingNormBoundProp_right
  {cset samples : Array Coeffs}
  {B : Nat}
  (h : samplingNormBoundProp cset samples B) :
  ∀ j : Fin samples.size, normInfCoeffs samples[j] ≤ B := h.2

theorem samplingNormBoundProp_mono
  {cset samples : Array Coeffs}
  {B B' : Nat}
  (h : samplingNormBoundProp cset samples B)
  (hBB' : B ≤ B') :
  samplingNormBoundProp cset samples B' := by
  constructor
  · intro i
    exact Nat.le_trans (h.1 i) hBB'
  · intro j
    exact Nat.le_trans (h.2 j) hBB'

/-- Constructor from explicit per-entry bounds. -/
theorem samplingExpansionProp_of_bounds
  {cset samples : Array Coeffs}
  {B : Nat}
  (hCset : ∀ i : Fin cset.size, normInfCoeffs cset[i] ≤ B)
  (hSamples : ∀ j : Fin samples.size, normInfCoeffs samples[j] ≤ B) :
  samplingExpansionProp cset samples := by
  exact ⟨B, hCset, hSamples⟩

theorem samplingExpansionProp_mono
  {cset samples : Array Coeffs}
  {B B' : Nat}
  (h : samplingNormBoundProp cset samples B)
  (hBB' : B ≤ B') :
  samplingExpansionProp cset samples := by
  exact ⟨B', samplingNormBoundProp_mono h hBB'⟩

theorem samplingExpansionProp_empty :
  samplingExpansionProp (#[] : Array Coeffs) (#[] : Array Coeffs) := by
  refine ⟨0, ?_⟩
  constructor
  · intro i
    exact False.elim (Nat.not_lt_zero _ i.2)
  · intro j
    exact False.elim (Nat.not_lt_zero _ j.2)

theorem strongSamplingExpansionProp_mono
  {C : SamplingCarrier}
  {T T' : Nat}
  (h : strongSamplingExpansionProp C T)
  (hTT' : T ≤ T') :
  strongSamplingExpansionProp C T' := by
  intro δ hδ z B hB
  have hδz : normInfCoeffs (mulRq δ z) ≤ 4 * T * B := h δ hδ z B hB
  have hBound : 4 * T * B ≤ 4 * T' * B := by
    exact Nat.mul_le_mul_right B (Nat.mul_le_mul_left 4 hTT')
  exact Nat.le_trans hδz hBound

theorem expansionFactor_of_strongSampling
  {C : SamplingCarrier}
  {T : Nat}
  (h : strongSamplingExpansionProp C T)
  {δ z : Coeffs}
  (hδ : samplingDiffSet C δ)
  {B : Nat}
  (hB : normInfCoeffs z ≤ B) :
  normInfCoeffs (mulRq δ z) ≤ 4 * T * B :=
  h δ hδ z B hB

/-! Compatibility check surface retained for protocol-level glue. -/

/--
Executable compatibility check for sampling expansion obligations.

This compact scaffold reflects the theorem-facing proposition directly.
-/
noncomputable def samplingSetBoundCheck
  (cset samples : Array Coeffs) : Bool := by
  classical
  exact decide (samplingExpansionProp cset samples)

theorem samplingSetBoundCheck_sound
  {cset samples : Array Coeffs}
  (hOk : samplingSetBoundCheck cset samples = true) :
  samplingExpansionProp cset samples := by
  classical
  unfold samplingSetBoundCheck at hOk
  exact decide_eq_true_eq.mp hOk

theorem samplingSetBoundCheck_complete
  {cset samples : Array Coeffs}
  (hProp : samplingExpansionProp cset samples) :
  samplingSetBoundCheck cset samples = true := by
  classical
  unfold samplingSetBoundCheck
  exact decide_eq_true hProp

theorem samplingSetBoundCheck_iff
  {cset samples : Array Coeffs} :
  samplingSetBoundCheck cset samples = true ↔ samplingExpansionProp cset samples := by
  constructor
  · exact samplingSetBoundCheck_sound
  · exact samplingSetBoundCheck_complete


end SuperNeo
