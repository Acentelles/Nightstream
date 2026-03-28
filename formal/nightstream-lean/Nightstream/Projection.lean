import Nightstream.BridgeTypes
import Nightstream.ClaimedMemorySemantics
import TwistShout.ShoutCoreInterface
import TwistShout.TwistValueEvalInterface

namespace Nightstream

def ProjectionFamilyAt
  {Family Point : Type*}
  (family : Family)
  (relation : RelationKind)
  (point : Point)
  (claims : List (Obligation Family Point)) : Prop :=
  claims ≠ [] ∧
    ∀ claim ∈ claims,
      claim.source = SourceKind.twistShout ∧
      claim.family = family ∧
      claim.relation = relation ∧
      claim.point = point

def ceProjectionObligation
  {Family Point : Type*}
  (family : Family)
  (point : Point) : Obligation Family Point where
  family := family
  relation := .ce
  point := point
  source := .twistShout

def shoutReadCheckObligation
  {Family K : Type*} [Field K]
  (family : Family)
  (point : ShoutReadPoint K) : Obligation Family (ShoutReadPoint K) where
  family := family
  relation := .shoutReadEval
  point := point
  source := .twistShout

def twistValEvaluationObligation
  {Family K : Type*} [Field K]
  (family : Family)
  (point : TwistValPoint K) : Obligation Family (TwistValPoint K) where
  family := family
  relation := .twistValEval
  point := point
  source := .twistShout

def openingProjectionObligation
  {Family Point : Type*}
  (family : Family)
  (point : Point) : Obligation Family Point where
  family := family
  relation := .opening
  point := point
  source := .twistShout

def finalProjectionObligation
  {Family Point : Type*}
  (family : Family)
  (point : Point) : Obligation Family Point where
  family := family
  relation := .final
  point := point
  source := .twistShout

def ceProjection
  {Family Point : Type*}
  (family : Family)
  (point : Point) : List (Obligation Family Point) :=
  [ceProjectionObligation family point]

def shoutReadProjection
  {Family K : Type*} [Field K]
  (family : Family)
  (point : ShoutReadPoint K) : List (Obligation Family (ShoutReadPoint K)) :=
  [shoutReadCheckObligation family point]

def twistValProjection
  {Family K : Type*} [Field K]
  (family : Family)
  (point : TwistValPoint K) : List (Obligation Family (TwistValPoint K)) :=
  [twistValEvaluationObligation family point]

def openingProjection
  {Family Point : Type*}
  (family : Family)
  (point : Point) : List (Obligation Family Point) :=
  [openingProjectionObligation family point]

def finalProjection
  {Family Point : Type*}
  (family : Family)
  (point : Point) : List (Obligation Family Point) :=
  [finalProjectionObligation family point]

theorem projectionFamilyAt_implies_homogeneous
  {Family Point : Type*}
  {family : Family}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Family Point)} :
  ProjectionFamilyAt family relation point claims →
    Homogeneous claims := by
  intro hProjection
  refine ⟨family, relation, point, ?_⟩
  refine ⟨hProjection.1, ?_⟩
  intro claim hMem
  exact (hProjection.2 claim hMem).2

theorem projectionFamilyAt_members_have_shape
  {Family Point : Type*}
  {family : Family}
  {relation : RelationKind}
  {point : Point}
  {claims : List (Obligation Family Point)}
  (hProjection : ProjectionFamilyAt family relation point claims)
  {claim : Obligation Family Point}
  (hMem : claim ∈ claims) :
  claim.source = SourceKind.twistShout ∧
    claim.family = family ∧
    claim.relation = relation ∧
    claim.point = point := by
  exact hProjection.2 claim hMem

theorem ceProjection_is_projectionFamily
  {Family Point : Type*}
  {family : Family}
  {point : Point} :
  ProjectionFamilyAt family .ce point (ceProjection family point) := by
  refine ⟨by simp [ceProjection], ?_⟩
  intro claim hMem
  simp [ceProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · constructor
      · rfl
      · rfl

theorem shoutReadProjection_is_projectionFamily
  {Family K : Type*} [Field K]
  {family : Family}
  {point : ShoutReadPoint K} :
  ProjectionFamilyAt family .shoutReadEval point (shoutReadProjection family point) := by
  refine ⟨by simp [shoutReadProjection], ?_⟩
  intro claim hMem
  simp [shoutReadProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · constructor
      · rfl
      · rfl

theorem twistValProjection_is_projectionFamily
  {Family K : Type*} [Field K]
  {family : Family}
  {point : TwistValPoint K} :
  ProjectionFamilyAt family .twistValEval point (twistValProjection family point) := by
  refine ⟨by simp [twistValProjection], ?_⟩
  intro claim hMem
  simp [twistValProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · constructor
      · rfl
      · rfl

theorem openingProjection_is_projectionFamily
  {Family Point : Type*}
  {family : Family}
  {point : Point} :
  ProjectionFamilyAt family .opening point (openingProjection family point) := by
  refine ⟨by simp [openingProjection], ?_⟩
  intro claim hMem
  simp [openingProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · constructor
      · rfl
      · rfl

theorem finalProjection_is_projectionFamily
  {Family Point : Type*}
  {family : Family}
  {point : Point} :
  ProjectionFamilyAt family .final point (finalProjection family point) := by
  refine ⟨by simp [finalProjection], ?_⟩
  intro claim hMem
  simp [finalProjection] at hMem
  rcases hMem with rfl
  constructor
  · rfl
  · constructor
    · rfl
    · constructor
      · rfl
      · rfl

theorem ceProjection_homogeneous
  {Family Point : Type*}
  {family : Family}
  {point : Point} :
  Homogeneous (ceProjection family point) := by
  exact projectionFamilyAt_implies_homogeneous ceProjection_is_projectionFamily

theorem shoutReadProjection_homogeneous
  {Family K : Type*} [Field K]
  {family : Family}
  {point : ShoutReadPoint K} :
  Homogeneous (shoutReadProjection family point) := by
  exact projectionFamilyAt_implies_homogeneous shoutReadProjection_is_projectionFamily

theorem twistValProjection_homogeneous
  {Family K : Type*} [Field K]
  {family : Family}
  {point : TwistValPoint K} :
  Homogeneous (twistValProjection family point) := by
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
