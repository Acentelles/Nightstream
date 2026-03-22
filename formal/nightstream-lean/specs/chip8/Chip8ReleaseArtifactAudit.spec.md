# Chip8ReleaseArtifactAudit Spec

## Purpose

- **What it is**: The Lean-defined audit checker over the final CHIP-8 release
  artifact.
- **Key property**: `releaseArtifactAuditAccepted_of_bound` accepts any
  realized release artifact, and `releaseArtifactAuditSound` recovers the exact
  combined release-artifact realization predicate.
- **Protocol role**: This owner is the theorem-facing Layer-3 checker above
  `Chip8ReleaseArtifact`. It checks the combined package rather than only the
  kernel digest or only the chunk staged bundle, while
  `Chip8ExternalReleaseArtifactAudit` owns the proof-free imported Rust view
  above this theorem-facing package.

## Target Formulas

### Checker surfaces

For one release artifact `a`, define:

$$
\mathrm{checkKernelDigestSurface}(a)
$$

to mean that the packaged kernel digest satisfies the exact
`Chip8KernelArtifactAudit` acceptance predicate.

Define:

$$
\mathrm{checkStagedBundleSurface}(a)
$$

to mean that the packaged chunk bundle satisfies the exact
`Chip8StagedExecutionBundleAudit` acceptance predicate.

Define:

$$
\mathrm{checkChunkInputSurface}(a)
$$

to keep the simple-kernel chunk-input contract explicit at the final release
boundary.

The bundled checker is:

$$
\mathrm{checkReleaseArtifact}(a).
$$

### Acceptance and soundness

Define:

$$
\mathrm{ReleaseArtifactAuditAccepted}(a)
$$

to mean the bundled checker accepts the artifact.

The primary theorem target is:

$$
\mathrm{ReleaseArtifactAuditAccepted}(a)
\Longrightarrow
\mathrm{ReleaseArtifactBound}(a,\dots).
$$

This must recover the exact theorem-facing release-artifact realization
predicate, not only a weaker digest-shape compatibility view.

### Combined consequences

From accepted release-artifact audit, downstream users must be able to recover:

$$
\mathrm{KernelSoundnessConclusion}(\dots)
$$

and exact per-entry staged consequences:

$$
\mathrm{bundleAuditImpliesEntryBound}(a,\mathrm{entry}).
$$

The final checker must also expose an explicit cross-layer count consequence:

$$
\mathrm{ReleaseArtifactAuditAccepted}(a)
\Longrightarrow
\mathrm{kernelPreparedSteps}(frames).length = a.\mathrm{stagedBundle}.length.
$$

This is one of the concrete guarantees that the packaged kernel export and the
packaged staged chunk bundle describe the same semantic prefix.

## Paper Anchors

- **Sources**:
  - `./docs/assurance-strategy.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8ReleaseArtifact.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8KernelArtifactAudit.spec.md`
  - `./formal/nightstream-lean/specs/chip8/Chip8StagedExecutionBundleAudit.spec.md`
- Anchors:
  - Layer 3 should check one explicit final release package
  - the checker must recover both kernel-level and per-entry staged theorem
    surfaces
  - the final package must prove that kernel export count and staged bundle
    count agree

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Kernel/ReleaseArtifactAudit.lean` | Combined audit checker and recovery theorems over one release artifact |
| `Nightstream/Chip8/Kernel/ReleaseArtifactAuditInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Checker | `checkKernelDigestSurface` | def | Definitional | The packaged kernel digest satisfies exact kernel-digest audit acceptance |
| Checker | `checkStagedBundleSurface` | def | Definitional | The packaged staged bundle satisfies exact chunk-bundle audit acceptance |
| Checker | `checkChunkInputSurface` | def | Definitional | The simple-kernel chunk input remains explicit in the final package |
| Checker | `checkReleaseArtifact` | def | Definitional | Bundled final release-artifact checker |
| Acceptance | `ReleaseArtifactAuditAccepted` | def | Definitional | Final release-artifact acceptance predicate |
| Theorem | `checkKernelDigestSurface_of_bound` | theorem | Theorem-Target | Realized artifacts satisfy the packaged kernel-digest checker |
| Theorem | `checkStagedBundleSurface_of_bound` | theorem | Theorem-Target | Realized artifacts satisfy the packaged staged-bundle checker |
| Theorem | `checkChunkInputSurface_of_bound` | theorem | Theorem-Target | Realized artifacts satisfy the packaged chunk-input checker |
| Theorem | `releaseArtifactAuditAccepted_of_bound` | theorem | Theorem-Target | Realized artifacts are accepted by the bundled checker |
| Theorem | `releaseArtifactAuditSound` | theorem | Theorem-Target | Accepted artifacts recover the exact release-artifact realization predicate |
| Theorem | `releaseArtifactAuditImpliesKernelSoundnessConclusion` | theorem | Theorem-Target | Accepted artifacts recover the exact kernel theorem conclusion |
| Theorem | `releaseArtifactAuditImpliesEntryBound` | theorem | Theorem-Target | Accepted artifacts recover exact per-entry staged digest realization |
| Theorem | `releaseArtifactAuditImpliesBundleLength_eq_semanticRows` | theorem | Theorem-Target | Accepted artifacts recover exact semantic-row count for the packaged staged bundle |
| Theorem | `releaseArtifactAuditImpliesPreparedStepCount_eq_bundleLength` | theorem | Theorem-Target | Accepted artifacts prove kernel export count equals staged bundle count |

## Proof Obligations

- Do not redefine final acceptance as a kernel-only or bundle-only checker.
- Do not drop the simple-kernel chunk-input contract from the final checker.
- Do not weaken the kernel theorem conclusion to a digest-only consequence.
- Do not omit a concrete cross-layer count theorem; the final package must show
  that both packaged sides describe the same semantic prefix.
