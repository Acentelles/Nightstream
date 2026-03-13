# RV64TraceShard

## Purpose

- **What it is**: The maintained product-facing RV64IM trace-wiring path for `neo-fold`.
- **What it owns**: The maintained ELF/program loading path, RV64 trace preparation, prove/verify execution over that trace, and the result-bundle surface for consumers and exporters.
- **Routing boundary**: All instruction routing and state-transition glue lives in the main-lane CCS as uniform flag-gated constraints (Jolt model). This includes decode routing, control-flow routing, register writeback routing, and all load/store width routing (LB/LBU/LH/LHU/LW/LWU/LD/SB/SH/SW/SD). No frontend decode or width transport exists. No fake Shout transport tables exist. Maintained RV64 does not schedule a Route-A decode stage. The sidecar owns only real Twist, real Shout, and virtual decomposition.
- **What it must not do**: Become the owner of shard/session theorem semantics or quietly diverge from the maintained lower shard/session contracts.

## Architectural Position

- **Layer**: frontend
- **Direct paper theorem owner?** No. This module is a frontend adapter from machine/program traces into the lower session/shard proof system under the Jolt execution model.
- **Consumes lower-layer semantics from**: [Session.spec.md](crates/neo-fold/specs/Session.spec.md), [ShardFolding.spec.md](crates/neo-fold/specs/ShardFolding.spec.md), [OutputBinding.spec.md](crates/neo-fold/specs/OutputBinding.spec.md)
- **Exports semantics to**: integration tests, artifact/session exporters, maintained product-facing consumers
- **Erasure rule**: projecting away frontend convenience structure must preserve the lower shard/session artifact and proof meaning.

## Target Formulas (Paper -> Rust)

| Paper/architecture notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| supported RV64 program input and machine-state initialization | Jolt execution model | `Rv64TraceWiring::from_elf`, `ram_init_u32`, `ram_init_u64`, `reg_init_u64` | Maintained RV64 program and state-loading path |
| prepared program / trace preprocessing | implementation support | `Rv64PreparedProgram`, `prepare`, `simulate` | Preprocessed program/input state and simulation |
| routing boundary | implementation support | `Rv64TraceWiring::prove`, RV64 trace metadata columns, main-lane CCS constraints | All routing/glue constraints live in the main-lane CCS. No frontend decode or width transport. No fake Shout transport tables. No maintained-RV64 Route-A decode stage. Sidecar owns only real Twist/Shout and virtual decomposition. |
| trace-proving configuration | implementation support | `profile`, `min_trace_len`, `chunk_rows`, `max_steps`, `mode`, output-claim methods | Maintained proof-path configuration |
| prove run | implementation support | `Rv64TraceWiring::prove` | Executes the maintained proof run |
| prove/verify result bundle | implementation support | `Rv64TraceWiringRun` | Holds proof, CCS, layout, outputs, and profiling information |

## Direct Paper Anchors

This module is not a direct paper-theorem owner.

## Context Anchors

- `crates/neo-fold/specs/Architecture.spec.md`
- `docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md`
  - use this for the architecture-level machine/execution model
- `docs/jolt-paper/13-B_Overview_of_Memory-Checking_Arguments.md`
  - use this for the memory-checking context that the sidecar/shard path relies on
- `docs/architecture/how-superneo-works.md`
  - use this for how the maintained RV64 path feeds the shard/session proof system
- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
  - the RV64 path is a frontend into this folded proof pipeline, not a separate theorem owner

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `formal/superneo-lean/specs/RustRefinement/NeoFoldArtifactValidation.spec.md` | `SuperNeo/NeoFoldArtifactValidation.lean` | Validates exported artifacts from maintained runs |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldSessionValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldSessionValidation.lean` | Validates maintained session families |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldRefinement.spec.md` | `SuperNeo/RustRefinement/NeoFoldRefinement.lean` | Conservative-extension theorem layer for exported maintained artifacts/sessions |

## Contract Surface

