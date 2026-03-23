import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.WordShiftWordArithmetic

/-!
Owns lifting of exact word/shift word-level arithmetic consequences through the
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

theorem wordArithmetic_of_authenticatedChunkTrace_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode : trace.stepComposition.wordShiftOpcode = opcode) :
  trace.stepComposition.executionRow.results.aluResult =
    WordShiftWordResult
      trace.stepComposition.wordShiftWordOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.limbPairToWord
      opcode := by
  cases opcode with
  | addw =>
      simpa using
        (addw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | addiw =>
      simpa using
        (addiw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | subw =>
      simpa using
        (subw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sllw =>
      simpa using
        (sllw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | slliw =>
      simpa using
        (slliw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | srlw =>
      simpa using
        (srlw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | srliw =>
      simpa using
        (srliw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sraw =>
      simpa using
        (sraw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)
  | sraiw =>
      simpa using
        (sraiw_wordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode)

theorem authenticatedWordArithmetic_of_authenticatedChunkTrace_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode : trace.stepComposition.wordShiftOpcode = opcode)
  (hRd : trace.stepComposition.decodedRow.rd ≠ trace.stepComposition.x0) :
  trace.stepComposition.limbPairToWord trace.stepComposition.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      trace.stepComposition.wordShiftWordOps
      trace.stepComposition.decodedRow
      trace.stepComposition.twistBinding.registerTwist
      trace.stepComposition.limbPairToWord
      opcode := by
  cases opcode with
  | addw =>
      simpa using
        (addw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | addiw =>
      simpa using
        (addiw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | subw =>
      simpa using
        (subw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sllw =>
      simpa using
        (sllw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | slliw =>
      simpa using
        (slliw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | srlw =>
      simpa using
        (srlw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | srliw =>
      simpa using
        (srliw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sraw =>
      simpa using
        (sraw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)
  | sraiw =>
      simpa using
        (sraiw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
          (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
          hOpcode
          hRd)

theorem wordArithmetic_of_exactBoundaries_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode : boundaries.stepComposition.wordShiftOpcode = opcode) :
  boundaries.stepComposition.executionRow.results.aluResult =
    WordShiftWordResult
      boundaries.stepComposition.wordShiftWordOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.limbPairToWord
      opcode := by
  exact
    wordArithmetic_of_authenticatedChunkTrace_wordShift
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem authenticatedWordArithmetic_of_exactBoundaries_wordShift
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
  {opcode : WordShiftOpcode}
  (hOpcode : boundaries.stepComposition.wordShiftOpcode = opcode)
  (hRd : boundaries.stepComposition.decodedRow.rd ≠ boundaries.stepComposition.x0) :
  boundaries.stepComposition.limbPairToWord boundaries.stepComposition.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      boundaries.stepComposition.wordShiftWordOps
      boundaries.stepComposition.decodedRow
      boundaries.stepComposition.twistBinding.registerTwist
      boundaries.stepComposition.limbPairToWord
      opcode := by
  exact
    authenticatedWordArithmetic_of_authenticatedChunkTrace_wordShift
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode
      hRd

end

end Nightstream.Rv64IM
