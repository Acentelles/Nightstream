import Nightstream.Rv64IM.Kernel.AcceptedProofSoundness

/-!
Owns the theorem-facing RV64IM surface that reads like the final accepted-proof
claim: accepted proof evidence yields a valid execution surface together with
its exported public-result consequences. This file does not re-own accepted
proof soundness; it repackages the exact execution-facing consequences.
-/

namespace Nightstream.Rv64IM

structure AcceptedProofExecutionResult
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _) [OfNat Limb 0]
  (accepted :
    AcceptedProofSoundness
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
  conclusion :
    AcceptedProofConclusion
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
      accepted
  executionCorrect :
    ExecutionCorrect
      conclusion.kernel.authenticatedTrace.stepComposition.execution.initialState
      conclusion.kernel.authenticatedTrace.stepComposition.execution.finalState
      conclusion.kernel.authenticatedTrace.stepComposition.execution.rows
      conclusion.kernel.authenticatedTrace.stepComposition.execution.preparedSteps
      conclusion.kernel.authenticatedTrace.stepComposition.execution.boundary
      conclusion.kernel.authenticatedTrace.stepComposition.execution.entrypoint
      conclusion.kernel.authenticatedTrace.stepComposition.execution.successors
  preparedStepExportBound :
    PreparedStepExportBound
      conclusion.kernel.authenticatedTrace.chunkInput.rows
      conclusion.kernel.authenticatedTrace.mainLane.preparedSteps
  fullHaltedExecutionClaim :
    FullHaltedExecutionClaim
      conclusion.kernel.authenticatedTrace.stage3Refinement.finalBoundary.sequence
      conclusion.kernel.authenticatedTrace.stage3Refinement.finalBoundary.terminatingRow

def acceptedProofExecutionResult_of_acceptedProofConclusion
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
  {accepted :
    AcceptedProofSoundness
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
      BridgeBinding}
  (conclusion :
    AcceptedProofConclusion
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
      accepted) :
  AcceptedProofExecutionResult
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
    accepted :=
  { conclusion := conclusion
    executionCorrect := conclusion.executionCorrect
    preparedStepExportBound := conclusion.preparedStepExportBound
    fullHaltedExecutionClaim := conclusion.fullHaltedExecutionClaim }

def acceptedProofExecutionResult_of_acceptedProofSoundness
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
  (accepted :
    AcceptedProofSoundness
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
  AcceptedProofExecutionResult
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
    accepted :=
  acceptedProofExecutionResult_of_acceptedProofConclusion
    (acceptedProofImpliesConclusion accepted)

def acceptedProofImpliesExecutionAndPublicResult
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
  (accepted :
    AcceptedProofSoundness
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
  AcceptedProofExecutionResult
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
    accepted :=
  acceptedProofExecutionResult_of_acceptedProofSoundness accepted

def acceptedProofExecutionResult_of_exactKernelBoundaries
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
  AcceptedProofExecutionResult
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
    (acceptedProofSoundness_of_exactKernelBoundaries boundaries) :=
  acceptedProofExecutionResult_of_acceptedProofConclusion
    (exactKernelBoundariesImplyAcceptedProofConclusion boundaries)

def exactKernelBoundariesImplyExecutionAndPublicResult
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
  AcceptedProofExecutionResult
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
    (acceptedProofSoundness_of_exactKernelBoundaries boundaries) :=
  acceptedProofExecutionResult_of_exactKernelBoundaries boundaries

end Nightstream.Rv64IM
