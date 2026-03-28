import Nightstream.Rv64IM.Execution.NativeAluLoweringSemantics

/-!
Owns exact theorem-facing opcode consequences for the RV64IM native-ALU
family. This file sits above native-ALU lowering semantics and closes the
exact-opcode gap for the one-row non-memory, non-multiply, non-div/rem
instructions without re-owning the committed-sequence proof package itself.
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

theorem opcodeBound_of_nativeAluOpcodeSemantics
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
  NativeAluOpcodeBound pkg.nativeAluOps pkg.decodedRow pkg.nativeAluOpcode :=
  nativeAluOpcodeBound_of_stepComposition pkg

theorem flags_of_nativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode) :
  pkg.decodedRow.isJal = false ∧
    pkg.decodedRow.isJalr = false ∧
    pkg.decodedRow.isBranch = false ∧
    pkg.decodedRow.isLoad = false ∧
    pkg.decodedRow.isStore = false ∧
    pkg.decodedRow.isWOp = false ∧
    pkg.decodedRow.isMul = false ∧
    pkg.decodedRow.isDiv = false ∧
    pkg.decodedRow.isRem = false ∧
    pkg.decodedRow.usesRs2 = opcode.usesRs2 ∧
    pkg.decodedRow.writesMemToRd = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.forOpcode opcode := by
  have hBound := opcodeBound_of_nativeAluOpcodeSemantics facts
  rcases classFlags_of_nativeAluOpcodeBound hBound with
    ⟨hJal, hJalr, hBranch, hLoad, hStore, hWOp, hMul, hDiv, hRem⟩
  have hUsesRs2 := usesRs2_of_nativeAluOpcodeBound hBound
  have hWritesMem := writesMemToRd_of_nativeAluOpcodeBound hBound
  have hAluOp := aluOp_of_nativeAluOpcodeBound hBound
  simpa [hOpcode] using
    (show
      pkg.decodedRow.isJal = false ∧
        pkg.decodedRow.isJalr = false ∧
        pkg.decodedRow.isBranch = false ∧
        pkg.decodedRow.isLoad = false ∧
        pkg.decodedRow.isStore = false ∧
        pkg.decodedRow.isWOp = false ∧
        pkg.decodedRow.isMul = false ∧
        pkg.decodedRow.isDiv = false ∧
        pkg.decodedRow.isRem = false ∧
        pkg.decodedRow.usesRs2 = pkg.nativeAluOpcode.usesRs2 ∧
        pkg.decodedRow.writesMemToRd = false ∧
        pkg.decodedRow.aluOp = pkg.nativeAluOps.forOpcode pkg.nativeAluOpcode from
      ⟨hJal, hJalr, hBranch, hLoad, hStore, hWOp, hMul, hDiv, hRem,
        hUsesRs2, hWritesMem, hAluOp⟩)

theorem usesRs2_aluOp_of_nativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode) :
  pkg.decodedRow.usesRs2 = opcode.usesRs2 ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.forOpcode opcode := by
  rcases flags_of_nativeAluOpcodeSemantics facts hOpcode with
    ⟨_, _, _, _, _, _, _, _, _, hUsesRs2, _, hAluOp⟩
  exact ⟨hUsesRs2, hAluOp⟩

theorem x0WritePreserved_of_nativeAluOpcodeSemantics
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
  x0WritePreserved_of_nativeAluLoweringSemantics facts hRd

theorem registerOperands_of_nativeAluOpcodeSemantics
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

theorem nonX0WriteFacts_of_nativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  if opcode.writesArchitecturalRd then
    pkg.decodedRow.preservesRd = false ∧
      pkg.decodedRow.writesAluToRd = true ∧
      pkg.decodedRow.writesMemToRd = false
  else
    pkg.decodedRow.preservesRd = true ∧
      pkg.decodedRow.writesAluToRd = false ∧
      pkg.decodedRow.writesMemToRd = false := by
  simpa [hOpcode] using
    nonX0WriteFacts_of_nativeAluOpcodeWriteContract
      (nativeAluWriteContract_of_stepComposition pkg)
      hRd

theorem activeWrite_of_nativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.decodedRow.preservesRd = false ∧
    pkg.decodedRow.writesAluToRd = true ∧
    pkg.decodedRow.writesMemToRd = false := by
  have hPkgWrites : pkg.nativeAluOpcode.writesArchitecturalRd = true := by
    simpa [hOpcode] using hWrites
  exact activeWrite_of_nativeAluOpcodeWriteContract
    (nativeAluWriteContract_of_stepComposition pkg)
    hPkgWrites
    hRd

theorem passiveWrite_of_nativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = false)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.decodedRow.preservesRd = true ∧
    pkg.decodedRow.writesAluToRd = false ∧
    pkg.decodedRow.writesMemToRd = false := by
  have hPkgWrites : pkg.nativeAluOpcode.writesArchitecturalRd = false := by
    simpa [hOpcode] using hWrites
  exact passiveWrite_of_nativeAluOpcodeWriteContract
    (nativeAluWriteContract_of_stepComposition pkg)
    hPkgWrites
    hRd

theorem authenticatedWriteback_of_activeNativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  have hActive :=
    activeWrite_of_nativeAluOpcodeSemantics facts hOpcode hWrites hRd
  have hRegisterWrite :
      pkg.twistBinding.registerLane.writesRd = true :=
    registerWritesRd_of_stepComposition pkg (Or.inl hActive.2.1)
  exact registerWriteValue_of_stepComposition pkg hRegisterWrite

