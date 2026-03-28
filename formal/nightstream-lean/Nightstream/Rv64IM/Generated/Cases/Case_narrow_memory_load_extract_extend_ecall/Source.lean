import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "narrow_memory_load_extract_extend_ecall", fixtureId := "narrow_memory_load_extract_extend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , startPc := 0
  , programWords := [327811, 1392899, 332163, 2445827, 336515, 4547331, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 12288, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := [{ addr := 12288, value := 9920249032750366975 }]
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 114, 114, 111, 119, 45, 109, 101, 109, 111, 114, 121, 45, 108, 111, 97, 100, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall
