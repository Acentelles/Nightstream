import Nightstream.Chip8.Checks

/-!
Interface for the executable CHIP-8 transcript parity checks.

Spec:
`./formal/nightstream-lean/specs/chip8/Chip8Checks.spec.md`
-/

namespace Nightstream.Chip8

namespace ChecksInterface

def implementationModule : String := "Nightstream.Chip8.Checks"

def exportedModuleNames : List String :=
  [ "Nightstream.Chip8.Generated.TranscriptVectors"
  , "Nightstream.Chip8.Kernel.ConcreteTranscriptParity"
  ]

def entrypointContract : Prop := True

theorem entrypointContract_true : entrypointContract := by
  trivial

end ChecksInterface

end Nightstream.Chip8
