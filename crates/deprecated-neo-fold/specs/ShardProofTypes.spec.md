# ShardProofTypes

## Purpose

- **What it is**: The proof-data schema exported by shard proving and consumed by session orchestration, finalization, Rust exporters, and Lean refinement.
- **What it owns**: Typed representation of time-fold steps, memory-side and instruction-lookup extension proofs, RLC/DEC proofs, opening manifests/reductions, per-step proof objects, and shard-level obligation summaries.
- **What it must not do**: Invent weaker semantic surrogates than the verifier actually checks, or let compatibility/convenience fields redefine the proof boundary.

## Architectural Position

- **Layer**: proof-data boundary
- **Direct paper theorem owner?** No. This module carries the data boundary between lower theorem surfaces and Rust/session/export consumers.
- **Consumes lower-layer semantics from**: [ShardFolding.spec.md](crates/deprecated-neo-fold/specs/ShardFolding.spec.md), [InstructionLookup.spec.md](crates/deprecated-neo-fold/specs/InstructionLookup.spec.md), [MemorySidecar.spec.md](crates/deprecated-neo-fold/specs/MemorySidecar.spec.md), [TimeOpening.spec.md](crates/deprecated-neo-fold/specs/TimeOpening.spec.md)
- **Exports semantics to**: [Session.spec.md](crates/deprecated-neo-fold/specs/Session.spec.md), [Finalize.spec.md](crates/deprecated-neo-fold/specs/Finalize.spec.md), Rust artifact/session exporters, Lean refinement validators
- **Erasure rule**: erasing Rust-only metadata and strengthening fields must preserve the paper-core and extension proof meaning carried by the lower semantic subfields.

## Target Formulas (Paper -> Rust)

| Paper notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| one folded step proof | SuperNeo §7.2-§7.4 | `StepProof` | One shard step’s main proof, auxiliary lanes, sidecars, and output binding |
| `Π_RLC` / `Π_DEC` proof objects | SuperNeo §7.3-§7.4 | `RlcDecProof` | Parent/child claim and witness reductions |
| opening claim/reduction objects | joint-opening / time-opening machinery | `OpeningClaimManifest`, `OpeningReductionProof`, `OpeningUnificationProof`, `JointOpeningGroupProof`, `JointOpeningLaneProof` | Rust proof-data layer for time openings |
| carried obligations between folds | SuperNeo Thm 1; §7.5 | `ShardObligations<C,FF,KK>`, `ShardFoldOutputs<C,FF,KK>`, `ShardFoldWitnesses<FF>` | One owner for outgoing shard obligations |
| shard-level folded proof | implementation support | `ShardProof` | Exported proof for one shard or segment |

## Direct Paper Anchors

This module is not a direct paper-theorem owner. It is the Rust proof-data boundary for lower theorem-bearing layers.

## Context Anchors

- `crates/deprecated-neo-fold/specs/Architecture.spec.md`
- `formal/superneo-lean/SuperNeo.pdf.md`
  - §7.2: `Π_CCS`
  - §7.3: `Π_RLC`
  - §7.4: `Π_DEC`
  - §7.5: arithmetic composition
  - Thm 1: final theorem surface
- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
- `docs/twist-and-shout-paper/4_the_shout_piop.md`
- `docs/twist-and-shout-paper/5_the_twist_piop.md`

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `specs/ProtocolTheorem.spec.md` | `SuperNeo/ProtocolTheorem.lean` | Final theorem obligations consume the folded claim surface represented here |
| `specs/RustRefinement/NeoFoldArtifactValidation.spec.md` | `SuperNeo/NeoFoldArtifactValidation.lean` | Rust artifact validation over exported proof objects |
| `specs/RustRefinement/NeoFoldRefinement.spec.md` | `SuperNeo/RustRefinement/NeoFoldRefinement.lean` | Defines `PaperCEClaim`, `ImplCEClaimSidecar`, `PaperFoldLane`, `projectPaperCEClaim`, `projectPaperFoldLane`, `embedPaperCEClaim`, `embedPaperFoldLane`, and the projection/embedding theorems `projectPaperCEClaim_embedPaperCEClaim` and `projectPaperFoldLane_embedPaperFoldLane` |

