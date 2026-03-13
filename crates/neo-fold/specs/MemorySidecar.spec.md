# MemorySidecar

## Purpose

- **What it is**: The Route-A memory sidecar layer that instantiates Twist-derived memory claims, residual generic lookup-side checks, openings, and verifier obligations for shard folding.
- **What it owns**: Real Twist (RAM/register consistency), virtual decomposition (MUL/DIV multi-limb sequences), Poseidon/precompiles, memory-side claim planning, batched time claims, Route-A memory claim construction, address pre-proofs, transcript binding, and final Route-A memory-step verification. Residual generic Shout compatibility may live here, but dedicated maintained opcode lookup proving belongs to [InstructionLookup.spec.md](crates/neo-fold/specs/InstructionLookup.spec.md).
- **What it does not own**: Instruction routing/state-transition glue (main lane), decode/control flag routing (main lane), register-address binding (main lane), branch-conditioned `pc_after` routing (main lane), load/store width routing (main lane), or any fake transport on the supported trace frontends. All routing and glue constraints live in the main-lane CCS as uniform flag-gated constraints following the Jolt model. On the maintained RV64 path this includes register-address packing, branch-conditioned `pc_after`, and `LB/LBU/LH/LHU/LW/LWU/LD/SB/SH/SW/SD`, and Route-A has no decode or control transport stage there.
- **What it must not do**: Become the owner of shard orchestration or session policy, weaken paper sidecar semantics into implementation-only shortcuts, or re-introduce routing/glue/decode/width ownership that belongs in the main lane.

## Architectural Position

- **Layer**: extension
- **Direct paper theorem owner?** Yes, for the Twist-derived Route-A memory extension semantics and any residual generic lookup semantics that remain under Route-A. It is not the owner of SuperNeo Section 7 reductions, and it is not the maintained hot opcode lookup owner.
- **Consumes lower-layer semantics from**: Jolt-style machine/trace frontends and lower CCS/sidecar arithmetic crates
- **Exports semantics to**: [ShardFolding.spec.md](crates/neo-fold/specs/ShardFolding.spec.md), [TimeOpening.spec.md](crates/neo-fold/specs/TimeOpening.spec.md), Rust artifact/session exporters
- **Erasure rule**: erasing Rust-only exporter metadata must preserve the same Route-A claim, opening, and verifier obligations.

In repo terminology, the "Nightstream extension layer" is the combination of dedicated instruction lookup, memory-side Route-A sidecars, and time-opening/joint-opening obligations. This is an architectural umbrella term, not a paper theorem label.

## Target Formulas (Paper -> Rust)

| Paper notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| Twist time/address/increment checks | Twist §5 | `RouteATwistTimeClaimsGuard`, `TwistRouteAProtocol`, `verify_twist_addr_pre_time` | Memory-side Route-A proof machinery |
| virtual decomposition stages | implementation support over extension claims | packed-opcode oracles and residual virtual-sequence helpers | MUL/DIV multi-limb virtual sequences and any remaining non-routing residual stages after main-lane routing moved out of Route-A |
| batched time claims for memory-side stages | extension fast prover path | `RouteATimeClaimPlan`, `RouteABatchedTimeClaims`, `prove_route_a_batched_time`, `verify_route_a_batched_time` | Batched time-claim aggregation for memory-side and residual sidecar stages |
| final Route-A memory-step verification | implementation support over extension claims | `verify_route_a_memory_step` | Verifier-facing memory-side sidecar check for one step |

## Direct Paper Anchors

- `docs/twist-and-shout-paper/4_the_shout_piop.md`
- `docs/twist-and-shout-paper/5_the_twist_piop.md`

## Context Anchors

