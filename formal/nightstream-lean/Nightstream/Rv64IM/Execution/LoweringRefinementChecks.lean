import Nightstream.Rv64IM.Execution.LoweringRefinement
import Nightstream.Rv64IM.Generated.ImportedParityCorpus

/-!
Owns executable imported-row refinement checks built on top of
`Execution.LoweringRefinement`. This keeps row slicing and case-local booleans
out of the already-large top-level parity checker.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

private def insertNatIfNew (acc : List Nat) (value : Nat) : List Nat :=
  if value ∈ acc then acc else acc ++ [value]

private def stepIndicesForOpcode (rows : List ExpandedRowView) (opcode : Opcode) : List Nat :=
  rows.foldl
    (fun acc row =>
      if row.opcode = opcode then
        insertNatIfNew acc row.stepIndex
      else
        acc)
    []

def rowsForOpcodeStep
    (rows : List ExpandedRowView)
    (opcode : Opcode)
    (stepIndex : Nat) : List ExpandedRowView :=
  rows.filter fun row => decide (row.opcode = opcode ∧ row.stepIndex = stepIndex)

private def allRowsForOpcodeRefine
    (rows : List ExpandedRowView)
    (opcode : Opcode)
    (refines : List ExpandedRowView → Bool) : Bool :=
  (stepIndicesForOpcode rows opcode).all fun stepIndex =>
    refines (rowsForOpcodeStep rows opcode stepIndex)

private def allOpcodesWithSingleRowSpecRefine
    (rows : List ExpandedRowView)
    (opcodes : List Opcode)
    (spec : SingleRowReferenceSpec) : Bool :=
  opcodes.all fun opcode =>
    allRowsForOpcodeRefine rows opcode (fun slice =>
      decide (SingleRowConcreteLoweringRefinesReference opcode spec slice))

private def nativeAluWriteRdSingleRowOpcodes : List Opcode :=
  [ .addi, .add, .sub, .addiw, .addw, .subw
  , .andi, .and, .ori, .or, .xori, .xor
  , .slti, .slt, .sltiu, .sltu
  , .slli, .sll, .srli, .srl, .srai, .sra
  , .slliw, .sllw, .srliw, .srlw, .sraiw, .sraw
  , .lui, .auipc
  ]

private def alignedMemoryLoadSingleRowOpcodes : List Opcode :=
  [.ld]

private def alignedMemoryStoreSingleRowOpcodes : List Opcode :=
  [.sd]

private def narrowMemoryLoadSingleRowOpcodes : List Opcode :=
  [.lb, .lbu, .lh, .lhu, .lw, .lwu]

private def narrowMemoryStoreSingleRowOpcodes : List Opcode :=
  [.sb, .sh, .sw]

private def controlFlowWriteRdSingleRowOpcodes : List Opcode :=
  [.jal, .jalr]

private def controlFlowNoWriteSingleRowOpcodes : List Opcode :=
  [.beq, .bne, .blt, .bge, .bltu, .bgeu, .ecall]

def singleRowLoweringRefinementCheck (rows : List ExpandedRowView) : Bool :=
  allOpcodesWithSingleRowSpecRefine rows nativeAluWriteRdSingleRowOpcodes nativeAluWriteRdSingleRowSpec &&
    allOpcodesWithSingleRowSpecRefine rows [.fence] nativeAluNoWriteSingleRowSpec &&
    allOpcodesWithSingleRowSpecRefine rows alignedMemoryLoadSingleRowOpcodes alignedMemoryLoadSingleRowSpec &&
    allOpcodesWithSingleRowSpecRefine rows alignedMemoryStoreSingleRowOpcodes alignedMemoryStoreSingleRowSpec &&
    allOpcodesWithSingleRowSpecRefine rows narrowMemoryLoadSingleRowOpcodes narrowMemoryLoadSingleRowSpec &&
    allOpcodesWithSingleRowSpecRefine rows narrowMemoryStoreSingleRowOpcodes narrowMemoryStoreSingleRowSpec &&
    allOpcodesWithSingleRowSpecRefine rows controlFlowWriteRdSingleRowOpcodes controlFlowWriteRdSingleRowSpec &&
    allOpcodesWithSingleRowSpecRefine rows controlFlowNoWriteSingleRowOpcodes controlFlowNoWriteSingleRowSpec

def multiplyLoweringRefinementCheck (rows : List ExpandedRowView) : Bool :=
  allRowsForOpcodeRefine rows .mul (fun slice => decide (MulConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .mulhu (fun slice => decide (MulhuConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .mulw (fun slice => decide (MulwConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .mulh (fun slice => decide (MulhConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .mulhsu (fun slice => decide (MulhsuConcreteLoweringRefinesReference slice))

def unsignedDivRemLoweringRefinementCheck (rows : List ExpandedRowView) : Bool :=
  allRowsForOpcodeRefine rows .divu (fun slice => decide (DivuConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .remu (fun slice => decide (RemuConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .divuw (fun slice => decide (DivuwConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .remuw (fun slice => decide (RemuwConcreteLoweringRefinesReference slice))

def signedDivRemLoweringRefinementCheck (rows : List ExpandedRowView) : Bool :=
  allRowsForOpcodeRefine rows .div (fun slice => decide (DivConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .rem (fun slice => decide (RemConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .divw (fun slice => decide (DivwConcreteLoweringRefinesReference slice)) &&
    allRowsForOpcodeRefine rows .remw (fun slice => decide (RemwConcreteLoweringRefinesReference slice))

theorem multiplyLowCase_refinesReference :
  multiplyLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_multiply_low_mul_mulw_ecall.derivedCase.executionRows = true := by
  native_decide

theorem multiplyHighCase_refinesReference :
  multiplyLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_multiply_high_mulh_mulhu_mulhsu_ecall.derivedCase.executionRows = true := by
  native_decide

theorem unsignedDivRemCase_refinesReference :
  unsignedDivRemLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_unsigned_divrem_chain_ecall.derivedCase.executionRows = true := by
  native_decide

theorem signedDivRemCase_refinesReference :
  signedDivRemLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_signed_divrem_chain_ecall.derivedCase.executionRows = true := by
  native_decide

theorem nativeSingleRowCase_refinesReference :
  singleRowLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_native_sub_lui_auipc_fence_ecall.derivedCase.executionRows = true := by
  native_decide

theorem alignedMemorySingleRowCase_refinesReference :
  singleRowLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_aligned_negative_offset_roundtrip.derivedCase.executionRows = true := by
  native_decide

theorem narrowMemorySingleRowCase_refinesReference :
  singleRowLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_narrow_memory_load_extract_extend_ecall.derivedCase.executionRows = true := by
  native_decide

theorem controlFlowSingleRowCase_refinesReference :
  singleRowLoweringRefinementCheck
    Nightstream.Rv64IM.Generated.Cases.Case_control_flow_jalr_skip_ecall.derivedCase.executionRows = true := by
  native_decide

end Nightstream.Rv64IM
