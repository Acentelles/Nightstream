import Nightstream.Rv64IM.Trace.ExactTraceBoundaries
import Nightstream.Rv64IM.Execution.ExactOpcodeClassSemantics

/-!
Owns lifting of exact opcode-class semantic facts through the authenticated
trace and exact trace-boundary surfaces. This file does not re-own execution
semantics or kernel-level conclusions.
-/

namespace Nightstream.Rv64IM

noncomputable def canonicalOpcodeClassSemantics_of_authenticatedChunkTrace
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
  CanonicalOpcodeClassSemantics
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace) :=
  canonicalOpcodeClassSemantics_of_canonicalOpcodeProofs
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def nativeAluFacts_of_authenticatedChunkTrace
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
  OpcodeClassExecutionFacts
    .nativeAlu
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace).nativeAlu :=
  nativeAluFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def wordShiftFacts_of_authenticatedChunkTrace
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
  OpcodeClassExecutionFacts
    .wordShift
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace).wordShift :=
  wordShiftFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def controlFlowFacts_of_authenticatedChunkTrace
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
  OpcodeClassExecutionFacts
    .controlFlow
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace).controlFlow :=
  controlFlowFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def narrowMemoryFacts_of_authenticatedChunkTrace
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
  OpcodeClassExecutionFacts
    .narrowMemory
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace).narrowMemory :=
  narrowMemoryFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def multiplyFacts_of_authenticatedChunkTrace
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
  OpcodeClassExecutionFacts
    .multiply
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace).multiply :=
  multiplyFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def unsignedDivRemFacts_of_authenticatedChunkTrace
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
  OpcodeClassExecutionFacts
    .unsignedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace).unsignedDivRem :=
  unsignedDivRemFacts_of_canonicalOpcodeProofs
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def signedDivRemFacts_of_authenticatedChunkTrace
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
  OpcodeClassExecutionFacts
    .signedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace trace).signedDivRem :=
  signedDivRemFacts_of_canonicalOpcodeProofs (canonicalOpcodeProofs_of_authenticatedChunkTrace trace)

noncomputable def canonicalOpcodeClassSemantics_of_exactBoundaries
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
  CanonicalOpcodeClassSemantics
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)) :=
  canonicalOpcodeClassSemantics_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def nativeAluFacts_of_exactBoundaries
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
  OpcodeClassExecutionFacts
    .nativeAlu
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)).nativeAlu :=
  nativeAluFacts_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def wordShiftFacts_of_exactBoundaries
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
  OpcodeClassExecutionFacts
    .wordShift
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)).wordShift :=
  wordShiftFacts_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def controlFlowFacts_of_exactBoundaries
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
  OpcodeClassExecutionFacts
    .controlFlow
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)).controlFlow :=
  controlFlowFacts_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def narrowMemoryFacts_of_exactBoundaries
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
  OpcodeClassExecutionFacts
    .narrowMemory
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)).narrowMemory :=
  narrowMemoryFacts_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def multiplyFacts_of_exactBoundaries
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
  OpcodeClassExecutionFacts
    .multiply
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)).multiply :=
  multiplyFacts_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def unsignedDivRemFacts_of_exactBoundaries
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
  OpcodeClassExecutionFacts
    .unsignedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)).unsignedDivRem :=
  unsignedDivRemFacts_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

noncomputable def signedDivRemFacts_of_exactBoundaries
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
  OpcodeClassExecutionFacts
    .signedDivRem
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    (canonicalOpcodeProofs_of_authenticatedChunkTrace
      (authenticatedChunkTrace_of_exactBoundaries boundaries)).signedDivRem :=
  signedDivRemFacts_of_authenticatedChunkTrace
    (authenticatedChunkTrace_of_exactBoundaries boundaries)

end Nightstream.Rv64IM
