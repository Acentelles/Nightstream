import Nightstream.Chip8.Stage1.Routing

namespace Nightstream.Chip8.FetchDecodeBinding

open Nightstream.Chip8

inductive OpcodeId where
  | ldImm
  | addImm
  | mov
  | addReg
  | skipEqImm
  | jump
  | ldI
  | storeRegs
  | loadRegs
deriving DecidableEq, Repr

abbrev OpcodeId.addRegNoCarry : OpcodeId := .addReg

inductive LookupKind where
  | noLookup
  | identity
  | equal8
  | add8Lo
deriving DecidableEq, Repr

inductive OperandSelector where
  | regX
  | regY
  | kk
  | constZero
deriving DecidableEq, Repr

def behaviorOfOpcode : OpcodeId → Nightstream.Chip8.BehaviorClass
  | .ldImm => .writesLookupToVx
  | .addImm => .writesLookupToVx
  | .mov => .writesLookupToVx
  | .addReg => .writesLookupToVx
  | .skipEqImm => .skipEqImm
  | .jump => .jump
  | .ldI => .writesNnnToI
  | .storeRegs => .storeRegs
  | .loadRegs => .loadRegs

theorem behaviorOfOpcode_mem_decodeImage
  {K : Type*} [Field K]
  (opcodeId : OpcodeId) :
  Nightstream.Chip8.behaviorFlags (K := K) (behaviorOfOpcode opcodeId) ∈
    Nightstream.Chip8.decodeImage (K := K) := by
  exact ⟨behaviorOfOpcode opcodeId, rfl⟩

structure DecodedStage1 where
  valid : Nat
  xDec : Nat
  yDec : Nat
  kkDec : Nat
  nnnAddrDec : Nat
  nnnWordDec : Nat
  writesLookupToXDec : Nat
  writesMemToXDec : Nat
  preservesXDec : Nat
  writesNnnToIDec : Nat
  isJumpDec : Nat
  isBranchDec : Nat
  isMemOpDec : Nat
  isStoreDec : Nat
  isLoadDec : Nat
  readsRamDec : Nat
  writesRamDec : Nat
  usesYDec : Nat
  lookupKindDec : LookupKind
  lhsSelectorDec : OperandSelector
  rhsSelectorDec : OperandSelector
  xBoundDec : Nat
deriving DecidableEq, Repr

structure DecodedCore where
  opcodeId : OpcodeId
  x : Nat
  y : Nat
  kk : Nat
  nnnAddr : Nat
  nnnWord : Nat
  valid : Nat
  writesLookupToX : Nat
  writesMemToX : Nat
  preservesX : Nat
  writesNnnToI : Nat
  isJump : Nat
  isBranch : Nat
  isMemOp : Nat
  isStore : Nat
  isLoad : Nat
  readsRam : Nat
  writesRam : Nat
  usesY : Nat
  lookupKind : LookupKind
  lhsSelector : OperandSelector
  rhsSelector : OperandSelector
  xBound : Nat
deriving DecidableEq, Repr

abbrev DecodedRow := DecodedCore

def DecodedCore.behavior (dec : DecodedCore) : Nightstream.Chip8.BehaviorClass :=
  behaviorOfOpcode dec.opcodeId

def DecodedCore.nnn (dec : DecodedCore) : Nat :=
  dec.nnnAddr

def DecodedCore.handoffUsesY (dec : DecodedCore) : Nat :=
  dec.usesY

def DecodedCore.handoffReadsRam (dec : DecodedCore) : Nat :=
  dec.readsRam

def DecodedCore.handoffWritesRam (dec : DecodedCore) : Nat :=
  dec.writesRam

def DecodedCore.toDecodedStage1 (dec : DecodedCore) : DecodedStage1 :=
  { valid := dec.valid
    xDec := dec.x
    yDec := dec.y
    kkDec := dec.kk
    nnnAddrDec := dec.nnnAddr
    nnnWordDec := dec.nnnWord
    writesLookupToXDec := dec.writesLookupToX
    writesMemToXDec := dec.writesMemToX
    preservesXDec := dec.preservesX
    writesNnnToIDec := dec.writesNnnToI
    isJumpDec := dec.isJump
    isBranchDec := dec.isBranch
    isMemOpDec := dec.isMemOp
    isStoreDec := dec.isStore
    isLoadDec := dec.isLoad
    readsRamDec := dec.readsRam
    writesRamDec := dec.writesRam
    usesYDec := dec.usesY
    lookupKindDec := dec.lookupKind
    lhsSelectorDec := dec.lhsSelector
    rhsSelectorDec := dec.rhsSelector
    xBoundDec := dec.xBound }

def DecodedCore.WellFormed (dec : DecodedCore) : Prop :=
  dec.x < 16 ∧ dec.y < 16 ∧ dec.kk < 256 ∧ dec.nnnAddr < 4096

structure Program where
  words : List (Fin 65536)
  startPc : Nat
deriving Repr

def opcodeAt (rom : Program) (pc : Nat) : Option Nat :=
  if _h : rom.startPc ≤ pc then
    let offset := pc - rom.startPc
    match rom.words[offset]? with
    | some word => some word.1
    | none => none
  else
    none

def topNibble (opcode : Nat) : Nat :=
  opcode / 4096

def xField (opcode : Nat) : Nat :=
  (opcode / 256) % 16

def yField (opcode : Nat) : Nat :=
  (opcode / 16) % 16

def lowNibble (opcode : Nat) : Nat :=
  opcode % 16

def kkField (opcode : Nat) : Nat :=
  opcode % 256

def nnnAddrField (opcode : Nat) : Nat :=
  opcode % 4096

def nnnWordField (opcode : Nat) : Nat :=
  nnnAddrField opcode / 2

def jumpTargetAligned (opcode : Nat) : Prop :=
  nnnAddrField opcode = 2 * nnnWordField opcode

instance instDecidableJumpTargetAligned (opcode : Nat) :
  Decidable (jumpTargetAligned opcode) := by
  unfold jumpTargetAligned nnnWordField
  infer_instance

def invalidStage1 : DecodedStage1 :=
  { valid := 0
    xDec := 0
    yDec := 0
    kkDec := 0
    nnnAddrDec := 0
    nnnWordDec := 0
    writesLookupToXDec := 0
    writesMemToXDec := 0
    preservesXDec := 0
    writesNnnToIDec := 0
    isJumpDec := 0
    isBranchDec := 0
    isMemOpDec := 0
    isStoreDec := 0
    isLoadDec := 0
    readsRamDec := 0
    writesRamDec := 0
    usesYDec := 0
    lookupKindDec := .noLookup
    lhsSelectorDec := .constZero
    rhsSelectorDec := .constZero
    xBoundDec := 0 }

private def mkDecodedCore
  (opcodeId : OpcodeId)
  (x y kk nnnAddr nnnWord : Nat)
  (writesLookupToX writesMemToX preservesX writesNnnToI isJump isBranch isMemOp
    isStore isLoad readsRam writesRam usesY : Nat)
  (lookupKind : LookupKind)
  (lhsSelector rhsSelector : OperandSelector)
  (xBound : Nat) :
  DecodedCore :=
  { opcodeId := opcodeId
    x := x
    y := y
    kk := kk
    nnnAddr := nnnAddr
    nnnWord := nnnWord
    valid := 1
    writesLookupToX := writesLookupToX
    writesMemToX := writesMemToX
    preservesX := preservesX
    writesNnnToI := writesNnnToI
    isJump := isJump
    isBranch := isBranch
    isMemOp := isMemOp
    isStore := isStore
    isLoad := isLoad
    readsRam := readsRam
    writesRam := writesRam
    usesY := usesY
    lookupKind := lookupKind
    lhsSelector := lhsSelector
    rhsSelector := rhsSelector
    xBound := xBound }

private def ldImmCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .ldImm (xField opcode) 0 (kkField opcode) 0 0
    1 0 0 0 0 0 0 0 0 0 0 0 .identity .kk .constZero 0

private def addImmCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .addImm (xField opcode) 0 (kkField opcode) 0 0
    1 0 0 0 0 0 0 0 0 0 0 0 .add8Lo .regX .kk 0

private def movCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .mov (xField opcode) (yField opcode) 0 0 0
    1 0 0 0 0 0 0 0 0 0 0 1 .identity .regY .constZero 0

private def addRegCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .addReg (xField opcode) (yField opcode) 0 0 0
    1 0 0 0 0 0 0 0 0 0 0 1 .add8Lo .regX .regY 0

