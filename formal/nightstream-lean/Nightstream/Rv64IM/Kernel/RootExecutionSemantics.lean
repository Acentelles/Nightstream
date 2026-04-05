import Nightstream.Rv64IM.Kernel.ChunkedRootProof
import Nightstream.Rv64IM.Trace.ExactTraceBoundaries

/-!
Owns the theorem-facing RV64IM root-execution-semantics surface. This file
binds one exact authenticated trace boundary to one chunked root execution
package and packages the refinement proving `ExecutionCorrect` on the same
authenticated rows; it does not re-own Twist/Shout or the full kernel bridge.
-/

namespace Nightstream.Rv64IM

structure RootExecutionSemanticsPackage
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _) [OfNat Limb 0] where
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
      (PreparedStepView Pc)
  root :
    ChunkedRootProofPackage
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      (PreparedStepView Pc)
  mainLaneShared : root.mainLane = trace.mainLane
  executionCorrectOnExactPrefix :
    ExecutionCorrect
      trace.stepComposition.execution.initialState
      trace.stepComposition.execution.finalState
      trace.chunkInput.rows
      trace.mainLane.preparedSteps
      trace.stepComposition.execution.boundary
      trace.stepComposition.execution.entrypoint
      trace.stepComposition.execution.successors

theorem mainLaneShared_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  (pkg :
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
      StateEffect) :
  pkg.root.mainLane = pkg.trace.mainLane :=
  pkg.mainLaneShared

theorem executionCorrect_on_exactPrefix_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  (pkg :
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
      StateEffect) :
  ExecutionCorrect
    pkg.trace.stepComposition.execution.initialState
    pkg.trace.stepComposition.execution.finalState
    pkg.trace.chunkInput.rows
    pkg.trace.mainLane.preparedSteps
    pkg.trace.stepComposition.execution.boundary
    pkg.trace.stepComposition.execution.entrypoint
    pkg.trace.stepComposition.execution.successors :=
  pkg.executionCorrectOnExactPrefix

theorem executionCorrect_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  (pkg :
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
      StateEffect) :
  ExecutionCorrect
    pkg.trace.stepComposition.execution.initialState
    pkg.trace.stepComposition.execution.finalState
    pkg.trace.stepComposition.execution.rows
    pkg.trace.stepComposition.execution.preparedSteps
    pkg.trace.stepComposition.execution.boundary
    pkg.trace.stepComposition.execution.entrypoint
    pkg.trace.stepComposition.execution.successors := by
  simpa [pkg.trace.executionRowsMatch, pkg.trace.preparedStepExport] using
    pkg.executionCorrectOnExactPrefix

theorem rootExecution_scheduleValid
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  (pkg :
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
      StateEffect) :
  FoldSchedule.Valid pkg.root.mainLane.schedule :=
  chunkedRootProof_scheduleValid pkg.root

theorem piCCS_atIndex_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {j : Nat}
  (hJ : j < pkg.root.mainLane.chunks.length) :
  ∃ backendPkg,
    pkg.root.chunkProofs[j]? = some backendPkg ∧
      Nightstream.SuperNeoPiCCSStrongStatement backendPkg.protocolTarget :=
  piCCS_atIndex_of_chunkedRootProof (pkg := pkg.root) hJ

theorem piRLC_atIndex_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {j : Nat}
  (hJ : j < pkg.root.mainLane.chunks.length) :
  ∃ backendPkg,
    pkg.root.chunkProofs[j]? = some backendPkg ∧
      Nightstream.SuperNeoPiRLCWeakStatement backendPkg.protocolTarget :=
  piRLC_atIndex_of_chunkedRootProof (pkg := pkg.root) hJ

theorem piDEC_atIndex_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {j : Nat}
  (hJ : j < pkg.root.mainLane.chunks.length) :
  ∃ backendPkg,
    pkg.root.chunkProofs[j]? = some backendPkg ∧
      Nightstream.SuperNeoPiDECKnowledgeStatement backendPkg.protocolTarget :=
  piDEC_atIndex_of_chunkedRootProof (pkg := pkg.root) hJ

