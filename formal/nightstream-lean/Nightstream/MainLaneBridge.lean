import Nightstream.Projection
import Nightstream.FoldAdmissibility

namespace Nightstream

theorem projectionFamilyAt_not_mainLane_of_relation_ne_ce
  {Family Point : Type*}
  {family mainFamily : Family}
  {relation : RelationKind}
  {point mainPoint : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family relation point claims)
  (hNotCe : relation ≠ .ce) :
  ¬ MainLaneAdmissible mainFamily mainPoint claims := by
  intro hMain
  rcases hProjection with ⟨hNonempty, hMembers⟩
  cases claims with
  | nil =>
      exfalso
      exact hNonempty rfl
  | cons claim rest =>
      have hHeadMem : claim ∈ claim :: rest := by simp
      have hProjectionShape := hMembers claim hHeadMem
      have hMainShape := mergeMain_members_have_main_shape hMain hHeadMem
      have hRelCe : relation = .ce := by
        calc
          relation = claim.relation := by simpa using hProjectionShape.2.2.1.symm
          _ = .ce := hMainShape.2.1
      exact hNotCe hRelCe

theorem projectionFamilyAt_mainLaneAdmissible_iff
  {Family Point : Type*}
  {family mainFamily : Family}
  {point mainPoint : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family .ce point claims) :
  MainLaneAdmissible mainFamily mainPoint claims ↔
    family = mainFamily ∧ point = mainPoint := by
  constructor
  · intro hMain
    rcases hProjection with ⟨hNonempty, hMembers⟩
    cases claims with
    | nil =>
        exfalso
        exact hNonempty rfl
    | cons claim rest =>
        have hHeadMem : claim ∈ claim :: rest := by simp
        have hProjectionShape := hMembers claim hHeadMem
        have hMainShape := mergeMain_members_have_main_shape hMain hHeadMem
        constructor
        · calc
            family = claim.family := by simpa using hProjectionShape.2.1.symm
            _ = mainFamily := hMainShape.1
        · calc
            point = claim.point := by simpa using hProjectionShape.2.2.2.symm
            _ = mainPoint := hMainShape.2.2
  · rintro ⟨hFamilyEq, hPointEq⟩
    refine ⟨hProjection.1, ?_⟩
    intro claim hMem
    have hShape := hProjection.2 claim hMem
    rcases hShape with ⟨_, hFamily, hRel, hPoint⟩
    constructor
    · simpa [hFamilyEq] using hFamily
    · constructor
      · exact hRel
      · simpa [hPointEq] using hPoint

theorem ceProjection_mainLaneAdmissible_iff
  {Family Point : Type*}
  {family mainFamily : Family}
  {point mainPoint : Point} :
  MainLaneAdmissible mainFamily mainPoint (ceProjection family point) ↔
    family = mainFamily ∧ point = mainPoint := by
  exact projectionFamilyAt_mainLaneAdmissible_iff ceProjection_is_projectionFamily

theorem shoutReadProjection_not_mainLane
  {Family K : Type*} [Field K]
  {family mainFamily : Family}
  {point mainPoint : ShoutReadPoint K} :
  ¬ MainLaneAdmissible mainFamily mainPoint (shoutReadProjection family point) := by
  exact projectionFamilyAt_not_mainLane_of_relation_ne_ce
    shoutReadProjection_is_projectionFamily
    (by decide)

theorem twistValProjection_not_mainLane
  {Family K : Type*} [Field K]
  {family mainFamily : Family}
  {point mainPoint : TwistValPoint K} :
  ¬ MainLaneAdmissible mainFamily mainPoint (twistValProjection family point) := by
  exact projectionFamilyAt_not_mainLane_of_relation_ne_ce
    twistValProjection_is_projectionFamily
    (by decide)

end Nightstream
