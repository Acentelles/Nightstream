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

structure TranscriptVectorCase where
  name : String
  transcriptSeed : List Byte
  commitmentBindings : List CommitmentBinding
  metaPub : MetaPub
  expectedRoot0TranscriptStateWords : List Nat
  expectedRoot0DigestStateWords : List Nat
  expectedRoot0DigestWords : List Nat
  expectedRoot0DigestBytes : List Byte
  expectedStage1LookupPoint : List ChallengePairWords
deriving Repr

def bytes (values : List Nat) : List Byte :=
  values.map UInt8.ofNat

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

def pairOfChallenge (value : ChallengePair) : ChallengePairWords :=
  { re := value.re.val, im := value.im.val }

def pointOfChallenges (values : List ChallengePair) : List ChallengePairWords :=
  values.map pairOfChallenge

def mkTranscriptVectorCase
    (name : String)
    (transcriptSeed : List Byte)
    (commitmentBindings : List CommitmentBinding)
    (metaPub : MetaPub)
    (expectedRoot0TranscriptStateWords : List Nat)
    (expectedRoot0DigestStateWords : List Nat)
    (expectedRoot0DigestWords : List Nat)
    (expectedRoot0DigestBytes : List Byte)
    (expectedStage1LookupPoint : List ChallengePairWords) : TranscriptVectorCase :=
  { name := name
  , transcriptSeed := transcriptSeed
  , commitmentBindings := commitmentBindings
  , metaPub := metaPub
  , expectedRoot0TranscriptStateWords := expectedRoot0TranscriptStateWords
  , expectedRoot0DigestStateWords := expectedRoot0DigestStateWords
  , expectedRoot0DigestWords := expectedRoot0DigestWords
  , expectedRoot0DigestBytes := expectedRoot0DigestBytes
  , expectedStage1LookupPoint := expectedStage1LookupPoint }

end Nightstream.Chip8.Generated
