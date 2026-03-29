import Nightstream.ChunkLayout

namespace Nightstream.Rv64IM

abbrev CommitmentDigest := List Nat

inductive Root0CommitmentId where
  | lane
  | bytecodeRa
  | aluRa
  | branchRa
  | decodeHandoff
  | regTwist
  | ramTwist
  | romTable
  | bytecodeTable
  | aluSubtables
  | branchTable
deriving DecidableEq, Repr

structure Root0CommitmentBinding where
  id : Root0CommitmentId
  digest : CommitmentDigest
deriving DecidableEq, Repr

inductive TranscriptEvent where
  | absorbCommitment (binding : Root0CommitmentBinding)
  | absorbMetaPub
  | programBinding
  | absorbFoldSchedule (schedule : Nightstream.FoldSchedule)
  | rootChunkStart (chunkIndex startIndex stopIndex : Nat)
  | rootChunkRowLabel (chunkIndex rowIndex : Nat)
  | rootChunkPiCCS (chunkIndex : Nat)
  | rootChunkPiRLC (chunkIndex : Nat)
  | rootChunkPiDEC (chunkIndex : Nat)
  | sampleStage1Cycle
  | stage1BytecodeSumcheck
  | stage1BytecodeRafEntrypoint
  | stage1BytecodeRafSuccessor
  | stage1AluSumcheck
  | stage1BranchSumcheck
  | stage1AddrCheckBytecode
  | stage1AddrCheckAlu
  | stage1AddrCheckBranch
  | stage1LinkageBatch
  | sampleStage2Cycle
  | sampleGammaReg
  | stage2RegRwBatched
  | stage2RegValFromInc
  | sampleGammaRam
  | stage2RamRwBatched
  | stage2RamValFromInc
  | stage2RamRaf
  | stage2AddrCheckReg
  | stage2AddrCheckRam
  | stage2VirtualizedRamAddr
  | sampleGammaTwistLink
  | stage2LinkageBatch
  | sampleBeta1
  | sampleBeta2
  | sampleStage3Cycle
  | laneShiftReduction
  | stage3Continuity
  | stage3OpeningProvenance
  | rowBinding (j : Nat)
  | emitKernelOpeningClaims
deriving DecidableEq, Repr

def root0CommitmentIds : List Root0CommitmentId :=
  [ .lane
  , .bytecodeRa
  , .aluRa
  , .branchRa
  , .decodeHandoff
  , .regTwist
  , .ramTwist
  , .romTable
  , .bytecodeTable
  , .aluSubtables
  , .branchTable
  ]

def root0CommitmentBindingsConform
  (bindings : List Root0CommitmentBinding) : Prop :=
  bindings.map Root0CommitmentBinding.id = root0CommitmentIds

def phase0Events
  (root0Bindings : List Root0CommitmentBinding) : List TranscriptEvent :=
  root0Bindings.map TranscriptEvent.absorbCommitment ++
    [.absorbMetaPub, .programBinding]

def rootChunkRowLabelEvents
  (chunkIndex : Nat)
  (chunk : Nightstream.ChunkRange) : List TranscriptEvent :=
  (List.range' chunk.start chunk.width).map (fun rowIndex =>
    TranscriptEvent.rootChunkRowLabel chunkIndex rowIndex)

def rootChunkEvents
  (chunkIndex : Nat)
  (chunk : Nightstream.ChunkRange) : List TranscriptEvent :=
  [TranscriptEvent.rootChunkStart chunkIndex chunk.start chunk.stop] ++
    rootChunkRowLabelEvents chunkIndex chunk ++
    [ TranscriptEvent.rootChunkPiCCS chunkIndex
    , TranscriptEvent.rootChunkPiRLC chunkIndex
    , TranscriptEvent.rootChunkPiDEC chunkIndex
    ]

private def rootChunkScheduleFrom
  (chunkIndex : Nat) : List Nightstream.ChunkRange → List TranscriptEvent
  | [] => []
  | chunk :: rest =>
      rootChunkEvents chunkIndex chunk ++ rootChunkScheduleFrom (chunkIndex + 1) rest

def rootMainLaneEvents
  (schedule : Nightstream.FoldSchedule)
  (publicStepCount : Nat) : List TranscriptEvent :=
  [TranscriptEvent.absorbFoldSchedule schedule] ++
    rootChunkScheduleFrom 0 (Nightstream.ChunkLayout.layout schedule publicStepCount)

def stage1Events : List TranscriptEvent :=
  [ .sampleStage1Cycle
  , .stage1BytecodeSumcheck
  , .stage1BytecodeRafEntrypoint
  , .stage1BytecodeRafSuccessor
  , .stage1AluSumcheck
  , .stage1BranchSumcheck
  , .stage1AddrCheckBytecode
  , .stage1AddrCheckAlu
  , .stage1AddrCheckBranch
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
  , .stage2RamRaf
  , .stage2AddrCheckReg
  , .stage2AddrCheckRam
  , .stage2VirtualizedRamAddr
  , .sampleGammaTwistLink
  , .stage2LinkageBatch
  ]

