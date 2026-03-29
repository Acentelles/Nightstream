import Nightstream.Rv64IM.Kernel.ExactKernelBoundaries

/-!
Owns the theorem-facing semantic closure extracted from RV64IM kernel
soundness. This file packages the execution, trace, Stage 2, and Stage 3
consequences that a kernel acceptance boundary must provide; it does not re-own
the kernel acceptance construction itself.
-/

namespace Nightstream.Rv64IM

structure KernelSemanticClosure
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _) [OfNat Limb 0]
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
      BridgeBinding) where
  executionCorrect :
    ExecutionCorrect
      kernel.authenticatedTrace.stepComposition.execution.initialState
      kernel.authenticatedTrace.stepComposition.execution.finalState
      kernel.authenticatedTrace.stepComposition.execution.rows
      kernel.authenticatedTrace.stepComposition.execution.preparedSteps
      kernel.authenticatedTrace.stepComposition.execution.boundary
      kernel.authenticatedTrace.stepComposition.execution.entrypoint
      kernel.authenticatedTrace.stepComposition.execution.successors
  mainLaneTraceBoundary :
    MainLaneTraceBoundary
      kernel.authenticatedTrace.chunkInput.rows
      kernel.authenticatedTrace.mainLane.preparedSteps
      kernel.authenticatedTrace.mainLane.chunks
      kernel.authenticatedTrace.chunkInput.semanticRows
      kernel.authenticatedTrace.mainLane.schedule
  traceLinkBoundary :
    TraceLinkBoundary
      kernel.authenticatedTrace.chunkInput.rows
      kernel.authenticatedTrace.chunkInput.semanticRows
  expandedBytecodeExecutionBound :
    ExpandedBytecodeExecutionBound
      kernel.authenticatedTrace.stepComposition.execution.entrypoint
      kernel.authenticatedTrace.stepComposition.execution.successors
      kernel.authenticatedTrace.chunkInput.rows
  preparedStepExportBound :
    PreparedStepExportBound
      kernel.authenticatedTrace.chunkInput.rows
      kernel.authenticatedTrace.mainLane.preparedSteps
  stage2AuthenticatedHistorySemantics :
    Stage2AuthenticatedHistorySemantics
      kernel.authenticatedTrace.temporal
      (twistConcreteBinding_of_authenticatedChunkTrace kernel.authenticatedTrace)
  registerTimelineBound :
    RegisterTimelineBound
      kernel.authenticatedTrace.temporal.registers.timeline
      kernel.authenticatedTrace.temporal.registers.preState
      kernel.authenticatedTrace.temporal.registers.postState
      kernel.authenticatedTrace.temporal.registers.semanticRows
  ramTimelineBound :
    RamTimelineBound
      kernel.authenticatedTrace.temporal.ram.timeline
      kernel.authenticatedTrace.temporal.ram.preState
      kernel.authenticatedTrace.temporal.ram.postState
      kernel.authenticatedTrace.temporal.ram.semanticRows
  stage3ContinuitySemantics :
    Stage3ContinuitySemantics kernel.authenticatedTrace.stage3Refinement
  stage3ExportSemantics :
    Stage3ExportSemantics kernel.authenticatedTrace.stage3Refinement
  pcAdjacentBridge :
    PcAdjacentBridge
      Pc
      kernel.authenticatedTrace.temporal.pcBridge.postPc
      kernel.authenticatedTrace.temporal.pcBridge.prePc
      kernel.authenticatedTrace.temporal.pcBridge.semanticRows
  activePrefixContinuity :
    ActivePrefixContinuity
      kernel.authenticatedTrace.stage3Refinement.stage3.postPc
      kernel.authenticatedTrace.stage3Refinement.stage3.prePc
      kernel.authenticatedTrace.stage3Refinement.stage3.semanticRows
  fullHaltedExecutionClaim :
    FullHaltedExecutionClaim
      kernel.authenticatedTrace.stage3Refinement.finalBoundary.sequence
      kernel.authenticatedTrace.stage3Refinement.finalBoundary.terminatingRow

def kernelSemanticClosure_of_kernelSoundness
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
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
  KernelSemanticClosure
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
    BridgeBinding
    kernel :=
  { executionCorrect := executionCorrect_of_kernelSoundness kernel
    mainLaneTraceBoundary := mainLaneTraceBoundary_of_kernelSoundness kernel
    traceLinkBoundary := traceLinkBoundary_of_kernelSoundness kernel
    expandedBytecodeExecutionBound := expandedBytecodeExecutionBound_of_kernelSoundness kernel
    preparedStepExportBound := preparedStepExportBound_on_authenticatedPrefix_of_kernelSoundness kernel
    stage2AuthenticatedHistorySemantics := stage2AuthenticatedHistorySemantics_of_kernelSoundness kernel
    registerTimelineBound := registerTimelineBound_of_kernelSoundness kernel
    ramTimelineBound := ramTimelineBound_of_kernelSoundness kernel
    stage3ContinuitySemantics := stage3ContinuitySemantics_of_kernelSoundness kernel
    stage3ExportSemantics := stage3ExportSemantics_of_kernelSoundness kernel
    pcAdjacentBridge := pcAdjacentBridge_of_kernelSoundness kernel
    activePrefixContinuity := activePrefixContinuity_of_kernelSoundness kernel
    fullHaltedExecutionClaim := fullHaltedExecutionClaim_of_kernelSoundness kernel }

def kernelSemanticClosure_of_exactKernelBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
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
  KernelSemanticClosure
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
    BridgeBinding
    (kernelSoundness_of_exactBoundaries boundaries) :=
  kernelSemanticClosure_of_kernelSoundness
    (kernelSoundness_of_exactBoundaries boundaries)

end Nightstream.Rv64IM
