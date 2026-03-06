/-!
Negligible-function surface inspired by VCV-io:
- VCVio/CryptoFoundations/Asymptotics/Negligible.lean
- Apache-2.0, Copyright (c) 2024 Devon Tuma

The proof-system layer uses a theorem-facing asymptotic negligible model over
security-parameter indexed rational error functions.
-/

namespace SuperNeo.ProofSystem

/-- Error functions are indexed by the security parameter. -/
abbrev ErrorFn := Nat → Rat

/-- Canonical inverse-polynomial tail bound used by negligible statements. -/
def invPolyBound (c n : Nat) : Rat :=
  Rat.divInt 1 ((Int.ofNat (n + 1)) ^ c)

/--
Asymptotic negligible predicate:
for every polynomial degree `c`, the error is eventually bounded by
`1 / (n+1)^c`.
-/
def IsNegligible (f : ErrorFn) : Prop :=
  ∀ c : Nat, ∃ N : Nat, ∀ n : Nat, N ≤ n → f n ≤ invPolyBound c n

@[simp] theorem isNegligible_iff
  (f : ErrorFn) :
  IsNegligible f ↔
    ∀ c : Nat, ∃ N : Nat, ∀ n : Nat, N ≤ n → f n ≤ invPolyBound c n := Iff.rfl

private theorem invPolyBound_nonneg (c n : Nat) : 0 ≤ invPolyBound c n := by
  unfold invPolyBound
  have hOne : (0 : Int) ≤ 1 := by decide
  have hDen : 0 ≤ ((Int.ofNat (n + 1)) ^ c) := by
    exact Int.pow_nonneg (Int.natCast_nonneg (n + 1))
  exact Rat.divInt_nonneg hOne hDen

theorem isNegligible_zero : IsNegligible (fun _ => 0) :=
  by
    intro c
    refine ⟨0, ?_⟩
    intro n _hn
    simpa using (invPolyBound_nonneg c n)

theorem isNegligible_of_zero
  {f : ErrorFn}
  (hf : ∀ n, f n = 0) :
  IsNegligible f := by
  intro c
  refine ⟨0, ?_⟩
  intro n _hn
  simpa [hf n] using (invPolyBound_nonneg c n)

end SuperNeo.ProofSystem
