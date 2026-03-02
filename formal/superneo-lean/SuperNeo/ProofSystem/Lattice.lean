import SuperNeo.Ring
import SuperNeo.Norm
import SuperNeo.ProofSystem.Negligible
import SuperNeo.ProofSystem.Security

namespace SuperNeo.ProofSystem

/-!
Lattice-security boundary surfaces.

This module is theorem-facing and remains reduction-interface level.
It now makes Ajtai opening/collision and MSIS witness surfaces definition-complete.

What is intentionally still missing (for full paper-faithful closure):

1. Advantage-level reduction proofs:
   - We derive Prop-level implications (`collision -> MSIS break`, hardness -> no break),
     but the probability-bound translation for Ajtai games is still boundary-assumed.

2. Concrete probabilistic games:
   - Replace abstract `breakAt : Nat -> Prop` shells with sampled game semantics
     (challenger/adversary interaction and event probabilities).

3. Discharge boundary axioms:
   - Core subtraction/linearity and norm helper surfaces used by extractors are
     still axiomatized here and should be proved from the Ring/Norm layers.

4. Boundary consistency hardening:
   - Boundary packages are canonicalized by deriving hardness from aligned
     `(eps, bound, negligible)` fields; constructor privacy can be tightened later.

5. Parameter side-conditions:
   - Side-condition bundles exist (`AjtaiParams.SideConditions` / `Nontrivial`),
     but only the required subset is threaded through current reduction theorems.
-/

/-- Public parameter bundle for lattice assumptions used by protocol theorems. -/
structure AjtaiParams where
  ringDim : Nat
  messageLength : Nat
  bindingNormBound : Nat
  relaxedExpansion : Nat

/-- Alias used as κ (rows/output dimension). -/
def AjtaiParams.kappa (params : AjtaiParams) : Nat := params.ringDim

/-- Alias used as m (witness/message length). -/
def AjtaiParams.msgLen (params : AjtaiParams) : Nat := params.messageLength

/-- Flattened matrix length for a κ×m Ajtai matrix. -/
def AjtaiParams.matrixFlatLen (params : AjtaiParams) : Nat :=
  params.kappa * params.msgLen

/-- Commitment vector length κ. -/
def AjtaiParams.commitmentLen (params : AjtaiParams) : Nat :=
  params.kappa

/-- Payload length for `(M || c)` encoding. -/
def AjtaiParams.payloadLen (params : AjtaiParams) : Nat :=
  params.matrixFlatLen + params.commitmentLen

/-- Derived MSIS norm-bound surface used by this theorem-facing layer. -/
def AjtaiParams.msisNormBound (params : AjtaiParams) : Nat :=
  8 * params.relaxedExpansion * params.bindingNormBound

/-- Theorem-facing lattice parameter side-conditions (paper-style preconditions). -/
def AjtaiParams.SideConditions (params : AjtaiParams) : Prop :=
  0 < params.ringDim ∧
  0 < params.messageLength ∧
  0 < params.bindingNormBound ∧
  0 < params.relaxedExpansion

/-- Abstract commitment object used by theorem-level interfaces. -/
structure Commitment where
  payload : Array Coeffs

/-- Abstract opening object used by theorem-level interfaces. -/
structure Opening where
  witness : Array Coeffs
  normBound : Nat

/-! ### Deterministic norm and Ajtai equations -/

/-- `ℓ∞` norm on vectors of ring elements, using max coefficient norm. -/
def normInfVec (v : Array Coeffs) : Nat :=
  v.foldl (fun acc x => Nat.max acc (normInfCoeffs x)) 0

/-- Ring-vector dot product, truncating to the shorter side if sizes differ. -/
def dotRq (xs ys : Array Coeffs) : Coeffs :=
  let rec go (xs ys : List Coeffs) (acc : Coeffs) : Coeffs :=
    match xs, ys with
    | x :: xs', y :: ys' => go xs' ys' (vecAdd acc (mulRq x y))
    | _, _ => acc
  go xs.toList ys.toList zeroRq

/-- Extract row `r` (length `cols`) from flattened matrix data. -/
def matRow (cols : Nat) (flat : Array Coeffs) (r : Nat) : Array Coeffs :=
  flat.extract (r * cols) ((r + 1) * cols)

