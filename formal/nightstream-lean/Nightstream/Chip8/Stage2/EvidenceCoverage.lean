import Nightstream.Chip8.Stage2.EvidenceCoverageCore
import Nightstream.Chip8.Stage3.Stage3Refinement

/-!
Owns the bundled authenticated evidence surface for one CHIP-8 row and the
downstream extraction theorems that recover semantic obligations from that
surface. The low-level direct-witness and session-closure machinery lives in
`EvidenceCoverageCore`.
-/

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

section Evidence

variable
  {AuxIndex EvalPoint AddressPoint CyclePoint AddressColumns Addr Table ValSurface
    Increment SessionKey : Type*}
  {DigestRom DigestSchedule RootParamsId VmSpec TranscriptSeed : Type}

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
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (stepIdx : Nat)
  (semanticRows : Nat)
  (z : Nightstream.Chip8.Witness F) where
  N : Nat
  β1 : F
  β2 : F
  shiftClaim : ContinuityBridge.LaneShiftClaim F
  shiftProof : ContinuityBridge.LaneShiftWitness F Unit
  currentRow : ContinuityBridge.ContinuityRow F
  rawShift : PaddedContinuityCheck.RawShiftValues F
  rawCurrent : PaddedContinuityCheck.RawCurrentValues F
  tailCorrections : PaddedContinuityCheck.TailCorrections F
  currentPoint : EvalPoint
  currentPcNextWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colPcNext) currentPoint
      currentRow.pcNext
  currentXIdxWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colXIdx) currentPoint
      currentRow.xIdx
  currentIsMemOpWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colIsMemOp) currentPoint
      currentRow.isMemOp
  currentBurstLastWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colBurstLast) currentPoint
      currentRow.burstLast
  startRow : ContinuityBridge.StartBoundaryRow F
  startPoint : EvalPoint
  startIsMemOpWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colIsMemOp) startPoint
      startRow.isMemOp
  startXIdxWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colXIdx) startPoint
      startRow.xIdx
  finalRow : ContinuityBridge.FinalBoundaryRow F
  finalPoint : EvalPoint
  finalIsMemOpWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colIsMemOp) finalPoint
      finalRow.isMemOp
  finalBurstLastWitness :
    DirectValueWitness pcs evalBase B Γ₁ (.coreCol colBurstLast) finalPoint
      finalRow.burstLast
  rowClaim : ContinuityBridge.RowBindingClaim F Unit
  paddedCheck :
    PaddedContinuityCheck.PaddedContinuityCheckBound N β1 β2 shiftClaim
      shiftProof currentRow rawShift rawCurrent tailCorrections
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

