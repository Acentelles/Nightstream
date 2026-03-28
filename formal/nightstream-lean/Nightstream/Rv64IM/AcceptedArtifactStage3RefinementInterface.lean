import Nightstream.Rv64IM.AcceptedArtifactStage3Refinement

/-!
Interface for constructive Stage 3 refinement recovery from the recompute-first
RV64IM accepted-artifact surface.
-/

namespace Nightstream.Rv64IM

namespace AcceptedArtifactStage3RefinementInterface

abbrev recoverStage3Refinement? := @Nightstream.Rv64IM.recoverStage3Refinement?
abbrev recoveredStage3RefinementMatchesArtifact :=
  @Nightstream.Rv64IM.recoveredStage3RefinementMatchesArtifact
abbrev recoveredStage3ContinuitySemantics :=
  @Nightstream.Rv64IM.recoveredStage3ContinuitySemantics
abbrev recoveredStage3ExportSemantics :=
  @Nightstream.Rv64IM.recoveredStage3ExportSemantics

def implementationModule : String :=
  "Nightstream.Rv64IM.AcceptedArtifactStage3Refinement"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.AcceptedArtifactStage3Refinement"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end AcceptedArtifactStage3RefinementInterface

end Nightstream.Rv64IM
