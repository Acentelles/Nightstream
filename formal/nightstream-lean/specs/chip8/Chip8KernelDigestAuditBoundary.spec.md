# Chip8KernelDigestAuditBoundary Spec

## Purpose

- **What it is**: The theorem-facing grouped-surface decomposition owner for the
  Lean-defined kernel digest and its audit checker.
- **Key property**: one realized kernel digest exposes its grouped trace,
  export, audit, manifest, transcript, and error surfaces directly, and those
  same grouped surfaces are sufficient to satisfy the Lean audit-acceptance
  predicate.
- **Protocol role**: This owner sits above `Chip8KernelExecutionDigest` and
  `Chip8KernelArtifactAudit`. It does not add new semantic facts; it makes the
  digest/checker boundary mechanically explicit for downstream consumers.

## Target Formulas

### Digest-field grouped surfaces

For one realized kernel digest

$$
\mathrm{KernelExecutionDigest}(d),
$$

this owner must expose the exact grouped surfaces already packaged by the
digest:

$$
\mathrm{KernelTraceSurface}(frames),
$$

$$
\mathrm{KernelExportSurface}(frames),
$$

$$
\mathrm{KernelAuditSurface}(frames),
$$

$$
\mathrm{KernelManifestSurface}(kernelManifest, rootManifest),
$$

$$
\mathrm{KernelTranscriptSurface}(meta.semanticRows, events),
$$

and

$$
\mathrm{KernelErrorSurface}(accounting).
$$

### Digest realization from grouped fields

The grouped fields of a realized digest must be sufficient to recover the exact
digest realization predicate:

$$
\mathrm{KernelExecutionDigest}(d)
\Longrightarrow
\mathrm{KernelExecutionDigestBound}(d,\dots).
$$

This theorem must recover the same exact theorem-facing digest realization used
by `Chip8KernelExecutionDigest`, not a weaker approximation.

### Audit-check grouped surfaces

The Lean audit checker is defined as the conjunction of grouped surface checks.
This owner must expose one theorem per grouped surface showing that a realized
digest satisfies:

- `checkKernelTraceSurface`
- `checkKernelExportSurface`
- `checkKernelAuditSurface`
- `checkKernelManifestSurface'`
- `checkKernelTranscriptSurface`
- `checkKernelErrorSurface`

### Audit acceptance from digest

Finally, one realized digest must satisfy the bundled audit acceptance surface:

$$
\mathrm{KernelExecutionDigest}(d)
\Longrightarrow
\mathrm{KernelArtifactAuditAccepted}(d,\dots).
$$

This does not introduce a new trust boundary. It makes explicit that the
Lean-owned checker consumes exactly the same grouped surfaces already carried by
the Lean-owned digest contract.

## Paper Anchors

- **Sources**:
  - `./docs/assurance-strategy.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8KernelExecutionDigest.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8KernelArtifactAudit.spec.md`
- Anchors:
  - Layer 3 checks the Lean-defined digest contract
  - the checker must land in the same theorem surface as Layer 1
  - digest/checker alignment must be explicit and auditor-readable

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Theorem | `kernelTraceSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest exposes its grouped trace surface directly |
| Theorem | `kernelExportSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest exposes its grouped export surface directly |
| Theorem | `kernelAuditSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest exposes its grouped audit surface directly |
| Theorem | `kernelManifestSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest exposes its grouped manifest surface directly |
| Theorem | `kernelTranscriptSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest exposes its grouped transcript surface directly |
| Theorem | `kernelErrorSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest exposes its grouped error surface directly |
| Theorem | `kernelExecutionDigestBound_of_digest` | theorem | Theorem-Target | Realized kernel digest determines its exact theorem-facing realization predicate |
| Theorem | `checkKernelTraceSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest satisfies the grouped trace checker surface |
| Theorem | `checkKernelExportSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest satisfies the grouped export checker surface |
| Theorem | `checkKernelAuditSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest satisfies the grouped audit checker surface |
| Theorem | `checkKernelManifestSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest satisfies the grouped manifest checker surface |
| Theorem | `checkKernelTranscriptSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest satisfies the grouped transcript checker surface |
| Theorem | `checkKernelErrorSurface_of_digest` | theorem | Theorem-Target | Realized kernel digest satisfies the grouped error checker surface |
| Theorem | `kernelArtifactAuditAccepted_of_digest` | theorem | Theorem-Target | Realized kernel digest satisfies the bundled Lean audit-acceptance predicate |

## Proof Obligations

- This owner must not add new theorem-level kernel facts.
- It must not weaken the digest realization predicate into a checker-only view.
- It must make the checker decomposition explicit enough that a downstream
  exporter can target grouped surfaces rather than raw conjunction indexing.
- It must preserve the assurance-strategy layering: Layer 1 owns soundness,
  Layer 3 checks the Lean-defined digest boundary.
