import Nightstream.Chip8.Trace.AuthenticatedTraceCore

/-!
Owns the chunk-boundary and temporal-closure bridge above exact frame evidence.
This file turns exact authenticated frame evidence into chunk execution bounds,
trace boundary closure, Stage-2 temporal context, and the exact `pc` adjacency
bridge. It does not own the final execution/tracelink corollaries.
-/

namespace Nightstream.Chip8.AuthenticatedTrace

open Nightstream.Chip8
open Nightstream.Chip8.StepComposition
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.ChunkInput
open Nightstream.Chip8.TraceLinkBoundary
open Nightstream.Chip8.TemporalConsistency
open Nightstream.Chip8.PcContinuityBridge
open Nightstream.Chip8.TwistTemporalInstantiation

theorem wf_of_exactFrameEvidence
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  Nightstream.Chip8.wf frame.frame.row := by
  rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨_, _, _, _, _, _, hCont, _, _⟩
  rcases hCont with ⟨_, _, _, _, _, _, rowClaim, hRow⟩
  let _ := rowClaim
  rcases hRow with ⟨_, _, _, _, _, _, _, hRowBound⟩
  simpa [Nightstream.Chip8.wf] using hRowBound.2.2.2.2.2

theorem stateWellFormedFrames_of_frames
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
  (frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)) :
  List.Forall
    (fun frame =>
      StepComposition.StateWellFormed frame.pre ∧
        StepComposition.StateWellFormed frame.post)
    (traceOf frames) := by
  induction frames with
  | nil =>
      simp [traceOf, List.Forall]
  | cons frame rest ih =>
      simpa [traceOf, List.Forall] using
        And.intro ⟨frame.preWellFormed, frame.postWellFormed⟩ ih

theorem executionFrameBound_of_exactFrameEvidence
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  StepComposition.ExecutionFrameBound rom σ frame.frame := by
  have hWf : Nightstream.Chip8.wf frame.frame.row := wf_of_exactFrameEvidence frame
  rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨_, _, hWitness, hFetch, hLookup, hMem, _, hFramebuffer, hSchedule⟩
  rcases semanticEvidenceCovered_of_exactEvidence frame.exactEvidence with
    ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  have hRouting : Nightstream.Chip8.chip8RoutingSound frame.frame.row :=
    routingSound_of_evidence hSem
  refine ⟨hWf, hWitness, ?_⟩
  exact StepComposition.microstepCorrect_of_bounds
    frame.preWellFormed frame.postWellFormed hWf hWitness hFetch hLookup
    hMem hFramebuffer hSchedule hRouting

theorem stepIdx_lt_publishedLength_of_exactFrameEvidence
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
  (frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init) :
  frame.stepIdx < inputs.publishedLength := by
  rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
    ⟨_, hExecInputs, _, _, _, _, _, _, _⟩
  have hLen : inputs.publishedLength = inputs.scheduleLength σ := hExecInputs.2.2.1
  have hLive : frame.stepIdx < inputs.scheduleLength σ := hExecInputs.2.2.2
  simpa [hLen] using hLive

theorem executionFramesBound_of_exactTraceFrom
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)} :
  ∀ {stepIdx : Nat},
    ExactTraceEvidenceFrom stepIdx frames →
      List.Forall (StepComposition.ExecutionFrameBound rom σ) (traceOf frames) := by
  induction frames with
  | nil =>
      intro stepIdx hTrace
      simp [traceOf, List.Forall]
  | cons frame rest ih =>
      intro stepIdx hTrace
      cases rest with
      | nil =>
          simpa [traceOf, List.Forall] using
            And.intro
              (executionFrameBound_of_exactFrameEvidence frame)
              True.intro
      | cons next tail =>
          have hTail :
              ExactTraceEvidenceFrom (stepIdx + 1) (next :: tail) :=
            tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons_cons hTrace
          simpa [traceOf, List.Forall] using
            And.intro
              (executionFrameBound_of_exactFrameEvidence frame)
              (ih hTail)