- `crates/neo-fold/specs/Architecture.spec.md`
- `crates/neo-fold/specs/InstructionLookup.spec.md`
- `docs/twist-and-shout-paper/2_overview_of_twist_and_shout_and_their_costs.md`
- `docs/jolt-paper/13-B_Overview_of_Memory-Checking_Arguments.md`
- `docs/architecture/how-superneo-works.md`

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `specs/ProtocolRelations.spec.md` | `SuperNeo/ProtocolRelations.lean` | Paper CCS/CE relations that the sidecar ultimately feeds |
| `specs/RustRefinement/NeoFoldArtifactValidation.spec.md` | `SuperNeo/NeoFoldArtifactValidation.lean` | Defines executable checks for Route-A batched-time transcripts, CPU/shift metadata wrappers, CE witness semantics, lane summaries, `ccs_out.r`, and tamper rejection |
| `specs/RustRefinement/NeoFoldRelationValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldRelationValidation.lean` | Exposes `paperArtifactRelationChecks` and `paperArtifactRelationChecks_implies_paperArtifactStepRelationsAccepts`, including auxiliary-lane singleton-input linkage and joint-opening obligations |
| `specs/RustRefinement/NeoFoldStepSemanticValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldStepSemanticValidation.lean` | Exposes `paperArtifactStepSemanticChecks` and `paperArtifactStepSemanticChecks_implies_paperArtifactStepSemanticsAccepts` for current-step and witness-chain semantic checks |

## Contract Surface

### Claim planning

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `TimeClaimMeta` | struct | Core | One named time-claim descriptor |
| `POSEIDON_CYCLE_CLAIM_METAS`, `POSEIDON_LOCAL_TIME_CLAIM_METAS` | const arrays | Core | Canonical Poseidon time-claim metadata |
| `poseidon_cycle_claim_metas`, `poseidon_local_time_claim_metas` | fn | Core | Metadata accessors |
| `TwistTimeClaimIdx` | struct | Core | Canonical indices for Twist claims |
| `RouteATimeClaimPlan` | struct | Core | One owner for per-step memory-side Route-A claim planning |
| `TwistValEvalClaimPlan` | struct | Core | One owner for Twist val-evaluation planning |

Representative planning methods:
- `RouteATimeClaimPlan::poseidon_stage_required_for_step_instance`
- `RouteATimeClaimPlan::poseidon_stage_required_for_step_witness`
- `RouteATimeClaimPlan::time_claim_metas_for_instances`
- `RouteATimeClaimPlan::time_claim_metas_for_step`
- `RouteATimeClaimPlan::build`
- `TwistValEvalClaimPlan::build`
- `TwistValEvalClaimPlan::base`

### Batched time claims

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `RouteABatchedTimeProverOutput` | struct | Core | Prover result for batched time claims |
| `ExtraBatchedTimeClaim` | struct | Core | One extra batched claim |
| `PoseidonCycleTimeClaims`, `OutputBindingTimeClaims` | structs | Core | Stage-grouped time claims for memory-side and residual extension stages after removing maintained-RV64 decode/control routing from Route-A |
| `RouteABatchedTimeClaims` | struct | Core | One owner for all stage-grouped batched time claims |
| `OutputBindingTimeVerifyConfig`, `RouteABatchedTimeVerifyConfig` | structs | Core | Verifier-side grouped config |
| `prove_route_a_batched_time` | fn | Core | Canonical batched-time prover |
| `RouteABatchedTimeVerifyOutput` | struct | Core | Batched-time verifier output |
| `verify_route_a_batched_time` | fn | Core | Canonical batched-time verifier |
| `PoseidonLocalTimeProverOutput`, `PoseidonLocalTimeVerifyOutput` | structs | Core | Poseidon local-time proof outputs |
| `prove_poseidon_local_time`, `verify_poseidon_local_time` | fn | Core | Canonical Poseidon local-time proof pair |

### Route-A claim construction and verification

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `RouteATwistTimeClaimsGuard<'a>` | struct | Core | Guarded view over Twist time claims |
| `build_route_a_twist_time_claims_guard` | fn | Core | Canonical Twist claim-guard builder |
| `append_route_a_twist_time_claims` | fn | Core | Appends Twist time claims in canonical order |
| `TwistRouteAProtocol<'a>` | struct | Core | One owner for Twist Route-A claim construction |
| `verify_route_a_memory_step` | fn | Core | Final Route-A step verifier |
| `verify_twist_addr_pre_time` | fn | Core | Address pre-proof verifier |

### Transcript/common Route-A objects

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `absorb_step_memory` | fn | Core | Binds step memory objects into the transcript in canonical order |
| `RouteATwistTimeOracles`, `RouteAMemoryOracles` | structs | Core | Canonical Route-A oracle bundles for memory-side stages |
| `TimeBatchedClaims` | trait | Core | Common trait for batched time claims |
| `TwistTimeLaneOpeningsLane`, `TwistTimeLaneOpenings` | structs | Core | Twist opening bundles |
| `RouteAMemoryVerifyOutput` | struct | Core | Final Route-A verification output |

