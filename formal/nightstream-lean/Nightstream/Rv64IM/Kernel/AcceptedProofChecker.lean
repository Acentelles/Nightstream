import Nightstream.Rv64IM.Kernel.AcceptedProofArtifactConsequences

/-!
Owns the theorem-facing RV64IM accepted-proof checker result surface. This
packages an accepted artifact together with the exact public-proof projection
it determines and the execution-facing consequences discharged by the exact
kernel-boundary witness carried by that artifact.
-/

namespace Nightstream.Rv64IM

structure AcceptedProofCheckerResult
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _)
  (project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle)
  [OfNat Limb 0] where
  artifact :
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
      KernelProofBundle
  exactBoundaries :
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
      BridgeBinding
  publicResult :
    PublicProofSchemaExecutionResult
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
      KernelProofBundle
      (recomputedPublicProofSchema_of_acceptedProofArtifact project artifact)
      (acceptedProofSoundness_of_acceptedProofArtifact artifact)
  acceptedResult :
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
      (acceptedProofSoundness_of_acceptedProofArtifact artifact)
  projectionExact :
    let schema := recomputedPublicProofSchema_of_acceptedProofArtifact project artifact
    let boundary := publicProofBoundary_of_acceptedProofArtifact project artifact
    boundary.statement = schema.statement ∧
      boundary.claims = schema.claims ∧
      boundary.kernelProof = schema.kernelProof ∧
      boundary.accepted = acceptedProofSoundness_of_acceptedProofArtifact artifact

def acceptedProofCheckerResult_of_artifact
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
  AcceptedProofCheckerResult
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
    project :=
  { artifact := artifact
  , exactBoundaries := exactKernelBoundaries_of_acceptedProofArtifact artifact
  , publicResult := publicProofSchemaExecutionResult_of_acceptedProofArtifact project artifact
  , acceptedResult := acceptedProofExecutionResult_of_acceptedProofArtifact artifact
  , projectionExact := acceptedProofArtifactHasExactPublicProofProjection project artifact
  }

end Nightstream.Rv64IM
