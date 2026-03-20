import Nightstream.Chip8.Execution.StepComposition
import Nightstream.Chip8.Stage3.ContinuityBridge
import Nightstream.Chip8.Kernel.OpeningBoundary
import Nightstream.Chip8.Execution.RomScheduleBindingStepComposition
import Nightstream.PCSOpeningSemantics

namespace Nightstream.Chip8.EvidenceCoverage

open Nightstream.Chip8
open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.DecodeAddressBinding
open Nightstream.Chip8.WitnessMemoryBinding
open Nightstream.Chip8.StepComposition
open Nightstream.Chip8.ContinuityBridge
open Nightstream.Chip8.RomScheduleBinding
open Nightstream.PCSOpeningSemantics
open SuperNeo.ProofSystem

abbrev F := StepComposition.F
abbrev Program := FetchDecodeBinding.Program
abbrev MachineState := StepComposition.MachineState
abbrev InitialState := StepComposition.InitialState
abbrev ExternalSchedule := StepComposition.ExternalSchedule

private def flag1 (t : FlagTuple F) : F := t.1
private def flag2 (t : FlagTuple F) : F := t.2.1
private def flag3 (t : FlagTuple F) : F := t.2.2.1
private def flag4 (t : FlagTuple F) : F := t.2.2.2.1
private def flag5 (t : FlagTuple F) : F := t.2.2.2.2.1
private def flag6 (t : FlagTuple F) : F := t.2.2.2.2.2.1
private def flag7 (t : FlagTuple F) : F := t.2.2.2.2.2.2

section Evidence

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}

structure PCSContext (AuxIndex EvalPoint : Type*) where
  params : AjtaiParams
  extract :
    Commitment → Opening → BaseFamily Nat AuxIndex → EvalPoint → F

def rawScalarClaim
  (family : BaseFamily Nat AuxIndex)
  (point : EvalPoint)
  (value : F) :
  RawScalarClaim (BaseFamily Nat AuxIndex) EvalPoint :=
  ⟨family, point, value⟩

structure ExecutionInputContext
  (DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type*) where
  hashProgram : Program → DigestRom
  hashSchedule : ExternalSchedule → DigestSchedule
  scheduleLength : ExternalSchedule → Nat
  romHash : PublicDigest DigestRom
  scheduleHash : PublicDigest DigestSchedule
  publishedLength : Nat
  publicInput : KernelPublicInput VmSpec TranscriptSeed
  pubMeta : KernelMeta DigestRom RootParamsId
  hashInitialState : InitialState → DigestRom
  programWordCountOf : Program → Nat
  programBaseAddrOf : Program → Nat
  padPcWordOf : Program → Nat
  paddedTraceLengthOf : Nat → Nat
  twoPow : Nat → Nat
  rootParamsOf : VmSpec → RootParamsId

def RomEvidence
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rom : Program) : Prop :=
  AuthenticatedRom inputs.hashProgram inputs.romHash rom

def ScheduleEvidence
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (_pre _post : MachineState)
  (_dec : DecodedStep Addr) : Prop :=
  AuthenticatedStepSchedule inputs.hashSchedule inputs.scheduleLength
    inputs.scheduleHash inputs.publishedLength σ stepIdx

def KernelInputEvidence
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (rom : Program)
  (init : InitialState) : Prop :=
  AuthenticatedProgramImage inputs.publicInput rom ∧
    AuthenticatedInitialState inputs.publicInput init ∧
    @AuthenticatedKernelMeta DigestRom RootParamsId VmSpec TranscriptSeed
      inputs.hashProgram inputs.hashInitialState inputs.programWordCountOf
      inputs.programBaseAddrOf inputs.padPcWordOf inputs.paddedTraceLengthOf
      inputs.twoPow inputs.rootParamsOf inputs.publicInput inputs.pubMeta

structure DirectValueWitness
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (family : BaseFamily Nat AuxIndex)
  (point : EvalPoint)
  (value : F) where
  claim : Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F
  mem : claim ∈ Γ₁
  sound :
    claim.kind = .direct family ∧
      claim.point = .eval point ∧
      family ∈ B ∧
      claim.value = value ∧
      claim.value = evalBase family point
  refinement :
    OpeningRefinement pcs.params pcs.extract
      (rawScalarClaim (AuxIndex := AuxIndex) family point value)

theorem DirectValueWitness.checked
  {pcs : PCSContext AuxIndex EvalPoint}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {family : BaseFamily Nat AuxIndex}
  {point : EvalPoint}
  {value : F}
  (w :
    DirectValueWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B Γ₁
      family point value) :
  DirectClaim evalBase B w.claim := by
  rcases w.sound with ⟨hKind, hPoint, hFam, _, hEval⟩
  exact ⟨family, point, hKind, hPoint, hFam, hEval⟩

