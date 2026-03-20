import Mathlib

namespace Nightstream.Chip8

inductive BaseFamily (CoreIndex AuxIndex : Type*) where
  | coreCol : CoreIndex → BaseFamily CoreIndex AuxIndex
  | auxCol : AuxIndex → BaseFamily CoreIndex AuxIndex
deriving DecidableEq, Repr

inductive ClaimKind (CoreIndex AuxIndex : Type*) where
  | direct : BaseFamily CoreIndex AuxIndex → ClaimKind CoreIndex AuxIndex
  | shoutRead
  | twistRead
  | twistWrite
  | twistVal
deriving DecidableEq, Repr

inductive ClaimPoint (EvalPoint AddressPoint CyclePoint : Type*) where
  | eval : EvalPoint → ClaimPoint EvalPoint AddressPoint CyclePoint
  | paired : AddressPoint → CyclePoint → ClaimPoint EvalPoint AddressPoint CyclePoint
deriving DecidableEq, Repr

structure Claim
  (CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value : Type*) where
  kind : ClaimKind CoreIndex AuxIndex
  point : ClaimPoint EvalPoint AddressPoint CyclePoint
  value : Value
deriving DecidableEq, Repr

section OpeningBoundary

variable
  {CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value : Type*}
  {AddressColumns Address Table ValSurface ReadValue WriteValue Increment : Type*}

def KernelAddressBound
  (kernelAddressBound : Address → Prop)
  (addr : Address) : Prop :=
  kernelAddressBound addr

def DirectClaim
  (evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value)
  (B : Set (BaseFamily CoreIndex AuxIndex))
  (c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value) : Prop :=
  ∃ b p,
    c.kind = .direct b ∧
      c.point = .eval p ∧
      b ∈ B ∧
      c.value = evalBase b p

def ShoutCheckedClaim
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → Value)
  (readOnlyMemoryRelation : Table → Address → ReadValue → Prop)
  (c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value) : Prop :=
  ∃ table ra addr rv p,
    c.kind = .shoutRead ∧
      c.point = .eval p ∧
      c.value = readCheckExpression ra table p ∧
      validAddressColumns ra addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      readOnlyMemoryRelation table addr rv

def TwistReadCheckedClaim
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value)
  (readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop)
  (c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value) : Prop :=
  ∃ val ra addr rv p,
    c.kind = .twistRead ∧
      c.point = .eval p ∧
      c.value = rwReadCheckExpression ra val p ∧
      validAddressColumns ra addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      readWriteMemoryRelation val addr rv

def TwistWriteCheckedClaim
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value)
  (incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop)
  (c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value) : Prop :=
  ∃ val wa addr wv inc qa qc,
    c.kind = .twistWrite ∧
      c.point = .paired qa qc ∧
      c.value = writeCheckExpression qa qc wa wv val ∧
      validAddressColumns wa addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      incrementRelation val wa wv inc

def TwistValCheckedClaim
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value)
  (incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop)
  (c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value) : Prop :=
  ∃ val wa addr wv inc qa qc,
    c.kind = .twistVal ∧
      c.point = .paired qa qc ∧
      c.value = valEvaluationExpression inc qa qc ∧
      validAddressColumns wa addr ∧
      KernelAddressBound kernelAddressBound addr ∧
      incrementRelation val wa wv inc

def AuthenticatedClaim
  (evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value)
  (B : Set (BaseFamily CoreIndex AuxIndex))
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → Value)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value)
  (readOnlyMemoryRelation : Table → Address → ReadValue → Prop)
  (readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop)
  (incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop)
  (c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value) : Prop :=
  DirectClaim evalBase B c ∨
    ShoutCheckedClaim validAddressColumns kernelAddressBound readCheckExpression
      readOnlyMemoryRelation c ∨
    TwistReadCheckedClaim validAddressColumns kernelAddressBound rwReadCheckExpression
      readWriteMemoryRelation c ∨
    TwistWriteCheckedClaim validAddressColumns kernelAddressBound writeCheckExpression
      incrementRelation c ∨
    TwistValCheckedClaim validAddressColumns kernelAddressBound valEvaluationExpression
      incrementRelation c

