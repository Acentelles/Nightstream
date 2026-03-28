import Nightstream.Rv64IM.Kernel.AcceptedProofArtifact
import Nightstream.Rv64IM.Kernel.AcceptedProofExecutionResult
import Nightstream.Rv64IM.Kernel.AcceptedPublicProofConsequences

/-!
Owns the theorem-facing corollaries of the RV64IM accepted-artifact boundary.
This is the explicit bridge from an accepted artifact to accepted-proof
soundness, exact public-proof projection, and the execution-facing consequences
used by the RV64IM soundness stack.
-/

namespace Nightstream.Rv64IM

theorem acceptedProofArtifactRecoversExactKernelBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  (artifact :
    AcceptedProofArtifact
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
      Artifact
      Statement
      ClaimBundle
      KernelProofBundle) :
  exactKernelBoundaries_of_acceptedProofArtifact artifact = artifact.exactBoundaries := by
  rfl

theorem acceptedProofArtifactRecoversAcceptedProofSoundness
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  (artifact :
    AcceptedProofArtifact
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
      Artifact
      Statement
      ClaimBundle
      KernelProofBundle) :
  acceptedProofSoundness_of_acceptedProofArtifact artifact =
    acceptedProofSoundness_of_exactKernelBoundaries artifact.exactBoundaries := by
  rfl

theorem acceptedProofArtifactHasExactPublicProofProjection
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  (project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle)
  [OfNat Limb 0]
  (artifact :
    AcceptedProofArtifact
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
      Artifact
      Statement
      ClaimBundle
      KernelProofBundle) :
  let schema := recomputedPublicProofSchema_of_acceptedProofArtifact project artifact
  let boundary := publicProofBoundary_of_acceptedProofArtifact project artifact
  boundary.statement = schema.statement ∧
    boundary.claims = schema.claims ∧
    boundary.kernelProof = schema.kernelProof ∧
    boundary.accepted = acceptedProofSoundness_of_acceptedProofArtifact artifact := by
  dsimp [recomputedPublicProofSchema_of_acceptedProofArtifact,
    publicProofBoundary_of_acceptedProofArtifact, publicProofBoundary_of_schema]
  simp

def acceptedProofExecutionResult_of_acceptedProofArtifact
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  (artifact :
    AcceptedProofArtifact
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
      Artifact
      Statement
      ClaimBundle
      KernelProofBundle) :
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
    (acceptedProofSoundness_of_acceptedProofArtifact artifact) :=
  acceptedProofExecutionResult_of_acceptedProofSoundness
    (acceptedProofSoundness_of_acceptedProofArtifact artifact)

theorem acceptedProofArtifactImpliesExecutionConsequences
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  (artifact :
    AcceptedProofArtifact
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
      Artifact
      Statement
      ClaimBundle
      KernelProofBundle) :
  ExecutionCorrect
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stepComposition.execution.initialState
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stepComposition.execution.finalState
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stepComposition.execution.rows
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stepComposition.execution.preparedSteps
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stepComposition.execution.boundary
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stepComposition.execution.entrypoint
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stepComposition.execution.successors ∧
    PreparedStepExportBound
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.chunkInput.rows
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.mainLane.preparedSteps ∧
    FullHaltedExecutionClaim
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.sequence
      (acceptedProofSoundness_of_acceptedProofArtifact artifact).topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.terminatingRow := by
  let result := acceptedProofExecutionResult_of_acceptedProofArtifact artifact
  exact ⟨result.executionCorrect, result.preparedStepExportBound, result.fullHaltedExecutionClaim⟩

theorem acceptedProofArtifactImpliesAcceptedPublicProofExecutionConsequences
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  (project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle)
  [OfNat Limb 0]
  (artifact :
    AcceptedProofArtifact
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
      Artifact
      Statement
      ClaimBundle
      KernelProofBundle) :
  let proof := publicProofBoundary_of_acceptedProofArtifact project artifact
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
    (publicProofBoundary_of_acceptedProofArtifact project artifact)

end Nightstream.Rv64IM
