# jolt-stages-specs/specs/JoltStage4.spec.md
# Stage 4 Specification Draft

## Status

Draft. This document captures the **normative protocol shape** of Jolt Stage 4 for the upstream
`a16z/jolt` `main` revision fetched during this session.

As with the retargeted Stage 1 and Stage 2 drafts, this document distinguishes:

- the clear path, where batched-sumcheck claims, round polynomials, and exported openings are
  absorbed directly into the transcript
- the backend-instantiated zk path, where those objects are bound by the active backend profile

SuperNEO profile note.

- This stage specification fixes semantic claims, imported claims, challenge derivations,
  normalized opening points, and the canonical exported opening stream.
- Under the SuperNEO profile, imported and exported Stage 4 openings are evaluations against the
  shared Ajtai-committed frontend witness surface established before Stage 1.
- Pedersen commitments, BlindFold objects, and `output_claims_coms` belong to a legacy backend
  profile and are not normative for SuperNEO.
- Semantic machine-word values may be reconstructed views over bounded witness encodings under the
  SuperNEO profile.

## Summary

- Defines the register read/write checking and RAM value checking layer.
- Uses Stage 3 register claims and Stage 2 RAM claims to bind them to new normalized Stage 4
  points for register and RAM semantics.
- Introduces and exports the key increment and selector objects needed later, especially `RdInc`,
  `RamInc`, register address selectors, and RAM address selectors.
- Handles the optional advice pre-accumulation path that contributes to the RAM-value side of the
  protocol.

Stage 4 is a single batched sumcheck composed of two subinstances:

- RegistersReadWriteChecking
- RamValCheck

This document fixes the canonical imported claims, optional advice-opening pre-accumulation,
batch order, round layout, local opening-point normalization, exported claims, proof shape, and
conformance conditions for that stage.

## 1. Scope

Stage 4 has three purposes:

1. reduce Stage 3 register-value claims into a register address-cycle opening point that is
   consistent with register read/write semantics
2. bind Stage 2 RAM value claims to a new Stage 4 RAM cycle point while reusing the aligned Stage 2
   RAM address point
3. export the register and RAM increment/address claims needed by later stages and by the bridge
   export contract

At a high level, Stage 4 takes prior virtual claims from Stage 2 and Stage 3 and produces:

```text
- register value/address openings at a Stage 4 register address-cycle point
- a committed RdInc opening at the Stage 4 register cycle point
- a RAM write-address opening at a Stage 4 RAM address-cycle point
- a committed RamInc opening at the Stage 4 RAM cycle point
```

Stage 4 introduces no new bytecode or instruction-lookups claims. Its purpose is to bridge:

- Stage 3 register-claim reductions
- Stage 2 RAM value / RAM output alignment
- Stage 6 increment reduction and bridge export

## 2. Imported Objects

Let:

```text
T      = padded trace length = 2^n
K_ram  = RAM address domain size
K_reg  = REGISTER_COUNT
m      = log_2(K_reg)
p1_reg = registers_rw_phase1_num_rounds
p2_reg = registers_rw_phase2_num_rounds
```

Stage 4 imports:

```text
Stage 2 virtual openings
Stage 3 virtual openings
the shared Ajtai-committed frontend witness surface
ReadWriteConfig
initial RAM state
program I/O memory layout
optional trusted/untrusted advice commitments or evaluations
transcript state at Stage 4 entry
```

The imported claims are interpreted as evaluations of the shared Ajtai-committed frontend witness
surface, while any advice commitment path remains machine-specific and additional to that shared
surface.

The Stage 4 batch-wide maximum round count is:

```text
R_max = m + n
```

## 3. Canonical Stage 4 Decomposition

Stage 4 consists of one batched sumcheck with the following canonical subinstance order:

```text
I1 RegistersReadWriteChecking
I2 RamValCheck
```

This order is normative. It determines:

- the order of appended `sumcheck_claim` values
- the order of sampled batching coefficients
- the order of the canonical Stage 4 opening block at stage end

The canonical per-instance round counts are:

```text
I1 RegistersReadWriteChecking : m + n rounds
I2 RamValCheck               : n rounds
```

Therefore the canonical global round offsets are:

```text
round_offset(I1) = 0
round_offset(I2) = m
```

Equivalently:

- `RegistersReadWriteChecking` is active in all Stage 4 global rounds
- `RamValCheck` is active only in the final `n` global rounds
- the first `m` global rounds are dummy constant rounds for `RamValCheck`

## 4. Advice Pre-Accumulation Contract

Before sampling the `RamValCheck` batching challenge, Stage 4 may enqueue up to two optional
advice openings in the opening accumulator under:

```text
SumcheckId::RamValCheck
```

These advice openings are not Stage 4 subinstances. They are pre-accumulated openings used to
define the full initial RAM evaluation seen by `RamValCheck`.

Under the SuperNEO profile, any advice quantity queued under `SumcheckId::RamValCheck` MUST be
classified as exactly one of:

```text
- a leaf-bounded advice witness already inside the declared bounded advice-family alphabet, or
- a transient imported semantic claim that is not re-committed until it has been converted into the declared advice-family carrier from ZkVmBridge.Frontier.spec.md
```

A Stage 4 implementation is non-conformant if it treats an unbounded advice scalar as an
Ajtai-committed leaf witness before that carrier conversion.

### 4.1 Aligned Stage 2 RAM Address Point

Let:

```text
r_ram_rw = opening point of VirtualPolynomial::RamVal under SumcheckId::RamReadWriteChecking
```

Split it as:

```text
r_ram_rw = [r_ram_addr_stage2 || r_ram_cycle_stage2]
```

where:

- `r_ram_addr_stage2` has length `log_2(K_ram)`
- `r_ram_cycle_stage2` has length `n`

Stage 4 uses `r_ram_addr_stage2` as the unique aligned RAM address point for:

- `RamVal` imported from `SumcheckId::RamReadWriteChecking`
- `RamValFinal` imported from `SumcheckId::RamOutputCheck`
- optional advice openings accumulated under `SumcheckId::RamValCheck`

Protocol intent is that the address point used by:

```text
VirtualPolynomial::RamVal      under SumcheckId::RamReadWriteChecking
VirtualPolynomial::RamValFinal under SumcheckId::RamOutputCheck
```

is identical. In current upstream `main`, `RamValCheck` derives `r_ram_addr_stage2` from
`RamVal @ RamReadWriteChecking` and only `debug_assert_eq!`s that `RamValFinal @ RamOutputCheck`
uses the same address point. This is an upstream invariant, not a separate release-mode verifier
rejection path.

### 4.2 Advice Opening Shapes

Define the advice-address suffix length for each advice kind by:

```text
advice_vars(kind) =
  log_2(next_power_of_two(max_configured_advice_region_size_bytes(kind) / 8))
```

That is: the configured maximum advice-region size is converted from bytes to words, rounded to a
power-of-two advice domain, and then converted to a variable count.

If an untrusted advice opening exists, Stage 4 MUST enqueue:

```text
OpeningId::UntrustedAdvice(SumcheckId::RamValCheck)
```

at the suffix of `r_ram_addr_stage2` whose length equals `advice_vars(untrusted)`.

If a trusted advice opening exists, Stage 4 MUST enqueue:

```text
OpeningId::TrustedAdvice(SumcheckId::RamValCheck)
```

at the suffix of `r_ram_addr_stage2` whose length equals `advice_vars(trusted)`.

The canonical enqueue order is:

```text
0 UntrustedAdvice(SumcheckId::RamValCheck), if present
1 TrustedAdvice(SumcheckId::RamValCheck),   if present
```

### 4.3 Initial RAM Evaluation Contract

Define:

```text
InitRamEval(r_ram_addr_stage2)
```

as the evaluation of the **full initial RAM state** at the aligned Stage 2 RAM address point,
including:

- bytecode
- public inputs
- trusted advice region contents
- untrusted advice region contents

`RamValCheck` uses this single scalar in its input claim.

An implementation MAY realize `InitRamEval` differently on the prover and verifier, but the
resulting scalar MUST be identical. In particular:

- the prover MAY evaluate a fully materialized initial RAM state
- the verifier MAY evaluate public initial RAM plus advice-region contributions derived from the
  cached advice openings

## 5. Imported Claims

### 5.1 RegistersReadWriteChecking Inputs

RegistersReadWriteChecking imports the following Stage 3 claims:

```text
From SumcheckId::RegistersClaimReduction:
  RdWriteValue
  Rs1Value
  Rs2Value

From SumcheckId::InstructionInputVirtualization:
  Rs1Value
  Rs2Value
```

It also imports:

```text
r_cycle_stage3 = the cycle opening point of RdWriteValue under SumcheckId::RegistersClaimReduction
```

The protocol requires:

```text
Rs1Value_RegistersClaimReduction = Rs1Value_InstructionInputVirtualization
Rs2Value_RegistersClaimReduction = Rs2Value_InstructionInputVirtualization
```

These imported values are expected to refer to the common Stage 3 cycle point fixed by the Stage 3
specification.

### 5.2 RamValCheck Inputs

RamValCheck imports the following Stage 2 claims:

```text
From SumcheckId::RamReadWriteChecking:
  RamVal

From SumcheckId::RamOutputCheck:
  RamValFinal
```

It also imports the aligned Stage 2 RAM opening decomposition:

```text
r_ram_rw = [r_ram_addr_stage2 || r_ram_cycle_stage2]
```

from the `RamVal` opening under `SumcheckId::RamReadWriteChecking`.

Its second imported scalar is:

```text
InitRamEval(r_ram_addr_stage2)
```

from Section 4.3.

## 6. Global Round Layout

Let the global Stage 4 round challenges be:

```text
u = [u_0, u_1, ..., u_{m+n-1}]
```

### 6.1 RegistersReadWriteChecking Local Layout

RegistersReadWriteChecking consumes the full Stage 4 challenge vector `u`.

Define the local slices:

```text
u_reg_phase1      = u[0 .. p1_reg)
u_reg_phase2      = u[p1_reg .. p1_reg + p2_reg)
u_reg_phase3_cycle =
  u[p1_reg + p2_reg .. p1_reg + p2_reg + (n - p1_reg))
u_reg_phase3_addr =
  u[p1_reg + p2_reg + (n - p1_reg) .. m + n)
```

The canonical normalized Stage 4 register opening point is:

```text
s_cycle_stage4 =
  reverse(u_reg_phase3_cycle) || reverse(u_reg_phase1)

s_addr_stage4 =
  reverse(u_reg_phase3_addr)  || reverse(u_reg_phase2)

s_stage4 = [s_addr_stage4 || s_cycle_stage4]
```

This ordering is normative.

### 6.2 RamValCheck Local Layout

RamValCheck consumes only the final `n` global challenges:

```text
u_ram = u[m .. m + n)
```

The canonical normalized Stage 4 RAM cycle point is:

```text
t_cycle_stage4 = reverse(u_ram)
```

The canonical Stage 4 RAM address-cycle point used for `RamRa` export is:

```text
t_ram_stage4 = [r_ram_addr_stage2 || t_cycle_stage4]
```

This ordering is normative.

## 7. Stage 4a: RegistersReadWriteChecking

### 7.1 Challenge Sampling

At Stage 4 entry, RegistersReadWriteChecking samples:

```text
gamma_reg_rw
```

This is the first Stage 4 randomness event.

### 7.2 Imported Input Claim

The canonical imported claim order is:

```text
0 RdWriteValue
1 Rs1Value
2 Rs2Value
```

The imported input claim is:

```text
claim_reg_rw_in =
    RdWriteValue
  + gamma_reg_rw * (Rs1Value + gamma_reg_rw * Rs2Value)
```

using the `RegistersClaimReduction` values after enforcing the equality constraints from
Section 5.1.

### 7.3 Statement

Let:

```text
RegistersVal(a, j)
Rs1Ra(a, j)
Rs2Ra(a, j)
RdWa(a, j)
RdInc(j)
```

be the register-value, read-address, write-address, and committed increment objects over:

```text
a in {0,1}^m
j in {0,1}^n
```

RegistersReadWriteChecking proves:

```text
sum_{a,j} Eq(r_cycle_stage3, j)
  * (
        RdWa(a, j) * (RegistersVal(a, j) + RdInc(j))
      + gamma_reg_rw
        * (
              Rs1Ra(a, j) * RegistersVal(a, j)
            + gamma_reg_rw * Rs2Ra(a, j) * RegistersVal(a, j)
          )
    )
  =
  claim_reg_rw_in
```

### 7.4 Verifier Acceptance Rule

At the normalized Stage 4 register opening point:

```text
s_stage4 = [s_addr_stage4 || s_cycle_stage4]
```

RegistersReadWriteChecking exports:

```text
RegistersVal
Rs1Ra
Rs2Ra
RdWa
RdInc
```

with:

- the first four objects opened at `s_stage4`
- `RdInc` opened at `s_cycle_stage4`

The verifier-computed expected output claim is:

```text
Eq(s_cycle_stage4, r_cycle_stage3)
  * (
        RdWa * (RegistersVal + RdInc)
      + gamma_reg_rw
        * (
              Rs1Ra * RegistersVal
            + gamma_reg_rw * Rs2Ra * RegistersVal
          )
    )
```

### 7.5 Export Order

RegistersReadWriteChecking appends exported `opening_claim` values in the following canonical
order:

```text
0 VirtualPolynomial::RegistersVal
1 VirtualPolynomial::Rs1Ra
2 VirtualPolynomial::Rs2Ra
3 VirtualPolynomial::RdWa
4 CommittedPolynomial::RdInc
```

All five exports are recorded under:

```text
SumcheckId::RegistersReadWriteChecking
```

with opening points:

```text
RegistersVal, Rs1Ra, Rs2Ra, RdWa : s_stage4
RdInc                            : s_cycle_stage4
```

## 8. Stage 4b: RamValCheck

### 8.1 Challenge Sampling

After optional advice openings are enqueued, Stage 4 performs explicit domain separation:

```text
append_bytes("ram_val_check_gamma", [])
```

and then samples:

```text
gamma_ram_val
```

This is the second and final Stage 4 randomness event before `sumcheck_claim` appends.

### 8.2 Imported Input Claim

The canonical imported claim order is:

```text
0 RamVal
1 RamValFinal
2 InitRamEval(r_ram_addr_stage2)
```

The imported input claim is:

```text
claim_ram_val_in =
    (RamVal      - InitRamEval(r_ram_addr_stage2))
  + gamma_ram_val
    * (RamValFinal - InitRamEval(r_ram_addr_stage2))
```

### 8.3 Statement

Let:

```text
RamInc(j)
RamRa(r_ram_addr_stage2, j)
LT(j, r_ram_cycle_stage2)
```

denote:

- the committed RAM increment polynomial over cycle variables
- the RAM write-address indicator evaluated at the aligned Stage 2 RAM address point
- the multilinear less-than relation used for RAM value accumulation

RamValCheck proves:

```text
sum_j RamInc(j)
     * RamRa(r_ram_addr_stage2, j)
     * (LT(j, r_ram_cycle_stage2) + gamma_ram_val)
  =
  claim_ram_val_in
```

where the sum ranges over:

```text
j in {0,1}^n
```

### 8.4 Verifier Acceptance Rule

At the normalized Stage 4 RAM cycle point `t_cycle_stage4`, RamValCheck exports:

```text
VirtualPolynomial::RamRa
CommittedPolynomial::RamInc
```

with opening points:

```text
RamRa  : t_ram_stage4   = [r_ram_addr_stage2 || t_cycle_stage4]
RamInc : t_cycle_stage4
```

The verifier-computed expected output claim is:

```text
RamInc(t_cycle_stage4)
  * RamRa(r_ram_addr_stage2, t_cycle_stage4)
  * (LT(t_cycle_stage4, r_ram_cycle_stage2) + gamma_ram_val)
```

### 8.5 Export Order

RamValCheck appends exported `opening_claim` values in the following canonical order:

```text
0 VirtualPolynomial::RamRa
1 CommittedPolynomial::RamInc
```

Both exports are recorded under:

```text
SumcheckId::RamValCheck
```

### 8.6 Front-Loaded Batch Behavior

Because RamValCheck has only `n` rounds while the Stage 4 batch has `m + n` rounds, Stage 4 uses
front-loaded batching with:

```text
round_offset(RamValCheck) = m
```

This means:

- the first `m` global rounds are dummy constant rounds for RamValCheck
- the RamValCheck local challenge vector is the suffix `u[m .. m+n)`
- its input claim is scaled by `2^m` inside the batched-sumcheck combination

This behavior is normative.

## 9. Batched Sumcheck Rules

Stage 4 runs one batched sumcheck over the two subinstances from Section 3.

The canonical per-instance parameters are:

```text
I1 RegistersReadWriteChecking : degree = 3, rounds = m + n
I2 RamValCheck               : degree = 3, rounds = n
```

The canonical `sumcheck_claim` append order is:

```text
0 claim_reg_rw_in
1 claim_ram_val_in
```

The canonical batching-coefficient order is:

```text
0 beta_reg_rw
1 beta_ram_val
```

## 10. Export Set

At the end of Stage 4, the accumulator MUST contain the following openings, in the exact pending
claim order shown below:

```text
Advice pre-accumulation:
  0 UntrustedAdvice(SumcheckId::RamValCheck), if present
  1 TrustedAdvice(SumcheckId::RamValCheck),   if present

RegistersReadWriteChecking:
  next VirtualPolynomial::RegistersVal
  next VirtualPolynomial::Rs1Ra
  next VirtualPolynomial::Rs2Ra
  next VirtualPolynomial::RdWa
  next CommittedPolynomial::RdInc

RamValCheck:
  next VirtualPolynomial::RamRa
  next CommittedPolynomial::RamInc
```

The associated opening points are:

```text
UntrustedAdvice(SumcheckId::RamValCheck) -> suffix of r_ram_addr_stage2 of length advice_vars(untrusted)
TrustedAdvice(SumcheckId::RamValCheck)   -> suffix of r_ram_addr_stage2 of length advice_vars(trusted)

VirtualPolynomial::RegistersVal  -> s_stage4
VirtualPolynomial::Rs1Ra         -> s_stage4
VirtualPolynomial::Rs2Ra         -> s_stage4
VirtualPolynomial::RdWa          -> s_stage4
CommittedPolynomial::RdInc       -> s_cycle_stage4

VirtualPolynomial::RamRa         -> t_ram_stage4
CommittedPolynomial::RamInc      -> t_cycle_stage4
```

## 11. Proof Shape

The Stage 4 proof contribution consists of exactly one proof object:

```text
stage4_sumcheck_proof : SumcheckInstanceProof
```

Stage 4 has no uni-skip round and no stage-local opening proof.

In the clear path:

- `stage4_sumcheck_proof` contains the clear round-polynomial data for the batched sumcheck
- the advice openings pre-accumulated under `SumcheckId::RamValCheck` are flushed only after the
  batched sumcheck finishes and after Stage 4 output openings are cached
- the resulting clear-path opening-claims stream contains:
  optional `UntrustedAdvice`, optional `TrustedAdvice`, then the seven Stage 4 exports from
  Section 10

In the backend-instantiated zk path:

- `stage4_sumcheck_proof` is the backend proof object for the canonical Stage 4 batched relation
- no clear `sumcheck_claim` scalars are required before batching coefficients are derived
- the advice pre-accumulation contract still occurs before `ram_val_check_gamma` is sampled
- the canonical Stage 4 output block is bound according to the active backend profile
- any Pedersen- or BlindFold-specific realization is a legacy-backend detail only

## 12. Transcript Schedule

Relative to the transcript state at Stage 4 entry, Stage 4 MUST perform:

```text
1. sample gamma_reg_rw

2. if present, enqueue UntrustedAdvice(SumcheckId::RamValCheck) in the opening accumulator
3. if present, enqueue TrustedAdvice(SumcheckId::RamValCheck) in the opening accumulator

4. append_bytes("ram_val_check_gamma", [])
5. sample gamma_ram_val
```

