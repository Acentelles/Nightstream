import Nightstream.Projection
import Nightstream.FoldAdmissibility

namespace Nightstream

theorem projectionFamilyAt_not_mainLane_of_relation_ne_ce
  {Point : Type*}
  {relation : RelationKind}
  {point mainPoint : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt relation point claims)
  (hNotCe : relation ≠ .ce) :
  ¬ MainLaneAdmissible mainPoint claims := by
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
          relation = claim.relation := by simpa using hProjectionShape.2.1.symm
          _ = .ce := hMainShape.1
      exact hNotCe hRelCe

theorem projectionFamilyAt_mainLaneAdmissible_iff
  {Point : Type*}
  {point mainPoint : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt .ce point claims) :
  MainLaneAdmissible mainPoint claims ↔ point = mainPoint := by
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
        calc
          point = claim.point := by simpa using hProjectionShape.2.2.symm
          _ = mainPoint := hMainShape.2
  · intro hEq
    refine ⟨hProjection.1, ?_⟩
    intro claim hMem
    have hShape := hProjection.2 claim hMem
    rcases hShape with ⟨_, hRel, hPoint⟩
    constructor
    · exact hRel
    · simpa [hEq] using hPoint

theorem shoutReadProjection_not_mainLane
  {K : Type*} [Field K]
  {point mainPoint : ShoutReadPoint K} :
  ¬ MainLaneAdmissible mainPoint (shoutReadProjection point) := by
  exact projectionFamilyAt_not_mainLane_of_relation_ne_ce
    shoutReadProjection_is_projectionFamily
    (by decide)

theorem twistValProjection_not_mainLane
  {K : Type*} [Field K]
  {point mainPoint : TwistValPoint K} :
  ¬ MainLaneAdmissible mainPoint (twistValProjection point) := by
  exact projectionFamilyAt_not_mainLane_of_relation_ne_ce
    twistValProjection_is_projectionFamily
    (by decide)

end Nightstream
