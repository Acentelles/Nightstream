import Nightstream.Chip8.Kernel.OpeningBoundary

/-!
Owns the exact `root0` commitment bundle and the theorem-facing transcript
schedule for the 3-stage CHIP-8 kernel. This file is about temporal protocol
order only; it does not own opening-manifest shape or semantic extraction.
-/

namespace Nightstream.Chip8.TranscriptSchedule

open Nightstream.Chip8
open Nightstream.Chip8.ExactOpeningBoundary

abbrev CommitmentDigest := List Nat

structure Root0CommitmentBinding where
  id : CommitmentId
  digest : CommitmentDigest
deriving DecidableEq, Repr

inductive TranscriptEvent where
  | absorbCommitment (binding : Root0CommitmentBinding)
  | absorbMetaPub
  | sampleStage1Cycle
  | stage1FetchSumcheck
  | stage1DecodeSumcheck
  | stage1AluSumcheck
  | stage1Eq4Sumcheck
  | stage1AddrCheckFetch
  | stage1AddrCheckDecode
  | stage1AddrCheckAlu
  | stage1AddrCheckEq4
  | recordFetchAddr
  | recordDecodeAddr
  | recordAluAddr
  | deriveAdd8LoAddr
  | recordEq4Addr
  | sampleGammaLookupLink
  | stage1LinkageBatch
  | sampleStage2Cycle
  | sampleGammaReg
  | stage2RegRwBatched
  | stage2RegValFromInc
  | sampleGammaRam
  | stage2RamRwBatched
  | stage2RamValFromInc
  | stage2RamRafRead
  | stage2RamRafWrite
  | stage2AddrCheckRegRaX
  | stage2AddrCheckRegRaY
  | stage2AddrCheckRegRaI
  | stage2AddrCheckRegWa
  | stage2AddrCheckRamRa
  | stage2AddrCheckRamWa
  | recordRegAddr
  | recordRamAddr
  | sampleGammaTwistLink
  | stage2LinkageBatch
  | sampleBeta1
  | sampleBeta2
  | sampleStage3Cycle
  | laneShiftReduction
  | stage3Continuity
  | stage3StartBoundaryOpening
  | stage3FinalBoundaryOpening
  | rowBinding (j : Nat)
  | emitKernelOpeningClaims
deriving DecidableEq, Repr

def root0CommitmentIds : List CommitmentId :=
  [ .lane
  , .fetchRa
  , .decodeRa
  , .aluRa
  , .eq4Ra
  , .decodeHandoff
  , .regTwist
  , .ramTwist
  , .romTable
  , .decodeTable
  , .aluTable
  , .eq4Table
  ]

def root0CommitmentBindingsConform
  (bindings : List Root0CommitmentBinding) : Prop :=
  bindings.map Root0CommitmentBinding.id = root0CommitmentIds

def phase0Events
  (root0Bindings : List Root0CommitmentBinding) : List TranscriptEvent :=
  root0Bindings.map TranscriptEvent.absorbCommitment ++ [.absorbMetaPub]

def stage1Events : List TranscriptEvent :=
  [ .sampleStage1Cycle
  , .stage1FetchSumcheck
  , .stage1DecodeSumcheck
  , .stage1AluSumcheck
  , .stage1Eq4Sumcheck
  , .stage1AddrCheckFetch
  , .stage1AddrCheckDecode
  , .stage1AddrCheckAlu
  , .stage1AddrCheckEq4
  , .recordFetchAddr
  , .recordDecodeAddr
  , .recordAluAddr
  , .deriveAdd8LoAddr
  , .recordEq4Addr
  , .sampleGammaLookupLink
  , .stage1LinkageBatch
  ]

def stage2Events : List TranscriptEvent :=
  [ .sampleStage2Cycle
  , .sampleGammaReg
  , .stage2RegRwBatched
  , .stage2RegValFromInc
  , .sampleGammaRam
  , .stage2RamRwBatched
  , .stage2RamValFromInc
  , .stage2RamRafRead
  , .stage2RamRafWrite
  , .stage2AddrCheckRegRaX
  , .stage2AddrCheckRegRaY
  , .stage2AddrCheckRegRaI
  , .stage2AddrCheckRegWa
  , .stage2AddrCheckRamRa
  , .stage2AddrCheckRamWa
  , .recordRegAddr
  , .recordRamAddr
  , .sampleGammaTwistLink
  , .stage2LinkageBatch
  ]

def stage3PrefixEvents : List TranscriptEvent :=
  [ .sampleBeta1
  , .sampleBeta2
  , .sampleStage3Cycle
  , .laneShiftReduction
  , .stage3Continuity
  , .stage3StartBoundaryOpening
  , .stage3FinalBoundaryOpening
  ]

def stage3RowBindingEvents (exportedRows : Nat) : List TranscriptEvent :=
  List.ofFn (fun j : Fin exportedRows => TranscriptEvent.rowBinding j.1)

