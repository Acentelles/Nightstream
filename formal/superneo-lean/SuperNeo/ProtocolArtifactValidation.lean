import SuperNeo.ProtocolTheorem
import SuperNeo.Generated.ProtocolArtifacts

namespace SuperNeo

open F
open SuperNeo.Generated

private def toF (x : Nat) : F := F.ofNat x

private def toFArray (xs : Array Nat) : Array F :=
  xs.map toF

private def toFMatrix (m : Array (Array Nat)) : Array (Array F) :=
  m.map toFArray

private def protocolVecHom : VecModuleHom where
  map z := z

private def protocolScalarHom : ScalarModuleHom where
  map _ := 0

private theorem protocolVecHom_assumption :
  vecModuleAssumption protocolVecHom := by
  constructor
  · intro x y
    rfl
  · intro s x
    rfl

private theorem protocolScalarHom_assumption :
  scalarModuleAssumption protocolScalarHom := by
  constructor
  · intro x y
    simp [protocolScalarHom]
  · intro s x
    simp [protocolScalarHom]

def protocolArtifactCase : ProtocolArtifactCase :=
  protocolArtifactCases[0]!

def tamperedProtocolArtifactCase : ProtocolArtifactCase :=
  protocolArtifactCases[1]!

def finalProtocolArtifactCase : FinalProtocolArtifactCase :=
  finalProtocolArtifactCases[0]!

private def protocolArtifactMatrixOf (c : ProtocolArtifactCase) : Array (Array F) :=
  toFMatrix c.matrix

private def protocolArtifactROf (c : ProtocolArtifactCase) : Array F :=
  toFArray c.r

private def protocolArtifactCarrierLeftOf (c : ProtocolArtifactCase) : Coeffs :=
  toFArray c.carrierLeft

private def protocolArtifactCarrierRightOf (c : ProtocolArtifactCase) : Coeffs :=
  toFArray c.carrierRight

private def protocolArtifactInvDeltaOf (c : ProtocolArtifactCase) : Coeffs :=
  protocolArtifactCarrierLeftOf c

private def protocolArtifactCsetOf (c : ProtocolArtifactCase) : Array Coeffs :=
  toFMatrix c.cset

private def protocolArtifactSamplesOf (c : ProtocolArtifactCase) : Array Coeffs :=
  toFMatrix c.samples

private def protocolArtifactXsOf (c : ProtocolArtifactCase) : Array F :=
  toFArray c.xs

private def protocolArtifactYsOf (c : ProtocolArtifactCase) : Array F :=
  toFArray c.ys

private def protocolArtifactQValsOf (c : ProtocolArtifactCase) : Array F :=
  toFArray c.qVals

private def protocolArtifactCoeffsOf (c : ProtocolArtifactCase) : Array F :=
  toFArray c.coeffs

private def protocolArtifactTranscriptOf (c : ProtocolArtifactCase) : SumCheckTranscript :=
  { challenges := toFArray c.transcriptChallenges
    roundPolys := toFMatrix c.transcriptRoundPolys }

private def protocolArtifactContextOf (c : ProtocolArtifactCase) : ProtocolTargetContext :=
  { bar := nativeBarMatrix
    m := protocolArtifactMatrixOf c
    r := protocolArtifactROf c
    rho1 := toF c.rho1
    rho2 := toF c.rho2
    hVec := protocolVecHom
    hScal := protocolScalarHom
    splitScalar := toF c.splitScalar
    kSplit := c.kSplit
    invDelta := protocolArtifactInvDeltaOf c
    cset := protocolArtifactCsetOf c
    samples := protocolArtifactSamplesOf c
    xs := protocolArtifactXsOf c
    ys := protocolArtifactYsOf c
    qVals := protocolArtifactQValsOf c
    coeffs := protocolArtifactCoeffsOf c
    xEval := toF c.xEval
    expectedEval := toF c.expectedEval }

private def protocolArtifactInstanceOf (c : ProtocolArtifactCase) : SumCheckInstance :=
  sumcheckInstanceOfContext (protocolArtifactContextOf c)

def protocolArtifactMatrix : Array (Array F) :=
  protocolArtifactMatrixOf protocolArtifactCase