theorem DirectValueWitness.rawOpeningSeparation
  {pcs : PCSContext AuxIndex EvalPoint}
  {evalBase : BaseFamily Nat AuxIndex → EvalPoint → F}
  {B : Set (BaseFamily Nat AuxIndex)}
  {Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {family : BaseFamily Nat AuxIndex}
  {point : EvalPoint}
  {value : F}
  (w :
    DirectValueWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B Γ₁
      family point value) :
  RawOpeningSeparation pcs.params pcs.extract
    (rawScalarClaim (AuxIndex := AuxIndex) family point value) := by
  exact rawOpeningSeparation_of_refinement w.refinement

structure RowView where
  pc : F
  pcNext : F
  vx : F
  vy : F
  vxNext : F
  iReg : F
  iNext : F
  kk : F
  nnnAddr : F
  nnnWord : F
  memValue : F
  lookupOut : F
  flags : FlagTuple F
  xIdx : F
  yIdx : F
  burstLast : F
  ramAddr : F

structure RowProjection
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (ρ : RowView) where
  point : EvalPoint
  pc : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 1) point ρ.pc
  pcNext : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 2) point ρ.pcNext
  vx : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 3) point ρ.vx
  vy : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 4) point ρ.vy
  vxNext : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 5) point ρ.vxNext
  iReg : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 6) point ρ.iReg
  iNext : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 7) point ρ.iNext
  kk : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 8) point ρ.kk
  nnnAddr : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 9) point ρ.nnnAddr
  nnnWord : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 10) point ρ.nnnWord
  memValue : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 11) point ρ.memValue
  lookupOut : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 12) point ρ.lookupOut
  flagLookup : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 13) point (flag1 ρ.flags)
  flagMem : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 14) point (flag2 ρ.flags)
  flagPreserve : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 15) point (flag3 ρ.flags)
  flagWriteI : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 16) point (flag4 ρ.flags)
  flagJump : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 17) point (flag5 ρ.flags)
  flagBranch : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 18) point (flag6 ρ.flags)
  flagMemOp : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 19) point (flag7 ρ.flags)
  xIdx : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 20) point ρ.xIdx
  yIdx : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 21) point ρ.yIdx
  burstLast : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 22) point ρ.burstLast
  ramAddr : DirectValueWitness pcs evalBase B Γ₁ (.coreCol 23) point ρ.ramAddr

