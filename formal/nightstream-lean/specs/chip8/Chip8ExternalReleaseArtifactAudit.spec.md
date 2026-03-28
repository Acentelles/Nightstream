# Chip8ExternalReleaseArtifactAudit Spec

## Purpose

- **What it is**: The executable Lean checker over one imported CHIP-8 release
  artifact.
- **Key property**: `importedReleaseArtifactAuditSound` says that if the
  checker accepts the imported artifact, then every external source-derived
  release-artifact check required by `Chip8ExternalReleaseArtifact` holds.
- **Protocol role**: This is the final Lean checker directly above the
  proof-free external artifact schema. It is the Layer-3 owner that a real Rust
  export should target.

## Target Formulas

### Component checks

For one imported artifact `a`, define executable checks for:

- trace-surface rebuild,
- export-surface rebuild,
- staged-bundle rebuild,
- Stage-3 source length,
- Stage-3 source row/frame alignment,
- transcript-surface rebuild,
- error-surface family lists,
- simple-boundary manifest constraints,
- row-projection / bridge-binding reuse,
- prepared-step / Stage-3 alignment.

### Bundled acceptance

Define:

$$
\mathrm{ImportedReleaseArtifactAccepted}(a)
$$

to mean that the bundled imported-artifact checker accepts.

### Soundness

The primary theorem target is:

$$
\mathrm{ImportedReleaseArtifactAccepted}(a)
\Longrightarrow
\mathrm{ImportedReleaseArtifactBound}(a).
$$

### Concrete count consequences

Accepted imported artifacts must also support concrete corollaries:

$$
\mathrm{stagedBundleLength}(a) = \mathrm{semanticRows}(a)
$$

and:

$$
\mathrm{kernelPreparedStepCount}(a) = \mathrm{stagedBundleLength}(a).
$$

These are the concrete cross-layer facts that the final Rust export and the
final Lean checker must agree on.

## Paper Anchors

- **Sources**:
  - `./docs/assurance-strategy.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8ExternalReleaseArtifact.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8ReleaseArtifactAudit.spec.md`
- Anchors:
  - final release checking should run against one exact Lean-owned external
    artifact target
  - imported artifacts must preserve count, transcript, and row-path coherence

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Kernel/ExternalReleaseArtifactAudit.lean` | Executable checker and soundness/corollary theorems over imported release artifacts |
| `Nightstream/Chip8/Kernel/ExternalReleaseArtifactAuditInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Checker | `checkImportedReleaseArtifact` | def | Definitional | Bundled executable checker over one imported artifact |
| Acceptance | `ImportedReleaseArtifactAccepted` | def | Definitional | Acceptance predicate for one imported artifact |
| Theorem | `importedReleaseArtifactAccepted_iff_bound` | theorem | Theorem-Target | Acceptance is equivalent to the exact imported-artifact bound |
| Theorem | `importedReleaseArtifactAuditSound` | theorem | Theorem-Target | Accepted imported artifacts satisfy the exact imported-artifact contract |
| Theorem | `importedReleaseArtifactAuditImpliesBundleLength_eq_semanticRows` | theorem | Theorem-Target | Accepted imported artifacts prove bundle length equals semantic rows |
| Theorem | `importedReleaseArtifactAuditImpliesPreparedStepCount_eq_bundleLength` | theorem | Theorem-Target | Accepted imported artifacts prove prepared-step count equals bundle length |
| Theorem | `importedReleaseArtifactAuditImpliesAuditReuseRowBinding` | theorem | Theorem-Target | Accepted imported artifacts preserve row-path reuse in the imported audit surface |

## Proof Obligations

- Do not let the imported checker accept a grouped release package whose source
  lists do not match the grouped surfaces.
- Do not drop the Stage-3 source-length or row/frame-alignment checks.
- Do not weaken row-path reuse to a digest-only coincidence.
- Keep the imported checker executable and deterministic so Rust↔Lean parity can
  run `1:1` on exported artifacts.
