import Mathlib

namespace Nightstream.Chip8

variable {K : Type*} [Field K]

abbrev Witness (K : Type*) := Fin 24 → K
abbrev ControlTuple (K : Type*) := K × K × K × K × K × K × K × K

structure RoutingFlags (K : Type*) where
  writesLookupToX : K
  writesMemToX : K
  preservesX : K
  writesNnnToI : K
  isJump : K
  isBranch : K
  isMemOp : K

@[simp] def colOne : Fin 24 := 0
@[simp] def colPc : Fin 24 := 1
@[simp] def colPcNext : Fin 24 := 2
@[simp] def colRegX : Fin 24 := 3
@[simp] def colRegY : Fin 24 := 4
@[simp] def colRegXNext : Fin 24 := 5
@[simp] def colIReg : Fin 24 := 6
@[simp] def colINext : Fin 24 := 7
@[simp] def colKk : Fin 24 := 8
@[simp] def colNnnAddr : Fin 24 := 9
@[simp] def colNnnWord : Fin 24 := 10
@[simp] def colMemValue : Fin 24 := 11
@[simp] def colLookupOutput : Fin 24 := 12
@[simp] def colWritesLookupToX : Fin 24 := 13
@[simp] def colWritesMemToX : Fin 24 := 14
@[simp] def colPreservesX : Fin 24 := 15
@[simp] def colWritesNnnToI : Fin 24 := 16
@[simp] def colIsJump : Fin 24 := 17
@[simp] def colIsBranch : Fin 24 := 18
@[simp] def colIsMemOp : Fin 24 := 19
@[simp] def colXIdx : Fin 24 := 20
@[simp] def colYIdx : Fin 24 := 21
@[simp] def colBurstLast : Fin 24 := 22
@[simp] def colRamAddr : Fin 24 := 23

@[simp] abbrev flagWritesLookupToX (t : RoutingFlags K) : K := t.writesLookupToX
@[simp] abbrev flagWritesMemToX (t : RoutingFlags K) : K := t.writesMemToX
@[simp] abbrev flagPreservesX (t : RoutingFlags K) : K := t.preservesX
@[simp] abbrev flagWritesNnnToI (t : RoutingFlags K) : K := t.writesNnnToI
@[simp] abbrev flagIsJump (t : RoutingFlags K) : K := t.isJump
@[simp] abbrev flagIsBranch (t : RoutingFlags K) : K := t.isBranch
@[simp] abbrev flagIsMemOp (t : RoutingFlags K) : K := t.isMemOp

def routingFlags (z : Witness K) : RoutingFlags K :=
  { writesLookupToX := z colWritesLookupToX
    writesMemToX := z colWritesMemToX
    preservesX := z colPreservesX
    writesNnnToI := z colWritesNnnToI
    isJump := z colIsJump
    isBranch := z colIsBranch
    isMemOp := z colIsMemOp }

def controlBits (z : Witness K) : ControlTuple K :=
  (z colWritesLookupToX, z colWritesMemToX, z colPreservesX, z colWritesNnnToI,
    z colIsJump, z colIsBranch, z colIsMemOp, z colBurstLast)

def wf (z : Witness K) : Prop :=
  z colOne = 1

def isBit (x : K) : Prop :=
  x * (x - 1) = 0

def controlBitConstraints (z : Witness K) : Prop :=
  isBit (z colWritesLookupToX) ∧
    isBit (z colWritesMemToX) ∧
    isBit (z colPreservesX) ∧
    isBit (z colWritesNnnToI) ∧
    isBit (z colIsJump) ∧
    isBit (z colIsBranch) ∧
    isBit (z colIsMemOp) ∧
    isBit (z colBurstLast)

def xLanePartitionConstraint (z : Witness K) : Prop :=
  z colWritesLookupToX + z colWritesMemToX + z colPreservesX = 1

def xLookupConstraint (z : Witness K) : Prop :=
  z colWritesLookupToX * (z colRegXNext - z colLookupOutput) = 0

