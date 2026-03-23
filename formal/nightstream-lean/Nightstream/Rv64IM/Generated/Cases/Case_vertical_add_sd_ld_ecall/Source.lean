import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "vertical_add_sd_ld_ecall", fixtureId := "vertical_add_sd_ld_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , startPc := 0
  , programWords := [5243027, 1081651, 2437155, 340355, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4096, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := [{ addr := 4096, value := 0 }]
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 118, 101, 114, 116, 105, 99, 97, 108, 45, 115, 108, 105, 99, 101, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_vertical_add_sd_ld_ecall