def protocolArtifactR : Array F :=
  protocolArtifactROf protocolArtifactCase

def protocolArtifactCarrierLeft : Coeffs :=
  protocolArtifactCarrierLeftOf protocolArtifactCase

def protocolArtifactCarrierRight : Coeffs :=
  protocolArtifactCarrierRightOf protocolArtifactCase

def protocolArtifactInvDelta : Coeffs :=
  protocolArtifactInvDeltaOf protocolArtifactCase

def protocolArtifactCset : Array Coeffs :=
  protocolArtifactCsetOf protocolArtifactCase

def protocolArtifactSamples : Array Coeffs :=
  protocolArtifactSamplesOf protocolArtifactCase

def protocolArtifactXs : Array F :=
  protocolArtifactXsOf protocolArtifactCase

def protocolArtifactYs : Array F :=
  protocolArtifactYsOf protocolArtifactCase

def protocolArtifactQVals : Array F :=
  protocolArtifactQValsOf protocolArtifactCase

def protocolArtifactCoeffs : Array F :=
  protocolArtifactCoeffsOf protocolArtifactCase

def protocolArtifactTranscript : SumCheckTranscript :=
  protocolArtifactTranscriptOf protocolArtifactCase

private theorem protocolArtifactCset_size :
  protocolArtifactCset.size = 1 := by
  native_decide

private theorem protocolArtifactSamples_size :
  protocolArtifactSamples.size = 1 := by
  native_decide

private theorem protocolArtifactXs_size :
  protocolArtifactXs.size = 2 := by
  native_decide

private theorem protocolArtifactYs_size :
  protocolArtifactYs.size = 2 := by
  native_decide

private theorem protocolArtifactCoeffs_size :
  protocolArtifactCoeffs.size = 2 := by
  native_decide

private theorem protocolArtifactTranscriptChallenges_size :
  protocolArtifactTranscript.challenges.size = 1 := by
  native_decide

private theorem protocolArtifactTranscriptRoundPolys_size :
  protocolArtifactTranscript.roundPolys.size = 1 := by
  native_decide

def protocolArtifactContext : ProtocolTargetContext :=
  protocolArtifactContextOf protocolArtifactCase

def protocolArtifactInstance : SumCheckInstance :=
  protocolArtifactInstanceOf protocolArtifactCase

private def coeffsBoundedExec (entries : Array Coeffs) (bound : Nat) : Bool :=
  (List.range entries.size).all fun i =>
    decide (normInfCoeffs entries[i]! ≤ bound)

private def protocolPolyEvalExec (coeffs : Array F) (x : F) : F :=
  coeffs.foldr (fun coeff acc => coeff + x * acc) 0

private def protocolInterpolatesOnExec (xs ys coeffs : Array F) : Bool :=
  decide (xs.size = ys.size ∧ coeffs.size = xs.size) &&
    (List.range xs.size).all fun i =>
      decide (protocolPolyEvalExec coeffs xs[i]! = ys[i]!)

private def protocolArtifactSamplingCheckOf (c : ProtocolArtifactCase) : Bool :=
  coeffsBoundedExec (protocolArtifactCsetOf c) c.samplingBound &&
    coeffsBoundedExec (protocolArtifactSamplesOf c) c.samplingBound

private def protocolArtifactInterpCheckOf (c : ProtocolArtifactCase) : Bool :=
  protocolInterpolatesOnExec
      (protocolArtifactXsOf c)
      (protocolArtifactYsOf c)
      (protocolArtifactCoeffsOf c) &&
    decide
      (protocolPolyEvalExec (protocolArtifactCoeffsOf c) (protocolArtifactContextOf c).xEval =
        (protocolArtifactContextOf c).expectedEval)

private def protocolArtifactTranscriptBasicCheckOf (c : ProtocolArtifactCase) : Bool :=
  let tr := protocolArtifactTranscriptOf c
  let inst := protocolArtifactInstanceOf c
  decide
      (tr.challenges.size = inst.rounds) &&
    decide
      (tr.roundPolys.size = inst.rounds) &&
    decide (inst.maxDegree ≤ inst.domainSize) &&
    decide
      (inst.rounds = 0 ∨ 0 < inst.maxDegree) &&
    (List.range tr.roundPolys.size).all fun i =>
      decide
        (tr.roundPolys[i]!.size =
          inst.maxDegree + 1) &&
    if hZero : tr.roundPolys.size = 0 then
      true
    else
      decide
        (sumcheckEvalPoly (tr.roundPolys[0]!) 0 +
            sumcheckEvalPoly (tr.roundPolys[0]!) 1 =
          inst.claimedValue)

