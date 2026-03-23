import Nightstream.Rv64IM.Execution.StepComposition

/-!
Owns the exact opcode-class extraction surface above `StepComposition`. This
file packages the seven canonical opcode-class proof objects in fixed order; it
does not re-own stage-local semantics or kernel-level closure.
-/

namespace Nightstream.Rv64IM

structure CanonicalOpcodeProofs
  (Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _)
  (proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)) where
  nativeAlu : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  wordShift : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  controlFlow : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  narrowMemory : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  multiply : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  unsignedDivRem : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  signedDivRem : OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation
  proofsEq :
    proofs =
      [ nativeAlu
      , wordShift
      , controlFlow
      , narrowMemory
      , multiply
      , unsignedDivRem
      , signedDivRem
      ]
  nativeAluClass : nativeAlu.opcodeClass = .nativeAlu
  wordShiftClass : wordShift.opcodeClass = .wordShift
  controlFlowClass : controlFlow.opcodeClass = .controlFlow
  narrowMemoryClass : narrowMemory.opcodeClass = .narrowMemory
  multiplyClass : multiply.opcodeClass = .multiply
  unsignedDivRemClass : unsignedDivRem.opcodeClass = .unsignedDivRem
  signedDivRemClass : signedDivRem.opcodeClass = .signedDivRem

theorem canonicalOpcodeProofs_nonempty_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
  Nonempty
    (CanonicalOpcodeProofs
      Pc
      BytecodeAddr
      RegIdx
      RamAddr
      Word
      StateLocation
      pkg.opcodeProofs) := by
  rcases opcodeProofs_canonicalShape_of_stepComposition pkg with
    ⟨nativeAlu, wordShift, controlFlow, narrowMemory, multiply, unsignedDivRem,
      signedDivRem, hProofs, hNativeAlu, hWordShift, hControlFlow, hNarrowMemory,
      hMultiply, hUnsignedDivRem, hSignedDivRem⟩
  exact ⟨
    { nativeAlu := nativeAlu
      wordShift := wordShift
      controlFlow := controlFlow
      narrowMemory := narrowMemory
      multiply := multiply
      unsignedDivRem := unsignedDivRem
      signedDivRem := signedDivRem
      proofsEq := hProofs
      nativeAluClass := hNativeAlu
      wordShiftClass := hWordShift
      controlFlowClass := hControlFlow
      narrowMemoryClass := hNarrowMemory
      multiplyClass := hMultiply
      unsignedDivRemClass := hUnsignedDivRem
      signedDivRemClass := hSignedDivRem }⟩

noncomputable def canonicalOpcodeProofs_of_stepComposition
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _} [OfNat Limb 0]
  (pkg :
    StepCompositionProofPackage
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
  CanonicalOpcodeProofs
    Pc
    BytecodeAddr
    RegIdx
    RamAddr
    Word
    StateLocation
    pkg.opcodeProofs :=
  Classical.choice (canonicalOpcodeProofs_nonempty_of_stepComposition pkg)

theorem nativeAlu_mem_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  canonical.nativeAlu ∈ proofs := by
  simp [canonical.proofsEq]

theorem wordShift_mem_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  canonical.wordShift ∈ proofs := by
  simp [canonical.proofsEq]

theorem controlFlow_mem_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  canonical.controlFlow ∈ proofs := by
  simp [canonical.proofsEq]

theorem narrowMemory_mem_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  canonical.narrowMemory ∈ proofs := by
  simp [canonical.proofsEq]

theorem multiply_mem_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  canonical.multiply ∈ proofs := by
  simp [canonical.proofsEq]

theorem unsignedDivRem_mem_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  canonical.unsignedDivRem ∈ proofs := by
  simp [canonical.proofsEq]

theorem signedDivRem_mem_of_canonicalOpcodeProofs
  {Pc BytecodeAddr RegIdx RamAddr Word StateLocation : Type _}
  {proofs : List (OpcodeClassProof Pc BytecodeAddr RegIdx RamAddr Word StateLocation)}
  (canonical :
    CanonicalOpcodeProofs Pc BytecodeAddr RegIdx RamAddr Word StateLocation proofs) :
  canonical.signedDivRem ∈ proofs := by
  simp [canonical.proofsEq]

end Nightstream.Rv64IM
