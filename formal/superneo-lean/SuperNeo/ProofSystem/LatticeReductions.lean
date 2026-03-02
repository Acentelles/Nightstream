import SuperNeo.ProofSystem.Lattice

namespace SuperNeo.ProofSystem

/-- Norm-transfer boundary for extracted witness from a standard binding collision. -/
theorem bindingCollision_subWitness_norm_lt_msisNormBound
  {params : AjtaiParams}
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : BindingCollision params) :
  normInfVec (subVec params.msgLen coll.opening1.witness coll.opening2.witness) <
    params.msisNormBound := by
  rcases coll.opens1 with ⟨_hCwf1, _hOwf1, hNs1, _hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, _hOwf2, hNs2, _hEq2⟩

  have hSubLe :
      normInfVec (subVec params.msgLen coll.opening1.witness coll.opening2.witness) ≤
        coll.opening1.normBound + coll.opening2.normBound := by
    have h :=
      normInfVec_subVec_le (n := params.msgLen)
        coll.opening1.witness coll.opening2.witness
    exact Nat.le_trans h (Nat.add_le_add hNs1 hNs2)

  have hSumLt :
      coll.opening1.normBound + coll.opening2.normBound <
        params.bindingNormBound + params.bindingNormBound :=
    Nat.add_lt_add coll.bounded1 coll.bounded2

  have hLtBB :
      normInfVec (subVec params.msgLen coll.opening1.witness coll.opening2.witness) <
        params.bindingNormBound + params.bindingNormBound :=
    Nat.lt_of_le_of_lt hSubLe hSumLt

  have h1le : 1 ≤ params.relaxedExpansion :=
    Nat.succ_le_of_lt hExpPos

  have h8le : 8 ≤ 8 * params.relaxedExpansion := by
    simpa using (Nat.mul_le_mul_left 8 h1le)

  have h2le8 : (2 : Nat) ≤ 8 := by decide
  have h2le : (2 : Nat) ≤ 8 * params.relaxedExpansion :=
    Nat.le_trans h2le8 h8le

  have hBBLe : params.bindingNormBound + params.bindingNormBound ≤ params.msisNormBound := by
    unfold AjtaiParams.msisNormBound
    have h := Nat.mul_le_mul_right params.bindingNormBound h2le
    simpa [Nat.two_mul, Nat.mul_assoc] using h

  exact Nat.lt_of_lt_of_le hLtBB hBBLe

