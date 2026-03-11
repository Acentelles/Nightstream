# NeoFoldArtifactValidation Spec

## Goal

Validate Rust-exported `neo-fold` proof artifacts inside Lean at the stored transcript, claim, witness, and fold-lane level.

## Mathematical target

For each exported `neo-fold` artifact family:

- reconstruct the quadratic extension field `K = F[u]/(u^2 - 7)` from explicit coefficient pairs,
- validate the stored `Π_CCS` FE transcript,
- validate the stored `Π_CCS` NC transcript,
- validate the stored Route-A batched-time transcript under its shared challenge point,
- validate the stored CPU and shift metadata wrappers against those transcripts,
- validate the stored `Π_RLC` / `Π_DEC` lane summaries for the main lane and any exported auxiliary lanes,
- validate the exported CE-claim semantics for current, carried, parent, and child witnesses on every exported lane,
- validate cross-step folding-chain shape on exported multi-step proof families,
- validate mixed CCS-only / Route-A segment metadata when a family exports segmented proof steps,
- validate that the exported `ccs_out.r` points agree with the exported CPU time point,
- and reject deliberately tampered artifact families.

## Validation model

- Rust exports only concrete data.
- Lean recomputes the extension-field polynomial evaluations and sumcheck running sums from that data.
- Lean also checks that the exported CE-claim summaries and exported witnesses satisfy the batch-alignment, per-claim CE semantics, parent/child reduction invariants, and segment-structure invariants required by the Rust verifier.
- Acceptance is based on executable checks whose soundness is the arithmetic of the reconstructed field, transcript recurrences, and exported fold-lane structure itself, not on trusted proof terms from Rust.

## Output expectations

- all valid exported `neo-fold` artifact families are accepted,
- all tampered exported `neo-fold` artifact families are rejected,
- the validation runner reports success only when both outcomes hold simultaneously.