After those stage-local events, Stage 4 MUST use the standard batched-sumcheck transcript surface
for the canonical instance order from Section 3.

In the clear path:

```text
6. append "sumcheck_claim" for RegistersReadWriteChecking
7. append "sumcheck_claim" for RamValCheck

8. sample two batching coefficients in the same order:
   [beta_reg_rw, beta_ram_val]

9. for each global round g in 0..m+n-1:
   append "sumcheck_poly"
   sample u_g

10. flush Stage 4 pending `opening_claim` values in the exact order from Section 10
```

In the backend-instantiated zk path:

```text
6. sample two batching coefficients in the same order:
   [beta_reg_rw, beta_ram_val]

7. for each global round g in 0..m+n-1:
   invoke the backend round flow for the same canonical batch order
   sample u_g

8. bind the canonical Stage 4 opening block from Section 10 according to the active backend profile
```

These surfaces describe alternative stage-level realizations of the same Stage 4 algebra.
Under the SuperNEO profile, this file makes the Stage 4 algebraic relation, challenge schedule,
normalized opening points, and canonical export order normative; the backend proof realization is
governed instead by `ZkVmCeBridge.spec.md`,
[ZkVmBridge.CurrentStep.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.CurrentStep.spec.md),
[ZkVmBridge.Frontier.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.Frontier.spec.md),
and
[ZkVmReduction.SuperNeoAjtai.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai.spec.md).

## 13. Conformance Conditions

Two Stage 4 implementations are conformant only if they agree on all of the following:

```text
- the Stage 4 subinstance batch order
- the existence and order of optional advice-opening pre-accumulation
- the fact that advice openings are enqueued before `ram_val_check_gamma` but emitted or committed
  only at stage end
- the aligned Stage 2 RAM address point as an upstream invariant shared by RamVal, RamValFinal,
  and Stage 4 advice openings
- the advice-opening suffix lengths derived from configured maximum advice-region sizes
- the definition of InitRamEval(r_ram_addr_stage2)
- the explicit transcript domain-separation event append_bytes("ram_val_check_gamma", [])
- the RegistersReadWriteChecking imported-claim order [RdWriteValue, Rs1Value, Rs2Value]
- the RegistersReadWriteChecking equality requirements against InstructionInputVirtualization for Rs1Value and Rs2Value
- the RegistersReadWriteChecking normalized opening-point layout from Section 6.1
- the RegistersReadWriteChecking verifier equation from Section 7.4
- the RamValCheck imported-claim order and input-claim formula
- the RamValCheck normalized opening-point layout from Section 6.2
- the RamValCheck use of the aligned Stage 2 RAM address point
- the RamValCheck verifier equation from Section 8.4
- the front-loaded batch offset round_offset(RamValCheck) = m
- the aggregate exported-opening append order from Section 10
- the Stage 4 transcript schedule from Section 12
```

Without these fixed points, two implementations can both be strategically similar while producing
incompatible Stage 4 proofs.

## 14. Non-Normative Implementation Anchors

- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/prover.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/verifier.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/registers/read_write_checking.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/ram/val_check.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/ram/mod.rs`

# jolt-stages-specs/specs/JoltStage5.spec.md
# Stage 5 Specification Draft

## Status

Draft. This document captures the **normative protocol shape** of Jolt Stage 5 for the upstream
`a16z/jolt` `main` revision fetched during this session.

As with the retargeted Stage 1 and Stage 2 drafts, this document distinguishes:

- the clear path, where batched-sumcheck claims, round polynomials, and exported openings are
  absorbed directly into the transcript
- the backend-instantiated zk path, where those objects are bound by the active backend profile

SuperNEO profile note.

- This stage specification fixes semantic claims, imported claims, challenge derivations,
  normalized opening points, and the canonical exported opening stream.
- Under the SuperNEO profile, imported and exported Stage 5 openings are evaluations against the
  shared Ajtai-committed frontend witness surface established before Stage 1.
- Pedersen commitments, BlindFold objects, and `output_claims_coms` belong to a legacy backend
  profile and are not normative for SuperNEO.
- Semantic machine-word values may be reconstructed views over bounded witness encodings under the
  SuperNEO profile.

## Summary

- Defines the instruction lookup read/RAF, RAM RA reduction, and register value evaluation layer.
- Reduces instruction-lookup consistency to a new Stage 5 lookup-address/cycle point and exports
  lookup-table flags, `InstructionRa(i)`, and `InstructionRafFlag`.
- Collapses the multiple prior RAM RA claims into a single reduced `RamRa` claim at a common Stage
  5 cycle point.
- Carries the register-value path forward by exporting `RdInc` and `RdWa` at Stage-5-normalized
  points.

Stage 5 is a single batched sumcheck composed of three subinstances:

- InstructionReadRaf
- RamRaClaimReduction
- RegistersValEvaluation

This document fixes the canonical imported claims, batch order, round layout, local opening-point
normalization, exported claims, proof shape, and conformance conditions for that stage.

## 1. Scope

Stage 5 has three purposes:

1. reduce instruction-lookup read/RAF consistency to a new Stage 5 lookup address-cycle point
2. consolidate the three prior RAM RA claims into a single RAM RA claim at a common Stage 5 cycle
   point
3. reduce the Stage 4 register-value claim to a Stage 5 cycle point together with the matching
   `RdWa` and `RdInc` openings

At a high level, Stage 5 takes prior virtual and committed claims from Stage 2 and Stage 4 and
produces:

```text
- instruction lookup-table flag openings at a Stage 5 cycle point
- instruction virtual-RA openings at Stage 5 lookup-address chunk points
- a Stage 5 instruction RAF-selector opening
- a reduced RAM RA opening at the aligned RAM address and the Stage 5 cycle point
- a committed RdInc opening at the Stage 5 cycle point
- a reduced RdWa opening at the Stage 4 register address and the Stage 5 cycle point
```

Stage 5 is the bridge between:

- Stage 2 instruction/RAM openings
- Stage 4 register/RAM value openings
- Stage 6 bytecode and RAM-address virtualization

## 2. Imported Objects

Let:

```text
T             = padded trace length = 2^n
LOG_K_lookup  = 2 * XLEN
K_lookup      = 2^LOG_K_lookup
K_reg         = REGISTER_COUNT
m_reg         = log_2(K_reg)
c_lookup      = lookups_ra_virtual_log_k_chunk
d_lookup      = LOG_K_lookup / c_lookup
N_tables      = number of lookup tables in the canonical lookup-table catalog
```

Stage 5 imports:

```text
Stage 2 virtual openings
Stage 4 virtual openings
the shared Ajtai-committed frontend witness surface
OneHotParams
canonical lookup-table catalog
fixed lookup-address polynomials:
  LeftOperand
  RightOperand
  Identity
transcript state at Stage 5 entry
```

The imported claims are interpreted as evaluations of the shared Ajtai-committed frontend witness
surface, not as free-standing uncommitted scalars.

The Stage 5 batch-wide maximum round count is:

```text
R_max = LOG_K_lookup + n
```

## 3. Canonical Stage 5 Decomposition

Stage 5 consists of one batched sumcheck with the following canonical subinstance order:

```text
I1 InstructionReadRaf
I2 RamRaClaimReduction
I3 RegistersValEvaluation
```

This order is normative. It determines:

- the order of appended `sumcheck_claim` values
- the order of sampled batching coefficients
- the order of appended exported `opening_claim` values at the end of Stage 5

The canonical per-instance round counts are:

```text
I1 InstructionReadRaf    : LOG_K_lookup + n rounds
I2 RamRaClaimReduction   : n rounds
I3 RegistersValEvaluation: n rounds
```

Therefore the canonical global round offsets are:

```text
round_offset(I1) = 0
round_offset(I2) = LOG_K_lookup
round_offset(I3) = LOG_K_lookup
```

Equivalently:

- `InstructionReadRaf` is active in all Stage 5 global rounds
- `RamRaClaimReduction` and `RegistersValEvaluation` are active only in the final `n` global rounds
- the first `LOG_K_lookup` global rounds are dummy constant rounds for `RamRaClaimReduction` and
  `RegistersValEvaluation`

## 4. Global Round Layout

Let the global Stage 5 round challenges be:

```text
u = [u_0, u_1, ..., u_{LOG_K_lookup + n - 1}]
```

Define the canonical Stage 5 lookup-address prefix:

```text
r_lookup_addr_stage5 = [u_0, u_1, ..., u_{LOG_K_lookup - 1}]
```

This address prefix is **not reversed**.

Define the canonical Stage 5 cycle point:

```text
r_cycle_stage5 =
  reverse([u_{LOG_K_lookup}, ..., u_{LOG_K_lookup + n - 1}])
```

This cycle point is shared by all three Stage 5 subinstances.

### 4.1 InstructionReadRaf Local Opening Point

The canonical Stage 5 instruction opening point is:

```text
r_instr_stage5 = [r_lookup_addr_stage5 || r_cycle_stage5]
```

Split the lookup-address prefix into contiguous chunks in canonical order:

```text
r_lookup_addr_stage5 = [A_0 || A_1 || ... || A_{d_lookup-1}]
```

where each chunk `A_i` has length `c_lookup`.

The canonical opening point for `InstructionRa(i)` is:

```text
r_instr_ra_i_stage5 = [A_i || r_cycle_stage5]
```

### 4.2 RamRaClaimReduction Local Opening Point

Let the aligned RAM address imported from prior stages be:

```text
r_ram_addr_aligned
```

The canonical Stage 5 reduced RAM RA opening point is:

```text
r_ram_stage5 = [r_ram_addr_aligned || r_cycle_stage5]
```

### 4.3 RegistersValEvaluation Local Opening Point

Let the Stage 4 register opening point imported from `RegistersVal` be:

```text
r_reg_stage4 = [r_reg_addr_stage4 || r_reg_cycle_stage4]
```

The canonical Stage 5 reduced register write-address opening point is:

```text
r_reg_stage5 = [r_reg_addr_stage4 || r_cycle_stage5]
```

The canonical Stage 5 committed increment opening point is just:

```text
r_cycle_stage5
```

## 5. Imported Claims

### 5.1 InstructionReadRaf Inputs

InstructionReadRaf imports:

```text
From SumcheckId::InstructionClaimReduction:
  LookupOutput
  LeftLookupOperand
  RightLookupOperand

From SumcheckId::SpartanProductVirtualization:
  LookupOutput
```

It also imports:

```text
r_cycle_instruction_reduction =
  the opening point of LookupOutput under SumcheckId::InstructionClaimReduction
```

The protocol requires:

```text
LookupOutput_InstructionClaimReduction
  = LookupOutput_SpartanProductVirtualization
```

In the clear path, this equality is checked directly before forming the Stage 5 input claim. Under
the protocol invariant above, the canonical imported claim may be written as:

```text
(1/2) * LookupOutput_InstructionClaimReduction
+ (1/2) * LookupOutput_SpartanProductVirtualization
+ gamma_lookup   * LeftLookupOperand
+ gamma_lookup^2 * RightLookupOperand
```

Under the protocol invariant above, this is equal to the clear-path input claim. A legacy Jolt
backend may realize this average through BlindFold input wiring with equal weight `1/2`. Under the
SuperNEO profile, only the averaged semantic claim above is normative here; its backend realization
is delegated to the active backend profile.

### 5.2 RamRaClaimReduction Inputs

RamRaClaimReduction imports:

```text
From SumcheckId::RamRafEvaluation:
  RamRa

From SumcheckId::RamReadWriteChecking:
  RamRa

From SumcheckId::RamValCheck:
  RamRa
```

Split each imported opening point as:

```text
[r_address_x || r_cycle_x]
```

for:

```text
x in {raf, rw, val}
```

Protocol intent requires:

```text
r_address_raf = r_address_rw = r_address_val
```

Define that common address point as:

```text
r_ram_addr_aligned
```

In current upstream `main`, this condition is treated as a construction invariant and is checked
with `debug_assert_eq!` during `RaReductionParams::new`; it is not a separate release-mode
verifier rejection path.

### 5.3 RegistersValEvaluation Inputs

RegistersValEvaluation imports:

```text
From SumcheckId::RegistersReadWriteChecking:
  RegistersVal
```

with imported opening point:

```text
r_reg_stage4 = [r_reg_addr_stage4 || r_reg_cycle_stage4]
```

## 6. Stage 5a: InstructionReadRaf

### 6.1 Challenge Sampling

At Stage 5 entry, InstructionReadRaf samples:

```text
gamma_lookup
gamma_lookup^2
```

where `gamma_lookup^2` is derived from the sampled `gamma_lookup`.

This is the first Stage 5 randomness event.

### 6.2 Imported Input Claim

The canonical imported claim order is:

```text
0 LookupOutput
1 LeftLookupOperand
2 RightLookupOperand
```

The imported input claim is:

```text
claim_lookup_in =
    LookupOutput
  + gamma_lookup   * LeftLookupOperand
  + gamma_lookup^2 * RightLookupOperand
```

using the `InstructionClaimReduction` values after enforcing the equality requirement from
Section 5.1.

### 6.3 Statement

Let:

```text
InstructionRa(k, j)
LookupTableValue_j(k)
InstructionRafFlag(j)
LeftOperand(k)
RightOperand(k)
Identity(k)
```

denote:

- the instruction virtual-RA selector on the lookup-address domain
- the selected fixed lookup-table value at cycle `j`
- the RAF selector at cycle `j`
- the fixed left-operand polynomial over the lookup-address domain
- the fixed right-operand polynomial over the lookup-address domain
- the fixed identity polynomial over the lookup-address domain

Define:

```text
RafValue(k, j) =
    (1 - InstructionRafFlag(j))
      * (LeftOperand(k) + gamma_lookup * RightOperand(k))
  + InstructionRafFlag(j) * gamma_lookup * Identity(k)
```

InstructionReadRaf proves:

```text
sum_{j,k}
  Eq(r_cycle_instruction_reduction, j)
  * InstructionRa(k, j)
  * (LookupTableValue_j(k) + gamma_lookup * RafValue(k, j))
  =
  claim_lookup_in
```

where:

```text
j in {0,1}^n
k in {0,1}^{LOG_K_lookup}
```

### 6.4 Verifier Acceptance Rule

At the normalized Stage 5 instruction opening point:

```text
r_instr_stage5 = [r_lookup_addr_stage5 || r_cycle_stage5]
```

the verifier reconstructs:

```text
Val_stage5 =
  sum_{i=0}^{N_tables-1}
    LookupTableFlag(i) * LookupTable_i(r_lookup_addr_stage5)

Raf_stage5 =
    (1 - InstructionRafFlag)
      * (LeftOperand(r_lookup_addr_stage5) + gamma_lookup * RightOperand(r_lookup_addr_stage5))
  + InstructionRafFlag * gamma_lookup * Identity(r_lookup_addr_stage5)

InstructionRa_stage5 =
  product_{i=0}^{d_lookup-1} InstructionRa(i)
```

The verifier-computed expected output claim is:

```text
Eq(r_cycle_instruction_reduction, r_cycle_stage5)
  * InstructionRa_stage5
  * (Val_stage5 + gamma_lookup * Raf_stage5)
```

### 6.5 Export Order

InstructionReadRaf appends exported `opening_claim` values in the following canonical order:

```text
0 .. N_tables-1:
  VirtualPolynomial::LookupTableFlag(i)
  at opening point r_cycle_stage5

N_tables .. N_tables + d_lookup - 1:
  VirtualPolynomial::InstructionRa(i)
  at opening point r_instr_ra_i_stage5

last:
  VirtualPolynomial::InstructionRafFlag
  at opening point r_cycle_stage5
```

All exports are recorded under:

```text
SumcheckId::InstructionReadRaf
```

The order of `LookupTableFlag(i)` is the canonical lookup-table catalog order.

## 7. Stage 5b: RamRaClaimReduction

### 7.1 Challenge Sampling

After `InstructionReadRaf` samples `gamma_lookup`, RamRaClaimReduction samples:

```text
gamma_ram_ra
gamma_ram_ra^2
```

where `gamma_ram_ra^2` is derived from the sampled `gamma_ram_ra`.

This is the second Stage 5 randomness event.

### 7.2 Imported Input Claim

The canonical imported claim order is:

```text
0 RamRa from SumcheckId::RamRafEvaluation
1 RamRa from SumcheckId::RamReadWriteChecking
2 RamRa from SumcheckId::RamValCheck
```

The imported input claim is:

```text
claim_ram_ra_in =
    RamRa_raf
  + gamma_ram_ra   * RamRa_rw
  + gamma_ram_ra^2 * RamRa_val
```

### 7.3 Statement

Let:

```text
RamRa(r_ram_addr_aligned, j)
```

be the RAM read/write-address selector evaluated at the aligned RAM address point. Let the three
imported cycle points be:

```text
r_cycle_raf
r_cycle_rw
r_cycle_val
```

RamRaClaimReduction proves:

```text
sum_j
  (
      Eq(r_cycle_raf, j)
    + gamma_ram_ra   * Eq(r_cycle_rw, j)
    + gamma_ram_ra^2 * Eq(r_cycle_val, j)
  )
  * RamRa(r_ram_addr_aligned, j)
  =
  claim_ram_ra_in
```

where:

```text
j in {0,1}^n
```

### 7.4 Verifier Acceptance Rule

At the normalized Stage 5 RAM opening point:

```text
r_ram_stage5 = [r_ram_addr_aligned || r_cycle_stage5]
```

RamRaClaimReduction exports:

```text
VirtualPolynomial::RamRa
```

under:

```text
SumcheckId::RamRaClaimReduction
```

The verifier-computed expected output claim is:

```text
(
    Eq(r_cycle_raf, r_cycle_stage5)
  + gamma_ram_ra   * Eq(r_cycle_rw, r_cycle_stage5)
  + gamma_ram_ra^2 * Eq(r_cycle_val, r_cycle_stage5)
)
* RamRa(r_ram_stage5)
```

### 7.5 Export Order

RamRaClaimReduction appends exactly one exported `opening_claim` value:

```text
VirtualPolynomial::RamRa
```

at:

```text
r_ram_stage5 = [r_ram_addr_aligned || r_cycle_stage5]
```

## 8. Stage 5c: RegistersValEvaluation

### 8.1 Challenge Sampling

RegistersValEvaluation samples no new transcript randomness.

### 8.2 Imported Input Claim

The imported input claim is:

```text
claim_reg_val_in = RegistersVal(r_reg_stage4)
```

That is, the Stage 4 `RegistersVal` claim is carried unchanged into this Stage 5 subinstance.

### 8.3 Statement

Let:

```text
RdInc(j)
RdWa(r_reg_addr_stage4, j)
LT(j, r_reg_cycle_stage4)
```

denote:

- the committed register increment polynomial over cycle variables
- the register write-address selector evaluated at the Stage 4 register address point
- the multilinear less-than relation against the imported Stage 4 register cycle point

RegistersValEvaluation proves:

```text
sum_j
  RdInc(j)
  * RdWa(r_reg_addr_stage4, j)
  * LT(j, r_reg_cycle_stage4)
  =
  claim_reg_val_in
```

where:

```text
j in {0,1}^n
```

### 8.4 Verifier Acceptance Rule

RegistersValEvaluation exports:

```text
CommittedPolynomial::RdInc
VirtualPolynomial::RdWa
```

with opening points:

```text
CommittedPolynomial::RdInc at r_cycle_stage5
VirtualPolynomial::RdWa    at r_reg_stage5 = [r_reg_addr_stage4 || r_cycle_stage5]
```

The verifier-computed expected output claim is:

```text
RdInc(r_cycle_stage5)
  * RdWa(r_reg_stage5)
  * LT(r_cycle_stage5, r_reg_cycle_stage4)
