import Nightstream.Chip8.Kernel.Root0Digest

/-!
Owns exact Rust-compatible challenge sampling above the CHIP-8 transcript
cursor. This file fixes `sample_k`, `sample_point`, the explicit shared kernel
challenge labels, and the pre-digest `root0` continuation cursor used before
Stage 1. It does not own the concrete Poseidon2 permutation or stage-local
sumcheck round transcripts.
-/

namespace Nightstream.Chip8.ChallengeDerivation

open Nightstream.Chip8
open Nightstream.Chip8.Poseidon2Transcript
open Nightstream.Chip8.Root0Digest

structure ChallengePair where
  re : FieldElem
  im : FieldElem
deriving Repr, Inhabited, DecidableEq

def stage1LookupLabel : String := "stage1/r_lookup"
def stage1GammaLookupLinkLabel : String := "stage1/gamma_lookup_link"
def stage2TwistCycleLabel : String := "stage2/r_cycle"
def stage2GammaRegLabel : String := "stage2/gamma_reg"
def stage2GammaRamLabel : String := "stage2/gamma_ram"
def stage2RegAddrLabel : String := "stage2/r_addr_reg"
def stage2RamAddrLabel : String := "stage2/r_addr_ram"
def stage2GammaTwistLinkLabel : String := "stage2/gamma_twist_link"
def stage3Beta1Label : String := "stage3/beta1"
def stage3Beta2Label : String := "stage3/beta2"
def stage3ShiftLabel : String := "stage3/r_shift"

def sampleFieldCursor
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) : FieldElem × Cursor :=
  (challengeFieldValue core cursor label, challengeFieldCursor core cursor label)

def sampleChallengePairCursor
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) : ChallengePair × Cursor :=
  let (c0, cursor₁) := sampleFieldCursor core cursor label
  let (c1, cursor₂) := sampleFieldCursor core cursor₁ label
  ({ re := c0, im := c1 }, cursor₂)

def samplePointCursor
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) : Nat → List ChallengePair × Cursor
  | 0 => ([], cursor)
  | n + 1 =>
      let (head, cursor₁) := sampleChallengePairCursor core cursor label
      let (tail, cursor₂) := samplePointCursor core cursor₁ label n
      (head :: tail, cursor₂)

def root0TranscriptCursor
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : Cursor :=
  runOps core emptyCursor
    (root0TranscriptOps
      encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta)

def sampleStage1LookupPointFromRoot0
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId)
    (cycleBits : Nat) : List ChallengePair × Cursor :=
  samplePointCursor
    core
    (root0TranscriptCursor
      core encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta)
    stage1LookupLabel
    cycleBits

def sampleStage1GammaLookupLink
    (core : Poseidon2Width8Core)
    (cursor : Cursor) : ChallengePair × Cursor :=
  sampleChallengePairCursor core cursor stage1GammaLookupLinkLabel

def sampleStage2TwistCyclePoint
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (cycleBits : Nat) : List ChallengePair × Cursor :=
  samplePointCursor core cursor stage2TwistCycleLabel cycleBits

def sampleStage2GammaReg
    (core : Poseidon2Width8Core)
    (cursor : Cursor) : ChallengePair × Cursor :=
  sampleChallengePairCursor core cursor stage2GammaRegLabel

def sampleStage2GammaRam
    (core : Poseidon2Width8Core)
    (cursor : Cursor) : ChallengePair × Cursor :=
  sampleChallengePairCursor core cursor stage2GammaRamLabel

def sampleStage2RegAddrPoint
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (addrRegBits : Nat) : List ChallengePair × Cursor :=
  samplePointCursor core cursor stage2RegAddrLabel addrRegBits

def sampleStage2RamAddrPoint
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (addrRamBits : Nat) : List ChallengePair × Cursor :=
  samplePointCursor core cursor stage2RamAddrLabel addrRamBits

def sampleStage2GammaTwistLink
    (core : Poseidon2Width8Core)
    (cursor : Cursor) : ChallengePair × Cursor :=
  sampleChallengePairCursor core cursor stage2GammaTwistLinkLabel

def sampleStage3Beta1
    (core : Poseidon2Width8Core)
    (cursor : Cursor) : ChallengePair × Cursor :=
  sampleChallengePairCursor core cursor stage3Beta1Label

def sampleStage3Beta2
    (core : Poseidon2Width8Core)
    (cursor : Cursor) : ChallengePair × Cursor :=
  sampleChallengePairCursor core cursor stage3Beta2Label

def sampleStage3ShiftPoint
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (cycleBits : Nat) : List ChallengePair × Cursor :=
  samplePointCursor core cursor stage3ShiftLabel cycleBits

@[simp] theorem sampleFieldCursor_absorbed
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) :
    (sampleFieldCursor core cursor label).2.absorbed = 0 := by
  simp [sampleFieldCursor]

@[simp] theorem sampleChallengePairCursor_absorbed
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) :
    (sampleChallengePairCursor core cursor label).2.absorbed = 0 := by
  simp [sampleChallengePairCursor, sampleFieldCursor]

theorem samplePointCursor_length
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String)
    (n : Nat) :
    (samplePointCursor core cursor label n).1.length = n := by
  induction n generalizing cursor with
  | zero =>
      simp [samplePointCursor]
  | succ n ih =>
      simp [samplePointCursor, ih]

@[simp] theorem samplePointCursor_succ_absorbed
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String)
    (n : Nat) :
    (samplePointCursor core cursor label (n + 1)).2.absorbed = 0 := by
  induction n generalizing cursor with
  | zero =>
      simp [samplePointCursor, sampleChallengePairCursor, sampleFieldCursor]
  | succ n ih =>
      simp [samplePointCursor]
      exact ih _

@[simp] theorem sampleStage1LookupPointFromRoot0_length
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId)
    (cycleBits : Nat) :
    (sampleStage1LookupPointFromRoot0
      core encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta cycleBits).1.length =
      cycleBits := by
  simp [sampleStage1LookupPointFromRoot0, samplePointCursor_length]

@[simp] theorem sampleStage2TwistCyclePoint_length
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (cycleBits : Nat) :
    (sampleStage2TwistCyclePoint core cursor cycleBits).1.length = cycleBits := by
  simp [sampleStage2TwistCyclePoint, samplePointCursor_length]

@[simp] theorem sampleStage2RegAddrPoint_length
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (addrRegBits : Nat) :
    (sampleStage2RegAddrPoint core cursor addrRegBits).1.length = addrRegBits := by
  simp [sampleStage2RegAddrPoint, samplePointCursor_length]

@[simp] theorem sampleStage2RamAddrPoint_length
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (addrRamBits : Nat) :
    (sampleStage2RamAddrPoint core cursor addrRamBits).1.length = addrRamBits := by
  simp [sampleStage2RamAddrPoint, samplePointCursor_length]

@[simp] theorem sampleStage3ShiftPoint_length
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (cycleBits : Nat) :
    (sampleStage3ShiftPoint core cursor cycleBits).1.length = cycleBits := by
  simp [sampleStage3ShiftPoint, samplePointCursor_length]

end Nightstream.Chip8.ChallengeDerivation
