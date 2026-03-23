# neo-fold-next Architecture Design

> Archived design note for a superseded Jolt-shaped scaffold. References below
> to `pipeline/`, `families/`, `stages/`, and `bridge/` are historical and do
> not describe the active owner map in `crates/neo-fold-next/src`. The current
> owner map lives under
> `crates/neo-fold-next/specs/neo-fold-next-rust-structure-plan.md`.

## Purpose

Architecture specification for `neo-fold-next`, the clean-break replacement for `neo-fold`.
Organized as a two-part document: Part I defines the protocol pipeline (phase contracts, challenge
dependencies, paper anchors). Part II defines the crate design (module layout, trait contracts,
data flow). The appendix provides the normative per-phase contract table and subinstance ownership map.

This spec replaces the attic'd `neo-fold-legacy/specs/Architecture.spec.md`, which was organized
by conceptual concern (paper-core, instruction lookup, memory sidecar) instead of reflecting the
actual sequential proving pipeline.

---

## Part I: Protocol Pipeline

### Pipeline Overview

The proving pipeline is a strict sequential chain of 13 phases (0-12):

```
Phase 0   Shared Ajtai frontend commitment
Phase 1   Stage 1 - Outer Spartan R1CS
Phase 2   Stage 2 - Memory/lookup/product checking
Phase 3   Stage 3 - Shift + instruction input + register reduction
Phase 4   Stage 4 - Register R/W + RAM value check
Phase 5   Stage 5 - Instruction RAF + RAM RA + register value eval
Phase 6   Stage 6 - Bytecode/booleanity/RA virtual + advice phase 1
Phase 7   Stage 7 - Hamming weight + advice phase 2
Phase 8   Bridge export / current-step materialization
Phase 9   Π_CCS (owned by neo-reductions)
Phase 10  Π_RLC (owned by neo-reductions)
Phase 11  Π_DEC (owned by neo-reductions)
Phase 12  Finalization / proof packaging
```

`neo-fold-next` owns Phases 0-8 and 12. Phases 9-11 are owned by `neo-reductions` and called
directly by the pipeline orchestrator.

### Invariants

- Fiat-Shamir ordering is determined by the phase sequence. No reordering, no parallelism between phases.
- Phases 1-7 are batched sumcheck stages. Each batches N subinstances into a single sumcheck.
- Phase 8 (bridge) is not a sumcheck. It is a translation layer.
- Phases 9-11 are folding protocols, not sumchecks.
- Phase 12 is proof packaging and transcript sealing.

### Challenge Propagation

```
r_stage1 --> Phase 2 binds polynomials on r_stage1
r_stage2 --> Phase 3 binds polynomials on r_stage2
...
r_stage7 --> Phase 8 splits r_stage7 into FrontierPoint(r_address || r_cycle)
          --> neo-reductions uses frontier point for ME claims
```

### Opening Accumulation

Every sumcheck stage appends (polynomial_id, opening_point, claimed_value) triples to an
accumulator. The accumulator is passed explicitly between stages as a moved value, not shared
as mutable state. After Phase 7, the accumulator's contents define the bridge's input.

---

### Per-Stage Contracts

#### Phase 0 - Shared Frontend Commitment

Commit the shared Ajtai frontend witness surface once, before any stage logic. This is the
normative opening surface for Phases 1-7.

- Input: raw frontend witnesses
- Output: Ajtai commitment digest (absorbed into transcript)
- Paper anchor: SuperNeo S7, ZkVmReduction.SuperNeoAjtai.spec.md

#### Phase 1 - Stage 1: Outer Spartan R1CS

| Property       | Value                                                    |
|----------------|----------------------------------------------------------|
| Subinstances   | 1 (outer Spartan constraint)                             |
| Uni-skip       | Yes (round 1 optimization)                               |
| Input          | Committed witness polynomials, Spartan key               |
| Output         | r_stage1 challenge vector, 35 virtual-input evaluations  |
| Paper anchor   | Jolt S7 (R1CS via Spartan), SuperNeo S7.2 (Pi_CCS)      |

Only stage that touches R1CS directly. Proves the uniform per-cycle CPU constraint.

#### Phase 2 - Stage 2: Memory/Lookup/Product Checking

| Property       | Value                                                                  |
|----------------|------------------------------------------------------------------------|
| Subinstances   | 5: RamReadWriteChecking, ProductVirtualRemainder, InstructionLookupsClaimReduction, RamRafEvaluation, OutputSumcheck |
| Uni-skip       | Yes (on product virtual)                                               |
| Input          | r_stage1                                                               |
| Output         | r_stage2                                                               |
| Paper anchor   | Jolt S7 (memory checking), Twist S5 (RAM consistency), Jolt S4-5 (Lasso lookups) |

Heaviest stage. Initiates all three subsystem checks: RAM consistency (Twist),
instruction lookups (Lasso), and Spartan product completion.

#### Phase 3 - Stage 3: Shift + Instruction Input + Register Reduction

| Property       | Value                                                                  |
|----------------|------------------------------------------------------------------------|
| Subinstances   | 3: SpartanShift, InstructionInputVirtualization, RegistersClaimReduction |
| Uni-skip       | No                                                                     |
| Input          | r_stage2                                                               |
| Output         | r_stage3                                                               |
| Paper anchor   | Jolt S3 (PC linking), Jolt S7 (instruction operand encoding)           |

Links PC transitions (next_pc = pc+4 or branch target), encodes instruction operands,
begins register consistency reduction.

#### Phase 4 - Stage 4: Register R/W + RAM Value Check

| Property       | Value                                              |
|----------------|----------------------------------------------------|
| Subinstances   | 2: RegistersReadWriteChecking, RamValCheck         |
| Uni-skip       | No                                                 |
| Input          | r_stage3                                           |
| Output         | r_stage4                                           |
| Paper anchor   | Jolt S7 (register/RAM value correctness)           |

Smallest sumcheck stage. Proves register read-write consistency and RAM value correctness.

#### Phase 5 - Stage 5: Instruction RAF + RAM RA + Register Value Eval

| Property       | Value                                                                    |
|----------------|--------------------------------------------------------------------------|
| Subinstances   | 3: InstructionReadRaf, RamRaClaimReduction, RegistersValEvaluation       |
| Uni-skip       | No                                                                       |
| Input          | r_stage4                                                                 |
| Output         | r_stage5                                                                 |
| Paper anchor   | Jolt S7 (RAF checking), Twist S5 (RA polynomial)                        |

Verifies instruction read-after-free, reduces RAM random-access claims, evaluates register
values at target points. This stage demonstrates why Twist and Shout cannot be separate
phases: instruction lookups (Shout-like), RAM RA reduction (Twist-like), and register value
evaluation (Twist-like) are batched together.

