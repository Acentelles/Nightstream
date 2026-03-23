import Nightstream.Rv64IM.Trace.ExactTraceBoundaries
import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Trace.OpcodeClassSemantics

/-!
Owns lifting of exact opcode-family semantic facts through the authenticated
trace and exact trace-boundary surfaces. This file does not re-own execution
semantics or kernel-level conclusions.
-/

namespace Nightstream.Rv64IM

noncomputable def exactOpcodeFamilySemantics_of_authenticatedChunkTrace
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (trace :
    AuthenticatedChunkTrace
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
    trace.stepComposition :=
  { canonical := canonicalOpcodeClassSemantics_of_authenticatedChunkTrace trace
    nativeAlu :=
      nativeAluExecutionFacts_of_opcodeClassFacts
        (nativeAluFacts_of_authenticatedChunkTrace trace)
    wordShift :=
      wordShiftExecutionFacts_of_opcodeClassFacts
        (wordShiftFacts_of_authenticatedChunkTrace trace)
    controlFlow :=
      controlFlowExecutionFacts_of_opcodeClassFacts
        (controlFlowFacts_of_authenticatedChunkTrace trace)
        trace.stepComposition.executionRow.wordToNat
        trace.stepComposition.executionRow.lane
        (takenTargetAlignmentBound_of_authenticatedChunkTrace trace)
    controlFlowWordToNatEq := rfl
    controlFlowLaneEq := rfl
    narrowMemory :=
      narrowMemoryExecutionFacts_of_opcodeClassFacts
        (narrowMemoryFacts_of_authenticatedChunkTrace trace)
    multiply :=
      multiplyExecutionFacts_of_opcodeClassFacts
        (multiplyFacts_of_authenticatedChunkTrace trace)
    nativeAluSequenceProof :=
      nativeAluSequenceProof_of_stepComposition trace.stepComposition
    wordShiftSequenceProof :=
      wordShiftSequenceProof_of_stepComposition trace.stepComposition
    controlFlowSequenceProof :=
      controlFlowSequenceProof_of_stepComposition trace.stepComposition
    narrowMemorySequenceProof :=
      narrowMemorySequenceProof_of_stepComposition trace.stepComposition
    multiplySequenceProof :=
      multiplySequenceProof_of_stepComposition trace.stepComposition
    unsignedDivRem :=
      unsignedDivRemExecutionFacts_of_opcodeClassFacts
        (unsignedDivRemFacts_of_authenticatedChunkTrace trace)
        trace.stepComposition.unsignedDivRem
        trace.stepComposition.executionRow.mulHigh
        trace.stepComposition.executionRow.zeroWord
        trace.stepComposition.executionRow.divRemQuotient
        trace.stepComposition.executionRow.divRemDivisor
        (mulUNoOverflowBound_of_authenticatedChunkTrace trace)
        (mulUNoOverflow_of_authenticatedChunkTrace trace)
        (unsignedDivRemSpec_of_authenticatedChunkTrace trace)
        (by
          intro quotient' remainder' hSpec
          exact unsignedDivRemDeterministic_of_authenticatedChunkTrace trace hSpec)
    unsignedDivRemSoundnessEq := rfl
    unsignedDivRemSequenceProof :=
      unsignedDivRemSequenceProof_of_stepComposition trace.stepComposition
    signedDivRem :=
      signedDivRemExecutionFacts_of_opcodeClassFacts
        (signedDivRemFacts_of_authenticatedChunkTrace trace)
        trace.stepComposition.signedDivRem
        (changeDivisorCorrect_of_authenticatedChunkTrace trace)
        (remainderFromDividendSign_of_authenticatedChunkTrace trace)
        (signedDivRemSpec_of_authenticatedChunkTrace trace)
    signedDivRemSoundnessEq := rfl
    signedDivRemSequenceProof :=
      signedDivRemSequenceProof_of_stepComposition trace.stepComposition
    temporaryRegisterHygiene := temporaryRegisterHygiene_of_authenticatedChunkTrace trace }

noncomputable def exactOpcodeFamilySemantics_of_exactBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (boundaries :
    ExactTraceBoundaries
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
    boundaries.stepComposition :=
  exactOpcodeFamilySemantics_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

end Nightstream.Rv64IM
