import Nightstream.Rv64IM.Execution.NativeAluOpcodeSemantics

/-!
Owns exact opcode-specialized encoded-result consequences for the RV64IM
native-ALU family. This file sharpens the generic native-ALU opcode owner to
exact architectural opcodes without re-owning decode classification or generic
write-activation routing.
-/

namespace Nightstream.Rv64IM

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

local notation "NativeFacts" =>
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
    pkg

private theorem encodedAluResult_of_writeOpcode
  (facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    hWrites
    hRd

private theorem authenticatedEncodedAluResult_of_writeOpcode
  (facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    hWrites
    hRd

theorem add_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .add)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem add_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .add)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem addi_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .addi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem addi_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .addi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sub_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sub)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sub_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sub)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem and_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem and_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem andi_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem andi_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem or_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .orOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem or_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .orOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem ori_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem ori_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xor_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xorOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xor_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xorOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xori_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xori_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slt_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slt)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slt_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slt)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slti_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slti)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slti_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slti)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltu_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltu_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltiu_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltiu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltiu_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltiu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem lui_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .lui)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem lui_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .lui)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem auipc_encodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .auipc)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem auipc_authenticatedEncodedAluResult_of_nativeAluOpcodeResultSemantics
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .auipc)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_writeOpcode facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

end

end Nightstream.Rv64IM
