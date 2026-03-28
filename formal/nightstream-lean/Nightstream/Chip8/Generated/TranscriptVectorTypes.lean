import Nightstream.Chip8.Kernel.ConcreteTranscriptParity

/-!
Owns the generated-case surface for the CHIP-8 concrete transcript parity lane.
It packages Rust-exported `root0` and first-shared-challenge vectors in the
exact Lean-owned types consumed by `Nightstream.Chip8.Checks`.
-/

namespace Nightstream.Chip8.Generated

open Nightstream.Chip8
open Nightstream.Chip8.Poseidon2Transcript
open Nightstream.Chip8.Root0Preimage
open Nightstream.Chip8.MetaPubEncoding
open Nightstream.Chip8.ChallengeDerivation
open Nightstream.Chip8.ExactOpeningBoundary

abbrev Byte := Poseidon2Transcript.Byte
abbrev CommitmentBinding := Root0Preimage.Root0CommitmentDigestBinding (List Byte)
abbrev MetaPub := MetaPubEncoding.KernelMetaPub (List Byte) (List Byte)

structure ChallengePairWords where
  re : Nat
  im : Nat
deriving DecidableEq, Repr

structure CursorSnapshotWords where
  stateWords : List Nat
  absorbed : Nat
deriving DecidableEq, Repr

def regAddrBits : Nat := 5
def ramAddrBits : Nat := 13

structure TranscriptVectorCase where
  name : String
  transcriptSeed : List Byte
  commitmentBindings : List CommitmentBinding
  metaPub : MetaPub
  expectedRoot0TranscriptCursor : CursorSnapshotWords
  expectedRoot0DigestCursor : CursorSnapshotWords
  expectedRoot0DigestWords : List Nat
  expectedRoot0DigestBytes : List Byte
  expectedStage1LookupPoint : List ChallengePairWords
  expectedStage1GammaLookupLinkCursor : CursorSnapshotWords
  expectedStage1GammaLookupLink : ChallengePairWords
  expectedStage2TwistCycleCursor : CursorSnapshotWords
  expectedStage2TwistCyclePoint : List ChallengePairWords
  expectedStage2GammaRegCursor : CursorSnapshotWords
  expectedStage2GammaReg : ChallengePairWords
  expectedStage2RegAddrCursor : CursorSnapshotWords
  expectedStage2RegAddrPoint : List ChallengePairWords
  expectedStage2GammaRamCursor : CursorSnapshotWords
  expectedStage2GammaRam : ChallengePairWords
  expectedStage2RamAddrCursor : CursorSnapshotWords
  expectedStage2RamAddrPoint : List ChallengePairWords
  expectedStage2GammaTwistLinkCursor : CursorSnapshotWords
  expectedStage2GammaTwistLink : ChallengePairWords
  expectedStage3Beta1Cursor : CursorSnapshotWords
  expectedStage3Beta1 : ChallengePairWords
  expectedStage3Beta2Cursor : CursorSnapshotWords
  expectedStage3Beta2 : ChallengePairWords
  expectedStage3ShiftCursor : CursorSnapshotWords
  expectedStage3ShiftPoint : List ChallengePairWords
  expectedStage3GammaShiftCursor : CursorSnapshotWords
  expectedStage3GammaShift : ChallengePairWords
deriving Repr

def bytes (values : List Nat) : List Byte :=
  values.map UInt8.ofNat

def zeroBytes (n : Nat) : List Byte :=
  bytes (List.replicate n 0)

def mkMetaPub
    (programImageDigest : List Byte)
    (initialStateDigest : List Byte)
    (romTableDigest : List Byte)
    (decodeTableDigest : List Byte)
    (aluTableDigest : List Byte)
    (eq4TableDigest : List Byte)
    (transcriptSeedDigest : List Byte)
    (protocolVersionId : Nat)
    (fieldId : Nat)
    (extensionFieldId : Nat)
    (rootParamsId : List Byte)
    (variableOrderId : Nat)
    (domainShapeId : Nat)
    (sinkConventionId : Nat)
    (initModeId : Nat)
    (loweringConventionId : Nat)
    (paddingConventionId : Nat)
    (tableAuthModeId : Nat)
    (openingReductionModeId : Nat)
    (programWordCount : Nat)
    (semanticRows : Nat)
    (paddedTraceLength : Nat)
    (padPcWord : Nat)
    (programBaseAddr : Nat)
    (cycleBits : Nat) : MetaPub :=
  { programImageDigest := programImageDigest
  , initialStateDigest := initialStateDigest
  , romTableDigest := romTableDigest
  , decodeTableDigest := decodeTableDigest
  , aluTableDigest := aluTableDigest
  , eq4TableDigest := eq4TableDigest
  , transcriptSeedDigest := transcriptSeedDigest
  , protocolVersionId := protocolVersionId
  , fieldId := fieldId
  , extensionFieldId := extensionFieldId
  , rootParamsId := rootParamsId
  , variableOrderId := variableOrderId
  , domainShapeId := domainShapeId
  , sinkConventionId := sinkConventionId
  , initModeId := initModeId
  , loweringConventionId := loweringConventionId
  , paddingConventionId := paddingConventionId
  , tableAuthModeId := tableAuthModeId
  , openingReductionModeId := openingReductionModeId
  , programWordCount := programWordCount
  , semanticRows := semanticRows
  , paddedTraceLength := paddedTraceLength
  , padPcWord := padPcWord
  , programBaseAddr := programBaseAddr
  , cycleBits := cycleBits }

