import Nightstream.Rv64IM.Execution.AdviceSequenceSoundness
import Nightstream.Rv64IM.Execution.ExecutionSemantics
import Nightstream.Rv64IM.Execution.TemporaryRegisterHygiene
import Nightstream.Rv64IM.Execution.UnsignedDivRemSoundness
import Nightstream.Rv64IM.Execution.SignedDivRemSoundness
import Nightstream.Rv64IM.Stage1.BytecodeFetchProjection
import Nightstream.Rv64IM.Stage1.FetchDecodeBinding
import Nightstream.Rv64IM.Stage1.ExecutionRowBinding
import Nightstream.Rv64IM.Stage1.TrivialPredicateArithmetic
import Nightstream.Rv64IM.Stage1.NarrowMemoryHelpers
import Nightstream.Rv64IM.Stage2.RegisterHistoryProjection
import Nightstream.Rv64IM.Stage2.RamHistoryProjection
import Nightstream.Rv64IM.Stage2.TwistConcreteBinding
import Nightstream.Rv64IM.Stage3.ContinuityBridge

namespace Nightstream.Rv64IM

def opcodeClassOrder : List OpcodeClass :=
  [ .nativeAlu
  , .wordShift
  , .controlFlow
  , .narrowMemory
  , .multiply
  , .unsignedDivRem
  , .signedDivRem
  ]

inductive NativeAluOpcode where
  | add
  | addi
  | sub
  | andOp
  | andi
  | orOp
  | ori
  | xorOp
  | xori
  | slt
  | slti
  | sltu
  | sltiu
  | lui
  | auipc
  | fence
  | ecall
deriving Repr, DecidableEq

def NativeAluOpcode.usesRs2 : NativeAluOpcode → Bool
  | .add | .sub | .andOp | .orOp | .xorOp | .slt | .sltu => true
  | .addi | .andi | .ori | .xori | .slti | .sltiu
  | .lui | .auipc | .fence | .ecall => false

def NativeAluOpcode.writesArchitecturalRd : NativeAluOpcode → Bool
  | .fence | .ecall => false
  | _ => true

structure NativeAluAluOps (AluOp : Type _) where
  add : AluOp
  sub : AluOp
  andOp : AluOp
  orOp : AluOp
  xorOp : AluOp
  slt : AluOp
  sltu : AluOp
  lui : AluOp
  auipc : AluOp
  fence : AluOp
  ecall : AluOp

def NativeAluAluOps.forOpcode
  {AluOp : Type _}
  (ops : NativeAluAluOps AluOp) :
  NativeAluOpcode → AluOp
  | .add | .addi => ops.add
  | .sub => ops.sub
  | .andOp | .andi => ops.andOp
  | .orOp | .ori => ops.orOp
  | .xorOp | .xori => ops.xorOp
  | .slt | .slti => ops.slt
  | .sltu | .sltiu => ops.sltu
  | .lui => ops.lui
  | .auipc => ops.auipc
  | .fence => ops.fence
  | .ecall => ops.ecall

def NativeAluOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (ops : NativeAluAluOps AluOp)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : NativeAluOpcode) : Prop :=
  row.isJal = false ∧
    row.isJalr = false ∧
    row.isBranch = false ∧
    row.isLoad = false ∧
    row.isStore = false ∧
    row.isWOp = false ∧
    row.isMul = false ∧
    row.isDiv = false ∧
    row.isRem = false ∧
    row.usesRs2 = opcode.usesRs2 ∧
    row.writesMemToRd = false ∧
    row.aluOp = ops.forOpcode opcode

def NativeAluOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (x0 : RegIdx)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : NativeAluOpcode) : Prop :=
  (row.rd = x0 →
    row.preservesRd = true ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = false) ∧
    (row.rd ≠ x0 →
      if opcode.writesArchitecturalRd then
        row.preservesRd = false ∧
          row.writesAluToRd = true ∧
          row.writesMemToRd = false
      else
        row.preservesRd = true ∧
          row.writesAluToRd = false ∧
          row.writesMemToRd = false)

theorem classFlags_of_nativeAluOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : NativeAluAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeBound ops row opcode) :
  row.isJal = false ∧
    row.isJalr = false ∧
    row.isBranch = false ∧
    row.isLoad = false ∧
    row.isStore = false ∧
    row.isWOp = false ∧
    row.isMul = false ∧
    row.isDiv = false ∧
    row.isRem = false := by
  rcases h with
    ⟨hJal, hJalr, hBranch, hLoad, hStore, hWOp, hMul, hDiv, hRem, _, _, _⟩
  exact ⟨hJal, hJalr, hBranch, hLoad, hStore, hWOp, hMul, hDiv, hRem⟩

theorem usesRs2_of_nativeAluOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : NativeAluAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeBound ops row opcode) :
  row.usesRs2 = opcode.usesRs2 := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, hUsesRs2, _, _⟩
  exact hUsesRs2

theorem writesMemToRd_of_nativeAluOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : NativeAluAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeBound ops row opcode) :
  row.writesMemToRd = false := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, _, hWritesMem, _⟩
  exact hWritesMem

theorem aluOp_of_nativeAluOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : NativeAluAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeBound ops row opcode) :
  row.aluOp = ops.forOpcode opcode := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, _, _, hAluOp⟩
  exact hAluOp

theorem x0WriteFacts_of_nativeAluOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeWriteContract x0 row opcode)
  (hRd : row.rd = x0) :
  row.preservesRd = true ∧
    row.writesAluToRd = false ∧
    row.writesMemToRd = false :=
  h.1 hRd

theorem nonX0WriteFacts_of_nativeAluOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeWriteContract x0 row opcode)
  (hRd : row.rd ≠ x0) :
  if opcode.writesArchitecturalRd then
    row.preservesRd = false ∧
      row.writesAluToRd = true ∧
      row.writesMemToRd = false
  else
    row.preservesRd = true ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = false :=
  h.2 hRd

theorem activeWrite_of_nativeAluOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeWriteContract x0 row opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : row.rd ≠ x0) :
  row.preservesRd = false ∧
    row.writesAluToRd = true ∧
    row.writesMemToRd = false := by
  simpa [hWrites] using h.2 hRd

theorem passiveWrite_of_nativeAluOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : NativeAluOpcode}
  (h : NativeAluOpcodeWriteContract x0 row opcode)
  (hWrites : opcode.writesArchitecturalRd = false)
  (hRd : row.rd ≠ x0) :
  row.preservesRd = true ∧
    row.writesAluToRd = false ∧
    row.writesMemToRd = false := by
  simpa [hWrites] using h.2 hRd

inductive AlignedMemoryOpcode where
  | ld
  | sd
deriving Repr, DecidableEq

def AlignedMemoryOpcode.isLoad : AlignedMemoryOpcode → Bool
  | .ld => true
  | .sd => false

def AlignedMemoryOpcode.isStore : AlignedMemoryOpcode → Bool
  | .ld => false
  | .sd => true

def AlignedMemoryOpcode.usesRs2 : AlignedMemoryOpcode → Bool
  | .ld => false
  | .sd => true

def AlignedMemoryOpcode.writesArchitecturalRd : AlignedMemoryOpcode → Bool
  | .ld => true
  | .sd => false

def AlignedMemoryOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (doublewordWidth : MemWidth)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : AlignedMemoryOpcode) : Prop :=
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
    row.memWidth = doublewordWidth

def AlignedMemoryOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (x0 : RegIdx)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : AlignedMemoryOpcode) : Prop :=
  (row.rd = x0 →
    row.preservesRd = true ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = false) ∧
    (row.rd ≠ x0 →
      if opcode.writesArchitecturalRd then
        row.preservesRd = false ∧
          row.writesAluToRd = false ∧
          row.writesMemToRd = true
      else
        row.preservesRd = true ∧
          row.writesAluToRd = false ∧
          row.writesMemToRd = false)

theorem rowClassFlags_of_alignedMemoryOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {doublewordWidth : MemWidth}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : AlignedMemoryOpcode}
  (h : AlignedMemoryOpcodeBound doublewordWidth row opcode) :
  row.isJal = false ∧
    row.isJalr = false ∧
    row.isBranch = false ∧
    row.isMul = false ∧
    row.isDiv = false ∧
    row.isRem = false ∧
    row.isWOp = false := by
  rcases h with
    ⟨hJal, hJalr, hBranch, hMul, hDiv, hRem, hWOp, _, _, _, _, _⟩
  exact ⟨hJal, hJalr, hBranch, hMul, hDiv, hRem, hWOp⟩

