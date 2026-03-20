import TwistShout.FastShoutSmallMemory

/-!
# FastShoutStructuredMemory

Section 7 structured-memory prover identities for Shout.
-/

open scoped BigOperators

namespace TwistShout

section

variable {K : Type*} [Field K]

/-- A verifier-visible structured-table oracle whose answers are exactly the paper's `\tilde{Val}`. -/
structure StructuredTableOracle {d m : Nat}
    (val : PublicTable (K := K) d m) where
  eval : (Fin d → Point (K := K) m) → K
  eval_eq_tableMLE : ∀ rAddress, eval rAddress = tableMLE (K := K) val rAddress

/-- Canonical oracle obtained by directly using `tableMLE`. -/
def StructuredTableOracle.ofTableMLE
    {d m : Nat}
    (val : PublicTable (K := K) d m) :
    StructuredTableOracle (K := K) val where
  eval := tableMLE (K := K) val
  eval_eq_tableMLE := by
    intro rAddress
    rfl

theorem StructuredTableOracle.eval_eq
    {d m : Nat}
    {val : PublicTable (K := K) d m}
    (oracle : StructuredTableOracle (K := K) val)
    (rAddress : Fin d → Point (K := K) m) :
    oracle.eval rAddress = tableMLE (K := K) val rAddress :=
  oracle.eval_eq_tableMLE rAddress

theorem StructuredTableOracle.eval_at_bitAddress
    {d m : Nat}
    {val : PublicTable (K := K) d m}
    (oracle : StructuredTableOracle (K := K) val)
    (a : Address d m) :
    oracle.eval (bitAddress (K := K) a) = val a := by
  rw [oracle.eval_eq]
  exact tableMLE_at_bitAddress (K := K) val a

/-- Section 7.4 batched oracle replacing `Val` by `Val + z * int`. -/
def StructuredTableOracle.batched
    {d m : Nat}
    {val : PublicTable (K := K) d m}
    (oracle : StructuredTableOracle (K := K) val)
    (z : K) :
    StructuredTableOracle (K := K) (batchedTable (K := K) z val) where
  eval := fun rAddress =>
    oracle.eval rAddress + z * tableMLE (K := K) (addressValue (K := K)) rAddress
  eval_eq_tableMLE := by
    intro rAddress
    rw [tableMLE_batchedTable (K := K) z val rAddress, oracle.eval_eq]

theorem StructuredTableOracle.batched_eval
    {d m : Nat}
    {val : PublicTable (K := K) d m}
    (oracle : StructuredTableOracle (K := K) val)
    (z : K)
    (rAddress : Fin d → Point (K := K) m) :
    (oracle.batched z).eval rAddress =
      oracle.eval rAddress + z * tableMLE (K := K) (addressValue (K := K)) rAddress := by
  rfl

theorem StructuredTableOracle.batched_eval_at_bitAddress
    {d m : Nat}
    {val : PublicTable (K := K) d m}
    (oracle : StructuredTableOracle (K := K) val)
    (z : K)
    (a : Address d m) :
    (oracle.batched z).eval (bitAddress (K := K) a) =
      val a + z * addressValue (K := K) a := by
  rw [(oracle.batched z).eval_eq]
  rw [tableMLE_at_bitAddress (K := K) (val := batchedTable (K := K) z val) (a := a)]
  rfl

/-- Final-round verifier target using a structured table oracle instead of direct `tableMLE` access. -/
def structuredReadCheckFinalRoundTarget
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    (queryCycle : Point (K := K) t)
    (ra : AddressColumns (K := K) d m t)
    (oracle : StructuredTableOracle (K := K) val)
    (rAddress : Fin d → Point (K := K) m)
    (boundCycle : Point (K := K) t) : K :=
  eqPoly queryCycle boundCycle *
    (∏ i, columnMLE (K := K) ra i (rAddress i) boundCycle) *
    oracle.eval rAddress

theorem StructuredTableOracle.structuredReadCheckFinalRoundTarget_eq
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    (oracle : StructuredTableOracle (K := K) val)
    (queryCycle : Point (K := K) t)
    (ra : AddressColumns (K := K) d m t)
    (rAddress : Fin d → Point (K := K) m)
    (boundCycle : Point (K := K) t) :
    structuredReadCheckFinalRoundTarget (K := K) queryCycle ra oracle rAddress boundCycle =
      readCheckFinalRoundTarget (K := K) queryCycle ra val rAddress boundCycle := by
  unfold structuredReadCheckFinalRoundTarget readCheckFinalRoundTarget
  rw [oracle.eval_eq]

