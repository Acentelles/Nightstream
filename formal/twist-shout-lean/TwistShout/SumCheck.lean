import TwistShout.MLE

/-!
# SumCheck

Paper-level sum-check protocol over multivariate polynomials.
-/

open scoped BigOperators
open MvPolynomial

namespace TwistShout

noncomputable section

section

variable {K : Type*} [Field K]

/-- Sum of a multivariate polynomial over the Boolean hypercube. -/
def hypercubeSum {n : Nat} (g : MvPolynomial (Fin n) K) : K :=
  ∑ b : Cube n, MvPolynomial.eval (bitVec (K := K) b) g

/-- Bind the first variable of a polynomial to a field challenge. -/
def bindHead {n : Nat} (g : MvPolynomial (Fin (n + 1)) K) (c : K) :
    MvPolynomial (Fin n) K :=
  Polynomial.eval (MvPolynomial.C c) (MvPolynomial.finSuccEquiv K n g)

/-- Honest first-round polynomial obtained by summing over the remaining Boolean variables. -/
def firstRoundPoly {n : Nat} (g : MvPolynomial (Fin (n + 1)) K) : Polynomial K :=
  ∑ tail : Cube n,
    Polynomial.map (MvPolynomial.eval (bitVec (K := K) tail)) (MvPolynomial.finSuccEquiv K n g)

/-- Drop the first verifier challenge. -/
def tailChallenges {n : Nat} (challenges : Fin (n + 1) → K) : Fin n → K :=
  fun i => challenges i.succ

/-- Typed sum-check transcript with one challenge and one round polynomial per round. -/
structure SumCheckTranscript (n : Nat) where
  challenges : Fin n → K
  roundPolys : Fin n → Polynomial K

/-- Drop the first round and challenge from a transcript. -/
def tailTranscript {n : Nat} (tr : SumCheckTranscript (K := K) n.succ) :
    SumCheckTranscript (K := K) n :=
  { challenges := tailChallenges tr.challenges
    roundPolys := fun i => tr.roundPolys i.succ }

/-- Honest prover round polynomials for a fixed verifier challenge vector. -/
def honestRoundPolys : {n : Nat} → MvPolynomial (Fin n) K → (Fin n → K) → Fin n → Polynomial K
  | 0, _, _, i => nomatch i
  | _ + 1, g, challenges, i =>
      Fin.cases
        (firstRoundPoly (K := K) g)
        (fun j => honestRoundPolys (bindHead g (challenges 0)) (tailChallenges challenges) j)
        i

/-- Honest transcript for a fixed verifier challenge vector. -/
def honestTranscript {n : Nat} (g : MvPolynomial (Fin n) K) (challenges : Fin n → K) :
    SumCheckTranscript (K := K) n :=
  { challenges := challenges
    roundPolys := honestRoundPolys g challenges }

/-- Public sum-check instance: claimed sum and per-round degree bounds. -/
structure SumCheckInstance (n : Nat) where
  claimedSum : K
  degreeBound : Fin n → Nat

/-- Paper-facing sum-check statement for a concrete polynomial. -/
structure SumCheckStatement {n : Nat} (inst : SumCheckInstance (K := K) n) where
  polynomial : MvPolynomial (Fin n) K
  hypercubeSumEqClaimed : hypercubeSum (K := K) polynomial = inst.claimedSum
  honestRoundDegreeLe :
    ∀ challenges : Fin n → K,
      ∀ i : Fin n, (honestRoundPolys polynomial challenges i).natDegree ≤ inst.degreeBound i

/-- Per-round degree check against the public instance bounds. -/
def sumcheckRoundDegrees {n : Nat} (inst : SumCheckInstance (K := K) n)
    (tr : SumCheckTranscript (K := K) n) : Prop :=
  ∀ i : Fin n, (tr.roundPolys i).natDegree ≤ inst.degreeBound i

/-- Initial-round consistency `s₀(0) + s₀(1) = H`. -/
def sumcheckInitialRoundConsistent :
    {n : Nat} → SumCheckInstance (K := K) n → SumCheckTranscript (K := K) n → Prop
  | 0, _, _ => True
  | _ + 1, inst, tr =>
      (tr.roundPolys 0).eval 0 + (tr.roundPolys 0).eval 1 = inst.claimedSum

/-- Round-transition consistency `sᵢ₊₁(0) + sᵢ₊₁(1) = sᵢ(rᵢ)`. -/
def sumcheckFoldConsistent : {n : Nat} → SumCheckTranscript (K := K) n → Prop
  | 0, _ => True
  | 1, _ => True
  | _ + 2, tr =>
      (tr.roundPolys 1).eval 0 + (tr.roundPolys 1).eval 1 =
        (tr.roundPolys 0).eval (tr.challenges 0) ∧
      sumcheckFoldConsistent (tailTranscript tr)

