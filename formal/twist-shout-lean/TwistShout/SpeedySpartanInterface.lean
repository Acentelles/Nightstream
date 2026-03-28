import TwistShout.SpeedySpartan

/-!
# SpeedySpartanInterface

Thin theorem-facing boundary for the paper's SpeedySpartan application.
-/

namespace TwistShout

namespace SpeedySpartanInterface

abbrev GateCube := @TwistShout.GateCube
abbrev GateTable := @TwistShout.GateTable
abbrev DigitCube := @TwistShout.DigitCube
abbrev Address := @TwistShout.Address
abbrev AddressColumns := @TwistShout.AddressColumns
abbrev ValidAddressColumns := @TwistShout.ValidAddressColumns
abbrev PublicTable := @TwistShout.PublicTable
abbrev bitVec := @TwistShout.bitVec
abbrev bitAddress := @TwistShout.bitAddress
abbrev PreprocessedLookup := @TwistShout.PreprocessedLookup
abbrev DegreeTwoPlonkish := @TwistShout.DegreeTwoPlonkish
abbrev gateTableMLE := @TwistShout.gateTableMLE
abbrev spartanSumcheckFieldCost := @TwistShout.spartanSumcheckFieldCost
abbrev speedySpartanShoutInvocationFieldCost := @TwistShout.speedySpartanShoutInvocationFieldCost
abbrev speedySpartanShoutFieldCost := @TwistShout.speedySpartanShoutFieldCost
abbrev speedySpartanFieldMultiplications := @TwistShout.speedySpartanFieldMultiplications
abbrev smallWitnessCommitFieldCost := @TwistShout.smallWitnessCommitFieldCost
abbrev speedySpartanApproxTotalFieldMultiplications :=
  @TwistShout.speedySpartanApproxTotalFieldMultiplications

def PreprocessedLookup.readValues
  {K : Type*} [Field K]
  {d m s : Nat}
  (lookup : PreprocessedLookup (K := K) d m s)
  (z : PublicTable (K := K) d m) :
  GateTable (K := K) s :=
  TwistShout.PreprocessedLookup.readValues lookup z

