import Nightstream.Rv64IM.Kernel.BridgeBinding
import Nightstream.Rv64IM.Kernel.RootExecutionSemantics
import Nightstream.Rv64IM.Trace.ExactTraceBoundaries
import Nightstream.Rv64IM.Stage2.AuthenticatedHistorySemantics

/-!
Owns the theorem-facing RV64IM kernel-design bridge. This file binds
authenticated selected-row openings, the chunked root execution theorem,
Stage 1/2/3 trace obligations, and kernel opening provenance into one bridge
surface; it does not re-own Twist/Shout, SuperNeo, or stage-local semantics.
-/

namespace Nightstream.Rv64IM

structure SelectedRowRootRoutingWitness
  (Pc BytecodeAddr RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _)
  [OfNat Limb 0]
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
      (PreparedStepView Pc))
  (rootExecution :
    RootExecutionSemanticsPackage
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
      StateEffect) where
  opening :
    KernelBridgeBindingWitness
      Pc
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      (PreparedStepView Pc)
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
      trace.stage3Refinement.stage3
  rootPreparedStep : PreparedStepView Pc
  rootPreparedStepAtIndex :
    rootExecution.root.mainLane.preparedSteps[opening.exportedStepIndex]? = some rootPreparedStep
  exportedPreparedStepEq :
    opening.exportedBinding.preparedStep = rootPreparedStep
  chunkIndex : Nat
  chunkIndexMatchesSchedule :
    chunkIndex =
      Nightstream.ChunkLayout.chunkIndexOf
        rootExecution.root.mainLane.schedule
        rootPreparedStep.rowIndex
  backendPkg : RootChunkBackendProofPackage
  chunkProofAtIndex :
    rootExecution.root.chunkProofs[chunkIndex]? = some backendPkg
  backendChunkAtIndex :
    rootExecution.root.mainLane.chunks[chunkIndex]? = some backendPkg.chunk
  rowIndexCovered : rootPreparedStep.rowIndex ∈ backendPkg.rowLabels

def KernelDesignBridgeBound
  {Pc BytecodeAddr RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
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
      (PreparedStepView Pc))
  (rootExecution :
    RootExecutionSemanticsPackage
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
      StateEffect)
  (routings :
    List
      (SelectedRowRootRoutingWitness
        Pc
        BytecodeAddr
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
        trace
        rootExecution)) : Prop :=
  rootExecution.trace = trace ∧
    routings.length = trace.stage3Refinement.stage3.rowBindings.length ∧
    ∀ j, j < trace.stage3Refinement.stage3.rowBindings.length →
      ∃ routing, routings[j]? = some routing ∧ routing.opening.exportedStepIndex = j

structure KernelDesignBridgePackage
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _)
  [OfNat Limb 0] where
  rootExecution :
    RootExecutionSemanticsPackage
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
  routings :
    List
      (SelectedRowRootRoutingWitness
        Pc
        BytecodeAddr
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
        rootExecution.trace
        rootExecution)
  bound : KernelDesignBridgeBound rootExecution.trace rootExecution routings

theorem mainLaneShared_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  (pkg :
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
      BridgeBinding) :
  pkg.rootExecution.root.mainLane = pkg.rootExecution.trace.mainLane := by
  simpa [pkg.bound.1] using pkg.rootExecution.mainLaneShared

theorem selectedRoutingWitnessAtIndex_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing, pkg.routings[j]? = some routing ∧ routing.opening.exportedStepIndex = j :=
  pkg.bound.2.2 j hJ

theorem authenticatedSelectionAtIndex_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings[j]? =
        some routing.opening.exportedBinding ∧
      routing.opening.provenance.chain.preparedStep = routing.opening.exportedBinding.preparedStep := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, hIndex⟩
  refine ⟨routing, hRouting, ?_, routing.opening.samePreparedStep⟩
  simpa [hIndex] using routing.opening.exportedBindingAtIndex

theorem rootPreparedStepAtIndex_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing step,
    pkg.routings[j]? = some routing ∧
      pkg.rootExecution.root.mainLane.preparedSteps[j]? = some step ∧
      routing.opening.provenance.chain.preparedStep = step := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, hIndex⟩
  refine ⟨routing, routing.rootPreparedStep, hRouting, ?_, ?_⟩
  · simpa [hIndex] using routing.rootPreparedStepAtIndex
  · calc
      routing.opening.provenance.chain.preparedStep =
          routing.opening.exportedBinding.preparedStep := routing.opening.samePreparedStep
      _ = routing.rootPreparedStep := routing.exportedPreparedStepEq

theorem selectedPreparedStepCoveredByChunk_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      routing.rootPreparedStep.rowIndex ∈ routing.backendPkg.rowLabels := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  exact ⟨routing, hRouting, routing.rowIndexCovered⟩

theorem selectedPreparedStepOwnedByScheduledChunk_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      routing.chunkIndex =
        Nightstream.ChunkLayout.chunkIndexOf
          pkg.rootExecution.root.mainLane.schedule
          routing.rootPreparedStep.rowIndex := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  exact ⟨routing, hRouting, routing.chunkIndexMatchesSchedule⟩