theorem StructuredTableOracle.readCheckFinalRoundTarget_atBooleanPoint
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (oracle : StructuredTableOracle (K := K) val)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    structuredReadCheckFinalRoundTarget (K := K) queryCycle ra oracle
      (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
      chiWeight (K := K) queryCycle j * val (addr j) := by
  rw [oracle.structuredReadCheckFinalRoundTarget_eq]
  exact hvalid.readCheckFinalRoundTarget_atBooleanPoint val queryCycle j

theorem StructuredTableOracle.batched_readCheckFinalRoundTarget_atBooleanPoint
    {d m t : Nat}
    {val : PublicTable (K := K) d m}
    {ra : AddressColumns (K := K) d m t}
    {addr : CycleCube t → Address d m}
    (oracle : StructuredTableOracle (K := K) val)
    (hvalid : ValidAddressColumns (K := K) ra addr)
    (z : K)
    (queryCycle : Point (K := K) t)
    (j : CycleCube t) :
    structuredReadCheckFinalRoundTarget (K := K) queryCycle ra (oracle.batched z)
      (bitAddress (K := K) (addr j)) (bitVec (K := K) j) =
      chiWeight (K := K) queryCycle j *
        (val (addr j) + z * addressValue (K := K) (addr j)) := by
  rw [(oracle.batched z).structuredReadCheckFinalRoundTarget_eq]
  exact hvalid.readCheckFinalRoundTarget_atBooleanPoint
    (batchedTable (K := K) z val) queryCycle j

/-- Section 7.5 cost for evaluating `\tilde{rv}(r_cycle)` before the read-checking sum-check. -/
def structuredReadValueEvalLeadingCost (t : Nat) : Nat :=
  2 * cycleSpaceSize t

/-- Section 7.5 cost for the structured read-checking sum-check. -/
def structuredReadCheckLeadingCost (C d t : Nat) : Nat :=
  (2 * C + d * d) * cycleSpaceSize t

/-- Section 7.5 cost for Booleanity checking. -/
def structuredBooleanityLeadingCost (C d t : Nat) : Nat :=
  (4 * C + 3 * d) * cycleSpaceSize t

/-- Section 7.4 cost for the structured `\tilde{raf}`-evaluation sum-check. -/
def structuredRafLeadingCost (C t : Nat) : Nat :=
  C * cycleSpaceSize t

/-- Section 7.4 cost for the structured Hamming-weight-one check. -/
def structuredHammingLeadingCost (c t : Nat) : Nat :=
  c * cycleSpaceSize t

/-- Section 7.5 combined leading-term summary. -/
def structuredShoutLeadingCost (C c d t : Nat) : Nat :=
  (7 * C + d * d + 3 * d + c + 2) * cycleSpaceSize t

theorem structuredBooleanityLeadingCost_eq_chunked
    (c d t : Nat) :
    structuredBooleanityLeadingCost (c * d) d t =
      (4 * c * d + 3 * d) * cycleSpaceSize t := by
  unfold structuredBooleanityLeadingCost
  ring

theorem structuredReadCheckLeadingCost_eq_chunked
    (c d t : Nat) :
    structuredReadCheckLeadingCost (c * d) d t =
      (2 * c * d + d * d) * cycleSpaceSize t := by
  unfold structuredReadCheckLeadingCost
  ring

theorem structuredShoutLeadingCost_eq_sum
    (C c d t : Nat) :
    structuredShoutLeadingCost C c d t =
      structuredReadValueEvalLeadingCost t +
        structuredReadCheckLeadingCost C d t +
        structuredBooleanityLeadingCost C d t +
        structuredRafLeadingCost C t +
        structuredHammingLeadingCost c t := by
  unfold structuredShoutLeadingCost
  unfold structuredReadValueEvalLeadingCost structuredReadCheckLeadingCost
  unfold structuredBooleanityLeadingCost structuredRafLeadingCost
  unfold structuredHammingLeadingCost cycleSpaceSize
  ring

theorem structuredShoutLeadingCost_eq_chunked
    (c d t : Nat) :
    structuredShoutLeadingCost (c * d) c d t =
      (7 * c * d + d * d + 3 * d + c + 2) * cycleSpaceSize t := by
  unfold structuredShoutLeadingCost
  ring

end

end TwistShout
