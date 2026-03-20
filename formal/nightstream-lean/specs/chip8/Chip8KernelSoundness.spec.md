# Chip8KernelSoundness Spec

## Purpose

- **What it is**: The top-level theorem-facing soundness owner for one
  authenticated CHIP-8 kernel chunk.
- **Key property**: `kernelSoundness_of_boundaries` composes exact trace
  evidence, the simple-kernel chunk-input contract, exact kernel/root opening
  discipline, the exact transcript schedule, and the exact soundness-accounting
  package into one explicit kernel conclusion bundle.
- **Auditor entrypoint**: `KernelSoundnessAccepted` packages the kernel
  acceptance boundary into one named predicate, and the direct corollaries
  expose the named authenticated temporal-support bundle, exact execution
  correctness, the authenticated chunk-trace surface, prepared-step export, and
  negligible total soundness error without forcing consumers to manually
  thread the conjunction.
- **Protocol role**: This module sits above
  `Chip8AuthenticatedTrace`, `Chip8OpeningBoundary`,
  `Chip8TranscriptSchedule`, and `Chip8SoundnessAccounting`. It does not re-own
  any Stage 1 / Stage 2 / Stage 3 theorem.

## Target Formulas

### Kernel prepared steps

Define:

$$
\mathrm{kernelPreparedSteps}(frames)
:=
\mathrm{map}\left(
  frame \mapsto \mathrm{mkPreparedStep}(\mathrm{RootEncode}, \mathrm{AjtaiCommit}, frame.row)
\right)(\mathrm{traceOf}(frames)).
$$

This is the exact root-facing export induced by the authenticated semantic
trace.

### Kernel conclusion bundle

Define `KernelSoundnessConclusion` to package the following theorem surfaces for
one kernel chunk:

1. authenticated temporal support for strong trace linking:

$$
\mathrm{AuthenticatedTemporalSupportBound}(frames)
$$

2. exact chunk execution correctness:

$$
\mathrm{ExecutionCorrect}(rom,\sigma,init,\mathrm{traceOf}(frames))
$$

3. authenticated chunk-trace closure:

$$
\mathrm{AuthenticatedChunkTraceBound}(frames)
$$

4. exact prepared-step export:

$$
\mathrm{kernelPreparedSteps}(frames).length = meta.semanticRows
$$

and

$$
\mathrm{PreparedStepTraceBound}(
  \mathrm{traceOf}(frames),
  \mathrm{kernelPreparedSteps}(frames)
)
$$

5. exact `root0` commitment binding for kernel opening claims:

$$
\forall claim \in kernelManifest,\;
claim.commitmentId \in \mathrm{root0CommitmentIds}
$$

6. kernel/root commitment separation:

$$
\forall kernelClaim \in kernelManifest,\;
\forall rootClaim \in rootManifest,\;
kernelClaim.commitmentId \neq rootClaim.commitmentId
$$

7. exact transcript-order consequences:

for every challenge event:

$$
\mathrm{ChallengeEvent}(e)
\Longrightarrow
\exists rest,\;
events = \mathrm{phase0Events} \mathbin{+\!\!+} rest \land e \in rest
$$

for every Stage-1 terminal-point event:

$$
\mathrm{Stage1TerminalPointEvent}(e)
\Longrightarrow
\exists rest,\;
events = \mathrm{phase0Events} \mathbin{+\!\!+} rest \land e \in rest
$$

for every Stage-2 terminal-point event:

$$
\mathrm{Stage2TerminalPointEvent}(e)
\Longrightarrow
\exists rest,\;
events = \mathrm{phase0Events} \mathbin{+\!\!+} rest \land e \in rest
$$

exact Stage-3 row-binding coverage:

$$
\mathrm{rowBinding}(j) \in events
\Longleftrightarrow
j < meta.semanticRows
$$

and final emit placement:

$$
\exists pre,\;
events = pre \mathbin{+\!\!+} [\mathrm{emitKernelOpeningClaims}]
$$

8. negligible total soundness error:

$$
\mathrm{IsNegligible}(accounting.\varepsilon_{\mathrm{total}})
$$

### Main theorem target

The top-level theorem target is:

$$
\mathrm{ExactTraceEvidence}(frames)
\land
\mathrm{SimpleKernelChunkInput}(init, meta.semanticRows, \mathrm{traceOf}(frames))
\land
\mathrm{ExactKernelOpeningBoundary}(pts, kernelManifest, rootManifest)
\land
\mathrm{KernelTranscriptSchedule}(meta.semanticRows, events)
\land
\mathrm{AuthenticatedTemporalSupportBound}(frames)
\land
\mathrm{KernelSoundnessAccounting}(accounting)
$$

$$
\Longrightarrow
\mathrm{KernelSoundnessConclusion}(\dots).
$$

This is the exact theorem-facing owner that turns the current Nightstream
bridge into one kernel-level statement that includes the strong execution-trace
soundness claim required by the kernel spec.

### Accepted boundary packaging

Define:

$$
\mathrm{KernelSoundnessAccepted}(frames, pts, kernelManifest, rootManifest, events)
$$

to package the exact conjunction:

$$
\mathrm{ExactTraceEvidence}(frames)
\land
\mathrm{SimpleKernelChunkInput}(init, meta.semanticRows, \mathrm{traceOf}(frames))
\land
\mathrm{ExactKernelOpeningBoundary}(pts, kernelManifest, rootManifest)
\land
\mathrm{KernelTranscriptSchedule}(meta.semanticRows, events)
\land
\mathrm{AuthenticatedTemporalSupportBound}(frames).
$$

