import Nightstream.Projection

namespace Nightstream

namespace ProjectionInterface

abbrev ProjectionFamilyAt {Family Point : Type*} := @Nightstream.ProjectionFamilyAt Family Point
abbrev ceProjectionObligation {Family Point : Type*} := @Nightstream.ceProjectionObligation Family Point
abbrev shoutReadCheckObligation {Family K : Type*} [Field K] :=
  @Nightstream.shoutReadCheckObligation Family K _
abbrev twistValEvaluationObligation {Family K : Type*} [Field K] :=
  @Nightstream.twistValEvaluationObligation Family K _
abbrev openingProjectionObligation {Family Point : Type*} :=
  @Nightstream.openingProjectionObligation Family Point
abbrev finalProjectionObligation {Family Point : Type*} :=
  @Nightstream.finalProjectionObligation Family Point

abbrev ceProjection {Family Point : Type*} := @Nightstream.ceProjection Family Point
abbrev shoutReadProjection {Family K : Type*} [Field K] := @Nightstream.shoutReadProjection Family K _
abbrev twistValProjection {Family K : Type*} [Field K] := @Nightstream.twistValProjection Family K _
abbrev openingProjection {Family Point : Type*} := @Nightstream.openingProjection Family Point
abbrev finalProjection {Family Point : Type*} := @Nightstream.finalProjection Family Point

abbrev projectionFamilyAt_implies_homogeneous :=
  @Nightstream.projectionFamilyAt_implies_homogeneous
abbrev projectionFamilyAt_members_have_shape :=
  @Nightstream.projectionFamilyAt_members_have_shape
abbrev ceProjection_is_projectionFamily :=
  @Nightstream.ceProjection_is_projectionFamily
abbrev shoutReadProjection_is_projectionFamily :=
  @Nightstream.shoutReadProjection_is_projectionFamily
abbrev twistValProjection_is_projectionFamily :=
  @Nightstream.twistValProjection_is_projectionFamily
abbrev openingProjection_is_projectionFamily :=
  @Nightstream.openingProjection_is_projectionFamily
abbrev finalProjection_is_projectionFamily :=
  @Nightstream.finalProjection_is_projectionFamily
abbrev ceProjection_homogeneous :=
  @Nightstream.ceProjection_homogeneous
abbrev shoutReadProjection_homogeneous :=
  @Nightstream.shoutReadProjection_homogeneous
abbrev twistValProjection_homogeneous :=
  @Nightstream.twistValProjection_homogeneous
abbrev shoutReadProjectionSound := @Nightstream.shoutReadProjectionSound
abbrev twistValProjectionSound := @Nightstream.twistValProjectionSound

end ProjectionInterface

end Nightstream
