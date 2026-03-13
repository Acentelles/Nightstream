# ShardFolding

## Purpose

- **What it is**: The shard-level integration point that (a) realizes the SuperNeo Section 7 folding core over CPU CCS claims and (b) composes in optional memory-side, instruction-lookup, and time-opening extension obligations.
- **What it owns**: Per-step proving and verification, carried accumulator updates, step-linking checks, output-binding strengthening, and the proof-data boundary exported to sessions and Rust→Lean refinement tooling.
- **What it must not do**: Redefine CCS/CE semantics, redefine memory-side or instruction-lookup extension semantics, or let convenience wrapper APIs become the effective protocol spec.

## Architectural Position

- **Layer**: paper-core folding integration point
- **Direct paper theorem owner?** Yes, for the Section 7 folding core. Memory-side, instruction-lookup, and time-opening integration plus Rust-only strengthenings are additional layers composed here.
- **Consumes lower-layer semantics from**: [MemorySidecar.spec.md](crates/neo-fold/specs/MemorySidecar.spec.md), [InstructionLookup.spec.md](crates/neo-fold/specs/InstructionLookup.spec.md), [TimeOpening.spec.md](crates/neo-fold/specs/TimeOpening.spec.md), lower CCS/CE semantics from `neo-ccs`
- **Exports semantics to**: [Session.spec.md](crates/neo-fold/specs/Session.spec.md), [Finalize.spec.md](crates/neo-fold/specs/Finalize.spec.md), Rust refinement/export tooling
- **Erasure rule**: erasing step linking, output binding, and other Rust-only strengthening metadata must leave the same lower accepted shard artifact and the same projected Section 7 obligation surface.

## Target Formulas (Paper -> Rust)

| Paper notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| `Π_CCS` | SuperNeo §7.2 | `fold_shard_prove_*`, `fold_shard_verify_*`, `StepProof.main` | First shard reduction from CCS relation to CE relation and folded children |
| `Π_RLC` | SuperNeo §7.3 | `RlcDecProof` parent/child reduction objects | Relaxed linear-combination fold over carried CE claims |
| `Π_DEC` | SuperNeo §7.4 | `RlcDecProof` plus produced child claims and witnesses | Decomposition of the folded parent into carried children |
| arithmetic composition for final theorem path | SuperNeo §7.5 | `ShardProof::compute_final_obligations`, `compute_fold_outputs`, `compute_final_main_children` | Shard-local final obligations handed to sessions/finalization |
| carried CE/CCS accumulator | SuperNeo Thm 1 | `acc_init`, `ShardFoldOutputs`, `ShardFoldWitnesses`, `ShardObligations` | Incoming and outgoing obligation state for one shard |
| strengthening side conditions | implementation support | `StepLinkingConfig`, `ShardOutputBindingInput<'a>` | Rust-only strengthening features layered on top of the paper core |

## Direct Paper Anchors

- `formal/superneo-lean/SuperNeo.pdf.md`
  - Definitions 11–14: CCS/CE/global-parameter relations
  - §7.2: `Π_CCS`
  - §7.3: `Π_RLC`
  - §7.4: `Π_DEC`
  - §7.5: arithmetic composition
  - Thm 1: final protocol theorem
- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`

## Context Anchors

- `crates/neo-fold/specs/Architecture.spec.md`
- `docs/twist-and-shout-paper/4_the_shout_piop.md`
- `docs/twist-and-shout-paper/5_the_twist_piop.md`
- `docs/architecture/how-superneo-works.md`

## Lean Cross-Reference

| Lean spec | Lean module | Why it matters here |
|---|---|---|
| `specs/PiCCS.spec.md` | `SuperNeo/PiCCS.lean` | Paper `Π_CCS` theorem surface |
| `specs/PiRLC.spec.md` | `SuperNeo/PiRLC.lean` | Paper `Π_RLC` theorem surface |
| `specs/PiDEC.spec.md` | `SuperNeo/PiDEC.lean` | Paper `Π_DEC` theorem surface |
| `specs/InteractiveReductions.spec.md` | `SuperNeo/InteractiveReductions.lean` | Composition of shard reductions into the final theorem path |
| `specs/RustRefinement/NeoFoldArtifactValidation.spec.md` | `SuperNeo/NeoFoldArtifactValidation.lean` | Defines executable checks for `Π_CCS` FE/NC transcripts, Route-A batched-time transcripts, CPU/shift metadata wrappers, CE witness semantics, lane summaries, `ccs_out.r`, and tamper rejection |
| `specs/RustRefinement/NeoFoldRelationValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldRelationValidation.lean` | Exposes `paperArtifactRelationChecks`, `paperArtifactRelationChecks_implies_paperArtifactStepRelationsAccepts`, `implArtifactChecks_implies_paperArtifactRelationChecks`, and corpus booleans for projected paper-core per-step relation checks |
| `specs/RustRefinement/NeoFoldStepSemanticValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldStepSemanticValidation.lean` | Exposes `paperArtifactStepSemanticChecks`, `paperArtifactStepSemanticChecks_implies_paperArtifactStepSemanticsAccepts`, `implArtifactChecks_implies_paperArtifactStepSemanticChecks`, and corpus booleans for projected CE/witness semantics |
| `specs/RustRefinement/NeoFoldRefinement.spec.md` | `SuperNeo/RustRefinement/NeoFoldRefinement.lean` | Exposes `PaperCEClaim`, `PaperFoldLane`, `implCheckClaimCEFromWitness_sidecarInvariant`, `implCEAccepts_refines_paperCEAccepts`, `implPiRLCParentAccepts_refines_paperPiRLCParentAccepts`, `implPiDECParentAccepts_refines_paperPiDECParentAccepts`, `implFoldLaneAccepts_refines_paperFoldLaneAccepts`, `implArtifactChecks_refines_paperArtifactCoreAccepts`, `implArtifactChecks_refines_paperArtifactStepRelationsAccepts`, and `implArtifactChecks_refines_paperArtifactFullAccepts` |

## Contract Surface

### Top-level shard exports

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `fold_shard_prove_ccs_only_batched` | fn | Core | Prove one CCS-only shard batch without Route-A sidecars |
| `fold_shard_verify_ccs_only_batched` | fn | Core | Verify one CCS-only shard batch without Route-A sidecars |
| `absorb_step_memory` | fn | Core | Bind Route-A/public sidecar material into the transcript in verifier order |
| `check_step_linking` | fn | Core | Enforce configured step-linking policy on public step transitions |
| `CommitMixers<MR, MB>` | struct | Core | Carries commitment-combination operators for shard folding |
| `StepLinkingConfig` | struct | Core | Explicit linking policy owner |
| `LaneWitnessAudit`, `StepWitnessAudit`, `ShardProofAudit` | structs | Optional support | Exported audit information; verifier correctness must not depend on them |

### Proving API

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `ShardOutputBindingInput<'a>` | struct | Core | Declares output-binding expectations for one prove call |
| `ShardProveApiOptions<'a>` | struct | Core | Canonical prove-time semantic options bundle |
| `ShardProveApiResult` | struct | Core | Named prove output boundary |
| `fold_shard_prove_with_options` | fn | Core | Canonical prove entrypoint; wrappers must reduce to it |
| `fold_shard_prove` | fn | Convenience | Minimal prove surface |
| `fold_shard_prove_with_witnesses` | fn | Convenience | Prove and return witness outputs |

### Verification and finalization API

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `ShardVerifyApiOptions<'a>` | struct | Core | Canonical verify/finalize semantic options bundle |
| `fold_shard_verify_with_options` | fn | Core | Canonical verify entrypoint |
| `fold_shard_verify` | fn | Convenience | Minimal verify surface |
| `fold_shard_verify_and_finalize_with_options` | fn | Core | Canonical verify-and-finalize entrypoint |
| `fold_shard_verify_and_finalize` | fn | Convenience | Minimal verify-and-finalize |

### Proof-data boundary consumed by sessions and exporters

This spec depends on [ShardProofTypes.spec.md](crates/neo-fold/specs/ShardProofTypes.spec.md), especially:
- `StepProof`
- `RlcDecProof`
- `ShardProof`
- `ShardObligations`
- `ShardFoldOutputs`
- `ShardFoldWitnesses`

## Invariant Obligations

