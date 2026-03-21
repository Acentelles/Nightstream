import Nightstream.Chip8.Kernel.StagedExecutionDigest

namespace Nightstream.Chip8.ArtifactAudit

open Nightstream.Chip8
open Nightstream.Chip8.DecodeAddressBinding
open Nightstream.Chip8.RootHandoffContext
open Nightstream.Chip8.StepComposition
open Nightstream.Chip8.StagedExecutionDigest

abbrev F := StagedExecutionDigest.F
abbrev Program := StagedExecutionDigest.Program
abbrev MachineState := StagedExecutionDigest.MachineState
abbrev InitialState := StagedExecutionDigest.InitialState
abbrev ExternalSchedule := StagedExecutionDigest.ExternalSchedule
abbrev ExecutionInputContext := EvidenceCoverage.ExecutionInputContext
abbrev RootEncode := ContinuityBridge.RootEncode

section Audit

variable
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment Addr : Type*}

def checkDigestPublicSurface
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (_d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z) : Prop :=
  @RomScheduleBinding.KernelPublicInputsBound DigestRom RootParamsId VmSpec
    TranscriptSeed
    inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
    inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
    inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
    init

def checkStage1Surface
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (rom : Program)
  (σ : ExternalSchedule)
  (_stepIdx : Nat)
  (_init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (_d :
    ExecutionDigest inputs rootCtx rom σ _stepIdx _init pre post
      dec z) : Prop :=
  StepComposition.FetchDecodeBound rom pre.pc dec ∧
    StepComposition.LookupBound dec pre z

def checkStage2Surface
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (rom : Program)
  (σ : ExternalSchedule)
  (_stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (_d :
    ExecutionDigest inputs rootCtx rom σ _stepIdx init pre post
      dec z) : Prop :=
  WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z ∧
    StepComposition.MemoryBound pre post init dec z

def checkStage3Surface
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z) : Prop :=
  let stage3 := ExecutionDigest.stage3 d
  StepComposition.ContinuityRowBound stepIdx (Stage3DigestSurface.N stage3)
      (Stage3DigestSurface.β1 stage3) (Stage3DigestSurface.β2 stage3)
      (Stage3DigestSurface.shiftClaim stage3)
      (Stage3DigestSurface.shiftProof stage3)
      (Stage3DigestSurface.currentRow stage3)
      (Stage3DigestSurface.rowClaim stage3) z ∧
    ContinuityBridge.PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z
      (Stage3DigestSurface.preparedStep stage3)

def checkExecutionResultSurface
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (_d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z) : Prop :=
  StepComposition.MicrostepCorrect rom σ dec pre post ∧
    StepComposition.FramebufferBound pre post dec ∧
    StepComposition.ScheduleBound σ stepIdx pre post dec

def checkStagedExecutionDigest
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z) : Prop :=
  checkDigestPublicSurface inputs rootCtx rom σ stepIdx init pre
      post dec z d ∧
    checkStage1Surface inputs rootCtx rom σ stepIdx init pre post
      dec z d ∧
    checkStage2Surface inputs rootCtx rom σ stepIdx init pre post
      dec z d ∧
    checkStage3Surface inputs rootCtx rom σ stepIdx init pre post
      dec z d ∧
    checkExecutionResultSurface inputs rootCtx rom σ stepIdx init
      pre post dec z d

def ArtifactAuditAccepted
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z) : Prop :=
  checkStagedExecutionDigest inputs rootCtx rom σ stepIdx init
    pre post dec z d

theorem artifactAuditSound
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z}
  (h :
    ArtifactAuditAccepted inputs rootCtx rom σ stepIdx init pre
      post dec z d) :
  StagedExecutionDigest.StagedExecutionDigestBound inputs rootCtx
    rom σ stepIdx init pre post dec z d := by
  rcases (show
      RomScheduleBinding.KernelPublicInputsBound inputs.hashProgram
          inputs.hashInitialState inputs.programWordCountOf
          inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
          inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom
          init ∧
        (StepComposition.FetchDecodeBound rom pre.pc dec ∧
          StepComposition.LookupBound dec pre z) ∧
        (WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z ∧
          StepComposition.MemoryBound pre post init dec z) ∧
        (StepComposition.ContinuityRowBound stepIdx d.stage3.N d.stage3.β1
            d.stage3.β2 d.stage3.shiftClaim d.stage3.shiftProof
            d.stage3.currentRow d.stage3.rowClaim z ∧
          ContinuityBridge.PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z
            d.stage3.preparedStep) ∧
        StepComposition.MicrostepCorrect rom σ dec pre post ∧
        StepComposition.FramebufferBound pre post dec ∧
        StepComposition.ScheduleBound σ stepIdx pre post dec from by
          simpa [ArtifactAuditAccepted, checkStagedExecutionDigest,
            checkDigestPublicSurface, checkStage1Surface, checkStage2Surface,
            checkStage3Surface, checkExecutionResultSurface] using h) with
    ⟨hPub, hStage1, hStage2, hStage3, hMicro, hFramebuffer, hSchedule⟩
  rcases hStage1 with ⟨hFetch, hLookup⟩
  rcases hStage2 with ⟨hWitness, hMem⟩
  rcases hStage3 with ⟨hCont, hPrepared⟩
  exact ⟨hPub, hFetch, hLookup, hWitness, hMem, hCont, hPrepared, hMicro,
    hFramebuffer, hSchedule⟩

def artifactAuditImpliesBridgeBinding
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z}
  (h :
    ArtifactAuditAccepted inputs rootCtx rom σ stepIdx init pre
      post dec z d) :
  BridgeBinding.BridgeBindingWitness rootCtx stepIdx z
    d.stage3.rowClaim d.stage3.preparedStep :=
  StagedExecutionDigest.bridgeBinding_of_digest (artifactAuditSound h)

theorem artifactAuditImpliesExecutionResultSurface
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z}
  (h :
    ArtifactAuditAccepted inputs rootCtx rom σ stepIdx init pre
      post dec z d) :
  StagedExecutionDigest.ExecutionResultSurface rom σ stepIdx pre post dec := by
  exact StagedExecutionDigest.executionResultSurface_of_digest (artifactAuditSound h)

theorem artifactAuditImpliesExecutionFrameBound
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z}
  (h :
    ArtifactAuditAccepted inputs rootCtx rom σ stepIdx init pre
      post dec z d) :
  StepComposition.ExecutionFrameBound rom σ
    ({ dec := dec, pre := pre, post := post, row := z } :
      StepComposition.ExecutionFrame Addr) := by
  exact StagedExecutionDigest.executionFrameBound_of_digest (artifactAuditSound h)

theorem artifactAuditImpliesMicrostepCorrect
  {inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {d :
    ExecutionDigest inputs rootCtx rom σ stepIdx init pre post
      dec z}
  (h :
    ArtifactAuditAccepted inputs rootCtx rom σ stepIdx init pre
      post dec z d) :
  StepComposition.MicrostepCorrect rom σ dec pre post := by
  exact StepComposition.executionFrameBound_microstepCorrect
    (artifactAuditImpliesExecutionFrameBound h)

end Audit

end Nightstream.Chip8.ArtifactAudit
