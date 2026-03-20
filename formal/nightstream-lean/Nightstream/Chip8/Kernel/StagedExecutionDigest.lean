import Nightstream.Chip8.Kernel.BridgeBinding
import Nightstream.Chip8.Stage2.EvidenceCoverageBounds

namespace Nightstream.Chip8.StagedExecutionDigest

open Nightstream.Chip8
open Nightstream.Chip8.DecodeAddressBinding
open Nightstream.Chip8.StepComposition
open Nightstream.Chip8.ContinuityBridge
open Nightstream.Chip8.BridgeBinding
open Nightstream.Chip8.RomScheduleBinding
open Nightstream.Chip8.EvidenceCoverage

abbrev F := StepComposition.F
abbrev Program := EvidenceCoverage.Program
abbrev MachineState := StepComposition.MachineState
abbrev InitialState := StepComposition.InitialState
abbrev ExternalSchedule := StepComposition.ExternalSchedule

section Digest

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment : Type*}

structure DigestPublicSurface
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rom : Program)
  (init : InitialState) where
  bound :
    @KernelPublicInputsBound DigestRom RootParamsId VmSpec TranscriptSeed
      inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
      inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
      inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
      init

structure Stage1DigestSurface
  (rom : Program)
  (pre : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) where
  fetchDecode : StepComposition.FetchDecodeBound rom pre.pc dec
  lookup : StepComposition.LookupBound dec pre z

structure Stage2DigestSurface
  (pre post : MachineState)
  (init : InitialState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) where
  witnessBinds : WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z
  memory : StepComposition.MemoryBound pre post init dec z

structure Stage3DigestSurface
  (rootEncode : RootEncode W Z F)
  (ajtaiCommit : Z → Commitment)
  (stepIdx : Nat)
  (z : Nightstream.Chip8.Witness F) where
  N : Nat
  β1 : F
  β2 : F
  shiftClaim : LaneShiftClaim F
  shiftProof : LaneShiftWitness F Unit
  currentRow : ContinuityRow F
  rowClaim : RowBindingClaim F Unit
  continuity :
    StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim shiftProof
      currentRow rowClaim z
  preparedStep : PreparedStep W Z Commitment F
  prepared :
    PreparedStepBound rootEncode ajtaiCommit z preparedStep
  bridgeBinding :
    BridgeBindingWitness rootEncode ajtaiCommit stepIdx z rowClaim preparedStep

structure ExecutionResultSurface
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (pre post : MachineState)
  (dec : DecodedStep Addr) where
  microstep : StepComposition.MicrostepCorrect rom σ dec pre post
  framebuffer : StepComposition.FramebufferBound pre post dec
  schedule : StepComposition.ScheduleBound σ stepIdx pre post dec

structure ExecutionDigest
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootEncode : RootEncode W Z F)
  (ajtaiCommit : Z → Commitment)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) where
  pub : DigestPublicSurface inputs rom init
  stage1 : Stage1DigestSurface rom pre dec z
  stage2 : Stage2DigestSurface pre post init dec z
  stage3 : Stage3DigestSurface rootEncode ajtaiCommit stepIdx z
  result : ExecutionResultSurface rom σ stepIdx pre post dec

abbrev StagedExecutionDigest := @ExecutionDigest

def StagedExecutionDigestBound
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootEncode : RootEncode W Z F)
  (ajtaiCommit : Z → Commitment)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z) : Prop :=
  @KernelPublicInputsBound DigestRom RootParamsId VmSpec TranscriptSeed
      inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
      inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
      inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
      init ∧
    StepComposition.FetchDecodeBound rom pre.pc dec ∧
    StepComposition.LookupBound dec pre z ∧
    WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z ∧
    StepComposition.MemoryBound pre post init dec z ∧
    StepComposition.ContinuityRowBound stepIdx d.stage3.N d.stage3.β1 d.stage3.β2
      d.stage3.shiftClaim d.stage3.shiftProof d.stage3.currentRow d.stage3.rowClaim
      z ∧
    PreparedStepBound rootEncode ajtaiCommit z d.stage3.preparedStep ∧
    BridgeBindingWitness rootEncode ajtaiCommit stepIdx z d.stage3.rowClaim
      d.stage3.preparedStep ∧
    StepComposition.MicrostepCorrect rom σ dec pre post ∧
    StepComposition.FramebufferBound pre post dec ∧
    StepComposition.ScheduleBound σ stepIdx pre post dec

theorem kernelPublicInputsBound_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  @KernelPublicInputsBound DigestRom RootParamsId VmSpec TranscriptSeed
    inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
    inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
    inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
    init := h.1

theorem fetchDecodeBound_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  StepComposition.FetchDecodeBound rom pre.pc dec := h.2.1