def xMemConstraint (z : Witness K) : Prop :=
  z colWritesMemToX * (z colRegXNext - z colMemValue) = 0

def xPreserveConstraint (z : Witness K) : Prop :=
  z colPreservesX * (z colRegXNext - z colRegX) = 0

def iRoutingConstraint (z : Witness K) : Prop :=
  z colWritesNnnToI * (z colNnnAddr - z colIReg) = z colINext - z colIReg

def pcJumpConstraint (z : Witness K) : Prop :=
  z colIsJump * (z colPcNext - z colNnnWord) = 0

def pcBranchConstraint (z : Witness K) : Prop :=
  z colIsBranch * (z colPcNext - z colPc - z colOne - z colLookupOutput) = 0

def pcMemConstraint (z : Witness K) : Prop :=
  z colIsMemOp * (z colPcNext - z colPc - z colBurstLast) = 0

def pcDefaultConstraint (z : Witness K) : Prop :=
  (z colOne - z colIsJump - z colIsBranch - z colIsMemOp) *
      (z colPcNext - z colPc - z colOne) = 0

def ramAddrActiveConstraint (z : Witness K) : Prop :=
  z colIsMemOp * (z colRamAddr - z colIReg - z colXIdx) = 0

def ramAddrInactiveConstraint (z : Witness K) : Prop :=
  (z colOne - z colIsMemOp) * z colRamAddr = 0

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
  (z colWritesLookupToX = 1 → z colRegXNext = z colLookupOutput) ∧
    (z colWritesMemToX = 1 → z colRegXNext = z colMemValue) ∧
    (z colPreservesX = 1 → z colRegXNext = z colRegX) ∧
    (z colWritesNnnToI = 1 → z colINext = z colNnnAddr) ∧
    (z colWritesNnnToI = 0 → z colINext = z colIReg) ∧
    (z colIsJump = 1 → z colPcNext = z colNnnWord) ∧
    (wf z ∧ z colIsBranch = 1 → z colPcNext = z colPc + 1 + z colLookupOutput) ∧
    (z colIsMemOp = 1 → z colPcNext = z colPc + z colBurstLast) ∧
    (wf z ∧ z colIsJump = 0 ∧ z colIsBranch = 0 ∧ z colIsMemOp = 0 →
      z colPcNext = z colPc + 1) ∧
    (z colIsMemOp = 1 → z colRamAddr = z colIReg + z colXIdx) ∧
    (wf z ∧ z colIsMemOp = 0 → z colRamAddr = 0)

inductive BehaviorClass where
  | writesLookupToVx
  | skipEqImm
  | jump
  | writesNnnToI
  | storeRegs
  | loadRegs
deriving DecidableEq, Repr

def behaviorFlags : BehaviorClass → RoutingFlags K
  | .writesLookupToVx =>
      { writesLookupToX := 1
        writesMemToX := 0
        preservesX := 0
        writesNnnToI := 0
        isJump := 0
        isBranch := 0
        isMemOp := 0 }
  | .skipEqImm =>
      { writesLookupToX := 0
        writesMemToX := 0
        preservesX := 1
        writesNnnToI := 0
        isJump := 0
        isBranch := 1
        isMemOp := 0 }
  | .jump =>
      { writesLookupToX := 0
        writesMemToX := 0
        preservesX := 1
        writesNnnToI := 0
        isJump := 1
        isBranch := 0
        isMemOp := 0 }
  | .writesNnnToI =>
      { writesLookupToX := 0
        writesMemToX := 0
        preservesX := 1
        writesNnnToI := 1
        isJump := 0
        isBranch := 0
        isMemOp := 0 }
  | .storeRegs =>
      { writesLookupToX := 0
        writesMemToX := 0
        preservesX := 1
        writesNnnToI := 0
        isJump := 0
        isBranch := 0
        isMemOp := 1 }
  | .loadRegs =>
      { writesLookupToX := 0
        writesMemToX := 1
        preservesX := 0
        writesNnnToI := 0
        isJump := 0
        isBranch := 0
        isMemOp := 1 }

