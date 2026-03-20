import Nightstream.BridgeTypes
import Nightstream.ClaimedMemorySemantics
import TwistShout.ShoutCoreInterface
import TwistShout.TwistValueEvalInterface

namespace Nightstream

def ProjectionFamilyAt
  {Point : Type*}
  (relation : RelationKind)
  (point : Point)
  (claims : List (Obligation Point)) : Prop :=
  claims ≠ [] ∧
    ∀ claim ∈ claims,
      claim.source = SourceKind.twistShout ∧
      claim.relation = relation ∧
      claim.point = point

def shoutReadCheckObligation
  {K : Type*} [Field K]
  (point : ShoutReadPoint K) : Obligation (ShoutReadPoint K) where
  relation := .shoutReadEval
  point := point
  source := .twistShout

def twistValEvaluationObligation
  {K : Type*} [Field K]
  (point : TwistValPoint K) : Obligation (TwistValPoint K) where
  relation := .twistValEval
  point := point
  source := .twistShout

def openingProjectionObligation
  {Point : Type*}
  (point : Point) : Obligation Point where
  relation := .opening
  point := point
  source := .twistShout

def finalProjectionObligation
  {Point : Type*}
  (point : Point) : Obligation Point where
  relation := .final
  point := point
  source := .twistShout

def shoutReadProjection
  {K : Type*} [Field K]
  (point : ShoutReadPoint K) : List (Obligation (ShoutReadPoint K)) :=
  [shoutReadCheckObligation point]

def twistValProjection
  {K : Type*} [Field K]
  (point : TwistValPoint K) : List (Obligation (TwistValPoint K)) :=
  [twistValEvaluationObligation point]

def openingProjection
  {Point : Type*}
  (point : Point) : List (Obligation Point) :=
  [openingProjectionObligation point]

def finalProjection
  {Point : Type*}
  (point : Point) : List (Obligation Point) :=
  [finalProjectionObligation point]

theorem projectionFamilyAt_implies_homogeneous
  {Point : Type*}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Point)} :
  ProjectionFamilyAt relation point claims →
    Homogeneous claims := by
  intro hProjection
  refine ⟨relation, point, ?_⟩
  refine ⟨hProjection.1, ?_⟩
  intro claim hMem
  exact (hProjection.2 claim hMem).2

theorem projectionFamilyAt_members_have_shape
  {Point : Type*}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Point)}
  (hProjection : ProjectionFamilyAt relation point claims)
  {claim : Obligation Point}
  (hMem : claim ∈ claims) :
  claim.source = SourceKind.twistShout ∧
    claim.relation = relation ∧
    claim.point = point := by
  exact hProjection.2 claim hMem

theorem shoutReadProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : ShoutReadPoint K} :
  ProjectionFamilyAt .shoutReadEval point (shoutReadProjection point) := by
  refine ⟨by simp [shoutReadProjection], ?_⟩
  intro claim hMem
  simp [shoutReadProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · rfl

theorem twistValProjection_is_projectionFamily
  {K : Type*} [Field K]
  {point : TwistValPoint K} :
  ProjectionFamilyAt .twistValEval point (twistValProjection point) := by
  refine ⟨by simp [twistValProjection], ?_⟩
  intro claim hMem
  simp [twistValProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · rfl

theorem openingProjection_is_projectionFamily
  {Point : Type*}
  {point : Point} :
  ProjectionFamilyAt .opening point (openingProjection point) := by
  refine ⟨by simp [openingProjection], ?_⟩
  intro claim hMem
  simp [openingProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · rfl

theorem finalProjection_is_projectionFamily
  {Point : Type*}
  {point : Point} :
  ProjectionFamilyAt .final point (finalProjection point) := by
  refine ⟨by simp [finalProjection], ?_⟩
  intro claim hMem
  simp [finalProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · rfl

theorem shoutReadProjection_homogeneous
  {K : Type*} [Field K]
  {point : ShoutReadPoint K} :
  Homogeneous (shoutReadProjection point) := by
  exact projectionFamilyAt_implies_homogeneous shoutReadProjection_is_projectionFamily

theorem twistValProjection_homogeneous
  {K : Type*} [Field K]
  {point : TwistValPoint K} :
  Homogeneous (twistValProjection point) := by
  exact projectionFamilyAt_implies_homogeneous twistValProjection_is_projectionFamily

theorem shoutReadProjectionSound
  {K : Type*} [Field K]
  {d m t : Nat}
  {val : TwistShout.ShoutCoreInterface.PublicTable (K := K) d m}
  {addr : TwistShout.ShoutCoreInterface.CycleCube t →
    TwistShout.ShoutCoreInterface.Address d m}
  {rv : TwistShout.ShoutCoreInterface.CycleCube t → K}
  {ra : TwistShout.ShoutCoreInterface.AddressColumns (K := K) d m t}
  (hRel : TwistShout.ShoutCoreInterface.ReadOnlyMemoryRelation (K := K) val addr rv)
  (hvalid : TwistShout.ShoutCoreInterface.ValidAddressColumns (K := K) ra addr)
  (rCycle : TwistShout.Point (K := K) t) :
  TwistShout.mle (K := K) rv rCycle =
    TwistShout.ShoutCoreInterface.readCheckExpression (K := K) ra val rCycle := by
  exact TwistShout.ShoutCoreInterface.ReadOnlyMemoryRelation.readCheckIdentity
    (K := K) hRel hvalid rCycle

theorem twistValProjectionSound
  {K : Type*} [Field K]
  {d m t : Nat}
  (inc : TwistShout.TwistValueEvalInterface.TimeTable (K := K) d m t)
  (rAddress : Fin d → TwistShout.TwistValueEvalInterface.Point (K := K) m)
  (rCycle : TwistShout.TwistValueEvalInterface.Point (K := K) t) :
  TwistShout.TwistValueEvalInterface.timeTableMLE (K := K)
      (TwistShout.TwistValueEvalInterface.reconstructedTimeTable (K := K) inc)
      rAddress
      rCycle =
    TwistShout.TwistValueEvalInterface.valEvaluationExpression (K := K) inc rAddress rCycle := by
  exact TwistShout.TwistValueEvalInterface.timeTableMLE_reconstructedTimeTable
    (K := K) inc rAddress rCycle

end Nightstream
