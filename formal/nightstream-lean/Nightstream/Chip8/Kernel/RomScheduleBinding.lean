import Nightstream.Chip8.Stage1.FetchDecodeBinding
import Nightstream.Chip8.Stage2.WitnessMemoryBinding
import Nightstream.Chip8.Execution.ExecutionSemantics

namespace Nightstream.Chip8.RomScheduleBinding

open Nightstream.Chip8
open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.DecodeAddressBinding

abbrev Program := FetchDecodeBinding.Program
abbrev InitialState := WitnessMemoryBinding.InitialState
abbrev ExternalSchedule := ExecutionSemantics.ExternalSchedule

structure PublicDigest (Digest : Type*) where
  value : Digest
deriving DecidableEq, Repr

def RomHashBound
  (hashProgram : Program → Digest)
  (romHash : PublicDigest Digest)
  (rom : Program) : Prop :=
  romHash.value = hashProgram rom

def ScheduleDigestBound
  (hashSchedule : ExternalSchedule → Digest)
  (scheduleHash : PublicDigest Digest)
  (σ : ExternalSchedule) : Prop :=
  scheduleHash.value = hashSchedule σ

def ScheduleLengthBound
  (scheduleLength : ExternalSchedule → Nat)
  (publishedLength : Nat)
  (σ : ExternalSchedule) : Prop :=
  publishedLength = scheduleLength σ

def ScheduleStepBound
  (scheduleLength : ExternalSchedule → Nat)
  (σ : ExternalSchedule)
  (stepIdx : Nat) : Prop :=
  stepIdx < scheduleLength σ

structure AuthenticatedRom
  (hashProgram : Program → Digest)
  (romHash : PublicDigest Digest)
  (rom : Program) : Prop where
  bound : RomHashBound hashProgram romHash rom

structure AuthenticatedSchedule
  (hashSchedule : ExternalSchedule → Digest)
  (scheduleLength : ExternalSchedule → Nat)
  (scheduleHash : PublicDigest Digest)
  (publishedLength : Nat)
  (σ : ExternalSchedule) : Prop where
  digestBound : ScheduleDigestBound hashSchedule scheduleHash σ
  lengthBound : ScheduleLengthBound scheduleLength publishedLength σ

structure AuthenticatedStepSchedule
  (hashSchedule : ExternalSchedule → Digest)
  (scheduleLength : ExternalSchedule → Nat)
  (scheduleHash : PublicDigest Digest)
  (publishedLength : Nat)
  (σ : ExternalSchedule)
  (stepIdx : Nat) : Prop where
  schedule : AuthenticatedSchedule hashSchedule scheduleLength scheduleHash publishedLength σ
  stepLive : stepIdx < publishedLength

def ExecutionInputsBound
  (hashProgram : Program → DigestRom)
  (hashSchedule : ExternalSchedule → DigestSchedule)
  (scheduleLength : ExternalSchedule → Nat)
  (romHash : PublicDigest DigestRom)
  (scheduleHash : PublicDigest DigestSchedule)
  (publishedLength : Nat)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat) : Prop :=
  RomHashBound hashProgram romHash rom ∧
    ScheduleDigestBound hashSchedule scheduleHash σ ∧
    ScheduleLengthBound scheduleLength publishedLength σ ∧
    ScheduleStepBound scheduleLength σ stepIdx

structure KernelMeta (Digest RootParamsId : Type*) where
  programImageDigest : Digest
  initialStateDigest : Digest
  programWordCount : Nat
  semanticRows : Nat
  paddedTraceLength : Nat
  padPcWord : Nat
  programBaseAddr : Nat
  cycleBits : Nat
  rootParamsId : RootParamsId
deriving DecidableEq, Repr

structure KernelPublicInput (VmSpec TranscriptSeed : Type*) where
  vmSpec : VmSpec
  publicProgram : Program
  initialState : InitialState
  transcriptSeed : TranscriptSeed

def ProgramDigestBound {D : Type} {R : Type}
  (hashProgram : Program → D) (pubMeta : KernelMeta D R)
  (rom : Program) : Prop :=
  pubMeta.programImageDigest = hashProgram rom

def ProgramShapeBound {D : Type} {R : Type}
  (programWordCountOf : Program → Nat) (programBaseAddrOf : Program → Nat)
  (pubMeta : KernelMeta D R) (rom : Program) : Prop :=
  pubMeta.programWordCount = programWordCountOf rom ∧
    pubMeta.programBaseAddr = programBaseAddrOf rom