def decodeImage : Set (RoutingFlags K) :=
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
  (z colWritesLookupToX = 1 ∧ z colWritesMemToX = 0 ∧ z colPreservesX = 0) ∨
    (z colWritesLookupToX = 0 ∧ z colWritesMemToX = 1 ∧ z colPreservesX = 0) ∨
    (z colWritesLookupToX = 0 ∧ z colWritesMemToX = 0 ∧ z colPreservesX = 1) := by
  have hBits := controlBitConstraints_of_constraints h
  exact threeBitPartition_oneHot
    hBits.1
    hBits.2.1
    hBits.2.2.1
    (xLanePartitionConstraint_of_constraints h)

theorem iRouting_forced
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  (z colWritesNnnToI = 1 → z colINext = z colNnnAddr) ∧
    (z colWritesNnnToI = 0 → z colINext = z colIReg) := by
  constructor
  · intro hWriteI
    have hEq := iRoutingConstraint_of_constraints h
    rw [iRoutingConstraint] at hEq
    rw [hWriteI, one_mul] at hEq
    calc
      z colINext = (z colINext - z colIReg) + z colIReg := by ring
      _ = (z colNnnAddr - z colIReg) + z colIReg := by rw [← hEq]
      _ = z colNnnAddr := by ring
  · intro hWriteI
    have hEq := iRoutingConstraint_of_constraints h
    rw [iRoutingConstraint] at hEq
    rw [hWriteI, zero_mul] at hEq
    have hEq' : z colINext - z colIReg = 0 := by simpa using hEq.symm
    exact eq_of_sub_eq_zero hEq'

