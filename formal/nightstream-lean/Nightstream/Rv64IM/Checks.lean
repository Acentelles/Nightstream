import Nightstream.Rv64IM.Generated.ImportedParityCorpus
import Nightstream.Rv64IM.Execution.ImportedSequenceSemantics
import Nightstream.Rv64IM.Execution.LoweringRefinement
import Nightstream.Rv64IM.Execution.LoweringRefinementChecks
import Nightstream.Rv64IM.Stage1.ImportedClosure
import Nightstream.Rv64IM.Stage1.ImportedLocalSemantics
import Nightstream.Rv64IM.Stage1.ImportedSemantics
import Nightstream.Rv64IM.Stage2.ImportedClosure
import Nightstream.Rv64IM.Stage2.ImportedAuthenticatedHistorySemantics
import Nightstream.Rv64IM.Stage2.ImportedHistorySemantics
import Nightstream.Rv64IM.Stage2.ImportedLocalSemantics
import Nightstream.Rv64IM.Stage3.ImportedClosure
import Nightstream.Rv64IM.Stage3.ImportedContinuitySemantics
import Nightstream.Rv64IM.Stage3.ImportedExportSemantics
import Nightstream.Rv64IM.Stage3.ImportedLocalSemantics
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

private def decodeIImm (word : Nat) : Int :=
  signExtend (bitField word 20 12) 12

private def decodeBImm (word : Nat) : Int :=
  let imm11 := bitField word 7 1
  let imm4_1 := bitField word 8 4
  let imm10_5 := bitField word 25 6
  let imm12 := bitField word 31 1
  signExtend (imm12 * pow2 12 + imm11 * pow2 11 + imm10_5 * pow2 5 + imm4_1 * 2) 13

private def decodeUImm (word : Nat) : Int :=
  signExtend (bitField word 12 20 * pow2 12) 32

private def signedWord (value : Nat) : Int :=
  signExtend (mod64 value) 64

private def bitAnd64 (lhs rhs : Nat) : Nat :=
  ((UInt64.ofNat lhs) &&& (UInt64.ofNat rhs)).toNat

private def bitOr64 (lhs rhs : Nat) : Nat :=
  ((UInt64.ofNat lhs) ||| (UInt64.ofNat rhs)).toNat

private def bitXor64 (lhs rhs : Nat) : Nat :=
  ((UInt64.ofNat lhs) ^^^ (UInt64.ofNat rhs)).toNat

private def bitNot64 (value : Nat) : Nat :=
  bitXor64 value (u64Modulus - 1)

private def shiftLeft64 (value amount : Nat) : Nat :=
  UInt64.shiftLeft (UInt64.ofNat value) (UInt64.ofNat amount) |>.toNat

private def logicalShiftRight64 (value amount : Nat) : Nat :=
  UInt64.shiftRight (UInt64.ofNat value) (UInt64.ofNat amount) |>.toNat

private def arithmeticShiftRight64 (value amount : Nat) : Nat :=
  Int64.shiftRight (Int64.ofInt (signedWord value)) (Int64.ofNat amount) |>.toUInt64.toNat

private def narrowAccessSpec : Opcode → Option (Nat × Bool × Bool)
  | .lb => some (1, true, false)
  | .lbu => some (1, false, false)
  | .lh => some (2, true, false)
  | .lhu => some (2, false, false)
  | .lw => some (4, true, false)
  | .lwu => some (4, false, false)
  | .sb => some (1, false, true)
  | .sh => some (2, false, true)
  | .sw => some (4, false, true)
  | _ => none

private def extractNarrow (word byteOffset sizeBytes : Nat) (signed : Bool) : Nat :=
  let bits := sizeBytes * 8
  let raw := logicalShiftRight64 word (byteOffset * 8) % pow2 bits
  if signed then
    mod64Int (signExtend raw bits)
  else
    raw

private def blendNarrow (word byteOffset sizeBytes value : Nat) : Nat :=
  let bits := sizeBytes * 8
  let fieldMask := pow2 bits - 1
  let shiftedMask := shiftLeft64 fieldMask (byteOffset * 8)
  let shiftedValue := shiftLeft64 (value % pow2 bits) (byteOffset * 8)
  bitOr64 (bitAnd64 word (bitNot64 shiftedMask)) shiftedValue

private def signedWord32 (value : Nat) : Int :=
  signExtend (value % pow2 32) 32

private def mulHighSigned (lhs rhs : Nat) : Nat :=
  let product := signedWord lhs * signedWord rhs
  Int.toNat ((product.emod (Int.ofNat (pow2 128))) / Int.ofNat u64Modulus)

private def mulHighSignedUnsigned (lhs rhs : Nat) : Nat :=
  let product := signedWord lhs * Int.ofNat (mod64 rhs)
  Int.toNat ((product.emod (Int.ofNat (pow2 128))) / Int.ofNat u64Modulus)

private def mulHighUnsigned (lhs rhs : Nat) : Nat :=
  (mod64 lhs * mod64 rhs) / u64Modulus

private def mulwResult (lhs rhs : Nat) : Nat :=
  let product := signedWord32 lhs * signedWord32 rhs
  mod64Int (signExtend (Int.toNat (product.emod (Int.ofNat (pow2 32)))) 32)

private def signExtendWord32 (value : Nat) : Nat :=
  mod64Int (signExtend (value % pow2 32) 32)

private def mod32Int (value : Int) : Nat :=
  Int.toNat (value.emod (Int.ofNat (pow2 32)))

private def addiwResult (lhs : Nat) (imm : Int) : Nat :=
  signExtendWord32 (mod64Int (Int.ofNat lhs + imm))

private def addwResult (lhs rhs : Nat) : Nat :=
  signExtendWord32 (lhs + rhs)

private def subwResult (lhs rhs : Nat) : Nat :=
  signExtendWord32 (lhs + (u64Modulus - rhs))

private def wordShiftLeftResult (value amount : Nat) : Nat :=
  signExtendWord32 (((value % pow2 32) * pow2 (amount % 32)) % pow2 32)

private def wordLogicalShiftRightResult (value amount : Nat) : Nat :=
  signExtendWord32 ((value % pow2 32) / pow2 (amount % 32))

private def wordArithmeticShiftRightResult (value amount : Nat) : Nat :=
  signExtendWord32 (mod32Int (signedWord32 value / Int.ofNat (pow2 (amount % 32))))

private def intDivTrunc (lhs rhs : Int) : Int :=
  if rhs = 0 then
    0
  else
    let q := Int.ofNat (lhs.natAbs / rhs.natAbs)
    if decide (lhs < 0) = decide (rhs < 0) then q else -q

private def intRemTrunc (lhs rhs : Int) : Int :=
  lhs - intDivTrunc lhs rhs * rhs