def OrphanClaim
  (evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value)
  (B : Set (BaseFamily CoreIndex AuxIndex))
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → Value)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value)
  (readOnlyMemoryRelation : Table → Address → ReadValue → Prop)
  (readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop)
  (incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop)
  (c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value) : Prop :=
  ¬ AuthenticatedClaim evalBase B validAddressColumns kernelAddressBound readCheckExpression
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readOnlyMemoryRelation readWriteMemoryRelation incrementRelation c

def Stage1Boundary
  (evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value)
  (B : Set (BaseFamily CoreIndex AuxIndex))
  (Γ₁ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)) : Prop :=
  ∀ c, c ∈ Γ₁ → DirectClaim evalBase B c

def Stage2Boundary
  (evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value)
  (B : Set (BaseFamily CoreIndex AuxIndex))
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → Value)
  (readOnlyMemoryRelation : Table → Address → ReadValue → Prop)
  (Γ₂ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)) : Prop :=
  ∀ c, c ∈ Γ₂ →
    DirectClaim evalBase B c ∨
      ShoutCheckedClaim validAddressColumns kernelAddressBound readCheckExpression
        readOnlyMemoryRelation c

def Stage3Boundary
  (evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value)
  (B : Set (BaseFamily CoreIndex AuxIndex))
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value)
  (readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop)
  (incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop)
  (Γ₃ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)) : Prop :=
  ∀ c, c ∈ Γ₃ →
    DirectClaim evalBase B c ∨
      TwistReadCheckedClaim validAddressColumns kernelAddressBound rwReadCheckExpression
        readWriteMemoryRelation c ∨
      TwistWriteCheckedClaim validAddressColumns kernelAddressBound writeCheckExpression
        incrementRelation c ∨
      TwistValCheckedClaim validAddressColumns kernelAddressBound valEvaluationExpression
        incrementRelation c

def KernelOpeningBoundary
  (evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value)
  (B : Set (BaseFamily CoreIndex AuxIndex))
  (validAddressColumns : AddressColumns → Address → Prop)
  (kernelAddressBound : Address → Prop)
  (readCheckExpression : AddressColumns → Table → EvalPoint → Value)
  (rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value)
  (writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value)
  (valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value)
  (readOnlyMemoryRelation : Table → Address → ReadValue → Prop)
  (readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop)
  (incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop)
  (Γ₁ Γ₂ Γ₃ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)) : Prop :=
  Stage1Boundary evalBase B Γ₁ ∧
    Stage2Boundary evalBase B validAddressColumns kernelAddressBound readCheckExpression
      readOnlyMemoryRelation Γ₂ ∧
    Stage3Boundary evalBase B validAddressColumns kernelAddressBound rwReadCheckExpression
      writeCheckExpression valEvaluationExpression readWriteMemoryRelation
      incrementRelation Γ₃

theorem shoutCheckedClaim_requires_kernelAddressBound
  {validAddressColumns : AddressColumns → Address → Prop}
  {kernelAddressBound : Address → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → Value}
  {readOnlyMemoryRelation : Table → Address → ReadValue → Prop}
  {c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value}
  (h : ShoutCheckedClaim validAddressColumns kernelAddressBound readCheckExpression
    readOnlyMemoryRelation c) :
  ∃ addr, KernelAddressBound kernelAddressBound addr := by
  rcases h with ⟨_, _, addr, _, _, _, _, _, _, hBound, _⟩
  exact ⟨addr, hBound⟩

