import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.Execution.ExecutionSemantics
import Nightstream.Rv64IM.Execution.Stage2TemporalClosure
import Nightstream.Rv64IM.Execution.PcAdjacentBridge
import Nightstream.Rv64IM.Trace.RegisterTimeline
import Nightstream.Rv64IM.Trace.RamTimeline
import Nightstream.Rv64IM.Trace.TemporalConsistency

/-!
Owns constructive replay of the RV64IM architectural state trace from the
accepted-artifact source case and imported execution rows. This owner rebuilds
the exact temporal packages Lean can already recover directly from row-local
read/write effects: Stage 2 temporal closure, register and RAM timelines, the
PC-adjacency bridge, and the derived temporal-consistency package.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated

abbrev ReplayPc := Nat
abbrev ReplayRegIdx := Nat
abbrev ReplayRamAddr := Nat
abbrev ReplayWord := Nat

abbrev ReplayRegisterState := RegisterState ReplayRegIdx ReplayWord
abbrev ReplayRamState := RamWordState ReplayRamAddr ReplayWord
abbrev ReplayArchitecturalState :=
  ArchitecturalState ReplayPc ReplayRegIdx ReplayRamAddr ReplayWord

structure ReplayConcreteState where
  pc : Nat
  registers : List Nat
  memory : List MemoryWordView
  halted : Bool
deriving DecidableEq, Repr

structure RecoveredTemporalReplay where
  initialConcrete : ReplayConcreteState
  rows : List ExpandedRowView
  postConcreteStates : List ReplayConcreteState
deriving DecidableEq, Repr

private def listGet? : List α → Nat → Option α
  | [], _ => none
  | value :: _, 0 => some value
  | _ :: values, idx + 1 => listGet? values idx

private def listGetD (values : List Nat) (idx default : Nat) : Nat :=
  values.getD idx default

private def listSet : List Nat → Nat → Nat → List Nat
  | [], _, _ => []
  | _ :: values, 0, value => value :: values
  | head :: values, idx + 1, value => head :: listSet values idx value

private def readRegister (registers : List Nat) (idx : Nat) : Nat :=
  listGetD registers idx 0

private def writeRegister (registers : List Nat) (idx value : Nat) : List Nat :=
  let registers' :=
    if idx = 0 then
      registers
    else
      listSet registers idx value
  listSet registers' 0 0

private def readMemory (memory : List MemoryWordView) (addr : Nat) : Nat :=
  match memory.find? (fun word => word.addr = addr) with
  | some word => word.value
  | none => 0

private def writeMemory : List MemoryWordView → Nat → Nat → List MemoryWordView
  | [], addr, value => [{ addr := addr, value := value }]
  | word :: rest, addr, value =>
      if addr = word.addr then
        { addr := addr, value := value } :: rest
      else if addr < word.addr then
        { addr := addr, value := value } :: word :: rest
      else
        word :: writeMemory rest addr value

private def normalizedInitialRegisters (registers : List Nat) : List Nat :=
  writeRegister registers 0 0

def initialConcreteStateOfSource (source : ParitySourceCase) : ReplayConcreteState :=
  { pc := source.startPc
  , registers := normalizedInitialRegisters source.initialRegisters
  , memory := source.initialMemory
  , halted := false
  }

def architecturalStateOfConcrete (state : ReplayConcreteState) : ReplayArchitecturalState :=
  { pc := state.pc
  , registers := { read := fun idx => readRegister state.registers idx }
  , ram := { read := fun addr => readMemory state.memory addr }
  , halted := state.halted
  }

private def rowReadsMatch
    (state : ReplayConcreteState)
    (row : ExpandedRowView) : Bool :=
  state.pc = row.pc &&
    readRegister state.registers row.rs1 = row.rs1Value &&
    readRegister state.registers row.rs2 = row.rs2Value &&
    readRegister state.registers row.rd = row.rdBefore &&
    match row.effectiveAddr, row.memoryBefore with
    | some addr, some before => readMemory state.memory addr = before
    | some _, none => true
    | none, some _ => false
    | none, none => true