/-- Final reduction to a single random-point evaluation of the summed polynomial. -/
def sumcheckFinalConsistent :
    {n : Nat} → {inst : SumCheckInstance (K := K) n} →
      SumCheckStatement inst → SumCheckTranscript (K := K) n → Prop
  | 0, inst, stmt, _ => hypercubeSum (K := K) stmt.polynomial = inst.claimedSum
  | n + 1, _, stmt, tr =>
      (tr.roundPolys (Fin.last n)).eval (tr.challenges (Fin.last n)) =
        MvPolynomial.eval tr.challenges stmt.polynomial

/-- Full paper-facing verifier predicate. -/
def sumcheckVerifierAccepted :
    {n : Nat} → {inst : SumCheckInstance (K := K) n} →
      SumCheckStatement inst → SumCheckTranscript (K := K) n → Prop
  | _, inst, stmt, tr =>
      sumcheckRoundDegrees inst tr ∧
      sumcheckInitialRoundConsistent inst tr ∧
      sumcheckFoldConsistent tr ∧
      sumcheckFinalConsistent stmt tr

@[simp] theorem bitVec_cons
    {n : Nat}
    (head : Bool)
    (tail : Cube n) :
    bitVec (K := K) (Fin.cons head tail) =
      Fin.cases (bitToField (K := K) head) (bitVec (K := K) tail) := by
  funext i
  refine Fin.cases ?_ ?_ i
  · rfl
  · intro j
    rfl

omit [Field K] in
@[simp] theorem finCases_tailChallenges
    {n : Nat}
    (challenges : Fin (n + 1) → K) :
    Fin.cases (challenges 0) (tailChallenges challenges) = challenges := by
  funext i
  refine Fin.cases ?_ ?_ i
  · rfl
  · intro j
    rfl

theorem eval_bindHead
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K)
    (c : K)
    (x : Fin n → K) :
    MvPolynomial.eval x (bindHead (K := K) g c) =
      MvPolynomial.eval (Fin.cases c x) g := by
  unfold bindHead
  rw [MvPolynomial.eval_polynomial_eval_finSuccEquiv (R := K) (f := g) (q := MvPolynomial.C c)]
  simp

theorem hypercubeSum_bindHead
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K)
    (c : K) :
    hypercubeSum (K := K) (bindHead (K := K) g c) =
      ∑ tail : Cube n, MvPolynomial.eval (Fin.cases c (bitVec (K := K) tail)) g := by
  unfold hypercubeSum
  apply Finset.sum_congr rfl
  intro tail _
  rw [eval_bindHead]

theorem hypercubeSum_split_head
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K) :
    hypercubeSum (K := K) g =
      hypercubeSum (K := K) (bindHead (K := K) g 0) +
        hypercubeSum (K := K) (bindHead (K := K) g 1) := by
  unfold hypercubeSum
  calc
    ∑ b : Cube (n + 1), MvPolynomial.eval (bitVec (K := K) b) g
        = ∑ p : Bool × Cube n, MvPolynomial.eval (bitVec (K := K) (Fin.cons p.1 p.2)) g := by
            refine Fintype.sum_equiv (cubeSuccEquiv n)
              (fun b => MvPolynomial.eval (bitVec (K := K) b) g)
              (fun p => MvPolynomial.eval (bitVec (K := K) (Fin.cons p.1 p.2)) g) ?_
            intro b
            have hb : Fin.cons ((cubeSuccEquiv n) b).1 ((cubeSuccEquiv n) b).2 = b :=
              (cubeSuccEquiv n).left_inv b
            simpa using (congrArg (fun v => MvPolynomial.eval (bitVec (K := K) v) g) hb).symm
    _ = ∑ tail : Cube n, ∑ head : Bool, MvPolynomial.eval (bitVec (K := K) (Fin.cons head tail)) g := by
          simpa using (Fintype.sum_prod_type_right'
            (fun head tail => MvPolynomial.eval (bitVec (K := K) (Fin.cons head tail)) g))
    _ = ∑ tail : Cube n,
          (MvPolynomial.eval (Fin.cases 0 (bitVec (K := K) tail)) g +
            MvPolynomial.eval (Fin.cases 1 (bitVec (K := K) tail)) g) := by
          apply Finset.sum_congr rfl
          intro tail _
          ring_nf
          simp [bitVec_cons, add_comm]
    _ = hypercubeSum (K := K) (bindHead (K := K) g 0) +
          hypercubeSum (K := K) (bindHead (K := K) g 1) := by
          rw [hypercubeSum_bindHead (K := K) g 0, hypercubeSum_bindHead (K := K) g 1,
            Finset.sum_add_distrib]

