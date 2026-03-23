import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.NativeAluOpcodeResultSemantics

/-!
Owns lifting of exact native-ALU encoded-result consequences through the
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

theorem encodedAluResult_of_authenticatedChunkTrace_nativeAlu
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
    trace.stepComposition.aluWritebackValue := by
  cases opcode with
  | add =>
      simpa using
        (add_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | addi =>
      simpa using
        (addi_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | sub =>
      simpa using
        (sub_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | andOp =>
      simpa using
        (and_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | andi =>
      simpa using
        (andi_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | orOp =>
      simpa using
        (or_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | ori =>
      simpa using
        (ori_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | xorOp =>
      simpa using
        (xor_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | xori =>
      simpa using
        (xori_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | slt =>
      simpa using
        (slt_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | slti =>
      simpa using
        (slti_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | sltu =>
      simpa using
        (sltu_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | sltiu =>
      simpa using
        (sltiu_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | lui =>
      simpa using
        (lui_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | auipc =>
      simpa using
        (auipc_encodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | fence =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites
  | ecall =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites

theorem authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
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
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult := by
  cases opcode with
  | add =>
      simpa using
        (add_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | addi =>
      simpa using
        (addi_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | sub =>
      simpa using
        (sub_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | andOp =>
      simpa using
        (and_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | andi =>
      simpa using
        (andi_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | orOp =>
      simpa using
        (or_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | ori =>
      simpa using
        (ori_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | xorOp =>
      simpa using
        (xor_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | xori =>
      simpa using
        (xori_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | slt =>
      simpa using
        (slt_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | slti =>
      simpa using
        (slti_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | sltu =>
      simpa using
        (sltu_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | sltiu =>
      simpa using
        (sltiu_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | lui =>
      simpa using
        (lui_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | auipc =>
      simpa using
        (auipc_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) hOpcode hRd)
  | fence =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites
  | ecall =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites

theorem add_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .add)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem add_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .add)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem addi_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .addi)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem addi_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .addi)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sub_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .sub)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sub_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .sub)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem and_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .andOp)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem and_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .andOp)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem andi_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .andi)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem andi_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .andi)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem or_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .orOp)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem or_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .orOp)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem ori_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .ori)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem ori_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .ori)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xor_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .xorOp)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xor_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .xorOp)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xori_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .xori)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xori_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .xori)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slt_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .slt)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slt_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .slt)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slti_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .slti)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slti_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .slti)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltu_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .sltu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltu_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .sltu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltiu_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .sltiu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltiu_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .sltiu)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem lui_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .lui)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem lui_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .lui)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem auipc_encodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .auipc)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    trace.stepComposition.aluWritebackValue :=
  encodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem auipc_authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
  (trace :
    AuthenticatedChunkTrace
      BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
      RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
      ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
      PreparedStep)
  (hOpcode : trace.stepComposition.nativeAluOpcode = .auipc)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
    trace hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem encodedAluResult_of_exactBoundaries_nativeAlu
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
  exact
    encodedAluResult_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

theorem authenticatedEncodedAluResult_of_exactBoundaries_nativeAlu
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
  exact
    authenticatedEncodedAluResult_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

end

end Nightstream.Rv64IM