/-- Matrix-vector multiplication for flattened `κ×m` matrix data. -/
def matVecMul (params : AjtaiParams) (matrixFlat : Array Coeffs) (v : Array Coeffs) : Array Coeffs :=
  Array.ofFn (fun i : Fin params.kappa =>
    let row := matRow params.msgLen matrixFlat i.1
    dotRq row v
  )

/-- Scalar multiplication of a ring-vector by one ring element. -/
def smulVec (delta : Coeffs) (v : Array Coeffs) : Array Coeffs :=
  v.map (fun x => mulRq delta x)

/-! ### Extractor-facing vector subtraction + linearity surfaces

This theorem-facing file needs subtraction/linearity/norm transfer lemmas to
connect Ajtai collisions to homogeneous MSIS witnesses. These are declared as
axioms at the boundary layer and should be discharged by ring/norm modules.
-/

/-- Ring subtraction placeholder at theorem boundary. -/
axiom subRq : Coeffs → Coeffs → Coeffs

/-- Zero ring-vector of length `n`. -/
def zeroVec (n : Nat) : Array Coeffs :=
  Array.replicate n zeroRq

/-- Pointwise subtraction with fixed output length `n`. -/
noncomputable def subVec (n : Nat) (xs ys : Array Coeffs) : Array Coeffs :=
  Array.ofFn (fun i : Fin n => subRq (xs.getD i.1 zeroRq) (ys.getD i.1 zeroRq))

/-- Subtraction cancels on equal inputs. -/
axiom subRq_self (x : Coeffs) : subRq x x = zeroRq

@[simp] theorem subVec_size (n : Nat) (xs ys : Array Coeffs) :
  (subVec n xs ys).size = n := by
  simp [subVec]

/-- `subVec n v v = 0` (pointwise cancellation). -/
theorem subVec_self (n : Nat) (v : Array Coeffs) :
  subVec n v v = zeroVec n := by
  apply Array.ext
  · simp [subVec, zeroVec]
  · intro i hi₁ hi₂
    simpa [subVec, zeroVec] using (subRq_self (v.getD i zeroRq))

/-- Matrix multiplication respects subtraction of witnesses. -/
axiom matVecMul_subVec
  (params : AjtaiParams)
  (matrixFlat : Array Coeffs)
  (v1 v2 : Array Coeffs) :
    matVecMul params matrixFlat (subVec params.msgLen v1 v2) =
      subVec params.kappa
        (matVecMul params matrixFlat v1)
        (matVecMul params matrixFlat v2)

/-- Matrix multiplication commutes with left-scaling. -/
axiom matVecMul_smulVec
  (params : AjtaiParams)
  (matrixFlat : Array Coeffs)
  (delta : Coeffs)
  (v : Array Coeffs) :
    matVecMul params matrixFlat (smulVec delta v) =
      smulVec delta (matVecMul params matrixFlat v)

/-- Left-scaling commutes on vectors. -/
axiom smulVec_comm (delta1 delta2 : Coeffs) (v : Array Coeffs) :
  smulVec delta1 (smulVec delta2 v) = smulVec delta2 (smulVec delta1 v)

/-- Non-zero difference witness when inputs are distinct and size-matched. -/
axiom subVec_ne_zero_of_ne
  (n : Nat) (v1 v2 : Array Coeffs) :
    v1.size = n →
    v2.size = n →
    v1 ≠ v2 →
    subVec n v1 v2 ≠ zeroVec n

/-- `ℓ∞` norm subadditivity for subtraction. -/
axiom normInfVec_subVec_le (n : Nat) (v1 v2 : Array Coeffs) :
  normInfVec (subVec n v1 v2) ≤ normInfVec v1 + normInfVec v2

/-- `ℓ∞` scaling bound at vector level. -/
axiom normInfVec_smulVec_le (delta : Coeffs) (v : Array Coeffs) :
  normInfVec (smulVec delta v) ≤ normInfCoeffs delta * normInfVec v

/-- Payload well-formedness for `(M || c)` encoding. -/
def Commitment.WellFormed (params : AjtaiParams) (commitment : Commitment) : Prop :=
  commitment.payload.size = params.payloadLen

/-- Extract flattened public matrix `M` from payload. -/
def Commitment.ppMatrixFlat (params : AjtaiParams) (commitment : Commitment) : Array Coeffs :=
  commitment.payload.take params.matrixFlatLen

