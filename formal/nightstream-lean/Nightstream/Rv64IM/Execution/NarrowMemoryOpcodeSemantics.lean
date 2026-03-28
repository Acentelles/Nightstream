import Nightstream.Rv64IM.Execution.NarrowMemoryLoweringSemantics

/-!
Owns exact theorem-facing opcode consequences for the RV64IM narrow-memory
family. This file sits above narrow-memory lowering semantics and closes the
exact-opcode gap for `LB`, `LBU`, `LH`, `LHU`, `LW`, `LWU`, `SB`, `SH`, and
`SW`.
-/

namespace Nightstream.Rv64IM

structure NarrowMemoryWidths (MemWidth : Type _) where
  byte : MemWidth
  half : MemWidth
  word : MemWidth

inductive NarrowMemoryOpcode where
  | lb
  | lbu
  | lh
  | lhu
  | lw
  | lwu
  | sb
  | sh
  | sw
deriving Repr, DecidableEq

def NarrowMemoryOpcode.isLoad : NarrowMemoryOpcode → Bool
  | .lb | .lbu | .lh | .lhu | .lw | .lwu => true
  | .sb | .sh | .sw => false

def NarrowMemoryOpcode.isStore : NarrowMemoryOpcode → Bool
  | .lb | .lbu | .lh | .lhu | .lw | .lwu => false
  | .sb | .sh | .sw => true

def NarrowMemoryOpcode.usesRs2 : NarrowMemoryOpcode → Bool
  | .lb | .lbu | .lh | .lhu | .lw | .lwu => false
  | .sb | .sh | .sw => true

def NarrowMemoryOpcode.memUnsigned : NarrowMemoryOpcode → Bool
  | .lb | .lh | .lw | .sb | .sh | .sw => false
  | .lbu | .lhu | .lwu => true

def NarrowMemoryWidths.forOpcode
  {MemWidth : Type _}
  (widths : NarrowMemoryWidths MemWidth) :
  NarrowMemoryOpcode → MemWidth
  | .lb | .lbu | .sb => widths.byte
  | .lh | .lhu | .sh => widths.half
  | .lw | .lwu | .sw => widths.word

def NarrowMemoryOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (widths : NarrowMemoryWidths MemWidth)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : NarrowMemoryOpcode) : Prop :=
  row.isJal = false ∧
    row.isJalr = false ∧
    row.isBranch = false ∧
    row.isMul = false ∧
    row.isDiv = false ∧
    row.isRem = false ∧
    row.isWOp = false ∧
    row.isLoad = opcode.isLoad ∧
    row.isStore = opcode.isStore ∧
    row.usesRs2 = opcode.usesRs2 ∧
    row.writesAluToRd = false ∧
    row.memWidth = widths.forOpcode opcode ∧
    row.memUnsigned = opcode.memUnsigned

theorem flags_of_narrowMemoryOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {widths : NarrowMemoryWidths MemWidth}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NarrowMemoryOpcode}
  (h : NarrowMemoryOpcodeBound widths row opcode) :
  row.isLoad = opcode.isLoad ∧
    row.isStore = opcode.isStore ∧
    row.usesRs2 = opcode.usesRs2 ∧
    row.writesAluToRd = false ∧
    row.memWidth = widths.forOpcode opcode ∧
    row.memUnsigned = opcode.memUnsigned := by
  rcases h with
    ⟨_, _, _, _, _, _, _, hLoad, hStore, hUsesRs2, hWritesAlu, hWidth, hUnsigned⟩
  exact ⟨hLoad, hStore, hUsesRs2, hWritesAlu, hWidth, hUnsigned⟩

theorem rowClassFlags_of_narrowMemoryOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {widths : NarrowMemoryWidths MemWidth}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NarrowMemoryOpcode}
  (h : NarrowMemoryOpcodeBound widths row opcode) :
  row.isJal = false ∧
    row.isJalr = false ∧
    row.isBranch = false ∧
    row.isMul = false ∧
    row.isDiv = false ∧
    row.isRem = false ∧
    row.isWOp = false := by
  rcases h with
    ⟨hJal, hJalr, hBranch, hMul, hDiv, hRem, hW, _, _, _, _, _, _⟩
  exact ⟨hJal, hJalr, hBranch, hMul, hDiv, hRem, hW⟩

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]
  {pkg :
    StepCompositionProofPackage
      BytecodeAddr
      Pc
      RegIdx
      VirtualOpcode
      AluOp
      BranchOp
      MemWidth
      DivRemKind
      RamAddr
      Word
      StateLocation
      RegisterTimeline
      RamTimeline
      Limb
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      PreparedStep}

