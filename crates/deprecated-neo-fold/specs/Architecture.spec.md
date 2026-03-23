# NeoFoldArchitecture

## Purpose

- **What it is**: The crate-level architecture map for `neo-fold` as the Rust orchestration and integration layer around the SuperNeo folding core.
- **What it owns**: The layering contract between paper-core folding semantics, dedicated instruction-lookup proving, memory-side Route-A/time-opening extensions, Jolt-style frontend adapters, and Rust-only strengthenings.
- **What it must not do**: Recast frontend or strengthening behavior as if it were part of the Section 7 theorem surface.

## Layer Stack

| Layer | Owner specs/modules | Anchor | Role |
|---|---|---|---|
| paper-core folding | `ShardFolding`, Lean `FoldingProtocol` | SuperNeo §7.2-§7.5 | Realizes `Π_CCS`, `Π_RLC`, `Π_DEC` and produces outgoing obligations |
| instruction lookup | `InstructionLookup` | Jolt §4-§7 + Spartan integration | Proves maintained opcode lookup membership with a dedicated owner: chunked/decomposable families for dense tables and packed/combined/direct families for smaller semantic key spaces. Does not own RAM/register consistency or main-lane routing/glue. |
| memory sidecar | `MemorySidecar` | Twist §5 + residual generic lookup | Proves real Twist (RAM/register consistency), virtual decomposition (MUL/DIV), and precompile/memory-side sidecar checks. It does not own maintained-RV64 routing glue, register-address binding, branch-conditioned `pc_after`, or maintained hot opcode lookup proving. |
| time/opening reduction | `TimeOpening` | extension opening layer | Reduces extension time/opening claims from memory-side and instruction-lookup subsystems into grouped opening and joint-opening obligations. |
| proof-data boundary | `ShardProofTypes` | Rust artifact/refinement layer | Exports the combined artifact with explicit separation between core, extension, and metadata fields |
| orchestration | `Session` | architecture-level | Carries accumulators across shards and invokes lower layers |
| frontends | `RV64TraceShard`, shared-bus APIs in `Session` | Jolt §3 | Turns machine/program traces into step bundles and extension inputs for shard proving |
| Rust-only strengthenings | `OutputBinding`, step linking, `Finalize` | implementation-level | Strengthen or finalize acceptance without changing lower-layer proof meaning |

## Erasure and Refinement Rules

- Erasing Rust-only strengthening metadata must preserve the lower accepted shard or session artifact.
- Projecting away frontend convenience structure must preserve the lower proof meaning.
- The paper-core refinement target is the Section 7 obligation surface, not the frontend or strengthening API.

## Direct Paper Anchors

- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
  - use this for the paper-core folding layer (`Π_CCS`, `Π_RLC`, `Π_DEC`)
- `docs/twist-and-shout-paper/4_the_shout_piop.md`
  - use this only for residual generic Shout context; maintained hot opcode lookup ownership is separate
- `docs/twist-and-shout-paper/5_the_twist_piop.md`
  - use this for the Twist memory-side extension layer
- `docs/jolt-paper/05-4_Analyzing_MLE-structure_and_Decomposability.md`
  - use this for the dedicated instruction-lookup decomposition layer
- `docs/jolt-paper/08-7_Putting_It_all_Together_a_SNARK_for_RISC-V_Emulation.md`
  - use this for the Spartan-fed instruction-lookup integration story

## Context Anchors

- `docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md`
  - use this for the execution-model context behind the frontend adapters
- `docs/architecture/how-superneo-works.md`
  - use this for the repo-specific integration story across layers
- `formal/superneo-lean/SuperNeo.pdf.md`
  - use this for the full formalized paper backdrop; the architecture spec itself is not a theorem owner

## Acceptance Criteria

1. Every `neo-fold` spec identifies its architectural position explicitly.
2. The crate-level layering story is readable without reverse-engineering it from source files.
3. Rust-only strengthenings and frontend adapters are clearly distinguished from direct theorem owners.
