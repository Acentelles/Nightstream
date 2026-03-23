import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.MultiplyEncodedArithmetic

/-!
Owns lifting of exact multiply encoded arithmetic consequences through the
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

theorem encodedArithmetic_of_authenticatedChunkTrace_multiply
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
  trace.stepComposition.wordToLimbPair trace.stepComposition.executionRow.results.aluResult =
    MultiplyEncodedResult
      trace.stepComposition.multiplyEncodedOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      opcode := by
  cases opcode with
  | mul =>
      simpa using
        (mul_encodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulh =>
      simpa using
        (mulh_encodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulhu =>
      simpa using
        (mulhu_encodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulhsu =>
      simpa using
        (mulhsu_encodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | mulw =>
      simpa using
        (mulw_encodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)

theorem authenticatedEncodedArithmetic_of_authenticatedChunkTrace_multiply
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
  trace.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyEncodedResult
      trace.stepComposition.multiplyEncodedOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      opcode := by
  cases opcode with
  | mul =>
      simpa using
        (mul_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulh =>
      simpa using
        (mulh_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulhu =>
      simpa using
        (mulhu_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulhsu =>
      simpa using
        (mulhsu_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | mulw =>
      simpa using
        (mulw_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)

theorem encodedArithmetic_of_exactBoundaries_multiply
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
  boundaries.stepComposition.wordToLimbPair boundaries.stepComposition.executionRow.results.aluResult =
    MultiplyEncodedResult
      boundaries.stepComposition.multiplyEncodedOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      opcode := by
  exact
    encodedArithmetic_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedEncodedArithmetic_of_exactBoundaries_multiply
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
  boundaries.stepComposition.twistBinding.registerTwist.wvReg =
    MultiplyEncodedResult
      boundaries.stepComposition.multiplyEncodedOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      opcode := by
  exact
    authenticatedEncodedArithmetic_of_authenticatedChunkTrace_multiply
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
