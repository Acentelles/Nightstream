import Nightstream.Chip8.Trace.AuthenticatedTrace

/-!
Owns extraction of local CHIP-8 state-transition facts from one exact frame
evidence object. This file does not reconstruct trace-global temporal closure;
it only exposes the per-frame semantic step facts already implied by exact
authenticated evidence.
-/

namespace Nightstream.Chip8.ExactFrameSemantics

open Nightstream.Chip8
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.StepComposition

abbrev F := AuthenticatedTrace.F
abbrev PCSContext := EvidenceCoverage.PCSContext
abbrev ExecutionInputContext := EvidenceCoverage.ExecutionInputContext
abbrev Program := AuthenticatedTrace.Program
abbrev MachineState := AuthenticatedTrace.MachineState
abbrev InitialState := AuthenticatedTrace.InitialState
abbrev ExternalSchedule := AuthenticatedTrace.ExternalSchedule

section Exact

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {pcs : PCSContext AuxIndex EvalPoint}
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {publicTable : Table → Prop}
  {tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop}
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → F}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression :
    AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}

theorem microstepCorrect_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  MicrostepCorrect rom σ frame.frame.dec frame.frame.pre frame.frame.post := by
  exact executionFrameBound_microstepCorrect
    (executionFrameBound_of_exactFrameEvidence frame)

theorem ldImm_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .ldImm) :
  frame.frame.post.pc = frame.frame.pre.pc + 1 ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    frame.frame.post.v frame.frame.dec.x = frame.frame.dec.kk ∧
    RegistersPreservedExcept frame.frame.pre frame.frame.post frame.frame.dec.x ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_ldImm hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem addImm_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .addImm) :
  frame.frame.post.pc = frame.frame.pre.pc + 1 ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    frame.frame.post.v frame.frame.dec.x =
      byteAdd (frame.frame.pre.v frame.frame.dec.x) frame.frame.dec.kk ∧
    RegistersPreservedExcept frame.frame.pre frame.frame.post frame.frame.dec.x ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_addImm hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem mov_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .mov) :
  frame.frame.post.pc = frame.frame.pre.pc + 1 ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    frame.frame.post.v frame.frame.dec.x =
      frame.frame.pre.v frame.frame.dec.y ∧
    RegistersPreservedExcept frame.frame.pre frame.frame.post frame.frame.dec.x ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_mov hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem addReg_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .addReg) :
  frame.frame.post.pc = frame.frame.pre.pc + 1 ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    frame.frame.post.v frame.frame.dec.x =
      byteAdd (frame.frame.pre.v frame.frame.dec.x)
        (frame.frame.pre.v frame.frame.dec.y) ∧
    RegistersPreservedExcept frame.frame.pre frame.frame.post frame.frame.dec.x ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_addReg hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem skipEqImm_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .skipEqImm) :
  frame.frame.post.pc =
      frame.frame.pre.pc + 1 +
        skipEqBit (frame.frame.pre.v frame.frame.dec.x) frame.frame.dec.kk ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    RegistersPreserved frame.frame.pre frame.frame.post ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_skipEqImm hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem jump_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .jump) :
  frame.frame.post.pc = frame.frame.dec.nnnWord ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    RegistersPreserved frame.frame.pre frame.frame.post ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_jump hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem ldI_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .ldI) :
  frame.frame.post.pc = frame.frame.pre.pc + 1 ∧
    frame.frame.post.i = frame.frame.dec.nnnAddr ∧
    RegistersPreserved frame.frame.pre frame.frame.post ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_ldI hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem storeRegs_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .storeRegs) :
  frame.frame.post.pc =
      frame.frame.pre.pc +
        WitnessMemoryBinding.burstLastValue frame.frame.dec ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    RegistersPreserved frame.frame.pre frame.frame.post ∧
    RamPrefixStored frame.frame.pre frame.frame.post frame.frame.dec ∧
    RamPreservedOutsidePrefix frame.frame.pre frame.frame.post frame.frame.dec := by
  exact StepComposition.microstepCorrect_storeRegs hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

theorem loadRegs_facts_of_exactFrameEvidence
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init)
  (hOpcode : frame.frame.dec.opcodeId = .loadRegs) :
  frame.frame.post.pc =
      frame.frame.pre.pc +
        WitnessMemoryBinding.burstLastValue frame.frame.dec ∧
    frame.frame.post.i = frame.frame.pre.i ∧
    RegistersLoadedPrefix frame.frame.pre frame.frame.post frame.frame.dec ∧
    RegistersPreservedAbove frame.frame.pre frame.frame.post frame.frame.dec.x ∧
    RamPreserved frame.frame.pre frame.frame.post := by
  exact StepComposition.microstepCorrect_loadRegs hOpcode
    (microstepCorrect_of_exactFrameEvidence frame)

end Exact

end Nightstream.Chip8.ExactFrameSemantics
