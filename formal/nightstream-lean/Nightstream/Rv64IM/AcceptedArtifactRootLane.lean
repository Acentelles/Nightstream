import Nightstream.Rv64IM.Generated.AcceptedProofArtifactTypes
import Nightstream.Rv64IM.Generated.ParityTypes
import Nightstream.Rv64IM.ProofBoundaryChecks
import Nightstream.Chip8.Kernel.Poseidon2Transcript
import Nightstream.Chip8.Kernel.Root0Digest
import Nightstream.Chip8.Kernel.Poseidon2GoldilocksCore

/-!
Owns exact recomputation of the RV64IM root main-lane protocol-binding objects
from replayed execution rows. This owner covers the semantic-row embedding,
root-lane row and column authentication digests, the exported root-lane
commitment summary surface, the derived main-lane surface, and the prepared-step
binding summary. It does not own PCS commitment verification or root0 binding
recovery.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated
open Nightstream.Chip8.Poseidon2Transcript
open Nightstream.Chip8.Root0Digest
open Nightstream.Chip8.Poseidon2GoldilocksCore (concreteCore)

private abbrev RvByte := Generated.Byte

def rv64imRootRowWidth : Nat := 38
def rv64imRootLaneColumnsLayoutV1 : Nat := 1
def rv64imRootLaneCommittedRowsFamilyTag : Nat := 10
def rv64imRootLaneCommittedRowsLayoutV1 : Nat := 3

structure RecomputedPreparedStepBindingSummary where
  bindingDigests : List (List RvByte)
  bindingCount : Nat
  firstBindingDigest : Option (List RvByte)
  lastBindingDigest : Option (List RvByte)
  digest : List RvByte
deriving DecidableEq, Repr

structure RecomputedRootLaneView where
  semanticRows : List (List Nat)
  rowDigests : List (List RvByte)
  columnDigests : List (List RvByte)
  familyDigest : List RvByte
  rootLaneColumns : RootLaneColumnsView
  mainLaneSurface : MainLaneSurfaceView
  preparedStepBindings : RecomputedPreparedStepBindingSummary
deriving DecidableEq, Repr

private def u64Modulus : Nat := 18446744073709551616

private def pow2 (n : Nat) : Nat :=
  Nat.pow 2 n

private def mod64 (value : Nat) : Nat :=
  value % u64Modulus

private def mod64Int (value : Int) : Nat :=
  Int.toNat (value.emod (Int.ofNat u64Modulus))

private def add64 (lhs rhs : Nat) : Nat :=
  mod64 (lhs + rhs)

private def signExtend (value bits : Nat) : Int :=
  if value < pow2 (bits - 1) then
    Int.ofNat value
  else
    Int.ofNat value - Int.ofNat (pow2 bits)

private def signExtendBits (raw bits : Nat) : Nat :=
  mod64Int (signExtend raw bits)

private def optionGetD (value : Option Nat) (default : Nat) : Nat :=
  match value with
  | some result => result
  | none => default

private def listEnumFrom : Nat → List α → List (Nat × α)
  | _, [] => []
  | rowIndex, row :: rows => (rowIndex, row) :: listEnumFrom (rowIndex + 1) rows

private def listEnum (rows : List α) : List (Nat × α) :=
  listEnumFrom 0 rows

private def listLast? : List α → Option α
  | [] => none
  | [value] => some value
  | _ :: values => listLast? values

private def encodeU64Words (value : Nat) : List Nat :=
  [value % pow2 32, value / pow2 32]

private def isRealBranch : Opcode → Bool
  | .beq | .bne | .blt | .bge | .bltu | .bgeu => true
  | _ => false

private def isRealLoad : Opcode → Bool
  | .lb | .lbu | .lh | .lhu | .lw | .lwu | .ld => true
  | _ => false

private def isRealStore : Opcode → Bool
  | .sb | .sh | .sw | .sd => true
  | _ => false

private def realOpcodeUsesRs2 : Opcode → Bool
  | .add | .addw | .sub | .subw
  | .and | .or | .xor
  | .slt | .sltu
  | .sll | .srl | .sra
  | .sllw | .srlw | .sraw
  | .mul | .mulh | .mulhsu | .mulhu | .mulw
  | .div | .divu | .rem | .remu
  | .divw | .divuw | .remw | .remuw
  | .sb | .sh | .sw | .sd
  | .beq | .bne | .blt | .bge | .bltu | .bgeu => true
  | _ => false

private def narrowStoreValue (opcode : Opcode) (rs2Value : Nat) : Nat :=
  match opcode with
  | .sb => rs2Value % pow2 8
  | .sh => rs2Value % pow2 16
  | .sw => rs2Value % pow2 32
  | .sd => mod64 rs2Value
  | _ => 0

private def extractNarrowValue
    (word byteOffset sizeBytes : Nat)
    (signed : Bool) : Nat :=
  let bits := sizeBytes * 8
  let raw := ((mod64 word) / pow2 (byteOffset * 8)) % pow2 bits
  if signed then signExtendBits raw bits else raw

private def narrowLoadValue (row : ExpandedRowView) (opcode : Opcode) : Nat :=
  let value := optionGetD row.memoryBefore 0
  let addr := optionGetD row.effectiveAddr 0
  let byteOffset := addr % 8
  match opcode with
  | .lb => extractNarrowValue value byteOffset 1 true
  | .lbu => extractNarrowValue value byteOffset 1 false
  | .lh => extractNarrowValue value byteOffset 2 true
  | .lhu => extractNarrowValue value byteOffset 2 false
  | .lw => extractNarrowValue value byteOffset 4 true
  | .lwu => extractNarrowValue value byteOffset 4 false
  | _ => mod64 row.rdAfter

private def memoryTransferValue (row : ExpandedRowView) : Nat :=
  match row.traceOpcode with
  | some opcode =>
      if isRealLoad opcode then
        if opcode = .ld then
          optionGetD row.memoryBefore 0
        else
          narrowLoadValue row opcode
      else if isRealStore opcode then
        narrowStoreValue opcode row.rs2Value
      else
        0
  | none => 0

def semanticRowWordsOfExecutionRow (row : ExpandedRowView) : List Nat :=
  let realOpcode := row.traceOpcode
  let isLoad := realOpcode.isSome && realOpcode.any isRealLoad
  let isStore := realOpcode.isSome && realOpcode.any isRealStore
  let writesMemToRd := isLoad && row.writesRd
  let writesAluToRd := row.writesRd && !writesMemToRd
  let preservesRd := !writesAluToRd && !writesMemToRd
  let isJal := realOpcode = some .jal
  let isJalr := realOpcode = some .jalr
  let isBranch := realOpcode.isSome && realOpcode.any isRealBranch
  let stepPc := add64 row.pc 4
  let branchTaken := isBranch && row.nextPc ≠ stepPc
  let branchTakenMux := isBranch && branchTaken
  let jumpTarget :=
    if isJal || isJalr || branchTakenMux then row.nextPc else 0
  let memAddr :=
    if isLoad || isStore then optionGetD row.effectiveAddr 0 else 0
  let memVal := memoryTransferValue row
  let rdNext :=
    if writesAluToRd || writesMemToRd then row.rdAfter else 0
  let usesRs2 :=
    match realOpcode with
    | some opcode => realOpcodeUsesRs2 opcode
    | none => row.rs2 ≠ 0
  [ 1 ] ++
    encodeU64Words row.pc ++
    encodeU64Words row.nextPc ++
    encodeU64Words row.rs1Value ++
    encodeU64Words row.rs2Value ++
    encodeU64Words rdNext ++
    encodeU64Words (mod64Int row.imm) ++
    encodeU64Words row.aluResult ++
    encodeU64Words stepPc ++
    encodeU64Words jumpTarget ++
    encodeU64Words memAddr ++
    encodeU64Words memVal ++
    [ row.rd
    , row.rs1
    , row.rs2
    , boolWord writesAluToRd
    , boolWord writesMemToRd
    , boolWord preservesRd
    , boolWord isJal
    , boolWord isJalr
    , boolWord isBranch
    , boolWord branchTaken
    , boolWord branchTakenMux
    , boolWord isLoad
    , boolWord isStore
    , boolWord usesRs2
    , boolWord row.isCommitRow
    ]

