import Nightstream.Chip8.Kernel.BoundaryParity

namespace Nightstream.Chip8

namespace BoundaryParityInterface

abbrev OpeningRefinement := Nightstream.Chip8.BoundaryParity.OpeningRefinement
abbrev AcceptedDirectOpening := Nightstream.Chip8.BoundaryParity.AcceptedDirectOpening

abbrev RegisterSessionKey := Nightstream.Chip8.BoundaryParity.RegisterSessionKey
abbrev RegisterSessionKeyBound := Nightstream.Chip8.BoundaryParity.RegisterSessionKeyBound
abbrev regRaYKey_sink_iff_not_usesY :=
  @Nightstream.Chip8.BoundaryParity.regRaYKey_sink_iff_not_usesY
abbrev regWaKey_sink_iff_no_lane_write :=
  @Nightstream.Chip8.BoundaryParity.regWaKey_sink_iff_no_lane_write

abbrev ActivePrefixContinuityRefinement :=
  @Nightstream.Chip8.BoundaryParity.ActivePrefixContinuityRefinement
abbrev continuityRowBound_of_activePrefixRefinement :=
  @Nightstream.Chip8.BoundaryParity.continuityRowBound_of_activePrefixRefinement

abbrev KernelMetaPub := @Nightstream.Chip8.BoundaryParity.KernelMetaPub
abbrev root0MetaPubAbsorbPlan := @Nightstream.Chip8.BoundaryParity.root0MetaPubAbsorbPlan

abbrev KernelTranscriptSchedule := @Nightstream.Chip8.BoundaryParity.KernelTranscriptSchedule
abbrev transcriptEvents := Nightstream.Chip8.BoundaryParity.transcriptEvents
abbrev root0DigestCursor := @Nightstream.Chip8.BoundaryParity.root0DigestCursor

abbrev KernelPublicInputsBound := @Nightstream.Chip8.BoundaryParity.KernelPublicInputsBound
abbrev kernelPublicInputsBound_of_authenticatedInputs :=
  @Nightstream.Chip8.BoundaryParity.kernelPublicInputsBound_of_authenticatedInputs

abbrev Stage2TemporalContextBound :=
  @Nightstream.Chip8.BoundaryParity.Stage2TemporalContextBound
abbrev temporalInstantiationBound_of_stage2_and_bridge :=
  @Nightstream.Chip8.BoundaryParity.temporalInstantiationBound_of_stage2_and_bridge

abbrev PcAdjacentBridge := @Nightstream.Chip8.BoundaryParity.PcAdjacentBridge
abbrev pcTemporalBound_of_adjacentBridge :=
  @Nightstream.Chip8.BoundaryParity.pcTemporalBound_of_adjacentBridge

abbrev BridgeBindingBundle := @Nightstream.Chip8.BoundaryParity.BridgeBindingBundle
abbrev exists_bridgeBindingBundle_of_exactEvidence :=
  @Nightstream.Chip8.BoundaryParity.exists_bridgeBindingBundle_of_exactEvidence

end BoundaryParityInterface

end Nightstream.Chip8