/-- Norm-transfer boundary for extracted witness from a relaxed binding collision. -/
theorem relaxedBindingCollision_subWitness_norm_lt_msisNormBound
  {params : AjtaiParams}
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : RelaxedBindingCollision params) :
  normInfVec
      (subVec params.msgLen
        (smulVec coll.delta1 coll.opening2.witness)
        (smulVec coll.delta2 coll.opening1.witness)) <
    params.msisNormBound := by
  rcases coll.opens1 with ⟨_hCwf1, _hOwf1, hNs1, _hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, _hOwf2, hNs2, _hEq2⟩

  have h4pos : 0 < (4 : Nat) := by decide
  have hPos : 0 < 4 * params.relaxedExpansion :=
    Nat.mul_pos h4pos hExpPos

  let w1 := smulVec coll.delta1 coll.opening2.witness
  let w2 := smulVec coll.delta2 coll.opening1.witness

  have hw1_le :
      normInfVec w1 ≤ (4 * params.relaxedExpansion) * coll.opening2.normBound := by
    have hw1' : normInfVec w1 ≤ normInfCoeffs coll.delta1 * normInfVec coll.opening2.witness := by
      simpa [w1] using (normInfVec_smulVec_le coll.delta1 coll.opening2.witness)
    have hw1'' :
        normInfVec w1 ≤ normInfCoeffs coll.delta1 * coll.opening2.normBound := by
      exact Nat.le_trans hw1' (Nat.mul_le_mul_left _ hNs2)
    have hδ1 : normInfCoeffs coll.delta1 ≤ 4 * params.relaxedExpansion :=
      Nat.le_of_lt coll.deltaBound1
    exact Nat.le_trans hw1'' (Nat.mul_le_mul_right coll.opening2.normBound hδ1)

  have hw2_le :
      normInfVec w2 ≤ (4 * params.relaxedExpansion) * coll.opening1.normBound := by
    have hw2' : normInfVec w2 ≤ normInfCoeffs coll.delta2 * normInfVec coll.opening1.witness := by
      simpa [w2] using (normInfVec_smulVec_le coll.delta2 coll.opening1.witness)
    have hw2'' :
        normInfVec w2 ≤ normInfCoeffs coll.delta2 * coll.opening1.normBound := by
      exact Nat.le_trans hw2' (Nat.mul_le_mul_left _ hNs1)
    have hδ2 : normInfCoeffs coll.delta2 ≤ 4 * params.relaxedExpansion :=
      Nat.le_of_lt coll.deltaBound2
    exact Nat.le_trans hw2'' (Nat.mul_le_mul_right coll.opening1.normBound hδ2)

  have hsub_le :
      normInfVec (subVec params.msgLen w1 w2) ≤ normInfVec w1 + normInfVec w2 :=
    normInfVec_subVec_le (n := params.msgLen) w1 w2

  have htotal_le :
      normInfVec (subVec params.msgLen w1 w2) ≤
        (4 * params.relaxedExpansion) * coll.opening2.normBound +
        (4 * params.relaxedExpansion) * coll.opening1.normBound := by
    exact Nat.le_trans hsub_le (Nat.add_le_add hw1_le hw2_le)

  have h1lt :
      (4 * params.relaxedExpansion) * coll.opening2.normBound <
        (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.mul_lt_mul_of_pos_left coll.bounded2 hPos

  have h2lt :
      (4 * params.relaxedExpansion) * coll.opening1.normBound <
        (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.mul_lt_mul_of_pos_left coll.bounded1 hPos

  have hsumlt :
      (4 * params.relaxedExpansion) * coll.opening2.normBound +
      (4 * params.relaxedExpansion) * coll.opening1.normBound <
      (4 * params.relaxedExpansion) * params.bindingNormBound +
      (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.add_lt_add h1lt h2lt

  have hlt :
      normInfVec (subVec params.msgLen w1 w2) <
      (4 * params.relaxedExpansion) * params.bindingNormBound +
      (4 * params.relaxedExpansion) * params.bindingNormBound :=
    Nat.lt_of_le_of_lt htotal_le hsumlt

  have hRhs :
      (4 * params.relaxedExpansion) * params.bindingNormBound +
      (4 * params.relaxedExpansion) * params.bindingNormBound =
      params.msisNormBound := by
    unfold AjtaiParams.msisNormBound
    calc
      (4 * params.relaxedExpansion) * params.bindingNormBound +
          (4 * params.relaxedExpansion) * params.bindingNormBound
          = 2 * ((4 * params.relaxedExpansion) * params.bindingNormBound) := by
              simpa using
                (Eq.symm (Nat.two_mul ((4 * params.relaxedExpansion) * params.bindingNormBound)))
      _ = (2 * (4 * params.relaxedExpansion)) * params.bindingNormBound := by
              simp [Nat.mul_assoc]
      _ = (8 * params.relaxedExpansion) * params.bindingNormBound := by
              simp [Nat.mul_left_comm, Nat.mul_comm]
      _ = 8 * params.relaxedExpansion * params.bindingNormBound := by
              simp [Nat.mul_assoc]

  exact lt_of_lt_of_eq hlt hRhs

/--
Extractor: a standard Ajtai binding collision yields a homogeneous MSIS witness.
-/
theorem msisBreakEvent_of_bindingCollision
  {params : AjtaiParams}
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : BindingCollision params) :
  MSISBreakEvent params := by
  rcases coll.opens1 with ⟨hCwf1, hOwf1, _hNs1, hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, hOwf2, _hNs2, hEq2⟩
  let chal : MSISChallenge params :=
    ⟨Commitment.ppMatrixFlat params coll.commitment, zeroVec params.kappa⟩
  refine ⟨chal, rfl, ?_⟩
  let w := subVec params.msgLen coll.opening1.witness coll.opening2.witness
  refine ⟨{
    witness := w
    bounded := ?_
    satisfies := ?_
  }⟩
  · refine ⟨by simp [w], ?_, ?_⟩
    · have hwNeZero :
        subVec params.msgLen coll.opening1.witness coll.opening2.witness ≠
          zeroVec params.msgLen := by
        exact subVec_ne_zero_of_ne params.msgLen coll.opening1.witness coll.opening2.witness
          (by simpa [Opening.WellFormed] using hOwf1)
          (by simpa [Opening.WellFormed] using hOwf2)
          coll.distinct
      simpa [w, zeroVec] using hwNeZero
    · simpa [w] using
        bindingCollision_subWitness_norm_lt_msisNormBound (params := params) hExpPos coll
  · refine ⟨?_, ?_⟩
    · refine ⟨?_, ?_⟩
      · exact Commitment.ppMatrixFlat_size_of_wf (params := params) (c := coll.commitment) hCwf1
      · simp [chal, zeroVec]
    · calc
        matVecMul params chal.matrix w
            = subVec params.kappa
                (matVecMul params chal.matrix coll.opening1.witness)
                (matVecMul params chal.matrix coll.opening2.witness) := by
                simpa [w] using
                  matVecMul_subVec params chal.matrix coll.opening1.witness coll.opening2.witness
        _ = subVec params.kappa
              (Commitment.valueVec params coll.commitment)
              (Commitment.valueVec params coll.commitment) := by
              simp [chal, hEq1, hEq2]
        _ = zeroVec params.kappa := by
              simpa using subVec_self params.kappa (Commitment.valueVec params coll.commitment)
        _ = chal.target := by
              rfl

/--
Extractor: a relaxed Ajtai binding collision yields a homogeneous MSIS witness.
-/
theorem msisBreakEvent_of_relaxedBindingCollision
  {params : AjtaiParams}
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : RelaxedBindingCollision params) :
  MSISBreakEvent params := by
  rcases coll.opens1 with ⟨hCwf1, hOwf1, _hNs1, hEq1⟩
  rcases coll.opens2 with ⟨_hCwf2, hOwf2, _hNs2, hEq2⟩
  let chal : MSISChallenge params :=
    ⟨Commitment.ppMatrixFlat params coll.commitment, zeroVec params.kappa⟩
  refine ⟨chal, rfl, ?_⟩
  let w1 := smulVec coll.delta1 coll.opening2.witness
  let w2 := smulVec coll.delta2 coll.opening1.witness
  let w := subVec params.msgLen w1 w2
  refine ⟨{
    witness := w
    bounded := ?_
    satisfies := ?_
  }⟩
  · refine ⟨by simp [w], ?_, ?_⟩
    · have hwNeZero : subVec params.msgLen w1 w2 ≠ zeroVec params.msgLen := by
        have hw1Size : w1.size = params.msgLen := by
          simpa [w1, smulVec, Opening.WellFormed] using hOwf2
        have hw2Size : w2.size = params.msgLen := by
          simpa [w2, smulVec, Opening.WellFormed] using hOwf1
        exact subVec_ne_zero_of_ne params.msgLen w1 w2
          hw1Size
          hw2Size
          (by simpa [w1, w2] using coll.distinct)
      simpa [w, zeroVec] using hwNeZero
    · simpa [w, w1, w2] using
        relaxedBindingCollision_subWitness_norm_lt_msisNormBound (params := params) hExpPos coll
  · refine ⟨?_, ?_⟩
    · refine ⟨?_, ?_⟩
      · exact Commitment.ppMatrixFlat_size_of_wf (params := params) (c := coll.commitment) hCwf1
      · simp [chal, zeroVec]
    · calc
        matVecMul params chal.matrix w
            = subVec params.kappa
                (matVecMul params chal.matrix w1)
                (matVecMul params chal.matrix w2) := by
                simpa [w] using matVecMul_subVec params chal.matrix w1 w2
        _ = subVec params.kappa
              (smulVec coll.delta1 (matVecMul params chal.matrix coll.opening2.witness))
              (smulVec coll.delta2 (matVecMul params chal.matrix coll.opening1.witness)) := by
              simp [w1, w2, matVecMul_smulVec]
        _ = subVec params.kappa
              (smulVec coll.delta1 (smulVec coll.delta2 (Commitment.valueVec params coll.commitment)))
              (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment))) := by
              simp [chal, hEq1, hEq2]
        _ = subVec params.kappa
              (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment)))
              (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment))) := by
              simp [smulVec_comm]
        _ = zeroVec params.kappa := by
              simpa using
                subVec_self params.kappa
                  (smulVec coll.delta2 (smulVec coll.delta1 (Commitment.valueVec params coll.commitment)))
        _ = chal.target := by
              rfl

