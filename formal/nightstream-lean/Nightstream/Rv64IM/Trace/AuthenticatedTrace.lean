import Nightstream.Rv64IM.Execution.StepComposition
import Nightstream.Rv64IM.Trace.ChunkInput
import Nightstream.Rv64IM.Trace.MainLaneTraceBoundary
import Nightstream.Rv64IM.Trace.RegisterTimeline
import Nightstream.Rv64IM.Trace.RamTimeline
import Nightstream.Rv64IM.Trace.TemporalConsistency
import Nightstream.Rv64IM.Trace.TraceLinkBoundary
import Nightstream.Rv64IM.Stage3.Stage3Refinement
import Nightstream.Rv64IM.Execution.OpcodeClassExtractors

namespace Nightstream.Rv64IM

structure AuthenticatedChunkTrace
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

theorem authenticatedChunkTrace_executionCorrect
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  ExecutionCorrect
    trace.stepComposition.execution.initialState
    trace.stepComposition.execution.finalState
    trace.stepComposition.execution.rows
    trace.stepComposition.execution.preparedSteps
    trace.stepComposition.execution.boundary
    trace.stepComposition.execution.entrypoint
    trace.stepComposition.execution.successors :=
  trace.stepComposition.execution.correct

theorem authenticatedChunkTrace_executionCorrect_on_chunkInput
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  ExecutionCorrect
    trace.stepComposition.execution.initialState
    trace.stepComposition.execution.finalState
    trace.chunkInput.rows
    trace.mainLane.preparedSteps
    trace.stepComposition.execution.boundary
    trace.stepComposition.execution.entrypoint
    trace.stepComposition.execution.successors := by
  simpa [trace.executionRowsMatch, trace.preparedStepExport] using
    authenticatedChunkTrace_executionCorrect trace

theorem mainLaneSemanticRows_eq_chunkInput_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  trace.mainLane.semanticRows = trace.chunkInput.semanticRows := by
  calc
    trace.mainLane.semanticRows = trace.mainLane.rows.length := by
      symm
      exact mainLaneTraceBoundary_rowsLength trace.mainLane
    _ = trace.chunkInput.rows.length := by
      simp [trace.mainLaneRowsMatch]
    _ = trace.chunkInput.semanticRows := by
      simpa [trace.executionRowsMatch] using trace.executionRowsLength

theorem traceLinkSemanticRows_eq_chunkInput_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  trace.traceLink.semanticRows = trace.chunkInput.semanticRows := by
  calc
    trace.traceLink.semanticRows = trace.traceLink.rows.length := by
      symm
      exact traceLinkBoundary_rowsLength trace.traceLink
    _ = trace.chunkInput.rows.length := by
      simp [trace.traceRowsMatch]
    _ = trace.chunkInput.semanticRows := by
      simpa [trace.executionRowsMatch] using trace.executionRowsLength

theorem mainLaneTraceBoundary_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  MainLaneTraceBoundary
    trace.chunkInput.rows
    trace.mainLane.preparedSteps
    trace.chunkInput.semanticRows := by
  have hSemanticRowsEq :
      trace.mainLane.semanticRows = trace.chunkInput.semanticRows :=
    mainLaneSemanticRows_eq_chunkInput_of_authenticatedChunkTrace trace
  simpa [trace.mainLaneRowsMatch, hSemanticRowsEq] using trace.mainLane.boundary

theorem traceLinkBoundary_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  TraceLinkBoundary trace.chunkInput.rows trace.chunkInput.semanticRows := by
  have hSemanticRowsEq :
      trace.traceLink.semanticRows = trace.chunkInput.semanticRows :=
    traceLinkSemanticRows_eq_chunkInput_of_authenticatedChunkTrace trace
  simpa [trace.traceRowsMatch, hSemanticRowsEq] using trace.traceLink.bound

theorem preparedStepExportBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  PreparedStepExportBound trace.chunkInput.rows trace.mainLane.preparedSteps :=
  preparedStepExportBound_of_executionCorrect
    (authenticatedChunkTrace_executionCorrect_on_chunkInput trace)

theorem expandedRowSequenceBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  ExpandedRowSequenceBound trace.chunkInput.rows :=
  expandedRowSequenceBound_of_executionCorrect
    (authenticatedChunkTrace_executionCorrect_on_chunkInput trace)

theorem expandedBytecodeExecutionBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  ExpandedBytecodeExecutionBound
    trace.stepComposition.execution.entrypoint
    trace.stepComposition.execution.successors
    trace.chunkInput.rows :=
  expandedBytecodeExecutionBound_of_executionCorrect
    (authenticatedChunkTrace_executionCorrect_on_chunkInput trace)

theorem fullHaltedExecutionClaim_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  FullHaltedExecutionClaim
    trace.chunkInput.rows
    (fun row => ExpandedRow.terminates row = true) :=
  fullHaltedExecutionClaim_of_executionCorrect
    (authenticatedChunkTrace_executionCorrect_on_chunkInput trace)

theorem authenticatedChunkTrace_adjacentStateClosed
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  AdjacentStateClosed
    (ArchitecturalState Pc RegIdx RamAddr Word)
    trace.stage2Closure.preState
    trace.stage2Closure.postState
    trace.stage2Closure.semanticRows :=
  trace.stage2Closure.adjacentClosed

theorem pcAdjacentBridge_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  PcAdjacentBridge
    Pc
    trace.temporal.pcBridge.postPc
    trace.temporal.pcBridge.prePc
    trace.temporal.pcBridge.semanticRows :=
  pcAdjacentBridge_of_temporalConsistency trace.temporal

theorem prePc_eq_stage2PreStatePc_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  {j : Nat}
  (h : j < trace.stage2Closure.semanticRows) :
  trace.temporal.pcBridge.prePc j =
    trace.temporal.pcOf (trace.stage2Closure.preState j) := by
  have hTemporal : j < trace.temporal.stage2.semanticRows := by
    simpa [trace.stage2MatchesTemporal] using h
  simpa [trace.stage2MatchesTemporal] using
    prePc_eq_stage2PreStatePc_of_temporalConsistency trace.temporal hTemporal

theorem postPc_eq_stage2PostStatePc_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  {j : Nat}
  (h : j < trace.stage2Closure.semanticRows) :
  trace.temporal.pcBridge.postPc j =
    trace.temporal.pcOf (trace.stage2Closure.postState j) := by
  have hTemporal : j < trace.temporal.stage2.semanticRows := by
    simpa [trace.stage2MatchesTemporal] using h
  simpa [trace.stage2MatchesTemporal] using
    postPc_eq_stage2PostStatePc_of_temporalConsistency trace.temporal hTemporal

theorem registerTimelineBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  RegisterTimelineBound
    trace.temporal.registers.timeline
    trace.temporal.registers.preState
    trace.temporal.registers.postState
    trace.temporal.registers.semanticRows :=
  registerTimelineBound_of_temporalConsistency trace.temporal

theorem ramTimelineBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  RamTimelineBound
    trace.temporal.ram.timeline
    trace.temporal.ram.preState
    trace.temporal.ram.postState
    trace.temporal.ram.semanticRows :=
  ramTimelineBound_of_temporalConsistency trace.temporal

theorem stage1LinkageBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  Stage1LinkageBound
    trace.stepComposition.executionRow.row
    trace.stepComposition.executionRow.lane
    trace.stepComposition.executionRow.handoff
    trace.stepComposition.executionRow.results :=
  stage1LinkageBound_of_stepComposition trace.stepComposition

def twistConcreteBinding_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  TwistConcreteBindingProofPackage Limb :=
  twistConcreteBinding_of_stepComposition trace.stepComposition

theorem stage2LinkageBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  Stage2LinkageBound
    trace.stepComposition.twistBinding.registerLane
    trace.stepComposition.twistBinding.registerTwist
    trace.stepComposition.twistBinding.ramLane
    trace.stepComposition.twistBinding.ramTwist :=
  stage2LinkageBound_of_stepComposition trace.stepComposition

theorem registerLinkageBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  RegisterLinkageBound
    trace.stepComposition.twistBinding.registerLane
    trace.stepComposition.twistBinding.registerTwist :=
  registerLinkageBound_of_stepComposition trace.stepComposition

theorem ramLinkageBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  RamLinkageBound
    trace.stepComposition.twistBinding.ramLane
    trace.stepComposition.twistBinding.ramTwist :=
  ramLinkageBound_of_stepComposition trace.stepComposition

theorem registerWriteValue_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  (hWrite : trace.stepComposition.twistBinding.registerLane.writesRd = true) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.twistBinding.registerLane.rdNext :=
  registerWriteValue_of_stepComposition trace.stepComposition hWrite

theorem ramLoadMemVal_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  (hLoad : trace.stepComposition.twistBinding.ramLane.isLoad = true) :
  trace.stepComposition.twistBinding.ramLane.memVal =
    trace.stepComposition.twistBinding.ramTwist.rvRamWord :=
  ramLoadMemVal_of_stepComposition trace.stepComposition hLoad

