import Nightstream.Rv64IM.Kernel.RequiredBackendPayloadSurface

/-!
Interface for the theorem-facing RV64IM backend payload export surface owner.
-/

namespace Nightstream.Rv64IM

namespace RequiredBackendPayloadSurfaceInterface

def implementationModule : String :=
  "Nightstream.Rv64IM.Kernel.RequiredBackendPayloadSurface"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.Kernel.RequiredBackendPayloadSurface"
  ]

abbrev requiredBackendPayloadRustExportBlockers :=
  Nightstream.Rv64IM.requiredBackendPayloadRustExportBlockers
abbrev uniqueMissingRequiredBackendPayloadFields :=
  Nightstream.Rv64IM.uniqueMissingRequiredBackendPayloadFields
abbrev uniqueRequiredBackendPayloadRustExportBlockers :=
  Nightstream.Rv64IM.uniqueRequiredBackendPayloadRustExportBlockers

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end RequiredBackendPayloadSurfaceInterface

end Nightstream.Rv64IM