theorem pcRouting_forced
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  (z colIsJump = 1 → z colPcNext = z colNnnWord) ∧
    (wf z ∧ z colIsBranch = 1 → z colPcNext = z colPc + 1 + z colLookupOutput) ∧
    (z colIsMemOp = 1 → z colPcNext = z colPc + z colBurstLast) ∧
    (wf z ∧ z colIsJump = 0 ∧ z colIsBranch = 0 ∧ z colIsMemOp = 0 →
      z colPcNext = z colPc + 1) := by
  constructor
  · intro hJump
    have hEq := pcJumpConstraint_of_constraints h
    rw [pcJumpConstraint] at hEq
    rw [hJump, one_mul] at hEq
    exact eq_of_sub_eq_zero hEq
  constructor
  · rintro ⟨hWf, hBranch⟩
    simp [wf] at hWf
    have hEq := pcBranchConstraint_of_constraints h
    rw [pcBranchConstraint] at hEq
    rw [hBranch, one_mul] at hEq
    have hEq' : z colPcNext - z colPc - 1 - z colLookupOutput = 0 := by
      simpa [hWf] using hEq
    exact eq_of_sub_sub_sub_eq_zero hEq'
  constructor
  · intro hMemOp
    have hEq := pcMemConstraint_of_constraints h
    rw [pcMemConstraint] at hEq
    rw [hMemOp, one_mul] at hEq
    exact eq_of_sub_sub_eq_zero hEq
  · rintro ⟨hWf, hJump, hBranch, hMemOp⟩
    simp [wf] at hWf
    have hEq := pcDefaultConstraint_of_constraints h
    rw [pcDefaultConstraint] at hEq
    have hJump' : z 17 = 0 := by simpa [colIsJump] using hJump
    have hBranch' : z 18 = 0 := by simpa [colIsBranch] using hBranch
    have hMemOp' : z 19 = 0 := by simpa [colIsMemOp] using hMemOp
    have hCoeff : z colOne - z colIsJump - z colIsBranch - z colIsMemOp = 1 := by
      change z 0 - z 17 - z 18 - z 19 = 1
      rw [hWf, hJump', hBranch', hMemOp']
      ring
    rw [hCoeff, one_mul] at hEq
    have hEq' : z colPcNext - z colPc - 1 = 0 := by
      simpa [hWf] using hEq
    exact eq_of_sub_sub_eq_zero hEq'

theorem ramAddrRouting_forced
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  (z colIsMemOp = 1 → z colRamAddr = z colIReg + z colXIdx) ∧
    (wf z ∧ z colIsMemOp = 0 → z colRamAddr = 0) := by
  constructor
  · intro hMemOp
    have hEq := ramAddrActiveConstraint_of_constraints h
    rw [ramAddrActiveConstraint] at hEq
    rw [hMemOp, one_mul] at hEq
    exact eq_of_sub_sub_eq_zero hEq
  · rintro ⟨hWf, hMemOp⟩
    simp [wf] at hWf
    have hEq := ramAddrInactiveConstraint_of_constraints h
    rw [ramAddrInactiveConstraint] at hEq
    have hMemOp' : z 19 = 0 := by simpa [colIsMemOp] using hMemOp
    have hCoeff : z colOne - z colIsMemOp = 1 := by
      change z 0 - z 19 = 1
      rw [hWf, hMemOp']
      ring
    rw [hCoeff, one_mul] at hEq
    exact hEq

theorem chip8RowLocalSound_of_constraints
  {z : Witness K}
  (h : chip8RowLocalConstraints z) :
  chip8RowLocalSound z := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro h13
    have hEq := xLookupConstraint_of_constraints h
    rw [xLookupConstraint] at hEq
    rw [h13, one_mul] at hEq
    exact eq_of_sub_eq_zero hEq
  · intro h14
    have hEq := xMemConstraint_of_constraints h
    rw [xMemConstraint] at hEq
    rw [h14, one_mul] at hEq
    exact eq_of_sub_eq_zero hEq
  · intro h15
    have hEq := xPreserveConstraint_of_constraints h
    rw [xPreserveConstraint] at hEq
    rw [h15, one_mul] at hEq
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
  cases behavior <;> simp [routingFlags, witnessForBehavior, mkWitness, behaviorFlags]

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
  (b : RoutingFlags K)
  (hb : b ∈ decodeImage (K := K))
  {last : K}
  (hLast : isBit last)
  (pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  ∃ z : Witness K,
    wf z ∧
      chip8RowLocalConstraints z ∧
      routingFlags z = b ∧
      z colBurstLast = last ∧
      z colPc = pc ∧
      z colRegX = regX ∧
      z colRegY = regY ∧
      z colIReg = iReg ∧
      z colKk = kk ∧
      z colNnnAddr = nnnAddr ∧
      z colNnnWord = nnnWord ∧
      z colMemValue = memValue ∧
      z colLookupOutput = lookupOutput ∧
      z colXIdx = xIdx ∧
      z colYIdx = yIdx ∧
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

abbrev flags {K : Type*} [Field K] (z : Witness K) : RoutingFlags K :=
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
  (b : RoutingFlags K)
  (hb : b ∈ decodeImage (K := K))
  {last : K}
  (hLast : isBit last)
  (pc regX regY iReg kk nnnAddr nnnWord memValue lookupOutput xIdx yIdx : K) :
  ∃ z : Witness K,
    wf z ∧
      chip8RoutingConstraints z ∧
      flags z = b ∧
      z colBurstLast = last ∧
      z colPc = pc ∧
      z colRegX = regX ∧
      z colRegY = regY ∧
      z colIReg = iReg ∧
      z colKk = kk ∧
      z colNnnAddr = nnnAddr ∧
      z colNnnWord = nnnWord ∧
      z colMemValue = memValue ∧
      z colLookupOutput = lookupOutput ∧
      z colXIdx = xIdx ∧
      z colYIdx = yIdx ∧
      chip8RoutingSound z :=
  rowWitness_exists_of_decodeImage (K := K) b hb hLast pc regX regY iReg kk nnnAddr nnnWord
    memValue lookupOutput xIdx yIdx

end Nightstream.Chip8
