import Nightstream.Chip8.Generated.TranscriptVectors

/-!
Executable parity checks for Rust-generated CHIP-8 concrete transcript vectors.
This owner only checks the protocol slice Lean can already recompute exactly:
the `root0` transcript state/digest and the first shared Stage-1 lookup point.
-/

namespace Nightstream.Chip8

open Nightstream.Chip8.Generated
open Nightstream.Chip8.ConcreteTranscriptParity
open Nightstream.Chip8.Poseidon2GoldilocksCore

private def idBytes (xs : List Generated.Byte) : List Generated.Byte := xs

private def root0TranscriptStateWords (case : TranscriptVectorCase) : List Nat :=
  stateWords
    ((root0TranscriptCursor
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub).st)

private def root0DigestStateWords (case : TranscriptVectorCase) : List Nat :=
  stateWords
    ((root0DigestCursor
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub).st)

private def stage1LookupPointWords (case : TranscriptVectorCase) : List ChallengePairWords :=
  pointOfChallenges
    ((sampleStage1LookupPointFromRoot0
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub
        case.metaPub.cycleBits).1)

structure TranscriptVectorReport where
  name : String
  root0TranscriptStateMatches : Bool
  root0DigestStateMatches : Bool
  root0DigestWordsMatches : Bool
  root0DigestBytesMatches : Bool
  stage1LookupPointMatches : Bool
  actualRoot0TranscriptStateWords : List Nat
  expectedRoot0TranscriptStateWords : List Nat
  actualRoot0DigestStateWords : List Nat
  expectedRoot0DigestStateWords : List Nat
  actualRoot0DigestWords : List Nat
  expectedRoot0DigestWords : List Nat
  actualRoot0DigestBytes : List Generated.Byte
  expectedRoot0DigestBytes : List Generated.Byte
  actualStage1LookupPoint : List ChallengePairWords
  expectedStage1LookupPoint : List ChallengePairWords
deriving Repr

def checkTranscriptVectorCase (case : TranscriptVectorCase) : Bool :=
  root0TranscriptStateWords case == case.expectedRoot0TranscriptStateWords &&
    root0DigestStateWords case == case.expectedRoot0DigestStateWords &&
    root0DigestWords
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub ==
      case.expectedRoot0DigestWords &&
    root0DigestBytes
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub ==
      case.expectedRoot0DigestBytes &&
    stage1LookupPointWords case == case.expectedStage1LookupPoint

def transcriptVectorChecks : List Bool :=
  Generated.transcriptVectorCases.map checkTranscriptVectorCase

def validGeneratedTranscriptVectorCases : Bool :=
  Generated.transcriptVectorCases.all checkTranscriptVectorCase

def transcriptVectorReports : List TranscriptVectorReport :=
  Generated.transcriptVectorCases.map fun case =>
    let actualRoot0TranscriptStateWords := root0TranscriptStateWords case
    let actualRoot0DigestStateWords := root0DigestStateWords case
    let actualRoot0DigestWords :=
      root0DigestWords
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub
    let actualRoot0DigestBytes :=
      root0DigestBytes
        idBytes idBytes idBytes
        case.transcriptSeed
        case.commitmentBindings
        case.metaPub
    let actualStage1LookupPoint := stage1LookupPointWords case
    { name := case.name
    , root0TranscriptStateMatches :=
        actualRoot0TranscriptStateWords == case.expectedRoot0TranscriptStateWords
    , root0DigestStateMatches :=
        actualRoot0DigestStateWords == case.expectedRoot0DigestStateWords
    , root0DigestWordsMatches :=
        actualRoot0DigestWords == case.expectedRoot0DigestWords
    , root0DigestBytesMatches :=
        actualRoot0DigestBytes == case.expectedRoot0DigestBytes
    , stage1LookupPointMatches :=
        actualStage1LookupPoint == case.expectedStage1LookupPoint
    , actualRoot0TranscriptStateWords := actualRoot0TranscriptStateWords
    , expectedRoot0TranscriptStateWords := case.expectedRoot0TranscriptStateWords
    , actualRoot0DigestStateWords := actualRoot0DigestStateWords
    , expectedRoot0DigestStateWords := case.expectedRoot0DigestStateWords
    , actualRoot0DigestWords := actualRoot0DigestWords
    , expectedRoot0DigestWords := case.expectedRoot0DigestWords
    , actualRoot0DigestBytes := actualRoot0DigestBytes
    , expectedRoot0DigestBytes := case.expectedRoot0DigestBytes
    , actualStage1LookupPoint := actualStage1LookupPoint
    , expectedStage1LookupPoint := case.expectedStage1LookupPoint }

end Nightstream.Chip8