theorem twistCheckedClaim_requires_kernelAddressBound
  {validAddressColumns : AddressColumns → Address → Prop}
  {kernelAddressBound : Address → Prop}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value}
  {readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop}
  {incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop}
  {c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value}
  (h :
    TwistReadCheckedClaim validAddressColumns kernelAddressBound rwReadCheckExpression
      readWriteMemoryRelation c ∨
      TwistWriteCheckedClaim validAddressColumns kernelAddressBound writeCheckExpression
        incrementRelation c ∨
      TwistValCheckedClaim validAddressColumns kernelAddressBound valEvaluationExpression
        incrementRelation c) :
  ∃ addr, KernelAddressBound kernelAddressBound addr := by
  rcases h with hRead | hWriteOrVal
  · rcases hRead with ⟨_, _, addr, _, _, _, _, _, _, hBound, _⟩
    exact ⟨addr, hBound⟩
  · rcases hWriteOrVal with hWrite | hVal
    · rcases hWrite with ⟨_, _, addr, _, _, _, _, _, _, _, _, hBound, _⟩
      exact ⟨addr, hBound⟩
    · rcases hVal with ⟨_, _, addr, _, _, _, _, _, _, _, _, hBound, _⟩
      exact ⟨addr, hBound⟩

theorem stage1Boundary_no_orphan_claims
  {evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value}
  {B : Set (BaseFamily CoreIndex AuxIndex)}
  {validAddressColumns : AddressColumns → Address → Prop}
  {kernelAddressBound : Address → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → Value}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value}
  {readOnlyMemoryRelation : Table → Address → ReadValue → Prop}
  {readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop}
  {incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop}
  {Γ₁ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)}
  {c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value}
  (hStage : Stage1Boundary evalBase B Γ₁)
  (hc : c ∈ Γ₁) :
  ¬ OrphanClaim evalBase B validAddressColumns kernelAddressBound readCheckExpression
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readOnlyMemoryRelation readWriteMemoryRelation incrementRelation c := by
  intro hOrphan
  exact hOrphan (Or.inl (hStage c hc))

theorem stage2Boundary_no_orphan_claims
  {evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value}
  {B : Set (BaseFamily CoreIndex AuxIndex)}
  {validAddressColumns : AddressColumns → Address → Prop}
  {kernelAddressBound : Address → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → Value}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value}
  {readOnlyMemoryRelation : Table → Address → ReadValue → Prop}
  {readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop}
  {incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop}
  {Γ₂ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)}
  {c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value}
  (hStage : Stage2Boundary evalBase B validAddressColumns kernelAddressBound
    readCheckExpression readOnlyMemoryRelation Γ₂)
  (hc : c ∈ Γ₂) :
  ¬ OrphanClaim evalBase B validAddressColumns kernelAddressBound readCheckExpression
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readOnlyMemoryRelation readWriteMemoryRelation incrementRelation c := by
  intro hOrphan
  rcases hStage c hc with hDirect | hShout
  · exact hOrphan (Or.inl hDirect)
  · exact hOrphan (Or.inr (Or.inl hShout))

theorem stage3Boundary_no_orphan_claims
  {evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value}
  {B : Set (BaseFamily CoreIndex AuxIndex)}
  {validAddressColumns : AddressColumns → Address → Prop}
  {kernelAddressBound : Address → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → Value}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value}
  {readOnlyMemoryRelation : Table → Address → ReadValue → Prop}
  {readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop}
  {incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop}
  {Γ₃ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)}
  {c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value}
  (hStage : Stage3Boundary evalBase B validAddressColumns kernelAddressBound
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readWriteMemoryRelation incrementRelation Γ₃)
  (hc : c ∈ Γ₃) :
  ¬ OrphanClaim evalBase B validAddressColumns kernelAddressBound readCheckExpression
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readOnlyMemoryRelation readWriteMemoryRelation incrementRelation c := by
  intro hOrphan
  rcases hStage c hc with hDirect | hRead | hWrite | hVal
  · exact hOrphan (Or.inl hDirect)
  · exact hOrphan (Or.inr (Or.inr (Or.inl hRead)))
  · exact hOrphan (Or.inr (Or.inr (Or.inr (Or.inl hWrite))))
  · exact hOrphan (Or.inr (Or.inr (Or.inr (Or.inr hVal))))

