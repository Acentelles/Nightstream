import Nightstream.FoldSchedule

namespace Nightstream

namespace FoldScheduleInterface

abbrev FoldSchedule := Nightstream.FoldSchedule

namespace FoldSchedule

abbrev Valid := Nightstream.FoldSchedule.Valid
abbrev chunkCount := Nightstream.FoldSchedule.chunkCount
abbrev valid_wholeTrace := Nightstream.FoldSchedule.valid_wholeTrace
abbrev valid_rowsPerChunk_iff := @Nightstream.FoldSchedule.valid_rowsPerChunk_iff
abbrev chunkCount_wholeTrace := Nightstream.FoldSchedule.chunkCount_wholeTrace
abbrev chunkCount_eq_of_valid_wholeTrace :=
  @Nightstream.FoldSchedule.chunkCount_eq_of_valid_wholeTrace

end FoldSchedule

end FoldScheduleInterface

end Nightstream
