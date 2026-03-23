# Session

## Purpose

- **What it is**: The front-door orchestration API for `neo-fold`: it accumulates frontend-produced CCS step bundles, carries the accumulator across shard folds, invokes the shard folding core, and exposes session-level prove/verify flows.
- **What it owns**: Session-local step accumulation, initial-state and accumulator seeding, optional step-linking and output-binding configuration, and the ergonomic bridge from direct IO or shared-bus circuits into shard proving.
- **What it must not do**: Redefine shard semantics, redefine Route-A sidecar semantics, or let convenience wrappers become the real protocol contract.

## Architectural Position

- **Layer**: orchestration
- **Direct paper theorem owner?** No. This module is a façade over lower theorem-owning layers.
- **Consumes lower-layer semantics from**: [ShardFolding.spec.md](crates/deprecated-neo-fold/specs/ShardFolding.spec.md), [InstructionLookup.spec.md](crates/deprecated-neo-fold/specs/InstructionLookup.spec.md), [MemorySidecar.spec.md](crates/deprecated-neo-fold/specs/MemorySidecar.spec.md), [TimeOpening.spec.md](crates/deprecated-neo-fold/specs/TimeOpening.spec.md)
- **Exports semantics to**: trace frontends, integration/session tests, Rust artifact and session exporters
- **Erasure rule**: removing step-linking/output-binding strengthenings and frontend convenience structure must leave the same lower shard obligations and the same projected paper-core session glue.

## Target Formulas (Paper -> Rust)

| Paper notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| carried CE/CCS accumulator between folds | SuperNeo Thm 1; §7 | `Accumulator` | Rust owner of the carried obligation state between shard folds |
| folding session over step claims | SuperNeo §7 | `FoldingSession<L>` | Main session coordinator over shard proving and verification |
| step witness / public input pair | SuperNeo Defs 12-14 | `ProveInput<'a>`, `StepSpec`, `StepArtifacts` | Ergonomic Rust-side step description |
| step transition relation | Jolt execution + SuperNeo §7.1 | `NeoStep` | User-implemented step producer interface |
| shared-bus circuit frontend | Jolt memory checking + dedicated instruction lookup + memory-side extensions | `NeoCircuit`, `SharedBusR1csPreprocessing<C>`, `SharedBusR1csProver<L, C>` | Typed route from R1CS/witness layout into session proving |
| witness column allocation | implementation support | `WitnessLayout`, `WitnessLayoutAllocator`, `Lane<N>`, `LookupPort<N>`, `TwistPort<N>`, `TwistPortWithInc<N>` | One owner for witness-layout DSL |
| shared Twist/lookup resources | shared CPU-bus resource declaration plus dedicated instruction-lookup owner | `SharedBusResources`, `TwistResource<'a>`, `LookupResource<'a>` | Session-owned generic resource declaration; maintained hot opcode lookup ownership may be discharged by `InstructionLookup` rather than generic `LookupResource` |
| R1CS -> CCS circuit builder | implementation support | `R1csRow<F>`, `CcsBuilder<F>` | Ergonomic circuit-construction helper |

## Direct Paper Anchors

This module is not a direct paper-theorem owner. It orchestrates lower theorem-owning layers.

## Context Anchors

- `crates/deprecated-neo-fold/specs/Architecture.spec.md`
- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
- `docs/architecture/how-superneo-works.md`
- `crates/deprecated-neo-fold/src/session/README.md`
- `docs/twist-and-shout-paper/2_overview_of_twist_and_shout_and_their_costs.md`
- `docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md`

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `specs/ProtocolTheorem.spec.md` | `SuperNeo/ProtocolTheorem.lean` | Final paper theorem the session must refine |
| `specs/ProtocolRelations.spec.md` | `SuperNeo/ProtocolRelations.lean` | Paper CCS/CE relations the session must feed correctly |
| `specs/RustRefinement/NeoFoldSessionValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldSessionValidation.lean` | Defines the executable session checks for session shape, adjacent-step linking, resumed-segment carry/digest carry, and output binding via `neoFoldSessionChecks` |
| `specs/RustRefinement/NeoFoldRefinement.spec.md` | `SuperNeo/RustRefinement/NeoFoldRefinement.lean` | Exposes `paperSessionGlueAccepts`, `paperSessionGlueChecks`, `paperSessionGlueChecks_implies_paperSessionGlueAccepts`, `implSessionChecks_refines_paperSessionGlueAccepts`, `validGeneratedNeoFoldSessionCases_paperSessionGlueChecks`, and `generatedNeoFoldSessionRefinementChecks` |

