import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "multiply_low_mul_mulw_ecall", fixtureId := "multiply_low_mul_mulw_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.multiply, .controlFlow] }
  , startPc := 0
  , programWords := [35685043, 37847867, 115]
  , initialRegisters := [0, 3, 5, 18446744073709551615, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 109, 117, 108, 116, 105, 112, 108, 121, 45, 108, 111, 119, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall
