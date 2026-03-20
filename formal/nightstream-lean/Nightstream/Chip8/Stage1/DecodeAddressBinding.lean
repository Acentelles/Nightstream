import Nightstream.Chip8.Stage1.FetchDecodeBinding

namespace Nightstream.Chip8.DecodeAddressBinding

open Nightstream.Chip8
open Nightstream.Chip8.FetchDecodeBinding

inductive AddressRole where
  | fetch
  | decode
  | alu
  | eq4
  | regRaX
  | regRaY
  | regRaI
  | regWa
  | ramRa
  | ramWa
deriving DecidableEq, Repr

namespace AddressRole

abbrev lookup : AddressRole := .alu
abbrev readMem : AddressRole := .ramRa
abbrev writeMem : AddressRole := .ramWa

end AddressRole

structure DecodedStep (Addr : Type*) extends DecodedCore where
  microIndex : Nat
  pcWord : Nat
  opcodeWord : Nat
  aluLhs : Nat
  aluRhs : Nat
  ramAddr : Nat
  addressOfNat : Nat → Addr

abbrev DecodedRow := DecodedStep

def behavior
  {Addr : Type*}
  (dec : DecodedStep Addr) : Nightstream.Chip8.BehaviorClass :=
  behaviorOfOpcode dec.opcodeId

def IsBurstOpcode : OpcodeId → Prop
  | .storeRegs => True
  | .loadRegs => True
  | _ => False

instance instDecidableIsBurstOpcode (opcode : OpcodeId) : Decidable (IsBurstOpcode opcode) := by
  cases opcode <;> unfold IsBurstOpcode <;> infer_instance

def activeXIndex
  {Addr : Type*}
  (dec : DecodedStep Addr) : Nat :=
  if IsBurstOpcode dec.opcodeId then dec.microIndex else dec.x

def burstLast
  {Addr : Type*}
  (dec : DecodedStep Addr) : Prop :=
  dec.microIndex = dec.x

def projectedYIndex
  {Addr : Type*}
  (dec : DecodedStep Addr) : Nat :=
  if dec.usesY = 1 then dec.y else 0

def UsesLookup : OpcodeId → Prop
  | .ldImm => True
  | .addImm => True
  | .mov => True
  | .addReg => True
  | .skipEqImm => True
  | .jump => False
  | .ldI => False
  | .storeRegs => False
  | .loadRegs => False

def UsesReadMem : OpcodeId → Prop
  | .loadRegs => True
  | _ => False

def UsesWriteMem : OpcodeId → Prop
  | .storeRegs => True
  | _ => False

def Stage1Decoded
  {Addr : Type*}
  (dec : DecodedStep Addr) : Prop :=
  decodeOpcodeWord dec.opcodeWord = some dec.toDecodedCore

def NoLookupOperandsZero
  {Addr : Type*}
  (dec : DecodedStep Addr) : Prop :=
  dec.lookupKind = .noLookup → dec.aluLhs = 0 ∧ dec.aluRhs = 0

def DecodeAddressShape
  {Addr : Type*}
  (dec : DecodedStep Addr) : Prop :=
  Stage1Decoded dec ∧ NoLookupOperandsZero dec

def lookupKindCode : LookupKind → Nat
  | .noLookup => 0
  | .identity => 1
  | .equal8 => 2
  | .add8Lo => 3

def flattenAluKey (kind : LookupKind) (lhs rhs : Nat) : Nat :=
  2 ^ 16 * lookupKindCode kind + 2 ^ 8 * lhs + rhs

def eq4Key
  {Addr : Type*}
  (dec : DecodedStep Addr) : Nat :=
  16 * activeXIndex dec + dec.xBound

def regSinkAddr : Nat := 17

def ramSinkAddr : Nat := 4096

def ActiveXIndexBound
  {Addr : Type*}
  (dec : DecodedStep Addr) : Prop :=
  activeXIndex dec < regSinkAddr

