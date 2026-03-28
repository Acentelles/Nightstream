# RV64IM Checks

## Purpose

`Nightstream/Rv64IM/Checks.lean` owns the executable exact-parity gate for the
imported RV64IM Rust slice corpus.

## Imported Boundary

The imported corpus consists of paired source/derived cases:

- `Rv64imParitySourceCase`: program words, initial state, aligned RAM words,
  transcript seed, and case manifest
- `Rv64imParityDerivedCase`: Rust-computed execution rows, Stage 1/2/3
  summaries, transcript event log/checkpoints, and kernel digest/final-state
  summary

The imported corpus is sharded per case and reassembled only through the small
generated index and corpus modules.

## Required Checks

For each imported case, the checker must independently recompute from the
source case:

- executed RV64IM slice rows
- Stage 1 row-binding/helper summaries
- Stage 2 register history, RAM history, and Twist-link summaries
- Stage 3 continuity summaries
- Fiat-Shamir transcript events, checkpoints, challenge outputs, and final
  digest
- kernel-facing digests and final halted state

The checker accepts a case iff every recomputed object is definitionally equal
to the imported derived case.

## Fiat-Shamir Transcript Coverage

Transcript parity is explicit. The checker must compare:

- app label
- ordered event list
- event labels
- absorbed message payloads
- absorbed `u64` vectors
- cursor snapshots before and after each event
- challenge outputs
- digest outputs

Final-digest-only agreement is insufficient.

## Acceptance Surface

The module exports:

- per-case boolean checks
- per-case detailed reports
- a corpus-wide acceptance boolean

The global regression gate may report success only when every imported RV64IM
parity case is accepted.
