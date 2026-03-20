import Nightstream.Chip8.Execution.ExecutionSemantics

namespace Nightstream.Chip8.BurstSession

open Nightstream.Chip8
open Nightstream.Chip8.DecodeAddressBinding
open Nightstream.Chip8.ExecutionSemantics
open Nightstream.Chip8.WitnessMemoryBinding

abbrev MachineState := ExecutionSemantics.MachineState
abbrev ExternalSchedule := ExecutionSemantics.ExternalSchedule
abbrev ExecutionFrame := ExecutionSemantics.ExecutionFrame

def RamPreservedExcept (pre post : MachineState) (addr : Nat) : Prop :=
  ∀ other, other ≠ addr → post.ram other = pre.ram other

def BurstMicrostepCorrect
  {Addr : Type*}
  (rom : FetchDecodeBinding.Program)
  (σ : ExternalSchedule)
  (frame : ExecutionFrame Addr) : Prop :=
  (frame.dec.opcodeId = .storeRegs ∨ frame.dec.opcodeId = .loadRegs) ∧
    MicrostepCorrect rom σ frame.dec frame.pre frame.post

def BurstSession
  {Addr : Type*}
  (frames : List (ExecutionFrame Addr)) : Prop :=
  frames ≠ []

def BurstAnchored
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (pre post : MachineState)
  (frames : List (ExecutionFrame Addr)) : Prop :=
  ∃ firstFrame lastFrame,
    frames[0]? = some firstFrame ∧
      frames[dec.x]? = some lastFrame ∧
      firstFrame.pre = pre ∧
      lastFrame.post = post

def BurstChained
  {Addr : Type*}
  (frames : List (ExecutionFrame Addr)) : Prop :=
  ExecutionLinked frames

def BurstStepDerivedFrom
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (idx : Nat)
  (frame : ExecutionFrame Addr) : Prop :=
  frame.dec.toDecodedCore = dec.toDecodedCore ∧
    frame.dec.microIndex = idx ∧
    frame.dec.pcWord = dec.pcWord ∧
    frame.dec.opcodeWord = dec.opcodeWord ∧
    frame.dec.isMemOp = 1 ∧
    frame.dec.xBound = dec.x ∧
    frame.dec.ramAddr = frame.pre.i + idx

def BurstDerivedFrom
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (frames : List (ExecutionFrame Addr)) : Prop :=
  ∀ (i : Nat) (frame : ExecutionFrame Addr),
    frames[i]? = some frame → BurstStepDerivedFrom dec i frame

def BurstCoversPrefix
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (frames : List (ExecutionFrame Addr)) : Prop :=
  frames.length = dec.x + 1