private def transcriptAppCursor (appLabel : String) : Cursor :=
  appendMessageCursor concreteCore emptyCursor poseidon2AppDomain (utf8Bytes appLabel)

private def appendFieldWordsCursor
    (cursor : Cursor)
    (label : String)
    (fieldWords : List Nat) : Cursor :=
  absorbFields concreteCore cursor
    (toFieldElems (absorbPackedBytesWithLenWords (utf8Bytes label) ++ [fieldWords.length] ++ fieldWords))

def rootLaneRowDigest (logicalIndex : Nat) (semanticRow : List Nat) : List RvByte :=
  let cursor0 := transcriptAppCursor "neo.fold.next/rv64im/root_lane_row"
  let cursor1 :=
    appendU64sCursor concreteCore cursor0 "rv64im/root_lane_row/logical_index" [logicalIndex]
  let cursor2 :=
    appendFieldWordsCursor cursor1 "rv64im/root_lane_row/semantic" semanticRow
  digestBytes concreteCore cursor2

def rootLaneColumnDigest (columnIndex : Nat) (values : List Nat) : List RvByte :=
  let cursor0 := transcriptAppCursor "neo.fold.next/rv64im/root_lane_column"
  let cursor1 :=
    appendU64sCursor concreteCore cursor0 "rv64im/root_lane_column/meta" [columnIndex, values.length]
  let cursor2 :=
    appendFieldWordsCursor cursor1 "rv64im/root_lane_column/values" values
  digestBytes concreteCore cursor2

def rootLaneFamilyDigest (columnDigests : List (List RvByte)) : List RvByte :=
  transcriptDigest "neo.fold.next/rv64im/root_lane_column_family"
    ([ .appendU64s
         "rv64im/root_lane_column_family/column_count"
         [columnDigests.length]
     ] ++
      columnDigests.map fun digest =>
        TranscriptOp.appendMessage "rv64im/root_lane_column_family/column_digest" digest)

private def rootLaneColumnsObject (familyDigest : List RvByte) : AjtaiObjectIdView :=
  let object : AjtaiObjectIdView :=
    { familyTag := 0
    , commitmentDigest := familyDigest
    , layoutVersion := rv64imRootLaneColumnsLayoutV1
    , digest := []
    }
  { object with digest := ajtaiObjectIdDigest object }

private def selectedOpeningRefOfRowDigest
    (object : AjtaiObjectIdView)
    (logicalIndex : Nat)
    (rowDigest : List RvByte) : SelectedOpeningRefView :=
  let openingId : AjtaiOpeningIdView :=
    { object := object
    , logicalIndex := logicalIndex
    , digest := []
    }
  let openingId := { openingId with digest := ajtaiOpeningIdDigest openingId }
  let reference : SelectedOpeningRefView :=
    { id := openingId
    , valueDigest := rowDigest
    , digest := []
    }
  { reference with digest := selectedOpeningRefDigest reference }

private def rootLaneCommittedRowsObject
    (commitmentDigest : List RvByte) : AjtaiObjectIdView :=
  let object : AjtaiObjectIdView :=
    { familyTag := rv64imRootLaneCommittedRowsFamilyTag
    , commitmentDigest := commitmentDigest
    , layoutVersion := rv64imRootLaneCommittedRowsLayoutV1
    , digest := []
    }
  { object with digest := ajtaiObjectIdDigest object }

private def selectedCommittedRowRefOfDigest
    (commitmentDigest : List RvByte)
    (logicalIndex : Nat)
    (rowDigest : List RvByte) : SelectedOpeningRefView :=
  selectedOpeningRefOfRowDigest
    (rootLaneCommittedRowsObject commitmentDigest)
    logicalIndex
    rowDigest