## Contract Surface

### Top-level session API

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `OutputClaim<Ff>` | struct | Core | Names one session-level output expectation |
| `ProveInput<'a>` | struct | Core | Direct CCS-only step input |
| `StepSpec` | struct | Core | Public step metadata, including linking pairs |
| `StepArtifacts` | struct | Core | Per-step optional artifacts retained by the session |
| `NeoStep` | trait | Core | User-defined step producer interface |
| `Accumulator` | struct | Core | Carried session accumulator |
| `me_from_z_balanced` | fn | Helper | Balanced `ME` synthesis from witness |
| `me_from_z_balanced_select` | fn | Helper | Balanced `ME` synthesis with selection mask |
| `FoldingSession<L>` | struct | Core | Main session coordinator |

### `FoldingSession<L>` public methods

| Rust symbol | Role | Contract |
|---|---|---|
| `new(mode, params, l)` | Constructor | Creates an empty session with explicit mode, params, and committer |
| `params()` | Inspector | Returns session parameters |
| `initial_accumulator()` | Inspector | Returns initial accumulator if present |
| `committer()` | Inspector | Returns commitment operator |
| `set_shared_bus_resources(resources)` | Config | Installs shared Twist/generic-lookup resource declarations |
| `shared_bus_resources_mut()` | Config | Mutable access to resource declarations |
| `set_step_linking(cfg)` | Config | Installs explicit linking policy |
| `enable_step_linking_from_step_spec(spec)` | Config | Derives linking policy from a step spec |
| `set_initial_state(y0)` | Config | Sets initial public state |
| `with_initial_accumulator(acc, s)` | Config | Seeds the session with an already-validated accumulator |
| `mcss_public()` | Inspector | Returns carried/public CCS claims |
| `steps_public()` | Inspector | Returns public step bundles |
| `steps_witness()` / `steps_witness_mut()` | Inspector | Access stored step witnesses |
| `shared_bus_aux()` | Inspector | Returns shared-bus witness auxiliary state if present |
| `add_step(stepper, inputs)` | Core | Add one step through the `NeoStep` trait |
| `add_step_from_io(input)` | Core | Add one direct CCS-only step |
| `add_step_io(ccs, public_input, witness)` | Core | Minimal direct IO helper |
| `add_steps(stepper, inputs)` | Core | Batch-add steps through the `NeoStep` trait |
| `add_step_bundle(bundle)` / `add_step_bundles(bundles)` | Core | Add already-built step bundles |
| `execute_shard_shared_cpu_bus(...)` | Core | Build and add a shared CPU-bus step |
| `execute_shard_shared_cpu_bus_from_trace(...)` | Core | Build and add a step from trace rows |
| `execute_shard_shared_cpu_bus_from_trace_with_mem_remaps(...)` | Core | Trace helper with remapped memory layout |
| `execute_shard_shared_cpu_bus_configured(...)` | Core | Shared-bus execution with explicit configuration |
| `new_ajtai(mode, ccs)` | Convenience | Builds an Ajtai-backed session with default parameters |
| `new_ajtai_seeded(mode, ccs, seed)` | Convenience | Seeded Ajtai-backed session |
| `ivc_step_linking_pairs()` | Inspector | Returns linking edges implied by accumulated steps |
| `Accumulator::check(params, s)` | Validator | Validates accumulator shape against params and CCS |

### Shared-bus circuit frontend

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `NeoCircuit` | trait | Core | Declares resources, layout, and CPU constraints |
| `SharedBusR1csPreprocessing<C>` | struct | Core | Preprocessed shared-bus circuit state |
| `SharedBusR1csProver<L, C>` | struct | Core | Prover facade over preprocessed shared-bus circuit |
| `preprocess_shared_bus_r1cs(Arc<C>)` | fn | Core | Builds the base CCS and witness-width preprocessing |
| `SharedBusR1csPreprocessing::m()` | fn | Inspector | Returns witness width |
| `SharedBusR1csPreprocessing::into_prover(params, committer)` | fn | Core | Turns preprocessing into a prover artifact |
| `SharedBusR1csProver::ccs()` | fn | Inspector | Returns the shared-bus CCS |
| `SharedBusR1csProver::execute_into_session(...)` | fn | Core | Adds a configured shared-bus step into a session |

