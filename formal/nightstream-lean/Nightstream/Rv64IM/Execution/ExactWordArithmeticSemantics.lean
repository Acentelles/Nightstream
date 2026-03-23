import Nightstream.Rv64IM.Execution.ExactOpcodeFamilySemantics
import Nightstream.Rv64IM.Execution.MultiplyWordArithmetic
import Nightstream.Rv64IM.Execution.NativeAluWordArithmetic
import Nightstream.Rv64IM.Execution.WordShiftWordArithmetic

/-!
Owns the exact word-level arithmetic bundle above exact opcode-family
semantics. This file packages the theorem-facing native-ALU, word/shift, and
multiply word-arithmetic consequences into one canonical execution-level
bundle, without re-owning the underlying encoded-arithmetic or opcode-family
proofs.
-/

namespace Nightstream.Rv64IM

structure ExactWordArithmeticSemantics
  (BytecodeAddr Pc RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind
    RamAddr Word StateLocation RegisterTimeline RamTimeline Limb
    ArchitecturalInputs AuthenticatedReads WitnessAssignment Output StateEffect
    PreparedStep : Type _) [OfNat Limb 0]
  (pkg :
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
      PreparedStep)
  (_families :
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
      pkg) where
  nativeAluWord :
    ∀ {opcode : NativeAluOpcode},
      pkg.nativeAluOpcode = opcode →
      pkg.executionRow.results.aluResult =
        NativeAluWordResult
          pkg.nativeAluWordOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.executionRow.lane
          pkg.limbPairToWord
          opcode
  nativeAluAuthenticatedWord :
    ∀ {opcode : NativeAluOpcode},
      pkg.nativeAluOpcode = opcode →
      opcode.writesArchitecturalRd = true →
      pkg.decodedRow.rd ≠ pkg.x0 →
      pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
        NativeAluWordResult
          pkg.nativeAluWordOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.executionRow.lane
          pkg.limbPairToWord
          opcode
  wordShiftWord :
    ∀ {opcode : WordShiftOpcode},
      pkg.wordShiftOpcode = opcode →
      pkg.executionRow.results.aluResult =
        WordShiftWordResult
          pkg.wordShiftWordOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.limbPairToWord
          opcode
  wordShiftAuthenticatedWord :
    ∀ {opcode : WordShiftOpcode},
      pkg.wordShiftOpcode = opcode →
      pkg.decodedRow.rd ≠ pkg.x0 →
      pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
        WordShiftWordResult
          pkg.wordShiftWordOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.limbPairToWord
          opcode
  multiplyWord :
    ∀ {opcode : MultiplyOpcode},
      pkg.multiplyOpcode = opcode →
      pkg.executionRow.results.aluResult =
        MultiplyWordResult
          pkg.multiplyWordOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.limbPairToWord
          opcode
  multiplyAuthenticatedWord :
    ∀ {opcode : MultiplyOpcode},
      pkg.multiplyOpcode = opcode →
      pkg.decodedRow.rd ≠ pkg.x0 →
      pkg.limbPairToWord pkg.twistBinding.registerTwist.wvReg =
        MultiplyWordResult
          pkg.multiplyWordOps
          pkg.decodedRow
          pkg.twistBinding.registerTwist
          pkg.limbPairToWord
          opcode

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