```

### 8.5 Export Order

RegistersValEvaluation appends exported `opening_claim` values in the following canonical order:

```text
0 CommittedPolynomial::RdInc
1 VirtualPolynomial::RdWa
```

Both exports are recorded under:

```text
SumcheckId::RegistersValEvaluation
```

## 9. Front-Loaded Batch Behavior

Because `RamRaClaimReduction` and `RegistersValEvaluation` each have only `n` rounds while the
Stage 5 batch has `LOG_K_lookup + n` rounds, Stage 5 uses front-loaded batching with:

```text
round_offset(RamRaClaimReduction)   = LOG_K_lookup
round_offset(RegistersValEvaluation) = LOG_K_lookup
```

This means:

- the first `LOG_K_lookup` global rounds are dummy constant rounds for both suffix instances
- both suffix instances use the shared local challenge vector:
  `[u_{LOG_K_lookup}, ..., u_{LOG_K_lookup + n - 1}]`
- both suffix input claims are scaled by `2^LOG_K_lookup` inside the batched-sumcheck
  combination

This behavior is normative.

## 10. Batched Sumcheck Rules

Stage 5 runs one batched sumcheck over the three subinstances from Section 3.

The canonical per-instance parameters are:

```text
I1 InstructionReadRaf     : degree = d_lookup + 2, rounds = LOG_K_lookup + n
I2 RamRaClaimReduction    : degree = 2, rounds = n
I3 RegistersValEvaluation : degree = 3, rounds = n
```

The canonical `sumcheck_claim` append order is:

```text
0 claim_lookup_in
1 claim_ram_ra_in
2 claim_reg_val_in
```

The canonical batching-coefficient order is:

```text
0 beta_lookup
1 beta_ram_ra
2 beta_reg_val
```

## 11. Export Set

At the end of Stage 5, the accumulator MUST contain the following exported openings, in the exact
append order shown below:

```text
InstructionReadRaf:
  0 .. N_tables-1:
    VirtualPolynomial::LookupTableFlag(i)
  N_tables .. N_tables + d_lookup - 1:
    VirtualPolynomial::InstructionRa(i)
  next:
    VirtualPolynomial::InstructionRafFlag

RamRaClaimReduction:
  next:
    VirtualPolynomial::RamRa

RegistersValEvaluation:
  next:
    CommittedPolynomial::RdInc
  next:
    VirtualPolynomial::RdWa
```

The associated opening points are:

```text
VirtualPolynomial::LookupTableFlag(i) -> r_cycle_stage5
VirtualPolynomial::InstructionRa(i)   -> r_instr_ra_i_stage5 = [A_i || r_cycle_stage5]
VirtualPolynomial::InstructionRafFlag -> r_cycle_stage5

VirtualPolynomial::RamRa              -> r_ram_stage5 = [r_ram_addr_aligned || r_cycle_stage5]

CommittedPolynomial::RdInc            -> r_cycle_stage5
VirtualPolynomial::RdWa               -> r_reg_stage5 = [r_reg_addr_stage4 || r_cycle_stage5]
```

## 12. Proof Shape

The Stage 5 proof contribution consists of exactly one proof object:

```text
stage5_sumcheck_proof : SumcheckInstanceProof
```

Stage 5 has no uni-skip round and no stage-local opening proof.

In the clear path:

- `stage5_sumcheck_proof` contains the clear round-polynomial data for the batched sumcheck
- the Stage 5 exported openings are absorbed directly into the global opening-claims transcript

In the backend-instantiated zk path:

- `stage5_sumcheck_proof` is the backend proof object for the canonical Stage 5 batched relation
- no clear `sumcheck_claim` scalars are required before batching coefficients are derived
- the canonical Stage 5 output block is bound according to the active backend profile
- any Pedersen- or BlindFold-specific realization is a legacy-backend detail only

## 13. Transcript Schedule

Relative to the transcript state at Stage 5 entry, Stage 5 MUST perform:

```text
1. sample gamma_lookup
2. sample gamma_ram_ra
```

After those stage-local challenges are sampled, Stage 5 MUST use the standard batched-sumcheck
transcript surface for the canonical instance order from Section 3.

In the clear path:

```text
3. append "sumcheck_claim" for InstructionReadRaf
4. append "sumcheck_claim" for RamRaClaimReduction
5. append "sumcheck_claim" for RegistersValEvaluation

6. sample three batching coefficients in the same order:
   [beta_lookup, beta_ram_ra, beta_reg_val]

7. for each global round g in 0..LOG_K_lookup + n - 1:
   append "sumcheck_poly"
   sample u_g

8. append exported Stage 5 "opening_claim" values in the exact order from Section 11
```

In the backend-instantiated zk path:

```text
3. sample three batching coefficients in the same order:
   [beta_lookup, beta_ram_ra, beta_reg_val]

4. for each global round g in 0..LOG_K_lookup + n - 1:
   invoke the backend round flow for the same canonical batch order
   sample u_g

5. bind the canonical Stage 5 exported opening block according to the active backend profile
```

These surfaces describe alternative stage-level realizations of the same Stage 5 algebra.
Under the SuperNEO profile, this file makes the Stage 5 algebraic relation, challenge schedule,
normalized opening points, and canonical export order normative; the backend proof realization is
governed instead by `ZkVmCeBridge.spec.md`,
[ZkVmBridge.CurrentStep.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.CurrentStep.spec.md),
[ZkVmBridge.Frontier.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.Frontier.spec.md),
and
[ZkVmReduction.SuperNeoAjtai.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai.spec.md).

## 14. Conformance Conditions

Two Stage 5 implementations are conformant only if they agree on all of the following:

```text
- the Stage 5 subinstance batch order
- the global round layout with a lookup-address prefix followed by a shared cycle suffix
- the fact that r_lookup_addr_stage5 is not reversed while r_cycle_stage5 is reversed
- the InstructionReadRaf imported-claim order [LookupOutput, LeftLookupOperand, RightLookupOperand]
- the requirement that LookupOutput agrees across InstructionClaimReduction and SpartanProductVirtualization
- the zk input-constraint wiring for InstructionReadRaf that weights the two LookupOutput openings
  by 1/2 and 1/2 before adding gamma-weighted operands
- the InstructionReadRaf verifier equation from Section 6.4
- the contiguous chunking of r_lookup_addr_stage5 into d_lookup chunks of size c_lookup
- the canonical lookup-table flag order given by the shared lookup-table catalog
- the RamRaClaimReduction aligned-address invariant across RamRafEvaluation, RamReadWriteChecking,
  and RamValCheck
- the RamRaClaimReduction imported-claim order and verifier equation
- the RegistersValEvaluation input-claim identity and verifier equation
- the front-loaded batch offsets for RamRaClaimReduction and RegistersValEvaluation
- the aggregate exported-opening append order from Section 11
- the Stage 5 transcript schedule from Section 13
```

Without these fixed points, two implementations can both be strategically similar while producing
incompatible Stage 5 proofs.

## 15. Non-Normative Implementation Anchors

- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/prover.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/verifier.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/instruction_lookups/read_raf_checking.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/claim_reductions/ram_ra.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/registers/val_evaluation.rs`

# jolt-stages-specs/specs/JoltStage7.spec.md
# Stage 7 Specification Draft

## Status

Draft. This document captures the **normative protocol shape** of Jolt Stage 7 for the upstream
`a16z/jolt` `main` revision fetched during this session.

As with the retargeted Stage 1 and Stage 2 drafts, this document distinguishes:

- the clear path, where batched-sumcheck claims, round polynomials, and exported openings are
  absorbed directly into the transcript
- the backend-instantiated zk path, where those objects are bound by the active backend profile

SuperNEO profile note.

- This stage specification fixes semantic claims, imported claims, challenge derivations,
  normalized opening points, and the canonical exported opening stream.
- Under the SuperNEO profile, imported and exported Stage 7 openings are evaluations against the
  shared Ajtai-committed frontend witness surface established before Stage 1.
- Pedersen commitments, BlindFold objects, and any Dory final-opening ABI belong to a legacy
  backend profile and are not normative for SuperNEO.

## Summary

- Defines the final address-phase reduction layer before bridge export.
- Collapses all committed RA families onto one shared unified address point while preserving the
  common cycle point from Stage 6.
- Finishes the remaining advice address-phase reduction when advice still has unbound address
  variables.
- Exports the final aligned frontier openings that feed the bridge: unified `InstructionRa`,
  `BytecodeRa`, `RamRa`, and final advice openings when present.

Stage 7 is a single batched sumcheck with one mandatory subinstance and up to two optional
subinstances:

- HammingWeightClaimReduction
- AdviceClaimReduction(Trusted, AddressPhase), if trusted advice exists and still has unbound address variables
- AdviceClaimReduction(Untrusted, AddressPhase), if untrusted advice exists and still has unbound address variables

This document fixes the canonical batch order, imported claims, shared round geometry, fused
HammingWeight relation, optional advice address-phase behavior, exported openings, proof shape, and
conformance conditions for that stage.

## 1. Scope

Stage 7 has two purposes:

1. collapse every committed RA polynomial family to a **single unified opening point**
   `[r_address_stage7 || r_cycle_stage6]`
2. optionally finish the second half of advice reduction by binding the remaining
   address-derived advice coordinates

At a high level, Stage 7 takes the committed RA openings created in Stage 6 and produces:

```text
- one committed opening per InstructionRa(i), BytecodeRa(i), and RamRa(i)
  at the unified Stage 7 point [r_address_stage7 || r_cycle_stage6]
- optional final TrustedAdvice and UntrustedAdvice openings under SumcheckId::AdviceClaimReduction
```

Stage 7 is the final frontend reduction stage before bridge export. After Stage 7:

- all sparse RA claims are aligned to one common main frontier point component
- all advice claims are either already finalized or remain absent
- the frontend has the terminal address and cycle data needed for bridge export into current-step
  CCS/MCS witnesses and carried CE-family witnesses

Stage 7 does not hand off to a Dory-native final opening ABI. It hands off to the bridge export
contract defined in `ZkVmCeBridge.spec.md`.

The Stage 7 handoff is complete only once the verifier-reconstructible public bridge view fixed by
`ZkVmCeBridge.spec.md` is determined. Stage 7 does not authorize any alternative public export
view.

## 2. Imported Objects

Let:

```text
log_k_chunk  = one-hot address chunk size in bits
d_instr      = number of committed InstructionRa polynomials
d_bytecode   = number of committed BytecodeRa polynomials
d_ram        = number of committed RamRa polynomials
N_ra         = d_instr + d_bytecode + d_ram
```

Stage 7 imports:

```text
Stage 6 committed RA openings
Stage 6 RamHammingWeight opening
optional advice cycle-phase intermediate openings from Stage 6
the shared Ajtai-committed frontend witness surface
OneHotParams
AdviceEmbeddingLayout and advice-family dimensions from the bridge family contract
transcript state at Stage 7 entry
```

The imported claims are interpreted as evaluations of the shared Ajtai-committed frontend witness
surface, with Stage 7 only changing the normalized address/cycle geometry of those claims.

The canonical committed RA polynomial order is:

```text
0 .. d_instr-1:
  CommittedPolynomial::InstructionRa(i)

d_instr .. d_instr + d_bytecode - 1:
  CommittedPolynomial::BytecodeRa(i)

remaining:
  CommittedPolynomial::RamRa(i)
```

This order is normative for:

- HammingWeightClaimReduction batching weights
- imported HammingWeight / Booleanity / Virtualization claims
- exported openings under `SumcheckId::HammingWeightClaimReduction`

## 3. Canonical Stage 7 Decomposition

Stage 7 consists of one batched sumcheck with the following canonical instance order:

```text
I1 HammingWeightClaimReduction
I2 AdviceClaimReduction(Trusted, AddressPhase),   if present
I3 AdviceClaimReduction(Untrusted, AddressPhase), if present
```

An advice address-phase instance is present if and only if:

```text
num_address_phase_rounds(kind) > 0
```

for that `kind ∈ {Trusted, Untrusted}`.

If:

```text
num_address_phase_rounds(kind) = 0
```

then Stage 7 MUST NOT include that advice instance. In that case, the final advice opening was
already exported by Stage 6.

## 4. Global Round Layout

Let:

```text
n_addr(kind) = num_address_phase_rounds(kind)
```

for each present advice kind. The Stage 7 batch-wide maximum round count is:

```text
R_max = max(log_k_chunk, n_addr(Trusted if present), n_addr(Untrusted if present))
```

Let the global Stage 7 challenges be:

```text
v = [v_0, v_1, ..., v_{R_max - 1}]
```

All Stage 7 instances use the default front-loaded offset:

```text
round_offset(instance) = 0
```

Therefore:

- HammingWeightClaimReduction consumes the prefix `v[0 .. log_k_chunk)`
- each advice address-phase instance consumes the prefix `v[0 .. n_addr(kind))`
- any remaining rounds for a shorter instance are dummy trailing rounds handled by the standard
  batched-sumcheck scaling rule

Define the canonical Stage 7 address point:

```text
v_addr = v[0 .. log_k_chunk)
r_address_stage7 = reverse(v_addr)
```

This is the unified address point used for all exported RA openings.

## 5. Stage 7a: HammingWeightClaimReduction

### 5.1 Challenge Sampling

At Stage 7 entry, HammingWeightClaimReduction samples one batching scalar:

```text
gamma_hw
```

and derives:

```text
gamma_hw_powers = [1, gamma_hw, gamma_hw^2, ..., gamma_hw^(3*N_ra - 1)]
```

with the canonical per-polynomial grouping:

```text
gamma_hw^(3i)   -> HammingWeight claim for polynomial i
gamma_hw^(3i+1) -> Booleanity claim for polynomial i
gamma_hw^(3i+2) -> Virtualization claim for polynomial i
```

This is the first and only Stage 7 challenge block before the batched sumcheck transcript events.

### 5.2 Imported Claims and Opening Points

HammingWeightClaimReduction imports the shared Stage 6 Booleanity opening point:

```text
r_bool_stage6 = [r_addr_bool_stage6 || r_cycle_stage6]
```

This point is read from any committed RA opening under:

```text
SumcheckId::Booleanity
```

and determines:

```text
r_addr_bool_stage6
r_cycle_stage6
```

For each committed RA polynomial in the canonical order from Section 2, Stage 7 imports three
claims:

1. a HammingWeight claim
2. a Booleanity claim
3. a Virtualization claim

The canonical HammingWeight claim values are:

```text
InstructionRa(i): 1
BytecodeRa(i):    1
RamRa(i):         RamHammingWeight @ SumcheckId::RamHammingBooleanity
```

The canonical Booleanity claim for polynomial `P_i` is:

```text
P_i @ SumcheckId::Booleanity
```

The canonical Virtualization claim source for polynomial `P_i` is:

```text
InstructionRa(i) -> SumcheckId::InstructionRaVirtualization
BytecodeRa(i)    -> SumcheckId::BytecodeReadRaf
RamRa(i)         -> SumcheckId::RamRaVirtualization
```

For each polynomial `P_i`, let:

```text
r_addr_virt_i
```

denote the address component of its imported Stage 6 virtualization opening point.

### 5.3 Imported Input Claim

For each polynomial index `i` in canonical order, define:

```text
H_i       = imported HammingWeight claim
B_i       = imported Booleanity claim
V_i       = imported Virtualization claim
```

The imported Stage 7 input claim is:

```text
claim_hw_in =
  sum_{i=0}^{N_ra-1}
      gamma_hw^(3i)   * H_i
    + gamma_hw^(3i+1) * B_i
    + gamma_hw^(3i+2) * V_i
```

### 5.4 Pushforward Polynomials

For each committed RA polynomial `P_i(a, c)`, define its Stage 7 pushforward polynomial:

```text
G_i(a) = sum_c Eq(r_cycle_stage6, c) * P_i(a, c)
```

This is a multilinear polynomial over the address variables only.

Stage 7 uses the same `G_i` for all three imported claim types:

```text
H_i = sum_a G_i(a)
B_i = sum_a Eq(r_addr_bool_stage6, a) * G_i(a)
V_i = sum_a Eq(r_addr_virt_i, a) * G_i(a)
```

### 5.5 Statement

HammingWeightClaimReduction proves:

```text
claim_hw_in
=
sum_a
  sum_{i=0}^{N_ra-1}
    G_i(a)
    * (
        gamma_hw^(3i)
      + gamma_hw^(3i+1) * Eq(r_addr_bool_stage6, a)
      + gamma_hw^(3i+2) * Eq(r_addr_virt_i, a)
    )
```

This is the fused Stage 7 relation. It simultaneously:

- checks the HammingWeight totals
- reduces all Stage 6 Booleanity claims to the new Stage 7 address point
- reduces all Stage 6 Virtualization claims to the same Stage 7 address point

### 5.6 Verifier Acceptance Rule

At the normalized Stage 7 address point:

```text
r_address_stage7 = reverse(v[0 .. log_k_chunk))
```

let:

```text
g_i = P_i([r_address_stage7 || r_cycle_stage6])
```

denote the exported committed opening for polynomial `P_i`.

The verifier-computed expected output claim is:

```text
claim_hw_out =
  sum_{i=0}^{N_ra-1}
    g_i
    * (
        gamma_hw^(3i)
      + gamma_hw^(3i+1) * Eq(r_addr_bool_stage6, r_address_stage7)
      + gamma_hw^(3i+2) * Eq(r_addr_virt_i, r_address_stage7)
    )
```

### 5.7 Export Order

HammingWeightClaimReduction appends exported committed openings in the canonical RA order from
Section 2:

```text
InstructionRa(0 .. d_instr-1)
BytecodeRa(0 .. d_bytecode-1)
RamRa(0 .. d_ram-1)
```

All exports are recorded under:

```text
SumcheckId::HammingWeightClaimReduction
```

and all use the same full opening point:

```text
[r_address_stage7 || r_cycle_stage6]
```

This export contract is normative. The bridge family export depends on this exact point shape and
ordering.

## 6. Stage 7b: Optional AdviceClaimReduction (Address Phase)

### 6.1 Presence and Order

Stage 7 includes the trusted advice address phase if and only if:

```text
num_address_phase_rounds(Trusted) > 0
```

Stage 7 includes the untrusted advice address phase if and only if:

```text
num_address_phase_rounds(Untrusted) > 0
```

If both are present, the trusted instance MUST appear before the untrusted instance.

### 6.2 Imported Input Claim

For each present `kind ∈ {Trusted, Untrusted}`, Stage 7 imports:

```text
Advice(kind) under SumcheckId::AdviceClaimReductionCyclePhase
```

The imported Stage 7 input claim is:

```text
claim_advice_addr_in(kind)
= Advice(kind) @ SumcheckId::AdviceClaimReductionCyclePhase
```

This is the intermediate claim exported by Stage 6 after binding the cycle-derived advice
coordinates.

### 6.3 Address-Phase Round Count

For each present advice kind, let:

```text
cycle_phase_col_rounds(kind)
cycle_phase_row_rounds(kind)
advice_col_vars(kind)
advice_row_vars(kind)
```

be the same canonical objects defined by the Stage 6 advice-cycle specification.

Then the remaining Stage 7 address-phase round count is:

```text
num_address_phase_rounds(kind)
= (advice_col_vars(kind) + advice_row_vars(kind))
 - (length(cycle_phase_col_rounds(kind)) + length(cycle_phase_row_rounds(kind)))
```

This quantity is normative and determines whether the advice address phase exists in Stage 7.

### 6.4 Native Address-Phase Point Construction

For each present advice kind, let:

```text
rho_cycle_LE(kind)
```

be the little-endian vector of cycle-phase challenges already bound in Stage 6 and carried forward
into Stage 7.

Let:

```text
rho_addr_LE(kind) = v[0 .. num_address_phase_rounds(kind))
```

be the Stage 7 little-endian address-phase challenges for that advice instance.

The canonical native little-endian advice point is:

For `AdviceEmbeddingLayout::CycleMajor`:

```text
rho_advice_LE(kind) = [rho_cycle_LE(kind) || rho_addr_LE(kind)]
```

For `AdviceEmbeddingLayout::AddressMajor`:

