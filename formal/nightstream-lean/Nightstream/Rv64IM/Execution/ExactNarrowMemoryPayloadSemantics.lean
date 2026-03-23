import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Stage1.NarrowMemoryHelpers

/-!
Owns the exact narrow-memory RAM-side payload bundle above exact opcode-family
semantics. This file packages the theorem-facing address decomposition, raw
aligned load-word, inactive helper-row, store-payload, and memory-writeback
consequences that are already justified by `StepComposition`, without
re-owning Stage-1 helper arithmetic or Stage-2 RAM authentication.
-/

namespace Nightstream.Rv64IM

structure ExactNarrowMemoryPayloadSemantics
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _) [OfNat Limb 0]
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
  (_families :
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
      pkg) where
  alignedAddrDecomposition :
    alignDown8 (pkg.executionRow.wordToNat pkg.executionRow.lane.memAddr) +
      byteOffset8 (pkg.executionRow.wordToNat pkg.executionRow.lane.memAddr) =
        pkg.executionRow.wordToNat pkg.executionRow.lane.memAddr
  loadRawMemVal :
    pkg.twistBinding.ramLane.isLoad = true →
      pkg.twistBinding.ramLane.memVal = pkg.twistBinding.ramTwist.rvRamWord
  loadRawMemValWord :
    pkg.twistBinding.ramLane.isLoad = true →
      pkg.limbPairToWord pkg.twistBinding.ramLane.memVal =
        pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord
  inactiveRamMemValZero :
    pkg.twistBinding.ramLane.isLoad = false →
      pkg.twistBinding.ramLane.isStore = false →
        pkg.twistBinding.ramLane.memVal = zeroLimbPair
  memWritebackWord :
    pkg.decodedRow.writesMemToRd = true →
      pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
        pkg.limbPairToWord pkg.twistBinding.ramLane.memVal
  storePayload :
    pkg.twistBinding.ramLane.isStore = true →
      pkg.twistBinding.ramLane.memVal = pkg.twistBinding.ramLane.rs2 ∧
        pkg.twistBinding.ramTwist.wvRamWord = pkg.twistBinding.ramLane.memVal
  storePayloadWord :
    pkg.twistBinding.ramLane.isStore = true →
      pkg.limbPairToWord pkg.twistBinding.ramTwist.wvRamWord =
        pkg.limbPairToWord pkg.twistBinding.ramLane.rs2

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

noncomputable def exactNarrowMemoryPayloadSemantics_of_exactOpcodeFamilySemantics
  (families :
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
  ExactNarrowMemoryPayloadSemantics
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
    families :=
  { alignedAddrDecomposition := by
      exact
        alignDown8_add_byteOffset8
          (pkg.executionRow.wordToNat pkg.executionRow.lane.memAddr)
    loadRawMemVal := by
      intro hLoad
      exact ramLoadMemVal_of_stepComposition pkg hLoad
    loadRawMemValWord := by
      intro hLoad
      exact congrArg pkg.limbPairToWord (ramLoadMemVal_of_stepComposition pkg hLoad)
    inactiveRamMemValZero := by
      intro hLoad hStore
      exact ramInactiveMemValZero_of_stepComposition pkg hLoad hStore
    memWritebackWord := by
      intro hWrite
      exact congrArg pkg.limbPairToWord (authenticatedMemWriteValue_of_stepComposition pkg hWrite)
    storePayload := by
      intro hStore
      exact ramStorePayload_of_stepComposition pkg hStore
    storePayloadWord := by
      intro hStore
      rcases ramStorePayload_of_stepComposition pkg hStore with ⟨hMem, hPayload⟩
      calc
        pkg.limbPairToWord pkg.twistBinding.ramTwist.wvRamWord =
            pkg.limbPairToWord pkg.twistBinding.ramLane.memVal := by
              exact congrArg pkg.limbPairToWord hPayload
        _ = pkg.limbPairToWord pkg.twistBinding.ramLane.rs2 := by
              exact congrArg pkg.limbPairToWord hMem }

noncomputable def exactNarrowMemoryPayloadSemantics_of_stepComposition
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
  ExactNarrowMemoryPayloadSemantics
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
    (exactOpcodeFamilySemantics_of_stepComposition pkg) :=
  exactNarrowMemoryPayloadSemantics_of_exactOpcodeFamilySemantics
    (exactOpcodeFamilySemantics_of_stepComposition pkg)

end

end Nightstream.Rv64IM