theorem selectedPreparedStepRoutedToScheduledChunk_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      pkg.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      pkg.rootExecution.root.mainLane.chunks[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg.chunk := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  refine ⟨routing, hRouting, ?_, ?_⟩
  · simpa [routing.chunkIndexMatchesSchedule] using routing.chunkProofAtIndex
  · simpa [routing.chunkIndexMatchesSchedule] using routing.backendChunkAtIndex

theorem piCCS_atSelectedIndex_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      Nightstream.SuperNeoPiCCSStrongStatement routing.backendPkg.protocolTarget := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  exact ⟨routing, hRouting, routing.backendPkg.piCCSStrong⟩

theorem piRLC_atSelectedIndex_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      Nightstream.SuperNeoPiRLCWeakStatement routing.backendPkg.protocolTarget := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  exact ⟨routing, hRouting, routing.backendPkg.piRLCWeak⟩

theorem piDEC_atSelectedIndex_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      Nightstream.SuperNeoPiDECKnowledgeStatement routing.backendPkg.protocolTarget := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  exact
    ⟨routing, hRouting, SuperNeo.PiDECInterface.piDEC_of_weak routing.backendPkg.piRLCWeak⟩

theorem piCCS_atScheduledChunk_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      pkg.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      Nightstream.SuperNeoPiCCSStrongStatement routing.backendPkg.protocolTarget := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  refine ⟨routing, hRouting, ?_, routing.backendPkg.piCCSStrong⟩
  simpa [routing.chunkIndexMatchesSchedule] using routing.chunkProofAtIndex

theorem piRLC_atScheduledChunk_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      pkg.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      Nightstream.SuperNeoPiRLCWeakStatement routing.backendPkg.protocolTarget := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  refine ⟨routing, hRouting, ?_, routing.backendPkg.piRLCWeak⟩
  simpa [routing.chunkIndexMatchesSchedule] using routing.chunkProofAtIndex

theorem piDEC_atScheduledChunk_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  {pkg :
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
      BridgeBinding}
  {j : Nat}
  (hJ : j < pkg.rootExecution.trace.stage3Refinement.stage3.rowBindings.length) :
  ∃ routing,
    pkg.routings[j]? = some routing ∧
      pkg.rootExecution.root.chunkProofs[
          Nightstream.ChunkLayout.chunkIndexOf
            pkg.rootExecution.root.mainLane.schedule
            routing.rootPreparedStep.rowIndex]? = some routing.backendPkg ∧
      Nightstream.SuperNeoPiDECKnowledgeStatement routing.backendPkg.protocolTarget := by
  rcases selectedRoutingWitnessAtIndex_of_kernelDesignBridge (pkg := pkg) hJ with
    ⟨routing, hRouting, _⟩
  refine
    ⟨routing, hRouting, ?_,
      SuperNeo.PiDECInterface.piDEC_of_weak routing.backendPkg.piRLCWeak⟩
  simpa [routing.chunkIndexMatchesSchedule] using routing.chunkProofAtIndex

theorem executionCorrect_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  (pkg :
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
      BridgeBinding) :
  ExecutionCorrect
    pkg.rootExecution.trace.stepComposition.execution.initialState
    pkg.rootExecution.trace.stepComposition.execution.finalState
    pkg.rootExecution.trace.stepComposition.execution.rows
    pkg.rootExecution.trace.stepComposition.execution.preparedSteps
    pkg.rootExecution.trace.stepComposition.execution.boundary
    pkg.rootExecution.trace.stepComposition.execution.entrypoint
    pkg.rootExecution.trace.stepComposition.execution.successors :=
  executionCorrect_of_rootExecutionSemantics pkg.rootExecution

theorem stage2AuthenticatedHistorySemantics_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  (pkg :
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
      BridgeBinding) :
  Stage2AuthenticatedHistorySemantics
    pkg.rootExecution.trace.temporal
    pkg.rootExecution.trace.stepComposition.twistBinding :=
  stage2AuthenticatedHistorySemantics_of_temporalConsistency_and_twistConcreteBinding
    pkg.rootExecution.trace.temporal
    pkg.rootExecution.trace.stepComposition.twistBinding

theorem fullHaltedExecutionClaim_of_kernelDesignBridge
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    Source CommitmentId Point PolynomialId Value Digest ExactOpeningWitness
    OpeningRefinement RowProjectionWitness BridgeBinding : Type _}
  [OfNat Limb 0]
  (pkg :
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
      BridgeBinding) :
  FullHaltedExecutionClaim
    pkg.rootExecution.trace.stage3Refinement.finalBoundary.sequence
    pkg.rootExecution.trace.stage3Refinement.finalBoundary.terminatingRow :=
  fullHaltedExecutionClaim_of_stage3Refinement pkg.rootExecution.trace.stage3Refinement

end Nightstream.Rv64IM
