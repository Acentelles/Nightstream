# ChunkLayout Spec

## Purpose

- **What it is**: The theorem-owned partition of prepared steps into public proof chunks induced by `FoldSchedule`.
- **What it is not**: It is not a Rust-exported chunk summary and it does not trust an exported chunk count as an authority.
- **Protocol role**: It gives Lean one canonical meaning of when folding occurs, so chunk count and chunk boundaries are recomputed rather than trusted.

## Target Formulas

- `WholeTrace` means one chunk:

$$
\mathrm{layout}(\mathrm{WholeTrace}, n) = [(0, n)].
$$

- `RowsPerChunk(k)` means the canonical contiguous partition of width `k`:

$$
\mathrm{layout}(\mathrm{RowsPerChunk}(k), n)
=
[(0, \min(k,n)), (k, \min(2k,n)), \dots].
$$

- Layout length is derived from the schedule:

$$
|\mathrm{layout}(s, n)| = \mathrm{chunkCount}(s, n).
$$

- Every row index is routed by the schedule to an in-bounds chunk index:

$$
i < n \implies \mathrm{chunkIndexOf}(s, i) < \mathrm{chunkCount}(s, n).
$$

## Theorem Targets

- `ChunkLayout.chunkIndexOf`
- `ChunkLayout.layout_wholeTrace`
- `ChunkLayout.layout_length_eq_chunkCount`
- `ChunkLayout.coveredRows_wholeTrace`
- `ChunkLayout.chunkIndexOf_wholeTrace`
- `ChunkLayout.chunkIndexOf_lt_chunkCount_of_lt_preparedStepCount`

## Dependency and Consumer Map

- **Depends on**: `Nightstream/FoldSchedule.lean`
- **Consumed by**:
  - RV64IM accepted-artifact backend refinement
  - RV64IM accepted checker
  - release/staged bridge schedule parity checks

## Out of Scope

- backend `Π_CCS / Π_RLC / Π_DEC` verification
- Rust refinement by itself
- stage-local execution semantics
