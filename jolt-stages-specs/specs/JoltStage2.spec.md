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
