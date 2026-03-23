import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.MultiplyEncodedArithmetic

/-!
Owns lifting of exact multiply encoded arithmetic consequences through RV64IM
kernel soundness and exact kernel-boundary surfaces.
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

theorem encodedArithmetic_of_kernelSoundness_multiply
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
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    MultiplyEncodedResult
      kernel.authenticatedTrace.stepComposition.multiplyEncodedOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      opcode := by
  exact
    encodedArithmetic_of_authenticatedChunkTrace_multiply
      kernel.authenticatedTrace
      hOpcode

theorem authenticatedEncodedArithmetic_of_kernelSoundness_multiply
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
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyEncodedResult
      kernel.authenticatedTrace.stepComposition.multiplyEncodedOps
      kernel.authenticatedTrace.stepComposition.decodedRow
      kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist
      opcode := by
  exact
    authenticatedEncodedArithmetic_of_authenticatedChunkTrace_multiply
      kernel.authenticatedTrace
      hOpcode
      hRd

theorem encodedArithmetic_of_exactKernelBoundaries_multiply
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
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    MultiplyEncodedResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyEncodedOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      opcode := by
  exact
    encodedArithmetic_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedEncodedArithmetic_of_exactKernelBoundaries_multiply
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
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyEncodedResult
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyEncodedOps
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist
      opcode := by
  exact
    authenticatedEncodedArithmetic_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
