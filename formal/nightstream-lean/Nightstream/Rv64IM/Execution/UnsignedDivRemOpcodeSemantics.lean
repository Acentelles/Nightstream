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

end

end Nightstream.Rv64IM