theorem executionFramesBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace : ExactTraceEvidence frames) :
  List.Forall (StepComposition.ExecutionFrameBound rom σ) (traceOf frames) :=
  executionFramesBound_of_exactTraceFrom hTrace

theorem continuityTraceBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)} :
  ∀ {stepIdx : Nat},
    ExactTraceEvidenceFrom stepIdx frames →
      StepComposition.ContinuityTraceBound stepIdx (traceOf frames) := by
  induction frames with
  | nil =>
      intro stepIdx hTrace
      simp [traceOf, ExecutionSemantics.ContinuityTraceBound]
  | cons frame rest ih =>
      intro stepIdx hTrace
      have hStep : frame.stepIdx = stepIdx :=
        headStepIdx_of_exactTraceEvidenceFrom_cons hTrace
      rcases semanticBounds_of_exactAuthenticatedEvidence frame.exactEvidence with
        ⟨_, _, _, _, _, _, hCont, _, _⟩
      have hHead :
          ∃ N β1 β2 shiftClaim shiftProof currentRow rowClaim,
            StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim
              shiftProof currentRow rowClaim frame.frame.row := by
        simpa [hStep] using hCont
      cases rest with
      | nil =>
          simpa [traceOf, ExecutionSemantics.ContinuityTraceBound] using
            And.intro hHead True.intro
      | cons next tail =>
          have hTail :
              ExactTraceEvidenceFrom (stepIdx + 1) (next :: tail) :=
            tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons_cons hTrace
          exact ⟨hHead, ih hTail⟩

