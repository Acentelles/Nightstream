import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "aligned_negative_offset_roundtrip", fixtureId := "aligned_negative_offset_roundtrip_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.nativeAlu, .alignedMemory, .controlFlow] }
  , startPc := 0
  , programWords := [44040339, 4262804515, 4286918915, 115]
  , initialRegisters := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := [{ addr := 8192, value := 13 }, { addr := 8200, value := 99 }]
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 97, 108, 105, 103, 110, 101, 100, 45, 109, 101, 109, 111, 114, 121, 45, 102, 111, 99, 117, 115, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip
