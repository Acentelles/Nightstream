import Nightstream.Rv64IM.Execution.NativeAluEncodedArithmetic

/-!
Owns exact opcode-specialized word-level arithmetic consequences for the RV64IM
native-ALU family. This file uses the explicit word/limb representation bridge
from `StepComposition` to turn encoded arithmetic equalities into exact Stage-1
word equalities and exact authenticated word-level writeback consequences.
-/

namespace Nightstream.Rv64IM

section

variable
  {BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _}
  [OfNat Limb 0]
  {pkg :
    StepCompositionProofPackage
      BytecodeAddr
      Pc
      RegIdx
      VirtualOpcode
      AluOp
      BranchOp
      MemWidth
      DivRemKind
      RamAddr
      Word
      StateLocation
      RegisterTimeline
      RamTimeline
      Limb
      ArchitecturalInputs
      AuthenticatedReads
      WitnessAssignment
      Output
      StateEffect
      PreparedStep}

local notation "NativeFacts" =>
  ExactOpcodeFamilySemantics
    BytecodeAddr
    Pc
    RegIdx
    VirtualOpcode
    AluOp
    BranchOp
    MemWidth
    DivRemKind
    RamAddr
    Word
    StateLocation
    RegisterTimeline
    RamTimeline
    Limb
    ArchitecturalInputs
    AuthenticatedReads
    WitnessAssignment
    Output
    StateEffect
    PreparedStep
    pkg

private theorem encodedBinary
  (opWord : Word → Word → Word)
  (opEncoded : LimbPair Limb → LimbPair Limb → LimbPair Limb)
  (hCompat :
    ∀ a b,
      pkg.wordToLimbPair (opWord a b) =
        opEncoded (pkg.wordToLimbPair a) (pkg.wordToLimbPair b))
  (x y : LimbPair Limb) :
  opEncoded x y =
    pkg.wordToLimbPair (opWord (pkg.limbPairToWord x) (pkg.limbPairToWord y)) := by
  calc
    opEncoded x y
      =
        opEncoded
          (pkg.wordToLimbPair (pkg.limbPairToWord x))
          (pkg.wordToLimbPair (pkg.limbPairToWord y)) := by
            rw
              [ wordEncodingRoundTripPair_of_stepComposition pkg x
              , wordEncodingRoundTripPair_of_stepComposition pkg y
              ]
    _ =
        pkg.wordToLimbPair
          (opWord (pkg.limbPairToWord x) (pkg.limbPairToWord y)) := by
            symm
            exact hCompat _ _

private theorem encodedBinaryImm
  (opWord : Word → Word → Word)
  (opEncoded : LimbPair Limb → LimbPair Limb → LimbPair Limb)
  (hCompat :
    ∀ a b,
      pkg.wordToLimbPair (opWord a b) =
        opEncoded (pkg.wordToLimbPair a) (pkg.wordToLimbPair b))
  (x : LimbPair Limb)
  (imm : Word) :
  opEncoded x (pkg.wordToLimbPair imm) =
    pkg.wordToLimbPair (opWord (pkg.limbPairToWord x) imm) := by
  calc
    opEncoded x (pkg.wordToLimbPair imm)
      =
        opEncoded
          (pkg.wordToLimbPair (pkg.limbPairToWord x))
          (pkg.wordToLimbPair imm) := by
            rw [wordEncodingRoundTripPair_of_stepComposition pkg x]
    _ = pkg.wordToLimbPair (opWord (pkg.limbPairToWord x) imm) := by
      symm
      exact hCompat _ _

private theorem encodedUnaryImm
  (opWord : Word → Word)
  (opEncoded : LimbPair Limb → LimbPair Limb)
  (hCompat :
    ∀ a,
      pkg.wordToLimbPair (opWord a) = opEncoded (pkg.wordToLimbPair a))
  (imm : Word) :
  opEncoded (pkg.wordToLimbPair imm) =
    pkg.wordToLimbPair (opWord imm) := by
  symm
  exact hCompat _

private theorem encodedPcImm
  (opWord : Word → Word → Word)
  (opEncoded : LimbPair Limb → LimbPair Limb → LimbPair Limb)
  (hCompat :
    ∀ pc imm,
      pkg.wordToLimbPair (opWord pc imm) =
        opEncoded (pkg.wordToLimbPair pc) (pkg.wordToLimbPair imm))
  (pc imm : Word) :
  opEncoded (pkg.wordToLimbPair pc) (pkg.wordToLimbPair imm) =
    pkg.wordToLimbPair (opWord pc imm) := by
  symm
  exact hCompat _ _

private theorem encodedZero
  (zeroWord : Word)
  (zeroEncoded : LimbPair Limb)
  (hCompat : pkg.wordToLimbPair zeroWord = zeroEncoded) :
  zeroEncoded = pkg.wordToLimbPair zeroWord := by
  simpa using Eq.symm hCompat