```text
rho_advice_LE(kind) = [rho_addr_LE(kind) || rho_cycle_LE(kind)]
```

The normalized stored opening point is:

```text
r_advice_stage7(kind) = big_endian(rho_advice_LE(kind))
```

The layout name identifies only the advice-family coordinate order used by the frontend reduction.
It does not imply a Dory-style opening proof or Dory verifier ABI.

### 6.5 Gap Scaling

Define the Stage 6 internal dummy-gap length:

```text
gap_len(kind) =
  if cycle_phase_row_rounds(kind) and cycle_phase_col_rounds(kind) are both non-empty:
    cycle_phase_row_rounds(kind).start - cycle_phase_col_rounds(kind).end
  else:
    0
```

and the associated scaling factor:

```text
gap_scale(kind) = 2^(-gap_len(kind))
```

This factor is normative. It accounts for the Stage 6 cycle-phase dummy rounds traversed before
Stage 7 resumes the remaining address bindings.

### 6.6 Statement

For each present advice kind, let:

```text
Advice_kind(x)
```

be the advice polynomial over its native advice variables, and let:

```text
r_val_kind
```

be the opening point imported from `SumcheckId::RamValCheck`.

Stage 7 address phase proves:

```text
claim_advice_addr_in(kind)
=
gap_scale(kind)
  * sum_x Advice_kind(x) * Eq(r_val_kind, x)
```

where the Stage 7 rounds bind exactly the remaining address-derived coordinates of `x`.

Equivalently, after Stage 7 finishes:

```text
claim_advice_addr_out(kind)
= Advice_kind(r_advice_stage7(kind))
   * Eq(r_val_kind, r_advice_stage7(kind))
   * gap_scale(kind)
```

### 6.7 Verifier Acceptance Rule

For each present advice kind, the verifier-computed expected output claim is:

```text
claim_advice_addr_out(kind)
= Advice_kind(r_advice_stage7(kind))
   * Eq(r_val_kind, r_advice_stage7(kind))
   * gap_scale(kind)
```

The final advice opening:

```text
Advice(kind) @ SumcheckId::AdviceClaimReduction
```

is the advice claim used in that equation.

Under the SuperNEO backend profile, this final advice opening is a bridge-level family output
carried into the CCS / CE export boundary.

### 6.8 Export Order

For each present advice kind, Stage 7 appends exactly one final advice opening:

```text
Advice(kind) under SumcheckId::AdviceClaimReduction
```

at:

```text
r_advice_stage7(kind)
```

If both kinds are present, the append order is:

```text
1. TrustedAdvice
2. UntrustedAdvice
```

No `AdviceClaimReductionCyclePhase` opening is appended in Stage 7. Those intermediate claims are
Stage 6 outputs only.

## 7. Batched Sumcheck Rules

Stage 7 runs one batched sumcheck over:

```text
the mandatory HammingWeightClaimReduction instance
plus AdviceClaimReduction(Trusted, AddressPhase),   if present
plus AdviceClaimReduction(Untrusted, AddressPhase), if present
```

The canonical degree bounds are:

```text
HammingWeightClaimReduction              : 2
AdviceClaimReduction(AddressPhase, kind) : 2
```

The canonical `sumcheck_claim` append order is the instance order from Section 3.

The canonical batching-coefficient order is identical to the instance order from Section 3,
restricted to the instances that are present.

Because Stage 7 uses front-loaded batch sumcheck with all offsets equal to zero, the batched
relation scales each input claim by:

```text
2^(R_max - num_rounds(instance))
```

before applying that instance's batching coefficient.

This scaling is part of the normative Stage 7 batch semantics.

## 8. Export Set

At the end of Stage 7, the accumulator MUST contain the following Stage 7 exports in exact append
order:

```text
HammingWeightClaimReduction:
  CommittedPolynomial::InstructionRa(i) for i = 0 .. d_instr-1
  CommittedPolynomial::BytecodeRa(i)    for i = 0 .. d_bytecode-1
  CommittedPolynomial::RamRa(i)         for i = 0 .. d_ram-1

AdviceClaimReduction(Trusted, AddressPhase), if present:
  TrustedAdvice under SumcheckId::AdviceClaimReduction

AdviceClaimReduction(Untrusted, AddressPhase), if present:
  UntrustedAdvice under SumcheckId::AdviceClaimReduction
```

The associated opening points are:

```text
HammingWeightClaimReduction:
  [r_address_stage7 || r_cycle_stage6]

AdviceClaimReduction(AddressPhase, kind):
  r_advice_stage7(kind)
```

If an advice kind has no Stage 7 address-phase instance, then Stage 7 contributes no new export for
that kind; the final advice opening remains the one already cached by Stage 6.

All Stage 7 exports are bridge-facing frontier outputs. If an advice kind is finalized in Stage 6,
Stage 7 contributes no new export for that kind; in either case the stable recursive meaning is the
bridge-level family export, not a stage-local Dory opening ABI.

## 9. Proof Shape

The Stage 7 proof contribution consists of exactly one proof object:

```text
stage7_sumcheck_proof : SumcheckInstanceProof
```

Stage 7 has no uni-skip round and no stage-local opening proof.

In the clear path:

- `stage7_sumcheck_proof` contains the clear round-polynomial data for the batched sumcheck
- the Stage 7 exported openings are absorbed directly into the global opening-claims transcript

In the backend-instantiated zk path:

- `stage7_sumcheck_proof` is the backend proof object that binds the canonical Stage 7 relation and
  canonical Stage 7 outputs for the active profile
- clear claim scalars and round-polynomial messages may be replaced by backend commitments or other
  backend proof objects, depending on the active profile
- Stage 7 exported outputs remain logical stage outputs, but their stable recursive meaning is the
  bridge-level CCS / CE export contract
- no normative requirement is imposed here that the backend use Pedersen commitments, BlindFold, or
  a Dory final-opening proof

## 10. Transcript Schedule

Relative to the transcript state at Stage 7 entry, Stage 7 MUST perform:

```text
1. sample gamma_hw
```

AdviceClaimReduction contributes no additional Stage 7 challenge sampling beyond the shared batched
sumcheck transcript events.

After that stage-local challenge is sampled, Stage 7 MUST use the standard batched-sumcheck
transcript surface for the canonical instance order from Section 3.

In the clear path:

```text
2. append "sumcheck_claim" for each present instance in canonical instance order

3. sample batching coefficients in that same instance order

4. for each global round g in 0 .. R_max - 1:
   append "sumcheck_poly"
   sample v_g

5. append exported Stage 7 "opening_claim" values in the exact order from Section 8
```

In the backend-instantiated zk path:

```text
2. invoke the backend proof flow for the same canonical instance order
3. bind the blinded or encoded claim/output blocks and per-round messages according to the active
   backend profile
4. carry the resulting Stage 7 outputs forward into the bridge export contract
```

These surfaces describe alternative stage-level realizations of the same Stage 7 algebra.
Under the SuperNEO profile, this file makes the Stage 7 algebraic relation, challenge schedule,
normalized opening points, and canonical export order normative; the backend proof realization is
governed instead by `ZkVmCeBridge.spec.md`,
[ZkVmBridge.CurrentStep.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.CurrentStep.spec.md),
[ZkVmBridge.Frontier.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.Frontier.spec.md),
and
[ZkVmReduction.SuperNeoAjtai.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai.spec.md).

## 11. Conformance Conditions

Two Stage 7 implementations are conformant only if they agree on all of the following:

```text
- the canonical instance order [HammingWeight, TrustedAdvice?, UntrustedAdvice?]
- the canonical committed RA polynomial order
- the rule that advice address phase is present iff num_address_phase_rounds(kind) > 0
- the definition of H_i for InstructionRa, BytecodeRa, and RamRa
- the source of r_addr_bool_stage6 and r_cycle_stage6 from the Stage 6 Booleanity opening point
- the source of each virtualization claim and each r_addr_virt_i
- the fused HammingWeight batching schedule gamma^(3i), gamma^(3i+1), gamma^(3i+2)
- the unified Stage 7 point [r_address_stage7 || r_cycle_stage6]
- the rule that r_address_stage7 is reverse(v[0 .. log_k_chunk))
- the AdviceEmbeddingLayout-dependent native advice-point construction
- the gap_len(kind) and gap_scale(kind) definitions
- the rule that Stage 7 exports final advice openings only for advice kinds with address-phase instances
- the aggregate exported-opening append order from Section 8
- the Stage 7 transcript schedule from Section 10
- the fact that Stage 7 outputs are bridge-facing frontier semantics rather than a Dory final-opening surface
```

Without these fixed points, two implementations can both be strategically similar while producing
incompatible Stage 7 proofs.

## 12. Non-Normative Implementation Anchors

- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/prover.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/verifier.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/claim_reductions/hamming_weight.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/claim_reductions/advice.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/subprotocols/sumcheck.rs`

# jolt-stages-specs/specs/JoltStage6.spec.md
# Stage 6 Specification Draft

## Status

Draft. This document fixes the normative Stage 6 algebra for the upstream Jolt Stage 6 shape,
retargeted to the SuperNEO profile.

Normative here:

- imported claims and their order
- challenge derivations and round layout
- normalized opening points
- verifier equations
- canonical export order

Not normative here:

- any legacy Pedersen / BlindFold / Dory final-opening ABI details

## Summary

Stage 6 is the final cycle-phase reduction stage before Stage 7 address reduction and Stage 8
opening. It:

- converts bytecode / RAM / instruction virtual objects into committed chunk-family openings
- checks booleanity and RAM hamming booleanity
- reduces `RamInc` and `RdInc` to the common Stage 6 cycle point
- optionally performs advice cycle-phase reduction

Stage 6 is one batched sumcheck with six mandatory subinstances and up to two optional advice
subinstances:

```text
I1 BytecodeReadRaf
I2 Booleanity
I3 RamHammingBooleanity
I4 RamRaVirtualization
I5 InstructionRaVirtualization
I6 IncClaimReduction
I7 AdviceClaimReduction(Trusted),   if present
I8 AdviceClaimReduction(Untrusted), if present
```

## 1. Scope

Stage 6 owns:

1. bytecode read / RAF consistency at a Stage 6 bytecode address-cycle point
2. booleanity of committed RA families at a shared Stage 6 booleanity point
3. RAM hamming-booleanity at the Stage 6 cycle point
4. RAM RA virtualization at the Stage 6 cycle point
5. instruction RA virtualization at the Stage 6 cycle point
6. `RamInc` / `RdInc` reduction to the Stage 6 cycle point
7. optional advice cycle-phase reduction

It bridges:

- virtual openings from Stages 2 through 5
- committed openings consumed by Stage 7 HammingWeight reduction
- bridge-facing frontier outputs

## 2. Imported Objects

Let:

```text
T                = padded trace length = 2^n
log_K_bytecode   = log_2(bytecode_k)
log_k_chunk      = one_hot log chunk size
a_max            = max(log_K_bytecode, log_k_chunk)
d_bytecode       = number of committed bytecode RA polynomials
d_instr_comm     = number of committed instruction RA polynomials
d_instr_virtual  = number of virtual instruction RA polynomials from Stage 5
d_ram            = number of committed RAM RA polynomials
d_bool_total     = d_instr_comm + d_bytecode + d_ram
R_max            = a_max + n
```

Stage 6 imports:

- Stage 1 through Stage 5 openings
- the shared Ajtai-committed frontend witness surface
- `OneHotParams`
- `ReadWriteConfig`-derived committed opening points
- canonical lookup-table and flag orders
- bytecode preprocessing
- optional trusted / untrusted advice openings from `SumcheckId::RamValCheck`
- `AdviceEmbeddingLayout` and advice-family dimensions
- transcript state at Stage 6 entry

## 3. Global Round Layout

Let the global Stage 6 round challenges be:

```text
u = [u_0, u_1, ..., u_{a_max + n - 1}]
```

Define the shared Stage 6 cycle suffix:

```text
u_cycle = [u_{a_max}, ..., u_{a_max + n - 1}]
r_cycle_stage6 = reverse(u_cycle)
```

This cycle point is used by:

- RamHammingBooleanity
- RamRaVirtualization
- InstructionRaVirtualization
- IncClaimReduction
- the cycle component of BytecodeReadRaf
- the cycle component of Booleanity

Bytecode prefix:

```text
u_bytecode_addr      = u[a_max - log_K_bytecode .. a_max]
r_bytecode_addr_stage6 = reverse(u_bytecode_addr)
r_bytecode_stage6      = [r_bytecode_addr_stage6 || r_cycle_stage6]
```

Booleanity prefix:

```text
u_bool_addr       = u[a_max - log_k_chunk .. a_max]
r_bool_addr_stage6 = reverse(u_bool_addr)
r_bool_stage6      = [r_bool_addr_stage6 || r_cycle_stage6]
```

Default front-loaded offsets:

```text
round_offset(BytecodeReadRaf)             = a_max - log_K_bytecode
round_offset(Booleanity)                  = a_max - log_k_chunk
round_offset(RamHammingBooleanity)        = a_max
round_offset(RamRaVirtualization)         = a_max
round_offset(InstructionRaVirtualization) = a_max
round_offset(IncClaimReduction)           = a_max
```

Optional advice-cycle instances use the custom schedule in Section 10.

## 4. Stage 6a: BytecodeReadRaf

### 4.1 Challenge Sampling

BytecodeReadRaf samples, in order:

```text
Gamma_master = challenge_scalar_powers(8)
entry_gamma  = Gamma_master[7]
alpha_1      = challenge_scalar_powers(2 + NUM_CIRCUIT_FLAGS)
alpha_2      = challenge_scalar_powers(4)
alpha_3      = challenge_scalar_powers(9)
alpha_4      = challenge_scalar_powers(3)
alpha_5      = challenge_scalar_powers(2 + N_tables)
```

### 4.2 Imported Claims

BytecodeReadRaf imports:

- Stage 1: `UnexpandedPC`, `Imm`, all `OpFlags(f)` in canonical `CircuitFlags` order, and `PC`
- Stage 2: `OpFlags(Jump)`, `InstructionFlags(Branch)`, `OpFlags(WriteLookupOutputToRD)`,
  `OpFlags(VirtualInstruction)`
- Stage 3: `Imm`, both `UnexpandedPC` claims, the canonical operand / noop / virtual / sequence
  flags, and `PC`
- Stage 4: `RdWa`, `Rs1Ra`, `Rs2Ra`
- Stage 5: `RdWa`, `InstructionRafFlag`, and all `LookupTableFlag(i)`

Required equality:

```text
UnexpandedPC_SpartanShift = UnexpandedPC_InstructionInputVirtualization
```

### 4.3 Fixed Value Families

Define five bytecode value families over the bytecode address domain:

```text
Val_1(k) =
    address(k)
  + alpha_1[1] * imm(k)
  + sum_{f in CircuitFlags order} alpha_1[f] * OpFlag_f(k)

Val_2(k) =
    alpha_2[0] * Jump(k)
  + alpha_2[1] * Branch(k)
  + alpha_2[2] * WriteLookupOutputToRD(k)
  + alpha_2[3] * VirtualInstruction(k)

Val_3(k) =
    imm(k)
  + alpha_3[1] * unexpanded_pc(k)
  + alpha_3[2] * left_operand_is_rs1(k)
  + alpha_3[3] * left_operand_is_pc(k)
  + alpha_3[4] * right_operand_is_rs2(k)
  + alpha_3[5] * right_operand_is_imm(k)
  + alpha_3[6] * is_noop(k)
  + alpha_3[7] * virtual_instruction(k)
  + alpha_3[8] * is_first_in_sequence(k)

Val_4(k) =
    alpha_4[0] * eq(rd(k), r_reg_addr_stage4)
  + alpha_4[1] * eq(rs1(k), r_reg_addr_stage4)
  + alpha_4[2] * eq(rs2(k), r_reg_addr_stage4)

Val_5(k) =
    alpha_5[0] * eq(rd(k), r_reg_addr_stage5)
  + alpha_5[1] * InstructionRafFlag(k)
  + sum_{i=0}^{N_tables-1} alpha_5[2+i] * LookupTableFlag_i(k)
```

### 4.4 Imported Input Claim

Let:

```text
rv_1, rv_2, rv_3, rv_4, rv_5
```

be the canonical scalar reductions of the Stage 1 through Stage 5 imported families under the same
`alpha_*` schedules.

Let:

```text
raf_1 = PC claim from SumcheckId::SpartanOuter
raf_3 = PC claim from SumcheckId::SpartanShift
```

Then:

```text
claim_bytecode_in =
    rv_1
  + gamma   * rv_2
  + gamma^2 * rv_3
  + gamma^3 * rv_4
  + gamma^4 * rv_5
  + gamma^5 * raf_1
  + gamma^6 * raf_3
  + entry_gamma
```

### 4.5 Statement and Acceptance

With:

```text
r_cycle_1 ... r_cycle_5
BytecodeRa(k, c)
Entry(k)
EqZero(c)
```

BytecodeReadRaf proves:

```text
sum_{c,k}
  BytecodeRa(k, c)
  * [
        Eq(r_cycle_1, c) * (Val_1(k) + gamma^5 * Identity(k))
      + gamma   * Eq(r_cycle_2, c) * Val_2(k)
      + gamma^2 * Eq(r_cycle_3, c) * (Val_3(k) + gamma^4 * Identity(k))
      + gamma^3 * Eq(r_cycle_4, c) * Val_4(k)
      + gamma^4 * Eq(r_cycle_5, c) * Val_5(k)
      + entry_gamma * Entry(k) * EqZero(c)
    ]
  =
  claim_bytecode_in
```

At:

```text
r_bytecode_stage6 = [r_bytecode_addr_stage6 || r_cycle_stage6]
```

the verifier checks:

```text
BytecodeRa_stage6 * (BytecodeVal_stage6 + Entry_stage6)
```

where `BytecodeVal_stage6`, `BytecodeRa_stage6`, and `Entry_stage6` are the obvious pointwise
specializations of the objects above.

### 4.6 Export Order

```text
CommittedPolynomial::BytecodeRa(i) for i = 0 .. d_bytecode-1
```

under:

```text
SumcheckId::BytecodeReadRaf
```

with points:

```text
[B_i || r_cycle_stage6]
```

## 5. Stage 6b: Booleanity

### 5.1 Challenge Sampling and Order

Booleanity samples:

```text
gamma_bool
```

and uses weights:

```text
[1, gamma_bool^2, gamma_bool^4, ..., gamma_bool^{2(d_bool_total-1)}]
```

Committed family order is fixed:

```text
InstructionRa*
BytecodeRa*
RamRa*
```

### 5.2 Statement and Acceptance

Base point:

```text
r_bool_addr_base  = suffix_{log_k_chunk}(r_lookup_addr_stage5)
r_bool_cycle_base = r_cycle_stage5
```

Booleanity proves:

```text
0 =
sum_{a,c}
  Eq(r_bool_addr_base, a)
  * Eq(r_bool_cycle_base, c)
  * sum_i gamma_bool^{2i} * (RA_i(a, c)^2 - RA_i(a, c))
```

At:

```text
r_bool_stage6 = [r_bool_addr_stage6 || r_cycle_stage6]
```

the verifier checks the corresponding point evaluation:

```text
Eq([r_bool_addr_base || r_bool_cycle_base], r_bool_stage6)
  * sum_i gamma_bool^{2i} * (RA_i(r_bool_stage6)^2 - RA_i(r_bool_stage6))
```

### 5.3 Export Order

All committed RA families in the canonical order above, under:

```text
SumcheckId::Booleanity
```

at:

```text
r_bool_stage6
```

## 6. Stage 6c: RamHammingBooleanity

No new challenge sampling.

Imported input claim:

```text
claim_ram_hamming_in = 0
r_cycle_stage1_outer
```

Statement:

```text
0 =
sum_c
  Eq(r_cycle_stage1_outer, c)
  * (RamHammingWeight(c)^2 - RamHammingWeight(c))
