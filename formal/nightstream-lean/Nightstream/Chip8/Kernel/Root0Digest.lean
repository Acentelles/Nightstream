import Nightstream.Chip8.Kernel.Poseidon2Transcript

/-!
Owns the exact width-8/rate-4 sponge mechanics above the CHIP-8 transcript
packing layer. This file fixes cursor movement, `digest32`, `challenge_field`,
and `root0` digest extraction, leaving only the concrete Poseidon2 permutation
as an explicit parameter.
-/

namespace Nightstream.Chip8.Root0Digest

open Nightstream.Chip8
open Nightstream.Chip8.Poseidon2Transcript

structure State where
  x0 : FieldElem
  x1 : FieldElem
  x2 : FieldElem
  x3 : FieldElem
  x4 : FieldElem
  x5 : FieldElem
  x6 : FieldElem
  x7 : FieldElem
deriving Repr, Inhabited

def State.get (st : State) : Fin 8 → FieldElem
  | ⟨0, _⟩ => st.x0
  | ⟨1, _⟩ => st.x1
  | ⟨2, _⟩ => st.x2
  | ⟨3, _⟩ => st.x3
  | ⟨4, _⟩ => st.x4
  | ⟨5, _⟩ => st.x5
  | ⟨6, _⟩ => st.x6
  | ⟨7, _⟩ => st.x7

instance : CoeFun State (fun _ => Fin 8 → FieldElem) where
  coe := State.get

def State.set (st : State) (idx : Fin 8) (value : FieldElem) : State :=
  match idx with
  | ⟨0, _⟩ => { st with x0 := value }
  | ⟨1, _⟩ => { st with x1 := value }
  | ⟨2, _⟩ => { st with x2 := value }
  | ⟨3, _⟩ => { st with x3 := value }
  | ⟨4, _⟩ => { st with x4 := value }
  | ⟨5, _⟩ => { st with x5 := value }
  | ⟨6, _⟩ => { st with x6 := value }
  | ⟨7, _⟩ => { st with x7 := value }

def rate : Nat := 4
def width : Nat := 8

structure Poseidon2Width8Core where
  permute : State → State

def zeroState : State :=
  { x0 := 0
  , x1 := 0
  , x2 := 0
  , x3 := 0
  , x4 := 0
  , x5 := 0
  , x6 := 0
  , x7 := 0 }

structure Cursor where
  st : State
  absorbed : Nat

def emptyCursor : Cursor :=
  { st := zeroState, absorbed := 0 }

def permuteCursor (core : Poseidon2Width8Core) (cursor : Cursor) : Cursor :=
  { st := core.permute cursor.st, absorbed := 0 }

def absorbElem (core : Poseidon2Width8Core) (cursor : Cursor) (x : FieldElem) : Cursor :=
  if h : cursor.absorbed < rate then
    have hWidth : cursor.absorbed < width :=
      Nat.lt_of_lt_of_le h (by decide : rate ≤ width)
    { st := cursor.st.set ⟨cursor.absorbed, hWidth⟩ x
    , absorbed := cursor.absorbed + 1
    }
  else
    { st := (core.permute cursor.st).set ⟨0, by decide⟩ x
    , absorbed := 1
    }

def absorbFields (core : Poseidon2Width8Core) : Cursor → List FieldElem → Cursor
  | cursor, [] => cursor
  | cursor, x :: xs => absorbFields core (absorbElem core cursor x) xs

def appendMessageCursor
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String)
    (msg : List Byte) : Cursor :=
  absorbFields core cursor (toFieldElems (appendMessageWords label msg))

def appendU64sCursor
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String)
    (values : List Nat) : Cursor :=
  absorbFields core cursor (toFieldElems (appendU64Words label values))

def digestCursor (core : Poseidon2Width8Core) (cursor : Cursor) : Cursor :=
  permuteCursor core (absorbElem core cursor 1)

def challengeFieldCursor
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) : Cursor :=
  digestCursor core (appendMessageCursor core cursor challengeLabelLabel (utf8Bytes label))

def challengeFieldValue
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) : FieldElem :=
  (challengeFieldCursor core cursor label).st ⟨0, by decide⟩

def applyOp (core : Poseidon2Width8Core) (cursor : Cursor) : TranscriptOp → Cursor
  | .appendMessage label msg => appendMessageCursor core cursor label msg
  | .appendU64s label values => appendU64sCursor core cursor label values
  | .digest32 => digestCursor core cursor
  | .challengeField label => challengeFieldCursor core cursor label

def runOps (core : Poseidon2Width8Core) : Cursor → List TranscriptOp → Cursor
  | cursor, [] => cursor
  | cursor, op :: ops => runOps core (applyOp core cursor op) ops