### Configuration / preparation

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `Rv64TraceProvePhaseDurations` | struct | Support | Per-phase timing report |
| `Rv64TraceWiring` | struct | Core | Maintained trace-wiring entrypoint |
| `Rv64PreparedProgram` | struct | Core | Prepared program state |
| `Rv64TraceWiring::from_elf` | fn | Core | Constructs the maintained path from ELF bytes |
| `profile`, `min_trace_len`, `chunk_rows`, `max_steps`, `mode` | methods | Config | Maintained proof-path configuration |
| `ram_init_u32`, `ram_init_u64`, `reg_init_u64` | methods | Config | Initial machine state |
| `output_claim`, `reg_output_claim`, `reg_output_claim_exact_u64` | methods | Config | Output-binding declarations |
| `loaded_program`, `elf_bytes`, `prepare`, `simulate` | methods | Inspect/Core | Program/trace preparation and inspection |
| `Rv64PreparedProgram::program_instruction_pairs`, `program_instructions`, `simulate` | methods | Inspect/Core | Prepared-program inspection and simulation |

### Run/result surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `Rv64TraceWiring::prove` | fn | Core | Executes one maintained proof run |
| `Rv64TraceWiringRun` | struct | Core | Maintained result bundle |
| `params`, `committer`, `ccs`, `layout`, `exec_table`, `proof` | methods | Inspector | Core result accessors |
| `used_memory_ids`, `used_shout_table_ids`, `profile_config`, `memory_layout` | methods | Inspector | Sidecar/profile context |
| `steps_public` | fn | Inspector | Exported public step instances |
| `verify_proof`, `verify` | fn | Core | Maintained verification |
| `ccs_num_constraints`, `ccs_num_variables`, `trace_len`, `fold_count` | methods | Inspector | Size/count summary |
| `prove_duration`, `prove_phase_durations`, `verify_duration` | methods | Inspector | Timing summary |

### Internal-but-spec-relevant support

| Rust surface | Role | Why it is spec-relevant |
|---|---|---|
| `rv64_ram_bridge` (internal support) | Implementation support | It mediates RAM/output-binding coherence for the maintained RV64 path even though it is not public API |

## Invariant Obligations

| Invariant | Why it matters | How it should be checked |
|---|---|---|
| Maintained RV64 trace runs produce shard/session inputs accepted by the maintained proving path | Core frontend contract | Integration tests and runtime checks |
| Output binding and linking are wired consistently with lower shard/session semantics | Prevents frontend-specific semantic drift | Integration tests and refinement corpus |
| No frontend decode or width transport exists, and no maintained-RV64 Route-A decode stage exists | Prevents fake transport anti-pattern from reappearing | Integration tests and runtime checks |
| All routing/glue constraints live in the main-lane CCS, not in Route-A sidecar residuals | Prevents routing from drifting back into the sidecar | Integration tests and runtime checks |
| No fake Shout transport tables exist — every Shout table performs real lookup verification | Prevents transport-only anti-pattern from reappearing | Integration tests and runtime checks |
| Unsupported or malformed programs/configurations fail cleanly | Prevents weakened semantics through partial execution | Tests and API behavior |
| Internal RAM bridge support remains aligned with maintained semantics | Prevents hidden frontend divergence | Integration tests and review |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Jolt/RISC-V execution machinery below this layer is correct | supporting crates | This module is a frontend bridge, not a theorem owner |
| Internal `rv64_ram_bridge` support remains aligned with maintained semantics | sibling internal implementation support | Required for RAM/output-binding coherence |
| Lower shard/session semantics are maintained elsewhere | `neo-fold::session`, `neo-fold::shard` | This module must feed them, not redefine them |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-fold::session`
- `neo-fold::shard`
- `neo-fold::output_binding`
- internal `rv64_ram_bridge` support

Primary consumers:
- integration tests
- Rust artifact/session exporters

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| real exported artifacts from maintained runs | accepted by Lean artifact validator |
| real exported sessions from maintained runs | accepted by session validator and session refinement validator |
| projected paper-core obligations for exported maintained runs | remain true after erasing Rust-only sidecars |

## Quality Expectations

- This module should define the maintained product path explicitly.
- Legacy/reference behavior must not dictate maintained-path semantics.
- Output-binding and linking options should remain obvious and intentional.
- No routing, decode, control, or width constraints in the sidecar — all belong to main-lane CCS.
- No fake transport tables — every Shout table performs real lookup verification.
- No frontend decode or width transport of any kind.

## Acceptance Criteria

1. Maintained RV64 runs can prove and verify successfully for supported examples.
2. Output-binding integration remains green on the maintained path.
3. Real exported maintained artifacts and sessions satisfy the Rust↔Lean refinement validators.

## Out of Scope

- Generic shard/session theorem ownership