theorem firstRoundPoly_eval
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K)
    (c : K) :
    (firstRoundPoly (K := K) g).eval c =
      hypercubeSum (K := K) (bindHead (K := K) g c) := by
  unfold firstRoundPoly
  change Polynomial.evalRingHom c
      (∑ tail : Cube n,
        Polynomial.map (MvPolynomial.eval (bitVec (K := K) tail)) (MvPolynomial.finSuccEquiv K n g)) = _
  rw [map_sum]
  rw [hypercubeSum_bindHead (K := K) g c]
  apply Finset.sum_congr rfl
  intro tail _
  show (Polynomial.map (MvPolynomial.eval (bitVec (K := K) tail)) (MvPolynomial.finSuccEquiv K n g)).eval c =
      MvPolynomial.eval (Fin.cases c (bitVec (K := K) tail)) g
  calc
    (Polynomial.map (MvPolynomial.eval (bitVec (K := K) tail)) (MvPolynomial.finSuccEquiv K n g)).eval c
        = (MvPolynomial.finSuccEquiv K n g).eval₂ (MvPolynomial.eval (bitVec (K := K) tail)) c := by
            rw [Polynomial.eval_map]
    _ = (MvPolynomial.finSuccEquiv K n g).eval₂ (MvPolynomial.eval (bitVec (K := K) tail))
          ((MvPolynomial.eval (bitVec (K := K) tail)) (MvPolynomial.C c)) := by
            simp
    _ = MvPolynomial.eval (bitVec (K := K) tail) (bindHead (K := K) g c) := by
          rw [Polynomial.eval₂_at_apply]
          rfl
    _ = MvPolynomial.eval (Fin.cases c (bitVec (K := K) tail)) g := by
          exact eval_bindHead (K := K) g c (bitVec (K := K) tail)

theorem firstRoundPoly_zero_one
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K) :
    (firstRoundPoly (K := K) g).eval 0 + (firstRoundPoly (K := K) g).eval 1 =
      hypercubeSum (K := K) g := by
  rw [firstRoundPoly_eval (K := K) g 0, firstRoundPoly_eval (K := K) g 1]
  symm
  exact hypercubeSum_split_head (K := K) g

@[simp] theorem honestRoundPolys_zero
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K)
    (challenges : Fin (n + 1) → K) :
    honestRoundPolys g challenges 0 = firstRoundPoly (K := K) g := by
  rfl

@[simp] theorem honestRoundPolys_succ
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K)
    (challenges : Fin (n + 1) → K)
    (i : Fin n) :
    honestRoundPolys g challenges i.succ =
      honestRoundPolys (bindHead (K := K) g (challenges 0)) (tailChallenges challenges) i := by
  simp [honestRoundPolys]

@[simp] theorem tailTranscript_honestTranscript
    {n : Nat}
    (g : MvPolynomial (Fin (n + 1)) K)
    (challenges : Fin (n + 1) → K) :
    tailTranscript (honestTranscript (K := K) g challenges) =
      honestTranscript (K := K) (bindHead (K := K) g (challenges 0)) (tailChallenges challenges) := by
  cases n <;> rfl

@[simp] theorem hypercubeSum_zero_eval
    (g : MvPolynomial (Fin 0) K)
    (x : Fin 0 → K) :
    hypercubeSum (K := K) g = MvPolynomial.eval x g := by
  letI : Unique (Cube 0) := inferInstance
  unfold hypercubeSum
  simp
  exact congrArg (fun w => MvPolynomial.eval w g) (Subsingleton.elim _ _)

