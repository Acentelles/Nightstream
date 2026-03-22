import Nightstream.Chip8.Generated.TranscriptVectorTypes
import Nightstream.Chip8.Stage1.FetchDecodeBinding
import Nightstream.Chip8.Stage3.ContinuityBridge
import Nightstream.Chip8.Kernel.OpeningBoundary

/-!
Owns the generated-case surface for CHIP-8 staged-execution bundle parity.
These are proof-free external artifact views used for Rust↔Lean exact-equality
checks over the chunk-level staged bundle boundary.
-/

namespace Nightstream.Chip8.Generated

open Nightstream.Chip8.FetchDecodeBinding
open Nightstream.Chip8.ContinuityBridge
open Nightstream.Chip8.ExactOpeningBoundary

structure PublicInputView where
  programImage : List Byte
  initialPcWord : Nat
  initialRegisters : List Byte
  initialI : Nat
  initialRam : List Byte
  transcriptSeed : List Byte
deriving DecidableEq, Repr

structure DigestPublicView where
  publicInput : PublicInputView
  metaPub : MetaPub
deriving DecidableEq, Repr

structure MachineStateView where
  pc : Nat
  i : Nat
  registers : List Byte
  ram : List Byte
deriving DecidableEq, Repr

structure FrameDecodeView where
  opcodeId : OpcodeId
  x : Nat
  y : Nat
  kk : Nat
  nnn : Nat
  opcodeWord : Nat
  pcWord : Nat
  rowXIdx : Nat
  rowYIdx : Nat
  isMemOp : Bool
  burstLast : Bool
  ramAddr : Nat
deriving DecidableEq, Repr

structure FrameSourceView where
  stepIdx : Nat
  dec : FrameDecodeView
  pre : MachineStateView
  post : MachineStateView
  row : List Nat
deriving DecidableEq, Repr

structure Stage1View where
  pre : MachineStateView
  dec : FrameDecodeView
  row : List Nat
deriving DecidableEq, Repr

structure Stage2View where
  pre : MachineStateView
  post : MachineStateView
  dec : FrameDecodeView
  row : List Nat
deriving DecidableEq, Repr

structure ExecutionResultView where
  stepIdx : Nat
  pre : MachineStateView
  post : MachineStateView
  dec : FrameDecodeView
deriving DecidableEq, Repr

structure Stage3ShiftClaimView where
  sourceCommitment : CommitmentId
  sourcePoint : List ChallengePairWords
  sourceColumns : List LaneColumn
  shiftedColumns : List ShiftedLaneColumn
  claimedShiftValues : List ChallengePairWords
deriving DecidableEq, Repr

structure Stage3ShiftWitnessView where
  shiftPc : ChallengePairWords
  shiftXIdx : ChallengePairWords
  shiftIsMemOp : ChallengePairWords
  reductionRounds : List (List ChallengePairWords)
deriving DecidableEq, Repr

structure Stage3CurrentRowView where
  rowIndex : Nat
  pairMask : Nat
  pcNext : Nat
  xIdx : Nat
  isMemOp : Nat
  burstLast : Nat
deriving DecidableEq, Repr

structure Stage3RowClaimView where
  rowIndex : Nat
  rowBits : List Bool
  openedValues : List ChallengePairWords
deriving DecidableEq, Repr

structure Stage3View where
  stepIdx : Nat
  n : Nat
  beta1 : ChallengePairWords
  beta2 : ChallengePairWords
  shiftClaim : Stage3ShiftClaimView
  shiftProof : Stage3ShiftWitnessView
  currentRow : Stage3CurrentRowView
  rowClaim : Stage3RowClaimView
  preparedStepDigest : List Byte
deriving DecidableEq, Repr

structure StagedExecutionDigestView where
  stage1 : Stage1View
  stage2 : Stage2View
  stage3 : Stage3View
  result : ExecutionResultView
deriving DecidableEq, Repr

structure StagedExecutionDigestBundleView where
  publicSurface : DigestPublicView
  digests : List StagedExecutionDigestView
deriving DecidableEq, Repr

structure StagedExecutionDigestBundleVectorCase where
  name : String
  publicSurface : DigestPublicView
  frames : List FrameSourceView
  stage3s : List Stage3View
  expectedBundle : StagedExecutionDigestBundleView
deriving Repr

def mkPublicInputView
    (programImage : List Byte)
    (initialPcWord : Nat)
    (initialRegisters : List Byte)
    (initialI : Nat)
    (initialRam : List Byte)
    (transcriptSeed : List Byte) : PublicInputView :=
  { programImage := programImage
  , initialPcWord := initialPcWord
  , initialRegisters := initialRegisters
  , initialI := initialI
  , initialRam := initialRam
  , transcriptSeed := transcriptSeed }

def mkDigestPublicView
    (publicInput : PublicInputView)
    (metaPub : MetaPub) : DigestPublicView :=
  { publicInput := publicInput, metaPub := metaPub }

def mkMachineStateView
    (pc : Nat)
    (i : Nat)
    (registers : List Byte)
    (ram : List Byte) : MachineStateView :=
  { pc := pc, i := i, registers := registers, ram := ram }

def mkFrameDecodeView
    (opcodeId : OpcodeId)
    (x y kk nnn opcodeWord pcWord rowXIdx rowYIdx : Nat)
    (isMemOp burstLast : Bool)
    (ramAddr : Nat) : FrameDecodeView :=
  { opcodeId := opcodeId
  , x := x
  , y := y
  , kk := kk
  , nnn := nnn
  , opcodeWord := opcodeWord
  , pcWord := pcWord
  , rowXIdx := rowXIdx
  , rowYIdx := rowYIdx
  , isMemOp := isMemOp
  , burstLast := burstLast
  , ramAddr := ramAddr }

