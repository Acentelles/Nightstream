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
  (rootEncode : RootEncode W Z F)
  (ajtaiCommit : Z → Commitment)
  (stepIdx : Nat)
  (z : Nightstream.Chip8.Witness F)
  (rowClaim : RowBindingClaim F Unit)
  (preparedStep : PreparedStep W Z Commitment F) where
  rowClaimIndex : rowClaim.rowIndex = stepIdx
  rowBinding : RowBound rowClaim z
  prepared : PreparedStepBound rootEncode ajtaiCommit z preparedStep

theorem rowBound_of_bridgeBinding
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {stepIdx : Nat}
  {z : Nightstream.Chip8.Witness F}
  {rowClaim : RowBindingClaim F Unit}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    BridgeBindingWitness rootEncode ajtaiCommit stepIdx z rowClaim
      preparedStep) :
  RowBound rowClaim z :=
  h.rowBinding

theorem preparedStepBound_of_bridgeBinding
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  {stepIdx : Nat}
  {z : Nightstream.Chip8.Witness F}
  {rowClaim : RowBindingClaim F Unit}
  {preparedStep : PreparedStep W Z Commitment F}
  (h :
    BridgeBindingWitness rootEncode ajtaiCommit stepIdx z rowClaim
      preparedStep) :
  PreparedStepBound rootEncode ajtaiCommit z preparedStep :=
  h.prepared

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  (h :
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z) :
  ∃ rowClaim,
    BridgeBindingWitness rootEncode ajtaiCommit stepIdx z rowClaim
      (mkPreparedStep rootEncode ajtaiCommit z) := by
  rcases h with ⟨ev⟩
  refine ⟨ev.continuity.rowClaim, ?_⟩
  refine
    { rowClaimIndex := ev.continuity.rowClaimIndex
      rowBinding := ev.continuity.rowBinding
      prepared := ?_ }
  exact preparedStepBound_of_rowBinding ev.continuity.rowBinding

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
  {rootEncode : RootEncode W Z F}
  {ajtaiCommit : Z → Commitment}
  (h :
    ExactSemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation rom σ stepIdx init pre post dec z) :
  ∃ rowClaim,
    BridgeBindingWitness rootEncode ajtaiCommit stepIdx z rowClaim
      (mkPreparedStep rootEncode ajtaiCommit z) := by
  rcases h with ⟨Γ₁, Γ₂, Γ₃, hSem⟩
  exact exists_bridgeBindingWitness_of_semanticEvidence
    (Γ₁ := Γ₁) (Γ₂ := Γ₂) (Γ₃ := Γ₃) (rootEncode := rootEncode)
    (ajtaiCommit := ajtaiCommit) hSem

end Binding

end Nightstream.Chip8.BridgeBinding
