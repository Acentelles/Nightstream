# CHIP-8 Poseidon2 Transcript

## Purpose

This owner fixes the exact CHIP-8 transcript packing and domain-separation rules
for the Poseidon2-over-Goldilocks transcript used by the simple kernel. It owns
the executable transcript-input semantics beneath `root0` and beneath later
challenge draws; it does not own the Poseidon2 permutation rounds themselves.

## Scope

This module defines:

- the transcript application-domain binding
- the simple-kernel application label
- the transcript-seed binding
- byte-message packing into Goldilocks limbs
- `u64` packing into two 32-bit Goldilocks limbs
- the absorb words implied by `append_message`
- the absorb words implied by `append_u64s`
- the absorb words implied by `digest32`
- the absorb words implied by `challenge_field`
- the exact conversion from the `root0` preimage owner into transcript
  operations and absorb words

This module does not define:

- the Poseidon2 permutation constants or round function
- cryptographic security claims about Poseidon2
- any Stage 1 / Stage 2 / Stage 3 semantic theorem

## Canonical transcript rules

### Application binding

The transcript starts by applying:

- label: `neo/transcript/v1|poseidon2-goldilocks-w8-r4`
- message: `neo.fold.next/chip8/simple_kernel`

This is modeled as one canonical `append_message`.

### Transcript seed binding

After the application binding, the transcript absorbs:

- label: `chip8/kernel/transcript_seed`
- message: the external transcript-seed byte string

### `append_message`

`append_message(label, msg)` absorbs:

1. the byte length of `label` as one Goldilocks limb
2. the bytes of `label`, packed seven bytes per limb in little-endian order
3. the byte length of `msg` as one Goldilocks limb
4. the bytes of `msg`, packed seven bytes per limb in little-endian order

The seven-byte packing rule is exact: each limb is the little-endian integer of
one chunk of at most seven bytes, so every packed limb is strictly below
`2^56 < q_goldilocks`.

### `append_u64s`

`append_u64s(label, values)` absorbs:

1. the `append_message` encoding of `label`
2. the number of `u64` values as one Goldilocks limb
3. for each `u64`, two Goldilocks limbs:
   - low 32 bits
   - high 32 bits

This matches the Rust transcript’s full-range injective encoding for `u64`.

### `digest32`

`digest32` absorbs one Goldilocks `ONE` domain gate before the next permutation.

### `challenge_field`

`challenge_field(label)` absorbs:

1. `append_message("chal/label", utf8(label))`
2. one Goldilocks `ONE` domain gate

before the next permutation, after which the first output limb is read as the
challenge value.

## `root0`

The `root0` transcript path is:

1. application binding
2. transcript-seed binding
3. the exact `root0` preimage operations from `Chip8Root0Preimage`
4. `digest32`

The owner exports the exact transcript operations and exact absorbed Goldilocks
limbs for that path, parameterized by byte encoders for commitment digests,
public digests, and the root-parameter identifier.