theorem flags_of_alignedMemoryOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {doublewordWidth : MemWidth}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : AlignedMemoryOpcode}
  (h : AlignedMemoryOpcodeBound doublewordWidth row opcode) :
  row.isLoad = opcode.isLoad ∧
    row.isStore = opcode.isStore ∧
    row.usesRs2 = opcode.usesRs2 ∧
    row.writesAluToRd = false ∧
    row.memWidth = doublewordWidth := by
  rcases h with
    ⟨_, _, _, _, _, _, _, hLoad, hStore, hUsesRs2, hWritesAlu, hWidth⟩
  exact ⟨hLoad, hStore, hUsesRs2, hWritesAlu, hWidth⟩

theorem x0WriteFacts_of_alignedMemoryOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : AlignedMemoryOpcode}
  (h : AlignedMemoryOpcodeWriteContract x0 row opcode)
  (hRd : row.rd = x0) :
  row.preservesRd = true ∧
    row.writesAluToRd = false ∧
    row.writesMemToRd = false :=
  h.1 hRd

theorem nonX0WriteFacts_of_alignedMemoryOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : AlignedMemoryOpcode}
  (h : AlignedMemoryOpcodeWriteContract x0 row opcode)
  (hRd : row.rd ≠ x0) :
  if opcode.writesArchitecturalRd then
    row.preservesRd = false ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = true
  else
    row.preservesRd = true ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = false :=
  h.2 hRd

theorem activeMemWrite_of_alignedMemoryOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : AlignedMemoryOpcode}
  (h : AlignedMemoryOpcodeWriteContract x0 row opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : row.rd ≠ x0) :
  row.preservesRd = false ∧
    row.writesAluToRd = false ∧
    row.writesMemToRd = true := by
  simpa [hWrites] using h.2 hRd

theorem passiveWrite_of_alignedMemoryOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : AlignedMemoryOpcode}
  (h : AlignedMemoryOpcodeWriteContract x0 row opcode)
  (hWrites : opcode.writesArchitecturalRd = false)
  (hRd : row.rd ≠ x0) :
  row.preservesRd = true ∧
    row.writesAluToRd = false ∧
    row.writesMemToRd = false := by
  simpa [hWrites] using h.2 hRd

inductive WordShiftOpcode where
  | addw
  | addiw
  | subw
  | sllw
  | slliw
  | srlw
  | srliw
  | sraw
  | sraiw
deriving Repr, DecidableEq

def WordShiftOpcode.usesRs2 : WordShiftOpcode → Bool
  | .addw => true
  | .addiw => false
  | .subw => true
  | .sllw => true
  | .slliw => false
  | .srlw => true
  | .srliw => false
  | .sraw => true
  | .sraiw => false

structure WordShiftAluOps (AluOp : Type _) where
  add : AluOp
  sub : AluOp
  sll : AluOp
  srl : AluOp
  sra : AluOp

def WordShiftAluOps.forOpcode
  {AluOp : Type _}
  (ops : WordShiftAluOps AluOp) :
  WordShiftOpcode → AluOp
  | .addw | .addiw => ops.add
  | .subw => ops.sub
  | .sllw | .slliw => ops.sll
  | .srlw | .srliw => ops.srl
  | .sraw | .sraiw => ops.sra

def WordShiftOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (ops : WordShiftAluOps AluOp)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : WordShiftOpcode) : Prop :=
  row.isWOp = true ∧
    row.usesRs2 = opcode.usesRs2 ∧
    row.aluOp = ops.forOpcode opcode

def WordShiftOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (x0 : RegIdx)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (_opcode : WordShiftOpcode) : Prop :=
  (row.rd = x0 →
    row.preservesRd = true ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = false) ∧
    (row.rd ≠ x0 →
      row.preservesRd = false ∧
        row.writesAluToRd = true ∧
        row.writesMemToRd = false)

theorem isWOp_of_wordShiftOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : WordShiftAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : WordShiftOpcode}
  (h : WordShiftOpcodeBound ops row opcode) :
  row.isWOp = true :=
  h.1

theorem usesRs2_of_wordShiftOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : WordShiftAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : WordShiftOpcode}
  (h : WordShiftOpcodeBound ops row opcode) :
  row.usesRs2 = opcode.usesRs2 :=
  h.2.1

theorem aluOp_of_wordShiftOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : WordShiftAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : WordShiftOpcode}
  (h : WordShiftOpcodeBound ops row opcode) :
  row.aluOp = ops.forOpcode opcode :=
  h.2.2

theorem x0WriteFacts_of_wordShiftOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : WordShiftOpcode}
  (h : WordShiftOpcodeWriteContract x0 row opcode)
  (hRd : row.rd = x0) :
  row.preservesRd = true ∧
    row.writesAluToRd = false ∧
    row.writesMemToRd = false :=
  h.1 hRd

theorem activeWrite_of_wordShiftOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : WordShiftOpcode}
  (h : WordShiftOpcodeWriteContract x0 row opcode)
  (hRd : row.rd ≠ x0) :
  row.preservesRd = false ∧
    row.writesAluToRd = true ∧
    row.writesMemToRd = false :=
  h.2 hRd

inductive MultiplyOpcode where
  | mul
  | mulh
  | mulhu
  | mulhsu
  | mulw
deriving Repr, DecidableEq

def MultiplyOpcode.isWOp : MultiplyOpcode → Bool
  | .mulw => true
  | .mul | .mulh | .mulhu | .mulhsu => false

def MultiplyOpcode.writesArchitecturalRd : MultiplyOpcode → Bool
  | _ => true

structure MultiplyAluOps (AluOp : Type _) where
  mul : AluOp
  mulh : AluOp
  mulhu : AluOp
  mulhsu : AluOp

def MultiplyAluOps.forOpcode
  {AluOp : Type _}
  (ops : MultiplyAluOps AluOp) :
  MultiplyOpcode → AluOp
  | .mul | .mulw => ops.mul
  | .mulh => ops.mulh
  | .mulhu => ops.mulhu
  | .mulhsu => ops.mulhsu

def MultiplyOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (ops : MultiplyAluOps AluOp)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : MultiplyOpcode) : Prop :=
  row.isJal = false ∧
    row.isJalr = false ∧
    row.isBranch = false ∧
    row.isLoad = false ∧
    row.isStore = false ∧
    row.isDiv = false ∧
    row.isRem = false ∧
    row.isMul = true ∧
    row.usesRs2 = true ∧
    row.writesMemToRd = false ∧
    row.isWOp = opcode.isWOp ∧
    row.aluOp = ops.forOpcode opcode

def MultiplyOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (x0 : RegIdx)
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (_opcode : MultiplyOpcode) : Prop :=
  (row.rd = x0 →
    row.preservesRd = true ∧
      row.writesAluToRd = false ∧
      row.writesMemToRd = false) ∧
    (row.rd ≠ x0 →
      row.preservesRd = false ∧
        row.writesAluToRd = true ∧
        row.writesMemToRd = false)

theorem classFlags_of_multiplyOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : MultiplyAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : MultiplyOpcode}
  (h : MultiplyOpcodeBound ops row opcode) :
  row.isJal = false ∧
    row.isJalr = false ∧
    row.isBranch = false ∧
    row.isLoad = false ∧
    row.isStore = false ∧
  row.isDiv = false ∧
    row.isRem = false ∧
    row.isMul = true := by
  rcases h with
    ⟨hJal, hJalr, hBranch, hLoad, hStore, hDiv, hRem, hMul, _, _, _, _⟩
  exact ⟨hJal, hJalr, hBranch, hLoad, hStore, hDiv, hRem, hMul⟩

theorem usesRs2_of_multiplyOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : MultiplyAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : MultiplyOpcode}
  (h : MultiplyOpcodeBound ops row opcode) :
  row.usesRs2 = true := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, hUsesRs2, _, _, _⟩
  exact hUsesRs2

theorem writeFlags_of_multiplyOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : MultiplyAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : MultiplyOpcode}
  (h : MultiplyOpcodeBound ops row opcode) :
  row.writesMemToRd = false := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, hWritesMem, _, _⟩
  exact hWritesMem

