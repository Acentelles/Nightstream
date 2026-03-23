import Nightstream.Rv64IM.Execution.MultiplyOpcodeSemantics

/-!
Owns exact opcode-specialized encoded-result consequences for the RV64IM
multiply family. This file sharpens the generic multiply opcode owner to exact
architectural multiply opcodes without re-owning decode classification or
generic write-activation routing.
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

local notation "MultiplyFacts" =>
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

private theorem encodedAluResult_of_multiplyOpcode
  (facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_activeMultiplyOpcodeSemantics facts hOpcode hRd

private theorem authenticatedEncodedAluResult_of_multiplyOpcode
  (facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_activeMultiplyOpcodeSemantics facts hOpcode hRd

theorem mul_encodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mul)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mul_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mul)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulh_encodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulh)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulh_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulh)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulhu_encodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulhu_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulhsu_encodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhsu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulhsu_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhsu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulw_encodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_multiplyOpcode facts hOpcode hRd

theorem mulw_authenticatedEncodedAluResult_of_multiplyOpcodeResultSemantics
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult :=
  authenticatedEncodedAluResult_of_multiplyOpcode facts hOpcode hRd

end

end Nightstream.Rv64IM
