import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "multiply_high_mulh_mulhu_mulhsu_ecall", fixtureId := "multiply_high_mulh_mulhu_mulhsu_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , startPc := 0
  , programWords := [35689395, 37860403, 40019123, 115]
  , initialRegisters := [0, 18446744073709551614, 18446744073709551613, 18446744073709551614, 3, 18446744073709551614, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 109, 117, 108, 116, 105, 112, 108, 121, 45, 104, 105, 103, 104, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall
