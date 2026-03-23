import Nightstream.Rv64IM.Execution.StepComposition

/-!
Owns the canonical theorem-facing exact native aligned-memory opcode bundle for
RV64IM `LD` / `SD`. This owner sits directly above `StepComposition`: these
rows are native aligned 64-bit RAM rows, so they do not belong to the seven
family/lowering bundles that serve the narrow-memory and arithmetic paths.
-/

namespace Nightstream.Rv64IM

structure ExactAlignedMemoryOpcodeSemantics
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _)
  [OfNat Limb 0]
  (pkg :
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
      PreparedStep) where
  classFlags :
    pkg.decodedRow.isJal = false ∧
      pkg.decodedRow.isJalr = false ∧
      pkg.decodedRow.isBranch = false ∧
      pkg.decodedRow.isMul = false ∧
      pkg.decodedRow.isDiv = false ∧
      pkg.decodedRow.isRem = false ∧
      pkg.decodedRow.isWOp = false
  flags :
    pkg.decodedRow.isLoad = pkg.alignedMemoryOpcode.isLoad ∧
      pkg.decodedRow.isStore = pkg.alignedMemoryOpcode.isStore ∧
      pkg.decodedRow.usesRs2 = pkg.alignedMemoryOpcode.usesRs2 ∧
      pkg.decodedRow.writesAluToRd = false ∧
      pkg.decodedRow.memWidth = pkg.alignedMemoryWidth
  ramRoleFlags :
    pkg.twistBinding.ramLane.isLoad = pkg.decodedRow.isLoad ∧
      pkg.twistBinding.ramLane.isStore = pkg.decodedRow.isStore
  x0WritePreserved :
    pkg.decodedRow.rd = pkg.x0 →
      pkg.decodedRow.preservesRd = true ∧
        pkg.decodedRow.writesAluToRd = false ∧
        pkg.decodedRow.writesMemToRd = false
  activeLoadWrite :
    pkg.alignedMemoryOpcode = .ld →
      pkg.decodedRow.rd ≠ pkg.x0 →
        pkg.decodedRow.preservesRd = false ∧
          pkg.decodedRow.writesAluToRd = false ∧
          pkg.decodedRow.writesMemToRd = true
  passiveStore :
    pkg.alignedMemoryOpcode = .sd →
      pkg.decodedRow.preservesRd = true ∧
        pkg.decodedRow.writesAluToRd = false ∧
        pkg.decodedRow.writesMemToRd = false
  registerOperands :
    pkg.twistBinding.registerTwist.rvRs1 = pkg.twistBinding.registerLane.rs1 ∧
      pkg.twistBinding.registerTwist.rvRs2 = pkg.twistBinding.registerLane.rs2
  loadRawMemVal :
    pkg.alignedMemoryOpcode = .ld →
      pkg.twistBinding.ramLane.memVal = pkg.twistBinding.ramTwist.rvRamWord
  loadRawMemValWord :
    pkg.alignedMemoryOpcode = .ld →
      pkg.limbPairToWord pkg.twistBinding.ramLane.memVal =
        pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord
  loadWriteback :
    pkg.alignedMemoryOpcode = .ld →
      pkg.decodedRow.rd ≠ pkg.x0 →
        pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.ramTwist.rvRamWord
  loadWritebackWord :
    pkg.alignedMemoryOpcode = .ld →
      pkg.decodedRow.rd ≠ pkg.x0 →
        pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
          pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord
  storePayload :
    pkg.alignedMemoryOpcode = .sd →
      pkg.twistBinding.ramLane.memVal = pkg.twistBinding.ramLane.rs2 ∧
        pkg.twistBinding.ramTwist.wvRamWord = pkg.twistBinding.ramLane.memVal
  storePayloadWord :
    pkg.alignedMemoryOpcode = .sd →
      pkg.limbPairToWord pkg.twistBinding.ramTwist.wvRamWord =
        pkg.limbPairToWord pkg.twistBinding.ramLane.rs2

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]

private theorem alignedMemoryLoadFlag_of_stepComposition
  (pkg :
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
      PreparedStep)
  (hOpcode : pkg.alignedMemoryOpcode = .ld) :
  pkg.decodedRow.isLoad = true := by
  have hFlags :=
    flags_of_alignedMemoryOpcodeBound
      (alignedMemoryOpcodeBound_of_stepComposition pkg)
  simpa [hOpcode, AlignedMemoryOpcode.isLoad] using hFlags.1

private theorem alignedMemoryStoreFlag_of_stepComposition
  (pkg :
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
      PreparedStep)
  (hOpcode : pkg.alignedMemoryOpcode = .sd) :
  pkg.decodedRow.isStore = true := by
  have hFlags :=
    flags_of_alignedMemoryOpcodeBound
      (alignedMemoryOpcodeBound_of_stepComposition pkg)
  simpa [hOpcode, AlignedMemoryOpcode.isStore] using hFlags.2.1

noncomputable def exactAlignedMemoryOpcodeSemantics_of_stepComposition
  (pkg :
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
      PreparedStep) :
  ExactAlignedMemoryOpcodeSemantics
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
    pkg :=
  { classFlags := by
      exact
        rowClassFlags_of_alignedMemoryOpcodeBound
          (alignedMemoryOpcodeBound_of_stepComposition pkg)
    flags := by
      exact
        flags_of_alignedMemoryOpcodeBound
          (alignedMemoryOpcodeBound_of_stepComposition pkg)
    ramRoleFlags := by
      exact ramRoleFlags_of_stepComposition pkg
    x0WritePreserved := by
      intro hRd
      exact fetchDecodeBound_x0Preserved pkg.fetchDecodeBound hRd
    activeLoadWrite := by
      intro hOpcode hRd
      have hWrites : pkg.alignedMemoryOpcode.writesArchitecturalRd = true := by
        simpa [hOpcode, AlignedMemoryOpcode.writesArchitecturalRd]
      exact
        activeMemWrite_of_alignedMemoryOpcodeWriteContract
          (alignedMemoryWriteContract_of_stepComposition pkg)
          hWrites
          hRd
    passiveStore := by
      intro hOpcode
      by_cases hRd : pkg.decodedRow.rd = pkg.x0
      · exact
          x0WriteFacts_of_alignedMemoryOpcodeWriteContract
            (alignedMemoryWriteContract_of_stepComposition pkg)
            hRd
      · have hWrites : pkg.alignedMemoryOpcode.writesArchitecturalRd = false := by
          simpa [hOpcode, AlignedMemoryOpcode.writesArchitecturalRd]
        exact
          passiveWrite_of_alignedMemoryOpcodeWriteContract
            (alignedMemoryWriteContract_of_stepComposition pkg)
            hWrites
            hRd
    registerOperands := by
      exact registerReadValues_of_stepComposition pkg
    loadRawMemVal := by
      intro hOpcode
      have hLoadRow : pkg.decodedRow.isLoad = true :=
        alignedMemoryLoadFlag_of_stepComposition pkg hOpcode
      have hRamLoad : pkg.twistBinding.ramLane.isLoad = true := by
        calc
          pkg.twistBinding.ramLane.isLoad = pkg.decodedRow.isLoad :=
            ramLaneIsLoad_eq_decodedRow_of_stepComposition pkg
          _ = true := hLoadRow
      exact ramLoadMemVal_of_stepComposition pkg hRamLoad
    loadRawMemValWord := by
      intro hOpcode
      have hLoadRow : pkg.decodedRow.isLoad = true :=
        alignedMemoryLoadFlag_of_stepComposition pkg hOpcode
      have hRamLoad : pkg.twistBinding.ramLane.isLoad = true := by
        calc
          pkg.twistBinding.ramLane.isLoad = pkg.decodedRow.isLoad :=
            ramLaneIsLoad_eq_decodedRow_of_stepComposition pkg
          _ = true := hLoadRow
      exact congrArg pkg.limbPairToWord (ramLoadMemVal_of_stepComposition pkg hRamLoad)
    loadWriteback := by
      intro hOpcode hRd
      have hWrites : pkg.alignedMemoryOpcode.writesArchitecturalRd = true := by
        simpa [hOpcode, AlignedMemoryOpcode.writesArchitecturalRd]
      have hWrite :=
        activeMemWrite_of_alignedMemoryOpcodeWriteContract
          (alignedMemoryWriteContract_of_stepComposition pkg)
          hWrites
          hRd
      rcases hWrite with ⟨_, _, hWritesMem⟩
      have hLoadRow : pkg.decodedRow.isLoad = true :=
        alignedMemoryLoadFlag_of_stepComposition pkg hOpcode
      have hRamLoad : pkg.twistBinding.ramLane.isLoad = true := by
        calc
          pkg.twistBinding.ramLane.isLoad = pkg.decodedRow.isLoad :=
            ramLaneIsLoad_eq_decodedRow_of_stepComposition pkg
          _ = true := hLoadRow
      have hLoadMem := ramLoadMemVal_of_stepComposition pkg hRamLoad
      calc
        pkg.twistBinding.registerTwist.wvReg = pkg.twistBinding.ramLane.memVal :=
          authenticatedMemWriteValue_of_stepComposition pkg hWritesMem
        _ = pkg.twistBinding.ramTwist.rvRamWord := hLoadMem
    loadWritebackWord := by
      intro hOpcode hRd
      have hWrites : pkg.alignedMemoryOpcode.writesArchitecturalRd = true := by
        simpa [hOpcode, AlignedMemoryOpcode.writesArchitecturalRd]
      have hWrite :=
        activeMemWrite_of_alignedMemoryOpcodeWriteContract
          (alignedMemoryWriteContract_of_stepComposition pkg)
          hWrites
          hRd
      rcases hWrite with ⟨_, _, hWritesMem⟩
      have hLoadRow : pkg.decodedRow.isLoad = true :=
        alignedMemoryLoadFlag_of_stepComposition pkg hOpcode
      have hRamLoad : pkg.twistBinding.ramLane.isLoad = true := by
        calc
          pkg.twistBinding.ramLane.isLoad = pkg.decodedRow.isLoad :=
            ramLaneIsLoad_eq_decodedRow_of_stepComposition pkg
          _ = true := hLoadRow
      calc
        pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
            pkg.limbPairToWord pkg.twistBinding.ramLane.memVal := by
              exact congrArg pkg.limbPairToWord
                (authenticatedMemWriteValue_of_stepComposition pkg hWritesMem)
        _ = pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord := by
              exact congrArg pkg.limbPairToWord
                (ramLoadMemVal_of_stepComposition pkg hRamLoad)
    storePayload := by
      intro hOpcode
      have hStoreRow : pkg.decodedRow.isStore = true :=
        alignedMemoryStoreFlag_of_stepComposition pkg hOpcode
      have hRamStore : pkg.twistBinding.ramLane.isStore = true := by
        calc
          pkg.twistBinding.ramLane.isStore = pkg.decodedRow.isStore :=
            ramLaneIsStore_eq_decodedRow_of_stepComposition pkg
          _ = true := hStoreRow
      exact ramStorePayload_of_stepComposition pkg hRamStore
    storePayloadWord := by
      intro hOpcode
      have hStoreRow : pkg.decodedRow.isStore = true :=
        alignedMemoryStoreFlag_of_stepComposition pkg hOpcode
      have hRamStore : pkg.twistBinding.ramLane.isStore = true := by
        calc
          pkg.twistBinding.ramLane.isStore = pkg.decodedRow.isStore :=
            ramLaneIsStore_eq_decodedRow_of_stepComposition pkg
          _ = true := hStoreRow
      rcases ramStorePayload_of_stepComposition pkg hRamStore with ⟨hMem, hWrite⟩
      calc
        pkg.limbPairToWord pkg.twistBinding.ramTwist.wvRamWord =
            pkg.limbPairToWord pkg.twistBinding.ramLane.memVal := by
              exact congrArg pkg.limbPairToWord hWrite
        _ = pkg.limbPairToWord pkg.twistBinding.ramLane.rs2 := by
              exact congrArg pkg.limbPairToWord hMem }

end

end Nightstream.Rv64IM