def RowProjectionWitness
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (ρ : RowView) : Prop :=
  Nonempty (RowProjection (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B Γ₁ ρ)

structure RowConsistency
  {Addr : Type*}
  (ρ : RowView)
  (z : Nightstream.Chip8.Witness F)
  (dec : DecodedStep Addr)
  (pre post : MachineState)
  (stepIdx : Nat) where
  pc_eq : ρ.pc = z 1
  pcNext_eq : ρ.pcNext = z 2
  vx_eq : ρ.vx = z 3
  vy_eq : ρ.vy = z 4
  vxNext_eq : ρ.vxNext = z 5
  iReg_eq : ρ.iReg = z 6
  iNext_eq : ρ.iNext = z 7
  kk_eq : ρ.kk = z 8
  nnnAddr_eq : ρ.nnnAddr = z 9
  nnnWord_eq : ρ.nnnWord = z 10
  memValue_eq : ρ.memValue = z 11
  lookupOut_eq : ρ.lookupOut = z 12
  flags_eq : ρ.flags = Nightstream.Chip8.flags z
  xIdx_eq : ρ.xIdx = z 20
  yIdx_eq : ρ.yIdx = z 21
  burstLast_eq : ρ.burstLast = z 22
  ramAddr_eq : ρ.ramAddr = z 23
  pc_sem : ρ.pc = (pre.pc : F)
  pcNext_sem : ρ.pcNext = (post.pc : F)
  vx_sem : ρ.vx = (WitnessMemoryBinding.primaryValue pre dec : F)
  vy_sem : ρ.vy = (WitnessMemoryBinding.secondaryValue pre dec : F)
  vxNext_sem : ρ.vxNext = (WitnessMemoryBinding.primaryValue post dec : F)
  iReg_sem : ρ.iReg = (pre.i : F)
  iNext_sem : ρ.iNext = (post.i : F)
  kk_sem : ρ.kk = (dec.kk : F)
  nnnAddr_sem : ρ.nnnAddr = (dec.nnn : F)
  nnnWord_sem : ρ.nnnWord = (dec.nnnWord : F)
  memValue_sem : ρ.memValue = (WitnessMemoryBinding.memValueOf pre post dec : F)
  flags_sem : ρ.flags = Nightstream.Chip8.behaviorFlags (K := F) dec.behavior
  xIdx_sem : ρ.xIdx = (activeXIndex dec : F)
  yIdx_sem : ρ.yIdx = (WitnessMemoryBinding.yIndexOf dec : F)
  burstLast_sem : ρ.burstLast = (WitnessMemoryBinding.burstLastValue dec : F)
  ramAddr_sem : ρ.ramAddr = (WitnessMemoryBinding.ramAddrValue pre dec : F)
  step_index_eq : stepIdx = dec.microIndex

def RowConsistent
  {Addr : Type*}
  (ρ : RowView)
  (z : Nightstream.Chip8.Witness F)
  (dec : DecodedStep Addr)
  (pre post : MachineState)
  (stepIdx : Nat) : Prop :=
  Nonempty (RowConsistency ρ z dec pre post stepIdx)

theorem witnessBinds_of_rowConsistent
  {Addr : Type*}
  {ρ : RowView}
  {z : Nightstream.Chip8.Witness F}
  {dec : DecodedStep Addr}
  {pre post : MachineState}
  {stepIdx : Nat}
  (h : RowConsistent ρ z dec pre post stepIdx) :
  WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z := by
  rcases h with ⟨rc⟩
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simpa [rc.pc_eq] using rc.pc_sem
  · simpa [rc.pcNext_eq] using rc.pcNext_sem
  · simpa [rc.vx_eq] using rc.vx_sem
  · simpa [rc.vy_eq] using rc.vy_sem
  · simpa [rc.vxNext_eq] using rc.vxNext_sem
  · simpa [rc.iReg_eq] using rc.iReg_sem
  · simpa [rc.iNext_eq] using rc.iNext_sem
  · simpa [rc.kk_eq] using rc.kk_sem
  · simpa [rc.nnnAddr_eq] using rc.nnnAddr_sem
  · simpa [rc.nnnWord_eq] using rc.nnnWord_sem
  · simpa [rc.xIdx_eq] using rc.xIdx_sem
  · simpa [rc.yIdx_eq] using rc.yIdx_sem
  · simpa [rc.burstLast_eq] using rc.burstLast_sem
  · simpa [rc.ramAddr_eq] using rc.ramAddr_sem
  · calc
      Nightstream.Chip8.flags z = ρ.flags := by simp [rc.flags_eq]
      _ = Nightstream.Chip8.behaviorFlags (K := F) dec.behavior := rc.flags_sem

theorem localMemoryBound_of_rowConsistent
  {Addr : Type*}
  {ρ : RowView}
  {z : Nightstream.Chip8.Witness F}
  {dec : DecodedStep Addr}
  {pre post : MachineState}
  {stepIdx : Nat}
  (h : RowConsistent ρ z dec pre post stepIdx) :
  WitnessMemoryBinding.LocalMemoryBound (K := F) pre post dec z := by
  rcases h with ⟨rc⟩
  have hRow : RowConsistent ρ z dec pre post stepIdx := ⟨rc⟩
  refine ⟨witnessBinds_of_rowConsistent hRow, ?_, ?_⟩
  · simpa [WitnessMemoryBinding.MemValueBound, rc.memValue_eq] using rc.memValue_sem
  · refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
    · simpa [rc.vx_eq] using rc.vx_sem
    · simpa [rc.vy_eq] using rc.vy_sem
    · simpa [rc.iReg_eq] using rc.iReg_sem
    · calc
        (((dec.writesLookupToX + dec.writesMemToX : Nat) : F) * z 5 +
            (dec.writesNnnToI : F) * z 7)
            = (((dec.writesLookupToX + dec.writesMemToX : Nat) : F) *
                (WitnessMemoryBinding.primaryValue post dec : F) +
                (dec.writesNnnToI : F) * (post.i : F)) := by
                  rw [← rc.vxNext_eq, ← rc.iNext_eq, rc.vxNext_sem, rc.iNext_sem]
        _ = (WitnessMemoryBinding.registerWriteClaimValue post dec : F) := by
              simp [WitnessMemoryBinding.registerWriteClaimValue, Nat.cast_add, Nat.cast_mul]
    · calc
        (dec.readsRam : F) * z 11
            = (dec.readsRam : F) * (WitnessMemoryBinding.memValueOf pre post dec : F) := by
                rw [← rc.memValue_eq, rc.memValue_sem]
        _ = (WitnessMemoryBinding.ramReadClaimValue pre post dec : F) := by
              simp [WitnessMemoryBinding.ramReadClaimValue, Nat.cast_mul]
    · calc
        (dec.writesRam : F) * z 11
            = (dec.writesRam : F) * (WitnessMemoryBinding.memValueOf pre post dec : F) := by
                rw [← rc.memValue_eq, rc.memValue_sem]
        _ = (WitnessMemoryBinding.ramWriteClaimValue pre post dec : F) := by
              simp [WitnessMemoryBinding.ramWriteClaimValue, Nat.cast_mul]

def TableProvenance
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (B : Set (BaseFamily Nat AuxIndex))
  (table : Table) : Prop :=
  publicTable table → ∃ b, tableBackedBy table b ∧ b ∈ B

structure ShoutClaimWitness
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop) where
  claim : Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F
  table : Table
  ra : AddressColumns
  addr : Addr
  rv : Nat
  point : EvalPoint
  sound :
    claim.kind = .shoutRead ∧
      claim.point = .eval point ∧
      claim.value = readCheckExpression ra table point ∧
      validAddressColumns ra addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      readOnlyMemoryRelation table addr rv

