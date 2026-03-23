import Nightstream.Rv64IM.Generated.ImportedParityCorpus
import Nightstream.Chip8.Kernel.Poseidon2Transcript
import Nightstream.Chip8.Kernel.Root0Digest
import Nightstream.Chip8.Kernel.Poseidon2GoldilocksCore

/-!
Executable exact-parity checks for the imported RV64IM Rust slice corpus. This
owner independently decodes and executes the supported RV64IM vertical slice,
rebuilds Stage 1/2/3 summaries, replays the Fiat-Shamir transcript with exact
cursor checkpoints, and compares the recomputed result against the imported
Rust-derived artifact.
-/

namespace Nightstream.Rv64IM

open Nightstream.Rv64IM.Generated
open Nightstream.Chip8.Poseidon2Transcript
open Nightstream.Chip8.Root0Digest

abbrev Byte := Generated.Byte

private def u64Modulus : Nat := 18446744073709551616

private def mod64 (value : Nat) : Nat :=
  value % u64Modulus

private def mod64Int (value : Int) : Nat :=
  Int.toNat (value.emod (Int.ofNat u64Modulus))

private def add64 (lhs rhs : Nat) : Nat :=
  mod64 (lhs + rhs)

private def addSigned64 (base : Nat) (offset : Int) : Nat :=
  mod64Int (Int.ofNat base + offset)

private def pow2 (n : Nat) : Nat :=
  Nat.pow 2 n

private def bitField (word shift width : Nat) : Nat :=
  (word / pow2 shift) % pow2 width

private def signExtend (value bits : Nat) : Int :=
  if value < pow2 (bits - 1) then
    Int.ofNat value
  else
    Int.ofNat value - Int.ofNat (pow2 bits)

private def bytesToByteArray (values : List Byte) : ByteArray :=
  values.foldl (fun acc value => acc.push value) ByteArray.empty

private def bytesToString? (values : List Byte) : Option String :=
  String.fromUTF8? (bytesToByteArray values)

private def stringBytes (value : String) : List Byte :=
  utf8Bytes value

private def listGet? : List α → Nat → Option α
  | [], _ => none
  | x :: _, 0 => some x
  | _ :: xs, idx + 1 => listGet? xs idx

private def listGetD (values : List Nat) (idx default : Nat) : Nat :=
  values.getD idx default

private def listFlatMap (values : List α) (f : α → List β) : List β :=
  values.foldr (fun value acc => f value ++ acc) []

private def listEnumFrom : Nat → List α → List (Nat × α)
  | _, [] => []
  | idx, x :: xs => (idx, x) :: listEnumFrom (idx + 1) xs

private def listEnum (values : List α) : List (Nat × α) :=
  listEnumFrom 0 values

private def boolToNat (value : Bool) : Nat :=
  if value then 1 else 0

private def listSet : List Nat → Nat → Nat → List Nat
  | [], _, _ => []
  | _ :: xs, 0, value => value :: xs
  | x :: xs, idx + 1, value => x :: listSet xs idx value

private def readRegister (regs : List Nat) (idx : Nat) : Nat :=
  listGetD regs idx 0

private def writeRegister (regs : List Nat) (idx value : Nat) : List Nat :=
  let regs' := if idx = 0 then regs else listSet regs idx (mod64 value)
  listSet regs' 0 0

private def readMemory (memory : List MemoryWordView) (addr : Nat) : Nat :=
  match memory.find? (fun word => word.addr = addr) with
  | some word => word.value
  | none => 0

private def writeMemory : List MemoryWordView → Nat → Nat → List MemoryWordView
  | [], addr, value => [{ addr := addr, value := mod64 value }]
  | word :: rest, addr, value =>
      if addr = word.addr then
        { addr := addr, value := mod64 value } :: rest
      else if addr < word.addr then
        { addr := addr, value := mod64 value } :: word :: rest
      else
        word :: writeMemory rest addr value

private def flattenMemoryWords (words : List MemoryWordView) : List Nat :=
  listFlatMap words fun word => [word.addr, word.value]

private def stateWords (st : State) : List Nat :=
  [ st.x0.val, st.x1.val, st.x2.val, st.x3.val, st.x4.val, st.x5.val, st.x6.val, st.x7.val ]