private def minSigned64 : Int :=
  -Int.ofNat (pow2 63)

private def minSigned32 : Int :=
  -Int.ofNat (pow2 31)

private def divSignedResult (lhs rhs : Nat) : Nat :=
  let lhsInt := signedWord lhs
  let rhsInt := signedWord rhs
  if rhsInt = 0 then
    u64Modulus - 1
  else if lhsInt = minSigned64 && rhsInt = -1 then
    mod64Int lhsInt
  else
    mod64Int (intDivTrunc lhsInt rhsInt)

private def divUnsignedResult (lhs rhs : Nat) : Nat :=
  if rhs = 0 then u64Modulus - 1 else lhs / rhs

private def remSignedResult (lhs rhs : Nat) : Nat :=
  let lhsInt := signedWord lhs
  let rhsInt := signedWord rhs
  if rhsInt = 0 then
    lhs
  else if lhsInt = minSigned64 && rhsInt = -1 then
    0
  else
    mod64Int (intRemTrunc lhsInt rhsInt)

private def remUnsignedResult (lhs rhs : Nat) : Nat :=
  if rhs = 0 then lhs else lhs % rhs

private def divwSignedResult (lhs rhs : Nat) : Nat :=
  let lhsInt := signedWord32 lhs
  let rhsInt := signedWord32 rhs
  if rhsInt = 0 then
    u64Modulus - 1
  else if lhsInt = minSigned32 && rhsInt = -1 then
    mod64Int lhsInt
  else
    mod64Int (intDivTrunc lhsInt rhsInt)

private def divwUnsignedResult (lhs rhs : Nat) : Nat :=
  let lhsWord := lhs % pow2 32
  let rhsWord := rhs % pow2 32
  if rhsWord = 0 then
    u64Modulus - 1
  else
    signExtendWord32 (lhsWord / rhsWord)

private def remwSignedResult (lhs rhs : Nat) : Nat :=
  let lhsInt := signedWord32 lhs
  let rhsInt := signedWord32 rhs
  if rhsInt = 0 then
    mod64Int lhsInt
  else if lhsInt = minSigned32 && rhsInt = -1 then
    0
  else
    mod64Int (intRemTrunc lhsInt rhsInt)

private def remwUnsignedResult (lhs rhs : Nat) : Nat :=
  let lhsWord := lhs % pow2 32
  let rhsWord := rhs % pow2 32
  if rhsWord = 0 then
    signExtendWord32 lhsWord
  else
    signExtendWord32 (lhsWord % rhsWord)

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

private def rustAbsorbSlice : Cursor → List FieldElem → Cursor
  | cursor, [] => cursor
  | cursor, x :: xs =>
      let cursor' :=
        if cursor.absorbed = rate then
          permuteCursor concreteCore cursor
        else
          cursor
      let cursor'' := absorbElem concreteCore cursor' x
      let cursor''' :=
        if cursor''.absorbed = rate then
          permuteCursor concreteCore cursor''
        else
          cursor''
      rustAbsorbSlice cursor''' xs

private def rustAbsorbPackedBytesWithLen (cursor : Cursor) (bytes : List Byte) : Cursor :=
  let cursor' := absorbElem concreteCore cursor (SuperNeo.F.ofNat bytes.length)
  let packed := toFieldElems (packBytesWords bytes)
  if packed.isEmpty then
    cursor'
  else
    rustAbsorbSlice cursor' packed

private def rustAppendMessageCursor (cursor : Cursor) (label : String) (msg : List Byte) : Cursor :=
  let cursor' := rustAbsorbPackedBytesWithLen cursor (stringBytes label)
  rustAbsorbPackedBytesWithLen cursor' msg

private def rustAppendU64sCursor (cursor : Cursor) (label : String) (values : List Nat) : Cursor :=
  let cursor' := rustAbsorbPackedBytesWithLen cursor (stringBytes label)
  let cursor'' := absorbElem concreteCore cursor' (SuperNeo.F.ofNat values.length)
  let payload := toFieldElems (listFlatMap values splitU64Words)
  if payload.isEmpty then
    cursor''
  else
    rustAbsorbSlice cursor'' payload

private def newCursor : Cursor :=
  rustAppendMessageCursor emptyCursor poseidon2AppDomain transcriptAppLabelBytes