theorem ShoutClaimWitness.checked
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → F}
  {readOnlyMemoryRelation : Table → Addr → Nat → Prop}
  (w : ShoutClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr) (Table := Table)
    validAddressColumns kernelAddressBound readCheckExpression readOnlyMemoryRelation) :
  ShoutCheckedClaim validAddressColumns kernelAddressBound readCheckExpression
    readOnlyMemoryRelation w.claim := by
  rcases w.sound with ⟨hKind, hPoint, hValue, hValid, hBound, hRead⟩
  exact ⟨w.table, w.ra, w.addr, w.rv, w.point, hKind, hPoint, hValue, hValid, hBound, hRead⟩

structure TwistReadClaimWitness
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop) where
  claim : Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F
  val : ValSurface
  ra : AddressColumns
  addr : Addr
  rv : Nat
  point : EvalPoint
  sound :
    claim.kind = .twistRead ∧
      claim.point = .eval point ∧
      claim.value = rwReadCheckExpression ra val point ∧
      validAddressColumns ra addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      readWriteMemoryRelation val addr rv

theorem TwistReadClaimWitness.checked
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  (w : TwistReadClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
    validAddressColumns kernelAddressBound rwReadCheckExpression readWriteMemoryRelation) :
  TwistReadCheckedClaim validAddressColumns kernelAddressBound rwReadCheckExpression
    readWriteMemoryRelation w.claim := by
  rcases w.sound with ⟨hKind, hPoint, hValue, hValid, hBound, hRead⟩
  exact ⟨w.val, w.ra, w.addr, w.rv, w.point, hKind, hPoint, hValue, hValid, hBound, hRead⟩

structure TwistWriteClaimWitness
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop) where
  claim : Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F
  val : ValSurface
  wa : AddressColumns
  addr : Addr
  wv : Nat
  inc : Increment
  qa : AddressPoint
  qc : CyclePoint
  sound :
    claim.kind = .twistWrite ∧
      claim.point = .paired qa qc ∧
      claim.value = writeCheckExpression qa qc wa wv val ∧
      validAddressColumns wa addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      incrementRelation val wa wv inc

theorem TwistWriteClaimWitness.checked
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  (w : TwistWriteClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
    (Increment := Increment)
    validAddressColumns kernelAddressBound writeCheckExpression incrementRelation) :
  TwistWriteCheckedClaim validAddressColumns kernelAddressBound writeCheckExpression
    incrementRelation w.claim := by
  rcases w.sound with ⟨hKind, hPoint, hValue, hValid, hBound, hInc⟩
  exact ⟨w.val, w.wa, w.addr, w.wv, w.inc, w.qa, w.qc, hKind, hPoint, hValue, hValid, hBound, hInc⟩

structure TwistValClaimWitness
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop) where
  claim : Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F
  val : ValSurface
  wa : AddressColumns
  addr : Addr
  wv : Nat
  inc : Increment
  qa : AddressPoint
  qc : CyclePoint
  sound :
    claim.kind = .twistVal ∧
      claim.point = .paired qa qc ∧
      claim.value = valEvaluationExpression inc qa qc ∧
      validAddressColumns wa addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      incrementRelation val wa wv inc

theorem TwistValClaimWitness.checked
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  (w : TwistValClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
    (Increment := Increment)
    validAddressColumns kernelAddressBound valEvaluationExpression incrementRelation) :
  TwistValCheckedClaim validAddressColumns kernelAddressBound valEvaluationExpression
    incrementRelation w.claim := by
  rcases w.sound with ⟨hKind, hPoint, hValue, hValid, hBound, hInc⟩
  exact ⟨w.val, w.wa, w.addr, w.wv, w.inc, w.qa, w.qc, hKind, hPoint, hValue, hValid, hBound, hInc⟩