theorem kernelOpeningBoundary_no_orphan_claims
  {evalBase : BaseFamily CoreIndex AuxIndex → EvalPoint → Value}
  {B : Set (BaseFamily CoreIndex AuxIndex)}
  {validAddressColumns : AddressColumns → Address → Prop}
  {kernelAddressBound : Address → Prop}
  {readCheckExpression : AddressColumns → Table → EvalPoint → Value}
  {rwReadCheckExpression : AddressColumns → ValSurface → EvalPoint → Value}
  {writeCheckExpression : AddressPoint → CyclePoint → AddressColumns → WriteValue → ValSurface → Value}
  {valEvaluationExpression : Increment → AddressPoint → CyclePoint → Value}
  {readOnlyMemoryRelation : Table → Address → ReadValue → Prop}
  {readWriteMemoryRelation : ValSurface → Address → ReadValue → Prop}
  {incrementRelation : ValSurface → AddressColumns → WriteValue → Increment → Prop}
  {Γ₁ Γ₂ Γ₃ : List (Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value)}
  {c : Claim CoreIndex AuxIndex EvalPoint AddressPoint CyclePoint Value}
  (hBoundary : KernelOpeningBoundary evalBase B validAddressColumns kernelAddressBound
    readCheckExpression rwReadCheckExpression writeCheckExpression
    valEvaluationExpression readOnlyMemoryRelation readWriteMemoryRelation
    incrementRelation Γ₁ Γ₂ Γ₃)
  (hc : c ∈ Γ₁ ∨ c ∈ Γ₂ ∨ c ∈ Γ₃) :
  ¬ OrphanClaim evalBase B validAddressColumns kernelAddressBound readCheckExpression
    rwReadCheckExpression writeCheckExpression valEvaluationExpression
    readOnlyMemoryRelation readWriteMemoryRelation incrementRelation c := by
  rcases hBoundary with ⟨hStage1, hStage2, hStage3⟩
  rcases hc with hc1 | hc23
  · exact stage1Boundary_no_orphan_claims (c := c) hStage1 hc1
  · rcases hc23 with hc2 | hc3
    · exact stage2Boundary_no_orphan_claims (c := c) hStage2 hc2
    · exact stage3Boundary_no_orphan_claims (c := c) hStage3 hc3

end OpeningBoundary

namespace ExactOpeningBoundary

inductive OpeningSource where
  | kernel
  | root
deriving DecidableEq, Repr

inductive CommitmentId where
  | lane
  | fetchRa
  | decodeRa
  | aluRa
  | eq4Ra
  | decodeHandoff
  | regTwist
  | ramTwist
  | romTable
  | decodeTable
  | aluTable
  | eq4Table
  | rootProver (tag : Nat)
deriving DecidableEq, Repr

inductive LaneColumn where
  | pc
  | pcNext
  | regX
  | regY
  | regXNext
  | iReg
  | iNext
  | kk
  | nnnAddr
  | nnnWord
  | memValue
  | lookupOutput
  | writesLookupToX
  | writesMemToX
  | preservesX
  | writesNnnToI
  | isJump
  | isBranch
  | isMemOp
  | xIdx
  | yIdx
  | burstLast
  | ramAddr
deriving DecidableEq, Repr

