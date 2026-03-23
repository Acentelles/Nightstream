import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.MultiplyOpcodeResultSemantics

/-!
Owns lifting of exact multiply encoded-result consequences through RV64IM
kernel soundness and exact kernel boundaries.
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

theorem encodedAluResult_of_kernelSoundness_multiply
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
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluResult_of_authenticatedChunkTrace_multiply
      kernel.authenticatedTrace
      hOpcode
      hRd

theorem authenticatedEncodedAluResult_of_kernelSoundness_multiply
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
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult := by
  exact
    authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
      kernel.authenticatedTrace
      hOpcode
      hRd

theorem mul_encodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mul)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mul_authenticatedEncodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mul)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulh_encodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulh)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulh_authenticatedEncodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulh)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulhu_encodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulhu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulhu_authenticatedEncodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulhu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulhsu_encodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulhsu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulhsu_authenticatedEncodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulhsu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulw_encodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulw)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem mulw_authenticatedEncodedAluResult_of_kernelSoundness_multiply
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = .mulw)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_multiply kernel hOpcode hRd

theorem encodedAluResult_of_exactKernelBoundaries_multiply
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
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluResult_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedEncodedAluResult_of_exactKernelBoundaries_multiply
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult := by
  exact
    authenticatedEncodedAluResult_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
