import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.NarrowMemoryOpcodeSemantics

/-!
Owns lifting of exact narrow-memory opcode consequences through RV64IM kernel
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

theorem flags_of_kernelSoundness_narrowMemory
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
  {widths : NarrowMemoryWidths MemWidth}
  {opcode : NarrowMemoryOpcode}
  (hOpcode : NarrowMemoryOpcodeBound widths kernel.authenticatedTrace.stepComposition.decodedRow opcode) :
  kernel.authenticatedTrace.stepComposition.decodedRow.isLoad = opcode.isLoad ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.isStore = opcode.isStore ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.writesAluToRd = false ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.memWidth = widths.forOpcode opcode ∧
    kernel.authenticatedTrace.stepComposition.decodedRow.memUnsigned = opcode.memUnsigned :=
  flags_of_narrowMemoryOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem x0WritePreserved_of_kernelSoundness_narrowMemory
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
  x0WritePreserved_of_narrowMemoryOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hRd

theorem sequenceCorrect_of_narrowMemory_of_kernelSoundness
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
  {widths : NarrowMemoryWidths MemWidth}
  {_opcode : NarrowMemoryOpcode}
  (hOpcode :
    NarrowMemoryOpcodeBound widths kernel.authenticatedTrace.stepComposition.decodedRow _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).narrowMemorySequenceProof.sequence
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel).narrowMemorySequenceProof.touchedState
    kernel.authenticatedTrace.stepComposition.rowAssertions
    kernel.authenticatedTrace.stepComposition.committedResult
    kernel.authenticatedTrace.stepComposition.isaResult
    kernel.authenticatedTrace.stepComposition.preservedState :=
  sequenceCorrect_of_narrowMemoryOpcodeSemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)
    hOpcode

theorem flags_of_exactKernelBoundaries_narrowMemory
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
  {widths : NarrowMemoryWidths MemWidth}
  {opcode : NarrowMemoryOpcode}
  (hOpcode :
    NarrowMemoryOpcodeBound
      widths
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow
      opcode) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isLoad =
      opcode.isLoad ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isStore =
      opcode.isStore ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.usesRs2 =
      opcode.usesRs2 ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.writesAluToRd =
      false ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.memWidth =
      widths.forOpcode opcode ∧
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.memUnsigned =
      opcode.memUnsigned := by
  exact
    flags_of_kernelSoundness_narrowMemory
      (kernelSoundness_of_exactBoundaries boundaries)
      hOpcode

theorem x0WritePreserved_of_exactKernelBoundaries_narrowMemory
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
    x0WritePreserved_of_kernelSoundness_narrowMemory
      (kernelSoundness_of_exactBoundaries boundaries)
      hRd

end

end Nightstream.Rv64IM