theorem routedWriteback_of_activeNativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerLane.rdNext = pkg.aluWritebackValue := by
  have hActive :=
    activeWrite_of_nativeAluOpcodeSemantics facts hOpcode hWrites hRd
  exact registerRdNext_of_activeAluWrite pkg hActive.2.1

theorem authenticatedRoutedWriteback_of_activeNativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
  have hActive :=
    activeWrite_of_nativeAluOpcodeSemantics facts hOpcode hWrites hRd
  exact authenticatedAluWriteValue_of_stepComposition pkg hActive.2.1

theorem encodedAluOut_of_activeNativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (_hOpcode : pkg.nativeAluOpcode = opcode)
  (_hWrites : opcode.writesArchitecturalRd = true)
  (_hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.lane.aluOut = pkg.aluWritebackValue :=
  encodedAluOut_of_stepComposition pkg

theorem encodedAluResult_of_activeNativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (_hOpcode : pkg.nativeAluOpcode = opcode)
  (_hWrites : opcode.writesArchitecturalRd = true)
  (_hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult = pkg.aluWritebackValue :=
  encodedAluResult_of_stepComposition pkg

theorem authenticatedEncodedAluOut_of_activeNativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.lane.aluOut := by
  calc
    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue :=
      authenticatedRoutedWriteback_of_activeNativeAluOpcodeSemantics
        facts hOpcode hWrites hRd
    _ = pkg.wordToLimbPair pkg.executionRow.lane.aluOut := by
      symm
      exact encodedAluOut_of_stepComposition pkg

theorem authenticatedEncodedAluResult_of_activeNativeAluOpcodeSemantics
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
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair pkg.executionRow.results.aluResult := by
  calc
    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue :=
      authenticatedRoutedWriteback_of_activeNativeAluOpcodeSemantics
        facts hOpcode hWrites hRd
    _ = pkg.wordToLimbPair pkg.executionRow.results.aluResult := by
      symm
      exact encodedAluResult_of_stepComposition pkg

theorem add_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .add)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem addi_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .addi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem sub_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .sub)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem and_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .andOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem andi_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .andi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem or_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .orOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem ori_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .ori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem xor_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .xorOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem xori_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .xori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem slt_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .slt)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem slti_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .slti)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem sltu_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .sltu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem sltiu_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .sltiu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem lui_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .lui)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem auipc_writeback_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .auipc)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  exact authenticatedWriteback_of_activeNativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem fence_passiveWrite_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .fence)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.decodedRow.preservesRd = true ∧
    pkg.decodedRow.writesAluToRd = false ∧
    pkg.decodedRow.writesMemToRd = false := by
  exact passiveWrite_of_nativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem ecall_passiveWrite_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .ecall)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.decodedRow.preservesRd = true ∧
    pkg.decodedRow.writesAluToRd = false ∧
    pkg.decodedRow.writesMemToRd = false := by
  exact passiveWrite_of_nativeAluOpcodeSemantics
    facts
    hOpcode
    (by simp [NativeAluOpcode.writesArchitecturalRd])
    hRd

theorem add_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .add) :
  pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.add := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem addi_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .addi) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.add := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem sub_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .sub) :
  pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.sub := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem and_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .andOp) :
  pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.andOp := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem andi_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .andi) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.andOp := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem or_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .orOp) :
  pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.orOp := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem ori_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .ori) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.orOp := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem xor_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .xorOp) :
  pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.xorOp := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem xori_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .xori) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.xorOp := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem slt_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .slt) :
  pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.slt := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem slti_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .slti) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.slt := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem sltu_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .sltu) :
  pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.sltu := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem sltiu_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .sltiu) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.sltu := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem lui_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .lui) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.lui := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem auipc_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .auipc) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.auipc := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem fence_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .fence) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.fence := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem ecall_flags_of_nativeAluOpcodeSemantics
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
  (hOpcode : pkg.nativeAluOpcode = .ecall) :
  pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.nativeAluOps.ecall := by
  simpa [NativeAluOpcode.usesRs2, NativeAluAluOps.forOpcode]
    using usesRs2_aluOp_of_nativeAluOpcodeSemantics facts hOpcode

theorem ecall_terminates_of_nativeAluOpcodeSemantics
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
  (_hOpcode : pkg.nativeAluOpcode = .ecall) :
  (canonicalOpcodeProofs_of_stepComposition pkg).nativeAlu.semantics.boundary.terminates = true ∧
    (canonicalOpcodeProofs_of_stepComposition pkg).nativeAlu.semantics.finalState.halted = true :=
  ⟨facts.nativeAlu.classFacts.boundaryTerminates, facts.nativeAlu.classFacts.finalStateHalted⟩

theorem sequenceCorrect_of_nativeAluOpcodeSemantics
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
  {_opcode : NativeAluOpcode}
  (_hOpcode : pkg.nativeAluOpcode = _opcode) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.nativeAluSequenceProof.sequence
    facts.nativeAluSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  sequenceCorrect_of_nativeAluLoweringSemantics facts

theorem sequenceDeterministic_of_nativeAluOpcodeSemantics
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
  {_opcode : NativeAluOpcode}
  (_hOpcode : pkg.nativeAluOpcode = _opcode) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.nativeAluSequenceProof.sequence
    facts.nativeAluSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  sequenceDeterministic_of_nativeAluLoweringSemantics facts

end

end Nightstream.Rv64IM