private def cursorSnapshotWords (cursor : Cursor) : CursorSnapshotWords :=
  { stateWords := stateWords cursor.st, absorbed := cursor.absorbed }

private def concreteCore : Poseidon2Width8Core :=
  Nightstream.Chip8.Poseidon2GoldilocksCore.concreteCore

private def transcriptAppLabelBytes : List Byte :=
  stringBytes "neo.fold.next/rv64im/parity_kernel_v1"

private def transcriptSeedLabel : String := "rv64im/kernel/transcript_seed"
private def caseNameLabel : String := "rv64im/kernel/case_name"
private def programWordsLabel : String := "rv64im/kernel/program_words"
private def initialRegsLabel : String := "rv64im/kernel/initial_regs"
private def initialMemoryLabel : String := "rv64im/kernel/initial_memory"
private def root0DigestLabel : String := "rv64im/kernel/root0_digest"
private def stage1DigestLabel : String := "rv64im/kernel/stage1_digest"
private def stage2DigestLabel : String := "rv64im/kernel/stage2_digest"
private def stage3DigestLabel : String := "rv64im/kernel/stage3_digest"
private def executionDigestLabel : String := "rv64im/kernel/execution_digest"
private def finalStateDigestLabel : String := "rv64im/kernel/final_state_digest"
private def stage1MixLabel : String := "rv64im/stage1/row_mix"
private def stage2RegMixLabel : String := "rv64im/stage2/reg_mix"
private def stage2RamMixLabel : String := "rv64im/stage2/ram_mix"
private def stage3ContinuityMixLabel : String := "rv64im/stage3/continuity_mix"
private def kernelFinalMixLabel : String := "rv64im/kernel/final_mix"

private def newCursor : Cursor :=
  appendMessageCursor concreteCore emptyCursor poseidon2AppDomain transcriptAppLabelBytes

private def digestSections (appLabel : String) (sections : List (String × List Nat)) : List Byte :=
  let cursor := appendMessageCursor concreteCore emptyCursor poseidon2AppDomain (stringBytes appLabel)
  let cursor' := sections.foldl (fun acc (label, values) => appendU64sCursor concreteCore acc label values) cursor
  digestBytes concreteCore cursor'

private structure MachineState where
  pc : Nat
  registers : List Nat
  memory : List MemoryWordView
  halted : Bool
deriving DecidableEq, Repr

private structure DecodedInstruction where
  opcode : Opcode
  rd : Nat
  rs1 : Nat
  rs2 : Nat
  imm : Int
  word : Nat
deriving DecidableEq, Repr

private structure ExecutedStep where
  stepIndex : Nat
  family : FamilyTag
  decoded : DecodedInstruction
  prev : MachineState
  next : MachineState
  rs1Value : Nat
  rs2Value : Nat
  rdBefore : Nat
  aluResult : Nat
  effectiveAddr : Option Nat
  memoryBefore : Option Nat
  memoryAfter : Option Nat
  terminated : Bool
deriving DecidableEq, Repr

private def opcodeFamily : Opcode → FamilyTag
  | .addi | .add => .nativeAlu
  | .ld | .sd => .alignedMemory
  | .ecall => .controlFlow

