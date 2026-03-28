namespace Nightstream.Rv64IM

structure DecodeHandoff (MemWidth : Type _) where
  usesRs2 : Bool
  isLoad : Bool
  isStore : Bool
  memWidth : MemWidth
  memUnsigned : Bool
  isFirstInSequence : Bool
  isLastInSequence : Bool
deriving Repr

structure DecodedStage1Row
  (Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _) where
  valid : Bool
  instructionWordArch : Nat
  unexpandedPc : Word
  virtualOpcode : VirtualOpcode
  isVirtualInstruction : Bool
  isFirstInSequence : Bool
  isLastInSequence : Bool
  rd : RegIdx
  rs1 : RegIdx
  rs2 : RegIdx
  imm : Word
  writesAluToRd : Bool
  writesMemToRd : Bool
  preservesRd : Bool
  isJal : Bool
  isJalr : Bool
  isBranch : Bool
  isLoad : Bool
  isStore : Bool
  usesRs2 : Bool
  aluOp : AluOp
  branchOp : BranchOp
  memWidth : MemWidth
  memUnsigned : Bool
  divremKind : DivRemKind
  isWOp : Bool
  isMul : Bool
  isDiv : Bool
  isRem : Bool
deriving Repr

def DecodedStage1Row.toDecodeHandoff
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  DecodeHandoff MemWidth :=
  { usesRs2 := row.usesRs2
    isLoad := row.isLoad
    isStore := row.isStore
    memWidth := row.memWidth
    memUnsigned := row.memUnsigned
    isFirstInSequence := row.isFirstInSequence
    isLastInSequence := row.isLastInSequence }

def DecodedStage1Row.advanceArchPc
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) : Bool :=
  row.isLastInSequence

def DecodeHandoffBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (handoff : DecodeHandoff MemWidth) : Prop :=
  handoff = row.toDecodeHandoff

def X0WritePreserved
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (x0 : RegIdx)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  Prop :=
  row.rd = x0 →
    row.preservesRd = true ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = false

def NonFinalRdTargetBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (isArchitectural : RegIdx → Prop)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  Prop :=
  row.isLastInSequence = false →
    (row.writesAluToRd = true ∨ row.writesMemToRd = true) →
      ¬ isArchitectural row.rd

def FetchDecodeBound
  {BytecodeAddr Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind))
  (expandedPc : BytecodeAddr)
  (x0 : RegIdx)
  (isArchitectural : RegIdx → Prop)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  Prop :=
  bytecodeTable expandedPc = some row ∧
    row.valid = true ∧
    DecodeHandoffBound row row.toDecodeHandoff ∧
    X0WritePreserved x0 row ∧
    NonFinalRdTargetBound isArchitectural row

theorem decodeHandoffBound_refl
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  DecodeHandoffBound row row.toDecodeHandoff := by
  rfl

theorem advanceArchPc_eq_isLastInSequence
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind) :
  row.advanceArchPc = row.isLastInSequence := by
  rfl

theorem fetchDecodeBound_bytecodeRow
  {BytecodeAddr Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)}
  {expandedPc : BytecodeAddr}
  {x0 : RegIdx}
  {isArchitectural : RegIdx → Prop}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  (h : FetchDecodeBound bytecodeTable expandedPc x0 isArchitectural row) :
  bytecodeTable expandedPc = some row :=
  h.1

theorem fetchDecodeBound_valid
  {BytecodeAddr Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)}
  {expandedPc : BytecodeAddr}
  {x0 : RegIdx}
  {isArchitectural : RegIdx → Prop}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  (h : FetchDecodeBound bytecodeTable expandedPc x0 isArchitectural row) :
  row.valid = true :=
  h.2.1

theorem fetchDecodeBound_handoff
  {BytecodeAddr Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)}
  {expandedPc : BytecodeAddr}
  {x0 : RegIdx}
  {isArchitectural : RegIdx → Prop}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  (h : FetchDecodeBound bytecodeTable expandedPc x0 isArchitectural row) :
  DecodeHandoffBound row row.toDecodeHandoff :=
  h.2.2.1

theorem fetchDecodeBound_x0Preserved
  {BytecodeAddr Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)}
  {expandedPc : BytecodeAddr}
  {x0 : RegIdx}
  {isArchitectural : RegIdx → Prop}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  (h : FetchDecodeBound bytecodeTable expandedPc x0 isArchitectural row) :
  X0WritePreserved x0 row :=
  h.2.2.2.1

theorem fetchDecodeBound_nonFinalRdTarget
  {BytecodeAddr Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)}
  {expandedPc : BytecodeAddr}
  {x0 : RegIdx}
  {isArchitectural : RegIdx → Prop}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  (h : FetchDecodeBound bytecodeTable expandedPc x0 isArchitectural row) :
  NonFinalRdTargetBound isArchitectural row :=
  h.2.2.2.2

end Nightstream.Rv64IM
