import Nightstream.Chip8.Stage3.ContinuityBridge

namespace Nightstream.Chip8

namespace ContinuityBridgeInterface

abbrev PairMaskN := @Nightstream.Chip8.ContinuityBridge.PairMaskN
abbrev pairMaskValue := @Nightstream.Chip8.ContinuityBridge.pairMaskValue
abbrev ShiftedLaneColumn := Nightstream.Chip8.ContinuityBridge.ShiftedLaneColumn
abbrev LaneShiftClaim := @Nightstream.Chip8.ContinuityBridge.LaneShiftClaim
abbrev LaneShiftWitness := @Nightstream.Chip8.ContinuityBridge.LaneShiftWitness
abbrev LaneShiftBound := @Nightstream.Chip8.ContinuityBridge.LaneShiftBound
abbrev ContinuityRow := @Nightstream.Chip8.ContinuityBridge.ContinuityRow
abbrev deltaPc := @Nightstream.Chip8.ContinuityBridge.deltaPc
abbrev deltaBurstStep := @Nightstream.Chip8.ContinuityBridge.deltaBurstStep
abbrev deltaBurstReset := @Nightstream.Chip8.ContinuityBridge.deltaBurstReset
abbrev ContinuityBound := @Nightstream.Chip8.ContinuityBridge.ContinuityBound
abbrev StartBoundaryRow := @Nightstream.Chip8.ContinuityBridge.StartBoundaryRow
abbrev StartBoundaryBound := @Nightstream.Chip8.ContinuityBridge.StartBoundaryBound
abbrev StartBoundaryMatches :=
  @Nightstream.Chip8.ContinuityBridge.StartBoundaryMatches
abbrev FinalBoundaryRow := @Nightstream.Chip8.ContinuityBridge.FinalBoundaryRow
abbrev FinalBoundaryBound := @Nightstream.Chip8.ContinuityBridge.FinalBoundaryBound
abbrev FinalBoundaryMatches :=
  @Nightstream.Chip8.ContinuityBridge.FinalBoundaryMatches
abbrev rowNonFixedValues := @Nightstream.Chip8.ContinuityBridge.rowNonFixedValues
abbrev RowBindingClaim := @Nightstream.Chip8.ContinuityBridge.RowBindingClaim
abbrev RowBound := @Nightstream.Chip8.ContinuityBridge.RowBound
abbrev RootEncode := @Nightstream.Chip8.ContinuityBridge.RootEncode
abbrev PreparedWitness := @Nightstream.Chip8.ContinuityBridge.PreparedWitness
abbrev PreparedMcs := @Nightstream.Chip8.ContinuityBridge.PreparedMcs
abbrev PreparedStep := @Nightstream.Chip8.ContinuityBridge.PreparedStep
abbrev mkPreparedStep := @Nightstream.Chip8.ContinuityBridge.mkPreparedStep
abbrev PreparedStepBound := @Nightstream.Chip8.ContinuityBridge.PreparedStepBound
abbrev Stage3Bound := @Nightstream.Chip8.ContinuityBridge.Stage3Bound

abbrev continuityBound_of_laneShift :=
  @Nightstream.Chip8.ContinuityBridge.continuityBound_of_laneShift
abbrev preparedStepBound_of_rowBinding :=
  @Nightstream.Chip8.ContinuityBridge.preparedStepBound_of_rowBinding
abbrev startBoundaryBound_of_match :=
  @Nightstream.Chip8.ContinuityBridge.startBoundaryBound_of_match
abbrev finalBoundaryBound_of_match :=
  @Nightstream.Chip8.ContinuityBridge.finalBoundaryBound_of_match
abbrev stage3Bound_exports_authenticatedRows :=
  @Nightstream.Chip8.ContinuityBridge.stage3Bound_exports_authenticatedRows

end ContinuityBridgeInterface

end Nightstream.Chip8