theorem lookupBound_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  StepComposition.LookupBound dec pre z := h.2.2.1

theorem witnessBinds_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z := h.2.2.2.1

theorem memoryBound_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  StepComposition.MemoryBound pre post init dec z := h.2.2.2.2.1

theorem continuityRowBound_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  StepComposition.ContinuityRowBound stepIdx d.stage3.N d.stage3.β1 d.stage3.β2
    d.stage3.shiftClaim d.stage3.shiftProof d.stage3.currentRow d.stage3.rowClaim
    z := h.2.2.2.2.2.1

theorem preparedStepBound_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  PreparedStepBound rootEncode ajtaiCommit z d.stage3.preparedStep := h.2.2.2.2.2.2.1

theorem bridgeBinding_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  BridgeBindingWitness rootEncode ajtaiCommit stepIdx z d.stage3.rowClaim
    d.stage3.preparedStep := h.2.2.2.2.2.2.2.1

theorem executionResultSurface_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  ExecutionResultSurface rom σ stepIdx pre post dec := by
  exact ⟨h.2.2.2.2.2.2.2.2.1, h.2.2.2.2.2.2.2.2.2.1,
    h.2.2.2.2.2.2.2.2.2.2⟩

theorem microstepCorrect_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  StepComposition.MicrostepCorrect rom σ dec pre post := by
  exact (executionResultSurface_of_digest h).1

theorem executionFrameBound_of_digest
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z}
  (h :
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d) :
  StepComposition.ExecutionFrameBound rom σ
    ({ dec := dec, pre := pre, post := post, row := z } :
      StepComposition.ExecutionFrame Addr) := by
  have hRowBound : ContinuityBridge.RowBound d.stage3.rowClaim z := by
    exact rowBound_of_bridgeBinding (bridgeBinding_of_digest h)
  refine ⟨?_, witnessBinds_of_digest h, microstepCorrect_of_digest h⟩
  exact hRowBound.2.2.2.2.2

theorem stagedExecutionDigest_of_exactEvidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z)
  (hResult : StepComposition.MicrostepCorrect rom σ dec pre post) :
  ∃ d :
    ExecutionDigest inputs rootEncode ajtaiCommit rom σ stepIdx init pre post
      dec z,
    StagedExecutionDigestBound inputs rootEncode ajtaiCommit rom σ stepIdx init
      pre post dec z d := by
  rcases semanticBounds_of_exactAuthenticatedEvidence h with
    ⟨hInputs, _hExecInputs, hWitness, hFetch, hLookup, hMem, hCont,
      hFramebuffer, hSchedule⟩
  rcases h with ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  rcases hSem with ⟨ev⟩
  have hContRow :
      StepComposition.ContinuityRowBound stepIdx ev.continuity.N ev.continuity.β1
        ev.continuity.β2 ev.continuity.shiftClaim ev.continuity.shiftProof
        ev.continuity.currentRow ev.continuity.rowClaim z := by
    exact ⟨ev.continuity.continuity, ev.continuity.currentRowIndex,
      ev.continuity.currentPcNext, ev.continuity.currentXIdx,
      ev.continuity.currentIsMemOp, ev.continuity.currentBurstLast,
      ev.continuity.rowClaimIndex, ev.continuity.rowBinding⟩
  let preparedStep := mkPreparedStep rootEncode ajtaiCommit z
  have hPrepared :
      PreparedStepBound rootEncode ajtaiCommit z preparedStep := by
    exact preparedStepBound_of_rowBinding ev.continuity.rowBinding
  have hBridge :
      BridgeBindingWitness rootEncode ajtaiCommit stepIdx z ev.continuity.rowClaim
        preparedStep := by
    refine
      { rowClaimIndex := ev.continuity.rowClaimIndex
        rowBinding := ev.continuity.rowBinding
        prepared := hPrepared }
  refine ⟨{
    pub := ⟨hInputs⟩
    stage1 := ⟨hFetch, hLookup⟩
    stage2 := ⟨hWitness, hMem⟩
    stage3 := {
      N := ev.continuity.N
      β1 := ev.continuity.β1
      β2 := ev.continuity.β2
      shiftClaim := ev.continuity.shiftClaim
      shiftProof := ev.continuity.shiftProof
      currentRow := ev.continuity.currentRow
      rowClaim := ev.continuity.rowClaim
      continuity := hContRow
      preparedStep := preparedStep
      prepared := hPrepared
      bridgeBinding := hBridge
    }
    result := ⟨hResult, hFramebuffer, hSchedule⟩
  }, by
    exact ⟨hInputs, hFetch, hLookup, hWitness, hMem, hContRow, hPrepared,
      hBridge, hResult, hFramebuffer, hSchedule⟩⟩

end Digest

end Nightstream.Chip8.StagedExecutionDigest