private def sumcheckFoldCheck (tr : SumCheckTranscript) : Bool :=
  decide (tr.challenges.size = tr.roundPolys.size) &&
    (List.range tr.roundPolys.size).all fun i =>
      if h : i + 1 < tr.roundPolys.size then
        decide (
          sumcheckEvalPoly (tr.roundPolys[i + 1]!) 0 +
              sumcheckEvalPoly (tr.roundPolys[i + 1]!) 1 =
            sumcheckEvalPoly (tr.roundPolys[i]!) (tr.challenges[i]!))
      else
        true

private def protocolArtifactWitnessCheckOf (c : ProtocolArtifactCase) : Bool :=
  protocolArtifactTranscriptBasicCheckOf c && sumcheckFoldCheck (protocolArtifactTranscriptOf c)

def protocolArtifactSamplingCheck : Bool :=
  protocolArtifactSamplingCheckOf protocolArtifactCase

def protocolArtifactInterpCheck : Bool :=
  protocolArtifactInterpCheckOf protocolArtifactCase

def protocolArtifactTranscriptBasicCheck : Bool :=
  protocolArtifactTranscriptBasicCheckOf protocolArtifactCase

def protocolArtifactWitnessCheck : Bool :=
  protocolArtifactWitnessCheckOf protocolArtifactCase

def allProtocolArtifactChecksOf (c : ProtocolArtifactCase) : Bool :=
  protocolArtifactSamplingCheckOf c &&
    protocolArtifactInterpCheckOf c &&
    protocolArtifactWitnessCheckOf c

def allProtocolArtifactChecks : Bool :=
  allProtocolArtifactChecksOf protocolArtifactCase

def tamperedProtocolArtifactChecks : Bool :=
  allProtocolArtifactChecksOf tamperedProtocolArtifactCase

theorem protocolArtifactSamplingCheck_true :
  protocolArtifactSamplingCheck = true := by
  native_decide

theorem protocolArtifactInterpCheck_true :
  protocolArtifactInterpCheck = true := by
  native_decide

theorem tamperedProtocolArtifactChecks_false :
  tamperedProtocolArtifactChecks = false := by
  native_decide

private theorem protocolArtifactSplitScalarBound :
  protocolArtifactContext.splitScalar.val < 2 ^ protocolArtifactContext.kSplit := by
  native_decide

private theorem protocolArtifactMleSize :
  protocolArtifactContext.qVals.size = 2 ^ protocolArtifactContext.r.size := by
  native_decide

private theorem protocolArtifactCarrierLeft_paper :
  paperCarrier protocolArtifactCarrierLeft := by
  unfold paperCarrier ringNormCarrier hasRingDegreeShape
    protocolArtifactCarrierLeft protocolArtifactCarrierLeftOf toFArray toF
  constructor <;> native_decide

private theorem protocolArtifactCarrierRight_paper :
  paperCarrier protocolArtifactCarrierRight := by
  unfold paperCarrier ringNormCarrier hasRingDegreeShape
    protocolArtifactCarrierRight protocolArtifactCarrierRightOf toFArray toF
  constructor <;> native_decide

private theorem protocolArtifactInvDelta_diff :
  samplingDiffSet paperCarrier protocolArtifactContext.invDelta := by
  refine ⟨protocolArtifactCarrierLeft, protocolArtifactCarrierRight, ?_, ?_, ?_⟩
  · exact protocolArtifactCarrierLeft_paper
  · exact protocolArtifactCarrierRight_paper
  · native_decide

private theorem protocolArtifactInvDelta_ne_zero :
  protocolArtifactContext.invDelta ≠ zeroRq := by
  native_decide