private def digestSections (appLabel : String) (sections : List (String × List Nat)) : List Byte :=
  let cursor := rustAppendMessageCursor emptyCursor poseidon2AppDomain (stringBytes appLabel)
  let cursor' := sections.foldl (fun acc (label, values) => rustAppendU64sCursor acc label values) cursor
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
  | .addi | .add | .sub | .addiw | .addw | .subw | .andi | .and | .ori | .or | .xori | .xor
  | .slti | .slt | .sltiu | .sltu
  | .slli | .sll | .srli | .srl | .srai | .sra
  | .slliw | .sllw | .srliw | .srlw | .sraiw | .sraw
  | .lui | .auipc | .fence => .nativeAlu
  | .mul | .mulh | .mulhsu | .mulhu | .mulw => .multiply
  | .divu | .remu | .divuw | .remuw => .unsignedDivRem
  | .div | .rem | .divw | .remw => .signedDivRem
  | .lb | .lbu | .lh | .lhu | .lw | .lwu | .sb | .sh | .sw => .narrowMemory
  | .ld | .sd => .alignedMemory
  | .jal | .jalr | .beq | .bne | .blt | .bge | .bltu | .bgeu | .ecall => .controlFlow

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
    let funct6 := bitField word 26 6
    let shamt6 := bitField word 20 6
    let shamt5 := bitField word 20 5
    if opcode = 0x13 then
      match funct3 with
      | 0 =>
          some
            { opcode := .addi
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := decodeIImm word
            , word := word }
      | 2 =>
          some
            { opcode := .slti
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := decodeIImm word
            , word := word }
      | 3 =>
          some
            { opcode := .sltiu
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := decodeIImm word
            , word := word }
      | 4 =>
          some
            { opcode := .xori
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := decodeIImm word
            , word := word }
      | 6 =>
          some
            { opcode := .ori
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := decodeIImm word
            , word := word }
      | 7 =>
          some
            { opcode := .andi
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := decodeIImm word
            , word := word }
      | 1 =>
          if funct6 = 0 then
            some
              { opcode := .slli
              , rd := rd
              , rs1 := rs1
              , rs2 := 0
              , imm := Int.ofNat shamt6
              , word := word }
          else
            none
      | 5 =>
          if funct6 = 0 then
            some
              { opcode := .srli
              , rd := rd
              , rs1 := rs1
              , rs2 := 0
              , imm := Int.ofNat shamt6
              , word := word }
          else if funct6 = 0b010000 then
            some
              { opcode := .srai
              , rd := rd
              , rs1 := rs1
              , rs2 := 0
              , imm := Int.ofNat shamt6
              , word := word }
          else
            none
      | _ => none
    else if opcode = 0x1b then
      match funct3, funct7 with
      | 0, _ =>
          some
            { opcode := .addiw
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := decodeIImm word
            , word := word }
      | 1, 0 =>
          some
            { opcode := .slliw
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := Int.ofNat shamt5
            , word := word }
      | 5, 0 =>
          some
            { opcode := .srliw
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := Int.ofNat shamt5
            , word := word }
      | 5, 0b0100000 =>
          some
            { opcode := .sraiw
            , rd := rd
            , rs1 := rs1
            , rs2 := 0
            , imm := Int.ofNat shamt5
            , word := word }
      | _, _ => none
    else if opcode = 0x33 then
      match funct3, funct7 with
      | 0, 0 => some { opcode := .add, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 0, 0b0100000 => some { opcode := .sub, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 1, 0 => some { opcode := .sll, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 2, 0 => some { opcode := .slt, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 3, 0 => some { opcode := .sltu, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 4, 0 => some { opcode := .xor, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 5, 0 => some { opcode := .srl, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 5, 0b0100000 => some { opcode := .sra, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 6, 0 => some { opcode := .or, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 7, 0 => some { opcode := .and, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 0, 1 => some { opcode := .mul, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 1, 1 => some { opcode := .mulh, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 2, 1 => some { opcode := .mulhsu, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 3, 1 => some { opcode := .mulhu, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 4, 1 => some { opcode := .div, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 5, 1 => some { opcode := .divu, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 6, 1 => some { opcode := .rem, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 7, 1 => some { opcode := .remu, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | _, _ => none
    else if opcode = 0x3b then
      match funct3, funct7 with
      | 0, 0 => some { opcode := .addw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 0, 0b0100000 => some { opcode := .subw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 1, 0 => some { opcode := .sllw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 5, 0 => some { opcode := .srlw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 5, 0b0100000 => some { opcode := .sraw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 0, 1 => some { opcode := .mulw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 4, 1 => some { opcode := .divw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 5, 1 => some { opcode := .divuw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 6, 1 => some { opcode := .remw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | 7, 1 => some { opcode := .remuw, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, word := word }
      | _, _ => none
    else if opcode = 0x17 then
      some
        { opcode := .auipc
        , rd := rd
        , rs1 := 0
        , rs2 := 0
        , imm := decodeUImm word
        , word := word }
    else if opcode = 0x37 then
      some
        { opcode := .lui
        , rd := rd
        , rs1 := 0
        , rs2 := 0
        , imm := decodeUImm word
        , word := word }
    else if opcode = 0x0f && funct3 = 0 then
      some
        { opcode := .fence
        , rd := 0
        , rs1 := 0
        , rs2 := 0
        , imm := 0
        , word := word }
    else if opcode = 0x03 && (funct3 = 0 || funct3 = 1 || funct3 = 2 || funct3 = 3 || funct3 = 4 || funct3 = 5 || funct3 = 6) then
      some
        { opcode :=
            match funct3 with
            | 0 => .lb
            | 1 => .lh
            | 2 => .lw
            | 3 => .ld
            | 4 => .lbu
            | 5 => .lhu
            | 6 => .lwu
            | _ => .ld
        , rd := rd
        , rs1 := rs1
        , rs2 := 0
        , imm := decodeIImm word
        , word := word }
    else if opcode = 0x23 && (funct3 = 0 || funct3 = 1 || funct3 = 2 || funct3 = 3) then
      let immLo := bitField word 7 5
      let immHi := bitField word 25 7
      let imm := immHi * pow2 5 + immLo
      some
        { opcode :=
            match funct3 with
            | 0 => .sb
            | 1 => .sh
            | 2 => .sw
            | 3 => .sd
            | _ => .sd
        , rd := 0
        , rs1 := rs1
        , rs2 := rs2
        , imm := signExtend imm 12
        , word := word }
    else if opcode = 0x6f then
      let imm20 := bitField word 31 1
      let imm10_1 := bitField word 21 10
      let imm11 := bitField word 20 1
      let imm19_12 := bitField word 12 8
      let imm := imm20 * pow2 20 + imm19_12 * pow2 12 + imm11 * pow2 11 + imm10_1 * 2
      some
        { opcode := .jal
        , rd := rd
        , rs1 := 0
        , rs2 := 0
        , imm := signExtend imm 21
        , word := word }
    else if opcode = 0x67 && funct3 = 0 then
      some
        { opcode := .jalr
        , rd := rd
        , rs1 := rs1
        , rs2 := 0
        , imm := decodeIImm word
        , word := word }
    else if opcode = 0x63 && (funct3 = 0 || funct3 = 1 || funct3 = 4 || funct3 = 5 || funct3 = 6 || funct3 = 7) then
      some
        { opcode :=
            match funct3 with
            | 0 => .beq
            | 1 => .bne
            | 4 => .blt
            | 5 => .bge
            | 6 => .bltu
            | 7 => .bgeu
            | _ => .beq
        , rd := 0
        , rs1 := rs1
        , rs2 := rs2
        , imm := decodeBImm word
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

private def narrowLoadOrStore?
    (stepIndex : Nat)
    (family : FamilyTag)
    (decoded : DecodedInstruction)
    (state nextBase : MachineState)
    (rs1Value rs2Value rdBefore : Nat) : Option ExecutedStep := do
  let (sizeBytes, signed, writesRam) <- narrowAccessSpec decoded.opcode
  let addr := addSigned64 rs1Value decoded.imm
  if addr % sizeBytes ≠ 0 then
    none
  else
    let byteOffset := addr % 8
    if byteOffset + sizeBytes > 8 then
      none
    else
      let backingAddr := addr - byteOffset
      let backingWord := readMemory state.memory backingAddr
      if writesRam then
        let blended := blendNarrow backingWord byteOffset sizeBytes rs2Value
        let next := { nextBase with memory := writeMemory state.memory backingAddr blended }
        some
          { stepIndex := stepIndex
          , family := family
          , decoded := decoded
          , prev := state
          , next := next
          , rs1Value := rs1Value
          , rs2Value := rs2Value
          , rdBefore := rdBefore
          , aluResult := blended
          , effectiveAddr := some addr
          , memoryBefore := some backingWord
          , memoryAfter := some blended
          , terminated := false }
      else
        let value := extractNarrow backingWord byteOffset sizeBytes signed
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd value }
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
          , memoryBefore := some backingWord
          , memoryAfter := some backingWord
          , terminated := false }

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
    | .addiw =>
        let result := addiwResult rs1Value decoded.imm
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
    | .addw =>
        let result := addwResult rs1Value rs2Value
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
    | .sub =>
        let result := mod64 (rs1Value + (u64Modulus - rs2Value))
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
    | .subw =>
        let result := subwResult rs1Value rs2Value
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
    | .andi =>
        let result := bitAnd64 rs1Value (mod64Int decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .and =>
        let result := bitAnd64 rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .ori =>
        let result := bitOr64 rs1Value (mod64Int decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .or =>
        let result := bitOr64 rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .xori =>
        let result := bitXor64 rs1Value (mod64Int decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .xor =>
        let result := bitXor64 rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .slti =>
        let result := boolToNat (signedWord rs1Value < decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .slt =>
        let result := boolToNat (signedWord rs1Value < signedWord rs2Value)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .sltiu =>
        let result := boolToNat (rs1Value < mod64Int decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .sltu =>
        let result := boolToNat (rs1Value < rs2Value)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .slli =>
        let result := shiftLeft64 rs1Value (mod64Int decoded.imm % 64)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .slliw =>
        let result := wordShiftLeftResult rs1Value (mod64Int decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .sll =>
        let result := shiftLeft64 rs1Value (rs2Value % 64)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .sllw =>
        let result := wordShiftLeftResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .srli =>
        let result := logicalShiftRight64 rs1Value (mod64Int decoded.imm % 64)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .srliw =>
        let result := wordLogicalShiftRightResult rs1Value (mod64Int decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .srl =>
        let result := logicalShiftRight64 rs1Value (rs2Value % 64)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .srlw =>
        let result := wordLogicalShiftRightResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .srai =>
        let result := arithmeticShiftRight64 rs1Value (mod64Int decoded.imm % 64)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .sraiw =>
        let result := wordArithmeticShiftRightResult rs1Value (mod64Int decoded.imm)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .sra =>
        let result := arithmeticShiftRight64 rs1Value (rs2Value % 64)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .sraw =>
        let result := wordArithmeticShiftRightResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .lui =>
        let result := mod64Int decoded.imm
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .auipc =>
        let result := addSigned64 state.pc decoded.imm
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .fence =>
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := nextBase
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 0
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .mul =>
        let result := mod64 (rs1Value * rs2Value)
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .mulh =>
        let result := mulHighSigned rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .mulhsu =>
        let result := mulHighSignedUnsigned rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .mulhu =>
        let result := mulHighUnsigned rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .mulw =>
        let result := mulwResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .div =>
        let result := divSignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .divu =>
        let result := divUnsignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .rem =>
        let result := remSignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .remu =>
        let result := remUnsignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .divw =>
        let result := divwSignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .divuw =>
        let result := divwUnsignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .remw =>
        let result := remwSignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .remuw =>
        let result := remwUnsignedResult rs1Value rs2Value
        let next := { nextBase with registers := writeRegister nextBase.registers decoded.rd result }
        some
          { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
          , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := result
          , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .lb | .lbu | .lh | .lhu | .lw | .lwu | .sb | .sh | .sw =>
        narrowLoadOrStore? stepIndex family decoded state nextBase rs1Value rs2Value rdBefore
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
    | .jal =>
        let link := nextBase.pc
        let next :=
          { nextBase with
            pc := addSigned64 state.pc decoded.imm
            registers := writeRegister nextBase.registers decoded.rd link }
        some
          { stepIndex := stepIndex
          , family := family
          , decoded := decoded
          , prev := state
          , next := next
          , rs1Value := rs1Value
          , rs2Value := rs2Value
          , rdBefore := rdBefore
          , aluResult := link
          , effectiveAddr := none
          , memoryBefore := none
          , memoryAfter := none
          , terminated := false }
    | .jalr =>
        let link := nextBase.pc
        let rawTarget := addSigned64 rs1Value decoded.imm
        let target := rawTarget - rawTarget % 2
        if target % 4 ≠ 0 then
          none
        else
          let next :=
            { nextBase with
              pc := target
              registers := writeRegister nextBase.registers decoded.rd link }
          some
            { stepIndex := stepIndex
            , family := family
            , decoded := decoded
            , prev := state
            , next := next
            , rs1Value := rs1Value
            , rs2Value := rs2Value
            , rdBefore := rdBefore
            , aluResult := link
            , effectiveAddr := none
            , memoryBefore := none
            , memoryAfter := none
            , terminated := false }
    | .beq =>
        let taken := rs1Value = rs2Value
        if taken then
          let target := addSigned64 state.pc decoded.imm
          if target % 4 ≠ 0 then
            none
          else
            let next := { nextBase with pc := target }
            some
              { stepIndex := stepIndex
              , family := family
              , decoded := decoded
              , prev := state
              , next := next
              , rs1Value := rs1Value
              , rs2Value := rs2Value
              , rdBefore := rdBefore
              , aluResult := 1
              , effectiveAddr := none
              , memoryBefore := none
              , memoryAfter := none
              , terminated := false }
        else
          some
            { stepIndex := stepIndex
            , family := family
            , decoded := decoded
            , prev := state
            , next := nextBase
            , rs1Value := rs1Value
            , rs2Value := rs2Value
            , rdBefore := rdBefore
            , aluResult := 0
            , effectiveAddr := none
            , memoryBefore := none
            , memoryAfter := none
            , terminated := false }
    | .bne =>
        let taken := rs1Value ≠ rs2Value
        if taken then
          let target := addSigned64 state.pc decoded.imm
          if target % 4 ≠ 0 then
            none
          else
            let next := { nextBase with pc := target }
            some
              { stepIndex := stepIndex
              , family := family
              , decoded := decoded
              , prev := state
              , next := next
              , rs1Value := rs1Value
              , rs2Value := rs2Value
              , rdBefore := rdBefore
              , aluResult := 1
              , effectiveAddr := none
              , memoryBefore := none
              , memoryAfter := none
              , terminated := false }
        else
          some
            { stepIndex := stepIndex
            , family := family
            , decoded := decoded
            , prev := state
            , next := nextBase
            , rs1Value := rs1Value
            , rs2Value := rs2Value
            , rdBefore := rdBefore
            , aluResult := 0
            , effectiveAddr := none
            , memoryBefore := none
            , memoryAfter := none
            , terminated := false }
    | .blt =>
        let taken := signedWord rs1Value < signedWord rs2Value
        if taken then
          let target := addSigned64 state.pc decoded.imm
          if target % 4 ≠ 0 then
            none
          else
            let next := { nextBase with pc := target }
            some
              { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
              , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 1
              , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
        else
          some
            { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := nextBase
            , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 0
            , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .bge =>
        let taken := signedWord rs1Value ≥ signedWord rs2Value
        if taken then
          let target := addSigned64 state.pc decoded.imm
          if target % 4 ≠ 0 then
            none
          else
            let next := { nextBase with pc := target }
            some
              { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
              , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 1
              , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
        else
          some
            { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := nextBase
            , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 0
            , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .bltu =>
        let taken := rs1Value < rs2Value
        if taken then
          let target := addSigned64 state.pc decoded.imm
          if target % 4 ≠ 0 then
            none
          else
            let next := { nextBase with pc := target }
            some
              { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
              , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 1
              , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
        else
          some
            { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := nextBase
            , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 0
            , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
    | .bgeu =>
        let taken := rs1Value ≥ rs2Value
        if taken then
          let target := addSigned64 state.pc decoded.imm
          if target % 4 ≠ 0 then
            none
          else
            let next := { nextBase with pc := target }
            some
              { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := next
              , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 1
              , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
        else
          some
            { stepIndex := stepIndex, family := family, decoded := decoded, prev := state, next := nextBase
            , rs1Value := rs1Value, rs2Value := rs2Value, rdBefore := rdBefore, aluResult := 0
            , effectiveAddr := none, memoryBefore := none, memoryAfter := none, terminated := false }
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

private inductive TraceOpcode where
  | real (opcode : Opcode)
  | virtual (opcode : TraceVirtualOpcode)
deriving DecidableEq, Repr

private structure TraceInstructionSpec where
  opcode : TraceOpcode
  rd : Nat
  rs1 : Nat
  rs2 : Nat
  imm : Int
  hint : Option Nat
deriving DecidableEq, Repr

private structure InlineTracePlan where
  sequence : List TraceInstructionSpec
  effectIndex : Nat
deriving DecidableEq, Repr

private def initialTraceRegisters (step : ExecutedStep) : Array Nat :=
  let base := step.prev.registers.toArray
  base ++ (List.replicate (64 - base.size) 0).toArray

private def traceRead (regs : Array Nat) (idx : Nat) : Nat :=
  regs.getD idx 0

private def traceWrite (regs : Array Nat) (idx value : Nat) : Array Nat :=
  let regs' := if idx = 0 then regs else regs.set! idx (mod64 value)
  regs'.set! 0 0

private def signMask (value : Nat) : Nat :=
  if signedWord value < 0 then u64Modulus - 1 else 0

private def executeTraceInstruction
    (spec : TraceInstructionSpec)
    (regs : Array Nat) : Nat × Nat × Nat × Nat × Nat × Array Nat :=
  let rs1Value := traceRead regs spec.rs1
  let rs2Value := traceRead regs spec.rs2
  let rdBefore := traceRead regs spec.rd
  let result :=
    match spec.opcode with
    | .real .addi => addSigned64 rs1Value spec.imm
    | .real .add => add64 rs1Value rs2Value
    | .real .sub => mod64 (rs1Value + (u64Modulus - rs2Value))
    | .real .andi => bitAnd64 rs1Value (mod64Int spec.imm)
    | .real .xor => bitXor64 rs1Value rs2Value
    | .real .sltu => boolToNat (rs1Value < rs2Value)
    | .real .mul => mod64 (rs1Value * rs2Value)
    | .real .mulhu => mulHighUnsigned rs1Value rs2Value
    | .virtual .movsign => signMask rs1Value
    | .virtual .advice
    | .virtual .changeDivisor
    | .virtual .assertValidDiv0
    | .virtual .assertMulNoOverflow
    | .virtual .assertLte
    | .virtual .assertValidUnsignedRemainder
    | .virtual .assertSignedDivIdentity
    | .virtual .assertSignedRemainderBounds
    | .virtual .move => spec.hint.getD 0
    | .virtual .signExtendWord => signExtendWord32 rs1Value
    | _ => 0
  let regs' := traceWrite regs spec.rd result
  let rdAfter := traceRead regs' spec.rd
  (rs1Value, rs2Value, rdBefore, rdAfter, result, regs')

private def ordinaryWritesRd (opcode : Opcode) (rd : Nat) : Bool :=
  match opcode with
  | .addi | .add | .sub | .addiw | .addw | .subw
  | .andi | .and | .ori | .or | .xori | .xor
  | .slti | .slt | .sltiu | .sltu
  | .slli | .sll | .srli | .srl | .srai | .sra
  | .slliw | .sllw | .srliw | .srlw | .sraiw | .sraw
  | .lui | .auipc
  | .mul | .mulh | .mulhsu | .mulhu | .mulw
  | .div | .divu | .rem | .remu | .divw | .divuw | .remw | .remuw
  | .lb | .lbu | .lh | .lhu | .lw | .lwu
  | .ld | .jal | .jalr => rd ≠ 0
  | .fence | .sb | .sh | .sw | .sd | .beq | .bne | .blt | .bge | .bltu | .bgeu | .ecall => false

private def finalizeInlinePlan (base : List TraceInstructionSpec) : InlineTracePlan :=
  { sequence := base
  , effectIndex := base.length - 1 }

private def multiplySequence? (step : ExecutedStep) : Option InlineTracePlan :=
  let rs1 := step.decoded.rs1
  let rs2 := step.decoded.rs2
  let rd := step.decoded.rd
  let v0 := inlineScratchRegisterBase
  let v1 := inlineScratchRegisterBase + 1
  let v2 := inlineScratchRegisterBase + 2
  let v3 := inlineScratchRegisterBase + 3
  match step.decoded.opcode with
  | .mul => none
  | .mulhu => none
  | .mulw =>
      some
        { sequence :=
            [ { opcode := .real .mul, rd := rd, rs1 := rs1, rs2 := rs2, imm := 0, hint := none }
            , { opcode := .virtual .signExtendWord, rd := rd, rs1 := rd, rs2 := 0, imm := 0, hint := none } ]
        , effectIndex := 1 }
  | .mulh =>
      some <| finalizeInlinePlan
          [ { opcode := .virtual .movsign, rd := v0, rs1 := rs1, rs2 := 0, imm := 0, hint := none }
          , { opcode := .virtual .movsign, rd := v1, rs1 := rs2, rs2 := 0, imm := 0, hint := none }
          , { opcode := .real .mul, rd := v0, rs1 := v0, rs2 := rs2, imm := 0, hint := none }
          , { opcode := .real .mul, rd := v1, rs1 := v1, rs2 := rs1, imm := 0, hint := none }
          , { opcode := .real .mulhu, rd := v2, rs1 := rs1, rs2 := rs2, imm := 0, hint := none }
          , { opcode := .real .add, rd := v2, rs1 := v2, rs2 := v0, imm := 0, hint := none }
          , { opcode := .real .add, rd := rd, rs1 := v2, rs2 := v1, imm := 0, hint := none } ]
  | .mulhsu =>
      some <| finalizeInlinePlan
          [ { opcode := .virtual .movsign, rd := v0, rs1 := rs1, rs2 := 0, imm := 0, hint := none }
          , { opcode := .real .andi, rd := v1, rs1 := v0, rs2 := 0, imm := 1, hint := none }
          , { opcode := .real .xor, rd := v2, rs1 := rs1, rs2 := v0, imm := 0, hint := none }
          , { opcode := .real .add, rd := v2, rs1 := v2, rs2 := v1, imm := 0, hint := none }
          , { opcode := .real .mulhu, rd := v3, rs1 := v2, rs2 := rs2, imm := 0, hint := none }
          , { opcode := .real .mul, rd := v2, rs1 := v2, rs2 := rs2, imm := 0, hint := none }
          , { opcode := .real .xor, rd := v3, rs1 := v3, rs2 := v0, imm := 0, hint := none }
          , { opcode := .real .xor, rd := v2, rs1 := v2, rs2 := v0, imm := 0, hint := none }
          , { opcode := .real .add, rd := v0, rs1 := v2, rs2 := v1, imm := 0, hint := none }
          , { opcode := .real .sltu, rd := v0, rs1 := v0, rs2 := v2, imm := 0, hint := none }
          , { opcode := .real .add, rd := rd, rs1 := v3, rs2 := v0, imm := 0, hint := none } ]
  | _ => none

private def divremSequence? (step : ExecutedStep) : Option InlineTracePlan := do
  let rs1 := step.decoded.rs1
  let rs2 := step.decoded.rs2
  let rd := step.decoded.rd
  let v0 := inlineScratchRegisterBase
  let v1 := inlineScratchRegisterBase + 1
  let v2 := inlineScratchRegisterBase + 2
  let v3 := inlineScratchRegisterBase + 3
  match step.decoded.opcode with
  | .divu | .remu | .divuw | .remuw =>
      let wordOp := step.decoded.opcode = .divuw || step.decoded.opcode = .remuw
      let useRemainder := step.decoded.opcode = .remu || step.decoded.opcode = .remuw
      let dividend := if wordOp then step.rs1Value % pow2 32 else step.rs1Value
      let divisor := if wordOp then step.rs2Value % pow2 32 else step.rs2Value
      let maxQuotient := if wordOp then pow2 32 - 1 else u64Modulus - 1
      let quotient := if divisor = 0 then maxQuotient else dividend / divisor
      let product := mod64 (quotient * divisor)
      let remainder := if divisor = 0 then dividend else dividend - product
      let rawResult := if useRemainder then remainder else quotient
      let finalResult := if wordOp then signExtendWord32 rawResult else rawResult
      let base :=
        [ { opcode := .virtual .advice, rd := v0, rs1 := rs1, rs2 := rs2, imm := 0, hint := some quotient }
        , { opcode := .virtual .assertValidDiv0, rd := v0, rs1 := rs2, rs2 := v0, imm := 0, hint := some quotient }
        , { opcode := .virtual .assertMulNoOverflow, rd := v1, rs1 := v0, rs2 := rs2, imm := 0, hint := some product }
        , { opcode := .real .mul, rd := v1, rs1 := v0, rs2 := rs2, imm := 0, hint := none }
        , { opcode := .virtual .assertLte, rd := v1, rs1 := v1, rs2 := rs1, imm := 0, hint := some product }
        , { opcode := .real .sub, rd := v2, rs1 := rs1, rs2 := v1, imm := 0, hint := none }
        , { opcode := .virtual .assertValidUnsignedRemainder, rd := v2, rs1 := v2, rs2 := rs2, imm := 0, hint := some remainder }
        , { opcode := .virtual .move, rd := rd, rs1 := if useRemainder then v2 else v0, rs2 := 0, imm := 0, hint := some rawResult } ]
      if step.decoded.opcode = .divuw || step.decoded.opcode = .remuw then
        some <| finalizeInlinePlan
          (base ++ [{ opcode := .virtual .signExtendWord, rd := rd, rs1 := rd, rs2 := 0, imm := 0, hint := some finalResult }])
      else
        some <| finalizeInlinePlan base
  | .div | .rem =>
      let useRemainder := step.decoded.opcode = .rem
      let dividend := signedWord step.rs1Value
      let divisor := signedWord step.rs2Value
      let overflow := dividend = minSigned64 && divisor = -1
      let effectiveDivisor := if overflow then (1 : Int) else divisor
      let quotient :=
        if divisor = 0 then
          (-1 : Int)
        else if overflow then
          dividend
        else
          intDivTrunc dividend divisor
      let remainder :=
        if divisor = 0 then
          dividend
        else if overflow then
          0
        else
          intRemTrunc dividend divisor
      let effectiveDivisorNat := mod64Int effectiveDivisor
      let quotientNat := mod64Int quotient
      let remainderNat := mod64Int remainder
      let finalResult := if useRemainder then remainderNat else quotientNat
      some <| finalizeInlinePlan
        [ { opcode := .virtual .changeDivisor, rd := v0, rs1 := rs1, rs2 := rs2, imm := 0, hint := some effectiveDivisorNat }
        , { opcode := .virtual .advice, rd := v1, rs1 := rs1, rs2 := rs2, imm := 0, hint := some quotientNat }
        , { opcode := .real .mul, rd := v2, rs1 := v1, rs2 := v0, imm := 0, hint := none }
        , { opcode := .real .sub, rd := v3, rs1 := rs1, rs2 := v2, imm := 0, hint := none }
        , { opcode := .virtual .assertSignedDivIdentity, rd := v1, rs1 := rs1, rs2 := v0, imm := 0, hint := some quotientNat }
        , { opcode := .virtual .assertSignedRemainderBounds, rd := v3, rs1 := v3, rs2 := v0, imm := 0, hint := some remainderNat }
        , { opcode := .virtual .move, rd := rd, rs1 := if useRemainder then v3 else v1, rs2 := 0, imm := 0, hint := some finalResult } ]
  | .divw | .remw =>
      let useRemainder := step.decoded.opcode = .remw
      let dividend := signedWord32 step.rs1Value
      let divisor := signedWord32 step.rs2Value
      let overflow := dividend = minSigned32 && divisor = -1
      let effectiveDivisor := if overflow then (1 : Int) else divisor
      let quotient :=
        if divisor = 0 then
          (-1 : Int)
        else if overflow then
          dividend
        else
          intDivTrunc dividend divisor
      let remainder :=
        if divisor = 0 then
          dividend
        else if overflow then
          0
        else
          intRemTrunc dividend divisor
      let effectiveDivisorNat := mod64Int effectiveDivisor
      let quotientNat := mod64Int quotient
      let remainderNat := mod64Int remainder
      let rawResult := if useRemainder then mod32Int remainder else mod32Int quotient
      let finalResult := signExtendWord32 rawResult
      some <| finalizeInlinePlan
        [ { opcode := .virtual .changeDivisor, rd := v0, rs1 := rs1, rs2 := rs2, imm := 0, hint := some effectiveDivisorNat }
        , { opcode := .virtual .advice, rd := v1, rs1 := rs1, rs2 := rs2, imm := 0, hint := some quotientNat }
        , { opcode := .real .mul, rd := v2, rs1 := v1, rs2 := v0, imm := 0, hint := none }
        , { opcode := .real .sub, rd := v3, rs1 := rs1, rs2 := v2, imm := 0, hint := none }
        , { opcode := .virtual .assertSignedDivIdentity, rd := v1, rs1 := rs1, rs2 := v0, imm := 0, hint := some quotientNat }
        , { opcode := .virtual .assertSignedRemainderBounds, rd := v3, rs1 := v3, rs2 := v0, imm := 0, hint := some remainderNat }
        , { opcode := .virtual .move, rd := rd, rs1 := if useRemainder then v3 else v1, rs2 := 0, imm := 0, hint := some rawResult }
        , { opcode := .virtual .signExtendWord, rd := rd, rs1 := rd, rs2 := 0, imm := 0, hint := some finalResult } ]
  | _ => none

private def expandedRowOfStep (traceIndex : Nat) (step : ExecutedStep) : ExpandedRowView :=
  let writesRd :=
    ordinaryWritesRd step.decoded.opcode step.decoded.rd
  { traceIndex := traceIndex
  , stepIndex := step.stepIndex
  , sequenceIndex := 0
  , pc := step.prev.pc
  , nextPc := step.next.pc
  , word := step.decoded.word
  , opcode := step.decoded.opcode
  , traceOpcode := some step.decoded.opcode
  , traceVirtualOpcode := none
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
  , writesRam :=
      match step.decoded.opcode with
      | .sb | .sh | .sw | .sd => true
      | _ => false
  , halted := step.next.halted
  , isFirstInSequence := true
  , virtualSequenceRemaining := none
  , isEffectRow := true
  , isCommitRow := true
  , isReal := true }

private def inlineRowsAux
    (step : ExecutedStep)
    (traceIndexStart : Nat)
    (effectIndex : Nat)
    (sequence : List TraceInstructionSpec)
    (regs : Array Nat)
    (sequenceIndex : Nat) : List ExpandedRowView :=
  match sequence with
  | [] => []
  | spec :: rest =>
      let (rs1Value, rs2Value, rdBefore, rdAfter, result, regs') := executeTraceInstruction spec regs
      let remaining := rest.length
      let isReal := remaining = 0
      let isEffectRow := sequenceIndex = effectIndex
      let isCommitRow := remaining = 0
      let row : ExpandedRowView :=
        { traceIndex := traceIndexStart + sequenceIndex
        , stepIndex := step.stepIndex
        , sequenceIndex := sequenceIndex
        , pc := step.prev.pc
        , nextPc := if isReal then step.next.pc else step.prev.pc
        , word := step.decoded.word
        , opcode := step.decoded.opcode
        , traceOpcode := match spec.opcode with | .real opcode => some opcode | .virtual _ => none
        , traceVirtualOpcode := match spec.opcode with | .real _ => none | .virtual opcode => some opcode
        , family := step.family
        , rs1 := spec.rs1
        , rs1Value := rs1Value
        , rs2 := spec.rs2
        , rs2Value := rs2Value
        , rd := spec.rd
        , rdBefore := rdBefore
        , rdAfter := rdAfter
        , imm := spec.imm
        , aluResult := result
        , effectiveAddr := none
        , memoryBefore := none
        , memoryAfter := none
        , writesRd := spec.rd ≠ 0
        , writesRam := false
        , halted := isReal && step.next.halted
        , isFirstInSequence := sequenceIndex = 0
        , virtualSequenceRemaining := some remaining
        , isEffectRow := isEffectRow
        , isCommitRow := isCommitRow
        , isReal := isReal }
      row :: inlineRowsAux step traceIndexStart effectIndex rest regs' (sequenceIndex + 1)

private def expandedRowsOfStep (traceIndexStart : Nat) (step : ExecutedStep) : List ExpandedRowView :=
  match multiplySequence? step <|> divremSequence? step with
  | some plan => inlineRowsAux step traceIndexStart plan.effectIndex plan.sequence (initialTraceRegisters step) 0
  | none => [expandedRowOfStep traceIndexStart step]

private def expandedRowsOfStepsAux (traceIndex : Nat) : List ExecutedStep → List ExpandedRowView
  | [] => []
  | step :: rest =>
      let rows := expandedRowsOfStep traceIndex step
      rows ++ expandedRowsOfStepsAux (traceIndex + rows.length) rest

private def expandedRowsOfSteps (steps : List ExecutedStep) : List ExpandedRowView :=
  expandedRowsOfStepsAux 0 steps

private def stage1SummaryOfRows (rows : List ExpandedRowView) : Stage1SummaryView :=
  { rows :=
      rows.map fun row =>
        { traceIndex := row.traceIndex
        , stepIndex := row.stepIndex
        , sequenceIndex := row.sequenceIndex
        , fetchPc := row.pc
        , fetchedWord := row.word
        , opcode := row.opcode
        , traceOpcode := row.traceOpcode
        , traceVirtualOpcode := row.traceVirtualOpcode
        , family := row.family
        , nextPc := row.nextPc
        , aluResult := row.aluResult
        , effectiveAddr := row.effectiveAddr
        , writesRd := row.writesRd
        , rd := row.rd
        , rdAfter := row.rdAfter
        , isFirstInSequence := row.isFirstInSequence
        , virtualSequenceRemaining := row.virtualSequenceRemaining
        , isEffectRow := row.isEffectRow
        , isCommitRow := row.isCommitRow
        , isReal := row.isReal
        , preservesX0 := row.rd = 0 || not row.writesRd }
  }

private def stage3SummaryOfRows (rows : List ExpandedRowView) : Stage3SummaryView :=
  let rows := rows.filter (·.isReal)
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

private def opcodeWord : Opcode → Nat
  | .addi => 0
  | .add => 1
  | .sub => 2
  | .andi => 3
  | .and => 4
  | .ori => 5
  | .or => 6
  | .xori => 7
  | .xor => 8
  | .slti => 9
  | .slt => 10
  | .sltiu => 11
  | .sltu => 12
  | .slli => 13
  | .sll => 14
  | .srli => 15
  | .srl => 16
  | .srai => 17
  | .sra => 18
  | .lui => 19
  | .auipc => 20
  | .fence => 21
  | .ld => 22
  | .sd => 23
  | .ecall => 24
  | .jal => 25
  | .jalr => 26
  | .beq => 27
  | .bne => 28
  | .blt => 29
  | .bge => 30
  | .bltu => 31
  | .bgeu => 32
  | .lb => 33
  | .lbu => 34
  | .lh => 35
  | .lhu => 36
  | .lw => 37
  | .lwu => 38
  | .sb => 39
  | .sh => 40
  | .sw => 41
  | .mul => 42
  | .mulh => 43
  | .mulhsu => 44
  | .mulhu => 45
  | .mulw => 46
  | .div => 47
  | .divu => 48
  | .rem => 49
  | .remu => 50
  | .divw => 51
  | .divuw => 52
  | .remw => 53
  | .remuw => 54
  | .addiw => 55
  | .addw => 56
  | .subw => 57
  | .slliw => 58
  | .sllw => 59
  | .srliw => 60
  | .srlw => 61
  | .sraiw => 62
  | .sraw => 63

private def familyWord : FamilyTag → Nat
  | .nativeAlu => 0
  | .alignedMemory => 1
  | .controlFlow => 2
  | .narrowMemory => 3
  | .multiply => 4
  | .unsignedDivRem => 5
  | .signedDivRem => 6

private def traceVirtualOpcodeWord : TraceVirtualOpcode → Nat
  | .movsign => 0
  | .advice => 1
  | .changeDivisor => 2
  | .assertValidDiv0 => 3
  | .assertMulNoOverflow => 4
  | .assertLte => 5
  | .assertValidUnsignedRemainder => 6
  | .assertSignedDivIdentity => 7
  | .assertSignedRemainderBounds => 8
  | .move => 9
  | .signExtendWord => 10

private def flattenRow (row : ExpandedRowView) : List Nat :=
  [ row.traceIndex
  , row.stepIndex
  , row.sequenceIndex
  , row.pc
  , row.nextPc
  , row.word
  , opcodeWord row.opcode
  , row.traceOpcode.map opcodeWord |>.getD 0
  , row.traceVirtualOpcode.map traceVirtualOpcodeWord |>.getD 0
  , boolToNat row.traceOpcode.isSome
  , boolToNat row.traceVirtualOpcode.isSome
  , familyWord row.family
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
  , boolToNat row.isFirstInSequence
  , row.virtualSequenceRemaining.getD (pow2 16 - 1)
  , boolToNat row.isEffectRow
  , boolToNat row.isCommitRow
  , boolToNat row.isReal
  , row.effectiveAddr.getD 0
  , row.memoryBefore.getD 0
  , row.memoryAfter.getD 0 ]

private def flattenStage1 (stage1 : Stage1SummaryView) : List Nat :=
  listFlatMap stage1.rows fun row =>
    [ row.traceIndex
    , row.stepIndex
    , row.sequenceIndex
    , row.fetchPc
    , row.fetchedWord
    , opcodeWord row.opcode
    , row.traceOpcode.map opcodeWord |>.getD 0
    , row.traceVirtualOpcode.map traceVirtualOpcodeWord |>.getD 0
    , boolToNat row.traceOpcode.isSome
    , boolToNat row.traceVirtualOpcode.isSome
    , familyWord row.family
    , row.nextPc
    , row.aluResult
    , row.effectiveAddr.getD 0
    , boolToNat row.writesRd
    , row.rd
    , row.rdAfter
    , boolToNat row.isFirstInSequence
    , row.virtualSequenceRemaining.getD (pow2 16 - 1)
    , boolToNat row.isEffectRow
    , boolToNat row.isCommitRow
    , boolToNat row.isReal
    , boolToNat row.preservesX0 ]

private def flattenStage2 (stage2 : Stage2SummaryView) : List Nat :=
  let registerReads :=
    listFlatMap stage2.registerReads fun event =>
      [ event.traceIndex
      , event.stepIndex
      , match event.role with | .rs1 => 0 | .rs2 => 1
      , event.reg
      , event.value ]
  let registerWrites :=
    listFlatMap stage2.registerWrites fun event =>
      [event.traceIndex, event.stepIndex, event.reg, event.previous, event.next]
  let ramEvents :=
    listFlatMap stage2.ramEvents fun event =>
      [ event.traceIndex
      , event.stepIndex
      , match event.kind with | .read => 0 | .write => 1
      , event.addr
      , event.previous
      , event.next ]
  let twistLinks :=
    listFlatMap stage2.twistLinks fun event =>
      [ event.traceIndex
      , event.stepIndex
      , familyWord event.family
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
  let next := rustAppendMessageCursor cursor label msg
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
  let next := rustAppendU64sCursor cursor label values
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
  let rows := expandedRowsOfSteps steps
  let stage1 := stage1SummaryOfRows rows
  let stage2 := stage2SummaryOfExecutionRows rows
  let stage3 := stage3SummaryOfExecutionRows rows
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
      , ("executionImportedSequenceSemantics",
          importedExpandedRowSequenceSemanticsCheck actual.executionRows)
      , ("stage1ImportedClosure", importedStage1ClosureCheck actual.executionRows actual.stage1)
      , ("stage1ImportedProjectionSemantics", importedStage1ProjectionSemanticsCheck actual.executionRows actual.stage1)
      , ("stage1ImportedLocalSemantics", importedStage1LocalSemanticsCheck actual.executionRows actual.stage1)
      , ("stage2ImportedClosure", importedStage2ClosureCheck actual.executionRows actual.stage2)
      , ("stage2ImportedHistorySemantics", importedStage2HistorySemanticsCheck actual.executionRows actual.stage2)
      , ("stage2ImportedAuthenticatedHistorySemantics", importedStage2AuthenticatedHistorySemanticsCheck actual.executionRows actual.stage2)
      , ("stage2ImportedLocalSemantics", importedStage2LocalSemanticsCheck actual.executionRows actual.stage2)
      , ("stage3ImportedClosure", importedStage3ClosureCheck actual.executionRows actual.stage3)
      , ("stage3ImportedLocalSemantics", importedStage3LocalSemanticsCheck actual.executionRows actual.stage3)
      , ("stage3ImportedContinuitySemantics", importedStage3ContinuitySemanticsCheck actual.executionRows actual.stage3)
      , ("stage3ImportedExportSemantics", importedStage3ExportSemanticsCheck actual.executionRows actual.stage3)
      , ("singleRowLoweringRefinement", singleRowLoweringRefinementCheck actual.executionRows)
      , ("multiplyLoweringRefinement", multiplyLoweringRefinementCheck actual.executionRows)
      , ("unsignedDivRemLoweringRefinement", unsignedDivRemLoweringRefinementCheck actual.executionRows)
      , ("signedDivRemLoweringRefinement", signedDivRemLoweringRefinementCheck actual.executionRows)
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