def laneColumnPolynomialId : LaneColumn → Nat
  | .pc => 1
  | .pcNext => 2
  | .regX => 3
  | .regY => 4
  | .regXNext => 5
  | .iReg => 6
  | .iNext => 7
  | .kk => 8
  | .nnnAddr => 9
  | .nnnWord => 10
  | .memValue => 11
  | .lookupOutput => 12
  | .writesLookupToX => 13
  | .writesMemToX => 14
  | .preservesX => 15
  | .writesNnnToI => 16
  | .isJump => 17
  | .isBranch => 18
  | .isMemOp => 19
  | .xIdx => 20
  | .yIdx => 21
  | .burstLast => 22
  | .ramAddr => 23

def laneLookupPolynomialIds : List Nat :=
  [1, 3, 4, 8, 9, 10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]

def laneTwistPolynomialIds : List Nat :=
  [3, 4, 5, 6, 7, 11, 13, 14, 15, 16, 19, 20, 21, 23]

def laneShiftPolynomialIds : List Nat := [1, 2, 19, 20, 22]
def laneStartPolynomialIds : List Nat := [19, 20]
def laneFinalPolynomialIds : List Nat := [19, 22]
def laneRowBindingPolynomialIds : List Nat := (List.range 23).map (· + 1)

def decodeHandoffPolynomialIds : List Nat := [0, 1, 2]
def regTwistPolynomialIds : List Nat := [0, 1, 2, 3, 4]
def ramTwistPolynomialIds : List Nat := [0, 1, 2]
def singletonPolynomialIds : List Nat := [0]
def decodeTablePolynomialIds : List Nat := List.range 22

structure OpeningClaim (Value Digest : Type*) where
  source : OpeningSource
  commitmentId : CommitmentId
  point : List Nat
  polynomialIds : List Nat
  claimedValues : List Value
  digest : Digest
deriving DecidableEq, Repr

abbrev KernelOpeningManifest (Value Digest : Type*) := List (OpeningClaim Value Digest)
abbrev RootOpeningManifest (Value Digest : Type*) := List (OpeningClaim Value Digest)

structure KernelPoints where
  rLookup : List Nat
  rFetchRa : List Nat
  rDecodeRa : List Nat
  rAluRa : List Nat
  rEq4Ra : List Nat
  rDecodeHandoffLookup : List Nat
  rRomTable : List Nat
  rDecodeTable : List Nat
  rAluTable : List Nat
  rEq4Table : List Nat
  rTwistCycle : List Nat
  rDecodeHandoffTwist : List Nat
  rRegTwist : List Nat
  rRamTwist : List Nat
  rShift : List Nat
  j0Bits : List Nat
  jLastBits : List Nat
  exportedRows : Nat
  jBits : Fin exportedRows → List Nat

structure LaneShiftProof (Value Digest : Type*) where
  sourceCommitment : CommitmentId
  sourcePoint : List Nat
  sourceColumns : List LaneColumn
  claimedShiftValues : List Value
  digest : Digest
deriving Repr

def commitmentIdOrder : CommitmentId → Nat
  | .lane => 0
  | .fetchRa => 1
  | .decodeRa => 2
  | .aluRa => 3
  | .eq4Ra => 4
  | .decodeHandoff => 5
  | .regTwist => 6
  | .ramTwist => 7
  | .romTable => 8
  | .decodeTable => 9
  | .aluTable => 10
  | .eq4Table => 11
  | .rootProver _ => 12

def isKernelCommitment : CommitmentId → Prop
  | .rootProver _ => False
  | _ => True

def isRootCommitment : CommitmentId → Prop
  | .rootProver _ => True
  | _ => False

def strictlyIncreasing : List Nat → Prop
  | [] => True
  | [_] => True
  | x :: y :: rest => x < y ∧ strictlyIncreasing (y :: rest)

def lexNatList : List Nat → List Nat → Prop
  | [], [] => False
  | [], _ :: _ => True
  | _ :: _, [] => False
  | x :: xs, y :: ys => x < y ∨ (x = y ∧ lexNatList xs ys)

