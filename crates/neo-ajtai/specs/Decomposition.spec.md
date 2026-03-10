# Decomposition

## Purpose

- **What it is**: Base-b digit decomposition `split_b: F^m -> (F^m)^k` with balanced and non-negative styles, used to reduce norm of committed witnesses in Pi_DEC.
- **Key invariant**: Round-trip `z = Sigma_{i=0}^{k-1} b^i * d_i` and digit bound `||d_j||_inf < b`.
- **Protocol role**: Pi_DEC decomposes high-norm witnesses into `k` low-norm digit vectors, each re-committed and folded separately.

## Target Formulas (Paper -> Rust)

| Paper notation | Paper reference | Rust identifier | Notes |
|---|---|---|---|
| `split_b(z) := (z_1, ..., z_k)` | Section 4, line 294 | `split_b(Z, b, d, m, k, style) -> Vec<Vec<Fq>>` | Split matrix into `k` digit-matrices |
| `z = Sigma b^{i-1} z_i` | Section 4, line 295 | round-trip property | Recomposition identity |
| `\|\|z_i\|\|_inf < b` | Section 4, line 296 | `assert_range_b(Z, b) -> AjtaiResult<()>` | Digit bound assertion |
| `b = 2, k = 14` | Appendix B.2, line 713 | concrete parameters | Default decomposition base |

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Section 4, lines 294-296: `split_b(z) := (z_1, ..., z_k)` with `z = Sigma b^{i-1} z_i` and `||z_i||_inf < b`.
- Section 7.5, lines 585-593: Pi_DEC decomposition reduction.
- Appendix B.2, lines 709-727: concrete `b=2`, `k=14`.

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `Decomp.spec.md` | `SuperNeo/Decomp.lean` | `splitBase2Scalar`, `splitBalancedScalar`, `splitBalancedRoundTripProp` |
| `PiDEC.spec.md` | `SuperNeo/PiDEC.lean` | Decomposition check in the folding protocol |

## Contract Surface

| Group | Rust symbol | Kind | Role | Guarantee |
|---|---|---|---|---|
| Decompose | `decomp_b(z, b, d, style) -> Vec<Fq>` | fn | Core | Column-major base-b digit decomposition |
| Decompose | `decomp_b_row_major(z, b, d, style) -> Vec<Fq>` | fn | Core | Row-major variant (optimized for `b=2,3`) |
| Split | `split_b(Z, b, d, m, k, style) -> Vec<Vec<Fq>>` | fn | Core | Split matrix into `k` digit-matrices |
| Assertion | `assert_range_b(Z, b) -> AjtaiResult<()>` | fn | Core | Range assertion (`|d| < b`) |
| Style | `DecompStyle` | enum | Core | `Balanced \| NonNegative` |

## Invariant Obligations

| Invariant | Verification method | Lean theorem counterpart |
|---|---|---|
| Round-trip: `z = Sigma b^i * d_i` (balanced) | `lean_oracles` (`decomp_v1`) + unit test | `splitBalancedRoundTripProp_holds` |
| Round-trip: `z = Sigma b^i * d_i` (non-negative) | Unit test | (none) |
| Digit bound: all `\|d_j\| < b` (balanced) | `lean_oracles` (`decomp_v1`) + unit test | `splitBase2DigitsWithinBound` |
| Column-major == Row-major (transpose equivalence) | Unit test | (none) |
| `split_b` round-trip: recomposition equals input | Unit test | (none) |
| `assert_range_b` catches out-of-range digits | Unit test | (none) |

## Assumption Ledger

| Assumption | Source | Justification |
|---|---|---|
| Balanced representation is unique for `\|z\| < q/2` | Field arithmetic | Standard signed-digit representation over `F_q` |
| Decomposition base `b` divides field characteristic cleanly | Parameter selection | `b in {2, 3, 5}` are small primes; digit extraction via repeated division is exact |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-math`: `Fq`
- `neo-ajtai::util`: `to_balanced_i64`

Downstream consumers:
- `neo-fold`: shard decomposition
- `neo-reductions`: `Pi_DEC` protocol

## Lean Oracle Conformance

All spec-derived tests (lean oracles + invariant obligations) live in `spec-tests/`.

| Test file | Oracle family | What it checks |
|---|---|---|
| `crates/neo-ajtai/spec-tests/lean_oracles.rs` | `decomp_v1` | Round-trip, digit bounds, recomposition for bases 2, 3, 5 |

## Quality Expectations

- No `unsafe` (enforced crate-wide)
- `decomp_b_row_major` is optimized for `b=2` and `b=3` with specialized branches
- `DecompStyle::Balanced` produces centered digits in `[-(b-1)/2, (b-1)/2]`
- `DecompStyle::NonNegative` produces digits in `[0, b-1]`

## Acceptance Criteria

- `cargo test -p neo-ajtai --release` succeeds
- `decomp_v1` lean oracle family passes
- All invariant obligations have spec-tests
- Round-trip holds for random field elements with bases 2, 3, and 5

## Out of Scope

- NTT-based fast decomposition
- Decomposition over extension field `K`