private def skipEqImmCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .skipEqImm (xField opcode) 0 (kkField opcode) 0 0
    0 0 1 0 0 1 0 0 0 0 0 0 .equal8 .regX .kk 0

private def jumpCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .jump 0 0 0 (nnnAddrField opcode) (nnnWordField opcode)
    0 0 1 0 1 0 0 0 0 0 0 0 .noLookup .constZero .constZero 0

private def ldICore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .ldI 0 0 0 (nnnAddrField opcode) 0
    0 0 1 1 0 0 0 0 0 0 0 0 .noLookup .constZero .constZero 0

private def storeRegsCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .storeRegs (xField opcode) 0 0 0 0
    0 0 1 0 0 0 1 1 0 0 1 0 .noLookup .constZero .constZero (xField opcode)

private def loadRegsCore (opcode : Nat) : DecodedCore :=
  mkDecodedCore .loadRegs (xField opcode) 0 0 0 0
    0 1 0 0 0 0 1 0 1 1 0 0 .noLookup .constZero .constZero (xField opcode)

def decodeOpcodeWord (opcode : Nat) : Option DecodedCore :=
  match topNibble opcode, lowNibble opcode with
  | 0x6, _ => some (ldImmCore opcode)
  | 0x7, _ => some (addImmCore opcode)
  | 0x8, 0x0 => some (movCore opcode)
  | 0x8, 0x4 => some (addRegCore opcode)
  | 0x3, _ => some (skipEqImmCore opcode)
  | 0x1, _ =>
      if _hAlign : jumpTargetAligned opcode then
        some (jumpCore opcode)
      else
        none
  | 0xA, _ => some (ldICore opcode)
  | 0xF, 0x5 =>
      if kkField opcode = 0x55 then
        some (storeRegsCore opcode)
      else if kkField opcode = 0x65 then
        some (loadRegsCore opcode)
      else
        none
  | _, _ => none

def decodeStage1Word (opcode : Nat) : DecodedStage1 :=
  match decodeOpcodeWord opcode with
  | some dec => dec.toDecodedStage1
  | none => invalidStage1

def selectOperand (sel : OperandSelector) (regX regY kk : Nat) : Nat :=
  match sel with
  | .regX => regX
  | .regY => regY
  | .kk => kk
  | .constZero => 0

def byteAddLo (lhs rhs : Nat) : Nat :=
  (lhs + rhs) % 256

def equal8 (lhs rhs : Nat) : Nat :=
  if lhs = rhs then 1 else 0

def evalLookup (kind : LookupKind) (lhs rhs : Nat) : Nat :=
  match kind with
  | .noLookup => 0
  | .identity => lhs
  | .equal8 => equal8 lhs rhs
  | .add8Lo => byteAddLo lhs rhs

def eq4Eval (lhs rhs : Nat) : Nat :=
  if lhs = rhs then 1 else 0

def AluLookupBound (dec : DecodedCore) (regX regY lookupOut : Nat) : Prop :=
  let lhs := selectOperand dec.lhsSelector regX regY dec.kk
  let rhs := selectOperand dec.rhsSelector regX regY dec.kk
  lookupOut = evalLookup dec.lookupKind lhs rhs

def BurstEqBound (dec : DecodedCore) (xIdx burstLast : Nat) : Prop :=
  burstLast = dec.isMemOp * eq4Eval xIdx dec.xBound

def DecodeHandoffBound (dec : DecodedCore) (hUsesY hReadsRam hWritesRam : Nat) : Prop :=
  hUsesY = dec.handoffUsesY ∧
    hReadsRam = dec.handoffReadsRam ∧
    hWritesRam = dec.handoffWritesRam

def FetchDecodeBound (rom : Program) (pc : Nat) (dec : DecodedCore) : Prop :=
  ∃ opcode, opcodeAt rom pc = some opcode ∧ decodeOpcodeWord opcode = some dec

theorem xField_lt (opcode : Nat) : xField opcode < 16 := by
  unfold xField
  exact Nat.mod_lt _ (by decide)

theorem yField_lt (opcode : Nat) : yField opcode < 16 := by
  unfold yField
  exact Nat.mod_lt _ (by decide)

