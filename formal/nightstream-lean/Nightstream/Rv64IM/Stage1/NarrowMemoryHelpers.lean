import Mathlib

namespace Nightstream.Rv64IM

open scoped BigOperators

def byteAt (word k : Nat) : Nat :=
  (word / 2 ^ (8 * k)) % 256

def alignDown8 (addr : Nat) : Nat :=
  addr - addr % 8

def byteOffset8 (addr : Nat) : Nat :=
  addr % 8

theorem byteOffset8_lt (addr : Nat) : byteOffset8 addr < 8 := by
  simpa [byteOffset8] using Nat.mod_lt addr (by decide : 0 < 8)

theorem alignDown8_add_byteOffset8 (addr : Nat) :
  alignDown8 addr + byteOffset8 addr = addr := by
  simp [alignDown8, byteOffset8, Nat.sub_add_cancel (Nat.mod_le addr 8)]

def extractRaw (word off width : Nat) : Nat :=
  (word / 2 ^ (8 * off)) % (2 ^ (8 * width))

def signFill (word off width : Nat) : Nat :=
  if byteAt word (off + width - 1) ≥ 128 then 255 else 0

def extractExtend (word off width : Nat) (unsigned : Bool) : Nat :=
  if unsigned then
    extractRaw word off width
  else
    extractRaw word off width +
      Finset.sum (Finset.Icc width 7) (fun k => 2 ^ (8 * k) * signFill word off width)

def blend (word src off width : Nat) : Nat :=
  Finset.sum (Finset.range 8) fun k =>
    2 ^ (8 * k) *
      (if _ : off ≤ k ∧ k < off + width then
         byteAt src (k - off)
       else
         byteAt word k)

structure NarrowMemoryExtractProofPackage where
  word : Nat
  addr : Nat
  off : Nat
  width : Nat
  unsigned : Bool
  out : Nat
  offsetBinding : off = byteOffset8 addr
  extraction : out = extractExtend word off width unsigned

structure NarrowMemoryBlendProofPackage where
  word : Nat
  src : Nat
  addr : Nat
  off : Nat
  width : Nat
  out : Nat
  offsetBinding : off = byteOffset8 addr
  blended : out = blend word src off width

end Nightstream.Rv64IM
