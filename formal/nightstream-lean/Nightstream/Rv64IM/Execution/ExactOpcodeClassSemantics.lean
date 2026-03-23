import Nightstream.Rv64IM.Execution.OpcodeClassExtractors

/-!
Owns exact opcode-class semantic consequences above the canonical RV64IM
opcode-class proof package. This file does not re-own stage-local proofs,
authenticated trace closure, or kernel-level bridge/transcript facts.
-/

namespace Nightstream.Rv64IM

private theorem mem_of_getElem?_eq_some
  {α : Type _}
  {xs : List α}
  {idx : Nat}
  {x : α}
  (h : xs[idx]? = some x) :
  x ∈ xs := by
  induction xs generalizing idx with
  | nil =>
      cases idx <;> simp at h
  | cons y ys ih =>
      cases idx with
      | zero =>
          simp only [List.getElem?_cons_zero] at h
          injection h with hEq
          subst hEq
          exact List.mem_cons.2 (Or.inl rfl)
      | succ idx =>
          simp only [List.getElem?_cons_succ] at h
          exact List.mem_cons_of_mem _ (ih h)

structure OpcodeClassExecutionFacts
  (opcodeClass : OpcodeClass)
  (Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _)
  (proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation) where
  classEq : proof.opcodeClass = opcodeClass
  executionCorrect :
    ExecutionCorrect
      proof.semantics.initialState
      proof.semantics.finalState
      proof.semantics.rows
      proof.semantics.preparedSteps
      proof.semantics.boundary
      proof.semantics.entrypoint
      proof.semantics.successors
  executionTrace :
    ExecutionTraceCorrect
      proof.semantics.initialState
      proof.semantics.finalState
      proof.semantics.rows
      proof.semantics.frames
  frameRows :
    FrameRowsBound proof.semantics.frames proof.semantics.rows
  executionLinked :
    ExecutionLinked proof.semantics.frames
  executionTraceEndpoints :
    ExecutionTraceEndpoints
      proof.semantics.initialState
      proof.semantics.finalState
      proof.semantics.frames
  expandedRowSequence :
    ExpandedRowSequenceBound proof.semantics.rows
  preparedStepExport :
    PreparedStepExportBound proof.semantics.rows proof.semantics.preparedSteps
  expandedBytecodeExecution :
    ExpandedBytecodeExecutionBound
      proof.semantics.entrypoint
      proof.semantics.successors
      proof.semantics.rows
  fullSequenceTerminated :
    FullSequenceTerminated proof.semantics.boundary proof.semantics.rows
  boundaryStartPc :
    proof.semantics.boundary.startPc = proof.semantics.initialState.pc
  boundaryPcNext :
    proof.semantics.boundary.pcNext = proof.semantics.finalState.pc
  boundaryTerminates :
    proof.semantics.boundary.terminates = true
  finalStateHalted :
    proof.semantics.finalState.halted = true
  rowsHaveClass :
    ∀ row, row ∈ proof.semantics.rows → row.opcodeClass = opcodeClass

theorem frame_row_eq_at_index_of_opcodeClassExecutionFacts
  {opcodeClass : OpcodeClass}
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts :
    OpcodeClassExecutionFacts
      opcodeClass
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof)
  {idx : Nat}
  {frame : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hFrame : proof.semantics.frames[idx]? = some frame)
  (hRow : proof.semantics.rows[idx]? = some row) :
  frame.row = row :=
  frameRowsBound_row_eq_at_index facts.frameRows hFrame hRow

theorem adjacentStates_of_opcodeClassExecutionFacts
  {opcodeClass : OpcodeClass}
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts :
    OpcodeClassExecutionFacts
      opcodeClass
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof)
  {idx : Nat}
  {prev next : ExecutionFrame Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (hPrev : proof.semantics.frames[idx]? = some prev)
  (hNext : proof.semantics.frames[idx + 1]? = some next) :
  prev.postState = next.preState :=
  adjacentStates_of_executionTraceCorrect facts.executionTrace hPrev hNext

theorem preparedStep_matches_row_of_opcodeClassExecutionFacts
  {opcodeClass : OpcodeClass}
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts :
    OpcodeClassExecutionFacts
      opcodeClass
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof)
  {idx : Nat}
  {step : PreparedStepView Pc}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hStep : proof.semantics.preparedSteps[idx]? = some step)
  (hRow : proof.semantics.rows[idx]? = some row) :
  PreparedStepView.rowIndex step = idx ∧
    PreparedStepView.pc step = (ExpandedRow.bytecode row).unexpandedPc ∧
      PreparedStepView.advanceArchPc step = ExpandedRow.advanceArchPc row ∧
        PreparedStepView.terminates step = ExpandedRow.terminates row :=
  preparedStep_matches_row_of_preparedStepExportBound facts.preparedStepExport hStep hRow