def openingClaimLt {Value Digest : Type*}
  (a b : OpeningClaim Value Digest) : Prop :=
  commitmentIdOrder a.commitmentId < commitmentIdOrder b.commitmentId ∨
    (commitmentIdOrder a.commitmentId = commitmentIdOrder b.commitmentId ∧
      (a.point.length < b.point.length ∨
        (a.point.length = b.point.length ∧
          (lexNatList a.point b.point ∨
            (a.point = b.point ∧ lexNatList a.polynomialIds b.polynomialIds)))))

def hasManifestClaim {Value Digest : Type*}
  (manifest : List (OpeningClaim Value Digest))
  (source : OpeningSource)
  (commitmentId : CommitmentId)
  (point : List Nat)
  (polynomialIds : List Nat) : Prop :=
  ∃ claim ∈ manifest,
    claim.source = source ∧
      claim.commitmentId = commitmentId ∧
      claim.point = point ∧
      claim.polynomialIds = polynomialIds

def kernelClaimAllowed {Value Digest : Type*}
  (pts : KernelPoints)
  (claim : OpeningClaim Value Digest) : Prop :=
  match claim.commitmentId with
  | .lane =>
      (claim.point = pts.rLookup ∧ claim.polynomialIds = laneLookupPolynomialIds) ∨
        (claim.point = pts.rTwistCycle ∧ claim.polynomialIds = laneTwistPolynomialIds) ∨
        (claim.point = pts.rShift ∧ claim.polynomialIds = laneShiftPolynomialIds) ∨
        (claim.point = pts.j0Bits ∧ claim.polynomialIds = laneStartPolynomialIds) ∨
        (claim.point = pts.jLastBits ∧ claim.polynomialIds = laneFinalPolynomialIds) ∨
        ∃ j : Fin pts.exportedRows,
          claim.point = pts.jBits j ∧
            claim.polynomialIds = laneRowBindingPolynomialIds
  | .fetchRa =>
      claim.point = pts.rFetchRa ∧ claim.polynomialIds = singletonPolynomialIds
  | .decodeRa =>
      claim.point = pts.rDecodeRa ∧ claim.polynomialIds = singletonPolynomialIds
  | .aluRa =>
      claim.point = pts.rAluRa ∧ claim.polynomialIds = singletonPolynomialIds
  | .eq4Ra =>
      claim.point = pts.rEq4Ra ∧ claim.polynomialIds = singletonPolynomialIds
  | .decodeHandoff =>
      (claim.point = pts.rDecodeHandoffLookup ∧ claim.polynomialIds = decodeHandoffPolynomialIds) ∨
        (claim.point = pts.rDecodeHandoffTwist ∧ claim.polynomialIds = decodeHandoffPolynomialIds)
  | .regTwist =>
      claim.point = pts.rRegTwist ∧ claim.polynomialIds = regTwistPolynomialIds
  | .ramTwist =>
      claim.point = pts.rRamTwist ∧ claim.polynomialIds = ramTwistPolynomialIds
  | .romTable =>
      claim.point = pts.rRomTable ∧ claim.polynomialIds = singletonPolynomialIds
  | .decodeTable =>
      claim.point = pts.rDecodeTable ∧ claim.polynomialIds = decodeTablePolynomialIds
  | .aluTable =>
      claim.point = pts.rAluTable ∧ claim.polynomialIds = singletonPolynomialIds
  | .eq4Table =>
      claim.point = pts.rEq4Table ∧ claim.polynomialIds = singletonPolynomialIds
  | .rootProver _ => False

def rootClaimAllowed {Value Digest : Type*} (claim : OpeningClaim Value Digest) : Prop :=
  claim.source = .root ∧ isRootCommitment claim.commitmentId

