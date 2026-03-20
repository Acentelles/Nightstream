import Nightstream.Chip8.Kernel.StagedExecutionDigest

namespace Nightstream.Chip8

namespace StagedExecutionDigestInterface

abbrev F := Nightstream.Chip8.StagedExecutionDigest.F
abbrev Program := Nightstream.Chip8.StagedExecutionDigest.Program
abbrev MachineState := Nightstream.Chip8.StagedExecutionDigest.MachineState
abbrev InitialState := Nightstream.Chip8.StagedExecutionDigest.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.StagedExecutionDigest.ExternalSchedule
abbrev DigestPublicSurface := @Nightstream.Chip8.StagedExecutionDigest.DigestPublicSurface
abbrev Stage1DigestSurface := @Nightstream.Chip8.StagedExecutionDigest.Stage1DigestSurface
abbrev Stage2DigestSurface := @Nightstream.Chip8.StagedExecutionDigest.Stage2DigestSurface
abbrev Stage3DigestSurface := @Nightstream.Chip8.StagedExecutionDigest.Stage3DigestSurface
abbrev ExecutionResultSurface := @Nightstream.Chip8.StagedExecutionDigest.ExecutionResultSurface
abbrev StagedExecutionDigest := @Nightstream.Chip8.StagedExecutionDigest.StagedExecutionDigest
abbrev StagedExecutionDigestBound :=
  @Nightstream.Chip8.StagedExecutionDigest.StagedExecutionDigestBound

abbrev kernelPublicInputsBound_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.kernelPublicInputsBound_of_digest
abbrev fetchDecodeBound_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.fetchDecodeBound_of_digest
abbrev lookupBound_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.lookupBound_of_digest
abbrev witnessBinds_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.witnessBinds_of_digest
abbrev memoryBound_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.memoryBound_of_digest
abbrev continuityRowBound_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.continuityRowBound_of_digest
abbrev executionFrameBound_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.executionFrameBound_of_digest
abbrev preparedStepBound_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.preparedStepBound_of_digest
abbrev bridgeBinding_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.bridgeBinding_of_digest
abbrev executionResultSurface_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.executionResultSurface_of_digest
abbrev microstepCorrect_of_digest :=
  @Nightstream.Chip8.StagedExecutionDigest.microstepCorrect_of_digest
abbrev stagedExecutionDigest_of_exactEvidence :=
  @Nightstream.Chip8.StagedExecutionDigest.stagedExecutionDigest_of_exactEvidence

end StagedExecutionDigestInterface

end Nightstream.Chip8
