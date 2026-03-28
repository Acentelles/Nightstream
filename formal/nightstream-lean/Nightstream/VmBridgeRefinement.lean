import Nightstream.ReleaseBridge

namespace Nightstream

def RefinesReleaseBridge
  {Stage Family VmStageView VmPublicView : Type*}
  (shape : ReleaseShape Stage Family)
  (toStageView : VmStageView → ReleaseStageView Stage Family)
  (vmCanonicalStageViews : List VmStageView)
  (toPublicView : VmPublicView → ReleaseBridgePublicView Stage Family)
  (vmPublicViewBound : VmPublicView → Nat → Prop) : Prop :=
  vmCanonicalStageViews.map toStageView = canonicalStageViews shape ∧
    ∀ view preparedStepCount,
      vmPublicViewBound view preparedStepCount →
        ReleaseBridgePublicViewBound shape (toPublicView view) preparedStepCount

theorem canonicalStageViews_eq_of_refines
  {Stage Family VmStageView VmPublicView : Type*}
  {shape : ReleaseShape Stage Family}
  {toStageView : VmStageView → ReleaseStageView Stage Family}
  {vmCanonicalStageViews : List VmStageView}
  {toPublicView : VmPublicView → ReleaseBridgePublicView Stage Family}
  {vmPublicViewBound : VmPublicView → Nat → Prop}
  (hRefine :
    RefinesReleaseBridge
      shape toStageView vmCanonicalStageViews toPublicView vmPublicViewBound) :
  vmCanonicalStageViews.map toStageView = canonicalStageViews shape :=
  hRefine.1

theorem releaseBridgePublicViewBound_of_refines
  {Stage Family VmStageView VmPublicView : Type*}
  {shape : ReleaseShape Stage Family}
  {toStageView : VmStageView → ReleaseStageView Stage Family}
  {vmCanonicalStageViews : List VmStageView}
  {toPublicView : VmPublicView → ReleaseBridgePublicView Stage Family}
  {vmPublicViewBound : VmPublicView → Nat → Prop}
  (hRefine :
    RefinesReleaseBridge
      shape toStageView vmCanonicalStageViews toPublicView vmPublicViewBound)
  {view : VmPublicView}
  {preparedStepCount : Nat}
  (hView : vmPublicViewBound view preparedStepCount) :
  ReleaseBridgePublicViewBound shape (toPublicView view) preparedStepCount :=
  hRefine.2 view preparedStepCount hView

theorem releaseBridgePublicViewBound_of_publicView_eq
  {Stage Family VmPublicView : Type*}
  {shape : ReleaseShape Stage Family}
  {toPublicView : VmPublicView → ReleaseBridgePublicView Stage Family}
  {view : VmPublicView}
  {preparedStepCount : Nat}
  (hEq :
    toPublicView view =
      releaseBridgePublicView_of_preparedStepCount shape preparedStepCount) :
  ReleaseBridgePublicViewBound shape (toPublicView view) preparedStepCount := by
  rw [hEq]
  exact releaseBridgePublicViewBound_of_preparedStepCount shape preparedStepCount

theorem releaseBridgePublicViewBound_of_publicView_eq_schedule
  {Stage Family VmPublicView : Type*}
  {shape : ReleaseShape Stage Family}
  {toPublicView : VmPublicView → ReleaseBridgePublicView Stage Family}
  {view : VmPublicView}
  {schedule : FoldSchedule}
  {preparedStepCount : Nat}
  (hValid : FoldSchedule.Valid schedule)
  (hEq :
    toPublicView view =
      releaseBridgePublicView_of_schedule shape schedule preparedStepCount) :
  ReleaseBridgePublicViewBound shape (toPublicView view) preparedStepCount := by
  rw [hEq]
  exact releaseBridgePublicViewBound_of_schedule shape hValid preparedStepCount

end Nightstream
