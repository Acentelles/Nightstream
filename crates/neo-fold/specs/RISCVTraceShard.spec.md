# RISCVTraceShard

## Purpose

- **What it is**: The legacy/internal RV32 reference trace-wiring path retained for regression, debugging, exporter coverage, and reference families in the Rust↔Lean refinement corpus.
- **What it owns**: The RV32 ROM/program loading path, legacy prove/verify configuration, and the reference result-bundle surface.
- **What it must not do**: Become the owner of maintained product policy or redefine the lower shard/session contracts.

## Architectural Position

- **Layer**: frontend
- **Direct paper theorem owner?** No. This module is a legacy/reference frontend adapter from machine/program traces into the lower session/shard proof system under the Jolt execution model.
- **Consumes lower-layer semantics from**: [Session.spec.md](crates/neo-fold/specs/Session.spec.md), [ShardFolding.spec.md](crates/neo-fold/specs/ShardFolding.spec.md), [OutputBinding.spec.md](crates/neo-fold/specs/OutputBinding.spec.md)
- **Exports semantics to**: regression/reference tests and Rust refinement exporters
- **Erasure rule**: projecting away frontend convenience structure must preserve the lower shard/session artifact and proof meaning.

## Target Formulas (Paper -> Rust)

| Paper/architecture notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| legacy/reference trace-wiring configuration | Jolt execution model as adapted to the older RV32/reference path | `Rv32TraceWiring` builder methods | Internal/reference proof-path configuration |
| legacy prove run | implementation support | `Rv32TraceWiring::prove` | Executes one reference proof run |
| legacy result bundle | implementation support | `Rv32TraceWiringRun` | Holds proof and exported run state |
| step-linking, output-binding, and shout/lookup configuration for the reference path | implementation support | `step_linking_*`, `output*`, `shout_*`, `extra_*` methods on `Rv32TraceWiringRun`/`Rv32TraceWiring` | Reference-path context surface |

## Direct Paper Anchors

This module is not a direct paper-theorem owner.

## Context Anchors

- `crates/neo-fold/specs/Architecture.spec.md`
- `docs/architecture/how-superneo-works.md`
  - use this for how the reference path still feeds the same lower shard/session proof system
- `docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md`
  - use this for the architecture/execution backdrop
- `docs/jolt-paper/13-B_Overview_of_Memory-Checking_Arguments.md`
  - use this for the memory-checking backdrop that the sidecar path relies on
  
This module does not define the maintained product contract. It is a legacy/reference frontend over the same lower shard/session proof system.

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `formal/superneo-lean/specs/RustRefinement/NeoFoldArtifactValidation.spec.md` | `SuperNeo/NeoFoldArtifactValidation.lean` | Exported reference artifacts are validated here |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldSessionValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldSessionValidation.lean` | Exported reference sessions are validated here |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldRefinement.spec.md` | `SuperNeo/RustRefinement/NeoFoldRefinement.lean` | Conservative-extension theorem layer for exported reference cases |

## Contract Surface

### Configuration / proving

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `Rv32TraceProvePhaseDurations` | struct | Support | Per-phase timing report |
| `Rv32TraceWiring` | struct | Core | Legacy/reference trace-wiring entrypoint |
| `Rv32TraceWiring::from_rom` | fn | Core | Constructs the reference path from ROM bytes |
| `xlen`, `min_trace_len`, `chunk_rows`, `shared_cpu_bus`, `max_steps`, `mode` | methods | Config | Proof-path configuration |
| `ram_init_u32`, `reg_init_u32` | methods | Config | Initial machine state |
| `output`, `output_claim`, `reg_output`, `reg_output_claim` | methods | Config | Output declarations |
| `shout_auto_minimal`, `shout_ops`, `extra_lut_table_spec`, `extra_shout_bus_specs` | methods | Config | Reference-path shout/lookup configuration |
| `prove` | fn | Core | Executes one reference proof run |

### Run/result surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `Rv32TraceWiringRun` | struct | Core | Reference result bundle |
| `params`, `committer`, `ccs`, `layout`, `exec_table`, `proof` | methods | Inspector | Core result accessors |
| `step_linking_pairs`, `step_linking_config` | methods | Inspector | Linking context |
| `used_memory_ids`, `used_shout_table_ids`, `requires_poseidon_stage` | methods | Inspector | Sidecar/profile context |
| `output_binding_cfg`, `output_binding_target_state` | methods | Inspector | Output-binding context |
| `verify_proof`, `verify` | fn | Core | Reference verification |
| `ccs_num_constraints`, `ccs_num_variables`, `uniform_ccs_num_variables`, `trace_len`, `fold_count` | methods | Inspector | Size/count summary |
| `prove_duration`, `prove_phase_durations`, `verify_duration` | methods | Inspector | Timing summary |
| `steps_public`, `steps_witness` | methods | Inspector | Exported proof inputs |

## Invariant Obligations

| Invariant | Why it matters | How it should be checked |
|---|---|---|
| Reference-path runs still satisfy the maintained lower shard/session contracts | Prevents regression/reference drift | Integration tests and Lean refinement exporters |
| Legacy convenience options do not redefine maintained protocol semantics | Keeps product-path ownership clear | API review and documentation |
| Exported reference artifacts and sessions remain valid Rust↔Lean refinement cases | Keeps the reference corpus useful | Slow-lane validators and generated-corpus tests |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Lower shard/session semantics are maintained elsewhere | `neo-fold::session`, `neo-fold::shard` | This path is a frontend over them |
| Legacy/reference status is preserved in docs and API usage | repo policy | Consumers should not mistake this for the maintained product path |

## Dependency and Consumer Map

Primary consumers:
- regression/reference tests
- Rust artifact/session exporters for reference families

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| exported RV32/reference artifacts included in the corpus | accepted by Lean artifact validator |
| exported RV32/reference sessions included in the corpus | accepted by session validator and session refinement validator |

## Quality Expectations

- This module must stay clearly marked as legacy/internal/reference.
- It should not become the owner of maintained protocol policy.
- Extra convenience configuration should not redefine the lower shard/session contracts.

## Acceptance Criteria

1. Included reference scenarios still prove and verify successfully.
2. Included exported reference artifacts and sessions remain usable by the Lean refinement tooling.
3. The reference path does not silently expand into the maintained product contract.

## Out of Scope

- Maintained product-path ownership
- Generic folding theorem ownership
