import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.ExactNarrowMemoryHelperResultSemantics

/-!
Owns lifting of exact narrow-memory helper-result consequences through the
authenticated trace and exact trace-boundary surfaces.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]

noncomputable def exactNarrowMemoryHelperResultSemantics_of_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep) :
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
    trace.stepComposition
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) :=
  exactNarrowMemoryHelperResultSemantics_of_exactOpcodeFamilySemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem loadExtractHelperResult_of_authenticatedChunkTrace_narrowMemory
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  (hLoad : trace.stepComposition.decodedRow.isLoad = true) :
  trace.stepComposition.executionRow.wordToNat
      trace.stepComposition.executionRow.results.aluResult =
    extractExtend
      (trace.stepComposition.executionRow.wordToNat
        (trace.stepComposition.limbPairToWord
          trace.stepComposition.twistBinding.ramTwist.rvRamWord))
      trace.stepComposition.narrowMemoryExtract.off
      trace.stepComposition.narrowMemoryExtract.width
      trace.stepComposition.decodedRow.memUnsigned :=
  loadExtractHelperResult_of_exactNarrowMemoryHelperResultSemantics
    (exactNarrowMemoryHelperResultSemantics_of_authenticatedChunkTrace trace)
    hLoad

theorem storeBlendHelperResult_of_authenticatedChunkTrace_narrowMemory
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  (hStore : trace.stepComposition.decodedRow.isStore = true) :
  trace.stepComposition.executionRow.wordToNat
      trace.stepComposition.executionRow.results.aluResult =
    blend
      (trace.stepComposition.executionRow.wordToNat
        (trace.stepComposition.limbPairToWord
          trace.stepComposition.twistBinding.ramTwist.rvRamWord))
      (trace.stepComposition.executionRow.wordToNat
        (trace.stepComposition.limbPairToWord
          trace.stepComposition.twistBinding.registerTwist.rvRs2))
      trace.stepComposition.narrowMemoryBlend.off
      trace.stepComposition.narrowMemoryBlend.width :=
  storeBlendHelperResult_of_exactNarrowMemoryHelperResultSemantics
    (exactNarrowMemoryHelperResultSemantics_of_authenticatedChunkTrace trace)
    hStore

noncomputable def exactNarrowMemoryHelperResultSemantics_of_exactBoundaries
  (boundaries :
    ExactTraceBoundaries
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
      PreparedStep) :
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
    boundaries.stepComposition
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)) :=
  exactNarrowMemoryHelperResultSemantics_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem loadExtractHelperResult_of_exactBoundaries_narrowMemory
  (boundaries :
    ExactTraceBoundaries
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
      PreparedStep)
  (hLoad : boundaries.stepComposition.decodedRow.isLoad = true) :
  boundaries.stepComposition.executionRow.wordToNat
      boundaries.stepComposition.executionRow.results.aluResult =
    extractExtend
      (boundaries.stepComposition.executionRow.wordToNat
        (boundaries.stepComposition.limbPairToWord
          boundaries.stepComposition.twistBinding.ramTwist.rvRamWord))
      boundaries.stepComposition.narrowMemoryExtract.off
      boundaries.stepComposition.narrowMemoryExtract.width
      boundaries.stepComposition.decodedRow.memUnsigned := by
  exact
    loadExtractHelperResult_of_authenticatedChunkTrace_narrowMemory
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hLoad

theorem storeBlendHelperResult_of_exactBoundaries_narrowMemory
  (boundaries :
    ExactTraceBoundaries
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
      PreparedStep)
  (hStore : boundaries.stepComposition.decodedRow.isStore = true) :
  boundaries.stepComposition.executionRow.wordToNat
      boundaries.stepComposition.executionRow.results.aluResult =
    blend
      (boundaries.stepComposition.executionRow.wordToNat
        (boundaries.stepComposition.limbPairToWord
          boundaries.stepComposition.twistBinding.ramTwist.rvRamWord))
      (boundaries.stepComposition.executionRow.wordToNat
        (boundaries.stepComposition.limbPairToWord
          boundaries.stepComposition.twistBinding.registerTwist.rvRs2))
      boundaries.stepComposition.narrowMemoryBlend.off
      boundaries.stepComposition.narrowMemoryBlend.width := by
  exact
    storeBlendHelperResult_of_authenticatedChunkTrace_narrowMemory
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hStore

end

end Nightstream.Rv64IM