def PadRowMetadataBound {D : Type} {R : Type}
  (padPcWordOf : Program → Nat) (paddedTraceLengthOf : Nat → Nat)
  (twoPow : Nat → Nat) (pubMeta : KernelMeta D R)
  (rom : Program) : Prop :=
  1 ≤ pubMeta.semanticRows ∧
    pubMeta.semanticRows ≤ pubMeta.paddedTraceLength ∧
    pubMeta.paddedTraceLength = paddedTraceLengthOf pubMeta.semanticRows ∧
    pubMeta.padPcWord = padPcWordOf rom ∧
    twoPow pubMeta.cycleBits = pubMeta.paddedTraceLength

def InitialStateDigestBound {D : Type} {R : Type}
  (hashInitialState : InitialState → D)
  (pubMeta : KernelMeta D R) (init : InitialState) : Prop :=
  pubMeta.initialStateDigest = hashInitialState init

def RootParamsBound {D : Type} {R : Type} {V : Type}
  (rootParamsOf : V → R) (pubMeta : KernelMeta D R)
  (vmSpec : V) : Prop :=
  pubMeta.rootParamsId = rootParamsOf vmSpec

def AuthenticatedProgramImage {V : Type} {T : Type}
  (publicInput : KernelPublicInput V T) (rom : Program) : Prop :=
  publicInput.publicProgram = rom

def AuthenticatedInitialState {V : Type} {T : Type}
  (publicInput : KernelPublicInput V T)
  (init : InitialState) : Prop :=
  publicInput.initialState = init

def AuthenticatedKernelMeta
  {D : Type} {R : Type} {V : Type} {T : Type}
  (hashProgram : Program → D) (hashInitialState : InitialState → D)
  (programWordCountOf : Program → Nat) (programBaseAddrOf : Program → Nat)
  (padPcWordOf : Program → Nat) (paddedTraceLengthOf : Nat → Nat)
  (twoPow : Nat → Nat) (rootParamsOf : V → R)
  (publicInput : KernelPublicInput V T)
  (pubMeta : KernelMeta D R) : Prop :=
  ProgramDigestBound hashProgram pubMeta publicInput.publicProgram ∧
    ProgramShapeBound programWordCountOf programBaseAddrOf pubMeta publicInput.publicProgram ∧
    PadRowMetadataBound padPcWordOf paddedTraceLengthOf twoPow pubMeta publicInput.publicProgram ∧
    InitialStateDigestBound hashInitialState pubMeta publicInput.initialState ∧
    RootParamsBound rootParamsOf pubMeta publicInput.vmSpec

def KernelPublicInputsBound
  {D : Type} {R : Type} {V : Type} {T : Type}
  (hashProgram : Program → D) (hashInitialState : InitialState → D)
  (programWordCountOf : Program → Nat) (programBaseAddrOf : Program → Nat)
  (padPcWordOf : Program → Nat) (paddedTraceLengthOf : Nat → Nat)
  (twoPow : Nat → Nat) (rootParamsOf : V → R)
  (publicInput : KernelPublicInput V T)
  (pubMeta : KernelMeta D R) (rom : Program)
  (init : InitialState) : Prop :=
  ProgramDigestBound hashProgram pubMeta rom ∧
    ProgramShapeBound programWordCountOf programBaseAddrOf pubMeta rom ∧
    PadRowMetadataBound padPcWordOf paddedTraceLengthOf twoPow pubMeta rom ∧
    InitialStateDigestBound hashInitialState pubMeta init ∧
    RootParamsBound rootParamsOf pubMeta publicInput.vmSpec

theorem romHashBound_of_authenticatedRom
  {hashProgram : Program → Digest}
  {romHash : PublicDigest Digest}
  {rom : Program}
  (h : AuthenticatedRom hashProgram romHash rom) :
  RomHashBound hashProgram romHash rom := by
  exact h.bound

theorem scheduleDigestBound_of_authenticatedSchedule
  {hashSchedule : ExternalSchedule → Digest}
  {scheduleLength : ExternalSchedule → Nat}
  {scheduleHash : PublicDigest Digest}
  {publishedLength : Nat}
  {σ : ExternalSchedule}
  (h : AuthenticatedSchedule hashSchedule scheduleLength scheduleHash publishedLength σ) :
  ScheduleDigestBound hashSchedule scheduleHash σ := by
  exact h.digestBound

theorem scheduleLengthBound_of_authenticatedSchedule
  {hashSchedule : ExternalSchedule → Digest}
  {scheduleLength : ExternalSchedule → Nat}
  {scheduleHash : PublicDigest Digest}
  {publishedLength : Nat}
  {σ : ExternalSchedule}
  (h : AuthenticatedSchedule hashSchedule scheduleLength scheduleHash publishedLength σ) :
  ScheduleLengthBound scheduleLength publishedLength σ := by
  exact h.lengthBound

