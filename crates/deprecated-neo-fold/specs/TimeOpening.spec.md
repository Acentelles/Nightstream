# TimeOpening

## Purpose

- **What it is**: The joint-opening fold and time-opening layer that turns time-column obligations into opening manifests, grouped reductions, joint-lane proofs, and final opening unification checks.
- **What it owns**: The canonical opening-claim manifest, the grouped reduction and sampled coefficients, the joint-lane proof plan, the final unification sumcheck, and the `ME`/digit adapter logic used to connect time columns to opening claims.
- **What it must not do**: Redefine shard folding semantics, hide opening obligations behind implementation-only shortcuts, or silently weaken the opening surface that the verifier checks.

## Architectural Position

- **Layer**: extension
- **Direct paper theorem owner?** Yes, for the extension time-opening and joint-opening reduction semantics over memory-side and instruction-lookup claims. It is not itself a Section 7 theorem owner.
- **Consumes lower-layer semantics from**: [MemorySidecar.spec.md](crates/deprecated-neo-fold/specs/MemorySidecar.spec.md), [InstructionLookup.spec.md](crates/deprecated-neo-fold/specs/InstructionLookup.spec.md), lower transcript/math layers
- **Exports semantics to**: [ShardFolding.spec.md](crates/deprecated-neo-fold/specs/ShardFolding.spec.md), [ShardProofTypes.spec.md](crates/deprecated-neo-fold/specs/ShardProofTypes.spec.md), Rust artifact/refinement tooling
- **Erasure rule**: erasing Rust-only exporter metadata must preserve the same opening manifests, grouped reductions, and joint-lane obligations.

In repo terminology, the "Nightstream extension layer" is the combination of dedicated instruction lookup, memory-side Route-A sidecars, and time-opening/joint-opening obligations. This is an architectural umbrella term, not a paper theorem label.

## Target Formulas (Paper -> Rust)

| Paper notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| batched extension time-claim reduction into final opening obligations | extension time-evaluation and batched reduction flow | `build_opening_claim_manifest`, `build_opening_reduction`, `OpeningClaimManifest`, `OpeningReductionProof` | Canonical reduction from memory-side and instruction-lookup time/opening claims to grouped opening checks |
| transcript binding and sampled coefficients for grouped opening reductions | same | `bind_opening_claim_manifest`, `bind_opening_reduction_and_sample_group_coeffs` | Transcript discipline for the reduction surface |
| final opening unification check | same | `prove_opening_unification_sumcheck`, `verify_opening_unification_sumcheck`, `OpeningUnificationProof` | Final proof that grouped opening claims are jointly satisfied |
| joint-opening fold-lane proof | implementation support for the SuperNeo route | `JointOpeningFoldLanePlan`, `build_joint_opening_fold_lane_plan`, `prove_joint_opening_lane*`, `verify_joint_opening_lane` | One owner for the joint-opening lane |
| time-column `ME` / digit transport into opening claims | implementation support | public helpers in `me_adapter.rs` | Concrete adapter layer between time columns, digit decomposition, and opening claims |
| decomposition base for joint-opening time openings | implementation support | `JOINT_OPENING_TIME_DECOMP_BASE` | Shared decomposition base used by the joint-opening path |

## Direct Paper Anchors

- `docs/twist-and-shout-paper/4_the_shout_piop.md`
  - use this only for residual generic-lookup-derived `Shout` time claims, one-hot checks, and batched-time obligations
- `docs/twist-and-shout-paper/5_the_twist_piop.md`
  - use this as the anchor for `Twist` time claims, `Val`-evaluation obligations, and the final sidecar opening path
- `docs/jolt-paper/05-4_Analyzing_MLE-structure_and_Decomposability.md`
  - use this as the context anchor for instruction-lookup-derived opening claims when the maintained hot path uses chunked/decomposable lookup proving

## Context Anchors

- `crates/deprecated-neo-fold/specs/Architecture.spec.md`
- `docs/twist-and-shout-paper/2_overview_of_twist_and_shout_and_their_costs.md`
  - for the two-lane architecture (`main` lane and `val` lane) and why time openings exist
- `docs/architecture/how-superneo-works.md`
  - for how joint-opening/opening obligations fit the overall Rust proving pipeline
- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
  - for how these opening obligations feed the Section 7 pipeline

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `formal/superneo-lean/specs/ProtocolTheorem.spec.md` | `SuperNeo/ProtocolTheorem.lean` | Final theorem consumes the resulting soundness obligations |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldArtifactValidation.spec.md` | `SuperNeo/NeoFoldArtifactValidation.lean` | Defines executable checks for Route-A batched-time transcripts, lane summaries, CE semantics, and `ccs_out.r` consistency on exported artifacts |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldRelationValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldRelationValidation.lean` | Exposes `paperArtifactRelationChecks` and `paperArtifactRelationChecks_implies_paperArtifactStepRelationsAccepts` for projected joint-opening lane folding obligations over real exported artifacts |

## Contract Surface

### Top-level constants

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `JOINT_OPENING_TIME_DECOMP_BASE` | const | Core | Shared decomposition base for joint-opening time-opening logic; prover and verifier must agree on it exactly |

### Manifest and reduction surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `build_opening_claim_manifest` | fn | Core | Builds the canonical opening-claim manifest from time/opening obligations |
| `bind_opening_claim_manifest` | fn | Core | Binds the manifest to the transcript in canonical order |
| `build_opening_reduction` | fn | Core | Groups manifest entries into reduction groups for final checking |
| `bind_opening_reduction_and_sample_group_coeffs` | fn | Core | Transcript-binds the grouped reduction and samples the group coefficients |
| `prove_opening_unification_sumcheck` | fn | Core | Proves the final opening-unification sumcheck over the grouped reduction |
| `verify_opening_unification_sumcheck` | fn | Core | Verifies that unification proof |

