import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.LoweringRefinement

/-!
Owns theorem-facing multiply-family lowering consequences above exact
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

theorem fetchDecodeBound_of_multiplyLoweringSemantics
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

theorem decodedRow_valid_of_multiplyLoweringSemantics
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
    (fetchDecodeBound_of_multiplyLoweringSemantics facts)

theorem decodeHandoffBound_of_multiplyLoweringSemantics
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
    (fetchDecodeBound_of_multiplyLoweringSemantics facts)

theorem x0WritePreserved_of_multiplyLoweringSemantics
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
    (fetchDecodeBound_of_multiplyLoweringSemantics facts)

theorem nonFinalRdTarget_of_multiplyLoweringSemantics
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
    (fetchDecodeBound_of_multiplyLoweringSemantics facts)

theorem frame_row_eq_at_index_of_multiplyLoweringSemantics
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
  (hFrame : (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.frames[idx]? = some frame)
  (hRow : (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.rows[idx]? = some row) :
  frame.row = row :=
  frame_row_eq_at_index_of_multiplyExecutionFacts facts.multiply hFrame hRow

theorem adjacentStates_of_multiplyLoweringSemantics
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
  (hPrev : (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.frames[idx]? = some prev)
  (hNext :
    (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.frames[idx + 1]? = some next) :
  prev.postState = next.preState :=
  adjacentStates_of_multiplyExecutionFacts facts.multiply hPrev hNext

theorem preparedStep_matches_row_of_multiplyLoweringSemantics
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
    (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.preparedSteps[idx]? = some step)
  (hRow : (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.rows[idx]? = some row) :
  PreparedStepView.rowIndex step = idx ∧
    PreparedStepView.pc step = (ExpandedRow.bytecode row).unexpandedPc ∧
      PreparedStepView.advanceArchPc step = ExpandedRow.advanceArchPc row ∧
        PreparedStepView.terminates step = ExpandedRow.terminates row :=
  preparedStep_matches_row_of_multiplyExecutionFacts facts.multiply hStep hRow

theorem successor_matches_rows_of_multiplyLoweringSemantics
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
    (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.successors[idx]? = some successor)
  (hRow : (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.rows[idx]? = some row)
  (hNext :
    (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.rows[idx + 1]? = some nextRow) :
  successor.row = ExpandedRow.bytecode row ∧
    successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc :=
  successor_matches_rows_of_multiplyExecutionFacts facts.multiply hSucc hRow hNext

theorem row_has_opcodeClass_at_index_of_multiplyLoweringSemantics
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
  (hRow : (canonicalOpcodeProofs_of_stepComposition pkg).multiply.semantics.rows[idx]? = some row) :
  row.opcodeClass = .multiply :=
  row_has_opcodeClass_at_index_of_multiplyExecutionFacts facts.multiply hRow

theorem sequenceCorrect_of_multiplyLoweringSemantics
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
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.multiplySequenceProof.sequence
    facts.multiplySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  multiplySequenceCorrect_of_exactOpcodeFamilySemantics facts

theorem sequenceDeterministic_of_multiplyLoweringSemantics
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
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.multiplySequenceProof.sequence
    facts.multiplySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  multiplySequenceDeterministic_of_exactOpcodeFamilySemantics facts

end

section

theorem normalizedReference_of_mulRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  normalizeMulConcreteCore? rows = some mulReferenceLowering :=
  normalizedReference_of_mulConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_mulRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_mulRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulEffectRowIndex :=
  uniqueCommitRow_of_mulConcreteLoweringRefinesReference h

theorem normalizedReference_of_mulhuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  normalizeMulhuConcreteCore? rows = some mulhuReferenceLowering :=
  normalizedReference_of_mulhuConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_mulhuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulhuConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_mulhuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhuEffectRowIndex :=
  uniqueCommitRow_of_mulhuConcreteLoweringRefinesReference h

theorem normalizedReference_of_mulwRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  normalizeMulwConcreteCore? rows = some mulwReferenceLowering :=
  normalizedReference_of_mulwConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_mulwRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulwConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_mulwRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulwEffectRowIndex :=
  uniqueCommitRow_of_mulwConcreteLoweringRefinesReference h

theorem normalizedReference_of_mulhRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  normalizeMulhConcreteCore? rows = some mulhReferenceLowering :=
  normalizedReference_of_mulhConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_mulhRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulhConcreteLoweringRefinesReference h

theorem closureSuffixScratchOnly_of_mulhRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  mulhClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_mulhConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_mulhRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhEffectRowIndex :=
  uniqueCommitRow_of_mulhConcreteLoweringRefinesReference h

theorem effectRowPrecedesCommitRow_of_mulhRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhConcreteLoweringRefinesReference rows) :
  mulhEffectRowIndex ≤ rows.length - 1 :=
  effectRow_precedesCommitRow_of_mulhConcreteLoweringRefinesReference h

theorem normalizedReference_of_mulhsuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  normalizeMulhsuConcreteCore? rows = some mulhsuReferenceLowering :=
  normalizedReference_of_mulhsuConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_mulhsuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_mulhsuConcreteLoweringRefinesReference h

theorem closureSuffixScratchOnly_of_mulhsuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  mulhsuClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_mulhsuConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_mulhsuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows mulhsuEffectRowIndex :=
  uniqueCommitRow_of_mulhsuConcreteLoweringRefinesReference h

theorem effectRowPrecedesCommitRow_of_mulhsuRefinedMultiplyLowering
  {rows : List ImportedLoweringRow}
  (h : MulhsuConcreteLoweringRefinesReference rows) :
  mulhsuEffectRowIndex ≤ rows.length - 1 :=
  effectRow_precedesCommitRow_of_mulhsuConcreteLoweringRefinesReference h

end

end Nightstream.Rv64IM
