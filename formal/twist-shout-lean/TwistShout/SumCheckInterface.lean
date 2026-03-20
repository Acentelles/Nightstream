import TwistShout.SumCheck

/-!
# SumCheckInterface

Thin theorem-facing boundary for the paper-level sum-check protocol.
-/

namespace TwistShout

namespace SumCheckInterface

noncomputable section

abbrev hypercubeSum := @TwistShout.hypercubeSum
abbrev bindHead := @TwistShout.bindHead
abbrev firstRoundPoly := @TwistShout.firstRoundPoly
abbrev tailChallenges := @TwistShout.tailChallenges
abbrev SumCheckTranscript := @TwistShout.SumCheckTranscript
abbrev tailTranscript := @TwistShout.tailTranscript
abbrev honestRoundPolys := @TwistShout.honestRoundPolys
abbrev honestTranscript := @TwistShout.honestTranscript
abbrev SumCheckInstance := @TwistShout.SumCheckInstance
abbrev SumCheckStatement := @TwistShout.SumCheckStatement
abbrev sumcheckRoundDegrees := @TwistShout.sumcheckRoundDegrees
abbrev sumcheckInitialRoundConsistent := @TwistShout.sumcheckInitialRoundConsistent
abbrev sumcheckFoldConsistent := @TwistShout.sumcheckFoldConsistent
abbrev sumcheckFinalConsistent := @TwistShout.sumcheckFinalConsistent
abbrev sumcheckVerifierAccepted := @TwistShout.sumcheckVerifierAccepted

theorem eval_bindHead
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K)
  (c : K)
  (x : Fin n → K) :
  MvPolynomial.eval x (bindHead (K := K) g c) =
    MvPolynomial.eval (Fin.cases c x) g :=
  TwistShout.eval_bindHead (K := K) g c x

theorem hypercubeSum_bindHead
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K)
  (c : K) :
  hypercubeSum (K := K) (bindHead (K := K) g c) =
    ∑ tail : Cube n, MvPolynomial.eval (Fin.cases c (bitVec (K := K) tail)) g :=
  TwistShout.hypercubeSum_bindHead (K := K) g c

theorem hypercubeSum_split_head
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K) :
  hypercubeSum (K := K) g =
    hypercubeSum (K := K) (bindHead (K := K) g 0) +
      hypercubeSum (K := K) (bindHead (K := K) g 1) :=
  TwistShout.hypercubeSum_split_head (K := K) g

theorem firstRoundPoly_eval
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K)
  (c : K) :
  (firstRoundPoly (K := K) g).eval c =
    hypercubeSum (K := K) (bindHead (K := K) g c) :=
  TwistShout.firstRoundPoly_eval (K := K) g c

theorem firstRoundPoly_zero_one
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K) :
  (firstRoundPoly (K := K) g).eval 0 + (firstRoundPoly (K := K) g).eval 1 =
    hypercubeSum (K := K) g :=
  TwistShout.firstRoundPoly_zero_one (K := K) g

theorem honestRoundPolys_zero
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K)
  (challenges : Fin (n + 1) → K) :
  honestRoundPolys (K := K) g challenges 0 = firstRoundPoly (K := K) g :=
  TwistShout.honestRoundPolys_zero (K := K) g challenges

theorem honestRoundPolys_succ
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K)
  (challenges : Fin (n + 1) → K)
  (i : Fin n) :
  honestRoundPolys (K := K) g challenges i.succ =
    honestRoundPolys (K := K) (bindHead (K := K) g (challenges 0))
      (tailChallenges challenges) i :=
  TwistShout.honestRoundPolys_succ (K := K) g challenges i

theorem tailTranscript_honestTranscript
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K)
  (challenges : Fin (n + 1) → K) :
  tailTranscript (K := K) (honestTranscript (K := K) g challenges) =
    honestTranscript (K := K) (bindHead (K := K) g (challenges 0)) (tailChallenges challenges) :=
  TwistShout.tailTranscript_honestTranscript (K := K) g challenges

@[simp] theorem hypercubeSum_zero_eval
  {K : Type*} [Field K]
  (g : MvPolynomial (Fin 0) K)
  (x : Fin 0 → K) :
  hypercubeSum (K := K) g = MvPolynomial.eval x g :=
  TwistShout.hypercubeSum_zero_eval (K := K) g x

theorem honestTranscript_lastEval_pos
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin (n + 1)) K)
  (challenges : Fin (n + 1) → K) :
  ((honestTranscript (K := K) g challenges).roundPolys (Fin.last n)).eval
      (challenges (Fin.last n)) =
    MvPolynomial.eval challenges g :=
  TwistShout.honestTranscript_lastEval_pos (K := K) g challenges

theorem honestTranscript_roundDegrees
  {K : Type*} [Field K]
  {n : Nat}
  {inst : SumCheckInstance (K := K) n}
  (stmt : SumCheckStatement inst)
  (challenges : Fin n → K) :
  sumcheckRoundDegrees inst (honestTranscript (K := K) stmt.polynomial challenges) :=
  TwistShout.honestTranscript_roundDegrees (K := K) stmt challenges

theorem honestTranscript_initialRoundConsistent
  {K : Type*} [Field K]
  {n : Nat}
  {inst : SumCheckInstance (K := K) n}
  (stmt : SumCheckStatement inst)
  (challenges : Fin n → K) :
  sumcheckInitialRoundConsistent inst (honestTranscript (K := K) stmt.polynomial challenges) :=
  TwistShout.honestTranscript_initialRoundConsistent (K := K) stmt challenges

theorem honestTranscript_foldConsistent
  {K : Type*} [Field K]
  {n : Nat}
  (g : MvPolynomial (Fin n) K)
  (challenges : Fin n → K) :
  sumcheckFoldConsistent (honestTranscript (K := K) g challenges) :=
  TwistShout.honestTranscript_foldConsistent (K := K) g challenges

theorem honestTranscript_finalConsistent
  {K : Type*} [Field K]
  {n : Nat}
  {inst : SumCheckInstance (K := K) n}
  (stmt : SumCheckStatement inst)
  (challenges : Fin n → K) :
  sumcheckFinalConsistent stmt (honestTranscript (K := K) stmt.polynomial challenges) :=
  TwistShout.honestTranscript_finalConsistent (K := K) stmt challenges

theorem honestTranscript_verifierAccepted
  {K : Type*} [Field K]
  {n : Nat}
  {inst : SumCheckInstance (K := K) n}
  (stmt : SumCheckStatement inst)
  (challenges : Fin n → K) :
  sumcheckVerifierAccepted stmt (honestTranscript (K := K) stmt.polynomial challenges) :=
  TwistShout.honestTranscript_verifierAccepted (K := K) stmt challenges

end

end SumCheckInterface

end TwistShout