private def decodeInstruction? (word : Nat) : Option DecodedInstruction :=
  if word = 0x00000073 then
    some { opcode := .ecall, rd := 0, rs1 := 0, rs2 := 0, imm := 0, word := word }
  else
    let opcode := bitField word 0 7
    let rd := bitField word 7 5
    let funct3 := bitField word 12 3
    let rs1 := bitField word 15 5
    let rs2 := bitField word 20 5
    let funct7 := bitField word 25 7
    if opcode = 0x13 && funct3 = 0 then
      some
        { opcode := .addi
        , rd := rd
        , rs1 := rs1
        , rs2 := 0
        , imm := signExtend (bitField word 20 12) 12
        , word := word }
    else if opcode = 0x33 && funct3 = 0 && funct7 = 0 then
      some { opcode := .add, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
    else if opcode = 0x03 && funct3 = 3 then
      some
        { opcode := .ld
        , rd := rd
        , rs1 := rs1
        , rs2 := 0
        , imm := signExtend (bitField word 20 12) 12
        , word := word }
    else if opcode = 0x23 && funct3 = 3 then
      let immLo := bitField word 7 5
      let immHi := bitField word 25 7
      let imm := immHi * pow2 5 + immLo
      some
        { opcode := .sd
        , rd := 0
        , rs1 := rs1
        , rs2 := rs2
        , imm := signExtend imm 12
        , word := word }
    else
      none

private def fetchWord? (source : ParitySourceCase) (pc : Nat) : Option Nat := do
  if pc < source.startPc then
    none
  else if (pc - source.startPc) % 4 ≠ 0 then
    none
  else
    listGet? source.programWords ((pc - source.startPc) / 4)

private def initialMachineState (source : ParitySourceCase) : MachineState :=
  { pc := source.startPc
  , registers := listSet source.initialRegisters 0 0
  , memory := source.initialMemory
  , halted := false }

private def executeStep? (source : ParitySourceCase) (state : MachineState) (stepIndex : Nat) : Option ExecutedStep := do
  if state.halted then
    none
  else
    let word <- fetchWord? source state.pc
    let decoded <- decodeInstruction? word
    let family := opcodeFamily decoded.opcode
    let rs1Value := readRegister state.registers decoded.rs1
    let rs2Value := readRegister state.registers decoded.rs2
    let rdBefore := readRegister state.registers decoded.rd
    let nextBase : MachineState :=
      { state with pc := state.pc + 4 }
    match decoded.opcode with
    | .addi =>
        let result := addSigned64 rs1Value decoded.imm
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex
          , family := family
          , decoded := decoded
          , prev := state
          , next := next
          , rs1Value := rs1Value
          , rs2Value := rs2Value
          , rdBefore := rdBefore
          , aluResult := result
          , effectiveAddr := none
          , memoryBefore := none
          , memoryAfter := none
          , terminated := false }
    | .add =>
        let result := add64 rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex
          , family := family
          , decoded := decoded
          , prev := state
          , next := next
          , rs1Value := rs1Value
          , rs2Value := rs2Value
          , rdBefore := rdBefore
          , aluResult := result
          , effectiveAddr := none
          , memoryBefore := none
          , memoryAfter := none
          , terminated := false }
    | .ld =>
        let addr := addSigned64 rs1Value decoded.imm
        if addr % 8 ≠ 0 then
          none
        else
          let value := readMemory state.memory addr
          let next :=
            { nextBase with
              registers := writeRegister nextBase.registers decoded.rd value }
          some
            { stepIndex := stepIndex
            , family := family
            , decoded := decoded
            , prev := state
            , next := next
            , rs1Value := rs1Value
            , rs2Value := rs2Value
            , rdBefore := rdBefore
            , aluResult := value
            , effectiveAddr := some addr
            , memoryBefore := some value
            , memoryAfter := some value
            , terminated := false }
    | .sd =>
        let addr := addSigned64 rs1Value decoded.imm
        if addr % 8 ≠ 0 then
          none
        else
          let before := readMemory state.memory addr
          let next :=
            { nextBase with
              memory := writeMemory state.memory addr rs2Value }
          some
            { stepIndex := stepIndex
            , family := family
            , decoded := decoded
            , prev := state
            , next := next
            , rs1Value := rs1Value
            , rs2Value := rs2Value
            , rdBefore := rdBefore
            , aluResult := rs2Value
            , effectiveAddr := some addr
            , memoryBefore := some before
            , memoryAfter := some rs2Value
            , terminated := false }
    | .ecall =>
        let next := { nextBase with halted := true }
        some
          { stepIndex := stepIndex
          , family := family
          , decoded := decoded
          , prev := state
          , next := next
          , rs1Value := rs1Value
          , rs2Value := rs2Value
          , rdBefore := rdBefore
          , aluResult := 0
          , effectiveAddr := none
          , memoryBefore := none
          , memoryAfter := none
          , terminated := true }

private def executeProgramAux :
    ParitySourceCase → Nat → Nat → MachineState → Option (List ExecutedStep × MachineState)
  | _, 0, _, _ => none
  | source, fuel + 1, stepIndex, state => do
      let step <- executeStep? source state stepIndex
      if step.next.halted then
        pure ([step], step.next)
      else
        let (rest, finalState) <- executeProgramAux source fuel (stepIndex + 1) step.next
        pure (step :: rest, finalState)