private def rootLaneColumnsOfRows
    (semanticRows : List (List Nat))
    (rowDigests : List (List RvByte)) : RootLaneColumnsView :=
  let columnDigests :=
    (List.range rv64imRootRowWidth).map fun columnIndex =>
      rootLaneColumnDigest columnIndex (semanticRows.map fun row => row.getD columnIndex 0)
  let familyDigest := rootLaneFamilyDigest columnDigests
  let object := rootLaneColumnsObject familyDigest
  let firstRow :=
    rowDigests.head?.map fun digest =>
      selectedOpeningRefOfRowDigest object 0 digest
  let lastRow :=
    listLast? (listEnum rowDigests) |>.map fun (logicalIndex, digest) =>
      selectedOpeningRefOfRowDigest object logicalIndex digest
  let bundle : RootLaneColumnsView :=
    { object := object
    , rowWidth := rv64imRootRowWidth
    , timeLen := semanticRows.length
    , columnDigests := columnDigests
    , familyDigest := familyDigest
    , firstRow := firstRow
    , lastRow := lastRow
    , digest := []
    }
  { bundle with digest := rootLaneColumnsDigest bundle }

def preparedStepBindingDigest
    (logicalIndex traceIndex : Nat)
    (semanticRow : List Nat) : List RvByte :=
  let cursor0 := transcriptAppCursor "neo.fold.next/rv64im/prepared_step_binding"
  let cursor1 :=
    appendU64sCursor concreteCore cursor0
      "rv64im/prepared_step_binding/meta"
      [logicalIndex, traceIndex]
  let cursor2 :=
    appendFieldWordsCursor cursor1 "rv64im/prepared_step_binding/semantic_row" semanticRow
  digestBytes concreteCore cursor2

def preparedStepBindingSummaryOfExecutionRows
    (rows : List ExpandedRowView)
    (semanticRows : List (List Nat)) : RecomputedPreparedStepBindingSummary :=
  let bindingDigests :=
    (listEnum rows).zip semanticRows |>.map fun ((logicalIndex, row), semanticRow) =>
      preparedStepBindingDigest logicalIndex row.traceIndex semanticRow
  let digest :=
    transcriptDigest "neo.fold.next/rv64im/prepared_step_binding_summary"
      ([ .appendU64s
           "rv64im/prepared_step_binding_summary/len"
           [rows.length]
       ] ++
        bindingDigests.map fun bindingDigest =>
          TranscriptOp.appendMessage
            "rv64im/prepared_step_binding_summary/binding_digest"
            bindingDigest)
  { bindingDigests := bindingDigests
  , bindingCount := rows.length
  , firstBindingDigest := bindingDigests.head?
  , lastBindingDigest := listLast? bindingDigests
  , digest := digest
  }

def rootLaneCommitmentSummaryOfRowDigests
    (commitmentDigest : List RvByte)
    (rowDigests : List (List RvByte)) : RootLaneCommitmentArtifactView :=
  let firstSelectedRow :=
    rowDigests.head?.map fun rowDigest =>
      selectedCommittedRowRefOfDigest commitmentDigest 0 rowDigest
  let lastSelectedRow :=
    listLast? (listEnum rowDigests) |>.map fun (logicalIndex, rowDigest) =>
      selectedCommittedRowRefOfDigest commitmentDigest logicalIndex rowDigest
  let artifact : RootLaneCommitmentArtifactView :=
    { timeLen := rowDigests.length
    , commitments :=
        { commitmentCount := rv64imRootRowWidth
        , digest := commitmentDigest
        }
    , firstSelectedRow := firstSelectedRow
    , lastSelectedRow := lastSelectedRow
    , digest := []
    }
  { artifact with digest := rootLaneCommitmentArtifactDigest artifact }

def recomputeRootLaneView (rows : List ExpandedRowView) : RecomputedRootLaneView :=
  let semanticRows := rows.map semanticRowWordsOfExecutionRow
  let rowDigests :=
    (listEnum semanticRows).map fun (logicalIndex, semanticRow) =>
      rootLaneRowDigest logicalIndex semanticRow
  let rootLaneColumns := rootLaneColumnsOfRows semanticRows rowDigests
  let preparedStepBindings :=
    preparedStepBindingSummaryOfExecutionRows rows semanticRows
  { semanticRows := semanticRows
  , rowDigests := rowDigests
  , columnDigests := rootLaneColumns.columnDigests
  , familyDigest := rootLaneColumns.familyDigest
  , rootLaneColumns := rootLaneColumns
  , mainLaneSurface := mainLaneSurfaceOfRootLaneColumns rootLaneColumns
  , preparedStepBindings := preparedStepBindings
  }

