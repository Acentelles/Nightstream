import Nightstream.Chip8.Kernel.ChallengeDerivation
import Nightstream.Chip8.Kernel.Poseidon2GoldilocksCore

/-!
Owns the exact concrete specialization of the CHIP-8 `root0` digest and shared
kernel challenge layer to the concrete width-8 Poseidon2-over-Goldilocks core.
It adds no new transcript logic; it fixes the generic digest/challenge owners
to the actual production permutation surface.
-/

namespace Nightstream.Chip8.ConcreteTranscriptParity

open Nightstream.Chip8
open Nightstream.Chip8.Poseidon2Transcript
open Nightstream.Chip8.Root0Digest
open Nightstream.Chip8.ChallengeDerivation

abbrev concreteCore : Poseidon2Width8Core :=
  Nightstream.Chip8.Poseidon2GoldilocksCore.concreteCore

abbrev Byte := Poseidon2Transcript.Byte
abbrev FieldElem := Poseidon2Transcript.FieldElem
abbrev Cursor := Root0Digest.Cursor
abbrev ChallengePair := ChallengeDerivation.ChallengePair

def root0DigestCursor
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : Cursor :=
  Root0Digest.root0DigestCursor
    concreteCore encodeCommitmentDigest encodeDigest encodeRootParamsId
    transcriptSeed bindings pubMeta

def root0DigestWords
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : List Nat :=
  Root0Digest.root0DigestWords
    concreteCore encodeCommitmentDigest encodeDigest encodeRootParamsId
    transcriptSeed bindings pubMeta

def root0DigestBytes
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : List Byte :=
  Root0Digest.root0DigestBytes
    concreteCore encodeCommitmentDigest encodeDigest encodeRootParamsId
    transcriptSeed bindings pubMeta

def root0TranscriptCursor
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : Cursor :=
  ChallengeDerivation.root0TranscriptCursor
    concreteCore encodeCommitmentDigest encodeDigest encodeRootParamsId
    transcriptSeed bindings pubMeta

def sampleFieldCursor
    (cursor : Cursor)
    (label : String) : FieldElem × Cursor :=
  ChallengeDerivation.sampleFieldCursor concreteCore cursor label

def sampleChallengePairCursor
    (cursor : Cursor)
    (label : String) : ChallengePair × Cursor :=
  ChallengeDerivation.sampleChallengePairCursor concreteCore cursor label

def samplePointCursor
    (cursor : Cursor)
    (label : String)
    (n : Nat) : List ChallengePair × Cursor :=
  ChallengeDerivation.samplePointCursor concreteCore cursor label n

def sampleStage1LookupPointFromRoot0
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId)
    (cycleBits : Nat) : List ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage1LookupPointFromRoot0
    concreteCore encodeCommitmentDigest encodeDigest encodeRootParamsId
    transcriptSeed bindings pubMeta cycleBits

def sampleStage1GammaLookupLink
    (cursor : Cursor) : ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage1GammaLookupLink concreteCore cursor

def sampleStage2TwistCyclePoint
    (cursor : Cursor)
    (cycleBits : Nat) : List ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage2TwistCyclePoint concreteCore cursor cycleBits

def sampleStage2GammaReg
    (cursor : Cursor) : ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage2GammaReg concreteCore cursor

def sampleStage2GammaRam
    (cursor : Cursor) : ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage2GammaRam concreteCore cursor

def sampleStage2RegAddrPoint
    (cursor : Cursor)
    (addrRegBits : Nat) : List ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage2RegAddrPoint concreteCore cursor addrRegBits

def sampleStage2RamAddrPoint
    (cursor : Cursor)
    (addrRamBits : Nat) : List ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage2RamAddrPoint concreteCore cursor addrRamBits

def sampleStage2GammaTwistLink
    (cursor : Cursor) : ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage2GammaTwistLink concreteCore cursor

def sampleStage3Beta1
    (cursor : Cursor) : ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage3Beta1 concreteCore cursor

def sampleStage3Beta2
    (cursor : Cursor) : ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage3Beta2 concreteCore cursor

def sampleStage3ShiftPoint
    (cursor : Cursor)
    (cycleBits : Nat) : List ChallengePair × Cursor :=
  ChallengeDerivation.sampleStage3ShiftPoint concreteCore cursor cycleBits

@[simp] theorem root0DigestCursor_absorbed
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) :
    (root0DigestCursor
      encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).absorbed = 0 := by
  simp [root0DigestCursor, concreteCore]

@[simp] theorem root0DigestWords_length
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) :
    (root0DigestWords
      encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).length = 4 := by
  simp [root0DigestWords, concreteCore]

@[simp] theorem root0DigestBytes_length
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) :
    (root0DigestBytes
      encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).length = 32 := by
  simp [root0DigestBytes, concreteCore]

@[simp] theorem sampleFieldCursor_absorbed
    (cursor : Cursor)
    (label : String) :
    (sampleFieldCursor cursor label).2.absorbed = 0 := by
  simp [sampleFieldCursor, concreteCore]

@[simp] theorem sampleChallengePairCursor_absorbed
    (cursor : Cursor)
    (label : String) :
    (sampleChallengePairCursor cursor label).2.absorbed = 0 := by
  simp [sampleChallengePairCursor, concreteCore]

theorem samplePointCursor_length
    (cursor : Cursor)
    (label : String)
    (n : Nat) :
    (samplePointCursor cursor label n).1.length = n := by
  simpa [samplePointCursor, concreteCore] using
    ChallengeDerivation.samplePointCursor_length concreteCore cursor label n

@[simp] theorem sampleStage1LookupPointFromRoot0_length
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId)
    (cycleBits : Nat) :
    (sampleStage1LookupPointFromRoot0
      encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta cycleBits).1.length =
      cycleBits := by
  simp [sampleStage1LookupPointFromRoot0, concreteCore]

@[simp] theorem sampleStage2TwistCyclePoint_length
    (cursor : Cursor)
    (cycleBits : Nat) :
    (sampleStage2TwistCyclePoint cursor cycleBits).1.length = cycleBits := by
  simp [sampleStage2TwistCyclePoint, concreteCore]

@[simp] theorem sampleStage2RegAddrPoint_length
    (cursor : Cursor)
    (addrRegBits : Nat) :
    (sampleStage2RegAddrPoint cursor addrRegBits).1.length = addrRegBits := by
  simp [sampleStage2RegAddrPoint, concreteCore]

@[simp] theorem sampleStage2RamAddrPoint_length
    (cursor : Cursor)
    (addrRamBits : Nat) :
    (sampleStage2RamAddrPoint cursor addrRamBits).1.length = addrRamBits := by
  simp [sampleStage2RamAddrPoint, concreteCore]

@[simp] theorem sampleStage3ShiftPoint_length
    (cursor : Cursor)
    (cycleBits : Nat) :
    (sampleStage3ShiftPoint cursor cycleBits).1.length = cycleBits := by
  simp [sampleStage3ShiftPoint, concreteCore]

end Nightstream.Chip8.ConcreteTranscriptParity
