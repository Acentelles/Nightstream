import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.UnsignedDivRemOpcodeSemantics

/-!
Owns lifting of exact unsigned DIV/REM opcode consequences through the
authenticated trace and exact trace-boundary surfaces. This file does not
re-own execution semantics or kernel-level conclusions.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]

theorem opcodeBound_of_authenticatedChunkTrace_unsignedDivRem
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
  UnsignedDivRemOpcodeBound
    trace.stepComposition.decodedRow
    trace.stepComposition.unsignedDivRem.opcode :=
  opcodeBound_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem divu_flags_of_authenticatedChunkTrace
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .divu) :
  trace.stepComposition.decodedRow.isDiv = true ∧
    trace.stepComposition.decodedRow.isRem = false ∧
    trace.stepComposition.decodedRow.isWOp = false :=
  divu_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem remu_flags_of_authenticatedChunkTrace
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .remu) :
  trace.stepComposition.decodedRow.isDiv = false ∧
    trace.stepComposition.decodedRow.isRem = true ∧
    trace.stepComposition.decodedRow.isWOp = false :=
  remu_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem divuw_flags_of_authenticatedChunkTrace
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .divuw) :
  trace.stepComposition.decodedRow.isDiv = true ∧
    trace.stepComposition.decodedRow.isRem = false ∧
    trace.stepComposition.decodedRow.isWOp = true :=
  divuw_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem remuw_flags_of_authenticatedChunkTrace
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .remuw) :
  trace.stepComposition.decodedRow.isDiv = false ∧
    trace.stepComposition.decodedRow.isRem = true ∧
    trace.stepComposition.decodedRow.isWOp = true :=
  remuw_flags_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem spec_of_unsignedDivu_authenticatedChunkTrace
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .divu ∨
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .divuw) :
  UnsignedDivRemSpec
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.remainder :=
  spec_of_unsignedDivuOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem spec_of_unsignedRemu_authenticatedChunkTrace
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .remu ∨
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.opcode =
      .remuw) :
  UnsignedDivRemSpec
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.remainder :=
  spec_of_unsignedRemuOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem deterministic_of_unsignedDivRem_authenticatedChunkTrace
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
  {quotient' remainder'}
  (hSpec :
    UnsignedDivRemSpec
      (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.dividend
      quotient'
      (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.divisor
      remainder') :
  quotient' =
      (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.quotient ∧
    remainder' =
      (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).unsignedDivRem.soundness.remainder :=
  deterministic_of_unsignedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hSpec

theorem divu_flags_of_exactBoundaries
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).unsignedDivRem.soundness.opcode =
      .divu) :
  boundaries.stepComposition.decodedRow.isDiv = true ∧
    boundaries.stepComposition.decodedRow.isRem = false ∧
    boundaries.stepComposition.decodedRow.isWOp = false := by
  simpa [exactOpcodeFamilySemantics_of_exactBoundaries] using
    divu_flags_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem spec_of_unsignedDivu_of_exactBoundaries
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
  (hOpcode :
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).unsignedDivRem.soundness.opcode =
      .divu ∨
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).unsignedDivRem.soundness.opcode =
      .divuw) :
  UnsignedDivRemSpec
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).unsignedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).unsignedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).unsignedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).unsignedDivRem.soundness.remainder := by
  simpa [exactOpcodeFamilySemantics_of_exactBoundaries] using
    spec_of_unsignedDivu_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
