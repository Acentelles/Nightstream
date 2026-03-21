# Chip8Checks Spec

## Purpose

- **What it is**: The executable parity-check owner for Rust-generated CHIP-8
  transcript vectors.
- **Key property**: every generated case must match Lean's concrete
  recomputation of the `root0` transcript state, the `root0` digest, and the
  first shared Stage-1 lookup point.
- **Protocol role**: this is the first concrete Layer-2 Rust↔Lean conformance
  lane for protocol-binding values.

## Target Checks

For every generated case

$$
\mathrm{case} \in \mathrm{transcriptVectorCases},
$$

the checker must validate:

1. Lean's concrete `root0` transcript cursor state equals the Rust-exported
   state words.
2. Lean's concrete `root0` digest cursor state equals the Rust-exported state
   words.
3. Lean's concrete `root0` digest words equal the Rust-exported digest words.
4. Lean's concrete `root0` digest bytes equal the Rust-exported digest bytes.
5. Lean's concrete Stage-1 shared lookup point `r_lookup` equals the
   Rust-exported point.

This owner is intentionally limited to the transcript slice Lean already owns
completely. Later stage-local transcript replay owners may extend this checker
to Stage 2 and Stage 3 shared challenges.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Generated/TranscriptVectorTypes.lean` | Generated-case types and helpers |
| `Nightstream/Chip8/Generated/TranscriptVectors.lean` | Rust-exported concrete cases |
| `Nightstream/Chip8/Checks.lean` | Executable parity checks |
| `Nightstream/Chip8/ChecksInterface.lean` | Thin machine-facing boundary |

## Acceptance Criteria

1. `lake build Nightstream.Chip8.Checks` succeeds.
2. `lake exe check` reports `chip8_transcript_parity=true`.
3. No theorem-facing owner imports this generated/check lane through
   `Nightstream.lean`.
