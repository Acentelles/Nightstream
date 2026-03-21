import Nightstream.Chip8.Kernel.Poseidon2Transcript

namespace Nightstream.Chip8.Poseidon2TranscriptInterface

open Nightstream.Chip8.Poseidon2Transcript

abbrev FieldElem := Nightstream.Chip8.Poseidon2Transcript.FieldElem
abbrev Byte := Nightstream.Chip8.Poseidon2Transcript.Byte
abbrev TranscriptOp := Nightstream.Chip8.Poseidon2Transcript.TranscriptOp

abbrev poseidon2AppDomain := Nightstream.Chip8.Poseidon2Transcript.poseidon2AppDomain
abbrev simpleKernelTranscriptAppLabel :=
  Nightstream.Chip8.Poseidon2Transcript.simpleKernelTranscriptAppLabel
abbrev transcriptSeedLabel := Nightstream.Chip8.Poseidon2Transcript.transcriptSeedLabel
abbrev challengeLabelLabel := Nightstream.Chip8.Poseidon2Transcript.challengeLabelLabel
abbrev domainGateWord := Nightstream.Chip8.Poseidon2Transcript.domainGateWord
abbrev utf8Bytes := Nightstream.Chip8.Poseidon2Transcript.utf8Bytes
abbrev littleEndianNat := Nightstream.Chip8.Poseidon2Transcript.littleEndianNat
abbrev packBytesWords := Nightstream.Chip8.Poseidon2Transcript.packBytesWords
abbrev absorbPackedBytesWithLenWords :=
  Nightstream.Chip8.Poseidon2Transcript.absorbPackedBytesWithLenWords
abbrev u64LoWord := Nightstream.Chip8.Poseidon2Transcript.u64LoWord
abbrev u64HiWord := Nightstream.Chip8.Poseidon2Transcript.u64HiWord
abbrev splitU64Words := Nightstream.Chip8.Poseidon2Transcript.splitU64Words
abbrev appendMessageWords := Nightstream.Chip8.Poseidon2Transcript.appendMessageWords
abbrev appendU64Words := Nightstream.Chip8.Poseidon2Transcript.appendU64Words
abbrev toFieldElems := Nightstream.Chip8.Poseidon2Transcript.toFieldElems
abbrev transcriptOpLabel? := Nightstream.Chip8.Poseidon2Transcript.transcriptOpLabel?
abbrev transcriptOpAbsorbWords := Nightstream.Chip8.Poseidon2Transcript.transcriptOpAbsorbWords
abbrev transcriptOpsAbsorbWords := Nightstream.Chip8.Poseidon2Transcript.transcriptOpsAbsorbWords
abbrev transcriptOpsAbsorbFields := Nightstream.Chip8.Poseidon2Transcript.transcriptOpsAbsorbFields
abbrev root0TranscriptPreludeOps := Nightstream.Chip8.Poseidon2Transcript.root0TranscriptPreludeOps

theorem packBytesWords_nil :
    Nightstream.Chip8.Poseidon2Transcript.packBytesWords [] = [] :=
  Nightstream.Chip8.Poseidon2Transcript.packBytesWords_nil

theorem absorbPackedBytesWithLenWords_nonempty (bytes : List Byte) :
    (Nightstream.Chip8.Poseidon2Transcript.absorbPackedBytesWithLenWords bytes).length > 0 :=
  Nightstream.Chip8.Poseidon2Transcript.absorbPackedBytesWithLenWords_nonempty bytes

theorem appendMessageWords_prefix (label : String) (msg : List Byte) :
    (Nightstream.Chip8.Poseidon2Transcript.appendMessageWords label msg).take 1 =
      [Nightstream.Chip8.Poseidon2Transcript.utf8Bytes label |>.length] :=
  Nightstream.Chip8.Poseidon2Transcript.appendMessageWords_prefix label msg

theorem root0TranscriptPrelude_labels (transcriptSeed : List Byte) :
    (Nightstream.Chip8.Poseidon2Transcript.root0TranscriptPreludeOps transcriptSeed).filterMap
        Nightstream.Chip8.Poseidon2Transcript.transcriptOpLabel? =
      [ Nightstream.Chip8.Poseidon2Transcript.poseidon2AppDomain
      , Nightstream.Chip8.Poseidon2Transcript.transcriptSeedLabel
      ] :=
  Nightstream.Chip8.Poseidon2Transcript.root0TranscriptPrelude_labels transcriptSeed

theorem root0DigestOps_labels_of_conform
    {CommitmentDigest Digest RootParamsId : Type*}
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    {bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest)}
    {pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId}
    (transcriptSeed : List Byte)
    (hConform : Nightstream.Chip8.Root0Preimage.root0CommitmentDigestBindingsConform bindings) :
    (Nightstream.Chip8.Poseidon2Transcript.root0DigestOps
        encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).filterMap
        Nightstream.Chip8.Poseidon2Transcript.transcriptOpLabel? =
      [ Nightstream.Chip8.Poseidon2Transcript.poseidon2AppDomain
      , Nightstream.Chip8.Poseidon2Transcript.transcriptSeedLabel
      ] ++ Nightstream.Chip8.MetaPubEncoding.root0MetaPubLabels.take 3 ++
        Nightstream.Chip8.Root0Preimage.root0CommitmentLabels ++
        Nightstream.Chip8.MetaPubEncoding.root0MetaPubLabels.drop 3 :=
  Nightstream.Chip8.Poseidon2Transcript.root0DigestOps_labels_of_conform
    encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed hConform

theorem root0DigestInputWords_suffix
    {CommitmentDigest Digest RootParamsId : Type*}
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) :
    (Nightstream.Chip8.Poseidon2Transcript.root0DigestInputWords
        encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).getLast? =
      some Nightstream.Chip8.Poseidon2Transcript.domainGateWord :=
  Nightstream.Chip8.Poseidon2Transcript.root0DigestInputWords_suffix
    encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta

end Nightstream.Chip8.Poseidon2TranscriptInterface
