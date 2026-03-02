import SuperNeo.MLE

/-!
Contract interface for `SuperNeo.MLE`.

Spec: `specs/MLE.spec.md`

Paper anchors:
- Section 4, line 273: `ṽ(X) = Σ_j eq(X,j) · v_j` — MLE definition.
- Definition 6, Section 4, lines 352-355: sum-check uses MLE claims.
- Section 7.3, lines 440-470: MLE evaluation in folding.
-/

namespace SuperNeo

namespace MLEInterface

/-! ## Core Surfaces -/

/-- [Status: Definitional] Bit predicate over `F`. -/
abbrev IsBit := SuperNeo.IsBit

/-- [Status: Definitional] Bit-vector predicate over arrays. -/
abbrev IsBitVec := SuperNeo.IsBitVec

/-- [Status: Definitional] Index-mask embedding to a field bit vector. -/
abbrev bitsToFieldArray := SuperNeo.bitsToFieldArray

/-- [Status: Definitional] Guarded executable MLE evaluator. -/
abbrev mleEval := SuperNeo.mleEval

/-- [Status: Definitional] Unguarded sum-form MLE expression. -/
abbrev mleInnerProductForm := SuperNeo.mleInnerProductForm

/-- [Status: Definitional] Single basis-weight selector `χ_r(j)`. -/
abbrev chiWeight := SuperNeo.chiWeight

/-- [Status: Definitional] Compatibility `rHat` vector. -/
abbrev rHat := SuperNeo.rHat

/-- [Status: Definitional] Compatibility evaluator (inner-product route). -/
abbrev mleByInnerProduct := SuperNeo.mleByInnerProduct

/-- [Status: Definitional] Executable iterative folding evaluator. -/
abbrev mleByFoldingExec := SuperNeo.mleByFoldingExec

/-- [Status: Definitional] Theorem-facing folding evaluator. -/
abbrev mleByFolding := SuperNeo.mleByFolding

/-- [Status: Definitional] Canonical chi vector indexed by Boolean-cube masks. -/
abbrev chi := SuperNeo.chi

/-- [Status: Definitional] Dot-product surface used by chi-form MLE. -/
abbrev dot := SuperNeo.dot

/-- [Status: Definitional] MLE via dot-product with chi weights. -/
abbrev mleViaChiDot := SuperNeo.mleViaChiDot

/-- [Status: Definitional] Pointwise table linear combination `f + δ*g`. -/
abbrev linComb := SuperNeo.linComb

/-! ## Proved Theorems -/

/-- [Status: Proved] Size-valid executable evaluator equals sum form. -/
abbrev mleEval_eq_innerProductForm_of_size
  {f r : Array F}
  (hSize : f.size = (2 ^ r.size)) :
  mleEval f r = mleInnerProductForm f r :=
  SuperNeo.mleEval_eq_innerProductForm_of_size hSize

/-- [Status: Proved] `rHat` has the requested output size. -/
abbrev rHat_size := SuperNeo.rHat_size

/-- [Status: Proved] `chi` has size `2 ^ r.size`. -/
abbrev chi_size := SuperNeo.chi_size

/-- [Status: Proved] `linComb` preserves the left-table size. -/
abbrev linComb_size := SuperNeo.linComb_size

/-- [Status: Proved] Package-level executable-vs-sum identity is closed. -/
abbrev mleIdentityAssumption_holds := SuperNeo.mleIdentityAssumption_holds

/-- [Status: Proved] Size-guarded identity between theorem-facing inner and folding forms. -/
abbrev mleByInnerProduct_eq_mleByFolding_of_size :=
  SuperNeo.mleByInnerProduct_eq_mleByFolding_of_size

/-- [Status: Proved] Size-guarded sum-form equals chi/dot form. -/
abbrev mleInnerProductForm_eq_mleViaChiDot_of_size
  {f r : Array F}
  (hSize : f.size = (2 ^ r.size)) :
  mleInnerProductForm f r = mleViaChiDot f r :=
  SuperNeo.mleInnerProductForm_eq_mleViaChiDot_of_size hSize

/-- [Status: Proved] Package-level chi/dot identity is closed. -/
abbrev mleChiIdentityAssumption_holds := SuperNeo.mleChiIdentityAssumption_holds

/-- [Status: Proved] Derived guarded linearity under identity + inner linearity packages. -/
abbrev mleEval_linComb_of_assumptions := SuperNeo.mleEval_linComb_of_assumptions

/-! ## Boundary Targets (Definitional Carriers + Bridges) -/

/-- [Status: Definitional] Package target for executable-vs-sum identity. -/
abbrev mleIdentityAssumption := SuperNeo.mleIdentityAssumption

/-- [Status: Definitional] Package target for Boolean-cube delta behavior of `eqPoly`. -/
abbrev eqPolyDeltaOnBitsAssumption := SuperNeo.eqPolyDeltaOnBitsAssumption

/-- [Status: Proved] Bridge from `EqPoly.eqPolyAssumption` to MLE-local delta package. -/
abbrev eqPolyDeltaOnBitsAssumption_of_eqPolyAssumption :=
  SuperNeo.eqPolyDeltaOnBitsAssumption_of_eqPolyAssumption

/-- [Status: Proved] Canonical closure of MLE-local delta package from EqPoly selector boundary. -/
abbrev eqPolyDeltaOnBitsAssumption_holds_of_eqPolyAssumption :=
  SuperNeo.eqPolyDeltaOnBitsAssumption_holds_of_eqPolyAssumption

/-- [Status: Proved] Conditional delta theorem from the package target. -/
abbrev eqPoly_eq_delta_of_isBitVec_of_assumption := SuperNeo.eqPoly_eq_delta_of_isBitVec_of_assumption

/-- [Status: Definitional] Package target for sum-form equals chi/dot form. -/
abbrev mleChiIdentityAssumption := SuperNeo.mleChiIdentityAssumption

/-- [Status: Proved] Conditional chi/dot identity theorem from the package target. -/
abbrev mleInnerProductForm_eq_mleViaChiDot_of_size_of_assumption := SuperNeo.mleInnerProductForm_eq_mleViaChiDot_of_size_of_assumption

/-- [Status: Definitional] Package target for sum-form linearity in table input. -/
abbrev mleInnerProductLinearityAssumption := SuperNeo.mleInnerProductLinearityAssumption

/-- [Status: Proved] Canonical closure of inner-product-form linearity. -/
abbrev mleInnerProductLinearityAssumption_holds :=
  SuperNeo.mleInnerProductLinearityAssumption_holds

/-- [Status: Definitional] Package target for guarded evaluator linearity. -/
abbrev mleEvalLinearityAssumption := SuperNeo.mleEvalLinearityAssumption

/-- [Status: Proved] Conditional guarded linearity theorem from the package target. -/
abbrev mleEval_linComb_of_assumption := SuperNeo.mleEval_linComb_of_assumption

/-- [Status: Proved] Build guarded-linearity package from identity + inner-linearity packages. -/
abbrev mleEvalLinearityAssumption_of_assumptions :=
  SuperNeo.mleEvalLinearityAssumption_of_assumptions

/-- [Status: Proved] Canonical closure of guarded evaluator linearity. -/
abbrev mleEvalLinearityAssumption_holds :=
  SuperNeo.mleEvalLinearityAssumption_holds

end MLEInterface

end SuperNeo
