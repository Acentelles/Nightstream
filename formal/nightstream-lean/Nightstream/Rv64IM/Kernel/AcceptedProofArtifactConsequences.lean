import Nightstream.Rv64IM.Kernel.AcceptedProofArtifact
import Nightstream.Rv64IM.Kernel.AcceptedProofExecutionResult
import Nightstream.Rv64IM.Kernel.AcceptedPublicProofConsequences

/-!
Owns the theorem-facing corollaries of the RV64IM accepted-artifact boundary.
The low-level artifact determines the exact public-proof projection, while the
separate theorem-owned boundary construction discharges exact kernel boundaries
and the resulting execution-facing consequences.
-/

namespace Nightstream.Rv64IM

theorem acceptedProofArtifactBoundaryRecoversExactKernelBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  {acceptedArtifact :
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
      KernelProofBundle}
  (boundary :
    AcceptedProofArtifactBoundary
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
      KernelProofBundle
      acceptedArtifact) :
  exactKernelBoundaries_of_acceptedProofArtifactBoundary boundary = boundary.exactBoundaries := by
  rfl

theorem acceptedProofArtifactBoundaryRecoversAcceptedProofSoundness
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  {acceptedArtifact :
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
      KernelProofBundle}
  (boundary :
    AcceptedProofArtifactBoundary
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
      KernelProofBundle
      acceptedArtifact) :
  acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary =
    acceptedProofSoundness_of_exactKernelBoundaries boundary.exactBoundaries := by
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
  (acceptedArtifact :
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
  let schema := recomputedPublicProofSchema_of_acceptedProofArtifact project acceptedArtifact
  let boundary := publicProofBoundary_of_acceptedProofArtifact project acceptedArtifact
  boundary.statement = schema.statement ∧
    boundary.claims = schema.claims ∧
    boundary.kernelProof = schema.kernelProof := by
  dsimp [recomputedPublicProofSchema_of_acceptedProofArtifact,
    publicProofBoundary_of_acceptedProofArtifact, publicProofBoundary_of_schema]
  simp

def acceptedProofExecutionResult_of_acceptedProofArtifactBoundary
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  {acceptedArtifact :
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
      KernelProofBundle}
  (boundary :
    AcceptedProofArtifactBoundary
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
      KernelProofBundle
      acceptedArtifact) :
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
    (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary) :=
  acceptedProofExecutionResult_of_acceptedProofSoundness
    (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary)

theorem acceptedProofArtifactBoundaryImpliesExecutionConsequences
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _} [OfNat Limb 0]
  {acceptedArtifact :
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
      KernelProofBundle}
  (boundary :
    AcceptedProofArtifactBoundary
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
      KernelProofBundle
      acceptedArtifact) :
  ExecutionCorrect
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stepComposition.execution.initialState
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stepComposition.execution.finalState
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stepComposition.execution.rows
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stepComposition.execution.preparedSteps
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stepComposition.execution.boundary
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stepComposition.execution.entrypoint
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stepComposition.execution.successors ∧
    PreparedStepExportBound
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.chunkInput.rows
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.mainLane.preparedSteps ∧
    FullHaltedExecutionClaim
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.sequence
      (acceptedProofSoundness_of_acceptedProofArtifactBoundary boundary).topLevel.kernel.authenticatedTrace.stage3Refinement.finalBoundary.terminatingRow := by
  let result := acceptedProofExecutionResult_of_acceptedProofArtifactBoundary boundary
  exact ⟨result.executionCorrect, result.preparedStepExportBound, result.fullHaltedExecutionClaim⟩

theorem acceptedProofArtifactBoundaryImpliesAcceptedPublicProofExecutionConsequences
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
  {acceptedArtifact :
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
      KernelProofBundle}
  (boundary :
    AcceptedProofArtifactBoundary
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
      KernelProofBundle
      acceptedArtifact) :
  let proof := acceptedPublicProof_of_acceptedProofArtifactBoundary project boundary
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
    (acceptedPublicProof_of_acceptedProofArtifactBoundary project boundary)

end Nightstream.Rv64IM