/-- Extract commitment vector `c` from payload. -/
def Commitment.valueVec (params : AjtaiParams) (commitment : Commitment) : Array Coeffs :=
  commitment.payload.drop params.matrixFlatLen

/-- Witness shape requirement. -/
def Opening.WellFormed (params : AjtaiParams) (opening : Opening) : Prop :=
  opening.witness.size = params.msgLen

/-- Declared norm bound is sound for the witness. -/
def Opening.NormSound (opening : Opening) : Prop :=
  normInfVec opening.witness ≤ opening.normBound

/--
Concrete Ajtai opening relation:
`opensTo (M||c) z` iff `Mz = c` with shape + norm obligations.
-/
def opensTo (params : AjtaiParams) (commitment : Commitment) (opening : Opening) : Prop :=
  Commitment.WellFormed params commitment ∧
  Opening.WellFormed params opening ∧
  Opening.NormSound opening ∧
    matVecMul params (Commitment.ppMatrixFlat params commitment) opening.witness =
      Commitment.valueVec params commitment

/--
Concrete relaxed-opening relation:
`opensToRelaxed (M||c) Δ z` iff `Mz = Δ • c` with shape + norm obligations.
-/
def opensToRelaxed
  (params : AjtaiParams)
  (commitment : Commitment)
  (delta : Coeffs)
  (opening : Opening) : Prop :=
  Commitment.WellFormed params commitment ∧
  Opening.WellFormed params opening ∧
  Opening.NormSound opening ∧
    matVecMul params (Commitment.ppMatrixFlat params commitment) opening.witness =
      smulVec delta (Commitment.valueVec params commitment)

/-- Collision witness for standard Ajtai binding. -/
structure BindingCollision (params : AjtaiParams) where
  commitment : Commitment
  opening1 : Opening
  opening2 : Opening
  /-- Paper-faithful distinctness is on witnesses (`z1 ≠ z2`). -/
  distinct : opening1.witness ≠ opening2.witness
  opens1 : opensTo params commitment opening1
  opens2 : opensTo params commitment opening2
  bounded1 : opening1.normBound < params.bindingNormBound
  bounded2 : opening2.normBound < params.bindingNormBound

/-- Collision witness for relaxed binding. -/
structure RelaxedBindingCollision (params : AjtaiParams) where
  commitment : Commitment
  delta1 : Coeffs
  delta2 : Coeffs
  /-- Paper-facing Δ-bounds needed for norm transfer into MSIS. -/
  deltaBound1 : normInfCoeffs delta1 < 4 * params.relaxedExpansion
  deltaBound2 : normInfCoeffs delta2 < 4 * params.relaxedExpansion
  opening1 : Opening
  opening2 : Opening
  /-- Paper-faithful relaxed distinctness: `Δ1 z2 ≠ Δ2 z1`. -/
  distinct : smulVec delta1 opening2.witness ≠ smulVec delta2 opening1.witness
  opens1 : opensToRelaxed params commitment delta1 opening1
  opens2 : opensToRelaxed params commitment delta2 opening2
  bounded1 : opening1.normBound < params.bindingNormBound
  bounded2 : opening2.normBound < params.bindingNormBound

/-- MSIS challenge surface used for theorem-facing hardness assumptions. -/
structure MSISChallenge (params : AjtaiParams) where
  matrix : Array Coeffs
  target : Array Coeffs

/-- MSIS challenge shape conditions (`matrix` is `κ*m`, `target` is `κ`). -/
def MSISChallenge.WellFormed (params : AjtaiParams) (chal : MSISChallenge params) : Prop :=
  chal.matrix.size = params.matrixFlatLen ∧ chal.target.size = params.kappa

/-- MSIS witness surface with explicit bound/satisfaction predicates. -/
structure MSISSolution (params : AjtaiParams) (chal : MSISChallenge params) where
  witness : Array Coeffs
  bounded :
    witness.size = params.msgLen ∧
    witness ≠ Array.replicate params.msgLen zeroRq ∧
    normInfVec witness < params.msisNormBound
  satisfies :
    MSISChallenge.WellFormed params chal ∧
    matVecMul params chal.matrix witness = chal.target