## Semantic Tiers in Exported Proof Data

| Tier | Meaning | Representative surfaces |
|---|---|---|
| paper-core folded data | Section 7 folded claims and outgoing obligations | `RlcDecProof`, main-lane reductions, `ShardObligations`, final folded children |
| extension proof data | Memory-side, instruction-lookup, and time-opening/joint-opening proof objects consumed by shard verification | `MemOrLutProof`, `MemSidecarProof`, `BatchedTimeProof`, `OpeningClaimManifest`, `OpeningReductionProof`, `OpeningUnificationProof`, `JointOpening*` |
| Rust-only metadata / strengthening | Exporter metadata, audits, optional strengthenings, compatibility fields | audit structs, segment metadata, output-binding-related fields, sidecar-only refinement metadata |

Mixed containers:
- `StepProof` mixes paper-core folded data, extension proof data, and Rust-only metadata/strengthening.
- `ShardProof` is a mixed top-level container that must preserve the tier of each semantic subfield explicitly.

## Contract Surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `TwistProofK`, `ShoutProofK` | type aliases | Core | Canonical proof scalar types for Twist and residual-generic-lookup sidecars |
| `CpuTimeSumcheckProof`, `ShiftTimeSumcheckProof` | structs | Core | Time-claim sumcheck proof wrappers |
| `TimeOpeningSource` | enum | Core | Source of a time opening value |
| `TimePointOpening`, `TimeOpeningProof` | structs | Core | Point-evaluation opening proof data |
| `OpeningDomain` | enum | Core | Which logical domain an opening belongs to |
| `OpeningClaimEntry`, `OpeningClaimManifest` | structs | Core | Manifest of all opening claims |
| `OpeningReductionGroup`, `OpeningReductionProof` | structs | Core | Batched reduction of opening claims |
| `OpeningUnificationProof` | struct | Core | Final unification sumcheck proof |
| `JointOpeningGroupProof`, `JointOpeningLaneProof` | structs | Core | Joint-lane opening proof data |
| `JointClaimKind` | enum | Core | Kind of joint claim carried in lane proofs |
| `FoldingLanes` | struct | Core | Main and auxiliary lane fold results |
| `ShoutAddrPreProof<KK>`, `ShoutAddrPreGroupProof<KK>` | structs | Core | Shout pre-address proof families |
| `TimeFoldStep` | struct | Core | One time-fold proof stage |
| `FoldStep` | type alias | Core | Alias to `TimeFoldStep` |
| `ShardObligations<C,FF,KK>` | struct | Core | Aggregated main and auxiliary outgoing obligations |
| `ShardFoldOutputs<C,FF,KK>` | struct | Core | Fold outputs produced by one shard |
| `ShardFoldWitnesses<FF>` | struct | Core | Witness material paired with fold outputs |
| `MemOrLutProof` | enum | Core | Extension proof variant for memory-side or instruction-lookup proof material |
| `MemSidecarProof<C,FF,KK>` | struct | Core | Aggregated extension proof bundle carrying memory-side and lookup-side proof material as verifier-relevant variants |
| `BatchedTimeProof` | struct | Core | Batched time-claim proof bundle |
| `RlcDecProof` | struct | Core | `Π_RLC`/`Π_DEC` proof data for one lane |
| `StepProof` | struct | Core | One full folded step proof |
| `ShardSegmentKind`, `ShardSegmentMeta` | enum/struct | Core | Segment classification metadata |
| `ShardProof` | struct | Core | Exported shard/segment proof object |

### Public methods with semantic meaning