theorem scheduleStepBound_of_authenticatedStepSchedule
  {hashSchedule : ExternalSchedule → Digest}
  {scheduleLength : ExternalSchedule → Nat}
  {scheduleHash : PublicDigest Digest}
  {publishedLength : Nat}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  (h :
    AuthenticatedStepSchedule hashSchedule scheduleLength scheduleHash
      publishedLength σ stepIdx) :
  ScheduleStepBound scheduleLength σ stepIdx := by
  rcases h with ⟨hSchedule, hLive⟩
  rcases hSchedule with ⟨_, hLen⟩
  unfold ScheduleStepBound
  simp [ScheduleLengthBound] at hLen
  simpa [hLen] using hLive

theorem executionInputsBound_of_authenticatedInputs
  {hashProgram : Program → DigestRom}
  {hashSchedule : ExternalSchedule → DigestSchedule}
  {scheduleLength : ExternalSchedule → Nat}
  {romHash : PublicDigest DigestRom}
  {scheduleHash : PublicDigest DigestSchedule}
  {publishedLength : Nat}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  (hRom : AuthenticatedRom hashProgram romHash rom)
  (hSchedule :
    AuthenticatedStepSchedule hashSchedule scheduleLength scheduleHash
      publishedLength σ stepIdx) :
  ExecutionInputsBound hashProgram hashSchedule scheduleLength romHash
    scheduleHash publishedLength rom σ stepIdx := by
  exact ⟨romHashBound_of_authenticatedRom hRom,
    scheduleDigestBound_of_authenticatedSchedule hSchedule.schedule,
    scheduleLengthBound_of_authenticatedSchedule hSchedule.schedule,
    scheduleStepBound_of_authenticatedStepSchedule hSchedule⟩

theorem padRowMetadataBound_semanticRows_pos
  {D : Type} {R : Type} {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat} {pubMeta : KernelMeta D R}
  {rom : Program}
  (h : PadRowMetadataBound padPcWordOf paddedTraceLengthOf twoPow pubMeta rom) :
  1 ≤ pubMeta.semanticRows := by
  exact h.1

theorem padRowMetadataBound_semanticRows_le_padded
  {D : Type} {R : Type} {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat} {pubMeta : KernelMeta D R}
  {rom : Program}
  (h : PadRowMetadataBound padPcWordOf paddedTraceLengthOf twoPow pubMeta rom) :
  pubMeta.semanticRows ≤ pubMeta.paddedTraceLength := by
  exact h.2.1

theorem padRowMetadataBound_paddedTraceLength
  {D : Type} {R : Type} {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat} {pubMeta : KernelMeta D R}
  {rom : Program}
  (h : PadRowMetadataBound padPcWordOf paddedTraceLengthOf twoPow pubMeta rom) :
  pubMeta.paddedTraceLength = paddedTraceLengthOf pubMeta.semanticRows := by
  exact h.2.2.1

theorem padRowMetadataBound_padPcWord
  {D : Type} {R : Type} {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat} {pubMeta : KernelMeta D R}
  {rom : Program}
  (h : PadRowMetadataBound padPcWordOf paddedTraceLengthOf twoPow pubMeta rom) :
  pubMeta.padPcWord = padPcWordOf rom := by
  exact h.2.2.2.1

theorem padRowMetadataBound_powerOfTwo
  {D : Type} {R : Type} {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat} {pubMeta : KernelMeta D R}
  {rom : Program}
  (h : PadRowMetadataBound padPcWordOf paddedTraceLengthOf twoPow pubMeta rom) :
  twoPow pubMeta.cycleBits = pubMeta.paddedTraceLength := by
  exact h.2.2.2.2

theorem kernelPublicInputsBound_of_authenticatedInputs
  {D : Type} {R : Type} {V : Type} {T : Type}
  {hashProgram : Program → D} {hashInitialState : InitialState → D}
  {programWordCountOf programBaseAddrOf : Program → Nat} {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat} {rootParamsOf : V → R}
  {publicInput : KernelPublicInput V T} {pubMeta : KernelMeta D R}
  {rom : Program} {init : InitialState}
  (hProgram : AuthenticatedProgramImage publicInput rom)
  (hInit : AuthenticatedInitialState publicInput init)
  (hMeta :
    AuthenticatedKernelMeta hashProgram hashInitialState programWordCountOf
      programBaseAddrOf padPcWordOf paddedTraceLengthOf twoPow rootParamsOf
      publicInput pubMeta) :
  KernelPublicInputsBound hashProgram hashInitialState programWordCountOf
    programBaseAddrOf padPcWordOf paddedTraceLengthOf twoPow rootParamsOf
    publicInput pubMeta rom init := by
  subst hProgram
  subst hInit
  exact hMeta

