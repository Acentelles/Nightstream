import Nightstream.Rv64IM.Kernel.AcceptedPublicProof
import Nightstream.Rv64IM.Kernel.PublicProofSchema
import Nightstream.Rv64IM.Kernel.PublicProofBoundaryConsequences

/-!
Owns the proposition-level theorem surface for the canonical accepted public
proof route. This file does not re-own the public proof object; it packages
its three execution/public-result consequences into one explicit theorem-facing
boundary.
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
    executionCorrect_of_publicProofBoundary proof,
    preparedStepExportBound_of_publicProofBoundary proof,
    fullHaltedExecutionClaim_of_publicProofBoundary proof
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
        publicProofBoundary_of_schema
          schema
          (acceptedProofSoundness_of_exactKernelBoundaries boundaries)
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
    (publicProofBoundary_of_schema
      schema
      (acceptedProofSoundness_of_exactKernelBoundaries boundaries))

theorem rv64imAcceptedPublicProofImpliesExecutionConsequences
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Rv64imProofStatement Rv64imKernelClaimBundle Rv64imKernelProofBundle :
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
      Rv64imProofStatement
      Rv64imKernelClaimBundle
      Rv64imKernelProofBundle) :
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
  exact acceptedPublicProofImpliesExecutionConsequences proof

theorem exactKernelBoundariesImplyRv64imAcceptedPublicProofExecutionConsequences
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Rv64imProofStatement Rv64imKernelClaimBundle Rv64imKernelProofBundle :
    Type _} [OfNat Limb 0]
  (schema :
    Rv64imPublicProofSchema
      Rv64imProofStatement
      Rv64imKernelClaimBundle
      Rv64imKernelProofBundle)
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
        Rv64imProofStatement
        Rv64imKernelClaimBundle
        Rv64imKernelProofBundle :=
        publicProofBoundary_of_schema
          schema
          (acceptedProofSoundness_of_exactKernelBoundaries boundaries)
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
  exact exactKernelBoundariesImplyAcceptedPublicProofExecutionConsequences
    schema
    boundaries

end Nightstream.Rv64IM