def stage3Events (exportedRows : Nat) : List TranscriptEvent :=
  stage3PrefixEvents ++ stage3RowBindingEvents exportedRows

def transcriptEvents
  (root0Bindings : List Root0CommitmentBinding)
  (exportedRows : Nat) : List TranscriptEvent :=
  phase0Events root0Bindings ++
    stage1Events ++
    stage2Events ++
    stage3Events exportedRows ++
    [.emitKernelOpeningClaims]

def KernelTranscriptSchedule
  (root0Bindings : List Root0CommitmentBinding)
  (exportedRows : Nat)
  (events : List TranscriptEvent) : Prop :=
  root0CommitmentBindingsConform root0Bindings ∧
    events = transcriptEvents root0Bindings exportedRows

def challengeEvents : List TranscriptEvent :=
  [ .sampleStage1Cycle
  , .sampleGammaLookupLink
  , .sampleStage2Cycle
  , .sampleGammaReg
  , .sampleGammaRam
  , .sampleGammaTwistLink
  , .sampleBeta1
  , .sampleBeta2
  , .sampleStage3Cycle
  ]

def ChallengeEvent (e : TranscriptEvent) : Prop :=
  e ∈ challengeEvents

def stage1TerminalPointEvents : List TranscriptEvent :=
  [ .recordFetchAddr
  , .recordDecodeAddr
  , .recordAluAddr
  , .recordEq4Addr
  ]

def Stage1TerminalPointEvent (e : TranscriptEvent) : Prop :=
  e ∈ stage1TerminalPointEvents

def stage2TerminalPointEvents : List TranscriptEvent :=
  [ .recordRegAddr
  , .recordRamAddr
  ]

def Stage2TerminalPointEvent (e : TranscriptEvent) : Prop :=
  e ∈ stage2TerminalPointEvents

theorem root0CommitmentIds_nodup : root0CommitmentIds.Nodup := by
  native_decide

theorem root0CommitmentBindings_ids
  {root0Bindings : List Root0CommitmentBinding}
  (h : root0CommitmentBindingsConform root0Bindings) :
  root0Bindings.map Root0CommitmentBinding.id = root0CommitmentIds :=
  h

theorem mem_root0CommitmentIds_iff_isKernelCommitment
  (cid : CommitmentId) :
  cid ∈ root0CommitmentIds ↔ isKernelCommitment cid := by
  cases cid <;> simp [root0CommitmentIds, isKernelCommitment]

theorem kernelClaim_commitment_fixed_in_root0
  {Value Digest : Type*}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  {claim : OpeningClaim Value Digest}
  (hBoundary : ExactKernelOpeningBoundary pts kernelManifest rootManifest)
  (hMem : claim ∈ kernelManifest) :
  claim.commitmentId ∈ root0CommitmentIds := by
  rcases exact_kernelOpeningBoundary_conforms hBoundary with ⟨hKernel, _⟩
  rcases hKernel claim hMem with ⟨_, hKernelCommitment, _⟩
  exact (mem_root0CommitmentIds_iff_isKernelCommitment claim.commitmentId).2
    hKernelCommitment

theorem kernelTranscriptSchedule_phase0_prefix
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  (h : KernelTranscriptSchedule root0Bindings exportedRows events) :
  ∃ rest, events = phase0Events root0Bindings ++ rest := by
  rcases h with ⟨_, rfl⟩
  refine ⟨stage1Events ++ stage2Events ++ stage3Events exportedRows ++
      [.emitKernelOpeningClaims], ?_⟩
  simp [transcriptEvents, stage3Events, List.append_assoc]

theorem kernelTranscriptSchedule_stage1_prefix
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  (h : KernelTranscriptSchedule root0Bindings exportedRows events) :
  ∃ rest, events = phase0Events root0Bindings ++ stage1Events ++ rest := by
  rcases h with ⟨_, rfl⟩
  refine ⟨stage2Events ++ stage3Events exportedRows ++ [.emitKernelOpeningClaims], ?_⟩
  simp [transcriptEvents, stage3Events, List.append_assoc]

theorem kernelTranscriptSchedule_stage2_prefix
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  (h : KernelTranscriptSchedule root0Bindings exportedRows events) :
  ∃ rest, events = phase0Events root0Bindings ++ stage1Events ++ stage2Events ++ rest := by
  rcases h with ⟨_, rfl⟩
  refine ⟨stage3Events exportedRows ++ [.emitKernelOpeningClaims], ?_⟩
  simp [transcriptEvents, stage3Events, List.append_assoc]

theorem kernelTranscriptSchedule_stage3_prefix
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  (h : KernelTranscriptSchedule root0Bindings exportedRows events) :
  ∃ rest, events =
      phase0Events root0Bindings ++ stage1Events ++ stage2Events ++
        stage3PrefixEvents ++ rest := by
  rcases h with ⟨_, rfl⟩
  refine ⟨stage3RowBindingEvents exportedRows ++ [.emitKernelOpeningClaims], ?_⟩
  simp [transcriptEvents, stage3Events, List.append_assoc]