theorem rom_eq_of_sharedDigest
  {hashProgram : Program → Digest}
  (hInj : Function.Injective hashProgram)
  {romHash : PublicDigest Digest}
  {rom₁ rom₂ : Program}
  (h₁ : RomHashBound hashProgram romHash rom₁)
  (h₂ : RomHashBound hashProgram romHash rom₂) :
  rom₁ = rom₂ := by
  apply hInj
  calc
    hashProgram rom₁ = romHash.value := by simpa [RomHashBound] using h₁.symm
    _ = hashProgram rom₂ := by simpa [RomHashBound] using h₂

theorem romTable_eq_of_sharedMeta
  {D : Type} {R : Type} {V : Type} {T : Type}
  {hashProgram : Program → D}
  {hashInitialState : InitialState → D}
  {programWordCountOf programBaseAddrOf : Program → Nat}
  {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat}
  {rootParamsOf : V → R}
  (hInj : Function.Injective hashProgram)
  {publicInput : KernelPublicInput V T}
  {pubMeta : KernelMeta D R}
  {rom₁ rom₂ : Program}
  {init₁ init₂ : InitialState}
  (h₁ :
    KernelPublicInputsBound hashProgram hashInitialState programWordCountOf
      programBaseAddrOf padPcWordOf paddedTraceLengthOf twoPow rootParamsOf
      publicInput pubMeta rom₁ init₁)
  (h₂ :
    KernelPublicInputsBound hashProgram hashInitialState programWordCountOf
      programBaseAddrOf padPcWordOf paddedTraceLengthOf twoPow rootParamsOf
      publicInput pubMeta rom₂ init₂) :
  rom₁ = rom₂ := by
  apply hInj
  calc
    hashProgram rom₁ = pubMeta.programImageDigest := by
      simpa [ProgramDigestBound] using h₁.1.symm
    _ = hashProgram rom₂ := by
      simpa [ProgramDigestBound] using h₂.1

theorem schedule_eq_of_sharedDigest
  {hashSchedule : ExternalSchedule → Digest}
  (hInj : Function.Injective hashSchedule)
  {scheduleHash : PublicDigest Digest}
  {σ₁ σ₂ : ExternalSchedule}
  (h₁ : ScheduleDigestBound hashSchedule scheduleHash σ₁)
  (h₂ : ScheduleDigestBound hashSchedule scheduleHash σ₂) :
  σ₁ = σ₂ := by
  apply hInj
  calc
    hashSchedule σ₁ = scheduleHash.value := by simpa [ScheduleDigestBound] using h₁.symm
    _ = hashSchedule σ₂ := by simpa [ScheduleDigestBound] using h₂

theorem initialState_eq_of_sharedMeta
  {D : Type} {R : Type} {V : Type} {T : Type}
  {hashProgram : Program → D}
  {hashInitialState : InitialState → D}
  {programWordCountOf programBaseAddrOf : Program → Nat}
  {padPcWordOf : Program → Nat}
  {paddedTraceLengthOf twoPow : Nat → Nat}
  {rootParamsOf : V → R}
  (hInj : Function.Injective hashInitialState)
  {publicInput : KernelPublicInput V T}
  {pubMeta : KernelMeta D R}
  {rom₁ rom₂ : Program}
  {init₁ init₂ : InitialState}
  (h₁ :
    KernelPublicInputsBound hashProgram hashInitialState programWordCountOf
      programBaseAddrOf padPcWordOf paddedTraceLengthOf twoPow rootParamsOf
      publicInput pubMeta rom₁ init₁)
  (h₂ :
    KernelPublicInputsBound hashProgram hashInitialState programWordCountOf
      programBaseAddrOf padPcWordOf paddedTraceLengthOf twoPow rootParamsOf
      publicInput pubMeta rom₂ init₂) :
  init₁ = init₂ := by
  apply hInj
  calc
    hashInitialState init₁ = pubMeta.initialStateDigest := by
      simpa [InitialStateDigestBound] using h₁.2.2.2.1.symm
    _ = hashInitialState init₂ := by
      simpa [InitialStateDigestBound] using h₂.2.2.2.1

end Nightstream.Chip8.RomScheduleBinding
