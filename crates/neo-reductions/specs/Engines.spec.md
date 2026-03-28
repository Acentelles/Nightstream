# Engines

## Purpose

- **What it is**: Engine trait and backend implementations for Pi_CCS proving/verification: `OptimizedEngine` (production), `PaperExactEngine` (audit reference), and `CrossCheckEngine` (development debugging wrapper).
- **Key invariant**: All engines implement `PiCcsEngine` and produce identical logical outputs (CE claims, proof acceptance) for the same inputs. The optimized engine uses factored algebra and CSC sparse caching for performance; the paper-exact engine uses literal paper formulas.
- **Protocol role**: The engine abstraction enables `FoldingMode`-based dispatch, allowing production use (Optimized), auditability (PaperExact), and development verification (CrossCheck) with the same API surface.

## Target Formulas (Paper -> Rust)

| Paper notation | Paper reference | Rust identifier | Notes |
|---|---|---|---|
| `Q(alpha, r) = eq(alpha, beta_a) * eq(r, beta_r) * F(r, alpha)` | Section 7.3, line 490 | `OptimizedOracle::evals_at`, `PaperExactOracle::evals_at` | FE sumcheck target |
| `Q_nc(s, alpha) = eq(s, beta_m) * eq(alpha, beta_a) * Sigma gamma^i * N_i(...)` | Extension | `NcOracle::evals_at` | NC sumcheck target (norm-check range poly) |
| `eq(p, q) = Pi (1-p_i)(1-q_i) + p_i*q_i` | Standard | `eq_points(p, q)` | Multilinear equality function |
| `chi_r(row)` | Standard | `chi_row_at_bool_point(row, xr_mask)` | Row selector for boolean hypercube |
| `chi_a(rho)` | Standard | `chi_ajtai_at_bool_point(rho, xa_mask)` | Ajtai-dimension selector |
| Terminal identity (RHS) | Section 7.3 | `rhs_terminal_identity_fe`, `rhs_terminal_identity_nc` | Verifier computes RHS to compare against sumcheck final value |

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Section 7.3 (Pi_CCS), lines 481-548: Q polynomial, sumcheck variable order, terminal identity.
- Lemma 3 (Pi_CCS is strong), lines 545-546.
- Section 7.5 (Pi_DEC), lines 585-593: DEC operations shared between engines.

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `PiCCS.spec.md` | `SuperNeo/PiCCS.lean` | Defines the Q polynomial structure that engines evaluate |
| `MatrixTransform.spec.md` | `SuperNeo/MatrixTransform.lean` | `matrixTransformIdentity` underpins SuperNeo evaluations |
| `EvalHom.spec.md` | `SuperNeo/EvalHom.lean` | Theorem 5 linearity used by optimized engine |

## Contract Surface

| Group | Rust symbol | Kind | Role | Guarantee |
|---|---|---|---|---|
| Trait | `PiCcsEngine` | trait | Core | `prove` + `verify` interface for all backends |
| Optimized | `OptimizedEngine` | struct | Core | Production engine with CSC caching and factored algebra |
| PaperExact | `PaperExactEngine` | struct | Core | Literal paper formulas for audit (feature-gated: `paper-exact`) |
| CrossCheck | `CrossCheckEngine<I, R>` | struct | Helper | Wraps inner + reference engine; compares outputs |
| CrossCheck | `CrosscheckCfg` | struct | Helper | Configuration for cross-checking behavior |
| Oracle (opt) | `OptimizedOracle` | struct | Core | FE sumcheck oracle with factored eq-gate and CSC operations |
| Oracle (opt) | `NcOracle` | struct | Core | NC-only sumcheck oracle (split-NC variant) |
| Oracle (opt) | `CcsOracle` | type alias | Core | Alias for `OptimizedOracle` |
| Oracle (ref) | Paper-exact oracle | struct | Helper | Literal Q evaluation (feature-gated) |
| Sparse | `SparseCache<F>` | struct | Core | CSC matrix cache for efficient `A^T * x` |
| Challenges | `Challenges` | struct | Core | `alpha`, `beta_a`, `beta_r`, `beta_m`, `gamma` |
| Common | `eq_points(p, q)` | fn | Core | Multilinear equality `eq(p,q)` |
| RLC/DEC | `RlcDecOps` | trait | Core | `rlc_with_commit`, `dec_children_with_commit` interface |
| RLC/DEC | `OptimizedRlcDec` | struct | Core | Optimized RLC/DEC with optional CSC cache reuse |

## Invariant Obligations

| Invariant | Verification method | Lean theorem counterpart |
|---|---|---|
| Engine equivalence: optimized and paper-exact produce same CE claims | Integration test (existing tests) | (none) |
| Engine equivalence: optimized and paper-exact produce same sumcheck rounds | Integration test | (none) |
| `eq_points` symmetry: `eq(p,q) == eq(q,p)` | Unit test | (none) |
| `eq_points` identity: `eq(p,p) == 1` for boolean points | Unit test | (none) |
| `SparseCache`: CSC format matches dense matrix operations | Unit test | (none) |
| `CrossCheckEngine`: detects intentional mismatches | Unit test | (none) |
| `RlcDecOps`: optimized and paper-exact produce same RLC/DEC results | Integration test | (none) |

## Assumption Ledger

| Assumption | Source | Justification |
|---|---|---|
| `OptimizedOracle` factored algebra is equivalent to paper formulas | Cross-check tests | Validated by `OptimizedWithCrosscheck` mode |
| CSC sparse format produces same matrix-vector products as dense | Unit tests | Standard sparse matrix correctness |
| Paper-exact engine faithfully implements paper formulas | Code review + Lean cross-reference | 1:1 mapping to paper equations |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-reductions::sumcheck`: `RoundOracle`, `run_sumcheck_prover`, `verify_sumcheck_rounds`
- `neo-reductions::common`: balanced splitting, rotation sampling, witness helpers
- `neo-reductions::superneo_eval`: `SuperneoMatrixCache`, `SuperneoLinearForm`
- `neo-ccs`: `CcsStructure`, `CcsMatrix`, `CeClaim`, `Mat`

Downstream consumers:
- `neo-reductions::api`: dispatches to engines based on `FoldingMode`
- `neo-fold`: may use `SparseCache` for cached DEC operations

## Lean Oracle Conformance

| Test file | Oracle family | What it checks |
|---|---|---|
| (none yet) | (none) | Engines verified via cross-check and end-to-end roundtrip tests |

## Quality Expectations

- `PaperExactEngine` and `CrossCheckEngine` are feature-gated behind `paper-exact`
- `OptimizedOracle` uses `SparseCache` for O(nnz) column operations instead of O(n*m) dense scans
- `NcOracle` variable order: first `ell_m` column bits, then `ell_d` Ajtai bits

## Acceptance Criteria

- `cargo test -p neo-reductions --release` succeeds
- Spec-derived tests in `spec-tests/engines.rs` pass
- Existing engine equivalence tests (`optimized_oracle_all_base_equivalence`, `optimized_oracle_me_outputs_match_paper_exact`) pass
- `cargo clippy -p neo-reductions --all-targets --release -- -D warnings` clean

## Out of Scope

- Sumcheck protocol details -- see SumCheck.spec.md
- High-level API -- see PiCCS.spec.md
- SuperNeo evaluation helpers -- see SuperNeoEval.spec.md