#### Phase 6 - Stage 6: Bytecode/Booleanity/RA Virtual + Advice Phase 1

| Property       | Value                                                                    |
|----------------|--------------------------------------------------------------------------|
| Subinstances   | 6 mandatory + 2 optional: BytecodeReadRaf, Booleanity, RamHammingBooleanity, RamRaVirtualization, InstructionRaVirtualization, IncClaimReduction, [AdviceClaimReduction x2] |
| Uni-skip       | No                                                                       |
| Input          | r_stage5                                                                 |
| Output         | r_stage6 + advice carry state (consumed by Phase 7)                      |
| Paper anchor   | Jolt S7 (booleanity), Jolt S5-6 (RA virtualization)                     |

Widest stage by subinstance count. Validates one-hot encoding, Hamming weight booleanity,
RA polynomial virtualization. Begins advice reduction (only cross-stage state in pipeline).

#### Phase 7 - Stage 7: Hamming Weight + Advice Phase 2

| Property       | Value                                                                    |
|----------------|--------------------------------------------------------------------------|
| Subinstances   | 1 mandatory + 2 optional: HammingWeightClaimReduction, [AdviceClaimReduction x2] |
| Uni-skip       | No                                                                       |
| Rounds         | Shorter than stages 1-6 (log_k_chunk rounds only)                       |
| Input          | r_stage6 + advice carry state from Phase 6                              |
| Output         | r_stage7 = unified opening point (frontier point)                        |
| Paper anchor   | Jolt S7 (final reduction)                                               |

Terminal sumcheck stage. Collapses all committed RA families to one shared address point.
r_stage7 splits into r_address || r_cycle, which defines the bridge input.

Note: IncClaimReduction belongs to Stage 6, not Stage 7. The existing stage specs
(JoltStage6.spec.md) are normative on this point.

---

### Phase 8 - Bridge Export

After Phase 7 produces the unified frontier point, the pipeline stops being Jolt-native.
Phase 8 is the translation boundary.

What it does:
1. Takes Phase 7's frontier point + the full opening accumulator
2. Materializes the current-step carrier (35 Stage-1 semantic slots as bounded MCS witnesses, leaf norm b=2)
3. Materializes the frontier CE carriers (one per committed RA family in canonical order: RdIncFamily, RamIncFamily, InstructionRaFamily, BytecodeRaFamily, RamRaFamily, + optional advice)
4. Exports a BridgeBundle containing: mcs_list, mcs_witnesses, ce_claims, ce_witnesses, public_bridge_view

What it does NOT do:
- No sumcheck. No new challenges sampled.
- No norm reduction. Witnesses are materialized at leaf norm, not yet decomposed.
- No commitment. Ajtai commitment happened at Phase 0. The bridge reshapes existing committed data.

Paper anchor: ZkVmCeBridge.spec.md, ZkVmBridge.CurrentStep.spec.md, ZkVmBridge.Frontier.spec.md

---

### Phases 9-11 - SuperNEO Backend Spine (owned by neo-reductions)

These three phases are the lattice-based folding tail. neo-fold-next calls neo-reductions
via three explicit API calls (not one opaque fold). Each step carries a `MainCarryState`
containing the CE claims and witnesses produced by the prior step's Π_DEC.

Phase 9 - Π_CCS (CCS Reduction):
- Type signature (paper Lemma 3, S7.2):
  `Π_CCS : CCS(b,L)^K × CE(b,L)^k → CE(b,L)^(K+k)`
