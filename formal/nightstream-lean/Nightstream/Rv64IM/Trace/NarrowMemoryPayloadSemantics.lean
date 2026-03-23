import Nightstream.Rv64IM.Trace.OpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.ExactNarrowMemoryPayloadSemantics

/-!
Owns lifting of the exact narrow-memory RAM-side payload bundle through
authenticated trace and exact trace-boundary surfaces.
-/

namespace Nightstream.Rv64IM

noncomputable def exactNarrowMemoryPayloadSemantics_of_authenticatedChunkTrace
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
  ExactNarrowMemoryPayloadSemantics
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
    trace.stepComposition
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace) :=
  exactNarrowMemoryPayloadSemantics_of_exactOpcodeFamilySemantics
    (exactOpcodeFamilySemantics_of_authenticatedChunkTrace trace)

noncomputable def exactNarrowMemoryPayloadSemantics_of_exactBoundaries
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
  ExactNarrowMemoryPayloadSemantics
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
    boundaries.stepComposition
    (exactOpcodeFamilySemantics_of_exactBoundaries boundaries) :=
  exactNarrowMemoryPayloadSemantics_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

end Nightstream.Rv64IM