/-- Truth-valued probability model: `Pr P = 1` iff `P`, else `0`. -/
noncomputable def truthProb : ProbModel where
  Pr := fun P => by
    classical
    exact if P then (1 : Rat) else 0
  prNonneg := by
    intro P
    classical
    by_cases hP : P
    · simp [hP]
      exact (by decide : (0 : Rat) ≤ 1)
    · simp [hP]
      exact (by decide : (0 : Rat) ≤ 0)
  prLeOne := by
    intro P
    classical
    by_cases hP : P
    · simp [hP]
      exact (by decide : (1 : Rat) ≤ 1)
    · simp [hP]
      exact (by decide : (0 : Rat) ≤ 1)

/--
Under the current eventually-zero negligible model, MSIS hardness implies the
canonical homogeneous MSIS break event is impossible.
-/
theorem no_msisBreakEvent_of_hardness
  {params : AjtaiParams}
  (h : MSISHardnessAssumption params) :
  ¬ MSISBreakEvent params := by
  rcases h with ⟨eps, hNeg, hBound⟩
  rcases hNeg 0 with ⟨N, hZero⟩
  have hEps0 : eps N = 0 := hZero N (Nat.le_refl N)
  intro hBreak
  have hLe :
      MSISAdvantage truthProb (canonicalMSISGame params) N ≤ (eps N : Rat) :=
    hBound truthProb N
  have hAdvOne :
      MSISAdvantage truthProb (canonicalMSISGame params) N = (1 : Rat) := by
    classical
    simp [MSISAdvantage, canonicalMSISGame, truthProb, hBreak]
  have hOneLe : (1 : Rat) ≤ (eps N : Rat) := by
    simpa [hAdvOne] using hLe
  have hOneLeZero : (1 : Rat) ≤ 0 := by
    simpa [hEps0] using hOneLe
  exact (by decide : ¬ ((1 : Rat) ≤ 0)) hOneLeZero

