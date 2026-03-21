import Nightstream.Chip8.Stage2.TwistTraceRoleSessions

namespace Nightstream.Chip8

namespace TwistTraceRoleSessionsInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.TwistTraceRoleSessions.F
abbrev Program := Nightstream.Chip8.TwistTraceRoleSessions.Program
abbrev MachineState := Nightstream.Chip8.TwistTraceRoleSessions.MachineState
abbrev InitialState := Nightstream.Chip8.TwistTraceRoleSessions.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.TwistTraceRoleSessions.ExternalSchedule

-- ── Structures ──

abbrev ExactFrameEvidence := @Nightstream.Chip8.AuthenticatedTrace.ExactFrameEvidence
abbrev ExactFrameRoleSessions :=
  @Nightstream.Chip8.TwistTraceRoleSessions.ExactFrameRoleSessions
abbrev ExactFrameRoleSessionsBound :=
  @Nightstream.Chip8.TwistTraceRoleSessions.ExactFrameRoleSessionsBound
abbrev ExactTraceRoleSessionsBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.ExactTraceRoleSessionsBundle
abbrev ExactTraceRoleSessionsBundleBound :=
  @Nightstream.Chip8.TwistTraceRoleSessions.ExactTraceRoleSessionsBundleBound

-- ── Theorems: Frame-Level Construction ──

noncomputable abbrev exactFrameRoleSessions_of_exactFrameEvidence :=
  @Nightstream.Chip8.TwistTraceRoleSessions.exactFrameRoleSessions_of_exactFrameEvidence
abbrev exactFrameRoleSessionsBound_of_exactFrameEvidence :=
  @Nightstream.Chip8.TwistTraceRoleSessions.exactFrameRoleSessionsBound_of_exactFrameEvidence
abbrev exactTraceRoleSessionsBound_of_frames :=
  @Nightstream.Chip8.TwistTraceRoleSessions.exactTraceRoleSessionsBound_of_frames

-- ── Theorems: Trace-Level Construction ──

noncomputable abbrev exactTraceRoleSessionsBundle_of_frames :=
  @Nightstream.Chip8.TwistTraceRoleSessions.exactTraceRoleSessionsBundle_of_frames
abbrev exactTraceRoleSessionsBundleBound_of_frames :=
  @Nightstream.Chip8.TwistTraceRoleSessions.exactTraceRoleSessionsBundleBound_of_frames

-- ── Theorems: Value Equalities ──

abbrev registerReadXValue_eq_primaryValue_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerReadXValue_eq_primaryValue_of_traceBundle
abbrev registerReadYValue_eq_secondaryValue_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerReadYValue_eq_secondaryValue_of_traceBundle
abbrev registerReadIValue_eq_preI_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerReadIValue_eq_preI_of_traceBundle
abbrev registerWriteRegValue_eq_postValue_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerWriteRegValue_eq_postValue_of_traceBundle

-- ── Theorems: Trace Expected Matches ──

abbrev registerReadsExpected_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerReadsExpected_of_traceBundle
abbrev registerWritesExpected_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerWritesExpected_of_traceBundle
abbrev ramReadsExpected_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.ramReadsExpected_of_traceBundle
abbrev ramWritesExpected_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.ramWritesExpected_of_traceBundle

-- ── Theorems: Role Value Coherence ──

abbrev registerReads_eq_roleValues_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerReads_eq_roleValues_of_traceBundle
abbrev registerWrites_eq_roleValues_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerWrites_eq_roleValues_of_traceBundle
abbrev registerReads_eq_roleValues_tracewise :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerReads_eq_roleValues_tracewise
abbrev registerWrites_eq_roleValues_tracewise :=
  @Nightstream.Chip8.TwistTraceRoleSessions.registerWrites_eq_roleValues_tracewise
abbrev loadRamReads_eq_roleValues_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.loadRamReads_eq_roleValues_of_traceBundle
abbrev storeRamWrites_eq_roleValues_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.storeRamWrites_eq_roleValues_of_traceBundle
abbrev loadRamReads_eq_roleValues_tracewise :=
  @Nightstream.Chip8.TwistTraceRoleSessions.loadRamReads_eq_roleValues_tracewise
abbrev storeRamWrites_eq_roleValues_tracewise :=
  @Nightstream.Chip8.TwistTraceRoleSessions.storeRamWrites_eq_roleValues_tracewise
abbrev loadRamReadMemValue_eq_preRam_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.loadRamReadMemValue_eq_preRam_of_traceBundle
abbrev storeRamWriteMemValue_eq_postRam_of_traceBundle :=
  @Nightstream.Chip8.TwistTraceRoleSessions.storeRamWriteMemValue_eq_postRam_of_traceBundle
abbrev loadRamReadMemValue_eq_preRam_tracewise :=
  @Nightstream.Chip8.TwistTraceRoleSessions.loadRamReadMemValue_eq_preRam_tracewise
abbrev storeRamWriteMemValue_eq_postRam_tracewise :=
  @Nightstream.Chip8.TwistTraceRoleSessions.storeRamWriteMemValue_eq_postRam_tracewise

end TwistTraceRoleSessionsInterface

end Nightstream.Chip8
