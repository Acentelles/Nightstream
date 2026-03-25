import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "signed_divrem_chain_ecall", fixtureId := "signed_divrem_chain_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.signedDivRem, .controlFlow] }
  , startPc := 0
  , programWords := [35701427, 35709747, 37864371, 37872691, 44352955, 44361275, 48678835, 48687155, 53004731, 53013051, 115]
  , initialRegisters := [0, 18446744073709551596, 6, 9223372036854775808, 18446744073709551615, 0, 0, 0, 0, 18446744073709551607, 4, 0, 0, 7, 0, 0, 0, 18446744071562067969, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 115, 105, 103, 110, 101, 100, 45, 100, 105, 118, 114, 101, 109, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall
