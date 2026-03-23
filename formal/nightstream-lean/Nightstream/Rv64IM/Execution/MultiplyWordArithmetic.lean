import Nightstream.Rv64IM.Execution.MultiplyEncodedArithmetic

/-!
Owns exact opcode-specialized word-level arithmetic consequences for the RV64IM
multiply family. This file uses the explicit word/limb representation bridge
from `StepComposition` to turn encoded multiply equalities into exact Stage-1
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

local notation "MultiplyFacts" =>
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

private theorem encodedWordArithmetic_of_opcode
  (facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode) :
  pkg.wordToLimbPair pkg.executionRow.results.aluResult =
    pkg.wordToLimbPair
      (MultiplyWordResult
        pkg.multiplyWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.limbPairToWord
        opcode) := by
  let wordResult :=
    MultiplyWordResult
      pkg.multiplyWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode
  have hCompat := multiplyWordCompatibility_of_stepComposition pkg
  cases opcode with
  | mul =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.multiplyEncodedOps.mul
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mul_encodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mul
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mul
                    pkg.multiplyEncodedOps.mul
                    hCompat.mul
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulh =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.multiplyEncodedOps.mulh
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulh_encodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulh
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulh
                    pkg.multiplyEncodedOps.mulh
                    hCompat.mulh
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulhu =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.multiplyEncodedOps.mulhu
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulhu_encodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulhu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulhu
                    pkg.multiplyEncodedOps.mulhu
                    hCompat.mulhu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulhsu =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.multiplyEncodedOps.mulhsu
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulhsu_encodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulhsu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulhsu
                    pkg.multiplyEncodedOps.mulhsu
                    hCompat.mulhsu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulw =>
      calc
        pkg.wordToLimbPair pkg.executionRow.results.aluResult
          =
            pkg.multiplyEncodedOps.mulw
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulw_encodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulw
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulw
                    pkg.multiplyEncodedOps.mulw
                    hCompat.mulw
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]

private theorem wordArithmetic_of_opcode
  (facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode) :
  pkg.executionRow.results.aluResult =
    MultiplyWordResult
      pkg.multiplyWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode := by
  apply wordToLimbPair_injective_of_stepComposition pkg
  exact encodedWordArithmetic_of_opcode facts hOpcode

private theorem authenticatedEncodedWordArithmetic_of_opcode
  (facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.twistBinding.registerTwist.wvReg =
    pkg.wordToLimbPair
      (MultiplyWordResult
        pkg.multiplyWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.limbPairToWord
        opcode) := by
  let wordResult :=
    MultiplyWordResult
      pkg.multiplyWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode
  have hCompat := multiplyWordCompatibility_of_stepComposition pkg
  cases opcode with
  | mul =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.multiplyEncodedOps.mul
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mul_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mul
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mul
                    pkg.multiplyEncodedOps.mul
                    hCompat.mul
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulh =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.multiplyEncodedOps.mulh
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulh_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulh
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulh
                    pkg.multiplyEncodedOps.mulh
                    hCompat.mulh
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulhu =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.multiplyEncodedOps.mulhu
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulhu_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulhu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulhu
                    pkg.multiplyEncodedOps.mulhu
                    hCompat.mulhu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulhsu =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.multiplyEncodedOps.mulhsu
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulhsu_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulhsu
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulhsu
                    pkg.multiplyEncodedOps.mulhsu
                    hCompat.mulhsu
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]
  | mulw =>
      calc
        pkg.twistBinding.registerTwist.wvReg
          =
            pkg.multiplyEncodedOps.mulw
              pkg.twistBinding.registerTwist.rvRs1
              pkg.twistBinding.registerTwist.rvRs2 := by
                simpa using
                  mulw_authenticatedEncodedArithmetic_of_multiplyEncodedArithmetic facts hOpcode hRd
        _ =
            pkg.wordToLimbPair
              (pkg.multiplyWordOps.mulw
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
                (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2)) := by
                  exact encodedBinary
                    pkg.multiplyWordOps.mulw
                    pkg.multiplyEncodedOps.mulw
                    hCompat.mulw
                    _
                    _
        _ = pkg.wordToLimbPair wordResult := by
          simp [wordResult, MultiplyWordResult]

private theorem authenticatedWordArithmetic_of_opcode
  (facts : MultiplyFacts)
  {opcode : MultiplyOpcode}
  (hOpcode : pkg.multiplyOpcode = opcode)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    MultiplyWordResult
      pkg.multiplyWordOps
      pkg.decodedRow
      pkg.twistBinding.registerTwist
      pkg.limbPairToWord
      opcode := by
  have hEncoded := authenticatedEncodedWordArithmetic_of_opcode facts hOpcode hRd
  have hRound :=
    wordEncodingRoundTripWord_of_stepComposition
      pkg
      (MultiplyWordResult
        pkg.multiplyWordOps
        pkg.decodedRow
        pkg.twistBinding.registerTwist
        pkg.limbPairToWord
        opcode)
  simpa [hRound] using congrArg pkg.limbPairToWord hEncoded

theorem mul_wordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mul) :
  pkg.executionRow.results.aluResult =
    pkg.multiplyWordOps.mul
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem mul_authenticatedWordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mul)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyWordOps.mul
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem mulh_wordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulh) :
  pkg.executionRow.results.aluResult =
    pkg.multiplyWordOps.mulh
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem mulh_authenticatedWordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulh)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyWordOps.mulh
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem mulhu_wordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhu) :
  pkg.executionRow.results.aluResult =
    pkg.multiplyWordOps.mulhu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem mulhu_authenticatedWordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyWordOps.mulhu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem mulhsu_wordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhsu) :
  pkg.executionRow.results.aluResult =
    pkg.multiplyWordOps.mulhsu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem mulhsu_authenticatedWordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulhsu)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyWordOps.mulhsu
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

theorem mulw_wordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulw) :
  pkg.executionRow.results.aluResult =
    pkg.multiplyWordOps.mulw
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using wordArithmetic_of_opcode facts hOpcode

theorem mulw_authenticatedWordArithmetic_of_multiplyWordArithmetic
  (facts : MultiplyFacts)
  (hOpcode : pkg.multiplyOpcode = .mulw)
  (hRd : pkg.decodedRow.rd ≠ pkg.x0) :
  pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
    pkg.multiplyWordOps.mulw
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs1)
      (pkg.limbPairToWord pkg.twistBinding.registerTwist.rvRs2) := by
  simpa [MultiplyWordResult] using authenticatedWordArithmetic_of_opcode facts hOpcode hRd

end

end Nightstream.Rv64IM
