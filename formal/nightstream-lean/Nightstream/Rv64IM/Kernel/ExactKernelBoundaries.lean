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
