import Nightstream.Chip8.Stage1.DecodeAddressBinding

/-!
Owns the concrete register-side Stage-2 session-key boundary for CHIP-8.
This file fixes the register session-key domain and the exact role-to-key
constructors for `regRaX`, `regRaY`, `regRaI`, and `regWa`. It does not
re-own generic Twist session closure.
-/

namespace Nightstream.Chip8.RegisterSessionBoundary

open Nightstream.Chip8.DecodeAddressBinding

structure RegisterSessionKey where
  cycleIndex : Nat
  regAddr : Nat
deriving DecidableEq, Repr

def RegisterSessionKeyBound (key : RegisterSessionKey) : Prop :=
  key.regAddr < 16 ∨ key.regAddr = 16 ∨ key.regAddr = regSinkAddr

def regRaXKey
  {Addr : Type*}
  (stepIdx : Nat)
  (dec : DecodedStep Addr) : RegisterSessionKey :=
  ⟨stepIdx, projectedNatAddressAt dec .regRaX⟩

def regRaYKey
  {Addr : Type*}
  (stepIdx : Nat)
  (dec : DecodedStep Addr) : RegisterSessionKey :=
  ⟨stepIdx, projectedNatAddressAt dec .regRaY⟩

def regRaIKey
  {Addr : Type*}
  (stepIdx : Nat)
  (dec : DecodedStep Addr) : RegisterSessionKey :=
  ⟨stepIdx, projectedNatAddressAt dec .regRaI⟩

def regWaKey
  {Addr : Type*}
  (stepIdx : Nat)
  (dec : DecodedStep Addr) : RegisterSessionKey :=
  ⟨stepIdx, projectedNatAddressAt dec .regWa⟩

theorem regRaXKey_bound_of_activeXIndexBound
  {Addr : Type*}
  {stepIdx : Nat}
  {dec : DecodedStep Addr}
  (hX : ActiveXIndexBound dec) :
  RegisterSessionKeyBound (regRaXKey stepIdx dec) := by
  have hX' : activeXIndex dec < 17 := by
    simpa [ActiveXIndexBound, regSinkAddr] using hX
  unfold RegisterSessionKeyBound regRaXKey
  dsimp [projectedNatAddressAt]
  have hCases : activeXIndex dec < 16 ∨ activeXIndex dec = 16 := by
    omega
  rcases hCases with hLt | hEq
  · exact Or.inl hLt
  · exact Or.inr (Or.inl hEq)

theorem regRaYKey_bound_of_shape
  {Addr : Type*}
  {stepIdx : Nat}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec) :
  RegisterSessionKeyBound (regRaYKey stepIdx dec) := by
  rcases stage1Decoded_usesY_bit hShape.1 with hUses | hUses
  · exact Or.inr (Or.inr (by simp [regRaYKey, projectedNatAddressAt, projectedYIndex, hUses, regSinkAddr]))
  · exact Or.inl (by
      have hWf := stage1Decoded_wellFormed hShape.1
      simpa [regRaYKey, projectedNatAddressAt, projectedYIndex, hUses, regSinkAddr] using hWf.2.1)

theorem regRaYKey_sink_iff_not_usesY
  {Addr : Type*}
  {stepIdx : Nat}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec) :
  (regRaYKey stepIdx dec).regAddr = regSinkAddr ↔ dec.usesY = 0 := by
  constructor
  · intro hEq
    rcases stage1Decoded_usesY_bit hShape.1 with hUses | hUses
    · exact hUses
    · have hNat : projectedNatAddressAt dec .regRaY = regSinkAddr := by
        simpa [regRaYKey] using hEq
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
    simp [regRaYKey, projectedNatAddressAt, projectedYIndex, hUses, regSinkAddr]

theorem regRaIKey_is_i
  {Addr : Type*}
  {stepIdx : Nat}
  {dec : DecodedStep Addr} :
  (regRaIKey stepIdx dec).regAddr = 16 := by
  simp [regRaIKey, projectedNatAddressAt]

theorem regRaIKey_bound
  {Addr : Type*}
  {stepIdx : Nat}
  {dec : DecodedStep Addr} :
  RegisterSessionKeyBound (regRaIKey stepIdx dec) := by
  exact Or.inr (Or.inl (regRaIKey_is_i (stepIdx := stepIdx) (dec := dec)))

