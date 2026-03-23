import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.SignedDivRemOpcodeSemantics

/-!
Owns lifting of exact signed DIV/REM opcode consequences through the
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

theorem opcodeBound_of_authenticatedChunkTrace_signedDivRem
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
  SignedDivRemOpcodeBound
    trace.stepComposition.decodedRow
    trace.stepComposition.signedDivRem.opcode :=
  opcodeBound_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

theorem div_flags_of_authenticatedChunkTrace
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
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .div) :
  trace.stepComposition.decodedRow.isDiv = true ∧
    trace.stepComposition.decodedRow.isRem = false ∧
    trace.stepComposition.decodedRow.isWOp = false :=
  div_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem rem_flags_of_authenticatedChunkTrace
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
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .rem) :
  trace.stepComposition.decodedRow.isDiv = false ∧
    trace.stepComposition.decodedRow.isRem = true ∧
    trace.stepComposition.decodedRow.isWOp = false :=
  rem_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem divw_flags_of_authenticatedChunkTrace
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
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .divw) :
  trace.stepComposition.decodedRow.isDiv = true ∧
    trace.stepComposition.decodedRow.isRem = false ∧
    trace.stepComposition.decodedRow.isWOp = true :=
  divw_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem remw_flags_of_authenticatedChunkTrace
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
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .remw) :
  trace.stepComposition.decodedRow.isDiv = false ∧
    trace.stepComposition.decodedRow.isRem = true ∧
    trace.stepComposition.decodedRow.isWOp = true :=
  remw_flags_of_signedDivRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem spec_of_signedDiv_authenticatedChunkTrace
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
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .div ∨
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .divw) :
  SignedDivRemSpec
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.remainderSigned :=
  spec_of_signedDivOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem spec_of_signedRem_authenticatedChunkTrace
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
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .rem ∨
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.opcode =
      .remw) :
  SignedDivRemSpec
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace).signedDivRem.soundness.remainderSigned :=
  spec_of_signedRemOpcodeSemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)
    hOpcode

theorem div_flags_of_exactBoundaries
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
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).signedDivRem.soundness.opcode =
      .div) :
  boundaries.stepComposition.decodedRow.isDiv = true ∧
    boundaries.stepComposition.decodedRow.isRem = false ∧
    boundaries.stepComposition.decodedRow.isWOp = false := by
  simpa [exactOpcodeFamilySemantics_of_exactBoundaries] using
    div_flags_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

theorem spec_of_signedDiv_of_exactBoundaries
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
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).signedDivRem.soundness.opcode =
      .div ∨
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).signedDivRem.soundness.opcode =
      .divw) :
  SignedDivRemSpec
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).signedDivRem.soundness.dividend
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).signedDivRem.soundness.quotient
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).signedDivRem.soundness.divisor
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries).signedDivRem.soundness.remainderSigned := by
  simpa [exactOpcodeFamilySemantics_of_exactBoundaries] using
    spec_of_signedDiv_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)
      hOpcode

end

end Nightstream.Rv64IM
