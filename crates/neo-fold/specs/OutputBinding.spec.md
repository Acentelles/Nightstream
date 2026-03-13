# OutputBinding

## Purpose

- **What it is**: The optional Rust-side strengthening layer that binds frontend-derived terminal outputs to an already-valid folded proof.
- **What it owns**: Output-binding configuration, transcript labels, helper functions for memory-derived terminal values, and small convenience constructors.
- **What it must not do**: Become part of the core acceptance boundary for callers who do not enable output binding, or silently reinterpret the folded obligations.

## Architectural Position

- **Layer**: Rust-only strengthening
- **Direct paper theorem owner?** No. This module is outside the SuperNeo, Twist, and dedicated instruction-lookup theorem surfaces.
- **Consumes lower-layer semantics from**: [Session.spec.md](crates/neo-fold/specs/Session.spec.md), [ShardFolding.spec.md](crates/neo-fold/specs/ShardFolding.spec.md), frontend terminal-state data
- **Exports semantics to**: shard/session verification and Rust refinement validators
- **Erasure rule**: erasing output-binding metadata must leave the same lower accepted shard or session artifact.

## Target Formulas (Paper -> Rust)

| Paper notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| output claim as a strengthening of the execution proof | architecture-level strengthening over the SuperNeo route | `OutputBindingConfig`, `has_output_binding` | Optional stronger acceptance condition layered on top of shard/session verification |
| canonical transcript labels for output-binding claims | implementation support | `OB_INC_TOTAL_LABEL`, `OB_REG_EXACT_LINKAGE_LABEL` | Transcript labels for the two bound output-binding relations |
| minimal output-binding configuration | implementation support | `simple_output_config` | Small convenience constructor for one output-binding target |

## Direct Paper Anchors

This module is not a direct paper-theorem owner.

## Context Anchors

- `crates/neo-fold/specs/Architecture.spec.md`
- `docs/architecture/how-superneo-works.md`
  - use this as the anchor for how output binding fits the Rust proving pipeline
- `docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md`
  - output claims are tied to Jolt-style machine-state evolution and terminal state
- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
  - output binding is a Rust-side strengthening layered over the folded proof path

This module does **not** correspond to a standalone paper theorem. It is an implementation-side strengthening layer over the paper-core proof system.

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `formal/superneo-lean/specs/RustRefinement/NeoFoldArtifactValidation.spec.md` | `SuperNeo/NeoFoldArtifactValidation.lean` | Output-binding fields are validated as Rust-side strengthening metadata |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldSessionValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldSessionValidation.lean` | Defines the exact session-level output-binding statement over exported final target state and claimed outputs via `neoFoldSessionChecks` item `4` |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldRefinement.spec.md` | `SuperNeo/RustRefinement/NeoFoldRefinement.lean` | Exposes `paperSessionGlueAccepts`, `paperSessionGlueChecks`, `paperSessionGlueChecks_implies_paperSessionGlueAccepts`, and `implSessionChecks_refines_paperSessionGlueAccepts` for output-binding-as-strengthening |

## Contract Surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `OutputBindingConfig` | struct | Core | One owner for output-binding expectations: target address/register semantics, optional memory index, and linkage mode |
| `OB_INC_TOTAL_LABEL` | const | Core | Canonical transcript label for increment-total output binding |
| `OB_REG_EXACT_LINKAGE_LABEL` | const | Core | Canonical transcript label for exact register-linkage binding |
| `OutputBindingConfig::new` | fn | Core | Canonical constructor |
| `OutputBindingConfig::with_mem_idx` | fn | Core | Refines binding to one memory index |
| `has_output_binding` | fn | Core | Detects whether a shard proof carries output-binding obligations |
| `simple_output_config` | fn | Convenience | Minimal constructor for one output-binding target |

Internal helpers such as `addr_bits_as_k`, `sample_output_lincomb_weights`, `val_init_from_mem_init`, and `inc_terminal_from_time_openings` are implementation support and are not part of the stable public API contract.

## Invariant Obligations

| ID | Invariant | Lean anchor | Why it matters |
|---|---|---|---|
| `OB-1` | Output binding only strengthens acceptance and does not weaken paper-core obligations | `paperSessionGlueAccepts`; `implSessionChecks_refines_paperSessionGlueAccepts` | Prevents semantic drift between paper proof and Rust implementation |
| `OB-2` | Session-level output-binding statement: if enabled, the final target state has size `2 ^ numBits` and every claimed `(addr, value)` satisfies `addr < 2 ^ numBits ∧ finalTargetState[addr] = value` | `NeoFoldSessionValidation` item `4`; `paperSessionGlueAccepts`; `paperSessionGlueChecks_implies_paperSessionGlueAccepts` | This is the exact theorem-backed condition for output-binding correctness |
| `OB-3` | Transcript labels remain canonical and stable | Rust artifact/session validators | Prevents prover/verifier drift |
| `OB-4` | Convenience constructors produce the same semantic config as explicit construction | Rust unit tests | Prevents convenience drift |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Shard/session core is already correct without output binding | shard/session specs | Output binding is a strengthening feature, not the base proof system |
| The trace frontend reports terminal machine state consistently | trace frontend specs | Output binding consumes those terminal values |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-fold::shard_proof_types`
- `neo-math`

Primary consumers:
- `neo-fold::shard`
- `neo-fold::session`
- RV64 trace frontend
- Rust artifact/session exporters

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| valid output-binding artifact/session cases | accepted by Rust↔Lean validators |
| wrong claimed outputs / wrong linkage | rejected by Rust↔Lean validators |
| projected paper-core obligations | remain valid when Rust-only output-binding metadata is erased, via `implSessionChecks_refines_paperSessionGlueAccepts` |

## Quality Expectations

- Output binding must remain a small, explicit strengthening layer.
- Transcript labels are part of the contract and must not be silently changed.
- Convenience constructors must not outrun the semantics of explicit configuration.

## Acceptance Criteria

1. Correct output claims verify.
2. Wrong output claims fail.
3. Output-binding-enabled artifacts and sessions remain accepted by the Rust↔Lean refinement layer only when the strengthening condition is satisfied.

## Out of Scope

- Core shard/session semantics
- Route-A sidecar claim construction
- Trace execution semantics themselves
