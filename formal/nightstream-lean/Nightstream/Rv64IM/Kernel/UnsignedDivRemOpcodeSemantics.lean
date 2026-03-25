import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.HardOpLoweringRefinementSemantics

/-!
Owns lifting of exact unsigned DIV/REM opcode consequences through RV64IM
kernel soundness and exact kernel boundaries. This file does not re-own
execution semantics or authenticated trace closure.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _}
  [OfNat Limb 0]

theorem opcodeBound_of_kernelSoundness_unsignedDivRem
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding) :
  UnsignedDivRemOpcodeBound
    kernel.authenticatedTrace.stepComposition.decodedRow
    kernel.authenticatedTrace.stepComposition.unsignedDivRem.opcode :=
  opcodeBound_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem divu_flags_of_kernelSoundness
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .divu) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = false :=
  divu_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem remu_flags_of_kernelSoundness
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .remu) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = false :=
  remu_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem divuw_flags_of_kernelSoundness
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .divuw) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = true :=
  divuw_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem remuw_flags_of_kernelSoundness
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .remuw) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = true :=
  remuw_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem spec_of_unsignedDivu_of_kernelSoundness
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .divu ∨
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .divuw) :
  UnsignedDivRemSpec
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.remainder :=
  spec_of_unsignedDivuOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem spec_of_unsignedRemu_of_kernelSoundness
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .remu ∨
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.opcode =
      .remuw) :
  UnsignedDivRemSpec
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.remainder :=
  spec_of_unsignedRemuOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem deterministic_of_unsignedDivRem_of_kernelSoundness
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  {quotient' remainder'}
  (hSpec :
    UnsignedDivRemSpec
      (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.dividend
      quotient'
      (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.divisor
      remainder') :
  quotient' =
      (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.quotient ∧
    remainder' =
      (exactOpcodeFamilySemantics_of_kernelSoundness kernel).unsignedDivRem.soundness.remainder :=
  deterministic_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hSpec

theorem divu_flags_of_exactKernelBoundaries
  (boundaries :
    ExactKernelBoundaries
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).unsignedDivRem.soundness.opcode =
      .divu) :
  boundaries.trace.stepComposition.decodedRow.isDiv = true ∧
    boundaries.trace.stepComposition.decodedRow.isRem = false ∧
    boundaries.trace.stepComposition.decodedRow.isWOp = false := by
  simpa [exactOpcodeFamilySemantics_of_exactKernelBoundaries] using
    divu_flags_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem spec_of_unsignedDivu_of_exactKernelBoundaries
  (boundaries :
    ExactKernelBoundaries
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding)
  (hOpcode :
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).unsignedDivRem.soundness.opcode =
      .divu ∨
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).unsignedDivRem.soundness.opcode =
      .divuw) :
  UnsignedDivRemSpec
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).unsignedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).unsignedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).unsignedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).unsignedDivRem.soundness.remainder := by
  simpa [exactOpcodeFamilySemantics_of_exactKernelBoundaries] using
    spec_of_unsignedDivu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