private theorem protocolArtifactSampling :
  samplingExpansionProp protocolArtifactCset protocolArtifactSamples := by
  refine ⟨protocolArtifactCase.samplingBound, ?_⟩
  constructor
  · intro i
    have hi_lt : i.1 < 1 := by
      simpa [protocolArtifactCset_size] using i.2
    have hi0 : i.1 = 0 := by omega
    have hiEq : i = ⟨0, by simpa [protocolArtifactCset_size] using i.2⟩ := by
      apply Fin.ext
      simpa using hi0
    subst hiEq
    have h0 : normInfCoeffs protocolArtifactCset[0] ≤ protocolArtifactCase.samplingBound := by
      native_decide +revert
    exact h0
  · intro j
    have hj_lt : j.1 < 1 := by
      simpa [protocolArtifactSamples_size] using j.2
    have hj0 : j.1 = 0 := by omega
    have hjEq : j = ⟨0, by simpa [protocolArtifactSamples_size] using j.2⟩ := by
      apply Fin.ext
      simpa using hj0
    subst hjEq
    have h0 : normInfCoeffs protocolArtifactSamples[0] ≤ protocolArtifactCase.samplingBound := by
      native_decide +revert
    exact h0

private theorem protocolArtifactXs_distinct :
  interpolationNodesDistinct protocolArtifactXs := by
  intro i j hij
  have hi_lt : i.1 < 2 := by
    simpa [protocolArtifactXs_size] using i.2
  have hj_lt : j.1 < 2 := by
    simpa [protocolArtifactXs_size] using j.2
  have hi : i.1 = 0 ∨ i.1 = 1 := by omega
  have hj : j.1 = 0 ∨ j.1 = 1 := by omega
  rcases hi with hi0 | hi1 <;> rcases hj with hj0 | hj1
  · exact False.elim (hij (Fin.ext (by simpa [hi0, hj0])))
  · have h01 : protocolArtifactXs[0]! ≠ protocolArtifactXs[1]! := by
      native_decide +revert
    have hiEq : i = ⟨0, by simpa [protocolArtifactXs_size] using i.2⟩ := by
      apply Fin.ext
      simpa using hi0
    have hjEq : j = ⟨1, by simpa [protocolArtifactXs_size] using j.2⟩ := by
      apply Fin.ext
      simpa using hj1
    subst hiEq
    subst hjEq
    exact h01
  · have h10 : protocolArtifactXs[1]! ≠ protocolArtifactXs[0]! := by
      native_decide +revert
    have hiEq : i = ⟨1, by simpa [protocolArtifactXs_size] using i.2⟩ := by
      apply Fin.ext
      simpa using hi1
    have hjEq : j = ⟨0, by simpa [protocolArtifactXs_size] using j.2⟩ := by
      apply Fin.ext
      simpa using hj0
    subst hiEq
    subst hjEq
    exact h10
  · exact False.elim (hij (Fin.ext (by simpa [hi1, hj1])))

private theorem protocolArtifactPolyEval_x0 :
  polyEval protocolArtifactCoeffs (protocolArtifactXs[0]!) = protocolArtifactYs[0]! := by
  apply fToZMod_injective
  simpa [protocolArtifactCoeffs, protocolArtifactCoeffsOf, protocolArtifactXs, protocolArtifactXsOf,
    protocolArtifactYs, protocolArtifactYsOf, protocolArtifactCase, protocolArtifactCases,
    toFArray, toF,
    polyEval, coeffArrayPolynomial, Polynomial.ofFn] using
    (show Polynomial.eval (fToZMod 0) { toFinsupp := [0, 1].toFinsupp } = fToZMod 0 by
      native_decide)

private theorem protocolArtifactPolyEval_x1 :
  polyEval protocolArtifactCoeffs (protocolArtifactXs[1]!) = protocolArtifactYs[1]! := by
  apply fToZMod_injective
  simpa [protocolArtifactCoeffs, protocolArtifactCoeffsOf, protocolArtifactXs, protocolArtifactXsOf,
    protocolArtifactYs, protocolArtifactYsOf, protocolArtifactCase, protocolArtifactCases,
    toFArray, toF,
    polyEval, coeffArrayPolynomial, Polynomial.ofFn] using
    (show Polynomial.eval (fToZMod 1) { toFinsupp := [0, 1].toFinsupp } = fToZMod 1 by
      native_decide)

