import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.LoweringRefinement

/-!
Owns theorem-facing signed DIV/REM lowering consequences above exact
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

theorem fetchDecodeBound_of_signedDivRemLoweringSemantics
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

theorem decodedRow_valid_of_signedDivRemLoweringSemantics
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
    (fetchDecodeBound_of_signedDivRemLoweringSemantics facts)

theorem decodeHandoffBound_of_signedDivRemLoweringSemantics
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
    (fetchDecodeBound_of_signedDivRemLoweringSemantics facts)

theorem x0WritePreserved_of_signedDivRemLoweringSemantics
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
    (fetchDecodeBound_of_signedDivRemLoweringSemantics facts)

theorem nonFinalRdTarget_of_signedDivRemLoweringSemantics
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
    (fetchDecodeBound_of_signedDivRemLoweringSemantics facts)

theorem frame_row_eq_at_index_of_signedDivRemLoweringSemantics
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
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.frames[idx]? = some frame)
  (hRow :
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.rows[idx]? = some row) :
  frame.row = row :=
  frame_row_eq_at_index_of_signedDivRemExecutionFacts facts.signedDivRem hFrame hRow

theorem adjacentStates_of_signedDivRemLoweringSemantics
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
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.frames[idx]? = some prev)
  (hNext :
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.frames[idx + 1]? =
      some next) :
  prev.postState = next.preState :=
  adjacentStates_of_signedDivRemExecutionFacts facts.signedDivRem hPrev hNext

theorem preparedStep_matches_row_of_signedDivRemLoweringSemantics
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
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.preparedSteps[idx]? =
      some step)
  (hRow :
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.rows[idx]? = some row) :
  PreparedStepView.rowIndex step = idx ∧
    PreparedStepView.pc step = (ExpandedRow.bytecode row).unexpandedPc ∧
      PreparedStepView.advanceArchPc step = ExpandedRow.advanceArchPc row ∧
        PreparedStepView.terminates step = ExpandedRow.terminates row :=
  preparedStep_matches_row_of_signedDivRemExecutionFacts facts.signedDivRem hStep hRow

theorem successor_matches_rows_of_signedDivRemLoweringSemantics
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
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.successors[idx]? =
      some successor)
  (hRow :
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.rows[idx]? = some row)
  (hNext :
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.rows[idx + 1]? =
      some nextRow) :
  successor.row = ExpandedRow.bytecode row ∧
    successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc :=
  successor_matches_rows_of_signedDivRemExecutionFacts facts.signedDivRem hSucc hRow hNext

theorem row_has_opcodeClass_at_index_of_signedDivRemLoweringSemantics
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
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem.semantics.rows[idx]? = some row) :
  row.opcodeClass = .signedDivRem :=
  row_has_opcodeClass_at_index_of_signedDivRemExecutionFacts facts.signedDivRem hRow

theorem changeDivisorCorrect_of_signedDivRemLoweringSemantics
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
  ChangeDivisorCorrect
    facts.signedDivRem.soundness.dividend
    facts.signedDivRem.soundness.divisor
    facts.signedDivRem.soundness.changedDivisor :=
  changeDivisorCorrect_of_signedDivRemExecutionFacts facts.signedDivRem

theorem remainderFromDividendSign_of_signedDivRemLoweringSemantics
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
  RemainderFromDividendSign
    facts.signedDivRem.soundness.dividend
    facts.signedDivRem.soundness.remainderAbs
    facts.signedDivRem.soundness.remainderSigned :=
  remainderFromDividendSign_of_signedDivRemExecutionFacts facts.signedDivRem

theorem signedDivRemSpec_of_signedDivRemLoweringSemantics
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
  SignedDivRemSpec
    facts.signedDivRem.soundness.dividend
    facts.signedDivRem.soundness.quotient
    facts.signedDivRem.soundness.divisor
    facts.signedDivRem.soundness.remainderSigned :=
  signedDivRemSpec_of_signedDivRemExecutionFacts facts.signedDivRem

theorem sequenceCorrect_of_signedDivRemLoweringSemantics
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
    facts.signedDivRemSequenceProof.sequence
    facts.signedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  signedDivRemSequenceCorrect_of_exactOpcodeFamilySemantics facts

theorem sequenceDeterministic_of_signedDivRemLoweringSemantics
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
    facts.signedDivRemSequenceProof.sequence
    facts.signedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  signedDivRemSequenceDeterministic_of_exactOpcodeFamilySemantics facts

end

section

theorem normalizedReference_of_divRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  normalizeDivConcreteCore? rows = some divReferenceLowering :=
  normalizedReference_of_divConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_divRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divConcreteLoweringRefinesReference h

theorem closureSuffixScratchOnly_of_divRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_divRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divEffectRowIndex :=
  uniqueCommitRow_of_divConcreteLoweringRefinesReference h

theorem effectRowPrecedesCommitRow_of_divRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divEffectRowIndex ≤ rows.length - 1 :=
  effectRow_precedesCommitRow_of_divConcreteLoweringRefinesReference h

theorem normalizedReference_of_remRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  normalizeRemConcreteCore? rows = some remReferenceLowering :=
  normalizedReference_of_remConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_remRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remConcreteLoweringRefinesReference h

theorem closureSuffixScratchOnly_of_remRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_remRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remEffectRowIndex :=
  uniqueCommitRow_of_remConcreteLoweringRefinesReference h

theorem effectRowPrecedesCommitRow_of_remRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remEffectRowIndex ≤ rows.length - 1 :=
  effectRow_precedesCommitRow_of_remConcreteLoweringRefinesReference h

theorem normalizedReference_of_divwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  normalizeDivwConcreteCore? rows = some divwReferenceLowering :=
  normalizedReference_of_divwConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_divwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divwConcreteLoweringRefinesReference h

theorem closureSuffixScratchOnly_of_divwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divwConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_divwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divwEffectRowIndex :=
  uniqueCommitRow_of_divwConcreteLoweringRefinesReference h

theorem effectRowPrecedesCommitRow_of_divwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwEffectRowIndex ≤ rows.length - 1 :=
  effectRow_precedesCommitRow_of_divwConcreteLoweringRefinesReference h

theorem normalizedReference_of_remwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  normalizeRemwConcreteCore? rows = some remwReferenceLowering :=
  normalizedReference_of_remwConcreteLoweringRefinesReference h

theorem sequenceMetadataBound_of_remwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remwConcreteLoweringRefinesReference h

theorem closureSuffixScratchOnly_of_remwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remwConcreteLoweringRefinesReference h

theorem uniqueCommitRow_of_remwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remwEffectRowIndex :=
  uniqueCommitRow_of_remwConcreteLoweringRefinesReference h

theorem effectRowPrecedesCommitRow_of_remwRefinedSignedDivRemLowering
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwEffectRowIndex ≤ rows.length - 1 :=
  effectRow_precedesCommitRow_of_remwConcreteLoweringRefinesReference h

end

end Nightstream.Rv64IM