def projectedNatAddressAt
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (role : AddressRole) : Nat :=
  match role with
  | .fetch => dec.pcWord
  | .decode => dec.opcodeWord
  | .alu => flattenAluKey dec.lookupKind dec.aluLhs dec.aluRhs
  | .eq4 => eq4Key dec
  | .regRaX => activeXIndex dec
  | .regRaY => dec.usesY * projectedYIndex dec + (1 - dec.usesY) * regSinkAddr
  | .regRaI => 16
  | .regWa =>
      (dec.writesLookupToX + dec.writesMemToX) * activeXIndex dec +
        dec.writesNnnToI * 16 +
        (1 - dec.writesLookupToX - dec.writesMemToX - dec.writesNnnToI) * regSinkAddr
  | .ramRa => dec.readsRam * dec.ramAddr + (1 - dec.readsRam) * ramSinkAddr
  | .ramWa => dec.writesRam * dec.ramAddr + (1 - dec.writesRam) * ramSinkAddr

def projectedAddress
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (role : AddressRole) : Option Addr :=
  some (dec.addressOfNat (projectedNatAddressAt dec role))

def KernelAddressBoundAt
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (role : AddressRole)
  (addr : Addr) : Prop :=
  projectedAddress dec role = some addr

def KernelAddressBound
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (addr : Addr) : Prop :=
  ∃ role, KernelAddressBoundAt dec role addr

theorem kernelAddressBound_iff_projectedAddress
  {Addr : Type*}
  {dec : DecodedStep Addr}
  {addr : Addr} :
  KernelAddressBound dec addr ↔ ∃ role, projectedAddress dec role = some addr := by
  rfl

theorem kernelAddressBound_iff_familyProjection
  {Addr : Type*}
  {dec : DecodedStep Addr}
  {addr : Addr} :
  KernelAddressBound dec addr ↔ ∃ role, projectedAddress dec role = some addr := by
  rfl

theorem kernelAddressBoundAt_projected
  {Addr : Type*}
  (dec : DecodedStep Addr)
  (role : AddressRole) :
  KernelAddressBoundAt dec role (dec.addressOfNat (projectedNatAddressAt dec role)) := by
  simp [KernelAddressBoundAt, projectedAddress]

theorem kernelAddressBoundAt_fetch
  {Addr : Type*}
  (dec : DecodedStep Addr) :
  KernelAddressBoundAt dec .fetch (dec.addressOfNat dec.pcWord) := by
  simpa [projectedNatAddressAt] using kernelAddressBoundAt_projected dec .fetch

theorem kernelAddressBoundAt_decode
  {Addr : Type*}
  (dec : DecodedStep Addr) :
  KernelAddressBoundAt dec .decode (dec.addressOfNat dec.opcodeWord) := by
  simpa [projectedNatAddressAt] using kernelAddressBoundAt_projected dec .decode

theorem kernelAddressBound_of_boundAt
  {Addr : Type*}
  {dec : DecodedStep Addr}
  {role : AddressRole}
  {addr : Addr}
  (h : KernelAddressBoundAt dec role addr) :
  KernelAddressBound dec addr := by
  exact ⟨role, h⟩

theorem activeXIndex_of_storeRegs
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : dec.opcodeId = .storeRegs) :
  activeXIndex dec = dec.microIndex := by
  cases hOpcode : dec.opcodeId <;> simp [activeXIndex, IsBurstOpcode, hOpcode] at h ⊢

theorem activeXIndex_of_loadRegs
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : dec.opcodeId = .loadRegs) :
  activeXIndex dec = dec.microIndex := by
  cases hOpcode : dec.opcodeId <;> simp [activeXIndex, IsBurstOpcode, hOpcode] at h ⊢

theorem activeXIndex_of_nonBurst
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hStore : dec.opcodeId ≠ .storeRegs)
  (hLoad : dec.opcodeId ≠ .loadRegs) :
  activeXIndex dec = dec.x := by
  cases hOpcode : dec.opcodeId <;> simp [activeXIndex, IsBurstOpcode, hOpcode] at hStore hLoad ⊢

theorem stage1Decoded_wellFormed
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec) :
  dec.x < 16 ∧ dec.y < 16 ∧ dec.kk < 256 ∧ dec.nnn < 4096 := by
  simpa [Stage1Decoded, DecodedStep.toDecodedCore] using decodeOpcodeWord_wellFormed h

theorem stage1Decoded_usesY_bit
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec) :
  dec.usesY = 0 ∨ dec.usesY = 1 := by
  simpa [Stage1Decoded, DecodedStep.toDecodedCore] using decodeOpcodeWord_usesY_bit h

theorem stage1Decoded_readsRam_bit
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec) :
  dec.readsRam = 0 ∨ dec.readsRam = 1 := by
  simpa [Stage1Decoded, DecodedStep.toDecodedCore] using decodeOpcodeWord_readsRam_bit h

