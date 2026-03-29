import Nightstream.Rv64IM.Kernel.AcceptedPublicProof
import Nightstream.Rv64IM.Kernel.PublicProofSchema
import Nightstream.Rv64IM.Kernel.PublicProofBoundaryConsequences

/-!
Owns the proposition-level theorem surface for the canonical accepted public
proof route. This file packages the Rust-shaped public proof boundary together
with the accepted-proof witness that discharges it.
-/

namespace Nightstream.Rv64IM

theorem acceptedPublicProofImpliesExecutionConsequences
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  (proof :
    AcceptedPublicProof
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
      Statement
      ClaimBundle
      KernelProofBundle) :
  ExecutionCorrect
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.initialState
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.finalState
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.rows
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.preparedSteps
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.boundary
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.entrypoint
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.successors ∧
    PreparedStepExportBound
      proof.accepted.topLevel.kernel.authenticatedTrace.chunkInput.rows
      proof.accepted.topLevel.kernel.authenticatedTrace.mainLane.preparedSteps ∧
    FullHaltedExecutionClaim
      proof.accepted.topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.sequence
      proof.accepted.topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.terminatingRow := by
  exact ⟨
    executionCorrect_of_publicProofBoundary proof.boundary proof.accepted,
    preparedStepExportBound_of_publicProofBoundary proof.boundary proof.accepted,
    fullHaltedExecutionClaim_of_publicProofBoundary proof.boundary proof.accepted
  ⟩

theorem exactKernelBoundariesImplyAcceptedPublicProofExecutionConsequences
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  (schema : PublicProofSchema Statement ClaimBundle KernelProofBundle)
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
  let proof :
      AcceptedPublicProof
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
        Statement
        ClaimBundle
        KernelProofBundle :=
        { boundary := publicProofBoundary_of_schema schema
          accepted := acceptedProofSoundness_of_exactKernelBoundaries boundaries }
  ExecutionCorrect
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.initialState
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.finalState
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.rows
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.preparedSteps
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.boundary
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.entrypoint
      proof.accepted.topLevel.kernel.authenticatedTrace.stepComposition.execution.successors ∧
    PreparedStepExportBound
      proof.accepted.topLevel.kernel.authenticatedTrace.chunkInput.rows
      proof.accepted.topLevel.kernel.authenticatedTrace.mainLane.preparedSteps ∧
    FullHaltedExecutionClaim
      proof.accepted.topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.sequence
      proof.accepted.topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.terminatingRow := by
  dsimp
  exact acceptedPublicProofImpliesExecutionConsequences
    { boundary := publicProofBoundary_of_schema schema
      accepted := acceptedProofSoundness_of_exactKernelBoundaries boundaries }

abbrev rv64imAcceptedPublicProofImpliesExecutionConsequences :=
  @acceptedPublicProofImpliesExecutionConsequences

abbrev exactKernelBoundariesImplyRv64imAcceptedPublicProofExecutionConsequences :=
  @exactKernelBoundariesImplyAcceptedPublicProofExecutionConsequences

end Nightstream.Rv64IM
