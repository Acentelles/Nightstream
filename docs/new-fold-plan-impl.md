# neo-fold-next Implementation Plan

> Archived implementation plan for a superseded scaffold. References in this
> document to `families/`, `stages/`, `bridge/`, and `pipeline/` are
> historical and do not describe the active owner map in
> `crates/neo-fold-next/src`. The current Rust owner map lives in
> `crates/neo-fold-next/specs/neo-fold-next-rust-structure-plan.md`.

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the `neo-fold-next` crate as a clean-break replacement for `neo-fold`, implementing the 13-phase proving pipeline with pluggable VM frontends.

**Architecture:** A 13-phase sequential proving pipeline (Phase 0: Ajtai commitment, Phases 1-7: batched sumcheck stages, Phase 8: CE bridge export, Phases 9-11: neo-reductions directly, Phase 12: finalization). Stages implement a common `SumcheckStage` trait. VM flexibility via three layers: VmSpec (developer API for banks + opcode classes) -> Family Compiler (lowers to Twist/Shout instances) -> Fixed Stage Kernel. See `docs/plans/2026-03-17-neo-fold-next-architecture-design.md` for the full design.

**Tech Stack:** Rust, neo-math (Fq/K/Rq field types), neo-transcript (Poseidon2), neo-ajtai (Ajtai commitment), neo-ccs (CCS matrices), neo-reductions (Pi_CCS/RLC/DEC), dory-pcs (polynomial commitment)

**Reference files:**
- Design doc: `docs/plans/2026-03-17-neo-fold-next-architecture-design.md`
- Existing prover: `external/jolt/jolt-core/src/zkvm/prover.rs`
- Existing verifier: `external/jolt/jolt-core/src/zkvm/verifier.rs`
- Existing stage specs: `crates/deprecated-neo-fold/specs/JoltStage1.spec.md` through `JoltStage7.spec.md`
- Bridge specs: `crates/deprecated-neo-fold/specs/ZkVmCeBridge.spec.md`, `ZkVmBridge.CurrentStep.spec.md`, `ZkVmBridge.Frontier.spec.md`
- Reduction spec: `crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai.spec.md`

---

## Task 1: Crate Scaffold

**Files:**
- Create: `crates/neo-fold-next/Cargo.toml`
- Create: `crates/neo-fold-next/src/lib.rs`
- Modify: `Cargo.toml` (workspace members)

**Step 1: Create crate directory structure**

```bash
mkdir -p crates/neo-fold-next/src/{types,vm,families,vms,stages/subinstances,bridge,pipeline,phase0,finalize}
```

**Step 2: Create Cargo.toml**

Create `crates/neo-fold-next/Cargo.toml` with dependencies on:
- `neo-math`, `neo-transcript`, `neo-ajtai`, `neo-ccs`, `neo-reductions`, `neo-params`
- `serde` (for Serialize/Deserialize on proof types)
- `thiserror` (for error types)

Reference `crates/deprecated-neo-fold/Cargo.toml` for workspace dependency patterns. Use `path = "../neo-math"` style deps. Include feature flags: `default = ["host"]`, `host`, `prover`, `zk`.

**Step 3: Create lib.rs with module declarations**

```rust
pub mod types;
pub mod vm;
pub mod families;
pub mod vms;
pub mod stages;
pub mod bridge;
pub mod pipeline;
pub mod phase0;
pub mod finalize;
```

**Step 4: Create empty mod.rs for each module**

Touch `mod.rs` in each subdirectory with placeholder comments describing the module's role from the architecture design.

**Step 5: Add to workspace**

Add `"crates/neo-fold-next"` to the `[workspace].members` array in the root `Cargo.toml`.

**Step 6: Verify it compiles**

Run: `cargo check -p neo-fold-next`
Expected: PASS (empty crate compiles)

**Step 7: Commit**

```bash
git add crates/neo-fold-next/ Cargo.toml
git commit -m "feat: scaffold neo-fold-next crate with module skeleton"
```

---

## Task 2: Core Types

**Files:**
- Create: `crates/neo-fold-next/src/types/mod.rs`
- Create: `crates/neo-fold-next/src/types/claims.rs`
- Create: `crates/neo-fold-next/src/types/challenges.rs`
- Create: `crates/neo-fold-next/src/types/accumulator.rs`
- Create: `crates/neo-fold-next/src/types/proof.rs`
- Create: `crates/neo-fold-next/src/types/config.rs`
- Test: `crates/neo-fold-next/tests/types_test.rs`

**Step 1: Write tests for StageChallenge type safety**

```rust
// tests/types_test.rs
#[test]
fn stage_challenge_type_safety() {
    // StageChallenge<1> should not be passable where StageChallenge<2> is expected.
    // This is a compile-time check, so the test just verifies construction/conversion.
    let initial = StageChallenge::initial();
    let stage1: StageChallenge<1> = StageChallenge::from_challenges(vec![/* ... */]);
    // stage1 cannot be used as StageChallenge<2> (compile error if attempted)
}
```

**Step 2: Implement challenges.rs**

Define `StageChallenge<const N: usize>` with phantom const generic for type-safe stage indexing. Include:
- `StageChallenge::initial() -> StageChallenge<0>`
- `StageChallenge::from_challenges(Vec<F::Challenge>) -> StageChallenge<N>`
- `StageChallenge::as_frontier(&self) -> FrontierPoint` (for Stage 7 -> Bridge)
- `FrontierPoint` struct wrapping `(Vec<F::Challenge>, Vec<F::Challenge>)` for `(r_address, r_cycle)`

