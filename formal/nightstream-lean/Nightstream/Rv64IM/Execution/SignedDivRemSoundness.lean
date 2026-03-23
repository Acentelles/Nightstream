import Nightstream.Rv64IM.Stage1.FetchDecodeBinding

namespace Nightstream.Rv64IM

def intMin64 : Int := -((2 : Int) ^ (63 : Nat))

def ChangeDivisorCorrect (dividend divisor changedDivisor : Int) : Prop :=
  changedDivisor =
    if dividend = intMin64 ∧ divisor = (-1 : Int) then
      (1 : Int)
    else
      divisor

def RemainderFromDividendSign (dividend remainderAbs remainderSigned : Int) : Prop :=
  remainderSigned = if dividend < 0 then -remainderAbs else remainderAbs

def SignedDivRemSpec (dividend quotient divisor remainder : Int) : Prop :=
  if divisor = 0 then
    quotient = (-1 : Int) ∧ remainder = dividend
  else
    dividend = quotient * divisor + remainder ∧
      Int.natAbs remainder < Int.natAbs divisor ∧
      (remainder = 0 ∨ ((remainder < 0) ↔ (dividend < 0)))

inductive SignedDivRemOpcode where
  | div
  | rem
  | divw
  | remw
deriving DecidableEq, Repr

def SignedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  (row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind)
  (opcode : SignedDivRemOpcode) : Prop :=
  match opcode with
  | .div => row.isDiv = true ∧ row.isRem = false ∧ row.isWOp = false
  | .rem => row.isDiv = false ∧ row.isRem = true ∧ row.isWOp = false
  | .divw => row.isDiv = true ∧ row.isRem = false ∧ row.isWOp = true
  | .remw => row.isDiv = false ∧ row.isRem = true ∧ row.isWOp = true

structure SignedDivRemProofPackage where
  opcode : SignedDivRemOpcode
  dividend : Int
  divisor : Int
  changedDivisor : Int
  quotient : Int
  remainderAbs : Int
  remainderSigned : Int
  changeDivisorCorrect :
    ChangeDivisorCorrect dividend divisor changedDivisor
  remainderFromDividendSign :
    RemainderFromDividendSign dividend remainderAbs remainderSigned
  specHolds :
    SignedDivRemSpec dividend quotient divisor remainderSigned

theorem changeDivisorCorrect_of_signedDivRemSoundness
  (pkg : SignedDivRemProofPackage) :
  ChangeDivisorCorrect pkg.dividend pkg.divisor pkg.changedDivisor :=
  pkg.changeDivisorCorrect

theorem remainderFromDividendSign_of_signedDivRemSoundness
  (pkg : SignedDivRemProofPackage) :
  RemainderFromDividendSign pkg.dividend pkg.remainderAbs pkg.remainderSigned :=
  pkg.remainderFromDividendSign

theorem signedDivRemSpec_of_signedDivRemSoundness
  (pkg : SignedDivRemProofPackage) :
  SignedDivRemSpec pkg.dividend pkg.quotient pkg.divisor pkg.remainderSigned :=
  pkg.specHolds

theorem isDiv_of_signedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : SignedDivRemOpcode}
  (h : SignedDivRemOpcodeBound row opcode) :
  row.isDiv =
    match opcode with
    | .div => true
    | .rem => false
    | .divw => true
    | .remw => false := by
  cases opcode <;> simpa [SignedDivRemOpcodeBound] using h.1

theorem isRem_of_signedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : SignedDivRemOpcode}
  (h : SignedDivRemOpcodeBound row opcode) :
  row.isRem =
    match opcode with
    | .div => false
    | .rem => true
    | .divw => false
    | .remw => true := by
  cases opcode <;> simpa [SignedDivRemOpcodeBound] using h.2.1

theorem isWOp_of_signedDivRemOpcodeBound
  {Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind : Type _}
  {row : DecodedStage1Row Word RegIdx VirtualOpcode AluOp BranchOp MemWidth DivRemKind}
  {opcode : SignedDivRemOpcode}
  (h : SignedDivRemOpcodeBound row opcode) :
  row.isWOp =
    match opcode with
    | .div => false
    | .rem => false
    | .divw => true
    | .remw => true := by
  cases opcode <;> simpa [SignedDivRemOpcodeBound] using h.2.2

end Nightstream.Rv64IM
