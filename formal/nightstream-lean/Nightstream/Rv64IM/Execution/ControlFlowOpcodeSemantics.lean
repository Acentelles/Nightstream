import Nightstream.Rv64IM.Execution.ControlFlowLoweringSemantics

/-!
Owns exact theorem-facing opcode consequences for the control-flow family. This
file sits above control-flow lowering semantics and closes the exact-opcode gap
for `JAL`, `JALR`, and generic branch opcodes carried by the decoded `branchOp`
field.
-/

namespace Nightstream.Rv64IM

inductive ControlFlowOpcode (BranchOp : Type _) where
  | jal
  | jalr
  | branch (op : BranchOp)
deriving Repr, DecidableEq

def ControlFlowOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : ControlFlowOpcode BranchOp) : Prop :=
  match opcode with
  | .jal =>
      row.isJal = true ∧ row.isJalr = false ∧ row.isBranch = false
  | .jalr =>
      row.isJal = false ∧ row.isJalr = true ∧ row.isBranch = false
  | .branch op =>
      row.isJal = false ∧ row.isJalr = false ∧ row.isBranch = true ∧ row.branchOp = op

theorem isJal_of_controlFlowOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : ControlFlowOpcode BranchOp}
  (h : ControlFlowOpcodeBound row opcode) :
  row.isJal =
    match opcode with
    | .jal => true
    | .jalr => false
    | .branch _ => false := by
  cases opcode <;> simpa [ControlFlowOpcodeBound] using h.1

theorem isJalr_of_controlFlowOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : ControlFlowOpcode BranchOp}
  (h : ControlFlowOpcodeBound row opcode) :
  row.isJalr =
    match opcode with
    | .jal => false
    | .jalr => true
    | .branch _ => false := by
  cases opcode with
  | jal =>
      simpa [ControlFlowOpcodeBound] using h.2.1
  | jalr =>
      simpa [ControlFlowOpcodeBound] using h.2.1
  | branch _ =>
      simpa [ControlFlowOpcodeBound] using h.2.1

theorem isBranch_of_controlFlowOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : ControlFlowOpcode BranchOp}
  (h : ControlFlowOpcodeBound row opcode) :
  row.isBranch =
    match opcode with
    | .jal => false
    | .jalr => false
    | .branch _ => true := by
  cases opcode with
  | jal =>
      simpa [ControlFlowOpcodeBound] using h.2.2
  | jalr =>
      simpa [ControlFlowOpcodeBound] using h.2.2
  | branch _ =>
      simpa [ControlFlowOpcodeBound] using h.2.2.1

theorem branchOp_of_controlFlowOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {op : BranchOp}
  (h : ControlFlowOpcodeBound row (.branch op)) :
  row.branchOp = op :=
  h.2.2.2

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]
  {pkg :
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
      PreparedStep}

private theorem controlFlowLaneLinkageFacts
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
  pkg.executionRow.lane.isJal = pkg.executionRow.row.isJal ∧
    pkg.executionRow.lane.isJalr = pkg.executionRow.row.isJalr ∧
    pkg.executionRow.lane.isBranch = pkg.executionRow.row.isBranch ∧
    pkg.executionRow.lane.branchTaken = pkg.executionRow.results.branchTaken ∧
    pkg.executionRow.lane.branchTakenMux =
      branchTakenMux pkg.executionRow.row.isBranch pkg.executionRow.results.branchTaken := by
  rcases stage1LinkageBound_of_stepComposition pkg with
    ⟨_, _, _, _, _, _, _, _, hJal, hJalr, hBranch, _, _, _, _, _, _, _, _, hTaken, hTakenMux, _⟩
  exact ⟨hJal, hJalr, hBranch, hTaken, hTakenMux⟩

theorem jal_flags_of_controlFlowOpcodeSemantics
  (_facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow .jal) :
  pkg.decodedRow.isJal = true ∧
    pkg.decodedRow.isJalr = false ∧
    pkg.decodedRow.isBranch = false :=
  hOpcode

theorem jalr_flags_of_controlFlowOpcodeSemantics
  (_facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow .jalr) :
  pkg.decodedRow.isJal = false ∧
    pkg.decodedRow.isJalr = true ∧
    pkg.decodedRow.isBranch = false :=
  hOpcode

theorem branch_flags_of_controlFlowOpcodeSemantics
  (_facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow (.branch op)) :
  pkg.decodedRow.isJal = false ∧
    pkg.decodedRow.isJalr = false ∧
    pkg.decodedRow.isBranch = true ∧
    pkg.decodedRow.branchOp = op :=
  hOpcode

theorem lane_isJal_of_controlFlowOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow .jal) :
  facts.controlFlow.lane.isJal = true := by
  rcases controlFlowLaneLinkageFacts pkg with ⟨hJal, _, _, _, _⟩
  have hLane :
      facts.controlFlow.lane.isJal = pkg.executionRow.row.isJal := by
    simpa [facts.controlFlowLaneEq] using hJal
  have hRow :
      pkg.executionRow.row.isJal = true := by
    simpa [decodedRow_eq_executionRow_of_stepComposition pkg]
      using hOpcode.1
  exact hLane.trans hRow