```

Verifier check at `r_cycle_stage6`:

```text
Eq(r_cycle_stage1_outer, r_cycle_stage6)
  * (RamHammingWeight(r_cycle_stage6)^2 - RamHammingWeight(r_cycle_stage6))
```

Export:

```text
VirtualPolynomial::RamHammingWeight
```

under:

```text
SumcheckId::RamHammingBooleanity
```

at:

```text
r_cycle_stage6
```

## 7. Stage 6d: RamRaVirtualization

No new challenge sampling.

Imported input:

```text
VirtualPolynomial::RamRa under SumcheckId::RamRaClaimReduction
claim_ram_ra_virtual_in = RamRa(r_ram_stage5)
r_ram_stage5 = [r_ram_addr_aligned || r_cycle_ram_stage5]
r_ram_addr_aligned = [R_0 || ... || R_{d_ram-1}]
```

Statement:

```text
sum_c
  Eq(r_cycle_ram_stage5, c)
  * product_{i=0}^{d_ram-1} RamRa_i(R_i, c)
  =
  claim_ram_ra_virtual_in
```

Verifier check at `r_cycle_stage6`:

```text
Eq(r_cycle_ram_stage5, r_cycle_stage6)
  * product_{i=0}^{d_ram-1} RamRa_i([R_i || r_cycle_stage6])
```

Export order:

```text
CommittedPolynomial::RamRa(i) for i = 0 .. d_ram-1
```

under:

```text
SumcheckId::RamRaVirtualization
```

with points:

```text
[R_i || r_cycle_stage6]
```

## 8. Stage 6e: InstructionRaVirtualization

### 8.1 Challenge Sampling

After `gamma_bool`, sample:

```text
gamma_lookup_ra_powers = challenge_scalar_powers(d_instr_virtual)
```

### 8.2 Imported Input, Statement, Acceptance

Imported virtual openings:

```text
VirtualPolynomial::InstructionRa(i) for i = 0 .. d_instr_virtual-1
under SumcheckId::InstructionReadRaf
```

with:

```text
r_lookup_addr_stage5 = [A_0 || ... || A_{d_instr_virtual-1}]
r_cycle_lookup_stage5
claim_instr_ra_virtual_in =
  sum_{i=0}^{d_instr_virtual-1} gamma_lookup_ra_powers[i] * InstructionRa_virtual_i
```

Let:

```text
n_committed_per_virtual = c_lookup / log_k_chunk
```

and group committed instruction chunks into `d_instr_virtual` consecutive batches.

Statement:

```text
sum_c
  Eq(r_cycle_lookup_stage5, c)
  * sum_{b=0}^{d_instr_virtual-1}
      gamma_lookup_ra_powers[b]
      * product_{j in batch b} InstructionRa_j(c)
  =
  claim_instr_ra_virtual_in
```

Verifier check at `r_cycle_stage6`:

```text
Eq(r_cycle_lookup_stage5, r_cycle_stage6)
  * sum_{b=0}^{d_instr_virtual-1}
      gamma_lookup_ra_powers[b]
      * product_{j in batch b} InstructionRa_j([I_j || r_cycle_stage6])
```

### 8.3 Export Order

```text
CommittedPolynomial::InstructionRa(i) for i = 0 .. d_instr_comm-1
```

under:

```text
SumcheckId::InstructionRaVirtualization
```

with points:

```text
[I_i || r_cycle_stage6]
```

## 9. Stage 6f: IncClaimReduction

### 9.1 Challenge Sampling

After instruction RA virtualization, sample:

```text
gamma_inc
gamma_inc^2
gamma_inc^3
```

### 9.2 Imported Input, Statement, Acceptance

Imports:

```text
RamInc from SumcheckId::RamReadWriteChecking
RamInc from SumcheckId::RamValCheck
RdInc  from SumcheckId::RegistersReadWriteChecking
RdInc  from SumcheckId::RegistersValEvaluation
```

at:

```text
r_cycle_ram_stage2
r_cycle_ram_stage4
r_cycle_rd_stage4
r_cycle_rd_stage5
```

Input claim:

```text
claim_inc_in =
    RamInc_stage2
  + gamma_inc   * RamInc_stage4
  + gamma_inc^2 * RdInc_stage4
  + gamma_inc^3 * RdInc_stage5
```

Statement:

```text
sum_c
  RamInc(c)
    * (Eq(r_cycle_ram_stage2, c) + gamma_inc * Eq(r_cycle_ram_stage4, c))
  + gamma_inc^2
    * RdInc(c)
    * (Eq(r_cycle_rd_stage4, c) + gamma_inc * Eq(r_cycle_rd_stage5, c))
  =
  claim_inc_in
```

Verifier check at `r_cycle_stage6`:

```text
RamInc(r_cycle_stage6)
  * (Eq(r_cycle_ram_stage2, r_cycle_stage6) + gamma_inc * Eq(r_cycle_ram_stage4, r_cycle_stage6))
  + gamma_inc^2
    * RdInc(r_cycle_stage6)
    * (Eq(r_cycle_rd_stage4, r_cycle_stage6) + gamma_inc * Eq(r_cycle_rd_stage5, r_cycle_stage6))
```

### 9.3 Export Order

```text
CommittedPolynomial::RamInc
CommittedPolynomial::RdInc
```

under:

```text
SumcheckId::IncClaimReduction
```

at:

```text
r_cycle_stage6
```

## 10. Stage 6g: Optional AdviceClaimReduction (Cycle Phase)

At most two optional instances appear, after `IncClaimReduction`, in this order:

```text
AdviceClaimReduction(Trusted)
AdviceClaimReduction(Untrusted)
```

for each present kind:

```text
claim_advice_cycle_in(kind) = Advice(kind) @ SumcheckId::RamValCheck
```

at the imported Stage 4 advice point `r_val_kind`.

Let the cycle-phase schedule depend on:

```text
log_t
log_k_chunk
main_col_vars
main_row_vars
advice_col_vars(kind)
advice_row_vars(kind)
AdviceEmbeddingLayout
```

For `CycleMajor`:

```text
cycle_phase_col_rounds = [0, min(log_t, advice_col_vars))
cycle_phase_row_rounds = [min(log_t, main_col_vars), min(log_t, main_col_vars + advice_row_vars))
```

For `AddressMajor`:

```text
cycle_phase_col_rounds = [0, advice_col_vars - log_k_chunk)
cycle_phase_row_rounds = [main_col_vars - log_k_chunk,
                          min(log_t, main_col_vars - log_k_chunk + advice_row_vars))
```

Local round count:

```text
cycle_phase_num_rounds(kind) =
  if cycle_phase_row_rounds is non-empty:
    cycle_phase_row_rounds.end - cycle_phase_col_rounds.start
  else:
    length(cycle_phase_col_rounds)
```

Global offset:

```text
round_offset(AdviceClaimReduction(kind), CyclePhase) = a_max
```

Rounds outside the active local sets are internal dummy rounds and contribute the canonical
`2^{-gap}` gap scaling.

Stage 6 always exports:

```text
Advice(kind) under SumcheckId::AdviceClaimReductionCyclePhase
```

at:

```text
r_advice_cycle_stage6(kind)
```

If:

```text
num_address_phase_rounds(kind) = 0
```

then Stage 6 also exports:

```text
Advice(kind) under SumcheckId::AdviceClaimReduction
```

at the same normalized point.

The verifier acceptance value for the cycle phase is exactly the exported intermediate claim:

```text
C_mid(kind) = Advice(kind) @ SumcheckId::AdviceClaimReductionCyclePhase
```

## 11. Batched Sumcheck Rules

Stage 6 runs one batched sumcheck over the six mandatory instances plus any present advice-cycle
instances.

Canonical degree bounds:

```text
BytecodeReadRaf             : d_bytecode + 1
Booleanity                  : 3
RamHammingBooleanity        : 3
RamRaVirtualization         : d_ram + 1
InstructionRaVirtualization : n_committed_per_virtual + 1
IncClaimReduction           : 2
AdviceClaimReduction        : 2
```

`sumcheck_claim` append order and batching-coefficient order both equal the canonical instance
order from the summary, restricted to present instances.

## 12. Export Set

Canonical append order:

```text
BytecodeReadRaf:
  BytecodeRa(i) for i = 0 .. d_bytecode-1

Booleanity:
  InstructionRa(i) for i = 0 .. d_instr_comm-1
  BytecodeRa(i)    for i = 0 .. d_bytecode-1
  RamRa(i)         for i = 0 .. d_ram-1

RamHammingBooleanity:
  RamHammingWeight

RamRaVirtualization:
  RamRa(i) for i = 0 .. d_ram-1

InstructionRaVirtualization:
  InstructionRa(i) for i = 0 .. d_instr_comm-1

IncClaimReduction:
  RamInc
  RdInc

AdviceClaimReduction(Trusted), if present:
  AdviceClaimReductionCyclePhase(Trusted)
  and AdviceClaimReduction(Trusted) iff num_address_phase_rounds = 0

AdviceClaimReduction(Untrusted), if present:
  AdviceClaimReductionCyclePhase(Untrusted)
  and AdviceClaimReduction(Untrusted) iff num_address_phase_rounds = 0
```

Associated points:

```text
BytecodeReadRaf:             [B_i || r_cycle_stage6]
Booleanity:                  r_bool_stage6
RamHammingBooleanity:        r_cycle_stage6
RamRaVirtualization:         [R_i || r_cycle_stage6]
InstructionRaVirtualization: [I_i || r_cycle_stage6]
IncClaimReduction:           r_cycle_stage6
Advice cycle phase:          r_advice_cycle_stage6(kind)
```

## 13. Proof Shape and Transcript Schedule

Stage 6 contributes exactly one proof object:

```text
stage6_sumcheck_proof : SumcheckInstanceProof
```

There is no Stage 6 uni-skip and no Stage 6-local opening proof.

Transcript schedule:

```text
1. sample Gamma_master, alpha_1, alpha_2, alpha_3, alpha_4, alpha_5
2. sample gamma_bool
3. sample gamma_lookup_ra_powers
4. sample gamma_inc
5. append "sumcheck_claim" for each present instance in canonical order
6. sample batching coefficients in the same order
7. for each global round g in 0 .. a_max + n - 1:
     append "sumcheck_poly"
     sample u_g
8. append exported Stage 6 opening claims in the exact order from Section 12
```

## 14. Conformance Conditions

Conformant Stage 6 implementations must agree on:

- the canonical instance order and optional advice insertion order
- the global layout with `a_max`-wide address prefix and shared `r_cycle_stage6`
- BytecodeReadRaf challenge sampling, including `entry_gamma`
- `alpha_2` length = 4
- bytecode value families `Val_1` through `Val_5`
- the bytecode entry term and BytecodeRa export order
- booleanity family order `[InstructionRa*, BytecodeRa*, RamRa*]`
- `r_bool_addr_base = suffix_{log_k_chunk}(r_lookup_addr_stage5)`
- RAM / instruction RA virtualization equations
- the `IncClaimReduction` imported-claim order and equation
- the advice cycle-phase schedule, offset, and export rule
- the Stage 6 export append order
- the Stage 6 transcript schedule

## 15. Non-Normative Implementation Anchors

- `external/jolt/jolt-core/src/zkvm/prover.rs`
- `external/jolt/jolt-core/src/zkvm/verifier.rs`
- `external/jolt/jolt-core/src/zkvm/bytecode/read_raf_checking.rs`
- `external/jolt/jolt-core/src/subprotocols/booleanity.rs`
- `external/jolt/jolt-core/src/zkvm/ram/hamming_booleanity.rs`
- `external/jolt/jolt-core/src/zkvm/ram/ra_virtual.rs`
- `external/jolt/jolt-core/src/zkvm/instruction_lookups/ra_virtual.rs`
- `external/jolt/jolt-core/src/zkvm/claim_reductions/increments.rs`
- `external/jolt/jolt-core/src/zkvm/claim_reductions/advice.rs`

# jolt-stages-specs/specs/JoltStage3.spec.md
# Stage 3 Specification Draft

## Status

Draft. This document captures the **normative protocol shape** of Jolt Stage 3 for the upstream
`a16z/jolt` `main` revision fetched during this session.

As with the retargeted Stage 1 and Stage 2 drafts, this document distinguishes:

- the clear path, where batched-sumcheck claims, round polynomials, and exported openings are
  absorbed directly into the transcript
- the backend-instantiated zk path, where those objects are bound by the active backend profile

SuperNEO profile note.

- This stage specification fixes semantic claims, imported claims, challenge derivations,
  normalized opening points, alias rules, and the canonical exported opening stream.
- Under the SuperNEO profile, imported and exported Stage 3 openings are evaluations against the
  shared Ajtai-committed frontend witness surface established before Stage 1.
- Pedersen commitments, BlindFold objects, and `output_claims_coms` belong to a legacy backend
  profile and are not normative for SuperNEO.

## Summary

- Defines the next-cycle/state-shift and register-claim reduction layer.
- Shifts “next” state claims from earlier stages onto a new Stage 3 cycle point so the verifier can
  compare them against the current-cycle view.
- Reconstructs `LeftInstructionInput` and `RightInstructionInput` from operand-selector flags and
  operand values instead of treating them as opaque inputs.
- Reduces register-related claims (`RdWriteValue`, `Rs1Value`, `Rs2Value`) to the common Stage 3
  cycle point and exports those reduced openings.

Stage 3 is a single batched sumcheck composed of three subinstances:

- SpartanShift
- InstructionInputVirtualization
- RegistersClaimReduction

This document fixes the canonical imported claims, subinstance order, challenge schedule,
opening-point normalization, exported claims, proof shape, and conformance conditions for
that batched stage.

## 1. Scope

Stage 3 has three purposes:

1. align next-cycle state claims from earlier stages with the current-cycle shifted trace state
2. reconstruct `LeftInstructionInput` and `RightInstructionInput` from operand-selector and operand-value openings
3. reduce register-related virtual claims to a new Stage 3 cycle point for later stages

At a high level, Stage 3 takes prior virtual claims at Stage 1 and Stage 2 opening points and
produces:

```text
- shifted cycle-state openings at a new Stage 3 cycle point
- instruction-input factor openings at the same Stage 3 cycle point
- reduced register-value openings at the same Stage 3 cycle point
```

Stage 3 operates only on **virtual polynomials**. It does not introduce new committed
polynomial openings.

## 2. Imported Objects

Let:

```text
T = padded trace length = 2^n
```

Stage 3 imports:

```text
Stage 1 virtual openings
Stage 2 virtual openings
the shared Ajtai-committed frontend witness surface
trace semantics
bytecode preprocessing
transcript state at Stage 3 entry
```

The imported claims are interpreted as evaluations of the shared Ajtai-committed frontend witness
surface, not as free-standing uncommitted scalars.

## 3. Canonical Stage 3 Decomposition

Stage 3 consists of one batched sumcheck with the following canonical subinstance order:

```text
I1 SpartanShift
I2 InstructionInputVirtualization
I3 RegistersClaimReduction
```

This order is normative. It determines:

- the order of appended `sumcheck_claim` values
- the order of sampled batching coefficients
- the logical exported-opening request order at the end of Stage 3

All three Stage 3 subinstances have:

```text
num_rounds = n = log_2(T)
```

Therefore:

```text
round_offset(I1) = 0
round_offset(I2) = 0
round_offset(I3) = 0
```

Stage 3 has no dummy leading rounds and no subinstance-specific round padding.

## 4. Common Opening-Point Convention

Let the batched Stage 3 round challenges be sampled in per-round order as:

```text
u = [u_0, u_1, ..., u_{n-1}]
```

Each Stage 3 subinstance normalizes the local round-challenge vector by reversing it:

```text
r_stage3_BE = [u_{n-1}, ..., u_1, u_0]
```

This normalized big-endian cycle point is the canonical Stage 3 exported opening point for all
three Stage 3 subinstances.

## 5. Imported Claims

### 5.1 SpartanShift Inputs

SpartanShift imports the following prior claims:

```text
From SumcheckId::SpartanOuter:
  NextUnexpandedPC
  NextPC
  NextIsVirtual
  NextIsFirstInSequence

From SumcheckId::SpartanProductVirtualization:
  NextIsNoop
```

It also imports two prior cycle opening points:

```text
r_outer_stage1   = the common cycle component of the SpartanOuter opening point
r_product_stage2 = the cycle component of the SpartanProductVirtualization opening point for NextIsNoop
```

### 5.2 InstructionInputVirtualization Inputs

InstructionInputVirtualization imports the following claims:

```text
From SumcheckId::InstructionClaimReduction:
  LeftInstructionInput
  RightInstructionInput

From SumcheckId::SpartanProductVirtualization:
  LeftInstructionInput
  RightInstructionInput
```

It also imports:

```text
r_cycle_stage2 = the SpartanProductVirtualization opening point for LeftInstructionInput
```

The protocol requires the imported instruction-input claims to agree across both sources:

```text
LeftInstructionInput_InstructionClaimReduction
  = LeftInstructionInput_SpartanProductVirtualization

RightInstructionInput_InstructionClaimReduction
  = RightInstructionInput_SpartanProductVirtualization
```

and both equalities must hold at identical opening points.

### 5.3 RegistersClaimReduction Inputs

RegistersClaimReduction imports:

```text
From SumcheckId::SpartanOuter:
  RdWriteValue
  Rs1Value
  Rs2Value
```

and the common Stage 1 outer cycle opening point:

```text
r_outer_stage1 = the common SpartanOuter cycle opening point
```

Upstream `main` seeds this point from `LookupOutput @ SpartanOuter` during parameter
construction. During verifier-side output evaluation, the equivalent cycle point may be re-read
from `RdWriteValue @ SpartanOuter`. These code paths are compatible only because current
`main` maintains the invariant that all Stage 1 SpartanOuter cycle openings share the same point.

## 6. Stage 3a: SpartanShift

### 6.1 Challenge Sampling

At Stage 3 entry, before batched-sumcheck claim appends, SpartanShift samples:

```text
gamma_shift_pows = [1, gamma_shift, gamma_shift^2, gamma_shift^3, gamma_shift^4]
```

This challenge-power vector is sampled first among all Stage 3 randomness.

### 6.2 Imported Input Claim

The canonical SpartanShift input claim is:

```text
claim_shift_in =
    NextUnexpandedPC
  + gamma_shift * NextPC
  + gamma_shift^2 * NextIsVirtual
  + gamma_shift^3 * NextIsFirstInSequence
  + gamma_shift^4 * (1 - NextIsNoop)
```

where:

- the first four claims are imported from `SumcheckId::SpartanOuter`
- `NextIsNoop` is imported from `SumcheckId::SpartanProductVirtualization`

### 6.3 Statement

Let:

```text
UnexpandedPC_shift(c)
PC_shift(c)
IsVirtual_shift(c)
IsFirstInSequence_shift(c)
IsNoop_shift(c)
```

denote the Stage 3 shifted virtual polynomials aligned so that cycle `c` represents the
next-cycle state. Let `EqPlusOne(a, b)` denote the multilinear extension of the relation
`a = b + 1`, with no wrap-around on the final cycle.

SpartanShift proves the batched identity:

```text
sum_c EqPlusOne(r_outer_stage1, c)
    * (
          UnexpandedPC_shift(c)
        + gamma_shift * PC_shift(c)
        + gamma_shift^2 * IsVirtual_shift(c)
        + gamma_shift^3 * IsFirstInSequence_shift(c)
      )
  +
  gamma_shift^4
  * sum_c EqPlusOne(r_product_stage2, c) * (1 - IsNoop_shift(c))
  =
  claim_shift_in
