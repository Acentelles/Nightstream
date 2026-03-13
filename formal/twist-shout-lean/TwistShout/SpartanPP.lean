import TwistShout.FastShoutStructuredMemory

/-!
# SpartanPP

Section 9.3 application identities for Spark++ and Spartan++.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Support index cube for a `T = 2^s`-sparse polynomial. -/
abbrev SupportCube (s : Nat) := CycleCube s

/-- Honest Spark++ commitment: valid one-hot addresses listing a sparse support set injectively. -/
structure SparkCommitment (d m s : Nat) where
  columns : AddressColumns (K := K) d m s
  addr : SupportCube s → Address d m
  valid : ValidAddressColumns (K := K) columns addr
  injective_addr : Function.Injective addr

/-- The Boolean support indicator reconstructed from the committed support addresses. -/
def SparkCommitment.supportTable
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s) :
    PublicTable (K := K) d m :=
  fun k => ∑ j : SupportCube s, tupleCubeOneHot (K := K) (commitment.addr j) k

/-- The lookup table `k ↦ eq~(r, k)` used in Spark++ evaluation. -/
def SparkCommitment.eqTable
    {d m s : Nat}
    (_commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m) :
    PublicTable (K := K) d m :=
  fun k => addressWeight (K := K) rAddress k

/-- The cycle-indexed lookup values returned by applying Shout to the Eq-table. -/
def SparkCommitment.lookupValues
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m) :
    SupportCube s → K :=
  readOracleTable (K := K) (commitment.eqTable rAddress) commitment.addr

/-- The multilinear extension of the returned lookup values. -/
def SparkCommitment.lookupEval
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m)
    (rSupport : Point (K := K) s) : K :=
  mle (K := K) (commitment.lookupValues rAddress) rSupport

/-- The Shout read-check expression for the Eq-table lookups. -/
def SparkCommitment.readCheckEval
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m)
    (rSupport : Point (K := K) s) : K :=
  readCheckExpression (K := K) commitment.columns (commitment.eqTable rAddress) rSupport

/-- The sparse polynomial evaluation `p(r)` induced by the support indicator. -/
def SparkCommitment.sparkEval
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m) : K :=
  tableMLE (K := K) commitment.supportTable rAddress

open Classical in
theorem SparkCommitment.supportTable_eq_indicator
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (k : Address d m) :
    commitment.supportTable k = (if ∃ j, commitment.addr j = k then 1 else 0) := by
  by_cases hk : ∃ j, commitment.addr j = k
  · rcases hk with ⟨j, hj⟩
    have hk' : ∃ j, commitment.addr j = k := ⟨j, hj⟩
    unfold SparkCommitment.supportTable
    rw [Finset.sum_eq_single j]
    · simp [hj, hk']
    · intro j' _ hj'
      have hneq : commitment.addr j' ≠ k := by
        intro hEq
        apply hj'
        exact commitment.injective_addr (hEq.trans hj.symm)
      rw [tupleCubeOneHot_eq_zero_of_ne (K := K)
        (hzk := fun hEq => hneq hEq.symm)]
    · simp [hj]
  · unfold SparkCommitment.supportTable
    simp [hk]
    apply Finset.sum_eq_zero
    intro j _
    have hneq : commitment.addr j ≠ k := by
      intro hEq
      exact hk ⟨j, hEq⟩
    rw [tupleCubeOneHot_eq_zero_of_ne (K := K)
      (hzk := fun hEq => hneq hEq.symm)]

theorem SparkCommitment.lookupEval_eq_readCheckEval
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m)
    (rSupport : Point (K := K) s) :
    commitment.lookupEval rAddress rSupport =
      commitment.readCheckEval rAddress rSupport :=
  commitment.valid.readCheckExpression (commitment.eqTable rAddress) rSupport

