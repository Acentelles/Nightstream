import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.HardOpLoweringRefinementSemantics

/-!
Owns lifting of exact signed DIV/REM opcode consequences through RV64IM kernel
soundness and exact kernel boundaries. This file does not re-own execution
semantics or authenticated trace closure.
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

theorem opcodeBound_of_kernelSoundness_signedDivRem
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
  SignedDivRemOpcodeBound
    kernel.authenticatedTrace.stepComposition.decodedRow
    kernel.authenticatedTrace.stepComposition.signedDivRem.opcode :=
  opcodeBound_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem div_flags_of_kernelSoundness
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
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .div) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = false :=
  div_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem rem_flags_of_kernelSoundness
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
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .rem) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = false :=
  rem_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem divw_flags_of_kernelSoundness
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
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .divw) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = true :=
  divw_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem remw_flags_of_kernelSoundness
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
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .remw) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = true :=
  remw_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem spec_of_signedDiv_of_kernelSoundness
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
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .div ∨
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .divw) :
  SignedDivRemSpec
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.remainderSigned :=
  spec_of_signedDivOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem spec_of_signedRem_of_kernelSoundness
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
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .rem ∨
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.opcode =
      .remw) :
  SignedDivRemSpec
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).signedDivRem.soundness.remainderSigned :=
  spec_of_signedRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem div_flags_of_exactKernelBoundaries
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
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).signedDivRem.soundness.opcode =
      .div) :
  boundaries.trace.stepComposition.decodedRow.isDiv = true ∧
    boundaries.trace.stepComposition.decodedRow.isRem = false ∧
    boundaries.trace.stepComposition.decodedRow.isWOp = false := by
  simpa [exactOpcodeFamilySemantics_of_exactKernelBoundaries] using
    div_flags_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem spec_of_signedDiv_of_exactKernelBoundaries
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
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).signedDivRem.soundness.opcode =
      .div ∨
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).signedDivRem.soundness.opcode =
      .divw) :
  SignedDivRemSpec
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).signedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).signedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).signedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).signedDivRem.soundness.remainderSigned := by
  simpa [exactOpcodeFamilySemantics_of_exactKernelBoundaries] using
    spec_of_signedDiv_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
