import SuperNeo.ArithmeticObligations

/-!
Contract interface for `SuperNeo.ArithmeticObligations`.

Spec: `./formal/superneo-lean/specs/ArithmeticObligations.spec.md`

Paper anchors (Source: `./formal/superneo-lean/SuperNeo.pdf.md`):
- Section 7 (Neo's folding scheme for CCS), lines 447–467: Relations and structure (Definitions 11–12)
- Section 4–5 preliminaries: decomposition, matrix transform, eval homomorphism, MLE, interpolation
-/

namespace SuperNeo

namespace ArithmeticObligationsInterface

/-! ## Core Surfaces -/

/-- [Status: Proved] Curated re-export of `ArithmeticObligations`. -/
abbrev ArithmeticObligations := SuperNeo.ArithmeticObligations

/-! ## Key Theorems -/

/-- [Status: Proved] Curated theorem surface `ArithmeticObligations.splitTerminalZero`. -/
abbrev ArithmeticObligations_splitTerminalZero := @SuperNeo.ArithmeticObligations.splitTerminalZero

/-- [Status: Proved] Theorem-native constructor deriving `evalHom` from `(P10 + P11)`. -/
abbrev ArithmeticObligations_of_p10_p11 := @SuperNeo.ArithmeticObligations.of_p10_p11

/-- [Status: Proved] Curated theorem surface `splitDecompositionNat_of_obligations`. -/
abbrev splitDecompositionNat_of_obligations := @SuperNeo.splitDecompositionNat_of_obligations

/-! ## Boundary Surfaces -/

/-- [Status: Proved] Optional MLE boundary constructor from global MLE assumption. -/
abbrev mleIdentityAtR_of_assumption := @SuperNeo.mleIdentityAtR_of_assumption

/-- [Status: Proved] Preferred theorem-native local MLE identity from table-size precondition. -/
abbrev mleIdentityAtR_of_size := @SuperNeo.mleIdentityAtR_of_size

end ArithmeticObligationsInterface

end SuperNeo
