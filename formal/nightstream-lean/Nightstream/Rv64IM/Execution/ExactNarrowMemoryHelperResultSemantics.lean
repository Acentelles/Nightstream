import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Stage1.NarrowMemoryHelpers

/-!
Owns the exact Stage-1 helper-result bridge for RV64IM narrow memory above
exact opcode-family semantics. This file packages the theorem-facing
`extractExtend` / `blend` consequences that connect authenticated aligned-word
inputs to `executionRow.results.aluResult`, without re-owning Stage-1 helper
arithmetic or Stage-2 RAM authentication.
-/

namespace Nightstream.Rv64IM

structure ExactNarrowMemoryHelperResultSemantics
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
  loadResultBinding :
    pkg.decodedRow.isLoad = true →
      pkg.narrowMemoryExtract.addr =
          pkg.executionRow.wordToNat pkg.executionRow.lane.memAddr ∧
        pkg.narrowMemoryExtract.word =
          pkg.executionRow.wordToNat
            (pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord) ∧
        pkg.narrowMemoryExtract.out =
          pkg.executionRow.wordToNat pkg.executionRow.results.aluResult ∧
        pkg.narrowMemoryExtract.unsigned = pkg.decodedRow.memUnsigned
  storeResultBinding :
    pkg.decodedRow.isStore = true →
      pkg.narrowMemoryBlend.addr =
          pkg.executionRow.wordToNat pkg.executionRow.lane.memAddr ∧
        pkg.narrowMemoryBlend.word =
          pkg.executionRow.wordToNat
            (pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord) ∧
        pkg.narrowMemoryBlend.src =
          pkg.executionRow.wordToNat
            (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) ∧
        pkg.narrowMemoryBlend.out =
          pkg.executionRow.wordToNat pkg.executionRow.results.aluResult

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
  {families :
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
      pkg}

noncomputable def exactNarrowMemoryHelperResultSemantics_of_exactOpcodeFamilySemantics
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
  ExactNarrowMemoryHelperResultSemantics
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
  { loadResultBinding := by
      intro hLoad
      exact narrowMemoryExtractResultBound_of_stepComposition pkg hLoad
    storeResultBinding := by
      intro hStore
      exact narrowMemoryBlendResultBound_of_stepComposition pkg hStore }

noncomputable def exactNarrowMemoryHelperResultSemantics_of_stepComposition
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
  ExactNarrowMemoryHelperResultSemantics
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
  exactNarrowMemoryHelperResultSemantics_of_exactOpcodeFamilySemantics
    (exactOpcodeFamilySemantics_of_stepComposition pkg)

theorem loadExtractHelperResult_of_exactNarrowMemoryHelperResultSemantics
  (facts :
    ExactNarrowMemoryHelperResultSemantics
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
      families)
  (hLoad : pkg.decodedRow.isLoad = true) :
  pkg.executionRow.wordToNat pkg.executionRow.results.aluResult =
    extractExtend
      (pkg.executionRow.wordToNat
        (pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord))
      pkg.narrowMemoryExtract.off
      pkg.narrowMemoryExtract.width
      pkg.decodedRow.memUnsigned := by
  rcases facts.loadResultBinding hLoad with ⟨_, hWord, hOut, hUnsigned⟩
  rw [← hOut, pkg.narrowMemoryExtract.extraction, hWord, hUnsigned]

theorem storeBlendHelperResult_of_exactNarrowMemoryHelperResultSemantics
  (facts :
    ExactNarrowMemoryHelperResultSemantics
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
      families)
  (hStore : pkg.decodedRow.isStore = true) :
  pkg.executionRow.wordToNat pkg.executionRow.results.aluResult =
    blend
      (pkg.executionRow.wordToNat
        (pkg.limbPairToWord pkg.twistBinding.ramTwist.rvRamWord))
      (pkg.executionRow.wordToNat
        (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2))
      pkg.narrowMemoryBlend.off
      pkg.narrowMemoryBlend.width := by
  rcases facts.storeResultBinding hStore with ⟨_, hWord, hSrc, hOut⟩
  rw [← hOut, pkg.narrowMemoryBlend.blended, hWord, hSrc]

end

end Nightstream.Rv64IM