The bundled theorem target is then:

$$
\mathrm{KernelSoundnessAccepted}(\dots)
\Longrightarrow
\mathrm{KernelSoundnessConclusion}(\dots).
$$

Direct corollaries must expose:

$$
\mathrm{stage2TemporalSeedSummary}(frames),
$$

$$
\mathrm{AuthenticatedTemporalSupportBound}(frames),
$$

$$
\mathrm{TraceLinkBound}(\mathrm{traceOf}(frames)),
$$

$$
\mathrm{ExecutionLinked}(\mathrm{traceOf}(frames)),
$$

$$
\mathrm{ExecutionCorrect}(rom,\sigma,init,\mathrm{traceOf}(frames)),
$$

possibly by normalizing through an authenticated execution-trace bundle that
packages the chunk-local trace surface together with the exact per-row
Stage-2 temporal seed summary and the named authenticated temporal-support
bundle (chunk-global Stage-2 temporal context plus the exact Stage-3 `pc`
bridge),

$$
\mathrm{AuthenticatedChunkTraceBound}(frames),
$$

$$
\mathrm{kernelPreparedSteps}(frames).length = meta.semanticRows
\;\land\;
\mathrm{PreparedStepTraceBound}(
  \mathrm{traceOf}(frames),
  \mathrm{kernelPreparedSteps}(frames)
),
$$

and:

$$
\mathrm{IsNegligible}(accounting.\varepsilon_{\mathrm{total}}).
$$

## Paper Anchors

- **Sources**:
  - `./crates/neo-fold-next/specs/chip8-kernel.md`
  - `./docs/soundness-specs/twist-and-shout-requirements.md`
  - `./docs/assurance-strategy.md`
  - `./docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
- Anchors:
  - exact Stage-1 / Stage-2 / Stage-3 ownership split
  - authenticated chunk-trace closure from staged evidence
  - component-wise temporal consistency over `pc`, `I`, `V[0..15]`, and
    `RAM[0..4095]`
  - exact adjacent-state linking across the semantic prefix
  - commitment-before-challenge and exact `root0` discipline
  - exact prepared-step bridge export
  - exact parameterized soundness accounting

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/KernelSoundness.lean` | Top-level CHIP-8 kernel soundness conclusion |
| `Nightstream/Chip8/KernelSoundnessInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Export | `kernelPreparedSteps` | def | Definitional | Canonical prepared-step list exported from one authenticated trace |
| Conclusion | `KernelSoundnessConclusion` | def | Definitional | Bundles the exact top-level kernel conclusions |
| Acceptance | `KernelSoundnessAccepted` | def | Definitional | Exact theorem-facing kernel acceptance boundary |
| Theorem | `kernelSoundness_of_boundaries` | theorem | Theorem-Target | Exact row evidence + chunk input + opening boundary + transcript schedule + accounting imply the full kernel conclusion bundle |
| Theorem | `kernelSoundness_of_acceptance` | theorem | Theorem-Target | Accepted kernel boundary instances imply the full kernel conclusion bundle |
| Theorem | `kernelAcceptanceImpliesAuthenticatedChunkTrace` | theorem | Theorem-Target | Accepted kernel boundary instances imply the authenticated chunk-trace surface exported by the current kernel boundary |
| Theorem | `kernelAcceptanceImpliesStage2TemporalSeeds` | theorem | Theorem-Target | Accepted kernel boundary instances imply the exact per-row Stage-2 temporal seed summary exported by authenticated trace closure |
| Theorem | `kernelAcceptanceImpliesTraceLinkBound` | theorem | Theorem-Target | Accepted kernel boundary instances imply the exact adjacent-state link contract directly |
| Theorem | `kernelAcceptanceImpliesExecutionLinked` | theorem | Theorem-Target | Accepted kernel boundary instances imply the raw execution-linked trace law directly |
| Theorem | `kernelAcceptanceImpliesExecutionCorrect` | theorem | Theorem-Target | Accepted kernel boundary instances imply exact chunk execution correctness directly at the kernel boundary |
| Theorem | `kernelAcceptanceImpliesPreparedStepExport` | theorem | Theorem-Target | Accepted kernel boundary instances imply exact prepared-step export and exact semantic-row count |
| Theorem | `kernelAcceptanceImpliesNegligibleTotal` | theorem | Theorem-Target | Accepted kernel boundary instances imply negligible total soundness error |

## Proof Obligations

- This owner must not re-own Stage-1 / Stage-2 / Stage-3 semantic theorems.
- It must consume `Chip8AuthenticatedTrace` for semantic trace closure rather
  than bypassing it through a weaker digest or audit surface.
- It must consume `Chip8AuthenticatedTrace` at the exact theorem level strong
  enough to recover `ExecutionCorrect`, not merely a weaker continuity/export
  boundary.
- That authenticated trace closure must get strong execution correctness through
  the explicit temporal `RegVal` / `RamVal` / `pc` path required by the kernel
  spec, not by leaving whole-trace linking external.
- It must consume `Chip8TranscriptSchedule` for transcript-order facts rather
  than restating commitment-before-challenge informally.
- It must consume `Chip8SoundnessAccounting` for the total-error statement
  rather than collapsing the exact decomposition into a vague negligible term.
- It must keep kernel opening commitments and root commitments distinct.
- It must expose one named accepted-boundary predicate so a human auditor does
  not have to reconstruct the exact kernel conjunction manually from consumers.
- It must not leave exact adjacent-state linking as an external corollary above
  kernel acceptance if the main kernel spec claims strong execution-trace
  soundness.