private def executeProgram? (source : ParitySourceCase) : Option (List ExecutedStep × MachineState) :=
  executeProgramAux source source.programWords.length 0 (initialMachineState source)

private def expandedRowOfStep (step : ExecutedStep) : ExpandedRowView :=
  let writesRd :=
    match step.decoded.opcode with
    | .addi | .add | .ld => step.decoded.rd ≠ 0
    | .sd | .ecall => false
  { stepIndex := step.stepIndex
  , pc := step.prev.pc
  , nextPc := step.next.pc
  , word := step.decoded.word
  , opcode := step.decoded.opcode
  , family := step.family
  , rs1 := step.decoded.rs1
  , rs1Value := step.rs1Value
  , rs2 := step.decoded.rs2
  , rs2Value := step.rs2Value
  , rd := step.decoded.rd
  , rdBefore := step.rdBefore
  , rdAfter := readRegister step.next.registers step.decoded.rd
  , imm := step.decoded.imm
  , aluResult := step.aluResult
  , effectiveAddr := step.effectiveAddr
  , memoryBefore := step.memoryBefore
  , memoryAfter := step.memoryAfter
  , writesRd := writesRd
  , writesRam := step.decoded.opcode = .sd
  , halted := step.next.halted }

private def stage1SummaryOfRows (rows : List ExpandedRowView) : Stage1SummaryView :=
  { rows :=
      rows.map fun row =>
        { stepIndex := row.stepIndex
        , fetchPc := row.pc
        , fetchedWord := row.word
        , opcode := row.opcode
        , family := row.family
        , nextPc := row.nextPc
        , aluResult := row.aluResult
        , effectiveAddr := row.effectiveAddr
        , writesRd := row.writesRd
        , rd := row.rd
        , rdAfter := row.rdAfter
        , preservesX0 := row.rd = 0 || not row.writesRd } }

private def stage2SummaryOfRows (rows : List ExpandedRowView) : Stage2SummaryView :=
  let registerReads :=
    listFlatMap rows fun row =>
      match row.opcode with
      | .addi | .ld | .sd =>
          [{ stepIndex := row.stepIndex, role := .rs1, reg := row.rs1, value := row.rs1Value }]
      | .add =>
          [ { stepIndex := row.stepIndex, role := .rs1, reg := row.rs1, value := row.rs1Value }
          , { stepIndex := row.stepIndex, role := .rs2, reg := row.rs2, value := row.rs2Value } ]
      | .ecall => []
  let registerWrites :=
    listFlatMap rows fun row =>
      if row.writesRd then
        [{ stepIndex := row.stepIndex, reg := row.rd, previous := row.rdBefore, next := row.rdAfter }]
      else
        []
  let ramEvents :=
    listFlatMap rows fun row =>
      match row.effectiveAddr, row.memoryBefore with
      | some addr, some before =>
          [ { stepIndex := row.stepIndex
            , kind := if row.writesRam then .write else .read
            , addr := addr
            , previous := before
            , next := row.memoryAfter.getD before } ]
      | _, _ => []
  let twistLinks :=
    rows.map fun row =>
      { stepIndex := row.stepIndex
      , family := row.family
      , routedWriteValue := if row.writesRd then some row.rdAfter else none
      , routedMemoryBefore := row.memoryBefore
      , routedMemoryAfter := row.memoryAfter }
  { registerReads := registerReads
  , registerWrites := registerWrites
  , ramEvents := ramEvents
  , twistLinks := twistLinks }

private def stage3SummaryOfRows (rows : List ExpandedRowView) : Stage3SummaryView :=
  let continuity :=
    (listEnum rows).map fun (idx, row) =>
      let successorPc := (listGet? rows (idx + 1)).map fun next => next.pc
      { stepIndex := row.stepIndex
      , pc := row.pc
      , nextPc := row.nextPc
      , successorPc := successorPc
      , finalStep := idx + 1 = rows.length
      , continuityHolds := successorPc.map (fun nextPc => row.nextPc == nextPc) |>.getD true }
  { continuity := continuity
  , halted := rows.reverse.head?.map (fun row => row.halted) |>.getD false }