def AddressProvenanceAt
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (stepIdx : Nat)
  (role : AddressRole)
  (addr : Addr) : Prop :=
  stepIdx = dec.microIndex ∧ KernelAddressBoundAt dec role addr

def AddressProvenance
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (stepIdx : Nat)
  (addr : Addr) : Prop :=
  ∃ role, AddressProvenanceAt dec stepIdx role addr

theorem addressProvenance_of_at
  {Addr : Type*}
  {dec : DecodedStep Addr}
  {stepIdx : Nat}
  {role : AddressRole}
  {addr : Addr}
  (h : AddressProvenanceAt dec stepIdx role addr) :
  AddressProvenance dec stepIdx addr := by
  exact ⟨role, h⟩

def VirtualValProvenance
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (key : SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (read :
    TwistReadClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      validAddressColumns kernelAddressBound rwReadCheckExpression
      readWriteMemoryRelation)
  (write :
    TwistWriteClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment)
      validAddressColumns kernelAddressBound writeCheckExpression incrementRelation)
  (valClaim :
    TwistValClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment)
      validAddressColumns kernelAddressBound valEvaluationExpression incrementRelation) :
  Prop :=
  readSessionKey read.point = key ∧
    pairedSessionKey write.qa write.qc = key ∧
    pairedSessionKey valClaim.qa valClaim.qc = key ∧
    read.val = write.val ∧
    write.val = valClaim.val

structure TwistSessionWitness
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop) where
  key : SessionKey
  read :
    TwistReadClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      validAddressColumns kernelAddressBound rwReadCheckExpression
      readWriteMemoryRelation
  write :
    TwistWriteClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment)
      validAddressColumns kernelAddressBound writeCheckExpression incrementRelation
  valClaim :
    TwistValClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment)
      validAddressColumns kernelAddressBound valEvaluationExpression incrementRelation
  provenance :
    VirtualValProvenance (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey key validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation read write valClaim

structure TwistSessionRegistry
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop) where
  sessions :
    List (TwistSessionWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation)

def TwistSessionMembersInClaims
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  ∀ session ∈ registry.sessions,
    session.read.claim ∈ Γ₃ ∧
      session.write.claim ∈ Γ₃ ∧
      session.valClaim.claim ∈ Γ₃

def TwistSessionReadTotal
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  ∀ c, c ∈ Γ₃ →
    TwistReadCheckedClaim validAddressColumns kernelAddressBound
      rwReadCheckExpression readWriteMemoryRelation c →
    ∃ session ∈ registry.sessions, session.read.claim = c

def TwistSessionWriteTotal
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  ∀ c, c ∈ Γ₃ →
    TwistWriteCheckedClaim validAddressColumns kernelAddressBound
      writeCheckExpression incrementRelation c →
    ∃ session ∈ registry.sessions, session.write.claim = c

def TwistSessionValTotal
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  ∀ c, c ∈ Γ₃ →
    TwistValCheckedClaim validAddressColumns kernelAddressBound
      valEvaluationExpression incrementRelation c →
    ∃ session ∈ registry.sessions, session.valClaim.claim = c

def TwistSessionUniqueByKey
  (registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  ∀ s₁ ∈ registry.sessions, ∀ s₂ ∈ registry.sessions,
    s₁.key = s₂.key →
      s₁.read.claim = s₂.read.claim ∧
        s₁.write.claim = s₂.write.claim ∧
        s₁.valClaim.claim = s₂.valClaim.claim

def TwistSessionClosed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  TwistSessionMembersInClaims
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry ∧
    TwistSessionReadTotal
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry ∧
    TwistSessionWriteTotal
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry ∧
    TwistSessionValTotal
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry ∧
    TwistSessionUniqueByKey
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      registry

theorem twistSessionClosed_membersInClaims
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation}
  (h :
    TwistSessionClosed readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      registry) :
  TwistSessionMembersInClaims
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry := by
  exact h.1

theorem twistSessionClosed_readTotal
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation}
  (h :
    TwistSessionClosed readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      registry) :
  TwistSessionReadTotal
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry := by
  exact h.2.1

theorem twistSessionClosed_writeTotal
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation}
  (h :
    TwistSessionClosed readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      registry) :
  TwistSessionWriteTotal
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry := by
  exact h.2.2.1

theorem twistSessionClosed_valTotal
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation}
  (h :
    TwistSessionClosed readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      registry) :
  TwistSessionValTotal
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      Γ₃ registry := by
  exact h.2.2.2.1

