import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.ControlFlowOpcodeSemantics

/-!
Owns lifting of exact control-flow opcode consequences through the authenticated
trace and exact trace-boundary surfaces. This file does not re-own execution
semantics or kernel-level conclusions.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]

theorem lane_isJal_of_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow .jal) :
  (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.isJal = true :=
  lane_isJal_of_controlFlowOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem lane_isJalr_of_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow .jalr) :
  (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.isJalr = true :=
  lane_isJalr_of_controlFlowOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem lane_isBranch_of_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow (.branch op)) :
  (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.isBranch = true :=
  lane_isBranch_of_controlFlowOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem branchOp_of_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow (.branch op)) :
  trace.stepComposition.decodedRow.branchOp = op :=
  branchOp_of_controlFlowOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem takenTargetAlignment_of_jal_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow .jal) :
  NaturalAlignment
    .word
    ((exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.wordToNat
      (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.jumpTarget) :=
  takenTargetAlignment_of_jalOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem takenTargetAlignment_of_jalr_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow .jalr) :
  NaturalAlignment
    .word
    ((exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.wordToNat
      (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.jumpTarget) :=
  takenTargetAlignment_of_jalrOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem takenBranchMux_of_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow (.branch op))
  (hTaken :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.branchTaken = true) :
  (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.branchTakenMux = true :=
  takenBranchMux_of_controlFlowOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hTaken

theorem takenTargetAlignment_of_takenBranch_authenticatedChunkTrace
  (trace :
    AuthenticatedChunkTrace
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
      PreparedStep)
  {op : BranchOp}
  (hOpcode : ControlFlowOpcodeBound trace.stepComposition.decodedRow (.branch op))
  (hTaken :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.branchTaken = true) :
  NaturalAlignment
    .word
    ((exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.wordToNat
      (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).controlFlow.lane.jumpTarget) :=
  takenTargetAlignment_of_takenBranchOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hTaken

theorem lane_isJal_of_exactBoundaries
  (boundaries :
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
      PreparedStep)
  (hOpcode : ControlFlowOpcodeBound boundaries.stepComposition.decodedRow .jal) :
  (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).controlFlow.lane.isJal = true := by
  simpa [exactOpcodeFamilySemantics_of_exactBoundaries] using
    lane_isJal_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem takenTargetAlignment_of_jal_of_exactBoundaries
  (boundaries :
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
      PreparedStep)
  (hOpcode : ControlFlowOpcodeBound boundaries.stepComposition.decodedRow .jal) :
  NaturalAlignment
    .word
    ((exactOpcodeFamilySemantics_of_exactBoundaries boundaries).controlFlow.wordToNat
      (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).controlFlow.lane.jumpTarget) := by
  simpa [exactOpcodeFamilySemantics_of_exactBoundaries] using
    takenTargetAlignment_of_jal_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
