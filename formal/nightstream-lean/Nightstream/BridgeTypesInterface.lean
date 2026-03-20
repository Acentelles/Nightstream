import Nightstream.BridgeTypes

namespace Nightstream

namespace BridgeTypesInterface

abbrev SuperNeoPiCCSStrongStatement := Nightstream.SuperNeoPiCCSStrongStatement
abbrev SuperNeoPiRLCWeakStatement := Nightstream.SuperNeoPiRLCWeakStatement
abbrev SuperNeoPiDECKnowledgeStatement := Nightstream.SuperNeoPiDECKnowledgeStatement

abbrev ShoutReadOnlyMemoryRelation := @Nightstream.ShoutReadOnlyMemoryRelation
abbrev TwistValEvaluationExpression := @Nightstream.TwistValEvaluationExpression
abbrev ShoutPoint := @Nightstream.ShoutPoint
abbrev TwistPoint := @Nightstream.TwistPoint

abbrev RelationKind := Nightstream.RelationKind
abbrev SourceKind := Nightstream.SourceKind
abbrev ShoutReadPoint (K : Type*) [Field K] := Nightstream.ShoutReadPoint K
abbrev TwistValPoint (K : Type*) [Field K] := Nightstream.TwistValPoint K
abbrev Obligation (Point : Type*) := Nightstream.Obligation Point
abbrev FamilyDecision := Nightstream.FamilyDecision

abbrev FoldableAt {Point : Type*} := @Nightstream.FoldableAt Point
abbrev Homogeneous {Point : Type*} := @Nightstream.Homogeneous Point
abbrev MainLaneAdmissible {Point : Type*} := @Nightstream.MainLaneAdmissible Point
abbrev SeparateFoldSupported {Point : Type*} := @Nightstream.SeparateFoldSupported Point
noncomputable abbrev classifyFamily {Point : Type*} := @Nightstream.classifyFamily Point

end BridgeTypesInterface

end Nightstream
