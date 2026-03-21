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
abbrev Obligation (Family Point : Type*) := Nightstream.Obligation Family Point
abbrev FamilyDecision := Nightstream.FamilyDecision

abbrev FoldableAt {Family Point : Type*} := @Nightstream.FoldableAt Family Point
abbrev Homogeneous {Family Point : Type*} := @Nightstream.Homogeneous Family Point
abbrev MainLaneAdmissible {Family Point : Type*} := @Nightstream.MainLaneAdmissible Family Point
abbrev SeparateFoldSupported {Family Point : Type*} := @Nightstream.SeparateFoldSupported Family Point
noncomputable abbrev classifyFamily {Family Point : Type*} := @Nightstream.classifyFamily Family Point

end BridgeTypesInterface

end Nightstream
