# FoldSchedule Spec

## Purpose

- **What it is**: the theorem-facing fold-cadence surface shared by generic release and staged bridges.
- **What it is not**: it is not a verifier config file and it does not restate any VM-local chunk payload theorem.
- **Protocol role**: it makes fold cadence explicit at the proof boundary, so chunk count is derived from a schedule rather than inferred from an unexplained constant.

## Target Formulas

Define the fold schedule datatype:

$$
\mathrm{FoldSchedule}
:=
\{
\mathrm{WholeTrace},
\mathrm{RowsPerChunk}(r)
\}.
$$

Admissibility is:

$$
\mathrm{Valid}(\mathrm{WholeTrace}),
$$

$$
\mathrm{Valid}(\mathrm{RowsPerChunk}(r))
\iff
0 < r.
$$

Define the derived chunk count for one prepared-step count `n`:

$$
\mathrm{chunkCount}(\mathrm{WholeTrace}, n) = 1.
$$

For a positive `r`, `RowsPerChunk(r)` denotes the exact ceiling partition count
of `n` rows into chunks of size at most `r`.

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Schedule | `FoldSchedule` | inductive | Definitional | Enumerates the theorem-facing fold cadence choices |
| Predicate | `FoldSchedule.Valid` | def | Definitional | Rejects zero-width row chunk schedules |
| Derived count | `FoldSchedule.chunkCount` | def | Definitional | Computes the exact public chunk count implied by a schedule |
| Theorem | `FoldSchedule.valid_wholeTrace` | theorem | Theorem-Target | Whole-trace folding is always admissible |
| Theorem | `FoldSchedule.valid_rowsPerChunk_iff` | theorem | Theorem-Target | Row-chunk admissibility is exactly positive chunk width |
| Theorem | `FoldSchedule.chunkCount_wholeTrace` | theorem | Theorem-Target | Whole-trace folding always yields one public chunk |

## Dependency and Consumer Map

- **Consumed by**:
  - `Nightstream/ReleaseBridge.lean`
  - `Nightstream/StagedBridge.lean`
  - VM-local staged bridge refinements

## Proof Obligations

- Fold cadence must be theorem-owned and explicit; it may not be smuggled in as an implementation convention.
- Public chunk count must be derived from the chosen schedule.
- “No per-row folding” is represented by `WholeTrace`, not by deleting fold cadence from the proof boundary.

## Out of Scope

- VM-local chunk payload semantics
- transcript / PCS instantiation
- final proof packaging