- Takes K fresh CCS claims (from the current step's MCS) plus k carried CE claims
  (from the prior step's Π_DEC output, empty on the first step)
- Runs CCS constraint check: digit decomposition validity, rerandomization, sumcheck
  over Boolean hypercube
- Produces K+k CE claims (= 1+k when K=1, which is the single-step case)
- Actual API: `neo_reductions::api::prove(mode, tr, params, s, &[mcs], &[witness],
  &incoming_claims, &incoming_witnesses, log)` — or `prove_simple(...)` when k=0
- Paper anchor: SuperNeo S7.2

Phase 10 - Π_RLC (Random Linear Combination):
- Type signature (paper Lemma 4, S7.3):
  `Π_RLC : CE(b,L)^(K+k) → CE(B,L)`
- Takes all K+k CE claims from Phase 9
- Samples RLC challenges ρ₁..ρ_{K+k} from transcript (via `sample_rot_rhos_n_typed`)
- Linearly combines: c ← Σ ρᵢcᵢ, x ← Σ ρᵢxᵢ, z ← Σ ρᵢzᵢ
- Produces 1 high-norm CE claim (the "parent")
- Actual API: `neo_reductions::api::rlc_with_commit(mode, s, params, &rhos,
  &ccs_outputs, &rlc_inputs_wit, ell_d, mix_rhos_commits)`
- The caller builds `rlc_inputs_wit` by prepending the fresh step witness to the
  carried witnesses
- Paper anchor: SuperNeo S7.3

Phase 11 - Π_DEC (Decomposition / Norm Reset):
- Type signature (paper Theorem 7, S7.4-S7.5):
  `Π_DEC : CE(B,L) → CE(b,L)^k_dec`
- Takes the 1 high-norm parent CE claim from Phase 10
- Splits the high-norm witness via base-b factorization: (z₁..z_{k_dec}) ← split_b(z)
- k_dec is dynamically determined by the witness norm (not a fixed constant):
  `required_k_dec(params, &z_mix, &parent.X, min_k)`
- Commits each child witness via the SModuleHomomorphism log
- Verifier checks: c = Σ b^(i-1)·cᵢ and ∀j: yⱼ = Σ b^(i-1)·yᵢⱼ
- Produces k_dec low-norm CE claims (norm bounded by b)
- Actual API: `neo_reductions::api::dec_children_with_commit(mode, s, params,
  &parent, &z_split, ell_d, &child_commitments, combine_b_pows)`
- Paper anchor: SuperNeo S7.4-S7.5

IVC carry: The output `MainCarryState { claims: children, witnesses: z_split }` from
Phase 11 becomes the `incoming_main` for the next step's Phase 9. The first step starts
with an empty carry (k=0), so `prove_simple` is used instead of `prove`.

---

### Phase 12 - Finalization

**Current implementation** (`finalize.rs`):
The current finalization is a packaging and digest boundary for the main-lane path.
It does NOT implement batch final openings, Spartan2, or FRI PCS.

What it does:
- Validates that public step instances match session proof step instances
- Computes a Poseidon2 digest over the public statement (step instances + final CE claims)
- Computes a Poseidon2 digest over the full proof (statement digest + all step proofs)
- Packages into `FinalizedSessionProof { statement, proof }`
- Verification recomputes both digests, replays `verify_steps`, and checks final CE
  claims match

What it explicitly does NOT do yet (per `finalize.rs` line 6):
- Time/joint opening proofs (the `time_opening.rs` module is an empty stub)
- Twist/Shout extension family proofs (stubs in `shard/twist/`, `shard/shout/`)
- Any polynomial commitment opening (no Dory, no FRI, no Spartan2)

**Future target**: When Twist/Shout families and time_opening are implemented, Phase 12
will additionally:
- Collect opening obligations from extension families
- Prove joint openings (time-opening reduction + batched polynomial opening proof)
- Bind extension proofs into the finalized artifact

This is an incremental extension of the current boundary — the current Poseidon2 digest
packaging is the start of the final architecture, not a throwaway scaffold.

---

## Part II: Crate Design

> **Implementation status key:**
> - **[IMPLEMENTED]** — exists in the current `neo-fold-next` crate and is tested
> - **[DESIGN CHOICE]** — architectural proposal not yet implemented; reasonable but
>   unproven. Not implied by the paper or by Jolt. Could be replaced by a different
>   design without affecting the mathematical correctness of the protocol.
> - **[STUB]** — module exists in code but is empty or trivially incomplete

### Module Layout

```
neo-fold-next/
  src/
    # --- [IMPLEMENTED] SuperNeo main-lane spine ---
    lib.rs                          # Public API surface
    proof.rs                        # Typed proof artifacts (MainCarryState, ShardStepProof, etc.)
    session.rs                      # Multi-step session driver (prove_steps, verify_steps)
    finalize.rs                     # Poseidon2 digest packaging (package_session_proof, verify)
    output_binding.rs               # Output binding config
    frontends.rs                    # Frontend trait surface
    shard/
      mod.rs
      prover.rs                     # ShardProver::prove_step (Π_CCS → Π_RLC → Π_DEC)
      verifier.rs                   # ShardVerifier::verify_step (mirror)
      main_lane.rs                  # Main-lane relation types

    # --- [STUB] Extension families (declared, not implemented) ---
    shard/twist/
      mod.rs                        # Twist-side mutable-history families
      register_history.rs           # Register R/W consistency (empty)
      ram_history.rs                # RAM R/W consistency (empty)
    shard/shout/
      mod.rs                        # Shout-side readonly families
      bytecode_fetch.rs             # PC → instruction lookup (empty)
      instruction_semantics_lookup.rs # Opcode evaluation lookup (empty)
    time_opening.rs                 # Future joint opening/finalizer logic (empty)

    # --- [DESIGN CHOICE] Proposed Phases 0-8 architecture (not yet implemented) ---
    # The following modules are architectural proposals. They represent one reasonable
    # way to build the Jolt-style sumcheck pipeline on top of the implemented spine.
    # The paper does not prescribe this decomposition. Jolt's 7-stage pipeline is a
    # reference implementation, not a normative requirement.
    pipeline/
      mod.rs                        # Pipeline orchestrator (Phase 0→8, calls spine, then 12)
      checkpoint.rs                 # Checkpoint/resume serialization
      emission.rs                   # Emission policy (EveryStep, Checkpoint, FinalOnly)
    phase0/
      commitment.rs                 # Shared Ajtai frontend commitment
    vm/
      mod.rs                        # VmSpec trait definition (public developer API)
      banks.rs                      # BankSpec, BankKind, BankId
      opcode_classes.rs             # OpcodeClassSpec, OpcodeClassId, QueryShape, EffectShape
      state.rs                      # StateSpec, StateFieldSpec
      decode.rs                     # DecodeSpec
    families/
      mod.rs                        # LoweredVmPlan, family compiler entry point
      compiler.rs                   # VmSpec → LoweredVmPlan lowering
      shout.rs                      # ShoutFamilySpec, LoweredShoutFamily
      twist.rs                      # TwistFamilySpec, LoweredTwistFamily
      support.rs                    # LoweredSupportFamily (booleanity, hamming, etc.)
      lookup_table.rs               # LookupTable trait + standard tables
    vms/
      mod.rs                        # VM registry
      rv64im.rs                     # RV64IM reference VM (default)
    stages/
      mod.rs                        # SumcheckStage trait definition
      planner.rs                    # FamilyPlan → stage instance population
      stage1.rs through stage7.rs   # Batched sumcheck stages (Jolt-modeled)
      subinstances/                 # 17 subinstance types (ported from Jolt)
    bridge/
      mod.rs                        # Phase 8: exports PreparedStep(s) for the spine
      current_step.rs               # N-slot current-step carrier
      frontier.rs                   # RA family frontier carriers
      public_view.rs                # Verifier-facing bridge slice
    types/
      mod.rs
      claims.rs                     # OpeningClaim, MEClaim, SumcheckClaim
      challenges.rs                 # StageChallenge<N>, typed challenge vectors
      accumulator.rs                # OpeningAccumulator (value type)
      proof.rs                      # Full pipeline proof artifact
      config.rs                     # OneHotParams, ReadWriteConfig, emission config
```

Structural decisions:
1. The implemented spine (`shard/`, `session.rs`, `finalize.rs`, `proof.rs`) is production
   code and should not be reorganized without cause.
2. The proposed modules (`pipeline/`, `vm/`, `families/`, `stages/`, `bridge/`, `types/`)
   are archived historical design choices for one earlier implementation path.
   They are not the active owner map for `neo-fold-next/src` and should not be
   read as current module guidance.
3. No reduction/ module. neo-fold-next calls neo-reductions directly (this is implemented
   and settled).
4. Extension family stubs (`twist/`, `shout/`, `time_opening.rs`) mark the next concrete
   work items — they are the path from the current main-lane spine to the full proving pipeline.

### Crate Boundary

**Current** (implemented):
```
neo-fold-next/session.rs          — drives N steps through the spine
    |
    | For each step: PreparedStep (CcsClaim + CcsWitness + MainCarryState)
    v
neo-fold-next/shard/prover.rs     — prove_step: Π_CCS → Π_RLC → Π_DEC
    |                               (calls neo-reductions API directly)
    | ProvedStep { proof, next_main: MainCarryState }
    v
neo-fold-next/finalize.rs         — package_session_proof: Poseidon2 digest packaging
```

**Target** (when Phases 0-8 are built):
```
neo-fold-next/pipeline            — [DESIGN CHOICE] Phases 0-8 sumcheck stages
    |
    | PreparedStep(s) — bridge output feeds into the existing spine
    v
neo-fold-next/session + shard     — [IMPLEMENTED] Phases 9-11 spine (unchanged)
    |
    | SessionProof
    v
neo-fold-next/finalize            — [IMPLEMENTED] Phase 12 packaging (extended with openings)
```

neo-fold-next depends on neo-reductions. The shard prover calls `prove`/`prove_simple`,
`rlc_with_commit`, and `dec_children_with_commit` directly — no adapter layer, no thin
wrappers, no hypothetical `fold(bundle)` one-call API.

---

### Trait Contracts

> **All trait contracts in this section are [DESIGN CHOICE].**
> They represent one reasonable API design for Phases 0-8 but are not implemented yet
> and are not implied by the paper or by the current Jolt source. They should be
> evaluated as engineering proposals.

#### SumcheckStage (core trait for Phases 1-7) [DESIGN CHOICE]

```rust
pub trait SumcheckStage {
    type Proof: Serialize + Deserialize;

    /// Number of subinstances batched in this stage's sumcheck.
    fn subinstance_count(&self) -> usize;

    /// Whether this stage uses uni-skip optimization (Stages 1-2: yes, 3-7: no).
    fn uses_uni_skip(&self) -> bool;

    /// Run the stage. Consumes self.
    /// Takes previous challenges + accumulator, returns proof + new challenges + updated accumulator.
    fn prove(
        self,
        prev_challenges: &StageChallenge,
        transcript: &mut Transcript,
        accumulator: OpeningAccumulator,
    ) -> (Self::Proof, StageChallenge, OpeningAccumulator);

    /// Verify a stage proof.
    fn verify(
        proof: &Self::Proof,
        prev_challenges: &StageChallenge,
        transcript: &mut Transcript,
        accumulator: VerifierAccumulator,
    ) -> Result<(StageChallenge, VerifierAccumulator), VerifyError>;
}
```

Design decisions:
- prove() consumes self. Stage state (witnesses, subinstance provers) is dropped after proving.
- OpeningAccumulator is moved in, moved out. Each stage gets ownership, appends claims, passes forward. No aliasing.
- StageChallenge is typed. Prevents accidentally passing Stage 3's challenges where Stage 5's are expected.
- Transcript is the one &mut. Correct because Fiat-Shamir ordering is sequential by definition.

#### Stage 6 -> 7 Advice Handoff

```rust
pub struct AdviceCarry {
    pub trusted: Option<AdviceReductionState>,
    pub untrusted: Option<AdviceReductionState>,
}
```

The advice carry is embedded in Stage 6's proof output and extracted by the pipeline before
constructing Stage 7. Explicit data flow, not a cached field on a shared struct.

#### BridgeExport (Phase 8) [DESIGN CHOICE]

```rust
pub trait BridgeExport {
    fn export(
        frontier_point: FrontierPoint,
        accumulator: OpeningAccumulator,
        commitment_context: &AjtaiContext,
    ) -> BridgeBundle;
}
```

No proof, no challenges, no transcript mutation. Pure data reshaping.

> **Note:** The bridge's output must produce `PreparedStep` instances compatible with the
> implemented `shard/prover.rs::prove_step` API. The bridge does not call neo-reductions
> directly — it feeds the existing spine.

#### Pipeline Orchestrator

> **Architectural status:** The Phases 0-8 pipeline (SumcheckStage, OpeningAccumulator,
> BridgeExport) is a **design proposal** — none of it is implemented yet. The Phases 9-12
> spine below is **source-backed** and matches the current `shard/prover.rs` + `session.rs`
> + `finalize.rs` code.

**Current implemented pipeline** (matches `session.rs::prove_steps` + `shard/prover.rs::prove_step`):

```rust
// session.rs — drives multiple steps through the SuperNeo spine
pub fn prove_steps(
    mode: FoldingMode,
    params: &NeoParams,
    s: &CcsStructure<F>,
    steps: impl IntoIterator<Item = PreparedStep>,
    log: &impl SModuleHomomorphism<F, Commitment>,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<SessionProof, PiCcsError> {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/session");
    let mut main_carry = MainCarryState::default(); // empty on first step

    for step in steps {
        // Phase 9: Π_CCS — prove_simple (k=0) or prove (k>0)
        let (ccs_outputs, ccs_proof) = if main_carry.claims.is_empty() {
            prove_simple(mode, &mut tr, params, s, &[step.mcs], &[step.witness], log)?
        } else {
            prove(mode, &mut tr, params, s, &[step.mcs], &[step.witness],
                  &main_carry.claims, &main_carry.witnesses, log)?
        };
        // ccs_outputs.len() == 1 + main_carry.claims.len()

        // Phase 10: Π_RLC — sample rhos, linearly combine all K+k CE claims
        let rlc_rhos = sample_rlc_rhos(&mut tr, params, ccs_outputs.len())?;
        let mut rlc_inputs_wit = vec![step.witness.Z.clone()];
        rlc_inputs_wit.extend(main_carry.witnesses.iter().cloned());
        let (parent, z_mix) = rlc_with_commit(
            mode, s, params, &rlc_rhos, &ccs_outputs, &rlc_inputs_wit,
            dims.ell_d, mixers.mix_rhos_commits,
        )?;

        // Phase 11: Π_DEC — base-b decomposition, k_dec determined by witness norm
        let k_dec = required_k_dec(params, &z_mix, &parent.X, rlc_rhos.len())?;
        let (z_split, digit_nonzero) = split_b_matrix_k_with_nonzero_flags(&z_mix, k_dec, params.b)?;
        let child_commitments = commit_split_children(log, &z_split, &digit_nonzero)?;
        let (children, ok_y, ok_x, ok_c) = dec_children_with_commit(
            mode, s, params, &parent, &z_split, dims.ell_d,
            &child_commitments, mixers.combine_b_pows,
        );

        // Carry forward: children become next step's incoming CE claims
        main_carry = MainCarryState { claims: children, witnesses: z_split };
        session.steps.push(/* step proof artifacts */);
    }
    session.final_main_claims = main_carry.claims;
    Ok(session)
}
```

**Target pipeline** (when Phases 0-8 are implemented):

```rust
// Future: the full pipeline will prepend Phases 0-8 before the current spine
pub fn prove_full(self, vm: &impl VmSpec, witnesses: FrontendWitnesses) -> FinalizedSessionProof {
    // Phase 0: Ajtai frontend commitment (future)
    let (commitment, ctx) = phase0::commit(&witnesses);

    // Phases 1-7: sequential sumcheck stages (future, architectural choice)
    let acc = OpeningAccumulator::new();
    let challenge = StageChallenge::initial();
    let mut transcript = Transcript::new();
    // ... Stage1 through Stage7 ...

    // Phase 8: bridge export → PreparedStep(s) (future)
    let steps = bridge::export(challenge.as_frontier(), acc, &ctx);

    // Phases 9-11: the current implemented spine (unchanged)
    let session = prove_steps(mode, params, s, steps, log, mixers)?;

    // Phase 12: finalize and package
    package_session_proof(public_steps, session)
}
```

---

### Data Flow

**Implemented flow** (the current SuperNeo spine):

```
MainCarryState::default()                 # empty on first step
  -> prove_step:
       Π_CCS(mcs + carry.claims)          # produces K+k CE claims
       -> Π_RLC(all CE claims, rhos)      # produces 1 high-norm parent
       -> Π_DEC(parent, split_b)          # produces k_dec low-norm children
  -> MainCarryState { children, z_split } # carry to next step
  -> ... repeat for N steps ...
  -> session.final_main_claims            # final carry after last step
  -> package_session_proof                # Poseidon2 digest packaging
```

The transcript (`Poseidon2Transcript`) is threaded through all steps via `&mut tr`.
Each `prove_step` / `verify_step` call advances the transcript deterministically.

**Proposed additional flows** (for future Phases 0-8, [DESIGN CHOICE]):

#### Flow 1 - Challenge Chain (forward-only) [DESIGN CHOICE]

```
StageChallenge::initial()
  -> Stage 1 samples r_stage1
    -> Stage 2 binds on r_stage1, samples r_stage2
      -> ...
        -> Stage 7 samples r_stage7
          -> Bridge splits r_stage7 into FrontierPoint(r_address || r_cycle)
            -> Bridge produces PreparedStep(s) for the implemented spine
```

Each StageChallenge is typed with a phantom stage index. The compiler enforces ordering.

#### Flow 2 - Opening Accumulator (threaded ownership) [DESIGN CHOICE]

```
OpeningAccumulator::new()
  -> Stage 1 appends (poly_ids, points, claims), passes ownership out
    -> Stage 2 receives ownership, appends more, passes out
      -> ...
        -> Stage 7 passes final accumulator to Bridge
          -> Bridge consumes accumulator, reshapes into PreparedStep inputs
```

The accumulator is a value type moved between stages. No Arc<Mutex>, no &mut field on a shared
struct. Each stage has exclusive ownership while running.

#### Flow 3 - Transcript (sequential mutation)

```
Poseidon2Transcript::new(b"neo.fold.next/session")
  -> [future] Phase 0 absorbs commitment digest
    -> [future] Stages 1-7 absorb/squeeze (Fiat-Shamir)
      -> [future] Bridge absorbs public view
        -> [IMPLEMENTED] prove_step absorbs step labels, drives Π_CCS/Π_RLC/Π_DEC
          -> [IMPLEMENTED] finalize digests statement + proof
```

The transcript is the one &mut that flows through everything. Fiat-Shamir is inherently sequential.

#### What Does NOT Flow Between Steps [IMPLEMENTED]

- `CcsStructure`, `NeoParams`: shared immutable references across all steps
- `SModuleHomomorphism` (log): shared commitment oracle, not mutated by the spine
- `CommitmentMixers`: pure functions passed by copy

#### What Does NOT Flow Between Stages [DESIGN CHOICE, future]

- Witness data: each stage constructs its own subinstance provers from a shared &FrontendWitnesses reference. Read-only.
- Preprocessing: SpartanKey, OneHotParams, ReadWriteConfig are in a shared &PreprocessingContext. Immutable.
- Subinstance state: internal to each stage. Dropped after prove() consumes self.

#### Memory Profile

Current spine (implemented):
```
Per step:    Peak = MainCarryState(claims + witnesses) + step.witness + intermediate z_mix
             z_split replaces z_mix after split_b; old witnesses dropped on carry assignment
Session:     Peak = all ShardStepProof artifacts retained in SessionProof.steps
Finalize:    Peak = SessionProof + digest computation
```

Target (when Phases 0-8 are built):
```
Phase 0:     Peak = witness + commitment
Stages 1-7:  Peak = witness (shared ref) + current stage subinstances + accumulator
              Previous stage subinstances DROPPED before next stage constructs
Phase 8:     Peak = accumulator + bridge → PreparedStep(s)
Phases 9-11: Peak = MainCarryState + step artifacts (per step, in the existing spine)
Phase 12:    Peak = SessionProof + digest computation
```

No stage holds onto previous stage memory. Pipeline peak memory is determined by the single
heaviest stage (likely Stage 2 with 5 subinstances), not the sum of all stages.

---

## Appendix A: Subinstance Ownership Table

Normative mapping of protocol family (Twist-like vs Shout-like) to subinstance to stage.
Twist and Shout are subinstance families owned by stages, not top-level prover phases.

| Stage | Subinstance                      | Family     | Protocol Anchor       |
|-------|----------------------------------|------------|-----------------------|
| 1     | OuterSpartanR1CS                 | Core glue  | Jolt S7, Spartan      |
| 2     | RamReadWriteChecking             | Twist      | Twist S5              |
| 2     | ProductVirtualRemainder          | Core glue  | Spartan               |
| 2     | InstructionLookupsClaimReduction | Shout      | Jolt S4-5 (Lasso)     |
| 2     | RamRafEvaluation                 | Twist      | Twist S5              |
| 2     | OutputSumcheck                   | Twist      | Jolt S7               |
| 3     | SpartanShift                     | Core glue  | Jolt S7               |
| 3     | InstructionInputVirtualization   | Shout      | Jolt S7               |
| 3     | RegistersClaimReduction          | Twist      | Jolt S7               |
| 4     | RegistersReadWriteChecking       | Twist      | Jolt S7               |
| 4     | RamValCheck                      | Twist      | Twist S5              |
| 5     | InstructionReadRaf               | Shout      | Jolt S7               |
| 5     | RamRaClaimReduction              | Twist      | Twist S5              |
| 5     | RegistersValEvaluation           | Twist      | Jolt S7               |
| 6     | BytecodeReadRaf                  | Shout      | Jolt S7               |
| 6     | Booleanity                       | Shout      | Jolt S5-6             |
| 6     | RamHammingBooleanity             | Twist      | Jolt S7               |
| 6     | RamRaVirtualization              | Twist      | Twist S5              |
| 6     | InstructionRaVirtualization      | Shout      | Jolt S5-6             |
| 6     | IncClaimReduction                | Twist      | Jolt S7               |
| 6     | AdviceClaimReduction (opt.)      | Advice     | Implementation-level  |
| 7     | HammingWeightClaimReduction      | Twist      | Jolt S7               |
| 7     | AdviceClaimReduction (opt.)      | Advice     | Implementation-level  |

---

## Appendix B: Per-Phase Contract Table

| Phase | Subinstances | Imported Claims              | Sampled Challenges        | Exported Claims                     | Consumer              |
|-------|-------------|------------------------------|---------------------------|-------------------------------------|-----------------------|
| 0     | --          | --                           | --                        | Ajtai commitment digest             | Phase 1 (transcript)  |
| 1     | 1           | Committed witnesses          | r_stage1                  | 35 virtual-input evals              | Phase 2               |
| 2     | 5           | r_stage1 bindings            | r_stage2                  | RAM/lookup/product openings         | Phase 3               |
| 3     | 3           | r_stage2 bindings            | r_stage3                  | Shift/register/instruction openings | Phase 4               |
| 4     | 2           | r_stage3 bindings            | r_stage4                  | Register R/W + RAM value openings   | Phase 5               |
| 5     | 3           | r_stage4 bindings            | r_stage5                  | RAF + RA + register value openings  | Phase 6               |
| 6     | 6+2opt      | r_stage5 bindings            | r_stage6 + advice carry   | Bytecode/booleanity/RA openings     | Phase 7               |
| 7     | 1+2opt      | r_stage6 + advice carry      | r_stage7 (frontier point) | Unified RA family openings          | Phase 8               |
| 8     | --          | Frontier point + accumulator | --                        | BridgeBundle (MCS + CE)             | neo-reductions        |
| 9     | --          | BridgeBundle                 | Pi_CCS challenges         | k ME claims                         | Phase 10              |
| 10    | --          | k ME claims                  | gamma (RLC challenge)     | 1 high-norm ME claim                | Phase 11              |
| 11    | --          | 1 high-norm ME               | --                        | k-1 low-norm ME claims              | Phase 12 / next IVC   |
| 12    | --          | Folded accumulator           | --                        | NeoFoldProof                        | Verifier              |

---

## Appendix C: Paper Anchors

| Document                                               | Phases   | What it governs                          |
|--------------------------------------------------------|----------|------------------------------------------|
| docs/jolt-paper/04-3_An_Overview_of_RISC-V...md       | 1-7      | Execution model, CPU state, frontend     |
| docs/jolt-paper/05-4_Analyzing_MLE-structure...md      | 2,5,6    | Instruction decomposition, Lasso lookups |
| docs/jolt-paper/08-7_Putting_It_all_Together...md      | 1-7      | Full Jolt proving pipeline               |
| docs/twist-and-shout-paper/4_the_shout_piop.md         | 2,5,6    | Shout-like subinstances                  |
| docs/twist-and-shout-paper/5_the_twist_piop.md         | 2,4,5,6  | Twist-like subinstances                  |
| docs/superneo-paper/07_7_Neo_s_folding_scheme...md     | 9-11     | Pi_CCS, Pi_RLC, Pi_DEC                  |
| crates/deprecated-neo-fold/specs/ZkVmCeBridge.spec.md             | 8        | Bridge export contract                   |
| crates/deprecated-neo-fold/specs/ZkVmBridge.CurrentStep.spec.md   | 8        | Current-step carrier                     |
| crates/deprecated-neo-fold/specs/ZkVmBridge.Frontier.spec.md      | 8        | Frontier CE carriers                     |
| crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai...md | 0,9-11   | Ajtai commitment, norm model             |
| docs/system-architecture.md                            | 12       | Emission policies, IVC embedded verifier |

---

## Part III: VM Flexibility

### Design Principle

Fixed proof kernel, dynamic family multiplicity.

The stage order, transcript schedule, bridge export contract, and SuperNeo tail (Pi_CCS,
Pi_RLC, Pi_DEC) all stay fixed. What becomes dynamic is how many read-only families exist,
how many read-write families exist, how many opcode classes share a lookup family, and which
support reductions are needed.

The architecture has three layers:

1. **Fixed proof kernel**: Stages 1-7, transcript order, bridge ABI, SuperNeo tail.
2. **VM spec**: A VM declares its state, banks, opcode classes, decode, and effects.
3. **Family compiler**: Lowers the VM spec into concrete Twist/Shout/support family instances
   that the fixed stages consume.

### What Stays Fixed

- Phase order (0-12)
- Transcript schedule
- Bridge export contract
- Pi_CCS / Pi_RLC / Pi_DEC
- Stage-local import/export meaning
- Normalization rules for opening points
- SumcheckStage trait interface

### What Becomes Dynamic

- How many read-only banks (Shout families) exist
- How many read-write banks (Twist families) exist
- How many opcode classes share a lookup family
- Which support reductions are needed (booleanity, hamming, etc.)
- The number of slots in the Stage 1 kernel constraint (N, not hardcoded 35)
- The number of frontier carriers in the bridge

### Layer 1: VM Spec (Developer API)

The public API for VM developers. A VM is defined by its state, banks, opcode classes,
and decode rules. Developers do NOT touch Twist/Shout algebra, stages, or families directly.

```rust
pub trait VmSpec {
    type OpcodeId: Copy + Eq + Hash;

    /// State fields: PC, flags, mode bits, etc.
    fn state_spec(&self) -> StateSpec;

    /// Banks: program ROM, registers, RAM, stack, display, advice, etc.
    fn banks(&self) -> Vec<BankSpec>;

    /// Opcode classes: groups of opcodes sharing lookup shape and effect routing.
    fn opcode_classes(&self) -> Vec<OpcodeClassSpec<Self::OpcodeId>>;

    /// Decode spec: how an instruction row becomes selectors and operands.
    fn decode_spec(&self) -> DecodeSpec<Self::OpcodeId>;

    /// Core CCS/R1CS spec: small glue constraints for the Stage 1 kernel.
    fn core_ccs_spec(&self) -> CoreCcsSpec;
}
```

### Banks

Every piece of addressable state is a bank. Banks are the fundamental unit the developer
works with. Each bank has a kind that determines what proof obligations it generates.

```rust
pub struct BankSpec {
    pub id: BankId,
    pub name: String,
    pub kind: BankKind,
}

pub enum BankKind {
    /// Read-only lookup bank (program ROM, constant tables).
    /// Generates Shout-side instances: read/RAF, address correctness, decode support.
    ReadOnlyLookup(ShoutFamilySpec),

    /// Read-write memory bank (registers, RAM, stack, display).
    /// Generates Twist-side instances: RW checking, value check, RA reduction,
    /// RA virtualization, Hamming/booleanity, increment reduction.
    ReadWriteMemory(TwistFamilySpec),

    /// Pure state field (PC, flags, mode bits).
    /// Carried in the Stage 1 kernel, no dedicated family.
    PureState(StateFieldSpec),
}
```

Bank kind determines which stage instances are generated:

| BankKind | Stage instances generated |
|----------|--------------------------|
| ReadOnlyLookup | Read/RAF (S5,S6), address correctness (S6), decode support (S6), RA virtualization (S6) |
| ReadWriteMemory | RW checking (S2,S4), value check (S4), RA reduction (S5), RA virtualization (S6), Hamming/booleanity (S6), increment reduction (S6) |
| PureState | Stage 1 kernel slot only |

### Bank Specs

```rust
pub struct ShoutFamilySpec {
    pub addr_bits: usize,
    pub table_shape: TableShape,
    pub decode: DecodeObligations,
    pub one_hot: OneHotSpec,
    pub auth: TableAuthSpec,
}

pub struct TwistFamilySpec {
    pub addr_bits: usize,
    pub value_bits: usize,
    pub init: InitRule,
    pub one_hot: OneHotSpec,
    pub rw_model: RwModel,
}

pub enum RwModel { ReadOnly, ReadWrite, WriteOnce, AppendOnly }
pub enum InitRule { ZeroInit, PreloadedFrom(BankId), Custom(Vec<u8>) }
```

### Opcode Classes (Column Reuse)

Columns are owned by opcode classes, not by opcodes. This is the mechanism that prevents
column explosion.

```rust
pub struct OpcodeClassSpec<OpcodeId> {
    /// Class identifier.
    pub class_id: OpcodeClassId,

    /// Opcodes in this class. They share the same columns.
    pub opcodes: Vec<OpcodeId>,

    /// Which Shout family this class maps to.
    pub family: FamilyId,

    /// How operands are packed into the lookup address/query.
    pub query_shape: QueryShape,

    /// Max number of sublookups this class may need.
    pub max_sublookups: usize,

    /// How effects are routed to rd / memory / pc / flags.
    pub effect_shape: EffectShape,
}
```

An opcode becomes:
- A selector value within its class
- A row in a shared class table
- Maybe a small class-local mux

NOT a new committed family every time.

Reuse rule: multiple opcodes may share the same class if they share:
- Operand packing (query_shape)
- Query address shape
- Sublookup budget (max_sublookups)
- Output routing shape (effect_shape)
- Decode support obligations

Only if an opcode fails all four checks should it create new columns.

### Layer 2: Family Compiler (Internal)

The compiler lowers a VmSpec into concrete family instances the stages consume.
Developers do not call this directly. The pipeline invokes it.

```rust
/// Output of the family compiler. Consumed by stages/planner.rs.
pub struct LoweredVmPlan {
    /// Stage 1 kernel: core CCS constraints, decode, state field slots.
    pub stage1: CoreKernelPlan,

    /// Stages 2-7: concrete Twist/Shout/support family instances.
    pub stages2_7: FamilyPlan,

    /// Phase 8 bridge: carrier shapes derived from the family plan.
    pub bridge: BridgeShape,
}

pub struct FamilyPlan {
    pub shout_families: Vec<LoweredShoutFamily>,
    pub twist_families: Vec<LoweredTwistFamily>,
    pub support_families: Vec<LoweredSupportFamily>,
}
```

The compiler:
1. Iterates over `VmSpec::banks()`.
2. For each ReadWriteMemory bank, emits a LoweredTwistFamily with the right address width,
   value width, RA chunk count, and derived support obligations (booleanity, hamming, inc).
3. For each ReadOnlyLookup bank, emits a LoweredShoutFamily with the right table shape,
   decomposition, and decode obligations.
4. Groups opcode classes by family, computing shared column sets.
5. Emits a CoreKernelPlan for Stage 1 with state field slots and core CCS constraints.
6. Emits a BridgeShape with the right number of frontier carriers.

### Layer 3: Stage Planner (Internal)

The stage planner takes a LoweredVmPlan and populates each stage with the right subinstances.
The stage skeleton is fixed; the instance counts are dynamic:

```
Stage 1: 1 kernel instance (always)
Stage 2: 1 ProductVirtual + N_rw RamRW + N_ro InstructionLookup + N_rw RamRaf + N_rw Output
Stage 3: 1 Shift + N_ro InstructionInput + N_rw RegistersClaim
Stage 4: N_rw RegistersRW + N_rw RamVal
Stage 5: N_ro InstructionRaf + N_rw RamRa + N_rw RegistersVal
Stage 6: N_ro BytecodeRaf + N_support Booleanity + N_rw RamRaVirtual + N_ro InstructionRaVirtual + N_rw Inc + optional Advice
Stage 7: N_support Hamming + optional Advice
```

Where N_rw = number of ReadWriteMemory banks, N_ro = number of ReadOnlyLookup banks,
N_support = derived from family requirements.

For RV64IM: N_rw = 2 (registers, ram), N_ro = 1 (program ROM).
For Chip8: N_rw = 3 (registers, ram, display), N_ro = 1 (program ROM).

### Compatibility Mode vs Research Mode

**Compatibility mode (stable, default):**

Users can define:
- Banks (ReadOnlyLookup, ReadWriteMemory, PureState)
- Opcode classes with shared column shapes
- Table decomposition parameters
- Init semantics
- Bridge-visible carriers

Users cannot define:
- New stage algebra
- Custom sumcheck identities
- Custom exported opening schedules
- Custom challenge schedules
- Custom bridge carrier semantics

**Research mode (unstable, opt-in feature flag):**

Users can inject:
- New support reductions
- Custom family lowering rules
- Custom stage-local subinstances

No compatibility guarantees. No promise of canonical frontend ABI.

### Pipeline Orchestrator (Updated)

```rust
impl Pipeline {
    pub fn prove<V: VmSpec>(self, vm: &V, witnesses: FrontendWitnesses) -> NeoFoldProof {
        // Compile VM spec into family plan
        let plan = families::compiler::lower(vm);

        // Phase 0: commit (surface shape from plan)
        let (commitment, ctx) = phase0::commit(&witnesses, &plan);
        let mut transcript = Transcript::new();
        transcript.append_commitment(&commitment);

        // Phases 1-7: stages populated from plan
        let mut acc = OpeningAccumulator::new();
        let mut challenge = StageChallenge::initial();

        let (p1, challenge, acc) = Stage1::from_plan(&plan.stage1, &witnesses, &ctx)
            .prove(&challenge, &mut transcript, acc);
        let (p2, challenge, acc) = Stage2::from_plan(&plan.stages2_7, &witnesses, &ctx)
            .prove(&challenge, &mut transcript, acc);
        // ... stages 3-7, each populated from plan.stages2_7 ...

        // Phase 8: bridge shaped by plan.bridge
        let bundle = Bridge::export(challenge.as_frontier(), acc, &ctx, &plan.bridge);

        // Phases 9-11: neo-reductions directly
        let folded = neo_reductions::api::pi_ccs_prove(&bundle, &mut transcript);

        // Phase 12: finalize
        finalize::package(folded, &mut transcript)
    }
}
```

### RV64IM VM Spec (Reference Implementation)

```rust
pub struct Rv64Im;

impl VmSpec for Rv64Im {
    type OpcodeId = RiscVOpcode;

    fn state_spec(&self) -> StateSpec {
        StateSpec::new(&[
            StateField::new("pc", 64),
        ])
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
                addr_bits: 5,
                value_bits: 64,
                init: InitRule::ZeroInit,
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
            BankSpec::new("ram", BankKind::ReadWriteMemory(TwistFamilySpec {
                addr_bits: 32,
                value_bits: 64,
                init: InitRule::PreloadedFrom(BankId::named("program_rom")),
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
        ]
    }

    fn opcode_classes(&self) -> Vec<OpcodeClassSpec<RiscVOpcode>> {
        vec![
            OpcodeClassSpec {
                class_id: OpcodeClassId::new("alu"),
                opcodes: vec![ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA,
                              ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI,
                              ADDW, SUBW, ADDIW, /* ... */],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 64, right: 64 },
                max_sublookups: 16,
                effect_shape: EffectShape::WriteRd,
            },
            OpcodeClassSpec {
                class_id: OpcodeClassId::new("branch"),
                opcodes: vec![BEQ, BNE, BLT, BGE, BLTU, BGEU],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 64, right: 64 },
                max_sublookups: 16,
                effect_shape: EffectShape::BranchPc,
            },
            OpcodeClassSpec {
                class_id: OpcodeClassId::new("memory"),
                opcodes: vec![LB, LH, LW, LD, SB, SH, SW, SD, LBU, LHU, LWU],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::BaseOffset { base: 64, offset: 12 },
                max_sublookups: 16,
                effect_shape: EffectShape::LoadStore,
            },
            OpcodeClassSpec {
                class_id: OpcodeClassId::new("mul_div"),
                opcodes: vec![MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU,
                              MULW, DIVW, DIVUW, REMW, REMUW],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 64, right: 64 },
                max_sublookups: 16,
                effect_shape: EffectShape::WriteRd,
            },
        ]
    }

    fn decode_spec(&self) -> DecodeSpec<RiscVOpcode> {
        DecodeSpec::standard_rv64im()
    }

    fn core_ccs_spec(&self) -> CoreCcsSpec {
        // 19 uniform equality-conditional constraints
        // Ported from crates/deprecated-neo-fold/src/zkvm/r1cs/constraints.rs
        CoreCcsSpec::rv64im_standard()
    }
}
```

### Chip8 VM Spec Example

```rust
pub struct Chip8;

impl VmSpec for Chip8 {
    type OpcodeId = Chip8Opcode;

    fn state_spec(&self) -> StateSpec {
        StateSpec::new(&[
            StateField::new("pc", 12),
            StateField::new("i_reg", 16),
            StateField::new("delay_timer", 8),
            StateField::new("sound_timer", 8),
        ])
    }

    fn banks(&self) -> Vec<BankSpec> {
        vec![
            BankSpec::new("program_rom", BankKind::ReadOnlyLookup(ShoutFamilySpec {
                addr_bits: 12,
                table_shape: TableShape::Decomposable { log_k: 16, chunk: 4 },
                decode: DecodeObligations::chip8_standard(),
                one_hot: OneHotSpec::default(),
                auth: TableAuthSpec::Bytecode,
            })),
            BankSpec::new("registers", BankKind::ReadWriteMemory(TwistFamilySpec {
                addr_bits: 4, value_bits: 8,
                init: InitRule::ZeroInit,
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
            BankSpec::new("ram", BankKind::ReadWriteMemory(TwistFamilySpec {
                addr_bits: 12, value_bits: 8,
                init: InitRule::ZeroInit,
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
            BankSpec::new("stack", BankKind::ReadWriteMemory(TwistFamilySpec {
                addr_bits: 4, value_bits: 16,
                init: InitRule::ZeroInit,
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
            BankSpec::new("display", BankKind::ReadWriteMemory(TwistFamilySpec {
                addr_bits: 11, value_bits: 1,
                init: InitRule::ZeroInit,
                one_hot: OneHotSpec::default(),
                rw_model: RwModel::ReadWrite,
            })),
        ]
    }

    fn opcode_classes(&self) -> Vec<OpcodeClassSpec<Chip8Opcode>> {
        vec![
            OpcodeClassSpec {
                class_id: OpcodeClassId::new("math"),
                // 7 opcodes, 1 column set
                opcodes: vec![ADD, SUB, OR, AND, XOR, SHR, SHL],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 8, right: 8 },
                max_sublookups: 4,
                effect_shape: EffectShape::WriteRd,
            },
            OpcodeClassSpec {
                class_id: OpcodeClassId::new("skip"),
                // 4 opcodes, 1 column set
                opcodes: vec![SE, SNE, SKP, SKNP],
                family: FamilyId::named("program_rom"),
                query_shape: QueryShape::TwoOperand { left: 8, right: 8 },
                max_sublookups: 4,
                effect_shape: EffectShape::BranchPc,
            },
        ]
    }

    fn decode_spec(&self) -> DecodeSpec<Chip8Opcode> { DecodeSpec::chip8_standard() }
    fn core_ccs_spec(&self) -> CoreCcsSpec { CoreCcsSpec::chip8_standard() }
}
```

### Developer Decision Flowchart for Adding an Opcode

When a developer adds a new opcode, ask:

1. Can it reuse an existing OpcodeClassId? (Same query shape, effect shape, sublookup budget)
2. Can it reuse an existing family's table shape?
3. Does it only change the class-local selector bits or collation polynomial row?
4. Does it introduce a genuinely new bank or effect shape?

Only if the answer to 1-3 is "no" should it create new columns.

### What Stays Fixed vs What Becomes Dynamic

| Fixed (proof kernel)                | Dynamic (from VmSpec)                 |
|-------------------------------------|---------------------------------------|
| 7-stage sumcheck structure          | Instance count per stage (from banks) |
| Challenge propagation pattern       | State field count and widths          |
| Opening accumulator threading       | Bank count and kinds                  |
| Bridge export contract              | Opcode class count and shapes         |
| Pi_CCS -> Pi_RLC -> Pi_DEC         | Kernel slot count (N, not 35)         |
| Ajtai commitment mechanics          | Lookup table set                      |
| SumcheckStage trait interface       | Column count (from opcode classes)    |
| Transcript schedule                 | Frontier carrier count (from banks)   |
| Stage-local import/export meaning   | Support reduction set (from families) |

---

## Appendix D: What This Spec Replaces

The attic'd Architecture.spec.md organized by conceptual layers:
- paper-core folding, instruction lookup, memory sidecar, time/opening reduction,
  proof-data boundary, orchestration, frontends, Rust-only strengthenings

Problems with that approach:
1. Never mentioned the 8-stage sequential pipeline.
2. Conflated Twist/Shout with Jolt stages. Twist and Shout are subinstance families
   distributed across stages 2-7, not independent layers.
3. Misplaced the opening proof as a "time/opening reduction" layer.
4. Ignored the batched sumcheck structure that defines each stage.

This spec fixes those problems by organizing around the actual execution pipeline:
stages as the unit of composition, subinstances as stage-local families, the bridge as the
semantic boundary, and neo-reductions as a direct dependency.
