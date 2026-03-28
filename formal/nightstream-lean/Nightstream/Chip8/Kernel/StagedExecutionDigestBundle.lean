import Nightstream.Chip8.Kernel.StagedExecutionDigest
import Nightstream.Chip8.Trace.AuthenticatedTrace
import Nightstream.Chip8.Trace.ChunkInput

/-!
Owns the chunk-level bundle of normalized staged execution digests over one
exact authenticated CHIP-8 frame list. This file does not own the later
bundle-audit acceptance checker; it only packages the exact digest entries in
canonical frame order.
-/

namespace Nightstream.Chip8.StagedExecutionDigestBundle

open Nightstream.Chip8
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.AuthenticatedTrace
open Nightstream.Chip8.ChunkInput
open Nightstream.Chip8.RootHandoffContext
open Nightstream.Chip8.StagedExecutionDigest

abbrev F := StagedExecutionDigest.F
abbrev Program := StagedExecutionDigest.Program
abbrev MachineState := StagedExecutionDigest.MachineState
abbrev InitialState := StagedExecutionDigest.InitialState
abbrev ExternalSchedule := StagedExecutionDigest.ExternalSchedule

section Bundle

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {pcs : EvidenceCoverage.PCSContext AuxIndex EvalPoint}
  {inputs :
    EvidenceCoverage.ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
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
  {W Z Commitment : Type*}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {rom : Program}
  {σ : ExternalSchedule}
  {init : InitialState}

local notation "ExactFrameT" =>
  AuthenticatedTrace.ExactFrameEvidence pcs inputs evalBase B publicTable
    tableBackedBy readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound readCheckExpression rwReadCheckExpression
    writeCheckExpression valEvaluationExpression readOnlyMemoryRelation
    readWriteMemoryRelation incrementRelation rom σ init

local notation "ExactFramesT" => List ExactFrameT

abbrev ExactFrames := ExactFramesT

private abbrev DigestOfFrame (frame : ExactFrameT) :=
  ExecutionDigest inputs rootCtx rom σ frame.stepIdx init
    frame.frame.pre frame.frame.post frame.frame.dec frame.frame.row

structure FrameDigestEntry where
  frame : ExactFrameT
  digest : DigestOfFrame frame
  bound :
    StagedExecutionDigestBound inputs rootCtx rom σ frame.stepIdx
      init frame.frame.pre frame.frame.post frame.frame.dec frame.frame.row
      digest

structure DigestBundle (frames : ExactFramesT) where
  publicSurface : DigestPublicSurface inputs rom init
  digests :
    List (@FrameDigestEntry AuxIndex EvalPoint AddressPoint CyclePoint
      AddressColumns Addr Table ValSurface Increment SessionKey DigestRom
      DigestSchedule RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B
      publicTable tableBackedBy readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound readCheckExpression
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readOnlyMemoryRelation readWriteMemoryRelation incrementRelation W Z
      Commitment rootCtx rom σ init)
  ordered : digests.map FrameDigestEntry.frame = frames

def DigestBundle.length
  {frames : ExactFramesT}
  (bundle :
    @DigestBundle AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns
      Addr Table ValSurface Increment SessionKey DigestRom DigestSchedule
      RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B publicTable
      tableBackedBy readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound readCheckExpression rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readOnlyMemoryRelation
      readWriteMemoryRelation incrementRelation W Z Commitment rootCtx rom σ init
      frames) :
  Nat :=
  bundle.digests.length

theorem kernelPublicInputsBound_of_bundle
  {frames : ExactFramesT}
  (bundle :
    @DigestBundle AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns
      Addr Table ValSurface Increment SessionKey DigestRom DigestSchedule
      RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B publicTable
      tableBackedBy readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound readCheckExpression rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readOnlyMemoryRelation
      readWriteMemoryRelation incrementRelation W Z Commitment rootCtx rom σ init
      frames) :
  RomScheduleBinding.KernelPublicInputsBound inputs.hashProgram
    inputs.hashInitialState inputs.programWordCountOf inputs.programBaseAddrOf
    inputs.padPcWordOf inputs.paddedTraceLengthOf inputs.twoPow
    inputs.rootParamsOf inputs.publicInput inputs.pubMeta rom init :=
  bundle.publicSurface.bound

theorem executionFrameBound_of_entry
  (entry :
    FrameDigestEntry (pcs := pcs) (inputs := inputs) (evalBase := evalBase)
      (B := B) (publicTable := publicTable)
      (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey)
      (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (W := W) (Z := Z)
      (Commitment := Commitment) (rootCtx := rootCtx) (rom := rom) (σ := σ)
      (init := init)) :
  StepComposition.ExecutionFrameBound rom σ entry.frame.frame := by
  exact executionFrameBound_of_digest entry.bound

noncomputable def frameDigestEntry_of_exactFrame
  (frame : ExactFrameT) :
  FrameDigestEntry (pcs := pcs) (inputs := inputs) (evalBase := evalBase)
    (B := B) (publicTable := publicTable)
    (tableBackedBy := tableBackedBy)
    (readSessionKey := readSessionKey)
    (pairedSessionKey := pairedSessionKey)
    (validAddressColumns := validAddressColumns)
    (kernelAddressBound := kernelAddressBound)
    (readCheckExpression := readCheckExpression)
    (rwReadCheckExpression := rwReadCheckExpression)
    (writeCheckExpression := writeCheckExpression)
    (valEvaluationExpression := valEvaluationExpression)
    (readOnlyMemoryRelation := readOnlyMemoryRelation)
    (readWriteMemoryRelation := readWriteMemoryRelation)
    (incrementRelation := incrementRelation) (W := W) (Z := Z)
    (Commitment := Commitment) (rootCtx := rootCtx) (rom := rom) (σ := σ)
    (init := init) := by
  have hFrameBound :
      StepComposition.ExecutionFrameBound rom σ frame.frame :=
    AuthenticatedTrace.executionFrameBound_of_exactFrameEvidence frame
  have hMicro :
      StepComposition.MicrostepCorrect rom σ frame.frame.dec frame.frame.pre
        frame.frame.post := hFrameBound.2.2
  classical
  let hDigestExists :=
    StagedExecutionDigest.stagedExecutionDigest_of_exactEvidence
      (inputs := inputs) (rootCtx := rootCtx) (h := frame.exactEvidence) hMicro
  let digest := Classical.choose hDigestExists
  let hDigest := Classical.choose_spec hDigestExists
  exact
    { frame := frame
      digest := digest
      bound := hDigest }

noncomputable def frameDigestEntries_of_frames :
  ExactFramesT →
    List (FrameDigestEntry (pcs := pcs) (inputs := inputs)
      (evalBase := evalBase) (B := B) (publicTable := publicTable)
      (tableBackedBy := tableBackedBy)
      (readSessionKey := readSessionKey)
      (pairedSessionKey := pairedSessionKey)
      (validAddressColumns := validAddressColumns)
      (kernelAddressBound := kernelAddressBound)
      (readCheckExpression := readCheckExpression)
      (rwReadCheckExpression := rwReadCheckExpression)
      (writeCheckExpression := writeCheckExpression)
      (valEvaluationExpression := valEvaluationExpression)
      (readOnlyMemoryRelation := readOnlyMemoryRelation)
      (readWriteMemoryRelation := readWriteMemoryRelation)
      (incrementRelation := incrementRelation) (W := W) (Z := Z)
      (Commitment := Commitment) (rootCtx := rootCtx) (rom := rom) (σ := σ)
      (init := init))
  | [] => []
  | frame :: frames =>
      frameDigestEntry_of_exactFrame frame ::
      frameDigestEntries_of_frames frames

theorem frame_of_frameDigestEntry_of_exactFrame
  (frame : ExactFrameT) :
  (@frameDigestEntry_of_exactFrame AuxIndex EvalPoint AddressPoint CyclePoint
      AddressColumns Addr Table ValSurface Increment SessionKey DigestRom
      DigestSchedule RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B
      publicTable tableBackedBy readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound readCheckExpression
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readOnlyMemoryRelation readWriteMemoryRelation incrementRelation W Z
      Commitment rootCtx rom σ init frame).frame = frame := by
  simp [frameDigestEntry_of_exactFrame]

theorem frameDigestEntries_frames :
  ∀ frames : ExactFramesT,
    (@frameDigestEntries_of_frames AuxIndex EvalPoint AddressPoint CyclePoint
        AddressColumns Addr Table ValSurface Increment SessionKey DigestRom
        DigestSchedule RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B
        publicTable tableBackedBy readSessionKey pairedSessionKey
        validAddressColumns kernelAddressBound readCheckExpression
        rwReadCheckExpression writeCheckExpression valEvaluationExpression
        readOnlyMemoryRelation readWriteMemoryRelation incrementRelation W Z
        Commitment rootCtx rom σ init frames).map
      FrameDigestEntry.frame = frames
  | [] => by rfl
  | frame :: frames => by
      simp [frameDigestEntries_of_frames, frame_of_frameDigestEntry_of_exactFrame,
        frameDigestEntries_frames frames]

noncomputable def stagedExecutionDigestBundle_of_frames
  {frames : ExactFramesT}
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (AuthenticatedTrace.traceOf frames)) :
  @DigestBundle AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns
    Addr Table ValSurface Increment SessionKey DigestRom DigestSchedule
    RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B publicTable
    tableBackedBy readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound readCheckExpression rwReadCheckExpression
    writeCheckExpression valEvaluationExpression readOnlyMemoryRelation
    readWriteMemoryRelation incrementRelation W Z Commitment rootCtx rom σ init
    frames := by
  cases hFrames : frames with
  | nil =>
      subst hFrames
      exfalso
      have hNonempty := ChunkInput.trace_nonempty_of_simpleKernelChunkInput hChunk
      simpa [AuthenticatedTrace.traceOf] using hNonempty
  | cons frame rest =>
      subst hFrames
      let headEntry :=
        @frameDigestEntry_of_exactFrame AuxIndex EvalPoint AddressPoint
          CyclePoint AddressColumns Addr Table ValSurface Increment
          SessionKey DigestRom DigestSchedule RootParamsId VmSpec
          TranscriptSeed pcs inputs evalBase B publicTable tableBackedBy
          readSessionKey pairedSessionKey validAddressColumns
          kernelAddressBound readCheckExpression rwReadCheckExpression
          writeCheckExpression valEvaluationExpression readOnlyMemoryRelation
          readWriteMemoryRelation incrementRelation W Z Commitment rootCtx rom σ
          init frame
      exact
        ({ publicSurface := ⟨kernelPublicInputsBound_of_digest headEntry.bound⟩
           digests :=
             @frameDigestEntries_of_frames AuxIndex EvalPoint AddressPoint
               CyclePoint AddressColumns Addr Table ValSurface Increment
               SessionKey DigestRom DigestSchedule RootParamsId VmSpec
               TranscriptSeed pcs inputs evalBase B publicTable
               tableBackedBy readSessionKey pairedSessionKey
               validAddressColumns kernelAddressBound readCheckExpression
               rwReadCheckExpression writeCheckExpression
               valEvaluationExpression readOnlyMemoryRelation
               readWriteMemoryRelation incrementRelation W Z Commitment
               rootCtx rom σ init (frame :: rest)
           ordered := frameDigestEntries_frames (frame :: rest) } :
          @DigestBundle AuxIndex EvalPoint AddressPoint CyclePoint
            AddressColumns Addr Table ValSurface Increment SessionKey
            DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed pcs
            inputs evalBase B publicTable tableBackedBy readSessionKey
            pairedSessionKey validAddressColumns kernelAddressBound
            readCheckExpression rwReadCheckExpression writeCheckExpression
            valEvaluationExpression readOnlyMemoryRelation
            readWriteMemoryRelation incrementRelation W Z Commitment rootCtx rom
            σ init
            (frame :: rest))

theorem bundleLength_eq
  {frames : ExactFramesT}
  (bundle :
    @DigestBundle AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns
      Addr Table ValSurface Increment SessionKey DigestRom DigestSchedule
      RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B publicTable
      tableBackedBy readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound readCheckExpression rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readOnlyMemoryRelation
      readWriteMemoryRelation incrementRelation W Z Commitment rootCtx rom σ init
      frames) :
  bundle.length = frames.length := by
  have hLen := congrArg List.length bundle.ordered
  simpa [DigestBundle.length] using hLen

theorem bundleLength_eq_semanticRows
  {frames : ExactFramesT}
  (bundle :
    @DigestBundle AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns
      Addr Table ValSurface Increment SessionKey DigestRom DigestSchedule
      RootParamsId VmSpec TranscriptSeed pcs inputs evalBase B publicTable
      tableBackedBy readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound readCheckExpression rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readOnlyMemoryRelation
      readWriteMemoryRelation incrementRelation W Z Commitment rootCtx rom σ init
      frames)
  (hChunk :
    ChunkInput.SimpleKernelChunkInput init inputs.pubMeta.semanticRows
      (AuthenticatedTrace.traceOf frames)) :
  bundle.length = inputs.pubMeta.semanticRows := by
  calc
    bundle.length = frames.length := bundleLength_eq bundle
    _ = (AuthenticatedTrace.traceOf frames).length := by
      simp [AuthenticatedTrace.traceOf]
    _ = inputs.pubMeta.semanticRows := by
      exact ChunkInput.traceLength_of_simpleKernelChunkInput hChunk

end Bundle

end Nightstream.Chip8.StagedExecutionDigestBundle
