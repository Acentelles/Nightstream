import Nightstream.Chip8.Kernel.OpeningBoundaryInterface
import Nightstream.Chip8.Kernel.MetaPubEncodingInterface
import Nightstream.Chip8.Kernel.ConcreteTranscriptParityInterface
import Nightstream.Chip8.Kernel.TranscriptScheduleInterface
import Nightstream.Chip8.Kernel.RomScheduleBindingInterface
import Nightstream.Chip8.Kernel.BridgeBindingInterface
import Nightstream.Chip8.Stage2.RegisterSessionBoundaryInterface
import Nightstream.Chip8.Stage2.TwistTemporalInstantiationInterface
import Nightstream.Chip8.Stage3.Stage3RefinementInterface
import Nightstream.Chip8.Stage3.PcContinuityBridgeInterface

/-!
Owns the theorem-facing parity map from the CHIP-8 kernel prose boundary to the
authoritative Lean owner interfaces it normatively relies on. This file adds no
new theorem logic; it freezes the exact owner surfaces reviewers should inspect
when checking the simple kernel boundary.
-/

namespace Nightstream.Chip8.BoundaryParity

abbrev OpeningRefinement := OpeningBoundaryInterface.OpeningRefinement
abbrev AcceptedDirectOpening := OpeningBoundaryInterface.AcceptedDirectOpening

abbrev RegisterSessionKey := RegisterSessionBoundaryInterface.RegisterSessionKey
abbrev RegisterSessionKeyBound := RegisterSessionBoundaryInterface.RegisterSessionKeyBound
abbrev regRaYKey_sink_iff_not_usesY :=
  @RegisterSessionBoundaryInterface.regRaYKey_sink_iff_not_usesY
abbrev regWaKey_sink_iff_no_lane_write :=
  @RegisterSessionBoundaryInterface.regWaKey_sink_iff_no_lane_write

abbrev ActivePrefixContinuityRefinement :=
  @Stage3RefinementInterface.ActivePrefixContinuityRefinement
abbrev continuityRowBound_of_activePrefixRefinement :=
  @Stage3RefinementInterface.continuityRowBound_of_activePrefixRefinement

abbrev KernelMetaPub := @MetaPubEncodingInterface.KernelMetaPub
abbrev root0MetaPubAbsorbPlan := @MetaPubEncodingInterface.root0MetaPubAbsorbPlan

abbrev KernelTranscriptSchedule := @TranscriptScheduleInterface.KernelTranscriptSchedule
abbrev transcriptEvents := TranscriptScheduleInterface.transcriptEvents
abbrev root0DigestCursor := @ConcreteTranscriptParityInterface.root0DigestCursor

abbrev KernelPublicInputsBound := @RomScheduleBindingInterface.KernelPublicInputsBound
abbrev kernelPublicInputsBound_of_authenticatedInputs :=
  @RomScheduleBindingInterface.kernelPublicInputsBound_of_authenticatedInputs

abbrev Stage2TemporalContextBound :=
  @TwistTemporalInstantiationInterface.Stage2TemporalContextBound
abbrev temporalInstantiationBound_of_stage2_and_bridge :=
  @TwistTemporalInstantiationInterface.temporalInstantiationBound_of_stage2_and_bridge

abbrev PcAdjacentBridge := @PcContinuityBridgeInterface.PcAdjacentBridge
abbrev pcTemporalBound_of_adjacentBridge :=
  @PcContinuityBridgeInterface.pcTemporalBound_of_adjacentBridge

abbrev BridgeBindingBundle := @BridgeBindingInterface.BridgeBindingBundle
abbrev exists_bridgeBindingBundle_of_exactEvidence :=
  @BridgeBindingInterface.exists_bridgeBindingBundle_of_exactEvidence

end Nightstream.Chip8.BoundaryParity
