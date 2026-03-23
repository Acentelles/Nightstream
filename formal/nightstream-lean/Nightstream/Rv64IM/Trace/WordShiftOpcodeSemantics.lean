import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.WordShiftOpcodeSemantics

/-!
Owns lifting of exact word/shift opcode consequences through the authenticated
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

theorem opcodeBound_of_authenticatedChunkTrace_wordShift
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
      PreparedStep) :
  WordShiftOpcodeBound
    trace.stepComposition.wordShiftAluOps
    trace.stepComposition.decodedRow
    trace.stepComposition.wordShiftOpcode :=
  opcodeBound_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem flags_of_authenticatedChunkTrace_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode : trace.stepComposition.wordShiftOpcode = opcode) :
  trace.stepComposition.decodedRow.isWOp = true ∧
    trace.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    trace.stepComposition.decodedRow.aluOp =
      trace.stepComposition.wordShiftAluOps.forOpcode opcode :=
  flags_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem sraw_flags_of_authenticatedChunkTrace
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
  (hOpcode : trace.stepComposition.wordShiftOpcode = .sraw) :
  trace.stepComposition.decodedRow.isWOp = true ∧
    trace.stepComposition.decodedRow.usesRs2 = true ∧
    trace.stepComposition.decodedRow.aluOp = trace.stepComposition.wordShiftAluOps.sra :=
  sraw_flags_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem sraiw_flags_of_authenticatedChunkTrace
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
  (hOpcode : trace.stepComposition.wordShiftOpcode = .sraiw) :
  trace.stepComposition.decodedRow.isWOp = true ∧
    trace.stepComposition.decodedRow.usesRs2 = false ∧
    trace.stepComposition.decodedRow.aluOp = trace.stepComposition.wordShiftAluOps.sra :=
  sraiw_flags_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem sequenceCorrect_of_wordShift_authenticatedChunkTrace
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
      PreparedStep) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).wordShiftSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).wordShiftSequenceProof.touchedState
    trace.stepComposition.rowAssertions
    trace.stepComposition.committedResult
    trace.stepComposition.isaResult
    trace.stepComposition.preservedState :=
  sequenceCorrect_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem sequenceDeterministic_of_wordShift_authenticatedChunkTrace
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
      PreparedStep) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).wordShiftSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).wordShiftSequenceProof.touchedState
    trace.stepComposition.rowAssertions
    trace.stepComposition.committedResult :=
  sequenceDeterministic_of_wordShiftOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem sraw_flags_of_exactBoundaries
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
  (hOpcode : boundaries.stepComposition.wordShiftOpcode = .sraw) :
  boundaries.stepComposition.decodedRow.isWOp = true ∧
    boundaries.stepComposition.decodedRow.usesRs2 = true ∧
    boundaries.stepComposition.decodedRow.aluOp = boundaries.stepComposition.wordShiftAluOps.sra := by
  exact
    sraw_flags_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem sequenceCorrect_of_wordShift_of_exactBoundaries
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
      PreparedStep) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).wordShiftSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).wordShiftSequenceProof.touchedState
    boundaries.stepComposition.rowAssertions
    boundaries.stepComposition.committedResult
    boundaries.stepComposition.isaResult
    boundaries.stepComposition.preservedState := by
  exact
    sequenceCorrect_of_wordShift_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)

end

end Nightstream.Rv64IM