theorem startBoundaryFrame_of_exactHead
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
  {frame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  {rest :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace : ExactTraceEvidence (frame :: rest)) :
  StepComposition.StartBoundaryFrame frame.frame := by
  have hStep : frame.stepIdx = 0 :=
    headStepIdx_of_exactTraceEvidenceFrom_cons hTrace
  rcases semanticEvidenceCovered_of_exactEvidence frame.exactEvidence with
    ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact startBoundaryFrame_of_evidence hSem hStep

theorem lastStepIdx_of_exactTraceFrom_appendLast
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
  {stepIdx : Nat}
  {framesPrefix :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {lastFrame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hTrace : ExactTraceEvidenceFrom stepIdx (framesPrefix ++ [lastFrame])) :
  lastFrame.stepIdx = stepIdx + framesPrefix.length := by
  induction framesPrefix generalizing stepIdx with
  | nil =>
      simpa [ExactTraceEvidenceFrom] using hTrace
  | cons frame framesPrefix ih =>
      have hFrame : frame.stepIdx = stepIdx :=
        headStepIdx_of_exactTraceEvidenceFrom_cons hTrace
      have hTail :
          ExactTraceEvidenceFrom (stepIdx + 1) (framesPrefix ++ [lastFrame]) :=
        tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons hTrace
      have hLast : lastFrame.stepIdx = stepIdx + 1 + framesPrefix.length := ih hTail
      calc
        lastFrame.stepIdx = stepIdx + 1 + framesPrefix.length := hLast
        _ = stepIdx + (framesPrefix.length + 1) := by omega
        _ = stepIdx + (frame :: framesPrefix).length := by simp

theorem finalBoundaryFrame_of_exactTail
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
  {framesPrefix :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  {lastFrame :
    ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ init}
  (hTrace : ExactTraceEvidence (framesPrefix ++ [lastFrame]))
  (hLen : (framesPrefix ++ [lastFrame]).length = inputs.pubMeta.semanticRows) :
  StepComposition.FinalBoundaryFrame lastFrame.frame := by
  have hStep : lastFrame.stepIdx = framesPrefix.length := by
    simpa using lastStepIdx_of_exactTraceFrom_appendLast hTrace
  have hLast :
      lastFrame.stepIdx + 1 = inputs.pubMeta.semanticRows := by
    simpa [hStep] using hLen
  rcases semanticEvidenceCovered_of_exactEvidence lastFrame.exactEvidence with
    ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact finalBoundaryFrame_of_evidence hSem hLast

theorem traceLength_le_publishedLength_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hTrace : ExactTraceEvidence frames) :
  frames.length ≤ inputs.publishedLength := by
  cases frames using List.reverseRecOn with
  | nil =>
      simp
  | @append_singleton framesPrefix last =>
      have hLastStep : last.stepIdx = framesPrefix.length := by
        simpa using
          (lastStepIdx_of_exactTraceFrom_appendLast
            (framesPrefix := framesPrefix) (lastFrame := last) hTrace)
      have hLive : last.stepIdx < inputs.publishedLength :=
        stepIdx_lt_publishedLength_of_exactFrameEvidence (inputs := inputs) last
      have hBound : framesPrefix.length + 1 ≤ inputs.publishedLength := by
        omega
      simpa using hBound

theorem headInitialStateMatch_of_chunkInput
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  HeadInitialStateMatch (init := init) frames := by
  cases frames with
  | nil =>
      have hNe :
          (traceOf
              ([] :
                List
                  (ExactFrameEvidence pcs inputs evalBase B publicTable
                    tableBackedBy readSessionKey pairedSessionKey
                    validAddressColumns kernelAddressBound readCheckExpression
                    rwReadCheckExpression writeCheckExpression
                    valEvaluationExpression readOnlyMemoryRelation
                    readWriteMemoryRelation incrementRelation rom σ init))) ≠ [] :=
        ChunkInput.trace_nonempty_of_simpleKernelChunkInput hChunk
      simp [traceOf] at hNe
  | cons first rest =>
      simpa [HeadInitialStateMatch, traceOf] using
        (ChunkInput.headInitialStateMatches_of_simpleKernelChunkInput hChunk)

theorem traceLength_eq_semanticRows_of_chunkInput
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  frames.length = inputs.pubMeta.semanticRows := by
  simpa [traceOf] using
    (ChunkInput.traceLength_of_simpleKernelChunkInput hChunk)

theorem boundaryTraceBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  StepComposition.BoundaryTraceBound init (traceOf frames) := by
  have hInitHead : HeadInitialStateMatch (init := init) frames :=
    headInitialStateMatch_of_chunkInput (inputs := inputs) hChunk
  have hLen : frames.length = inputs.pubMeta.semanticRows :=
    traceLength_eq_semanticRows_of_chunkInput (inputs := inputs) hChunk
  cases frames with
  | nil =>
      exfalso
      have hNonempty := ChunkInput.trace_nonempty_of_simpleKernelChunkInput hChunk
      simpa [AuthenticatedTrace.traceOf] using hNonempty
  | cons first rest =>
      have hInitFirst : StepComposition.InitialStateMatches init first.frame.pre := hInitHead
      have hStart : StepComposition.StartBoundaryFrame first.frame :=
        startBoundaryFrame_of_exactHead hExact
      cases rest using List.reverseRecOn with
      | nil =>
          have hFinal : StepComposition.FinalBoundaryFrame first.frame := by
            simpa using
              (finalBoundaryFrame_of_exactTail
                (inputs := inputs)
                (framesPrefix := [])
                (lastFrame := first)
                hExact hLen)
          simpa [traceOf, StepComposition.BoundaryTraceBound] using
            And.intro hInitFirst (And.intro hStart hFinal)
      | @append_singleton middle last =>
          have hExactTail :
              ExactTraceEvidence ((first :: middle) ++ [last]) := by
            simpa [List.cons_append] using hExact
          have hLenTail :
              ((first :: middle) ++ [last]).length = inputs.pubMeta.semanticRows := by
            simpa [List.cons_append] using hLen
          have hFinal : StepComposition.FinalBoundaryFrame last.frame := by
            exact finalBoundaryFrame_of_exactTail
              (inputs := inputs)
              (framesPrefix := first :: middle)
              (lastFrame := last)
              hExactTail hLenTail
          refine And.intro hInitFirst (And.intro hStart ?_)
          have hRev :
              (traceOf (first :: (middle ++ [last]))).reverse =
                last.frame ::
                  (List.map ExactFrameEvidence.frame middle).reverse ++ [first.frame] := by
            simp [traceOf, List.reverse_append]
          rw [hRev]
          simpa using hFinal

theorem authenticatedChunkTraceBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  AuthenticatedChunkTraceBound (inputs := inputs) frames := by
  exact
    { framesBound := executionFramesBound_of_exactTrace hExact
      continuity := continuityTraceBound_of_exactTrace hExact
      boundary := boundaryTraceBound_of_exactTrace (inputs := inputs) hExact hChunk }

theorem registerAdjacentTraceBound_of_exactTraceFrom
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)} :
  ∀ {stepIdx : Nat},
    ExactTraceEvidenceFrom stepIdx frames →
      RegisterAdjacentTraceBound (traceOf frames) := by
  induction frames with
  | nil =>
      intro stepIdx hTrace
      simpa [traceOf, RegisterAdjacentTraceBound] using True.intro
  | cons current rest ih =>
      intro stepIdx hTrace
      cases rest with
      | nil =>
          simpa [traceOf, RegisterAdjacentTraceBound] using True.intro
      | cons next tail =>
          have hAdj := adjacentSupport_of_exactTraceEvidenceFrom_cons_cons hTrace
          have hTail :
              ExactTraceEvidenceFrom (stepIdx + 1) (next :: tail) :=
            tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons_cons hTrace
          simpa [traceOf, RegisterAdjacentTraceBound] using
            And.intro hAdj.1.1 (ih hTail)

