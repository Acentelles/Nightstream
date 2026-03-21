import Nightstream.Chip8.Kernel.RootHandoffContext
import Nightstream.Chip8.Stage2.EvidenceCoverage

/-!
Owns the explicit per-row bridge-binding audit object tying one authenticated
row-binding claim to one exported prepared step. This file also exposes the
separate row-projection witness required by the kernel audit trail. It does not
re-own Stage-1/Stage-2/Stage-3 semantic closure.
-/

namespace Nightstream.Chip8.BridgeBinding

open Nightstream.Chip8
open Nightstream.Chip8.DecodeAddressBinding
open Nightstream.Chip8.EvidenceCoverage
open Nightstream.Chip8.ContinuityBridge
open Nightstream.Chip8.RootHandoffContext

abbrev F := EvidenceCoverage.F
abbrev MachineState := EvidenceCoverage.MachineState
abbrev Program := EvidenceCoverage.Program
abbrev InitialState := EvidenceCoverage.InitialState
abbrev ExternalSchedule := EvidenceCoverage.ExternalSchedule

section Binding

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}
  {W Z Commitment : Type*}

structure BridgeBindingWitness
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (stepIdx : Nat)
  (z : Nightstream.Chip8.Witness F)
  (rowClaim : RowBindingClaim F Unit)
  (preparedStep : PreparedStep W Z Commitment F) where
  acceptedRowOpening : ExactOpeningBoundary.AcceptedDirectOpening F Unit
  acceptedRowOpeningClaim : acceptedRowOpening.claim = rowClaim.openingClaim
  rowClaimIndex : rowClaim.rowIndex = stepIdx
  rowBinding : RowBound rowClaim z
  prepared : PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z preparedStep

structure ProjectedRowPath
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (stepIdx : Nat)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (rowClaim : RowBindingClaim F Unit) where
  acceptedRowOpening : ExactOpeningBoundary.AcceptedDirectOpening F Unit
  acceptedRowOpeningClaim : acceptedRowOpening.claim = rowClaim.openingClaim
  row : RowView
  rowProjection :
    RowProjection (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B Γ₁
      row
  rowConsistent : RowConsistent row z dec pre post stepIdx
  rowClaimIndex : rowClaim.rowIndex = stepIdx
  rowBinding : RowBound rowClaim z

structure BridgeBindingBundle
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (stepIdx : Nat)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F)
  (rootCtx : RootHandoffContext RootParamsId W Z Commitment F)
  (preparedStep : PreparedStep W Z Commitment F) where
  rowClaim : RowBindingClaim F Unit
  projectionPath :
    ProjectedRowPath (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B Γ₁
      stepIdx pre post dec z rowClaim
  bridge :
    BridgeBindingWitness rootCtx stepIdx z rowClaim preparedStep
  sameAcceptedRowOpening :
    projectionPath.acceptedRowOpening = bridge.acceptedRowOpening

theorem rowBound_of_bridgeBinding
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {stepIdx : Nat}
  {z : Nightstream.Chip8.Witness F}
  {rowClaim : RowBindingClaim F Unit}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    BridgeBindingWitness rootCtx stepIdx z rowClaim preparedStep) :
  RowBound rowClaim z :=
  h.rowBinding

theorem preparedStepBound_of_bridgeBinding
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {stepIdx : Nat}
  {z : Nightstream.Chip8.Witness F}
  {rowClaim : RowBindingClaim F Unit}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    BridgeBindingWitness rootCtx stepIdx z rowClaim preparedStep) :
  PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z preparedStep :=
  h.prepared

theorem rowBound_of_projectedRowPath
  {pcs : PCSContext AuxIndex EvalPoint}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rowClaim : RowBindingClaim F Unit}
  (h :
    ProjectedRowPath (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B
      Γ₁ stepIdx pre post dec z rowClaim) :
  RowBound rowClaim z :=
  h.rowBinding

theorem rowProjectionWitness_of_projectedRowPath
  {pcs : PCSContext AuxIndex EvalPoint}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rowClaim : RowBindingClaim F Unit}
  (h :
    ProjectedRowPath (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B
      Γ₁ stepIdx pre post dec z rowClaim) :
  RowProjectionWitness pcs evalBase B Γ₁ h.row := by
  exact ⟨h.rowProjection⟩

theorem rowBound_of_bridgeBindingBundle
  {pcs : PCSContext AuxIndex EvalPoint}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    BridgeBindingBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B
      Γ₁ stepIdx pre post dec z rootCtx preparedStep) :
  RowBound h.rowClaim z :=
  rowBound_of_projectedRowPath h.projectionPath

theorem rowProjectionWitness_of_bridgeBindingBundle
  {pcs : PCSContext AuxIndex EvalPoint}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    BridgeBindingBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B
      Γ₁ stepIdx pre post dec z rootCtx preparedStep) :
  RowProjectionWitness pcs evalBase B Γ₁ h.projectionPath.row := by
  exact rowProjectionWitness_of_projectedRowPath h.projectionPath

