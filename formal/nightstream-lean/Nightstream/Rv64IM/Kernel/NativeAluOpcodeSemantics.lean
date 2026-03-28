import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.NativeAluOpcodeSemantics

/-!
Owns lifting of exact native-ALU opcode consequences through RV64IM kernel
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

theorem opcodeBound_of_kernelSoundness_nativeAlu
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
  NativeAluOpcodeBound
    kernel.authenticatedTrace.stepComposition.nativeAluOps
    kernel.authenticatedTrace.stepComposition.decodedRow
    kernel.authenticatedTrace.stepComposition.nativeAluOpcode :=
  opcodeBound_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem flags_of_kernelSoundness_nativeAlu
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
  kernel.authenticatedTrace.stepComposition.decodedRow.isJal = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isJalr = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isBranch = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isLoad = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isStore = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isMul = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isDiv = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isRem = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.aluOp =
      kernel.authenticatedTrace.stepComposition.nativeAluOps.forOpcode opcode :=
  flags_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem x0WritePreserved_of_kernelSoundness_nativeAlu
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
  x0WritePreserved_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hRd

theorem registerOperands_of_kernelSoundness_nativeAlu
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
  registerOperands_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem nonX0WriteFacts_of_kernelSoundness_nativeAlu
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
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  if opcode.writesArchitecturalRd then
    kernel.authenticatedTrace.stepComposition.decodedRow.preservesRd = false ∧
      kernel.authenticatedTrace.stepComposition.decodedRow.writesAluToRd = true ∧
      kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false
  else
    kernel.authenticatedTrace.stepComposition.decodedRow.preservesRd = true ∧
      kernel.authenticatedTrace.stepComposition.decodedRow.writesAluToRd = false ∧
      kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false :=
  nonX0WriteFacts_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hRd

theorem activeWrite_of_kernelSoundness_nativeAlu
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
  kernel.authenticatedTrace.stepComposition.decodedRow.preservesRd = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesAluToRd = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false :=
  activeWrite_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem passiveWrite_of_kernelSoundness_nativeAlu
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
  (hWrites : opcode.writesArchitecturalRd = false)
  (hRd :
    kernel.authenticatedTrace.stepComposition.decodedRow.rd ≠
      kernel.authenticatedTrace.stepComposition.x0) :
  kernel.authenticatedTrace.stepComposition.decodedRow.preservesRd = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesAluToRd = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesMemToRd = false :=
  passiveWrite_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem authenticatedWriteback_of_activeNativeAlu_of_kernelSoundness
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
      kernel.authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext :=
  authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem routedWriteback_of_activeNativeAlu_of_kernelSoundness
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
  kernel.authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext =
      kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  routedWriteback_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem authenticatedRoutedWriteback_of_activeNativeAlu_of_kernelSoundness
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
      kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  authenticatedRoutedWriteback_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem encodedAluOut_of_activeNativeAlu_of_kernelSoundness
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
      kernel.authenticatedTrace.stepComposition.executionRow.lane.aluOut =
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluOut_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem encodedAluResult_of_activeNativeAlu_of_kernelSoundness
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
    kernel.authenticatedTrace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem authenticatedEncodedAluOut_of_activeNativeAlu_of_kernelSoundness
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
        kernel.authenticatedTrace.stepComposition.executionRow.lane.aluOut :=
  authenticatedEncodedAluOut_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem authenticatedEncodedAluResult_of_activeNativeAlu_of_kernelSoundness
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
        kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode
    hWrites
    hRd

theorem ecall_terminates_of_kernelSoundness
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
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = .ecall) :
  (canonicalOpcodeProofs_of_stepComposition kernel.authenticatedTrace.stepComposition).nativeAlu.semantics.boundary.terminates =
      true ∧
    (canonicalOpcodeProofs_of_stepComposition kernel.authenticatedTrace.stepComposition).nativeAlu.semantics.finalState.halted =
      true :=
  ecall_terminates_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem sequenceCorrect_of_nativeAlu_of_kernelSoundness
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
  {_opcode : NativeAluOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).nativeAluSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).nativeAluSequenceProof.touchedState
    kernel.authenticatedTrace.stepComposition.rowAssertions
    kernel.authenticatedTrace.stepComposition.committedResult
    kernel.authenticatedTrace.stepComposition.isaResult
    kernel.authenticatedTrace.stepComposition.preservedState :=
  sequenceCorrect_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem sequenceDeterministic_of_nativeAlu_of_kernelSoundness
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
  {_opcode : NativeAluOpcode}
  (hOpcode : kernel.authenticatedTrace.stepComposition.nativeAluOpcode = _opcode) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).nativeAluSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).nativeAluSequenceProof.touchedState
    kernel.authenticatedTrace.stepComposition.rowAssertions
    kernel.authenticatedTrace.stepComposition.committedResult :=
  sequenceDeterministic_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem flags_of_exactKernelBoundaries_nativeAlu
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isJal = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isJalr = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isBranch = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isLoad = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isStore = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isWOp = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isMul = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isDiv = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isRem = false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.usesRs2 =
      opcode.usesRs2 ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesMemToRd =
      false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.aluOp =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOps.forOpcode
        opcode := by
  exact
    flags_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem x0WritePreserved_of_exactKernelBoundaries_nativeAlu
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
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.preservesRd =
      true ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesAluToRd =
      false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesMemToRd =
      false := by
  exact
    x0WritePreserved_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hRd

theorem registerOperands_of_exactKernelBoundaries_nativeAlu
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
    registerOperands_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)

theorem nonX0WriteFacts_of_exactKernelBoundaries_nativeAlu
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  if opcode.writesArchitecturalRd then
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.preservesRd =
      false ∧
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesAluToRd =
        true ∧
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesMemToRd =
        false
  else
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.preservesRd =
      true ∧
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesAluToRd =
        false ∧
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesMemToRd =
        false := by
  exact
    nonX0WriteFacts_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem activeWrite_of_exactKernelBoundaries_nativeAlu
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
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
    activeWrite_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem passiveWrite_of_exactKernelBoundaries_nativeAlu
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = false)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.preservesRd =
      true ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesAluToRd =
      false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesMemToRd =
      false := by
  exact
    passiveWrite_of_kernelSoundness_nativeAlu
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedWriteback_of_activeNativeAlu_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext := by
  exact
    authenticatedWriteback_of_activeNativeAlu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem routedWriteback_of_activeNativeAlu_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerLane.rdNext =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    routedWriteback_of_activeNativeAlu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedRoutedWriteback_of_activeNativeAlu_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    authenticatedRoutedWriteback_of_activeNativeAlu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem encodedAluOut_of_activeNativeAlu_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.lane.aluOut =
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluOut_of_activeNativeAlu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem encodedAluResult_of_activeNativeAlu_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.aluWritebackValue := by
  exact
    encodedAluResult_of_activeNativeAlu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedEncodedAluOut_of_activeNativeAlu_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
        (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.lane.aluOut := by
  exact
    authenticatedEncodedAluOut_of_activeNativeAlu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedEncodedAluResult_of_activeNativeAlu_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.rd ≠
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.x0) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.wvReg =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordToLimbPair
        (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult := by
  exact
    authenticatedEncodedAluResult_of_activeNativeAlu_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem ecall_terminates_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.nativeAluOpcode =
      .ecall) :
  (canonicalOpcodeProofs_of_stepComposition
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition).nativeAlu.semantics.boundary.terminates =
      true ∧
    (canonicalOpcodeProofs_of_stepComposition
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition).nativeAlu.semantics.finalState.halted =
      true := by
  exact
    ecall_terminates_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
