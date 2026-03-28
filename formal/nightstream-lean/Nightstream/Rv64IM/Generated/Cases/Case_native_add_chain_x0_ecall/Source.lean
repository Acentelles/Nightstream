import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "native_add_chain_x0_ecall", fixtureId := "native_add_chain_x0_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .controlFlow] }
  , startPc := 0
  , programWords := [7340179, 9470227, 1114547, 5341203, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 110, 97, 116, 105, 118, 101, 45, 97, 108, 117, 45, 102, 111, 99, 117, 115, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_native_add_chain_x0_ecall
