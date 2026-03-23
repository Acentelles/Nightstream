import Nightstream.Rv64IM.Execution.MultiplyLoweringSemantics

/-!
Owns exact theorem-facing opcode consequences for the RV64IM multiply family.
This file sits above multiply lowering semantics and closes the exact-opcode
gap for `MUL`, `MULH`, `MULHU`, `MULHSU`, and `MULW`.
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

theorem opcodeBound_of_multiplyOpcodeSemantics
  (_facts :
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
      pkg) :
  MultiplyOpcodeBound
    pkg.multiplyAluOps
    pkg.decodedRow
    pkg.multiplyOpcode :=
  multiplyOpcodeBound_of_stepComposition pkg

theorem flags_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode) :
  pkg.decodedRow.isJal = false ∧
    pkg.decodedRow.isJalr = false ∧
    pkg.decodedRow.isBranch = false ∧
    pkg.decodedRow.isLoad = false ∧
    pkg.decodedRow.isStore = false ∧
    pkg.decodedRow.isDiv = false ∧
    pkg.decodedRow.isRem = false ∧
    pkg.decodedRow.isMul = true ∧
    pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.writesMemToRd = false ∧
    pkg.decodedRow.isWOp = opcode.isWOp ∧
    pkg.decodedRow.aluOp = pkg.multiplyAluOps.forOpcode opcode := by
  have hBound := opcodeBound_of_multiplyOpcodeSemantics facts
  rcases classFlags_of_multiplyOpcodeBound hBound with
    ⟨hJal, hJalr, hBranch, hLoad, hStore, hDiv, hRem, hMul⟩
  have hUsesRs2 := usesRs2_of_multiplyOpcodeBound hBound
  have hWritesMem := writeFlags_of_multiplyOpcodeBound hBound
  have hWOp := isWOp_of_multiplyOpcodeBound hBound
  have hAluOp := aluOp_of_multiplyOpcodeBound hBound
  simpa [hOpcode] using
    (show
      pkg.decodedRow.isJal = false ∧
        pkg.decodedRow.isJalr = false ∧
        pkg.decodedRow.isBranch = false ∧
        pkg.decodedRow.isLoad = false ∧
        pkg.decodedRow.isStore = false ∧
        pkg.decodedRow.isDiv = false ∧
        pkg.decodedRow.isRem = false ∧
        pkg.decodedRow.isMul = true ∧
        pkg.decodedRow.usesRs2 = true ∧
        pkg.decodedRow.writesMemToRd = false ∧
        pkg.decodedRow.isWOp = pkg.multiplyOpcode.isWOp ∧
        pkg.decodedRow.aluOp = pkg.multiplyAluOps.forOpcode pkg.multiplyOpcode from
      ⟨hJal, hJalr, hBranch, hLoad, hStore, hDiv, hRem, hMul,
        hUsesRs2, hWritesMem, hWOp, hAluOp⟩)

theorem isWOp_aluOp_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode) :
  pkg.decodedRow.isWOp = opcode.isWOp ∧
    pkg.decodedRow.aluOp = pkg.multiplyAluOps.forOpcode opcode := by
  rcases flags_of_multiplyOpcodeSemantics facts hOpcode with
    ⟨_, _, _, _, _, _, _, _, _, _, hWOp, hAluOp⟩
  exact ⟨hWOp, hAluOp⟩

theorem x0WritePreserved_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hRd : pkg.decodedRow.rd = pkg.x0) :
  pkg.decodedRow.preservesRd = true ∧
    pkg.decodedRow.writesAluToRd = false ∧
    pkg.decodedRow.writesMemToRd = false :=
  x0WritePreserved_of_multiplyLoweringSemantics facts hRd

theorem registerOperands_of_multiplyOpcodeSemantics
  (_facts :
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
      pkg) :
  pkg.twistBinding.registerTwist.rvRs1 = pkg.twistBinding.registerLane.rs1 ∧
    pkg.twistBinding.registerTwist.rvRs2 = pkg.twistBinding.registerLane.rs2 :=
  registerReadValues_of_stepComposition pkg

