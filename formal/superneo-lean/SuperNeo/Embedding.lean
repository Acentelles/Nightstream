import SuperNeo.Ring

/-!
Embedding layer (P9 core):
- element/vector/matrix embedding and unembedding,
- blockwise add/scale operators,
- basic linearity theorems for `embedVec`.
-/

namespace SuperNeo

open F

/-- Element embedding: `F^d -> Coeffs`. In the compact scaffold this is identity. -/
def embedElem (v : Array F) : Coeffs :=
  v

/-- Element unembedding: `Coeffs -> F^d`. In the compact scaffold this is identity. -/
def unembedElem (a : Coeffs) : Array F :=
  a

@[simp] theorem unembedElem_embedElem (v : Array F) :
    unembedElem (embedElem v) = v := by
  rfl

@[simp] theorem embedElem_unembedElem (a : Coeffs) :
    embedElem (unembedElem a) = a := by
  rfl

theorem embedElem_vecAdd (v w : Array F) :
    embedElem (vecAdd v w) = vecAdd (embedElem v) (embedElem w) := by
  rfl

theorem unembedElem_vecAdd (a b : Coeffs) :
    unembedElem (vecAdd a b) = vecAdd (unembedElem a) (unembedElem b) := by
  rfl

theorem embedElem_vecScale (s : F) (v : Array F) :
    embedElem (vecScale s v) = vecScale s (embedElem v) := by
  rfl

theorem unembedElem_vecScale (s : F) (a : Coeffs) :
    unembedElem (vecScale s a) = vecScale s (unembedElem a) := by
  rfl

private def chunkExact (xs : Array F) (chunk : Nat) : Array (Array F) :=
  if chunk = 0 then
    #[]
  else
    Array.ofFn (fun t : Fin (xs.size / chunk) =>
      xs.extract (t.1 * chunk) (t.1 * chunk + chunk))

private def flatten (blocks : Array (Array F)) : Array F :=
  blocks.foldl (fun acc blk => acc ++ blk) #[]

/-- Blockwise addition on vectors of coefficient blocks. -/
def vecAddBlocks (a b : Array Coeffs) : Array Coeffs :=
  if hSize : a.size = b.size then
    Array.ofFn (fun i : Fin a.size =>
      vecAdd (a[i.1]'i.2) (b[i.1]'(by simpa [hSize] using i.2)))
  else
    #[]

/-- Blockwise scalar multiplication on vectors of coefficient blocks. -/
def vecScaleBlocks (s : F) (a : Array Coeffs) : Array Coeffs :=
  a.map (vecScale s)

theorem vecAddBlocks_size_of_eq
  {a b : Array Coeffs}
  (hSize : a.size = b.size) :
  (vecAddBlocks a b).size = a.size := by
  unfold vecAddBlocks
  simp [hSize]

theorem vecScaleBlocks_size
  (s : F) (a : Array Coeffs) :
  (vecScaleBlocks s a).size = a.size := by
  unfold vecScaleBlocks
  simp

/-- Vector embedding by `d`-chunking. -/
def embedVec (z : Array F) : Array Coeffs :=
  if z.size % d != 0 then
    #[]
  else
    #[embedElem z]

/-- Vector unembedding by block flattening. -/
def unembedVec (zr : Array Coeffs) : Array F :=
  flatten (zr.map unembedElem)

private theorem d_ne_zero : d ≠ 0 := by
  unfold d
  decide

private theorem chunkExact_size
  (xs : Array F) (chunk : Nat) (hChunk : chunk ≠ 0) :
  (chunkExact xs chunk).size = xs.size / chunk := by
  unfold chunkExact
  simp [hChunk]

private theorem vecScale_extract
  (s : F) (z : Array F) (start stop : Nat) :
  (vecScale s z).extract start stop = vecScale s (z.extract start stop) := by
  simp [vecScale]

private theorem vecAdd_eq_zipWith_of_size_eq
  {v w : Array F}
  (hSize : v.size = w.size) :
  vecAdd v w = Array.zipWith (fun x y => x + y) v w := by
  apply Array.ext
  · simp [vecAdd, hSize]
  · intro i hiL hiR
    have hiV : i < v.size := by
      simpa [hSize] using hiR
    have hiW : i < w.size := by
      simpa [hSize] using hiV
    simp [vecAdd, hSize]

