import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_unsigned_divrem_chain_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "unsigned_divrem_chain_ecall", fixtureId := "unsigned_divrem_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.unsignedDivRem, .controlFlow] }
  , startPc := 0
  , programWords := [35705523, 35713843, 37868475, 37876795, 44357043, 44365363, 48682939, 48691259, 115]
  , initialRegisters := [0, 20, 6, 18446744073709551615, 3, 0, 0, 0, 0, 9, 0, 0, 0, 18446744071562067969, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 117, 110, 115, 105, 103, 110, 101, 100, 45, 100, 105, 118, 114, 101, 109, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_unsigned_divrem_chain_ecall
