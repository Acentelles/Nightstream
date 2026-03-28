import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "narrow_memory_store_blend_ecall", fixtureId := "narrow_memory_store_blend_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.narrowMemory, .controlFlow] }
  , startPc := 0
  , programWords := [1376419, 2429219, 3482147, 115]
  , initialRegisters := [0, 18446744073709551615, 291, 305418343, 0, 0, 0, 0, 0, 0, 16384, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := [{ addr := 16384, value := 9833440827789222417 }]
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 114, 114, 111, 119, 45, 109, 101, 109, 111, 114, 121, 45, 115, 116, 111, 114, 101, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_store_blend_ecall