private theorem vecAdd_extract_of_size_eq
  {v w : Array F}
  (hSize : v.size = w.size)
  (start stop : Nat) :
  (vecAdd v w).extract start stop =
    vecAdd (v.extract start stop) (w.extract start stop) := by
  calc
    (vecAdd v w).extract start stop
        = (Array.zipWith (fun x y => x + y) v w).extract start stop := by
            simp [vecAdd_eq_zipWith_of_size_eq hSize]
    _ = Array.zipWith (fun x y => x + y) (v.extract start stop) (w.extract start stop) := by
          simpa using
            (Array.extract_zipWith (f := fun x y => x + y) (as := v) (bs := w)
              (i := start) (j := stop))
    _ = vecAdd (v.extract start stop) (w.extract start stop) := by
          have hExtractSize : (v.extract start stop).size = (w.extract start stop).size := by
            simp [hSize]
          simp [vecAdd_eq_zipWith_of_size_eq hExtractSize]

theorem unembedVec_embedVec_of_mod_eq_zero
  {z : Array F}
  (hMod : z.size % d = 0) :
  unembedVec (embedVec z) = z := by
  unfold unembedVec embedVec
  simp [hMod, flatten, embedElem, unembedElem]

theorem embedVec_vecScale_of_mod_eq_zero
  {z : Array F}
  (hMod : z.size % d = 0)
  (s : F) :
  embedVec (vecScale s z) = vecScaleBlocks s (embedVec z) := by
  unfold embedVec vecScaleBlocks
  simp [hMod, vecScale_size, embedElem_vecScale]

theorem embedVec_vecAdd_of_size_mod_eq_zero
  {v w : Array F}
  (hSize : v.size = w.size)
  (hMod : v.size % d = 0) :
  embedVec (vecAdd v w) = vecAddBlocks (embedVec v) (embedVec w) := by
  unfold embedVec vecAddBlocks
  have hModW : w.size % d = 0 := by simpa [hSize] using hMod
  have hAddMod : (vecAdd v w).size % d = 0 := by
    simpa [vecAdd_size_of_eq hSize] using hMod
  simp [hMod, hModW, hAddMod, hSize, embedElem_vecAdd]
  apply Array.ext
  · simp
    simpa [hMod]
  · intro i hiL hiR
    have hi0 : i = 0 := Nat.lt_one_iff.mp hiL
    simp [hi0]

/-- Matrix embedding row-wise. -/
def embedMatrix (m : Array (Array F)) : Array (Array Coeffs) :=
  m.map embedVec

/-- Matrix unembedding row-wise. -/
def unembedMatrix (mr : Array (Array Coeffs)) : Array (Array F) :=
  mr.map unembedVec

/-- Row-wise matrix scaling on field vectors. -/
def matrixScaleRows (s : F) (m : Array (Array F)) : Array (Array F) :=
  m.map (vecScale s)

/-- Row-wise matrix scaling on embedded vectors. -/
def matrixScaleRowsBlocks (s : F) (mr : Array (Array Coeffs)) : Array (Array Coeffs) :=
  mr.map (vecScaleBlocks s)

/-- Row-wise matrix addition on field vectors. -/
def matrixAddRows (m n : Array (Array F)) : Array (Array F) :=
  if h : m.size = n.size then
    Array.ofFn (fun i : Fin m.size =>
      vecAdd (m[i.1]'i.2) (n[i.1]'(by simpa [h] using i.2)))
  else
    #[]

/-- Row-wise matrix addition on embedded vectors. -/
def matrixAddRowsBlocks (m n : Array (Array Coeffs)) : Array (Array Coeffs) :=
  if h : m.size = n.size then
    Array.ofFn (fun i : Fin m.size =>
      vecAddBlocks (m[i.1]'i.2) (n[i.1]'(by simpa [h] using i.2)))
  else
    #[]

