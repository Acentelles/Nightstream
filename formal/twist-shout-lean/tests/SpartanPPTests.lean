import TwistShout.SpartanPPInterface

open TwistShout.SpartanPPInterface

namespace tests.spartanpp

def zeroDigit : TwistShout.DigitCube 1 := fun _ => false

def oneDigit : TwistShout.DigitCube 1 := fun _ => true

def addr00 : Address 2 1 :=
  Fin.cases zeroDigit (fun _ => zeroDigit)

def addr01 : Address 2 1 :=
  Fin.cases oneDigit (fun _ => zeroDigit)

def addr10 : Address 2 1 :=
  Fin.cases zeroDigit (fun _ => oneDigit)

def support0 : SupportCube 1 := fun _ => false

def support1 : SupportCube 1 := fun _ => true

def supportAddr : SupportCube 1 → Address 2 1 :=
  fun j => if j 0 then addr10 else addr01

def supportCols : AddressColumns (K := Rat) 2 1 1 :=
  fun i k j => cubeOneHot (K := Rat) (supportAddr j i) k

theorem supportValid :
    TwistShout.ValidAddressColumns (K := Rat) supportCols supportAddr := by
  intro j i k
  rfl

theorem supportInj :
    Function.Injective supportAddr := by
  intro a b h
  have hneq01 : addr01 ≠ addr10 := by
    native_decide
  have h0 : a 0 = b 0 := by
    cases ha : a 0 <;> cases hb : b 0
    · rfl
    · exfalso
      apply hneq01
      simpa [supportAddr, ha, hb] using h
    · exfalso
      apply hneq01
      simpa [supportAddr, ha, hb] using h.symm
    · rfl
  funext i
  fin_cases i
  exact h0

def supportCommitment : SparkCommitment (K := Rat) 2 1 1 where
  columns := supportCols
  addr := supportAddr
  valid := supportValid
  injective_addr := supportInj

example :
    supportCommitment.supportTable addr01 = 1 := by
  rw [supportCommitment.supportTable_eq_indicator]
  native_decide

example :
    supportCommitment.supportTable addr00 = 0 := by
  rw [supportCommitment.supportTable_eq_indicator]
  native_decide

example :
    supportCommitment.sparkEval (TwistShout.bitAddress (K := Rat) addr01) = 1 := by
  unfold TwistShout.SparkCommitment.sparkEval
  rw [TwistShout.tableMLE_at_bitAddress (K := Rat) (val := supportCommitment.supportTable) (a := addr01)]
  rw [supportCommitment.supportTable_eq_indicator]
  native_decide

example :
    supportCommitment.sparkEval (TwistShout.bitAddress (K := Rat) addr00) = 0 := by
  unfold TwistShout.SparkCommitment.sparkEval
  rw [TwistShout.tableMLE_at_bitAddress (K := Rat) (val := supportCommitment.supportTable) (a := addr00)]
  rw [supportCommitment.supportTable_eq_indicator]
  native_decide

example :
    supportCommitment.sparkEval (TwistShout.bitAddress (K := Rat) addr01) =
      ∑ j : SupportCube 1,
        supportCommitment.lookupValues (TwistShout.bitAddress (K := Rat) addr01) j := by
  exact supportCommitment.sparkEval_eq_sum_lookupValues (TwistShout.bitAddress (K := Rat) addr01)

example :
    supportCommitment.sparkEval (TwistShout.bitAddress (K := Rat) addr01) =
      ((cycleSpaceSize 1 : Nat) : Rat) *
        supportCommitment.readCheckEval (TwistShout.bitAddress (K := Rat) addr01)
          (sparkMidpointPoint (K := Rat) (s := 1)) := by
  exact supportCommitment.sparkEval_eq_midpointReadCheckEval
    (TwistShout.bitAddress (K := Rat) addr01)

def zTable : VariableCube 1 → Rat :=
  fun j => if j 0 then 2 else 1

def sampleQuery : Point (K := Rat) 1 → Point (K := Rat) 1 → Fin 2 → Point (K := Rat) 1 :=
  fun _row varPoint =>
    Fin.cases (fun _ => 1 - varPoint 0) (fun _ => fun _ => varPoint 0)

def sampleMatrix : SparseMatrixCommitment (K := Rat) 2 1 1 1 1 where
  spark := supportCommitment
  query := sampleQuery

def row0 : RowCube 1 := fun _ => false

def row1 : RowCube 1 := fun _ => true

def var0 : VariableCube 1 := fun _ => false

def var1 : VariableCube 1 := fun _ => true

theorem sparkEval_addr01 :
    supportCommitment.sparkEval (TwistShout.bitAddress (K := Rat) addr01) = 1 := by
  unfold TwistShout.SparkCommitment.sparkEval
  rw [TwistShout.tableMLE_at_bitAddress (K := Rat) (val := supportCommitment.supportTable) (a := addr01)]
  rw [supportCommitment.supportTable_eq_indicator]
  native_decide

theorem sparkEval_addr10 :
    supportCommitment.sparkEval (TwistShout.bitAddress (K := Rat) addr10) = 1 := by
  unfold TwistShout.SparkCommitment.sparkEval
  rw [TwistShout.tableMLE_at_bitAddress (K := Rat) (val := supportCommitment.supportTable) (a := addr10)]
  rw [supportCommitment.supportTable_eq_indicator]
  native_decide

example :
    sampleMatrix.verifierTarget zTable (bitVec (K := Rat) row0) (bitVec (K := Rat) var0) =
      sampleMatrix.shoutReducedVerifierTarget zTable (bitVec (K := Rat) row0) (bitVec (K := Rat) var0) := by
  exact sampleMatrix.verifierTarget_eq_shoutReducedVerifierTarget
    zTable (bitVec (K := Rat) row0) (bitVec (K := Rat) var0)

def sampleSpartan : SpartanPPInstance (K := Rat) 2 1 1 1 1 where
  z := zTable
  A := sampleMatrix
  B := sampleMatrix
  w := fun row =>
    sampleMatrix.rowEval zTable (bitVec (K := Rat) row) *
      sampleMatrix.rowEval zTable (bitVec (K := Rat) row)
  constraints_satisfied := by
    intro row
    rfl

example :
    sampleSpartan.zeroCheckClaim (bitVec (K := Rat) row0) = 0 := by
  exact sampleSpartan.zeroCheckClaim_eq_zero (bitVec (K := Rat) row0)

example :
    sparkPPReadCheckFieldCost 3 4 = (3 * 3 + 4) * cycleSpaceSize 4 := by
  exact sparkPPReadCheckFieldCost_eq_paper 3 4

example :
    sparkPPEvaluationFieldCost 4 3 = (4 * 4 + 5) * cycleSpaceSize 3 := by
  exact sparkPPEvaluationFieldCost_eq_paper 4 3

example :
    spartanPPFieldMultiplications 4 5 5 3 = 11 * 5 + 42 * cycleSpaceSize 3 := by
  exact spartanPPFieldMultiplications_d4_diag 5 3

#guard sparkPPReadCheckFieldCost 3 4 = 208
#guard sparkPPEvaluationFieldCost 4 3 = 168
#guard spartanPPFieldMultiplications 4 5 5 3 = 391

end tests.spartanpp
