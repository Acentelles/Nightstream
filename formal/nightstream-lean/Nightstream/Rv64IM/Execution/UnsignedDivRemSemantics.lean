import Nightstream.Rv64IM.Execution.ExactOpcodeClassSemantics

/-!
Owns exact execution-level unsigned DIV/REM semantic facts above the canonical
RV64IM opcode-class package. This file does not re-own stage-local proofs,
trace closure, or kernel-level bridge/transcript facts.
-/

namespace Nightstream.Rv64IM

structure UnsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation) where
  classFacts :
    OpcodeClassExecutionFacts
      .unsignedDivRem
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof
  soundness : UnsignedDivRemSoundnessProofPackage Pc BytecodeAddr RegIdx StateLocation
  mulHigh : Word → Word → Word
  zeroWord : Word
  quotientWord : Word
  divisorWord : Word
  mulUNoOverflowBound :
    MulUNoOverflowBound mulHigh zeroWord quotientWord divisorWord
  mulUNoOverflow :
    MulUNoOverflow soundness.quotient soundness.divisor
  unsignedDivRemSpec :
    UnsignedDivRemSpec
      soundness.dividend
      soundness.quotient
      soundness.divisor
      soundness.remainder
  deterministic :
    ∀ quotient' remainder',
      UnsignedDivRemSpec
        soundness.dividend
        quotient'
        soundness.divisor
        remainder' →
          quotient' = soundness.quotient ∧
            remainder' = soundness.remainder

def unsignedDivRemExecutionFacts_of_opcodeClassFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (classFacts :
    OpcodeClassExecutionFacts
      .unsignedDivRem
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof)
  (soundness : UnsignedDivRemSoundnessProofPackage Pc BytecodeAddr RegIdx StateLocation)
  (mulHigh : Word → Word → Word)
  (zeroWord quotientWord divisorWord : Word)
  (mulUNoOverflowBound :
    MulUNoOverflowBound mulHigh zeroWord quotientWord divisorWord)
  (mulUNoOverflow :
    MulUNoOverflow soundness.quotient soundness.divisor)
  (unsignedDivRemSpec :
    UnsignedDivRemSpec
      soundness.dividend
      soundness.quotient
      soundness.divisor
      soundness.remainder)
  (deterministic :
    ∀ quotient' remainder',
      UnsignedDivRemSpec
        soundness.dividend
        quotient'
        soundness.divisor
        remainder' →
          quotient' = soundness.quotient ∧
            remainder' = soundness.remainder) :
  UnsignedDivRemExecutionFacts proof :=
  { classFacts := classFacts
    soundness := soundness
    mulHigh := mulHigh
    zeroWord := zeroWord
    quotientWord := quotientWord
    divisorWord := divisorWord
    mulUNoOverflowBound := mulUNoOverflowBound
    mulUNoOverflow := mulUNoOverflow
    unsignedDivRemSpec := unsignedDivRemSpec
    deterministic := deterministic }

theorem frame_row_eq_at_index_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof)
  {idx : Nat}
  {frame : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hFrame : proof.semantics.frames[idx]? = some frame)
  (hRow : proof.semantics.rows[idx]? = some row) :
  frame.row = row :=
  frame_row_eq_at_index_of_opcodeClassExecutionFacts facts.classFacts hFrame hRow

theorem adjacentStates_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof)
  {idx : Nat}
  {prev next : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (hPrev : proof.semantics.frames[idx]? = some prev)
  (hNext : proof.semantics.frames[idx + 1]? = some next) :
  prev.postState = next.preState :=
  adjacentStates_of_opcodeClassExecutionFacts facts.classFacts hPrev hNext

theorem preparedStep_matches_row_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof)
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

theorem successor_matches_rows_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof)
  {idx : Nat}
  {successor : ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr}
  {row nextRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hSucc : proof.semantics.successors[idx]? = some successor)
  (hRow : proof.semantics.rows[idx]? = some row)
  (hNext : proof.semantics.rows[idx + 1]? = some nextRow) :
  successor.row = ExpandedRow.bytecode row ∧
    successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc :=
  successor_matches_rows_of_opcodeClassExecutionFacts facts.classFacts hSucc hRow hNext

theorem row_has_opcodeClass_at_index_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof)
  {idx : Nat}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hRow : proof.semantics.rows[idx]? = some row) :
  row.opcodeClass = .unsignedDivRem :=
  row_has_opcodeClass_at_index_of_opcodeClassExecutionFacts facts.classFacts hRow

theorem mulUNoOverflowBound_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof) :
  MulUNoOverflowBound facts.mulHigh facts.zeroWord facts.quotientWord facts.divisorWord :=
  facts.mulUNoOverflowBound

theorem mulUNoOverflow_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof) :
  MulUNoOverflow facts.soundness.quotient facts.soundness.divisor :=
  facts.mulUNoOverflow

theorem unsignedDivRemSpec_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof) :
  UnsignedDivRemSpec
    facts.soundness.dividend
    facts.soundness.quotient
    facts.soundness.divisor
    facts.soundness.remainder :=
  facts.unsignedDivRemSpec

theorem unsignedDivRemDeterministic_of_unsignedDivRemExecutionFacts
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts : UnsignedDivRemExecutionFacts proof)
  {quotient' remainder'}
  (hSpec :
    UnsignedDivRemSpec
      facts.soundness.dividend
      quotient'
      facts.soundness.divisor
      remainder') :
  quotient' = facts.soundness.quotient ∧
    remainder' = facts.soundness.remainder :=
  facts.deterministic quotient' remainder' hSpec

noncomputable def unsignedDivRemExecutionFacts_of_stepComposition
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
  UnsignedDivRemExecutionFacts
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem :=
  unsignedDivRemExecutionFacts_of_opcodeClassFacts
    (unsignedDivRemFacts_of_stepComposition pkg)
    pkg.unsignedDivRem
    pkg.executionRow.mulHigh
    pkg.executionRow.zeroWord
    pkg.executionRow.divRemQuotient
    pkg.executionRow.divRemDivisor
    (mulUNoOverflowBound_of_stepComposition pkg)
    (mulUNoOverflow_of_stepComposition pkg)
    (unsignedDivRemSpec_of_stepComposition pkg)
    (by
      intro quotient' remainder' hSpec
      exact unsignedDivRemDeterministic_of_stepComposition pkg hSpec)

end Nightstream.Rv64IM
