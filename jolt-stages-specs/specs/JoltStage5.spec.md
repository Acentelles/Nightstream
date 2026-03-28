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
