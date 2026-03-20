import Nightstream.Projection

namespace Nightstream

namespace ProjectionInterface

abbrev ProjectionFamilyAt {Point : Type*} := @Nightstream.ProjectionFamilyAt Point
abbrev shoutReadCheckObligation {K : Type*} [Field K] := @Nightstream.shoutReadCheckObligation K _
abbrev twistValEvaluationObligation {K : Type*} [Field K] :=
  @Nightstream.twistValEvaluationObligation K _
abbrev openingProjectionObligation {Point : Type*} := @Nightstream.openingProjectionObligation Point
abbrev finalProjectionObligation {Point : Type*} := @Nightstream.finalProjectionObligation Point

abbrev shoutReadProjection {K : Type*} [Field K] := @Nightstream.shoutReadProjection K _
abbrev twistValProjection {K : Type*} [Field K] := @Nightstream.twistValProjection K _
abbrev openingProjection {Point : Type*} := @Nightstream.openingProjection Point
abbrev finalProjection {Point : Type*} := @Nightstream.finalProjection Point

abbrev projectionFamilyAt_implies_homogeneous :=
  @Nightstream.projectionFamilyAt_implies_homogeneous
abbrev projectionFamilyAt_members_have_shape :=
  @Nightstream.projectionFamilyAt_members_have_shape
abbrev shoutReadProjection_is_projectionFamily :=
  @Nightstream.shoutReadProjection_is_projectionFamily
abbrev twistValProjection_is_projectionFamily :=
  @Nightstream.twistValProjection_is_projectionFamily
abbrev openingProjection_is_projectionFamily :=
  @Nightstream.openingProjection_is_projectionFamily
abbrev finalProjection_is_projectionFamily :=
  @Nightstream.finalProjection_is_projectionFamily
abbrev shoutReadProjection_homogeneous :=
  @Nightstream.shoutReadProjection_homogeneous
abbrev twistValProjection_homogeneous :=
  @Nightstream.twistValProjection_homogeneous
abbrev shoutReadProjectionSound := @Nightstream.shoutReadProjectionSound
abbrev twistValProjectionSound := @Nightstream.twistValProjectionSound

end ProjectionInterface

end Nightstream