| ID | Invariant | Lean anchor | Why it matters |
|---|---|---|---|
| `SF-1` | CE refinement: implementation CE acceptance implies projected paper-core CE acceptance | `implCEAccepts_refines_paperCEAccepts` | This is the base conservative-extension theorem for CE claims |
| `SF-2` | CE witness checking is invariant under erasing sidecars (`foldDigest`, `cStepCoords`, `uOffset`, `uLen`) | `implCheckClaimCEFromWitness_sidecarInvariant` | Proves Rust-only metadata does not change CE witness acceptance |
| `SF-3` | `Π_RLC` parent refinement: implementation parent acceptance implies projected paper-core `Π_RLC` parent acceptance | `implPiRLCParentAccepts_refines_paperPiRLCParentAccepts` | Makes the parent reduction theorem explicit instead of only relying on the combined lane theorem |
| `SF-4` | `Π_DEC` parent refinement: implementation parent acceptance implies projected paper-core `Π_DEC` parent acceptance | `implPiDECParentAccepts_refines_paperPiDECParentAccepts` | Makes the decomposition-parent theorem explicit instead of only relying on the combined lane theorem |
| `SF-5` | Full folding-lane refinement: implementation lane acceptance implies projected paper-core lane acceptance for both `Π_RLC` and `Π_DEC` | `implFoldLaneAccepts_refines_paperFoldLaneAccepts` | This is the key lane-level composition theorem |
| `SF-6` | Whole-artifact core refinement: implementation artifact acceptance implies `paperArtifactCoreAccepts` | `implArtifactChecks_refines_paperArtifactCoreAccepts` | First whole-artifact conservative-extension theorem over projected paper-core claims |
| `SF-7` | Whole-artifact relation refinement: implementation artifact acceptance implies projected per-step relation acceptance | `implArtifactChecks_refines_paperArtifactStepRelationsAccepts`; `paperArtifactRelationChecks`; `paperArtifactRelationChecks_implies_paperArtifactStepRelationsAccepts` | Connects real Rust artifacts back to the paper-core `Π_RLC` / `Π_DEC` / joint-opening relation layer |
| `SF-8` | Whole-artifact full refinement: implementation artifact acceptance implies `paperArtifactFullAccepts` | `implArtifactChecks_refines_paperArtifactFullAccepts` | Strongest current artifact-level conservative-extension theorem |
| `SF-9` | Rust artifact validation reconstructs and validates `Π_CCS` FE and NC transcripts | `NeoFoldArtifactValidation` items `2-3` | Prevents transcript drift between prover/exporter/validator |
| `SF-10` | Rust artifact validation checks CE semantics for current, carried, parent, and child witnesses | `NeoFoldArtifactValidation` item `7`; `paperArtifactStepSemanticChecks`; `paperArtifactStepSemanticChecks_implies_paperArtifactStepSemanticsAccepts` | Ensures exported witness chains really satisfy the folded CE semantics |
| `SF-11` | Exported multi-step artifacts satisfy projected paper-core per-step relation obligations | `NeoFoldRelationValidation` items `1-3`; `generatedNeoFoldArtifactRelationChecks`; `generatedNeoFoldArtifactRelationRefinementChecks` | Gives the slow lane a direct relation-level acceptance target over the real exported corpus |
| `SF-12` | `ccs_out.r` agrees with the exported CPU time point | `NeoFoldArtifactValidation` item `10` | Prevents the step-time challenge point from silently drifting |
| `SF-13` | Step linking only strengthens acceptance | Session/session-refinement layer | Must not redefine the paper boundary |
| `SF-14` | Output binding only strengthens acceptance | Output-binding/session-refinement layer | Must not redefine the paper boundary |
| `SF-15` | Canonical options-based APIs are sufficient to drive shard folding | Rust API contract | Prevents wrapper combinatorics from becoming the effective spec |
| `SF-16` | `ShardProof::compute_*` helpers match verifier semantics | Rust code + artifact/session exporters | Prevents session/export drift |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| CCS/CE semantics are correct | `neo-ccs` specs + Lean formalization | This layer composes them; it does not redefine them |
| Memory-side sidecar semantics are correct | `MemorySidecar.spec.md` | This layer integrates memory-side sidecars into shard proving |
| Dedicated instruction-lookup semantics are correct | `InstructionLookup.spec.md` | This layer integrates maintained opcode lookup proofs into shard proving |
| Time-opening/joint-opening semantics are correct | `TimeOpening.spec.md` | This layer consumes joint-opening/opening proof objects |
| Transcript/arithmetic primitives are correct | lower crates | Required for prover/verifier agreement |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-ccs`
- `neo-math`
- `neo-ajtai`
- `neo-reductions`
- `neo-transcript`
- `neo-fold::memory_sidecar`
- `neo-fold::time_opening`
- `neo-fold::output_binding`

Primary consumers:
- `neo-fold::session`
- `rv64_trace_shard`
- Rust artifact/session exporters
- Lean refinement validators

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| valid exported shard artifacts | accepted by Rust artifact validator |
| tampered exported shard artifacts | rejected by Rust artifact validator |
| valid exported shard artifacts after sidecar erasure | satisfy `paperArtifactFullAccepts` via `implArtifactChecks_refines_paperArtifactFullAccepts` |
| valid exported shard artifacts | satisfy projected per-step relation checks from `NeoFoldRelationValidation` |
| `generatedNeoFoldArtifactRelationChecks` | `true` for the exported valid corpus |
| `generatedNeoFoldArtifactRelationRefinementChecks` | `true` for the combined valid/tampered corpus |
| real exported shard artifacts from hard integration families | satisfy direct projected paper-core relation checks |

## Quality Expectations

- Canonical shard APIs should stay options-based; wrapper families must not become the architecture.
- Shard proving/verifying should be organized by semantic phase, not by catch-all utilities.
- Duplicated protocol policy must be centralized where possible.
- Compatibility wrappers are acceptable only if the canonical options-based entrypoints remain the obvious owner.

## Acceptance Criteria

1. Canonical prove/verify/finalize APIs are sufficient to drive shard folding without feature-cartesian API growth.
2. Real exported shard artifacts satisfy `SF-5` through `SF-8` in the executable Rust artifact validators.
3. Real exported shard artifacts satisfy the Rust-to-paper conservative-extension theorem `implArtifactChecks_refines_paperArtifactFullAccepts`.
4. Step linking and output binding behave as strengthening features rather than alternate semantics.

## Out of Scope

- Session orchestration
- Trace wiring/frontends
- Direct Route-A claim-construction details
