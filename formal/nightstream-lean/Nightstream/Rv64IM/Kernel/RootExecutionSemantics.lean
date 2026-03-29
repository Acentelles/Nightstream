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

end Nightstream.Rv64IM
