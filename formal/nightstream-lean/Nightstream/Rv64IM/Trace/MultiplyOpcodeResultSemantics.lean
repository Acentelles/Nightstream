import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.MultiplyOpcodeResultSemantics

/-!
Owns lifting of exact multiply encoded-result consequences through the
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

theorem encodedAluResult_of_authenticatedChunkTrace_multiply
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
    trace.stepComposition.aluWritebackValue := by
  cases opcode with
  | mul =>
      simpa using
        (mul_encodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulh =>
      simpa using
        (mulh_encodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulhu =>
      simpa using
        (mulhu_encodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulhsu =>
      simpa using
        (mulhsu_encodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulw =>
      simpa using
        (mulw_encodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)

theorem authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
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
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult := by
  cases opcode with
  | mul =>
      simpa using
        (mul_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulh =>
      simpa using
        (mulh_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulhu =>
      simpa using
        (mulhu_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulhsu =>
      simpa using
        (mulhsu_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | mulw =>
      simpa using
        (mulw_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)

theorem mul_encodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mul)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mul_authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mul)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulh_encodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulh)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulh_authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulh)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulhu_encodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulhu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulhu_authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulhu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulhsu_encodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulhsu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulhsu_authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulhsu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulw_encodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulw)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem mulw_authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.multiplyOpcode = .mulw)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply trace hOpcode hRd

theorem encodedAluResult_of_exactBoundaries_multiply
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
  exact
    encodedAluResult_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

theorem authenticatedEncodedAluResult_of_exactBoundaries_multiply
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
  exact
    authenticatedEncodedAluResult_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