def KernelManifestShape {Value Digest : Type*}
  (pts : KernelPoints)
  (manifest : KernelOpeningManifest Value Digest) : Prop :=
  (∀ claim ∈ manifest,
    claim.source = .kernel ∧
      isKernelCommitment claim.commitmentId ∧
      kernelClaimAllowed pts claim) ∧
    hasManifestClaim manifest .kernel .lane pts.rLookup laneLookupPolynomialIds ∧
    hasManifestClaim manifest .kernel .fetchRa pts.rFetchRa singletonPolynomialIds ∧
    hasManifestClaim manifest .kernel .decodeRa pts.rDecodeRa singletonPolynomialIds ∧
    hasManifestClaim manifest .kernel .aluRa pts.rAluRa singletonPolynomialIds ∧
    hasManifestClaim manifest .kernel .eq4Ra pts.rEq4Ra singletonPolynomialIds ∧
    hasManifestClaim manifest .kernel .decodeHandoff pts.rDecodeHandoffLookup
      decodeHandoffPolynomialIds ∧
    hasManifestClaim manifest .kernel .romTable pts.rRomTable singletonPolynomialIds ∧
    hasManifestClaim manifest .kernel .decodeTable pts.rDecodeTable decodeTablePolynomialIds ∧
    hasManifestClaim manifest .kernel .aluTable pts.rAluTable singletonPolynomialIds ∧
    hasManifestClaim manifest .kernel .eq4Table pts.rEq4Table singletonPolynomialIds ∧
    hasManifestClaim manifest .kernel .lane pts.rTwistCycle laneTwistPolynomialIds ∧
    hasManifestClaim manifest .kernel .decodeHandoff pts.rDecodeHandoffTwist
      decodeHandoffPolynomialIds ∧
    hasManifestClaim manifest .kernel .regTwist pts.rRegTwist regTwistPolynomialIds ∧
    hasManifestClaim manifest .kernel .ramTwist pts.rRamTwist ramTwistPolynomialIds ∧
    hasManifestClaim manifest .kernel .lane pts.rShift laneShiftPolynomialIds ∧
    hasManifestClaim manifest .kernel .lane pts.j0Bits laneStartPolynomialIds ∧
    hasManifestClaim manifest .kernel .lane pts.jLastBits laneFinalPolynomialIds ∧
    (∀ j : Fin pts.exportedRows,
      hasManifestClaim manifest .kernel .lane (pts.jBits j) laneRowBindingPolynomialIds)

def RootManifestShape {Value Digest : Type*}
  (manifest : RootOpeningManifest Value Digest) : Prop :=
  ∀ claim ∈ manifest, rootClaimAllowed claim

def RootManifestEmpty {Value Digest : Type*}
  (manifest : RootOpeningManifest Value Digest) : Prop :=
  manifest = []

def SimpleBoundaryGlobalFoldPlanAbsent {FoldPlan : Type*}
  (globalPlan : Option FoldPlan) : Prop :=
  globalPlan = none

def CanonicalManifestOrder {Value Digest : Type*}
  (manifest : List (OpeningClaim Value Digest)) : Prop :=
  (∀ claim ∈ manifest, strictlyIncreasing claim.polynomialIds) ∧
    manifest.Pairwise openingClaimLt

def ExactKernelOpeningBoundary {Value Digest : Type*}
  (pts : KernelPoints)
  (kernelManifest : KernelOpeningManifest Value Digest)
  (rootManifest : RootOpeningManifest Value Digest) : Prop :=
  KernelManifestShape pts kernelManifest ∧
    RootManifestShape rootManifest ∧
    RootManifestEmpty rootManifest ∧
    CanonicalManifestOrder kernelManifest ∧
    CanonicalManifestOrder rootManifest

def LaneShiftAppearsInManifest {Value Digest : Type*}
  (_proof : LaneShiftProof Value Digest)
  (_manifest : KernelOpeningManifest Value Digest) : Prop :=
  False

def LaneShiftSourceOpeningAppearsInManifest {Value Digest : Type*}
  (pts : KernelPoints)
  (manifest : KernelOpeningManifest Value Digest) : Prop :=
  hasManifestClaim manifest .kernel .lane pts.rShift laneShiftPolynomialIds