theorem registerAdjacentTraceBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames) :
  RegisterAdjacentTraceBound (traceOf frames) :=
  registerAdjacentTraceBound_of_exactTraceFrom hExact

theorem ramAdjacentTraceBound_of_exactTraceFrom
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)} :
  ∀ {stepIdx : Nat},
    ExactTraceEvidenceFrom stepIdx frames →
      RamAdjacentTraceBound (traceOf frames) := by
  induction frames with
  | nil =>
      intro stepIdx hTrace
      simpa [traceOf, RamAdjacentTraceBound] using True.intro
  | cons current rest ih =>
      intro stepIdx hTrace
      cases rest with
      | nil =>
          simpa [traceOf, RamAdjacentTraceBound] using True.intro
      | cons next tail =>
          have hAdj := adjacentSupport_of_exactTraceEvidenceFrom_cons_cons hTrace
          have hTail :
              ExactTraceEvidenceFrom (stepIdx + 1) (next :: tail) :=
            tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons_cons hTrace
          simpa [traceOf, RamAdjacentTraceBound] using
            And.intro hAdj.1.2 (ih hTail)

theorem ramAdjacentTraceBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames) :
  RamAdjacentTraceBound (traceOf frames) :=
  ramAdjacentTraceBound_of_exactTraceFrom hExact

theorem pcAdjacentBridgeFrom_of_exactTraceFrom
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)} :
  ∀ {stepIdx : Nat},
    ExactTraceEvidenceFrom stepIdx frames →
      PcAdjacentBridgeFrom stepIdx (traceOf frames) := by
  induction frames with
  | nil =>
      intro stepIdx hTrace
      simp [traceOf, PcAdjacentBridgeFrom]
  | cons current rest ih =>
      intro stepIdx hTrace
      cases rest with
      | nil =>
          simp [traceOf, PcAdjacentBridgeFrom]
      | cons next tail =>
          have hStep : current.stepIdx = stepIdx :=
            headStepIdx_of_exactTraceEvidenceFrom_cons hTrace
          have hAdj := adjacentSupport_of_exactTraceEvidenceFrom_cons_cons hTrace
          have hTail :
              ExactTraceEvidenceFrom (stepIdx + 1) (next :: tail) :=
            tailExactTraceEvidenceFrom_of_exactTraceEvidenceFrom_cons_cons hTrace
          rcases hAdj.2 with
            ⟨N, β1, β2, shiftClaim, shiftProof, currentRow, rowClaim,
              hContCurrent, hShiftCurrent, hShiftNext⟩
          have hCont :
              StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim
                shiftProof currentRow rowClaim current.frame.row := by
            simpa [hStep] using hContCurrent
          refine ⟨?_, ih hTail⟩
          exact ⟨N, β1, β2, shiftClaim, shiftProof, currentRow, rowClaim, hCont,
            hShiftCurrent, hShiftNext⟩

