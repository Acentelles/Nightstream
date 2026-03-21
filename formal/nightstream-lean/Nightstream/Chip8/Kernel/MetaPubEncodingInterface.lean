import Nightstream.Chip8.Kernel.MetaPubEncoding

namespace Nightstream.Chip8

namespace MetaPubEncodingInterface

abbrev KernelMetaPub := @Nightstream.Chip8.MetaPubEncoding.KernelMetaPub
abbrev kernelMetaCore := @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore
abbrev metaPubNumericSuffix := @Nightstream.Chip8.MetaPubEncoding.metaPubNumericSuffix
abbrev Root0MetaAbsorbOp := @Nightstream.Chip8.MetaPubEncoding.Root0MetaAbsorbOp
abbrev root0MetaAbsorbOpLabel := @Nightstream.Chip8.MetaPubEncoding.root0MetaAbsorbOpLabel
abbrev root0VersionLabel := Nightstream.Chip8.MetaPubEncoding.root0VersionLabel
abbrev root0FieldIdLabel := Nightstream.Chip8.MetaPubEncoding.root0FieldIdLabel
abbrev root0ExtensionFieldIdLabel := Nightstream.Chip8.MetaPubEncoding.root0ExtensionFieldIdLabel
abbrev root0ProgramImageDigestLabel := Nightstream.Chip8.MetaPubEncoding.root0ProgramImageDigestLabel
abbrev root0InitialStateDigestLabel := Nightstream.Chip8.MetaPubEncoding.root0InitialStateDigestLabel
abbrev root0RomTableDigestLabel := Nightstream.Chip8.MetaPubEncoding.root0RomTableDigestLabel
abbrev root0DecodeTableDigestLabel := Nightstream.Chip8.MetaPubEncoding.root0DecodeTableDigestLabel
abbrev root0AluTableDigestLabel := Nightstream.Chip8.MetaPubEncoding.root0AluTableDigestLabel
abbrev root0Eq4TableDigestLabel := Nightstream.Chip8.MetaPubEncoding.root0Eq4TableDigestLabel
abbrev root0TranscriptSeedDigestLabel := Nightstream.Chip8.MetaPubEncoding.root0TranscriptSeedDigestLabel
abbrev root0RootParamsIdLabel := Nightstream.Chip8.MetaPubEncoding.root0RootParamsIdLabel
abbrev root0MetaPubLabel := Nightstream.Chip8.MetaPubEncoding.root0MetaPubLabel
abbrev root0MetaPubLabels := Nightstream.Chip8.MetaPubEncoding.root0MetaPubLabels
abbrev root0MetaPubAbsorbPlan := @Nightstream.Chip8.MetaPubEncoding.root0MetaPubAbsorbPlan

abbrev kernelMetaCore_programImageDigest :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_programImageDigest
abbrev kernelMetaCore_initialStateDigest :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_initialStateDigest
abbrev kernelMetaCore_rootParamsId :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_rootParamsId
abbrev kernelMetaCore_programWordCount :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_programWordCount
abbrev kernelMetaCore_semanticRows :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_semanticRows
abbrev kernelMetaCore_paddedTraceLength :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_paddedTraceLength
abbrev kernelMetaCore_padPcWord :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_padPcWord
abbrev kernelMetaCore_programBaseAddr :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_programBaseAddr
abbrev kernelMetaCore_cycleBits :=
  @Nightstream.Chip8.MetaPubEncoding.kernelMetaCore_cycleBits
abbrev metaPubNumericSuffix_length :=
  @Nightstream.Chip8.MetaPubEncoding.metaPubNumericSuffix_length
abbrev root0MetaPubAbsorbPlan_length :=
  @Nightstream.Chip8.MetaPubEncoding.root0MetaPubAbsorbPlan_length
abbrev root0MetaPubAbsorbPlan_labels :=
  @Nightstream.Chip8.MetaPubEncoding.root0MetaPubAbsorbPlan_labels
abbrev root0MetaPubAbsorbPlan_suffix :=
  @Nightstream.Chip8.MetaPubEncoding.root0MetaPubAbsorbPlan_suffix
abbrev root0MetaPubAbsorbPlan_rootParamsEntry :=
  @Nightstream.Chip8.MetaPubEncoding.root0MetaPubAbsorbPlan_rootParamsEntry

end MetaPubEncodingInterface

end Nightstream.Chip8