private theorem protocolArtifactPolyEval_expected :
  polyEval protocolArtifactCoeffs protocolArtifactContext.xEval =
    protocolArtifactContext.expectedEval := by
  apply fToZMod_injective
  simpa [protocolArtifactCoeffs, protocolArtifactCoeffsOf, protocolArtifactContext,
    protocolArtifactContextOf, protocolArtifactCase, protocolArtifactCases, toFArray, toF,
    polyEval, coeffArrayPolynomial, Polynomial.ofFn] using
    (show Polynomial.eval (fToZMod 2) { toFinsupp := [0, 1].toFinsupp } = fToZMod 2 by
      native_decide)

private theorem protocolArtifactInterpolation :
  interpolationProp
    protocolArtifactXs
    protocolArtifactYs
    protocolArtifactCoeffs
    protocolArtifactContext.xEval
    protocolArtifactContext.expectedEval := by
  refine interpolationProp_intro protocolArtifactXs_distinct ?_ protocolArtifactPolyEval_expected
  refine ⟨protocolArtifactXs_size.trans protocolArtifactYs_size.symm, by
    calc
      protocolArtifactCoeffs.size = 2 := protocolArtifactCoeffs_size
      _ = protocolArtifactXs.size := protocolArtifactXs_size.symm, ?_⟩
  intro i
  have hi_lt : i.1 < 2 := by
    simpa [protocolArtifactXs_size] using i.2
  have hi : i.1 = 0 ∨ i.1 = 1 := by omega
  rcases hi with hi0 | hi1
  · simpa [protocolArtifactXs, protocolArtifactXsOf, protocolArtifactYs, protocolArtifactYsOf,
      protocolArtifactCase, protocolArtifactCases,
      toFArray, toF, hi0]
      using protocolArtifactPolyEval_x0
  · simpa [protocolArtifactXs, protocolArtifactXsOf, protocolArtifactYs, protocolArtifactYsOf,
      protocolArtifactCase, protocolArtifactCases,
      toFArray, toF, hi1]
      using protocolArtifactPolyEval_x1

def protocolArtifactArithmetic :
  ArithmeticObligations
    protocolArtifactContext.bar
    protocolArtifactContext.m
    protocolArtifactContext.r
    protocolArtifactContext.rho1
    protocolArtifactContext.rho2
    protocolArtifactContext.hVec
    protocolArtifactContext.hScal
    protocolArtifactContext.splitScalar
    protocolArtifactContext.kSplit
    protocolArtifactContext.cset
    protocolArtifactContext.samples
    protocolArtifactContext.xs
    protocolArtifactContext.ys
    protocolArtifactContext.qVals
    protocolArtifactContext.coeffs
    protocolArtifactContext.xEval
    protocolArtifactContext.expectedEval :=
  ArithmeticObligations.of_constructive
    (hSplit := protocolArtifactSplitScalarBound)
    (hVecAssm := protocolVecHom_assumption)
    (hScalAssm := protocolScalarHom_assumption)
    (hSampling := protocolArtifactSampling)
    (hMleSize := protocolArtifactMleSize)
    (hInterp := protocolArtifactInterpolation)

def protocolArtifactTargetData :
  ProtocolTargetData protocolArtifactContext :=
  ProtocolTargetData.ofNativePaperCarrierDiff
    rfl
    protocolArtifactArithmetic
    protocolArtifactInvDelta_diff
    protocolArtifactInvDelta_ne_zero