private def applyExecutionRow?
    (state : ReplayConcreteState)
    (row : ExpandedRowView) : Option ReplayConcreteState := do
  guard (rowReadsMatch state row)
  let registers :=
    if row.writesRd then
      writeRegister state.registers row.rd row.rdAfter
    else
      state.registers
  let memory ←
    if row.writesRam then
      match row.effectiveAddr, row.memoryAfter with
      | some addr, some after => some (writeMemory state.memory addr after)
      | _, _ => none
    else
      some state.memory
  pure
    { pc := row.nextPc
    , registers := registers
    , memory := memory
    , halted := row.halted
    }

private def replayPostConcreteStates?
    (state : ReplayConcreteState)
    (rows : List ExpandedRowView) : Option (List ReplayConcreteState) :=
  match rows with
  | [] => some []
  | row :: rows => do
      let nextState <- applyExecutionRow? state row
      let tail <- replayPostConcreteStates? nextState rows
      pure (nextState :: tail)

def recoverTemporalReplay?
    (artifact : AcceptedProofArtifactView) : Option RecoveredTemporalReplay := do
  let initialConcrete := initialConcreteStateOfSource artifact.source
  let postConcreteStates <- replayPostConcreteStates? initialConcrete artifact.derived.executionRows
  pure
    { initialConcrete := initialConcrete
    , rows := artifact.derived.executionRows
    , postConcreteStates := postConcreteStates
    }

def recoveredSemanticRows (recovered : RecoveredTemporalReplay) : Nat :=
  recovered.postConcreteStates.length

def recoveredPostConcreteAt
    (recovered : RecoveredTemporalReplay)
    (j : Nat) : ReplayConcreteState :=
  (listGet? recovered.postConcreteStates j).getD recovered.initialConcrete

def recoveredPreConcreteAt
    (recovered : RecoveredTemporalReplay) : Nat → ReplayConcreteState
  | 0 => recovered.initialConcrete
  | j + 1 => recoveredPostConcreteAt recovered j

def recoveredPreState
    (recovered : RecoveredTemporalReplay)
    (j : Nat) : ReplayArchitecturalState :=
  architecturalStateOfConcrete (recoveredPreConcreteAt recovered j)

def recoveredPostState
    (recovered : RecoveredTemporalReplay)
    (j : Nat) : ReplayArchitecturalState :=
  architecturalStateOfConcrete (recoveredPostConcreteAt recovered j)

def recoveredRegisterTimeline
    (recovered : RecoveredTemporalReplay) :
    Nat → ReplayRegisterState :=
  fun j => (recoveredPreState recovered j).registers

def recoveredRamTimeline
    (recovered : RecoveredTemporalReplay) :
    Nat → ReplayRamState :=
  fun j => (recoveredPreState recovered j).ram

theorem adjacentClosed_of_recoveredTemporalReplay
    (recovered : RecoveredTemporalReplay) :
    AdjacentStateClosed
      ReplayArchitecturalState
      (recoveredPreState recovered)
      (recoveredPostState recovered)
      (recoveredSemanticRows recovered) := by
  intro j _hLt
  rfl

def recoveredStage2TemporalClosure
    (recovered : RecoveredTemporalReplay) :
    Stage2TemporalClosureProofPackage
      ReplayArchitecturalState
      (Nat → ReplayRegisterState)
      (Nat → ReplayRamState)
      Unit :=
  { context :=
      { regTimeline := recoveredRegisterTimeline recovered
      , ramTimeline := recoveredRamTimeline recovered
      , rowLinks := ()
      }
  , semanticRows := recoveredSemanticRows recovered
  , preState := recoveredPreState recovered
  , postState := recoveredPostState recovered
  , adjacentClosed := adjacentClosed_of_recoveredTemporalReplay recovered
  }

theorem registerTimelineBound_of_recoveredTemporalReplay
    (recovered : RecoveredTemporalReplay) :
    RegisterTimelineBound
      (recoveredRegisterTimeline recovered)
      (recoveredPreState recovered)
      (recoveredPostState recovered)
      (recoveredSemanticRows recovered) := by
  intro j hLt
  refine ⟨rfl, ?_⟩
  intro hNext
  exact congrArg ArchitecturalState.registers
    (adjacentClosed_of_recoveredTemporalReplay recovered j hNext)

