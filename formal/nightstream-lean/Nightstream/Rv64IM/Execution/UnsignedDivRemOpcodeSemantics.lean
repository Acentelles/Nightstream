import Nightstream.Rv64IM.Execution.UnsignedDivRemLoweringSemantics

/-!
Owns exact theorem-facing opcode consequences for the unsigned DIV/REM family.
This file sits above unsigned DIV/REM lowering semantics and exposes the
decoded-row/opcode correspondence that closes the remaining exact-opcode gap
for `DIVU`, `REMU`, `DIVUW`, and `REMUW`.
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

theorem opcodeBound_of_unsignedDivRemOpcodeSemantics
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
  UnsignedDivRemOpcodeBound pkg.decodedRow pkg.unsignedDivRem.opcode :=
  unsignedDivRemOpcodeBound_of_stepComposition pkg

theorem divu_flags_of_unsignedDivRemOpcodeSemantics
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
  (hOpcode : facts.unsignedDivRem.soundness.opcode = .divu) :
  pkg.decodedRow.isDiv = true ∧
    pkg.decodedRow.isRem = false ∧
    pkg.decodedRow.isWOp = false := by
  have hPkgOpcode : pkg.unsignedDivRem.opcode = .divu := by
    simpa [facts.unsignedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, UnsignedDivRemOpcodeBound]
    using opcodeBound_of_unsignedDivRemOpcodeSemantics facts

theorem remu_flags_of_unsignedDivRemOpcodeSemantics
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
  (hOpcode : facts.unsignedDivRem.soundness.opcode = .remu) :
  pkg.decodedRow.isDiv = false ∧
    pkg.decodedRow.isRem = true ∧
    pkg.decodedRow.isWOp = false := by
  have hPkgOpcode : pkg.unsignedDivRem.opcode = .remu := by
    simpa [facts.unsignedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, UnsignedDivRemOpcodeBound]
    using opcodeBound_of_unsignedDivRemOpcodeSemantics facts

theorem divuw_flags_of_unsignedDivRemOpcodeSemantics
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
  (hOpcode : facts.unsignedDivRem.soundness.opcode = .divuw) :
  pkg.decodedRow.isDiv = true ∧
    pkg.decodedRow.isRem = false ∧
    pkg.decodedRow.isWOp = true := by
  have hPkgOpcode : pkg.unsignedDivRem.opcode = .divuw := by
    simpa [facts.unsignedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, UnsignedDivRemOpcodeBound]
    using opcodeBound_of_unsignedDivRemOpcodeSemantics facts

theorem remuw_flags_of_unsignedDivRemOpcodeSemantics
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
  (hOpcode : facts.unsignedDivRem.soundness.opcode = .remuw) :
  pkg.decodedRow.isDiv = false ∧
    pkg.decodedRow.isRem = true ∧
    pkg.decodedRow.isWOp = true := by
  have hPkgOpcode : pkg.unsignedDivRem.opcode = .remuw := by
    simpa [facts.unsignedDivRemSoundnessEq] using hOpcode
  simpa [hPkgOpcode, UnsignedDivRemOpcodeBound]
    using opcodeBound_of_unsignedDivRemOpcodeSemantics facts

theorem spec_of_unsignedDivuOpcodeSemantics
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
    facts.unsignedDivRem.soundness.opcode = .divu ∨
    facts.unsignedDivRem.soundness.opcode = .divuw) :
  UnsignedDivRemSpec
    facts.unsignedDivRem.soundness.dividend
    facts.unsignedDivRem.soundness.quotient
    facts.unsignedDivRem.soundness.divisor
    facts.unsignedDivRem.soundness.remainder :=
  unsignedDivRemSpec_of_unsignedDivRemLoweringSemantics facts

theorem spec_of_unsignedRemuOpcodeSemantics
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
    facts.unsignedDivRem.soundness.opcode = .remu ∨
    facts.unsignedDivRem.soundness.opcode = .remuw) :
  UnsignedDivRemSpec
    facts.unsignedDivRem.soundness.dividend
    facts.unsignedDivRem.soundness.quotient
    facts.unsignedDivRem.soundness.divisor
    facts.unsignedDivRem.soundness.remainder :=
  unsignedDivRemSpec_of_unsignedDivRemLoweringSemantics facts

theorem deterministic_of_unsignedDivRemOpcodeSemantics
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
  unsignedDivRemDeterministic_of_unsignedDivRemLoweringSemantics facts hSpec

theorem normalizedReference_of_divuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  normalizeDivuConcreteCore? rows = some divuReferenceLowering :=
  normalizedReference_of_divuRefinedUnsignedDivRemLowering h

theorem sequenceMetadataBound_of_divuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divuRefinedUnsignedDivRemLowering h

theorem closureSuffixScratchOnly_of_divuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  divuClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divuRefinedUnsignedDivRemLowering h

theorem uniqueCommitRow_of_divuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divuCommitRowIndex :=
  uniqueCommitRow_of_divuRefinedUnsignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_divuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuConcreteLoweringRefinesReference rows) :
  divuEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divuRefinedUnsignedDivRemLowering h

theorem normalizedReference_of_remuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  normalizeRemuConcreteCore? rows = some remuReferenceLowering :=
  normalizedReference_of_remuRefinedUnsignedDivRemLowering h

theorem sequenceMetadataBound_of_remuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remuRefinedUnsignedDivRemLowering h

theorem closureSuffixScratchOnly_of_remuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  remuClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remuRefinedUnsignedDivRemLowering h

theorem uniqueCommitRow_of_remuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remuEffectRowIndex :=
  uniqueCommitRow_of_remuRefinedUnsignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_remuRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuConcreteLoweringRefinesReference rows) :
  remuEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remuRefinedUnsignedDivRemLowering h

theorem normalizedReference_of_divuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  normalizeDivuwConcreteCore? rows = some divuwReferenceLowering :=
  normalizedReference_of_divuwRefinedUnsignedDivRemLowering h

theorem sequenceMetadataBound_of_divuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_divuwRefinedUnsignedDivRemLowering h

theorem closureSuffixScratchOnly_of_divuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  divuwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_divuwRefinedUnsignedDivRemLowering h

theorem uniqueCommitRow_of_divuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows divuwEffectRowIndex :=
  uniqueCommitRow_of_divuwRefinedUnsignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_divuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : DivuwConcreteLoweringRefinesReference rows) :
  divuwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_divuwRefinedUnsignedDivRemLowering h

theorem normalizedReference_of_remuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  normalizeRemuwConcreteCore? rows = some remuwReferenceLowering :=
  normalizedReference_of_remuwRefinedUnsignedDivRemLowering h

theorem sequenceMetadataBound_of_remuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  rowSequenceMetadataBound rows :=
  sequenceMetadataBound_of_remuwRefinedUnsignedDivRemLowering h

theorem closureSuffixScratchOnly_of_remuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  remuwClosureSuffixScratchOnly rows :=
  closureSuffixScratchOnly_of_remuwRefinedUnsignedDivRemLowering h

theorem uniqueCommitRow_of_remuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  uniqueRealRowAt rows remuwEffectRowIndex :=
  uniqueCommitRow_of_remuwRefinedUnsignedDivRemLowering h

theorem effectRowPrecedesCommitRow_of_remuwRefinedUnsignedDivRemOpcodeSemantics
  {rows : List ImportedLoweringRow}
  (h : RemuwConcreteLoweringRefinesReference rows) :
  remuwEffectRowIndex ≤ rows.length - 1 :=
  effectRowPrecedesCommitRow_of_remuwRefinedUnsignedDivRemLowering h

end

end Nightstream.Rv64IM
