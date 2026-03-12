# neo-fold Naming Cleanup Plan

## Prerequisite

This plan lands **after** the structural reorganization in `PROPOSED_CODE_FILE_REORGANIZATION_PLAN.md` is complete. All file paths below reference the post-reorganization layout.

## Scope

Replace opaque internal stage nicknames (`WB`, `WP`, `W2`, `W3`, `stage8`) with semantic names that describe what each stage actually does. Optionally rename `route_a` and `memory_sidecar` if consensus exists.

This is a **pure rename** — no structural moves, no logic changes, no trait introductions.

## Why This Matters

The current names are internal conventions with no paper or architectural meaning:

- `WB` stands for... booleanity? write-booleanity? No one remembers without reading the code.
- `WP` stands for... quiescence? write-quiescence? Same problem.
- `W2` and `W3` are literally numbered pipeline buckets with no semantic content.
- `stage8` names a pipeline stage by its ordinal position, not what it does.

The structural reorganization already moved files to semantic locations (e.g., `riscv/decode_residuals.rs`), but the code **inside** those files still uses the old names. A developer reading `riscv/decode_residuals.rs` and seeing `W2_SELECTOR_RESIDUAL_COUNT` has to mentally map between the file name and the code name.

---

## The Transcript Label Constraint

**This is the single most important thing in this plan.**

Some of the WB/WP/stage8 names appear as **transcript labels** — byte strings hashed into the Fiat-Shamir transcript. The prover and verifier must agree on these strings exactly. Changing them is a **protocol-breaking change**: existing proofs become unverifiable.

Known protocol-sensitive labels:

| Label | File (post-reorg) |
|---|---|
| `b"fold/wb_lane_start"` | `shard/prover/step.rs` or `shard/verifier/mod.rs` |
| `b"fold/wb_lane_claim_idx"` | same |
| `b"wb/booleanity"` | claim plan / claim builders |
| `b"fold/wp_lane_start"` | same |
| `b"fold/wp_lane_claim_idx"` | same |
| `b"wp/quiescence"` | claim plan / claim builders |
| `b"fold/stage8_lane_start"` | `shard/prover/openings.rs` |
| `b"fold/stage8_lane_group_idx"` | same |
| `b"stage8/unified_fold_digest"` | `time_opening/joint_lane.rs` |
| `b"stage8/unified_fold_bind/v2"` | same |
| `b"stage8/reduction/*"` | `time_opening/reduction.rs` (~20 sub-labels) |
| `b"stage8/reduction_unify/*"` | same |

### Decision: transcript labels stay frozen

This plan **does not rename transcript labels**. The byte strings above remain exactly as they are. If a future protocol version bump happens, the labels can be updated at that time — but that's a protocol decision, not a naming cleanup.

What this means in practice: after the rename, code will read like:

```rust
// The variable name says what it IS; the label says what the protocol calls it
let bit_opening_lane = FoldLane::new(b"fold/wb_lane_start", ...);
```

This is acceptable and self-documenting. The label is a frozen protocol artifact; the variable name is what engineers read.

---

## Rename Map

### Stage nickname renames

| Current prefix | What it actually is | New prefix | Rationale |
|---|---|---|---|
| `wb` / `WB` | `r_time` openings for bit/booleanity checks | `bit_openings` | Describes the payload: opening claims over booleanity columns |
| `wp` / `WP` | `r_time` openings for state/trace columns consumed by downstream residuals | `state_openings` | Describes the payload: the large opening carrier for state columns |
| `w2` / `W2` | RISC-V decode-stage virtual constraint residuals | `decode_residual` | Already the file name after reorganization |
| `w3` / `W3` | RISC-V width/load-store residual stage | `width_residual` | Already the file name after reorganization |
| `stage8` | Final joint opening fold across all Route-A lanes | `joint_opening_fold` | Describes the operation, not the pipeline position |

### Proof-data field renames (shard_proof_types.rs)

| Current field | New field | Type |
|---|---|---|
| `wb_fold` | `bit_opening_fold` | `Vec<TimeFoldStep>` |
| `wb_children` | `bit_opening_children` | count field |
| `wb_me_claims` | `bit_opening_claims` | claim vec |
| `wp_fold` | `state_opening_fold` | `Vec<TimeFoldStep>` |
| `wp_children` | `state_opening_children` | count field |
| `wp_me_claims` | `state_opening_claims` | claim vec |
| `stage8_fold` | `joint_opening_fold` | fold data |
| `stage8_children` | `joint_opening_children` | count field |

### Function renames (representative, not exhaustive)