### Joint-lane proof surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `JointOpeningFoldLanePlan` | struct | Core | The explicit joint-opening plan for one lane |
| `build_joint_opening_fold_lane_plan` | fn | Core | Canonical planner for joint-opening lane obligations |
| `prove_joint_opening_lane_with_witnesses` | fn | Core | Proves one joint opening lane and returns witness material |
| `prove_joint_opening_lane` | fn | Core | Proves one joint opening lane without witness export |
| `verify_joint_opening_lane` | fn | Core | Verifies one joint opening lane |

### `ME` adapter surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `build_small_chi_table` | fn | Core | Builds the reduced `chi` table used for time-row evaluation |
| `cpu_time_row_weights`, `mem_time_row_weights` | fns | Core | Canonical row-weight definitions for CPU and memory time columns |
| `eval_mat_digits_from_row_weights`, `split_row_weight_coeffs`, `eval_mat_digits_from_row_weight_coeffs`, `eval_mat_digits_from_sparse_row_weight_coeffs` | fns | Core | Digit/evaluation adapters from row weights to matrix-digit evaluations |
| `mat_row_nonzero_entries`, `chi_for_row_index` | fns | Core | Sparse row/`chi` helpers used by the adapter layer |
| `eval_cpu_time_vector_at_point`, `eval_mem_time_vector_at_point`, `eval_time_vector_at_point` | fns | Core | Direct evaluation helpers for time vectors |
| `add_rot_scaled_commitment`, `apply_rot_to_digits` | fns | Core | Commitment/digit transport helpers under rotation |
| `build_logical_col_pos`, `domain_for_col_ids` | fns | Core | Logical column-domain helpers |
| `recompose_digits_to_scalar` | fn | Core | Recombines digit evaluations into scalars |
| `eval_time_mat_digits_at_point`, `eval_time_mat_digits_at_point_with_chi` | fns | Core | Matrix-digit evaluation helpers |
| `ClaimCommitEval` | struct | Core | Commitment/evaluation bundle for one opening claim |
| `claim_commitment_and_eval` | fn | Core | Canonical commitment/evaluation helper |

## Invariant Obligations

| ID | Invariant | Lean anchor | Why it matters |
|---|---|---|---|
| `TO-1` | Opening manifests enumerate exactly the claims the verifier later checks | Rust verifier + artifact validators | Prevents hidden or omitted opening obligations |
| `TO-2` | Reduction groups and sampled coefficients preserve the same opening obligations, not weaker surrogates | Artifact validation over exported opening artifacts | Prevents joint-opening weakening |
| `TO-3` | Joint-lane planning preserves lane/domain separation and required openings | `NeoFoldRelationValidation` item `3`; `paperArtifactRelationChecks`; `paperArtifactRelationChecks_implies_paperArtifactStepRelationsAccepts` | Prevents lane-crossing bugs in the projected joint-opening relation |
| `TO-4` | Extension batched-time transcript and lane-summary validation stay prover/verifier consistent | `NeoFoldArtifactValidation` items `4`, `6`, and `10` | Connects the time-opening path to the real exported artifact checks |
| `TO-5` | The `ME`/digit adapter preserves evaluations, rotations, and commitment transport semantics | Rust adapter/integration tests | Prevents wrong opening values even when proof objects look structurally valid |
| `TO-6` | `JOINT_OPENING_TIME_DECOMP_BASE` remains the agreed decomposition base | Rust constant tests + artifact validation | Prevents prover/verifier mismatch on the joint-opening path |
| `TO-7` | The two-lane architecture is preserved: main-lane and val-lane obligations are not accidentally merged or dropped | artifact validators and integration tests | Prevents weakening of the sidecar soundness story |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Time-column commitments/openings are constructed correctly upstream | shard, instruction-lookup, and memory-sidecar layers | This layer reduces and verifies them; it does not define them |
| Transcript arithmetic and challenge sampling are correct | `neo-transcript` and lower crates | Required for manifest binding, reduction binding, and unification |
| The shard layer feeds this module the correct main-lane/val-lane obligation partition | shard proving path | Joint-lane planning assumes the partition is already meaningful |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-transcript`
- `neo-math`
- `neo-fold::shard_proof_types`

Primary consumers:
- `neo-fold::shard`
- Rust artifact exporters
- Lean artifact/refinement validators

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| exported valid joint-opening/opening artifacts | accepted by Lean artifact validators |
| tampered joint-opening/opening artifacts | rejected by Lean artifact validators |
| projected paper-core relation checks over valid artifacts | remain true after erasing Rust-only sidecars |

## Quality Expectations

- Opening manifests and grouped reductions must remain the single source of truth for joint-opening claim structure.
- Joint-lane planning should stay semantic and explicit; it must not collapse into loosely typed helper bundles.
- The `ME` adapter may be large, but it should remain one coherent owner of time-column-to-opening arithmetic.

## Acceptance Criteria

1. Opening manifests, grouped reductions, and unification proofs remain prover/verifier consistent.
2. Joint-lane proofs verify on valid artifacts and fail on tampered artifacts.
3. Exported joint-opening/opening artifacts are accepted by the Rust↔Lean validators.
4. The joint-opening path preserves the main-lane/val-lane split and does not weaken the final opening obligations.

## Out of Scope

- Session policy
- Trace wiring frontends
- Route-A claim planning