theorem kernel_root_commitment_contra
  (cid : CommitmentId)
  (hKernel : isKernelCommitment cid)
  (hRoot : isRootCommitment cid) : False := by
  cases cid <;> simp [isKernelCommitment, isRootCommitment] at hKernel hRoot

theorem laneShift_not_openingClaim
  {Value Digest : Type*}
  (proof : LaneShiftProof Value Digest)
  (manifest : KernelOpeningManifest Value Digest) :
  ¬ LaneShiftAppearsInManifest proof manifest := by
  simp [LaneShiftAppearsInManifest]

theorem laneShiftSourceOpeningAppears_of_kernelManifestShape
  {Value Digest : Type*}
  {pts : KernelPoints}
  {manifest : KernelOpeningManifest Value Digest}
  (h : KernelManifestShape pts manifest) :
  LaneShiftSourceOpeningAppearsInManifest pts manifest := by
  rcases h with
    ⟨_, _hLookup, _hFetch, _hDecode, _hAlu, _hEq4, _hDecodeLookup,
      _hRom, _hDecodeTable, _hAluTable, _hEq4Table, _hTwistCycle,
      _hDecodeTwist, _hRegTwist, _hRamTwist, hShift, _hStart, _hFinal,
      _hRows⟩
  exact hShift

theorem laneShiftSourceOpeningAppears_of_exactKernelOpeningBoundary
  {Value Digest : Type*}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  (h : ExactKernelOpeningBoundary pts kernelManifest rootManifest) :
  LaneShiftSourceOpeningAppearsInManifest pts kernelManifest := by
  exact laneShiftSourceOpeningAppears_of_kernelManifestShape h.1

theorem exact_kernelOpeningBoundary_conforms
  {Value Digest : Type*}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  (h : ExactKernelOpeningBoundary pts kernelManifest rootManifest) :
  (∀ claim ∈ kernelManifest,
    claim.source = .kernel ∧
      isKernelCommitment claim.commitmentId ∧
      kernelClaimAllowed pts claim) ∧
    (∀ claim ∈ rootManifest,
      claim.source = .root ∧
        isRootCommitment claim.commitmentId) := by
  rcases h with ⟨hKernel, hRoot, _, _, _⟩
  refine ⟨?_, ?_⟩
  · intro claim hMem
    exact hKernel.1 claim hMem
  · intro claim hMem
    exact hRoot claim hMem

theorem rootManifestEmpty_of_exactKernelOpeningBoundary
  {Value Digest : Type*}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  (h : ExactKernelOpeningBoundary pts kernelManifest rootManifest) :
  RootManifestEmpty rootManifest := by
  exact h.2.2.1

theorem exact_kernel_root_commitments_disjoint
  {Value Digest : Type*}
  {pts : KernelPoints}
  {kernelManifest : KernelOpeningManifest Value Digest}
  {rootManifest : RootOpeningManifest Value Digest}
  (h : ExactKernelOpeningBoundary pts kernelManifest rootManifest) :
  ∀ {kernelClaim rootClaim},
    kernelClaim ∈ kernelManifest →
      rootClaim ∈ rootManifest →
      kernelClaim.commitmentId ≠ rootClaim.commitmentId := by
  intro kernelClaim rootClaim hKernelMem hRootMem
  rcases exact_kernelOpeningBoundary_conforms h with ⟨hKernel, hRoot⟩
  rcases hKernel kernelClaim hKernelMem with ⟨_, hKernelCommitment, _⟩
  rcases hRoot rootClaim hRootMem with ⟨_, hRootCommitment⟩
  intro hEq
  rw [hEq] at hKernelCommitment
  exact kernel_root_commitment_contra rootClaim.commitmentId
    hKernelCommitment hRootCommitment

end ExactOpeningBoundary

end Nightstream.Chip8
