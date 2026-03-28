import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.NativeAluOpcodeSemantics

/-!
Owns lifting of exact native-ALU opcode consequences through the authenticated
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

theorem opcodeBound_of_authenticatedChunkTrace_nativeAlu
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
  NativeAluOpcodeBound
    trace.stepComposition.nativeAluOps
    trace.stepComposition.decodedRow
    trace.stepComposition.nativeAluOpcode :=
  opcodeBound_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem flags_of_authenticatedChunkTrace_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode) :
  trace.stepComposition.decodedRow.isJal = false ∧
    trace.stepComposition.decodedRow.isJalr = false ∧
    trace.stepComposition.decodedRow.isBranch = false ∧
    trace.stepComposition.decodedRow.isLoad = false ∧
    trace.stepComposition.decodedRow.isStore = false ∧
    trace.stepComposition.decodedRow.isWOp = false ∧
    trace.stepComposition.decodedRow.isMul = false ∧
    trace.stepComposition.decodedRow.isDiv = false ∧
    trace.stepComposition.decodedRow.isRem = false ∧
    trace.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    trace.stepComposition.decodedRow.writesMemToRd = false ∧
    trace.stepComposition.decodedRow.aluOp =
      trace.stepComposition.nativeAluOps.forOpcode opcode :=
  flags_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem x0WritePreserved_of_authenticatedChunkTrace_nativeAlu
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
  x0WritePreserved_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hRd

theorem registerOperands_of_authenticatedChunkTrace_nativeAlu
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
  registerOperands_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem nonX0WriteFacts_of_authenticatedChunkTrace_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  if opcode.writesArchitecturalRd then
    trace.stepComposition.decodedRow.preservesRd = false ∧
      trace.stepComposition.decodedRow.writesAluToRd = true ∧
      trace.stepComposition.decodedRow.writesMemToRd = false
  else
    trace.stepComposition.decodedRow.preservesRd = true ∧
      trace.stepComposition.decodedRow.writesAluToRd = false ∧
      trace.stepComposition.decodedRow.writesMemToRd = false :=
  nonX0WriteFacts_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hRd

theorem activeWrite_of_authenticatedChunkTrace_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.decodedRow.preservesRd = false ∧
    trace.stepComposition.decodedRow.writesAluToRd = true ∧
    trace.stepComposition.decodedRow.writesMemToRd = false :=
  activeWrite_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem passiveWrite_of_authenticatedChunkTrace_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = false)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.decodedRow.preservesRd = true ∧
    trace.stepComposition.decodedRow.writesAluToRd = false ∧
    trace.stepComposition.decodedRow.writesMemToRd = false :=
  passiveWrite_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem authenticatedWriteback_of_activeNativeAlu_authenticatedChunkTrace
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.twistBinding.registerLane.rdNext :=
  authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem routedWriteback_of_activeNativeAlu_authenticatedChunkTrace
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerLane.rdNext =
      trace.stepComposition.aluWritebackValue :=
  routedWriteback_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem authenticatedRoutedWriteback_of_activeNativeAlu_authenticatedChunkTrace
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.aluWritebackValue :=
  authenticatedRoutedWriteback_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem encodedAluOut_of_activeNativeAlu_authenticatedChunkTrace
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.lane.aluOut =
      trace.stepComposition.aluWritebackValue :=
  encodedAluOut_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem encodedAluResult_of_activeNativeAlu_authenticatedChunkTrace
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
      trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem authenticatedEncodedAluOut_of_activeNativeAlu_authenticatedChunkTrace
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.lane.aluOut :=
  authenticatedEncodedAluOut_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem authenticatedEncodedAluResult_of_activeNativeAlu_authenticatedChunkTrace
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
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
      trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_activeNativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode
    hWrites
    hRd

