import SuperNeo.Embedding

/-!
Definition-8 bar-lift layer.

This module now wires the concrete chunked path:

`embedVec -> map superneoBarBlock -> unembedVec`

for chunkable vectors (`size % d = 0`), and keeps the identity fallback for
non-chunkable vectors.
-/

namespace SuperNeo

open F

/-- Vector-level chunkability predicate for Definition-8 lifting. -/
def barLiftChunkableVec (v : Array F) : Prop :=
  v.size % d = 0

/-- Decidability of vector chunkability. -/
instance barLiftChunkableVec_decidable (v : Array F) :
    Decidable (barLiftChunkableVec v) := by
  unfold barLiftChunkableVec
  infer_instance

/-- Matrix-level chunkability predicate (row-wise). -/
def barLiftChunkableMatrix (m : Array (Array F)) : Prop :=
  ∀ i : Fin m.size, (m[i.1]'i.2).size % d = 0

/--
Vector bar-lift operator.

Chunkable vectors follow the blockwise lifting chain:
`unembedVec ((embedVec v).map (superneoBarBlock bar))`.
Non-chunkable vectors keep the identity fallback.
-/
def barLiftVector (bar : Array (Array F)) (v : Array F) : Array F :=
  if _hChunk : barLiftChunkableVec v then
    unembedVec ((embedVec v).map (superneoBarBlock bar))
  else
    v

/-- Matrix bar-lift operator (row-wise). -/
def barLiftMatrix (bar : Array (Array F)) (m : Array (Array F)) : Array (Array F) :=
  m.map (barLiftVector bar)

theorem barLiftVector_eq_barBlockRoundTrip_of_chunkable
    (bar : Array (Array F))
    (v : Array F)
    (hChunk : barLiftChunkableVec v) :
    barLiftVector bar v = unembedVec ((embedVec v).map (superneoBarBlock bar)) := by
  simp [barLiftVector, hChunk]

theorem barLiftVector_eq_self_of_not_chunkable
    (bar : Array (Array F))
    (v : Array F)
    (hNotChunk : ¬ barLiftChunkableVec v) :
    barLiftVector bar v = v := by
  simp [barLiftVector, hNotChunk]

/--
Compatibility bridge: if bar-block acts as identity on embedded blocks,
chunkable bar-lift equals embed/unembed round-trip.
-/
theorem barLiftVector_eq_embedRoundTrip_of_chunkable
    (bar : Array (Array F))
    (v : Array F)
    (hChunk : barLiftChunkableVec v)
    (hBlockId : ∀ blk : Coeffs, superneoBarBlock bar blk = blk) :
    barLiftVector bar v = unembedVec (embedVec v) := by
  have hPath := barLiftVector_eq_barBlockRoundTrip_of_chunkable bar v hChunk
  have hMapId : (embedVec v).map (superneoBarBlock bar) = embedVec v := by
    apply Array.ext
    · simp
    · intro i hiL hiR
      simp [hBlockId]
  simpa [hMapId] using hPath

@[simp] theorem barLiftVector_size (bar : Array (Array F)) (v : Array F) :
    (barLiftVector bar v).size = v.size := by
  by_cases hChunk : barLiftChunkableVec v
  · have hMod : v.size % d = 0 := by
      simpa [barLiftChunkableVec] using hChunk
    unfold barLiftVector
    simp [hChunk]
    have hSizeEq :
        (unembedVec ((embedVec v).map (superneoBarBlock bar))).size =
          (unembedVec (embedVec v)).size := by
      simp [unembedVec]
    have hRoundSize : (unembedVec (embedVec v)).size = v.size := by
      simpa using congrArg Array.size (unembedVec_embedVec_of_mod_eq_zero (z := v) hMod)
    calc
      (unembedVec ((embedVec v).map (superneoBarBlock bar))).size
          = (unembedVec (embedVec v)).size := hSizeEq
      _ = v.size := hRoundSize
  · simp [barLiftVector, hChunk]

@[simp] theorem barLiftMatrix_size (bar : Array (Array F)) (m : Array (Array F)) :
    (barLiftMatrix bar m).size = m.size := by
  simp [barLiftMatrix]

/--
Identity-style boundary for bar blocks.

This is the theorem-facing condition needed by identity-specialized closures.
-/
def barBlockIdentityAssumption (bar : Array (Array F)) : Prop :=
  ∀ blk : Coeffs, superneoBarBlock bar blk = blk

theorem barLiftVector_eq_of_barBlockIdentity
    (bar : Array (Array F))
    (v : Array F)
    (hId : barBlockIdentityAssumption bar) :
    barLiftVector bar v = v := by
  by_cases hChunk : barLiftChunkableVec v
  · have hMod : v.size % d = 0 := by
      simpa [barLiftChunkableVec] using hChunk
    calc
      barLiftVector bar v = unembedVec (embedVec v) := by
        exact barLiftVector_eq_embedRoundTrip_of_chunkable bar v hChunk hId
      _ = v := by
        exact unembedVec_embedVec_of_mod_eq_zero (z := v) hMod
  · exact barLiftVector_eq_self_of_not_chunkable bar v hChunk

theorem barLiftVector_eq
    (bar : Array (Array F))
    (v : Array F)
    (hId : barBlockIdentityAssumption bar) :
    barLiftVector bar v = v := by
  exact barLiftVector_eq_of_barBlockIdentity bar v hId

theorem barLiftMatrix_eq
    (bar : Array (Array F))
    (m : Array (Array F))
    (hId : barBlockIdentityAssumption bar) :
    barLiftMatrix bar m = m := by
  apply Array.ext
  · simp [barLiftMatrix]
  · intro i hiL hiR
    have hi : i < m.size := by simpa using hiR
    simpa [barLiftMatrix] using barLiftVector_eq bar (m[i]'hi) hId

/--
Theorem-facing linearity contract for bar-lift.

Downstream theorem files should depend on this Prop boundary, not on Bool checks.
-/
def barLiftLinearityAssumption (bar : Array (Array F)) : Prop :=
  (∀ v w : Array F, v.size = w.size →
    barLiftVector bar (vecAdd v w) = vecAdd (barLiftVector bar v) (barLiftVector bar w)) ∧
  (∀ s : F, ∀ v : Array F,
    barLiftVector bar (vecScale s v) = vecScale s (barLiftVector bar v))

theorem barLiftVector_add
    (bar : Array (Array F))
    (v w : Array F)
    (hLift : barLiftLinearityAssumption bar)
    (hSize : v.size = w.size) :
    barLiftVector bar (vecAdd v w) = vecAdd (barLiftVector bar v) (barLiftVector bar w) := by
  exact hLift.1 v w hSize

theorem barLiftVector_add_of_size_eq
    (bar : Array (Array F))
    (v w : Array F)
    (hLift : barLiftLinearityAssumption bar)
    (hSize : v.size = w.size) :
    barLiftVector bar (vecAdd v w) = vecAdd (barLiftVector bar v) (barLiftVector bar w) := by
  exact hLift.1 v w hSize

theorem barLiftVector_scale
    (bar : Array (Array F))
    (s : F)
    (v : Array F)
    (hLift : barLiftLinearityAssumption bar) :
    barLiftVector bar (vecScale s v) = vecScale s (barLiftVector bar v) := by
  exact hLift.2 s v

/--
Check-facing universal contract for bar-lift linearity.

This is retained for executable compatibility, then bridged back to Prop.
-/
def barLiftLinearityCheckAssumption (bar : Array (Array F)) : Prop :=
  ∀ s : F, ∀ v w : Array F, v.size = w.size →
    decide (barLiftVector bar (vecAdd v w) = vecAdd (barLiftVector bar v) (barLiftVector bar w)) = true ∧
    decide (barLiftVector bar (vecScale s v) = vecScale s (barLiftVector bar v)) = true

/-- Identity wrapper for theorem-facing linearity (boundary-thread helper). -/
theorem barLiftLinearityAssumption_native
  (bar : Array (Array F))
  (hLift : barLiftLinearityAssumption bar) :
  barLiftLinearityAssumption bar := by
  exact hLift

/-- Thread theorem-facing linearity through P9 context when supplied explicitly. -/
theorem barLiftLinearityAssumption_of_p9Embedding
  (bar : Array (Array F))
  (_hP9 : p9EmbeddingAssumption)
  (hLift : barLiftLinearityAssumption bar) :
  barLiftLinearityAssumption bar := by
  exact hLift

/-- Closed wrapper is now explicit on theorem-facing linearity input. -/
theorem barLiftLinearityAssumption_of_p9Embedding_closed
  (bar : Array (Array F))
  (hLift : barLiftLinearityAssumption bar) :
  barLiftLinearityAssumption bar := by
  exact barLiftLinearityAssumption_of_p9Embedding bar p9EmbeddingAssumption_holds hLift

/-- Convert theorem-facing bar-lift linearity into the check-facing contract. -/
theorem barLiftLinearityCheckAssumption_of_assumption
  {bar : Array (Array F)}
  (hAssm : barLiftLinearityAssumption bar) :
  barLiftLinearityCheckAssumption bar := by
  intro s v w hSize
  refine ⟨?_, ?_⟩
  · exact decide_eq_true (hAssm.1 v w hSize)
  · exact decide_eq_true (hAssm.2 s v)

/-- Convert check-facing bar-lift linearity into the theorem-facing contract. -/
theorem barLiftLinearityAssumption_of_checkAssumption
  {bar : Array (Array F)}
  (hCheck : barLiftLinearityCheckAssumption bar) :
  barLiftLinearityAssumption bar := by
  constructor
  · intro v w hSize
    exact decide_eq_true_eq.mp (hCheck 0 v w hSize).1
  · intro s v
    exact decide_eq_true_eq.mp (hCheck s v v rfl).2

/-- Equivalence between theorem-facing and check-facing bar-lift contracts. -/
theorem barLiftLinearityAssumption_iff_checkAssumption
  {bar : Array (Array F)} :
  barLiftLinearityAssumption bar ↔ barLiftLinearityCheckAssumption bar := by
  constructor
  · exact barLiftLinearityCheckAssumption_of_assumption
  · exact barLiftLinearityAssumption_of_checkAssumption

end SuperNeo