private def flattenRow (row : ExpandedRowView) : List Nat :=
  [ row.stepIndex
  , row.pc
  , row.nextPc
  , row.word
  , match row.opcode with
    | .addi => 0
    | .add => 1
    | .ld => 2
    | .sd => 3
    | .ecall => 4
  , match row.family with
    | .nativeAlu => 0
    | .alignedMemory => 1
    | .controlFlow => 2
  , row.rs1
  , row.rs1Value
  , row.rs2
  , row.rs2Value
  , row.rd
  , row.rdBefore
  , row.rdAfter
  , mod64Int row.imm
  , row.aluResult
  , boolToNat row.writesRd
  , boolToNat row.writesRam
  , boolToNat row.halted
  , row.effectiveAddr.getD 0
  , row.memoryBefore.getD 0
  , row.memoryAfter.getD 0 ]

private def flattenStage1 (stage1 : Stage1SummaryView) : List Nat :=
  listFlatMap stage1.rows fun row =>
    [ row.stepIndex
    , row.fetchPc
    , row.fetchedWord
    , match row.opcode with
      | .addi => 0
      | .add => 1
      | .ld => 2
      | .sd => 3
      | .ecall => 4
    , match row.family with
      | .nativeAlu => 0
      | .alignedMemory => 1
      | .controlFlow => 2
    , row.nextPc
    , row.aluResult
    , row.effectiveAddr.getD 0
    , boolToNat row.writesRd
    , row.rd
    , row.rdAfter
    , boolToNat row.preservesX0 ]

private def flattenStage2 (stage2 : Stage2SummaryView) : List Nat :=
  let registerReads :=
    listFlatMap stage2.registerReads fun event =>
      [ event.stepIndex
      , match event.role with | .rs1 => 0 | .rs2 => 1
      , event.reg
      , event.value ]
  let registerWrites :=
    listFlatMap stage2.registerWrites fun event =>
      [event.stepIndex, event.reg, event.previous, event.next]
  let ramEvents :=
    listFlatMap stage2.ramEvents fun event =>
      [ event.stepIndex
      , match event.kind with | .read => 0 | .write => 1
      , event.addr
      , event.previous
      , event.next ]
  let twistLinks :=
    listFlatMap stage2.twistLinks fun event =>
      [ event.stepIndex
      , match event.family with
        | .nativeAlu => 0
        | .alignedMemory => 1
        | .controlFlow => 2
      , event.routedWriteValue.getD 0
      , event.routedMemoryBefore.getD 0
      , event.routedMemoryAfter.getD 0 ]
  [stage2.registerReads.length] ++
    registerReads ++
    [stage2.registerWrites.length] ++
    registerWrites ++
    [stage2.ramEvents.length] ++
    ramEvents ++
    [stage2.twistLinks.length] ++
    twistLinks

private def flattenStage3 (stage3 : Stage3SummaryView) : List Nat :=
  [boolToNat stage3.halted, stage3.continuity.length] ++
    listFlatMap stage3.continuity fun event =>
      [ event.stepIndex
      , event.pc
      , event.nextPc
      , event.successorPc.getD 0
      , boolToNat event.finalStep
      , boolToNat event.continuityHolds ]

private def digestSourceCase (source : ParitySourceCase) : List Byte :=
  digestSections
    "neo.fold.next/rv64im/source_digest_v1"
    [ ("source/protocol", [source.manifest.protocolVersionId, source.manifest.loweringVersionId])
    , ("source/program", source.programWords)
    , ("source/regs", source.initialRegisters)
    , ("source/memory", flattenMemoryWords source.initialMemory)
    , ("source/seed", source.transcriptSeed.map UInt8.toNat)
    ]

private def digestRows (rows : List ExpandedRowView) : List Byte :=
  digestSections
    "neo.fold.next/rv64im/execution_digest_v1"
    (rows.map fun row => ("execution/row", flattenRow row))

private def digestFinalState (finalState : MachineState) : List Byte :=
  digestSections
    "neo.fold.next/rv64im/final_state_digest_v1"
    [ ("final/pc", [finalState.pc])
    , ("final/halted", [boolToNat finalState.halted])
    , ("final/registers", finalState.registers)
    , ("final/memory", flattenMemoryWords finalState.memory)
    ]

private def digestStage1 (stage1 : Stage1SummaryView) : List Byte :=
  digestSections "neo.fold.next/rv64im/stage1_digest_v1" [("stage1/rows", flattenStage1 stage1)]