```

### 6.4 Verifier Acceptance Rule

Let the Stage 3 normalized opening point be `r_stage3_BE`.

SpartanShift exports the following evaluations at `r_stage3_BE`:

```text
UnexpandedPC
PC
OpFlags(VirtualInstruction)
OpFlags(IsFirstInSequence)
InstructionFlags(IsNoop)
```

The verifier-computed expected output claim is:

```text
EqPlusOne(r_outer_stage1, r_stage3_BE)
  * (
        UnexpandedPC
      + gamma_shift * PC
      + gamma_shift^2 * OpFlags(VirtualInstruction)
      + gamma_shift^3 * OpFlags(IsFirstInSequence)
    )
  +
  gamma_shift^4
  * EqPlusOne(r_product_stage2, r_stage3_BE)
  * (1 - InstructionFlags(IsNoop))
```

### 6.5 Logical Export Order

SpartanShift issues logical exported-opening requests in the following canonical order:

```text
0 UnexpandedPC
1 PC
2 OpFlags(VirtualInstruction)
3 OpFlags(IsFirstInSequence)
4 InstructionFlags(IsNoop)
```

All five exports are recorded under:

```text
SumcheckId::SpartanShift
```

at the common Stage 3 opening point `r_stage3_BE`.

## 7. Stage 3b: InstructionInputVirtualization

### 7.1 Challenge Sampling

After SpartanShift samples `gamma_shift_pows`, InstructionInputVirtualization samples:

```text
gamma_instr
```

This is the second Stage 3 randomness event.

### 7.2 Imported Input Claim

The canonical input-claim order for InstructionInputVirtualization is:

```text
0 RightInstructionInput
1 LeftInstructionInput
```

The imported input claim is:

```text
claim_instr_in = RightInstructionInput + gamma_instr * LeftInstructionInput
```

using the Stage 2 product-virtualization claims after enforcing source equality as specified in
Section 5.2.

### 7.3 Statement

Define:

```text
LeftInstructionInput_eval(c) =
    InstructionFlags(LeftOperandIsRs1Value)(c) * Rs1Value(c)
  + InstructionFlags(LeftOperandIsPC)(c)       * UnexpandedPC(c)

RightInstructionInput_eval(c) =
    InstructionFlags(RightOperandIsRs2Value)(c) * Rs2Value(c)
  + InstructionFlags(RightOperandIsImm)(c)      * Imm(c)
```

InstructionInputVirtualization proves:

```text
sum_c Eq(r_cycle_stage2, c)
  * (
        RightInstructionInput_eval(c)
      + gamma_instr * LeftInstructionInput_eval(c)
    )
  =
  claim_instr_in
```

### 7.4 Verifier Acceptance Rule

At the common Stage 3 opening point `r_stage3_BE`, the verifier reconstructs:

```text
LeftInstructionInput_eval(r_stage3_BE) =
    InstructionFlags(LeftOperandIsRs1Value) * Rs1Value
  + InstructionFlags(LeftOperandIsPC)       * UnexpandedPC

RightInstructionInput_eval(r_stage3_BE) =
    InstructionFlags(RightOperandIsRs2Value) * Rs2Value
  + InstructionFlags(RightOperandIsImm)      * Imm
```

The expected output claim is:

```text
Eq(r_stage3_BE, r_cycle_stage2)
  * (
        RightInstructionInput_eval(r_stage3_BE)
      + gamma_instr * LeftInstructionInput_eval(r_stage3_BE)
    )
```

### 7.5 Logical Export Order

InstructionInputVirtualization issues logical exported-opening requests in the following canonical
order:

```text
0 InstructionFlags(LeftOperandIsRs1Value)
1 Rs1Value
2 InstructionFlags(LeftOperandIsPC)
3 UnexpandedPC
4 InstructionFlags(RightOperandIsRs2Value)
5 Rs2Value
6 InstructionFlags(RightOperandIsImm)
7 Imm
```

All eight exports are recorded under:

```text
SumcheckId::InstructionInputVirtualization
```

at the common Stage 3 opening point `r_stage3_BE`.

## 8. Stage 3c: RegistersClaimReduction

### 8.1 Challenge Sampling

After InstructionInputVirtualization samples `gamma_instr`, RegistersClaimReduction samples:

```text
gamma_reg
gamma_reg^2
```

where `gamma_reg^2` is derived from the sampled `gamma_reg`.

This is the third and final Stage 3 randomness event before batched-sumcheck claim appends.

### 8.2 Imported Input Claim

The canonical imported claim order for RegistersClaimReduction is:

```text
0 RdWriteValue
1 Rs1Value
2 Rs2Value
```

The imported input claim is:

```text
claim_reg_in =
    RdWriteValue
  + gamma_reg   * Rs1Value
  + gamma_reg^2 * Rs2Value
```

All three claims are imported from `SumcheckId::SpartanOuter` at the common Stage 1 outer cycle
opening point.

### 8.3 Statement

RegistersClaimReduction proves:

```text
sum_c Eq(r_outer_stage1, c)
  * (
        RdWriteValue(c)
      + gamma_reg   * Rs1Value(c)
      + gamma_reg^2 * Rs2Value(c)
    )
  =
  claim_reg_in
```

### 8.4 Verifier Acceptance Rule

At the common Stage 3 opening point `r_stage3_BE`, RegistersClaimReduction exports:

```text
RdWriteValue
Rs1Value
Rs2Value
```

The verifier-computed expected output claim is:

```text
Eq(r_stage3_BE, r_outer_stage1)
  * (
        RdWriteValue
      + gamma_reg   * Rs1Value
      + gamma_reg^2 * Rs2Value
    )
```

### 8.5 Logical Export Order

RegistersClaimReduction issues logical exported-opening requests in the following canonical order:

```text
0 RdWriteValue
1 Rs1Value
2 Rs2Value
```

All three exports are recorded under:

```text
SumcheckId::RegistersClaimReduction
```

at the common Stage 3 opening point `r_stage3_BE`.

## 9. Batched Sumcheck Rules

Stage 3 runs one batched sumcheck over the three subinstances from Section 3.

The canonical per-instance parameters are:

```text
I1 SpartanShift                   degree = 2, rounds = n
I2 InstructionInputVirtualization degree = 3, rounds = n
I3 RegistersClaimReduction        degree = 2, rounds = n
```

The Stage 3 batched sumcheck uses the canonical claim order:

```text
0 claim_shift_in
1 claim_instr_in
2 claim_reg_in
```

The Stage 3 batching-coefficient order is identical to the subinstance order:

```text
0 beta_shift
1 beta_instr
2 beta_reg
```

## 10. Export Set and Canonicalization

At the end of Stage 3, the prover and verifier MUST issue the following Stage 3 logical opening
requests in this order:

```text
SpartanShift:
  0  UnexpandedPC
  1  PC
  2  OpFlags(VirtualInstruction)
  3  OpFlags(IsFirstInSequence)
  4  InstructionFlags(IsNoop)

InstructionInputVirtualization:
  5  InstructionFlags(LeftOperandIsRs1Value)
  6  Rs1Value
  7  InstructionFlags(LeftOperandIsPC)
  8  UnexpandedPC
  9  InstructionFlags(RightOperandIsRs2Value)
  10 Rs2Value
  11 InstructionFlags(RightOperandIsImm)
  12 Imm

RegistersClaimReduction:
  13 RdWriteValue
  14 Rs1Value
  15 Rs2Value
```

All sixteen logical Stage 3 exports use the same normalized Stage 3 opening point `r_stage3_BE`.

Upstream `main` canonicalizes openings by:

```text
(underlying polynomial id, normalized opening point)
```

before flushing clear-path `opening_claim` scalars or backend-bound export blocks. Under this
rule:

- `SumcheckId` does not prevent aliasing
- if two logical requests target the same underlying polynomial at the same normalized point, the
  later request aliases the earlier canonical opening
- only the first non-aliased occurrence becomes transcript-visible

Because all Stage 3 subinstances normalize to the same `r_stage3_BE`, three logical Stage 3
requests alias earlier openings:

```text
InstructionInputVirtualization::UnexpandedPC
  aliases SpartanShift::UnexpandedPC

RegistersClaimReduction::Rs1Value
  aliases InstructionInputVirtualization::Rs1Value

RegistersClaimReduction::Rs2Value
  aliases InstructionInputVirtualization::Rs2Value
```

Therefore the clear-path canonical export order is the following 13-opening sequence:

```text
0  SpartanShift::UnexpandedPC
1  SpartanShift::PC
2  SpartanShift::OpFlags(VirtualInstruction)
3  SpartanShift::OpFlags(IsFirstInSequence)
4  SpartanShift::InstructionFlags(IsNoop)
5  InstructionInputVirtualization::InstructionFlags(LeftOperandIsRs1Value)
6  InstructionInputVirtualization::Rs1Value
7  InstructionInputVirtualization::InstructionFlags(LeftOperandIsPC)
8  InstructionInputVirtualization::InstructionFlags(RightOperandIsRs2Value)
9  InstructionInputVirtualization::Rs2Value
10 InstructionInputVirtualization::InstructionFlags(RightOperandIsImm)
11 InstructionInputVirtualization::Imm
12 RegistersClaimReduction::RdWriteValue
```

## 11. Proof Shape

The Stage 3 proof contribution consists of exactly one proof object:

```text
stage3_sumcheck_proof : SumcheckInstanceProof
```

Stage 3 has no uni-skip round and no stage-local opening proof.

In the clear path:

- `stage3_sumcheck_proof` contains the clear round-polynomial data for the batched sumcheck
- the global opening-claims transcript contains only the 13 canonical, non-aliased Stage 3 exports
  from Section 10

In the backend-instantiated zk path:

- `stage3_sumcheck_proof` is the backend proof object for the canonical Stage 3 batched relation
- no clear `sumcheck_claim` scalars are required before batching coefficients are derived
- the canonical deduplicated Stage 3 export block is bound according to the active backend profile
- any Pedersen- or BlindFold-specific realization is a legacy-backend detail only

## 12. Transcript Schedule

Relative to the transcript state at Stage 3 entry, Stage 3 MUST perform:

```text
1. sample gamma_shift_pows = [1, gamma_shift, gamma_shift^2, gamma_shift^3, gamma_shift^4]
2. sample gamma_instr
3. sample gamma_reg
```

After those stage-local challenges are sampled, Stage 3 MUST use the standard batched-sumcheck
transcript surface for the canonical instance order from Section 3.

In the clear path:

```text
4. append "sumcheck_claim" for SpartanShift
5. append "sumcheck_claim" for InstructionInputVirtualization
6. append "sumcheck_claim" for RegistersClaimReduction

7. sample three batching coefficients in the same order:
   [beta_shift, beta_instr, beta_reg]

8. for each round j in 0..n-1:
   append "sumcheck_poly"
   sample u_j

9. flush canonical Stage 3 exported `opening_claim` values derived from the logical request order
   in Section 10
   note: aliased logical requests do not append additional `opening_claim` scalars
```

In the backend-instantiated zk path:

```text
4. sample three batching coefficients in canonical order:
   [beta_shift, beta_instr, beta_reg]

5. for each round j in 0..n-1:
   invoke the backend round flow for the same canonical batch order
   sample u_j

6. bind the canonical Stage 3 exported opening block after alias resolution according to the active
   backend profile
```

These surfaces describe alternative stage-level realizations of the same Stage 3 algebra.
Under the SuperNEO profile, this file makes the Stage 3 algebraic relation, challenge schedule,
normalized opening points, and canonical export order normative; the backend proof realization is
governed instead by `ZkVmCeBridge.spec.md`,
[ZkVmBridge.CurrentStep.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.CurrentStep.spec.md),
[ZkVmBridge.Frontier.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.Frontier.spec.md),
and
[ZkVmReduction.SuperNeoAjtai.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai.spec.md).

## 13. Conformance Conditions

Two Stage 3 implementations are conformant only if they agree on all of the following:

```text
- the Stage 3 subinstance batch order
- the fact that all three subinstances have rounds = log_2(T)
- the fact that all three subinstances use round_offset = 0
- the Stage 3 opening-point normalization rule r_stage3_BE = reverse([u_0, ..., u_{n-1}])
- the SpartanShift imported-claim combination
- the SpartanShift use of EqPlusOne against r_outer_stage1 and r_product_stage2
- the InstructionInputVirtualization imported-claim order [RightInstructionInput, LeftInstructionInput]
- the requirement that instruction-input claims agree across InstructionClaimReduction and SpartanProductVirtualization
- the operand-factor formulas for LeftInstructionInput_eval and RightInstructionInput_eval
- the RegistersClaimReduction imported-claim order [RdWriteValue, Rs1Value, Rs2Value]
- the logical exported-opening order within each Stage 3 subinstance
- the aggregate Stage 3 logical exported-opening request order
- the Stage 3 opening canonicalization rule keyed by underlying polynomial id and normalized opening point
- the 13-opening canonical clear-path export order from Section 10
- the Stage 3 transcript schedule from Section 12
```

Without these fixed points, two implementations can both be strategically similar while producing
incompatible Stage 3 proofs.

## 14. Non-Normative Implementation Anchors

- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/prover.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/verifier.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/spartan/shift.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/spartan/instruction_input.rs`
- `/Users/nicolasarqueros/.codex/worktrees/bb50/jolt/jolt-core/src/zkvm/claim_reductions/registers.rs`

# jolt-stages-specs/specs/JoltStage2.spec.md
# Stage 2 Specification Draft

## Status

Draft. This document captures the **normative protocol shape** of Jolt Stage 2 for the upstream
`a16z/jolt` `main` revision fetched during this session.

As with the retargeted Stage 1 draft, this document distinguishes:

- the clear path, where round polynomials and output claims are absorbed directly into the transcript
- the backend-instantiated zk path, where those objects are bound by the active backend profile

SuperNEO profile note.

- This stage specification fixes semantic claims, imported claims, challenge derivations,
  normalized opening points, alias rules, and the canonical exported opening stream.
- Under the SuperNEO profile, imported and exported Stage 2 openings are evaluations against the
  shared Ajtai-committed frontend witness surface established before Stage 1.
- Pedersen commitments, BlindFold objects, and `output_claims_coms` belong to a legacy backend
  profile and are not normative for SuperNEO.
- Semantic machine-word values may be reconstructed views over bounded witness encodings under the
  SuperNEO profile.
- Backend-local boundedness or decomposition witnesses MUST NOT widen, reorder, or redefine the
  canonical Stage 2 exported opening stream.

## Summary

- Defines the RAM / product / instruction-lookup reduction layer that consumes selected Stage 1
  openings.
- Splits Stage 2 into product virtualization plus a 5-instance batched sumcheck for RAM read/write,
  product remainder, instruction lookup reduction, RAM RAF, and public-output RAM checks.
- Aligns RAM values and RAM addresses at normalized Stage 2 points so later stages can reuse them
  consistently.
- Exports reduced openings such as `RamVal`, `RamRa`, `RamInc`, product factors, instruction
  lookup inputs, and `RamValFinal`.

## 1. Scope

Stage 2 is a composite stage with:

- one product-virtualization uni-skip round
- one batched sumcheck with five subinstances

Stage 2 has three purposes:

1. reduce the three upstream product identities into a single product-virtualization cycle point
2. bind RAM read/write, RAM address, and RAM output consistency to aligned Stage 2 openings
3. export the reduced virtual and committed claims needed by later stages

At a high level, Stage 2 takes Stage 1 openings at the Stage 1 cycle point and produces:

```text
- Product-virtualization factor openings at a Stage 2 cycle point
- RAM value and RAM address openings at a Stage 2 address-cycle point
- a committed RamInc opening at a Stage 2 cycle point
- reduced instruction-lookup openings at a Stage 2 cycle point
- a reduced RamRa opening at a Stage 2 address-cycle point
- a reduced RamValFinal opening at a Stage 2 address point
```

Stage 2 does not include `RamValCheck`. In upstream `main`, `RamValCheck` is a Stage 4 instance.

## 2. Imported Objects

Let:

```text
T   = padded trace length = 2^n
K   = RAM address domain size = 2^k
p1  = ram_rw_phase1_num_rounds
p2  = ram_rw_phase2_num_rounds
```

Stage 2 imports:

```text
Stage 1 virtual openings
the shared Ajtai-committed frontend witness surface
RAM preprocessing and memory layout
initial RAM state
final RAM state
public I/O device state
ReadWriteConfig
OneHotParams
```

The imported Stage 1 claims are interpreted as evaluations of the shared Ajtai-committed frontend
witness surface, not as free-standing uncommitted scalars.

## 3. Imported Stage 1 Claims

### 3.1 Product-Virtualization Base Claims

Stage 2a imports the following Stage 1 openings from `SumcheckId::SpartanOuter`, all at the common
Stage 1 cycle point:

```text
0 Product
1 ShouldBranch
2 ShouldJump
```

This order is normative.

### 3.2 RAM Inputs

Stage 2b imports the following Stage 1 openings:

```text
RamReadValue  from SpartanOuter
RamWriteValue from SpartanOuter
RamAddress    from SpartanOuter
```

### 3.3 Instruction-Lookup Inputs

Stage 2b also imports:

```text
LookupOutput
LeftLookupOperand
RightLookupOperand
LeftInstructionInput
RightInstructionInput
```

all from `SumcheckId::SpartanOuter`.

## 4. Canonical Product-Virtualization Objects

### 4.1 Product Constraint Order

Upstream `main` uses exactly three product constraints:

```text
0 Instruction
1 ShouldBranch
2 ShouldJump
```

with the corresponding factorization:

```text
Instruction   = LeftInstructionInput * RightInstructionInput
ShouldBranch  = LookupOutput * InstructionFlags(Branch)
ShouldJump    = OpFlags(Jump) * (1 - NextIsNoop)
```

This order is normative.

### 4.2 Product Unique Factor Order

The Stage 2b product-virtualization exporter opens the following factor list in the canonical
order:

```text
0 LeftInstructionInput
1 RightInstructionInput
2 OpFlags(Jump)
3 OpFlags(WriteLookupOutputToRD)
4 LookupOutput
5 InstructionFlags(Branch)
6 NextIsNoop
7 OpFlags(VirtualInstruction)
```

The last two entries matter:

- `NextIsNoop` is opened so the verifier can reconstruct `1 - NextIsNoop` for `ShouldJump`
- `OpFlags(WriteLookupOutputToRD)` is exported for downstream use, but is not part of the Stage 2b
  fused remainder equation
- `OpFlags(VirtualInstruction)` is not a product factor, but is still exported here for downstream stages

## 5. Canonical Stage 2 Decomposition

Stage 2 is divided into:

```text
Stage 2a: Product-virtualization uni-skip
Stage 2b: Batched sumcheck over five subinstances
```

The Stage 2b subinstances appear in the canonical batch order:

```text
I1 RamReadWriteChecking
I2 ProductVirtualRemainder
I3 InstructionLookupsClaimReduction
I4 RamRafEvaluation
I5 OutputSumcheck
```

This order is normative. It determines:

- the clear-path `sumcheck_claim` append order
- the batching-coefficient order
- the logical exported-opening request order at the end of Stage 2b

## 6. Stage 2a: Product-Virtualization Uni-Skip

### 6.1 Imported Objects and Randomness

Stage 2a reuses the Stage 1 cycle point as `tau_low` and samples one fresh challenge:

```text
tau_pv = [r_cycle_stage1_BE || tau_high_pv]
```

where:

- `r_cycle_stage1_BE` is read from the `Product` opening under `SumcheckId::SpartanOuter`
- `tau_high_pv` is sampled freshly from the transcript

### 6.2 Base Domain

The upstream product-virtualization uni-skip base window has size 3:

```text
W_pv = [-1, 0, 1]
```

The fixed parameters are:

```text
NUM_PRODUCT_VIRTUAL                         = 3
PRODUCT_VIRTUAL_UNIVARIATE_SKIP_DOMAIN_SIZE = 3
PRODUCT_VIRTUAL_UNIVARIATE_SKIP_DEGREE      = 2
PRODUCT_VIRTUAL_FIRST_ROUND_POLY_NUM_COEFFS = 7
degree bound of s1_pv                       = 6
```

### 6.3 Input Claim

Let:

