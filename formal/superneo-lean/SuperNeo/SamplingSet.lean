import SuperNeo.Norm

/-!
Sampling-set norm boundary layer (Theorem 9 style).

This module provides a theorem-native contract for bounding sampling inputs by a
shared norm cap. It is intentionally lightweight and does not encode probability
semantics; that lives in the protocol/security layers.
-/

namespace SuperNeo

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

/-- Constructor from explicit per-entry bounds. -/
theorem samplingExpansionProp_of_bounds
  {cset samples : Array Coeffs}
  {B : Nat}
  (hCset : ∀ i : Fin cset.size, normInfCoeffs cset[i] ≤ B)
  (hSamples : ∀ j : Fin samples.size, normInfCoeffs samples[j] ≤ B) :
  samplingExpansionProp cset samples := by
  exact ⟨B, hCset, hSamples⟩

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


end SuperNeo
