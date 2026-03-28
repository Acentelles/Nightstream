# Chip8ChallengeDerivation Spec

## Purpose

- **What it is**: the theorem-facing owner for exact Rust-compatible
  `challenge_field`, `sample_k`, and `sample_point` derivation above the
  width-8/rate-4 transcript cursor.
- **Key property**: every shared CHIP-8 stage challenge and every explicitly
  labeled terminal-point challenge is derived by one canonical repeated
  `challenge_field(label)` rule over the same cursor evolution that Rust uses.
- **Protocol role**: this owner sits strictly above `Chip8Poseidon2Transcript`
  and `Chip8Root0Digest`. It does not own the Poseidon2 permutation itself,
  and it does not own unlabeled internal sumcheck round challenges. It owns the
  exact transcript-sampling semantics for the explicit labeled kernel
  challenges.

## Scope

This owner fixes:

- the exact base-field challenge step
  `challenge_field(label)`;
- the exact extension-style challenge assembly
  `sample_k(label)` as two consecutive `challenge_field(label)` draws;
- the exact point assembly `sample_point(label, n)` as `n` consecutive
  `sample_k(label)` draws;
- the exact Rust labels for the shared kernel challenges:
  - `stage1/r_lookup`
  - `stage1/gamma_lookup_link`
  - `stage2/r_cycle`
  - `stage2/gamma_reg`
  - `stage2/gamma_ram`
  - `stage2/r_addr_reg`
  - `stage2/r_addr_ram`
  - `stage2/gamma_twist_link`
  - `stage3/beta1`
  - `stage3/beta2`
  - `stage3/r_shift`
  - `stage3/gamma_shift`

This owner does **not** fix:

- the concrete Poseidon2 permutation rounds;
- the full internal transcript of each stage-local sumcheck;
- unlabeled or subprotocol-local challenge families whose ownership belongs to
  another proof surface.

## Root0 continuation boundary

`root0` has two distinct views:

1. the **live transcript continuation state**, obtained by absorbing the exact
   `root0` commitment and `meta_pub` preimage into the transcript cursor; and
2. the **derived digest artifact** `digest32(root0_cursor)`.

Shared stage challenges continue from the first object, not from the second.
This owner therefore derives `r_lookup` from the **pre-digest** `root0`
 transcript cursor. The `root0` digest bytes are a separate artifact owned by
`Chip8Root0Digest`.

## Target formulas

Let `Cursor` be the width-8/rate-4 transcript cursor and let
`challengeFieldCursor(core, cursor, label)` be the exact cursor transition from
`Chip8Root0Digest`.

Define the base-field challenge step:

$$
\mathrm{sampleField}(core, cursor, label)
:=
(
  \mathrm{challengeFieldValue}(core, cursor, label),
  \mathrm{challengeFieldCursor}(core, cursor, label)
).
$$

Define the extension-style challenge pair:

$$
\mathrm{sampleK}(core, cursor, label)
:=
\Big(
  (c_0, c_1),
  cursor_2
\Big)
$$

where:

$$
(c_0, cursor_1) := \mathrm{sampleField}(core, cursor, label)
$$

and

$$
(c_1, cursor_2) := \mathrm{sampleField}(core, cursor_1, label).
$$

Define the point sampler recursively:

$$
\mathrm{samplePoint}(core, cursor, label, 0) := ([], cursor),
$$

$$
\mathrm{samplePoint}(core, cursor, label, n+1)
:=
\Big(
  k :: ks,
  cursor''
\Big)
$$

where:

$$
(k, cursor') := \mathrm{sampleK}(core, cursor, label),
$$

$$
(ks, cursor'') := \mathrm{samplePoint}(core, cursor', label, n).
$$

Then the explicit shared kernel challenges are the following derived objects:

- `r_lookup` := `samplePoint(root0TranscriptCursor, "stage1/r_lookup", cycle_bits)`
- `γ_lookup_link` := `sampleK(cursor_before_stage1_link, "stage1/gamma_lookup_link")`
- `r_twist_cycle` := `samplePoint(cursor_before_stage2_cycle, "stage2/r_cycle", cycle_bits)`
- `γ_reg` := `sampleK(cursor_before_gamma_reg, "stage2/gamma_reg")`
- `γ_ram` := `sampleK(cursor_before_gamma_ram, "stage2/gamma_ram")`
- `r_addr_reg` := `samplePoint(cursor_before_reg_addr, "stage2/r_addr_reg", addr_reg_bits)`
- `r_addr_ram` := `samplePoint(cursor_before_ram_addr, "stage2/r_addr_ram", addr_ram_bits)`
- `γ_twist_link` := `sampleK(cursor_before_twist_link, "stage2/gamma_twist_link")`
- `β1` := `sampleK(cursor_before_beta1, "stage3/beta1")`
- `β2` := `sampleK(cursor_before_beta2, "stage3/beta2")`
- `r_shift` := `samplePoint(cursor_before_shift_point, "stage3/r_shift", cycle_bits)`
- `γ_shift` := `sampleK(cursor_before_gamma_shift, "stage3/gamma_shift")`

The special case `r_lookup` is derived from the exact pre-digest `root0`
transcript cursor because it is the first shared challenge sampled after the
phase-0 `root0` absorb boundary.