theorem owningChunkIndex_lt_rootChunkCount_of_rowIndex
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {rowIndex : Nat}
  (hRow : rowIndex < pkg.trace.mainLane.semanticRows) :
  Nightstream.ChunkLayout.chunkIndexOf pkg.root.mainLane.schedule rowIndex <
    pkg.root.chunkProofs.length := by
  have hRootRow :
      rowIndex < pkg.root.mainLane.semanticRows := by
    simpa [pkg.mainLaneShared] using hRow
  exact owningChunkIndex_lt_chunkProofCount_of_rowIndex (pkg := pkg.root) hRootRow

theorem rootExecution_backendPackageAtOwningChunkIndex_of_rowIndex
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {rowIndex : Nat}
  (hRow : rowIndex < pkg.trace.mainLane.semanticRows) :
  ∃ backendPkg,
    pkg.root.chunkProofs[
        Nightstream.ChunkLayout.chunkIndexOf pkg.root.mainLane.schedule rowIndex]? =
      some backendPkg ∧
      backendPkg.chunkIndex =
        Nightstream.ChunkLayout.chunkIndexOf pkg.root.mainLane.schedule rowIndex ∧
      pkg.root.mainLane.chunks[
          Nightstream.ChunkLayout.chunkIndexOf pkg.root.mainLane.schedule rowIndex]? =
        some backendPkg.chunk := by
  have hRootRow :
      rowIndex < pkg.root.mainLane.semanticRows := by
    simpa [pkg.mainLaneShared] using hRow
  exact backendPackageAtOwningChunkIndex_of_rowIndex (pkg := pkg.root) hRootRow

theorem piCCS_atOwningChunkIndex_of_rowIndex_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {rowIndex : Nat}
  (hRow : rowIndex < pkg.trace.mainLane.semanticRows) :
  ∃ backendPkg,
    pkg.root.chunkProofs[
        Nightstream.ChunkLayout.chunkIndexOf pkg.root.mainLane.schedule rowIndex]? =
      some backendPkg ∧
      Nightstream.SuperNeoPiCCSStrongStatement backendPkg.protocolTarget := by
  rcases rootExecution_backendPackageAtOwningChunkIndex_of_rowIndex
      (pkg := pkg) hRow with
    ⟨backendPkg, hPkg, _, _⟩
  exact ⟨backendPkg, hPkg, backendPkg.piCCSStrong⟩

theorem piRLC_atOwningChunkIndex_of_rowIndex_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {rowIndex : Nat}
  (hRow : rowIndex < pkg.trace.mainLane.semanticRows) :
  ∃ backendPkg,
    pkg.root.chunkProofs[
        Nightstream.ChunkLayout.chunkIndexOf pkg.root.mainLane.schedule rowIndex]? =
      some backendPkg ∧
      Nightstream.SuperNeoPiRLCWeakStatement backendPkg.protocolTarget := by
  rcases rootExecution_backendPackageAtOwningChunkIndex_of_rowIndex
      (pkg := pkg) hRow with
    ⟨backendPkg, hPkg, _, _⟩
  exact ⟨backendPkg, hPkg, backendPkg.piRLCWeak⟩

theorem piDEC_atOwningChunkIndex_of_rowIndex_of_rootExecutionSemantics
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect :
    Type _} [OfNat Limb 0]
  {pkg :
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
      StateEffect}
  {rowIndex : Nat}
  (hRow : rowIndex < pkg.trace.mainLane.semanticRows) :
  ∃ backendPkg,
    pkg.root.chunkProofs[
        Nightstream.ChunkLayout.chunkIndexOf pkg.root.mainLane.schedule rowIndex]? =
      some backendPkg ∧
      Nightstream.SuperNeoPiDECKnowledgeStatement backendPkg.protocolTarget := by
  rcases piRLC_atOwningChunkIndex_of_rowIndex_of_rootExecutionSemantics
      (pkg := pkg) hRow with
    ⟨backendPkg, hPkg, hPiRLC⟩
  exact ⟨backendPkg, hPkg, SuperNeo.PiDECInterface.piDEC_of_weak hPiRLC⟩

end Nightstream.Rv64IM
