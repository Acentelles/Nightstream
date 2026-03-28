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
