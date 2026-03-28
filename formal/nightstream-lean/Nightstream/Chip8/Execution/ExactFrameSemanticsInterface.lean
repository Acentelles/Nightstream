import Nightstream.Chip8.Execution.ExactFrameSemantics

namespace Nightstream.Chip8

namespace ExactFrameSemanticsInterface

-- ── Types ──

abbrev F := Nightstream.Chip8.ExactFrameSemantics.F
abbrev Program := Nightstream.Chip8.ExactFrameSemantics.Program
abbrev MachineState := Nightstream.Chip8.ExactFrameSemantics.MachineState
abbrev InitialState := Nightstream.Chip8.ExactFrameSemantics.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.ExactFrameSemantics.ExternalSchedule

-- ── Theorems ──

abbrev microstepCorrect_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.microstepCorrect_of_exactFrameEvidence
abbrev ldImm_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.ldImm_facts_of_exactFrameEvidence
abbrev addImm_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.addImm_facts_of_exactFrameEvidence
abbrev mov_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.mov_facts_of_exactFrameEvidence
abbrev addReg_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.addReg_facts_of_exactFrameEvidence
abbrev skipEqImm_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.skipEqImm_facts_of_exactFrameEvidence
abbrev jump_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.jump_facts_of_exactFrameEvidence
abbrev ldI_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.ldI_facts_of_exactFrameEvidence
abbrev storeRegs_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.storeRegs_facts_of_exactFrameEvidence
abbrev loadRegs_facts_of_exactFrameEvidence :=
  @Nightstream.Chip8.ExactFrameSemantics.loadRegs_facts_of_exactFrameEvidence

end ExactFrameSemanticsInterface

end Nightstream.Chip8