def BurstCursorMonotone
  {Addr : Type*}
  (frames : List (ExecutionFrame Addr)) : Prop :=
  ∀ (i : Nat) (frame frame' : ExecutionFrame Addr),
    frames[i]? = some frame →
      frames[i + 1]? = some frame' →
      frame'.dec.microIndex = frame.dec.microIndex + 1

def BurstFrameCorrect
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (pre post : MachineState) : Prop :=
  match dec.opcodeId with
  | .storeRegs =>
      post.i = pre.i ∧
        RegistersPreserved pre post ∧
        RamPrefixStored pre post dec ∧
        RamPreservedOutsidePrefix pre post dec
  | .loadRegs =>
      post.i = pre.i ∧
        RegistersLoadedPrefix pre post dec ∧
        RegistersPreservedAbove pre post dec.x ∧
        RamPreserved pre post
  | _ => False

def BurstPcStable
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (pre : MachineState)
  (frames : List (ExecutionFrame Addr)) : Prop :=
  ∀ (i : Nat) (frame : ExecutionFrame Addr),
    frames[i]? = some frame →
      i ≤ dec.x →
      frame.pre.pc = pre.pc

def BurstFramesBound
  {Addr : Type*}
  (rom : FetchDecodeBinding.Program)
  (σ : ExternalSchedule)
  (frames : List (ExecutionFrame Addr)) : Prop :=
  List.Forall (ExecutionFrameBound rom σ) frames

def BurstContinuityBound
  {Addr : Type*}
  (frames : List (ExecutionFrame Addr)) : Prop :=
  ContinuityTraceBound 0 frames

def BurstScheduleCorrect
  {Addr : Type*}
  (rom : FetchDecodeBinding.Program)
  (σ : ExternalSchedule)
  (dec : DecodedStep Addr)
  (pre post : MachineState)
  (frames : List (ExecutionFrame Addr)) : Prop :=
  BurstSession frames ∧
    BurstAnchored dec pre post frames ∧
    BurstChained frames ∧
    BurstDerivedFrom dec frames ∧
    BurstCoversPrefix dec frames ∧
    BurstCursorMonotone frames ∧
    BurstFrameCorrect dec pre post ∧
    BurstPcStable dec pre frames ∧
    BurstFramesBound rom σ frames ∧
    BurstContinuityBound frames

private theorem listForall_get?_some
  {α : Type*}
  {P : α → Prop}
  {xs : List α}
  (hForall : List.Forall P xs)
  {i : Nat}
  {x : α}
  (hx : xs[i]? = some x) :
  P x := by
  induction xs generalizing i x with
  | nil =>
      cases hForall
      cases hx
  | cons a xs ih =>
      have hCons : P a ∧ List.Forall P xs := by
        simpa using hForall
      rcases hCons with ⟨ha, hTail⟩
      cases i with
      | zero =>
          simp at hx
          cases hx
          simpa using ha
      | succ i =>
          simp at hx
          exact ih hTail hx

private theorem burstLastValue_eq_one_of_finalFrame
  {Addr : Type*}
  {macroDec : DecodedStep Addr}
  {frameDec : DecodedStep Addr}
  (hOpcode : frameDec.opcodeId = .storeRegs ∨ frameDec.opcodeId = .loadRegs)
  (hMicro : frameDec.microIndex = macroDec.x)
  (hXBound : frameDec.xBound = macroDec.x)
  (hMemOp : frameDec.isMemOp = 1) :
  WitnessMemoryBinding.burstLastValue frameDec = 1 := by
  cases hOpcode with
  | inl hStore =>
      have hActive : activeXIndex frameDec = frameDec.microIndex := activeXIndex_of_storeRegs hStore
      unfold WitnessMemoryBinding.burstLastValue WitnessMemoryBinding.primaryIndex
      rw [hActive, hMemOp, hXBound, hMicro]
      simp [FetchDecodeBinding.eq4Eval]
  | inr hLoad =>
      have hActive : activeXIndex frameDec = frameDec.microIndex := activeXIndex_of_loadRegs hLoad
      unfold WitnessMemoryBinding.burstLastValue WitnessMemoryBinding.primaryIndex
      rw [hActive, hMemOp, hXBound, hMicro]
      simp [FetchDecodeBinding.eq4Eval]

theorem instructionCorrect_of_burstSession
  {Addr : Type*}
  {rom : FetchDecodeBinding.Program}
  {σ : ExternalSchedule}
  {dec : DecodedStep Addr}
  {pre post : MachineState}
  {frames : List (ExecutionFrame Addr)}
  (hSchedule : BurstScheduleCorrect rom σ dec pre post frames) :
  InstructionCorrect rom σ dec pre post := by
  rcases hSchedule with
    ⟨_, hAnchored, _, hDerived, _, _, hFrame, hPcStable, hFrames, _⟩
  rcases hAnchored with ⟨firstFrame, lastFrame, hFirstFrame, hLastFrame, hPre, hPost⟩
  have hLastDerived := hDerived dec.x lastFrame hLastFrame
  rcases hLastDerived with ⟨hCoreEq, hIdx, _, _, hMemOp, hXBound, _⟩
  have hLastFrameBound := listForall_get?_some hFrames hLastFrame
  have hLastMicro :=
    executionFrameBound_microstepCorrect hLastFrameBound
  have hStepOpcode : lastFrame.dec.opcodeId = dec.opcodeId := by
    simpa using congrArg (fun c => c.opcodeId) hCoreEq
  have hStepX : lastFrame.dec.x = dec.x := by
    simpa using congrArg (fun c => c.x) hCoreEq
  have hLastPrePc : lastFrame.pre.pc = pre.pc := by
    exact hPcStable dec.x lastFrame hLastFrame (Nat.le_refl _)
  cases hDec : dec.opcodeId
  · exact False.elim (by simpa [BurstFrameCorrect, hDec] using hFrame)
  · exact False.elim (by simpa [BurstFrameCorrect, hDec] using hFrame)
  · exact False.elim (by simpa [BurstFrameCorrect, hDec] using hFrame)
  · exact False.elim (by simpa [BurstFrameCorrect, hDec] using hFrame)
  · exact False.elim (by simpa [BurstFrameCorrect, hDec] using hFrame)
  · exact False.elim (by simpa [BurstFrameCorrect, hDec] using hFrame)
  · exact False.elim (by simpa [BurstFrameCorrect, hDec] using hFrame)
  · have hOpcodeStep : lastFrame.dec.opcodeId = .storeRegs := by
      simpa [hDec] using hStepOpcode
    have hBurstLastValue :
        WitnessMemoryBinding.burstLastValue lastFrame.dec = 1 := by
      exact burstLastValue_eq_one_of_finalFrame
        (hOpcode := Or.inl hOpcodeStep) (hMicro := hIdx) (hXBound := hXBound) (hMemOp := hMemOp)
    have hLastMicro' :
        lastFrame.post.pc =
            lastFrame.pre.pc + WitnessMemoryBinding.burstLastValue lastFrame.dec ∧
          lastFrame.post.i = lastFrame.pre.i ∧
          RegistersPreserved lastFrame.pre lastFrame.post ∧
          RamPrefixStored lastFrame.pre lastFrame.post lastFrame.dec ∧
          RamPreservedOutsidePrefix lastFrame.pre lastFrame.post lastFrame.dec := by
      simpa [MicrostepCorrect, hOpcodeStep] using hLastMicro
    have hFrame' :
        post.i = pre.i ∧
          RegistersPreserved pre post ∧
          RamPrefixStored pre post dec ∧
          RamPreservedOutsidePrefix pre post dec := by
      simpa [BurstFrameCorrect, hDec] using hFrame
    have hPc : post.pc = pre.pc + 1 := by
      rcases hLastMicro' with ⟨hPc, _, _, _, _⟩
      calc
        post.pc = lastFrame.post.pc := by simpa [hPost]
        _ = lastFrame.pre.pc + WitnessMemoryBinding.burstLastValue lastFrame.dec := hPc
        _ = lastFrame.pre.pc + 1 := by simp [hBurstLastValue]
        _ = pre.pc + 1 := by simp [hLastPrePc]
    simpa [InstructionCorrect, hDec] using
      ⟨hPc, hFrame'.1, hFrame'.2.1, hFrame'.2.2.1, hFrame'.2.2.2⟩
  · have hOpcodeStep : lastFrame.dec.opcodeId = .loadRegs := by
      simpa [hDec] using hStepOpcode
    have hBurstLastValue :
        WitnessMemoryBinding.burstLastValue lastFrame.dec = 1 := by
      exact burstLastValue_eq_one_of_finalFrame
        (hOpcode := Or.inr hOpcodeStep) (hMicro := hIdx) (hXBound := hXBound) (hMemOp := hMemOp)
    have hLastMicro' :
        lastFrame.post.pc =
            lastFrame.pre.pc + WitnessMemoryBinding.burstLastValue lastFrame.dec ∧
          lastFrame.post.i = lastFrame.pre.i ∧
          RegistersLoadedPrefix lastFrame.pre lastFrame.post lastFrame.dec ∧
          RegistersPreservedAbove lastFrame.pre lastFrame.post lastFrame.dec.x ∧
          RamPreserved lastFrame.pre lastFrame.post := by
      simpa [MicrostepCorrect, hOpcodeStep] using hLastMicro
    have hFrame' :
        post.i = pre.i ∧
          RegistersLoadedPrefix pre post dec ∧
          RegistersPreservedAbove pre post dec.x ∧
          RamPreserved pre post := by
      simpa [BurstFrameCorrect, hDec] using hFrame
    have hPc : post.pc = pre.pc + 1 := by
      rcases hLastMicro' with ⟨hPc, _, _, _, _⟩
      calc
        post.pc = lastFrame.post.pc := by simpa [hPost]
        _ = lastFrame.pre.pc + WitnessMemoryBinding.burstLastValue lastFrame.dec := hPc
        _ = lastFrame.pre.pc + 1 := by simp [hBurstLastValue]
        _ = pre.pc + 1 := by simp [hLastPrePc]
    simpa [InstructionCorrect, hDec] using
      ⟨hPc, hFrame'.1, hFrame'.2.1, hFrame'.2.2.1, hFrame'.2.2.2⟩

end Nightstream.Chip8.BurstSession