theorem SparkCommitment.sparkEval_eq_sum_lookupValues
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m) :
    commitment.sparkEval rAddress =
      ∑ j : SupportCube s, commitment.lookupValues rAddress j := by
  unfold SparkCommitment.sparkEval SparkCommitment.supportTable
  calc
    ∑ k : Address d m,
        (∑ j : SupportCube s, tupleCubeOneHot (K := K) (commitment.addr j) k) *
          addressWeight (K := K) rAddress k
      = ∑ k : Address d m, ∑ j : SupportCube s,
          addressWeight (K := K) rAddress k *
            tupleCubeOneHot (K := K) (commitment.addr j) k := by
              apply Finset.sum_congr rfl
              intro k _
              rw [Finset.sum_mul]
              apply Finset.sum_congr rfl
              intro j _
              ring
    _ = ∑ j : SupportCube s, ∑ k : Address d m,
          addressWeight (K := K) rAddress k *
            tupleCubeOneHot (K := K) (commitment.addr j) k := by
              rw [Finset.sum_comm]
    _ = ∑ j : SupportCube s, addressWeight (K := K) rAddress (commitment.addr j) := by
              apply Finset.sum_congr rfl
              intro j _
              rw [weightedSum_tupleCubeOneHot (K := K)
                (w := addressWeight (K := K) rAddress) (z := commitment.addr j)]
    _ = ∑ j : SupportCube s, commitment.lookupValues rAddress j := by
              apply Finset.sum_congr rfl
              intro j _
              rfl

/-- The special support point `(1/2, ..., 1/2)` used by the midpoint Spark++ evaluation route. -/
def sparkMidpointPoint {s : Nat} : Point (K := K) s :=
  fun _ => (2 : K)⁻¹

theorem inv_two_eq_one_sub_inv_two
    [NeZero (2 : K)] :
    (2 : K)⁻¹ = 1 - (2 : K)⁻¹ := by
  have h2 : (2 : K) ≠ 0 := NeZero.ne (2 : K)
  have hRight : (2 : K) * (1 - (2 : K)⁻¹) = 1 := by
    ring_nf
    simp [h2]
    ring
  apply (mul_left_cancel₀ h2)
  calc
    (2 : K) * ((2 : K)⁻¹) = 1 := by simp [h2]
    _ = (2 : K) * (1 - (2 : K)⁻¹) := by simpa using hRight.symm

theorem chiWeight_sparkMidpointPoint
    [NeZero (2 : K)]
    {s : Nat}
    (j : SupportCube s) :
    chiWeight (K := K) (sparkMidpointPoint (K := K) (s := s)) j = ((2 : K)⁻¹) ^ s := by
  have hHalf : 1 - (2 : K)⁻¹ = (2 : K)⁻¹ := by
    symm
    exact inv_two_eq_one_sub_inv_two (K := K)
  unfold chiWeight sparkMidpointPoint eqPoly bitVec
  have hTerm :
      ∀ i : Fin s,
        eqTerm ((2 : K)⁻¹) (bitToField (K := K) (j i)) = (2 : K)⁻¹ := by
          intro i
          cases h' : j i <;> simp [eqTerm, bitToField, hHalf]
  calc
    ∏ i, eqTerm ((2 : K)⁻¹) (bitToField (K := K) (j i))
      = ∏ _i : Fin s, (2 : K)⁻¹ := by
          apply Finset.prod_congr rfl
          intro i _
          exact hTerm i
    _ = ((2 : K)⁻¹) ^ s := by simp

theorem sparkMidpoint_scale
    [NeZero (2 : K)]
    (s : Nat) :
    ((cycleSpaceSize s : Nat) : K) * ((2 : K)⁻¹) ^ s = 1 := by
  have h2 : (2 : K) ≠ 0 := NeZero.ne (2 : K)
  calc
    ((cycleSpaceSize s : Nat) : K) * ((2 : K)⁻¹) ^ s
      = (2 : K) ^ s * ((2 : K)⁻¹) ^ s := by simp [cycleSpaceSize]
    _ = ((2 : K) * (2 : K)⁻¹) ^ s := by rw [← mul_pow]
    _ = 1 := by simp [h2]

