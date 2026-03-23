import Nightstream.Rv64IM.Execution.MultiplyOpcodeSemantics

/-!
Owns exact opcode-specialized encoded arithmetic consequences for the RV64IM
multiply family. This file sits above the exact multiply opcode owner and
turns the authenticated encoded-result routing surface into exact equalities
against theorem-facing encoded multiply operations on authenticated operands.
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

private theorem encodedArithmetic_of_opcode
  (_facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    MultiplyEncodedResult
      pkg.multiplyEncodedOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      opcode := by
  calc
    pkg.wordToLimbPair pkg.executionRow.results.aluResult
      = pkg.aluWritebackValue :=
        encodedAluResult_of_stepComposition pkg
    _ =
        MultiplyEncodedResult
          pkg.multiplyEncodedOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          opcode := by
            simpa [hOpcode] using multiplyEncodedResultBound_of_stepComposition pkg

private theorem authenticatedEncodedArithmetic_of_opcode
  (facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    MultiplyEncodedResult
      pkg.multiplyEncodedOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      opcode := by
  have hActive := activeWrite_of_multiplyOpcodeSemantics facts hOpcode hRd
  calc
    pkg.twistBinding.registerTwist.wvReg
      = pkg.aluWritebackValue :=
        authenticatedAluWriteValue_of_stepComposition pkg hActive.2.1
    _ =
        MultiplyEncodedResult
          pkg.multiplyEncodedOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          opcode := by
            simpa [hOpcode] using multiplyEncodedResultBound_of_stepComposition pkg

theorem mul_encodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mul) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.multiplyEncodedOps.mul
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem mul_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mul)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyEncodedOps.mul
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using
    authenticatedEncodedArithmetic_of_opcode facts hOpcode hRd

theorem mulh_encodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulh) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.multiplyEncodedOps.mulh
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem mulh_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulh)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyEncodedOps.mulh
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using
    authenticatedEncodedArithmetic_of_opcode facts hOpcode hRd

theorem mulhu_encodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhu) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.multiplyEncodedOps.mulhu
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem mulhu_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyEncodedOps.mulhu
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using
    authenticatedEncodedArithmetic_of_opcode facts hOpcode hRd

theorem mulhsu_encodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhsu) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.multiplyEncodedOps.mulhsu
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem mulhsu_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhsu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyEncodedOps.mulhsu
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using
    authenticatedEncodedArithmetic_of_opcode facts hOpcode hRd

theorem mulw_encodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulw) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.multiplyEncodedOps.mulw
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using encodedArithmetic_of_opcode facts hOpcode

theorem mulw_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyEncodedOps.mulw
      pkg.twistBinding.registerTwist.rvRs1
      pkg.twistBinding.registerTwist.rvRs2 := by
  simpa [MultiplyEncodedResult] using
    authenticatedEncodedArithmetic_of_opcode facts hOpcode hRd

end

end Nightstream.Rv64IM