Reference `neo-math` for field types: use `neo_math::Fq` as `F`.

**Step 3: Implement claims.rs**

Define:
- `OpeningClaim { poly_id: PolynomialId, point: Vec<F>, value: F }`
- `PolynomialId` enum matching `CommittedPolynomial` from current neo-fold (RdInc, RamInc, InstructionRa(usize), BytecodeRa(usize), RamRa(usize), TrustedAdvice, UntrustedAdvice)
- `MEClaim` (for bridge output, wrapping neo-reductions types)
- `SumcheckClaim { input: F, degree: usize, num_rounds: usize }`

**Step 4: Implement accumulator.rs**

Define `OpeningAccumulator` as a value type (not Arc/Mutex):
- `new() -> Self`
- `append(&mut self, claim: OpeningClaim)`
- `append_batch(&mut self, claims: Vec<OpeningClaim>)`
- `into_claims(self) -> Vec<OpeningClaim>` (consuming, for bridge)
- `len(&self) -> usize`

Define `VerifierAccumulator` with matching interface for verification side.

Reference current accumulator: `external/jolt/jolt-core/src/poly/opening_proof.rs`

**Step 5: Implement config.rs**

Define:
- `OneHotParams { log_k: usize, log_k_chunk: usize }`
- `ReadWriteConfig` (matching current `crates/deprecated-neo-fold/src/zkvm/config.rs`)
- `EmissionPolicy` enum: `EveryStep`, `Checkpoint(usize)`, `FinalOnly`

**Step 6: Implement proof.rs**

Define `NeoFoldProof` as a serializable container for all phase outputs. Initially a placeholder struct that will be filled in as stages are implemented.

**Step 7: Wire up types/mod.rs**

Re-export all public types from submodules.

**Step 8: Run tests**

Run: `cargo test -p neo-fold-next`
Expected: PASS

**Step 9: Commit**

```bash
git add crates/neo-fold-next/
git commit -m "feat: implement core types (challenges, claims, accumulator, config, proof)"
```

---

## Task 3: VM Spec + Family Compiler

**Files:**
- Create: `crates/neo-fold-next/src/vm/mod.rs`
- Create: `crates/neo-fold-next/src/vm/banks.rs`
- Create: `crates/neo-fold-next/src/vm/opcode_classes.rs`
- Create: `crates/neo-fold-next/src/vm/state.rs`
- Create: `crates/neo-fold-next/src/vm/decode.rs`
- Create: `crates/neo-fold-next/src/families/mod.rs`
- Create: `crates/neo-fold-next/src/families/compiler.rs`
- Create: `crates/neo-fold-next/src/families/shout.rs`
- Create: `crates/neo-fold-next/src/families/twist.rs`
- Create: `crates/neo-fold-next/src/families/support.rs`
- Create: `crates/neo-fold-next/src/families/lookup_table.rs`
- Test: `crates/neo-fold-next/tests/vm_spec_test.rs`
- Test: `crates/neo-fold-next/tests/compiler_test.rs`

**Step 1: Write tests for bank-to-instance derivation**

```rust
// tests/compiler_test.rs
#[test]
fn rw_bank_generates_twist_family() {
    let bank = BankSpec::new("registers", BankKind::ReadWriteMemory(TwistFamilySpec {
        addr_bits: 5, value_bits: 64,
        init: InitRule::ZeroInit,
        one_hot: OneHotSpec::default(),
        rw_model: RwModel::ReadWrite,
    }));
    let lowered = families::compiler::lower_bank(&bank);
    assert!(matches!(lowered, LoweredFamily::Twist(_)));
}

#[test]
fn ro_bank_generates_shout_family() {
    let bank = BankSpec::new("program_rom", BankKind::ReadOnlyLookup(ShoutFamilySpec {
        addr_bits: 32,
        table_shape: TableShape::Decomposable { log_k: 128, chunk: 8 },
        decode: DecodeObligations::default(),
        one_hot: OneHotSpec::default(),
        auth: TableAuthSpec::Bytecode,
    }));
    let lowered = families::compiler::lower_bank(&bank);
    assert!(matches!(lowered, LoweredFamily::Shout(_)));
}

#[test]
fn opcode_classes_share_columns() {
    // 7 opcodes in one class => 1 column set, not 7
    let class = OpcodeClassSpec {
        class_id: OpcodeClassId::new("math"),
        opcodes: vec![0, 1, 2, 3, 4, 5, 6],
        family: FamilyId::named("rom"),
        query_shape: QueryShape::TwoOperand { left: 8, right: 8 },
        max_sublookups: 4,
        effect_shape: EffectShape::WriteRd,
    };
    let plan = families::compiler::lower_class(&class, &DecompositionConfig { log_k: 16, chunk: 4 });
    // 1 column set with d = 16/4 = 4 RA columns
    assert_eq!(plan.ra_column_count(), 4);
}
```

**Step 2: Implement vm/banks.rs**

```rust
pub struct BankSpec { pub id: BankId, pub name: String, pub kind: BankKind }

pub enum BankKind {
    ReadOnlyLookup(ShoutFamilySpec),
    ReadWriteMemory(TwistFamilySpec),
    PureState(StateFieldSpec),
}

pub struct ShoutFamilySpec {
    pub addr_bits: usize, pub table_shape: TableShape,
    pub decode: DecodeObligations, pub one_hot: OneHotSpec, pub auth: TableAuthSpec,
}

pub struct TwistFamilySpec {
    pub addr_bits: usize, pub value_bits: usize,
    pub init: InitRule, pub one_hot: OneHotSpec, pub rw_model: RwModel,
}

pub enum RwModel { ReadOnly, ReadWrite, WriteOnce, AppendOnly }
pub enum InitRule { ZeroInit, PreloadedFrom(BankId), Custom(Vec<u8>) }
```

