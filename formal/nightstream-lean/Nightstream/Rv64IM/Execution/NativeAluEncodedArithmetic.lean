import Nightstream.Rv64IM.Execution.NativeAluOpcodeSemantics

/-!
Owns exact opcode-specialized encoded arithmetic consequences for the RV64IM
native-ALU family. This file sits above the exact native-ALU opcode owner and
turns the authenticated encoded-result routing surface into exact equalities
against theorem-facing encoded operations on authenticated operands, immediate,
and PC encodings.
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

private theorem encodedArithmetic_of_opcode
  (_facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    NativeAluEncodedResult
      pkg.nativeAluEncodedOps
      pkg.wordToLimbPair
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.executionRow.lane
      opcode := by
  calc
    pkg.wordToLimbPair pkg.executionRow.results.aluResult
      = pkg.aluWritebackValue :=
        encodedAluResult_of_stepComposition pkg
    _ =
        NativeAluEncodedResult
          pkg.nativeAluEncodedOps
          pkg.wordToLimbPair
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.executionRow.lane
          opcode := by
            simpa [hOpcode] using nativeAluEncodedResultBound_of_stepComposition pkg

private theorem authenticatedEncodedArithmetic_of_writeOpcode
  (facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    NativeAluEncodedResult
      pkg.nativeAluEncodedOps
      pkg.wordToLimbPair
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.executionRow.lane
      opcode := by
  have hActive := activeWrite_of_nativeAluOpcodeSemantics facts hOpcode hWrites hRd
  calc
    pkg.twistBinding.registerTwist.wvReg
      = pkg.aluWritebackValue :=
        authenticatedAluWriteValue_of_stepComposition pkg hActive.2.1
    _ =
        NativeAluEncodedResult
          pkg.nativeAluEncodedOps
          pkg.wordToLimbPair
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.executionRow.lane
          opcode := by
            simpa [hOpcode] using nativeAluEncodedResultBound_of_stepComposition pkg

theorem add_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .add) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.add
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem add_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .add)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.add
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem addi_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .addi) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.add
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem addi_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .addi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.add
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sub_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sub) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.sub
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem sub_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sub)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.sub
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem and_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andOp) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.andOp
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem and_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.andOp
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem andi_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andi) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.andOp
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem andi_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.andOp
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem or_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .orOp) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.orOp
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem or_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .orOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.orOp
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem ori_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ori) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.orOp
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem ori_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.orOp
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xor_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xorOp) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.xorOp
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem xor_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xorOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.xorOp
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem xori_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xori) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.xorOp
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem xori_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.xorOp
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slt_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slt) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.slt
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem slt_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slt)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.slt
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem slti_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slti) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.slt
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem slti_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slti)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.slt
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltu_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltu) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.sltu
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem sltu_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.sltu
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem sltiu_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltiu) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.sltu
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem sltiu_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltiu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.sltu
      pkg.twistBinding.registerTwist.rvRs1
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem lui_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .lui) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.lui
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem lui_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .lui)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.lui
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem auipc_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .auipc) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.auipc
      (pkg.wordToLimbPair pkg.executionRow.lane.pc)
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem auipc_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .auipc)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluEncodedOps.auipc
      (pkg.wordToLimbPair pkg.executionRow.lane.pc)
      (pkg.wordToLimbPair pkg.decodedRow.imm) := by
  simpa [NativeAluEncodedResult] using
    authenticatedEncodedArithmetic_of_writeOpcode
      facts hOpcode (by simp [NativeAluOpcode.writesArchitecturalRd]) hRd

theorem fence_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .fence) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.zero := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem ecall_encodedArithmetic_of_nativeAluEncodedArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ecall) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.nativeAluEncodedOps.zero := by
  simpa [NativeAluEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

end

end Nightstream.Rv64IM