theorem flags_of_narrowMemoryOpcodeSemantics
  (_facts :
    ExactOpcodeFamilySemantics
      BytecodeAddr
      Pc
      RegIdx
      VirtualOpcode
      AluOp
      BranchOp
      MemWidth
      DivRemKind
      RamAddr
      Word
      StateLocation
      RegisterTimeline
      RamTimeline
      Limb
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      PreparedStep
      pkg)
  {widths : NarrowMemoryWidths MemWidth}
  {opcode : NarrowMemoryOpcode}
  (hOpcode : NarrowMemoryOpcodeBound widths pkg.decodedRow opcode) :
  pkg.decodedRow.isLoad = opcode.isLoad ∧
    pkg.decodedRow.isStore = opcode.isStore ∧
    pkg.decodedRow.usesRs2 = opcode.usesRs2 ∧
    pkg.decodedRow.writesAluToRd = false ∧
    pkg.decodedRow.memWidth = widths.forOpcode opcode ∧
    pkg.decodedRow.memUnsigned = opcode.memUnsigned :=
  flags_of_narrowMemoryOpcodeBound hOpcode

theorem x0WritePreserved_of_narrowMemoryOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
      BytecodeAddr
      Pc
      RegIdx
      VirtualOpcode
      AluOp
      BranchOp
      MemWidth
      DivRemKind
      RamAddr
      Word
      StateLocation
      RegisterTimeline
      RamTimeline
      Limb
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      PreparedStep
      pkg)
  (hRd : pkg.decodedRow.rd = pkg.x0) :
  pkg.decodedRow.preservesRd = true ∧
    pkg.decodedRow.writesAluToRd = false ∧
    pkg.decodedRow.writesMemToRd = false :=
  x0WritePreserved_of_narrowMemoryLoweringSemantics facts hRd

theorem classFlags_of_narrowMemoryOpcodeSemantics
  (_facts :
    ExactOpcodeFamilySemantics
      BytecodeAddr
      Pc
      RegIdx
      VirtualOpcode
      AluOp
      BranchOp
      MemWidth
      DivRemKind
      RamAddr
      Word
      StateLocation
      RegisterTimeline
      RamTimeline
      Limb
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      PreparedStep
      pkg)
  {widths : NarrowMemoryWidths MemWidth}
  {opcode : NarrowMemoryOpcode}
  (hOpcode : NarrowMemoryOpcodeBound widths pkg.decodedRow opcode) :
  pkg.decodedRow.isJal = false ∧
    pkg.decodedRow.isJalr = false ∧
    pkg.decodedRow.isBranch = false ∧
    pkg.decodedRow.isMul = false ∧
    pkg.decodedRow.isDiv = false ∧
    pkg.decodedRow.isRem = false ∧
    pkg.decodedRow.isWOp = false :=
  rowClassFlags_of_narrowMemoryOpcodeBound hOpcode

theorem sequenceCorrect_of_narrowMemoryOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
      BytecodeAddr
      Pc
      RegIdx
      VirtualOpcode
      AluOp
      BranchOp
      MemWidth
      DivRemKind
      RamAddr
      Word
      StateLocation
      RegisterTimeline
      RamTimeline
      Limb
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      PreparedStep
      pkg)
  {widths : NarrowMemoryWidths MemWidth}
  {_opcode : NarrowMemoryOpcode}
  (_hOpcode : NarrowMemoryOpcodeBound widths pkg.decodedRow _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.narrowMemorySequenceProof.sequence
    facts.narrowMemorySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  sequenceCorrect_of_narrowMemoryLoweringSemantics facts

theorem sequenceDeterministic_of_narrowMemoryOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
      BytecodeAddr
      Pc
      RegIdx
      VirtualOpcode
      AluOp
      BranchOp
      MemWidth
      DivRemKind
      RamAddr
      Word
      StateLocation
      RegisterTimeline
      RamTimeline
      Limb
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      PreparedStep
      pkg)
  {widths : NarrowMemoryWidths MemWidth}
  {_opcode : NarrowMemoryOpcode}
  (_hOpcode : NarrowMemoryOpcodeBound widths pkg.decodedRow _opcode) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.narrowMemorySequenceProof.sequence
    facts.narrowMemorySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  sequenceDeterministic_of_narrowMemoryLoweringSemantics facts

end

end Nightstream.Rv64IM