private theorem protocolArtifactAccepted :
  SumCheckAccepted protocolArtifactInstance protocolArtifactTranscript := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · unfold sumcheckParameterConsistent
    native_decide
  · right
    native_decide
  · unfold sumcheckRoundConsistent
    constructor
    · simpa using protocolArtifactTranscriptChallenges_size
    · simpa using protocolArtifactTranscriptRoundPolys_size
  · intro i
    have hi_lt : i.1 < 1 := by
      simpa [protocolArtifactTranscriptRoundPolys_size] using i.2
    have hi0 : i.1 = 0 := by omega
    have hiEq : i = ⟨0, by simpa [protocolArtifactTranscriptRoundPolys_size] using i.2⟩ := by
      apply Fin.ext
      simpa using hi0
    subst hiEq
    unfold sumcheckRoundPolyShape
    native_decide
  · unfold sumcheckInitialRoundConsistent
    have hNonzero : protocolArtifactTranscript.roundPolys.size ≠ 0 := by
      simpa [protocolArtifactTranscriptRoundPolys_size]
    simpa [hNonzero] using
      (show sumcheckEvalPoly (protocolArtifactTranscript.roundPolys[0]!) 0 +
          sumcheckEvalPoly (protocolArtifactTranscript.roundPolys[0]!) 1 =
            protocolArtifactInstance.claimedValue by
        native_decide)
  · constructor
    · simpa [protocolArtifactTranscriptChallenges_size, protocolArtifactTranscriptRoundPolys_size]
    · intro i hi
      have hi' : i + 1 < 1 := by
        simpa [protocolArtifactTranscriptRoundPolys_size] using hi
      have : False := by omega
      exact this.elim

private theorem protocolArtifactInitialRound :
  sumcheckInitialRoundConsistent protocolArtifactInstance protocolArtifactTranscript := by
  unfold sumcheckInitialRoundConsistent
  have hNonzero : protocolArtifactTranscript.roundPolys.size ≠ 0 := by
    simpa [protocolArtifactTranscriptRoundPolys_size]
  simpa [hNonzero] using
    (show sumcheckEvalPoly (protocolArtifactTranscript.roundPolys[0]!) 0 +
        sumcheckEvalPoly (protocolArtifactTranscript.roundPolys[0]!) 1 =
          protocolArtifactInstance.claimedValue by
      native_decide)

def protocolArtifactWitness :
  SumCheckTransitionWitness protocolArtifactContext :=
  { transcript := protocolArtifactTranscript
    accepted := protocolArtifactAccepted
    initialRound := protocolArtifactInitialRound
    roundSumStep := by
      intro i hi
      have hi' : i + 1 < 1 := by
        simpa [protocolArtifactTranscriptRoundPolys_size] using hi
      have : False := by omega
      exact this.elim }

theorem protocolArtifact_protocolTargetProp :
  protocolTargetProp protocolArtifactContext :=
  protocolTargetProp_of_data protocolArtifactTargetData

theorem protocolArtifact_ccsRelation :
  ccsRelation protocolArtifactContext :=
  ccsRelation_of_protocolTargetData protocolArtifactTargetData

theorem protocolArtifact_ceRelation :
  ceRelation protocolArtifactContext :=
  ceRelation_of_protocolTargetData protocolArtifactTargetData protocolArtifactWitness

theorem protocolArtifact_piCCS :
  piCCSStrongStatement protocolArtifactContext :=
  piCCSStrong_of_protocolTargetData protocolArtifactTargetData protocolArtifactWitness

theorem protocolArtifact_piRLC :
  piRLCWeakStatement protocolArtifactContext :=
  piRLCWeak_of_protocolTargetData protocolArtifactTargetData protocolArtifactWitness

theorem protocolArtifact_piDEC :
  piDECKnowledgeStatement protocolArtifactContext :=
  piDEC_of_protocolTargetData protocolArtifactTargetData protocolArtifactWitness

theorem protocolArtifact_finalRoute
  (hMsis :
    msisHardnessAssumption
      (SuperNeo.ProofSystem.goldilocksPaperAjtaiParams finalProtocolArtifactCase.messageLength)) :
  FinalTheoremShape protocolArtifactContext
    (FinalTheoremAssumptions.ofGoldilocksNativePaperCarrierDiffBoundaryPackages
      finalProtocolArtifactCase.messageLength
      rfl
      protocolArtifactArithmetic
      protocolArtifactInvDelta_diff
      protocolArtifactInvDelta_ne_zero
      protocolArtifactWitness
      hMsis) := by
  exact finalTheoremShape_of_goldilocksNativePaperCarrierDiffBoundaryPackages
    finalProtocolArtifactCase.messageLength
    rfl
    protocolArtifactArithmetic
    protocolArtifactInvDelta_diff
    protocolArtifactInvDelta_ne_zero
    protocolArtifactWitness
    hMsis

theorem allProtocolArtifactChecks_true :
  allProtocolArtifactChecks = true := by
  native_decide

end SuperNeo