theorem isWOp_of_multiplyOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : MultiplyAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : MultiplyOpcode}
  (h : MultiplyOpcodeBound ops row opcode) :
  row.isWOp = opcode.isWOp := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, _, hWOp, _⟩
  exact hWOp

theorem aluOp_of_multiplyOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {ops : MultiplyAluOps AluOp}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : MultiplyOpcode}
  (h : MultiplyOpcodeBound ops row opcode) :
  row.aluOp = ops.forOpcode opcode := by
  rcases h with
    ⟨_, _, _, _, _, _, _, _, _, _, _, hAluOp⟩
  exact hAluOp

theorem x0WriteFacts_of_multiplyOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : MultiplyOpcode}
  (h : MultiplyOpcodeWriteContract x0 row opcode)
  (hRd : row.rd = x0) :
  row.preservesRd = true ∧
    row.writesAluToRd = false ∧
    row.writesMemToRd = false :=
  h.1 hRd

theorem activeWrite_of_multiplyOpcodeWriteContract
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {x0 : RegIdx}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : MultiplyOpcode}
  (h : MultiplyOpcodeWriteContract x0 row opcode)
  (hRd : row.rd ≠ x0) :
  row.preservesRd = false ∧
    row.writesAluToRd = true ∧
    row.writesMemToRd = false :=
  h.2 hRd

def RegisterWriteActivationBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (lane : RegisterLaneClaims Limb) : Prop :=
  (row.writesAluToRd = true ∨ row.writesMemToRd = true) →
    lane.writesRd = true

def WritebackRoutingBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  [OfNat Limb 0]
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerLane : RegisterLaneClaims Limb)
  (ramLane : RamLaneClaims Limb)
  (aluWritebackValue : LimbPair Limb) : Prop :=
  (row.writesAluToRd = true → registerLane.rdNext = aluWritebackValue) ∧
    (row.writesMemToRd = true → registerLane.rdNext = ramLane.memVal) ∧
  (row.preservesRd = true → registerLane.rdNext = zeroLimbPair)

def RamRoleFlagsBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (ramLane : RamLaneClaims Limb) : Prop :=
  ramLane.isLoad = row.isLoad ∧
    ramLane.isStore = row.isStore

structure NativeAluEncodedOps (Limb : Type _) where
  add : LimbPair Limb → LimbPair Limb → LimbPair Limb
  sub : LimbPair Limb → LimbPair Limb → LimbPair Limb
  andOp : LimbPair Limb → LimbPair Limb → LimbPair Limb
  orOp : LimbPair Limb → LimbPair Limb → LimbPair Limb
  xorOp : LimbPair Limb → LimbPair Limb → LimbPair Limb
  slt : LimbPair Limb → LimbPair Limb → LimbPair Limb
  sltu : LimbPair Limb → LimbPair Limb → LimbPair Limb
  lui : LimbPair Limb → LimbPair Limb
  auipc : LimbPair Limb → LimbPair Limb → LimbPair Limb
  zero : LimbPair Limb

structure NativeAluWordOps (Word : Type _) where
  add : Word → Word → Word
  sub : Word → Word → Word
  andOp : Word → Word → Word
  orOp : Word → Word → Word
  xorOp : Word → Word → Word
  slt : Word → Word → Word
  sltu : Word → Word → Word
  lui : Word → Word
  auipc : Word → Word → Word
  zero : Word

def NativeAluEncodedResult
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : NativeAluEncodedOps Limb)
  (wordToLimbPair : Word → LimbPair Limb)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (lane : Stage1LaneView Word RegIdx)
  (opcode : NativeAluOpcode) : LimbPair Limb :=
  match opcode with
  | .add => ops.add registerTwist.rvRs1 registerTwist.rvRs2
  | .addi => ops.add registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .sub => ops.sub registerTwist.rvRs1 registerTwist.rvRs2
  | .andOp => ops.andOp registerTwist.rvRs1 registerTwist.rvRs2
  | .andi => ops.andOp registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .orOp => ops.orOp registerTwist.rvRs1 registerTwist.rvRs2
  | .ori => ops.orOp registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .xorOp => ops.xorOp registerTwist.rvRs1 registerTwist.rvRs2
  | .xori => ops.xorOp registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .slt => ops.slt registerTwist.rvRs1 registerTwist.rvRs2
  | .slti => ops.slt registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .sltu => ops.sltu registerTwist.rvRs1 registerTwist.rvRs2
  | .sltiu => ops.sltu registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .lui => ops.lui (wordToLimbPair decodedRow.imm)
  | .auipc => ops.auipc (wordToLimbPair lane.pc) (wordToLimbPair decodedRow.imm)
  | .fence => ops.zero
  | .ecall => ops.zero

