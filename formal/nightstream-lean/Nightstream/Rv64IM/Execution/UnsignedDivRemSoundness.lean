import Nightstream.Rv64IM.Execution.CommittedSequenceSoundness
import Nightstream.Rv64IM.Execution.ExecutionSemantics
import Nightstream.Rv64IM.Stage1.FetchDecodeBinding

namespace Nightstream.Rv64IM

def maxUnsigned64 : Nat := 2 ^ 64 - 1

def MulUNoOverflow (quotient divisor : Nat) : Prop :=
  quotient * divisor < 2 ^ 64

def UnsignedDivRemSpec (dividend quotient divisor remainder : Nat) : Prop :=
  if divisor = 0 then
    quotient = maxUnsigned64 ∧ remainder = dividend
  else
    MulUNoOverflow quotient divisor ∧
      dividend = quotient * divisor + remainder ∧
      remainder < divisor

inductive UnsignedDivRemOpcode where
  | divu
  | remu
  | divuw
  | remuw
deriving DecidableEq, Repr

def UnsignedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : UnsignedDivRemOpcode) : Prop :=
  match opcode with
  | .divu => row.isDiv = true ∧ row.isRem = false ∧ row.isWOp = false
  | .remu => row.isDiv = false ∧ row.isRem = true ∧ row.isWOp = false
  | .divuw => row.isDiv = true ∧ row.isRem = false ∧ row.isWOp = true
  | .remuw => row.isDiv = false ∧ row.isRem = true ∧ row.isWOp = true

structure UnsignedDivRemSoundnessProofPackage
  (Pc BytecodeAddr RegIdx StateLocation : Type _) where
  opcode : UnsignedDivRemOpcode
  sequence : CommittedSequence (ExpandedRow Pc BytecodeAddr RegIdx StateLocation)
  touchedState : TouchedStateSet StateLocation
  dividend : Nat
  divisor : Nat
  quotient : Nat
  remainder : Nat
  noOverflow : MulUNoOverflow quotient divisor
  specHolds : UnsignedDivRemSpec dividend quotient divisor remainder
  deterministic :
    ∀ quotient' remainder',
      UnsignedDivRemSpec dividend quotient' divisor remainder' →
        quotient' = quotient ∧ remainder' = remainder

theorem mulUNoOverflow_of_unsignedDivRemSoundness
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  (pkg : UnsignedDivRemSoundnessProofPackage Pc BytecodeAddr RegIdx StateLocation) :
  MulUNoOverflow pkg.quotient pkg.divisor :=
  pkg.noOverflow

theorem unsignedDivRemDeterministic_of_soundness
  {Pc BytecodeAddr RegIdx StateLocation : Type _}
  (pkg : UnsignedDivRemSoundnessProofPackage Pc BytecodeAddr RegIdx StateLocation)
  {quotient' remainder' : Nat}
  (hSpec : UnsignedDivRemSpec pkg.dividend quotient' pkg.divisor remainder') :
  quotient' = pkg.quotient ∧ remainder' = pkg.remainder :=
  pkg.deterministic quotient' remainder' hSpec

theorem isDiv_of_unsignedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : UnsignedDivRemOpcode}
  (h : UnsignedDivRemOpcodeBound row opcode) :
  row.isDiv =
    match opcode with
    | .divu => true
    | .remu => false
    | .divuw => true
    | .remuw => false := by
  cases opcode <;> simpa [UnsignedDivRemOpcodeBound] using h.1

theorem isRem_of_unsignedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : UnsignedDivRemOpcode}
  (h : UnsignedDivRemOpcodeBound row opcode) :
  row.isRem =
    match opcode with
    | .divu => false
    | .remu => true
    | .divuw => false
    | .remuw => true := by
  cases opcode <;> simpa [UnsignedDivRemOpcodeBound] using h.2.1

theorem isWOp_of_unsignedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : UnsignedDivRemOpcode}
  (h : UnsignedDivRemOpcodeBound row opcode) :
  row.isWOp =
    match opcode with
    | .divu => false
    | .remu => false
    | .divuw => true
    | .remuw => true := by
  cases opcode <;> simpa [UnsignedDivRemOpcodeBound] using h.2.2

end Nightstream.Rv64IM
