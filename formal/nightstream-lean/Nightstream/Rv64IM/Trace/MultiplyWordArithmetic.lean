import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.MultiplyWordArithmetic

/-!
Owns lifting of exact multiply word-level arithmetic consequences through the
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

theorem wordArithmetic_of_authenticatedChunkTrace_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode) :
  trace.stepComposition.executionRow.results.aluResult =
    MultiplyWordResult
      trace.stepComposition.multiplyWordOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.limbPairToWord
      opcode := by
  cases opcode with
  | mul =>
      simpa using
        (mul_wordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulh =>
      simpa using
        (mulh_wordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulhu =>
      simpa using
        (mulhu_wordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulhsu =>
      simpa using
        (mulhsu_wordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulw =>
      simpa using
        (mulw_wordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)

theorem authenticatedWordArithmetic_of_authenticatedChunkTrace_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : trace.stepComposition.multiplyOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.limbPairToWord trace.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyWordResult
      trace.stepComposition.multiplyWordOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.limbPairToWord
      opcode := by
  cases opcode with
  | mul =>
      simpa using
        (mul_authenticatedWordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulh =>
      simpa using
        (mulh_authenticatedWordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulhu =>
      simpa using
        (mulhu_authenticatedWordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulhsu =>
      simpa using
        (mulhsu_authenticatedWordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulw =>
      simpa using
        (mulw_authenticatedWordArithmetic_of_multiplyWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)

theorem wordArithmetic_of_exactBoundaries_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode) :
  boundaries.stepComposition.executionRow.results.aluResult =
    MultiplyWordResult
      boundaries.stepComposition.multiplyWordOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedWordArithmetic_of_exactBoundaries_multiply
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
  {opcode : MultiplyOpcode}
  (hOpcode : boundaries.stepComposition.multiplyOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.limbPairToWord boundaries.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyWordResult
      boundaries.stepComposition.multiplyWordOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