theorem kkField_lt (opcode : Nat) : kkField opcode < 256 := by
  unfold kkField
  exact Nat.mod_lt _ (by decide)

theorem nnnAddrField_lt (opcode : Nat) : nnnAddrField opcode < 4096 := by
  unfold nnnAddrField
  exact Nat.mod_lt _ (by decide)

theorem nnnWordField_lt (opcode : Nat) : nnnWordField opcode < 2048 := by
  unfold nnnWordField
  have hAddr : nnnAddrField opcode < 4096 := nnnAddrField_lt opcode
  omega

theorem jumpTargetAligned_iff_even
  {opcode : Nat} :
  jumpTargetAligned opcode ↔ nnnAddrField opcode % 2 = 0 := by
  unfold jumpTargetAligned nnnWordField
  omega

theorem decodeOpcodeWord_deterministic
  {opcode : Nat}
  {dec₁ dec₂ : DecodedCore}
  (h₁ : decodeOpcodeWord opcode = some dec₁)
  (h₂ : decodeOpcodeWord opcode = some dec₂) :
  dec₁ = dec₂ := by
  rw [h₁] at h₂
  exact Option.some.inj h₂

theorem decodeStage1Word_total_defaults
  {opcode : Nat}
  (h : decodeOpcodeWord opcode = none) :
  decodeStage1Word opcode = invalidStage1 := by
  simp [decodeStage1Word, h]

private theorem decodeOpcodeWord_eq_core
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec = ldImmCore opcode ∨
    dec = addImmCore opcode ∨
    dec = movCore opcode ∨
    dec = addRegCore opcode ∨
    dec = skipEqImmCore opcode ∨
    dec = jumpCore opcode ∨
    dec = ldICore opcode ∨
    dec = storeRegsCore opcode ∨
    dec = loadRegsCore opcode := by
  unfold decodeOpcodeWord at h
  split at h
  · injection h with hDec
    exact Or.inl hDec.symm
  · injection h with hDec
    exact Or.inr <| Or.inl hDec.symm
  · injection h with hDec
    exact Or.inr <| Or.inr <| Or.inl hDec.symm
  · injection h with hDec
    exact Or.inr <| Or.inr <| Or.inr <| Or.inl hDec.symm
  · injection h with hDec
    exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inl hDec.symm
  · split at h
    · injection h with hDec
      exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inl hDec.symm
    · simp at h
  · injection h with hDec
    exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inl hDec.symm
  · split at h
    · injection h with hDec
      exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inl hDec.symm
    · split at h
      · injection h with hDec
        exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr hDec.symm
      · cases h
  · cases h

private theorem jumpTargetAligned_of_decodeJump
  {opcode : Nat}
  (h : decodeOpcodeWord opcode = some (jumpCore opcode)) :
  jumpTargetAligned opcode := by
  unfold decodeOpcodeWord at h
  split at h
  · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
    simp [ldImmCore, jumpCore, mkDecodedCore] at hId
  · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
    simp [addImmCore, jumpCore, mkDecodedCore] at hId
  · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
    simp [movCore, jumpCore, mkDecodedCore] at hId
  · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
    simp [addRegCore, jumpCore, mkDecodedCore] at hId
  · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
    simp [skipEqImmCore, jumpCore, mkDecodedCore] at hId
  · split at h
    · assumption
    · simp at h
  · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
    simp [ldICore, jumpCore, mkDecodedCore] at hId
  · split at h
    · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
      simp [storeRegsCore, jumpCore, mkDecodedCore] at hId
    · split at h
      · have hId := congrArg DecodedCore.opcodeId (Option.some.inj h)
        simp [loadRegsCore, jumpCore, mkDecodedCore] at hId
      · cases h
  · cases h

theorem decodeOpcodeWord_valid
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec.valid = 1 := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  all_goals
    subst dec
    rfl

