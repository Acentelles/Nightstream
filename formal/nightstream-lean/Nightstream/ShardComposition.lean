import Nightstream.MainLaneBridge

namespace Nightstream

structure FamilyPolicy (Point : Type*) where
  mainPoint : Point
  supportsSeparate : RelationKind → Point → Prop

noncomputable def decideFamily
  {Point : Type*}
  (policy : FamilyPolicy Point)
  (claims : List (Obligation Point)) : FamilyDecision :=
  classifyFamily policy.mainPoint policy.supportsSeparate claims

theorem decideFamily_eq_mergeMain_iff_mainLaneAdmissible
  {Point : Type*}
  {policy : FamilyPolicy Point}
  {claims : List (Obligation Point)} :
  decideFamily policy claims = FamilyDecision.mergeMain ↔
    MainLaneAdmissible policy.mainPoint claims := by
  classical
  constructor
  · intro hDecision
    by_cases hMain : MainLaneAdmissible policy.mainPoint claims
    · exact hMain
    · by_cases hSeparate : SeparateFoldSupported policy.supportsSeparate claims
      · simp [decideFamily, classifyFamily, hMain, hSeparate] at hDecision
      · simp [decideFamily, classifyFamily, hMain, hSeparate] at hDecision
  · intro hMain
    simp [decideFamily, classifyFamily, hMain]

theorem projectionFamily_separateFoldSupported
  {Point : Type*}
  {supports : RelationKind → Point → Prop}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt relation point claims)
  (hSupport : supports relation point) :
  SeparateFoldSupported supports claims := by
  refine ⟨relation, point, hSupport, ?_⟩
  refine ⟨hProjection.1, ?_⟩
  intro claim hMem
  exact (hProjection.2 claim hMem).2

theorem projectionFamily_not_separateFoldSupported_of_not_support
  {Point : Type*}
  {supports : RelationKind → Point → Prop}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt relation point claims)
  (hUnsupported : ¬ supports relation point) :
  ¬ SeparateFoldSupported supports claims := by
  intro hSeparate
  rcases hProjection with ⟨hNonempty, hMembers⟩
  rcases hSeparate with ⟨relation', point', hSupport, hFoldable⟩
  cases claims with
  | nil =>
      exact hNonempty rfl
  | cons claim rest =>
      have hHeadMem : claim ∈ claim :: rest := by simp
      have hProjectionShape := hMembers claim hHeadMem
      have hFoldableShape := hFoldable.2 claim hHeadMem
      have hRelationEq : relation' = relation := by
        calc
          relation' = claim.relation := by simpa using hFoldableShape.1.symm
          _ = relation := hProjectionShape.2.1
      have hPointEq : point' = point := by
        calc
          point' = claim.point := by simpa using hFoldableShape.2.symm
          _ = point := hProjectionShape.2.2
      exact hUnsupported (by simpa [hRelationEq, hPointEq] using hSupport)

theorem ceProjection_decide_eq_mergeMain_iff
  {Point : Type*}
  {policy : FamilyPolicy Point}
  {point : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt .ce point claims) :
  decideFamily policy claims = FamilyDecision.mergeMain ↔
    point = policy.mainPoint := by
  rw [decideFamily_eq_mergeMain_iff_mainLaneAdmissible]
  exact projectionFamilyAt_mainLaneAdmissible_iff hProjection

theorem projectionFamily_decide_eq_foldSeparate_of_supported_not_main
  {Point : Type*}
  {policy : FamilyPolicy Point}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt relation point claims)
  (hNotMain : ¬ MainLaneAdmissible policy.mainPoint claims)
  (hSupport : policy.supportsSeparate relation point) :
  decideFamily policy claims = FamilyDecision.foldSeparate := by
  exact classifyFamily_eq_foldSeparate_of_separateFoldSupported_not_main
    hNotMain
    (projectionFamily_separateFoldSupported hProjection hSupport)

theorem projectionFamily_decide_eq_exportFinal_of_unsupported_not_main
  {Point : Type*}
  {policy : FamilyPolicy Point}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt relation point claims)
  (hNotMain : ¬ MainLaneAdmissible policy.mainPoint claims)
  (hUnsupported : ¬ policy.supportsSeparate relation point) :
  decideFamily policy claims = FamilyDecision.exportFinal := by
  exact classifyFamily_eq_exportFinal_of_not_main_no_support
    hNotMain
    (projectionFamily_not_separateFoldSupported_of_not_support hProjection hUnsupported)

theorem shoutReadProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : FamilyPolicy (ShoutReadPoint K)}
  {point : ShoutReadPoint K}
  (hSupport : policy.supportsSeparate .shoutReadEval point) :
  decideFamily policy (shoutReadProjection point) = FamilyDecision.foldSeparate := by
  exact projectionFamily_decide_eq_foldSeparate_of_supported_not_main
    shoutReadProjection_is_projectionFamily
    shoutReadProjection_not_mainLane
    hSupport

theorem shoutReadProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : FamilyPolicy (ShoutReadPoint K)}
  {point : ShoutReadPoint K}
  (hUnsupported : ¬ policy.supportsSeparate .shoutReadEval point) :
  decideFamily policy (shoutReadProjection point) = FamilyDecision.exportFinal := by
  exact projectionFamily_decide_eq_exportFinal_of_unsupported_not_main
    shoutReadProjection_is_projectionFamily
    shoutReadProjection_not_mainLane
    hUnsupported

theorem twistValProjection_decide_eq_foldSeparate_of_supported
  {K : Type*} [Field K]
  {policy : FamilyPolicy (TwistValPoint K)}
  {point : TwistValPoint K}
  (hSupport : policy.supportsSeparate .twistValEval point) :
  decideFamily policy (twistValProjection point) = FamilyDecision.foldSeparate := by
  exact projectionFamily_decide_eq_foldSeparate_of_supported_not_main
    twistValProjection_is_projectionFamily
    twistValProjection_not_mainLane
    hSupport

theorem twistValProjection_decide_eq_exportFinal_of_unsupported
  {K : Type*} [Field K]
  {policy : FamilyPolicy (TwistValPoint K)}
  {point : TwistValPoint K}
  (hUnsupported : ¬ policy.supportsSeparate .twistValEval point) :
  decideFamily policy (twistValProjection point) = FamilyDecision.exportFinal := by
  exact projectionFamily_decide_eq_exportFinal_of_unsupported_not_main
    twistValProjection_is_projectionFamily
    twistValProjection_not_mainLane
    hUnsupported

end Nightstream