| Current | New | File (post-reorg) |
|---|---|---|
| `wb_wp_required_for_step_*()` | `bit_state_openings_required_for_step_*()` | `route_a/claims.rs` |
| `build_route_a_wb_wp_time_claims()` | `build_route_a_bit_state_opening_claims()` | `route_a/claims.rs` |
| `riscv_trace_wb_columns()` | `riscv_trace_bit_opening_columns()` | `riscv/trace_openings.rs` |
| `riscv_trace_wp_opening_columns()` | `riscv_trace_state_opening_columns()` | `riscv/trace_openings.rs` |
| `w2_virtual_table_ids()` | `decode_residual_table_ids()` | `riscv/decode_residuals.rs` |
| `w2_virtual_constants_k()` | `decode_residual_constants_k()` | `riscv/decode_residuals.rs` |
| `w2_decode_fields_weighted_residual()` | `decode_fields_weighted_residual()` | `riscv/decode_residuals.rs` |
| `w2_decode_selector_residuals()` | `decode_selector_residuals()` | `riscv/decode_residuals.rs` |
| `w2_decode_bitness_residuals()` | `decode_bitness_residuals()` | `riscv/decode_residuals.rs` |
| `w2_alu_branch_lookup_residuals()` | `decode_alu_branch_lookup_residuals()` | `riscv/decode_residuals.rs` |
| `w2_build_stage_gate_table()` | `decode_build_stage_gate_table()` | `riscv/decode_residuals.rs` |
| `w3_bitness_weight_vector()` | `width_bitness_weight_vector()` | `riscv/trace_semantics.rs` |
| `w3_load_weight_vector()` | `width_load_weight_vector()` | `riscv/trace_semantics.rs` |
| `w3_store_weight_vector()` | `width_store_weight_vector()` | `riscv/trace_semantics.rs` |
| `w3_load_semantics_residuals()` | `width_load_semantics_residuals()` | `riscv/rv64_width_residuals.rs` |
| `w3_store_semantics_residuals()` | `width_store_semantics_residuals()` | `riscv/rv64_width_residuals.rs` |
| `build_stage8_fold_lane_plan()` | `build_joint_opening_fold_plan()` | `time_opening/joint_lane.rs` |
| `stage8_time_decomp_params()` | `joint_opening_time_decomp_params()` | `shard/core_utils/time_columns.rs` |

### Type/struct renames

| Current | New | File |
|---|---|---|
| `W2VirtualTableIds` | `DecodeResidualTableIds` | `riscv/decode_residuals.rs` |
| `W2VirtualConstantsK` | `DecodeResidualConstantsK` | `riscv/decode_residuals.rs` |
| `W2DecodeFieldsOpenings` | `DecodeFieldsOpenings` | `riscv/decode_residuals.rs` |
| `W2ResidualSink` | `DecodeResidualSink` | `riscv/decode_residuals.rs` |
| `W3TimeClaims` | `WidthResidualTimeClaims` | `route_a/claims.rs` |

### Constant renames

| Current | New | File |
|---|---|---|
| `W2_SELECTOR_RESIDUAL_COUNT` | `DECODE_SELECTOR_RESIDUAL_COUNT` | `riscv/decode_residuals.rs` |
| `W2_BITNESS_RESIDUAL_COUNT` | `DECODE_BITNESS_RESIDUAL_COUNT` | `riscv/decode_residuals.rs` |
| `W2_ALU_BRANCH_RESIDUAL_COUNT` | `DECODE_ALU_BRANCH_RESIDUAL_COUNT` | `riscv/decode_residuals.rs` |
| `W2_FIELDS_RESIDUAL_COUNT` | `DECODE_FIELDS_RESIDUAL_COUNT` | `riscv/trace_semantics.rs` |
| `W2_FIELDS_DEGREE_BOUND` | `DECODE_FIELDS_DEGREE_BOUND` | `riscv/decode_residuals.rs` |
| `W2_STAGE_GATE_TABLE_CAP` | `DECODE_STAGE_GATE_TABLE_CAP` | `riscv/decode_residuals.rs` |
| `STAGE8_TIME_DECOMP_BASE` | `JOINT_OPENING_TIME_DECOMP_BASE` | `time_opening/mod.rs` |

### Error message prefix renames

| Current prefix | New prefix | Approx count |
|---|---|---|
| `"W2(shared):"` | `"decode-residual(shared):"` | ~12 occurrences |
| `"W3(rv64):"` | `"width-residual(rv64):"` | ~50 occurrences |

---

## Module/directory renames (lower priority, separate pass)

These are bigger and more disruptive. They should land in a separate commit after the stage nickname renames.

### `route_a` → TBD

