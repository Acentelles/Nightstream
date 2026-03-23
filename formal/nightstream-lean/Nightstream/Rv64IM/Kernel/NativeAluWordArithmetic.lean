import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.NativeAluWordArithmetic

/-!
Owns lifting of exact native-ALU word-level arithmetic consequences through
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

theorem wordArithmetic_of_kernelSoundness_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = opcode) :
  kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    NativeAluWordResult
      kernel.authenticatedTrace.stepComposition.nativeAluWordOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      kernel.authenticatedTrace.stepComposition.executionRow.lane
      kernel.authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_authenticatedChunkTrace_nativeAlu
      kernel.authenticatedTrace
      hOpcode

theorem authenticatedWordArithmetic_of_kernelSoundness_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.limbPairToWord
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    NativeAluWordResult
      kernel.authenticatedTrace.stepComposition.nativeAluWordOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      kernel.authenticatedTrace.stepComposition.executionRow.lane
      kernel.authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_authenticatedChunkTrace_nativeAlu
      kernel.authenticatedTrace
      hOpcode
      hWrites
      hRd

theorem wordArithmetic_of_exactKernelBoundaries_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode =
      opcode) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    NativeAluWordResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluWordOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.lane
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedWordArithmetic_of_exactKernelBoundaries_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode =
      opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    NativeAluWordResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluWordOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.lane
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

end

end Nightstream.Rv64IM
