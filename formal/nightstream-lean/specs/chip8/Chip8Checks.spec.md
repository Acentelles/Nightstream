# Chip8Checks Spec

## Purpose

- **What it is**: The executable parity-check owner for Rust-generated CHIP-8
  transcript vectors and chunk-level staged-execution bundle vectors.
- **Key property**: every generated case must match Lean's concrete
  recomputation of the `root0` cursor/digest and the shared Stage-1 / Stage-2 /
  Stage-3 challenge groups exported by the Rust vector generator, and every
  generated staged bundle case must rebuild exactly from the Lean-owned
  frame-plus-Stage-3 source surface, and every generated release-artifact case
  must satisfy the grouped kernel-digest and staged-bundle consistency checks
  expected by the Lean-owned release checker.
- **Protocol role**: this is the first concrete Layer-2 Rust↔Lean conformance
  lane for protocol-binding values, and the release-artifact cases now target
  the same external import schema owned by `Chip8ExternalReleaseArtifact`.

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
6. Lean's concrete Stage-1 lookup-link challenge `γ_lookup_link`, recomputed
   from the exported pre-link cursor snapshot, equals the Rust-exported pair.
7. Lean's concrete Stage-2 shared cycle point, register/RAM address points,
   and linkage challenge pairs, each recomputed from its exported pre-draw
   cursor snapshot, equal the Rust-exported values.
8. Lean's concrete Stage-3 batching pairs `β1`, `β2`, shift point `r_shift`,
   and `γ_shift`, each recomputed from its exported pre-draw cursor snapshot,
   equal the Rust-exported values.

This owner is intentionally limited to the shared labeled challenge groups that
Lean can already replay exactly from exported cursor snapshots. It does not yet
replay every unlabeled stage-local absorb event or internal sumcheck round.

For every generated chunk bundle case

$$
\mathrm{case} \in \mathrm{stagedExecutionDigestBundleVectorCases},
$$

the checker must validate:

1. the exported public digest surface matches the source public surface;
2. the exported frame list and Stage-3 source list have the same length;
3. the exported chunk bundle length equals the source frame length;
4. the public `semanticRows` count equals the source frame length;
5. every exported Stage-3 digest source matches the corresponding exact frame;
6. Lean rebuilds the exact same chunk-level staged digest bundle from the
   exported frame and Stage-3 sources.

For every generated release-artifact case

$$
\mathrm{case} \in \mathrm{releaseArtifactVectorCases},
$$

the checker must validate:

1. the grouped kernel trace surface matches the exported exact frame list plus
   the exported Stage-1 / Stage-2 / Stage-3 / semantic-evidence digests;
2. the grouped kernel export surface matches the exported exact frame list and
   exported prepared-step digests carried by the Stage-3 source surface;
3. the grouped transcript surface matches the theorem-facing kernel transcript
   schedule replayed from the exported `root0` binding ids and semantic-row
   count;
4. the grouped error surface carries the exact fixed Stage-1 / Stage-2 /
   Stage-3 / batch / tail family decomposition expected by the Lean-owned
   kernel accounting owner;
5. the grouped manifest surface preserves the simple-boundary constraints:
   canonical `root0` ids, no root-side claims, and only kernel-owned
   commitment families in the kernel manifest;
6. the grouped audit surface preserves row alignment, exact row-binding path
   reuse between row projection and bridge binding, and prepared-step digest
   alignment with the exported Stage-3 source surface;
7. the packaged staged bundle equals the exact Lean rebuild from the exported
   public surface, exact frame list, and Stage-3 source list.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Generated/TranscriptVectorTypes.lean` | Generated-case types and helpers |
| `Nightstream/Chip8/Generated/TranscriptVectors.lean` | Rust-exported concrete cases |
| `Nightstream/Chip8/Generated/StagedExecutionDigestBundleVectorTypes.lean` | Generated chunk-bundle case types and rebuild helpers |
| `Nightstream/Chip8/Generated/StagedExecutionDigestBundleVectors.lean` | Rust-exported chunk-bundle cases |
| `Nightstream/Chip8/Generated/ReleaseArtifactVectorTypes.lean` | Generated release-artifact case types and grouped-surface helpers |
| `Nightstream/Chip8/Generated/ReleaseArtifactVectors.lean` | Rust-exported release-artifact cases |
| `Nightstream/Chip8/Checks.lean` | Executable parity checks |
| `Nightstream/Chip8/ChecksInterface.lean` | Thin machine-facing boundary |

## Acceptance Criteria

1. `lake build Nightstream.Chip8.Checks` succeeds.
2. `lake exe check` reports `chip8_protocol_parity=true`.
3. No theorem-facing owner imports this generated/check lane through
   `Nightstream.lean`.
