import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.MultiplyWordArithmetic

/-!
Owns lifting of exact multiply word-level arithmetic consequences through
RV64IM kernel soundness and exact kernel-boundary surfaces.
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

theorem wordArithmetic_of_kernelSoundness_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = opcode) :
  kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    MultiplyWordResult
      kernel.authenticatedTrace.stepComposition.multiplyWordOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      kernel.authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_authenticatedChunkTrace_multiply
      kernel.authenticatedTrace
      hOpcode

theorem authenticatedWordArithmetic_of_kernelSoundness_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.limbPairToWord
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyWordResult
      kernel.authenticatedTrace.stepComposition.multiplyWordOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      kernel.authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_authenticatedChunkTrace_multiply
      kernel.authenticatedTrace
      hOpcode
      hRd

theorem wordArithmetic_of_exactKernelBoundaries_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode =
      opcode) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    MultiplyWordResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyWordOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedWordArithmetic_of_exactKernelBoundaries_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode =
      opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyWordResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyWordOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