theorem pcAdjacentBridge_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames) :
  PcAdjacentBridge (traceOf frames) := by
  exact pcAdjacentBridgeFrom_of_exactTraceFrom hExact

theorem stage2TemporalContextBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames) :
  Stage2TemporalContextBound (traceOf frames) := by
  exact
    stage2TemporalContextBound_of_adjacentTraceBounds
      (registerAdjacentTraceBound_of_exactTrace hExact)
      (ramAdjacentTraceBound_of_exactTrace hExact)

theorem authenticatedTemporalSupportBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames) :
  AuthenticatedTemporalSupportBound (inputs := inputs) frames := by
  exact
    { stage2 := stage2TemporalContextBound_of_exactTrace hExact
      pcBridge := pcAdjacentBridge_of_exactTrace hExact }

theorem authenticatedExecutionTraceBound_of_exactTrace_and_temporal
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames)
  (hTemporal :
    TemporalInstantiationBound (traceOf frames)) :
  AuthenticatedExecutionTraceBound (inputs := inputs) frames := by
  exact
    { chunkTrace :=
        authenticatedChunkTraceBound_of_exactTrace (inputs := inputs) hExact hChunk
      stage2TemporalSeeds :=
        stage2TemporalSeedSummary_of_frames (inputs := inputs)
          (evalBase := evalBase) (B := B) frames
      temporalSupport := hSupport
      temporal := hTemporal }

theorem temporalInstantiationBound_of_authenticatedTemporalSupport
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hFrames : List.Forall (StepComposition.ExecutionFrameBound rom σ) (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames) :
  TemporalInstantiationBound (traceOf frames) := by
  exact temporalInstantiationBound_of_stage2_and_bridge hFrames
    (stateWellFormedFrames_of_frames frames)
    (stage2TemporalInstantiationBound_of_context hSupport.stage2)
    hSupport.pcBridge

theorem authenticatedExecutionTraceBound_of_exactTrace_and_support
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames))
  (hSupport :
    AuthenticatedTemporalSupportBound (inputs := inputs) frames) :
  AuthenticatedExecutionTraceBound (inputs := inputs) frames := by
  exact
    authenticatedExecutionTraceBound_of_exactTrace_and_temporal
      (inputs := inputs) hExact hChunk
      hSupport
      (temporalInstantiationBound_of_authenticatedTemporalSupport
        (executionFramesBound_of_exactTrace hExact) hSupport)

theorem authenticatedExecutionTraceBound_of_exactTrace
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
  {frames :
    List
      (ExactFrameEvidence pcs inputs evalBase B publicTable tableBackedBy
        readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
        readCheckExpression rwReadCheckExpression writeCheckExpression
        valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
        incrementRelation rom σ init)}
  (hExact : ExactTraceEvidence frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (traceOf frames)) :
  AuthenticatedExecutionTraceBound (inputs := inputs) frames := by
  exact authenticatedExecutionTraceBound_of_exactTrace_and_support
    (inputs := inputs) hExact hChunk
    (authenticatedTemporalSupportBound_of_exactTrace hExact)

end Nightstream.Chip8.AuthenticatedTrace