theorem honestTranscript_lastEval_pos :
    {n : Nat} → (g : MvPolynomial (Fin (n + 1)) K) → (challenges : Fin (n + 1) → K) →
      ((honestTranscript (K := K) g challenges).roundPolys (Fin.last n)).eval
        (challenges (Fin.last n)) =
      MvPolynomial.eval challenges g
  | 0, g, challenges => by
      calc
        ((honestTranscript (K := K) g challenges).roundPolys 0).eval (challenges 0)
            = (firstRoundPoly (K := K) g).eval (challenges 0) := by
                rfl
        _ = hypercubeSum (K := K) (bindHead (K := K) g (challenges 0)) := by
              exact firstRoundPoly_eval (K := K) g (challenges 0)
        _ = MvPolynomial.eval (tailChallenges challenges) (bindHead (K := K) g (challenges 0)) := by
              exact hypercubeSum_zero_eval (K := K) (bindHead (K := K) g (challenges 0))
                (tailChallenges challenges)
        _ = MvPolynomial.eval challenges g := by
              simpa [finCases_tailChallenges] using
                eval_bindHead (K := K) g (challenges 0) (tailChallenges challenges)
  | n + 1, g, challenges => by
      have hLast : Fin.last (n + 1) = (Fin.last n).succ := by
        ext
        simp [Fin.last]
      calc
        ((honestTranscript (K := K) g challenges).roundPolys (Fin.last (n + 1))).eval
            (challenges (Fin.last (n + 1)))
            =
          ((honestTranscript (K := K) (bindHead (K := K) g (challenges 0))
              (tailChallenges challenges)).roundPolys (Fin.last n)).eval
            ((tailChallenges challenges) (Fin.last n)) := by
              rw [hLast]
              rfl
        _ = MvPolynomial.eval (tailChallenges challenges) (bindHead (K := K) g (challenges 0)) := by
              exact honestTranscript_lastEval_pos
                (g := bindHead (K := K) g (challenges 0))
                (challenges := tailChallenges challenges)
        _ = MvPolynomial.eval challenges g := by
              simpa [finCases_tailChallenges] using
                eval_bindHead (K := K) g (challenges 0) (tailChallenges challenges)

theorem honestTranscript_roundDegrees
    {n : Nat}
    {inst : SumCheckInstance (K := K) n}
    (stmt : SumCheckStatement inst)
    (challenges : Fin n → K) :
    sumcheckRoundDegrees inst (honestTranscript (K := K) stmt.polynomial challenges) := by
  intro i
  exact stmt.honestRoundDegreeLe challenges i

theorem honestTranscript_initialRoundConsistent :
    {n : Nat} → {inst : SumCheckInstance (K := K) n} →
      (stmt : SumCheckStatement inst) →
      (challenges : Fin n → K) →
      sumcheckInitialRoundConsistent inst (honestTranscript (K := K) stmt.polynomial challenges)
  | 0, _, _, _ => trivial
  | _ + 1, _, stmt, _ => by
      change (firstRoundPoly (K := K) stmt.polynomial).eval 0 +
          (firstRoundPoly (K := K) stmt.polynomial).eval 1 = _
      exact (firstRoundPoly_zero_one (K := K) stmt.polynomial).trans stmt.hypercubeSumEqClaimed

theorem honestTranscript_foldConsistent :
    {n : Nat} → (g : MvPolynomial (Fin n) K) → (challenges : Fin n → K) →
      sumcheckFoldConsistent (honestTranscript (K := K) g challenges)
  | 0, _, _ => trivial
  | 1, _, _ => trivial
  | n + 2, g, challenges => by
      constructor
      · change (honestRoundPolys g challenges (Fin.succ (0 : Fin (n + 1)))).eval 0 +
            (honestRoundPolys g challenges (Fin.succ (0 : Fin (n + 1)))).eval 1 =
            (honestRoundPolys g challenges 0).eval (challenges 0)
        rw [honestRoundPolys_succ, honestRoundPolys_zero, honestRoundPolys_zero]
        rw [firstRoundPoly_zero_one, firstRoundPoly_eval]
      · simpa [tailTranscript_honestTranscript] using
          honestTranscript_foldConsistent (g := bindHead (K := K) g (challenges 0))
            (challenges := tailChallenges challenges)

theorem honestTranscript_finalConsistent :
    {n : Nat} → {inst : SumCheckInstance (K := K) n} →
      (stmt : SumCheckStatement inst) →
      (challenges : Fin n → K) →
      sumcheckFinalConsistent stmt (honestTranscript (K := K) stmt.polynomial challenges)
  | 0, _, stmt, _ => stmt.hypercubeSumEqClaimed
  | _ + 1, _, stmt, challenges => by
      simpa [sumcheckFinalConsistent] using
        honestTranscript_lastEval_pos (g := stmt.polynomial) (challenges := challenges)

theorem honestTranscript_verifierAccepted
    {n : Nat}
    {inst : SumCheckInstance (K := K) n}
    (stmt : SumCheckStatement inst)
    (challenges : Fin n → K) :
    sumcheckVerifierAccepted stmt (honestTranscript (K := K) stmt.polynomial challenges) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact honestTranscript_roundDegrees stmt challenges
  · exact honestTranscript_initialRoundConsistent stmt challenges
  · exact honestTranscript_foldConsistent stmt.polynomial challenges
  · exact honestTranscript_finalConsistent stmt challenges

end

end

end TwistShout