theorem twistSessionClosed_uniqueByKey
  {readSessionKey : EvalPoint → SessionKey}
  {pairedSessionKey : AddressPoint → CyclePoint → SessionKey}
  {validAddressColumns : AddressColumns → Addr → Prop}
  {kernelAddressBound : Addr → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → F}
  {readWriteMemoryRelation : ValSurface → Addr → Nat → Prop}
  {incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop}
  {Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F)}
  {registry :
    TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation}
  (h :
    TwistSessionClosed readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      registry) :
  TwistSessionUniqueByKey
      (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      registry := by
  exact h.2.2.2.2

abbrev RegisterTwistSessionRegistry
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop) :=
  TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
    (Increment := Increment) (SessionKey := SessionKey)
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation

abbrev RamTwistSessionRegistry
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop) :=
  TwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
    (Increment := Increment) (SessionKey := SessionKey)
    readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation

abbrev RegisterTwistSessionClosed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (registry :
    RegisterTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  TwistSessionClosed readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃ registry

abbrev RamTwistSessionClosed
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (registry :
    RamTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation) : Prop :=
  TwistSessionClosed readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃ registry

structure FetchDecodeEvidence
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₂ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop)
  (rom : Program)
  (pre : MachineState)
  (dec : DecodedStep Addr)
  (stepIdx : Nat) where
  fetchClaim : ShoutClaimWitness validAddressColumns kernelAddressBound
    readCheckExpression readOnlyMemoryRelation
  fetchIn : fetchClaim.claim ∈ Γ₂
  fetchTableProvenance : TableProvenance publicTable tableBackedBy B fetchClaim.table
  fetchAddrProvenance : AddressProvenanceAt dec stepIdx .fetch fetchClaim.addr
  decodeClaim : ShoutClaimWitness validAddressColumns kernelAddressBound
    readCheckExpression readOnlyMemoryRelation
  decodeIn : decodeClaim.claim ∈ Γ₂
  decodeTableProvenance : TableProvenance publicTable tableBackedBy B decodeClaim.table
  decodeAddrProvenance : AddressProvenanceAt dec stepIdx .decode decodeClaim.addr
  opcode : Nat
  fetched : opcodeAt rom pre.pc = some opcode
  decoded : decodeOpcodeWord opcode = some dec.toDecodedCore

