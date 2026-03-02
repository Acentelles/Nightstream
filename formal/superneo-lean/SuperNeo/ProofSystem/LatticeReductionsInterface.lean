import SuperNeo.ProofSystem.LatticeReductions
import SuperNeo.SamplingSet

/-!
Contract interface for `SuperNeo.ProofSystem.LatticeReductions`.

Spec: `specs/ProofSystem/LatticeReductions.spec.md`
Paper: `./formal/superneo-lean/SuperNeo.pdf.md`
Anchors:
- Theorem 2 (Ajtai properties), lines 319-321.
- Definition 16 (MSIS), lines 743-744.
- Definition 18 (Ajtai commitment), lines 753-756.
-/

namespace SuperNeo
namespace ProofSystem.LatticeReductionsInterface

noncomputable section

/-! ## Reduction Boundary Package -/

abbrev MSISToAjtaiReductions := SuperNeo.ProofSystem.MSISToAjtaiReductions
abbrev LatticeReductionLaws := SuperNeo.ProofSystem.LatticeReductionLaws

/-! ## Extractor and Norm-Transfer Theorems -/

theorem bindingCollision_subWitness_norm_lt_msisNormBound
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : BindingCollision params) :
  normInfVec (subVec params.msgLen coll.opening1.witness coll.opening2.witness) <
    params.msisNormBound :=
  SuperNeo.ProofSystem.bindingCollision_subWitness_norm_lt_msisNormBound
    (params := params) laws hExpPos coll

theorem relaxedBindingCollision_subWitness_norm_lt_msisNormBound
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : RelaxedBindingCollision params) :
  normInfVec
      (subVec params.msgLen
        (smulVec coll.delta1 coll.opening2.witness)
        (smulVec coll.delta2 coll.opening1.witness)) <
    params.msisNormBound :=
  SuperNeo.ProofSystem.relaxedBindingCollision_subWitness_norm_lt_msisNormBound
    (params := params) laws hExpPos coll

theorem msisBreakEvent_of_bindingCollision
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : BindingCollision params) :
  MSISBreakEvent params :=
  SuperNeo.ProofSystem.msisBreakEvent_of_bindingCollision (params := params) laws hExpPos coll

theorem msisBreakEvent_of_relaxedBindingCollision
  {params : AjtaiParams}
  (laws : LatticeReductionLaws params)
  (hExpPos : 0 < params.relaxedExpansion)
  (coll : RelaxedBindingCollision params) :
  MSISBreakEvent params :=
  SuperNeo.ProofSystem.msisBreakEvent_of_relaxedBindingCollision
    (params := params) laws hExpPos coll

/-! ## Hardness and Binding Derivations -/

abbrev truthProb := SuperNeo.ProofSystem.truthProb

theorem no_msisBreakEvent_of_hardness
  {params : AjtaiParams}
  (h : MSISHardnessAssumption params) :
  ¬ MSISBreakEvent params :=
  SuperNeo.ProofSystem.no_msisBreakEvent_of_hardness (params := params) h

theorem no_ajtaiBindingCollision_of_advantageBound
  {params : AjtaiParams}
  {eps : ErrorFn}
  (hBound : AjtaiBindingAdvantageBound params eps)
  (hNeg : IsNegligible eps) :
  AjtaiBindingAssumption params :=
  SuperNeo.ProofSystem.no_ajtaiBindingCollision_of_advantageBound (params := params) hBound hNeg

theorem no_ajtaiRelaxedBindingCollision_of_advantageBound
  {params : AjtaiParams}
  {eps : ErrorFn}
  (hBound : AjtaiRelaxedBindingAdvantageBound params eps)
  (hNeg : IsNegligible eps) :
  AjtaiRelaxedBindingAssumption params :=
  SuperNeo.ProofSystem.no_ajtaiRelaxedBindingCollision_of_advantageBound (params := params) hBound hNeg

def AjtaiBindingBoundary_hardness
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingAssumption params :=
  h.hardness

def AjtaiBindingBoundary_hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiBindingBoundary params) : AjtaiBindingAssumption params :=
  h.hardnessFromFields

def AjtaiRelaxedBindingBoundary_hardness
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingAssumption params :=
  h.hardness

def AjtaiRelaxedBindingBoundary_hardnessFromFields
  {params : AjtaiParams}
  (h : AjtaiRelaxedBindingBoundary params) : AjtaiRelaxedBindingAssumption params :=
  h.hardnessFromFields

theorem MSISToAjtaiReductions_toBinding
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params :=
  hRed.toBinding hMsis

theorem MSISToAjtaiReductions_toRelaxedBinding
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingAssumption params :=
  hRed.toRelaxedBinding hMsis

theorem ajtaiBinding_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params :=
  SuperNeo.ProofSystem.ajtaiBinding_of_msis hRed hMsis

theorem ajtaiRelaxedBinding_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingAssumption params :=
  SuperNeo.ProofSystem.ajtaiRelaxedBinding_of_msis hRed hMsis

theorem ajtaiBoundaries_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingAssumption params ∧ AjtaiRelaxedBindingAssumption params :=
  SuperNeo.ProofSystem.ajtaiBoundaries_of_msis hRed hMsis

def ajtaiBindingBoundary_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiBindingBoundary params :=
  SuperNeo.ProofSystem.ajtaiBindingBoundary_of_msis hRed hMsis

def ajtaiRelaxedBindingBoundary_of_msis
  {params : AjtaiParams}
  (hRed : MSISToAjtaiReductions params)
  (hMsis : MSISHardnessAssumption params) :
  AjtaiRelaxedBindingBoundary params :=
  SuperNeo.ProofSystem.ajtaiRelaxedBindingBoundary_of_msis hRed hMsis

end
end ProofSystem.LatticeReductionsInterface
end SuperNeo