### Witness layout DSL

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `Scalar` | type | Core | Witness-column scalar index |
| `Public<T>` | struct | Core | Marks public witness layout positions |
| `WitnessLayoutField` | trait | Core | Field-level layout behavior |
| `WitnessLayout` | trait | Core | Full witness-layout DSL contract |
| `WitnessLayoutPublic` | trait | Core | Public-field extension |
| `WitnessLayoutAllocator` | struct | Core | Owner of witness column allocation |
| `Lane<N>` | struct | Core | CPU lane column allocation |
| `LookupPort<N>` | struct | Core | Generic lookup CPU-port binding; not by itself the maintained opcode proving owner |
| `TwistPort<N>` | struct | Core | Twist memory CPU-port binding |
| `TwistPortWithInc<N>` | struct | Core | Twist binding plus increment column |

Representative public DSL helpers:

| Rust symbol | Role | Contract |
|---|---|---|
| `WitnessLayoutAllocator::new` | Constructor | Starts witness column allocation |
| `WitnessLayoutAllocator::m_in` | Inspector | Returns current public-input width |
| `WitnessLayoutAllocator::used_cols` | Inspector | Returns consumed columns |
| `WitnessLayoutAllocator::scalar` / `public_scalar` | Builder | Allocate one scalar/public scalar |
| `WitnessLayoutAllocator::lane` / `public_lane` | Builder | Allocate one CPU lane/public lane |
| `WitnessLayoutAllocator::lookup_port` | Builder | Allocate one generic lookup port |
| `WitnessLayoutAllocator::twist_port` / `twist_port_with_inc` | Builder | Allocate one twist port |
| `Lane::new`, `base`, `at`, `iter`, `set`, `set_from_iter` | Core | CPU lane field access and filling |
| `LookupPort::cpu_binding`, `fill_from_trace` | Core | Generic lookup port CPU binding and fill semantics |
| `TwistPort::cpu_binding`, `fill_lanes_from_trace` | Core | Twist-port CPU binding and fill semantics |
| `TwistPortWithInc::cpu_binding`, `fill_lanes_from_trace` | Core | Twist+increment binding and fill semantics |

### Shared-bus resources and circuit builder

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `SharedBusResources` | struct | Core | One owner for generic Twist/lookup resource declarations at the session boundary |
| `TwistResource<'a>` | struct | Core | Builder for one Twist resource |
| `LookupResource<'a>` | struct | Core | Builder for one generic lookup resource |
| `R1csRow<F>` | struct | Core | One R1CS row specification |
| `CcsBuilder<F>` | struct | Core | Ergonomic R1CS -> CCS builder |

Representative public helpers:

| Rust symbol | Role | Contract |
|---|---|---|
| `SharedBusResources::new` | Constructor | Creates an empty resource set |
| `SharedBusResources::twist` / `shout` | Builder | Declares one Twist or generic lookup resource |
| `SharedBusResources::set_binary_lookup_table` / `set_padded_binary_lookup_table` | Config | Installs generic binary lookup tables; this does not by itself define the maintained hot opcode lookup path |
| `SharedBusResources::set_binary_mem_layout` | Config | Sets binary memory layout |
| `TwistResource::layout`, `init`, `init_cell`, `clear_init` | Config | Twist initialization semantics |
| `LookupResource::lanes`, `table`, `binary_table`, `padded_binary_table`, `spec` | Config | Generic lookup resource semantics |
| `CcsBuilder::new`, `m_in`, `const_one_col`, `rows_len` | Inspector/constructor | Builder setup |
| `CcsBuilder::r1cs_terms`, `r1cs_cols`, `eq`, `lane_continuity`, `build_rect` | Core | R1CS -> CCS construction primitives |

## Invariant Obligations

