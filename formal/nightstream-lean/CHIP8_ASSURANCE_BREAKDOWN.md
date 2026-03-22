## CHIP-8 Assurance Breakdown

This note is a current-state explanation of what the CHIP-8 Lean/Rust assurance
stack covers today, what it does not yet cover, and how hard the remaining work
looks.

The most important clarification is the project goal:

- the goal is **not** to formally verify the whole Rust implementation
- the goal **is** to make the **protocol** and its **transcript semantics**
  Lean-owned, then check that Rust matches them exactly enough at the right
  boundaries

It is intentionally stateful and explanatory, so it lives outside the timeless
`specs/` tree.

The key distinction is:

- the repo already proves and checks a strong **CHIP-8 kernel theorem path**
- the repo does **not** yet prove the whole Rust implementation line-by-line

## Scope

When this note says "the whole CHIP-8 process", there are two possible meanings:

1. the **theorem-facing CHIP-8 kernel process**
   - exact authenticated rows
   - Stage 1 facts
   - Stage 2 facts
   - Stage 3 continuity
   - row projection
   - bridge/prepared-step alignment
   - staged digest / bundle / release artifact boundaries

2. the **entire Rust implementation**
   - trace executor
   - prover
   - verifier
   - transcript plumbing
   - serialization
   - every internal control-flow path and helper

The current Nightstream Lean stack is already strong on `(1)`.

The repo's practical assurance target is:

- prove `(1)`
- define the protocol/transcript boundary in Lean
- make Rust export matching protocol/transcript data
- have Lean check that Rust matches it

That is much closer than `(2)`.

## What We Actually Care About

For CHIP-8, the meaningful finish line is:

1. Lean owns the **protocol** surfaces
   - Stage 1
   - Stage 2
   - Stage 3
   - bridge/prepared-step handoff
   - staged digest / bundle / release artifact

2. Lean owns the **transcript semantics**
   - labels
   - absorb order
   - payload encoding
   - challenge sampling
   - Poseidon2-over-Goldilocks meaning

3. Rust exports enough data to compare against that Lean-owned meaning

4. Lean checks that Rust matches the protocol and transcript meaning

Under that goal, the main remaining technical item is not "prove all Rust
code." It is "close transcript-call correctness more completely."

## Row-Level Breakdown

Each semantic CHIP-8 row `j` participates in a staged kernel story. The table
below records what exists today.

| Part | What it means per row | Lean status | Rust↔Lean equality/checking | Missing | Difficulty to close |
|---|---|---|---|---|---|
| Exact row/frame exists | There is a concrete authenticated row with pre-state, post-state, decoded instruction, and witness row | `Yes` | `Partial` | not every internal Rust construction step is replayed | `Medium` |
| Public-input binding | Row 0 and chunk input are tied to the public program/state contract | `Yes` | `Mostly theorem-level` | direct artifact replay here is not the main gap | `Low` |
| Stage 1 readonly/authentication | Fetch/decode/public-table facts for row `j` are correct | `Yes` | `Partial` | not every Stage-1 internal transcript step is replayed | `Medium` |
| Stage 2 register history | Register reads/writes for row `j` are tied to the right timeline/session | `Yes` | `Mostly theorem-level` | no full internal transcript replay for all Stage-2 internals | `Medium-High` |
| Stage 2 RAM history | RAM reads/writes for row `j` are tied to the right timeline/session | `Yes` | `Mostly theorem-level` | same as above | `Medium-High` |
| Stage 2 `Val` provenance | A read value comes from the right prior write or authenticated init surface | `Yes` | `Mostly theorem-level` | more direct implementation replay would be extra | `Medium` |
| Non-zero init | Authenticated non-zero init is part of the theorem path | `Yes` | `Mostly theorem-level` | more artifact-level checks are optional, not a blocker | `Low` |
| Lowering/visibility order | The row means the correct CHIP-8 micro-step / visibility semantics | `Yes` | `Spec/theorem aligned` | proving Rust trace execution implements it line-by-line is not done | `Very High` |
| Stage 3 continuity | Row `j` connects correctly to row `j+1` on the active prefix | `Yes` | `Mostly theorem-level` | we do not replay every low-level batching detail in parity lane | `Medium` |
| Padded-domain continuity check | Rust’s padded masked check refines to the row-local theorem | `Yes` | `Theorem aligned` | more direct artifact replay is possible but not critical | `Medium` |
| Row projection | Semantic extraction from the accepted row opening is correct | `Yes` | `Artifact-checked at grouped level` | not every raw opening object is parity-replayed individually | `Medium` |
| Bridge binding | The same row-opening path feeds the prepared-step/root bridge | `Yes` | `Artifact-checked at grouped level` | deeper per-object parity is possible | `Medium` |
| Prepared-step alignment | Row `j` matches the exported prepared step for that row | `Yes` | `Yes, at release-artifact/grouped level` | broader case coverage only | `Low` |

## Chunk / Artifact Breakdown

Some of the critical assurance owners sit above any single row.

| Part | What it means | Lean status | Rust↔Lean equality/checking | Missing | Difficulty |
|---|---|---|---|---|---|
| `root0` / transcript base | Commitments + `meta_pub` + labels + Poseidon2 transcript base are exact | `Yes` | `Yes` | wider corpus only | `Low` |
| Shared Fiat-Shamir challenges | Shared Stage 1 / 2 / 3 challenges are sampled exactly | `Yes` | `Yes` | more challenge families if wanted | `Low-Medium` |
| Single-slice staged digest | One row digest entry has Lean-owned meaning | `Yes` | `Indirectly` | more direct per-entry equality is possible | `Low-Medium` |
| Staged execution digest bundle | The whole chunk bundle has Lean-owned meaning | `Yes` | `Yes` on generated Rust cases | real normal-path artifact ingestion still needs wiring | `Medium` |
| Release artifact | Final grouped CHIP-8 artifact has Lean-owned schema and checker | `Yes` | `Yes` on generated Rust cases | direct normal-path export/import wiring | `Medium` |
| External release artifact schema | Rust export shape is Lean-owned, not ad hoc | `Yes` | `Yes` on generated cases | direct file/blob ingestion in the normal flow | `Medium` |

