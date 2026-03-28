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