| ID | Invariant | Lean anchor | Why it matters |
|---|---|---|---|
| `S-1` | Session shape: `publicStepCount = steps.len ∧ foldCount = publicStepCount ∧ proofSteps.len ≥ 1` | `NeoFoldSessionValidation` item `1`; executable predicate `neoFoldSessionChecks`; executable lift `paperSessionGlueChecks` | Prevents malformed sessions from entering the refinement path |
| `S-2` | Step linking: for every adjacent pair `(prev, next)` and every exported linking pair `(prevIdx, nextIdx)`, `prev.x[prevIdx] = next.x[nextIdx]` | `NeoFoldSessionValidation` item `2`; `paperSessionGlueAccepts`; `paperSessionGlueChecks` | Makes multi-step verification strengthen acceptance instead of silently redefining it |
| `S-3` | Segment carry: proof-step counts are positive and sum to `proofStepCount`; the first segment starts from an empty accumulator; every later segment satisfies `segment[i].accInitSize = segment[i-1].accFinalSize ∧ segment[i].mainAccDigest = segment[i-1].finalMainAccDigest` | `NeoFoldSessionValidation` item `3`; `paperSessionGlueAccepts`; `paperSessionGlueChecks` | Prevents resumed-session drift even when shape looks valid |
| `S-4` | Output binding: if enabled, the proof exports an output-binding proof, the final target state has size `2 ^ numBits`, and every claimed `(addr, value)` is in range and matches the exported final target state | `NeoFoldSessionValidation` item `4`; `paperSessionGlueAccepts`; `paperSessionGlueChecks` | Keeps output binding as a strengthening condition tied to the real terminal state |
| `S-5` | Whole-session refinement: implementation session acceptance implies the projected paper-core session-glue predicate | `implSessionChecks_refines_paperSessionGlueAccepts` | This is the session-level conservative-extension theorem |
| `S-6` | Executable Boolean session checks lift back into the mathematical session-glue proposition | `paperSessionGlueChecks_implies_paperSessionGlueAccepts` | Lets the slow lane report theorem-backed pass/fail results instead of opaque booleans |
| `S-7` | Valid generated session corpus satisfies the theorem-backed paper-core session-glue predicate | `validGeneratedNeoFoldSessionCases_paperSessionGlueChecks` | Gives the slow lane a concrete valid-corpus acceptance target |
| `S-8` | Combined corpus expectation: valid generated sessions satisfy the paper-core session-glue predicate and tampered sessions are rejected by the implementation validator | `generatedNeoFoldSessionRefinementChecks` | This is the executable end condition for session refinement in CI |
| `S-9` | Shared-bus circuit path produces the same kind of shard/session inputs as direct IO | Session frontend + shard specs; checked indirectly by session refinement corpus | Keeps the ergonomic frontend semantically honest |
| `S-10` | Witness layout and resource declarations are the single source of truth for column ownership and sidecar wiring | Session frontend contract | Prevents layout/trace drift |
| `S-11` | `CcsBuilder` encodes user constraints without hidden rewrites that change circuit meaning | Session frontend contract | Prevents ergonomic-builder drift |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Shard prove/verify APIs are correct and refine the paper-core folding obligations | `neo-fold::shard` + Lean Rust refinement | Session is an orchestrator over shard semantics |
| Witness layouts and resources are declared consistently by user circuits | `NeoCircuit` implementor | Session cannot recover from incoherent user layout/resource declarations |
| Shared-bus preprocess and prover artifacts preserve the declared circuit semantics | `session/circuit.rs` | Required for Route-A sidecar correctness |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-fold::shard`
- `neo-fold::output_binding`
- `neo-ccs`
- `neo-ajtai`
- `neo-memory`

Primary consumers:
- `rv64_trace_shard`
- end-to-end session/integration tests
- Rust artifact/session exporters

## Lean Oracle and Refinement Conformance

| Surface | Expected result |
|---|---|
| exported valid sessions | accepted by `NeoFoldSessionValidation` |
| exported tampered sessions | rejected by `NeoFoldSessionValidation` |
| exported valid sessions after sidecar erasure | satisfy `paperSessionGlueAccepts` via `implSessionChecks_refines_paperSessionGlueAccepts` |
| `paperSessionGlueChecks` | executable Boolean view of the paper-core session-glue predicate |
| `validGeneratedNeoFoldSessionCases_paperSessionGlueChecks` | `true` for the valid exported corpus |
| `generatedNeoFoldSessionRefinementChecks` | `true` for the combined valid/tampered corpus |

## Quality Expectations

- `session.rs` should remain a real facade rather than a second proving hub.
- Shared-bus/layout/resource policy should have one obvious owner per invariant family.
- The session API should stay small relative to the proving mechanism it orchestrates.
- Compatibility helpers must not dictate architecture.
- Public session submodules are part of the contract and must stay explicitly specified rather than treated as implementation detail.

## Acceptance Criteria

1. Session prove/verify flows work for CCS-only, shared-bus, Route-A, and resumed-session families.
2. Real exported sessions satisfy `S-1` through `S-4` in the executable Lean session validator.
3. Real exported sessions satisfy the theorem-backed refinement target `implSessionChecks_refines_paperSessionGlueAccepts`.
4. Session code does not silently duplicate shard-level policy that already has a lower owner.

## Out of Scope

- Shard proving details
- Route-A claim-construction details
- Trace frontend policy beyond the APIs that call into session