```text
base_eval[0] = Product      @ SpartanOuter
base_eval[1] = ShouldBranch @ SpartanOuter
base_eval[2] = ShouldJump   @ SpartanOuter
```

and let `w_i` be the Lagrange basis weights of `tau_high_pv` over the size-3 base window.

The Stage 2a input claim is:

```text
claim_pv_in = sum_{i=0..2} w_i * base_eval[i]
```

### 6.4 Statement

Let:

```text
Left(c, y)  = fused left product-side polynomial over the 3 product terms
Right(c, y) = fused right product-side polynomial over the 3 product terms
```

Stage 2a proves:

```text
sum_y L_W_pv(tau_high_pv, y) * sum_c Eq(r_cycle_stage1_BE, c_BE) * Left(c, y) * Right(c, y)
= claim_pv_in
```

### 6.5 Clear-Path Acceptance

In the clear path:

- the prover sends the full coefficient vector of the Stage 2a uni-skip polynomial
- the verifier checks the public degree bound `<= 6`
- the verifier checks:

```text
sum_{y in W_pv} s1_pv(y) = claim_pv_in
```

- the verifier samples `r0_pv`
- the exported uni-skip claim is `s1_pv(r0_pv)`

### 6.6 ZK-Path Acceptance

In the backend-instantiated zk path:

- the prover binds the Stage 2a uni-skip relation and the canonical Stage 2a export under the
  active backend profile
- the verifier checks transcript consistency and the public degree bound required by that backend
  profile
- the prover and verifier both derive `r0_pv` under the same canonical Stage 2 challenge schedule
- the canonical Stage 2 exported opening stream remains unchanged
- any Pedersen- or BlindFold-specific proof objects are legacy-backend details only

### 6.7 Output

Stage 2a exports exactly one opening:

```text
VirtualPolynomial::UnivariateSkip
under SumcheckId::SpartanProductVirtualization
at [r0_pv]
```

where `r0_pv` is the verifier challenge sampled after the uni-skip message.

## 7. Stage 2b: Batched Sumcheck

### 7.1 Batch-Wide Round Geometry

Let:

```text
M = log_T + log_K
```

This equals the number of rounds of `RamReadWriteChecking` and is the Stage 2b maximum round
count.

Stage 2b uses front-loaded batched sumcheck over the five instances from Section 5. For an
instance `I_i` with `n_i` rounds, its input claim is scaled by:

```text
2^(M - n_i)
```

before applying its batching coefficient.

### 7.2 Round Windows

The canonical round windows are:

```text
I1 RamReadWriteChecking:
    num_rounds = log_T + log_K
    offset     = 0

I2 ProductVirtualRemainder:
    num_rounds = log_T
    offset     = log_K

I3 InstructionLookupsClaimReduction:
    num_rounds = log_T
    offset     = log_K

I4 RamRafEvaluation:
    num_rounds = log_T + log_K - p1
    offset     = p1

I5 OutputSumcheck:
    num_rounds = log_T + log_K - p1
    offset     = p1
```

These offsets are normative.

### 7.3 Internal Cycle Gap

`RamRafEvaluation` and `OutputSumcheck` align to the RAM read/write schedule beginning at RW Phase
2. Their active windows therefore include an internal gap of:

```text
log_T - p1
```

dummy rounds corresponding to RW Phase 3 cycle bindings.

Those dummy rounds:

- are part of the Stage 2b batch transcript
- do not bind address variables for `I4` or `I5`
- are skipped when constructing their normalized address opening points

## 8. Stage 2b Subinstance Contracts

### 8.1 I1: RamReadWriteChecking

#### Input Claim

`RamReadWriteChecking` samples one challenge:

```text
gamma_rw
```

and imports:

```text
RamReadValue  @ SpartanOuter
RamWriteValue @ SpartanOuter
```

Its input claim is:

```text
claim_rw_in = RamReadValue + gamma_rw * RamWriteValue
```

#### Normalized Opening Point

The normalized Stage 2 RAM read/write opening point is:

```text
r_rw = [r_address_rw || r_cycle_rw]
```

where:

```text
r_cycle_rw   = reverse(phase3_cycle_challenges) || reverse(phase1_cycle_challenges)
r_address_rw = reverse(phase3_address_challenges) || reverse(phase2_address_challenges)
```

This ordering is normative.

#### Verifier Equation

At `r_rw`, the verifier checks:

```text
Eq(r_cycle_stage1_ram, r_cycle_rw)
*
RamRa(r_rw)
*
(
    RamVal(r_rw)
  + gamma_rw * (RamVal(r_rw) + RamInc(r_cycle_rw))
)
```

#### Exports

`RamReadWriteChecking` exports, in this exact order:

```text
1. VirtualPolynomial::RamVal  under SumcheckId::RamReadWriteChecking at r_rw
2. VirtualPolynomial::RamRa   under SumcheckId::RamReadWriteChecking at r_rw
3. CommittedPolynomial::RamInc under SumcheckId::RamReadWriteChecking at r_cycle_rw
```

### 8.2 I2: ProductVirtualRemainder

#### Input Claim

The input claim is:

```text
claim_pv_rem_in = UnivariateSkip @ SpartanProductVirtualization
```

#### Normalized Opening Point

The normalized opening point is the Stage 2 cycle point:

```text
r_cycle_pv_stage2 = reverse(local_cycle_challenges)
```

#### Verifier Equation

Let `w_0, w_1, w_2` be the Lagrange weights at `r0_pv` over the size-3 product window.

Define:

```text
fused_left  = w_0 * LeftInstructionInput
            + w_1 * LookupOutput
            + w_2 * OpFlags(Jump)

fused_right = w_0 * RightInstructionInput
            + w_1 * InstructionFlags(Branch)
            + w_2 * (1 - NextIsNoop)
```

Then the verifier checks:

```text
L_W_pv(tau_high_pv, r0_pv)
*
Eq(tau_low_pv, reverse(local_cycle_challenges))
*
fused_left(r_cycle_pv_stage2)
*
fused_right(r_cycle_pv_stage2)
```

#### Exports

`ProductVirtualRemainder` exports the eight virtual openings from
`PRODUCT_UNIQUE_FACTOR_VIRTUALS`, in the exact order from Section 4.2, all under:

```text
SumcheckId::SpartanProductVirtualization
```

and all at:

```text
r_cycle_pv_stage2
```

Only six of those eight openings participate in the Stage 2b fused remainder equation:

```text
LeftInstructionInput
RightInstructionInput
OpFlags(Jump)
LookupOutput
InstructionFlags(Branch)
NextIsNoop
```

`OpFlags(WriteLookupOutputToRD)` and `OpFlags(VirtualInstruction)` are exported here solely for
later stages.

### 8.3 I3: InstructionLookupsClaimReduction

#### Input Claim

This instance samples one scalar:

```text
gamma_instr
```

and defines:

```text
gamma_instr^2
gamma_instr^3
gamma_instr^4
```

Its input claim is:

```text
claim_instr_in =
    LookupOutput
  + gamma_instr   * LeftLookupOperand
  + gamma_instr^2 * RightLookupOperand
  + gamma_instr^3 * LeftInstructionInput
  + gamma_instr^4 * RightInstructionInput
```

with all five imported from `SumcheckId::SpartanOuter`.

#### Normalized Opening Point

The normalized opening point is the Stage 2 cycle point:

```text
r_cycle_instr_stage2 = reverse(local_cycle_challenges)
```

#### Verifier Equation

Let `r_spartan_lookup` be the Stage 1 cycle point imported from
`LookupOutput @ SpartanOuter`.

The verifier checks:

```text
Eq(r_cycle_instr_stage2, r_spartan_lookup)
*
(
    LookupOutput
  + gamma_instr   * LeftLookupOperand
  + gamma_instr^2 * RightLookupOperand
  + gamma_instr^3 * LeftInstructionInput
  + gamma_instr^4 * RightInstructionInput
)
```

where the five terms on the right are the Stage 2 exported openings under
`SumcheckId::InstructionClaimReduction`.

#### Exports

`InstructionLookupsClaimReduction` exports, in this exact order:

```text
1. LookupOutput
2. LeftLookupOperand
3. RightLookupOperand
4. LeftInstructionInput
5. RightInstructionInput
```

all under:

```text
SumcheckId::InstructionClaimReduction
```

and all at:

```text
r_cycle_instr_stage2
```

### 8.4 I4: RamRafEvaluation

#### Input Claim

The input claim is:

```text
claim_raf_in = RamAddress @ SpartanOuter
```

renormalized by:

```text
2^(log_T - p1)
```

to account for the internal cycle-gap rounds in this instance's active window.

#### Normalized Opening Point

Let the local Stage 2b challenges for this instance be split as:

```text
phase2_addr || cycle_gap || phase3_addr
```

Then:

```text
r_address_raf = reverse(phase3_addr) || reverse(phase2_addr)
```

The exported opening point for `RamRa` is:

```text
[r_address_raf || r_cycle_stage1_ram_address]
```

where `r_cycle_stage1_ram_address` is the cycle point imported from
`RamAddress @ SpartanOuter`.

#### Verifier Equation

The verifier checks:

```text
UnmapRamAddress(r_address_raf) * RamRa([r_address_raf || r_cycle_stage1_ram_address])
```

#### Exports

`RamRafEvaluation` exports exactly one opening:

```text
VirtualPolynomial::RamRa
under SumcheckId::RamRafEvaluation
at [r_address_raf || r_cycle_stage1_ram_address]
```

### 8.5 I5: OutputSumcheck

#### Input Claim

The input claim is:

```text
0
```

This instance samples one address point directly from the transcript:

```text
r_address_output_base
```

before the batched sumcheck begins.

#### Normalized Opening Point

As with `RamRafEvaluation`, the local challenge slice is interpreted as:

```text
phase2_addr || cycle_gap || phase3_addr
```

and normalized to:

```text
r_address_output = reverse(phase3_addr) || reverse(phase2_addr)
```

#### Verifier Equation

Let:

```text
eq_eval      = Eq(r_address_output_base, r_address_output)
io_mask_eval = IOMask(r_address_output)
val_io_eval  = PublicIOValue(r_address_output)
```

The verifier checks:

```text
eq_eval * io_mask_eval * (RamValFinal(r_address_output) - val_io_eval)
```

#### Exports

`OutputSumcheck` exports exactly one opening:

```text
VirtualPolynomial::RamValFinal
under SumcheckId::RamOutputCheck
at r_address_output
```

## 9. Export Set and Canonicalization

Over the course of Stage 2, the prover and verifier MUST issue Stage 2 logical opening requests in
the following order:

```text
Stage 2a:
  UnivariateSkip under SpartanProductVirtualization at [r0_pv]

Stage 2b / I1 RamReadWriteChecking:
  RamVal
  RamRa
  RamInc

Stage 2b / I2 ProductVirtualRemainder:
  LeftInstructionInput
  RightInstructionInput
  OpFlags(Jump)
  OpFlags(WriteLookupOutputToRD)
  LookupOutput
  InstructionFlags(Branch)
  NextIsNoop
  OpFlags(VirtualInstruction)

Stage 2b / I3 InstructionLookupsClaimReduction:
  LookupOutput
  LeftLookupOperand
  RightLookupOperand
  LeftInstructionInput
  RightInstructionInput

Stage 2b / I4 RamRafEvaluation:
  RamRa

Stage 2b / I5 OutputSumcheck:
  RamValFinal
```

The associated opening points are:

```text
UnivariateSkip:
  [r0_pv]

RamReadWriteChecking:
  RamVal, RamRa at [r_address_rw || r_cycle_rw]
  RamInc at r_cycle_rw

ProductVirtualRemainder:
  r_cycle_pv_stage2

InstructionLookupsClaimReduction:
  r_cycle_instr_stage2

RamRafEvaluation:
  [r_address_raf || r_cycle_stage1_ram_address]

OutputSumcheck:
  r_address_output
```

These entries define the **logical request order**, not the unconditional transcript-visible append
order.

Upstream `main` canonicalizes openings by:

```text
(underlying polynomial id, normalized opening point)
```

before flushing claims or output-claim commitments. Under this rule:

- `SumcheckId` does not prevent aliasing
- if two logical requests target the same underlying polynomial at the same normalized point, the
  later request aliases the earlier canonical opening
- only the first non-aliased occurrence creates a transcript-visible `opening_claim` in the clear
  path or a backend-bound export-block entry in the backend-instantiated zk path

In particular, the Stage 2 `ProductVirtualRemainder` and
`InstructionLookupsClaimReduction` requests for `LookupOutput`, `LeftInstructionInput`, and
`RightInstructionInput` MAY alias if their normalized cycle points coincide.

## 10. Proof Shape

### 10.1 Clear Path

The clear-path Stage 2 proof contribution consists of:

```text
stage2_uni_skip_first_round_proof:
    uni_poly : full coefficient vector of the Stage 2a uni-skip polynomial

stage2_sumcheck_proof:
    compressed_polys : one compressed round polynomial for each Stage 2b batch round
```

All Stage 2 exports are recorded in the global opening-claims stream rather than inside those proof
objects. In clear mode, the opening-claims stream contains only the canonical, non-aliased exports
from Section 9.

### 10.2 ZK Path

The backend-instantiated zk-path Stage 2 proof contribution consists of:

```text
stage2_uni_skip_first_round_proof:
    backend proof object binding the canonical Stage 2a relation and Stage 2a export

stage2_sumcheck_proof:
    backend proof object binding the canonical Stage 2b batched relation and canonical Stage 2b exports
```

If a legacy Jolt backend profile is explicitly enabled, those proof objects may be realized through
Pedersen commitments and BlindFold-compatible wiring. That legacy shape is not normative for the
SuperNEO profile.

## 11. Transcript Schedule

### 11.1 Clear Path

Relative to the transcript state at Stage 2 entry, the clear path MUST perform:

```text
1. sample tau_high_pv

2. append "uniskip_poly" for the Stage 2a uni-skip polynomial
3. sample r0_pv
4. append "opening_claim" for the Stage 2a UnivariateSkip opening

5. sample gamma_rw
6. sample gamma_instr
7. sample r_address_output_base

8. append "sumcheck_claim" for each Stage 2b instance in canonical order:
   I1 RamReadWriteChecking
   I2 ProductVirtualRemainder
   I3 InstructionLookupsClaimReduction
   I4 RamRafEvaluation
   I5 OutputSumcheck

9. sample five batching coefficients in that same order

10. for each of the M = log_T + log_K Stage 2b batch rounds:
    append "sumcheck_poly"
    sample the next round challenge

11. flush canonical Stage 2b exported opening claims derived from the logical request order in
    Section 9
    note: aliased requests do not append additional `opening_claim` values
```

### 11.2 ZK Path

Relative to the transcript state at Stage 2 entry, the backend-instantiated zk path MUST perform:

```text
1. sample tau_high_pv

2. invoke the active backend flow for the canonical Stage 2a uni-skip instance
3. sample r0_pv
4. bind the canonical Stage 2a export block according to the active backend profile

5. sample gamma_rw
6. sample gamma_instr
7. sample r_address_output_base

8. sample five Stage 2b batching coefficients

9. for each of the M = log_T + log_K Stage 2b batch rounds:
   invoke the backend round flow for the same canonical batch order
   sample the next round challenge

10. bind the canonical Stage 2b export block according to the active backend profile
```

These schedules describe two stage-level proof surfaces over the same Stage 2 algebraic relation.
Under the SuperNEO profile, this file makes the Stage 2 algebraic relation, challenge schedule,
normalized opening points, and canonical export order normative; the backend proof realization is
governed instead by `ZkVmCeBridge.spec.md`,
[ZkVmBridge.CurrentStep.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.CurrentStep.spec.md),
[ZkVmBridge.Frontier.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.Frontier.spec.md),
and
[ZkVmReduction.SuperNeoAjtai.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai.spec.md).

## 12. Conformance Conditions

Two Stage 2 implementations targeting upstream `main` are conformant only if they agree on all of
the following:

```text
- the 3-term product constraint order [Instruction, ShouldBranch, ShouldJump]
- the 8-element PRODUCT_UNIQUE_FACTOR_VIRTUALS order from Section 4.2
- the Stage 2b instance order [RW, ProductRemainder, InstructionClaimReduction, RamRafEvaluation, OutputSumcheck]
- the Stage 2a base window W_pv = [-1, 0, 1]
- the Stage 2a uniskip parameters (domain size 3, degree 2, 7 coefficients, degree bound 6)
- the fact that Stage 2a imports Product, ShouldBranch, and ShouldJump only
- the RamReadWriteChecking normalization rule producing [r_address_rw || r_cycle_rw]
- the ProductVirtualRemainder cycle-point normalization and export order
- the InstructionLookupsClaimReduction gamma weighting order
- the RamRafEvaluation offset = p1 and its internal-cycle-gap handling
- the OutputSumcheck offset = p1 and its internal-cycle-gap handling
- the exact logical export request set and order from Section 9
- the opening canonicalization rule keyed by underlying polynomial id and normalized opening point
- the Stage 2 clear-path transcript schedule
- the Stage 2 zk-path transcript schedule
```

Without those fixed points, two implementations can be strategically similar while producing
incompatible Stage 2 proofs.

## 13. Non-Normative Upstream Anchors

This draft follows the executable constants, verifier equations, and opening-accumulator behavior
of upstream `main`. Where comments in upstream source files still mention older five-term or
size-5 product-virtualization language, this draft treats those comments as stale and follows the
code paths instead.

- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/r1cs/constraints.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/r1cs/inputs.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/spartan/product.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/ram/read_write_checking.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/claim_reductions/instruction_lookups.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/ram/raf_evaluation.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/ram/output_check.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/subprotocols/univariate_skip.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/subprotocols/sumcheck.rs`

# jolt-stages-specs/specs/JoltStage1.spec.md
# Stage 1 Specification Draft

## Status

Draft. This document captures the **normative protocol shape** of Jolt Stage 1 for the upstream
`a16z/jolt` `main` revision fetched during this session.

This draft distinguishes:

- the clear path, where univariate polynomials and output claims are absorbed directly into the transcript
- the backend-instantiated zk path, where those objects are bound by the active backend profile

SuperNEO profile note.

- This stage specification fixes semantic claims, challenge derivations, normalized opening points,
  canonical input order, and the canonical exported opening stream.
- Under the SuperNEO profile, the Stage 1 openings are evaluations against a shared Ajtai-committed
  frontend witness surface that is created before Stage 1 begins.
- Pedersen commitments, BlindFold objects, `output_claims_coms`, and Dory-specific proof surfaces
  belong to a legacy backend profile and are not normative for SuperNEO.
- Semantic machine-word values may be reconstructed views over bounded witness encodings under the
  SuperNEO profile.
- Backend-local boundedness or decomposition witnesses MUST NOT widen, reorder, or redefine the
  canonical Stage 1 exported opening stream.

## Summary

- Defines the first reduction layer for the zkVM step: it checks the uniform per-cycle R1CS
  constraints for the machine state.
- Fixes the canonical Stage 1 input tuple: the 35 virtual inputs, their exact order, and the
  19-row R1CS catalog.
- Reduces the full per-cycle constraint system into a uni-skip first round plus outer sumcheck, so
  later stages only see reduced claims instead of the full trace relation.
- Exports the Stage 1 canonical openings: the uni-skip opening and the 35 virtual-input
  evaluations at the Stage 1 cycle point.

## Frontend commitment phase

Before Stage 1, the SuperNEO profile commits the canonical frontend witness families used by
Stages 1 through 7 under a shared Ajtai-style frontend commitment context:

```text
L_frontend : R_F^(n_R,frontend) -> C_frontend
```

Where:

```text
- the committed frontend witness surface is the only normative opening surface consumed by Stages 1 through 7
- Stage 1 virtual-input openings are evaluations of that Ajtai-committed frontend witness surface at the normalized Stage 1 point
- the active parameter package for L_frontend is inherited from the SuperNEO profile and MUST be compatible with the stage-local witness dimensions
```

## 1. Scope

Stage 1 proves the uniform per-cycle R1CS constraints for Jolt and exports the random-point
evaluations of the Stage 1 virtual inputs for later stages.

Stage 1 reduces:

```text
For every cycle c and every uniform R1CS row j:
    A_j(Z(c)) * B_j(Z(c)) = 0
