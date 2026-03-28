import Nightstream.Rv64IM.Kernel.OpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.NarrowMemoryHelperResultSemantics

/-!
Owns lifting of exact narrow-memory helper-result consequences through RV64IM
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

noncomputable def exactNarrowMemoryHelperResultSemantics_of_kernelSoundness
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
  ExactNarrowMemoryHelperResultSemantics
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
    kernel.authenticatedTrace.stepComposition
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel) :=
  exactNarrowMemoryHelperResultSemantics_of_exactOpcodeFamilySemantics
    (exactOpcodeFamilySemantics_of_kernelSoundness kernel)

theorem loadExtractHelperResult_of_kernelSoundness_narrowMemory
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
  (hLoad : kernel.authenticatedTrace.stepComposition.decodedRow.isLoad = true) :
  kernel.authenticatedTrace.stepComposition.executionRow.wordToNat
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    extractExtend
      (kernel.authenticatedTrace.stepComposition.executionRow.wordToNat
        (kernel.authenticatedTrace.stepComposition.limbPairToWord
          kernel.authenticatedTrace.stepComposition.twistBinding.ramTwist.rvRamWord))
      kernel.authenticatedTrace.stepComposition.narrowMemoryExtract.off
      kernel.authenticatedTrace.stepComposition.narrowMemoryExtract.width
      kernel.authenticatedTrace.stepComposition.decodedRow.memUnsigned :=
  loadExtractHelperResult_of_authenticatedChunkTrace_narrowMemory
    kernel.authenticatedTrace
    hLoad

theorem storeBlendHelperResult_of_kernelSoundness_narrowMemory
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
  (hStore : kernel.authenticatedTrace.stepComposition.decodedRow.isStore = true) :
  kernel.authenticatedTrace.stepComposition.executionRow.wordToNat
      kernel.authenticatedTrace.stepComposition.executionRow.results.aluResult =
    blend
      (kernel.authenticatedTrace.stepComposition.executionRow.wordToNat
        (kernel.authenticatedTrace.stepComposition.limbPairToWord
          kernel.authenticatedTrace.stepComposition.twistBinding.ramTwist.rvRamWord))
      (kernel.authenticatedTrace.stepComposition.executionRow.wordToNat
        (kernel.authenticatedTrace.stepComposition.limbPairToWord
          kernel.authenticatedTrace.stepComposition.twistBinding.registerTwist.rvRs2))
      kernel.authenticatedTrace.stepComposition.narrowMemoryBlend.off
      kernel.authenticatedTrace.stepComposition.narrowMemoryBlend.width :=
  storeBlendHelperResult_of_authenticatedChunkTrace_narrowMemory
    kernel.authenticatedTrace
    hStore

noncomputable def exactNarrowMemoryHelperResultSemantics_of_exactKernelBoundaries
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
  ExactNarrowMemoryHelperResultSemantics
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
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition
    (exactOpcodeFamilySemantics_of_kernelSoundness
      (kernelSoundness_of_exactBoundaries boundaries)) :=
  exactNarrowMemoryHelperResultSemantics_of_kernelSoundness
    (kernelSoundness_of_exactBoundaries boundaries)

theorem loadExtractHelperResult_of_exactKernelBoundaries_narrowMemory
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
  (hLoad :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isLoad = true) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.wordToNat
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    extractExtend
      ((kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.wordToNat
        ((kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
          (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.ramTwist.rvRamWord))
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.narrowMemoryExtract.off
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.narrowMemoryExtract.width
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.memUnsigned := by
  exact
    loadExtractHelperResult_of_kernelSoundness_narrowMemory
      (kernelSoundness_of_exactBoundaries boundaries)
      hLoad

theorem storeBlendHelperResult_of_exactKernelBoundaries_narrowMemory
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
  (hStore :
    (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.decodedRow.isStore = true) :
  (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.wordToNat
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.results.aluResult =
    blend
      ((kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.wordToNat
        ((kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
          (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.ramTwist.rvRamWord))
      ((kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.executionRow.wordToNat
        ((kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.limbPairToWord
          (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.twistBinding.registerTwist.rvRs2))
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.narrowMemoryBlend.off
      (kernelSoundness_of_exactBoundaries boundaries).authenticatedTrace.stepComposition.narrowMemoryBlend.width := by
  exact
    storeBlendHelperResult_of_kernelSoundness_narrowMemory
      (kernelSoundness_of_exactBoundaries boundaries)
      hStore

end

end Nightstream.Rv64IM