private theorem encodedWordArithmetic_of_opcode
  (facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.wordToLimbPair
      (NativeAluWordResult
        pkg.nativeAluWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.executionRow.lane
        pkg.limbPairToWord
        opcode) := by
  let wordResult :=
    NativeAluWordResult
      pkg.nativeAluWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.executionRow.lane
      pkg.limbPairToWord
      opcode
  have hCompat := nativeAluWordCompatibility_of_stepComposition pkg
  cases opcode with
  | add =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  add_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.add
                    pkg.nativeAluEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | addi =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  addi_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.add
                    pkg.nativeAluEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | sub =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.sub
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  sub_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.sub
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.sub
                    pkg.nativeAluEncodedOps.sub
                    hCompat.sub
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | andOp =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.andOp
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  and_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.andOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.andOp
                    pkg.nativeAluEncodedOps.andOp
                    hCompat.andOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | andi =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.andOp
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  andi_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.andOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.andOp
                    pkg.nativeAluEncodedOps.andOp
                    hCompat.andOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | orOp =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.orOp
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  or_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.orOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.orOp
                    pkg.nativeAluEncodedOps.orOp
                    hCompat.orOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | ori =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.orOp
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  ori_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.orOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.orOp
                    pkg.nativeAluEncodedOps.orOp
                    hCompat.orOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | xorOp =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.xorOp
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  xor_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.xorOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.xorOp
                    pkg.nativeAluEncodedOps.xorOp
                    hCompat.xorOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | xori =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.xorOp
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  xori_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.xorOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.xorOp
                    pkg.nativeAluEncodedOps.xorOp
                    hCompat.xorOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | slt =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.slt
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  slt_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.slt
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.slt
                    pkg.nativeAluEncodedOps.slt
                    hCompat.slt
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | slti =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.slt
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  slti_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.slt
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.slt
                    pkg.nativeAluEncodedOps.slt
                    hCompat.slt
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | sltu =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.sltu
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  sltu_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.sltu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.sltu
                    pkg.nativeAluEncodedOps.sltu
                    hCompat.sltu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | sltiu =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.sltu
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  sltiu_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.sltu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.sltu
                    pkg.nativeAluEncodedOps.sltu
                    hCompat.sltu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | lui =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.lui
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  lui_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair (pkg.nativeAluWordOps.lui pkg.decodedRow.imm) := by
              exact encodedUnaryImm
                pkg.nativeAluWordOps.lui
                pkg.nativeAluEncodedOps.lui
                hCompat.lui
                _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | auipc =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.nativeAluEncodedOps.auipc
              (pkg.wordToLimbPair pkg.executionRow.lane.pc)
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  auipc_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.auipc
                pkg.executionRow.lane.pc
                pkg.decodedRow.imm) := by
                  exact encodedPcImm
                    pkg.nativeAluWordOps.auipc
                    pkg.nativeAluEncodedOps.auipc
                    hCompat.auipc
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | fence =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          = pkg.nativeAluEncodedOps.zero := by
              simpa using
                fence_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ = pkg.wordToLimbPair pkg.nativeAluWordOps.zero := by
          exact encodedZero pkg.nativeAluWordOps.zero pkg.nativeAluEncodedOps.zero hCompat.zero
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | ecall =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          = pkg.nativeAluEncodedOps.zero := by
              simpa using
                ecall_encodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode
        _ = pkg.wordToLimbPair pkg.nativeAluWordOps.zero := by
          exact encodedZero pkg.nativeAluWordOps.zero pkg.nativeAluEncodedOps.zero hCompat.zero
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]

private theorem wordArithmetic_of_opcode
  (facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode) :
  pkg.executionRow.results.aluResult =
    NativeAluWordResult
      pkg.nativeAluWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.executionRow.lane
      pkg.limbPairToWord
      opcode := by
  apply wordToLimbPair_injective_of_stepComposition pkg
  exact encodedWordArithmetic_of_opcode facts hOpcode