**Step 3: Implement vm/opcode_classes.rs**

```rust
pub struct OpcodeClassSpec<OpcodeId> {
    pub class_id: OpcodeClassId,
    pub opcodes: Vec<OpcodeId>,
    pub family: FamilyId,
    pub query_shape: QueryShape,
    pub max_sublookups: usize,
    pub effect_shape: EffectShape,
}

pub enum QueryShape {
    TwoOperand { left: usize, right: usize },
    BaseOffset { base: usize, offset: usize },
    SingleOperand { width: usize },
}

pub enum EffectShape { WriteRd, BranchPc, LoadStore, NoEffect }
```

**Step 4: Implement vm/state.rs and vm/decode.rs**

State spec for pure state fields (PC, flags, mode bits). Decode spec for instruction-to-selector mapping.

**Step 5: Implement vm/mod.rs with VmSpec trait**

```rust
pub trait VmSpec {
    type OpcodeId: Copy + Eq + Hash;
    fn state_spec(&self) -> StateSpec;
    fn banks(&self) -> Vec<BankSpec>;
    fn opcode_classes(&self) -> Vec<OpcodeClassSpec<Self::OpcodeId>>;
    fn decode_spec(&self) -> DecodeSpec<Self::OpcodeId>;
    fn core_ccs_spec(&self) -> CoreCcsSpec;
}
```

**Step 6: Implement families/twist.rs and families/shout.rs**

Lowered family types consumed by stages:

```rust
pub struct LoweredTwistFamily { pub bank_id: BankId, pub addr_bits: usize, pub value_bits: usize, ... }
pub struct LoweredShoutFamily { pub bank_id: BankId, pub addr_bits: usize, pub table_shape: TableShape, ... }
pub struct LoweredSupportFamily { pub kind: SupportKind, pub source_bank: BankId }
pub enum SupportKind { Booleanity, HammingWeight, Range, Decode, AddressReduction }
```

**Step 7: Implement families/compiler.rs**

The family compiler lowers VmSpec into LoweredVmPlan:

```rust
pub fn lower<V: VmSpec>(vm: &V) -> LoweredVmPlan {
    let mut shout = vec![];
    let mut twist = vec![];
    let mut support = vec![];
    for bank in vm.banks() {
        match bank.kind {
            BankKind::ReadOnlyLookup(spec) => { shout.push(lower_shout(bank.id, spec)); }
            BankKind::ReadWriteMemory(spec) => {
                twist.push(lower_twist(bank.id, spec));
                support.extend(derive_support(bank.id, &spec));
            }
            BankKind::PureState(_) => { /* Stage 1 kernel slot only */ }
        }
    }
    LoweredVmPlan {
        stage1: CoreKernelPlan::from(vm.core_ccs_spec(), vm.state_spec()),
        stages2_7: FamilyPlan { shout_families: shout, twist_families: twist, support_families: support },
        bridge: BridgeShape::from(&shout, &twist),
    }
}
```

**Step 8: Implement families/lookup_table.rs**

LookupTable trait + standard tables (RangeCheck, Equal, BitwiseAnd, etc.). Port from `crates/deprecated-neo-fold/src/zkvm/lookup_table/`.

**Step 9: Run tests**

Run: `cargo test -p neo-fold-next`
Expected: PASS

**Step 10: Commit**

```bash
git add crates/neo-fold-next/
git commit -m "feat: implement VmSpec trait + family compiler (banks, opcode classes, lowering)"
```

---

## Task 4: SumcheckStage Trait + Stage Skeleton + Stage Planner

**Files:**
- Create: `crates/neo-fold-next/src/stages/mod.rs`
- Create: `crates/neo-fold-next/src/stages/planner.rs`
- Create: `crates/neo-fold-next/src/stages/stage1.rs` through `stage7.rs`
- Test: `crates/neo-fold-next/tests/stage_trait_test.rs`
- Test: `crates/neo-fold-next/tests/planner_test.rs`

**Step 1: Write test for SumcheckStage trait contract**

```rust
// A mock stage that implements SumcheckStage to verify the trait works
struct MockStage { subinstances: usize }
impl SumcheckStage for MockStage {
    type Proof = Vec<u8>;
    fn subinstance_count(&self) -> usize { self.subinstances }
    fn uses_uni_skip(&self) -> bool { false }
    fn prove(self, prev: &StageChallenge, transcript: &mut Transcript, acc: OpeningAccumulator)
        -> (Self::Proof, StageChallenge, OpeningAccumulator) {
        // Mock: pass through accumulator, return empty proof
        (vec![], StageChallenge::from_challenges(vec![]), acc)
    }
    fn verify(proof: &Self::Proof, prev: &StageChallenge, transcript: &mut Transcript, acc: VerifierAccumulator)
        -> Result<(StageChallenge, VerifierAccumulator), VerifyError> {
        Ok((StageChallenge::from_challenges(vec![]), acc))
    }
}

#[test]
fn mock_stage_pipeline() {
    let acc = OpeningAccumulator::new();
    let challenge = StageChallenge::initial();
    let mut transcript = Transcript::new();
    let stage = MockStage { subinstances: 3 };
    let (proof, next_challenge, acc) = stage.prove(&challenge, &mut transcript, acc);
    assert!(proof.is_empty());
}
```

**Step 2: Implement stages/mod.rs with SumcheckStage trait**

