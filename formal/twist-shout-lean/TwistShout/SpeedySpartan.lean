import TwistShout.FastShoutSmallMemory

/-!
# SpeedySpartan

Section 9 application identities for SpeedySpartan.
-/

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Gate labels for the outer Spartan-style sum-check. -/
abbrev GateCube (s : Nat) := Cube s

/-- Cube-indexed gate table used for selectors and virtual lookup values. -/
abbrev GateTable (s : Nat) := GateCube s → K

/-- Honest preprocessed Shout lookup data for one sparse matrix. -/
structure PreprocessedLookup (d m s : Nat) where
  columns : AddressColumns (K := K) d m s
  addr : GateCube s → Address d m
  valid : ValidAddressColumns (K := K) columns addr

/-- The gate-indexed table returned by the honest lookup addresses. -/
def PreprocessedLookup.readValues
    {d m s : Nat}
    (lookup : PreprocessedLookup (K := K) d m s)
    (z : PublicTable (K := K) d m) :
    GateTable (K := K) s :=
  readOracleTable (K := K) z lookup.addr

/-- The virtual polynomial `\tilde z_M(r)` obtained from the lookup table. -/
def PreprocessedLookup.readEval
    {d m s : Nat}
    (lookup : PreprocessedLookup (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (rGate : Point (K := K) s) : K :=
  mle (K := K) (lookup.readValues z) rGate

/-- The Shout read-check expression for the same preprocessed lookup data. -/
def PreprocessedLookup.readCheckEval
    {d m s : Nat}
    (lookup : PreprocessedLookup (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (rGate : Point (K := K) s) : K :=
  readCheckExpression (K := K) lookup.columns z rGate

theorem PreprocessedLookup.readEval_eq_readCheckEval
    {d m s : Nat}
    (lookup : PreprocessedLookup (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (rGate : Point (K := K) s) :
    lookup.readEval z rGate = lookup.readCheckEval z rGate :=
  lookup.valid.readCheckExpression z rGate

/-- Degree-2 Plonkish instance from Definition 9.1, represented as cube-indexed tables. -/
structure DegreeTwoPlonkish (d m s : Nat) where
  qL : GateTable (K := K) s
  qR : GateTable (K := K) s
  qO : GateTable (K := K) s
  qM : GateTable (K := K) s
  qC : GateTable (K := K) s
  lookupA : PreprocessedLookup (K := K) d m s
  lookupB : PreprocessedLookup (K := K) d m s
  lookupC : PreprocessedLookup (K := K) d m s

/-- Multilinear extension of a public gate-selector table. -/
def gateTableMLE
    {s : Nat}
    (q : GateTable (K := K) s)
    (rGate : Point (K := K) s) : K :=
  mle (K := K) q rGate

/-- Pointwise degree-2 Plonkish constraint value on the Boolean cube. -/
def DegreeTwoPlonkish.pointConstraint
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (j : GateCube s) : K :=
  inst.qL j * inst.lookupA.readValues z j +
    inst.qR j * inst.lookupB.readValues z j +
    inst.qO j * inst.lookupC.readValues z j +
    inst.qM j * inst.lookupA.readValues z j * inst.lookupB.readValues z j +
    inst.qC j

/-- Boolean-cube table whose vanishing encodes Plonkish satisfaction. -/
def DegreeTwoPlonkish.constraintTable
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m) :
    GateTable (K := K) s :=
  inst.pointConstraint z

/-- Equation (82) evaluated at a random point using the virtual lookup polynomials. -/
def DegreeTwoPlonkish.virtualConstraintEval
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (rGate : Point (K := K) s) : K :=
  gateTableMLE (K := K) inst.qL rGate * inst.lookupA.readEval z rGate +
    gateTableMLE (K := K) inst.qR rGate * inst.lookupB.readEval z rGate +
    gateTableMLE (K := K) inst.qO rGate * inst.lookupC.readEval z rGate +
    gateTableMLE (K := K) inst.qM rGate *
      inst.lookupA.readEval z rGate * inst.lookupB.readEval z rGate +
    gateTableMLE (K := K) inst.qC rGate

/-- The same random-point constraint expression with the virtual lookups reduced to Shout. -/
def DegreeTwoPlonkish.shoutReducedConstraintEval
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (rGate : Point (K := K) s) : K :=
  gateTableMLE (K := K) inst.qL rGate * inst.lookupA.readCheckEval z rGate +
    gateTableMLE (K := K) inst.qR rGate * inst.lookupB.readCheckEval z rGate +
    gateTableMLE (K := K) inst.qO rGate * inst.lookupC.readCheckEval z rGate +
    gateTableMLE (K := K) inst.qM rGate *
      inst.lookupA.readCheckEval z rGate * inst.lookupB.readCheckEval z rGate +
    gateTableMLE (K := K) inst.qC rGate

/-- The verifier's end-of-sum-check target after receiving lookup claims `v_A,v_B,v_C`. -/
def DegreeTwoPlonkish.verifierTarget
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (tau rGate : Point (K := K) s)
    (vA vB vC : K) : K :=
  eqPoly tau rGate *
    (gateTableMLE (K := K) inst.qL rGate * vA +
      gateTableMLE (K := K) inst.qR rGate * vB +
      gateTableMLE (K := K) inst.qO rGate * vC +
      gateTableMLE (K := K) inst.qM rGate * vA * vB +
      gateTableMLE (K := K) inst.qC rGate)

/-- The verifier target with the virtual claims reduced to the Shout read-check expressions. -/
def DegreeTwoPlonkish.shoutReducedVerifierTarget
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (tau rGate : Point (K := K) s) : K :=
  eqPoly tau rGate * inst.shoutReducedConstraintEval z rGate

/-- Pointwise satisfaction of the Plonkish constraint table on all gates. -/
def DegreeTwoPlonkish.ConstraintSatisfied
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m) : Prop :=
  ∀ j, inst.pointConstraint z j = 0

/-- The Boolean-hypercube zero-check claim used for the first SpeedySpartan sum-check. -/
def DegreeTwoPlonkish.spartanZeroCheckClaim
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (tau : Point (K := K) s) : K :=
  mle (K := K) (inst.constraintTable z) tau

theorem DegreeTwoPlonkish.spartanZeroCheckClaim_eq_zero_of_constraintSatisfied
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (hSat : inst.ConstraintSatisfied z)
    (tau : Point (K := K) s) :
    inst.spartanZeroCheckClaim z tau = 0 := by
  unfold DegreeTwoPlonkish.spartanZeroCheckClaim mle
  unfold DegreeTwoPlonkish.constraintTable
  apply Finset.sum_eq_zero
  intro j _
  rw [hSat j]
  ring

theorem DegreeTwoPlonkish.virtualConstraintEval_eq_shoutReducedConstraintEval
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (rGate : Point (K := K) s) :
    inst.virtualConstraintEval z rGate = inst.shoutReducedConstraintEval z rGate := by
  unfold DegreeTwoPlonkish.virtualConstraintEval
  unfold DegreeTwoPlonkish.shoutReducedConstraintEval
  rw [inst.lookupA.readEval_eq_readCheckEval z rGate]
  rw [inst.lookupB.readEval_eq_readCheckEval z rGate]
  rw [inst.lookupC.readEval_eq_readCheckEval z rGate]

theorem DegreeTwoPlonkish.verifierTarget_eq_virtualConstraintEval_of_lookupClaims
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (tau rGate : Point (K := K) s)
    (vA vB vC : K)
    (hA : vA = inst.lookupA.readEval z rGate)
    (hB : vB = inst.lookupB.readEval z rGate)
    (hC : vC = inst.lookupC.readEval z rGate) :
    inst.verifierTarget tau rGate vA vB vC =
      eqPoly tau rGate * inst.virtualConstraintEval z rGate := by
  subst vA
  subst vB
  subst vC
  unfold DegreeTwoPlonkish.verifierTarget
  unfold DegreeTwoPlonkish.virtualConstraintEval
  ring

theorem DegreeTwoPlonkish.verifierTarget_eq_shoutReducedVerifierTarget
    {d m s : Nat}
    (inst : DegreeTwoPlonkish (K := K) d m s)
    (z : PublicTable (K := K) d m)
    (tau rGate : Point (K := K) s) :
    inst.verifierTarget tau rGate
        (inst.lookupA.readEval z rGate)
        (inst.lookupB.readEval z rGate)
        (inst.lookupC.readEval z rGate) =
      inst.shoutReducedVerifierTarget z tau rGate := by
  rw [inst.verifierTarget_eq_virtualConstraintEval_of_lookupClaims
    z tau rGate
    (inst.lookupA.readEval z rGate)
    (inst.lookupB.readEval z rGate)
    (inst.lookupC.readEval z rGate)
    rfl rfl rfl]
  unfold DegreeTwoPlonkish.shoutReducedVerifierTarget
  rw [inst.virtualConstraintEval_eq_shoutReducedConstraintEval z rGate]

end

/-- Section 9.2.3 cost of the Spartan sum-check in the online phase. -/
def spartanSumcheckFieldCost (constraintCount : Nat) : Nat :=
  9 * constraintCount

/-- Section 9.2.3 cost of one Shout invocation in arithmetic-circuit SpeedySpartan. -/
def speedySpartanShoutInvocationFieldCost
    (d constraintCount tableSize : Nat) : Nat :=
  (d * d + 1) * constraintCount + 4 * tableSize

/-- Two Shout invocations for the arithmetic-circuit special case of SpeedySpartan. -/
def speedySpartanShoutFieldCost
    (d constraintCount tableSize : Nat) : Nat :=
  2 * speedySpartanShoutInvocationFieldCost d constraintCount tableSize

/-- Total online field multiplications across all sum-check invocations. -/
def speedySpartanFieldMultiplications
    (d constraintCount tableSize : Nat) : Nat :=
  spartanSumcheckFieldCost constraintCount +
    speedySpartanShoutFieldCost d constraintCount tableSize

/-- Figure 11's conversion from a small-field witness commitment to field multiplications. -/
def smallWitnessCommitFieldCost (witnessSize : Nat) : Nat :=
  6 * witnessSize

/-- Figure 11's approximate total prover field cost. -/
def speedySpartanApproxTotalFieldMultiplications
    (d constraintCount tableSize witnessSize : Nat) : Nat :=
  speedySpartanFieldMultiplications d constraintCount tableSize +
    smallWitnessCommitFieldCost witnessSize

theorem speedySpartanShoutFieldCost_eq_double
    (d constraintCount tableSize : Nat) :
    speedySpartanShoutFieldCost d constraintCount tableSize =
      2 * ((d * d + 1) * constraintCount + 4 * tableSize) := by
  unfold speedySpartanShoutFieldCost speedySpartanShoutInvocationFieldCost
  rfl

theorem speedySpartanFieldMultiplications_eq_formula
    (d constraintCount tableSize : Nat) :
    speedySpartanFieldMultiplications d constraintCount tableSize =
      (2 * d * d + 11) * constraintCount + 8 * tableSize := by
  unfold speedySpartanFieldMultiplications
  unfold spartanSumcheckFieldCost speedySpartanShoutFieldCost
  unfold speedySpartanShoutInvocationFieldCost
  ring

theorem speedySpartanApproxTotalFieldMultiplications_eq_formula
    (d constraintCount tableSize witnessSize : Nat) :
    speedySpartanApproxTotalFieldMultiplications d constraintCount tableSize witnessSize =
      (2 * d * d + 11) * constraintCount + 8 * tableSize + 6 * witnessSize := by
  unfold speedySpartanApproxTotalFieldMultiplications smallWitnessCommitFieldCost
  rw [speedySpartanFieldMultiplications_eq_formula]

theorem speedySpartanFieldMultiplications_d2
    (constraintCount tableSize : Nat) :
    speedySpartanFieldMultiplications 2 constraintCount tableSize =
      19 * constraintCount + 8 * tableSize := by
  rw [speedySpartanFieldMultiplications_eq_formula]

theorem speedySpartanFieldMultiplications_d3
    (constraintCount tableSize : Nat) :
    speedySpartanFieldMultiplications 3 constraintCount tableSize =
      29 * constraintCount + 8 * tableSize := by
  rw [speedySpartanFieldMultiplications_eq_formula]

theorem speedySpartanApproxTotalFieldMultiplications_d2
    (constraintCount tableSize witnessSize : Nat) :
    speedySpartanApproxTotalFieldMultiplications 2 constraintCount tableSize witnessSize =
      19 * constraintCount + 8 * tableSize + 6 * witnessSize := by
  rw [speedySpartanApproxTotalFieldMultiplications_eq_formula]

theorem speedySpartanApproxTotalFieldMultiplications_d3
    (constraintCount tableSize witnessSize : Nat) :
    speedySpartanApproxTotalFieldMultiplications 3 constraintCount tableSize witnessSize =
      29 * constraintCount + 8 * tableSize + 6 * witnessSize := by
  rw [speedySpartanApproxTotalFieldMultiplications_eq_formula]

theorem speedySpartanFieldMultiplications_d2_diag
    (constraintCount : Nat) :
    speedySpartanFieldMultiplications 2 constraintCount constraintCount =
      27 * constraintCount := by
  rw [speedySpartanFieldMultiplications_d2]
  ring

theorem speedySpartanApproxTotalFieldMultiplications_d2_diag
    (constraintCount : Nat) :
    speedySpartanApproxTotalFieldMultiplications 2 constraintCount constraintCount constraintCount =
      33 * constraintCount := by
  rw [speedySpartanApproxTotalFieldMultiplications_d2]
  ring

theorem speedySpartanApproxTotalFieldMultiplications_d3_diag
    (constraintCount : Nat) :
    speedySpartanApproxTotalFieldMultiplications 3 constraintCount constraintCount constraintCount =
      43 * constraintCount := by
  rw [speedySpartanApproxTotalFieldMultiplications_d3]
  ring

end TwistShout
