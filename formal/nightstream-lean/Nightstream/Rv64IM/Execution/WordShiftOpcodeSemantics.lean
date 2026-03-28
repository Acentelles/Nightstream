import Nightstream.Rv64IM.Execution.WordShiftLoweringSemantics

/-!
Owns exact theorem-facing opcode consequences for the RV64IM word/shift family.
This file sits above word/shift lowering semantics and closes the exact-opcode
gap for the W-width arithmetic and shift instructions without re-owning the
committed-sequence proof package itself.
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

theorem opcodeBound_of_wordShiftOpcodeSemantics
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
  WordShiftOpcodeBound
    pkg.wordShiftAluOps
    pkg.decodedRow
    pkg.wordShiftOpcode :=
  pkg.wordShiftOpcodeBound

theorem flags_of_wordShiftOpcodeSemantics
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
  {opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = opcode) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = opcode.usesRs2 ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.forOpcode opcode := by
  simpa [hOpcode] using opcodeBound_of_wordShiftOpcodeSemantics facts

theorem addw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .addw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.add := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem addiw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .addiw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.add := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem subw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .subw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.sub := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem sllw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .sllw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.sll := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem slliw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .slliw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.sll := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem srlw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .srlw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.srl := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem srliw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .srliw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.srl := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem sraw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .sraw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = true ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.sra := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem sraiw_flags_of_wordShiftOpcodeSemantics
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
  (hOpcode : pkg.wordShiftOpcode = .sraiw) :
  pkg.decodedRow.isWOp = true ∧
    pkg.decodedRow.usesRs2 = false ∧
    pkg.decodedRow.aluOp = pkg.wordShiftAluOps.sra := by
  simpa [WordShiftOpcode.usesRs2, WordShiftAluOps.forOpcode]
    using flags_of_wordShiftOpcodeSemantics facts hOpcode

theorem activeWrite_of_wordShiftOpcodeSemantics
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
  {_opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.decodedRow.preservesRd = false ∧
    pkg.decodedRow.writesAluToRd = true ∧
    pkg.decodedRow.writesMemToRd = false := by
  have _ := hOpcode
  exact activeWrite_of_wordShiftOpcodeWriteContract
    (wordShiftWriteContract_of_stepComposition pkg)
    hRd

theorem authenticatedWriteback_of_activeWordShiftOpcodeSemantics
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
  {_opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.registerLane.rdNext := by
  have hActive := activeWrite_of_wordShiftOpcodeSemantics facts hOpcode hRd
  have hRegisterWrite :
      pkg.twistBinding.registerLane.writesRd = true :=
    registerWritesRd_of_stepComposition pkg (Or.inl hActive.2.1)
  exact registerWriteValue_of_stepComposition pkg hRegisterWrite

theorem routedWriteback_of_activeWordShiftOpcodeSemantics
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
  {_opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerLane.rdNext = pkg.aluWritebackValue := by
  have hActive := activeWrite_of_wordShiftOpcodeSemantics facts hOpcode hRd
  exact registerRdNext_of_activeAluWrite pkg hActive.2.1

theorem authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics
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
  {_opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = _opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
  calc
    pkg.twistBinding.registerTwist.wvReg
      = pkg.twistBinding.registerLane.rdNext :=
        authenticatedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
    _ = pkg.aluWritebackValue :=
        routedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd

theorem sequenceCorrect_of_wordShiftOpcodeSemantics
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
      pkg) :
  CommittedSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.wordShiftSequenceProof.sequence
    facts.wordShiftSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  sequenceCorrect_of_wordShiftLoweringSemantics facts

theorem sequenceDeterministic_of_wordShiftOpcodeSemantics
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
      pkg) :
  CommittedSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.wordShiftSequenceProof.sequence
    facts.wordShiftSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  sequenceDeterministic_of_wordShiftLoweringSemantics facts

end

end Nightstream.Rv64IM