/-- Canonical homogeneous MSIS break event (`target = 0`). -/
def MSISBreakEvent (params : AjtaiParams) : Prop :=
  let zeroTarget : Array Coeffs := Array.replicate params.kappa zeroRq
  ∃ chal : MSISChallenge params,
    chal.target = zeroTarget ∧
    Nonempty (MSISSolution params chal)

/--
Abstract MSIS game interface indexed by security parameter.
This keeps the boundary theorem-facing while exposing a probability-ready shape.
-/
structure MSISGame (params : AjtaiParams) where
  breakAt : Nat → Prop

/-- Canonical game induced by the MSIS break-event surface. -/
def canonicalMSISGame (params : AjtaiParams) : MSISGame params where
  breakAt := fun _n => MSISBreakEvent params

/-- Advantage of an MSIS adversary/game event under a probability model. -/
def MSISAdvantage
  {params : AjtaiParams}
  (prob : ProbModel)
  (game : MSISGame params)
  (n : Nat) : Rat :=
  prob.Pr (game.breakAt n)

/-- Theorem-facing MSIS advantage bound shape against an error function. -/
def MSISAdvantageBound
  (params : AjtaiParams)
  (eps : ErrorFn) : Prop :=
  ∀ prob : ProbModel, ∀ n : Nat,
    MSISAdvantage prob (canonicalMSISGame params) n ≤ (eps n : Rat)

/-- MSIS hardness boundary in bound-shaped form: `∃ ε negl, Adv_MSIS ≤ ε`. -/
def MSISHardnessAssumption (params : AjtaiParams) : Prop :=
  ∃ eps : ErrorFn,
    IsNegligible eps ∧
    MSISAdvantageBound params eps

/-- Explicit MSIS hardness package with aligned error boundary. -/
structure MSISHardnessBoundary (params : AjtaiParams) where
  epsMSIS : ErrorFn
  advantageBound : MSISAdvantageBound params epsMSIS
  negligibleEpsMSIS : IsNegligible epsMSIS

/-- Canonical hardness view for an MSIS boundary package. -/
def MSISHardnessBoundary.hardness
  {params : AjtaiParams}
  (h : MSISHardnessBoundary params) : MSISHardnessAssumption params :=
  ⟨h.epsMSIS, h.negligibleEpsMSIS, h.advantageBound⟩

/-- Canonical hardness derivation from package fields. -/
theorem MSISHardnessBoundary.hardnessFromFields
  {params : AjtaiParams}
  (h : MSISHardnessBoundary params) : MSISHardnessAssumption params :=
  h.hardness

/-! ### Parameter sanity + basic arithmetic facts -/
namespace AjtaiParams

theorem matrixFlatLen_le_payloadLen (params : AjtaiParams) :
  params.matrixFlatLen ≤ params.payloadLen := by
  simp [AjtaiParams.payloadLen]

theorem commitmentLen_le_payloadLen (params : AjtaiParams) :
  params.commitmentLen ≤ params.payloadLen := by
  simp [AjtaiParams.payloadLen]

/-- Minimal “paper-facing” non-triviality conditions. -/
def Nontrivial (params : AjtaiParams) : Prop :=
  0 < params.kappa ∧ 0 < params.msgLen ∧
    0 < params.bindingNormBound ∧ 0 < params.relaxedExpansion

theorem msisNormBound_pos {params : AjtaiParams}
  (hExp : 0 < params.relaxedExpansion)
  (hB : 0 < params.bindingNormBound) :
  0 < params.msisNormBound := by
  unfold AjtaiParams.msisNormBound
  have h8 : 0 < (8 : Nat) := by decide
  have h1 : 0 < 8 * params.relaxedExpansion := Nat.mul_pos h8 hExp
  exact Nat.mul_pos h1 hB

end AjtaiParams

/-! ### Size lemmas for payload slicing -/
namespace Commitment

theorem ppMatrixFlat_size (params : AjtaiParams) (c : Commitment) :
  (Commitment.ppMatrixFlat params c).size = Nat.min params.matrixFlatLen c.payload.size := by
  simp [Commitment.ppMatrixFlat]

theorem valueVec_size (params : AjtaiParams) (c : Commitment) :
  (Commitment.valueVec params c).size = c.payload.size - params.matrixFlatLen := by
  simp [Commitment.valueVec]