def recoveredRegisterTimelineProof
    (recovered : RecoveredTemporalReplay) :
    RegisterTimelineProofPackage ReplayPc ReplayRegIdx ReplayRamAddr ReplayWord :=
  { semanticRows := recoveredSemanticRows recovered
  , timeline := recoveredRegisterTimeline recovered
  , preState := recoveredPreState recovered
  , postState := recoveredPostState recovered
  , bound := registerTimelineBound_of_recoveredTemporalReplay recovered
  }

theorem ramTimelineBound_of_recoveredTemporalReplay
    (recovered : RecoveredTemporalReplay) :
    RamTimelineBound
      (recoveredRamTimeline recovered)
      (recoveredPreState recovered)
      (recoveredPostState recovered)
      (recoveredSemanticRows recovered) := by
  intro j hLt
  refine ⟨rfl, ?_⟩
  intro hNext
  exact congrArg ArchitecturalState.ram
    (adjacentClosed_of_recoveredTemporalReplay recovered j hNext)

def recoveredRamTimelineProof
    (recovered : RecoveredTemporalReplay) :
    RamTimelineProofPackage ReplayPc ReplayRegIdx ReplayRamAddr ReplayWord :=
  { semanticRows := recoveredSemanticRows recovered
  , timeline := recoveredRamTimeline recovered
  , preState := recoveredPreState recovered
  , postState := recoveredPostState recovered
  , bound := ramTimelineBound_of_recoveredTemporalReplay recovered
  }

def recoveredPcAdjacentBridge
    (recovered : RecoveredTemporalReplay) :
    PcAdjacentBridgeProofPackage ReplayPc :=
  { semanticRows := recoveredSemanticRows recovered
  , postPc := fun j => (recoveredPostState recovered j).pc
  , prePc := fun j => (recoveredPreState recovered j).pc
  , bridge := by
      intro j hLt
      exact congrArg ArchitecturalState.pc
        (adjacentClosed_of_recoveredTemporalReplay recovered j hLt)
  }

def recoveredTemporalConsistency
    (recovered : RecoveredTemporalReplay) :
    TemporalConsistencyProofPackage
      ReplayArchitecturalState
      ReplayPc
      ReplayRegIdx
      ReplayRamAddr
      ReplayWord
      (Nat → ReplayRegisterState)
      (Nat → ReplayRamState)
      Unit :=
  let stage2 := recoveredStage2TemporalClosure recovered
  let registers := recoveredRegisterTimelineProof recovered
  let ram := recoveredRamTimelineProof recovered
  let pcBridge := recoveredPcAdjacentBridge recovered
  { pcOf := ArchitecturalState.pc
  , stage2 := stage2
  , pcBridge := pcBridge
  , registers := registers
  , ram := ram
  , consistent := by
      refine ⟨stage2.adjacentClosed, pcBridge.bridge, registers.bound, ram.bound, rfl, rfl, rfl, ?_, ?_⟩
      · intro j hLt
        rfl
      · intro j hLt
        rfl
  }

def recoveredTemporalReplayMatchesFinalState
    (recovered : RecoveredTemporalReplay)
    (artifact : AcceptedProofArtifactView) : Bool :=
  let finalConcrete := recoveredPostConcreteAt recovered (recoveredSemanticRows recovered - 1)
  finalConcrete.pc = artifact.derived.kernel.finalPc &&
    finalConcrete.registers = artifact.derived.kernel.finalRegisters &&
    finalConcrete.memory = artifact.derived.kernel.finalMemory &&
    finalConcrete.halted = artifact.derived.kernel.halted

def recoveredTemporalReplayMatchesArtifact
    (recovered : RecoveredTemporalReplay)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recovered.rows = artifact.derived.executionRows &&
    recoveredSemanticRows recovered = artifact.derived.executionRows.length &&
    recoveredTemporalReplayMatchesFinalState recovered artifact

end Nightstream.Rv64IM
