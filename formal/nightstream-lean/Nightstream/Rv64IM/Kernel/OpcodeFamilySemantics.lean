import Nightstream.Rv64IM.Kernel.ExactKernelBoundaries
import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Kernel.OpcodeClassSemantics

/-!
Owns lifting of exact opcode-family semantic facts through the kernel
soundness and exact kernel-boundary surfaces. This file does not re-own
execution semantics, authenticated trace closure, or transcript/bridge logic.
-/

namespace Nightstream.Rv64IM

noncomputable def exactOpcodeFamilySemantics_of_kernelSoundness
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
  (kernel :
    KernelSoundnessConclusion
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding) :
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
    kernel.authenticatedTrace.stepComposition :=
  { canonical := canonicalOpcodeClassSemantics_of_kernelSoundness kernel
    nativeAlu :=
      nativeAluExecutionFacts_of_opcodeClassFacts
        (nativeAluFacts_of_kernelSoundness kernel)
    wordShift :=
      wordShiftExecutionFacts_of_opcodeClassFacts
        (wordShiftFacts_of_kernelSoundness kernel)
    controlFlow :=
      controlFlowExecutionFacts_of_opcodeClassFacts
        (controlFlowFacts_of_kernelSoundness kernel)
        kernel.authenticatedTrace.stepComposition.executionRow.wordToNat
        kernel.authenticatedTrace.stepComposition.executionRow.lane
        (takenTargetAlignmentBound_of_kernelSoundness kernel)
    controlFlowWordToNatEq := rfl
    controlFlowLaneEq := rfl
    narrowMemory :=
      narrowMemoryExecutionFacts_of_opcodeClassFacts
        (narrowMemoryFacts_of_kernelSoundness kernel)
    multiply :=
      multiplyExecutionFacts_of_opcodeClassFacts
        (multiplyFacts_of_kernelSoundness kernel)
    nativeAluSequenceProof :=
      nativeAluSequenceProof_of_stepComposition kernel.authenticatedTrace.stepComposition
    wordShiftSequenceProof :=
      wordShiftSequenceProof_of_stepComposition kernel.authenticatedTrace.stepComposition
    controlFlowSequenceProof :=
      controlFlowSequenceProof_of_stepComposition kernel.authenticatedTrace.stepComposition
    narrowMemorySequenceProof :=
      narrowMemorySequenceProof_of_stepComposition kernel.authenticatedTrace.stepComposition
    multiplySequenceProof :=
      multiplySequenceProof_of_stepComposition kernel.authenticatedTrace.stepComposition
    unsignedDivRem :=
      unsignedDivRemExecutionFacts_of_opcodeClassFacts
        (unsignedDivRemFacts_of_kernelSoundness kernel)
        kernel.authenticatedTrace.stepComposition.unsignedDivRem
        kernel.authenticatedTrace.stepComposition.executionRow.mulHigh
        kernel.authenticatedTrace.stepComposition.executionRow.zeroWord
        kernel.authenticatedTrace.stepComposition.executionRow.divRemQuotient
        kernel.authenticatedTrace.stepComposition.executionRow.divRemDivisor
        (mulUNoOverflowBound_of_kernelSoundness kernel)
        (mulUNoOverflow_of_kernelSoundness kernel)
        (unsignedDivRemSpec_of_kernelSoundness kernel)
        (by
          intro quotient' remainder' hSpec
          exact unsignedDivRemDeterministic_of_kernelSoundness kernel hSpec)
    unsignedDivRemSoundnessEq := rfl
    unsignedDivRemSequenceProof :=
      unsignedDivRemSequenceProof_of_stepComposition kernel.authenticatedTrace.stepComposition
    signedDivRem :=
      signedDivRemExecutionFacts_of_opcodeClassFacts
        (signedDivRemFacts_of_kernelSoundness kernel)
        kernel.authenticatedTrace.stepComposition.signedDivRem
        (changeDivisorCorrect_of_kernelSoundness kernel)
        (remainderFromDividendSign_of_kernelSoundness kernel)
        (signedDivRemSpec_of_kernelSoundness kernel)
    signedDivRemSoundnessEq := rfl
    signedDivRemSequenceProof :=
      signedDivRemSequenceProof_of_stepComposition kernel.authenticatedTrace.stepComposition
    temporaryRegisterHygiene := temporaryRegisterHygiene_of_kernelSoundness kernel }

noncomputable def exactOpcodeFamilySemantics_of_exactKernelBoundaries
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep ProgramImage LoweringVersion RomTable BytecodeTable RomCommit
    BytecodeCommit Source CommitmentId Point PolynomialId Value Digest
    ExactOpeningWitness OpeningRefinement RowProjectionWitness BridgeBinding :
    Type _} [OfNat Limb 0]
  (boundaries :
    ExactKernelBoundaries
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
      ProgramImage
      LoweringVersion
      RomTable
      BytecodeTable
      RomCommit
      BytecodeCommit
      Source
      CommitmentId
      Point
      PolynomialId
      Value
      Digest
      ExactOpeningWitness
      OpeningRefinement
      RowProjectionWitness
      BridgeBinding) :
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
    boundaries.trace.stepComposition :=
  exactOpcodeFamilySemantics_of_kernelSoundness
    (kernelSoundness_of_exactBoundaries boundaries)

end Nightstream.Rv64IM
