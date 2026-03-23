import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.WordShiftWordArithmetic

/-!
Owns lifting of exact word/shift word-level arithmetic consequences through
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

theorem wordArithmetic_of_kernelSoundness_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.wordShiftOpcode = opcode) :
  kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    WordShiftWordResult
      kernel.authenticatedTrace.stepComposition.wordShiftWordOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      kernel.authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_authenticatedChunkTrace_wordShift
      kernel.authenticatedTrace
      hOpcode

theorem authenticatedWordArithmetic_of_kernelSoundness_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.wordShiftOpcode = opcode)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.limbPairToWord
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      kernel.authenticatedTrace.stepComposition.wordShiftWordOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      kernel.authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_authenticatedChunkTrace_wordShift
      kernel.authenticatedTrace
      hOpcode
      hRd

theorem wordArithmetic_of_exactKernelBoundaries_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordShiftOpcode =
      opcode) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    WordShiftWordResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordShiftWordOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_kernelSoundness_wordShift
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedWordArithmetic_of_exactKernelBoundaries_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordShiftOpcode =
      opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordShiftWordOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_kernelSoundness_wordShift
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