def binding (id : ExactOpeningBoundary.CommitmentId) (digest : List Byte) : CommitmentBinding :=
  { id := id, digest := digest }

def pair (re im : Nat) : ChallengePairWords :=
  { re := re, im := im }

def cursorSnapshot (stateWords : List Nat) (absorbed : Nat) : CursorSnapshotWords :=
  { stateWords := stateWords, absorbed := absorbed }

def pairOfChallenge (value : ChallengePair) : ChallengePairWords :=
  { re := value.re.val, im := value.im.val }

def pointOfChallenges (values : List ChallengePair) : List ChallengePairWords :=
  values.map pairOfChallenge

def mkTranscriptVectorCase
    (name : String)
    (transcriptSeed : List Byte)
    (commitmentBindings : List CommitmentBinding)
    (metaPub : MetaPub)
    (expectedRoot0TranscriptCursor : CursorSnapshotWords)
    (expectedRoot0DigestCursor : CursorSnapshotWords)
    (expectedRoot0DigestWords : List Nat)
    (expectedRoot0DigestBytes : List Byte)
    (expectedStage1LookupPoint : List ChallengePairWords)
    (expectedStage1GammaLookupLinkCursor : CursorSnapshotWords)
    (expectedStage1GammaLookupLink : ChallengePairWords)
    (expectedStage2TwistCycleCursor : CursorSnapshotWords)
    (expectedStage2TwistCyclePoint : List ChallengePairWords)
    (expectedStage2GammaRegCursor : CursorSnapshotWords)
    (expectedStage2GammaReg : ChallengePairWords)
    (expectedStage2RegAddrCursor : CursorSnapshotWords)
    (expectedStage2RegAddrPoint : List ChallengePairWords)
    (expectedStage2GammaRamCursor : CursorSnapshotWords)
    (expectedStage2GammaRam : ChallengePairWords)
    (expectedStage2RamAddrCursor : CursorSnapshotWords)
    (expectedStage2RamAddrPoint : List ChallengePairWords)
    (expectedStage2GammaTwistLinkCursor : CursorSnapshotWords)
    (expectedStage2GammaTwistLink : ChallengePairWords)
    (expectedStage3Beta1Cursor : CursorSnapshotWords)
    (expectedStage3Beta1 : ChallengePairWords)
    (expectedStage3Beta2Cursor : CursorSnapshotWords)
    (expectedStage3Beta2 : ChallengePairWords)
    (expectedStage3ShiftCursor : CursorSnapshotWords)
    (expectedStage3ShiftPoint : List ChallengePairWords)
    (expectedStage3GammaShiftCursor : CursorSnapshotWords)
    (expectedStage3GammaShift : ChallengePairWords) : TranscriptVectorCase :=
  { name := name
  , transcriptSeed := transcriptSeed
  , commitmentBindings := commitmentBindings
  , metaPub := metaPub
  , expectedRoot0TranscriptCursor := expectedRoot0TranscriptCursor
  , expectedRoot0DigestCursor := expectedRoot0DigestCursor
  , expectedRoot0DigestWords := expectedRoot0DigestWords
  , expectedRoot0DigestBytes := expectedRoot0DigestBytes
  , expectedStage1LookupPoint := expectedStage1LookupPoint
  , expectedStage1GammaLookupLinkCursor := expectedStage1GammaLookupLinkCursor
  , expectedStage1GammaLookupLink := expectedStage1GammaLookupLink
  , expectedStage2TwistCycleCursor := expectedStage2TwistCycleCursor
  , expectedStage2TwistCyclePoint := expectedStage2TwistCyclePoint
  , expectedStage2GammaRegCursor := expectedStage2GammaRegCursor
  , expectedStage2GammaReg := expectedStage2GammaReg
  , expectedStage2RegAddrCursor := expectedStage2RegAddrCursor
  , expectedStage2RegAddrPoint := expectedStage2RegAddrPoint
  , expectedStage2GammaRamCursor := expectedStage2GammaRamCursor
  , expectedStage2GammaRam := expectedStage2GammaRam
  , expectedStage2RamAddrCursor := expectedStage2RamAddrCursor
  , expectedStage2RamAddrPoint := expectedStage2RamAddrPoint
  , expectedStage2GammaTwistLinkCursor := expectedStage2GammaTwistLinkCursor
  , expectedStage2GammaTwistLink := expectedStage2GammaTwistLink
  , expectedStage3Beta1Cursor := expectedStage3Beta1Cursor
  , expectedStage3Beta1 := expectedStage3Beta1
  , expectedStage3Beta2Cursor := expectedStage3Beta2Cursor
  , expectedStage3Beta2 := expectedStage3Beta2
  , expectedStage3ShiftCursor := expectedStage3ShiftCursor
  , expectedStage3ShiftPoint := expectedStage3ShiftPoint
  , expectedStage3GammaShiftCursor := expectedStage3GammaShiftCursor
  , expectedStage3GammaShift := expectedStage3GammaShift }

end Nightstream.Chip8.Generated
