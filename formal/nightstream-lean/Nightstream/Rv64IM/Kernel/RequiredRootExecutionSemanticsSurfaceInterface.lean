import Nightstream.Rv64IM.Kernel.RequiredRootExecutionSemanticsSurface

namespace Nightstream.Rv64IM

namespace RequiredRootExecutionSemanticsSurfaceInterface

def implementationModule : String :=
  "Nightstream.Rv64IM.Kernel.RequiredRootExecutionSemanticsSurface"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.Kernel.RequiredRootExecutionSemanticsSurface"
  ]

abbrev requiredRootExecutionSemanticsRustExportBlockers :=
  Nightstream.Rv64IM.requiredRootExecutionSemanticsRustExportBlockers
abbrev uniqueMissingRequiredRootExecutionSemanticsFields :=
  Nightstream.Rv64IM.uniqueMissingRequiredRootExecutionSemanticsFields
abbrev uniqueRequiredRootExecutionSemanticsRustExportBlockers :=
  Nightstream.Rv64IM.uniqueRequiredRootExecutionSemanticsRustExportBlockers

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end RequiredRootExecutionSemanticsSurfaceInterface

end Nightstream.Rv64IM