/--
Under the current eventually-zero negligible model, an Ajtai binding-advantage
bound implies no binding collision can exist.
-/
theorem no_ajtaiBindingCollision_of_advantageBound
  {params : AjtaiParams}
  {eps : ErrorFn}
  (hBound : AjtaiBindingAdvantageBound params eps)
  (hNeg : IsNegligible eps) :
  AjtaiBindingAssumption params := by
  rcases hNeg 0 with ⟨N, hZero⟩
  have hEps0 : eps N = 0 := hZero N (Nat.le_refl N)
  intro hColl
  have hLe :
      AjtaiBindingAdvantage truthProb (canonicalAjtaiBindingGame params) N ≤ (eps N : Rat) :=
    hBound truthProb N
  have hAdvOne :
      AjtaiBindingAdvantage truthProb (canonicalAjtaiBindingGame params) N = (1 : Rat) := by
    classical
    simp [AjtaiBindingAdvantage, canonicalAjtaiBindingGame, truthProb, hColl]
  have hOneLe : (1 : Rat) ≤ (eps N : Rat) := by
    simpa [hAdvOne] using hLe
  have hOneLeZero : (1 : Rat) ≤ 0 := by
    simpa [hEps0] using hOneLe
  exact (by decide : ¬ ((1 : Rat) ≤ 0)) hOneLeZero

/--
Under the current eventually-zero negligible model, an Ajtai relaxed-binding
advantage bound implies no relaxed binding collision can exist.
-/
theorem no_ajtaiRelaxedBindingCollision_of_advantageBound
  {params : AjtaiParams}
  {eps : ErrorFn}
  (hBound : AjtaiRelaxedBindingAdvantageBound params eps)
  (hNeg : IsNegligible eps) :
  AjtaiRelaxedBindingAssumption params := by
  rcases hNeg 0 with ⟨N, hZero⟩
  have hEps0 : eps N = 0 := hZero N (Nat.le_refl N)
  intro hColl
  have hLe :
      AjtaiRelaxedBindingAdvantage truthProb (canonicalAjtaiRelaxedBindingGame params) N ≤ (eps N : Rat) :=
    hBound truthProb N
  have hAdvOne :
      AjtaiRelaxedBindingAdvantage truthProb (canonicalAjtaiRelaxedBindingGame params) N = (1 : Rat) := by
    classical
    simp [AjtaiRelaxedBindingAdvantage, canonicalAjtaiRelaxedBindingGame, truthProb, hColl]
  have hOneLe : (1 : Rat) ≤ (eps N : Rat) := by
    simpa [hAdvOne] using hLe
  have hOneLeZero : (1 : Rat) ≤ 0 := by
    simpa [hEps0] using hOneLe
  exact (by decide : ¬ ((1 : Rat) ≤ 0)) hOneLeZero

namespace AjtaiBindingBoundary

