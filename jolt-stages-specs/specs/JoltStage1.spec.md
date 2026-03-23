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