def PreprocessedLookup.readEval
  {K : Type*} [Field K]
  {d m s : Nat}
  (lookup : PreprocessedLookup (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (rGate : Point (K := K) s) : K :=
  TwistShout.PreprocessedLookup.readEval lookup z rGate

def PreprocessedLookup.readCheckEval
  {K : Type*} [Field K]
  {d m s : Nat}
  (lookup : PreprocessedLookup (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (rGate : Point (K := K) s) : K :=
  TwistShout.PreprocessedLookup.readCheckEval lookup z rGate

theorem PreprocessedLookup.readEval_eq_readCheckEval
  {K : Type*} [Field K]
  {d m s : Nat}
  (lookup : PreprocessedLookup (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (rGate : Point (K := K) s) :
  lookup.readEval z rGate = lookup.readCheckEval z rGate :=
  TwistShout.PreprocessedLookup.readEval_eq_readCheckEval lookup z rGate

def DegreeTwoPlonkish.pointConstraint
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (j : GateCube s) : K :=
  TwistShout.DegreeTwoPlonkish.pointConstraint inst z j

def DegreeTwoPlonkish.constraintTable
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m) :
  GateTable (K := K) s :=
  TwistShout.DegreeTwoPlonkish.constraintTable inst z

def DegreeTwoPlonkish.virtualConstraintEval
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (rGate : Point (K := K) s) : K :=
  TwistShout.DegreeTwoPlonkish.virtualConstraintEval inst z rGate

def DegreeTwoPlonkish.shoutReducedConstraintEval
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (rGate : Point (K := K) s) : K :=
  TwistShout.DegreeTwoPlonkish.shoutReducedConstraintEval inst z rGate

def DegreeTwoPlonkish.verifierTarget
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (tau rGate : Point (K := K) s)
  (vA vB vC : K) : K :=
  TwistShout.DegreeTwoPlonkish.verifierTarget inst tau rGate vA vB vC

def DegreeTwoPlonkish.shoutReducedVerifierTarget
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (tau rGate : Point (K := K) s) : K :=
  TwistShout.DegreeTwoPlonkish.shoutReducedVerifierTarget inst z tau rGate

abbrev DegreeTwoPlonkish.ConstraintSatisfied :=
  @TwistShout.DegreeTwoPlonkish.ConstraintSatisfied

def DegreeTwoPlonkish.spartanZeroCheckClaim
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (tau : Point (K := K) s) : K :=
  TwistShout.DegreeTwoPlonkish.spartanZeroCheckClaim inst z tau

theorem DegreeTwoPlonkish.spartanZeroCheckClaim_eq_zero_of_constraintSatisfied
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (hSat : TwistShout.DegreeTwoPlonkish.ConstraintSatisfied inst z)
  (tau : Point (K := K) s) :
  inst.spartanZeroCheckClaim z tau = 0 :=
  TwistShout.DegreeTwoPlonkish.spartanZeroCheckClaim_eq_zero_of_constraintSatisfied
    inst z hSat tau

theorem DegreeTwoPlonkish.virtualConstraintEval_eq_shoutReducedConstraintEval
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (rGate : Point (K := K) s) :
  inst.virtualConstraintEval z rGate = inst.shoutReducedConstraintEval z rGate :=
  TwistShout.DegreeTwoPlonkish.virtualConstraintEval_eq_shoutReducedConstraintEval
    inst z rGate

theorem DegreeTwoPlonkish.verifierTarget_eq_virtualConstraintEval_of_lookupClaims
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (tau rGate : Point (K := K) s)
  (vA vB vC : K)
  (hA : vA = inst.lookupA.readEval z rGate)
  (hB : vB = inst.lookupB.readEval z rGate)
  (hC : vC = inst.lookupC.readEval z rGate) :
  inst.verifierTarget tau rGate vA vB vC =
    eqPoly tau rGate * inst.virtualConstraintEval z rGate :=
  TwistShout.DegreeTwoPlonkish.verifierTarget_eq_virtualConstraintEval_of_lookupClaims
    inst z tau rGate vA vB vC hA hB hC

theorem DegreeTwoPlonkish.verifierTarget_eq_shoutReducedVerifierTarget
  {K : Type*} [Field K]
  {d m s : Nat}
  (inst : DegreeTwoPlonkish (K := K) d m s)
  (z : PublicTable (K := K) d m)
  (tau rGate : Point (K := K) s) :
  inst.verifierTarget tau rGate
      (inst.lookupA.readEval z rGate)
      (inst.lookupB.readEval z rGate)
      (inst.lookupC.readEval z rGate) =
    inst.shoutReducedVerifierTarget z tau rGate :=
  TwistShout.DegreeTwoPlonkish.verifierTarget_eq_shoutReducedVerifierTarget
    inst z tau rGate

theorem speedySpartanShoutFieldCost_eq_double
  (d constraintCount tableSize : Nat) :
  speedySpartanShoutFieldCost d constraintCount tableSize =
    2 * ((d * d + 1) * constraintCount + 4 * tableSize) :=
  TwistShout.speedySpartanShoutFieldCost_eq_double d constraintCount tableSize

theorem speedySpartanFieldMultiplications_eq_formula
  (d constraintCount tableSize : Nat) :
  speedySpartanFieldMultiplications d constraintCount tableSize =
    (2 * d * d + 11) * constraintCount + 8 * tableSize :=
  TwistShout.speedySpartanFieldMultiplications_eq_formula d constraintCount tableSize

theorem speedySpartanApproxTotalFieldMultiplications_eq_formula
  (d constraintCount tableSize witnessSize : Nat) :
  speedySpartanApproxTotalFieldMultiplications d constraintCount tableSize witnessSize =
    (2 * d * d + 11) * constraintCount + 8 * tableSize + 6 * witnessSize :=
  TwistShout.speedySpartanApproxTotalFieldMultiplications_eq_formula
    d constraintCount tableSize witnessSize

theorem speedySpartanFieldMultiplications_d2
  (constraintCount tableSize : Nat) :
  speedySpartanFieldMultiplications 2 constraintCount tableSize =
    19 * constraintCount + 8 * tableSize :=
  TwistShout.speedySpartanFieldMultiplications_d2 constraintCount tableSize

theorem speedySpartanFieldMultiplications_d3
  (constraintCount tableSize : Nat) :
  speedySpartanFieldMultiplications 3 constraintCount tableSize =
    29 * constraintCount + 8 * tableSize :=
  TwistShout.speedySpartanFieldMultiplications_d3 constraintCount tableSize

theorem speedySpartanApproxTotalFieldMultiplications_d2
  (constraintCount tableSize witnessSize : Nat) :
  speedySpartanApproxTotalFieldMultiplications 2 constraintCount tableSize witnessSize =
    19 * constraintCount + 8 * tableSize + 6 * witnessSize :=
  TwistShout.speedySpartanApproxTotalFieldMultiplications_d2
    constraintCount tableSize witnessSize

theorem speedySpartanApproxTotalFieldMultiplications_d3
  (constraintCount tableSize witnessSize : Nat) :
  speedySpartanApproxTotalFieldMultiplications 3 constraintCount tableSize witnessSize =
    29 * constraintCount + 8 * tableSize + 6 * witnessSize :=
  TwistShout.speedySpartanApproxTotalFieldMultiplications_d3
    constraintCount tableSize witnessSize

theorem speedySpartanFieldMultiplications_d2_diag
  (constraintCount : Nat) :
  speedySpartanFieldMultiplications 2 constraintCount constraintCount =
    27 * constraintCount :=
  TwistShout.speedySpartanFieldMultiplications_d2_diag constraintCount

theorem speedySpartanApproxTotalFieldMultiplications_d2_diag
  (constraintCount : Nat) :
  speedySpartanApproxTotalFieldMultiplications 2 constraintCount constraintCount constraintCount =
    33 * constraintCount :=
  TwistShout.speedySpartanApproxTotalFieldMultiplications_d2_diag constraintCount

theorem speedySpartanApproxTotalFieldMultiplications_d3_diag
  (constraintCount : Nat) :
  speedySpartanApproxTotalFieldMultiplications 3 constraintCount constraintCount constraintCount =
    43 * constraintCount :=
  TwistShout.speedySpartanApproxTotalFieldMultiplications_d3_diag constraintCount

end SpeedySpartanInterface

end TwistShout
