import Init

/-!
Generated-case surface for RV64IM Rust↔Lean exact parity. This file owns the
typed imported source/derived schemas consumed by `Nightstream.Rv64IM.Checks`.
-/

namespace Nightstream.Rv64IM.Generated

abbrev Byte := UInt8

inductive FamilyTag where
  | nativeAlu
  | alignedMemory
  | controlFlow
deriving DecidableEq, Repr

inductive Opcode where
  | addi
  | add
  | ld
  | sd
  | ecall
deriving DecidableEq, Repr

inductive RegisterReadRole where
  | rs1
  | rs2
deriving DecidableEq, Repr

inductive RamAccessKind where
  | read
  | write
deriving DecidableEq, Repr

inductive TranscriptEventKind where
  | appendMessage
  | appendU64s
  | challengeField
  | digest32
deriving DecidableEq, Repr

structure MemoryWordView where
  addr : Nat
  value : Nat
deriving DecidableEq, Repr

structure ParityCaseManifest where
  name : String
  fixtureId : String
  protocolVersionId : Nat
  loweringVersionId : Nat
  familyTags : List FamilyTag
deriving DecidableEq, Repr

structure ParitySourceCase where
  manifest : ParityCaseManifest
  startPc : Nat
  programWords : List Nat
  initialRegisters : List Nat
  initialMemory : List MemoryWordView
  transcriptSeed : List Byte
deriving DecidableEq, Repr

structure ExpandedRowView where
  stepIndex : Nat
  pc : Nat
  nextPc : Nat
  word : Nat
  opcode : Opcode
  family : FamilyTag
  rs1 : Nat
  rs1Value : Nat
  rs2 : Nat
  rs2Value : Nat
  rd : Nat
  rdBefore : Nat
  rdAfter : Nat
  imm : Int
  aluResult : Nat
  effectiveAddr : Option Nat
  memoryBefore : Option Nat
  memoryAfter : Option Nat
  writesRd : Bool
  writesRam : Bool
  halted : Bool
deriving DecidableEq, Repr

structure Stage1RowBindingView where
  stepIndex : Nat
  fetchPc : Nat
  fetchedWord : Nat
  opcode : Opcode
  family : FamilyTag
  nextPc : Nat
  aluResult : Nat
  effectiveAddr : Option Nat
  writesRd : Bool
  rd : Nat
  rdAfter : Nat
  preservesX0 : Bool
deriving DecidableEq, Repr

structure Stage1SummaryView where
  rows : List Stage1RowBindingView
deriving DecidableEq, Repr

structure RegisterReadEventView where
  stepIndex : Nat
  role : RegisterReadRole
  reg : Nat
  value : Nat
deriving DecidableEq, Repr

structure RegisterWriteEventView where
  stepIndex : Nat
  reg : Nat
  previous : Nat
  next : Nat
deriving DecidableEq, Repr

structure RamEventView where
  stepIndex : Nat
  kind : RamAccessKind
  addr : Nat
  previous : Nat
  next : Nat
deriving DecidableEq, Repr

structure TwistLinkEventView where
  stepIndex : Nat
  family : FamilyTag
  routedWriteValue : Option Nat
  routedMemoryBefore : Option Nat
  routedMemoryAfter : Option Nat
deriving DecidableEq, Repr

structure Stage2SummaryView where
  registerReads : List RegisterReadEventView
  registerWrites : List RegisterWriteEventView
  ramEvents : List RamEventView
  twistLinks : List TwistLinkEventView
deriving DecidableEq, Repr

structure ContinuityEventView where
  stepIndex : Nat
  pc : Nat
  nextPc : Nat
  successorPc : Option Nat
  finalStep : Bool
  continuityHolds : Bool
deriving DecidableEq, Repr

structure Stage3SummaryView where
  continuity : List ContinuityEventView
  halted : Bool
deriving DecidableEq, Repr

structure CursorSnapshotWords where
  stateWords : List Nat
  absorbed : Nat
deriving DecidableEq, Repr

structure TranscriptEventView where
  kind : TranscriptEventKind
  label : List Byte
  message : List Byte
  u64s : List Nat
  cursorBefore : CursorSnapshotWords
  cursorAfter : CursorSnapshotWords
  challengeOutput : Option Nat
  digestOutput : Option (List Byte)
deriving DecidableEq, Repr

structure TranscriptView where
  appLabel : List Byte
  events : List TranscriptEventView
deriving DecidableEq, Repr

structure KernelSummaryView where
  root0Digest : List Byte
  stage1Digest : List Byte
  stage2Digest : List Byte
  stage3Digest : List Byte
  executionDigest : List Byte
  finalStateDigest : List Byte
  stage1Mix : Nat
  stage2RegMix : Nat
  stage2RamMix : Nat
  stage3ContinuityMix : Nat
  kernelFinalMix : Nat
  transcriptFinalDigest : List Byte
  finalPc : Nat
  finalRegisters : List Nat
  finalMemory : List MemoryWordView
  halted : Bool
deriving DecidableEq, Repr

structure ParityDerivedCase where
  manifest : ParityCaseManifest
  executionRows : List ExpandedRowView
  stage1 : Stage1SummaryView
  stage2 : Stage2SummaryView
  stage3 : Stage3SummaryView
  transcript : TranscriptView
  kernel : KernelSummaryView
deriving DecidableEq, Repr

def bytes (values : List Nat) : List Byte :=
  values.map UInt8.ofNat

def zeroBytes (n : Nat) : List Byte :=
  bytes (List.replicate n 0)

end Nightstream.Rv64IM.Generated
