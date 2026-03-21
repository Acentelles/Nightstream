import Nightstream.Chip8.Kernel.StagedExecutionDigestBundle

namespace Nightstream.Chip8

namespace StagedExecutionDigestBundleInterface

abbrev F := Nightstream.Chip8.StagedExecutionDigestBundle.F
abbrev Program := Nightstream.Chip8.StagedExecutionDigestBundle.Program
abbrev MachineState := Nightstream.Chip8.StagedExecutionDigestBundle.MachineState
abbrev InitialState := Nightstream.Chip8.StagedExecutionDigestBundle.InitialState
abbrev ExternalSchedule := Nightstream.Chip8.StagedExecutionDigestBundle.ExternalSchedule

abbrev ExactFrames := @Nightstream.Chip8.StagedExecutionDigestBundle.ExactFrames
abbrev FrameDigestEntry := @Nightstream.Chip8.StagedExecutionDigestBundle.FrameDigestEntry
abbrev StagedExecutionDigestBundle :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.DigestBundle

noncomputable abbrev frameDigestEntry_of_exactFrame :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.frameDigestEntry_of_exactFrame
noncomputable abbrev frameDigestEntries_of_frames :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.frameDigestEntries_of_frames
noncomputable abbrev stagedExecutionDigestBundle_of_frames :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.stagedExecutionDigestBundle_of_frames

abbrev kernelPublicInputsBound_of_bundle :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.kernelPublicInputsBound_of_bundle
abbrev executionFrameBound_of_entry :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.executionFrameBound_of_entry
abbrev bundleLength_eq :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.bundleLength_eq
abbrev bundleLength_eq_semanticRows :=
  @Nightstream.Chip8.StagedExecutionDigestBundle.bundleLength_eq_semanticRows

end StagedExecutionDigestBundleInterface

end Nightstream.Chip8