def LookupEvidence
  (Γ₂ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (B : Set (BaseFamily Nat AuxIndex))
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop)
  (pre : MachineState)
  (dec : DecodedStep Addr)
  (stepIdx : Nat)
  (ρ : RowView) : Prop :=
  (∀ _ : UsesLookup dec.opcodeId,
    ∃ witness :
      ShoutClaimWitness (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
        (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
        (AddressColumns := AddressColumns) (Addr := Addr) (Table := Table)
        validAddressColumns kernelAddressBound readCheckExpression
        readOnlyMemoryRelation,
      witness.claim ∈ Γ₂ ∧
        TableProvenance publicTable tableBackedBy B witness.table ∧
        AddressProvenanceAt dec stepIdx .lookup witness.addr) ∧
    ρ.lookupOut = (StepComposition.lookupValueOf pre dec : F)

def MemoryFrameEvidence
  {Addr : Type*}
  (pre post : MachineState)
  (dec : DecodedStep Addr) : Prop :=
  match dec.opcodeId with
  | .ldImm | .addImm | .mov | .addReg =>
      RegistersPreservedExcept pre post dec.x ∧
        RamPreserved pre post
  | .skipEqImm | .jump | .ldI =>
      RegistersPreserved pre post ∧
        RamPreserved pre post
  | .storeRegs =>
      RegistersPreserved pre post ∧
        RamPrefixStored pre post dec ∧
        RamPreservedOutsidePrefix pre post dec
  | .loadRegs =>
      RegistersLoadedPrefix pre post dec ∧
        RegistersPreservedAbove pre post dec.x ∧
        RamPreserved pre post

structure MemoryEvidence
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (pre post : MachineState)
  (z : Nightstream.Chip8.Witness F)
  (dec : DecodedStep Addr)
  (stepIdx : Nat) where
  trace : StepMemoryTrace
  traceMatches : TraceMatches pre post dec trace
  frame : MemoryFrameEvidence pre post dec
  registerPorts : RegisterPortsBound pre post dec
  ramPorts : RamPortsBound pre post dec
  ramRaf : WitnessMemoryBinding.RamRafBound (K := F) pre dec z
  registerRegistry :
    RegisterTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  readXAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaX session.read.addr
  readXValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaX session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadXValue pre dec
  readYAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaY session.read.addr
  readYValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaY session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadYValue pre dec
  readIAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaI session.read.addr
  readIValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regRaI session.read.addr ∧
        session.read.rv = WitnessMemoryBinding.registerReadIValue pre dec
  writeRegAddressCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regWa session.write.addr
  writeRegValueCovered :
    ∃ session ∈ registerRegistry.sessions,
      AddressProvenanceAt dec stepIdx .regWa session.write.addr ∧
        session.write.wv = WitnessMemoryBinding.registerWriteClaimValue post dec
  ramRegistry :
    RamTwistSessionRegistry (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      rwReadCheckExpression writeCheckExpression valEvaluationExpression
      readWriteMemoryRelation incrementRelation
  loadReadAddressCovered :
    dec.opcodeId = .loadRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .readMem session.read.addr
  loadReadValueCovered :
    dec.opcodeId = .loadRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .readMem session.read.addr ∧
          session.read.rv = WitnessMemoryBinding.ramReadClaimValue pre post dec
  storeWriteAddressCovered :
    dec.opcodeId = .storeRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .writeMem session.write.addr
  storeWriteValueCovered :
    dec.opcodeId = .storeRegs →
      ∃ session ∈ ramRegistry.sessions,
        AddressProvenanceAt dec stepIdx .writeMem session.write.addr ∧
          session.write.wv = WitnessMemoryBinding.ramWriteClaimValue pre post dec

def FramebufferEvidence
  {Addr : Type*}
  (_pre _post : MachineState)
  (_dec : DecodedStep Addr) : Prop :=
  True

structure ContinuityEvidence
  (stepIdx : Nat)
  (semanticRows : Nat)
  (z : Nightstream.Chip8.Witness F) where
  N : Nat
  β1 : F
  β2 : F
  shiftClaim : ContinuityBridge.LaneShiftClaim F
  shiftProof : ContinuityBridge.LaneShiftWitness F Unit
  currentRow : ContinuityBridge.ContinuityRow F
  startRow : ContinuityBridge.StartBoundaryRow F
  finalRow : ContinuityBridge.FinalBoundaryRow F
  rowClaim : ContinuityBridge.RowBindingClaim F Unit
  continuity :
    ContinuityBridge.ContinuityBound N β1 β2 shiftClaim shiftProof currentRow
  startBoundary : ContinuityBridge.StartBoundaryBound startRow
  finalBoundary : ContinuityBridge.FinalBoundaryBound finalRow
  semanticRowsEq : N = semanticRows
  startMatches :
    ContinuityBridge.StartBoundaryMatches stepIdx startRow z
  finalMatches :
    ContinuityBridge.FinalBoundaryMatches stepIdx N finalRow z
  currentRowIndex : currentRow.rowIndex = stepIdx
  currentPcNext : currentRow.pcNext = z 2
  currentXIdx : currentRow.xIdx = z 20
  currentIsMemOp : currentRow.isMemOp = z 19
  currentBurstLast : currentRow.burstLast = z 22
  rowClaimIndex : rowClaim.rowIndex = stepIdx
  rowBinding : ContinuityBridge.RowBound rowClaim z

structure SemanticEvidence
  (pcs : PCSContext AuxIndex EvalPoint)
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) where
  row : RowView
  rowProjection : RowProjectionWitness pcs evalBase B Γ₁ row
  rowConsistent : RowConsistent row z dec pre post stepIdx
  routing : Nightstream.Chip8.chip8RoutingConstraints z
  openingPoints : ExactOpeningBoundary.KernelPoints
  kernelManifest : ExactOpeningBoundary.KernelOpeningManifest F Unit
  rootManifest : ExactOpeningBoundary.RootOpeningManifest F Unit
  kernelInputs : KernelInputEvidence inputs rom init
  romBinding : RomEvidence inputs rom
  fetchDecode : FetchDecodeEvidence evalBase B Γ₂ publicTable tableBackedBy
    validAddressColumns kernelAddressBound readCheckExpression
    readOnlyMemoryRelation rom pre dec stepIdx
  lookup : LookupEvidence Γ₂ publicTable tableBackedBy B validAddressColumns
    kernelAddressBound readCheckExpression readOnlyMemoryRelation pre dec
    stepIdx row
  memory : MemoryEvidence readSessionKey pairedSessionKey validAddressColumns
    kernelAddressBound rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
    pre post z dec stepIdx
  continuity : ContinuityEvidence stepIdx inputs.pubMeta.semanticRows z
  boundary :
    ExactOpeningBoundary.ExactKernelOpeningBoundary openingPoints
      kernelManifest rootManifest
  registerTwistClosed :
    RegisterTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation Γ₃ memory.registerRegistry
  ramTwistClosed :
    RamTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr) (ValSurface := ValSurface)
      (Increment := Increment) (SessionKey := SessionKey)
      readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃
      memory.ramRegistry
  initialState : InitialStateBound init
  framebuffer : FramebufferEvidence pre post dec
  schedule : ScheduleEvidence inputs σ stepIdx pre post dec

def SemanticEvidenceCovered
  (pcs : PCSContext AuxIndex EvalPoint)
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (Γ₁ Γ₂ Γ₃ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) : Prop :=
  Nonempty (
    SemanticEvidence pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z)

def ExactSemanticEvidenceCovered
  (pcs : PCSContext AuxIndex EvalPoint)
  (inputs :
    ExecutionInputContext DigestRom DigestSchedule RootParamsId VmSpec
      TranscriptSeed)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (readSessionKey : EvalPoint → SessionKey)
  (pairedSessionKey : AddressPoint → CyclePoint → SessionKey)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → F)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop)
  (readWriteMemoryRelation : ValSurface → Addr → Nat → Prop)
  (incrementRelation : ValSurface → AddressColumns → Nat → Increment → Prop)
  (rom : Program)
  (σ : ExternalSchedule)
  (stepIdx : Nat)
  (init : InitialState)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (z : Nightstream.Chip8.Witness F) : Prop :=
  ∃ Γ₁ Γ₂ Γ₃,
    SemanticEvidenceCovered pcs inputs evalBase B publicTable tableBackedBy
      readSessionKey pairedSessionKey validAddressColumns kernelAddressBound
      readCheckExpression rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
      incrementRelation Γ₁ Γ₂ Γ₃ rom σ stepIdx init pre post dec z

