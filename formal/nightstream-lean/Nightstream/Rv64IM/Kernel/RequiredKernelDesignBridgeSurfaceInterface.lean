import Nightstream.Rv64IM.Kernel.RequiredKernelDesignBridgeSurface

namespace Nightstream.Rv64IM

namespace RequiredKernelDesignBridgeSurfaceInterface

def implementationModule : String :=
  "Nightstream.Rv64IM.Kernel.RequiredKernelDesignBridgeSurface"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.AcceptedProofArtifactCorpus"
  , "Nightstream.Rv64IM.Kernel.RequiredKernelDesignBridgeSurface"
  ]

abbrev requiredKernelDesignBridgeRustExportBlockers :=
  Nightstream.Rv64IM.requiredKernelDesignBridgeRustExportBlockers
abbrev uniqueMissingRequiredKernelDesignBridgeFields :=
  Nightstream.Rv64IM.uniqueMissingRequiredKernelDesignBridgeFields
abbrev uniqueRequiredKernelDesignBridgeRustExportBlockers :=
  Nightstream.Rv64IM.uniqueRequiredKernelDesignBridgeRustExportBlockers

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end RequiredKernelDesignBridgeSurfaceInterface

end Nightstream.Rv64IM
