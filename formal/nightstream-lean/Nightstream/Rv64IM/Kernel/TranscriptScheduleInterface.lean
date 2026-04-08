import Nightstream.Rv64IM.Kernel.TranscriptSchedule

namespace Nightstream.Rv64IM

namespace TranscriptScheduleInterface

abbrev CommitmentDigest := Nightstream.Rv64IM.CommitmentDigest
abbrev Root0CommitmentId := Nightstream.Rv64IM.Root0CommitmentId
abbrev Root0CommitmentBinding := Nightstream.Rv64IM.Root0CommitmentBinding
abbrev TranscriptEvent := Nightstream.Rv64IM.TranscriptEvent
abbrev root0CommitmentIds := Nightstream.Rv64IM.root0CommitmentIds
abbrev root0CommitmentBindingsConform :=
  Nightstream.Rv64IM.root0CommitmentBindingsConform
abbrev phase0Events := Nightstream.Rv64IM.phase0Events
abbrev rootChunkRowLabelEvents := Nightstream.Rv64IM.rootChunkRowLabelEvents
abbrev rootChunkEvents := Nightstream.Rv64IM.rootChunkEvents
abbrev rootMainLaneEvents := Nightstream.Rv64IM.rootMainLaneEvents
abbrev stage1Events := Nightstream.Rv64IM.stage1Events
abbrev stage2Events := Nightstream.Rv64IM.stage2Events
abbrev stage3PrefixEvents := Nightstream.Rv64IM.stage3PrefixEvents
abbrev stage3RowBindingEvents := Nightstream.Rv64IM.stage3RowBindingEvents
abbrev stage3Events := Nightstream.Rv64IM.stage3Events
abbrev transcriptEvents := Nightstream.Rv64IM.transcriptEvents
abbrev KernelTranscriptSchedule := Nightstream.Rv64IM.KernelTranscriptSchedule
abbrev challengeEvents := Nightstream.Rv64IM.challengeEvents
abbrev ChallengeEvent := Nightstream.Rv64IM.ChallengeEvent
abbrev root0CommitmentIds_nodup := Nightstream.Rv64IM.root0CommitmentIds_nodup
abbrev root0CommitmentBindings_ids := @Nightstream.Rv64IM.root0CommitmentBindings_ids
abbrev transcriptSchedule_scheduleValid :=
  @Nightstream.Rv64IM.transcriptSchedule_scheduleValid
abbrev transcriptSchedule_events := @Nightstream.Rv64IM.transcriptSchedule_events
abbrev rootMainLaneEvents_prefix := @Nightstream.Rv64IM.rootMainLaneEvents_prefix
abbrev kernelTranscriptSchedule_rootMainLane_prefix :=
  @Nightstream.Rv64IM.kernelTranscriptSchedule_rootMainLane_prefix
abbrev rootChunkStart_mem_rootMainLaneEvents_of_layout :=
  @Nightstream.Rv64IM.rootChunkStart_mem_rootMainLaneEvents_of_layout
abbrev rootChunkPiCCS_mem_rootMainLaneEvents_of_layout :=
  @Nightstream.Rv64IM.rootChunkPiCCS_mem_rootMainLaneEvents_of_layout
abbrev rootChunkPiRLC_mem_rootMainLaneEvents_of_layout :=
  @Nightstream.Rv64IM.rootChunkPiRLC_mem_rootMainLaneEvents_of_layout
abbrev rootChunkPiDEC_mem_rootMainLaneEvents_of_layout :=
  @Nightstream.Rv64IM.rootChunkPiDEC_mem_rootMainLaneEvents_of_layout
abbrev rootChunkRowLabel_mem_rootMainLaneEvents_of_layout :=
  @Nightstream.Rv64IM.rootChunkRowLabel_mem_rootMainLaneEvents_of_layout

end TranscriptScheduleInterface

end Nightstream.Rv64IM
