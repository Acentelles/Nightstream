# PiCCS

## Purpose

- **What it is**: Strong interactive-reduction step Pi_CCS that converts CCS claims `(c, x)` into CE claims `(c, X, r, {y_j}, ct)` via a sum-check over the Q polynomial, plus terminal-identity verification.
- **Key invariant**: `prove` produces a proof such that `verify` accepts iff the CCS relation holds: `f(M_1 z, ..., M_t z) = 0` row-wise and the commitment `c = L(Z)` is valid. The reduction is **strong** (Lemma 3): acceptance implies both `ceRelation` and `SumCheckClaimTrue`.
- **Protocol role**: First step in the folding composition `Pi_DEC o Pi_RLC o Pi_CCS` (Theorem 1). Takes CCS claims from the current shard and produces CE claims that feed into Pi_RLC.

## Target Formulas (Paper -> Rust)

| Paper notation | Paper reference | Rust identifier | Notes |
|---|---|---|---|
| `Pi_CCS` | Section 7.3, line 481 | `api::prove`, `api::verify` | Strong interactive reduction |
| `Q(alpha, r) = eq(alpha, beta_a) * eq(r, beta_r) * F(r, alpha)` | Section 7.3, line 490 | Q polynomial in `OptimizedOracle` / `PaperExactOracle` | Sum-check target polynomial |
| `alpha in K^{ell_d}` | Section 7.3, line 483 | `Challenges::alpha` | Ajtai-dimension challenge |
| `beta = (beta_a, beta_r) in K^{ell_d + ell_n}` | Section 7.3, line 484 | `Challenges::beta_a`, `Challenges::beta_r` | Eq-gate challenges |
| `beta_m in K^{ell_m}` | Extension | `Challenges::beta_m` | NC channel column challenge |
| `gamma in K` | Extension | `Challenges::gamma` | Batched witness linear combination weight |
| `T = sum_{x in {0,1}^{ell_n+ell_d}} Q(x)` | Section 7.3, line 491 | `claimed_initial_sum_from_inputs_with_k_mcs` | Claimed sum from ME inputs |
| `y_j = ct(bar(M_j) * z)` (Thm 4) | Section 5, line 384 | CE output `y_ring` | Matrix-vector product via SuperNeo transform |
| `(c, X, r, y, ct)` CE claim | Def 13 | `CeClaim<Cmt, F, K>` | Output type |

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Section 7.3 (Pi_CCS strong interactive reduction), lines 481-548.
- Lemma 3 (Pi_CCS is a strong interactive reduction of CCS to CE), lines 545-546.
- Section 7.1 (Relations), lines 449-465: CCS/CE relation definitions consumed by Pi_CCS.
- Theorem 4 (Matrix-vector product transform), Section 5, lines 384-386: basis for SuperNeo evaluation.
- Appendix D (Proof of Lemma 3): soundness argument.

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `PiCCS.spec.md` | `SuperNeo/PiCCS.lean` | `piCCSStrongStatement` = `ceRelation` AND `SumCheckClaimTrue` |
| `ProofSystem/Folding/PiCCS.spec.md` | `SuperNeo/ProofSystem/Folding/PiCCS.lean` | Proof-system wrapper; `soundness_relations` |
| `ProtocolRelations.spec.md` | `SuperNeo/ProtocolRelations.lean` | `ccsRelation`, `ceRelation`, `ceRelaxedRelation` predicates |
| `InteractiveReductions.spec.md` | `SuperNeo/InteractiveReductions.lean` | `strongCompositionStatement` uses Pi_CCS |

## Contract Surface

