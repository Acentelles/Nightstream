import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.MultiplyOpcodeSemantics

/-!
Owns lifting of exact multiply opcode consequences through RV64IM kernel
soundness and exact kernel boundaries.
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

theorem opcodeBound_of_kernelSoundness_multiply
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
  MultiplyOpcodeBound
    kernel.authenticatedTrace.stepComposition.multiplyAluOps
    kernel.authenticatedTrace.stepComposition.decodedRow
    kernel.authenticatedTrace.stepComposition.multiplyOpcode :=
  opcodeBound_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem flags_of_kernelSoundness_multiply
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
  kernel.authenticatedTrace.stepComposition.decodedRow.isJal = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isJalr = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isBranch = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isLoad = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isStore = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isMul = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.usesRs2 = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = opcode.isWOp ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.aluOp =
      kernel.authenticatedTrace.stepComposition.multiplyAluOps.forOpcode opcode :=
  flags_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem x0WritePreserved_of_kernelSoundness_multiply
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
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd =
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.decodedRow.preservesRd = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesAluToRd = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false :=
  x0WritePreserved_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hRd

theorem registerOperands_of_kernelSoundness_multiply
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
  kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.rvRs1 =
      kernel.authenticatedTrace.stepComposition.twistBinding.registerLane.rs1 ∧
    kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.rvRs2 =
      kernel.authenticatedTrace.stepComposition.twistBinding.registerLane.rs2 :=
  registerOperands_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem activeWrite_of_kernelSoundness_multiply
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
  kernel.authenticatedTrace.stepComposition.decodedRow.preservesRd = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesAluToRd = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false :=
  activeWrite_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem authenticatedWriteback_of_activeMultiply_of_kernelSoundness
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
      kernel.authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext :=
  authenticatedWriteback_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem routedWriteback_of_activeMultiply_of_kernelSoundness
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
  kernel.authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext =
      kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  routedWriteback_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem authenticatedRoutedWriteback_of_activeMultiply_of_kernelSoundness
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
      kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  authenticatedRoutedWriteback_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem encodedAluOut_of_activeMultiply_of_kernelSoundness
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
      kernel.authenticatedTrace.stepComposition.executionRow.lane.aluOut =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluOut_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem encodedAluResult_of_activeMultiply_of_kernelSoundness
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
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem authenticatedEncodedAluOut_of_activeMultiply_of_kernelSoundness
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
        kernel.authenticatedTrace.stepComposition.executionRow.lane.aluOut :=
  authenticatedEncodedAluOut_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem authenticatedEncodedAluResult_of_activeMultiply_of_kernelSoundness
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
        kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem sequenceCorrect_of_multiply_of_kernelSoundness
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
  {_opcode : MultiplyOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).multiplySequenceProof.sequence
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).multiplySequenceProof.touchedState
    kernel.authenticatedTrace.stepComposition.rowAssertions
    kernel.authenticatedTrace.stepComposition.committedResult
    kernel.authenticatedTrace.stepComposition.isaResult
    kernel.authenticatedTrace.stepComposition.preservedState :=
  sequenceCorrect_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem sequenceDeterministic_of_multiply_of_kernelSoundness
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
  {_opcode : MultiplyOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.multiplyOpcode = _opcode) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).multiplySequenceProof.sequence
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).multiplySequenceProof.touchedState
    kernel.authenticatedTrace.stepComposition.rowAssertions
    kernel.authenticatedTrace.stepComposition.committedResult :=
  sequenceDeterministic_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem flags_of_exactKernelBoundaries_multiply
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
  (hOpcode : boundaries.trace.stepComposition.multiplyOpcode = opcode) :
  boundaries.trace.stepComposition.decodedRow.isJal = false ∧
    boundaries.trace.stepComposition.decodedRow.isJalr = false ∧
    boundaries.trace.stepComposition.decodedRow.isBranch = false ∧
    boundaries.trace.stepComposition.decodedRow.isLoad = false ∧
    boundaries.trace.stepComposition.decodedRow.isStore = false ∧
    boundaries.trace.stepComposition.decodedRow.isDiv = false ∧
    boundaries.trace.stepComposition.decodedRow.isRem = false ∧
    boundaries.trace.stepComposition.decodedRow.isMul = true ∧
    boundaries.trace.stepComposition.decodedRow.usesRs2 = true ∧
    boundaries.trace.stepComposition.decodedRow.writesMemToRd = false ∧
    boundaries.trace.stepComposition.decodedRow.isWOp = opcode.isWOp ∧
    boundaries.trace.stepComposition.decodedRow.aluOp =
      boundaries.trace.stepComposition.multiplyAluOps.forOpcode opcode := by
  simpa using
    flags_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem x0WritePreserved_of_exactKernelBoundaries_multiply
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
  (hRd : boundaries.trace.stepComposition.decodedRow.rd = boundaries.trace.stepComposition.x0) :
  boundaries.trace.stepComposition.decodedRow.preservesRd = true ∧
    boundaries.trace.stepComposition.decodedRow.writesAluToRd = false ∧
    boundaries.trace.stepComposition.decodedRow.writesMemToRd = false := by
  simpa using
    x0WritePreserved_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hRd

theorem registerOperands_of_exactKernelBoundaries_multiply
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
      BridgeBinding) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.rvRs1 =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerLane.rs1 ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.rvRs2 =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerLane.rs2 := by
  exact
    registerOperands_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)

theorem activeWrite_of_exactKernelBoundaries_multiply
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.preservesRd =
      false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesAluToRd =
      true ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesMemToRd =
      false := by
  exact
    activeWrite_of_kernelSoundness_multiply
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedWriteback_of_activeMultiply_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext := by
  exact
    authenticatedWriteback_of_activeMultiply_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem routedWriteback_of_activeMultiply_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    routedWriteback_of_activeMultiply_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedRoutedWriteback_of_activeMultiply_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    authenticatedRoutedWriteback_of_activeMultiply_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem encodedAluOut_of_activeMultiply_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.lane.aluOut =
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluOut_of_activeMultiply_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem encodedAluResult_of_activeMultiply_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluResult_of_activeMultiply_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedEncodedAluOut_of_activeMultiply_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
        (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.lane.aluOut := by
  exact
    authenticatedEncodedAluOut_of_activeMultiply_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedEncodedAluResult_of_activeMultiply_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.multiplyOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
        (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult := by
  exact
    authenticatedEncodedAluResult_of_activeMultiply_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
