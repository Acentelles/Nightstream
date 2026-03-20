import Nightstream.BridgeTypes

namespace Nightstream

theorem mainLaneAdmissible_implies_homogeneous
  {Point : Type*}
  {mainPoint : Point}
  {claims : List (Obligation Point)} :
  MainLaneAdmissible mainPoint claims →
    Homogeneous claims := by
  intro hMain
  exact ⟨RelationKind.ce, mainPoint, hMain⟩

theorem separateFoldSupported_implies_homogeneous
  {Point : Type*}
  {supports : RelationKind → Point → Prop}
  {claims : List (Obligation Point)} :
  SeparateFoldSupported supports claims →
    Homogeneous claims := by
  intro hSupport
  rcases hSupport with ⟨relation, point, _, hFoldable⟩
  exact ⟨relation, point, hFoldable⟩

theorem classifyFamily_eq_mergeMain_of_mainLaneAdmissible
  {Point : Type*}
  {mainPoint : Point}
  {supports : RelationKind → Point → Prop}
  {claims : List (Obligation Point)}
  (hMain : MainLaneAdmissible mainPoint claims) :
  classifyFamily mainPoint supports claims = FamilyDecision.mergeMain := by
  classical
  simp [classifyFamily, hMain]

theorem classifyFamily_eq_foldSeparate_of_separateFoldSupported_not_main
  {Point : Type*}
  {mainPoint : Point}
  {supports : RelationKind → Point → Prop}
  {claims : List (Obligation Point)}
  (hNotMain : ¬ MainLaneAdmissible mainPoint claims)
  (hSupport : SeparateFoldSupported supports claims) :
  classifyFamily mainPoint supports claims = FamilyDecision.foldSeparate := by
  classical
  simp [classifyFamily, hNotMain, hSupport]

theorem classifyFamily_eq_exportFinal_of_not_homogeneous
  {Point : Type*}
  {mainPoint : Point}
  {supports : RelationKind → Point → Prop}
  {claims : List (Obligation Point)}
  (hNotHom : ¬ Homogeneous claims) :
  classifyFamily mainPoint supports claims = FamilyDecision.exportFinal := by
  classical
  have hNotMain : ¬ MainLaneAdmissible mainPoint claims := by
    intro hMain
    exact hNotHom (mainLaneAdmissible_implies_homogeneous hMain)
  have hNoSupport : ¬ SeparateFoldSupported supports claims := by
    intro hSupport
    exact hNotHom (separateFoldSupported_implies_homogeneous hSupport)
  simp [classifyFamily, hNotMain, hNoSupport]

theorem mergeMain_members_have_main_shape
  {Point : Type*}
  {mainPoint : Point}
  {claims : List (Obligation Point)}
  (hMain : MainLaneAdmissible mainPoint claims)
  {claim : Obligation Point}
  (hMem : claim ∈ claims) :
  claim.relation = RelationKind.ce ∧ claim.point = mainPoint := by
  exact hMain.2 claim hMem

theorem classifyFamily_eq_exportFinal_of_not_main_no_support
  {Point : Type*}
  {mainPoint : Point}
  {supports : RelationKind → Point → Prop}
  {claims : List (Obligation Point)}
  (hNotMain : ¬ MainLaneAdmissible mainPoint claims)
  (hNoSupport : ¬ SeparateFoldSupported supports claims) :
  classifyFamily mainPoint supports claims = FamilyDecision.exportFinal := by
  classical
  simp [classifyFamily, hNotMain, hNoSupport]

end Nightstream
