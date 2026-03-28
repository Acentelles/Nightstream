import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.NarrowMemoryOpcodeSemantics

/-!
Owns lifting of exact narrow-memory opcode consequences through the
authenticated trace and exact trace-boundary surfaces.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]

theorem flags_of_authenticatedChunkTrace_narrowMemory
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
  {widths : NarrowMemoryWidths MemWidth}
  {opcode : NarrowMemoryOpcode}
  (hOpcode : NarrowMemoryOpcodeBound widths trace.stepComposition.decodedRow opcode) :
  trace.stepComposition.decodedRow.isLoad = opcode.isLoad ∧
    trace.stepComposition.decodedRow.isStore = opcode.isStore ∧
    trace.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    trace.stepComposition.decodedRow.writesAluToRd = false ∧
    trace.stepComposition.decodedRow.memWidth = widths.forOpcode opcode ∧
    trace.stepComposition.decodedRow.memUnsigned = opcode.memUnsigned :=
  flags_of_narrowMemoryOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem x0WritePreserved_of_authenticatedChunkTrace_narrowMemory
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
  (hRd : trace.stepComposition.decodedRow.rd = trace.stepComposition.x0) :
  trace.stepComposition.decodedRow.preservesRd = true ∧
    trace.stepComposition.decodedRow.writesAluToRd = false ∧
    trace.stepComposition.decodedRow.writesMemToRd = false :=
  x0WritePreserved_of_narrowMemoryOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hRd

theorem sequenceCorrect_of_narrowMemory_authenticatedChunkTrace
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
  {widths : NarrowMemoryWidths MemWidth}
  {_opcode : NarrowMemoryOpcode}
  (hOpcode : NarrowMemoryOpcodeBound widths trace.stepComposition.decodedRow _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).narrowMemorySequenceProof.sequence
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).narrowMemorySequenceProof.touchedState
    trace.stepComposition.rowAssertions
    trace.stepComposition.committedResult
    trace.stepComposition.isaResult
    trace.stepComposition.preservedState :=
  sequenceCorrect_of_narrowMemoryOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem flags_of_exactBoundaries_narrowMemory
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
  {widths : NarrowMemoryWidths MemWidth}
  {opcode : NarrowMemoryOpcode}
  (hOpcode : NarrowMemoryOpcodeBound widths boundaries.stepComposition.decodedRow opcode) :
  boundaries.stepComposition.decodedRow.isLoad = opcode.isLoad ∧
    boundaries.stepComposition.decodedRow.isStore = opcode.isStore ∧
    boundaries.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    boundaries.stepComposition.decodedRow.writesAluToRd = false ∧
    boundaries.stepComposition.decodedRow.memWidth = widths.forOpcode opcode ∧
    boundaries.stepComposition.decodedRow.memUnsigned = opcode.memUnsigned := by
  exact
    flags_of_authenticatedChunkTrace_narrowMemory
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem x0WritePreserved_of_exactBoundaries_narrowMemory
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
  (hRd : boundaries.stepComposition.decodedRow.rd = boundaries.stepComposition.x0) :
  boundaries.stepComposition.decodedRow.preservesRd = true ∧
    boundaries.stepComposition.decodedRow.writesAluToRd = false ∧
    boundaries.stepComposition.decodedRow.writesMemToRd = false := by
  exact
    x0WritePreserved_of_authenticatedChunkTrace_narrowMemory
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hRd

end

end Nightstream.Rv64IM
