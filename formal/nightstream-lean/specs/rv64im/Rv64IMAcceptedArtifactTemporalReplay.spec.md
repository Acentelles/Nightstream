# Rv64IMAcceptedArtifactTemporalReplay

## Purpose

This module owns constructive replay of the architectural state trace from the
accepted-artifact source case and imported execution rows.

## Mathematical target

From the lowest practical exported inputs already available to Lean, rebuild:

- the architectural pre-state and post-state stream over imported execution
  rows,
- the Stage 2 temporal-closure package,
- the register timeline package,
- the RAM timeline package,
- the PC-adjacency bridge package,
- the derived temporal-consistency package.

## Required behavior

- Replay must validate row-local reads against the replayed architectural state.
- Replay must validate the row-local PC against the replayed architectural
  state.
- Replay must apply row-local register writes and RAM writes to produce the next
  architectural state.
- Recovered Stage 2 and temporal packages must be derived from the replayed
  state trace, not imported as authoritative Rust summaries.
- The module must expose a final-state parity check against the imported derived
  kernel summary.
