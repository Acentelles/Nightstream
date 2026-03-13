import TwistShout.SpeedySpartanInterface

open TwistShout.SpeedySpartanInterface

namespace tests.speedyspartan

def zeroDigit : DigitCube 1 := fun _ => false

def oneDigit : DigitCube 1 := fun _ => true

def addr0 : Address 1 1 := fun _ => zeroDigit

def addr1 : Address 1 1 := fun _ => oneDigit

def gate0 : GateCube 1 := fun _ => false

def gate1 : GateCube 1 := fun _ => true

def lookupAAddr : GateCube 1 → Address 1 1 :=
  fun j => if j 0 then addr1 else addr0

def lookupBAddr : GateCube 1 → Address 1 1 :=
  fun j => if j 0 then addr0 else addr1

def lookupCAddr : GateCube 1 → Address 1 1 :=
  fun j => if j 0 then addr1 else addr0

def lookupACols : AddressColumns (K := Rat) 1 1 1 :=
  fun i k j => TwistShout.cubeOneHot (K := Rat) (lookupAAddr j i) k

def lookupBCols : AddressColumns (K := Rat) 1 1 1 :=
  fun i k j => TwistShout.cubeOneHot (K := Rat) (lookupBAddr j i) k

def lookupCCols : AddressColumns (K := Rat) 1 1 1 :=
  fun i k j => TwistShout.cubeOneHot (K := Rat) (lookupCAddr j i) k

theorem lookupAValid :
    ValidAddressColumns (K := Rat) lookupACols lookupAAddr := by
  intro j i k
  rfl

theorem lookupBValid :
    ValidAddressColumns (K := Rat) lookupBCols lookupBAddr := by
  intro j i k
  rfl

theorem lookupCValid :
    ValidAddressColumns (K := Rat) lookupCCols lookupCAddr := by
  intro j i k
  rfl

def preA : PreprocessedLookup (K := Rat) 1 1 1 where
  columns := lookupACols
  addr := lookupAAddr
  valid := lookupAValid

def preB : PreprocessedLookup (K := Rat) 1 1 1 where
  columns := lookupBCols
  addr := lookupBAddr
  valid := lookupBValid

def preC : PreprocessedLookup (K := Rat) 1 1 1 where
  columns := lookupCCols
  addr := lookupCAddr
  valid := lookupCValid

def sampleZ : PublicTable (K := Rat) 1 1 :=
  fun a => if a = addr0 then 7 else 11

def qL : GateTable (K := Rat) 1 :=
  fun j => if j 0 then 3 else 2

def qR : GateTable (K := Rat) 1 :=
  fun j => if j 0 then 7 else 5

def qO : GateTable (K := Rat) 1 :=
  fun j => if j 0 then 4 else -1

def qM : GateTable (K := Rat) 1 :=
  fun j => if j 0 then 1 else 0

def qC : GateTable (K := Rat) 1 :=
  fun j => if j 0 then -2 else 1

def sampleInst : DegreeTwoPlonkish (K := Rat) 1 1 1 where
  qL := qL
  qR := qR
  qO := qO
  qM := qM
  qC := qC
  lookupA := preA
  lookupB := preB
  lookupC := preC

def zeroInst : DegreeTwoPlonkish (K := Rat) 1 1 1 where
  qL := fun _ => 0
  qR := fun _ => 0
  qO := fun _ => 0
  qM := fun _ => 0
  qC := fun _ => 0
  lookupA := preA
  lookupB := preB
  lookupC := preC

theorem zeroInstSatisfied :
    TwistShout.DegreeTwoPlonkish.ConstraintSatisfied zeroInst sampleZ := by
  unfold TwistShout.DegreeTwoPlonkish.ConstraintSatisfied
  intro j
  simp [TwistShout.DegreeTwoPlonkish.pointConstraint, zeroInst]

example :
    preA.readEval sampleZ (bitVec (K := Rat) gate0) =
      preA.readCheckEval sampleZ (bitVec (K := Rat) gate0) := by
  exact preA.readEval_eq_readCheckEval sampleZ (bitVec (K := Rat) gate0)

example :
    preA.readEval sampleZ (bitVec (K := Rat) gate0) = 7 := by
  rw [preA.readEval_eq_readCheckEval sampleZ (bitVec (K := Rat) gate0)]
  native_decide

example :
    sampleInst.virtualConstraintEval sampleZ (bitVec (K := Rat) gate0) =
      sampleInst.shoutReducedConstraintEval sampleZ (bitVec (K := Rat) gate0) := by
  exact sampleInst.virtualConstraintEval_eq_shoutReducedConstraintEval
    sampleZ (bitVec (K := Rat) gate0)

example :
    sampleInst.virtualConstraintEval sampleZ (bitVec (K := Rat) gate0) = 63 := by
  rw [sampleInst.virtualConstraintEval_eq_shoutReducedConstraintEval
    sampleZ (bitVec (K := Rat) gate0)]
  native_decide

example :
    sampleInst.verifierTarget (bitVec (K := Rat) gate1) (bitVec (K := Rat) gate0)
      (sampleInst.lookupA.readEval sampleZ (bitVec (K := Rat) gate0))
      (sampleInst.lookupB.readEval sampleZ (bitVec (K := Rat) gate0))
      (sampleInst.lookupC.readEval sampleZ (bitVec (K := Rat) gate0)) =
      sampleInst.shoutReducedVerifierTarget sampleZ
        (bitVec (K := Rat) gate1) (bitVec (K := Rat) gate0) := by
  exact sampleInst.verifierTarget_eq_shoutReducedVerifierTarget sampleZ
    (bitVec (K := Rat) gate1) (bitVec (K := Rat) gate0)

example :
    zeroInst.spartanZeroCheckClaim sampleZ (bitVec (K := Rat) gate1) = 0 := by
  exact zeroInst.spartanZeroCheckClaim_eq_zero_of_constraintSatisfied
    sampleZ zeroInstSatisfied (bitVec (K := Rat) gate1)

example :
    speedySpartanFieldMultiplications 2 5 7 = 19 * 5 + 8 * 7 := by
  exact speedySpartanFieldMultiplications_d2 5 7

example :
    speedySpartanApproxTotalFieldMultiplications 3 5 7 11 =
      29 * 5 + 8 * 7 + 6 * 11 := by
  exact speedySpartanApproxTotalFieldMultiplications_d3 5 7 11

#guard speedySpartanFieldMultiplications 2 8 8 = 27 * 8
#guard speedySpartanApproxTotalFieldMultiplications 2 8 8 8 = 33 * 8
#guard speedySpartanApproxTotalFieldMultiplications 3 8 8 8 = 43 * 8

end tests.speedyspartan
