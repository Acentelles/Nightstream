import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.NativeAluEncodedArithmetic

/-!
Owns lifting of exact native-ALU encoded arithmetic consequences through the
authenticated trace and exact trace-boundary surfaces.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]

theorem encodedArithmetic_of_authenticatedChunkTrace_nativeAlu
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
      PreparedStep)
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode) :
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    NativeAluEncodedResult
      trace.stepComposition.nativeAluEncodedOps
      trace.stepComposition.wordToLimbPair
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.executionRow.lane
      opcode := by
  cases opcode with
  | add =>
      simpa using
        (add_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | addi =>
      simpa using
        (addi_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sub =>
      simpa using
        (sub_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | andOp =>
      simpa using
        (and_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | andi =>
      simpa using
        (andi_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | orOp =>
      simpa using
        (or_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | ori =>
      simpa using
        (ori_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | xorOp =>
      simpa using
        (xor_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | xori =>
      simpa using
        (xori_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | slt =>
      simpa using
        (slt_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | slti =>
      simpa using
        (slti_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sltu =>
      simpa using
        (sltu_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sltiu =>
      simpa using
        (sltiu_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | lui =>
      simpa using
        (lui_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | auipc =>
      simpa using
        (auipc_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | fence =>
      simpa using
        (fence_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | ecall =>
      simpa using
        (ecall_encodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)

theorem authenticatedEncodedArithmetic_of_authenticatedChunkTrace_nativeAlu
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
      PreparedStep)
  {opcode : NativeAluOpcode}
  (hOpcode : trace.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    NativeAluEncodedResult
      trace.stepComposition.nativeAluEncodedOps
      trace.stepComposition.wordToLimbPair
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.executionRow.lane
      opcode := by
  cases opcode with
  | add =>
      simpa using
        (add_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | addi =>
      simpa using
        (addi_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sub =>
      simpa using
        (sub_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | andOp =>
      simpa using
        (and_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | andi =>
      simpa using
        (andi_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | orOp =>
      simpa using
        (or_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | ori =>
      simpa using
        (ori_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | xorOp =>
      simpa using
        (xor_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | xori =>
      simpa using
        (xori_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | slt =>
      simpa using
        (slt_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | slti =>
      simpa using
        (slti_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sltu =>
      simpa using
        (sltu_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sltiu =>
      simpa using
        (sltiu_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | lui =>
      simpa using
        (lui_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | auipc =>
      simpa using
        (auipc_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | fence =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites
  | ecall =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites

theorem encodedArithmetic_of_exactBoundaries_nativeAlu
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
      PreparedStep)
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode) :
  boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.results.aluResult =
    NativeAluEncodedResult
      boundaries.stepComposition.nativeAluEncodedOps
      boundaries.stepComposition.wordToLimbPair
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.executionRow.lane
      opcode := by
  exact
    encodedArithmetic_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedEncodedArithmetic_of_exactBoundaries_nativeAlu
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
      PreparedStep)
  {opcode : NativeAluOpcode}
  (hOpcode : boundaries.stepComposition.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
    NativeAluEncodedResult
      boundaries.stepComposition.nativeAluEncodedOps
      boundaries.stepComposition.wordToLimbPair
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.executionRow.lane
      opcode := by
  exact
    authenticatedEncodedArithmetic_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

end

end Nightstream.Rv64IM