def stage3PrefixEvents : List TranscriptEvent :=
  [ .sampleBeta1
  , .sampleBeta2
  , .sampleStage3Cycle
  , .laneShiftReduction
  , .stage3Continuity
  , .stage3OpeningProvenance
  ]

def stage3RowBindingEvents (exportedRows : Nat) : List TranscriptEvent :=
  List.ofFn (fun j : Fin exportedRows => TranscriptEvent.rowBinding j.1)

def stage3Events (exportedRows : Nat) : List TranscriptEvent :=
  stage3PrefixEvents ++ stage3RowBindingEvents exportedRows

def transcriptEvents
  (root0Bindings : List Root0CommitmentBinding)
  (schedule : Nightstream.FoldSchedule)
  (publicStepCount : Nat)
  (exportedRows : Nat) : List TranscriptEvent :=
  phase0Events root0Bindings ++
    rootMainLaneEvents schedule publicStepCount ++
    stage1Events ++
    stage2Events ++
    stage3Events exportedRows ++
    [.emitKernelOpeningClaims]

def KernelTranscriptSchedule
  (root0Bindings : List Root0CommitmentBinding)
  (schedule : Nightstream.FoldSchedule)
  (publicStepCount : Nat)
  (exportedRows : Nat)
  (events : List TranscriptEvent) : Prop :=
  root0CommitmentBindingsConform root0Bindings ∧
    Nightstream.FoldSchedule.Valid schedule ∧
    events = transcriptEvents root0Bindings schedule publicStepCount exportedRows

def challengeEvents : List TranscriptEvent :=
  [ .sampleStage1Cycle
  , .sampleGammaReg
  , .sampleGammaRam
  , .sampleGammaTwistLink
  , .sampleBeta1
  , .sampleBeta2
  , .sampleStage3Cycle
  ]

def ChallengeEvent (e : TranscriptEvent) : Prop :=
  e ∈ challengeEvents

theorem root0CommitmentIds_nodup : root0CommitmentIds.Nodup := by
  native_decide

theorem root0CommitmentBindings_ids
  {root0Bindings : List Root0CommitmentBinding}
  (h : root0CommitmentBindingsConform root0Bindings) :
  root0Bindings.map Root0CommitmentBinding.id = root0CommitmentIds :=
  h

theorem transcriptSchedule_scheduleValid
  {root0Bindings : List Root0CommitmentBinding}
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount exportedRows : Nat}
  {events : List TranscriptEvent}
  (h :
    KernelTranscriptSchedule
      root0Bindings
      schedule
      publicStepCount
      exportedRows
      events) :
  Nightstream.FoldSchedule.Valid schedule :=
  h.2.1

theorem transcriptSchedule_events
  {root0Bindings : List Root0CommitmentBinding}
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount exportedRows : Nat}
  {events : List TranscriptEvent}
  (h :
    KernelTranscriptSchedule
      root0Bindings
      schedule
      publicStepCount
      exportedRows
      events) :
  events = transcriptEvents root0Bindings schedule publicStepCount exportedRows :=
  h.2.2

theorem rootMainLaneEvents_prefix
  (schedule : Nightstream.FoldSchedule)
  (publicStepCount : Nat) :
  ∃ rest,
    rootMainLaneEvents schedule publicStepCount =
      TranscriptEvent.absorbFoldSchedule schedule :: rest := by
  refine ⟨rootChunkScheduleFrom 0 (Nightstream.ChunkLayout.layout schedule publicStepCount), ?_⟩
  simp [rootMainLaneEvents]

theorem kernelTranscriptSchedule_rootMainLane_prefix
  {root0Bindings : List Root0CommitmentBinding}
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount exportedRows : Nat}
  {events : List TranscriptEvent}
  (h :
    KernelTranscriptSchedule
      root0Bindings
      schedule
      publicStepCount
      exportedRows
      events) :
  ∃ rest,
    events =
      phase0Events root0Bindings ++
        rootMainLaneEvents schedule publicStepCount ++
        rest := by
  rcases h with ⟨_, _, rfl⟩
  refine ⟨stage1Events ++ stage2Events ++ stage3Events exportedRows ++
      [.emitKernelOpeningClaims], ?_⟩
  simp [transcriptEvents, List.append_assoc]

theorem rowBinding_not_mem_rootChunkScheduleFrom
  (chunkIndex j : Nat)
  (chunks : List Nightstream.ChunkRange) :
  TranscriptEvent.rowBinding j ∉ rootChunkScheduleFrom chunkIndex chunks := by
  induction chunks generalizing chunkIndex with
  | nil =>
      simp [rootChunkScheduleFrom]
  | cons chunk rest ih =>
      simp [rootChunkScheduleFrom, rootChunkEvents, rootChunkRowLabelEvents, ih]

end Nightstream.Rv64IM
