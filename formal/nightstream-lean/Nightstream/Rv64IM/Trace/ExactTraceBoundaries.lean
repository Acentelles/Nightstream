import Nightstream.Rv64IM.Trace.AuthenticatedTrace

/-!
Owns the exact-boundary constructor path into the RV64IM authenticated trace
surface. This file packages one exact family of Stage 1/2/3 trace-local
boundaries and proves that they assemble into the canonical
`AuthenticatedChunkTrace`; it does not re-own stage-local semantics.
-/

namespace Nightstream.Rv64IM

structure ExactTraceBoundaries
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _) [OfNat Limb 0] where
  stepComposition :
    StepCompositionProofPackage
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
  chunkInput :
    ChunkInput
      (ArchitecturalState Pc RegIdx RamAddr Word)
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
  mainLane :
    MainLaneTraceBoundaryProofPackage
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      (PreparedStepView Pc)
  traceLink :
    TraceLinkBoundaryProofPackage
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
  temporal :
    TemporalConsistencyProofPackage
      (ArchitecturalState Pc RegIdx RamAddr Word)
      Pc
      RegIdx
      RamAddr
      Word
      RegisterTimeline
      RamTimeline
      Unit
  stage2Closure :
    Stage2TemporalClosureProofPackage
      (ArchitecturalState Pc RegIdx RamAddr Word)
      RegisterTimeline
      RamTimeline
      Unit
  stage3Refinement :
    Stage3RefinementPackage
      Pc
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      PreparedStep
  executionRowsMatch :
    stepComposition.execution.rows = chunkInput.rows
  executionRowsLength :
    stepComposition.execution.rows.length = chunkInput.semanticRows
  preparedStepExport :
    stepComposition.execution.preparedSteps = mainLane.preparedSteps
  mainLaneRowsMatch :
    mainLane.rows = chunkInput.rows
  traceRowsMatch :
    traceLink.rows = chunkInput.rows
  stage2MatchesTemporal :
    stage2Closure = temporal.stage2

def authenticatedChunkTrace_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
    PreparedStep :=
  { stepComposition := boundaries.stepComposition
    chunkInput := boundaries.chunkInput
    mainLane := boundaries.mainLane
    traceLink := boundaries.traceLink
    temporal := boundaries.temporal
    stage2Closure := boundaries.stage2Closure
    stage3Refinement := boundaries.stage3Refinement
    executionRowsMatch := boundaries.executionRowsMatch
    executionRowsLength := boundaries.executionRowsLength
    preparedStepExport := boundaries.preparedStepExport
    mainLaneRowsMatch := boundaries.mainLaneRowsMatch
    traceRowsMatch := boundaries.traceRowsMatch
    stage2MatchesTemporal := boundaries.stage2MatchesTemporal }

theorem executionCorrect_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  ExecutionCorrect
    boundaries.stepComposition.execution.initialState
    boundaries.stepComposition.execution.finalState
    boundaries.stepComposition.execution.rows
    boundaries.stepComposition.execution.preparedSteps
    boundaries.stepComposition.execution.boundary
    boundaries.stepComposition.execution.entrypoint
    boundaries.stepComposition.execution.successors :=
  authenticatedChunkTrace_executionCorrect
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem executionCorrect_on_exactPrefix_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  ExecutionCorrect
    boundaries.stepComposition.execution.initialState
    boundaries.stepComposition.execution.finalState
    boundaries.chunkInput.rows
    boundaries.mainLane.preparedSteps
    boundaries.stepComposition.execution.boundary
    boundaries.stepComposition.execution.entrypoint
    boundaries.stepComposition.execution.successors :=
  authenticatedChunkTrace_executionCorrect_on_chunkInput
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem traceLinkBoundary_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  TraceLinkBoundary
    boundaries.chunkInput.rows
    boundaries.chunkInput.semanticRows :=
  Nightstream.Rv64IM.traceLinkBoundary_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem preparedStepExportBound_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  PreparedStepExportBound
    boundaries.chunkInput.rows
    boundaries.mainLane.preparedSteps :=
  preparedStepExportBound_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem adjacentStateClosed_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  AdjacentStateClosed
    (ArchitecturalState Pc RegIdx RamAddr Word)
    boundaries.stage2Closure.preState
    boundaries.stage2Closure.postState
    boundaries.stage2Closure.semanticRows :=
  authenticatedChunkTrace_adjacentStateClosed
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem pcAdjacentBridge_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  PcAdjacentBridge
    Pc
    boundaries.temporal.pcBridge.postPc
    boundaries.temporal.pcBridge.prePc
    boundaries.temporal.pcBridge.semanticRows :=
  Nightstream.Rv64IM.pcAdjacentBridge_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def canonicalOpcodeProofs_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  CanonicalOpcodeProofs
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    boundaries.stepComposition.opcodeProofs :=
  canonicalOpcodeProofs_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

end Nightstream.Rv64IM
