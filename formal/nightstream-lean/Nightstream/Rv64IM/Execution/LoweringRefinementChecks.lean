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

end Nightstream.Rv64IM
