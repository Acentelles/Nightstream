import Nightstream.Rv64IM.Execution.ExactOpcodeClassSemantics
import Nightstream.Rv64IM.Execution.NativeAluSemantics
import Nightstream.Rv64IM.Execution.WordShiftSemantics
import Nightstream.Rv64IM.Execution.ControlFlowSemantics
import Nightstream.Rv64IM.Execution.NarrowMemorySemantics
import Nightstream.Rv64IM.Execution.MultiplySemantics
import Nightstream.Rv64IM.Execution.UnsignedDivRemSemantics
import Nightstream.Rv64IM.Execution.SignedDivRemSemantics

/-!
Owns exact opcode-family semantic consequences above exact opcode-class
semantics. This file packages the extra soundness-carrying facts that remain
after class-level execution closure, and does not re-own stage-local proofs,
authenticated trace closure, or kernel-level bridge/transcript facts.
-/

namespace Nightstream.Rv64IM

structure ExactOpcodeFamilySemantics
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
    PreparedStep) where
  canonical :
    CanonicalOpcodeClassSemantics
      (canonicalOpcodeProofs_of_stepComposition pkg)
  nativeAlu :
    NativeAluExecutionFacts
      (canonicalOpcodeProofs_of_stepComposition pkg).nativeAlu
  wordShift :
    WordShiftExecutionFacts
      (canonicalOpcodeProofs_of_stepComposition pkg).wordShift
  controlFlow :
    ControlFlowExecutionFacts
      (canonicalOpcodeProofs_of_stepComposition pkg).controlFlow
  controlFlowWordToNatEq :
    controlFlow.wordToNat = pkg.executionRow.wordToNat
  controlFlowLaneEq :
    controlFlow.lane = pkg.executionRow.lane
  narrowMemory :
    NarrowMemoryExecutionFacts
      (canonicalOpcodeProofs_of_stepComposition pkg).narrowMemory
  multiply :
    MultiplyExecutionFacts
      (canonicalOpcodeProofs_of_stepComposition pkg).multiply
  nativeAluSequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      pkg.rowAssertions
      pkg.committedResult
      pkg.isaResult
      pkg.preservedState
  wordShiftSequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      pkg.rowAssertions
      pkg.committedResult
      pkg.isaResult
      pkg.preservedState
  controlFlowSequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      pkg.rowAssertions
      pkg.committedResult
      pkg.isaResult
      pkg.preservedState
  narrowMemorySequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      pkg.rowAssertions
      pkg.committedResult
      pkg.isaResult
      pkg.preservedState
  multiplySequenceProof :
    CommittedSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      pkg.rowAssertions
      pkg.committedResult
      pkg.isaResult
      pkg.preservedState
  unsignedDivRem :
    UnsignedDivRemExecutionFacts
      (canonicalOpcodeProofs_of_stepComposition pkg).unsignedDivRem
  unsignedDivRemSoundnessEq :
    unsignedDivRem.soundness = pkg.unsignedDivRem
  unsignedDivRemSequenceProof :
    AdviceSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      pkg.rowAssertions
      pkg.committedResult
      pkg.isaResult
      pkg.preservedState
  signedDivRem :
    SignedDivRemExecutionFacts
      (canonicalOpcodeProofs_of_stepComposition pkg).signedDivRem
  signedDivRemSoundnessEq :
    signedDivRem.soundness = pkg.signedDivRem
  signedDivRemSequenceProof :
    AdviceSequenceProofPackage
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
      StateLocation
      pkg.rowAssertions
      pkg.committedResult
      pkg.isaResult
      pkg.preservedState
  temporaryRegisterHygiene :
    TemporaryRegisterHygiene
      pkg.temporaryHygiene.sequence
      pkg.temporaryHygiene.isTempRegister
      pkg.temporaryHygiene.readsRegister
      pkg.temporaryHygiene.writesRegister

