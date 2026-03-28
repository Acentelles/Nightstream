import Nightstream.Chip8.Kernel.RomScheduleBinding

/-!
Owns the exact theorem-facing `KernelMetaPub` payload and the canonical labeled
`meta_pub` absorption sequence used at `root0`. This file does not own the
Poseidon2 permutation itself; it owns the ordered payload that later transcript
and digest owners must consume.
-/

namespace Nightstream.Chip8.MetaPubEncoding

open Nightstream.Chip8

section

variable {Digest RootParamsId : Type*}

structure KernelMetaPub (Digest RootParamsId : Type*) where
  programImageDigest : Digest
  initialStateDigest : Digest
  romTableDigest : Digest
  decodeTableDigest : Digest
  aluTableDigest : Digest
  eq4TableDigest : Digest
  transcriptSeedDigest : Digest
  protocolVersionId : Nat
  fieldId : Nat
  extensionFieldId : Nat
  rootParamsId : RootParamsId
  variableOrderId : Nat
  domainShapeId : Nat
  sinkConventionId : Nat
  initModeId : Nat
  loweringConventionId : Nat
  paddingConventionId : Nat
  tableAuthModeId : Nat
  openingReductionModeId : Nat
  programWordCount : Nat
  semanticRows : Nat
  paddedTraceLength : Nat
  padPcWord : Nat
  programBaseAddr : Nat
  cycleBits : Nat
deriving DecidableEq, Repr

def kernelMetaCore (pubMeta : KernelMetaPub Digest RootParamsId) :
    RomScheduleBinding.KernelMeta Digest RootParamsId :=
  { programImageDigest := pubMeta.programImageDigest
  , initialStateDigest := pubMeta.initialStateDigest
  , programWordCount := pubMeta.programWordCount
  , semanticRows := pubMeta.semanticRows
  , paddedTraceLength := pubMeta.paddedTraceLength
  , padPcWord := pubMeta.padPcWord
  , programBaseAddr := pubMeta.programBaseAddr
  , cycleBits := pubMeta.cycleBits
  , rootParamsId := pubMeta.rootParamsId
  }

def metaPubNumericSuffix (pubMeta : KernelMetaPub Digest RootParamsId) :
    List Nat :=
  [ pubMeta.variableOrderId
  , pubMeta.domainShapeId
  , pubMeta.sinkConventionId
  , pubMeta.initModeId
  , pubMeta.loweringConventionId
  , pubMeta.paddingConventionId
  , pubMeta.tableAuthModeId
  , pubMeta.openingReductionModeId
  , pubMeta.programWordCount
  , pubMeta.semanticRows
  , pubMeta.paddedTraceLength
  , pubMeta.padPcWord
  , pubMeta.programBaseAddr
  , pubMeta.cycleBits
  ]

inductive Root0MetaAbsorbOp (Digest RootParamsId : Type*) where
  | absorbU64s (label : String) (values : List Nat)
  | absorbDigest (label : String) (value : Digest)
  | absorbRootParamsId (label : String) (value : RootParamsId)
deriving DecidableEq, Repr

def root0MetaAbsorbOpLabel :
    Root0MetaAbsorbOp Digest RootParamsId → String
  | .absorbU64s label _ => label
  | .absorbDigest label _ => label
  | .absorbRootParamsId label _ => label

def root0VersionLabel : String := "chip8/root0/version"
def root0FieldIdLabel : String := "chip8/root0/field_id"
def root0ExtensionFieldIdLabel : String := "chip8/root0/extension_field_id"
def root0ProgramImageDigestLabel : String := "chip8/root0/program_image_digest"
def root0InitialStateDigestLabel : String := "chip8/root0/initial_state_digest"
def root0RomTableDigestLabel : String := "chip8/root0/rom_table_digest"
def root0DecodeTableDigestLabel : String := "chip8/root0/decode_table_digest"
def root0AluTableDigestLabel : String := "chip8/root0/alu_table_digest"
def root0Eq4TableDigestLabel : String := "chip8/root0/eq4_table_digest"
def root0TranscriptSeedDigestLabel : String := "chip8/root0/transcript_seed_digest"
def root0RootParamsIdLabel : String := "chip8/root0/root_params_id"
def root0MetaPubLabel : String := "chip8/root0/meta_pub"

