import Nightstream.Rv64IM.AcceptedArtifactBackendRefinement

/-!
Interface for the executable RV64IM backend refinement audit.
-/

namespace Nightstream.Rv64IM

namespace AcceptedArtifactBackendRefinementInterface

def implementationModule : String := "Nightstream.Rv64IM.AcceptedArtifactBackendRefinement"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.AcceptedArtifactBackendRefinement"
  ]

abbrev backendRefinementRustExportBlockers :=
  Nightstream.Rv64IM.backendRefinementRustExportBlockers
abbrev uniqueBackendRefinementRustExportBlockers :=
  Nightstream.Rv64IM.uniqueBackendRefinementRustExportBlockers

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end AcceptedArtifactBackendRefinementInterface

end Nightstream.Rv64IM
