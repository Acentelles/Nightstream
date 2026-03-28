import Nightstream.Rv64IM.AcceptedArtifactConstructorAudit

/-!
Interface for the executable RV64IM accepted-artifact exact-constructor audit.
-/

namespace Nightstream.Rv64IM

namespace AcceptedArtifactConstructorAuditInterface

def implementationModule : String :=
  "Nightstream.Rv64IM.AcceptedArtifactConstructorAudit"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.AcceptedArtifactConstructorAudit"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end AcceptedArtifactConstructorAuditInterface

end Nightstream.Rv64IM
