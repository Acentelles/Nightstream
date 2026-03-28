import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.NativeAluOpcodeResultSemantics

/-!
Owns lifting of exact native-ALU encoded-result consequences through RV64IM
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

theorem encodedAluResult_of_kernelSoundness_nativeAlu
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
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluResult_of_authenticatedChunkTrace_nativeAlu
      kernel.authenticatedTrace
      hOpcode
      hWrites
      hRd

theorem authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
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
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult := by
  exact
    authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
      kernel.authenticatedTrace
      hOpcode
      hWrites
      hRd

theorem add_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .add)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem add_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .add)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem addi_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .addi)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem addi_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .addi)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sub_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .sub)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sub_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .sub)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem and_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .andOp)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem and_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .andOp)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem andi_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .andi)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem andi_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .andi)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem or_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .orOp)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem or_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .orOp)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem ori_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .ori)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem ori_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .ori)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xor_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .xorOp)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xor_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .xorOp)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xori_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .xori)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xori_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .xori)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slt_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .slt)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slt_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .slt)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slti_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .slti)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slti_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .slti)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltu_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .sltu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltu_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .sltu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltiu_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .sltiu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltiu_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .sltiu)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem lui_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .lui)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem lui_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .lui)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem auipc_encodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .auipc)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem auipc_authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
  (kernel :
    KernelSoundnessConclusion
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
      BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
      ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding)
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .auipc)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    kernel.authenticatedTrace.stepComposition.wordToLimbPair
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
    kernel hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem encodedAluResult_of_exactKernelBoundaries_nativeAlu
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
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluResult_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedEncodedAluResult_of_exactKernelBoundaries_nativeAlu
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
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult := by
  exact
    authenticatedEncodedAluResult_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

end

end Nightstream.Rv64IM
