# Chip8ReleaseArtifact Spec

## Purpose

- **What it is**: The Lean-defined final CHIP-8 release artifact above the
  normalized kernel digest and the chunk staged-execution bundle.
- **Key property**: `releaseArtifact_of_acceptance` packages one accepted
  CHIP-8 kernel chunk into one explicit artifact carrying the exact kernel
  digest plus the exact chunk-ordered staged bundle.
- **Protocol role**: This owner is the theorem-facing release package above
  `Chip8KernelExecutionDigest` and `Chip8StagedExecutionDigestBundle`. It does
  not own external serialization/import; it owns the exact combined object that
  `Chip8ExternalReleaseArtifact` must target.

## Target Formulas

### Artifact ownership

For one exact authenticated CHIP-8 chunk, define one release artifact:

$$
\mathrm{ReleaseArtifact}.
$$

It packages exactly two existing Lean-owned surfaces:

$$
\mathrm{KernelExecutionDigest}
$$

and

$$
\mathrm{StagedExecutionDigestBundle}.
$$

This owner must not weaken either surface and must not introduce a third
Rust-local summary object in between them.

### Artifact bound

Define:

$$
\mathrm{ReleaseArtifactBound}(a,\dots)
$$

to mean:

- the packaged kernel digest satisfies the exact
  `Chip8KernelExecutionDigest` realization predicate,
- the packaged staged bundle satisfies the exact
  `Chip8StagedExecutionBundleAudit` acceptance predicate,
- the simple-kernel chunk-input contract remains explicit.

This keeps the final release package tied to the exact kernel theorem surface
and to the exact chunk-order staged bundle surface.

### Normalization theorems

The primary normalization theorem is:

$$
\mathrm{KernelSoundnessConclusion}(\dots)
\land
\mathrm{SimpleKernelChunkInput}(init, meta.semanticRows, \mathrm{traceOf}(frames))
\Longrightarrow
\exists a,\; \mathrm{ReleaseArtifactBound}(a,\dots).
$$

The acceptance-level corollary is:

$$
\mathrm{KernelSoundnessAccepted}(\dots)
\Longrightarrow
\exists a,\; \mathrm{ReleaseArtifactBound}(a,\dots).
$$

The point is not to create a new proof surface. The point is to make one
explicit final package that the external Rust import/export owner can target.

### Projection theorems

From `ReleaseArtifactBound(a, …)` downstream users must be able to recover:

$$
\mathrm{KernelExecutionDigestBound}(a.\mathrm{kernelDigest},\dots)
$$

$$
\mathrm{StagedExecutionBundleAuditAccepted}(a.\mathrm{stagedBundle})
$$

and

$$
\mathrm{SimpleKernelChunkInput}(init, meta.semanticRows, \mathrm{traceOf}(frames)).
$$

## Paper Anchors

- **Sources**:
  - `./docs/assurance-strategy.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8KernelExecutionDigest.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8StagedExecutionDigestBundle.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8StagedExecutionBundleAudit.spec.md`
- Anchors:
  - Layer 3 should consume one explicit Lean-defined release package
  - the release package must preserve both the kernel boundary and the
    chunk-ordered staged-digest boundary
  - chunk input remains part of the theorem-facing release boundary

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Kernel/ReleaseArtifact.lean` | Combined theorem-facing release artifact above the kernel digest and staged bundle |
| `Nightstream/Chip8/Kernel/ReleaseArtifactInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Artifact | `ReleaseArtifact` | def/structure | Definitional | One explicit final release package carrying the kernel digest and staged bundle |
| Bound | `ReleaseArtifactBound` | def | Definitional | Exact realization predicate for one release artifact instance |
| Theorem | `kernelDigestBound_of_releaseArtifactBound` | theorem | Theorem-Target | Realized release artifacts recover exact kernel-digest realization |
| Theorem | `stagedBundleAuditAccepted_of_releaseArtifactBound` | theorem | Theorem-Target | Realized release artifacts recover accepted chunk-bundle audit |
| Theorem | `chunkInput_of_releaseArtifactBound` | theorem | Theorem-Target | Realized release artifacts keep the simple-kernel chunk input explicit |
| Theorem | `releaseArtifactBound_of_fields` | theorem | Theorem-Target | One realized kernel digest plus one accepted staged bundle determine one realized release artifact |
| Theorem | `releaseArtifact_of_conclusion` | theorem | Theorem-Target | Kernel conclusion plus chunk input normalize into one realized release artifact |
| Theorem | `releaseArtifact_of_acceptance` | theorem | Theorem-Target | Accepted kernel boundary normalizes into one realized release artifact |

## Proof Obligations

- Do not insert a Rust-local summary layer between the kernel digest and the
  staged bundle.
- Do not hide the simple-kernel chunk input; release packaging still depends on
  it.
- Do not weaken the kernel digest or staged bundle surfaces when packaging
  them.
- Do not treat this owner as the external serialization contract; that is owned
  by `Chip8ExternalReleaseArtifact`.