theorem successor_matches_rows_of_opcodeClassExecutionFacts
  {opcodeClass : OpcodeClass}
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts :
    OpcodeClassExecutionFacts
      opcodeClass
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof)
  {idx : Nat}
  {successor : ExpandedBytecodeSuccessorProofPackage Pc BytecodeAddr}
  {row nextRow : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hSucc : proof.semantics.successors[idx]? = some successor)
  (hRow : proof.semantics.rows[idx]? = some row)
  (hNext : proof.semantics.rows[idx + 1]? = some nextRow) :
  successor.row = ExpandedRow.bytecode row ∧
    successor.nextExpandedPc = (ExpandedRow.bytecode nextRow).expandedPc :=
  successor_matches_rows_of_expandedBytecodeExecutionBound
    facts.expandedBytecodeExecution
    hSucc
    hRow
    hNext

theorem row_has_opcodeClass_at_index_of_opcodeClassExecutionFacts
  {opcodeClass : OpcodeClass}
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (facts :
    OpcodeClassExecutionFacts
      opcodeClass
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      proof)
  {idx : Nat}
  {row : ExpandedRow Pc BytecodeAddr RegIdx StateLocation}
  (hRow : proof.semantics.rows[idx]? = some row) :
  row.opcodeClass = opcodeClass := by
  have hMem : row ∈ proof.semantics.rows := mem_of_getElem?_eq_some hRow
  exact facts.rowsHaveClass row hMem

def opcodeClassExecutionFacts_of_opcodeClassProof
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  (proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation) :
  OpcodeClassExecutionFacts
    proof.opcodeClass
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    proof :=
  { classEq := rfl
    executionCorrect := executionCorrect_of_opcodeClassProof proof
    executionTrace := proof.semantics.traceCorrect
    frameRows :=
      frameRowsBound_of_executionTraceCorrect proof.semantics.traceCorrect
    executionLinked :=
      executionLinked_of_executionTraceCorrect proof.semantics.traceCorrect
    executionTraceEndpoints :=
      executionTraceEndpoints_of_executionTraceCorrect proof.semantics.traceCorrect
    expandedRowSequence :=
      expandedRowSequenceBound_of_executionCorrect proof.semantics.correct
    preparedStepExport :=
      preparedStepExportBound_of_executionCorrect proof.semantics.correct
    expandedBytecodeExecution :=
      expandedBytecodeExecutionBound_of_executionCorrect proof.semantics.correct
    fullSequenceTerminated := by
      exact proof.semantics.correct.2.2.2.1
    boundaryStartPc :=
      boundaryStartPc_of_executionCorrect proof.semantics.correct
    boundaryPcNext :=
      boundaryPcNext_of_executionCorrect proof.semantics.correct
    boundaryTerminates :=
      boundaryTerminates_of_executionCorrect proof.semantics.correct
    finalStateHalted :=
      finalState_halted_of_executionCorrect proof.semantics.correct
    rowsHaveClass := fun row hRow => row_opcodeClass_of_opcodeClassProof proof hRow }

structure CanonicalOpcodeClassSemantics
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) where
  nativeAlu :
    OpcodeClassExecutionFacts
      .nativeAlu
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      canonical.nativeAlu
  wordShift :
    OpcodeClassExecutionFacts
      .wordShift
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      canonical.wordShift
  controlFlow :
    OpcodeClassExecutionFacts
      .controlFlow
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      canonical.controlFlow
  narrowMemory :
    OpcodeClassExecutionFacts
      .narrowMemory
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      canonical.narrowMemory
  multiply :
    OpcodeClassExecutionFacts
      .multiply
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      canonical.multiply
  unsignedDivRem :
    OpcodeClassExecutionFacts
      .unsignedDivRem
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      canonical.unsignedDivRem
  signedDivRem :
    OpcodeClassExecutionFacts
      .signedDivRem
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      canonical.signedDivRem