def firstDigestWords (state : State) : List Nat :=
  List.ofFn (fun i : Fin 4 => (state ⟨i.1, Nat.lt_trans i.isLt (by decide)⟩).val)

def natToLeBytes : Nat → Nat → List Byte
  | 0, _ => []
  | n + 1, value => UInt8.ofNat value :: natToLeBytes n (value / 256)

def wordToLeBytes8 (word : Nat) : List Byte :=
  natToLeBytes 8 word

def wordsToLeBytes : List Nat → List Byte
  | [] => []
  | word :: words => wordToLeBytes8 word ++ wordsToLeBytes words

def digestWords (core : Poseidon2Width8Core) (cursor : Cursor) : List Nat :=
  firstDigestWords (digestCursor core cursor).st

def digestBytes (core : Poseidon2Width8Core) (cursor : Cursor) : List Byte :=
  wordsToLeBytes (digestWords core cursor)

def root0DigestCursor
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : Cursor :=
  runOps core emptyCursor
    (root0DigestOps
      encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta)

def root0DigestWords
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : List Nat :=
  firstDigestWords
    (root0DigestCursor
      core encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).st

def root0DigestBytes
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) : List Byte :=
  wordsToLeBytes
    (root0DigestWords
      core encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta)

@[simp] theorem emptyCursor_absorbed :
    emptyCursor.absorbed = 0 := rfl

@[simp] theorem permuteCursor_absorbed
    (core : Poseidon2Width8Core)
    (cursor : Cursor) :
    (permuteCursor core cursor).absorbed = 0 := rfl

@[simp] theorem digestCursor_absorbed
    (core : Poseidon2Width8Core)
    (cursor : Cursor) :
    (digestCursor core cursor).absorbed = 0 := by
  simp [digestCursor, permuteCursor]

@[simp] theorem challengeFieldCursor_absorbed
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (label : String) :
    (challengeFieldCursor core cursor label).absorbed = 0 := by
  simp [challengeFieldCursor]

theorem runOps_append
    (core : Poseidon2Width8Core)
    (cursor : Cursor)
    (ops₁ ops₂ : List TranscriptOp) :
    runOps core cursor (ops₁ ++ ops₂) =
      runOps core (runOps core cursor ops₁) ops₂ := by
  induction ops₁ generalizing cursor with
  | nil =>
      simp [runOps]
  | cons op ops ih =>
      simp [runOps, ih]

@[simp] theorem firstDigestWords_length (state : State) :
    (firstDigestWords state).length = 4 := by
  simp [firstDigestWords]

@[simp] theorem wordToLeBytes8_length (word : Nat) :
    (wordToLeBytes8 word).length = 8 := by
  simp [wordToLeBytes8, natToLeBytes]

theorem wordsToLeBytes_length (words : List Nat) :
    (wordsToLeBytes words).length = 8 * words.length := by
  induction words with
  | nil =>
      simp [wordsToLeBytes]
  | cons word words ih =>
      simp [wordsToLeBytes, wordToLeBytes8_length, ih]
      omega

@[simp] theorem digestWords_length
    (core : Poseidon2Width8Core)
    (cursor : Cursor) :
    (digestWords core cursor).length = 4 := by
  simp [digestWords, firstDigestWords_length]

@[simp] theorem digestBytes_length
    (core : Poseidon2Width8Core)
    (cursor : Cursor) :
    (digestBytes core cursor).length = 32 := by
  simp [digestBytes, wordsToLeBytes_length]

@[simp] theorem root0DigestCursor_absorbed
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) :
    (root0DigestCursor
      core encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).absorbed = 0 := by
  rw [root0DigestCursor, root0DigestOps, runOps_append]
  simp [runOps, applyOp, digestCursor, permuteCursor]

@[simp] theorem root0DigestWords_length
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) :
    (root0DigestWords
      core encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).length = 4 := by
  simp [root0DigestWords, firstDigestWords_length]

@[simp] theorem root0DigestBytes_length
    (core : Poseidon2Width8Core)
    (encodeCommitmentDigest : CommitmentDigest → List Byte)
    (encodeDigest : Digest → List Byte)
    (encodeRootParamsId : RootParamsId → List Byte)
    (transcriptSeed : List Byte)
    (bindings : List (Nightstream.Chip8.Root0Preimage.Root0CommitmentDigestBinding CommitmentDigest))
    (pubMeta : Nightstream.Chip8.MetaPubEncoding.KernelMetaPub Digest RootParamsId) :
    (root0DigestBytes
      core encodeCommitmentDigest encodeDigest encodeRootParamsId transcriptSeed bindings pubMeta).length = 32 := by
  simp [root0DigestBytes, wordsToLeBytes_length]

end Nightstream.Chip8.Root0Digest
