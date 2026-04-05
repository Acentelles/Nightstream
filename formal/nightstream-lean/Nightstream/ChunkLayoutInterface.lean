import Nightstream.ChunkLayout

/-!
Interface for the theorem-facing chunk layout owner.
-/

namespace Nightstream.ChunkLayoutInterface

abbrev ChunkRange := Nightstream.ChunkRange

namespace ChunkRange

abbrev width := Nightstream.ChunkRange.width
abbrev BoundedBy := Nightstream.ChunkRange.BoundedBy

end ChunkRange

namespace ChunkLayout

abbrev layout := Nightstream.ChunkLayout.layout
abbrev coveredRows := Nightstream.ChunkLayout.coveredRows
abbrev chunkIndexOf := Nightstream.ChunkLayout.chunkIndexOf
abbrev layout_wholeTrace := Nightstream.ChunkLayout.layout_wholeTrace
abbrev layout_length_eq_chunkCount := Nightstream.ChunkLayout.layout_length_eq_chunkCount
abbrev coveredRows_wholeTrace := Nightstream.ChunkLayout.coveredRows_wholeTrace
abbrev chunkIndexOf_wholeTrace := Nightstream.ChunkLayout.chunkIndexOf_wholeTrace
abbrev chunkIndexOf_lt_chunkCount_of_lt_preparedStepCount :=
  @Nightstream.ChunkLayout.chunkIndexOf_lt_chunkCount_of_lt_preparedStepCount

end ChunkLayout

end Nightstream.ChunkLayoutInterface