```rust
pub trait SumcheckStage {
    type Proof: Serialize + DeserializeOwned;
    fn subinstance_count(&self) -> usize;
    fn uses_uni_skip(&self) -> bool;
    fn prove(
        self,
        prev_challenges: &StageChallenge,
        transcript: &mut Transcript,
        accumulator: OpeningAccumulator,
    ) -> (Self::Proof, StageChallenge, OpeningAccumulator);
    fn verify(
        proof: &Self::Proof,
        prev_challenges: &StageChallenge,
        transcript: &mut Transcript,
        accumulator: VerifierAccumulator,
    ) -> Result<(StageChallenge, VerifierAccumulator), VerifyError>;
}
```

Also define `AdviceCarry` here for Stage 6 -> 7 handoff.

**Step 3: Implement stages/planner.rs**

The stage planner takes a LoweredVmPlan and computes the instance count per stage:

```rust
pub struct StagePlan {
    pub stage1: Stage1Plan,  // Always 1 kernel instance
    pub stage2: Stage2Plan,  // 1 ProductVirtual + N_rw + N_ro + N_rw + N_rw
    pub stage3: Stage3Plan,  // 1 Shift + N_ro + N_rw
    pub stage4: Stage4Plan,  // N_rw + N_rw
    pub stage5: Stage5Plan,  // N_ro + N_rw + N_rw
    pub stage6: Stage6Plan,  // N_ro + N_support + N_rw + N_ro + N_rw + optional
    pub stage7: Stage7Plan,  // N_support + optional
}

pub fn plan_stages(family_plan: &FamilyPlan) -> StagePlan {
    let n_rw = family_plan.twist_families.len();
    let n_ro = family_plan.shout_families.len();
    // ... derive instance counts per stage slot
}
```

**Step 4: Create stage1.rs through stage7.rs skeletons**

Each file defines a `StageN` struct with a `from_plan()` constructor taking the stage-specific plan plus witnesses/ctx reference, and stub `SumcheckStage` impl. Mark prove/verify bodies as `todo!()`. Instance counts come from the plan, not from constants:

| File | Struct | Mandatory kernel slots | Per-bank slots | Uni-skip |
|------|--------|----------------------|----------------|----------|
| stage1.rs | Stage1 | 1 (Spartan) | — | true |
| stage2.rs | Stage2 | 1 (ProductVirtual) | N_rw RamRW + N_ro InstrLookup + N_rw RamRaf + N_rw Output | true |
| stage3.rs | Stage3 | 1 (Shift) | N_ro InstrInput + N_rw RegistersClaim | false |
| stage4.rs | Stage4 | — | N_rw RegistersRW + N_rw RamVal | false |
| stage5.rs | Stage5 | — | N_ro InstrRaf + N_rw RamRa + N_rw RegistersVal | false |
| stage6.rs | Stage6 | — | N_ro BytecodeRaf + N_support Booleanity + N_rw RamRaVirt + N_ro InstrRaVirt + N_rw Inc + opt Advice | false |
| stage7.rs | Stage7 | — | N_support Hamming + opt Advice | false |

**Step 5: Run tests**

