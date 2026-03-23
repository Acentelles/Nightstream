import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.MultiplyOpcodeSemantics

/-!
Owns lifting of exact multiply opcode consequences through the authenticated
trace and exact trace-boundary surfaces.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]

theorem opcodeBound_of_authenticatedChunkTrace_multiply
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
  MultiplyOpcodeBound
    trace.stepComposition.multiplyAluOps
    trace.stepComposition.decodedRow
    trace.stepComposition.multiplyOpcode :=
  opcodeBound_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem flags_of_authenticatedChunkTrace_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode) :
  trace.stepComposition.decodedRow.isJal = false ∧
    trace.stepComposition.decodedRow.isJalr = false ∧
    trace.stepComposition.decodedRow.isBranch = false ∧
    trace.stepComposition.decodedRow.isLoad = false ∧
    trace.stepComposition.decodedRow.isStore = false ∧
    trace.stepComposition.decodedRow.isDiv = false ∧
    trace.stepComposition.decodedRow.isRem = false ∧
    trace.stepComposition.decodedRow.isMul = true ∧
    trace.stepComposition.decodedRow.usesRs2 = true ∧
    trace.stepComposition.decodedRow.writesMemToRd = false ∧
    trace.stepComposition.decodedRow.isWOp = opcode.isWOp ∧
    trace.stepComposition.decodedRow.aluOp =
      trace.stepComposition.multiplyAluOps.forOpcode opcode :=
  flags_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem x0WritePreserved_of_authenticatedChunkTrace_multiply
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
  x0WritePreserved_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hRd

theorem registerOperands_of_authenticatedChunkTrace_multiply
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
  trace.stepComposition.twistBinding.registerTwist.rvRs1 =
      trace.stepComposition.twistBinding.registerLane.rs1 ∧
    trace.stepComposition.twistBinding.registerTwist.rvRs2 =
      trace.stepComposition.twistBinding.registerLane.rs2 :=
  registerOperands_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem activeWrite_of_authenticatedChunkTrace_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.decodedRow.preservesRd = false ∧
    trace.stepComposition.decodedRow.writesAluToRd = true ∧
    trace.stepComposition.decodedRow.writesMemToRd = false :=
  activeWrite_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem authenticatedWriteback_of_activeMultiply_authenticatedChunkTrace
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.twistBinding.registerLane.rdNext :=
  authenticatedWriteback_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem routedWriteback_of_activeMultiply_authenticatedChunkTrace
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerLane.rdNext =
      trace.stepComposition.aluWritebackValue :=
  routedWriteback_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem authenticatedRoutedWriteback_of_activeMultiply_authenticatedChunkTrace
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.aluWritebackValue :=
  authenticatedRoutedWriteback_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem encodedAluOut_of_activeMultiply_authenticatedChunkTrace
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.lane.aluOut =
      trace.stepComposition.aluWritebackValue :=
  encodedAluOut_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem encodedAluResult_of_activeMultiply_authenticatedChunkTrace
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
      trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem authenticatedEncodedAluOut_of_activeMultiply_authenticatedChunkTrace
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.lane.aluOut :=
  authenticatedEncodedAluOut_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem authenticatedEncodedAluResult_of_activeMultiply_authenticatedChunkTrace
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_activeMultiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem sequenceCorrect_of_multiply_authenticatedChunkTrace
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
  {_opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).multiplySequenceProof.sequence
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).multiplySequenceProof.touchedState
    trace.stepComposition.rowAssertions
    trace.stepComposition.committedResult
    trace.stepComposition.isaResult
    trace.stepComposition.preservedState :=
  sequenceCorrect_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem sequenceDeterministic_of_multiply_authenticatedChunkTrace
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
  {_opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = _opcode) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).multiplySequenceProof.sequence
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).multiplySequenceProof.touchedState
    trace.stepComposition.rowAssertions
    trace.stepComposition.committedResult :=
  sequenceDeterministic_of_multiplyOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem flags_of_exactBoundaries_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode) :
  boundaries.stepComposition.decodedRow.isJal = false ∧
    boundaries.stepComposition.decodedRow.isJalr = false ∧
    boundaries.stepComposition.decodedRow.isBranch = false ∧
    boundaries.stepComposition.decodedRow.isLoad = false ∧
    boundaries.stepComposition.decodedRow.isStore = false ∧
    boundaries.stepComposition.decodedRow.isDiv = false ∧
    boundaries.stepComposition.decodedRow.isRem = false ∧
    boundaries.stepComposition.decodedRow.isMul = true ∧
    boundaries.stepComposition.decodedRow.usesRs2 = true ∧
    boundaries.stepComposition.decodedRow.writesMemToRd = false ∧
    boundaries.stepComposition.decodedRow.isWOp = opcode.isWOp ∧
    boundaries.stepComposition.decodedRow.aluOp =
      boundaries.stepComposition.multiplyAluOps.forOpcode opcode := by
  simpa using
    flags_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem x0WritePreserved_of_exactBoundaries_multiply
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
  simpa using
    x0WritePreserved_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hRd

theorem registerOperands_of_exactBoundaries_multiply
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
  boundaries.stepComposition.twistBinding.registerTwist.rvRs1 =
      boundaries.stepComposition.twistBinding.registerLane.rs1 ∧
    boundaries.stepComposition.twistBinding.registerTwist.rvRs2 =
      boundaries.stepComposition.twistBinding.registerLane.rs2 := by
  simpa using
    registerOperands_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem activeWrite_of_exactBoundaries_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.decodedRow.preservesRd = false ∧
    boundaries.stepComposition.decodedRow.writesAluToRd = true ∧
    boundaries.stepComposition.decodedRow.writesMemToRd = false := by
  simpa using
    activeWrite_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedWriteback_of_activeMultiply_exactBoundaries
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.twistBinding.registerLane.rdNext := by
  simpa using
    authenticatedWriteback_of_activeMultiply_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem routedWriteback_of_activeMultiply_exactBoundaries
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerLane.rdNext =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    routedWriteback_of_activeMultiply_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedRoutedWriteback_of_activeMultiply_exactBoundaries
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    authenticatedRoutedWriteback_of_activeMultiply_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem encodedAluOut_of_activeMultiply_exactBoundaries
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.lane.aluOut =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    encodedAluOut_of_activeMultiply_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem encodedAluResult_of_activeMultiply_exactBoundaries
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.results.aluResult =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    encodedAluResult_of_activeMultiply_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedEncodedAluOut_of_activeMultiply_exactBoundaries
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.lane.aluOut := by
  simpa using
    authenticatedEncodedAluOut_of_activeMultiply_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedEncodedAluResult_of_activeMultiply_exactBoundaries
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.results.aluResult := by
  simpa using
    authenticatedEncodedAluResult_of_activeMultiply_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
