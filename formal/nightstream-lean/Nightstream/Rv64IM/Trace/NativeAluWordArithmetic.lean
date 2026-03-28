import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.NativeAluWordArithmetic

/-!
Owns lifting of exact native-ALU word-level arithmetic consequences through the
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

theorem wordArithmetic_of_authenticatedChunkTrace_nativeAlu
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
  trace.stepComposition.executionRow.results.aluResult =
    NativeAluWordResult
      trace.stepComposition.nativeAluWordOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.executionRow.lane
      trace.stepComposition.limbPairToWord
      opcode := by
  cases opcode with
  | add =>
      simpa using
        (add_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | addi =>
      simpa using
        (addi_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sub =>
      simpa using
        (sub_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | andOp =>
      simpa using
        (and_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | andi =>
      simpa using
        (andi_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | orOp =>
      simpa using
        (or_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | ori =>
      simpa using
        (ori_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | xorOp =>
      simpa using
        (xor_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | xori =>
      simpa using
        (xori_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | slt =>
      simpa using
        (slt_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | slti =>
      simpa using
        (slti_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sltu =>
      simpa using
        (sltu_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sltiu =>
      simpa using
        (sltiu_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | lui =>
      simpa using
        (lui_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | auipc =>
      simpa using
        (auipc_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | fence =>
      simpa using
        (fence_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | ecall =>
      simpa using
        (ecall_wordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)

theorem authenticatedWordArithmetic_of_authenticatedChunkTrace_nativeAlu
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
  trace.stepComposition.limbPairToWord trace.stepComposition.twistBinding.registerTwist.wvReg =
    NativeAluWordResult
      trace.stepComposition.nativeAluWordOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.executionRow.lane
      trace.stepComposition.limbPairToWord
      opcode := by
  cases opcode with
  | add =>
      simpa using
        (add_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | addi =>
      simpa using
        (addi_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sub =>
      simpa using
        (sub_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | andOp =>
      simpa using
        (and_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | andi =>
      simpa using
        (andi_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | orOp =>
      simpa using
        (or_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | ori =>
      simpa using
        (ori_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | xorOp =>
      simpa using
        (xor_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | xori =>
      simpa using
        (xori_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | slt =>
      simpa using
        (slt_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | slti =>
      simpa using
        (slti_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sltu =>
      simpa using
        (sltu_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sltiu =>
      simpa using
        (sltiu_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | lui =>
      simpa using
        (lui_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | auipc =>
      simpa using
        (auipc_authenticatedWordArithmetic_of_nativeAluWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | fence =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites
  | ecall =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites

theorem wordArithmetic_of_exactBoundaries_nativeAlu
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
  boundaries.stepComposition.executionRow.results.aluResult =
    NativeAluWordResult
      boundaries.stepComposition.nativeAluWordOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.executionRow.lane
      boundaries.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedWordArithmetic_of_exactBoundaries_nativeAlu
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
  boundaries.stepComposition.limbPairToWord boundaries.stepComposition.twistBinding.registerTwist.wvReg =
    NativeAluWordResult
      boundaries.stepComposition.nativeAluWordOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.executionRow.lane
      boundaries.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_authenticatedChunkTrace_nativeAlu
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hWrites
      hRd

end

end Nightstream.Rv64IM