| Rust symbol | Role | Contract |
|---|---|---|
| `ShardObligations::all_len` | Inspector | Returns total outgoing-obligation count |
| `ShardObligations::iter_all` | Inspector | Iterates over all outgoing obligations |
| `ShardObligations::require_all_finalized` | Validator | Fails if any obligation remains unfinalized |
| `ShardObligations::split` | Helper | Splits main and auxiliary obligations |
| `ShardProof::compute_final_obligations` | Core | Recomputes final obligations exactly as the verifier expects |
| `ShardProof::compute_final_main_children` | Core | Recomputes main-lane carried children |
| `ShardProof::compute_fold_outputs` | Core | Recomputes fold outputs paired with witness data |

## Invariant Obligations

| ID | Invariant | Lean anchor | Why it matters |
|---|---|---|---|
| `SPT-1` | `projectPaperCEClaim (embedPaperCEClaim claim) = claim` | `projectPaperCEClaim_embedPaperCEClaim` | Exported claim types must support erasure to the paper-core CE view without losing meaning |
| `SPT-2` | `projectPaperFoldLane (embedPaperFoldLane lane) = lane` | `projectPaperFoldLane_embedPaperFoldLane` | Exported lane types must support erasure to the paper-core lane view without losing meaning |
| `SPT-3` | Implementation-sidecar CE metadata is limited to the Rust-only refinement fields (`foldDigest`, `cStepCoords`, `uOffset`, `uLen`) | `PaperCEClaim`, `ImplCEClaimSidecar`, `projectPaperCEClaim` | Keeps the line between paper semantics and Rust-only metadata explicit |
| `SPT-4` | Proof-data structs preserve all verifier-relevant semantics after projection to the paper-core claim/lane views | `PaperCEClaim`, `PaperFoldLane`, `implArtifactChecks_refines_paperArtifactCoreAccepts`, `implArtifactChecks_refines_paperArtifactFullAccepts` | Prevents exporter/session drift |
| `SPT-5` | `ShardProof::compute_*` helpers match verifier semantics exactly | Rust verifier + Lean artifact/session refinement | Prevents downstream recomputation drift |
| `SPT-6` | Main and auxiliary obligations remain distinguishable and complete | Rust verifier + artifact validators | Prevents silent loss of carried claims |
| `SPT-7` | Opening-proof objects preserve the exact domain/source information checked by the verifier | Time-opening layer + artifact validators | Prevents joint-opening weakening |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Shard proving/verifying constructs and consumes these objects consistently | `ShardFolding.spec.md` | These types are the data boundary for shard folding |
| Dedicated instruction-lookup proof material is kept semantically explicit even when transport containers aggregate multiple extension families | `InstructionLookup.spec.md` | Prevents memory-side and lookup-side proof meaning from collapsing into an untyped blob |
| Time-opening layer is correct | `TimeOpening.spec.md` | Opening proof objects are only meaningful relative to that layer |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-fold::time_opening`
- `neo-fold::memory_sidecar`

Primary consumers:
- `neo-fold::shard`
- `neo-fold::session`
- `neo-fold::finalize`
- Rust artifact/session exporters
- Lean Rust-refinement validators

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| exported shard proofs | accepted/rejected by Lean artifact validators exactly as Rust intends |
| valid exported shard proofs after sidecar erasure | satisfy the paper-core artifact predicates built from `PaperCEClaim` and `PaperFoldLane` |

## Quality Expectations

- Proof-data types are part of the protocol contract and must stay explicitly specified.
- New fields require justification as either verifier-relevant or Rust-only refinement metadata.
- Helper methods that recompute obligations must remain semantically identical to verifier behavior.

## Acceptance Criteria

1. Exported proof objects are sufficient for session verification/finalization and Rust→Lean refinement.
2. `compute_final_obligations`, `compute_final_main_children`, and `compute_fold_outputs` remain aligned with verifier semantics.
3. Valid/tampered exported artifacts are distinguished by the Lean validators.

## Out of Scope

- Session orchestration policy
- Trace frontends
- Detailed Route-A arithmetic semantics
