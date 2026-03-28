import Nightstream.Chip8.Stage3.PaddedContinuityCheck

namespace Nightstream.Chip8

namespace PaddedContinuityCheckInterface

abbrev RawShiftValues := @Nightstream.Chip8.PaddedContinuityCheck.RawShiftValues
abbrev RawCurrentValues :=
  @Nightstream.Chip8.PaddedContinuityCheck.RawCurrentValues
abbrev TailCorrections := @Nightstream.Chip8.PaddedContinuityCheck.TailCorrections

abbrev correctedShiftPc :=
  @Nightstream.Chip8.PaddedContinuityCheck.correctedShiftPc
abbrev correctedShiftXIdx :=
  @Nightstream.Chip8.PaddedContinuityCheck.correctedShiftXIdx
abbrev correctedShiftIsMemOp :=
  @Nightstream.Chip8.PaddedContinuityCheck.correctedShiftIsMemOp
abbrev correctedPcNext := @Nightstream.Chip8.PaddedContinuityCheck.correctedPcNext
abbrev correctedXIdx := @Nightstream.Chip8.PaddedContinuityCheck.correctedXIdx
abbrev correctedIsMemOp :=
  @Nightstream.Chip8.PaddedContinuityCheck.correctedIsMemOp
abbrev correctedBurstLast :=
  @Nightstream.Chip8.PaddedContinuityCheck.correctedBurstLast

abbrev PaddedContinuityCheckBound :=
  @Nightstream.Chip8.PaddedContinuityCheck.PaddedContinuityCheckBound

abbrev continuityBound_of_paddedCheck :=
  @Nightstream.Chip8.PaddedContinuityCheck.continuityBound_of_paddedCheck

end PaddedContinuityCheckInterface

end Nightstream.Chip8
