import Nightstream.BridgeTypes

namespace Nightstream

theorem mainLaneAdmissible_implies_homogeneous
  {Family Point : Type*}
  {mainFamily : Family}
  {mainPoint : Point}
  {claims : List (Obligation Family Point)} :
  MainLaneAdmissible mainFamily mainPoint claims →
    Homogeneous claims := by
  intro hMain
  exact ⟨mainFamily, RelationKind.ce, mainPoint, hMain⟩

theorem separateFoldSupported_implies_homogeneous
  {Family Point : Type*}
  {supports : Family → RelationKind → Point → Prop}
  {claims : List (Obligation Family Point)} :
  SeparateFoldSupported supports claims →
    Homogeneous claims := by
  intro hSupport
  rcases hSupport with ⟨family, relation, point, _, hFoldable⟩
  exact ⟨family, relation, point, hFoldable⟩

theorem classifyFamily_eq_mergeMain_of_mainLaneAdmissible
  {Family Point : Type*}
  {mainFamily : Family}
  {mainPoint : Point}
  {supports : Family → RelationKind → Point → Prop}
  {claims : List (Obligation Family Point)}
  (hMain : MainLaneAdmissible mainFamily mainPoint claims) :
  classifyFamily mainFamily mainPoint supports claims = FamilyDecision.mergeMain := by
  classical
  simp [classifyFamily, hMain]

theorem classifyFamily_eq_foldSeparate_of_separateFoldSupported_not_main
  {Family Point : Type*}
  {mainFamily : Family}
  {mainPoint : Point}
  {supports : Family → RelationKind → Point → Prop}
  {claims : List (Obligation Family Point)}
  (hNotMain : ¬ MainLaneAdmissible mainFamily mainPoint claims)
  (hSupport : SeparateFoldSupported supports claims) :
  classifyFamily mainFamily mainPoint supports claims = FamilyDecision.foldSeparate := by
  classical
  simp [classifyFamily, hNotMain, hSupport]

theorem classifyFamily_eq_exportFinal_of_not_homogeneous
  {Family Point : Type*}
  {mainFamily : Family}
  {mainPoint : Point}
  {supports : Family → RelationKind → Point → Prop}
  {claims : List (Obligation Family Point)}
  (hNotHom : ¬ Homogeneous claims) :
  classifyFamily mainFamily mainPoint supports claims = FamilyDecision.exportFinal := by
  classical
  have hNotMain : ¬ MainLaneAdmissible mainFamily mainPoint claims := by
    intro hMain
    exact hNotHom (mainLaneAdmissible_implies_homogeneous hMain)
  have hNoSupport : ¬ SeparateFoldSupported supports claims := by
    intro hSupport
    exact hNotHom (separateFoldSupported_implies_homogeneous hSupport)
  simp [classifyFamily, hNotMain, hNoSupport]

theorem mergeMain_members_have_main_shape
  {Family Point : Type*}
  {mainFamily : Family}
  {mainPoint : Point}
  {claims : List (Obligation Family Point)}
  (hMain : MainLaneAdmissible mainFamily mainPoint claims)
  {claim : Obligation Family Point}
  (hMem : claim ∈ claims) :
  claim.family = mainFamily ∧
    claim.relation = RelationKind.ce ∧
    claim.point = mainPoint := by
  exact hMain.2 claim hMem

theorem classifyFamily_eq_exportFinal_of_not_main_no_support
  {Family Point : Type*}
  {mainFamily : Family}
  {mainPoint : Point}
  {supports : Family → RelationKind → Point → Prop}
  {claims : List (Obligation Family Point)}
  (hNotMain : ¬ MainLaneAdmissible mainFamily mainPoint claims)
  (hNoSupport : ¬ SeparateFoldSupported supports claims) :
  classifyFamily mainFamily mainPoint supports claims = FamilyDecision.exportFinal := by
  classical
  simp [classifyFamily, hNotMain, hNoSupport]

end Nightstream