private def executionFacts_cast
  {opcodeClass : OpcodeClass}
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proof : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation}
  (hClass : proof.opcodeClass = opcodeClass) :
  OpcodeClassExecutionFacts
    opcodeClass
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    proof :=
  { classEq := hClass
    executionCorrect := executionCorrect_of_opcodeClassProof proof
    executionTrace := proof.semantics.traceCorrect
    frameRows :=
      frameRowsBound_of_executionTraceCorrect proof.semantics.traceCorrect
    executionLinked :=
      executionLinked_of_executionTraceCorrect proof.semantics.traceCorrect
    executionTraceEndpoints :=
      executionTraceEndpoints_of_executionTraceCorrect proof.semantics.traceCorrect
    expandedRowSequence :=
      expandedRowSequenceBound_of_executionCorrect proof.semantics.correct
    preparedStepExport :=
      preparedStepExportBound_of_executionCorrect proof.semantics.correct
    expandedBytecodeExecution :=
      expandedBytecodeExecutionBound_of_executionCorrect proof.semantics.correct
    fullSequenceTerminated := by
      exact proof.semantics.correct.2.2.2.1
    boundaryStartPc :=
      boundaryStartPc_of_executionCorrect proof.semantics.correct
    boundaryPcNext :=
      boundaryPcNext_of_executionCorrect proof.semantics.correct
    boundaryTerminates :=
      boundaryTerminates_of_executionCorrect proof.semantics.correct
    finalStateHalted :=
      finalState_halted_of_executionCorrect proof.semantics.correct
    rowsHaveClass := by
      intro row hRow
      calc
        row.opcodeClass = proof.opcodeClass := row_opcodeClass_of_opcodeClassProof proof hRow
        _ = opcodeClass := hClass }

def canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  CanonicalOpcodeClassSemantics canonical :=
  { nativeAlu := executionFacts_cast canonical.nativeAluClass
    wordShift := executionFacts_cast canonical.wordShiftClass
    controlFlow := executionFacts_cast canonical.controlFlowClass
    narrowMemory := executionFacts_cast canonical.narrowMemoryClass
    multiply := executionFacts_cast canonical.multiplyClass
    unsignedDivRem := executionFacts_cast canonical.unsignedDivRemClass
    signedDivRem := executionFacts_cast canonical.signedDivRemClass }

def nativeAluFacts_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  OpcodeClassExecutionFacts
    .nativeAlu
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    canonical.nativeAlu :=
  (canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs canonical).nativeAlu

def wordShiftFacts_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  OpcodeClassExecutionFacts
    .wordShift
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    canonical.wordShift :=
  (canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs canonical).wordShift

def controlFlowFacts_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  OpcodeClassExecutionFacts
    .controlFlow
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    canonical.controlFlow :=
  (canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs canonical).controlFlow

def narrowMemoryFacts_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  OpcodeClassExecutionFacts
    .narrowMemory
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    canonical.narrowMemory :=
  (canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs canonical).narrowMemory

def multiplyFacts_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  OpcodeClassExecutionFacts
    .multiply
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    canonical.multiply :=
  (canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs canonical).multiply

def unsignedDivRemFacts_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  OpcodeClassExecutionFacts
    .unsignedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    canonical.unsignedDivRem :=
  (canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs canonical).unsignedDivRem

def signedDivRemFacts_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  OpcodeClassExecutionFacts
    .signedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    canonical.signedDivRem :=
  (canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs canonical).signedDivRem

noncomputable def canonicalOpcodeClassSemantics_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  CanonicalOpcodeClassSemantics
    (canonicalOpcodeProofs_of_stepComposition pkg) :=
  canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs
    (canonicalOpcodeProofs_of_stepComposition pkg)

noncomputable def nativeAluFacts_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  OpcodeClassExecutionFacts
    .nativeAlu
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_stepComposition pkg).nativeAlu :=
  nativeAluFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_stepComposition pkg)

noncomputable def wordShiftFacts_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  OpcodeClassExecutionFacts
    .wordShift
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_stepComposition pkg).wordShift :=
  wordShiftFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_stepComposition pkg)

noncomputable def controlFlowFacts_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  OpcodeClassExecutionFacts
    .controlFlow
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_stepComposition pkg).controlFlow :=
  controlFlowFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_stepComposition pkg)

noncomputable def narrowMemoryFacts_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  OpcodeClassExecutionFacts
    .narrowMemory
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_stepComposition pkg).narrowMemory :=
  narrowMemoryFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_stepComposition pkg)

noncomputable def multiplyFacts_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  OpcodeClassExecutionFacts
    .multiply
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_stepComposition pkg).multiply :=
  multiplyFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_stepComposition pkg)

noncomputable def unsignedDivRemFacts_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  OpcodeClassExecutionFacts
    .unsignedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem :=
  unsignedDivRemFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_stepComposition pkg)

noncomputable def signedDivRemFacts_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
      PreparedStep) :
  OpcodeClassExecutionFacts
    .signedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem :=
  signedDivRemFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_stepComposition pkg)

end Nightstream.Rv64IM