theorem ecall_terminates_of_authenticatedChunkTrace
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
  (hOpcode : trace.stepComposition.nativeAluOpcode = .ecall) :
  (canonicalOpcodeProofs_of_stepComposition trace.stepComposition).nativeAlu.semantics.boundary.terminates =
      true ∧
    (canonicalOpcodeProofs_of_stepComposition trace.stepComposition).nativeAlu.semantics.finalState.halted =
      true :=
  ecall_terminates_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem sequenceCorrect_of_nativeAlu_authenticatedChunkTrace
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
  {_opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).nativeAluSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).nativeAluSequenceProof.touchedState
    trace.stepComposition.rowAssertions
    trace.stepComposition.committedResult
    trace.stepComposition.isaResult
    trace.stepComposition.preservedState :=
  sequenceCorrect_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem sequenceDeterministic_of_nativeAlu_authenticatedChunkTrace
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
  {_opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = _opcode) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).nativeAluSequenceProof.sequence
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).nativeAluSequenceProof.touchedState
    trace.stepComposition.rowAssertions
    trace.stepComposition.committedResult :=
  sequenceDeterministic_of_nativeAluOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem flags_of_exactBoundaries_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode) :
  boundaries.stepComposition.decodedRow.isJal = false ∧
    boundaries.stepComposition.decodedRow.isJalr = false ∧
    boundaries.stepComposition.decodedRow.isBranch = false ∧
    boundaries.stepComposition.decodedRow.isLoad = false ∧
    boundaries.stepComposition.decodedRow.isStore = false ∧
    boundaries.stepComposition.decodedRow.isWOp = false ∧
    boundaries.stepComposition.decodedRow.isMul = false ∧
    boundaries.stepComposition.decodedRow.isDiv = false ∧
    boundaries.stepComposition.decodedRow.isRem = false ∧
    boundaries.stepComposition.decodedRow.usesRs2 = opcode.usesRs2 ∧
    boundaries.stepComposition.decodedRow.writesMemToRd = false ∧
    boundaries.stepComposition.decodedRow.aluOp =
      boundaries.stepComposition.nativeAluOps.forOpcode opcode := by
  exact
    flags_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem x0WritePreserved_of_exactBoundaries_nativeAlu
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
    x0WritePreserved_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hRd

theorem registerOperands_of_exactBoundaries_nativeAlu
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
    registerOperands_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)

theorem nonX0WriteFacts_of_exactBoundaries_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  if opcode.writesArchitecturalRd then
    boundaries.stepComposition.decodedRow.preservesRd = false ∧
      boundaries.stepComposition.decodedRow.writesAluToRd = true ∧
      boundaries.stepComposition.decodedRow.writesMemToRd = false
  else
    boundaries.stepComposition.decodedRow.preservesRd = true ∧
      boundaries.stepComposition.decodedRow.writesAluToRd = false ∧
      boundaries.stepComposition.decodedRow.writesMemToRd = false := by
  simpa using
    nonX0WriteFacts_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem activeWrite_of_exactBoundaries_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.decodedRow.preservesRd = false ∧
    boundaries.stepComposition.decodedRow.writesAluToRd = true ∧
    boundaries.stepComposition.decodedRow.writesMemToRd = false := by
  simpa using
    activeWrite_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem passiveWrite_of_exactBoundaries_nativeAlu
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = false)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.decodedRow.preservesRd = true ∧
    boundaries.stepComposition.decodedRow.writesAluToRd = false ∧
    boundaries.stepComposition.decodedRow.writesMemToRd = false := by
  simpa using
    passiveWrite_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedWriteback_of_activeNativeAlu_exactBoundaries
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.twistBinding.registerLane.rdNext := by
  simpa using
    authenticatedWriteback_of_activeNativeAlu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem routedWriteback_of_activeNativeAlu_exactBoundaries
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerLane.rdNext =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    routedWriteback_of_activeNativeAlu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedRoutedWriteback_of_activeNativeAlu_exactBoundaries
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    authenticatedRoutedWriteback_of_activeNativeAlu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem encodedAluOut_of_activeNativeAlu_exactBoundaries
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.lane.aluOut =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    encodedAluOut_of_activeNativeAlu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem encodedAluResult_of_activeNativeAlu_exactBoundaries
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.results.aluResult =
      boundaries.stepComposition.aluWritebackValue := by
  simpa using
    encodedAluResult_of_activeNativeAlu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedEncodedAluOut_of_activeNativeAlu_exactBoundaries
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.lane.aluOut := by
  simpa using
    authenticatedEncodedAluOut_of_activeNativeAlu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedEncodedAluResult_of_activeNativeAlu_exactBoundaries
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
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
      boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.results.aluResult := by
  simpa using
    authenticatedEncodedAluResult_of_activeNativeAlu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem ecall_terminates_of_exactBoundaries
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
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = .ecall) :
  (canonicalOpcodeProofs_of_stepComposition boundaries.stepComposition).nativeAlu.semantics.boundary.terminates =
      true ∧
    (canonicalOpcodeProofs_of_stepComposition boundaries.stepComposition).nativeAlu.semantics.finalState.halted =
      true := by
  exact
    ecall_terminates_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
