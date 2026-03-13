import TwistShout.MLE

/-!
# ShoutOneHot

Paper-faithful one-hot checking identities for Shout's Figure 6 and Figure 8.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- Address digits in the paper are Boolean cubes of width `m = log(K)/d`. -/
abbrev DigitCube (m : Nat) := Cube m

/-- Cycle indices are Boolean cubes of width `t = log(T)`. -/
abbrev CycleCube (t : Nat) := Cube t

/-- A full `d`-dimensional address is a tuple of Boolean-cube digits. -/
abbrev Address (d m : Nat) := Fin d → DigitCube m

/-- The committed Shout address columns `ra_i(k_i, j)`. -/
abbrev AddressColumns (d m t : Nat) := Fin d → DigitCube m → CycleCube t → K

/-- Cube-indexed one-hot vector used by Figure 8. -/
def cubeOneHot {m : Nat} (z : DigitCube m) : DigitCube m → K :=
  fun k => if k = z then 1 else 0

/-- Tuple-valued one-hot selector on `d` cube digits. -/
def tupleCubeOneHot {d m : Nat} (z : Address d m) : Address d m → K :=
  fun k => if k = z then 1 else 0

/-- Honest per-cycle address-column validity for Shout's `d`-dimensional encoding. -/
def ValidAddressColumns {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (addr : CycleCube t → Address d m) : Prop :=
  ∀ j i k, ra i k j = cubeOneHot (K := K) (addr j i) k

/-- Product selector `∏ᵢ raᵢ(kᵢ, j)` from Figure 8. -/
def addressSelector {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (k : Address d m)
    (j : CycleCube t) : K :=
  ∏ i, ra i (k i) j

/-- Figure 8 Booleanity integrand `(ra_i)^2 - ra_i`. -/
def booleanityDefect {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (i : Fin d)
    (k : DigitCube m)
    (j : CycleCube t) : K :=
  (ra i k j) ^ 2 - ra i k j

/-- Figure 8 Booleanity zero-check at random points `(r_address, r_cycle)`. -/
def booleanityExpression {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (i : Fin d)
    (rAddress : Point (K := K) m)
    (rCycle : Point (K := K) t) : K :=
  ∑ k : DigitCube m, ∑ j : CycleCube t,
    chiWeight (K := K) rAddress k *
      chiWeight (K := K) rCycle j *
      booleanityDefect (K := K) ra i k j

/-- Per-cycle Hamming weight of one address column. -/
def hammingWeightAtCycle {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (i : Fin d)
    (j : CycleCube t) : K :=
  ∑ k : DigitCube m, ra i k j

/-- Figure 8 Hamming-weight-one check at a random cycle point. -/
def hammingWeightExpression {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (i : Fin d)
    (rCycle : Point (K := K) t) : K :=
  ∑ j : CycleCube t,
    chiWeight (K := K) rCycle j * hammingWeightAtCycle (K := K) ra i j

/-- Bit-decoding of one cube digit into the ambient field. -/
def digitValue {m : Nat} (k : DigitCube m) : K :=
  ∑ l : Fin m, bitToField (K := K) (k l) * (2 : K) ^ l.1

/-- Field-valued address oracle from the paper's binary weighting formula.

Lean uses 0-based `Fin` indices, so the exponent is `i * m + l`.
-/
def addressValue {d m : Nat} (k : Address d m) : K :=
  ∑ i : Fin d, ∑ l : Fin m,
    bitToField (K := K) (k i l) * (2 : K) ^ (i.1 * m + l.1)

/-- The cycle-indexed address-value oracle `raf~`. -/
def addressOracleTable {d m t : Nat} (addr : CycleCube t → Address d m) : CycleCube t → K :=
  fun j => addressValue (K := K) (addr j)

/-- Figure 8 address-value reconstruction identity at a random cycle point. -/
def addressValueExpression {d m t : Nat}
    (ra : AddressColumns (K := K) d m t)
    (rCycle : Point (K := K) t) : K :=
  ∑ j : CycleCube t, chiWeight (K := K) rCycle j *
    ∑ k : Address d m, addressValue (K := K) k * addressSelector (K := K) ra k j

@[simp] theorem cubeOneHot_self
    {m : Nat}
    (z : DigitCube m) :
    cubeOneHot (K := K) z z = 1 := by
  simp [cubeOneHot]

theorem cubeOneHot_eq_zero_of_ne
    {m : Nat}
    {z k : DigitCube m}
    (hzk : k ≠ z) :
    cubeOneHot (K := K) z k = 0 := by
  simp [cubeOneHot, hzk]

open Classical in
theorem sum_cubeOneHot
    {m : Nat}
    (z : DigitCube m) :
    ∑ k : DigitCube m, cubeOneHot (K := K) z k = 1 := by
  rw [Finset.sum_eq_single z]
  · simp [cubeOneHot]
  · intro k _ hk
    simp [cubeOneHot, hk]
  · simp [cubeOneHot]

open Classical in
theorem mle_cubeOneHot
    {m : Nat}
    (z : DigitCube m)
    (r : Point (K := K) m) :
    mle (K := K) (cubeOneHot (K := K) z) r = chiWeight (K := K) r z := by
  unfold mle
  rw [Finset.sum_eq_single z]
  · simp [cubeOneHot]
  · intro k _ hk
    simp [cubeOneHot, hk]
  · simp [cubeOneHot]

@[simp] theorem tupleCubeOneHot_self
    {d m : Nat}
    (z : Address d m) :
    tupleCubeOneHot (K := K) z z = 1 := by
  simp [tupleCubeOneHot]

theorem tupleCubeOneHot_eq_zero_of_ne
    {d m : Nat}
    {z k : Address d m}
    (hzk : k ≠ z) :
    tupleCubeOneHot (K := K) z k = 0 := by
  simp [tupleCubeOneHot, hzk]

open Classical in
theorem weightedSum_tupleCubeOneHot
    {d m : Nat}
    (w : Address d m → K)
    (z : Address d m) :
    ∑ k : Address d m, w k * tupleCubeOneHot (K := K) z k = w z := by
  rw [Finset.sum_eq_single z]
  · simp [tupleCubeOneHot]
  · intro k _ hk
    simp [tupleCubeOneHot, hk]
  · simp [tupleCubeOneHot]

theorem ValidAddressColumns.coord_eq_cubeOneHot
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (j : CycleCube t)
    (i : Fin d) :
    (fun k => ra i k j) = cubeOneHot (K := K) (addr j i) := by
  funext k
  exact hvalid j i k

theorem ValidAddressColumns.booleanityAtEntry
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (j : CycleCube t)
    (i : Fin d)
    (k : DigitCube m) :
    booleanityDefect (K := K) ra i k j = 0 := by
  unfold booleanityDefect
  rw [hvalid j i k]
  by_cases hk : k = addr j i
  · simp [cubeOneHot, hk]
  · simp [cubeOneHot, hk]

theorem ValidAddressColumns.hammingWeightAtCycle
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (i : Fin d)
    (j : CycleCube t) :
    hammingWeightAtCycle (K := K) ra i j = 1 := by
  unfold TwistShout.hammingWeightAtCycle
  rw [hvalid.coord_eq_cubeOneHot (j := j) (i := i)]
  exact sum_cubeOneHot (K := K) (addr j i)

open Classical in
theorem ValidAddressColumns.addressSelector_eq_tupleCubeOneHot
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (k : Address d m)
    (j : CycleCube t) :
    addressSelector (K := K) ra k j = tupleCubeOneHot (K := K) (addr j) k := by
  by_cases hk : k = addr j
  · subst hk
    have hprod : addressSelector (K := K) ra (addr j) j = 1 := by
      unfold addressSelector
      apply Finset.prod_eq_one
      intro i _
      simpa [cubeOneHot] using hvalid j i (addr j i)
    simpa [tupleCubeOneHot] using hprod
  · have hcoord : ∃ i : Fin d, k i ≠ addr j i := by
      by_contra hNo
      apply hk
      funext i
      by_contra hi
      exact hNo ⟨i, hi⟩
    rcases hcoord with ⟨i, hi⟩
    have hprod :
        addressSelector (K := K) ra k j = 0 := by
      unfold addressSelector
      exact Finset.prod_eq_zero (s := Finset.univ)
        (i := i)
        (f := fun i' => ra i' (k i') j)
        (by simp)
        (by simp [hvalid j i (k i), cubeOneHot, hi])
    rw [hprod]
    simp [tupleCubeOneHot, hk]

open Classical in
theorem ValidAddressColumns.selectorWeightedSumAtCycle
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (w : Address d m → K)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (j : CycleCube t) :
    ∑ k : Address d m, w k * addressSelector (K := K) ra k j =
      w (addr j) := by
  rw [Finset.sum_eq_single (addr j)]
  · simp [hvalid.addressSelector_eq_tupleCubeOneHot (k := addr j) (j := j)]
  · intro k _ hk
    rw [hvalid.addressSelector_eq_tupleCubeOneHot (k := k) (j := j)]
    simp [tupleCubeOneHot, hk]
  · simp [hvalid.addressSelector_eq_tupleCubeOneHot (k := addr j) (j := j)]

open Classical in
theorem ValidAddressColumns.addressValueAtCycle
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (j : CycleCube t) :
    ∑ k : Address d m, addressValue (K := K) k * addressSelector (K := K) ra k j =
      addressValue (K := K) (addr j) := by
  simpa using hvalid.selectorWeightedSumAtCycle (w := addressValue (K := K)) j

theorem ValidAddressColumns.booleanityExpression
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (i : Fin d)
    (rAddress : Point (K := K) m)
    (rCycle : Point (K := K) t) :
    booleanityExpression (K := K) ra i rAddress rCycle = 0 := by
  unfold TwistShout.booleanityExpression
  apply Finset.sum_eq_zero
  intro k _
  apply Finset.sum_eq_zero
  intro j _
  rw [hvalid.booleanityAtEntry (j := j) (i := i) (k := k)]
  simp

theorem ValidAddressColumns.hammingWeightExpression
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (i : Fin d)
    (rCycle : Point (K := K) t) :
    hammingWeightExpression (K := K) ra i rCycle = 1 := by
  unfold TwistShout.hammingWeightExpression
  calc
    ∑ j : CycleCube t, chiWeight (K := K) rCycle j *
      TwistShout.hammingWeightAtCycle (K := K) ra i j
      = ∑ j : CycleCube t, chiWeight (K := K) rCycle j * 1 := by
          apply Finset.sum_congr rfl
          intro j _
          rw [hvalid.hammingWeightAtCycle (i := i) (j := j)]
    _ = ∑ j : CycleCube t, chiWeight (K := K) rCycle j := by simp
    _ = 1 := sum_chiWeight (K := K) rCycle

theorem ValidAddressColumns.addressValueExpression
    {d m t : Nat}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (rCycle : Point (K := K) t) :
    mle (K := K) (addressOracleTable (K := K) addr) rCycle =
      addressValueExpression (K := K) ra rCycle := by
  unfold mle addressOracleTable TwistShout.addressValueExpression
  apply Finset.sum_congr rfl
  intro j _
  rw [hvalid.addressValueAtCycle (j := j)]
  ring

end

end TwistShout