| Candidate | Pros | Cons |
|---|---|---|
| `twist_shout` | Paper-protocol naming; Twist and Shout are the two protocols batched here | Requires understanding the papers |
| `batched_time` | Describes the mechanism (batched time-domain sumcheck) | Too generic; doesn't say what's being checked |
| `mem_checking` | Functional (aligns with Jolt paper Section B) | Doesn't capture the Shout/lookup part |

~150+ references to `route_a` / `RouteA` across the crate. This is a large rename but purely mechanical (find-and-replace with review).

### `memory_sidecar` → TBD

| Candidate | Pros | Cons |
|---|---|---|
| `mem_extensions` | Extension proofs for memory/lookups | "Extensions" is overloaded in math |
| `memory_protocol` | The memory-checking protocol layer | Slightly generic |
| `twist_shout` | If the inner `route_a` directory gets a different name | Name collision if route_a also becomes twist_shout |

~200+ references. Even larger than route_a. Consider whether the benefit justifies the churn.

**Recommendation**: Defer both directory renames until the stage nickname renames land and stabilize. Do not attempt all renames in one round.

---

## What This Plan Does NOT Do

- **Does not change transcript labels** — frozen protocol artifacts stay as byte strings
- **Does not introduce traits or generic claim containers** — pure rename
- **Does not move any files** — structural reorganization is already done
- **Does not change any logic** — the code does the same thing with different names
- **Does not rename `route_a` or `memory_sidecar` directories** — those are a separate, lower-priority pass

---

## Impact Assessment

| Metric | Count |
|---|---|
| Total identifier references to rename | ~1,130 across ~40 files |
| Transcript labels (frozen, untouched) | ~30 label strings |
| Proof-data struct fields | ~8 fields in `shard_proof_types.rs` |
| Public functions | ~25 functions |
| Types/structs | ~5 types |
| Constants | ~7 constants |
| Error message prefixes | ~62 occurrences |
| Test files affected | ~10 test files |
| Spec files needing updates | `TimeOpening.spec.md`, possibly others |

---

## Execution Order

Renames should be grouped by stage to keep each commit reviewable:

1. **W2 renames first** — confined almost entirely to `riscv/decode_residuals.rs` and `riscv/trace_semantics.rs`. Smallest blast radius.
2. **W3 renames** — confined to `riscv/rv64_width_residuals.rs` and `riscv/trace_semantics.rs`. Similarly contained.
3. **stage8 renames** — touches `time_opening/joint_lane.rs`, `time_opening/reduction.rs`, `time_opening/mod.rs`, `shard_proof_types.rs`, verifier, prover. Medium blast radius.
4. **WB renames** — touches proof types, prover, verifier, claim builders. Paired naturally with WP.
5. **WP renames** — same files as WB. Do these together in one commit with WB.
6. **Spec and doc updates** — update `TimeOpening.spec.md`, `ShardProofTypes.spec.md`, and any other specs that reference the old names.

Each commit should compile and pass tests before the next rename lands.

---

## Lean-Side Impact

The Lean artifact validators reference proof-data field names. After renaming `wb_fold` → `bit_opening_fold` etc. in `shard_proof_types.rs`:

- The Rust→Lean exporter that serializes proof artifacts will emit the new field names
- The Lean validators need to be updated to expect the new names
- This is a coordinated change: land the Rust rename and Lean validator update together, or add a compatibility mapping in the exporter

**Recommendation**: Check whether the exporter uses Rust field names literally (serde) or maps them to Lean-side names. If it maps, only the Rust side changes. If it uses literal field names, the Lean side must update simultaneously.

---

## Compatibility with the Other-AI Proposal

The other AI proposed the same renames with slightly different target names:

| Stage | Other AI's name | This plan's name | Why this plan's choice |
|---|---|---|---|
| WB | `bit_opening_claims` | `bit_openings` / `bit_opening_*` | Shorter; the suffix (`_fold`, `_claims`, `_children`) already distinguishes the role |
| WP | `state_opening_claims` | `state_openings` / `state_opening_*` | Same reasoning |
| W2 | `decode_residuals` | `decode_residual_*` | Identical intent |
| W3 | `width_residuals` | `width_residual_*` | Identical intent |
| stage8 | `joint_opening_fold` | `joint_opening_fold` / `joint_opening_*` | Identical |

The other AI also proposed replacing `wb_me_claims` / `wp_me_claims` with a generic `Vec<AdapterTimeOpeningClaim>`. This plan **does not do that** — it renames the fields but keeps them typed and named. The generic container is deferred to when VM #2 has real code, per the structural reorganization plan's Design Constraint #3.
