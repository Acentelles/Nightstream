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
3. Stage 1 bytecode / execution events,
4. Stage 2 register / RAM / linkage events,
5. Stage 3 continuity / opening-provenance / row-binding events,
6. final kernel opening claims.

The root commitment bindings must conform to the canonical `Root0CommitmentId`
registry in exactly that order.

## Challenge discipline

The challenge-sampling events are a distinguished subset of the transcript and
must occur only at the named challenge positions in the schedule.
