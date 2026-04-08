import Nightstream.Rv64IM.Kernel.AcceptedProofChecker
import Nightstream.Rv64IM.Kernel.KernelDesignBridge

/-!
Owns the theorem-facing RV64IM checker/backend-refinement join surface. This
file pairs a checker result with the stronger kernel-design bridge package and
proves that the checker's authenticated trace is the same trace routed into the
selected-row `Π_CCS / Π_RLC / Π_DEC` consequences; it does not re-own the
accepted checker or the bridge theorem.
-/

namespace Nightstream.Rv64IM

structure AcceptedProofCheckerBackendRefinementPackage
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _)
  (project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle)
  [OfNat Limb 0] where
  checker :
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
      (PreparedStepView Pc)
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
      project
  bridge :
    KernelDesignBridgePackage
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
  traceShared :
    checker.accepted.topLevel.kernel.authenticatedTrace =
      authenticatedChunkTrace_of_exactBoundaries bridge.rootExecution.trace

def acceptedProofCheckerBackendRefinementPackage_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
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
      (PreparedStepView Pc)
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
      KernelProofBundle)
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
      (PreparedStepView Pc)
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
  (bridge :
    KernelDesignBridgePackage
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
  (hTrace : bridge.rootExecution.trace = boundaries.trace) :
  AcceptedProofCheckerBackendRefinementPackage
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
    project := by
  refine
    { checker := acceptedProofCheckerResult_of_exactKernelBoundaries project artifact boundaries
    , bridge := bridge
    , traceShared := ?_
    }
  simp [acceptedProofCheckerResult_of_exactKernelBoundaries,
    acceptedProofSoundness_of_exactKernelBoundaries,
    topLevelSoundness_of_exactKernelBoundaries,
    kernelSoundness_of_exactBoundaries,
    kernelSoundness_of_acceptance,
    kernelSoundnessAccepted_of_exactBoundaries,
    hTrace]

theorem piCCS_atSelectedIndex_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      Nightstream.SuperNeoPiCCSStrongStatement routing.backendPkg.protocolTarget :=
  piCCS_atSelectedIndex_of_kernelDesignBridge (pkg := pkg.bridge) hJ

theorem piRLC_atSelectedIndex_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      Nightstream.SuperNeoPiRLCWeakStatement routing.backendPkg.protocolTarget :=
  piRLC_atSelectedIndex_of_kernelDesignBridge (pkg := pkg.bridge) hJ

theorem piDEC_atSelectedIndex_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      Nightstream.SuperNeoPiDECKnowledgeStatement routing.backendPkg.protocolTarget :=
  piDEC_atSelectedIndex_of_kernelDesignBridge (pkg := pkg.bridge) hJ

theorem piCCS_atScheduledChunk_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      pkg.bridge.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.bridge.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      Nightstream.SuperNeoPiCCSStrongStatement routing.backendPkg.protocolTarget :=
  piCCS_atScheduledChunk_of_kernelDesignBridge (pkg := pkg.bridge) hJ

theorem piRLC_atScheduledChunk_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      pkg.bridge.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.bridge.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      Nightstream.SuperNeoPiRLCWeakStatement routing.backendPkg.protocolTarget :=
  piRLC_atScheduledChunk_of_kernelDesignBridge (pkg := pkg.bridge) hJ

theorem piDEC_atScheduledChunk_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      pkg.bridge.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.bridge.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      Nightstream.SuperNeoPiDECKnowledgeStatement routing.backendPkg.protocolTarget :=
  piDEC_atScheduledChunk_of_kernelDesignBridge (pkg := pkg.bridge) hJ

theorem selectedPreparedStepOwnedByScheduledChunk_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      routing.chunkIndex =
        Nightstream.ChunkLayout.chunkIndexOf
          pkg.bridge.rootExecution.root.mainLane.schedule
          routing.rootPreparedStep.rowIndex :=
  selectedPreparedStepOwnedByScheduledChunk_of_kernelDesignBridge
    (pkg := pkg.bridge) hJ

theorem selectedPreparedStepRoutedToScheduledChunk_of_acceptedProofCheckerBackendRefinement
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    ProgramImage LoweringVersion RomTable BytecodeTable RomCommit BytecodeCommit
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding
    Artifact Statement ClaimBundle KernelProofBundle :
    Type _}
  {project : Artifact -> PublicProofSchema Statement ClaimBundle KernelProofBundle}
  [OfNat Limb 0]
  {pkg :
    AcceptedProofCheckerBackendRefinementPackage
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
      project}
  {j : Nat}
  (hJ : j < pkg.bridge.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.bridge.routings[j]? = some routing ∧
      pkg.bridge.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.bridge.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      pkg.bridge.rootExecution.root.mainLane.chunks[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.bridge.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg.chunk :=
  selectedPreparedStepRoutedToScheduledChunk_of_kernelDesignBridge
    (pkg := pkg.bridge) hJ

end Nightstream.Rv64IM
