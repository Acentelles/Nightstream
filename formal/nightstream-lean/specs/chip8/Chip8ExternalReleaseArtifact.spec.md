# Chip8ExternalReleaseArtifact Spec

## Purpose

- **What it is**: The Lean-owned proof-free external import schema for one
  CHIP-8 release artifact emitted by Rust.
- **Key property**: `ImportedArtifact` fixes the exact imported fields that a
  Rust export must carry so Lean can rebuild the release package from
  independent frame, Stage-3, and transcript sources.
- **Protocol role**: This owner sits above `Chip8ReleaseArtifact`. It does not
  re-own the theorem-facing kernel package. It owns the external source view
  that Rust must populate if Lean is going to check a real exported artifact
  instead of a Rust-local summary.

## Target Formulas

### Imported artifact shape

For one imported artifact, define:

$$
\mathrm{ImportedArtifact}.
$$

It contains:

- the exact `root0` commitment bindings,
- the trace-digest source view,
- the exact frame list,
- the exact Stage-3 digest-source list,
- the grouped release-artifact view exported by Rust.

### Source-derived expectations

This owner must define the exact source-derived views:

$$
\mathrm{expectedTraceSurface}(a)
$$

$$
\mathrm{expectedExportSurface}(a)
$$

$$
\mathrm{expectedBundle}(a)
$$

$$
\mathrm{expectedTranscriptSurface}(a).
$$

These are the Lean-owned reference rebuilds that the later external-audit owner
must compare against the imported grouped release package.

### Structural source checks

This owner must also define the imported-source predicates needed by the final
checker:

- Stage-3 source length agrees with the frame list,
- Stage-3 rows match the imported frame rows,
- kernel manifest claims stay on the simple kernel boundary,
- row-projection and bridge-binding paths reuse the same row-binding identity,
- prepared-step digests align with the imported Stage-3 list.

### Imported-bound meaning

Define:

$$
\mathrm{ImportedReleaseArtifactBound}(a)
$$

to mean that every source-derived structural check holds for the imported
artifact instance. This owner defines what the imported artifact must mean; it
does not yet define the executable checker.

## Paper Anchors

- **Sources**:
  - `./docs/assurance-strategy.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8ReleaseArtifact.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8ReleaseArtifactAudit.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8Checks.spec.md`
- Anchors:
  - Layer 3 needs one exact Lean-owned external artifact target
  - Rust export must be checkable against Lean-owned source rebuilds
  - the external artifact must preserve the simple-boundary kernel manifest and
    row-path reuse guarantees

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Kernel/ExternalReleaseArtifact.lean` | Imported artifact shape and source-derived expected views |
| `Nightstream/Chip8/Kernel/ExternalReleaseArtifactInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Artifact | `ImportedArtifact` | structure | Definitional | One exact proof-free import schema for a Rust release artifact |
| Def | `ofVectorCase` | def | Definitional | Lifts generated parity cases into the same imported-artifact schema |
| Def | `expectedTraceSurface` | def | Definitional | Lean-owned trace-surface rebuild from imported sources |
| Def | `expectedExportSurface` | def | Definitional | Lean-owned export-surface rebuild from imported sources |
| Def | `expectedBundle` | def | Definitional | Lean-owned staged-bundle rebuild from imported sources |
| Def | `expectedTranscriptSurface` | def | Definitional | Lean-owned transcript-surface rebuild from `root0` bindings and semantic-row count |
| Def | `ImportedReleaseArtifactBound` | def | Definitional | Exact meaning of an imported artifact instance |

## Proof Obligations

- Do not weaken the imported artifact into only a grouped digest summary.
- Do not drop the exact frame list or Stage-3 source list from the imported
  boundary.
- Do not permit root-side manifest claims on the simple boundary.
- Do not hide the row-path reuse check behind the grouped digest alone.