theorem SparkCommitment.sparkEval_eq_midpointLookupEval
    {d m s : Nat}
    [NeZero (2 : K)]
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m) :
    commitment.sparkEval rAddress =
      ((cycleSpaceSize s : Nat) : K) *
        commitment.lookupEval rAddress (sparkMidpointPoint (K := K) (s := s)) := by
  calc
    commitment.sparkEval rAddress
      = ∑ j : SupportCube s, commitment.lookupValues rAddress j :=
          commitment.sparkEval_eq_sum_lookupValues rAddress
    _ = ((cycleSpaceSize s : Nat) : K) *
          commitment.lookupEval rAddress (sparkMidpointPoint (K := K) (s := s)) := by
          unfold SparkCommitment.lookupEval mle
          calc
            ∑ j : SupportCube s, commitment.lookupValues rAddress j
              = ∑ j : SupportCube s,
                  commitment.lookupValues rAddress j *
                    (((cycleSpaceSize s : Nat) : K) * ((2 : K)⁻¹) ^ s) := by
                      apply Finset.sum_congr rfl
                      intro j _
                      rw [sparkMidpoint_scale (K := K) s]
                      ring
            _ = ∑ j : SupportCube s,
                  ((cycleSpaceSize s : Nat) : K) *
                    (commitment.lookupValues rAddress j * ((2 : K)⁻¹) ^ s) := by
                      apply Finset.sum_congr rfl
                      intro j _
                      ring
            _ = ((cycleSpaceSize s : Nat) : K) *
                  ∑ j : SupportCube s,
                    commitment.lookupValues rAddress j * ((2 : K)⁻¹) ^ s := by
                      rw [Finset.mul_sum]
            _ = ((cycleSpaceSize s : Nat) : K) *
                  ∑ j : SupportCube s,
                    commitment.lookupValues rAddress j *
                      chiWeight (K := K) (sparkMidpointPoint (K := K) (s := s)) j := by
                      apply congrArg (((cycleSpaceSize s : Nat) : K) * ·)
                      apply Finset.sum_congr rfl
                      intro j _
                      rw [chiWeight_sparkMidpointPoint (K := K) (j := j)]

theorem SparkCommitment.sparkEval_eq_midpointReadCheckEval
    {d m s : Nat}
    [NeZero (2 : K)]
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m) :
    commitment.sparkEval rAddress =
      ((cycleSpaceSize s : Nat) : K) *
        commitment.readCheckEval rAddress (sparkMidpointPoint (K := K) (s := s)) := by
  rw [commitment.sparkEval_eq_midpointLookupEval rAddress]
  rw [commitment.lookupEval_eq_readCheckEval]

/-- Explicit structured oracle for the Spark++ Eq-table. -/
def SparkCommitment.eqTableOracle
    {d m s : Nat}
    (commitment : SparkCommitment (K := K) d m s)
    (rAddress : Fin d → Point (K := K) m) :
    StructuredTableOracle (K := K) (commitment.eqTable rAddress) where
  eval := fun boundAddress => ∏ i, eqPoly (boundAddress i) (rAddress i)
  eval_eq_tableMLE := by
    intro boundAddress
    symm
    simpa [SparkCommitment.eqTable] using
      (tableMLE_addressWeight (K := K) rAddress boundAddress)

/-- Boolean-cube row domain for Spartan++ constraints. -/
abbrev RowCube (rowBits : Nat) := Cube rowBits

/-- Boolean-cube variable domain for virtual matrix evaluations. -/
abbrev VariableCube (varBits : Nat) := Cube varBits

/-- Sparse matrix commitment specialized to the Spark++ support/evaluation interface. -/
structure SparseMatrixCommitment (d m s rowBits varBits : Nat) where
  spark : SparkCommitment (K := K) d m s
  query : Point (K := K) rowBits → Point (K := K) varBits → Fin d → Point (K := K) m

/-- The Boolean-column table appearing in the virtual matrix evaluation `Σ_j A~(r',j)·z(j)`. -/
def SparseMatrixCommitment.rowTable
    {d m s rowBits varBits : Nat}
    (matrix : SparseMatrixCommitment (K := K) d m s rowBits varBits)
    (z : VariableCube varBits → K)
    (rowPoint : Point (K := K) rowBits) :
    VariableCube varBits → K :=
  fun j => matrix.spark.sparkEval (matrix.query rowPoint (bitVec (K := K) j)) * z j

