import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_word_arith_chain_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "native_word_arith_chain_ecall", fixtureId := "native_word_arith_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [4293918875, 2130203, 4293563, 1080198203, 115]
  , initialRegisters := [0, 0, 0, 2147483647, 2, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 97, 114, 105, 116, 104, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_word_arith_chain_ecall
