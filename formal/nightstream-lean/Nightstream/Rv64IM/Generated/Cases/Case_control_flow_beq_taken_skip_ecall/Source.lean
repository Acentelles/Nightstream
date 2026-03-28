import Nightstream.Rv64IM.Generated.ParityTypes

namespace Nightstream.Rv64IM.Generated.Cases.Case_control_flow_beq_taken_skip_ecall

open Nightstream.Rv64IM.Generated

def sourceCase : ParitySourceCase :=
  {
  manifest := { name := "control_flow_beq_taken_skip_ecall", fixtureId := "control_flow_beq_taken_skip_ecall_v1", protocolVersionId := 1, loweringVersionId := 1, familyTags := [.controlFlow] }
  , startPc := 0
  , programWords := [2131043, 115, 115]
  , initialRegisters := [0, 11, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  , initialMemory := []
  , transcriptSeed := (bytes [114, 118, 54, 52, 105, 109, 45, 99, 111, 110, 116, 114, 111, 108, 45, 102, 108, 111, 119, 45, 98, 101, 113, 45, 118, 49])
}

end Nightstream.Rv64IM.Generated.Cases.Case_control_flow_beq_taken_skip_ecall