/-- The virtual polynomial value `\tilde a(r')` or `\tilde b(r')`. -/
def SparseMatrixCommitment.rowEval
    {d m s rowBits varBits : Nat}
    (matrix : SparseMatrixCommitment (K := K) d m s rowBits varBits)
    (z : VariableCube varBits → K)
    (rowPoint : Point (K := K) rowBits) : K :=
  ∑ j : VariableCube varBits, matrix.rowTable z rowPoint j

/-- Honest last-round target for the inner sum-check computing a virtual matrix evaluation. -/
def SparseMatrixCommitment.verifierTarget
    {d m s rowBits varBits : Nat}
    (matrix : SparseMatrixCommitment (K := K) d m s rowBits varBits)
    (z : VariableCube varBits → K)
    (rowPoint : Point (K := K) rowBits)
    (varPoint : Point (K := K) varBits) : K :=
  matrix.spark.sparkEval (matrix.query rowPoint varPoint) * mle (K := K) z varPoint

/-- The same target with the Spark++ evaluation reduced to the midpoint Shout read-check. -/
def SparseMatrixCommitment.shoutReducedVerifierTarget
    {d m s rowBits varBits : Nat}
    [NeZero (2 : K)]
    (matrix : SparseMatrixCommitment (K := K) d m s rowBits varBits)
    (z : VariableCube varBits → K)
    (rowPoint : Point (K := K) rowBits)
    (varPoint : Point (K := K) varBits) : K :=
  ((cycleSpaceSize s : Nat) : K) *
    matrix.spark.readCheckEval (matrix.query rowPoint varPoint)
      (sparkMidpointPoint (K := K) (s := s)) *
    mle (K := K) z varPoint

theorem SparseMatrixCommitment.verifierTarget_eq_shoutReducedVerifierTarget
    {d m s rowBits varBits : Nat}
    [NeZero (2 : K)]
    (matrix : SparseMatrixCommitment (K := K) d m s rowBits varBits)
    (z : VariableCube varBits → K)
    (rowPoint : Point (K := K) rowBits)
    (varPoint : Point (K := K) varBits) :
    matrix.verifierTarget z rowPoint varPoint =
      matrix.shoutReducedVerifierTarget z rowPoint varPoint := by
  unfold SparseMatrixCommitment.verifierTarget
  unfold SparseMatrixCommitment.shoutReducedVerifierTarget
  rw [matrix.spark.sparkEval_eq_midpointReadCheckEval (matrix.query rowPoint varPoint)]

/-- Spartan++ instance from Section 9.3.2: two virtual matrix evaluations and multiplication outputs. -/
structure SpartanPPInstance (d m s rowBits varBits : Nat) where
  z : VariableCube varBits → K
  A : SparseMatrixCommitment (K := K) d m s rowBits varBits
  B : SparseMatrixCommitment (K := K) d m s rowBits varBits
  w : RowCube rowBits → K
  constraints_satisfied :
    ∀ row : RowCube rowBits,
      A.rowEval z (bitVec (K := K) row) * B.rowEval z (bitVec (K := K) row) = w row

/-- The Boolean-cube defect table whose vanishing is proved by Spartan++'s outer zero-check. -/
def SpartanPPInstance.constraintTable
    {d m s rowBits varBits : Nat}
    (inst : SpartanPPInstance (K := K) d m s rowBits varBits) :
    RowCube rowBits → K :=
  fun row =>
    inst.A.rowEval inst.z (bitVec (K := K) row) *
      inst.B.rowEval inst.z (bitVec (K := K) row) - inst.w row

/-- Equation (85), written as a multilinear zero-check claim. -/
def SpartanPPInstance.zeroCheckClaim
    {d m s rowBits varBits : Nat}
    (inst : SpartanPPInstance (K := K) d m s rowBits varBits)
    (tau : Point (K := K) rowBits) : K :=
  mle (K := K) inst.constraintTable tau

/-- Honest last-round verifier target after the outer Spartan zero-check binds all row variables. -/
def SpartanPPInstance.zeroCheckVerifierTarget
    {d m s rowBits varBits : Nat}
    (inst : SpartanPPInstance (K := K) d m s rowBits varBits)
    (tau : Point (K := K) rowBits)
    (rowPoint : Point (K := K) rowBits) : K :=
  eqPoly tau rowPoint *
    (inst.A.rowEval inst.z rowPoint *
      inst.B.rowEval inst.z rowPoint -
      mle (K := K) inst.w rowPoint)

