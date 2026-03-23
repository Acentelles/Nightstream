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

end

end Nightstream.Rv64IM