theorem decodeOpcodeWord_fields
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec.x < 16 ∧ dec.y < 16 ∧ dec.kk < 256 ∧ dec.nnn < 4096 := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec
    simp [ldImmCore, mkDecodedCore, DecodedCore.nnn, xField_lt, kkField_lt]
  · subst dec
    simp [addImmCore, mkDecodedCore, DecodedCore.nnn, xField_lt, kkField_lt]
  · subst dec
    simp [movCore, mkDecodedCore, DecodedCore.nnn, xField_lt, yField_lt]
  · subst dec
    simp [addRegCore, mkDecodedCore, DecodedCore.nnn, xField_lt, yField_lt]
  · subst dec
    simp [skipEqImmCore, mkDecodedCore, DecodedCore.nnn, xField_lt, kkField_lt]
  · subst dec
    simp [jumpCore, mkDecodedCore, DecodedCore.nnn, nnnAddrField_lt]
  · subst dec
    simp [ldICore, mkDecodedCore, DecodedCore.nnn, nnnAddrField_lt]
  · subst dec
    simp [storeRegsCore, mkDecodedCore, DecodedCore.nnn, xField_lt]
  · subst dec
    simp [loadRegsCore, mkDecodedCore, DecodedCore.nnn, xField_lt]

theorem decodeOpcodeWord_wellFormed
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec.WellFormed := by
  simpa [DecodedCore.WellFormed] using decodeOpcodeWord_fields h

theorem decodeOpcodeWord_nnnWord_lt
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec.nnnWord < 2048 := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; simp [ldImmCore, mkDecodedCore]
  · subst dec; simp [addImmCore, mkDecodedCore]
  · subst dec; simp [movCore, mkDecodedCore]
  · subst dec; simp [addRegCore, mkDecodedCore]
  · subst dec; simp [skipEqImmCore, mkDecodedCore]
  · subst dec; simpa using nnnWordField_lt opcode
  · subst dec; simp [ldICore, mkDecodedCore]
  · subst dec; simp [storeRegsCore, mkDecodedCore]
  · subst dec; simp [loadRegsCore, mkDecodedCore]

theorem decodeOpcodeWord_jump_alignment
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec)
  (hJump : dec.isJump = 1) :
  dec.nnnAddr = 2 * dec.nnnWord := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; exfalso; simp [ldImmCore, mkDecodedCore] at hJump
  · subst dec; exfalso; simp [addImmCore, mkDecodedCore] at hJump
  · subst dec; exfalso; simp [movCore, mkDecodedCore] at hJump
  · subst dec; exfalso; simp [addRegCore, mkDecodedCore] at hJump
  · subst dec; exfalso; simp [skipEqImmCore, mkDecodedCore] at hJump
  · subst dec
    have hAlign : jumpTargetAligned opcode := jumpTargetAligned_of_decodeJump h
    simpa [jumpCore, jumpTargetAligned] using hAlign
  · subst dec; exfalso; simp [ldICore, mkDecodedCore] at hJump
  · subst dec; exfalso; simp [storeRegsCore, mkDecodedCore] at hJump
  · subst dec; exfalso; simp [loadRegsCore, mkDecodedCore] at hJump

theorem decodeOpcodeWord_noLookup_defaults
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec)
  (hNoLookup : dec.lookupKind = .noLookup) :
  dec.lhsSelector = .constZero ∧
    dec.rhsSelector = .constZero := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; simp [ldImmCore, mkDecodedCore] at hNoLookup
  · subst dec; simp [addImmCore, mkDecodedCore] at hNoLookup
  · subst dec; simp [movCore, mkDecodedCore] at hNoLookup
  · subst dec; simp [addRegCore, mkDecodedCore] at hNoLookup
  · subst dec; simp [skipEqImmCore, mkDecodedCore] at hNoLookup
  · subst dec; exact ⟨rfl, rfl⟩
  · subst dec; exact ⟨rfl, rfl⟩
  · subst dec; exact ⟨rfl, rfl⟩
  · subst dec; exact ⟨rfl, rfl⟩

theorem decodeOpcodeWord_nonMem_defaults
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec)
  (hNonMem : dec.isMemOp = 0) :
  dec.xBound = 0 := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; rfl
  · subst dec; rfl
  · subst dec; rfl
  · subst dec; rfl
  · subst dec; rfl
  · subst dec; rfl
  · subst dec; rfl
  · subst dec; simp [storeRegsCore, mkDecodedCore] at hNonMem
  · subst dec; simp [loadRegsCore, mkDecodedCore] at hNonMem