theorem challenge_after_phase0
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  {e : TranscriptEvent}
  (hSchedule : KernelTranscriptSchedule root0Bindings exportedRows events)
  (hChallenge : ChallengeEvent e) :
  ∃ rest, events = phase0Events root0Bindings ++ rest ∧ e ∈ rest := by
  refine ⟨stage1Events ++ stage2Events ++ stage3Events exportedRows ++
      [.emitKernelOpeningClaims], ?_, ?_⟩
  · rcases hSchedule with ⟨_, rfl⟩
    simp [transcriptEvents, stage3Events, List.append_assoc]
  · cases e <;>
      simp [ChallengeEvent, challengeEvents, stage1Events, stage2Events,
        stage3Events, stage3PrefixEvents] at hChallenge ⊢

theorem stage1TerminalPoint_after_phase0
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  {e : TranscriptEvent}
  (hSchedule : KernelTranscriptSchedule root0Bindings exportedRows events)
  (hTerminal : Stage1TerminalPointEvent e) :
  ∃ rest, events = phase0Events root0Bindings ++ rest ∧ e ∈ rest := by
  refine ⟨stage1Events ++ stage2Events ++ stage3Events exportedRows ++
      [.emitKernelOpeningClaims], ?_, ?_⟩
  · rcases hSchedule with ⟨_, rfl⟩
    simp [transcriptEvents, stage3Events, List.append_assoc]
  · cases e <;>
      simp [Stage1TerminalPointEvent, stage1TerminalPointEvents, stage1Events,
        stage2Events, stage3Events, stage3PrefixEvents] at hTerminal ⊢

theorem stage2TerminalPoint_after_phase0
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  {e : TranscriptEvent}
  (hSchedule : KernelTranscriptSchedule root0Bindings exportedRows events)
  (hTerminal : Stage2TerminalPointEvent e) :
  ∃ rest, events = phase0Events root0Bindings ++ rest ∧ e ∈ rest := by
  refine ⟨stage1Events ++ stage2Events ++ stage3Events exportedRows ++
      [.emitKernelOpeningClaims], ?_, ?_⟩
  · rcases hSchedule with ⟨_, rfl⟩
    simp [transcriptEvents, stage3Events, List.append_assoc]
  · cases e <;>
      simp [Stage2TerminalPointEvent, stage2TerminalPointEvents, stage1Events,
        stage2Events, stage3Events, stage3PrefixEvents] at hTerminal ⊢

theorem deriveAdd8LoAddr_not_challenge :
  ¬ ChallengeEvent .deriveAdd8LoAddr := by
  simp [ChallengeEvent, challengeEvents]

theorem rowBinding_mem_stage3RowBindingEvents_iff
  {exportedRows j : Nat} :
  TranscriptEvent.rowBinding j ∈ stage3RowBindingEvents exportedRows ↔
    j < exportedRows := by
  constructor
  · intro hMem
    unfold stage3RowBindingEvents at hMem
    simp only [List.mem_ofFn] at hMem
    rcases hMem with ⟨i, hi⟩
    cases i with
    | mk val isLt =>
        cases hi
        simpa using isLt
  · intro hj
    unfold stage3RowBindingEvents
    simp only [List.mem_ofFn]
    exact ⟨⟨j, hj⟩, rfl⟩

private theorem exists_fin_eq_iff_lt
  {n j : Nat} :
  (∃ i : Fin n, (i : Nat) = j) ↔ j < n := by
  constructor
  · intro h
    rcases h with ⟨i, hi⟩
    cases i with
    | mk val isLt =>
        cases hi
        exact isLt
  · intro hj
    exact ⟨⟨j, hj⟩, rfl⟩

theorem rowBinding_event_in_schedule_iff
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  {j : Nat}
  (hSchedule : KernelTranscriptSchedule root0Bindings exportedRows events) :
  TranscriptEvent.rowBinding j ∈ events ↔ j < exportedRows := by
  rcases hSchedule with ⟨_, rfl⟩
  simp [transcriptEvents, phase0Events, stage1Events, stage2Events, stage3Events,
    stage3PrefixEvents, stage3RowBindingEvents, exists_fin_eq_iff_lt]

theorem emitKernelOpeningClaims_last
  {root0Bindings : List Root0CommitmentBinding}
  {exportedRows : Nat}
  {events : List TranscriptEvent}
  (hSchedule : KernelTranscriptSchedule root0Bindings exportedRows events) :
  ∃ pre, events = pre ++ [.emitKernelOpeningClaims] := by
  rcases hSchedule with ⟨_, rfl⟩
  refine ⟨phase0Events root0Bindings ++ stage1Events ++ stage2Events ++
      stage3Events exportedRows, rfl⟩

end Nightstream.Chip8.TranscriptSchedule