def root0MetaPubLabels : List String :=
  [ root0VersionLabel
  , root0FieldIdLabel
  , root0ExtensionFieldIdLabel
  , root0ProgramImageDigestLabel
  , root0InitialStateDigestLabel
  , root0RomTableDigestLabel
  , root0DecodeTableDigestLabel
  , root0AluTableDigestLabel
  , root0Eq4TableDigestLabel
  , root0TranscriptSeedDigestLabel
  , root0RootParamsIdLabel
  , root0MetaPubLabel
  ]

def root0MetaPubAbsorbPlan (pubMeta : KernelMetaPub Digest RootParamsId) :
    List (Root0MetaAbsorbOp Digest RootParamsId) :=
  [ .absorbU64s root0VersionLabel [pubMeta.protocolVersionId]
  , .absorbU64s root0FieldIdLabel [pubMeta.fieldId]
  , .absorbU64s root0ExtensionFieldIdLabel [pubMeta.extensionFieldId]
  , .absorbDigest root0ProgramImageDigestLabel pubMeta.programImageDigest
  , .absorbDigest root0InitialStateDigestLabel pubMeta.initialStateDigest
  , .absorbDigest root0RomTableDigestLabel pubMeta.romTableDigest
  , .absorbDigest root0DecodeTableDigestLabel pubMeta.decodeTableDigest
  , .absorbDigest root0AluTableDigestLabel pubMeta.aluTableDigest
  , .absorbDigest root0Eq4TableDigestLabel pubMeta.eq4TableDigest
  , .absorbDigest root0TranscriptSeedDigestLabel pubMeta.transcriptSeedDigest
  , .absorbRootParamsId root0RootParamsIdLabel pubMeta.rootParamsId
  , .absorbU64s root0MetaPubLabel (metaPubNumericSuffix pubMeta)
  ]

@[simp] theorem kernelMetaCore_programImageDigest (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).programImageDigest = pubMeta.programImageDigest := rfl

@[simp] theorem kernelMetaCore_initialStateDigest (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).initialStateDigest = pubMeta.initialStateDigest := rfl

@[simp] theorem kernelMetaCore_rootParamsId (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).rootParamsId = pubMeta.rootParamsId := rfl

@[simp] theorem kernelMetaCore_programWordCount (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).programWordCount = pubMeta.programWordCount := rfl

@[simp] theorem kernelMetaCore_semanticRows (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).semanticRows = pubMeta.semanticRows := rfl

@[simp] theorem kernelMetaCore_paddedTraceLength (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).paddedTraceLength = pubMeta.paddedTraceLength := rfl

@[simp] theorem kernelMetaCore_padPcWord (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).padPcWord = pubMeta.padPcWord := rfl

@[simp] theorem kernelMetaCore_programBaseAddr (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).programBaseAddr = pubMeta.programBaseAddr := rfl

@[simp] theorem kernelMetaCore_cycleBits (pubMeta : KernelMetaPub Digest RootParamsId) :
    (kernelMetaCore pubMeta).cycleBits = pubMeta.cycleBits := rfl

@[simp] theorem metaPubNumericSuffix_length (pubMeta : KernelMetaPub Digest RootParamsId) :
    (metaPubNumericSuffix pubMeta).length = 14 := by
  simp [metaPubNumericSuffix]

@[simp] theorem root0MetaPubAbsorbPlan_length (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaPubAbsorbPlan pubMeta).length = 12 := by
  simp [root0MetaPubAbsorbPlan]

@[simp] theorem root0MetaPubAbsorbPlan_labels (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaPubAbsorbPlan pubMeta).map root0MetaAbsorbOpLabel = root0MetaPubLabels := by
  simp [root0MetaPubAbsorbPlan, root0MetaPubLabels, root0MetaAbsorbOpLabel]

@[simp] theorem root0MetaPubAbsorbPlan_suffix (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaPubAbsorbPlan pubMeta).getLast? =
      some (.absorbU64s root0MetaPubLabel (metaPubNumericSuffix pubMeta)) := by
  simp [root0MetaPubAbsorbPlan, root0MetaPubLabel]

@[simp] theorem root0MetaPubAbsorbPlan_rootParamsEntry (pubMeta : KernelMetaPub Digest RootParamsId) :
    (root0MetaPubAbsorbPlan pubMeta).drop 10 =
      [ Root0MetaAbsorbOp.absorbRootParamsId root0RootParamsIdLabel pubMeta.rootParamsId
      , Root0MetaAbsorbOp.absorbU64s root0MetaPubLabel (metaPubNumericSuffix pubMeta)
      ] := by
  rfl

end

end Nightstream.Chip8.MetaPubEncoding