theorem lane_isJalr_of_controlFlowOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow .jalr) :
  facts.controlFlow.lane.isJalr = true := by
  rcases controlFlowLaneLinkageFacts pkg with ⟨_, hJalr, _, _, _⟩
  have hLane :
      facts.controlFlow.lane.isJalr = pkg.executionRow.row.isJalr := by
    simpa [facts.controlFlowLaneEq] using hJalr
  have hRow :
      pkg.executionRow.row.isJalr = true := by
    simpa [decodedRow_eq_executionRow_of_stepComposition pkg]
      using hOpcode.2.1
  exact hLane.trans hRow

theorem lane_isBranch_of_controlFlowOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow (.branch op)) :
  facts.controlFlow.lane.isBranch = true := by
  rcases controlFlowLaneLinkageFacts pkg with ⟨_, _, hBranch, _, _⟩
  have hLane :
      facts.controlFlow.lane.isBranch = pkg.executionRow.row.isBranch := by
    simpa [facts.controlFlowLaneEq] using hBranch
  have hRow :
      pkg.executionRow.row.isBranch = true := by
    simpa [decodedRow_eq_executionRow_of_stepComposition pkg]
      using hOpcode.2.2.1
  exact hLane.trans hRow

theorem branchOp_of_controlFlowOpcodeSemantics
  (_facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow (.branch op)) :
  pkg.decodedRow.branchOp = op :=
  hOpcode.2.2.2

theorem takenTargetAlignment_of_jalOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow .jal) :
  NaturalAlignment .word
    (facts.controlFlow.wordToNat facts.controlFlow.lane.jumpTarget) := by
  apply takenTargetAlignment_of_controlFlowLoweringSemantics facts
  exact Or.inl (lane_isJal_of_controlFlowOpcodeSemantics facts hOpcode)

theorem takenTargetAlignment_of_jalrOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow .jalr) :
  NaturalAlignment .word
    (facts.controlFlow.wordToNat facts.controlFlow.lane.jumpTarget) := by
  apply takenTargetAlignment_of_controlFlowLoweringSemantics facts
  exact Or.inr <| Or.inl (lane_isJalr_of_controlFlowOpcodeSemantics facts hOpcode)

theorem takenBranchMux_of_controlFlowOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow (.branch op))
  (hTaken : facts.controlFlow.lane.branchTaken = true) :
  facts.controlFlow.lane.branchTakenMux = true := by
  rcases controlFlowLaneLinkageFacts pkg with ⟨_, _, _, hBranchTaken, hBranchTakenMux⟩
  have hRowBranch :
      pkg.executionRow.row.isBranch = true := by
    simpa [decodedRow_eq_executionRow_of_stepComposition pkg]
      using hOpcode.2.2.1
  have hLaneTaken :
      pkg.executionRow.lane.branchTaken = true := by
    simpa [facts.controlFlowLaneEq] using hTaken
  have hResultTaken :
      pkg.executionRow.results.branchTaken = true := by
    exact hBranchTaken.symm.trans hLaneTaken
  have hTakenMux :
      facts.controlFlow.lane.branchTakenMux =
        branchTakenMux pkg.executionRow.row.isBranch pkg.executionRow.results.branchTaken := by
    simpa [facts.controlFlowLaneEq] using hBranchTakenMux
  calc
    facts.controlFlow.lane.branchTakenMux
      = branchTakenMux pkg.executionRow.row.isBranch pkg.executionRow.results.branchTaken := hTakenMux
    _ = true := by
      simp [branchTakenMux, hRowBranch, hResultTaken]

theorem takenTargetAlignment_of_takenBranchOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound pkg.decodedRow (.branch op))
  (hTaken : facts.controlFlow.lane.branchTaken = true) :
  NaturalAlignment .word
    (facts.controlFlow.wordToNat facts.controlFlow.lane.jumpTarget) := by
  apply takenTargetAlignment_of_controlFlowLoweringSemantics facts
  exact Or.inr <| Or.inr
    (takenBranchMux_of_controlFlowOpcodeSemantics facts hOpcode hTaken)

theorem sequenceCorrect_of_controlFlowOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.controlFlowSequenceProof.sequence
    facts.controlFlowSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  sequenceCorrect_of_controlFlowLoweringSemantics facts

theorem sequenceDeterministic_of_controlFlowOpcodeSemantics
  (facts :
    ExactOpcodeFamilySemantics
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
      pkg) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.controlFlowSequenceProof.sequence
    facts.controlFlowSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  sequenceDeterministic_of_controlFlowLoweringSemantics facts

end

end Nightstream.Rv64IM
