import Nightstream.Rv64IM.AcceptedArtifactTemporalReplay

/-!
Interface for constructive accepted-artifact temporal replay recovery.
-/

namespace Nightstream.Rv64IM

namespace AcceptedArtifactTemporalReplayInterface

def implementationModule : String :=
  "Nightstream.Rv64IM.AcceptedArtifactTemporalReplay"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.AcceptedArtifactTemporalReplay"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end AcceptedArtifactTemporalReplayInterface

end Nightstream.Rv64IM
