import Nightstream.Chip8.Kernel.TranscriptSchedule

namespace Nightstream.Chip8

namespace TranscriptScheduleInterface

abbrev TranscriptEvent := Nightstream.Chip8.TranscriptSchedule.TranscriptEvent
abbrev root0CommitmentIds := Nightstream.Chip8.TranscriptSchedule.root0CommitmentIds
abbrev phase0Events := Nightstream.Chip8.TranscriptSchedule.phase0Events
abbrev stage1Events := Nightstream.Chip8.TranscriptSchedule.stage1Events
abbrev stage2Events := Nightstream.Chip8.TranscriptSchedule.stage2Events
abbrev stage3PrefixEvents := Nightstream.Chip8.TranscriptSchedule.stage3PrefixEvents
abbrev stage3RowBindingEvents := Nightstream.Chip8.TranscriptSchedule.stage3RowBindingEvents
abbrev stage3Events := Nightstream.Chip8.TranscriptSchedule.stage3Events
abbrev transcriptEvents := Nightstream.Chip8.TranscriptSchedule.transcriptEvents
abbrev KernelTranscriptSchedule :=
  @Nightstream.Chip8.TranscriptSchedule.KernelTranscriptSchedule
abbrev challengeEvents := Nightstream.Chip8.TranscriptSchedule.challengeEvents
abbrev ChallengeEvent := Nightstream.Chip8.TranscriptSchedule.ChallengeEvent
abbrev stage1TerminalPointEvents :=
  Nightstream.Chip8.TranscriptSchedule.stage1TerminalPointEvents
abbrev Stage1TerminalPointEvent :=
  Nightstream.Chip8.TranscriptSchedule.Stage1TerminalPointEvent
abbrev stage2TerminalPointEvents :=
  Nightstream.Chip8.TranscriptSchedule.stage2TerminalPointEvents
abbrev Stage2TerminalPointEvent :=
  Nightstream.Chip8.TranscriptSchedule.Stage2TerminalPointEvent
abbrev root0CommitmentIds_nodup :=
  Nightstream.Chip8.TranscriptSchedule.root0CommitmentIds_nodup
abbrev mem_root0CommitmentIds_iff_isKernelCommitment :=
  Nightstream.Chip8.TranscriptSchedule.mem_root0CommitmentIds_iff_isKernelCommitment
abbrev kernelClaim_commitment_fixed_in_root0 :=
  @Nightstream.Chip8.TranscriptSchedule.kernelClaim_commitment_fixed_in_root0
abbrev kernelTranscriptSchedule_phase0_prefix :=
  @Nightstream.Chip8.TranscriptSchedule.kernelTranscriptSchedule_phase0_prefix
abbrev kernelTranscriptSchedule_stage1_prefix :=
  @Nightstream.Chip8.TranscriptSchedule.kernelTranscriptSchedule_stage1_prefix
abbrev kernelTranscriptSchedule_stage2_prefix :=
  @Nightstream.Chip8.TranscriptSchedule.kernelTranscriptSchedule_stage2_prefix
abbrev kernelTranscriptSchedule_stage3_prefix :=
  @Nightstream.Chip8.TranscriptSchedule.kernelTranscriptSchedule_stage3_prefix
abbrev challenge_after_phase0 :=
  @Nightstream.Chip8.TranscriptSchedule.challenge_after_phase0
abbrev stage1TerminalPoint_after_phase0 :=
  @Nightstream.Chip8.TranscriptSchedule.stage1TerminalPoint_after_phase0
abbrev stage2TerminalPoint_after_phase0 :=
  @Nightstream.Chip8.TranscriptSchedule.stage2TerminalPoint_after_phase0
abbrev deriveAdd8LoAddr_not_challenge :=
  Nightstream.Chip8.TranscriptSchedule.deriveAdd8LoAddr_not_challenge
abbrev rowBinding_mem_stage3RowBindingEvents_iff :=
  @Nightstream.Chip8.TranscriptSchedule.rowBinding_mem_stage3RowBindingEvents_iff
abbrev rowBinding_event_in_schedule_iff :=
  @Nightstream.Chip8.TranscriptSchedule.rowBinding_event_in_schedule_iff
abbrev emitKernelOpeningClaims_last :=
  @Nightstream.Chip8.TranscriptSchedule.emitKernelOpeningClaims_last

end TranscriptScheduleInterface

end Nightstream.Chip8