theorem decodeOpcodeWord_handoff_exact
  {opcode : Nat}
  {dec : DecodedCore}
  (_h : decodeOpcodeWord opcode = some dec) :
  DecodeHandoffBound dec dec.handoffUsesY dec.handoffReadsRam dec.handoffWritesRam := by
  exact ⟨rfl, rfl, rfl⟩

theorem decodeOpcodeWord_usesY_bit
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec.usesY = 0 ∨ dec.usesY = 1 := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; simp [ldImmCore, mkDecodedCore]
  · subst dec; simp [addImmCore, mkDecodedCore]
  · subst dec; simp [movCore, mkDecodedCore]
  · subst dec; simp [addRegCore, mkDecodedCore]
  · subst dec; simp [skipEqImmCore, mkDecodedCore]
  · subst dec; simp [jumpCore, mkDecodedCore]
  · subst dec; simp [ldICore, mkDecodedCore]
  · subst dec; simp [storeRegsCore, mkDecodedCore]
  · subst dec; simp [loadRegsCore, mkDecodedCore]

theorem decodeOpcodeWord_readsRam_bit
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec.readsRam = 0 ∨ dec.readsRam = 1 := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  all_goals
    subst dec <;> simp [ldImmCore, addImmCore, movCore, addRegCore, skipEqImmCore,
      jumpCore, ldICore, storeRegsCore, loadRegsCore, mkDecodedCore]

theorem decodeOpcodeWord_writesRam_bit
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  dec.writesRam = 0 ∨ dec.writesRam = 1 := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  all_goals
    subst dec <;> simp [ldImmCore, addImmCore, movCore, addRegCore, skipEqImmCore,
      jumpCore, ldICore, storeRegsCore, loadRegsCore, mkDecodedCore]

theorem decodeOpcodeWord_laneWrite_cases
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec) :
  (dec.writesLookupToX + dec.writesMemToX = 1 ∧ dec.writesNnnToI = 0) ∨
    (dec.writesLookupToX + dec.writesMemToX = 0 ∧ dec.writesNnnToI = 1) ∨
    (dec.writesLookupToX + dec.writesMemToX = 0 ∧ dec.writesNnnToI = 0) := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; simp [ldImmCore, mkDecodedCore]
  · subst dec; simp [addImmCore, mkDecodedCore]
  · subst dec; simp [movCore, mkDecodedCore]
  · subst dec; simp [addRegCore, mkDecodedCore]
  · subst dec; simp [skipEqImmCore, mkDecodedCore]
  · subst dec; simp [jumpCore, mkDecodedCore]
  · subst dec; simp [ldICore, mkDecodedCore]
  · subst dec; simp [storeRegsCore, mkDecodedCore]
  · subst dec; simp [loadRegsCore, mkDecodedCore]

theorem decodeOpcodeWord_nonNoLookup_usesLookupOpcode
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec)
  (hLookup : dec.lookupKind ≠ .noLookup) :
  dec.opcodeId = .ldImm ∨
    dec.opcodeId = .addImm ∨
    dec.opcodeId = .mov ∨
    dec.opcodeId = .addReg ∨
    dec.opcodeId = .skipEqImm := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; simp [ldImmCore, mkDecodedCore]
  · subst dec; simp [addImmCore, mkDecodedCore]
  · subst dec; simp [movCore, mkDecodedCore]
  · subst dec; simp [addRegCore, mkDecodedCore]
  · subst dec; simp [skipEqImmCore, mkDecodedCore]
  · subst dec; simp [jumpCore, mkDecodedCore] at hLookup
  · subst dec; simp [ldICore, mkDecodedCore] at hLookup
  · subst dec; simp [storeRegsCore, mkDecodedCore] at hLookup
  · subst dec; simp [loadRegsCore, mkDecodedCore] at hLookup

theorem decodeOpcodeWord_readsRam_is_loadRegs
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec)
  (hRead : dec.readsRam = 1) :
  dec.opcodeId = .loadRegs := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; simp [ldImmCore, mkDecodedCore] at hRead
  · subst dec; simp [addImmCore, mkDecodedCore] at hRead
  · subst dec; simp [movCore, mkDecodedCore] at hRead
  · subst dec; simp [addRegCore, mkDecodedCore] at hRead
  · subst dec; simp [skipEqImmCore, mkDecodedCore] at hRead
  · subst dec; simp [jumpCore, mkDecodedCore] at hRead
  · subst dec; simp [ldICore, mkDecodedCore] at hRead
  · subst dec; simp [storeRegsCore, mkDecodedCore] at hRead
  · subst dec; rfl