theorem activeWrite_of_multiplyOpcodeSemantics
  (_facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.decodedRow.preservesRd = false ∧
    pkg.decodedRow.writesAluToRd = true ∧
    pkg.decodedRow.writesMemToRd = false := by
  have _ := hOpcode
  exact activeWrite_of_multiplyOpcodeWriteContract
    (multiplyWriteContract_of_stepComposition pkg)
    hRd

theorem authenticatedWriteback_of_activeMultiplyOpcodeSemantics
  (facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  have hActive := activeWrite_of_multiplyOpcodeSemantics facts hOpcode hRd
  have hRegisterWrite :
      pkg.twistBinding.registerLane.writesRd = true :=
    registerWritesRd_of_stepComposition pkg (Or.inl hActive.2.1)
  exact registerWriteValue_of_stepComposition pkg hRegisterWrite

theorem routedWriteback_of_activeMultiplyOpcodeSemantics
  (facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerLane.rdNext = pkg.aluWritebackValue := by
  have hActive := activeWrite_of_multiplyOpcodeSemantics facts hOpcode hRd
  exact registerRdNext_of_activeAluWrite pkg hActive.2.1

theorem authenticatedRoutedWriteback_of_activeMultiplyOpcodeSemantics
  (facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
  have hActive := activeWrite_of_multiplyOpcodeSemantics facts hOpcode hRd
  exact authenticatedAluWriteValue_of_stepComposition pkg hActive.2.1

theorem encodedAluOut_of_activeMultiplyOpcodeSemantics
  (_facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (_hOpcode : pkg.multiplyOpcode = _opcode)
  (_hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.lane.aluOut = pkg.aluWritebackValue :=
  encodedAluOut_of_stepComposition pkg

theorem encodedAluResult_of_activeMultiplyOpcodeSemantics
  (_facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (_hOpcode : pkg.multiplyOpcode = _opcode)
  (_hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_stepComposition pkg

theorem authenticatedEncodedAluOut_of_activeMultiplyOpcodeSemantics
  (facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.lane.aluOut := by
  calc
    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue :=
      authenticatedRoutedWriteback_of_activeMultiplyOpcodeSemantics facts hOpcode hRd
    _ = pkg.wordToLimbPair pkg.executionRow.lane.aluOut := by
      symm
      exact encodedAluOut_of_stepComposition pkg

theorem authenticatedEncodedAluResult_of_activeMultiplyOpcodeSemantics
  (facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult := by
  calc
    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue :=
      authenticatedRoutedWriteback_of_activeMultiplyOpcodeSemantics facts hOpcode hRd
    _ = pkg.wordToLimbPair pkg.executionRow.results.aluResult := by
      symm
      exact encodedAluResult_of_stepComposition pkg

theorem mul_writeback_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mul)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeMultiplyOpcodeSemantics facts hOpcode hRd

theorem mulh_writeback_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulh)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeMultiplyOpcodeSemantics facts hOpcode hRd

theorem mulhu_writeback_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulhu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeMultiplyOpcodeSemantics facts hOpcode hRd

theorem mulhsu_writeback_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulhsu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeMultiplyOpcodeSemantics facts hOpcode hRd

theorem mulw_writeback_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeMultiplyOpcodeSemantics facts hOpcode hRd

theorem mul_flags_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mul) :
  pkg.decodedRow.isMul = true ∧
    pkg.decodedRow.isWOp = false ∧
    pkg.decodedRow.aluOp = pkg.multiplyAluOps.mul := by
  rcases flags_of_multiplyOpcodeSemantics facts hOpcode with
    ⟨_, _, _, _, _, _, _, hMul, _, _, hWOp, hAluOp⟩
  exact ⟨hMul, by simpa [MultiplyOpcode.isWOp] using hWOp,
    by simpa [MultiplyAluOps.forOpcode] using hAluOp⟩

theorem mulh_flags_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulh) :
  pkg.decodedRow.isMul = true ∧
    pkg.decodedRow.isWOp = false ∧
    pkg.decodedRow.aluOp = pkg.multiplyAluOps.mulh := by
  rcases flags_of_multiplyOpcodeSemantics facts hOpcode with
    ⟨_, _, _, _, _, _, _, hMul, _, _, hWOp, hAluOp⟩
  exact ⟨hMul, by simpa [MultiplyOpcode.isWOp] using hWOp,
    by simpa [MultiplyAluOps.forOpcode] using hAluOp⟩

theorem mulhu_flags_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulhu) :
  pkg.decodedRow.isMul = true ∧
    pkg.decodedRow.isWOp = false ∧
    pkg.decodedRow.aluOp = pkg.multiplyAluOps.mulhu := by
  rcases flags_of_multiplyOpcodeSemantics facts hOpcode with
    ⟨_, _, _, _, _, _, _, hMul, _, _, hWOp, hAluOp⟩
  exact ⟨hMul, by simpa [MultiplyOpcode.isWOp] using hWOp,
    by simpa [MultiplyAluOps.forOpcode] using hAluOp⟩

theorem mulhsu_flags_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulhsu) :
  pkg.decodedRow.isMul = true ∧
    pkg.decodedRow.isWOp = false ∧
    pkg.decodedRow.aluOp = pkg.multiplyAluOps.mulhsu := by
  rcases flags_of_multiplyOpcodeSemantics facts hOpcode with
    ⟨_, _, _, _, _, _, _, hMul, _, _, hWOp, hAluOp⟩
  exact ⟨hMul, by simpa [MultiplyOpcode.isWOp] using hWOp,
    by simpa [MultiplyAluOps.forOpcode] using hAluOp⟩

theorem mulw_flags_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  (hOpcode : pkg.multiplyOpcode = .mulw) :
  pkg.decodedRow.isMul = true ∧
    pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.aluOp = pkg.multiplyAluOps.mul := by
  rcases flags_of_multiplyOpcodeSemantics facts hOpcode with
    ⟨_, _, _, _, _, _, _, hMul, _, _, hWOp, hAluOp⟩
  exact ⟨hMul, by simpa [MultiplyOpcode.isWOp] using hWOp,
    by simpa [MultiplyAluOps.forOpcode] using hAluOp⟩

theorem sequenceCorrect_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.multiplySequenceProof.sequence
    facts.multiplySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState := by
  have _ := hOpcode
  exact sequenceCorrect_of_multiplyLoweringSemantics facts

theorem sequenceDeterministic_of_multiplyOpcodeSemantics
  (facts :
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
      pkg)
  {_opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = _opcode) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.multiplySequenceProof.sequence
    facts.multiplySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult := by
  have _ := hOpcode
  exact sequenceDeterministic_of_multiplyLoweringSemantics facts

end

end Nightstream.Rv64IM
