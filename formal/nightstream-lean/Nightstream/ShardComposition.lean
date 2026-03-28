import Nightstream.MainLaneBridge

namespace Nightstream

structure FamilyPolicy (Family Point : Type*) where
  mainFamily : Family
  mainPoint : Point
  supportsSeparate : Family → RelationKind → Point → Prop

noncomputable def decideFamily
  {Family Point : Type*}
  (policy : FamilyPolicy Family Point)
  (claims : List (Obligation Family Point)) : FamilyDecision :=
  classifyFamily policy.mainFamily policy.mainPoint policy.supportsSeparate claims

theorem decideFamily_eq_mergeMain_iff_mainLaneAdmissible
  {Family Point : Type*}
  {policy : FamilyPolicy Family Point}
  {claims : List (Obligation Family Point)} :
  decideFamily policy claims = FamilyDecision.mergeMain ↔
    MainLaneAdmissible policy.mainFamily policy.mainPoint claims := by
  classical
  constructor
  · intro hDecision
    by_cases hMain : MainLaneAdmissible policy.mainFamily policy.mainPoint claims
    · exact hMain
    · by_cases hSeparate : SeparateFoldSupported policy.supportsSeparate claims
      · simp [decideFamily, classifyFamily, hMain, hSeparate] at hDecision
      · simp [decideFamily, classifyFamily, hMain, hSeparate] at hDecision
  · intro hMain
    simp [decideFamily, classifyFamily, hMain]

theorem projectionFamily_separateFoldSupported
  {Family Point : Type*}
  {supports : Family → RelationKind → Point → Prop}
  {family : Family}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family relation point claims)
  (hSupport : supports family relation point) :
  SeparateFoldSupported supports claims := by
  refine ⟨family, relation, point, hSupport, ?_⟩
  refine ⟨hProjection.1, ?_⟩
  intro claim hMem
  exact (hProjection.2 claim hMem).2

theorem projectionFamily_not_separateFoldSupported_of_not_support
  {Family Point : Type*}
  {supports : Family → RelationKind → Point → Prop}
  {family : Family}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family relation point claims)
  (hUnsupported : ¬ supports family relation point) :
  ¬ SeparateFoldSupported supports claims := by
  intro hSeparate
  rcases hProjection with ⟨hNonempty, hMembers⟩
  rcases hSeparate with ⟨family', relation', point', hSupport, hFoldable⟩
  cases claims with
  | nil =>
      exact hNonempty rfl
  | cons claim rest =>
      have hHeadMem : claim ∈ claim :: rest := by simp
      have hProjectionShape := hMembers claim hHeadMem
      have hFoldableShape := hFoldable.2 claim hHeadMem
      have hFamilyEq : family' = family := by
        calc
          family' = claim.family := by simpa using hFoldableShape.1.symm
          _ = family := hProjectionShape.2.1
      have hRelationEq : relation' = relation := by
        calc
          relation' = claim.relation := by simpa using hFoldableShape.2.1.symm
          _ = relation := hProjectionShape.2.2.1
      have hPointEq : point' = point := by
        calc
          point' = claim.point := by simpa using hFoldableShape.2.2.symm
          _ = point := hProjectionShape.2.2.2
      exact hUnsupported (by simpa [hFamilyEq, hRelationEq, hPointEq] using hSupport)

theorem ceProjection_decide_eq_mergeMain_iff
  {Family Point : Type*}
  {policy : FamilyPolicy Family Point}
  {family : Family}
  {point : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family .ce point claims) :
  decideFamily policy claims = FamilyDecision.mergeMain ↔
    family = policy.mainFamily ∧ point = policy.mainPoint := by
  rw [decideFamily_eq_mergeMain_iff_mainLaneAdmissible]
  exact projectionFamilyAt_mainLaneAdmissible_iff hProjection

theorem ceProjectionSingleton_decide_eq_mergeMain_iff
  {Family Point : Type*}
  {policy : FamilyPolicy Family Point}
  {family : Family}
  {point : Point} :
  decideFamily policy (ceProjection family point) = FamilyDecision.mergeMain ↔
    family = policy.mainFamily ∧ point = policy.mainPoint := by
  exact ceProjection_decide_eq_mergeMain_iff ceProjection_is_projectionFamily

theorem projectionFamily_decide_eq_foldSeparate_of_supported_not_main
  {Family Point : Type*}
  {policy : FamilyPolicy Family Point}
  {family : Family}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family relation point claims)
  (hNotMain : ¬ MainLaneAdmissible policy.mainFamily policy.mainPoint claims)
  (hSupport : policy.supportsSeparate family relation point) :
  decideFamily policy claims = FamilyDecision.foldSeparate := by
  exact classifyFamily_eq_foldSeparate_of_separateFoldSupported_not_main
    hNotMain
    (projectionFamily_separateFoldSupported hProjection hSupport)