Run: `cargo test -p neo-fold-next`
Expected: PASS (mock test only; stage stubs have todo!() but aren't called)

**Step 5: Commit**

```bash
git add crates/neo-fold-next/
git commit -m "feat: define SumcheckStage trait and stage 1-7 skeletons"
```

---

## Task 5: Subinstance Implementations

**Files:**
- Create: all files in `crates/neo-fold-next/src/stages/subinstances/`
- Test: `crates/neo-fold-next/tests/subinstance_test.rs`

This is the largest task. Each subinstance needs a prover struct, a verifier struct, and parameter types. Port from `external/jolt/jolt-core/src/zkvm/` and `crates/deprecated-neo-fold/src/zkvm/`.

**Step 1: Define SubinstanceProver/Verifier traits**

```rust
// stages/subinstances/mod.rs
pub trait SubinstanceProver<F: Field> {
    type Params;
    fn new(params: Self::Params) -> Self;
    fn input_claim(&self, acc: &OpeningAccumulator) -> F;
    fn degree(&self) -> usize;
    fn num_rounds(&self) -> usize;
    fn compute_round_poly(&mut self, round: usize, prev_claim: F) -> UniPoly<F>;
    fn ingest_challenge(&mut self, challenge: F, round: usize);
    fn cache_openings(&self, acc: &mut OpeningAccumulator, challenges: &[F]);
}

pub trait SubinstanceVerifier<F: Field> {
    type Params;
    fn new(params: Self::Params) -> Self;
    fn input_claim(&self, acc: &VerifierAccumulator) -> F;
    fn expected_output_claim(&self, acc: &VerifierAccumulator, challenges: &[F]) -> F;
    fn cache_openings(&self, acc: &mut VerifierAccumulator, challenges: &[F]);
}
```

Reference: `external/jolt/jolt-core/src/subprotocols/sumcheck_prover.rs` for the existing trait pattern.

**Step 2: Implement subinstances one at a time**

For each subinstance, follow this order (dependency-driven):

1. `product_virtual.rs` — ProductVirtualRemainder (needed by Stage 2, simplest Spartan helper)
2. `shift.rs` — SpartanShift (needed by Stage 3, simple shift constraint)
3. `ram_rw.rs` — RamReadWriteChecking (needed by Stage 2, core Twist)
4. `ram_raf.rs` — RamRafEvaluation (needed by Stage 2)
5. `output.rs` — OutputSumcheck (needed by Stage 2)
6. `instruction_lookups.rs` — InstructionLookupsClaimReduction (needed by Stage 2, core Shout)
7. `instruction_input.rs` — InstructionInputVirtualization (needed by Stage 3)
8. `registers.rs` — RegistersClaimReduction, RegistersReadWriteChecking, RegistersValEvaluation (needed by Stages 3, 4, 5)
9. `ram_val.rs` — RamValCheck (needed by Stage 4)
10. `instruction_raf.rs` — InstructionReadRaf (needed by Stage 5)
11. `ram_ra.rs` — RamRaClaimReduction (needed by Stage 5)
12. `bytecode_raf.rs` — BytecodeReadRaf (needed by Stage 6)
13. `booleanity.rs` — Booleanity + RamHammingBooleanity (needed by Stage 6)
14. `ra_virtual.rs` — RamRaVirtualization + InstructionRaVirtualization (needed by Stage 6)
15. `inc.rs` — IncClaimReduction (needed by Stage 6)
16. `hamming.rs` — HammingWeightClaimReduction (needed by Stage 7)
17. `advice.rs` — AdviceClaimReduction phases 1+2 (needed by Stages 6-7)

For each file:
- Port the prover from `crates/deprecated-neo-fold/src/zkvm/claim_reductions/` or the corresponding module
- Port the verifier
- Port the params struct
- Write at least one unit test (input_claim roundtrip or construction test)

**Step 3: Write per-subinstance unit tests**

Each subinstance gets a test that constructs it with known parameters and verifies `input_claim` computation. Reference existing tests in `crates/deprecated-neo-fold/tests/stage_pipeline.rs`.

**Step 4: Run all tests**

Run: `cargo test -p neo-fold-next`
Expected: PASS

**Step 5: Commit (per batch of 3-4 subinstances)**

Commit after each logical batch (e.g., "Stage 2 subinstances", "Stage 3-4 subinstances", etc.)

---

## Task 6: Stage Implementations (Stages 1-7)

**Files:**
- Modify: `crates/neo-fold-next/src/stages/stage1.rs` through `stage7.rs`
- Test: `crates/neo-fold-next/tests/stage_pipeline_test.rs`

**Step 1: Write pipeline integration test**

```rust
// tests/stage_pipeline_test.rs
#[test]
fn stage1_prove_verify_roundtrip() {
    // Construct minimal test trace (from existing test fixtures)
    let witnesses = test_fixtures::minimal_rv64_trace();
    let ctx = test_fixtures::preprocessing_context(&witnesses);
    let acc = OpeningAccumulator::new();
    let challenge = StageChallenge::initial();
    let mut transcript = Transcript::new();

    let stage1 = Stage1::new(&witnesses, &ctx);
    assert_eq!(stage1.subinstance_count(), 1);
    assert!(stage1.uses_uni_skip());

    let (proof, next_challenge, acc) = stage1.prove(&challenge, &mut transcript, acc);

    // Verify
    let mut v_transcript = Transcript::new();
    let v_acc = VerifierAccumulator::new();
    let result = Stage1::verify(&proof, &challenge, &mut v_transcript, v_acc);
    assert!(result.is_ok());
}
```

**Step 2: Implement Stage 1 (Outer Spartan R1CS)**

Port from `crates/deprecated-neo-fold/src/zkvm/prover.rs::prove_stage1()`:
- Construct `OuterUniSkipParams` from preprocessing
- Initialize `OuterUniSkipProver`
- Run uni-skip first round
- Run remaining batched sumcheck
- Cache openings in accumulator
- Return proof + challenges

Reference spec: `crates/deprecated-neo-fold/specs/JoltStage1.spec.md`

**Step 3: Implement Stage 2 (5 batched subinstances)**

Port from `prove_stage2()`. This is the heaviest stage:
- Construct all 5 subinstance provers
- Run uni-skip on product virtual
- Run batched sumcheck across all 5
- Cache openings

Reference spec: `crates/deprecated-neo-fold/specs/JoltStage2.spec.md`

**Step 4: Implement Stages 3-5**

Port from `prove_stage3/4/5()`. Simpler stages (no uni-skip):
- Stage 3: 3 subinstances
- Stage 4: 2 subinstances (smallest)
- Stage 5: 3 subinstances

Reference specs: `JoltStage3.spec.md`, `JoltStage4.spec.md`, `JoltStage5.spec.md`

**Step 5: Implement Stage 6 (widest stage + advice phase 1)**

Port from `prove_stage6()`. Handle optional advice subinstances:
- 6 mandatory + 2 optional
- Create `AdviceCarry` and embed in proof output

Reference spec: `JoltStage6.spec.md`

**Step 6: Implement Stage 7 (terminal + advice phase 2)**

Port from `prove_stage7()`. Handle advice carry input:
- Accept `AdviceCarry` from Stage 6
- 1 mandatory + 2 optional subinstances
- Output is the frontier point (`r_stage7 = r_address || r_cycle`)

Reference spec: `JoltStage7.spec.md`

**Step 7: Write full 7-stage pipeline roundtrip test**

```rust
#[test]
fn full_7_stage_pipeline_roundtrip() {
    let witnesses = test_fixtures::minimal_rv64_trace();
    let ctx = test_fixtures::preprocessing_context(&witnesses);
    // Run all 7 stages sequentially, verify each
    // Check that final challenge is a valid frontier point
}
```

Reference existing test: `crates/deprecated-neo-fold/tests/stage_pipeline.rs`

**Step 8: Run tests**

Run: `cargo test -p neo-fold-next -- --release`
Expected: PASS (release mode for crypto operations)

**Step 9: Commit**

```bash
git commit -m "feat: implement Stages 1-7 with SumcheckStage trait"
```

---

## Task 7: Bridge (Phase 8)

**Files:**
- Create: `crates/neo-fold-next/src/bridge/mod.rs`
- Create: `crates/neo-fold-next/src/bridge/current_step.rs`
- Create: `crates/neo-fold-next/src/bridge/frontier.rs`
- Create: `crates/neo-fold-next/src/bridge/public_view.rs`
- Test: `crates/neo-fold-next/tests/bridge_test.rs`

**Step 1: Write bridge export test**

```rust
#[test]
fn bridge_export_produces_valid_bundle() {
    // Use Stage 7 output fixture
    let frontier = test_fixtures::stage7_frontier_point();
    let acc = test_fixtures::stage7_accumulator();
    let ctx = test_fixtures::ajtai_context();

    let bundle = Bridge::export(frontier, acc, &ctx);

    // BridgeBundle should have:
    assert!(!bundle.mcs_list.is_empty());
    assert!(!bundle.ce_claims.is_empty());
    assert!(bundle.public_view.frontier_point == frontier);
}
```

**Step 2: Implement current_step.rs**

Port `CurrentStepMcsBundle` from `crates/deprecated-neo-fold/src/zkvm/ce_bridge/current_step.rs`.
- 35 semantic slots (parameterized by VmFrontend::input_catalog() in the future)
- Bounded MCS witnesses with leaf norm b=2
- Reconstruction rules from spec

Reference: `ZkVmBridge.CurrentStep.spec.md`

**Step 3: Implement frontier.rs**

Port frontier CE carriers from `crates/deprecated-neo-fold/src/zkvm/ce_bridge/frontier.rs`.
- One carrier per RA family in canonical order: RdInc, RamInc, InstructionRa, BytecodeRa, RamRa, + optional advice
- Native witness semantics and bounded witness matrices

Reference: `ZkVmBridge.Frontier.spec.md`

**Step 4: Implement public_view.rs**

```rust
pub struct PublicBridgeView {
    pub frontier_point: FrontierPoint,
    pub commitment_digests: Vec<[u8; 32]>,
    pub trace_length: usize,
    pub ram_k: usize,
    pub one_hot_config: OneHotParams,
}
```

**Step 5: Implement bridge/mod.rs with BridgeExport**

```rust
pub struct Bridge;

impl Bridge {
    pub fn export(
        frontier_point: FrontierPoint,
        accumulator: OpeningAccumulator,
        commitment_context: &AjtaiContext,
    ) -> BridgeBundle {
        let current_step = CurrentStepCarrier::from_accumulator(&accumulator);
        let frontier = FrontierCarrier::from_accumulator(&accumulator, &frontier_point);
        let public_view = PublicBridgeView::new(&frontier_point, commitment_context);
        BridgeBundle { mcs_list, mcs_witnesses, ce_claims, ce_witnesses, public_view }
    }
}
```

Reference: `ZkVmCeBridge.spec.md`, `crates/deprecated-neo-fold/src/zkvm/reduction_adapter.rs`

**Step 6: Run tests**

Run: `cargo test -p neo-fold-next`
Expected: PASS

**Step 7: Commit**

```bash
git commit -m "feat: implement CE bridge export (Phase 8)"
```

---

## Task 8: Pipeline Orchestrator

**Files:**
- Create: `crates/neo-fold-next/src/pipeline/mod.rs`
- Create: `crates/neo-fold-next/src/pipeline/checkpoint.rs`
- Create: `crates/neo-fold-next/src/pipeline/emission.rs`
- Create: `crates/neo-fold-next/src/phase0/commitment.rs`
- Create: `crates/neo-fold-next/src/finalize/mod.rs`
- Create: `crates/neo-fold-next/src/finalize/opening.rs`
- Create: `crates/neo-fold-next/src/finalize/output_binding.rs`
- Test: `crates/neo-fold-next/tests/pipeline_test.rs`

**Step 1: Implement emission.rs**

```rust
pub enum EmissionPolicy { EveryStep, Checkpoint(usize), FinalOnly }
impl EmissionPolicy {
    pub fn should_emit(&self, step: usize, total_steps: usize) -> bool { ... }
}
```

**Step 2: Implement checkpoint.rs**

Define serializable checkpoint state:
```rust
pub struct PipelineCheckpoint {
    pub completed_stage: usize,  // 0-7
    pub challenge: Vec<u8>,      // serialized StageChallenge
    pub accumulator: Vec<u8>,    // serialized OpeningAccumulator
    pub transcript_state: Vec<u8>,
}
```

With `save()` and `restore()` methods using serde.

**Step 3: Implement phase0/commitment.rs**

Phase 0: shared Ajtai frontend commitment. Port from the commitment generation in the existing `generate_and_commit_frontend_witnesses_with_ajtai()` in `crates/deprecated-neo-fold/src/zkvm/prover.rs`.

**Step 4: Implement finalize/mod.rs**

Phase 12: consume neo-reductions output, batch final openings, seal transcript, bind output.

```rust
pub fn package(
    folded: FoldedAccumulator,
    transcript: &mut Transcript,
) -> NeoFoldProof {
    let opening_proof = opening::batch_open(&folded);
    let binding = output_binding::bind(&folded.public_io, transcript);
    transcript.seal();
    NeoFoldProof { /* all fields */ }
}
```

**Step 5: Implement pipeline/mod.rs**

The main orchestrator:

```rust
pub struct Pipeline {
    pub config: PipelineConfig,
    pub emission: EmissionPolicy,
}

impl Pipeline {
    pub fn prove<V: VmSpec>(self, vm: &V, witnesses: FrontendWitnesses) -> NeoFoldProof {
        // Compile VM spec into family plan
        let plan = families::compiler::lower(vm);
        let stage_plan = stages::planner::plan_stages(&plan.stages2_7);

        // Phase 0: commit (surface shape from plan)
        let (commitment, ctx) = phase0::commit(&witnesses, &plan);
        let mut transcript = Transcript::new();
        transcript.append_commitment(&commitment);

        // Phases 1-7: stages populated from plan
        let mut acc = OpeningAccumulator::new();
        let mut challenge = StageChallenge::initial();

        let (p1, challenge, acc) = Stage1::from_plan(&plan.stage1, &witnesses, &ctx)
            .prove(&challenge, &mut transcript, acc);
        let (p2, challenge, acc) = Stage2::from_plan(&stage_plan.stage2, &witnesses, &ctx)
            .prove(&challenge, &mut transcript, acc);
        // ... stages 3-7, each from stage_plan ...

        // Phase 8: bridge shaped by plan.bridge
        let bundle = Bridge::export(challenge.as_frontier(), acc, &ctx, &plan.bridge);

        // Phases 9-11: neo-reductions directly
        let folded = neo_reductions::api::pi_ccs_prove(&bundle, &mut transcript);

        // Phase 12
        finalize::package(folded, &mut transcript)
    }
}
```

**Step 6: Write full pipeline test**

```rust
#[test]
fn full_pipeline_prove_verify() {
    let rv64im = vms::rv64im::Rv64Im;
    let pipeline = Pipeline::new(PipelineConfig::default(), EmissionPolicy::FinalOnly);
    let witnesses = test_fixtures::minimal_rv64_trace();
    let proof = pipeline.prove(&rv64im, witnesses);
    assert!(proof.verify().is_ok());
}
```

**Step 8: Run tests**

Run: `cargo test -p neo-fold-next -- --release`
Expected: PASS

**Step 9: Commit**

```bash
git commit -m "feat: implement pipeline orchestrator (Phase 0, 8, 12) with checkpoint/emission"
```

---

## Task 9: RV64IM Reference VM Spec

**Files:**
- Create: `crates/neo-fold-next/src/vms/mod.rs`
- Create: `crates/neo-fold-next/src/vms/rv64im.rs`
- Test: `crates/neo-fold-next/tests/rv64im_vm_test.rs`

**Step 1: Write test for RV64IM VM spec**

```rust
#[test]
fn rv64im_vm_spec_banks() {
    let vm = Rv64Im;
    let banks = vm.banks();
    assert_eq!(banks.len(), 3); // program_rom + registers + ram
    assert!(matches!(banks[0].kind, BankKind::ReadOnlyLookup(_)));
    assert!(matches!(banks[1].kind, BankKind::ReadWriteMemory(_)));
    assert!(matches!(banks[2].kind, BankKind::ReadWriteMemory(_)));
}

#[test]
fn rv64im_vm_spec_opcode_classes() {
    let vm = Rv64Im;
    let classes = vm.opcode_classes();
    assert_eq!(classes.len(), 4); // alu, branch, memory, mul_div
    // All classes share the same family (program_rom)
    for class in &classes {
        assert_eq!(class.family, FamilyId::named("program_rom"));
    }
}

#[test]
fn rv64im_lowering_produces_valid_plan() {
    let vm = Rv64Im;
    let plan = families::compiler::lower(&vm);
    assert_eq!(plan.stages2_7.twist_families.len(), 2);  // registers + ram
    assert_eq!(plan.stages2_7.shout_families.len(), 1);  // program_rom
}
```

**Step 2: Implement rv64im.rs with VmSpec**

```rust
pub struct Rv64Im;

impl VmSpec for Rv64Im {
    type OpcodeId = RiscVOpcode;

    fn state_spec(&self) -> StateSpec {
        StateSpec::new(&[StateField::new("pc", 64)])
    }

    fn banks(&self) -> Vec<BankSpec> {
        vec![
            BankSpec::new("program_rom", BankKind::ReadOnlyLookup(ShoutFamilySpec {
                addr_bits: 32,
                table_shape: TableShape::Decomposable { log_k: 128, chunk: 8 },
                decode: DecodeObligations::standard_rv64(),
                one_hot: OneHotSpec::default(),
                auth: TableAuthSpec::Bytecode,
            })),
            BankSpec::new("registers", BankKind::ReadWriteMemory(TwistFamilySpec {
                addr_bits: 5, value_bits: 64,
                init: InitRule::ZeroInit,
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
            BankSpec::new("ram", BankKind::ReadWriteMemory(TwistFamilySpec {
                addr_bits: 32, value_bits: 64,
                init: InitRule::PreloadedFrom(BankId::named("program_rom")),
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
        ]
    }

    fn opcode_classes(&self) -> Vec<OpcodeClassSpec<RiscVOpcode>> {
        vec![
            OpcodeClassSpec { class_id: OpcodeClassId::new("alu"),
                opcodes: vec![ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA, /* ... */],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 64, right: 64 },
                max_sublookups: 16, effect_shape: EffectShape::WriteRd },
            OpcodeClassSpec { class_id: OpcodeClassId::new("branch"),
                opcodes: vec![BEQ, BNE, BLT, BGE, BLTU, BGEU],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 64, right: 64 },
                max_sublookups: 16, effect_shape: EffectShape::BranchPc },
            OpcodeClassSpec { class_id: OpcodeClassId::new("memory"),
                opcodes: vec![LB, LH, LW, LD, SB, SH, SW, SD, LBU, LHU, LWU],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::BaseOffset { base: 64, offset: 12 },
                max_sublookups: 16, effect_shape: EffectShape::LoadStore },
            OpcodeClassSpec { class_id: OpcodeClassId::new("mul_div"),
                opcodes: vec![MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU, /* ... */],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 64, right: 64 },
                max_sublookups: 16, effect_shape: EffectShape::WriteRd },
        ]
    }

    fn decode_spec(&self) -> DecodeSpec<RiscVOpcode> { DecodeSpec::standard_rv64im() }
    fn core_ccs_spec(&self) -> CoreCcsSpec { CoreCcsSpec::rv64im_standard() }
}
```

Reference: Port the 19 CCS constraints from `crates/deprecated-neo-fold/src/zkvm/r1cs/constraints.rs`,
the 35 input slots from `crates/deprecated-neo-fold/src/zkvm/r1cs/inputs.rs`, and the instruction enum
from `crates/jolt-tracer/src/instruction/mod.rs`.

**Step 3: Write end-to-end test with RV64IM**

```rust
#[test]
fn rv64im_end_to_end() {
    let rv64im = Rv64Im;
    let program = test_fixtures::fib_program();
    let witnesses = test_fixtures::trace_rv64im(&program);
    let pipeline = Pipeline::new(PipelineConfig::default(), EmissionPolicy::FinalOnly);
    let proof = pipeline.prove(&rv64im, witnesses);
    assert!(proof.verify().is_ok());
}
```

**Step 4: Run tests**

Run: `cargo test -p neo-fold-next rv64im -- --release`
Expected: PASS

**Step 5: Commit**

```bash
git commit -m "feat: implement RV64IM reference VM spec"
```

---

## Task 10: Integration Testing + Parity Check

**Files:**
- Create: `crates/neo-fold-next/tests/parity_test.rs`
- Create: `crates/neo-fold-next/tests/test_fixtures/mod.rs`

**Step 1: Create shared test fixtures**

Port minimal test trace generation from `crates/deprecated-neo-fold/tests/stage_pipeline.rs`. Ensure neo-fold-next and neo-fold can both consume the same test vectors.

**Step 2: Write parity test against neo-fold**

```rust
#[test]
fn neo_fold_next_matches_neo_fold_stage_challenges() {
    // Run the same trace through both pipelines
    // Compare r_stage1 through r_stage7 challenge vectors
    // They must match exactly (same Fiat-Shamir transcript)
    let trace = test_fixtures::minimal_rv64_trace();

    let old_challenges = neo_fold::prove_and_extract_challenges(&trace);
    let new_challenges = neo_fold_next::prove_and_extract_challenges::<Rv64ImFrontend>(&trace);

    for i in 0..7 {
        assert_eq!(old_challenges[i], new_challenges[i],
            "Stage {} challenge mismatch", i + 1);
    }
}
```

**Step 3: Write bridge parity test**

Verify that the BridgeBundle from neo-fold-next matches the output of the existing bridge code.

**Step 4: Run full test suite**

Run: `cargo test -p neo-fold-next -- --release`
Expected: ALL PASS

**Step 5: Run existing neo-fold tests to verify no regressions**

Run: `cargo test -p neo-fold -- --release`
Expected: ALL PASS (neo-fold unchanged)

**Step 6: Commit**

```bash
git commit -m "test: add parity tests between neo-fold-next and neo-fold"
```

---

## Task 11: Documentation + Spec Placement

**Files:**
- Create: `crates/neo-fold-next/specs/Architecture.spec.md` (copy from design doc, adapted)
- Create: `crates/neo-fold-next/specs/JoltStage1.spec.md` through `JoltStage7.spec.md` (copy from neo-fold/specs/)

**Step 1: Copy and adapt Architecture.spec.md**

Take the design doc (`docs/plans/2026-03-17-neo-fold-next-architecture-design.md`) and create a normative `Architecture.spec.md` in the crate's specs/ directory. Remove planning language, keep only normative statements.

**Step 2: Copy stage specs**

Copy `JoltStage1.spec.md` through `JoltStage7.spec.md` from `crates/deprecated-neo-fold/specs/`. Update any references to point to neo-fold-next module paths.

**Step 3: Copy bridge specs**

Copy `ZkVmCeBridge.spec.md`, `ZkVmBridge.CurrentStep.spec.md`, `ZkVmBridge.Frontier.spec.md`.

**Step 4: Commit**

```bash
git commit -m "docs: add normative specs to neo-fold-next"
```

---

## Dependency Order Summary

```
Task 1: Scaffold               (no deps)
Task 2: Core Types             (depends on: Task 1)
Task 3: VM Spec + Compiler     (depends on: Task 2)
Task 4: Stage Trait + Planner  (depends on: Task 2, Task 3)
Task 5: Subinstances           (depends on: Task 4)
Task 6: Stage Impls            (depends on: Task 5)
Task 7: Bridge                 (depends on: Task 2, Task 3, Task 6)
Task 8: Pipeline               (depends on: Task 3, Task 6, Task 7)
Task 9: RV64IM VM Spec         (depends on: Task 3, Task 8)
Task 10: Integration Tests     (depends on: Task 9)
Task 11: Documentation         (depends on: Task 10)
```

Tasks 3 and early Task 4 (trait definition) can be parallelized. Task 5 can begin once the stage trait is defined (doesn't depend on the full family compiler).
