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

private theorem event_mem_rootChunkScheduleFrom_of_getElem?
  {chunks : List Nightstream.ChunkRange}
  {base chunkIndex : Nat}
  {chunk : Nightstream.ChunkRange}
  {event : TranscriptEvent}
  (hChunk : chunks[chunkIndex]? = some chunk)
  (hEvent : event ∈ rootChunkEvents (base + chunkIndex) chunk) :
  event ∈ rootChunkScheduleFrom base chunks := by
  induction chunks generalizing base chunkIndex with
  | nil =>
      cases chunkIndex <;> simp at hChunk
  | cons chunk0 rest ih =>
      cases chunkIndex with
      | zero =>
          simp only [List.getElem?_cons_zero] at hChunk
          injection hChunk with hEq
          subst hEq
          have hEvent0 : event ∈ rootChunkEvents base chunk0 := by
            simpa using hEvent
          have hMem :
              event ∈
                rootChunkEvents base chunk0 ++ rootChunkScheduleFrom (base + 1) rest := by
            exact List.mem_append.mpr (Or.inl hEvent0)
          simpa [rootChunkScheduleFrom] using hMem
      | succ chunkIndex =>
          simp only [List.getElem?_cons_succ] at hChunk
          have hEvent' :
              event ∈ rootChunkEvents ((base + 1) + chunkIndex) chunk := by
            simpa [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm] using hEvent
          have hTail :
              event ∈ rootChunkScheduleFrom (base + 1) rest :=
            ih hChunk hEvent'
          have hMem :
              event ∈
                rootChunkEvents base chunk0 ++ rootChunkScheduleFrom (base + 1) rest := by
            exact List.mem_append.mpr (Or.inr hTail)
          simpa [rootChunkScheduleFrom] using hMem

theorem rootChunkStart_mem_rootMainLaneEvents_of_layout
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount chunkIndex : Nat}
  {chunk : Nightstream.ChunkRange}
  (hChunk :
    (Nightstream.ChunkLayout.layout schedule publicStepCount)[chunkIndex]? = some chunk) :
  TranscriptEvent.rootChunkStart chunkIndex chunk.start chunk.stop ∈
    rootMainLaneEvents schedule publicStepCount := by
  have hEvent :
      TranscriptEvent.rootChunkStart chunkIndex chunk.start chunk.stop ∈
        rootChunkEvents chunkIndex chunk := by
    simp [rootChunkEvents]
  have hMem :
      TranscriptEvent.rootChunkStart chunkIndex chunk.start chunk.stop ∈
        rootChunkScheduleFrom 0 (Nightstream.ChunkLayout.layout schedule publicStepCount) :=
    event_mem_rootChunkScheduleFrom_of_getElem? (base := 0) hChunk (by simpa using hEvent)
  exact List.mem_cons_of_mem _ hMem

theorem rootChunkPiCCS_mem_rootMainLaneEvents_of_layout
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount chunkIndex : Nat}
  {chunk : Nightstream.ChunkRange}
  (hChunk :
    (Nightstream.ChunkLayout.layout schedule publicStepCount)[chunkIndex]? = some chunk) :
  TranscriptEvent.rootChunkPiCCS chunkIndex ∈
    rootMainLaneEvents schedule publicStepCount := by
  have hEvent :
      TranscriptEvent.rootChunkPiCCS chunkIndex ∈
        rootChunkEvents chunkIndex chunk := by
    simp [rootChunkEvents]
  have hMem :
      TranscriptEvent.rootChunkPiCCS chunkIndex ∈
        rootChunkScheduleFrom 0 (Nightstream.ChunkLayout.layout schedule publicStepCount) :=
    event_mem_rootChunkScheduleFrom_of_getElem? (base := 0) hChunk (by simpa using hEvent)
  exact List.mem_cons_of_mem _ hMem

theorem rootChunkPiRLC_mem_rootMainLaneEvents_of_layout
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount chunkIndex : Nat}
  {chunk : Nightstream.ChunkRange}
  (hChunk :
    (Nightstream.ChunkLayout.layout schedule publicStepCount)[chunkIndex]? = some chunk) :
  TranscriptEvent.rootChunkPiRLC chunkIndex ∈
    rootMainLaneEvents schedule publicStepCount := by
  have hEvent :
      TranscriptEvent.rootChunkPiRLC chunkIndex ∈
        rootChunkEvents chunkIndex chunk := by
    simp [rootChunkEvents]
  have hMem :
      TranscriptEvent.rootChunkPiRLC chunkIndex ∈
        rootChunkScheduleFrom 0 (Nightstream.ChunkLayout.layout schedule publicStepCount) :=
    event_mem_rootChunkScheduleFrom_of_getElem? (base := 0) hChunk (by simpa using hEvent)
  exact List.mem_cons_of_mem _ hMem

theorem rootChunkPiDEC_mem_rootMainLaneEvents_of_layout
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount chunkIndex : Nat}
  {chunk : Nightstream.ChunkRange}
  (hChunk :
    (Nightstream.ChunkLayout.layout schedule publicStepCount)[chunkIndex]? = some chunk) :
  TranscriptEvent.rootChunkPiDEC chunkIndex ∈
    rootMainLaneEvents schedule publicStepCount := by
  have hEvent :
      TranscriptEvent.rootChunkPiDEC chunkIndex ∈
        rootChunkEvents chunkIndex chunk := by
    simp [rootChunkEvents]
  have hMem :
      TranscriptEvent.rootChunkPiDEC chunkIndex ∈
        rootChunkScheduleFrom 0 (Nightstream.ChunkLayout.layout schedule publicStepCount) :=
    event_mem_rootChunkScheduleFrom_of_getElem? (base := 0) hChunk (by simpa using hEvent)
  exact List.mem_cons_of_mem _ hMem

theorem rootChunkRowLabel_mem_rootMainLaneEvents_of_layout
  {schedule : Nightstream.FoldSchedule}
  {publicStepCount chunkIndex rowIndex : Nat}
  {chunk : Nightstream.ChunkRange}
  (hChunk :
    (Nightstream.ChunkLayout.layout schedule publicStepCount)[chunkIndex]? = some chunk)
  (hRow : rowIndex ∈ List.range' chunk.start chunk.width) :
  TranscriptEvent.rootChunkRowLabel chunkIndex rowIndex ∈
    rootMainLaneEvents schedule publicStepCount := by
  have hLabel :
      TranscriptEvent.rootChunkRowLabel chunkIndex rowIndex ∈
        rootChunkRowLabelEvents chunkIndex chunk := by
    apply List.mem_map.mpr
    exact ⟨rowIndex, hRow, by simp⟩
  have hEvent :
      TranscriptEvent.rootChunkRowLabel chunkIndex rowIndex ∈
        rootChunkEvents chunkIndex chunk := by
    simp [rootChunkEvents, hLabel]
  have hMem :
      TranscriptEvent.rootChunkRowLabel chunkIndex rowIndex ∈
        rootChunkScheduleFrom 0 (Nightstream.ChunkLayout.layout schedule publicStepCount) :=
    event_mem_rootChunkScheduleFrom_of_getElem? (base := 0) hChunk (by simpa using hEvent)
  exact List.mem_cons_of_mem _ hMem

end Nightstream.Rv64IM
