import TwistShout.SpartanPP

/-!
# SpartanPPInterface

Thin theorem-facing boundary for the paper's Spartan++ application.
-/

namespace TwistShout

namespace SpartanPPInterface

abbrev Point := @TwistShout.Point
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev PublicTable := @TwistShout.PublicTable
abbrev bitVec := @TwistShout.bitVec
abbrev cubeOneHot := @TwistShout.cubeOneHot
abbrev cycleSpaceSize := @TwistShout.cycleSpaceSize
abbrev SupportCube := @TwistShout.SupportCube
abbrev SparkCommitment := @TwistShout.SparkCommitment
abbrev sparkMidpointPoint := @TwistShout.sparkMidpointPoint
abbrev RowCube := @TwistShout.RowCube
abbrev VariableCube := @TwistShout.VariableCube
abbrev SparseMatrixCommitment := @TwistShout.SparseMatrixCommitment
abbrev SpartanPPInstance := @TwistShout.SpartanPPInstance
abbrev sparkPPReadCheckFieldCost := @TwistShout.sparkPPReadCheckFieldCost
abbrev sparkPPEvaluationProofFieldCost := @TwistShout.sparkPPEvaluationProofFieldCost
abbrev sparkPPEvaluationFieldCost := @TwistShout.sparkPPEvaluationFieldCost
abbrev spartanPPOuterSumcheckFieldCost := @TwistShout.spartanPPOuterSumcheckFieldCost
abbrev spartanPPSparkFieldCost := @TwistShout.spartanPPSparkFieldCost
abbrev spartanPPFieldMultiplications := @TwistShout.spartanPPFieldMultiplications

theorem SparkCommitment.supportTable_eq_indicator
  {K : Type*} [Field K]
  {d m s : Nat}
  (commitment : SparkCommitment (K := K) d m s)
  (k : Address d m) :
  commitment.supportTable k = (if ∃ j, commitment.addr j = k then 1 else 0) :=
  TwistShout.SparkCommitment.supportTable_eq_indicator (K := K) commitment k

theorem SparkCommitment.lookupEval_eq_readCheckEval
  {K : Type*} [Field K]
  {d m s : Nat}
  (commitment : SparkCommitment (K := K) d m s)
  (rAddress : Fin d → Point (K := K) m)
  (rSupport : Point (K := K) s) :
  commitment.lookupEval rAddress rSupport =
    commitment.readCheckEval rAddress rSupport :=
  TwistShout.SparkCommitment.lookupEval_eq_readCheckEval (K := K) commitment rAddress rSupport

theorem SparkCommitment.sparkEval_eq_sum_lookupValues
  {K : Type*} [Field K]
  {d m s : Nat}
  (commitment : SparkCommitment (K := K) d m s)
  (rAddress : Fin d → Point (K := K) m) :
  commitment.sparkEval rAddress =
    ∑ j : SupportCube s, commitment.lookupValues rAddress j :=
  TwistShout.SparkCommitment.sparkEval_eq_sum_lookupValues (K := K) commitment rAddress

theorem SparkCommitment.sparkEval_eq_midpointReadCheckEval
  {K : Type*} [Field K] [NeZero (2 : K)]
  {d m s : Nat}
  (commitment : SparkCommitment (K := K) d m s)
  (rAddress : Fin d → Point (K := K) m) :
  commitment.sparkEval rAddress =
    ((cycleSpaceSize s : Nat) : K) *
      commitment.readCheckEval rAddress (sparkMidpointPoint (K := K) (s := s)) :=
  TwistShout.SparkCommitment.sparkEval_eq_midpointReadCheckEval (K := K) commitment rAddress

def SparkCommitment.eqTableOracle
  {K : Type*} [Field K]
  {d m s : Nat}
  (commitment : SparkCommitment (K := K) d m s)
  (rAddress : Fin d → Point (K := K) m) :
  StructuredTableOracle (K := K) (commitment.eqTable rAddress) :=
  TwistShout.SparkCommitment.eqTableOracle (K := K) commitment rAddress

theorem SparseMatrixCommitment.verifierTarget_eq_shoutReducedVerifierTarget
  {K : Type*} [Field K] [NeZero (2 : K)]
  {d m s rowBits varBits : Nat}
  (matrix : SparseMatrixCommitment (K := K) d m s rowBits varBits)
  (z : VariableCube varBits → K)
  (rowPoint : Point (K := K) rowBits)
  (varPoint : Point (K := K) varBits) :
  matrix.verifierTarget z rowPoint varPoint =
    matrix.shoutReducedVerifierTarget z rowPoint varPoint :=
  TwistShout.SparseMatrixCommitment.verifierTarget_eq_shoutReducedVerifierTarget
    (K := K) matrix z rowPoint varPoint

theorem SpartanPPInstance.zeroCheckClaim_eq_zero
  {K : Type*} [Field K]
  {d m s rowBits varBits : Nat}
  (inst : SpartanPPInstance (K := K) d m s rowBits varBits)
  (tau : Point (K := K) rowBits) :
  inst.zeroCheckClaim tau = 0 :=
  TwistShout.SpartanPPInstance.zeroCheckClaim_eq_zero (K := K) inst tau

theorem sparkPPReadCheckFieldCost_eq_paper
  (d supportBits : Nat) :
  sparkPPReadCheckFieldCost d supportBits =
    (d * d + 4) * cycleSpaceSize supportBits :=
  TwistShout.sparkPPReadCheckFieldCost_eq_paper d supportBits

theorem sparkPPEvaluationFieldCost_eq_paper
  (d supportBits : Nat) :
  sparkPPEvaluationFieldCost d supportBits =
    (d * d + 5) * cycleSpaceSize supportBits :=
  TwistShout.sparkPPEvaluationFieldCost_eq_paper d supportBits

theorem spartanPPFieldMultiplications_eq_paper
  (d constraintCount variableCount supportBits : Nat) :
  spartanPPFieldMultiplications d constraintCount variableCount supportBits =
    6 * constraintCount + 5 * variableCount +
      2 * (d * d + 5) * cycleSpaceSize supportBits :=
  TwistShout.spartanPPFieldMultiplications_eq_paper d constraintCount variableCount supportBits

theorem spartanPPFieldMultiplications_diag
  (d constraintCount supportBits : Nat) :
  spartanPPFieldMultiplications d constraintCount constraintCount supportBits =
    11 * constraintCount + (2 * d * d + 10) * cycleSpaceSize supportBits :=
  TwistShout.spartanPPFieldMultiplications_diag d constraintCount supportBits

theorem spartanPPFieldMultiplications_d4_diag
  (constraintCount supportBits : Nat) :
  spartanPPFieldMultiplications 4 constraintCount constraintCount supportBits =
    11 * constraintCount + 42 * cycleSpaceSize supportBits :=
  TwistShout.spartanPPFieldMultiplications_d4_diag constraintCount supportBits

end SpartanPPInterface

end TwistShout
