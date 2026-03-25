import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_logic_compare_chain_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "native_logic_compare_chain_ecall", fixtureId := "native_logic_compare_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [5243027, 3146003, 2159027, 6353427, 2155187, 8479507, 2147251, 7390227, 1123507, 4269331, 1127859, 4240915, 15, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 108, 111, 103, 105, 99, 45, 99, 111, 109, 112, 97, 114, 101, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_logic_compare_chain_ecall
