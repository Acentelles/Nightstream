import Nightstream.Rv64IM.AcceptedArtifactCompleteness

/-!
Interface for the executable RV64IM accepted-artifact theorem-completeness audit.
-/

namespace Nightstream.Rv64IM

namespace AcceptedArtifactCompletenessInterface

def implementationModule : String := "Nightstream.Rv64IM.AcceptedArtifactCompleteness"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.AcceptedArtifactCompleteness"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end AcceptedArtifactCompletenessInterface

end Nightstream.Rv64IM
