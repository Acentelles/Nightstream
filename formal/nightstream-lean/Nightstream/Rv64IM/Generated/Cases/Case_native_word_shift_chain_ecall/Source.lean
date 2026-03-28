import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_word_shift_chain_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "native_word_shift_chain_ecall", fixtureId := "native_word_shift_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [32543131, 4280859, 1078022811, 6329275, 6378555, 1080120507, 115]
  , initialRegisters := [0, 1, 18446744071562067968, 0, 0, 0, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 119, 111, 114, 100, 45, 115, 104, 105, 102, 116, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_word_shift_chain_ecall