## Invariant Obligations

| ID | Invariant | Lean anchor | Why it matters |
|---|---|---|---|
| `MS-1` | Claim planning is the single source of truth for Route-A time-claim ordering and grouping | Rust-side claim-plan owner; consumed by `NeoFoldArtifactValidation` item `4` | Prevents stage/claim drift |
| `MS-2` | Route-A batched-time transcripts validate under the shared challenge point | `NeoFoldArtifactValidation` item `4` | Prevents time-claim prover/verifier drift |
| `MS-3` | Residual one-hot/address-pre sidecar checks remain sound | Twist/generic-lookup paper anchors + Route-A verifier tests | Prevents false memory/lookup acceptance on residual generic lookup paths |
| `MS-4` | Decoded sparse oracle representations match the claims and openings they feed | `NeoFoldArtifactValidation` items `5` and `7` | Prevents exporter/verifier mismatch |
| `MS-5` | Auxiliary-lane singleton-input linkage holds for exported artifacts | `NeoFoldRelationValidation` item `2`; `paperArtifactRelationChecks`; `paperArtifactRelationChecks_implies_paperArtifactStepRelationsAccepts` | Ensures auxiliary sidecar lanes feed the folding relation correctly |
| `MS-6` | Current-step and witness-chain sidecar semantics remain valid after erasing Rust-only sidecars | `NeoFoldStepSemanticValidation` items `1-3`; `paperArtifactStepSemanticChecks`; `paperArtifactStepSemanticChecks_implies_paperArtifactStepSemanticsAccepts` | Prevents sidecar witness drift that still looks structurally well-formed |
| `MS-7` | Sidecar transcript binding order is prover/verifier consistent | `NeoFoldArtifactValidation` items `2-5` | Prevents challenge drift |
| `MS-8` | The sidecar does not own any routing/glue/decode/control/register-address/branch-routing/width constraints — those belong to the main-lane CCS | ISA-in-CCS plan | Prevents routing from drifting back into the sidecar |
| `MS-9` | Supported trace frontends do not materialize fake transport tables — any residual Shout tables perform real lookup verification, maintained RV64 does not reintroduce decode/width transport, and maintained hot opcode lookup ownership stays outside this layer | ISA-in-CCS plan + architecture contract | Prevents transport-only anti-patterns and owner drift |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Twist and residual generic-lookup semantics are correct | Twist/Shout docs | This layer is the Rust realization of those claims |
| CPU-step bundles accurately encode the machine-side witness/state transitions | `neo-fold` trace/session layers | Sidecar claims are built from those bundles |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-memory`
- `neo-ccs`
- `neo-transcript`
- `neo-math`

Primary consumers:
- `neo-fold::shard`
- `neo-fold::session` shared-bus path
- trace frontends
- Rust artifact/session exporters

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| exported valid Route-A shard artifacts | accepted by Lean artifact validators |
| exported tampered Route-A shard artifacts | rejected by Lean artifact validators |
| projected paper-core step relations over real Route-A artifacts | accepted by Lean relation validators, especially auxiliary-lane linkage and joint-opening obligations |

## Quality Expectations

- Claim ordering and stage requirements must have one obvious owner.
- Route-A common modules should hide mechanism, not semantic stage meaning.
- Batched-time APIs should stay grouped by stage semantics rather than positional parameter dumps.
- No routing, decode, control, register-address, branch-conditioned-PC, or width constraints in the sidecar — all belong to main-lane CCS.
- Supported trace frontends do not materialize fake transport tables.
- Any residual generic lookup compatibility must stay outside the maintained RV64 hot path.
- Sidecar stages are limited to: real Twist, residual generic lookup support, virtual decomposition, Poseidon/precompiles.

## Acceptance Criteria

1. Route-A memory-side prove/verify succeeds for maintained valid memory/precompile families and fails for tampered families.
2. Claim planning remains the single source of truth for claim ordering and stage requirements.
3. Real exported Route-A artifacts satisfy Lean artifact and relation validators.

## Out of Scope

- Session orchestration
- Shard wrapper/API policy
- Final theorem composition