theorem kernelOpeningBoundary_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
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
  ∃ openingPoints : ExactOpeningBoundary.KernelPoints,
    ∃ kernelManifest : ExactOpeningBoundary.KernelOpeningManifest F Unit,
      ∃ rootManifest : ExactOpeningBoundary.RootOpeningManifest F Unit,
    ExactOpeningBoundary.ExactKernelOpeningBoundary openingPoints
      kernelManifest rootManifest := by
  rcases h with ⟨ev⟩
  exact ⟨ev.openingPoints, ev.kernelManifest, ev.rootManifest, ev.boundary⟩

theorem witnessBinds_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
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
  WitnessMemoryBinding.WitnessBinds (K := F) pre post dec z := by
  rcases h with ⟨ev⟩
  exact witnessBinds_of_rowConsistent ev.rowConsistent

theorem routingSound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
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
  Nightstream.Chip8.chip8RoutingSound z := by
  rcases h with ⟨ev⟩
  exact Nightstream.Chip8.chip8RoutingSound_of_constraints ev.routing

theorem fetchDecodeBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
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
  StepComposition.FetchDecodeBound rom pre.pc dec := by
  rcases h with ⟨ev⟩
  exact ⟨ev.fetchDecode.opcode, ev.fetchDecode.fetched, ev.fetchDecode.decoded⟩

theorem lookupBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
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
  StepComposition.LookupBound dec pre z := by
  rcases h with ⟨ev⟩
  rcases ev.rowConsistent with ⟨rc⟩
  rcases ev.lookup with ⟨_, hLookup⟩
  calc
    z 12 = ev.row.lookupOut := by simp [rc.lookupOut_eq]
    _ = (StepComposition.lookupValueOf pre dec : F) := hLookup

theorem memoryBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
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
  StepComposition.MemoryBound pre post init dec z := by
  rcases h with ⟨ev⟩
  exact
    ⟨⟨localMemoryBound_of_rowConsistent ev.rowConsistent, ev.memory.registerPorts,
      ev.memory.ramPorts, ev.memory.ramRaf, ev.initialState⟩, ev.memory.frame⟩

theorem continuityRowBound_of_evidence
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
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → Nat → ValSurface → F}
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
  ∃ N β1 β2 shiftClaim shiftProof currentRow rowClaim,
    StepComposition.ContinuityRowBound stepIdx N β1 β2 shiftClaim
      shiftProof currentRow rowClaim z := by
  rcases h with ⟨ev⟩
  refine ⟨ev.continuity.N, ev.continuity.β1, ev.continuity.β2,
    ev.continuity.shiftClaim, ev.continuity.shiftProof, ev.continuity.currentRow,
    ev.continuity.rowClaim, ?_⟩
  exact ⟨ev.continuity.continuity, ev.continuity.currentRowIndex,
    ev.continuity.currentPcNext, ev.continuity.currentXIdx,
    ev.continuity.currentIsMemOp, ev.continuity.currentBurstLast,
    ev.continuity.rowClaimIndex, ev.continuity.rowBinding⟩

end Evidence

end Nightstream.Chip8.EvidenceCoverage
