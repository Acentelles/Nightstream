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
