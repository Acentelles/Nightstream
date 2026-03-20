import SuperNeo.PiCCSInterface
import SuperNeo.PiRLCInterface
import SuperNeo.PiDECInterface
import TwistShout.ShoutCoreInterface
import TwistShout.TwistValueEvalInterface

namespace Nightstream

abbrev SuperNeoPiCCSStrongStatement := SuperNeo.PiCCSInterface.piCCSStrongStatement
abbrev SuperNeoPiRLCWeakStatement := SuperNeo.PiRLCInterface.piRLCWeakStatement
abbrev SuperNeoPiDECKnowledgeStatement := SuperNeo.PiDECInterface.piDECKnowledgeStatement

abbrev ShoutReadOnlyMemoryRelation := @TwistShout.ShoutCoreInterface.ReadOnlyMemoryRelation
abbrev TwistValEvaluationExpression := @TwistShout.TwistValueEvalInterface.valEvaluationExpression
abbrev ShoutPoint := @TwistShout.ShoutCoreInterface.Point
abbrev TwistPoint := @TwistShout.TwistValueEvalInterface.Point

inductive RelationKind where
  | ce
  | shoutReadEval
  | twistValEval
  | opening
  | final
deriving DecidableEq, Repr

inductive SourceKind where
  | mainLane
  | twistShout
deriving DecidableEq, Repr

structure ShoutReadPoint (K : Type*) [Field K] where
  t : Nat
  cycle : ShoutPoint (K := K) t

structure TwistValPoint (K : Type*) [Field K] where
  d : Nat
  m : Nat
  t : Nat
  address : Fin d → TwistPoint (K := K) m
  cycle : TwistPoint (K := K) t

structure Obligation (Point : Type*) where
  relation : RelationKind
  point : Point
  source : SourceKind

inductive FamilyDecision where
  | mergeMain
  | foldSeparate
  | exportFinal
deriving DecidableEq, Repr

def FoldableAt
  {Point : Type*}
  (relation : RelationKind)
  (point : Point)
  (claims : List (Obligation Point)) : Prop :=
  claims ≠ [] ∧ ∀ claim ∈ claims, claim.relation = relation ∧ claim.point = point

def Homogeneous {Point : Type*} (claims : List (Obligation Point)) : Prop :=
  ∃ relation point, FoldableAt relation point claims

def MainLaneAdmissible
  {Point : Type*}
  (mainPoint : Point)
  (claims : List (Obligation Point)) : Prop :=
  FoldableAt .ce mainPoint claims

def SeparateFoldSupported
  {Point : Type*}
  (supports : RelationKind → Point → Prop)
  (claims : List (Obligation Point)) : Prop :=
  ∃ relation point, supports relation point ∧ FoldableAt relation point claims

noncomputable def classifyFamily
  {Point : Type*}
  (mainPoint : Point)
  (supports : RelationKind → Point → Prop)
  (claims : List (Obligation Point)) : FamilyDecision := by
  classical
  exact
    if MainLaneAdmissible mainPoint claims then .mergeMain
    else if SeparateFoldSupported supports claims then .foldSeparate
    else .exportFinal

end Nightstream
