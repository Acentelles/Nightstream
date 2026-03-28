import Nightstream.Rv64IM.Execution.WordShiftOpcodeSemantics

/-!
Owns exact opcode-specialized word-level arithmetic consequences for the RV64IM
word/shift family. This file uses the explicit word/limb representation bridge
from `StepComposition` to turn encoded word-shift equalities into exact Stage-1
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

local notation "WordShiftFacts" =>
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

private theorem encodedArithmetic_of_opcode
  (_facts : WordShiftFacts)
  {opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = opcode) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    WordShiftEncodedResult
      pkg.wordShiftEncodedOps
      pkg.wordToLimbPair
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      opcode := by
  calc
    pkg.wordToLimbPair pkg.executionRow.results.aluResult
      = pkg.aluWritebackValue :=
        encodedAluResult_of_stepComposition pkg
    _ =
        WordShiftEncodedResult
          pkg.wordShiftEncodedOps
          pkg.wordToLimbPair
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          opcode := by
            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg

private theorem encodedWordArithmetic_of_opcode
  (facts : WordShiftFacts)
  {opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = opcode) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.wordToLimbPair
      (WordShiftWordResult
        pkg.wordShiftWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.limbPairToWord
        opcode) := by
  let wordResult :=
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode
  have hCompat := wordShiftWordCompatibility_of_stepComposition pkg
  cases opcode with
  | addw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.add
                    pkg.wordShiftEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | addiw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.add
                    pkg.wordShiftEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | subw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.sub
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sub
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.sub
                    pkg.wordShiftEncodedOps.sub
                    hCompat.sub
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | sllw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.sll
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sll
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.sll
                    pkg.wordShiftEncodedOps.sll
                    hCompat.sll
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | slliw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.sll
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sll
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.sll
                    pkg.wordShiftEncodedOps.sll
                    hCompat.sll
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | srlw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.srl
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.srl
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.srl
                    pkg.wordShiftEncodedOps.srl
                    hCompat.srl
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | srliw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.srl
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.srl
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.srl
                    pkg.wordShiftEncodedOps.srl
                    hCompat.srl
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | sraw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.sra
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sra
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.sra
                    pkg.wordShiftEncodedOps.sra
                    hCompat.sra
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | sraiw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.wordShiftEncodedOps.sra
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using encodedArithmetic_of_opcode facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sra
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.sra
                    pkg.wordShiftEncodedOps.sra
                    hCompat.sra
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]

private theorem wordArithmetic_of_opcode
  (facts : WordShiftFacts)
  {opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = opcode) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode := by
  apply wordToLimbPair_injective_of_stepComposition pkg
  exact encodedWordArithmetic_of_opcode facts hOpcode

private theorem authenticatedEncodedWordArithmetic_of_opcode
  (facts : WordShiftFacts)
  {opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair
      (WordShiftWordResult
        pkg.wordShiftWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.limbPairToWord
        opcode) := by
  let wordResult :=
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode
  have hCompat := wordShiftWordCompatibility_of_stepComposition pkg
  cases opcode with
  | addw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .addw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.add
                    pkg.wordShiftEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | addiw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.add
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .addiw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.add
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.add
                    pkg.wordShiftEncodedOps.add
                    hCompat.add
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | subw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.sub
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .subw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sub
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.sub
                    pkg.wordShiftEncodedOps.sub
                    hCompat.sub
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | sllw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.sll
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .sllw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sll
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.sll
                    pkg.wordShiftEncodedOps.sll
                    hCompat.sll
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | slliw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.sll
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .slliw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sll
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.sll
                    pkg.wordShiftEncodedOps.sll
                    hCompat.sll
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | srlw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.srl
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .srlw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.srl
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.srl
                    pkg.wordShiftEncodedOps.srl
                    hCompat.srl
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | srliw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.srl
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .srliw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.srl
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.srl
                    pkg.wordShiftEncodedOps.srl
                    hCompat.srl
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | sraw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.sra
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .sraw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sra
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.wordShiftWordOps.sra
                    pkg.wordShiftEncodedOps.sra
                    hCompat.sra
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]
  | sraiw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.wordShiftEncodedOps.sra
              pkg.twistBinding.registerTwist.rvRs1
              (pkg.wordToLimbPair pkg.decodedRow.imm) := by
                simpa [WordShiftEncodedResult] using
                  calc
                    pkg.twistBinding.registerTwist.wvReg = pkg.aluWritebackValue := by
                      exact authenticatedRoutedWriteback_of_activeWordShiftOpcodeSemantics facts hOpcode hRd
                    _ =
                        WordShiftEncodedResult
                          pkg.wordShiftEncodedOps
                          pkg.wordToLimbPair
                          pkg.decodedRow
                          pkg.twistBinding.registerTwist
                          .sraiw := by
                            simpa [hOpcode] using wordShiftEncodedResultBound_of_stepComposition pkg
        _ =
            pkg.wordToLimbPair
              (pkg.wordShiftWordOps.sra
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                pkg.decodedRow.imm) := by
                  exact encodedBinaryImm
                    pkg.wordShiftWordOps.sra
                    pkg.wordShiftEncodedOps.sra
                    hCompat.sra
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, WordShiftWordResult]

private theorem authenticatedWordArithmetic_of_opcode
  (facts : WordShiftFacts)
  {opcode : WordShiftOpcode}
  (hOpcode : pkg.wordShiftOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode := by
  have hEncoded :=
    authenticatedEncodedWordArithmetic_of_opcode facts hOpcode hRd
  have hRound :=
    wordEncodingRoundTripWord_of_stepComposition
      pkg
      (WordShiftWordResult
        pkg.wordShiftWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.limbPairToWord
        opcode)
  exact
    (congrArg pkg.limbPairToWord hEncoded).trans hRound

theorem addw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .addw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .addw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem addw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .addw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .addw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem addiw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .addiw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .addiw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem addiw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .addiw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .addiw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem subw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .subw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .subw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem subw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .subw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .subw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem sllw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .sllw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .sllw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem sllw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .sllw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .sllw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem slliw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .slliw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .slliw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem slliw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .slliw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .slliw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem srlw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .srlw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .srlw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem srlw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .srlw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .srlw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem srliw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .srliw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .srliw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem srliw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .srliw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .srliw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem sraw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .sraw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .sraw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem sraw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .sraw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .sraw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem sraiw_wordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .sraiw) :
  pkg.executionRow.results.aluResult =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .sraiw := by
  simpa [WordShiftWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem sraiw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
  (facts : WordShiftFacts)
  (hOpcode : pkg.wordShiftOpcode = .sraiw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    WordShiftWordResult
      pkg.wordShiftWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      .sraiw := by
  simpa [WordShiftWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

end

end Nightstream.Rv64IM
