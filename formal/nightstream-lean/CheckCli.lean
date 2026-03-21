import Init
import Nightstream.Chip8.Checks

def main : IO UInt32 := do
  IO.println s!"chip8_transcript_vector_checks={Nightstream.Chip8.transcriptVectorChecks}"
  IO.println s!"chip8_transcript_vector_reports={reprStr Nightstream.Chip8.transcriptVectorReports}"
  if Nightstream.Chip8.validGeneratedTranscriptVectorCases then
    pure 0
  else
    pure 1
