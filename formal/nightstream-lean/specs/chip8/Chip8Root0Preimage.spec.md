# CHIP-8 Root0 Preimage

## Purpose

- **What it is**: the theorem-facing owner for the exact phase-0 `root0`
  preimage beneath any concrete hash function.
- **What it owns**: the canonical labeled root0 commitment absorbs, the exact
  lift of the `meta_pub` absorb plan into phase 0, and the combined ordered
  `root0` preimage.
- **What it does not own**: the Poseidon2 permutation, transcript squeezing, or
  challenge derivation.

## Mathematical Target

Let:

- `root0CommitmentIds` be the canonical kernel commitment inventory from the
  transcript-schedule owner,
- `root0MetaPubAbsorbPlan(pubMeta)` be the exact labeled metadata absorb plan
  from `Chip8MetaPubEncoding.spec.md`.

The root0-preimage owner must define one exact ordered sequence:

\[
\mathrm{root0Preimage}(bindings, pubMeta)
  =
\mathrm{take}_3(\mathrm{root0MetaAbsorbPlanOps}(pubMeta))
  \mathbin{+\!\!+}
\mathrm{root0CommitmentAbsorbPlan}(bindings)
  \mathbin{+\!\!+}
\mathrm{drop}_3(\mathrm{root0MetaAbsorbPlanOps}(pubMeta)).
\]

This is the exact phase-0 input sequence that any later executable
Poseidon2/transcript owner must consume.

The split at `3` is normative. Rust binds:

1. `chip8/root0/version`
2. `chip8/root0/field_id`
3. `chip8/root0/extension_field_id`
4. the twelve kernel commitment digests
5. the remaining metadata digests / ids / numeric suffix

## Commitment Labels

The canonical root0 commitment labels are:

1. `chip8/root0/c_lane`
2. `chip8/root0/c_fetch_ra`
3. `chip8/root0/c_decode_ra`
4. `chip8/root0/c_alu_ra`
5. `chip8/root0/c_eq4_ra`
6. `chip8/root0/c_decode_handoff`
7. `chip8/root0/c_reg`
8. `chip8/root0/c_ram`
9. `chip8/root0/c_rom_table`
10. `chip8/root0/c_decode_table`
11. `chip8/root0/c_alu_table`
12. `chip8/root0/c_eq4_table`

## Theorem Targets

The owner must expose:

- a theorem-facing root0 commitment binding object carrying `(commitmentId,
  digest)`,
- a conformance predicate tying those bindings to the canonical
  `root0CommitmentIds` order,
- the exact root0 commitment absorb plan,
- the exact lifted metadata absorb plan,
- the exact three-element metadata prefix and nine-element metadata suffix,
- the exact combined `root0Preimage`,
- theorems that:
  - the canonical root0 commitment label list has length `12`,
  - a conforming commitment absorb plan uses exactly the canonical commitment
    label order,
  - a conforming metadata prefix has length `3`,
  - a conforming metadata suffix has length `9`,
  - a conforming combined `root0Preimage` uses exactly
    `take 3 root0MetaPubLabels ++ root0CommitmentLabels ++ drop 3 root0MetaPubLabels`,
  - a conforming combined `root0Preimage` has length `24`,
  - dropping the three-element metadata prefix and the commitment block of
    `root0Preimage` recovers exactly the metadata suffix.

## Why This Owner Exists

- The transcript-schedule owner fixes **when** phase 0 happens.
- The meta-pub owner fixes **what metadata payload** is absorbed.
- This owner fixes the exact **combined ordered phase-0 input sequence** before
  hashing.

That separation is necessary for near-`1:1` Rust↔Lean parity: Rust must not
define its own root0-preimage meaning independently of Lean.

## File Map

- `Nightstream/Chip8/Kernel/Root0Preimage.lean`
- `Nightstream/Chip8/Kernel/Root0PreimageInterface.lean`
