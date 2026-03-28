# Rv64IMTranscriptSchedule

## Purpose

Defines the exact theorem-facing transcript order for the RV64IM kernel after the
public program and lowering version are fixed.

## Objects

- `Root0CommitmentId`: the canonical root commitment inventory for the RV64IM kernel.
- `Root0CommitmentBinding`: one commitment id paired with one absorbed digest.
- `TranscriptEvent`: one verifier-observable transcript step.

## Required schedule

For any accepted kernel proof, the transcript is the concatenation of:

1. root commitment absorption,
2. public metadata absorption and program-binding check,
3. root main-lane fold-schedule absorption,
4. one ordered root-chunk transcript segment per chunk in that schedule,
5. Stage 1 bytecode / execution events,
6. Stage 2 register / RAM / linkage events,
7. Stage 3 continuity / opening-provenance / row-binding events,
8. final kernel opening claims.

The root commitment bindings must conform to the canonical `Root0CommitmentId`
registry in exactly that order.

## Challenge discipline

The challenge-sampling events are a distinguished subset of the transcript and
must occur only at the named challenge positions in the schedule.

For the root main-lane theorem:

- the carried `FoldSchedule` is absorbed as public proof metadata,
- each chunk absorbs its `startIndex` and ordered row labels before proving,
- each chunk runs exactly one `Π_CCS`, one `Π_RLC`, and one `Π_DEC`,
- `WholeTrace` therefore yields exactly one root fold round for the whole active trace,
- `RowsPerChunk(1)` yields the legacy per-row fold cadence.