theorem regWaKey_bound_of_shape
  {Addr : Type*}
  {stepIdx : Nat}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  (hX : ActiveXIndexBound dec) :
  RegisterSessionKeyBound (regWaKey stepIdx dec) := by
  have hX' : activeXIndex dec < 17 := by
    simpa [ActiveXIndexBound, regSinkAddr] using hX
  rcases stage1Decoded_laneWrite_cases hShape.1 with hWriteX | hWriteI | hSink
  · rcases hWriteX with ⟨hXWrite, hIWrite⟩
    have hNoSinkTerm : 1 - dec.writesLookupToX - dec.writesMemToX = 0 := by
      omega
    have hAddr : (regWaKey stepIdx dec).regAddr = activeXIndex dec := by
      simp [regWaKey, projectedNatAddressAt, hXWrite, hIWrite, hNoSinkTerm, regSinkAddr]
    have hCases : activeXIndex dec < 16 ∨ activeXIndex dec = 16 := by
      omega
    rcases hCases with hLt | hEq
    · exact Or.inl (by simpa [hAddr] using hLt)
    · exact Or.inr (Or.inl (by simpa [hAddr] using hEq))
  · rcases hWriteI with ⟨hXWrite, hIWrite⟩
    have hLookupZero : dec.writesLookupToX = 0 := by
      omega
    have hMemZero : dec.writesMemToX = 0 := by
      omega
    exact Or.inr (Or.inl (by
      simp [regWaKey, projectedNatAddressAt, hLookupZero, hMemZero, hIWrite, regSinkAddr]))
  · exact Or.inr (Or.inr (by
      rcases hSink with ⟨_, hIWrite⟩
      have hLookupZero : dec.writesLookupToX = 0 := by
        omega
      have hMemZero : dec.writesMemToX = 0 := by
        omega
      simp [regWaKey, projectedNatAddressAt, hIWrite, hLookupZero, hMemZero, regSinkAddr]))

theorem regWaKey_sink_iff_no_lane_write
  {Addr : Type*}
  {stepIdx : Nat}
  {dec : DecodedStep Addr}
  (hShape : DecodeAddressShape dec)
  (hX : ActiveXIndexBound dec) :
  (regWaKey stepIdx dec).regAddr = regSinkAddr ↔
    (dec.writesLookupToX + dec.writesMemToX = 0 ∧ dec.writesNnnToI = 0) := by
  have hX' : activeXIndex dec < 17 := by
    simpa [ActiveXIndexBound, regSinkAddr] using hX
  constructor
  · intro hEq
    have hNat : projectedNatAddressAt dec .regWa = regSinkAddr := by
      simpa [regWaKey] using hEq
    rcases stage1Decoded_laneWrite_cases hShape.1 with hWriteX | hWriteI | hSink
    · rcases hWriteX with ⟨hXWrite, hIWrite⟩
      have hNoSinkTerm : 1 - dec.writesLookupToX - dec.writesMemToX = 0 := by
        omega
      have hActiveEq : activeXIndex dec = regSinkAddr := by
        simpa [projectedNatAddressAt, hXWrite, hIWrite, hNoSinkTerm, regSinkAddr] using hNat
      exact False.elim ((Nat.ne_of_lt hX') hActiveEq)
    · rcases hWriteI with ⟨hXWrite, hIWrite⟩
      have hLookupZero : dec.writesLookupToX = 0 := by
        omega
      have hMemZero : dec.writesMemToX = 0 := by
        omega
      have : (16 : Nat) = regSinkAddr := by
        simp [projectedNatAddressAt, hLookupZero, hMemZero, hIWrite, regSinkAddr] at hNat
      norm_num [regSinkAddr] at this
    · exact hSink
  · intro hNoWrite
    rcases hNoWrite with ⟨_, hIWrite⟩
    have hLookupZero : dec.writesLookupToX = 0 := by
      omega
    have hMemZero : dec.writesMemToX = 0 := by
      omega
    simp [regWaKey, projectedNatAddressAt, hIWrite, hLookupZero, hMemZero, regSinkAddr]

end Nightstream.Chip8.RegisterSessionBoundary