def NativeAluWordResult
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : NativeAluWordOps Word)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (lane : Stage1LaneView Word RegIdx)
  (limbPairToWord : LimbPair Limb → Word)
  (opcode : NativeAluOpcode) : Word :=
  match opcode with
  | .add => ops.add (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .addi => ops.add (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .sub => ops.sub (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .andOp => ops.andOp (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .andi => ops.andOp (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .orOp => ops.orOp (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .ori => ops.orOp (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .xorOp => ops.xorOp (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .xori => ops.xorOp (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .slt => ops.slt (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .slti => ops.slt (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .sltu => ops.sltu (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .sltiu => ops.sltu (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .lui => ops.lui decodedRow.imm
  | .auipc => ops.auipc lane.pc decodedRow.imm
  | .fence => ops.zero
  | .ecall => ops.zero

def NativeAluEncodedResultBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : NativeAluEncodedOps Limb)
  (wordToLimbPair : Word → LimbPair Limb)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (lane : Stage1LaneView Word RegIdx)
  (aluWritebackValue : LimbPair Limb)
  (opcode : NativeAluOpcode) : Prop :=
  aluWritebackValue =
    NativeAluEncodedResult
      ops
      wordToLimbPair
      decodedRow
      registerTwist
      lane
      opcode

structure NativeAluWordCompatibilityBound
  {Word Limb : Type _}
  (wordOps : NativeAluWordOps Word)
  (encodedOps : NativeAluEncodedOps Limb)
  (wordToLimbPair : Word → LimbPair Limb) where
  add :
    ∀ a b,
      wordToLimbPair (wordOps.add a b) =
        encodedOps.add (wordToLimbPair a) (wordToLimbPair b)
  sub :
    ∀ a b,
      wordToLimbPair (wordOps.sub a b) =
        encodedOps.sub (wordToLimbPair a) (wordToLimbPair b)
  andOp :
    ∀ a b,
      wordToLimbPair (wordOps.andOp a b) =
        encodedOps.andOp (wordToLimbPair a) (wordToLimbPair b)
  orOp :
    ∀ a b,
      wordToLimbPair (wordOps.orOp a b) =
        encodedOps.orOp (wordToLimbPair a) (wordToLimbPair b)
  xorOp :
    ∀ a b,
      wordToLimbPair (wordOps.xorOp a b) =
        encodedOps.xorOp (wordToLimbPair a) (wordToLimbPair b)
  slt :
    ∀ a b,
      wordToLimbPair (wordOps.slt a b) =
        encodedOps.slt (wordToLimbPair a) (wordToLimbPair b)
  sltu :
    ∀ a b,
      wordToLimbPair (wordOps.sltu a b) =
        encodedOps.sltu (wordToLimbPair a) (wordToLimbPair b)
  lui :
    ∀ a,
      wordToLimbPair (wordOps.lui a) = encodedOps.lui (wordToLimbPair a)
  auipc :
    ∀ pc imm,
      wordToLimbPair (wordOps.auipc pc imm) =
        encodedOps.auipc (wordToLimbPair pc) (wordToLimbPair imm)
  zero :
    wordToLimbPair wordOps.zero = encodedOps.zero

structure WordShiftEncodedOps (Limb : Type _) where
  add : LimbPair Limb → LimbPair Limb → LimbPair Limb
  sub : LimbPair Limb → LimbPair Limb → LimbPair Limb
  sll : LimbPair Limb → LimbPair Limb → LimbPair Limb
  srl : LimbPair Limb → LimbPair Limb → LimbPair Limb
  sra : LimbPair Limb → LimbPair Limb → LimbPair Limb

structure WordShiftWordOps (Word : Type _) where
  add : Word → Word → Word
  sub : Word → Word → Word
  sll : Word → Word → Word
  srl : Word → Word → Word
  sra : Word → Word → Word

def WordShiftEncodedResult
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : WordShiftEncodedOps Limb)
  (wordToLimbPair : Word → LimbPair Limb)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (opcode : WordShiftOpcode) : LimbPair Limb :=
  match opcode with
  | .addw => ops.add registerTwist.rvRs1 registerTwist.rvRs2
  | .addiw => ops.add registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .subw => ops.sub registerTwist.rvRs1 registerTwist.rvRs2
  | .sllw => ops.sll registerTwist.rvRs1 registerTwist.rvRs2
  | .slliw => ops.sll registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .srlw => ops.srl registerTwist.rvRs1 registerTwist.rvRs2
  | .srliw => ops.srl registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)
  | .sraw => ops.sra registerTwist.rvRs1 registerTwist.rvRs2
  | .sraiw => ops.sra registerTwist.rvRs1 (wordToLimbPair decodedRow.imm)

def WordShiftWordResult
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : WordShiftWordOps Word)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (limbPairToWord : LimbPair Limb → Word)
  (opcode : WordShiftOpcode) : Word :=
  match opcode with
  | .addw => ops.add (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .addiw => ops.add (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .subw => ops.sub (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .sllw => ops.sll (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .slliw => ops.sll (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .srlw => ops.srl (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .srliw => ops.srl (limbPairToWord registerTwist.rvRs1) decodedRow.imm
  | .sraw => ops.sra (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .sraiw => ops.sra (limbPairToWord registerTwist.rvRs1) decodedRow.imm

def WordShiftEncodedResultBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : WordShiftEncodedOps Limb)
  (wordToLimbPair : Word → LimbPair Limb)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (aluWritebackValue : LimbPair Limb)
  (opcode : WordShiftOpcode) : Prop :=
  aluWritebackValue =
    WordShiftEncodedResult
      ops
      wordToLimbPair
      decodedRow
      registerTwist
      opcode

structure WordShiftWordCompatibilityBound
  {Word Limb : Type _}
  (wordOps : WordShiftWordOps Word)
  (encodedOps : WordShiftEncodedOps Limb)
  (wordToLimbPair : Word → LimbPair Limb) where
  add :
    ∀ a b,
      wordToLimbPair (wordOps.add a b) =
        encodedOps.add (wordToLimbPair a) (wordToLimbPair b)
  sub :
    ∀ a b,
      wordToLimbPair (wordOps.sub a b) =
        encodedOps.sub (wordToLimbPair a) (wordToLimbPair b)
  sll :
    ∀ a b,
      wordToLimbPair (wordOps.sll a b) =
        encodedOps.sll (wordToLimbPair a) (wordToLimbPair b)
  srl :
    ∀ a b,
      wordToLimbPair (wordOps.srl a b) =
        encodedOps.srl (wordToLimbPair a) (wordToLimbPair b)
  sra :
    ∀ a b,
      wordToLimbPair (wordOps.sra a b) =
        encodedOps.sra (wordToLimbPair a) (wordToLimbPair b)

structure MultiplyEncodedOps (Limb : Type _) where
  mul : LimbPair Limb → LimbPair Limb → LimbPair Limb
  mulh : LimbPair Limb → LimbPair Limb → LimbPair Limb
  mulhu : LimbPair Limb → LimbPair Limb → LimbPair Limb
  mulhsu : LimbPair Limb → LimbPair Limb → LimbPair Limb
  mulw : LimbPair Limb → LimbPair Limb → LimbPair Limb

structure MultiplyWordOps (Word : Type _) where
  mul : Word → Word → Word
  mulh : Word → Word → Word
  mulhu : Word → Word → Word
  mulhsu : Word → Word → Word
  mulw : Word → Word → Word

def MultiplyEncodedResult
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : MultiplyEncodedOps Limb)
  (_decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (opcode : MultiplyOpcode) : LimbPair Limb :=
  match opcode with
  | .mul => ops.mul registerTwist.rvRs1 registerTwist.rvRs2
  | .mulh => ops.mulh registerTwist.rvRs1 registerTwist.rvRs2
  | .mulhu => ops.mulhu registerTwist.rvRs1 registerTwist.rvRs2
  | .mulhsu => ops.mulhsu registerTwist.rvRs1 registerTwist.rvRs2
  | .mulw => ops.mulw registerTwist.rvRs1 registerTwist.rvRs2

def MultiplyWordResult
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : MultiplyWordOps Word)
  (_decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (limbPairToWord : LimbPair Limb → Word)
  (opcode : MultiplyOpcode) : Word :=
  match opcode with
  | .mul => ops.mul (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .mulh => ops.mulh (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .mulhu => ops.mulhu (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .mulhsu => ops.mulhsu (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)
  | .mulw => ops.mulw (limbPairToWord registerTwist.rvRs1) (limbPairToWord registerTwist.rvRs2)

def MultiplyEncodedResultBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (ops : MultiplyEncodedOps Limb)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (aluWritebackValue : LimbPair Limb)
  (opcode : MultiplyOpcode) : Prop :=
  aluWritebackValue =
    MultiplyEncodedResult
      ops
      decodedRow
      registerTwist
      opcode

structure MultiplyWordCompatibilityBound
  {Word Limb : Type _}
  (wordOps : MultiplyWordOps Word)
  (encodedOps : MultiplyEncodedOps Limb)
  (wordToLimbPair : Word → LimbPair Limb) where
  mul :
    ∀ a b,
      wordToLimbPair (wordOps.mul a b) =
        encodedOps.mul (wordToLimbPair a) (wordToLimbPair b)
  mulh :
    ∀ a b,
      wordToLimbPair (wordOps.mulh a b) =
        encodedOps.mulh (wordToLimbPair a) (wordToLimbPair b)
  mulhu :
    ∀ a b,
      wordToLimbPair (wordOps.mulhu a b) =
        encodedOps.mulhu (wordToLimbPair a) (wordToLimbPair b)
  mulhsu :
    ∀ a b,
      wordToLimbPair (wordOps.mulhsu a b) =
        encodedOps.mulhsu (wordToLimbPair a) (wordToLimbPair b)
  mulw :
    ∀ a b,
      wordToLimbPair (wordOps.mulw a b) =
        encodedOps.mulw (wordToLimbPair a) (wordToLimbPair b)

def AluWritebackRepresentationBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (wordToLimbPair : Word → LimbPair Limb)
  (executionRow : ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (aluWritebackValue : LimbPair Limb) : Prop :=
  wordToLimbPair executionRow.lane.aluOut = aluWritebackValue

def NarrowMemoryExtractResultBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (wordToNat : Word → Nat)
  (limbPairToWord : LimbPair Limb → Word)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (executionRow : ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (ramTwist : RamTwistClaims Limb)
  (extract : NarrowMemoryExtractProofPackage) : Prop :=
  decodedRow.isLoad = true →
    extract.addr = wordToNat executionRow.lane.memAddr ∧
      extract.word = wordToNat (limbPairToWord ramTwist.rvRamWord) ∧
      extract.out = wordToNat executionRow.results.aluResult ∧
      extract.unsigned = decodedRow.memUnsigned

def NarrowMemoryBlendResultBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind Limb : Type _}
  (wordToNat : Word → Nat)
  (limbPairToWord : LimbPair Limb → Word)
  (decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (executionRow : ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (registerTwist : RegisterTwistClaims Limb)
  (ramTwist : RamTwistClaims Limb)
  (blendProof : NarrowMemoryBlendProofPackage) : Prop :=
  decodedRow.isStore = true →
    blendProof.addr = wordToNat executionRow.lane.memAddr ∧
      blendProof.word = wordToNat (limbPairToWord ramTwist.rvRamWord) ∧
      blendProof.src = wordToNat (limbPairToWord registerTwist.rvRs2) ∧
      blendProof.out = wordToNat executionRow.results.aluResult

structure OpcodeClassProof
  (Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _) where
  opcodeClass : OpcodeClass
  semantics : ExecutionSemanticsProofPackage Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  classMatches :
    ∀ row, row ∈ semantics.rows → row.opcodeClass = opcodeClass

def OpcodeProofsOrdered
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)) : Prop :=
  proofs.map OpcodeClassProof.opcodeClass = opcodeClassOrder

structure StepCompositionProofPackage
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _) [OfNat Limb 0] where
  bytecodeTable :
    BytecodeAddr →
      Option (DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  expandedPc : BytecodeAddr
  x0 : RegIdx
  isArchitectural : RegIdx → Prop
  decodedRow : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
  fetchDecodeBound :
    FetchDecodeBound bytecodeTable expandedPc x0 isArchitectural decodedRow
  executionRow :
    ExecutionRowProofPackage Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
  decodedRowEqExecutionRow :
    executionRow.row = decodedRow
  registerHistory : RegisterHistoryBundle RegisterTimeline RegIdx (LimbPair Limb)
  ramHistory : RamHistoryBundle RamTimeline (LimbPair Limb)
  twistBinding : TwistConcreteBindingProofPackage Limb
  ramRoleFlags :
    RamRoleFlagsBound decodedRow twistBinding.ramLane
  registerWriteActivation :
    RegisterWriteActivationBound decodedRow twistBinding.registerLane
  aluWritebackValue : LimbPair Limb
  wordToLimbPair : Word → LimbPair Limb
  limbPairToWord : LimbPair Limb → Word
  wordEncodingRoundTripWord :
    ∀ w, limbPairToWord (wordToLimbPair w) = w
  wordEncodingRoundTripPair :
    ∀ p, wordToLimbPair (limbPairToWord p) = p
  aluWritebackRepresentation :
    AluWritebackRepresentationBound
      wordToLimbPair
      executionRow
      aluWritebackValue
  writebackRouting :
    WritebackRoutingBound
      decodedRow
      twistBinding.registerLane
      twistBinding.ramLane
      aluWritebackValue
  continuity :
    Stage3ProofPackage
      Pc
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      PreparedStep
  rowAssertions :
    CommittedSequence (ExpandedRow Pc BytecodeAddr RegIdx StateLocation) →
      ArchitecturalInputs →
      AuthenticatedReads →
      WitnessAssignment →
      Prop
  committedResult :
    CommittedSequence (ExpandedRow Pc BytecodeAddr RegIdx StateLocation) →
      ArchitecturalInputs →
      AuthenticatedReads →
      WitnessAssignment →
      SequenceResult Output StateEffect
  isaResult :
    ArchitecturalInputs →
      AuthenticatedReads →
      SequenceResult Output StateEffect
  preservedState :
    PreservedStatePredicate
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      ArchitecturalInputs
      AuthenticatedReads
      Output
      StateEffect
      StateLocation
  committedSequence :
    CommittedSequence (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
  touchedState : TouchedStateSet StateLocation
  committedSequenceCorrect :
    CommittedSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      committedSequence
      touchedState
      rowAssertions
      committedResult
      isaResult
      preservedState
  nativeAluSequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      rowAssertions
      committedResult
      isaResult
      preservedState
  nativeAluOps : NativeAluAluOps AluOp
  nativeAluOpcode : NativeAluOpcode
  nativeAluOpcodeBound :
    NativeAluOpcodeBound nativeAluOps decodedRow nativeAluOpcode
  nativeAluWriteContract :
    NativeAluOpcodeWriteContract x0 decodedRow nativeAluOpcode
  nativeAluEncodedOps : NativeAluEncodedOps Limb
  nativeAluWordOps : NativeAluWordOps Word
  nativeAluWordCompatibility :
    NativeAluWordCompatibilityBound
      nativeAluWordOps
      nativeAluEncodedOps
      wordToLimbPair
  nativeAluEncodedResultBound :
    NativeAluEncodedResultBound
      nativeAluEncodedOps
      wordToLimbPair
      decodedRow
      twistBinding.registerTwist
      executionRow.lane
      aluWritebackValue
      nativeAluOpcode
  wordShiftSequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      rowAssertions
      committedResult
      isaResult
      preservedState
  controlFlowSequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      rowAssertions
      committedResult
      isaResult
      preservedState
  narrowMemorySequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      rowAssertions
      committedResult
      isaResult
      preservedState
  narrowMemoryExtract : NarrowMemoryExtractProofPackage
  narrowMemoryBlend : NarrowMemoryBlendProofPackage
  narrowMemoryExtractResult :
    NarrowMemoryExtractResultBound
      executionRow.wordToNat
      limbPairToWord
      decodedRow
      executionRow
      twistBinding.ramTwist
      narrowMemoryExtract
  narrowMemoryBlendResult :
    NarrowMemoryBlendResultBound
      executionRow.wordToNat
      limbPairToWord
      decodedRow
      executionRow
      twistBinding.registerTwist
      twistBinding.ramTwist
      narrowMemoryBlend
  alignedMemoryWidth : MemWidth
  alignedMemoryOpcode : AlignedMemoryOpcode
  alignedMemoryOpcodeBound :
    AlignedMemoryOpcodeBound alignedMemoryWidth decodedRow alignedMemoryOpcode
  alignedMemoryWriteContract :
    AlignedMemoryOpcodeWriteContract x0 decodedRow alignedMemoryOpcode
  multiplySequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      rowAssertions
      committedResult
      isaResult
      preservedState
  multiplyAluOps : MultiplyAluOps AluOp
  multiplyOpcode : MultiplyOpcode
  multiplyOpcodeBound :
    MultiplyOpcodeBound multiplyAluOps decodedRow multiplyOpcode
  multiplyWriteContract :
    MultiplyOpcodeWriteContract x0 decodedRow multiplyOpcode
  multiplyEncodedOps : MultiplyEncodedOps Limb
  multiplyWordOps : MultiplyWordOps Word
  multiplyWordCompatibility :
    MultiplyWordCompatibilityBound
      multiplyWordOps
      multiplyEncodedOps
      wordToLimbPair
  multiplyEncodedResultBound :
    MultiplyEncodedResultBound
      multiplyEncodedOps
      decodedRow
      twistBinding.registerTwist
      aluWritebackValue
      multiplyOpcode
  wordShiftAluOps : WordShiftAluOps AluOp
  wordShiftOpcode : WordShiftOpcode
  wordShiftOpcodeBound :
    WordShiftOpcodeBound wordShiftAluOps decodedRow wordShiftOpcode
  wordShiftWriteContract :
    WordShiftOpcodeWriteContract x0 decodedRow wordShiftOpcode
  wordShiftEncodedOps : WordShiftEncodedOps Limb
  wordShiftWordOps : WordShiftWordOps Word
  wordShiftWordCompatibility :
    WordShiftWordCompatibilityBound
      wordShiftWordOps
      wordShiftEncodedOps
      wordToLimbPair
  wordShiftEncodedResultBound :
    WordShiftEncodedResultBound
      wordShiftEncodedOps
      wordToLimbPair
      decodedRow
      twistBinding.registerTwist
      aluWritebackValue
      wordShiftOpcode
  adviceSequence :
    CommittedSequence (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
  adviceTouchedState : TouchedStateSet StateLocation
  adviceSequenceCorrect :
    AdviceSequenceCorrect
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      adviceSequence
      adviceTouchedState
      rowAssertions
      committedResult
      isaResult
      preservedState
  unsignedDivRemSequenceProof :
    AdviceSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      rowAssertions
      committedResult
      isaResult
      preservedState
  signedDivRemSequenceProof :
    AdviceSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      rowAssertions
      committedResult
      isaResult
      preservedState
  temporaryHygiene :
    TemporaryRegisterHygieneProofPackage
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      RegIdx
  execution :
    ExecutionSemanticsProofPackage
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
  opcodeProofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)
  opcodeProofsOrdered : OpcodeProofsOrdered opcodeProofs
  unsignedDivRem :
    UnsignedDivRemSoundnessProofPackage Pc BytecodeAddr RegIdx StateLocation
  unsignedDivRemOpcodeBound :
    UnsignedDivRemOpcodeBound decodedRow unsignedDivRem.opcode
  signedDivRem : SignedDivRemProofPackage
  signedDivRemOpcodeBound :
    SignedDivRemOpcodeBound decodedRow signedDivRem.opcode

theorem committedSequenceDeterministic_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.committedSequence
    pkg.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  committedSequenceDeterministic_of_correct pkg.committedSequenceCorrect

theorem adviceSequenceDeterministic_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  AdviceSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.adviceSequence
    pkg.adviceTouchedState
    pkg.rowAssertions
    pkg.committedResult :=
  adviceSequenceDeterministic_of_correct pkg.adviceSequenceCorrect

theorem unsignedDivRemOpcodeBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  UnsignedDivRemOpcodeBound pkg.decodedRow pkg.unsignedDivRem.opcode :=
  pkg.unsignedDivRemOpcodeBound

theorem nativeAluOpcodeBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  NativeAluOpcodeBound pkg.nativeAluOps pkg.decodedRow pkg.nativeAluOpcode :=
  pkg.nativeAluOpcodeBound

theorem nativeAluWriteContract_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  NativeAluOpcodeWriteContract pkg.x0 pkg.decodedRow pkg.nativeAluOpcode :=
  pkg.nativeAluWriteContract

theorem nativeAluEncodedResultBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  NativeAluEncodedResultBound
    pkg.nativeAluEncodedOps
    pkg.wordToLimbPair
    pkg.decodedRow
    pkg.twistBinding.registerTwist
    pkg.executionRow.lane
    pkg.aluWritebackValue
    pkg.nativeAluOpcode :=
  pkg.nativeAluEncodedResultBound

theorem signedDivRemOpcodeBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  SignedDivRemOpcodeBound pkg.decodedRow pkg.signedDivRem.opcode :=
  pkg.signedDivRemOpcodeBound

def nativeAluSequenceProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  CommittedSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  pkg.nativeAluSequenceProof

def wordShiftSequenceProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  CommittedSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  pkg.wordShiftSequenceProof

theorem wordShiftOpcodeBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  WordShiftOpcodeBound pkg.wordShiftAluOps pkg.decodedRow pkg.wordShiftOpcode :=
  pkg.wordShiftOpcodeBound

theorem wordShiftWriteContract_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  WordShiftOpcodeWriteContract pkg.x0 pkg.decodedRow pkg.wordShiftOpcode :=
  pkg.wordShiftWriteContract

theorem wordShiftEncodedResultBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  WordShiftEncodedResultBound
    pkg.wordShiftEncodedOps
    pkg.wordToLimbPair
    pkg.decodedRow
    pkg.twistBinding.registerTwist
    pkg.aluWritebackValue
    pkg.wordShiftOpcode :=
  pkg.wordShiftEncodedResultBound

def controlFlowSequenceProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  CommittedSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  pkg.controlFlowSequenceProof

def narrowMemorySequenceProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  CommittedSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  pkg.narrowMemorySequenceProof

theorem narrowMemoryExtractResultBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  NarrowMemoryExtractResultBound
    pkg.executionRow.wordToNat
    pkg.limbPairToWord
    pkg.decodedRow
    pkg.executionRow
    pkg.twistBinding.ramTwist
    pkg.narrowMemoryExtract :=
  pkg.narrowMemoryExtractResult

theorem narrowMemoryBlendResultBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  NarrowMemoryBlendResultBound
    pkg.executionRow.wordToNat
    pkg.limbPairToWord
    pkg.decodedRow
    pkg.executionRow
    pkg.twistBinding.registerTwist
      pkg.twistBinding.ramTwist
      pkg.narrowMemoryBlend :=
  pkg.narrowMemoryBlendResult

theorem alignedMemoryOpcodeBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  AlignedMemoryOpcodeBound
    pkg.alignedMemoryWidth
    pkg.decodedRow
    pkg.alignedMemoryOpcode :=
  pkg.alignedMemoryOpcodeBound

theorem alignedMemoryWriteContract_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  AlignedMemoryOpcodeWriteContract
    pkg.x0
    pkg.decodedRow
    pkg.alignedMemoryOpcode :=
  pkg.alignedMemoryWriteContract

def multiplySequenceProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  CommittedSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  pkg.multiplySequenceProof

def multiplyOpcodeBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  MultiplyOpcodeBound pkg.multiplyAluOps pkg.decodedRow pkg.multiplyOpcode :=
  pkg.multiplyOpcodeBound

def multiplyWriteContract_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  MultiplyOpcodeWriteContract pkg.x0 pkg.decodedRow pkg.multiplyOpcode :=
  pkg.multiplyWriteContract

theorem multiplyEncodedResultBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  MultiplyEncodedResultBound
    pkg.multiplyEncodedOps
    pkg.decodedRow
    pkg.twistBinding.registerTwist
    pkg.aluWritebackValue
    pkg.multiplyOpcode :=
  pkg.multiplyEncodedResultBound

def unsignedDivRemSequenceProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  AdviceSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  pkg.unsignedDivRemSequenceProof

def signedDivRemSequenceProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  AdviceSequenceProofPackage
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  pkg.signedDivRemSequenceProof

theorem executionCorrect_of_opcodeClassProof
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation) :
  ExecutionCorrect
    proof.semantics.initialState
    proof.semantics.finalState
    proof.semantics.rows
    proof.semantics.preparedSteps
    proof.semantics.boundary
    proof.semantics.entrypoint
    proof.semantics.successors :=
  proof.semantics.correct

theorem row_opcodeClass_of_opcodeClassProof
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hRow : row ∈ proof.semantics.rows) :
  row.opcodeClass = proof.opcodeClass :=
  proof.classMatches row hRow

theorem stage1LinkageBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  Stage1LinkageBound
    pkg.executionRow.row
    pkg.executionRow.lane
    pkg.executionRow.handoff
    pkg.executionRow.results :=
  stage1LinkageBound_of_executionRow pkg.executionRow

theorem decodedRow_eq_executionRow_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  pkg.executionRow.row = pkg.decodedRow :=
  pkg.decodedRowEqExecutionRow

def twistConcreteBinding_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  TwistConcreteBindingProofPackage Limb :=
  pkg.twistBinding

theorem registerWriteActivation_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  RegisterWriteActivationBound pkg.decodedRow pkg.twistBinding.registerLane :=
  pkg.registerWriteActivation

theorem writebackRoutingBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  WritebackRoutingBound
    pkg.decodedRow
    pkg.twistBinding.registerLane
    pkg.twistBinding.ramLane
    pkg.aluWritebackValue :=
  pkg.writebackRouting

theorem aluWritebackRepresentationBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  AluWritebackRepresentationBound
    pkg.wordToLimbPair
    pkg.executionRow
    pkg.aluWritebackValue :=
  pkg.aluWritebackRepresentation

theorem wordEncodingRoundTripWord_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∀ w, pkg.limbPairToWord (pkg.wordToLimbPair w) = w :=
  pkg.wordEncodingRoundTripWord

theorem wordEncodingRoundTripPair_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∀ p, pkg.wordToLimbPair (pkg.limbPairToWord p) = p :=
  pkg.wordEncodingRoundTripPair

theorem wordToLimbPair_injective_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  Function.Injective pkg.wordToLimbPair := by
  intro a b hEq
  have hA := wordEncodingRoundTripWord_of_stepComposition pkg a
  have hB := wordEncodingRoundTripWord_of_stepComposition pkg b
  rw [← hA, ← hB]
  exact congrArg pkg.limbPairToWord hEq

theorem nativeAluWordCompatibility_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  NativeAluWordCompatibilityBound
    pkg.nativeAluWordOps
    pkg.nativeAluEncodedOps
    pkg.wordToLimbPair :=
  pkg.nativeAluWordCompatibility

theorem multiplyWordCompatibility_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  MultiplyWordCompatibilityBound
    pkg.multiplyWordOps
    pkg.multiplyEncodedOps
    pkg.wordToLimbPair :=
  pkg.multiplyWordCompatibility

theorem wordShiftWordCompatibility_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  WordShiftWordCompatibilityBound
    pkg.wordShiftWordOps
    pkg.wordShiftEncodedOps
    pkg.wordToLimbPair :=
  pkg.wordShiftWordCompatibility

theorem encodedAluOut_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  pkg.wordToLimbPair pkg.executionRow.lane.aluOut = pkg.aluWritebackValue :=
  aluWritebackRepresentationBound_of_stepComposition pkg

theorem encodedAluResult_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue := by
  have hStage1 :
      pkg.executionRow.lane.aluOut = pkg.executionRow.results.aluResult :=
    laneAluOut_eq_resultsAluResult_of_executionRow pkg.executionRow
  calc
    pkg.wordToLimbPair pkg.executionRow.results.aluResult
      = pkg.wordToLimbPair pkg.executionRow.lane.aluOut := by
          simpa using congrArg pkg.wordToLimbPair hStage1.symm
    _ = pkg.aluWritebackValue :=
      encodedAluOut_of_stepComposition pkg

theorem registerWritesRd_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hWrite : pkg.decodedRow.writesAluToRd = true ∨ pkg.decodedRow.writesMemToRd = true) :
  pkg.twistBinding.registerLane.writesRd = true :=
  pkg.registerWriteActivation hWrite

theorem registerRdNext_of_activeAluWrite
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hWrite : pkg.decodedRow.writesAluToRd = true) :
  pkg.twistBinding.registerLane.rdNext = pkg.aluWritebackValue :=
  (writebackRoutingBound_of_stepComposition pkg).1 hWrite

theorem registerRdNext_of_activeMemWrite
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hWrite : pkg.decodedRow.writesMemToRd = true) :
  pkg.twistBinding.registerLane.rdNext = pkg.twistBinding.ramLane.memVal :=
  (writebackRoutingBound_of_stepComposition pkg).2.1 hWrite

theorem registerRdNext_zero_of_preservesRd
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hPreserves : pkg.decodedRow.preservesRd = true) :
  pkg.twistBinding.registerLane.rdNext = zeroLimbPair :=
  (writebackRoutingBound_of_stepComposition pkg).2.2 hPreserves

theorem stage2LinkageBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  Stage2LinkageBound
    pkg.twistBinding.registerLane
    pkg.twistBinding.registerTwist
    pkg.twistBinding.ramLane
    pkg.twistBinding.ramTwist :=
  pkg.twistBinding.linkageBound

theorem registerLinkageBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  RegisterLinkageBound
    pkg.twistBinding.registerLane
    pkg.twistBinding.registerTwist :=
  (stage2LinkageBound_of_stepComposition pkg).1

theorem ramLinkageBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  RamLinkageBound
    pkg.twistBinding.ramLane
    pkg.twistBinding.ramTwist :=
  (stage2LinkageBound_of_stepComposition pkg).2

theorem ramRoleFlags_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  RamRoleFlagsBound
    pkg.decodedRow
    pkg.twistBinding.ramLane :=
  pkg.ramRoleFlags

theorem ramLaneIsLoad_eq_decodedRow_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  pkg.twistBinding.ramLane.isLoad = pkg.decodedRow.isLoad :=
  (ramRoleFlags_of_stepComposition pkg).1

theorem ramLaneIsStore_eq_decodedRow_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  pkg.twistBinding.ramLane.isStore = pkg.decodedRow.isStore :=
  (ramRoleFlags_of_stepComposition pkg).2

theorem registerWriteValue_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hWrite : pkg.twistBinding.registerLane.writesRd = true) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext :=
  registerLinkageBound_writeValue_of_activeWrite
    (registerLinkageBound_of_stepComposition pkg)
    hWrite

theorem authenticatedAluWriteValue_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hWrite : pkg.decodedRow.writesAluToRd = true) :
  pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
  have hWritesRd :
      pkg.twistBinding.registerLane.writesRd = true :=
    registerWritesRd_of_stepComposition pkg (Or.inl hWrite)
  calc
    pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext :=
      registerWriteValue_of_stepComposition pkg hWritesRd
    _ = pkg.aluWritebackValue :=
      registerRdNext_of_activeAluWrite pkg hWrite

theorem authenticatedMemWriteValue_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hWrite : pkg.decodedRow.writesMemToRd = true) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.ramLane.memVal := by
  have hWritesRd :
      pkg.twistBinding.registerLane.writesRd = true :=
    registerWritesRd_of_stepComposition pkg (Or.inr hWrite)
  calc
    pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext :=
      registerWriteValue_of_stepComposition pkg hWritesRd
    _ = pkg.twistBinding.ramLane.memVal :=
      registerRdNext_of_activeMemWrite pkg hWrite

theorem registerReadValues_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  pkg.twistBinding.registerTwist.rvRs1 = pkg.twistBinding.registerLane.rs1 ∧
    pkg.twistBinding.registerTwist.rvRs2 = pkg.twistBinding.registerLane.rs2 := by
  exact ⟨(registerLinkageBound_of_stepComposition pkg).1,
    (registerLinkageBound_of_stepComposition pkg).2.1⟩

theorem ramLoadMemVal_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hLoad : pkg.twistBinding.ramLane.isLoad = true) :
  pkg.twistBinding.ramLane.memVal = pkg.twistBinding.ramTwist.rvRamWord :=
  ramLinkageBound_memVal_of_load
    (ramLinkageBound_of_stepComposition pkg)
    hLoad

theorem ramStorePayload_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hStore : pkg.twistBinding.ramLane.isStore = true) :
  pkg.twistBinding.ramLane.memVal = pkg.twistBinding.ramLane.rs2 ∧
    pkg.twistBinding.ramTwist.wvRamWord = pkg.twistBinding.ramLane.memVal :=
  ramLinkageBound_storePayload
    (ramLinkageBound_of_stepComposition pkg)
    hStore

theorem ramInactiveMemValZero_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (hLoad : pkg.twistBinding.ramLane.isLoad = false)
  (hStore : pkg.twistBinding.ramLane.isStore = false) :
  pkg.twistBinding.ramLane.memVal = zeroLimbPair :=
  ramLinkageBound_memVal_zero_of_inactive
    (ramLinkageBound_of_stepComposition pkg)
    hLoad
    hStore

theorem takenTargetAlignmentBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  TakenTargetAlignmentBound
    pkg.executionRow.wordToNat
    pkg.executionRow.lane :=
  takenTargetAlignmentBound_of_executionRow pkg.executionRow

theorem mulUNoOverflowBound_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  MulUNoOverflowBound
    pkg.executionRow.mulHigh
    pkg.executionRow.zeroWord
    pkg.executionRow.divRemQuotient
    pkg.executionRow.divRemDivisor :=
  mulUNoOverflowBound_of_executionRow pkg.executionRow

theorem opcodeProofs_cover_exact_order
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h : OpcodeProofsOrdered proofs) :
  proofs.map OpcodeClassProof.opcodeClass = opcodeClassOrder :=
  h

private theorem opcodeProofs_canonicalShape
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (h : OpcodeProofsOrdered proofs) :
  ∃ nativeAluProof wordShiftProof controlFlowProof narrowMemoryProof
      multiplyProof unsignedDivRemProof signedDivRemProof,
    proofs =
      [ nativeAluProof
      , wordShiftProof
      , controlFlowProof
      , narrowMemoryProof
      , multiplyProof
      , unsignedDivRemProof
      , signedDivRemProof
      ] ∧
    nativeAluProof.opcodeClass = .nativeAlu ∧
    wordShiftProof.opcodeClass = .wordShift ∧
    controlFlowProof.opcodeClass = .controlFlow ∧
    narrowMemoryProof.opcodeClass = .narrowMemory ∧
    multiplyProof.opcodeClass = .multiply ∧
    unsignedDivRemProof.opcodeClass = .unsignedDivRem ∧
    signedDivRemProof.opcodeClass = .signedDivRem := by
  cases proofs with
  | nil =>
      simp [OpcodeProofsOrdered, opcodeClassOrder] at h
  | cons nativeAluProof rest0 =>
      cases rest0 with
      | nil =>
          simp [OpcodeProofsOrdered, opcodeClassOrder] at h
      | cons wordShiftProof rest1 =>
          cases rest1 with
          | nil =>
              simp [OpcodeProofsOrdered, opcodeClassOrder] at h
          | cons controlFlowProof rest2 =>
              cases rest2 with
              | nil =>
                  simp [OpcodeProofsOrdered, opcodeClassOrder] at h
              | cons narrowMemoryProof rest3 =>
                  cases rest3 with
                  | nil =>
                      simp [OpcodeProofsOrdered, opcodeClassOrder] at h
                  | cons multiplyProof rest4 =>
                      cases rest4 with
                      | nil =>
                          simp [OpcodeProofsOrdered, opcodeClassOrder] at h
                      | cons unsignedDivRemProof rest5 =>
                          cases rest5 with
                          | nil =>
                              simp [OpcodeProofsOrdered, opcodeClassOrder] at h
                          | cons signedDivRemProof rest6 =>
                              cases rest6 with
                              | nil =>
                                  simp [OpcodeProofsOrdered, opcodeClassOrder] at h
                                  rcases h with
                                    ⟨hNativeAlu, hWordShift, hControlFlow, hNarrowMemory,
                                      hMultiply, hUnsignedDivRem, hSignedDivRem⟩
                                  refine
                                    ⟨nativeAluProof, wordShiftProof, controlFlowProof,
                                      narrowMemoryProof, multiplyProof,
                                      unsignedDivRemProof, signedDivRemProof, rfl,
                                      ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
                                    assumption
                              | cons extra rest =>
                                  simp [OpcodeProofsOrdered, opcodeClassOrder] at h

theorem opcodeProofs_canonicalShape_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ nativeAluProof wordShiftProof controlFlowProof narrowMemoryProof
      multiplyProof unsignedDivRemProof signedDivRemProof,
    pkg.opcodeProofs =
      [ nativeAluProof
      , wordShiftProof
      , controlFlowProof
      , narrowMemoryProof
      , multiplyProof
      , unsignedDivRemProof
      , signedDivRemProof
      ] ∧
    nativeAluProof.opcodeClass = .nativeAlu ∧
    wordShiftProof.opcodeClass = .wordShift ∧
    controlFlowProof.opcodeClass = .controlFlow ∧
    narrowMemoryProof.opcodeClass = .narrowMemory ∧
    multiplyProof.opcodeClass = .multiply ∧
    unsignedDivRemProof.opcodeClass = .unsignedDivRem ∧
    signedDivRemProof.opcodeClass = .signedDivRem :=
  opcodeProofs_canonicalShape pkg.opcodeProofsOrdered

theorem nativeAluOpcodeClassProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ proof,
    proof ∈ pkg.opcodeProofs ∧
      proof.opcodeClass = .nativeAlu ∧
      ExecutionCorrect
        proof.semantics.initialState
        proof.semantics.finalState
        proof.semantics.rows
        proof.semantics.preparedSteps
        proof.semantics.boundary
        proof.semantics.entrypoint
        proof.semantics.successors := by
  rcases opcodeProofs_canonicalShape pkg.opcodeProofsOrdered with
    ⟨proof, _, _, _, _, _, _, hProofs, hClass, _, _, _, _, _, _⟩
  refine ⟨proof, ?_, hClass, proof.semantics.correct⟩
  simp [hProofs]

theorem wordShiftOpcodeClassProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ proof,
    proof ∈ pkg.opcodeProofs ∧
      proof.opcodeClass = .wordShift ∧
      ExecutionCorrect
        proof.semantics.initialState
        proof.semantics.finalState
        proof.semantics.rows
        proof.semantics.preparedSteps
        proof.semantics.boundary
        proof.semantics.entrypoint
        proof.semantics.successors := by
  rcases opcodeProofs_canonicalShape pkg.opcodeProofsOrdered with
    ⟨_, proof, _, _, _, _, _, hProofs, _, hClass, _, _, _, _, _⟩
  refine ⟨proof, ?_, hClass, proof.semantics.correct⟩
  simp [hProofs]

theorem controlFlowOpcodeClassProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ proof,
    proof ∈ pkg.opcodeProofs ∧
      proof.opcodeClass = .controlFlow ∧
      ExecutionCorrect
        proof.semantics.initialState
        proof.semantics.finalState
        proof.semantics.rows
        proof.semantics.preparedSteps
        proof.semantics.boundary
        proof.semantics.entrypoint
        proof.semantics.successors := by
  rcases opcodeProofs_canonicalShape pkg.opcodeProofsOrdered with
    ⟨_, _, proof, _, _, _, _, hProofs, _, _, hClass, _, _, _, _⟩
  refine ⟨proof, ?_, hClass, proof.semantics.correct⟩
  simp [hProofs]

theorem narrowMemoryOpcodeClassProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ proof,
    proof ∈ pkg.opcodeProofs ∧
      proof.opcodeClass = .narrowMemory ∧
      ExecutionCorrect
        proof.semantics.initialState
        proof.semantics.finalState
        proof.semantics.rows
        proof.semantics.preparedSteps
        proof.semantics.boundary
        proof.semantics.entrypoint
        proof.semantics.successors := by
  rcases opcodeProofs_canonicalShape pkg.opcodeProofsOrdered with
    ⟨_, _, _, proof, _, _, _, hProofs, _, _, _, hClass, _, _, _⟩
  refine ⟨proof, ?_, hClass, proof.semantics.correct⟩
  simp [hProofs]

theorem multiplyOpcodeClassProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ proof,
    proof ∈ pkg.opcodeProofs ∧
      proof.opcodeClass = .multiply ∧
      ExecutionCorrect
        proof.semantics.initialState
        proof.semantics.finalState
        proof.semantics.rows
        proof.semantics.preparedSteps
        proof.semantics.boundary
        proof.semantics.entrypoint
        proof.semantics.successors := by
  rcases opcodeProofs_canonicalShape pkg.opcodeProofsOrdered with
    ⟨_, _, _, _, proof, _, _, hProofs, _, _, _, _, hClass, _, _⟩
  refine ⟨proof, ?_, hClass, proof.semantics.correct⟩
  simp [hProofs]

theorem unsignedDivRemOpcodeClassProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ proof,
    proof ∈ pkg.opcodeProofs ∧
      proof.opcodeClass = .unsignedDivRem ∧
      ExecutionCorrect
        proof.semantics.initialState
        proof.semantics.finalState
        proof.semantics.rows
        proof.semantics.preparedSteps
        proof.semantics.boundary
        proof.semantics.entrypoint
        proof.semantics.successors := by
  rcases opcodeProofs_canonicalShape pkg.opcodeProofsOrdered with
    ⟨_, _, _, _, _, proof, _, hProofs, _, _, _, _, _, hClass, _⟩
  refine ⟨proof, ?_, hClass, proof.semantics.correct⟩
  simp [hProofs]

theorem signedDivRemOpcodeClassProof_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ∃ proof,
    proof ∈ pkg.opcodeProofs ∧
      proof.opcodeClass = .signedDivRem ∧
      ExecutionCorrect
        proof.semantics.initialState
        proof.semantics.finalState
        proof.semantics.rows
        proof.semantics.preparedSteps
        proof.semantics.boundary
        proof.semantics.entrypoint
        proof.semantics.successors := by
  rcases opcodeProofs_canonicalShape pkg.opcodeProofsOrdered with
    ⟨_, _, _, _, _, _, proof, hProofs, _, _, _, _, _, _, hClass⟩
  refine ⟨proof, ?_, hClass, proof.semantics.correct⟩
  simp [hProofs]

theorem temporaryRegisterHygiene_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  TemporaryRegisterHygiene
    pkg.temporaryHygiene.sequence
    pkg.temporaryHygiene.isTempRegister
    pkg.temporaryHygiene.readsRegister
    pkg.temporaryHygiene.writesRegister :=
  pkg.temporaryHygiene.hygiene

theorem unsignedDivRemSpec_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  UnsignedDivRemSpec
    pkg.unsignedDivRem.dividend
    pkg.unsignedDivRem.quotient
    pkg.unsignedDivRem.divisor
    pkg.unsignedDivRem.remainder :=
  pkg.unsignedDivRem.specHolds

theorem mulUNoOverflow_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  MulUNoOverflow pkg.unsignedDivRem.quotient pkg.unsignedDivRem.divisor :=
  mulUNoOverflow_of_unsignedDivRemSoundness pkg.unsignedDivRem

theorem unsignedDivRemDeterministic_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  {quotient' remainder' : Nat}
  (hSpec :
    UnsignedDivRemSpec
      pkg.unsignedDivRem.dividend
      quotient'
      pkg.unsignedDivRem.divisor
      remainder') :
  quotient' = pkg.unsignedDivRem.quotient ∧
    remainder' = pkg.unsignedDivRem.remainder :=
  unsignedDivRemDeterministic_of_soundness pkg.unsignedDivRem hSpec

theorem signedDivRemSpec_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  SignedDivRemSpec
    pkg.signedDivRem.dividend
    pkg.signedDivRem.quotient
    pkg.signedDivRem.divisor
    pkg.signedDivRem.remainderSigned :=
  pkg.signedDivRem.specHolds

theorem changeDivisorCorrect_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  ChangeDivisorCorrect
    pkg.signedDivRem.dividend
    pkg.signedDivRem.divisor
    pkg.signedDivRem.changedDivisor :=
  changeDivisorCorrect_of_signedDivRemSoundness pkg.signedDivRem

theorem remainderFromDividendSign_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
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
      PreparedStep) :
  RemainderFromDividendSign
    pkg.signedDivRem.dividend
    pkg.signedDivRem.remainderAbs
    pkg.signedDivRem.remainderSigned :=
  remainderFromDividendSign_of_signedDivRemSoundness pkg.signedDivRem

end Nightstream.Rv64IM
