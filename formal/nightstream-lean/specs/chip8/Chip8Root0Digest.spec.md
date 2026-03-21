# CHIP-8 Root0 Digest

## Purpose

This owner fixes the exact transcript-state evolution immediately above
`Chip8Poseidon2Transcript`. It owns the width-8/rate-4 sponge mechanics used by
the CHIP-8 simple-kernel transcript, the exact `digest32` and
`challenge_field` state transitions, and the resulting `root0` digest surface.

This owner does not fix the concrete Poseidon2 round constants. Instead, it
exposes one explicit width-8 permutation parameter and proves everything else
around that parameter exactly.

## Scope

This module defines:

- the transcript state shape (`width = 8`, `rate = 4`)
- the absorb cursor
- absorb-one-element behavior
- absorb-sequence behavior
- exact `digest32` state transition
- exact `challenge_field` state transition
- little-endian 8-byte encoding of digest limbs
- `root0` digest words and bytes from the exact `root0` transcript operations

This module does not define:

- the concrete Poseidon2 permutation constants
- Poseidon2 cryptographic security
- Stage 1 / Stage 2 / Stage 3 challenge schedules beyond the generic
  `challenge_field` operator itself

## Width-8 / rate-4 transcript core

The sponge state is eight Goldilocks field elements.

The absorb rate is four field elements.

Absorbing one field element follows the Rust transcript exactly:

1. if the absorb cursor is already full, permute first and reset the cursor
2. write the next absorbed field element at the current absorb position
3. increment the absorb cursor

## `digest32`

`digest32` performs:

1. absorb one Goldilocks `ONE`
2. permute once
3. output the first four state limbs
4. encode each limb as eight little-endian bytes

The resulting digest is therefore exactly 32 bytes.

## `challenge_field(label)`

`challenge_field(label)` performs:

1. absorb the transcript words for `append_message("chal/label", utf8(label))`
2. absorb one Goldilocks `ONE`
3. permute once
4. return the first state limb as the challenge value

## `root0`

`root0` is the `digest32` result after replaying:

1. the transcript application binding
2. the transcript-seed binding
3. the exact `root0` commitment and `meta_pub` preimage operations from
   `Chip8Root0Preimage`

parameterized by the byte encoders for commitment digests, public digests, and
the root-parameter identifier.

## Remaining explicit dependency

The only unclosed cryptographic dependency at this layer is the concrete
Poseidon2 width-8 permutation itself. Once that permutation is supplied as a
Lean executable function matching Rust, this owner yields exact `root0` digest
bytes and exact challenge values with no further transcript ambiguity.
