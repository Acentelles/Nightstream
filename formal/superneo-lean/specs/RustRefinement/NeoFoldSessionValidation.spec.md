# RustRefinement/NeoFoldSessionValidation

## Purpose

Specify the Rust-only validation layer for exported real `neo-fold` `FoldingSession`
runs.

This is not a paper theorem. It is a conformance layer for implementation artifacts
that sit above the paper shard proof objects.

## Mathematical target

For each exported session case, the validator checks:

1. Session shape:
   - the exported public-step vector has the declared `publicStepCount`
   - the exported fold count matches the public-step count
   - the exported proof carries at least one proof step

2. Step-linking statement:
   - for every adjacent pair of public steps
   - and every exported `(prevIdx, nextIdx)` linking pair
   - the exported public input coordinates satisfy
     `prev.x[prevIdx] = next.x[nextIdx]`

3. Segment-carry statement:
   - the exported session case partitions proof steps into one or more proved segments
   - the segment proof-step counts are positive and sum to the exported `proofStepCount`
   - the first segment starts from an empty accumulator
   - the exported session case carries Rust-only digests for the paper-core carried obligations
   - every later segment starts from an accumulator whose size matches the previous segment's exported final accumulator size
   - every later segment starts from a main-accumulator digest that matches the previous segment's exported final main-accumulator digest

4. Output-binding statement:
   - if the session exports an output-binding configuration, then
     - the proof declares an output-binding proof
     - the exported final target state has size `2 ^ numBits`
     - every exported claimed `(addr, value)` is in range and matches the exported final target state

5. Corpus expectation:
   - exported valid session cases pass the validator
   - exported tampered session cases fail the validator
   - the slow executable layer also reports the theorem-backed paper-core session-refinement result over the valid generated corpus

## Scope

This spec is intentionally limited to session-level statement glue:
- step-linking
- resumed-segment carry consistency
- resumed-segment carried-obligation digest consistency
- output-binding claim consistency
- valid/tampered corpus classification

It does not restate the paper shard-proof theorems, and it does not replace the
artifact-level Rust refinement layer.