theorem SpartanPPInstance.zeroCheckClaim_eq_zero
    {d m s rowBits varBits : Nat}
    (inst : SpartanPPInstance (K := K) d m s rowBits varBits)
    (tau : Point (K := K) rowBits) :
    inst.zeroCheckClaim tau = 0 := by
  unfold SpartanPPInstance.zeroCheckClaim mle SpartanPPInstance.constraintTable
  apply Finset.sum_eq_zero
  intro row _
  rw [inst.constraints_satisfied row]
  ring

end

/-- Section 9.3.1 field work for Spark++'s Shout reduction before evaluation-proof work. -/
def sparkPPReadCheckFieldCost
    (d supportBits : Nat) : Nat :=
  structuredReadValueEvalLeadingCost supportBits +
    structuredReadCheckLeadingCost 1 d supportBits

/-- Section 9.3.2 Hyrax-style field work to answer one requested Spark++ evaluation. -/
def sparkPPEvaluationProofFieldCost
    (supportBits : Nat) : Nat :=
  cycleSpaceSize supportBits

/-- Total field work for one Spark++ evaluation in Spartan++. -/
def sparkPPEvaluationFieldCost
    (d supportBits : Nat) : Nat :=
  sparkPPReadCheckFieldCost d supportBits +
    sparkPPEvaluationProofFieldCost supportBits

/-- The `6M + 5n` field multiplications for the three Spartan sum-check invocations. -/
def spartanPPOuterSumcheckFieldCost
    (constraintCount variableCount : Nat) : Nat :=
  6 * constraintCount + 5 * variableCount

/-- Two Spark++ evaluations, one each for `A` and `B`. -/
def spartanPPSparkFieldCost
    (d supportBits : Nat) : Nat :=
  2 * sparkPPEvaluationFieldCost d supportBits

/-- Total prover field multiplications reported in Section 9.3.2. -/
def spartanPPFieldMultiplications
    (d constraintCount variableCount supportBits : Nat) : Nat :=
  spartanPPOuterSumcheckFieldCost constraintCount variableCount +
    spartanPPSparkFieldCost d supportBits

theorem sparkPPReadCheckFieldCost_eq_paper
    (d supportBits : Nat) :
    sparkPPReadCheckFieldCost d supportBits =
      (d * d + 4) * cycleSpaceSize supportBits := by
  unfold sparkPPReadCheckFieldCost
  unfold structuredReadValueEvalLeadingCost structuredReadCheckLeadingCost
  ring

theorem sparkPPEvaluationFieldCost_eq_paper
    (d supportBits : Nat) :
    sparkPPEvaluationFieldCost d supportBits =
      (d * d + 5) * cycleSpaceSize supportBits := by
  unfold sparkPPEvaluationFieldCost sparkPPEvaluationProofFieldCost
  rw [sparkPPReadCheckFieldCost_eq_paper]
  ring

theorem spartanPPFieldMultiplications_eq_paper
    (d constraintCount variableCount supportBits : Nat) :
    spartanPPFieldMultiplications d constraintCount variableCount supportBits =
      6 * constraintCount + 5 * variableCount +
        2 * (d * d + 5) * cycleSpaceSize supportBits := by
  unfold spartanPPFieldMultiplications spartanPPOuterSumcheckFieldCost spartanPPSparkFieldCost
  rw [sparkPPEvaluationFieldCost_eq_paper]
  ring

theorem spartanPPFieldMultiplications_diag
    (d constraintCount supportBits : Nat) :
    spartanPPFieldMultiplications d constraintCount constraintCount supportBits =
      11 * constraintCount + (2 * d * d + 10) * cycleSpaceSize supportBits := by
  rw [spartanPPFieldMultiplications_eq_paper]
  ring

theorem spartanPPFieldMultiplications_d4_diag
    (constraintCount supportBits : Nat) :
    spartanPPFieldMultiplications 4 constraintCount constraintCount supportBits =
      11 * constraintCount + 42 * cycleSpaceSize supportBits := by
  rw [spartanPPFieldMultiplications_diag]

end TwistShout
