# InstructionLookup

## Purpose

- **What it is**: The dedicated opcode/instruction lookup proving owner for maintained hot-path lookup families in `neo-fold`.
- **What it owns**: Maintained opcode-family lookup proving strategy, decomposable/chunked lookup planning for dense families, packed/combined/direct family specializations for smaller semantic key spaces, and the proof material that binds those lookup results into shard verification.
- **What it does not own**: RAM/register consistency, generic Route-A memory verification, output binding, shard/session orchestration, or main-lane routing/glue constraints.
- **What it must not do**: Collapse back into generic bit-addressed Route-A/Shout fallback for maintained hot opcode families, or force memory/output-binding architecture to share its internal lookup encoding.

## Architectural Position

- **Layer**: extension
- **Direct paper theorem owner?** No. This is a dedicated Rust protocol owner shaped by the Jolt instruction-lookup and Spartan integration model, not a SuperNeo Section 7 theorem owner.
- **Consumes lower-layer semantics from**: Jolt-style machine/trace frontends, opcode table semantics from `neo-memory`, and lower transcript/arithmetic crates
- **Exports semantics to**: [ShardFolding.spec.md](crates/deprecated-neo-fold/specs/ShardFolding.spec.md), [TimeOpening.spec.md](crates/deprecated-neo-fold/specs/TimeOpening.spec.md), [ShardProofTypes.spec.md](crates/deprecated-neo-fold/specs/ShardProofTypes.spec.md), maintained trace frontends
- **Erasure rule**: erasing Rust-only exporter metadata must preserve the same instruction-lookup claims, openings, and verifier obligations.

## Target Formulas (Paper -> Rust)

| Paper/architecture notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| decomposable instruction evaluation tables | Jolt §4-§6 | `LutTableSpec::RiscvOpcode`, `LutTableSpec::RiscvOpcodePacked` | One owner for opcode-family lookup key shape and lookup family selection on the maintained RV64 path |
| chunked address-equality lookup support | Jolt §4; decomposability analysis | chunked/decomposable lookup support under `neo-memory::riscv::sparse_access` | Support surface for InstructionRa-like lookup protocols without baking the maintained path into a bit-addressed key shape |
| opcode-family specialization from architectural operands | implementation support | packed-key derivation and opcode-family table selection in maintained frontend/circuit builders | Packed/combined/direct families derive witness keys from architectural operands instead of re-decoding a generic bit key |
| instruction lookup fed directly into the maintained proving path | Jolt §7 + Spartan integration | maintained frontend lookup planning, shard proof extension inputs, exported lookup proof data | Maintained hot opcode lookup bypasses generic Route-A/Shout as the default proving owner |

## Direct Paper Anchors

- `docs/jolt-paper/05-4_Analyzing_MLE-structure_and_Decomposability.md`
  - use this for chunked/decomposable instruction lookup structure
- `docs/jolt-paper/06-5_Evaluation_Tables_for_the_Base_Instruction_Set.md`
  - use this for dense opcode-family evaluation-table decomposition
- `docs/jolt-paper/08-7_Putting_It_all_Together_a_SNARK_for_RISC-V_Emulation.md`
  - use this for the Spartan-fed instruction-lookup integration story

## Context Anchors

- `crates/deprecated-neo-fold/specs/Architecture.spec.md`
- `docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md`
  - use this for the machine/execution-model context behind maintained opcode lookup
- `docs/architecture/how-superneo-works.md`
  - use this for how the dedicated instruction-lookup subsystem fits the overall Rust proving pipeline

## Contract Surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `LutTableSpec::RiscvOpcode` | enum variant | Core | Generic opcode-table surface; not the required hot-path owner for maintained dense families |
| `LutTableSpec::RiscvOpcodePacked` | enum variant | Core | Packed lookup-family surface for maintained specialized opcode families |
| chunked/decomposable lookup support under `neo-memory::riscv::sparse_access` | support surface | Support/Core | Chunk-native lookup-equality support for dense maintained opcode families where decomposable address planning beats plain bit addressing |

## Invariant Obligations

| ID | Invariant | Lean/paper anchor | Why it matters |
|---|---|---|---|
| `IL-1` | Maintained hot opcode families are owned by the dedicated instruction-lookup subsystem rather than generic Route-A/Shout fallback | architecture contract | Prevents the maintained fast path from silently regressing to the generic bit-addressed lookup path |
| `IL-2` | Dense opcode families may use chunked/decomposable lookup proving without forcing all families into one uniform key shape | Jolt decomposability model | Preserves the main performance reason for introducing this subsystem |
| `IL-3` | Packed/combined/direct families derive their lookup witnesses from architectural operands, not by reinterpreting a generic bit-addressed key after the fact | maintained opcode-family specialization contract | Prevents redundant witness encodings and keeps specialized families cheap |
| `IL-4` | Any emitted instruction-lookup tables perform real lookup verification rather than transport-only bookkeeping | maintained lookup contract | Prevents fake lookup tables from reappearing under a new owner |
| `IL-5` | Instruction-lookup proof data binds into shard verification in a prover/verifier-consistent order | shard/export validator contract | Prevents transcript drift at the extension boundary |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Jolt-style decomposable instruction lookup is the right architecture template for maintained hot opcode families | Jolt docs | This layer intentionally copies the ownership model even when it retunes parameters |
| Main-lane routing and CPU witness semantics are correct | maintained frontends + shard/session layers | Instruction lookup consumes routed opcode-family operands; it does not define CPU semantics |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-memory`
- `neo-ccs`
- `neo-transcript`
- `neo-math`

Primary consumers:
- `neo-fold::shard`
- maintained trace frontends
- Rust artifact/session exporters

## Lean Oracle and Refinement Conformance

This subsystem must refine the lower shard/session artifact boundary conservatively. Dedicated Rust↔Lean validation hooks may be added, but erasing Rust-only metadata must preserve the same projected folded obligations.

## Quality Expectations

- Maintained opcode lookup must have one obvious owner.
- Dense and packed opcode families may use different proving strategies when that improves performance.
- Generic bit-addressed lookup compatibility may exist, but it must not define the maintained hot path.

## Acceptance Criteria

1. Maintained hot opcode families are proved through the dedicated instruction-lookup owner.
2. Dense and specialized opcode families each use an explicit proving strategy rather than a one-size-fits-all fallback.
3. Instruction-lookup proof material binds into shard verification without transcript or artifact drift.

## Out of Scope

- RAM/register consistency
- Output binding
- Session orchestration
- Final theorem composition
