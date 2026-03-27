import Nightstream.Rv64IM.Execution.SignedDivRemLoweringSemantics

/-!
Owns exact theorem-facing opcode consequences for the signed DIV/REM family.
This file sits above signed DIV/REM lowering semantics and exposes the
decoded-row/opcode correspondence that closes the remaining exact-opcode gap
for `DIV`, `REM`, `DIVW`, and `REMW`.
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

theorem opcodeBound_of_signedDivRemOpcodeSemantics
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
  SignedDivRemOpcodeBound pkg.decodedRow pkg.signedDivRem.opcode :=
  signedDivRemOpcodeBound_of_stepComposition pkg

theorem div_flags_of_signedDivRemOpcodeSemantics
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
  (hOpcode : facts.signedDivRem.soundness.opcode = .div) :
  pkg.decodedRow.isDiv = true ∧
    pkg.decodedRow.isRem = false ∧
    pkg.decodedRow.isWOp = false := by
  have hPkgOpcode : pkg.signedDivRem.opcode = .div := by
    simpa [facts.signedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, SignedDivRemOpcodeBound]
    using opcodeBound_of_signedDivRemOpcodeSemantics facts

theorem rem_flags_of_signedDivRemOpcodeSemantics
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
  (hOpcode : facts.signedDivRem.soundness.opcode = .rem) :
  pkg.decodedRow.isDiv = false ∧
    pkg.decodedRow.isRem = true ∧
    pkg.decodedRow.isWOp = false := by
  have hPkgOpcode : pkg.signedDivRem.opcode = .rem := by
    simpa [facts.signedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, SignedDivRemOpcodeBound]
    using opcodeBound_of_signedDivRemOpcodeSemantics facts

theorem divw_flags_of_signedDivRemOpcodeSemantics
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
  (hOpcode : facts.signedDivRem.soundness.opcode = .divw) :
  pkg.decodedRow.isDiv = true ∧
    pkg.decodedRow.isRem = false ∧
    pkg.decodedRow.isWOp = true := by
  have hPkgOpcode : pkg.signedDivRem.opcode = .divw := by
    simpa [facts.signedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, SignedDivRemOpcodeBound]
    using opcodeBound_of_signedDivRemOpcodeSemantics facts

theorem remw_flags_of_signedDivRemOpcodeSemantics
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
  (hOpcode : facts.signedDivRem.soundness.opcode = .remw) :
  pkg.decodedRow.isDiv = false ∧
    pkg.decodedRow.isRem = true ∧
    pkg.decodedRow.isWOp = true := by
  have hPkgOpcode : pkg.signedDivRem.opcode = .remw := by
    simpa [facts.signedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, SignedDivRemOpcodeBound]
    using opcodeBound_of_signedDivRemOpcodeSemantics facts

theorem spec_of_signedDivOpcodeSemantics
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
  (_hOpcode :
    facts.signedDivRem.soundness.opcode = .div ∨
    facts.signedDivRem.soundness.opcode = .divw) :
  SignedDivRemSpec
    facts.signedDivRem.soundness.dividend
    facts.signedDivRem.soundness.quotient
    facts.signedDivRem.soundness.divisor
    facts.signedDivRem.soundness.remainderSigned :=
  signedDivRemSpec_of_signedDivRemLoweringSemantics facts

theorem spec_of_signedRemOpcodeSemantics
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
  (_hOpcode :
    facts.signedDivRem.soundness.opcode = .rem ∨
    facts.signedDivRem.soundness.opcode = .remw) :
  SignedDivRemSpec
    facts.signedDivRem.soundness.dividend
    facts.signedDivRem.soundness.quotient
    facts.signedDivRem.soundness.divisor
    facts.signedDivRem.soundness.remainderSigned :=
  signedDivRemSpec_of_signedDivRemLoweringSemantics facts

theorem normalizedReference_of_divRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  normalizeDivConcreteCore? rows = some divReferenceLowering :=
  normalizedReference_of_divRefinedSignedDivRemLowering h

theorem sequenceMetadataBound_of_divRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divRefinedSignedDivRemLowering h

theorem closureSuffixScratchOnly_of_divRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divRefinedSignedDivRemLowering h

theorem uniqueCommitRow_of_divRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divCommitRowIndex :=
  uniqueCommitRow_of_divRefinedSignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_divRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivConcreteLoweringRefinesReference rows) :
  divEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divRefinedSignedDivRemLowering h

theorem normalizedReference_of_remRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  normalizeRemConcreteCore? rows = some remReferenceLowering :=
  normalizedReference_of_remRefinedSignedDivRemLowering h

theorem sequenceMetadataBound_of_remRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remRefinedSignedDivRemLowering h

theorem closureSuffixScratchOnly_of_remRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remRefinedSignedDivRemLowering h

theorem uniqueCommitRow_of_remRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remEffectRowIndex :=
  uniqueCommitRow_of_remRefinedSignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_remRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemConcreteLoweringRefinesReference rows) :
  remEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remRefinedSignedDivRemLowering h

theorem normalizedReference_of_divwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  normalizeDivwConcreteCore? rows = some divwReferenceLowering :=
  normalizedReference_of_divwRefinedSignedDivRemLowering h

theorem sequenceMetadataBound_of_divwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divwRefinedSignedDivRemLowering h

theorem closureSuffixScratchOnly_of_divwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divwRefinedSignedDivRemLowering h

theorem uniqueCommitRow_of_divwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divwEffectRowIndex :=
  uniqueCommitRow_of_divwRefinedSignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_divwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivwConcreteLoweringRefinesReference rows) :
  divwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divwRefinedSignedDivRemLowering h

theorem normalizedReference_of_remwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  normalizeRemwConcreteCore? rows = some remwReferenceLowering :=
  normalizedReference_of_remwRefinedSignedDivRemLowering h

theorem sequenceMetadataBound_of_remwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remwRefinedSignedDivRemLowering h

theorem closureSuffixScratchOnly_of_remwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remwRefinedSignedDivRemLowering h

theorem uniqueCommitRow_of_remwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remwEffectRowIndex :=
  uniqueCommitRow_of_remwRefinedSignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_remwRefinedSignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemwConcreteLoweringRefinesReference rows) :
  remwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remwRefinedSignedDivRemLowering h

end

end Nightstream.Rv64IM