noncomputable def exactWordArithmeticSemantics_of_exactOpcodeFamilySemantics
  (families :
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
      pkg) :
  ExactWordArithmeticSemantics
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
    families :=
  { nativeAluWord := by
      intro opcode hOpcode
      cases opcode with
      | add =>
          simpa using add_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | addi =>
          simpa using addi_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | sub =>
          simpa using sub_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | andOp =>
          simpa using and_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | andi =>
          simpa using andi_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | orOp =>
          simpa using or_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | ori =>
          simpa using ori_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | xorOp =>
          simpa using xor_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | xori =>
          simpa using xori_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | slt =>
          simpa using slt_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | slti =>
          simpa using slti_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | sltu =>
          simpa using sltu_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | sltiu =>
          simpa using sltiu_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | lui =>
          simpa using lui_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | auipc =>
          simpa using auipc_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | fence =>
          simpa using fence_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
      | ecall =>
          simpa using ecall_wordArithmetic_of_nativeAluWordArithmetic families hOpcode
    nativeAluAuthenticatedWord := by
      intro opcode hOpcode hWrites hRd
      cases opcode with
      | add =>
          simpa using
            add_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | addi =>
          simpa using
            addi_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | sub =>
          simpa using
            sub_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | andOp =>
          simpa using
            and_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | andi =>
          simpa using
            andi_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | orOp =>
          simpa using
            or_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | ori =>
          simpa using
            ori_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | xorOp =>
          simpa using
            xor_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | xori =>
          simpa using
            xori_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | slt =>
          simpa using
            slt_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | slti =>
          simpa using
            slti_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | sltu =>
          simpa using
            sltu_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | sltiu =>
          simpa using
            sltiu_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | lui =>
          simpa using
            lui_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | auipc =>
          simpa using
            auipc_authenticatedWordArithmetic_of_nativeAluWordArithmetic
              families hOpcode hRd
      | fence =>
          exfalso
          simp [NativeAluOpcode.writesArchitecturalRd] at hWrites
      | ecall =>
          exfalso
          simp [NativeAluOpcode.writesArchitecturalRd] at hWrites
    wordShiftWord := by
      intro opcode hOpcode
      cases opcode with
      | addw =>
          simpa using addw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | addiw =>
          simpa using addiw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | subw =>
          simpa using subw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | sllw =>
          simpa using sllw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | slliw =>
          simpa using slliw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | srlw =>
          simpa using srlw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | srliw =>
          simpa using srliw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | sraw =>
          simpa using sraw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
      | sraiw =>
          simpa using sraiw_wordArithmetic_of_wordShiftWordArithmetic families hOpcode
    wordShiftAuthenticatedWord := by
      intro opcode hOpcode hRd
      cases opcode with
      | addw =>
          simpa using
            addw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | addiw =>
          simpa using
            addiw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | subw =>
          simpa using
            subw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | sllw =>
          simpa using
            sllw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | slliw =>
          simpa using
            slliw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | srlw =>
          simpa using
            srlw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | srliw =>
          simpa using
            srliw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | sraw =>
          simpa using
            sraw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
      | sraiw =>
          simpa using
            sraiw_authenticatedWordArithmetic_of_wordShiftWordArithmetic
              families hOpcode hRd
    multiplyWord := by
      intro opcode hOpcode
      cases opcode with
      | mul =>
          simpa using mul_wordArithmetic_of_multiplyWordArithmetic families hOpcode
      | mulh =>
          simpa using mulh_wordArithmetic_of_multiplyWordArithmetic families hOpcode
      | mulhu =>
          simpa using mulhu_wordArithmetic_of_multiplyWordArithmetic families hOpcode
      | mulhsu =>
          simpa using mulhsu_wordArithmetic_of_multiplyWordArithmetic families hOpcode
      | mulw =>
          simpa using mulw_wordArithmetic_of_multiplyWordArithmetic families hOpcode
    multiplyAuthenticatedWord := by
      intro opcode hOpcode hRd
      cases opcode with
      | mul =>
          simpa using
            mul_authenticatedWordArithmetic_of_multiplyWordArithmetic
              families hOpcode hRd
      | mulh =>
          simpa using
            mulh_authenticatedWordArithmetic_of_multiplyWordArithmetic
              families hOpcode hRd
      | mulhu =>
          simpa using
            mulhu_authenticatedWordArithmetic_of_multiplyWordArithmetic
              families hOpcode hRd
      | mulhsu =>
          simpa using
            mulhsu_authenticatedWordArithmetic_of_multiplyWordArithmetic
              families hOpcode hRd
      | mulw =>
          simpa using
            mulw_authenticatedWordArithmetic_of_multiplyWordArithmetic
              families hOpcode hRd }

noncomputable def exactWordArithmeticSemantics_of_stepComposition
  (pkg :
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
      PreparedStep) :
  ExactWordArithmeticSemantics
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
    (exactOpcodeFamilySemantics_of_stepComposition pkg) :=
  exactWordArithmeticSemantics_of_exactOpcodeFamilySemantics
    (exactOpcodeFamilySemantics_of_stepComposition pkg)

end

end Nightstream.Rv64IM
