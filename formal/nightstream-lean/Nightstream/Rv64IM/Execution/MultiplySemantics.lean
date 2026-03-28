import Nightstream.Rv64IM.Execution.ExactOpcodeClassSemantics

/-!
Owns exact execution-level multiply-family semantic facts above the canonical
RV64IM opcode-class package. This file does not re-own stage-local proofs,
trace closure, or kernel-level bridge/transcript facts.
-/

namespace Nightstream.Rv64IM

structure MultiplyExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation) where
  classFacts :
    OpcodeClassExecutionFacts
      .multiply
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof

def multiplyExecutionFacts_of_opcodeClassFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (classFacts :
    OpcodeClassExecutionFacts
      .multiply
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof) :
  MultiplyExecutionFacts proof :=
  { classFacts := classFacts }

theorem frame_row_eq_at_index_of_multiplyExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : MultiplyExecutionFacts proof)
  {idx : Nat}
  {frame : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hFrame : proof.semantics.frames[idx]? = some frame)
  (hRow : proof.semantics.rows[idx]? = some row) :
  frame.row = row :=
  frame_row_eq_at_index_of_opcodeClassExecutionFacts facts.classFacts hFrame hRow

theorem adjacentStates_of_multiplyExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : MultiplyExecutionFacts proof)
  {idx : Nat}
  {prev next : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (hPrev : proof.semantics.frames[idx]? = some prev)
  (hNext : proof.semantics.frames[idx + 1]? = some next) :
  prev.postState = next.preState :=
  adjacentStates_of_opcodeClassExecutionFacts facts.classFacts hPrev hNext

theorem preparedStep_matches_row_of_multiplyExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : MultiplyExecutionFacts proof)
  {idx : Nat}
  {step : PreparedStepView Pc}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hStep : proof.semantics.preparedSteps[idx]? = some step)
  (hRow : proof.semantics.rows[idx]? = some row) :
  PreparedStepView.rowIndex step = idx ∧
    PreparedStepView.pc step = (ExpandedRow.bytecode row).unexpandedPc ∧
      PreparedStepView.advanceArchPc step = ExpandedRow.advanceArchPc row ∧
        PreparedStepView.terminates step = ExpandedRow.terminates row :=
  preparedStep_matches_row_of_opcodeClassExecutionFacts facts.classFacts hStep hRow

theorem successor_matches_rows_of_multiplyExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : MultiplyExecutionFacts proof)
  {idx : Nat}
  {successor : ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr}
  {row nextRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hSucc : proof.semantics.successors[idx]? = some successor)
  (hRow : proof.semantics.rows[idx]? = some row)
  (hNext : proof.semantics.rows[idx + 1]? = some nextRow) :
  successor.row = ExpandedRow.bytecode row ∧
    successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc :=
  successor_matches_rows_of_opcodeClassExecutionFacts facts.classFacts hSucc hRow hNext

theorem row_has_opcodeClass_at_index_of_multiplyExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : MultiplyExecutionFacts proof)
  {idx : Nat}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hRow : proof.semantics.rows[idx]? = some row) :
  row.opcodeClass = .multiply :=
  row_has_opcodeClass_at_index_of_opcodeClassExecutionFacts facts.classFacts hRow

noncomputable def multiplyExecutionFacts_of_stepComposition
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
  MultiplyExecutionFacts
    (canonicalOpcodeProofs_of_stepComposition pkg).multiply :=
  multiplyExecutionFacts_of_opcodeClassFacts
    (multiplyFacts_of_stepComposition pkg)

end Nightstream.Rv64IM