theorem ppMatrixFlat_size_of_wf
  {params : AjtaiParams} {c : Commitment}
  (hc : Commitment.WellFormed params c) :
  (Commitment.ppMatrixFlat params c).size = params.matrixFlatLen := by
  have hc' : c.payload.size = params.payloadLen := hc
  have hle : params.matrixFlatLen ≤ c.payload.size := by
    have h' : params.matrixFlatLen ≤ params.payloadLen :=
      AjtaiParams.matrixFlatLen_le_payloadLen params
    calc
      params.matrixFlatLen ≤ params.payloadLen := h'
      _ = c.payload.size := hc'.symm
  calc
    (Commitment.ppMatrixFlat params c).size
        = Nat.min params.matrixFlatLen c.payload.size := Commitment.ppMatrixFlat_size params c
    _ = params.matrixFlatLen := by
        exact Nat.min_eq_left hle

theorem valueVec_size_of_wf
  {params : AjtaiParams} {c : Commitment}
  (hc : Commitment.WellFormed params c) :
  (Commitment.valueVec params c).size = params.commitmentLen := by
  have hc' : c.payload.size = params.payloadLen := hc
  calc
    (Commitment.valueVec params c).size
        = c.payload.size - params.matrixFlatLen := Commitment.valueVec_size params c
    _ = params.payloadLen - params.matrixFlatLen := by
        simp [hc']
    _ = params.commitmentLen := by
        simp [AjtaiParams.payloadLen]

end Commitment

/-! ### Small monotonicity helper for norm-soundness -/
namespace Opening

theorem NormSound_mono {o : Opening} {b : Nat}
  (h : Opening.NormSound o) (hb : o.normBound ≤ b) :
  normInfVec o.witness ≤ b :=
  Nat.le_trans h hb

end Opening

/-! ### Typed wrappers to make well-formedness available by construction -/

abbrev CommitmentWF (params : AjtaiParams) :=
  { c : Commitment // Commitment.WellFormed params c }

abbrev OpeningWF (params : AjtaiParams) :=
  { o : Opening // Opening.WellFormed params o }

abbrev MSISChallengeWF (params : AjtaiParams) :=
  { chal : MSISChallenge params // MSISChallenge.WellFormed params chal }

namespace CommitmentWF

def ppMatrixFlat {params : AjtaiParams} (c : CommitmentWF params) : Array Coeffs :=
  Commitment.ppMatrixFlat params c.1

def valueVec {params : AjtaiParams} (c : CommitmentWF params) : Array Coeffs :=
  Commitment.valueVec params c.1

theorem ppMatrixFlat_size {params : AjtaiParams} (c : CommitmentWF params) :
  (c.ppMatrixFlat).size = params.matrixFlatLen := by
  simpa [CommitmentWF.ppMatrixFlat] using
    (Commitment.ppMatrixFlat_size_of_wf (params := params) (c := c.1) c.2)

theorem valueVec_size {params : AjtaiParams} (c : CommitmentWF params) :
  (c.valueVec).size = params.commitmentLen := by
  simpa [CommitmentWF.valueVec] using
    (Commitment.valueVec_size_of_wf (params := params) (c := c.1) c.2)

end CommitmentWF

/-! ### Canonical constructors to keep boundary packages coherent by construction -/
namespace MSISHardnessBoundary

def ofFields
  {params : AjtaiParams}
  (eps : ErrorFn)
  (adv : MSISAdvantageBound params eps)
  (negl : IsNegligible eps) :
  MSISHardnessBoundary params where
  epsMSIS := eps
  advantageBound := adv
  negligibleEpsMSIS := negl

def normalize {params : AjtaiParams} (h : MSISHardnessBoundary params) : MSISHardnessBoundary params :=
  h

theorem normalize_hardnessFromFields
  {params : AjtaiParams} (h : MSISHardnessBoundary params) :
  (normalize h).hardness = h.hardnessFromFields := by
  rfl

end MSISHardnessBoundary

/-! ### Basic shape facts about derived operations -/
theorem smulVec_size (delta : Coeffs) (v : Array Coeffs) :
  (smulVec delta v).size = v.size := by
  simp [smulVec]

theorem matVecMul_size (params : AjtaiParams) (matrixFlat v : Array Coeffs) :
  (matVecMul params matrixFlat v).size = params.kappa := by
  simp [matVecMul]

/-- Ajtai binding boundary at theorem level. -/
def AjtaiBindingAssumption (params : AjtaiParams) : Prop :=
  ¬ Nonempty (BindingCollision params)

/-- Ajtai relaxed-binding boundary at theorem level. -/
def AjtaiRelaxedBindingAssumption (params : AjtaiParams) : Prop :=
  ¬ Nonempty (RelaxedBindingCollision params)

/-- Abstract Ajtai binding game interface indexed by security parameter. -/
structure AjtaiBindingGame (params : AjtaiParams) where
  breakAt : Nat → Prop

/-- Canonical Ajtai binding game induced by binding-collision events. -/
def canonicalAjtaiBindingGame (params : AjtaiParams) : AjtaiBindingGame params where
  breakAt := fun _n => Nonempty (BindingCollision params)

/-- Advantage of an Ajtai-binding adversary/game event under a probability model. -/
def AjtaiBindingAdvantage
  {params : AjtaiParams}
  (prob : ProbModel)
  (game : AjtaiBindingGame params)
  (n : Nat) : Rat :=
  prob.Pr (game.breakAt n)

/-- Theorem-facing Ajtai binding advantage bound shape against an error function. -/
def AjtaiBindingAdvantageBound
  (params : AjtaiParams)
  (eps : ErrorFn) : Prop :=
  ∀ prob : ProbModel, ∀ n : Nat,
    AjtaiBindingAdvantage prob (canonicalAjtaiBindingGame params) n ≤ (eps n : Rat)

/-- Abstract Ajtai relaxed-binding game interface indexed by security parameter. -/
structure AjtaiRelaxedBindingGame (params : AjtaiParams) where
  breakAt : Nat → Prop

/-- Canonical Ajtai relaxed-binding game induced by relaxed-collision events. -/
def canonicalAjtaiRelaxedBindingGame (params : AjtaiParams) : AjtaiRelaxedBindingGame params where
  breakAt := fun _n => Nonempty (RelaxedBindingCollision params)

/-- Advantage of an Ajtai relaxed-binding adversary/game event under a probability model. -/
def AjtaiRelaxedBindingAdvantage
  {params : AjtaiParams}
  (prob : ProbModel)
  (game : AjtaiRelaxedBindingGame params)
  (n : Nat) : Rat :=
  prob.Pr (game.breakAt n)

/-- Theorem-facing Ajtai relaxed-binding advantage bound shape against an error function. -/
def AjtaiRelaxedBindingAdvantageBound
  (params : AjtaiParams)
  (eps : ErrorFn) : Prop :=
  ∀ prob : ProbModel, ∀ n : Nat,
    AjtaiRelaxedBindingAdvantage prob (canonicalAjtaiRelaxedBindingGame params) n ≤ (eps n : Rat)

/-- Explicit Ajtai binding boundary package with aligned error/bound surfaces. -/
structure AjtaiBindingBoundary (params : AjtaiParams) where
  epsBinding : ErrorFn
  advantageBound : AjtaiBindingAdvantageBound params epsBinding
  negligibleEpsBinding : IsNegligible epsBinding

/-- Explicit Ajtai relaxed-binding boundary package with aligned error/bound surfaces. -/
structure AjtaiRelaxedBindingBoundary (params : AjtaiParams) where
  epsRelaxedBinding : ErrorFn
  advantageBound : AjtaiRelaxedBindingAdvantageBound params epsRelaxedBinding
  negligibleEpsRelaxedBinding : IsNegligible epsRelaxedBinding

namespace AjtaiBindingBoundary

def ofFields
  {params : AjtaiParams}
  (eps : ErrorFn)
  (adv : AjtaiBindingAdvantageBound params eps)
  (negl : IsNegligible eps) :
  AjtaiBindingBoundary params where
  epsBinding := eps
  advantageBound := adv
  negligibleEpsBinding := negl

end AjtaiBindingBoundary

namespace AjtaiRelaxedBindingBoundary

def ofFields
  {params : AjtaiParams}
  (eps : ErrorFn)
  (adv : AjtaiRelaxedBindingAdvantageBound params eps)
  (negl : IsNegligible eps) :
  AjtaiRelaxedBindingBoundary params where
  epsRelaxedBinding := eps
  advantageBound := adv
  negligibleEpsRelaxedBinding := negl

end AjtaiRelaxedBindingBoundary

end SuperNeo.ProofSystem