```

to:

```text
- one uni-skip first-round proof
- one remaining outer sumcheck proof
- one exported opening claim for each Stage 1 virtual input at r_cycle_BE
```

Stage 1 operates only on virtual polynomials.

The normative Stage 1 result is the canonical opening surface defined in this document. An
implementation may additionally materialize extra local openings, aliases, or adapter-facing
derived claims, but those are not Stage 1 outputs for conformance purposes.

## 2. Imported Objects

Let:

```text
T = padded trace length = 2^n
F = base field
```

Stage 1 imports:

```text
RowInputs(c)         : the typed per-cycle Stage 1 row
Z_i(c)               : the 35 Stage 1 virtual inputs derived from RowInputs(c)
R1CS row catalog     : the canonical list of 19 uniform constraints
UniformSpartanKey    : determines n and the row-axis challenge shape
Transcript state     : the transcript state at Stage 1 entry
```

The Stage 1 input tuple size is:

```text
NUM_R1CS_INPUTS = 35
```

Any implementation-local derived values that are useful for later adapters, caching, or local proof
engineering are outside this tuple and MUST NOT change its size, order, or meaning.

## 3. Canonical Stage 1 Input Order

The Stage 1 virtual inputs are ordered canonically as follows:

```text
 0  LeftInstructionInput
 1  RightInstructionInput
 2  Product
 3  ShouldBranch
 4  PC
 5  UnexpandedPC
 6  Imm
 7  RamAddress
 8  Rs1Value
 9  Rs2Value
10  RdWriteValue
11  RamReadValue
12  RamWriteValue
13  LeftLookupOperand
14  RightLookupOperand
15  NextUnexpandedPC
16  NextPC
17  NextIsVirtual
18  NextIsFirstInSequence
19  LookupOutput
20  ShouldJump
21  OpFlags(AddOperands)
22  OpFlags(SubtractOperands)
23  OpFlags(MultiplyOperands)
24  OpFlags(Load)
25  OpFlags(Store)
26  OpFlags(Jump)
27  OpFlags(WriteLookupOutputToRD)
28  OpFlags(VirtualInstruction)
29  OpFlags(Assert)
30  OpFlags(DoNotUpdateUnexpandedPC)
31  OpFlags(Advice)
32  OpFlags(IsCompressed)
33  OpFlags(IsFirstInSequence)
34  OpFlags(IsLastInSequence)
```

This order is normative.

Notably:

- there is no standalone Stage 1 input `WriteLookupOutputToRD`
- there is no standalone Stage 1 input `WritePCtoRD`
- the corresponding behavior is represented by `OpFlags(WriteLookupOutputToRD)` and `OpFlags(Jump)`

## 3A. Canonical and Supplemental Opening Surfaces

This document defines a canonical Stage 1 opening surface and permits, but does not normatively
define, a supplemental implementation-local opening surface.

### Canonical Stage 1 Opening Surface

The canonical Stage 1 opening surface consists only of:

```text
1. the Stage 1a UnivariateSkip opening at [r0]
2. the 35 Stage 1 virtual-input openings at r_cycle_BE in the exact order from Section 3
```

This surface is the only Stage 1 opening surface relevant to Jolt compatibility.

### Supplemental Implementation-Local Opening Surface

An implementation may maintain extra openings in a local namespace, including:

```text
- aliases of canonical Stage 1 openings
- extra derived openings used only by local verifier/prover engineering
- adapter-facing openings used by later non-Jolt export layers
```

Such openings are permitted only if all of the following hold:

```text
- they do not replace any canonical Stage 1 opening
- they do not reorder the canonical 35-input stream
- they do not widen the canonical Stage 1 input tuple
- they do not change the Stage 1 transcript schedule from Section 12
- they are never required by an interface claiming Stage 1 compatibility with upstream Jolt
```

If a supplemental opening is merely an alias of a canonical opening, it MUST preserve the same
opening point and the same claimed value.

## 4. Uniform R1CS Catalog

Stage 1 uses a canonical catalog of 19 uniform R1CS rows.

The normative form is the exact guard-and-equality pair used by upstream `main`:

```text
 0  (Load + Store) * (RamAddress - (Rs1Value + Imm)) = 0
 1  (1 - Load - Store) * RamAddress = 0
 2  Load * (RamReadValue - RamWriteValue) = 0
 3  Load * (RamReadValue - RdWriteValue) = 0
 4  Store * (Rs2Value - RamWriteValue) = 0
 5  (AddOperands + SubtractOperands + MultiplyOperands) * LeftLookupOperand = 0
 6  (1 - AddOperands - SubtractOperands - MultiplyOperands) * (LeftLookupOperand - LeftInstructionInput) = 0
 7  AddOperands * (RightLookupOperand - LeftInstructionInput - RightInstructionInput) = 0
 8  SubtractOperands * (RightLookupOperand - LeftInstructionInput + RightInstructionInput - 2^64) = 0
 9  MultiplyOperands * (RightLookupOperand - Product) = 0
10  (1 - AddOperands - SubtractOperands - MultiplyOperands - Advice) * (RightLookupOperand - RightInstructionInput) = 0
11  Assert * (LookupOutput - 1) = 0
12  OpFlags(WriteLookupOutputToRD) * (RdWriteValue - LookupOutput) = 0
13  Jump * (RdWriteValue - UnexpandedPC - 4 + 2*IsCompressed) = 0
14  ShouldJump * (NextUnexpandedPC - LookupOutput) = 0
15  ShouldBranch * (NextUnexpandedPC - UnexpandedPC - Imm) = 0
16  (1 - ShouldBranch - Jump) * (NextUnexpandedPC - UnexpandedPC - 4 + 4*DoNotUpdateUnexpandedPC + 2*IsCompressed) = 0
17  (VirtualInstruction - IsLastInSequence) * (NextPC - PC - 1) = 0
18  (NextIsVirtual - NextIsFirstInSequence) * (1 - DoNotUpdateUnexpandedPC) = 0
```

The distinction between rows 14 and 16 is normative:

- row 14 is guarded by `ShouldJump`
- row 16 is guarded by `1 - ShouldBranch - Jump`

This means the `Jump && NextIsNoop` case is excluded from both row 14 and row 16.

Two implementation notes are non-normative but useful when reading upstream code:

- row 13 may still appear under the legacy internal label `RdWriteEqPCPlusConstIfWritePCtoRD`,
  even though the actual guard is `OpFlags(Jump)` and there is no standalone Stage 1
  `WritePCtoRD` input
- row 18 may appear in code as the equivalent guarded equality
  `(NextIsVirtual - NextIsFirstInSequence) => 1 == DoNotUpdateUnexpandedPC`
  rather than the product form above; upstream does this to keep the B-side boolean

## 5. Canonical Grouping

The 19 rows are partitioned into two canonical groups.

The Stage 1 base window is:

```text
W = [-4, -3, -2, -1, 0, 1, 2, 3, 4, 5]
|W| = 10
```

### First Group

The first group has size 10 and is ordered as:

```text
G0[0] (1 - Load - Store) * RamAddress = 0
G0[1] Load * (RamReadValue - RamWriteValue) = 0
G0[2] Load * (RamReadValue - RdWriteValue) = 0
G0[3] Store * (Rs2Value - RamWriteValue) = 0
G0[4] (AddOperands + SubtractOperands + MultiplyOperands) * LeftLookupOperand = 0
G0[5] (1 - AddOperands - SubtractOperands - MultiplyOperands) * (LeftLookupOperand - LeftInstructionInput) = 0
G0[6] Assert * (LookupOutput - 1) = 0
G0[7] ShouldJump * (NextUnexpandedPC - LookupOutput) = 0
G0[8] (VirtualInstruction - IsLastInSequence) * (NextPC - PC - 1) = 0
G0[9] (NextIsVirtual - NextIsFirstInSequence) * (1 - DoNotUpdateUnexpandedPC) = 0
```

### Second Group

The second group is the complement, preserving catalog order:

```text
G1[0] (Load + Store) * (RamAddress - (Rs1Value + Imm)) = 0
G1[1] AddOperands * (RightLookupOperand - LeftInstructionInput - RightInstructionInput) = 0
G1[2] SubtractOperands * (RightLookupOperand - LeftInstructionInput + RightInstructionInput - 2^64) = 0
G1[3] MultiplyOperands * (RightLookupOperand - Product) = 0
G1[4] (1 - AddOperands - SubtractOperands - MultiplyOperands - Advice) * (RightLookupOperand - RightInstructionInput) = 0
G1[5] OpFlags(WriteLookupOutputToRD) * (RdWriteValue - LookupOutput) = 0
G1[6] Jump * (RdWriteValue - UnexpandedPC - 4 + 2*IsCompressed) = 0
G1[7] ShouldBranch * (NextUnexpandedPC - UnexpandedPC - Imm) = 0
G1[8] (1 - ShouldBranch - Jump) * (NextUnexpandedPC - UnexpandedPC - 4 + 4*DoNotUpdateUnexpandedPC + 2*IsCompressed) = 0
```

For interpolation over `W`, the missing `G1[9]` slot is defined to be zero on both the `A` and
`B` sides.

## 6. Randomness and Canonical Orderings

Let `n = log_2(T)`.

The UniformSpartanKey defines:

```text
num_rows_bits = n + 2
```

Stage 1 samples:

```text
tau = [tau_cycle_BE[0..n-1], tau_group, tau_high] in F^(n+2)
```

This ordering is normative.

Stage 1b later samples:

```text
r_sumcheck = [r_stream, r_cycle_LE[0], ..., r_cycle_LE[n-1]]
r_cycle_BE = reverse(r_cycle_LE)
```

The canonical exported opening point for Stage 1 virtual inputs is `r_cycle_BE`.

## 7. Stage 1 Statement

For each cycle `c`, define the first-group interpolation polynomials `A^0_c(Y), B^0_c(Y)` as the
unique degree-`<10` polynomials such that:

```text
A^0_c(W_i) = A_{G0[i]}(Z(c))
B^0_c(W_i) = B_{G0[i]}(Z(c))     for i = 0..9
```

Define the second-group interpolation polynomials `A^1_c(Y), B^1_c(Y)` as the unique degree-`<10`
polynomials such that:

```text
A^1_c(W_i) = A_{G1[i]}(Z(c))
B^1_c(W_i) = B_{G1[i]}(Z(c))     for i = 0..8
A^1_c(W_9) = 0
B^1_c(W_9) = 0
```

Define the group-interpolated forms:

```text
A_c(Y, b) = A^0_c(Y) + b * (A^1_c(Y) - A^0_c(Y))
B_c(Y, b) = B^0_c(Y) + b * (B^1_c(Y) - B^0_c(Y))
```

Define:

```text
t1(Y) =
    sum over c in {0,1}^n of
        Eq(tau_cycle_BE, c_BE) * A_c(Y, tau_group) * B_c(Y, tau_group)

s1(Y) = L_W(tau_high, Y) * t1(Y)
```

where `L_W` is the Lagrange kernel over the base window `W`.

Stage 1 is sound if and only if the verifier accepts the Stage 1 protocol for this statement.

## 8. Stage 1a: Uni-Skip First Round

The fixed Stage 1a parameters are:

```text
NUM_R1CS_CONSTRAINTS         = 19
OUTER_UNIVARIATE_SKIP_DEGREE = 9
OUTER_UNIVARIATE_SKIP_DOMAIN_SIZE = 10
OUTER_FIRST_ROUND_POLY_NUM_COEFFS = 28
degree bound of s1           = 27
```

The Stage 1a input claim is:

```text
0
```

The verifier challenge is:

```text
r0
```

The Stage 1a exported opening is:

```text
VirtualPolynomial::UnivariateSkip under SumcheckId::SpartanOuter at [r0]
```

### 8.1 Clear-Path Acceptance

In the clear path:

- the prover sends the full coefficient vector of `s1`
- the verifier checks `deg(s1) <= 27`
- the verifier checks:

```text
sum_{y in W} s1(y) = 0
```

- the verifier samples `r0`
- the exported uniskip claim is `s1(r0)`

### 8.2 ZK-Path Acceptance

In the backend-instantiated zk path:

- the prover binds the Stage 1a uni-skip relation and the canonical Stage 1a export under the
  active backend profile
- the verifier checks transcript consistency and the public degree bound required by that backend
  profile
- the prover and verifier both derive `r0` under the same canonical Stage 1 challenge schedule
- the canonical Stage 1 opening surface from Section 3A remains unchanged
- any Pedersen- or BlindFold-specific proof objects are legacy-backend details only

## 9. Stage 1b: Remaining Outer Sumcheck

Stage 1b is a single-instance outer sumcheck with:

```text
num_rounds        = 1 + n
degree bound      = 3
input claim       = s1(r0)
round 0 challenge = r_stream
round 1..n        = r_cycle_LE[0..n-1]
```

At the end of Stage 1b, the clear-path verifier checks:

```text
L_W(tau_high, r0)
*
Eq([tau_cycle_BE || tau_group], [r_cycle_BE || r_stream])
*
Az(r0, r_stream, r_cycle_BE)
*
Bz(r0, r_stream, r_cycle_BE)
```

where:

```text
w_i = i-th Lagrange weight of r0 over W

Az_g0 = sum_{i=0..9} w_i * A_{G0[i]}( Z(r_cycle_BE) )
Bz_g0 = sum_{i=0..9} w_i * B_{G0[i]}( Z(r_cycle_BE) )

Az_g1 = sum_{i=0..8} w_i * A_{G1[i]}( Z(r_cycle_BE) )
Bz_g1 = sum_{i=0..8} w_i * B_{G1[i]}( Z(r_cycle_BE) )

Az = Az_g0 + r_stream * (Az_g1 - Az_g0)
Bz = Bz_g0 + r_stream * (Bz_g1 - Bz_g0)
```

`Z(r_cycle_BE)` is the 35-tuple of Stage 1 virtual-input claims in the canonical order from
Section 3.

In the backend-instantiated zk path, Stage 1b uses the same algebraic relation and the same
exported openings, but the round messages and output bindings are carried by the active backend
profile rather than by direct polynomial evaluation.

## 10. Exported Claims

Stage 1 MUST export the following canonical openings under `SumcheckId::SpartanOuter`:

```text
1. UnivariateSkip at opening point [r0]
2. Each of the 35 Stage 1 virtual inputs at opening point r_cycle_BE
```

The 35 input claims MUST be emitted in exactly the order from Section 3.

These are the Stage 1 outputs consumed by later stages.

An implementation MAY additionally retain supplemental local openings, but those openings are not
part of the canonical exported Stage 1 stream and MUST NOT be used to redefine it.

## 11. Proof Shape

### 11.1 Clear Path

The clear-path Stage 1 proof contribution consists of:

```text
stage1_uni_skip_first_round_proof:
    uni_poly : full coefficient vector of s1

stage1_sumcheck_proof:
    compressed_polys : one compressed round polynomial for each of the 1+n rounds
```

The exported Stage 1 openings are not embedded inside those proof objects. They live in the global
opening-claims stream.

If a local implementation also stores supplemental openings, those extra claims are outside the
canonical Stage 1 proof contribution and MUST NOT alter the clear-path transcript schedule.

### 11.2 ZK Path

The backend-instantiated zk-path Stage 1 proof contribution consists of:

```text
stage1_uni_skip_first_round_proof:
    backend proof object binding the canonical Stage 1a relation and the canonical Stage 1a export

stage1_sumcheck_proof:
    backend proof object binding the canonical Stage 1b relation and the canonical Stage 1 export surface
```

If a legacy Jolt backend profile is explicitly enabled, those proof objects may be realized through
Pedersen commitments and BlindFold-compatible wiring. That legacy shape is not normative for the
SuperNEO profile.

If a local implementation also stores supplemental openings, those extra claims are outside the
canonical zk-path Stage 1 proof contribution and MUST NOT alter the zk-path transcript schedule.

## 12. Transcript Schedule

### 12.1 Clear Path

Relative to the transcript state at Stage 1 entry, the clear path MUST perform:

```text
1. sample tau in F^(n+2)

2. append "uniskip_poly" with the full coefficients of s1
3. sample r0
4. append "opening_claim" with s1(r0)

5. append "sumcheck_claim" with s1(r0)
6. sample one batching coefficient
   note: this still happens even though only one Stage 1b instance is present

7. for each of the 1+n remaining rounds:
   append "sumcheck_poly"
   sample the next round challenge

8. append 35 "opening_claim" scalars in the canonical Stage 1 input order
```

### 12.2 ZK Path

Relative to the transcript state at Stage 1 entry, the backend-instantiated zk path MUST perform:

```text
1. sample tau in F^(n+2)

2. invoke the active backend flow for the canonical Stage 1a uni-skip instance
3. sample r0
4. bind the canonical Stage 1a export block according to the active backend profile

5. sample one Stage 1b batching coefficient

6. for each of the 1+n remaining rounds:
   invoke the backend round flow for the same canonical instance order
   sample the next round challenge

7. bind the canonical Stage 1b exported opening block according to the active backend profile
```

These schedules describe two stage-level proof surfaces over the same Stage 1 algebraic relation.
Under the SuperNEO profile, this file makes the Stage 1 algebraic relation, challenge schedule,
normalized opening points, and canonical export order normative; the backend proof realization is
governed instead by `ZkVmCeBridge.spec.md`,
[ZkVmBridge.CurrentStep.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.CurrentStep.spec.md),
[ZkVmBridge.Frontier.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmBridge.Frontier.spec.md),
and
[ZkVmReduction.SuperNeoAjtai.spec.md](/Users/nicolasarqueros/starstream/develop/halo3/crates/deprecated-neo-fold/specs/ZkVmReduction.SuperNeoAjtai.spec.md).

Supplemental implementation-local openings, if materialized, are off-schedule bookkeeping only.
They MUST NOT inject extra transcript absorbs, commitments, labels, or challenges into Stage 1.

## 13. Conformance Conditions

Two Stage 1 implementations targeting upstream `main` are conformant only if they agree on all of
the following:

```text
- the 35-input canonical order from Section 3
- the absence of standalone Stage 1 inputs WriteLookupOutputToRD and WritePCtoRD
- the exact 19-row uniform R1CS catalog from Section 4
- the exact G0 / G1 partition and order from Section 5
- the base window W = [-4..5]
- tau interpreted as [tau_cycle_BE || tau_group || tau_high]
- remaining-round challenge order [r_stream || r_cycle_LE]
- exported opening point r_cycle_BE = reverse(r_cycle_LE)
- the fact that row 13 is guarded by Jump
- the fact that row 16 is guarded by 1 - ShouldBranch - Jump, not by the complement of ShouldJump
- the Stage 1 clear-path transcript schedule
- the Stage 1 zk-path transcript schedule
- the fact that Stage 1b still samples a batching coefficient even for one instance
- the fact that any supplemental implementation-local openings are off-surface and cannot perturb
  the canonical Stage 1 opening stream
```

Without those fixed points, two implementations can be strategically similar while producing
incompatible Stage 1 proofs.

## 14. Non-Normative Upstream Anchors

This draft follows the executable constants, sampled challenge shapes, and verifier equations of
upstream `main`. Where inline code comments disagree with executable behavior, this draft treats
the comments as stale. In particular, some `outer.rs` comments still describe the carried `tau`
vector as length `1 + n_cycle_vars`, while the actual sampled shape is `n + 2` and matches
Section 6.

- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/r1cs/inputs.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/r1cs/constraints.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/r1cs/key.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/zkvm/spartan/outer.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/subprotocols/univariate_skip.rs`
- `https://raw.githubusercontent.com/a16z/jolt/main/jolt-core/src/subprotocols/sumcheck.rs`

