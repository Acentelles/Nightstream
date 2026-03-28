import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.WordShiftOpcodeSemantics

/-!
Owns lifting of exact word/shift opcode consequences through RV64IM kernel
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

theorem opcodeBound_of_kernelSoundness_wordShift
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
  WordShiftOpcodeBound
    kernel.authenticatedTrace.stepComposition.wordShiftAluOps
    kernel.authenticatedTrace.stepComposition.decodedRow
    kernel.authenticatedTrace.stepComposition.wordShiftOpcode :=
  opcodeBound_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem flags_of_kernelSoundness_wordShift
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
  kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.aluOp =
      kernel.authenticatedTrace.stepComposition.wordShiftAluOps.forOpcode opcode :=
  flags_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem sraw_flags_of_kernelSoundness
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
  (hOpcode : kernel.authenticatedTrace.stepComposition.wordShiftOpcode = .sraw) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.usesRs2 = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.aluOp =
      kernel.authenticatedTrace.stepComposition.wordShiftAluOps.sra :=
  sraw_flags_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem sraiw_flags_of_kernelSoundness
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
  (hOpcode : kernel.authenticatedTrace.stepComposition.wordShiftOpcode = .sraiw) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isWOp = true ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.usesRs2 = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.aluOp =
      kernel.authenticatedTrace.stepComposition.wordShiftAluOps.sra :=
  sraiw_flags_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem sequenceCorrect_of_wordShift_of_kernelSoundness
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
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).wordShiftSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).wordShiftSequenceProof.touchedState
    kernel.authenticatedTrace.stepComposition.rowAssertions
    kernel.authenticatedTrace.stepComposition.committedResult
    kernel.authenticatedTrace.stepComposition.isaResult
    kernel.authenticatedTrace.stepComposition.preservedState :=
  sequenceCorrect_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem sequenceDeterministic_of_wordShift_of_kernelSoundness
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
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).wordShiftSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).wordShiftSequenceProof.touchedState
    kernel.authenticatedTrace.stepComposition.rowAssertions
    kernel.authenticatedTrace.stepComposition.committedResult :=
  sequenceDeterministic_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem sraw_flags_of_exactKernelBoundaries
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordShiftOpcode =
      WordShiftOpcode.sraw) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isWOp = true ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.usesRs2 = true ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.aluOp =
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.wordShiftAluOps.sra := by
  exact
    sraw_flags_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem sequenceCorrect_of_wordShift_of_exactKernelBoundaries
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
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).wordShiftSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_exactKernelBoundaries boundaries).wordShiftSequenceProof.touchedState
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.rowAssertions
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.committedResult
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.isaResult
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.preservedState := by
  exact
    sequenceCorrect_of_wordShift_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)

end

end Nightstream.Rv64IM