| Group | Rust symbol | Kind | Role | Guarantee |
|---|---|---|---|---|
| Prove | `api::prove(mode, tr, params, s, mcs_list, mcs_witnesses, me_inputs, me_witnesses, log)` | fn | Core | Returns `(Vec<CeClaim>, PiCcsProof)` or error |
| Prove | `api::prove_simple(mode, tr, params, s, mcs_list, mcs_witnesses, log)` | fn | Core | k=1 shorthand (no ME inputs) |
| Verify | `api::verify(mode, tr, params, s, mcs_list, me_inputs, me_outputs, proof)` | fn | Core | Returns `Ok(true)` iff proof is valid |
| Mode | `FoldingMode` | enum | Core | `Optimized`, `PaperExact`, `OptimizedWithCrosscheck` |
| Proof | `PiCcsProof` | struct | Core | Contains FE + NC sumcheck rounds, challenges, terminal values |
| Proof | `PiCcsProofVariant::SplitNcV1` | enum variant | Core | Split-NC: separate FE-only + NC-only sumchecks |
| Challenges | `Challenges` | struct | Core | `alpha`, `beta_a`, `beta_r`, `beta_m`, `gamma` |
| Errors | `PiCcsError` | enum | Core | `InvalidInput`, `SumcheckError`, `ExtensionPolicyFailed`, `TranscriptError`, `ProtocolError` |

## Invariant Obligations

| Invariant | Verification method | Lean theorem counterpart |
|---|---|---|
| Prove-verify roundtrip: `verify(prove(valid_witness)) == Ok(true)` | Integration test (existing `k_mcs_end_to_end`) | `piCCSStrong_of_assumptions` |
| Invalid witness rejected: tampered Z fails prove or verify | Integration test | `piCCSStrong_of_ce` (contrapositive) |
| FE sumcheck initial sum matches `T = sum_Q` | Unit test | `sumcheckClaimTrue` |
| NC sumcheck initial sum is zero (pure range check) | Unit test | (none -- Nightstream extension) |
| Terminal identity: verifier RHS matches prover's claimed final value | Unit test | (none -- verified structurally via sumcheck) |
| Engine equivalence: optimized and paper-exact produce same outputs | Integration test (existing `optimized_oracle_me_outputs_match_paper_exact`) | (none) |
| Input validation: empty mcs_list rejected | Unit test | (none) |
| Input validation: shape mismatches rejected | Unit test | (none) |

## Assumption Ledger

| Assumption | Source | Justification |
|---|---|---|
| `SModuleHomomorphism` implementor is binding | neo-ajtai | MSIS hardness (Appendix B.2) |
| Fiat-Shamir challenges are unpredictable | neo-transcript | Random-oracle model |
| CCS structure `s` has valid dimensions (n, m powers of 2) | Caller guarantee | Validated at API boundary |
| Witness norms bounded by `params.b^k` | Caller guarantee | Validated via `validate_packed_witness_nc_range` |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-math`: `F`, `K`, `D`, field arithmetic
- `neo-ajtai`: `Commitment` type
- `neo-ccs`: `CcsStructure`, `CcsClaim`, `CcsWitness`, `CeClaim`, `Mat`, `SModuleHomomorphism`
- `neo-params`: `NeoParams` (b, k, kappa, etc.)
- `neo-transcript`: `Poseidon2Transcript`
- `neo-reductions::sumcheck`: `run_sumcheck_prover`, `verify_sumcheck_rounds`

Downstream consumers:
- `neo-fold::shard`: orchestrates `prove` / `verify` within the shard folding loop
- `neo-fold::session`: sequences Pi_CCS -> Pi_RLC -> Pi_DEC across IVC steps

## Lean Oracle Conformance

| Test file | Oracle family | What it checks |
|---|---|---|
| (none yet) | (none) | Pi_CCS is verified via end-to-end prove/verify roundtrips; Lean spec proves `piCCSStrong_of_assumptions` |

## Quality Expectations

- No `todo!()` or `unimplemented!()` in the contract surface
- All `PiCcsError` variants carry context strings for debugging
- Input validation performed before engine dispatch (fail-fast)
- Transcript binding: all public challenges committed to transcript before sampling

## Acceptance Criteria

- `cargo test -p neo-reductions --release` succeeds
- Spec-derived tests in `spec-tests/pi_ccs.rs` pass
- Existing `k_mcs_end_to_end` and `k_mcs_parity` tests pass
- `cargo clippy -p neo-reductions --all-targets --release -- -D warnings` clean

## Out of Scope

- Oracle implementation details (OptimizedOracle, NcOracle) -- see Engines.spec.md
- RLC/DEC operations -- see PiRLC.spec.md and PiDEC.spec.md
- Shard-level orchestration -- belongs to neo-fold