def mkFrameSourceView
    (stepIdx : Nat)
    (dec : FrameDecodeView)
    (pre post : MachineStateView)
    (row : List Nat) : FrameSourceView :=
  { stepIdx := stepIdx, dec := dec, pre := pre, post := post, row := row }

def mkStage3ShiftClaimView
    (sourceCommitment : CommitmentId)
    (sourcePoint : List ChallengePairWords)
    (sourceColumns : List LaneColumn)
    (shiftedColumns : List ShiftedLaneColumn)
    (claimedShiftValues : List ChallengePairWords) : Stage3ShiftClaimView :=
  { sourceCommitment := sourceCommitment
  , sourcePoint := sourcePoint
  , sourceColumns := sourceColumns
  , shiftedColumns := shiftedColumns
  , claimedShiftValues := claimedShiftValues }

def mkStage3ShiftWitnessView
    (shiftPc shiftXIdx shiftIsMemOp : ChallengePairWords)
    (reductionRounds : List (List ChallengePairWords)) :
    Stage3ShiftWitnessView :=
  { shiftPc := shiftPc
  , shiftXIdx := shiftXIdx
  , shiftIsMemOp := shiftIsMemOp
  , reductionRounds := reductionRounds }

def mkStage3CurrentRowView
    (rowIndex pairMask pcNext xIdx isMemOp burstLast : Nat) :
    Stage3CurrentRowView :=
  { rowIndex := rowIndex
  , pairMask := pairMask
  , pcNext := pcNext
  , xIdx := xIdx
  , isMemOp := isMemOp
  , burstLast := burstLast }

def mkStage3RowClaimView
    (rowIndex : Nat)
    (rowBits : List Bool)
    (openedValues : List ChallengePairWords) : Stage3RowClaimView :=
  { rowIndex := rowIndex
  , rowBits := rowBits
  , openedValues := openedValues }

def mkStage3View
    (stepIdx n : Nat)
    (beta1 beta2 : ChallengePairWords)
    (shiftClaim : Stage3ShiftClaimView)
    (shiftProof : Stage3ShiftWitnessView)
    (currentRow : Stage3CurrentRowView)
    (rowClaim : Stage3RowClaimView)
    (preparedStepDigest : List Byte) : Stage3View :=
  { stepIdx := stepIdx
  , n := n
  , beta1 := beta1
  , beta2 := beta2
  , shiftClaim := shiftClaim
  , shiftProof := shiftProof
  , currentRow := currentRow
  , rowClaim := rowClaim
  , preparedStepDigest := preparedStepDigest }

def mkStage1View
    (pre : MachineStateView)
    (dec : FrameDecodeView)
    (row : List Nat) : Stage1View :=
  { pre := pre, dec := dec, row := row }

def mkStage2View
    (pre post : MachineStateView)
    (dec : FrameDecodeView)
    (row : List Nat) : Stage2View :=
  { pre := pre, post := post, dec := dec, row := row }

def mkExecutionResultView
    (stepIdx : Nat)
    (pre post : MachineStateView)
    (dec : FrameDecodeView) : ExecutionResultView :=
  { stepIdx := stepIdx, pre := pre, post := post, dec := dec }

def mkStagedExecutionDigestView
    (stage1 : Stage1View)
    (stage2 : Stage2View)
    (stage3 : Stage3View)
    (result : ExecutionResultView) : StagedExecutionDigestView :=
  { stage1 := stage1, stage2 := stage2, stage3 := stage3, result := result }

def mkStagedExecutionDigestBundleView
    (publicSurface : DigestPublicView)
    (digests : List StagedExecutionDigestView) :
    StagedExecutionDigestBundleView :=
  { publicSurface := publicSurface, digests := digests }

def mkStagedExecutionDigestBundleVectorCase
    (name : String)
    (publicSurface : DigestPublicView)
    (frames : List FrameSourceView)
    (stage3s : List Stage3View)
    (expectedBundle : StagedExecutionDigestBundleView) :
    StagedExecutionDigestBundleVectorCase :=
  { name := name
  , publicSurface := publicSurface
  , frames := frames
  , stage3s := stage3s
  , expectedBundle := expectedBundle }

def stage1ViewOfFrame (frame : FrameSourceView) : Stage1View :=
  { pre := frame.pre, dec := frame.dec, row := frame.row }

def stage2ViewOfFrame (frame : FrameSourceView) : Stage2View :=
  { pre := frame.pre, post := frame.post, dec := frame.dec, row := frame.row }

def executionResultViewOfFrame (frame : FrameSourceView) : ExecutionResultView :=
  { stepIdx := frame.stepIdx, pre := frame.pre, post := frame.post, dec := frame.dec }

def stagedExecutionDigestViewOfFrameStage3
    (frame : FrameSourceView)
    (stage3 : Stage3View) : StagedExecutionDigestView :=
  { stage1 := stage1ViewOfFrame frame
  , stage2 := stage2ViewOfFrame frame
  , stage3 := stage3
  , result := executionResultViewOfFrame frame }

def stagedExecutionDigestViewsOfSources :
    List FrameSourceView → List Stage3View → List StagedExecutionDigestView
  | [], _ => []
  | _, [] => []
  | frame :: frames, stage3 :: stage3s =>
      stagedExecutionDigestViewOfFrameStage3 frame stage3 ::
        stagedExecutionDigestViewsOfSources frames stage3s

def stagedExecutionDigestBundleViewOfSources
    (publicSurface : DigestPublicView)
    (frames : List FrameSourceView)
    (stage3s : List Stage3View) :
    StagedExecutionDigestBundleView :=
  { publicSurface := publicSurface
  , digests := stagedExecutionDigestViewsOfSources frames stage3s }

end Nightstream.Chip8.Generated
