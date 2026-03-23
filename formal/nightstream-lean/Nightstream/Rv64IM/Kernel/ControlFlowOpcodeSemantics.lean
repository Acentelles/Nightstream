import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.ControlFlowOpcodeSemantics

/-!
Owns lifting of exact control-flow opcode consequences through the kernel
soundness and exact kernel-boundary surfaces. This file does not re-own
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

theorem lane_isJal_of_kernelSoundness
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
  (hOpcode : ControlFlowOpcodeBound kernel.authenticatedTrace.stepComposition.decodedRow .jal) :
  (exactOpcodeFamilySemantics_of_kernelSoundness kernel).controlFlow.lane.isJal = true :=
  lane_isJal_of_controlFlowOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem lane_isJalr_of_kernelSoundness
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
  (hOpcode : ControlFlowOpcodeBound kernel.authenticatedTrace.stepComposition.decodedRow .jalr) :
  (exactOpcodeFamilySemantics_of_kernelSoundness kernel).controlFlow.lane.isJalr = true :=
  lane_isJalr_of_controlFlowOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem takenTargetAlignment_of_jal_of_kernelSoundness
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
  (hOpcode : ControlFlowOpcodeBound kernel.authenticatedTrace.stepComposition.decodedRow .jal) :
  NaturalAlignment
    .word
    ((exactOpcodeFamilySemantics_of_kernelSoundness kernel).controlFlow.wordToNat
      (exactOpcodeFamilySemantics_of_kernelSoundness kernel).controlFlow.lane.jumpTarget) :=
  takenTargetAlignment_of_jalOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem takenTargetAlignment_of_jalr_of_kernelSoundness
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
  (hOpcode : ControlFlowOpcodeBound kernel.authenticatedTrace.stepComposition.decodedRow .jalr) :
  NaturalAlignment
    .word
    ((exactOpcodeFamilySemantics_of_kernelSoundness kernel).controlFlow.wordToNat
      (exactOpcodeFamilySemantics_of_kernelSoundness kernel).controlFlow.lane.jumpTarget) :=
  takenTargetAlignment_of_jalrOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem lane_isJal_of_exactKernelBoundaries
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
  (hOpcode : ControlFlowOpcodeBound boundaries.trace.stepComposition.decodedRow .jal) :
  (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).controlFlow.lane.isJal = true := by
  simpa [exactOpcodeFamilySemantics_of_exactKernelBoundaries] using
    lane_isJal_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem takenTargetAlignment_of_jal_of_exactKernelBoundaries
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
  (hOpcode : ControlFlowOpcodeBound boundaries.trace.stepComposition.decodedRow .jal) :
  NaturalAlignment
    .word
    ((exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).controlFlow.wordToNat
      (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).controlFlow.lane.jumpTarget) := by
  simpa [exactOpcodeFamilySemantics_of_exactKernelBoundaries] using
    takenTargetAlignment_of_jal_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