private def digestStage2 (stage2 : Stage2SummaryView) : List Byte :=
  digestSections "neo.fold.next/rv64im/stage2_digest_v1" [("stage2/summary", flattenStage2 stage2)]

private def digestStage3 (stage3 : Stage3SummaryView) : List Byte :=
  digestSections "neo.fold.next/rv64im/stage3_digest_v1" [("stage3/summary", flattenStage3 stage3)]

private structure TranscriptBuild where
  view : TranscriptView
  stage1Mix : Nat
  stage2RegMix : Nat
  stage2RamMix : Nat
  stage3ContinuityMix : Nat
  kernelFinalMix : Nat
  finalDigest : List Byte

private def appendMessageEvent (cursor : Cursor) (label : String) (msg : List Byte) : TranscriptEventView × Cursor :=
  let before := cursorSnapshotWords cursor
  let next := appendMessageCursor concreteCore cursor label msg
  ( { kind := .appendMessage
    , label := stringBytes label
    , message := msg
    , u64s := []
    , cursorBefore := before
    , cursorAfter := cursorSnapshotWords next
    , challengeOutput := none
    , digestOutput := none }
  , next )

private def appendU64sEvent (cursor : Cursor) (label : String) (values : List Nat) : TranscriptEventView × Cursor :=
  let before := cursorSnapshotWords cursor
  let next := appendU64sCursor concreteCore cursor label values
  ( { kind := .appendU64s
    , label := stringBytes label
    , message := []
    , u64s := values
    , cursorBefore := before
    , cursorAfter := cursorSnapshotWords next
    , challengeOutput := none
    , digestOutput := none }
  , next )

private def challengeFieldEvent (cursor : Cursor) (label : String) : TranscriptEventView × Cursor × Nat :=
  let before := cursorSnapshotWords cursor
  let next := challengeFieldCursor concreteCore cursor label
  let out := challengeFieldValue concreteCore cursor label |>.val
  ( { kind := .challengeField
    , label := stringBytes label
    , message := []
    , u64s := []
    , cursorBefore := before
    , cursorAfter := cursorSnapshotWords next
    , challengeOutput := some out
    , digestOutput := none }
  , next
  , out )

private def digest32Event (cursor : Cursor) : TranscriptEventView × Cursor × List Byte :=
  let before := cursorSnapshotWords cursor
  let next := digestCursor concreteCore cursor
  let out := digestBytes concreteCore cursor
  ( { kind := .digest32
    , label := []
    , message := []
    , u64s := []
    , cursorBefore := before
    , cursorAfter := cursorSnapshotWords next
    , challengeOutput := none
    , digestOutput := some out }
  , next
  , out )

private def buildTranscript
    (source : ParitySourceCase)
    (root0Digest stage1Digest stage2Digest stage3Digest executionDigest finalStateDigest : List Byte) :
    TranscriptBuild :=
  let cursor0 := newCursor
  let (ev1, cursor1) := appendMessageEvent cursor0 transcriptSeedLabel source.transcriptSeed
  let (ev2, cursor2) := appendMessageEvent cursor1 caseNameLabel (stringBytes source.manifest.name)
  let (ev3, cursor3) := appendU64sEvent cursor2 programWordsLabel source.programWords
  let (ev4, cursor4) := appendU64sEvent cursor3 initialRegsLabel source.initialRegisters
  let (ev5, cursor5) := appendU64sEvent cursor4 initialMemoryLabel (flattenMemoryWords source.initialMemory)
  let (ev6, cursor6) := appendMessageEvent cursor5 root0DigestLabel root0Digest
  let (ev7, cursor7, stage1Mix) := challengeFieldEvent cursor6 stage1MixLabel
  let (ev8, cursor8) := appendMessageEvent cursor7 stage1DigestLabel stage1Digest
  let (ev9, cursor9, stage2RegMix) := challengeFieldEvent cursor8 stage2RegMixLabel
  let (ev10, cursor10, stage2RamMix) := challengeFieldEvent cursor9 stage2RamMixLabel
  let (ev11, cursor11) := appendMessageEvent cursor10 stage2DigestLabel stage2Digest
  let (ev12, cursor12, stage3ContinuityMix) := challengeFieldEvent cursor11 stage3ContinuityMixLabel
  let (ev13, cursor13) := appendMessageEvent cursor12 stage3DigestLabel stage3Digest
  let (ev14, cursor14) := appendMessageEvent cursor13 executionDigestLabel executionDigest
  let (ev15, cursor15) := appendMessageEvent cursor14 finalStateDigestLabel finalStateDigest
  let (ev16, cursor16, kernelFinalMix) := challengeFieldEvent cursor15 kernelFinalMixLabel
  let (ev17, _, finalDigest) := digest32Event cursor16
  { view :=
      { appLabel := transcriptAppLabelBytes
      , events := [ev1, ev2, ev3, ev4, ev5, ev6, ev7, ev8, ev9, ev10, ev11, ev12, ev13, ev14, ev15, ev16, ev17] }
  , stage1Mix := stage1Mix
  , stage2RegMix := stage2RegMix
  , stage2RamMix := stage2RamMix
  , stage3ContinuityMix := stage3ContinuityMix
  , kernelFinalMix := kernelFinalMix
  , finalDigest := finalDigest }