theorem ramStorePayload_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  (hStore : trace.stepComposition.twistBinding.ramLane.isStore = true) :
  trace.stepComposition.twistBinding.ramLane.memVal =
      trace.stepComposition.twistBinding.ramLane.rs2 ∧
    trace.stepComposition.twistBinding.ramTwist.wvRamWord =
      trace.stepComposition.twistBinding.ramLane.memVal :=
  ramStorePayload_of_stepComposition trace.stepComposition hStore

theorem ramInactiveMemValZero_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  (hLoad : trace.stepComposition.twistBinding.ramLane.isLoad = false)
  (hStore : trace.stepComposition.twistBinding.ramLane.isStore = false) :
  trace.stepComposition.twistBinding.ramLane.memVal = zeroLimbPair :=
  ramInactiveMemValZero_of_stepComposition trace.stepComposition hLoad hStore

theorem takenTargetAlignmentBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  TakenTargetAlignmentBound
    trace.stepComposition.executionRow.wordToNat
    trace.stepComposition.executionRow.lane :=
  takenTargetAlignmentBound_of_stepComposition trace.stepComposition

theorem mulUNoOverflowBound_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  MulUNoOverflowBound
    trace.stepComposition.executionRow.mulHigh
    trace.stepComposition.executionRow.zeroWord
    trace.stepComposition.executionRow.divRemQuotient
    trace.stepComposition.executionRow.divRemDivisor :=
  mulUNoOverflowBound_of_stepComposition trace.stepComposition

theorem temporaryRegisterHygiene_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  TemporaryRegisterHygiene
    trace.stepComposition.temporaryHygiene.sequence
    trace.stepComposition.temporaryHygiene.isTempRegister
    trace.stepComposition.temporaryHygiene.readsRegister
    trace.stepComposition.temporaryHygiene.writesRegister :=
  temporaryRegisterHygiene_of_stepComposition trace.stepComposition

theorem mulUNoOverflow_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  MulUNoOverflow
    trace.stepComposition.unsignedDivRem.quotient
    trace.stepComposition.unsignedDivRem.divisor :=
  mulUNoOverflow_of_stepComposition trace.stepComposition

theorem unsignedDivRemSpec_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  UnsignedDivRemSpec
    trace.stepComposition.unsignedDivRem.dividend
    trace.stepComposition.unsignedDivRem.quotient
    trace.stepComposition.unsignedDivRem.divisor
    trace.stepComposition.unsignedDivRem.remainder :=
  unsignedDivRemSpec_of_stepComposition trace.stepComposition

theorem unsignedDivRemDeterministic_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  {quotient' remainder' : Nat}
  (hSpec :
    UnsignedDivRemSpec
      trace.stepComposition.unsignedDivRem.dividend
      quotient'
      trace.stepComposition.unsignedDivRem.divisor
      remainder') :
  quotient' = trace.stepComposition.unsignedDivRem.quotient ∧
    remainder' = trace.stepComposition.unsignedDivRem.remainder :=
  unsignedDivRemDeterministic_of_stepComposition trace.stepComposition hSpec

theorem changeDivisorCorrect_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  ChangeDivisorCorrect
    trace.stepComposition.signedDivRem.dividend
    trace.stepComposition.signedDivRem.divisor
    trace.stepComposition.signedDivRem.changedDivisor :=
  changeDivisorCorrect_of_stepComposition trace.stepComposition

theorem remainderFromDividendSign_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  RemainderFromDividendSign
    trace.stepComposition.signedDivRem.dividend
    trace.stepComposition.signedDivRem.remainderAbs
    trace.stepComposition.signedDivRem.remainderSigned :=
  remainderFromDividendSign_of_stepComposition trace.stepComposition

theorem signedDivRemSpec_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  SignedDivRemSpec
    trace.stepComposition.signedDivRem.dividend
    trace.stepComposition.signedDivRem.quotient
    trace.stepComposition.signedDivRem.divisor
    trace.stepComposition.signedDivRem.remainderSigned :=
  signedDivRemSpec_of_stepComposition trace.stepComposition

noncomputable def canonicalOpcodeProofs_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
  CanonicalOpcodeProofs
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    trace.stepComposition.opcodeProofs :=
  canonicalOpcodeProofs_of_stepComposition trace.stepComposition

end Nightstream.Rv64IM