theorem decodeOpcodeWord_writesRam_is_storeRegs
  {opcode : Nat}
  {dec : DecodedCore}
  (h : decodeOpcodeWord opcode = some dec)
  (hWrite : dec.writesRam = 1) :
  dec.opcodeId = .storeRegs := by
  rcases decodeOpcodeWord_eq_core h with hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq | hEq
  · subst dec; simp [ldImmCore, mkDecodedCore] at hWrite
  · subst dec; simp [addImmCore, mkDecodedCore] at hWrite
  · subst dec; simp [movCore, mkDecodedCore] at hWrite
  · subst dec; simp [addRegCore, mkDecodedCore] at hWrite
  · subst dec; simp [skipEqImmCore, mkDecodedCore] at hWrite
  · subst dec; simp [jumpCore, mkDecodedCore] at hWrite
  · subst dec; simp [ldICore, mkDecodedCore] at hWrite
  · subst dec; rfl
  · subst dec; simp [loadRegsCore, mkDecodedCore] at hWrite

theorem fetchDecodeBound_opcodeAt
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  (h : FetchDecodeBound rom pc dec) :
  ∃ opcode, opcodeAt rom pc = some opcode := by
  rcases h with ⟨opcode, hFetch, _⟩
  exact ⟨opcode, hFetch⟩

theorem fetchDecodeBound_decodes
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  (h : FetchDecodeBound rom pc dec) :
  ∃ opcode, decodeOpcodeWord opcode = some dec := by
  rcases h with ⟨opcode, _, hDecode⟩
  exact ⟨opcode, hDecode⟩

theorem fetchDecodeBound_unique
  {rom : Program}
  {pc : Nat}
  {dec₁ dec₂ : DecodedCore}
  (h₁ : FetchDecodeBound rom pc dec₁)
  (h₂ : FetchDecodeBound rom pc dec₂) :
  dec₁ = dec₂ := by
  rcases h₁ with ⟨opcode₁, hFetch₁, hDecode₁⟩
  rcases h₂ with ⟨opcode₂, hFetch₂, hDecode₂⟩
  rw [hFetch₁] at hFetch₂
  injection hFetch₂ with hOpcode
  subst hOpcode
  exact decodeOpcodeWord_deterministic (h₁ := hDecode₁) (h₂ := hDecode₂)

theorem fetchDecodeBound_wellFormed
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  (h : FetchDecodeBound rom pc dec) :
  dec.WellFormed := by
  rcases h with ⟨opcode, _, hDecode⟩
  exact decodeOpcodeWord_wellFormed hDecode

theorem fetchDecodeBound_valid
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  (h : FetchDecodeBound rom pc dec) :
  dec.valid = 1 := by
  rcases h with ⟨opcode, _, hDecode⟩
  exact decodeOpcodeWord_valid hDecode

theorem fetchDecodeBound_flags_mem_decodeImage
  {K : Type*} [Field K]
  {rom : Program}
  {pc : Nat}
  {dec : DecodedCore}
  (_h : FetchDecodeBound rom pc dec) :
  Nightstream.Chip8.behaviorFlags (K := K) dec.behavior ∈
    Nightstream.Chip8.decodeImage (K := K) := by
  exact behaviorOfOpcode_mem_decodeImage dec.opcodeId

theorem aluLookupBound_noLookup_zero
  {dec : DecodedCore}
  {regX regY lookupOut : Nat}
  (hNoLookup : dec.lookupKind = .noLookup)
  (hBound : AluLookupBound dec regX regY lookupOut) :
  lookupOut = 0 := by
  unfold AluLookupBound at hBound
  simp [hNoLookup, evalLookup] at hBound
  exact hBound

theorem burstEqBound_nonMem_zero
  {dec : DecodedCore}
  {xIdx burstLast : Nat}
  (hNonMem : dec.isMemOp = 0)
  (hBound : BurstEqBound dec xIdx burstLast) :
  burstLast = 0 := by
  unfold BurstEqBound at hBound
  simp [hNonMem] at hBound
  exact hBound

end Nightstream.Chip8.FetchDecodeBinding