private theorem authenticatedEncodedWordArithmetic_of_writeOpcode
  (facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair
      (NativeAluWordResult
        pkg.nativeAluWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.executionRow.lane
        pkg.limbPairToWord
        opcode) := by
  let wordResult :=
    NativeAluWordResult
      pkg.nativeAluWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.executionRow.lane
      pkg.limbPairToWord
      opcode
  have hCompat := nativeAluWordCompatibility_of_stepComposition pkg
  cases opcode with
  | add =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  add_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.add
                    pkg.nativeAluEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | addi =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  addi_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.add
                    pkg.nativeAluEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | sub =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.sub
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  sub_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.sub
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.sub
                    pkg.nativeAluEncodedOps.sub
                    hCompat.sub
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | andOp =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.andOp
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  and_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.andOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.andOp
                    pkg.nativeAluEncodedOps.andOp
                    hCompat.andOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | andi =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.andOp
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  andi_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.andOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.andOp
                    pkg.nativeAluEncodedOps.andOp
                    hCompat.andOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | orOp =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.orOp
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  or_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.orOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.orOp
                    pkg.nativeAluEncodedOps.orOp
                    hCompat.orOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | ori =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.orOp
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  ori_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.orOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.orOp
                    pkg.nativeAluEncodedOps.orOp
                    hCompat.orOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | xorOp =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.xorOp
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  xor_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.xorOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.xorOp
                    pkg.nativeAluEncodedOps.xorOp
                    hCompat.xorOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | xori =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.xorOp
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  xori_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.xorOp
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.xorOp
                    pkg.nativeAluEncodedOps.xorOp
                    hCompat.xorOp
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | slt =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.slt
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  slt_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.slt
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.slt
                    pkg.nativeAluEncodedOps.slt
                    hCompat.slt
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | slti =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.slt
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  slti_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.slt
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.slt
                    pkg.nativeAluEncodedOps.slt
                    hCompat.slt
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | sltu =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.sltu
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  sltu_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.sltu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.nativeAluWordOps.sltu
                    pkg.nativeAluEncodedOps.sltu
                    hCompat.sltu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | sltiu =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.sltu
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  sltiu_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.sltu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.nativeAluWordOps.sltu
                    pkg.nativeAluEncodedOps.sltu
                    hCompat.sltu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | lui =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.lui
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  lui_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair (pkg.nativeAluWordOps.lui pkg.decodedRow.imm) := by
              exact encodedUnaryImm
                pkg.nativeAluWordOps.lui
                pkg.nativeAluEncodedOps.lui
                hCompat.lui
                _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | auipc =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.nativeAluEncodedOps.auipc
              (pkg.wordToLimbPair pkg.executionRow.lane.pc)
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa using
                  auipc_authenticatedEncodedArithmetic_of_nativeAluEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.nativeAluWordOps.auipc
                pkg.executionRow.lane.pc
                pkg.decodedRow.imm) := by
                  exact encodedPcImm
                    pkg.nativeAluWordOps.auipc
                    pkg.nativeAluEncodedOps.auipc
                    hCompat.auipc
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, NativeAluWordResult]
  | fence =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites
  | ecall =>
      simp [NativeAluOpcode.writesArchitecturalRd] at hWrites

private theorem authenticatedWordArithmetic_of_writeOpcode
  (facts : NativeFacts)
  {opcode : NativeAluOpcode}
  (hOpcode : pkg.nativeAluOpcode = opcode)
  (hWrites : opcode.writesArchitecturalRd = true)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    NativeAluWordResult
      pkg.nativeAluWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.executionRow.lane
      pkg.limbPairToWord
      opcode := by
  have hEncoded :=
    authenticatedEncodedWordArithmetic_of_writeOpcode facts hOpcode hWrites hRd
  have hRound :=
    wordEncodingRoundTripWord_of_stepComposition
      pkg
      (NativeAluWordResult
        pkg.nativeAluWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.executionRow.lane
        pkg.limbPairToWord
        opcode)
  simpa [hRound] using congrArg pkg.limbPairToWord hEncoded

theorem add_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .add) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.add
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem add_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .add)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.add
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem addi_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .addi) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.add
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem addi_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .addi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.add
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem sub_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sub) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.sub
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem sub_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sub)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.sub
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem and_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andOp) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.andOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem and_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.andOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem andi_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andi) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.andOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem andi_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .andi)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.andOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem or_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .orOp) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.orOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem or_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .orOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.orOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem ori_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ori) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.orOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem ori_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.orOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem xor_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xorOp) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.xorOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem xor_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xorOp)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.xorOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem xori_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xori) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.xorOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem xori_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .xori)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.xorOp
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem slt_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slt) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.slt
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem slt_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slt)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.slt
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem slti_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slti) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.slt
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem slti_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .slti)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.slt
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem sltu_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltu) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.sltu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem sltu_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.sltu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem sltiu_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltiu) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.sltu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem sltiu_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .sltiu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.sltu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem lui_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .lui) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.lui pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem lui_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .lui)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.lui pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem auipc_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .auipc) :
  pkg.executionRow.results.aluResult =
    pkg.nativeAluWordOps.auipc
      pkg.executionRow.lane.pc
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem auipc_authenticatedWordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .auipc)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.nativeAluWordOps.auipc
      pkg.executionRow.lane.pc
      pkg.decodedRow.imm := by
  simpa [NativeAluWordResult] using
    authenticatedWordArithmetic_of_writeOpcode
      facts
      hOpcode
      (by simp [NativeAluOpcode.writesArchitecturalRd])
      hRd

theorem fence_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .fence) :
  pkg.executionRow.results.aluResult = pkg.nativeAluWordOps.zero := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem ecall_wordArithmetic_of_nativeAluWordArithmetic
  (facts : NativeFacts)
  (hOpcode : pkg.nativeAluOpcode = .ecall) :
  pkg.executionRow.results.aluResult = pkg.nativeAluWordOps.zero := by
  simpa [NativeAluWordResult] using wordArithmetic_of_opcode facts hOpcode

end

end Nightstream.Rv64IM