theorem stage1Decoded_writesRam_bit
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec) :
  dec.writesRam = 0 ∨ dec.writesRam = 1 := by
  simpa [Stage1Decoded, DecodedStep.toDecodedCore] using decodeOpcodeWord_writesRam_bit h

theorem stage1Decoded_laneWrite_cases
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec) :
  (dec.writesLookupToX + dec.writesMemToX = 1 ∧ dec.writesNnnToI = 0) ∨
    (dec.writesLookupToX + dec.writesMemToX = 0 ∧ dec.writesNnnToI = 1) ∨
    (dec.writesLookupToX + dec.writesMemToX = 0 ∧ dec.writesNnnToI = 0) := by
  simpa [Stage1Decoded, DecodedStep.toDecodedCore] using decodeOpcodeWord_laneWrite_cases h

theorem stage1Decoded_nonNoLookup_usesLookupOpcode
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec)
  (hLookup : dec.lookupKind ≠ .noLookup) :
  UsesLookup dec.opcodeId := by
  rcases
      (show dec.opcodeId = .ldImm ∨
          dec.opcodeId = .addImm ∨
          dec.opcodeId = .mov ∨
          dec.opcodeId = .addReg ∨
          dec.opcodeId = .skipEqImm from
        by
          simpa [Stage1Decoded, DecodedStep.toDecodedCore] using
            decodeOpcodeWord_nonNoLookup_usesLookupOpcode h hLookup)
    with hOpcode | hOpcode | hOpcode | hOpcode | hOpcode
  · simp [UsesLookup, hOpcode]
  · simp [UsesLookup, hOpcode]
  · simp [UsesLookup, hOpcode]
  · simp [UsesLookup, hOpcode]
  · simp [UsesLookup, hOpcode]

theorem stage1Decoded_readsRam_is_loadRegs
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec)
  (hRead : dec.readsRam = 1) :
  dec.opcodeId = .loadRegs := by
  simpa [Stage1Decoded, DecodedStep.toDecodedCore] using
    decodeOpcodeWord_readsRam_is_loadRegs h hRead

theorem stage1Decoded_writesRam_is_storeRegs
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (h : Stage1Decoded dec)
  (hWrite : dec.writesRam = 1) :
  dec.opcodeId = .storeRegs := by
  simpa [Stage1Decoded, DecodedStep.toDecodedCore] using
    decodeOpcodeWord_writesRam_is_storeRegs h hWrite

theorem aluAddress_requires_lookup_family
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  {addr : Addr}
  (_hBound : KernelAddressBoundAt dec .alu addr)
  (hLookup : dec.lookupKind ≠ .noLookup) :
  UsesLookup dec.opcodeId := by
  exact stage1Decoded_nonNoLookup_usesLookupOpcode hShape.1 hLookup

theorem lookupAddress_requires_lookup_family
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  {addr : Addr}
  (hBound : KernelAddressBoundAt dec .lookup addr)
  (hLookup : dec.lookupKind ≠ .noLookup) :
  UsesLookup dec.opcodeId := by
  exact aluAddress_requires_lookup_family hShape hBound hLookup

theorem ramReadAddress_requires_readsRam
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  {addr : Addr}
  (hBound : KernelAddressBoundAt dec .ramRa addr)
  (hActive : addr ≠ dec.addressOfNat ramSinkAddr) :
  dec.readsRam = 1 := by
  rcases stage1Decoded_readsRam_bit hShape.1 with hRead | hRead
  · have hAddr : dec.addressOfNat ramSinkAddr = addr := by
      simpa [KernelAddressBoundAt, projectedAddress, projectedNatAddressAt, hRead, ramSinkAddr]
        using hBound
    exact False.elim (hActive hAddr.symm)
  · exact hRead

theorem ramWriteAddress_requires_writesRam
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  {addr : Addr}
  (hBound : KernelAddressBoundAt dec .ramWa addr)
  (hActive : addr ≠ dec.addressOfNat ramSinkAddr) :
  dec.writesRam = 1 := by
  rcases stage1Decoded_writesRam_bit hShape.1 with hWrite | hWrite
  · have hAddr : dec.addressOfNat ramSinkAddr = addr := by
      simpa [KernelAddressBoundAt, projectedAddress, projectedNatAddressAt, hWrite, ramSinkAddr]
        using hBound
    exact False.elim (hActive hAddr.symm)
  · exact hWrite

