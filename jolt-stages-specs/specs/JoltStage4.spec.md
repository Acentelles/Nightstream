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