theorem projectionFamily_decide_eq_exportFinal_of_unsupported_not_main
  {Family Point : Type*}
  {policy : FamilyPolicy Family Point}
  {family : Family}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family relation point claims)
  (hNotMain : ¬ MainLaneAdmissible policy.mainFamily policy.mainPoint claims)
  (hUnsupported : ¬ policy.supportsSeparate family relation point) :
  decideFamily policy claims = FamilyDecision.exportFinal := by
  exact classifyFamily_eq_exportFinal_of_not_main_no_support
    hNotMain
    (projectionFamily_not_separateFoldSupported_of_not_support hProjection hUnsupported)

theorem ceProjectionSingleton_decide_eq_foldSeparate_of_supported_not_main
  {Family Point : Type*}
  {policy : FamilyPolicy Family Point}
  {family : Family}
  {point : Point}
  (hNotMain : ¬ (family = policy.mainFamily ∧ point = policy.mainPoint))
  (hSupport : policy.supportsSeparate family .ce point) :
  decideFamily policy (ceProjection family point) = FamilyDecision.foldSeparate := by
  exact projectionFamily_decide_eq_foldSeparate_of_supported_not_main
    ceProjection_is_projectionFamily
    (by
      intro hMain
      exact hNotMain (ceProjection_mainLaneAdmissible_iff.mp hMain))
    hSupport

theorem ceProjectionSingleton_decide_eq_exportFinal_of_unsupported_not_main
  {Family Point : Type*}
  {policy : FamilyPolicy Family Point}
  {family : Family}
  {point : Point}
  (hNotMain : ¬ (family = policy.mainFamily ∧ point = policy.mainPoint))
  (hUnsupported : ¬ policy.supportsSeparate family .ce point) :
  decideFamily policy (ceProjection family point) = FamilyDecision.exportFinal := by
  exact projectionFamily_decide_eq_exportFinal_of_unsupported_not_main
    ceProjection_is_projectionFamily
    (by
      intro hMain
      exact hNotMain (ceProjection_mainLaneAdmissible_iff.mp hMain))
    hUnsupported

theorem shoutReadProjection_decide_eq_foldSeparate_of_supported
  {Family K : Type*} [Field K]
  {policy : FamilyPolicy Family (ShoutReadPoint K)}
  {family : Family}
  {point : ShoutReadPoint K}
  (hSupport : policy.supportsSeparate family .shoutReadEval point) :
  decideFamily policy (shoutReadProjection family point) = FamilyDecision.foldSeparate := by
  exact projectionFamily_decide_eq_foldSeparate_of_supported_not_main
    shoutReadProjection_is_projectionFamily
    shoutReadProjection_not_mainLane
    hSupport

theorem shoutReadProjection_decide_eq_exportFinal_of_unsupported
  {Family K : Type*} [Field K]
  {policy : FamilyPolicy Family (ShoutReadPoint K)}
  {family : Family}
  {point : ShoutReadPoint K}
  (hUnsupported : ¬ policy.supportsSeparate family .shoutReadEval point) :
  decideFamily policy (shoutReadProjection family point) = FamilyDecision.exportFinal := by
  exact projectionFamily_decide_eq_exportFinal_of_unsupported_not_main
    shoutReadProjection_is_projectionFamily
    shoutReadProjection_not_mainLane
    hUnsupported

theorem twistValProjection_decide_eq_foldSeparate_of_supported
  {Family K : Type*} [Field K]
  {policy : FamilyPolicy Family (TwistValPoint K)}
  {family : Family}
  {point : TwistValPoint K}
  (hSupport : policy.supportsSeparate family .twistValEval point) :
  decideFamily policy (twistValProjection family point) = FamilyDecision.foldSeparate := by
  exact projectionFamily_decide_eq_foldSeparate_of_supported_not_main
    twistValProjection_is_projectionFamily
    twistValProjection_not_mainLane
    hSupport

theorem twistValProjection_decide_eq_exportFinal_of_unsupported
  {Family K : Type*} [Field K]
  {policy : FamilyPolicy Family (TwistValPoint K)}
  {family : Family}
  {point : TwistValPoint K}
  (hUnsupported : ¬ policy.supportsSeparate family .twistValEval point) :
  decideFamily policy (twistValProjection family point) = FamilyDecision.exportFinal := by
  exact projectionFamily_decide_eq_exportFinal_of_unsupported_not_main
    twistValProjection_is_projectionFamily
    twistValProjection_not_mainLane
    hUnsupported

end Nightstream