private def recomputeDerivedCase? (source : ParitySourceCase) : Option ParityDerivedCase := do
  let (steps, finalState) <- executeProgram? source
  let rows := steps.map expandedRowOfStep
  let stage1 := stage1SummaryOfRows rows
  let stage2 := stage2SummaryOfRows rows
  let stage3 := stage3SummaryOfRows rows
  let root0Digest := digestSourceCase source
  let stage1Digest := digestStage1 stage1
  let stage2Digest := digestStage2 stage2
  let stage3Digest := digestStage3 stage3
  let executionDigest := digestRows rows
  let finalStateDigest := digestFinalState finalState
  let transcriptBuild :=
    buildTranscript source root0Digest stage1Digest stage2Digest stage3Digest executionDigest finalStateDigest
  pure
    { manifest := source.manifest
    , executionRows := rows
    , stage1 := stage1
    , stage2 := stage2
    , stage3 := stage3
    , transcript := transcriptBuild.view
    , kernel :=
        { root0Digest := root0Digest
        , stage1Digest := stage1Digest
        , stage2Digest := stage2Digest
        , stage3Digest := stage3Digest
        , executionDigest := executionDigest
        , finalStateDigest := finalStateDigest
        , stage1Mix := transcriptBuild.stage1Mix
        , stage2RegMix := transcriptBuild.stage2RegMix
        , stage2RamMix := transcriptBuild.stage2RamMix
        , stage3ContinuityMix := transcriptBuild.stage3ContinuityMix
        , kernelFinalMix := transcriptBuild.kernelFinalMix
        , transcriptFinalDigest := transcriptBuild.finalDigest
        , finalPc := finalState.pc
        , finalRegisters := finalState.registers
        , finalMemory := finalState.memory
        , halted := finalState.halted } }

private def caseCheckResults (source : ParitySourceCase) (expected : ParityDerivedCase) : List (String × Bool) :=
  match recomputeDerivedCase? source with
  | none => [("recompute", false)]
  | some actual =>
      [ ("manifest", decide (actual.manifest = expected.manifest))
      , ("executionRows", decide (actual.executionRows = expected.executionRows))
      , ("stage1", decide (actual.stage1 = expected.stage1))
      , ("stage2", decide (actual.stage2 = expected.stage2))
      , ("stage3", decide (actual.stage3 = expected.stage3))
      , ("transcript", decide (actual.transcript = expected.transcript))
      , ("kernel", decide (actual.kernel = expected.kernel))
      ]

structure Rv64imParityReport where
  name : String
  checks : List (String × Bool)
deriving Repr

def checkParityCase (source : ParitySourceCase) (expected : ParityDerivedCase) : Bool :=
  (caseCheckResults source expected).all Prod.snd

def rv64imParityChecks : List Bool :=
  Generated.parityCases.map fun (source, expected) => checkParityCase source expected

def rv64imRecomputedCases : List (Option ParityDerivedCase) :=
  Generated.parityCases.map fun (source, _) => recomputeDerivedCase? source

def validGeneratedRv64imParityCases : Bool :=
  Generated.parityCases.all fun (source, expected) => checkParityCase source expected

def rv64imParityReports : List Rv64imParityReport :=
  Generated.parityCases.map fun (source, expected) =>
    { name := source.manifest.name
    , checks := caseCheckResults source expected }

end Nightstream.Rv64IM