theorem embedMatrix_rowwise_vecScale_of_rows_mod_eq_zero
  {m : Array (Array F)}
  (hRowsMod : ∀ i : Fin m.size, (m[i.1]'i.2).size % d = 0)
  (s : F) :
  embedMatrix (matrixScaleRows s m) =
    matrixScaleRowsBlocks s (embedMatrix m) := by
  unfold embedMatrix matrixScaleRows matrixScaleRowsBlocks
  apply Array.ext
  · simp
  · intro i hiL hiR
    have hi : i < m.size := by
      simpa using hiL
    have hRowMod : (m[i]'hi).size % d = 0 := hRowsMod ⟨i, hi⟩
    simpa [hi] using
      (embedVec_vecScale_of_mod_eq_zero (z := m[i]'hi) hRowMod s)

theorem embedMatrix_rowwise_vecAdd_of_rows_size_mod_eq_zero
  {m n : Array (Array F)}
  (hRowsSize : m.size = n.size)
  (hRowEq :
    ∀ i : Fin m.size, (m[i.1]'i.2).size = (n[i.1]'(by simpa [hRowsSize] using i.2)).size)
  (hRowsMod : ∀ i : Fin m.size, (m[i.1]'i.2).size % d = 0) :
  embedMatrix (matrixAddRows m n) =
    matrixAddRowsBlocks (embedMatrix m) (embedMatrix n) := by
  unfold embedMatrix matrixAddRows matrixAddRowsBlocks
  simp [hRowsSize]
  apply Array.ext
  · simp
  · intro i hiL hiR
    have hi : i < m.size := by
      simpa using hiL
    have hMod : (m[i]'hi).size % d = 0 := hRowsMod ⟨i, hi⟩
    have hSize : (m[i]'hi).size = (n[i]'(by simpa [hRowsSize] using hi)).size := by
      exact hRowEq ⟨i, hi⟩
    simpa [hi] using
      (embedVec_vecAdd_of_size_mod_eq_zero
        (v := m[i]'hi)
        (w := n[i]'(by simpa [hRowsSize] using hi))
        hSize hMod)

theorem unembedMatrix_embedMatrix_of_rows_mod_eq_zero
  {m : Array (Array F)}
  (hRowsMod : ∀ i : Fin m.size, (m[i.1]'i.2).size % d = 0) :
  unembedMatrix (embedMatrix m) = m := by
  unfold unembedMatrix embedMatrix
  apply Array.ext
  · simp
  · intro i hiL hiR
    have hi : i < m.size := by
      simpa using hiR
    have hMod : (m[i]'hi).size % d = 0 := hRowsMod ⟨i, hi⟩
    simpa [hi] using
      (unembedVec_embedVec_of_mod_eq_zero (z := m[i]'hi) hMod)

/-! ## Round-trip executable checks + proposition bridges -/

/-- Bool-level vector embedding round-trip check. -/
def embeddingVecRoundTrip (z : Array F) : Bool :=
  if z.size % d != 0 then
    false
  else
    decide (unembedVec (embedVec z) = z)

/-- Proposition-level counterpart of `embeddingVecRoundTrip`. -/
def embeddingVecRoundTripProp (z : Array F) : Prop :=
  (z.size % d != 0) = false ∧
    unembedVec (embedVec z) = z

theorem embeddingVecRoundTrip_sound
  {z : Array F}
  (hOk : embeddingVecRoundTrip z = true) :
  embeddingVecRoundTripProp z := by
  unfold embeddingVecRoundTrip at hOk
  cases hSize : (z.size % d != 0) with
  | true =>
      simp [hSize] at hOk
  | false =>
      simp [hSize] at hOk
      exact ⟨hSize, hOk⟩

theorem embeddingVecRoundTrip_complete
  {z : Array F}
  (hProp : embeddingVecRoundTripProp z) :
  embeddingVecRoundTrip z = true := by
  rcases hProp with ⟨hSize, hEq⟩
  unfold embeddingVecRoundTrip
  simp [hSize, decide_eq_true hEq]

theorem embeddingVecRoundTrip_iff_prop
  {z : Array F} :
  embeddingVecRoundTrip z = true ↔ embeddingVecRoundTripProp z := by
  constructor
  · exact embeddingVecRoundTrip_sound
  · exact embeddingVecRoundTrip_complete

theorem embeddingVecRoundTrip_size_mod_eq_zero
  {z : Array F}
  (hOk : embeddingVecRoundTrip z = true) :
  z.size % d = 0 := by
  have hSizeFalse : (z.size % d != 0) = false := (embeddingVecRoundTrip_sound hOk).1
  by_cases hMod : z.size % d = 0
  · exact hMod
  · have hNeTrue : (z.size % d != 0) = true := by simp [hMod]
    rw [hNeTrue] at hSizeFalse
    cases hSizeFalse

theorem embeddingVecRoundTrip_unembed_embed_eq
  {z : Array F}
  (hOk : embeddingVecRoundTrip z = true) :
  unembedVec (embedVec z) = z := by
  exact (embeddingVecRoundTrip_sound hOk).2

/-- Bool-level matrix embedding round-trip check. -/
def embeddingMatrixRoundTrip (m : Array (Array F)) : Bool :=
  if !(m.all (fun row => row.size % d = 0)) then
    false
  else
    decide (unembedMatrix (embedMatrix m) = m)

/-- Proposition-level counterpart of `embeddingMatrixRoundTrip`. -/
def embeddingMatrixRoundTripProp (m : Array (Array F)) : Prop :=
  m.all (fun row => row.size % d = 0) = true ∧
    unembedMatrix (embedMatrix m) = m

theorem embeddingMatrixRoundTrip_sound
  {m : Array (Array F)}
  (hOk : embeddingMatrixRoundTrip m = true) :
  embeddingMatrixRoundTripProp m := by
  unfold embeddingMatrixRoundTrip at hOk
  cases hAll : m.all (fun row => row.size % d = 0) with
  | false =>
      simp [hAll] at hOk
  | true =>
      simp [hAll] at hOk
      exact ⟨hAll, hOk⟩

theorem embeddingMatrixRoundTrip_complete
  {m : Array (Array F)}
  (hProp : embeddingMatrixRoundTripProp m) :
  embeddingMatrixRoundTrip m = true := by
  rcases hProp with ⟨hAll, hEq⟩
  unfold embeddingMatrixRoundTrip
  simp [hAll, decide_eq_true hEq]

theorem embeddingMatrixRoundTrip_iff_prop
  {m : Array (Array F)} :
  embeddingMatrixRoundTrip m = true ↔ embeddingMatrixRoundTripProp m := by
  constructor
  · exact embeddingMatrixRoundTrip_sound
  · exact embeddingMatrixRoundTrip_complete

theorem embeddingMatrixRoundTrip_rows_mod_ok
  {m : Array (Array F)}
  (hOk : embeddingMatrixRoundTrip m = true) :
  m.all (fun row => row.size % d = 0) = true := by
  exact (embeddingMatrixRoundTrip_sound hOk).1

theorem embeddingMatrixRoundTrip_unembed_embed_eq
  {m : Array (Array F)}
  (hOk : embeddingMatrixRoundTrip m = true) :
  unembedMatrix (embedMatrix m) = m := by
  exact (embeddingMatrixRoundTrip_sound hOk).2

/-! ## Theorem-facing P9 package surfaces -/

/-- Theorem-facing element embedding package (Definition 7 interface). -/
def p9ElemEmbeddingAssumption : Prop :=
  (∀ v : Array F, unembedElem (embedElem v) = v) ∧
  (∀ a : Coeffs, embedElem (unembedElem a) = a) ∧
  (∀ v w : Array F, embedElem (vecAdd v w) = vecAdd (embedElem v) (embedElem w)) ∧
  (∀ s : F, ∀ v : Array F, embedElem (vecScale s v) = vecScale s (embedElem v))

theorem p9ElemEmbeddingAssumption_from_defs :
  p9ElemEmbeddingAssumption := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro v
    exact unembedElem_embedElem v
  · intro a
    exact embedElem_unembedElem a
  · intro v w
    exact embedElem_vecAdd v w
  · intro s v
    exact embedElem_vecScale s v

/-- Theorem-facing vector embedding package (Definition 7 interface). -/
def p9VecEmbeddingAssumption : Prop :=
  ∀ z : Array F, z.size % d = 0 → unembedVec (embedVec z) = z

/-- Check-facing vector embedding package (regression compatibility). -/
def p9VecEmbeddingCheckAssumption : Prop :=
  ∀ z : Array F, z.size % d = 0 → embeddingVecRoundTrip z = true

/-- Theorem-facing matrix embedding package (row-wise Definition 7 interface). -/
def p9MatrixEmbeddingAssumption : Prop :=
  ∀ m : Array (Array F),
    m.all (fun row => row.size % d = 0) = true →
      unembedMatrix (embedMatrix m) = m

/-- Check-facing matrix embedding package (regression compatibility). -/
def p9MatrixEmbeddingCheckAssumption : Prop :=
  ∀ m : Array (Array F),
    m.all (fun row => row.size % d = 0) = true →
      embeddingMatrixRoundTrip m = true

theorem p9VecEmbeddingAssumption_of_checkAssumption
  (hCheck : p9VecEmbeddingCheckAssumption) :
  p9VecEmbeddingAssumption := by
  intro z hMod
  exact (embeddingVecRoundTrip_sound (hCheck z hMod)).2

theorem p9VecEmbeddingCheckAssumption_of_assumption
  (hAssm : p9VecEmbeddingAssumption) :
  p9VecEmbeddingCheckAssumption := by
  intro z hMod
  exact embeddingVecRoundTrip_complete ⟨by simp [hMod], hAssm z hMod⟩

theorem p9VecEmbeddingAssumption_iff_checkAssumption :
  p9VecEmbeddingAssumption ↔ p9VecEmbeddingCheckAssumption := by
  constructor
  · exact p9VecEmbeddingCheckAssumption_of_assumption
  · exact p9VecEmbeddingAssumption_of_checkAssumption

theorem p9VecEmbeddingAssumption_holds :
  p9VecEmbeddingAssumption := by
  intro z hMod
  exact unembedVec_embedVec_of_mod_eq_zero hMod

theorem p9MatrixEmbeddingAssumption_of_checkAssumption
  (hCheck : p9MatrixEmbeddingCheckAssumption) :
  p9MatrixEmbeddingAssumption := by
  intro m hRows
  exact (embeddingMatrixRoundTrip_sound (hCheck m hRows)).2

theorem p9MatrixEmbeddingCheckAssumption_of_assumption
  (hAssm : p9MatrixEmbeddingAssumption) :
  p9MatrixEmbeddingCheckAssumption := by
  intro m hRows
  exact embeddingMatrixRoundTrip_complete ⟨hRows, hAssm m hRows⟩

theorem p9MatrixEmbeddingAssumption_iff_checkAssumption :
  p9MatrixEmbeddingAssumption ↔ p9MatrixEmbeddingCheckAssumption := by
  constructor
  · exact p9MatrixEmbeddingCheckAssumption_of_assumption
  · exact p9MatrixEmbeddingAssumption_of_checkAssumption

theorem p9MatrixEmbeddingAssumption_holds :
  p9MatrixEmbeddingAssumption := by
  intro m hRowsBool
  have hRows : ∀ i : Fin m.size, (m[i.1]'i.2).size % d = 0 := by
    intro i
    have hDec : decide ((m[i.1]'i.2).size % d = 0) = true :=
      (Array.all_eq_true.mp hRowsBool) i.1 i.2
    exact decide_eq_true_eq.mp hDec
  exact unembedMatrix_embedMatrix_of_rows_mod_eq_zero hRows

/-- Combined theorem-facing P9 surface (element + vector + matrix). -/
def p9EmbeddingAssumption : Prop :=
  p9ElemEmbeddingAssumption ∧
    p9VecEmbeddingAssumption ∧
      p9MatrixEmbeddingAssumption

/-- Combined check-facing P9 surface (vector + matrix checks). -/
def p9EmbeddingCheckAssumption : Prop :=
  p9VecEmbeddingCheckAssumption ∧
    p9MatrixEmbeddingCheckAssumption

theorem p9EmbeddingAssumption_of_checkAssumption
  (hCheck : p9EmbeddingCheckAssumption) :
  p9EmbeddingAssumption := by
  exact ⟨
    p9ElemEmbeddingAssumption_from_defs,
    p9VecEmbeddingAssumption_of_checkAssumption hCheck.1,
    p9MatrixEmbeddingAssumption_of_checkAssumption hCheck.2
  ⟩

theorem p9EmbeddingCheckAssumption_of_assumption
  (hAssm : p9EmbeddingAssumption) :
  p9EmbeddingCheckAssumption := by
  exact ⟨
    p9VecEmbeddingCheckAssumption_of_assumption hAssm.2.1,
    p9MatrixEmbeddingCheckAssumption_of_assumption hAssm.2.2
  ⟩

theorem p9EmbeddingAssumption_iff_checkAssumption :
  p9EmbeddingCheckAssumption ↔
    (p9VecEmbeddingAssumption ∧ p9MatrixEmbeddingAssumption) := by
  constructor
  · intro hCheck
    exact ⟨
      p9VecEmbeddingAssumption_of_checkAssumption hCheck.1,
      p9MatrixEmbeddingAssumption_of_checkAssumption hCheck.2
    ⟩
  · intro hAssm
    exact ⟨
      p9VecEmbeddingCheckAssumption_of_assumption hAssm.1,
      p9MatrixEmbeddingCheckAssumption_of_assumption hAssm.2
    ⟩

theorem p9EmbeddingAssumption_elem
  (hAssm : p9EmbeddingAssumption) :
  p9ElemEmbeddingAssumption := by
  exact hAssm.1

theorem p9EmbeddingAssumption_vec
  (hAssm : p9EmbeddingAssumption) :
  p9VecEmbeddingAssumption := by
  exact hAssm.2.1

theorem p9EmbeddingAssumption_matrix
  (hAssm : p9EmbeddingAssumption) :
  p9MatrixEmbeddingAssumption := by
  exact hAssm.2.2

theorem p9EmbeddingAssumption_holds :
  p9EmbeddingAssumption := by
  exact ⟨
    p9ElemEmbeddingAssumption_from_defs,
    p9VecEmbeddingAssumption_holds,
    p9MatrixEmbeddingAssumption_holds
  ⟩

theorem embeddingVecRoundTrip_true_of_p9VecAssumption
  {z : Array F}
  (hAssm : p9VecEmbeddingAssumption)
  (hMod : z.size % d = 0) :
  embeddingVecRoundTrip z = true := by
  exact embeddingVecRoundTrip_complete ⟨by simp [hMod], hAssm z hMod⟩

theorem embeddingVecRoundTrip_true_of_mod
  {z : Array F}
  (hAssm : p9VecEmbeddingAssumption)
  (hMod : z.size % d = 0) :
  embeddingVecRoundTrip z = true := by
  exact embeddingVecRoundTrip_true_of_p9VecAssumption (hAssm := hAssm) hMod

theorem embeddingMatrixRoundTrip_true_of_p9MatrixAssumption
  {m : Array (Array F)}
  (hAssm : p9MatrixEmbeddingAssumption)
  (hRows : m.all (fun row => row.size % d = 0) = true) :
  embeddingMatrixRoundTrip m = true := by
  exact embeddingMatrixRoundTrip_complete ⟨hRows, hAssm m hRows⟩

theorem embeddingMatrixRoundTrip_true_of_rows_mod
  {m : Array (Array F)}
  (hAssm : p9MatrixEmbeddingAssumption)
  (hRows : m.all (fun row => row.size % d = 0) = true) :
  embeddingMatrixRoundTrip m = true := by
  exact embeddingMatrixRoundTrip_true_of_p9MatrixAssumption (hAssm := hAssm) hRows

theorem embeddingVecRoundTrip_true_of_p9EmbeddingAssumption
  {z : Array F}
  (hAssm : p9EmbeddingAssumption)
  (hMod : z.size % d = 0) :
  embeddingVecRoundTrip z = true := by
  exact embeddingVecRoundTrip_true_of_p9VecAssumption
    (hAssm := p9EmbeddingAssumption_vec hAssm) hMod

theorem embeddingMatrixRoundTrip_true_of_p9EmbeddingAssumption
  {m : Array (Array F)}
  (hAssm : p9EmbeddingAssumption)
  (hRows : m.all (fun row => row.size % d = 0) = true) :
  embeddingMatrixRoundTrip m = true := by
  exact embeddingMatrixRoundTrip_true_of_p9MatrixAssumption
    (hAssm := p9EmbeddingAssumption_matrix hAssm) hRows

/-- Small executable sanity check for embedding round-trip. -/
def embeddingSanity : Bool :=
  let z := ((List.range (2 * d)).toArray).map F.ofNat
  embeddingVecRoundTrip z

end SuperNeo