theorem preparedStepBound_of_bridgeBindingBundle
  {pcs : PCSContext AuxIndex EvalPoint}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {stepIdx : Nat}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    BridgeBindingBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B
      Γ₁ stepIdx pre post dec z rootCtx preparedStep) :
  PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z preparedStep :=
  preparedStepBound_of_bridgeBinding h.bridge

theorem exists_rowProjection_of_semanticEvidence
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
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  ∃ row, RowProjectionWitness pcs evalBase B Γ₁ row := by
  rcases h with ⟨ev⟩
  exact ⟨ev.row, ev.rowProjection⟩

theorem exists_rowProjection_of_exactEvidence
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
      incrementRelation rom σ stepIdx init pre post dec z) :
  ∃ Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F),
    ∃ row, RowProjectionWitness pcs evalBase B Γ₁ row := by
  rcases h with ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  rcases exists_rowProjection_of_semanticEvidence (Γ₁ := Γ₁) (Γ₂ := Γ₂)
      (Γ₃ := Γ₃) hSem with ⟨row, hProjection⟩
  exact ⟨Γ₁, row, hProjection⟩

theorem exists_bridgeBindingWitness_of_semanticEvidence
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
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z)
  (hPrepared :
    PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z preparedStep) :
  ∃ rowClaim,
    Nonempty (BridgeBindingWitness rootCtx stepIdx z rowClaim preparedStep) := by
  rcases h with ⟨ev⟩
  refine ⟨ev.continuity.rowClaim, ?_⟩
  exact ⟨{
    acceptedRowOpening := ev.acceptedRowOpening
    acceptedRowOpeningClaim := ev.acceptedRowOpeningClaim
    rowClaimIndex := ev.continuity.rowClaimIndex
    rowBinding := ev.continuity.rowBinding
    prepared := hPrepared
  }⟩

theorem exists_bridgeBindingWitness_of_exactEvidence
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
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z)
  (hPrepared :
    PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z preparedStep) :
  ∃ rowClaim,
    Nonempty (BridgeBindingWitness rootCtx stepIdx z rowClaim preparedStep) := by
  rcases h with ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact exists_bridgeBindingWitness_of_semanticEvidence
    (Γ₁ := Γ₁) (Γ₂ := Γ₂) (Γ₃ := Γ₃) (rootCtx := rootCtx) hSem hPrepared

theorem exists_bridgeBindingBundle_of_semanticEvidence
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
  {Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {rom : Program}
  {σ : ExternalSchedule}
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z)
  (hPrepared :
    PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z preparedStep) :
  Nonempty (
    BridgeBindingBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B
      Γ₁ stepIdx pre post dec z rootCtx preparedStep) := by
  rcases h with ⟨ev⟩
  rcases ev.rowProjection with ⟨rowProjection⟩
  exact ⟨{
    rowClaim := ev.continuity.rowClaim
    projectionPath := {
      acceptedRowOpening := ev.acceptedRowOpening
      acceptedRowOpeningClaim := ev.acceptedRowOpeningClaim
      row := ev.row
      rowProjection := rowProjection
      rowConsistent := ev.rowConsistent
      rowClaimIndex := ev.continuity.rowClaimIndex
      rowBinding := ev.continuity.rowBinding
    }
    bridge := {
      acceptedRowOpening := ev.acceptedRowOpening
      acceptedRowOpeningClaim := ev.acceptedRowOpeningClaim
      rowClaimIndex := ev.continuity.rowClaimIndex
      rowBinding := ev.continuity.rowBinding
      prepared := hPrepared
    }
    sameAcceptedRowOpening := rfl
  }⟩

theorem exists_bridgeBindingBundle_of_exactEvidence
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
  {stepIdx : Nat}
  {init : InitialState}
  {pre post : MachineState}
  {dec : DecodedStep Addr}
  {z : Nightstream.Chip8.Witness F}
  {rootCtx : RootHandoffContext RootParamsId W Z Commitment F}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z)
  (hPrepared :
    PreparedStepBound rootCtx.rootEncode rootCtx.ajtaiCommit z preparedStep) :
  ∃ Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F),
    Nonempty (
      BridgeBindingBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
        (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase
        B Γ₁ stepIdx pre post dec z rootCtx preparedStep) := by
  rcases h with ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  rcases exists_bridgeBindingBundle_of_semanticEvidence
      (Γ₁ := Γ₁) (Γ₂ := Γ₂) (Γ₃ := Γ₃) (rootCtx := rootCtx) hSem hPrepared with
    ⟨bundle⟩
  exact ⟨Γ₁, ⟨bundle⟩⟩

end Binding

end Nightstream.Chip8.BridgeBinding
