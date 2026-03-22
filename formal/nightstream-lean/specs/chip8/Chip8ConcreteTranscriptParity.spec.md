# CHIP-8 Concrete Transcript Parity

## Purpose

This owner fixes the exact concrete CHIP-8 simple-kernel transcript surface by
specializing `Chip8Root0Digest` and `Chip8ChallengeDerivation` to the concrete
width-8 Poseidon2-over-Goldilocks permutation from
`Chip8Poseidon2GoldilocksCore`.

Its role is to make the protocol-binding `root0` digest and shared kernel
challenge draws available as one Lean-owned concrete surface, so Rust-to-Lean
comparison can talk about the exact same computations without leaving the
Poseidon2 core as an extra parameter.

## Scope

This module defines:

- the exact concrete `root0` digest cursor
- the exact concrete `root0` digest words and bytes
- the exact concrete transcript cursor after `root0` absorption and before
  Stage 1 challenge sampling
- the exact concrete `challenge_field`, `sample_k`, and `sample_point`
  specializations used by the shared CHIP-8 kernel challenge layer
- the exact concrete Stage 1 / Stage 2 / Stage 3 shared challenge samplers
- the exact concrete cursor-snapshot replay surface used by the generated
  Rust↔Lean transcript vectors

This module does not define:

- the generic transcript packing and absorb semantics
- the generic sponge cursor mechanics
- the concrete Poseidon2 round constants or permutation itself
- stage-local sumcheck-round transcript replay beyond the shared kernel
  challenge surface

## Concrete specialization boundary

Every function in this owner is definitionally the corresponding owner from
`Chip8Root0Digest` or `Chip8ChallengeDerivation`, applied to the concrete core
from `Chip8Poseidon2GoldilocksCore`.

That means this owner adds no new protocol logic. It fixes the exact concrete
instantiation of already-owned generic logic.

## Concrete `root0`

The concrete `root0` digest is the `Chip8Root0Digest.root0` computation with:

- the exact concrete width-8 Poseidon2-over-Goldilocks permutation from
  `Chip8Poseidon2GoldilocksCore`
- the exact `root0` preimage operations from `Chip8Root0Preimage`
- the exact transcript packing and labeled absorb semantics from
  `Chip8Poseidon2Transcript`

So once the byte encoders for commitment digests, public digests, and the
root-parameter identifier are fixed, this owner yields the exact Lean meaning
of the Rust `root0` computation.

## Concrete shared kernel challenges

The concrete shared kernel challenges are the
`Chip8ChallengeDerivation` samplers evaluated with the same concrete core.

This fixes the exact Lean meaning of:

- the Stage-1 lookup point
- the Stage-1 lookup-link challenge pair
- the Stage-2 cycle point
- the Stage-2 register and RAM linkage challenge pairs
- the Stage-2 register and RAM address points
- the Stage-3 continuity batching challenge pairs, shift point, and
  `gamma_shift`

## Rust-parity role

This owner is the theorem-facing concrete bridge between:

- the generic Lean transcript/digest/challenge owners, and
- Rust-produced protocol-binding digest/challenge values

It therefore forms the natural comparison surface for deterministic golden
vectors and Rust↔Lean exact-equality checks over `root0` and the shared
kernel challenge layer.