## What We Already Have

| Category | Status |
|---|---|
| Row-level mathematical CHIP-8 kernel story | `Mostly yes` |
| Chunk-level mathematical artifact story | `Yes` |
| Exact Rust↔Lean parity for transcript core | `Yes` |
| Exact Rust↔Lean parity for chunk bundle and release artifact on generated cases | `Yes` |
| Lean checking a real normal-path Rust release artifact as a mandatory release gate | `Not fully yet` |
| Proof that the Rust trace executor/prover/verifier implementation is correct line-by-line | `No, and not the main goal` |
| Proof of every internal transcript step / sumcheck round / control-flow detail in Rust | `No` |

## What We Still Do Not Have

The remaining gaps split into two very different classes.

### 1. Current assurance-target gaps

These are the remaining gaps for the assurance model described in
`docs/assurance-strategy.md`.

| Missing thing | What it really means | Why missing | Difficulty |
|---|---|---|---|
| Real release-gate wiring | Rust normal release flow emits the artifact; Lean checks it; release fails if it does not pass | mostly plumbing/integration, not theorem weakness | `Medium` |
| Broader parity corpus | More programs/rows/chunks to catch more implementation drift | coverage work | `Low-Medium` |
| Replay of more internal transcript events | Check more than the current shared challenge/artifact boundaries | this is the main remaining protocol/transcript assurance item | `Medium-High` |

### 2. Full Rust implementation-verification gaps

These are much bigger, and they are outside the main practical goal.

| Missing thing | What it really means | Difficulty |
|---|---|---|
| Formal model/refinement of Rust trace execution | Prove the actual Rust trace engine implements the Lean lowering/visibility model | `Extremely High` |
| Formal model/refinement of Rust prover/verifier logic | Prove the real Rust protocol code implements the theorem-facing stages | `Extremely High` |
| Fully verified serialization/parsing layer | Prove the Rust bytes exactly implement the Lean import/export meaning everywhere | `Very High` |
| Fully verified Poseidon2 implementation path | Prove the actual implementation refines the Lean executable model everywhere it matters | `Very High` |
| End-to-end Rust correctness | Prove the real Rust implementation is correct line-by-line, not just boundary-compatible | `Research-scale` |

## Transcript-Focused Reality Check

If the main concern is:

- "Are we doing the protocol correctly?"
- "Are we doing Fiat-Shamir / transcript binding correctly?"

then the situation is substantially better than a full implementation-proof
reading would suggest.

The key split is:

| Goal | Current state |
|---|---|
| Entire CHIP-8 protocol story | `Relatively close` |
| Entire CHIP-8 transcript semantics owned by Lean | `Well underway` |
| Exact Rust↔Lean transcript parity for the shared core | `Done` |
| Exact Rust↔Lean parity for every important transcript call in the kernel path | `Not fully done yet` |
| Full Rust implementation verification | `Far, but not the target` |

So the main remaining transcript work is localized and concrete. It is not a
huge missing protocol.

## Remaining Transcript-Call Gap

Today, the strongest transcript coverage is already in place for:

- `root0`
- the shared Stage 1 challenge draws
- the shared Stage 2 challenge draws
- the shared Stage 3 challenge draws
- grouped transcript/accounting surfaces at the bundle/release-artifact level

The main remaining gap is:

- replay more of the exact Rust transcript call stream inside the CHIP-8 kernel
  path, not just the shared challenge boundaries and grouped digest surfaces

This means checking more exact calls in owners such as:

- `stage_terminal.rs`
- `opening_boundary.rs`
- `joint_opening.rs`
- `semantic_evidence.rs`
- `bridge_binding.rs`
- `execution_digest.rs`

The right closure condition for this concern is:

1. Lean defines the exact transcript event semantics.
2. Rust exports the real transcript event stream, or enough exact snapshots to
   replay it without ambiguity.
3. Lean recomputes the same transcript path.
4. Rust and Lean are compared event-by-event when practical, and otherwise at
   exact challenge/digest boundaries.

For the transcript question, that is effectively enough.

## Best Short Summary

| Statement | True? |
|---|---|
| "We only proved isolated Stage 1/2/3 fragments." | `No` |
| "We proved the row-to-row CHIP-8 kernel composition story." | `Yes` |
| "We have Rust↔Lean exact equality at important protocol boundaries." | `Yes` |
| "We already proved the entire Rust implementation correct." | `No, and that is not the main target` |
| "The remaining near-term gap is mostly release integration plus fuller transcript-call parity, not missing row-level math." | `Yes` |

## Interpretation

The current state is best described as:

- **strong kernel-level theorem assurance**
- **strong protocol-boundary Rust↔Lean parity**
- **incomplete operational release-gate wiring**
- **one focused transcript-call parity project away from much stronger protocol closure**
- **still far from full Rust implementation verification, which is outside the main target**

That is consistent with `docs/assurance-strategy.md`, which targets:

1. Lean-proved design
2. Rust↔Lean differential parity on exported boundaries
3. Lean checking of real Rust-produced artifacts

It does **not** target proving every line of Rust correct.
