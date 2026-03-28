import Nightstream.Rv64IM.Checks

/-!
Interface for the executable RV64IM exact-parity checks.

Spec:
`./formal/nightstream-lean/specs/rv64im/Rv64IMChecks.spec.md`
-/

namespace Nightstream.Rv64IM

namespace ChecksInterface

def implementationModule : String := "Nightstream.Rv64IM.Checks"

def exportedModuleNames : List String :=
  [ "Nightstream.Rv64IM.Generated.ImportedParityCorpus"
  , "Nightstream.Rv64IM.Checks"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end ChecksInterface

end Nightstream.Rv64IM
