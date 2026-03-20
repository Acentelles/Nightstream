import Mathlib

namespace Nightstream.Chip8

variable {K : Type*} [Field K]

abbrev Witness (K : Type*) := Fin 24 → K
abbrev FlagTuple (K : Type*) := K × K × K × K × K × K × K
abbrev ControlTuple (K : Type*) := K × K × K × K × K × K × K × K

def routingFlags (z : Witness K) : FlagTuple K :=
  (z 13, z 14, z 15, z 16, z 17, z 18, z 19)

def controlBits (z : Witness K) : ControlTuple K :=
  (z 13, z 14, z 15, z 16, z 17, z 18, z 19, z 22)

def wf (z : Witness K) : Prop :=
  z 0 = 1

def isBit (x : K) : Prop :=
  x * (x - 1) = 0

def controlBitConstraints (z : Witness K) : Prop :=
  isBit (z 13) ∧
    isBit (z 14) ∧
    isBit (z 15) ∧
    isBit (z 16) ∧
    isBit (z 17) ∧
    isBit (z 18) ∧
    isBit (z 19) ∧
    isBit (z 22)

def xLanePartitionConstraint (z : Witness K) : Prop :=
  z 13 + z 14 + z 15 = 1

def xLookupConstraint (z : Witness K) : Prop :=
  z 13 * (z 5 - z 12) = 0

def xMemConstraint (z : Witness K) : Prop :=
  z 14 * (z 5 - z 11) = 0

def xPreserveConstraint (z : Witness K) : Prop :=
  z 15 * (z 5 - z 3) = 0

def iRoutingConstraint (z : Witness K) : Prop :=
  z 16 * (z 9 - z 6) = z 7 - z 6

def pcJumpConstraint (z : Witness K) : Prop :=
  z 17 * (z 2 - z 10) = 0

def pcBranchConstraint (z : Witness K) : Prop :=
  z 18 * (z 2 - z 1 - z 0 - z 12) = 0

def pcMemConstraint (z : Witness K) : Prop :=
  z 19 * (z 2 - z 1 - z 22) = 0

def pcDefaultConstraint (z : Witness K) : Prop :=
  (z 0 - z 17 - z 18 - z 19) * (z 2 - z 1 - z 0) = 0

def ramAddrActiveConstraint (z : Witness K) : Prop :=
  z 19 * (z 23 - z 6 - z 20) = 0

def ramAddrInactiveConstraint (z : Witness K) : Prop :=
  (z 0 - z 19) * z 23 = 0

def chip8RowLocalConstraints (z : Witness K) : Prop :=
  controlBitConstraints z ∧
    xLanePartitionConstraint z ∧
    xLookupConstraint z ∧
    xMemConstraint z ∧
    xPreserveConstraint z ∧
    iRoutingConstraint z ∧
    pcJumpConstraint z ∧
    pcBranchConstraint z ∧
    pcMemConstraint z ∧
    pcDefaultConstraint z ∧
    ramAddrActiveConstraint z ∧
    ramAddrInactiveConstraint z

def chip8RowLocalSound (z : Witness K) : Prop :=
  (z 13 = 1 → z 5 = z 12) ∧
    (z 14 = 1 → z 5 = z 11) ∧
    (z 15 = 1 → z 5 = z 3) ∧
    (z 16 = 1 → z 7 = z 9) ∧
    (z 16 = 0 → z 7 = z 6) ∧
    (z 17 = 1 → z 2 = z 10) ∧
    (wf z ∧ z 18 = 1 → z 2 = z 1 + 1 + z 12) ∧
    (z 19 = 1 → z 2 = z 1 + z 22) ∧
    (wf z ∧ z 17 = 0 ∧ z 18 = 0 ∧ z 19 = 0 → z 2 = z 1 + 1) ∧
    (z 19 = 1 → z 23 = z 6 + z 20) ∧
    (wf z ∧ z 19 = 0 → z 23 = 0)

inductive BehaviorClass where
  | writesLookupToVx
  | skipEqImm
  | jump
  | writesNnnToI
  | storeRegs
  | loadRegs
deriving DecidableEq, Repr

def behaviorFlags : BehaviorClass → FlagTuple K
  | .writesLookupToVx => (1, 0, 0, 0, 0, 0, 0)
  | .skipEqImm => (0, 0, 1, 0, 0, 1, 0)
  | .jump => (0, 0, 1, 0, 1, 0, 0)
  | .writesNnnToI => (0, 0, 1, 1, 0, 0, 0)
  | .storeRegs => (0, 0, 1, 0, 0, 0, 1)
  | .loadRegs => (0, 1, 0, 0, 0, 0, 1)

