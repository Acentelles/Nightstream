# NeoFoldArchitecture

## Purpose

- **What it is**: The crate-level architecture map for `neo-fold` as the Rust orchestration and integration layer around the SuperNeo folding core.
- **What it owns**: The layering contract between paper-core folding semantics, Twist/Shout Route-A and time-opening extensions, Jolt-style frontend adapters, and Rust-only strengthenings.
- **What it must not do**: Recast frontend or strengthening behavior as if it were part of the Section 7 theorem surface.

## Layer Stack

| Layer | Owner specs/modules | Anchor | Role |
|---|---|---|---|
| paper-core folding | `ShardFolding`, Lean `FoldingProtocol` | SuperNeo §7.2-§7.5 | Realizes `Π_CCS`, `Π_RLC`, `Π_DEC` and produces outgoing obligations |
| extension proofs | `MemorySidecar`, `TimeOpening` | Twist/Shout §4-§5 | Proves real Twist (RAM/register consistency), real Shout (ALU/opcode lookup membership), virtual decomposition (MUL/DIV), and time-opening/joint-opening obligations. Does not own routing/glue/decode/control/width constraints — those belong to the main-lane CCS. |
| proof-data boundary | `ShardProofTypes` | Rust artifact/refinement layer | Exports the combined artifact with explicit separation between core, extension, and metadata fields |
| orchestration | `Session` | architecture-level | Carries accumulators across shards and invokes lower layers |
| frontends | `RV64TraceShard`, `RISCVTraceShard`, shared-bus APIs in `Session` | Jolt §3 | Turns machine/program traces into step bundles and sidecar inputs |
| Rust-only strengthenings | `OutputBinding`, step linking, `Finalize` | implementation-level | Strengthen or finalize acceptance without changing lower-layer proof meaning |

## Erasure and Refinement Rules

- Erasing Rust-only strengthening metadata must preserve the lower accepted shard or session artifact.
- Projecting away frontend convenience structure must preserve the lower proof meaning.
- The paper-core refinement target is the Section 7 obligation surface, not the frontend or strengthening API.

## Direct Paper Anchors

- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
  - use this for the paper-core folding layer (`Π_CCS`, `Π_RLC`, `Π_DEC`)
- `docs/twist-and-shout-paper/4_the_shout_piop.md`
  - use this for the Shout / Route-A extension layer
- `docs/twist-and-shout-paper/5_the_twist_piop.md`
  - use this for the Twist extension layer

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