noncomputable def exactOpcodeFamilySemantics_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
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
    pkg :=
  { canonical := canonicalOpcodeClassSemantics_of_stepComposition pkg
    nativeAlu := nativeAluExecutionFacts_of_stepComposition pkg
    wordShift := wordShiftExecutionFacts_of_stepComposition pkg
    controlFlow := controlFlowExecutionFacts_of_stepComposition pkg
    controlFlowWordToNatEq := rfl
    controlFlowLaneEq := rfl
    narrowMemory := narrowMemoryExecutionFacts_of_stepComposition pkg
    multiply := multiplyExecutionFacts_of_stepComposition pkg
    nativeAluSequenceProof := nativeAluSequenceProof_of_stepComposition pkg
    wordShiftSequenceProof := wordShiftSequenceProof_of_stepComposition pkg
    controlFlowSequenceProof := controlFlowSequenceProof_of_stepComposition pkg
    narrowMemorySequenceProof := narrowMemorySequenceProof_of_stepComposition pkg
    multiplySequenceProof := multiplySequenceProof_of_stepComposition pkg
    unsignedDivRem := unsignedDivRemExecutionFacts_of_stepComposition pkg
    unsignedDivRemSoundnessEq := rfl
    unsignedDivRemSequenceProof := unsignedDivRemSequenceProof_of_stepComposition pkg
    signedDivRem := signedDivRemExecutionFacts_of_stepComposition pkg
    signedDivRemSoundnessEq := rfl
    signedDivRemSequenceProof := signedDivRemSequenceProof_of_stepComposition pkg
    temporaryRegisterHygiene := temporaryRegisterHygiene_of_stepComposition pkg
  }

section SequenceConsequences

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

theorem nativeAluSequenceCorrect_of_exactOpcodeFamilySemantics
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
    facts.nativeAluSequenceProof.sequence
    facts.nativeAluSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  facts.nativeAluSequenceProof.correct

theorem nativeAluSequenceDeterministic_of_exactOpcodeFamilySemantics
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
    facts.nativeAluSequenceProof.sequence
    facts.nativeAluSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  facts.nativeAluSequenceProof.deterministic

theorem wordShiftSequenceCorrect_of_exactOpcodeFamilySemantics
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
  facts.wordShiftSequenceProof.correct

theorem wordShiftSequenceDeterministic_of_exactOpcodeFamilySemantics
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
  facts.wordShiftSequenceProof.deterministic

theorem controlFlowSequenceCorrect_of_exactOpcodeFamilySemantics
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
    facts.controlFlowSequenceProof.sequence
    facts.controlFlowSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  facts.controlFlowSequenceProof.correct

theorem controlFlowSequenceDeterministic_of_exactOpcodeFamilySemantics
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
    facts.controlFlowSequenceProof.sequence
    facts.controlFlowSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  facts.controlFlowSequenceProof.deterministic

theorem narrowMemorySequenceCorrect_of_exactOpcodeFamilySemantics
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
    facts.narrowMemorySequenceProof.sequence
    facts.narrowMemorySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  facts.narrowMemorySequenceProof.correct

theorem narrowMemorySequenceDeterministic_of_exactOpcodeFamilySemantics
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
    facts.narrowMemorySequenceProof.sequence
    facts.narrowMemorySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  facts.narrowMemorySequenceProof.deterministic

theorem multiplySequenceCorrect_of_exactOpcodeFamilySemantics
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
    facts.multiplySequenceProof.sequence
    facts.multiplySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  facts.multiplySequenceProof.correct

theorem multiplySequenceDeterministic_of_exactOpcodeFamilySemantics
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
    facts.multiplySequenceProof.sequence
    facts.multiplySequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  facts.multiplySequenceProof.deterministic

theorem unsignedDivRemSequenceCorrect_of_exactOpcodeFamilySemantics
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
  AdviceSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.unsignedDivRemSequenceProof.sequence
    facts.unsignedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  facts.unsignedDivRemSequenceProof.correct

theorem unsignedDivRemSequenceDeterministic_of_exactOpcodeFamilySemantics
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
  AdviceSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.unsignedDivRemSequenceProof.sequence
    facts.unsignedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  facts.unsignedDivRemSequenceProof.deterministic

theorem signedDivRemSequenceCorrect_of_exactOpcodeFamilySemantics
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
  AdviceSequenceCorrect
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.signedDivRemSequenceProof.sequence
    facts.signedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult
    pkg.isaResult
    pkg.preservedState :=
  facts.signedDivRemSequenceProof.correct

theorem signedDivRemSequenceDeterministic_of_exactOpcodeFamilySemantics
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
  AdviceSequenceDeterministic
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
    StateLocation
    facts.signedDivRemSequenceProof.sequence
    facts.signedDivRemSequenceProof.touchedState
    pkg.rowAssertions
    pkg.committedResult :=
  facts.signedDivRemSequenceProof.deterministic

end SequenceConsequences

end Nightstream.Rv64IM
