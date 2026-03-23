import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics

/-!
Owns theorem-facing unsigned DIV/REM lowering consequences above exact
opcode-family semantics. This file does not re-own stage-local bindings,
canonical class closure, or kernel-level trace/bridge facts.
-/

namespace Nightstream.Rv64IM

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

theorem fetchDecodeBound_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  FetchDecodeBound
    pkg.bytecodeTable
    pkg.expandedPc
    pkg.x0
    pkg.isArchitectural
    pkg.decodedRow :=
  pkg.fetchDecodeBound

theorem decodedRow_valid_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  pkg.decodedRow.valid = true :=
  fetchDecodeBound_valid
    (fetchDecodeBound_of_unsignedDivRemLoweringSemantics facts)

theorem decodeHandoffBound_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  DecodeHandoffBound pkg.decodedRow pkg.decodedRow.toDecodeHandoff :=
  fetchDecodeBound_handoff
    (fetchDecodeBound_of_unsignedDivRemLoweringSemantics facts)

theorem x0WritePreserved_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  X0WritePreserved pkg.x0 pkg.decodedRow :=
  fetchDecodeBound_x0Preserved
    (fetchDecodeBound_of_unsignedDivRemLoweringSemantics facts)

theorem nonFinalRdTarget_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  NonFinalRdTargetBound pkg.isArchitectural pkg.decodedRow :=
  fetchDecodeBound_nonFinalRdTarget
    (fetchDecodeBound_of_unsignedDivRemLoweringSemantics facts)

theorem frame_row_eq_at_index_of_unsignedDivRemLoweringSemantics
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
  {idx : Nat}
  {frame : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hFrame :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.frames[idx]? = some frame)
  (hRow :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.rows[idx]? = some row) :
  frame.row = row :=
  frame_row_eq_at_index_of_unsignedDivRemExecutionFacts facts.unsignedDivRem hFrame hRow

theorem adjacentStates_of_unsignedDivRemLoweringSemantics
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
  {idx : Nat}
  {prev next : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (hPrev :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.frames[idx]? = some prev)
  (hNext :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.frames[idx + 1]? =
      some next) :
  prev.postState = next.preState :=
  adjacentStates_of_unsignedDivRemExecutionFacts facts.unsignedDivRem hPrev hNext

theorem preparedStep_matches_row_of_unsignedDivRemLoweringSemantics
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
  {idx : Nat}
  {step : PreparedStepView Pc}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hStep :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.preparedSteps[idx]? =
      some step)
  (hRow :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.rows[idx]? = some row) :
  PreparedStepView.rowIndex step = idx ∧
    PreparedStepView.pc step = (ExpandedRow.bytecode row).unexpandedPc ∧
      PreparedStepView.advanceArchPc step = ExpandedRow.advanceArchPc row ∧
        PreparedStepView.terminates step = ExpandedRow.terminates row :=
  preparedStep_matches_row_of_unsignedDivRemExecutionFacts facts.unsignedDivRem hStep hRow

theorem successor_matches_rows_of_unsignedDivRemLoweringSemantics
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
  {idx : Nat}
  {successor : ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr}
  {row nextRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hSucc :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.successors[idx]? =
      some successor)
  (hRow :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.rows[idx]? = some row)
  (hNext :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.rows[idx + 1]? =
      some nextRow) :
  successor.row = ExpandedRow.bytecode row ∧
    successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc :=
  successor_matches_rows_of_unsignedDivRemExecutionFacts facts.unsignedDivRem hSucc hRow hNext

theorem row_has_opcodeClass_at_index_of_unsignedDivRemLoweringSemantics
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
  {idx : Nat}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hRow :
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem.semantics.rows[idx]? = some row) :
  row.opcodeClass = .unsignedDivRem :=
  row_has_opcodeClass_at_index_of_unsignedDivRemExecutionFacts facts.unsignedDivRem hRow

theorem mulUNoOverflowBound_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  MulUNoOverflowBound
    facts.unsignedDivRem.mulHigh
    facts.unsignedDivRem.zeroWord
    facts.unsignedDivRem.quotientWord
    facts.unsignedDivRem.divisorWord :=
  mulUNoOverflowBound_of_unsignedDivRemExecutionFacts facts.unsignedDivRem

theorem mulUNoOverflow_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  MulUNoOverflow
    facts.unsignedDivRem.soundness.quotient
    facts.unsignedDivRem.soundness.divisor :=
  mulUNoOverflow_of_unsignedDivRemExecutionFacts facts.unsignedDivRem

theorem unsignedDivRemSpec_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  UnsignedDivRemSpec
    facts.unsignedDivRem.soundness.dividend
    facts.unsignedDivRem.soundness.quotient
    facts.unsignedDivRem.soundness.divisor
    facts.unsignedDivRem.soundness.remainder :=
  unsignedDivRemSpec_of_unsignedDivRemExecutionFacts facts.unsignedDivRem

theorem sequenceCorrect_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  AdviceSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.unsignedDivRemSequenceProof.sequence
    facts.unsignedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  unsignedDivRemSequenceCorrect_of_exactOpcodeFamilySemantics facts

theorem sequenceDeterministic_of_unsignedDivRemLoweringSemantics
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
      pkg) :
  AdviceSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.unsignedDivRemSequenceProof.sequence
    facts.unsignedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  unsignedDivRemSequenceDeterministic_of_exactOpcodeFamilySemantics facts

theorem unsignedDivRemDeterministic_of_unsignedDivRemLoweringSemantics
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
  {quotient' remainder'}
  (hSpec :
    UnsignedDivRemSpec
      facts.unsignedDivRem.soundness.dividend
      quotient'
      facts.unsignedDivRem.soundness.divisor
      remainder') :
  quotient' = facts.unsignedDivRem.soundness.quotient ∧
    remainder' = facts.unsignedDivRem.soundness.remainder :=
  unsignedDivRemDeterministic_of_unsignedDivRemExecutionFacts facts.unsignedDivRem hSpec

end

end Nightstream.Rv64IM