def recomputedRootLaneColumnsMatchArtifact
    (recomputed : RecomputedRootLaneView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.rootLaneColumns = artifact.kernelProof.rootLaneColumns &&
    recomputed.rootLaneColumns = artifact.exportedKernelProof.rootLaneColumns &&
    recomputed.rootLaneColumns.digest = artifact.exportedStatement.rootLaneColumnsDigest &&
    recomputed.rootLaneColumns.digest = artifact.kernelProof.mainLane.binding.rootLaneColumnsDigest

def recomputedMainLaneSurfaceMatchesArtifact
    (recomputed : RecomputedRootLaneView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.mainLaneSurface.digest = artifact.exportedStatement.mainLaneSurfaceDigest &&
    artifact.exportedStatement.publicStepCount = recomputed.rootLaneColumns.timeLen &&
    artifact.exportedStatement.chunkCount =
      Nightstream.FoldSchedule.chunkCount
        artifact.exportedStatement.foldSchedule
        artifact.exportedStatement.publicStepCount &&
    artifact.exportedStatement.foldSchedule = artifact.kernelProof.mainLane.binding.foldSchedule &&
    artifact.exportedStatement.chunkCount = artifact.kernelProof.mainLane.binding.chunkCount &&
    artifact.kernelProof.mainLane.binding.publicStepCount = recomputed.rootLaneColumns.timeLen &&
    artifact.kernelProof.mainLane.binding.chunkCount =
      Nightstream.FoldSchedule.chunkCount
        artifact.kernelProof.mainLane.binding.foldSchedule
        artifact.kernelProof.mainLane.binding.publicStepCount &&
    recomputed.mainLaneSurface.objectDigest = recomputed.rootLaneColumns.object.digest &&
    recomputed.mainLaneSurface.familyDigest = recomputed.rootLaneColumns.familyDigest &&
    recomputed.mainLaneSurface.publicStepCount = recomputed.rootLaneColumns.timeLen &&
    recomputed.mainLaneSurface.firstPublicStep = recomputed.rootLaneColumns.firstRow &&
    recomputed.mainLaneSurface.lastPublicStep = recomputed.rootLaneColumns.lastRow

def recomputedRootLaneCommitmentMatchesArtifact
    (recomputed : RecomputedRootLaneView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  let recomputedCommitment :=
    rootLaneCommitmentSummaryOfRowDigests
      artifact.kernelProof.rootLaneCommitment.commitments.digest
      recomputed.rowDigests
  recomputedCommitment = artifact.kernelProof.rootLaneCommitment &&
    recomputedCommitment = artifact.exportedKernelProof.rootLaneCommitment &&
    recomputedCommitment.digest = artifact.kernelProof.mainLane.binding.rootLaneCommitmentDigest

def recomputedPreparedStepBindingsMatchArtifact
    (recomputed : RecomputedRootLaneView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputed.preparedStepBindings.digest =
      artifact.kernelProof.kernelClaims.summary.preparedStepBindingsDigest &&
    recomputed.preparedStepBindings.digest =
      artifact.kernelProof.kernelOpening.bindings.preparedStepsDigest &&
    recomputed.preparedStepBindings.digest = artifact.exportedStatement.preparedStepBindingsDigest &&
    recomputed.preparedStepBindings.digest =
      artifact.exportedClaims.opening.terminal.preparedStepBindingsDigest

def recomputedRootLaneProtocolBindingsMatchArtifact
    (recomputed : RecomputedRootLaneView)
    (artifact : AcceptedProofArtifactView) : Bool :=
  recomputedRootLaneColumnsMatchArtifact recomputed artifact &&
    recomputedRootLaneCommitmentMatchesArtifact recomputed artifact &&
    recomputedMainLaneSurfaceMatchesArtifact recomputed artifact &&
    recomputedPreparedStepBindingsMatchArtifact recomputed artifact

end Nightstream.Rv64IM