abbrev Stage3AuthenticatedBundle
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (stepIdx : Nat)
  (semanticRows : Nat)
  (z : Nightstream.Chip8.Witness F) :=
  ContinuityEvidence (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B Γ₁
    stepIdx semanticRows z

def Stage1AuthenticatedBundle
  (pcs : PCSContext AuxIndex EvalPoint)
  (evalBase : BaseFamily Nat AuxIndex → EvalPoint → F)
  (B : Set (BaseFamily Nat AuxIndex))
  (Γ₁ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (Γ₂ : List (Claim Nat AuxIndex EvalPoint AddressPoint CyclePoint F))
  (publicTable : Table → Prop)
  (tableBackedBy : Table → BaseFamily Nat AuxIndex → Prop)
  (validAddressColumns : AddressColumns → Addr → Prop)
  (kernelAddressBound : Addr → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → F)
  (readOnlyMemoryRelation : Table → Addr → Nat → Prop)
  (rom : Program)
  (pre post : MachineState)
  (dec : DecodedStep Addr)
  (stepIdx : Nat)
  (z : Nightstream.Chip8.Witness F) : Prop :=
  ∃ row : RowView,
    RowProjectionWitness pcs evalBase B Γ₁ row ∧
      RowConsistent row z dec pre post stepIdx ∧
      Nonempty (
        FetchDecodeEvidence evalBase B Γ₂ publicTable tableBackedBy
          validAddressColumns kernelAddressBound readCheckExpression
          readOnlyMemoryRelation rom pre dec stepIdx) ∧
      LookupEvidence Γ₂ publicTable tableBackedBy B validAddressColumns
        kernelAddressBound readCheckExpression readOnlyMemoryRelation pre dec
        stepIdx row

def Stage2AuthenticatedBundle
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
  (stepIdx : Nat) : Prop :=
  ∃ memory :
    MemoryEvidence readSessionKey pairedSessionKey validAddressColumns
      kernelAddressBound rwReadCheckExpression writeCheckExpression
      valEvaluationExpression readWriteMemoryRelation incrementRelation Γ₃ pre
      post z dec stepIdx,
    RegisterTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey) readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation Γ₃ memory.registerRegistry ∧
    RamTwistSessionClosed (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
      (AddressColumns := AddressColumns) (Addr := Addr)
      (ValSurface := ValSurface) (Increment := Increment)
      (SessionKey := SessionKey) readSessionKey pairedSessionKey
      validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation Γ₃ memory.ramRegistry

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
  continuity :
    Stage3AuthenticatedBundle pcs evalBase B Γ₁ stepIdx
      inputs.pubMeta.semanticRows z
  acceptedRowOpening :
    ExactOpeningBoundary.AcceptedDirectOpening F Unit
  acceptedRowOpeningClaim :
    acceptedRowOpening.claim = continuity.rowClaim.openingClaim
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

theorem stage1AuthenticatedBundle_of_evidence
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
  Stage1AuthenticatedBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr) (Table := Table) pcs
    evalBase B Γ₁ Γ₂ publicTable tableBackedBy validAddressColumns
    kernelAddressBound readCheckExpression readOnlyMemoryRelation rom pre post
    dec stepIdx z := by
  rcases h with ⟨ev⟩
  exact
    ⟨ev.row, ev.rowProjection, ev.rowConsistent, ⟨ev.fetchDecode⟩, ev.lookup⟩

theorem stage2AuthenticatedBundle_of_evidence
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
  Stage2AuthenticatedBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
    (AddressPoint := AddressPoint) (CyclePoint := CyclePoint)
    (AddressColumns := AddressColumns) (Addr := Addr)
    (ValSurface := ValSurface) (Increment := Increment)
    (SessionKey := SessionKey) readSessionKey pairedSessionKey
    validAddressColumns kernelAddressBound rwReadCheckExpression
    writeCheckExpression valEvaluationExpression readWriteMemoryRelation
    incrementRelation Γ₃ pre post z dec stepIdx := by
  rcases h with ⟨ev⟩
  exact ⟨ev.memory, ev.registerTwistClosed, ev.ramTwistClosed⟩

theorem stage3AuthenticatedBundle_of_evidence
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
  Nonempty (
    Stage3AuthenticatedBundle (AuxIndex := AuxIndex) (EvalPoint := EvalPoint)
      (AddressPoint := AddressPoint) (CyclePoint := CyclePoint) pcs evalBase B
      Γ₁ stepIdx inputs.pubMeta.semanticRows z) := by
  rcases h with ⟨ev⟩
  exact ⟨ev.continuity⟩

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
    z colLookupOutput = ev.row.lookupOut := by simp [rc.lookupOut_eq]
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
  exact Stage3Refinement.continuityRowBound_of_paddedCheck
    ev.continuity.paddedCheck ev.continuity.currentRowIndex
    ev.continuity.currentPcNext ev.continuity.currentXIdx
    ev.continuity.currentIsMemOp ev.continuity.currentBurstLast
    ev.continuity.rowClaimIndex ev.continuity.rowBinding

end Evidence

end Nightstream.Chip8.EvidenceCoverage
