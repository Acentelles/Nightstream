import Nightstream.Rv64IM.Kernel.KernelSoundness
import Nightstream.Rv64IM.Trace.ExactTraceBoundaries

/-!
Owns the exact-boundary constructor path into the RV64IM kernel soundness
surface. This file packages exact trace/kernel boundary objects and proves that
they assemble into the canonical `KernelSoundnessAccepted` and
`KernelSoundnessConclusion`; it does not re-own stage-local or trace-local
semantics.
-/

namespace Nightstream.Rv64IM

structure ExactKernelBoundaries
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _) [OfNat Limb 0] where
  programBinding :
    ProgramBindingProofPackage
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
  trace :
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
      PreparedStep
  root0Bindings : List Root0CommitmentBinding
  transcript : List TranscriptEvent
  transcriptSchedule :
    KernelTranscriptSchedule
      root0Bindings
      trace.mainLane.schedule
      trace.mainLane.preparedSteps.length
      trace.stage3Refinement.stage3.rowBindings.length
      transcript
  accounting : KernelSoundnessAccounting
  bridgeBindings :
    List
      (KernelBridgeBindingWitness
        Pc
        (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
        PreparedStep
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
        trace.stage3Refinement.stage3)
  bridgeTraceBound :
    KernelBridgeTraceBound
      trace.stage3Refinement.stage3
      bridgeBindings
  rowBindingCoverage :
    ∀ j,
      TranscriptEvent.rowBinding j ∈ transcript ↔
        j < trace.stage3Refinement.stage3.rowBindings.length

structure MinimalExactKernelInputs
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _) [OfNat Limb 0] where
  programBinding :
    ProgramBindingProofPackage
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
  trace :
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
      PreparedStep
  root0Bindings : List Root0CommitmentBinding
  root0BindingsConform : root0CommitmentBindingsConform root0Bindings
  accounting : KernelSoundnessAccounting
  bridgeBindings :
    List
      (KernelBridgeBindingWitness
        Pc
        (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
        PreparedStep
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
        trace.stage3Refinement.stage3)
  bridgeTraceBound :
    KernelBridgeTraceBound
      trace.stage3Refinement.stage3
      bridgeBindings

def kernelSoundnessAccepted_of_exactBoundaries
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
  KernelSoundnessAccepted
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
    BridgeBinding :=
  { programBinding := boundaries.programBinding
    authenticatedTrace := authenticatedChunkTrace_of_exactBoundaries boundaries.trace
    root0Bindings := boundaries.root0Bindings
    transcript := boundaries.transcript
    transcriptSchedule := boundaries.transcriptSchedule
    accounting := boundaries.accounting
    bridgeBindings := boundaries.bridgeBindings
    bridgeTraceBound := boundaries.bridgeTraceBound
    rowBindingCoverage := boundaries.rowBindingCoverage }

theorem rowBinding_mem_stage3RowBindingEvents_iff
  {exportedRows j : Nat} :
  TranscriptEvent.rowBinding j ∈ stage3RowBindingEvents exportedRows ↔
    j < exportedRows := by
  rw [stage3RowBindingEvents, List.mem_ofFn']
  constructor
  · intro hMem
    rcases hMem with ⟨idx, hIdx⟩
    cases idx with
    | mk val isLt =>
        cases hIdx
        exact isLt
  · intro hLt
    exact ⟨⟨j, hLt⟩, rfl⟩

theorem rowBinding_mem_transcriptEvents_iff
  (root0Bindings : List Root0CommitmentBinding)
  (schedule : Nightstream.FoldSchedule)
  (publicStepCount : Nat)
  {exportedRows j : Nat} :
  TranscriptEvent.rowBinding j ∈
      transcriptEvents root0Bindings schedule publicStepCount exportedRows ↔
    j < exportedRows := by
  simp [transcriptEvents, phase0Events, rootMainLaneEvents, stage1Events,
    stage2Events, stage3Events, stage3PrefixEvents,
    rowBinding_mem_stage3RowBindingEvents_iff,
    rowBinding_not_mem_rootChunkScheduleFrom]

def exactKernelBoundaries_of_minimalKernelInputs
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
  (programBinding :
    ProgramBindingProofPackage
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit)
  (trace :
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
  (root0Bindings : List Root0CommitmentBinding)
  (root0BindingsConform : root0CommitmentBindingsConform root0Bindings)
  (accounting : KernelSoundnessAccounting)
  (bridgeBindings :
    List
      (KernelBridgeBindingWitness
        Pc
        (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
        PreparedStep
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
        trace.stage3Refinement.stage3))
  (bridgeTraceBound :
    KernelBridgeTraceBound
      trace.stage3Refinement.stage3
      bridgeBindings) :
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
    BridgeBinding :=
  let transcript :=
    transcriptEvents
      root0Bindings
      trace.mainLane.schedule
      trace.mainLane.preparedSteps.length
      trace.stage3Refinement.stage3.rowBindings.length
  { programBinding := programBinding
  , trace := trace
  , root0Bindings := root0Bindings
  , transcript := transcript
  , transcriptSchedule := ⟨root0BindingsConform, mainLaneTraceBoundary_scheduleValid trace.mainLane, rfl⟩
  , accounting := accounting
  , bridgeBindings := bridgeBindings
  , bridgeTraceBound := bridgeTraceBound
  , rowBindingCoverage := by
      intro j
      simpa [transcript] using
        (rowBinding_mem_transcriptEvents_iff
          root0Bindings
          (schedule := trace.mainLane.schedule)
          (publicStepCount := trace.mainLane.preparedSteps.length)
          (exportedRows := trace.stage3Refinement.stage3.rowBindings.length)
          (j := j))
  }

def exactKernelBoundaries_of_minimalKernelInputPackage
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
  (inputs :
    MinimalExactKernelInputs
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
    BridgeBinding :=
  exactKernelBoundaries_of_minimalKernelInputs
    inputs.programBinding
    inputs.trace
    inputs.root0Bindings
    inputs.root0BindingsConform
    inputs.accounting
    inputs.bridgeBindings
    inputs.bridgeTraceBound

def kernelSoundness_of_exactBoundaries
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
    BridgeBinding :=
  kernelSoundness_of_acceptance
    (kernelSoundnessAccepted_of_exactBoundaries boundaries)

theorem executionCorrect_of_exactKernelBoundaries
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
  ExecutionCorrect
    boundaries.trace.stepComposition.execution.initialState
    boundaries.trace.stepComposition.execution.finalState
    boundaries.trace.stepComposition.execution.rows
    boundaries.trace.stepComposition.execution.preparedSteps
    boundaries.trace.stepComposition.execution.boundary
    boundaries.trace.stepComposition.execution.entrypoint
    boundaries.trace.stepComposition.execution.successors :=
  executionCorrect_of_kernelSoundness
    (kernelSoundness_of_exactBoundaries boundaries)

theorem exactPreparedStepBridgeAtIndex_of_exactKernelBoundaries
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
      BridgeBinding)
  {j : Nat}
  (hJ : j < boundaries.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ w,
    boundaries.bridgeBindings[j]? = some w ∧
      boundaries.trace.stage3Refinement.stage3.rowBindings[j]? =
        some w.exportedBinding ∧
      w.provenance.chain.preparedStep = w.exportedBinding.preparedStep :=
  exactPreparedStepBridgeAtIndex_of_kernelSoundness
    (kernelSoundness_of_exactBoundaries boundaries) hJ

noncomputable def canonicalOpcodeProofs_of_exactKernelBoundaries
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
  CanonicalOpcodeProofs
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    boundaries.trace.stepComposition.opcodeProofs :=
  canonicalOpcodeProofs_of_kernelSoundness
    (kernelSoundness_of_exactBoundaries boundaries)

end Nightstream.Rv64IM