theorem readMemAddress_requires_loadRegs
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  {addr : Addr}
  (hBound : KernelAddressBoundAt dec .readMem addr)
  (hActive : addr ≠ dec.addressOfNat ramSinkAddr) :
  dec.opcodeId = .loadRegs := by
  exact stage1Decoded_readsRam_is_loadRegs hShape.1
    (ramReadAddress_requires_readsRam hShape hBound hActive)

theorem writeMemAddress_requires_storeRegs
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  {addr : Addr}
  (hBound : KernelAddressBoundAt dec .writeMem addr)
  (hActive : addr ≠ dec.addressOfNat ramSinkAddr) :
  dec.opcodeId = .storeRegs := by
  exact stage1Decoded_writesRam_is_storeRegs hShape.1
    (ramWriteAddress_requires_writesRam hShape hBound hActive)

theorem regYAddress_uses_sink_iff_not_usesY
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  (hinj : Function.Injective dec.addressOfNat) :
  KernelAddressBoundAt dec .regRaY (dec.addressOfNat regSinkAddr) ↔ dec.usesY = 0 := by
  constructor
  · intro hBound
    rcases stage1Decoded_usesY_bit hShape.1 with hUses | hUses
    · exact hUses
    · have hNat :
        projectedNatAddressAt dec .regRaY = regSinkAddr := by
        apply hinj
        simpa [KernelAddressBoundAt, projectedAddress] using hBound
      have hy : dec.y = regSinkAddr := by
        calc
          dec.y = projectedNatAddressAt dec .regRaY := by
            simp [projectedNatAddressAt, projectedYIndex, hUses, regSinkAddr]
          _ = regSinkAddr := hNat
      have hWf := stage1Decoded_wellFormed hShape.1
      have hylt : dec.y < regSinkAddr := by
        exact lt_trans hWf.2.1 (by decide)
      exact False.elim ((Nat.ne_of_lt hylt) hy)
  · intro hUses
    simp [KernelAddressBoundAt, projectedAddress, projectedNatAddressAt, projectedYIndex,
      hUses, regSinkAddr]

theorem regWriteAddress_uses_sink_iff_no_lane_write
  {Addr : Type*}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  (hX : ActiveXIndexBound dec)
  (hinj : Function.Injective dec.addressOfNat) :
  KernelAddressBoundAt dec .regWa (dec.addressOfNat regSinkAddr) ↔
    (dec.writesLookupToX + dec.writesMemToX = 0 ∧ dec.writesNnnToI = 0) := by
  constructor
  · intro hBound
    have hNat :
        projectedNatAddressAt dec .regWa = regSinkAddr := by
      apply hinj
      simpa [KernelAddressBoundAt, projectedAddress] using hBound
    rcases stage1Decoded_laneWrite_cases hShape.1 with hWriteX | hWriteI | hSink
    · rcases hWriteX with ⟨hXWrite, hIWrite⟩
      have hLookupLt : dec.writesLookupToX < 2 := by
        omega
      have hNoSinkTerm : 1 - dec.writesLookupToX - dec.writesMemToX = 0 := by
        interval_cases dec.writesLookupToX <;> omega
      have hActiveEq : activeXIndex dec = regSinkAddr := by
        simpa [projectedNatAddressAt, hXWrite, hIWrite, hNoSinkTerm, regSinkAddr] using hNat
      exact False.elim ((Nat.ne_of_lt hX) hActiveEq)
    · rcases hWriteI with ⟨hXWrite, hIWrite⟩
      have hLookupZero : dec.writesLookupToX = 0 := by
        omega
      have hMemZero : dec.writesMemToX = 0 := by
        omega
      have : (16 : Nat) = regSinkAddr := by
        simpa [projectedNatAddressAt, hLookupZero, hMemZero, hIWrite, regSinkAddr] using hNat
      norm_num [regSinkAddr] at this
    · exact hSink
  · intro hNoWrite
    rcases hNoWrite with ⟨hXWrite, hIWrite⟩
    have hLookupZero : dec.writesLookupToX = 0 := by
      omega
    have hMemZero : dec.writesMemToX = 0 := by
      omega
    simp [KernelAddressBoundAt, projectedAddress, projectedNatAddressAt, hXWrite, hIWrite,
      hLookupZero, hMemZero, regSinkAddr]

end Nightstream.Chip8.DecodeAddressBinding