def decodeImage : Set (FlagTuple K) :=
  Set.range (behaviorFlags (K := K))

def mkWitness
  (pc pcNext regX regY regXNext iReg iNext kk nnnAddr nnnWord memValue lookupOutput
    writesLookupToX writesMemToX preservesX writesNnnToI isJump isBranch isMemOp
    xIdx yIdx burstLast ramAddr : K) :
  Witness K
  | 0 => 1
  | 1 => pc
  | 2 => pcNext
  | 3 => regX
  | 4 => regY
  | 5 => regXNext
  | 6 => iReg
  | 7 => iNext
  | 8 => kk
  | 9 => nnnAddr
  | 10 => nnnWord
  | 11 => memValue
  | 12 => lookupOutput
  | 13 => writesLookupToX
  | 14 => writesMemToX
  | 15 => preservesX
  | 16 => writesNnnToI
  | 17 => isJump
  | 18 => isBranch
  | 19 => isMemOp
  | 20 => xIdx
  | 21 => yIdx
  | 22 => burstLast
  | 23 => ramAddr
  | _ => 0

def witnessForBehavior
  (behavior : BehaviorClass)
  (last pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  Witness K :=
  match behavior with
  | .writesLookupToVx =>
      mkWitness pc (pc + 1) regX regY lookupOutput iReg iReg kk nnnAddr nnnWord memValue
        lookupOutput 1 0 0 0 0 0 0 xIdx yIdx last 0
  | .skipEqImm =>
      mkWitness pc (pc + 1 + lookupOutput) regX regY regX iReg iReg kk nnnAddr nnnWord memValue
        lookupOutput 0 0 1 0 0 1 0 xIdx yIdx last 0
  | .jump =>
      mkWitness pc nnnWord regX regY regX iReg iReg kk nnnAddr nnnWord memValue
        lookupOutput 0 0 1 0 1 0 0 xIdx yIdx last 0
  | .writesNnnToI =>
      mkWitness pc (pc + 1) regX regY regX iReg nnnAddr kk nnnAddr nnnWord memValue
        lookupOutput 0 0 1 1 0 0 0 xIdx yIdx last 0
  | .storeRegs =>
      mkWitness pc (pc + last) regX regY regX iReg iReg kk nnnAddr nnnWord memValue
        lookupOutput 0 0 1 0 0 0 1 xIdx yIdx last (iReg + xIdx)
  | .loadRegs =>
      mkWitness pc (pc + last) regX regY memValue iReg iReg kk nnnAddr nnnWord memValue
        lookupOutput 0 1 0 0 0 0 1 xIdx yIdx last (iReg + xIdx)

private theorem eq_zero_or_eq_one_of_isBit
  {x : K}
  (h : isBit x) :
  x = 0 ∨ x = 1 := by
  rcases mul_eq_zero.mp h with hZero | hOne
  · exact Or.inl hZero
  · exact Or.inr (sub_eq_zero.mp hOne)

private theorem eq_of_sub_eq_zero
  {a b : K}
  (h : a - b = 0) :
  a = b := by
  calc
    a = (a - b) + b := by ring
    _ = b := by simp [h]

private theorem eq_of_sub_sub_eq_zero
  {a b c : K}
  (h : a - b - c = 0) :
  a = b + c := by
  calc
    a = (a - b - c) + (b + c) := by ring
    _ = b + c := by simp [h]

private theorem eq_of_sub_sub_sub_eq_zero
  {a b c d : K}
  (h : a - b - c - d = 0) :
  a = b + c + d := by
  calc
    a = (a - b - c - d) + (b + c + d) := by ring
    _ = b + c + d := by simp [h]

@[simp] private theorem isBit_zero : isBit (0 : K) := by
  simp [isBit]

@[simp] private theorem isBit_one : isBit (1 : K) := by
  simp [isBit]

private theorem controlBitConstraints_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  controlBitConstraints z :=
  h.1

private theorem xLanePartitionConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  xLanePartitionConstraint z :=
  h.2.1

private theorem xLookupConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  xLookupConstraint z :=
  h.2.2.1

private theorem xMemConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  xMemConstraint z :=
  h.2.2.2.1

private theorem xPreserveConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  xPreserveConstraint z :=
  h.2.2.2.2.1

private theorem iRoutingConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  iRoutingConstraint z :=
  h.2.2.2.2.2.1

private theorem pcJumpConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  pcJumpConstraint z :=
  h.2.2.2.2.2.2.1

private theorem pcBranchConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  pcBranchConstraint z :=
  h.2.2.2.2.2.2.2.1

private theorem pcMemConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  pcMemConstraint z :=
  h.2.2.2.2.2.2.2.2.1

private theorem pcDefaultConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  pcDefaultConstraint z :=
  h.2.2.2.2.2.2.2.2.2.1

private theorem ramAddrActiveConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  ramAddrActiveConstraint z :=
  h.2.2.2.2.2.2.2.2.2.2.1

private theorem ramAddrInactiveConstraint_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  ramAddrInactiveConstraint z :=
  h.2.2.2.2.2.2.2.2.2.2.2

private theorem threeBitPartition_oneHot
  [NeZero (2 : K)]
  {a b c : K}
  (ha : isBit a)
  (hb : isBit b)
  (hc : isBit c)
  (hs : a + b + c = 1) :
  (a = 1 ∧ b = 0 ∧ c = 0) ∨
    (a = 0 ∧ b = 1 ∧ c = 0) ∨
    (a = 0 ∧ b = 0 ∧ c = 1) := by
  rcases eq_zero_or_eq_one_of_isBit ha with ha0 | ha1
  · rcases eq_zero_or_eq_one_of_isBit hb with hb0 | hb1
    · have hc1 : c = 1 := by
        simpa [ha0, hb0] using hs
      exact Or.inr <| Or.inr ⟨ha0, hb0, hc1⟩
    · rcases eq_zero_or_eq_one_of_isBit hc with hc0 | hc1
      · exact Or.inr <| Or.inl ⟨ha0, hb1, hc0⟩
      · have hImpossible : (1 : K) = 0 := by
          have hSum := hs
          simp [ha0, hb1, hc1] at hSum
        exact (one_ne_zero hImpossible).elim
  · rcases eq_zero_or_eq_one_of_isBit hb with hb0 | hb1
    · rcases eq_zero_or_eq_one_of_isBit hc with hc0 | hc1
      · exact Or.inl ⟨ha1, hb0, hc0⟩
      · have hImpossible : (1 : K) = 0 := by
          have hSum := hs
          simp [ha1, hb0, hc1] at hSum
        exact (one_ne_zero hImpossible).elim
    · rcases eq_zero_or_eq_one_of_isBit hc with hc0 | hc1
      · have hImpossible : (1 : K) = 0 := by
          have hSum := hs
          simp [ha1, hb1, hc0] at hSum
        exact (one_ne_zero hImpossible).elim
      · have hTwoZero : (2 : K) = 0 := by
          have hSum : (1 : K) + 1 + 1 = 1 := by
            simpa [ha1, hb1, hc1, add_assoc, add_left_comm, add_comm] using hs
          calc
            (2 : K) = ((1 : K) + 1 + 1) - 1 := by ring
            _ = (1 : K) - 1 := by rw [hSum]
            _ = 0 := by ring
        exact (two_ne_zero hTwoZero).elim

theorem xRouting_oneHot
  [NeZero (2 : K)]
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  (z 13 = 1 ∧ z 14 = 0 ∧ z 15 = 0) ∨
    (z 13 = 0 ∧ z 14 = 1 ∧ z 15 = 0) ∨
    (z 13 = 0 ∧ z 14 = 0 ∧ z 15 = 1) := by
  have hBits := controlBitConstraints_of_constraints h
  exact threeBitPartition_oneHot
    hBits.1
    hBits.2.1
    hBits.2.2.1
    (xLanePartitionConstraint_of_constraints h)

theorem iRouting_forced
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  (z 16 = 1 → z 7 = z 9) ∧ (z 16 = 0 → z 7 = z 6) := by
  constructor
  · intro h16
    have hEq : z 9 - z 6 = z 7 - z 6 := by
      simpa [iRoutingConstraint, h16] using iRoutingConstraint_of_constraints h
    calc
      z 7 = (z 7 - z 6) + z 6 := by ring
      _ = (z 9 - z 6) + z 6 := by rw [← hEq]
      _ = z 9 := by ring
  · intro h16
    have hEq : z 7 - z 6 = 0 := by
      simpa [iRoutingConstraint, h16] using (iRoutingConstraint_of_constraints h).symm
    exact eq_of_sub_eq_zero hEq

theorem pcRouting_forced
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  (z 17 = 1 → z 2 = z 10) ∧
    (wf z ∧ z 18 = 1 → z 2 = z 1 + 1 + z 12) ∧
    (z 19 = 1 → z 2 = z 1 + z 22) ∧
    (wf z ∧ z 17 = 0 ∧ z 18 = 0 ∧ z 19 = 0 → z 2 = z 1 + 1) := by
  constructor
  · intro h17
    have hEq : z 2 - z 10 = 0 := by
      simpa [pcJumpConstraint, h17] using pcJumpConstraint_of_constraints h
    exact eq_of_sub_eq_zero hEq
  constructor
  · rintro ⟨hWf, h18⟩
    simp [wf] at hWf
    have hEq : z 2 - z 1 - z 0 - z 12 = 0 := by
      simpa [pcBranchConstraint, h18] using pcBranchConstraint_of_constraints h
    have hEq' : z 2 - z 1 - 1 - z 12 = 0 := by
      simpa [hWf] using hEq
    exact eq_of_sub_sub_sub_eq_zero hEq'
  constructor
  · intro h19
    have hEq : z 2 - z 1 - z 22 = 0 := by
      simpa [pcMemConstraint, h19] using pcMemConstraint_of_constraints h
    exact eq_of_sub_sub_eq_zero hEq
  · rintro ⟨hWf, h17, h18, h19⟩
    simp [wf] at hWf
    have hEq : z 2 - z 1 - z 0 = 0 := by
      simpa [pcDefaultConstraint, h17, h18, h19, hWf] using
        pcDefaultConstraint_of_constraints h
    have hEq' : z 2 - z 1 - 1 = 0 := by
      simpa [hWf] using hEq
    exact eq_of_sub_sub_eq_zero hEq'

theorem ramAddrRouting_forced
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  (z 19 = 1 → z 23 = z 6 + z 20) ∧
    (wf z ∧ z 19 = 0 → z 23 = 0) := by
  constructor
  · intro h19
    have hEq : z 23 - z 6 - z 20 = 0 := by
      simpa [ramAddrActiveConstraint, h19] using ramAddrActiveConstraint_of_constraints h
    exact eq_of_sub_sub_eq_zero hEq
  · rintro ⟨hWf, h19⟩
    simp [wf] at hWf
    have hEq : z 23 = 0 := by
      simpa [ramAddrInactiveConstraint, hWf, h19] using ramAddrInactiveConstraint_of_constraints h
    exact hEq

theorem chip8RowLocalSound_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  chip8RowLocalSound z := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro h13
    have hEq : z 5 - z 12 = 0 := by
      simpa [xLookupConstraint, h13] using xLookupConstraint_of_constraints h
    exact eq_of_sub_eq_zero hEq
  · intro h14
    have hEq : z 5 - z 11 = 0 := by
      simpa [xMemConstraint, h14] using xMemConstraint_of_constraints h
    exact eq_of_sub_eq_zero hEq
  · intro h15
    have hEq : z 5 - z 3 = 0 := by
      simpa [xPreserveConstraint, h15] using xPreserveConstraint_of_constraints h
    exact eq_of_sub_eq_zero hEq
  · exact (iRouting_forced h).1
  · exact (iRouting_forced h).2
  · exact (pcRouting_forced h).1
  · exact (pcRouting_forced h).2.1
  · exact (pcRouting_forced h).2.2.1
  · exact (pcRouting_forced h).2.2.2
  · exact (ramAddrRouting_forced h).1
  · exact (ramAddrRouting_forced h).2

@[simp] theorem wf_witnessForBehavior
  (behavior : BehaviorClass)
  (last pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  wf (witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord memValue
    lookupOutput xIdx yIdx) := by
  cases behavior <;> simp [wf, witnessForBehavior, mkWitness]

@[simp] theorem routingFlags_witnessForBehavior
  (behavior : BehaviorClass)
  (last pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  routingFlags (witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord
    memValue lookupOutput xIdx yIdx) =
    behaviorFlags (K := K) behavior := by
  cases behavior <;> rfl

theorem chip8RowLocalConstraints_witnessForBehavior
  (behavior : BehaviorClass)
  {last : K}
  (hLast : isBit last)
  (pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  chip8RowLocalConstraints
    (witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord memValue
      lookupOutput xIdx yIdx) := by
  constructor
  · cases behavior <;> simp [controlBitConstraints, witnessForBehavior, mkWitness, hLast]
  constructor
  · cases behavior <;> simp [xLanePartitionConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [xLookupConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [xMemConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [xPreserveConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [iRoutingConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [pcJumpConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [pcBranchConstraint, witnessForBehavior, mkWitness]
    ring
  constructor
  · cases behavior <;> simp [pcMemConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [pcDefaultConstraint, witnessForBehavior, mkWitness]
  constructor
  · cases behavior <;> simp [ramAddrActiveConstraint, witnessForBehavior, mkWitness]
  · cases behavior <;> simp [ramAddrInactiveConstraint, witnessForBehavior, mkWitness]

theorem rowWitness_exists_of_decodeImage
  (b : FlagTuple K)
  (hb : b ∈ decodeImage (K := K))
  {last : K}
  (hLast : isBit last)
  (pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  ∃ z : Witness K,
    wf z ∧
      chip8RowLocalConstraints z ∧
      routingFlags z = b ∧
      z 22 = last ∧
      z 1 = pc ∧
      z 3 = regX ∧
      z 4 = regY ∧
      z 6 = iReg ∧
      z 8 = kk ∧
      z 9 = nnnAddr ∧
      z 10 = nnnWord ∧
      z 11 = memValue ∧
      z 12 = lookupOutput ∧
      z 20 = xIdx ∧
      z 21 = yIdx ∧
      chip8RowLocalSound z := by
  rcases hb with ⟨behavior, rfl⟩
  refine ⟨witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord
    memValue lookupOutput xIdx yIdx, ?_⟩
  refine ⟨wf_witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord
    memValue lookupOutput xIdx yIdx, ?_⟩
  refine ⟨chip8RowLocalConstraints_witnessForBehavior (K := K) behavior hLast pc regX regY iReg kk
    nnnAddr nnnWord memValue lookupOutput xIdx yIdx, ?_⟩
  refine ⟨routingFlags_witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr
    nnnWord memValue lookupOutput xIdx yIdx, ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  refine ⟨by cases behavior <;> simp [witnessForBehavior, mkWitness], ?_⟩
  exact chip8RowLocalSound_of_constraints <|
    chip8RowLocalConstraints_witnessForBehavior (K := K) behavior hLast pc regX regY iReg kk
      nnnAddr nnnWord memValue lookupOutput xIdx yIdx

abbrev flags {K : Type*} [Field K] (z : Witness K) : FlagTuple K :=
  routingFlags z

abbrev chip8RoutingConstraints {K : Type*} [Field K] (z : Witness K) : Prop :=
  chip8RowLocalConstraints z

abbrev chip8RoutingSound {K : Type*} [Field K] (z : Witness K) : Prop :=
  chip8RowLocalSound z

theorem chip8RoutingSound_of_constraints
  {z : Witness K}
  (h : chip8RoutingConstraints z) :
  chip8RoutingSound z :=
  chip8RowLocalSound_of_constraints h

theorem chip8RoutingConstraints_witnessForBehavior
  (behavior : BehaviorClass)
  {last : K}
  (hLast : isBit last)
  (pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  chip8RoutingConstraints
    (witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord memValue
      lookupOutput xIdx yIdx) :=
  chip8RowLocalConstraints_witnessForBehavior (K := K) behavior hLast pc regX regY iReg kk
    nnnAddr nnnWord memValue lookupOutput xIdx yIdx

theorem flags_witnessForBehavior
  (behavior : BehaviorClass)
  (last pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  flags (witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord memValue
    lookupOutput xIdx yIdx) =
    behaviorFlags (K := K) behavior :=
  routingFlags_witnessForBehavior (K := K) behavior last pc regX regY iReg kk nnnAddr nnnWord
    memValue lookupOutput xIdx yIdx

theorem routingWitness_exists_of_decodeImage
  (b : FlagTuple K)
  (hb : b ∈ decodeImage (K := K))
  {last : K}
  (hLast : isBit last)
  (pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  ∃ z : Witness K,
    wf z ∧
      chip8RoutingConstraints z ∧
      flags z = b ∧
      z 22 = last ∧
      z 1 = pc ∧
      z 3 = regX ∧
      z 4 = regY ∧
      z 6 = iReg ∧
      z 8 = kk ∧
      z 9 = nnnAddr ∧
      z 10 = nnnWord ∧
      z 11 = memValue ∧
      z 12 = lookupOutput ∧
      z 20 = xIdx ∧
      z 21 = yIdx ∧
      chip8RoutingSound z :=
  rowWitness_exists_of_decodeImage (K := K) b hb hLast pc regX regY iReg kk nnnAddr nnnWord
    memValue lookupOutput xIdx yIdx

end Nightstream.Chip8