/-- Canonical hardness view for an Ajtai binding boundary package. -/
def hardness
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingAssumption params :=
  no_ajtaiBindingCollision_of_advantageBound h.advantageBound h.negligibleEpsBinding

/-- Canonical hardness derivation from package fields. -/
theorem hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingAssumption params :=
  h.hardness

/-- Normalize any package by overwriting redundant `hardness` proof from aligned fields. -/
def normalize
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingBoundary params :=
  h

theorem normalize_hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) :
  (normalize h).hardness = h.hardnessFromFields := by
  rfl

end AjtaiBindingBoundary

namespace AjtaiRelaxedBindingBoundary

/-- Canonical hardness view for an Ajtai relaxed-binding boundary package. -/
def hardness
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingAssumption params :=
  no_ajtaiRelaxedBindingCollision_of_advantageBound h.advantageBound h.negligibleEpsRelaxedBinding

/-- Canonical relaxed-hardness derivation from package fields. -/
theorem hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingAssumption params :=
  h.hardness

/-- Normalize any relaxed package by overwriting redundant `hardness` proof from aligned fields. -/
def normalize
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingBoundary params :=
  h

theorem normalize_hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) :
  (normalize h).hardness = h.hardnessFromFields := by
  rfl

end AjtaiRelaxedBindingBoundary

/--
Abstract reduction interface from MSIS hardness to Ajtai commitment security.
This remains theorem-facing only; implication theorems are derived below.
-/
structure MSISToAjtaiReductions (params : AjtaiParams) where
  relaxedExpansionPos : 0 < params.relaxedExpansion
  epsBinding : ErrorFn
  epsRelaxedBinding : ErrorFn
  bindingAdvantageBound : AjtaiBindingAdvantageBound params epsBinding
  relaxedBindingAdvantageBound : AjtaiRelaxedBindingAdvantageBound params epsRelaxedBinding
  negligibleEpsBinding : IsNegligible epsBinding
  negligibleEpsRelaxedBinding : IsNegligible epsRelaxedBinding

namespace MSISToAjtaiReductions

/-- Derived Ajtai binding boundary from MSIS hardness, via explicit extractor. -/
theorem toBinding
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params := by
  intro hColl
  rcases hColl with ⟨coll⟩
  have hBreak : MSISBreakEvent params :=
    msisBreakEvent_of_bindingCollision (params := params) hRed.relaxedExpansionPos coll
  exact (no_msisBreakEvent_of_hardness (params := params) hMsis) hBreak

/-- Derived Ajtai relaxed-binding boundary from MSIS hardness, via explicit extractor. -/
theorem toRelaxedBinding
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingAssumption params := by
  intro hColl
  rcases hColl with ⟨coll⟩
  have hBreak : MSISBreakEvent params :=
    msisBreakEvent_of_relaxedBindingCollision (params := params) hRed.relaxedExpansionPos coll
  exact (no_msisBreakEvent_of_hardness (params := params) hMsis) hBreak

end MSISToAjtaiReductions

/-- Derive Ajtai binding from MSIS via the declared reduction surface. -/
theorem ajtaiBinding_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params := by
  exact hRed.toBinding hMsis

/-- Derive Ajtai relaxed binding from MSIS via the declared reduction surface. -/
theorem ajtaiRelaxedBinding_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingAssumption params := by
  exact hRed.toRelaxedBinding hMsis

/-- Package both Ajtai boundaries derived from MSIS under one reduction interface. -/
theorem ajtaiBoundaries_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params ∧ AjtaiRelaxedBindingAssumption params := by
  exact ⟨ajtaiBinding_of_msis hRed hMsis, ajtaiRelaxedBinding_of_msis hRed hMsis⟩

/-- Build the canonical Ajtai binding boundary package from MSIS hardness + reduction surface. -/
def ajtaiBindingBoundary_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (_hMsis : MSISHardnessAssumption params) :
  AjtaiBindingBoundary params where
  epsBinding := hRed.epsBinding
  advantageBound := hRed.bindingAdvantageBound
  negligibleEpsBinding := hRed.negligibleEpsBinding

/-- Build the canonical Ajtai relaxed-binding boundary package from MSIS hardness + reduction surface. -/
def ajtaiRelaxedBindingBoundary_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (_hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingBoundary params where
  epsRelaxedBinding := hRed.epsRelaxedBinding
  advantageBound := hRed.relaxedBindingAdvantageBound
  negligibleEpsRelaxedBinding := hRed.negligibleEpsRelaxedBinding

end SuperNeo.ProofSystem

