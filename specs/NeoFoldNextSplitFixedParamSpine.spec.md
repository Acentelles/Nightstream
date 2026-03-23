# NeoFoldNextSplitFixedParamSpine

## Purpose

Define the exact main-lane folding protocol implemented by:

- `crates/neo-fold-next`
- `crates/neo-reductions`

This is an implementation-owned audit spec. It states the protocol that the
repo verifier actually checks.

## Scope

This spec owns:

- one-step main-lane proving and verification
- the carried CE state between steps
- the explicit `Π_CCS -> Π_RLC -> Π_DEC` spine
- packaged proof binding and digest checks

This spec does not own:

- zkVM frontend construction beyond `StepInput`
- Twist or Shout sibling-family proofs
- output binding
- grouped opening or joint-opening families
- a proof that the split `Π_CCS` variant is equivalent to the paper's single
  sumcheck presentation

## Baseline

The mathematical baseline is Section 7 of
`docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`.

The repo variant keeps the same top-level reduction order:

- `Π_CCS`
- `Π_RLC`
- `Π_DEC`

and keeps the paper-faithful security parameter shape:

- one global `k_rho`
- one global `B = b^{k_rho}`
- one fixed `Π_DEC` child count equal to `k_rho`

## Named Variant

The repo main lane is the following named variant:

- `Π_CCS.SplitNcV1`
- `Π_RLC.FixedParams`
- `Π_DEC.FixedK`

The run layer applies that spine once per `StepInput` and carries the
resulting bounded CE children into the next step.

## Paper Deltas

These deltas are part of the protocol definition for this repo.

### 1. `Π_CCS` is split

The paper presents one sumcheck over one polynomial `Q`.

The repo variant uses two transcript-separated sumchecks:

- an FE channel for the CCS and evaluation part
- an NC-only channel for the digit-range / norm-check path

The NC channel exposes:

- `s_col`
- `y_zcol`

and both become part of the CE claim shape used by later reductions.

### 2. CE claims carry repo-level public fields

The paper CE relation is shaped around:

- commitment `c`
- public input `x`
- evaluation point `r`
- ring evaluations `{y_j}`

The repo CE claim additionally carries:

- `X`
- `s_col`
- `ct`
- `y_zcol`
- `aux_openings`
- `fold_digest`
- `c_step_coords`
- `u_offset`
- `u_len`

Only some of these are paper-core. The others are repo-level CE fields that the
verifier binds and checks explicitly.

### 3. Deferred extension families are metadata only

`StepInput.deferred_extensions` are bound into proof packaging and checked
for equality across prove and verify.

They are not themselves proven by this spine.

This spec treats them as declared sibling-family metadata, not as satisfied
subrelations.

## Fixed Security Parameters

These are hard rules for the main-lane shard wrapper.

### `k_rho` is global

`params.k_rho` is the global folding and decomposition exponent.

It determines:

- the Ajtai post-RLC norm budget `B = b^{k_rho}`
- the fixed `Π_DEC` output width

The shard wrapper must not raise `k_rho` from the instance shape.

### `Π_RLC` uses the caller-provided params as-is

The shard wrapper samples `ρ_i` using the supplied `NeoParams`.

If the requested input count violates the fixed parameter guard already encoded
in `NeoParams`, proving must fail.

The shard wrapper must not widen `k_rho` at prove time or verify time.

### `Π_DEC` emits exactly `k_rho` children

The main-lane `Π_DEC` step always decomposes into exactly:

- `params.k_rho`

children.

If the mixed witness cannot be represented in that fixed balanced base-`b`
width, proving must fail.

## Core Objects

### `StepInput`

A step-local proving input containing:

- `label`
- one CCS claim `mcs`
- its witness
- declared deferred extension families

### `Carry`

The carried main-lane state between steps:

- `claims: Vec<CeClaim<...>>`
- `witnesses: Vec<Mat<F>>`

Hard rule:

- `claims.len() == witnesses.len()`

### `StepProof`

One proved step artifact containing:

- public step metadata
- `Π_CCS` outputs and proof
- `Π_RLC` challenges and parent CE claim
- `Π_DEC` child CE claims

## One-Step Contract

One main-lane step starts from:

- one `StepInput`
- zero or more carried CE claims and witnesses
- a live transcript state

One main-lane step ends with:

- one `StepProof`
- next carried CE claims equal to the `Π_DEC` children
- next carried witnesses equal to the digit-split child witness matrices

## Step Protocol

### Phase 1. `Π_CCS.SplitNcV1`

Inputs:

- one fresh MCS claim and witness
- zero or more carried CE claims and witnesses

Shape:

- if the carry is empty, prove with `prove_simple`
- otherwise prove with `prove`

The prover and verifier both bind:

- CCS header
- MCS instances
- incoming CE instances

The prover and verifier both sample transcript challenges for:

- FE channel
- NC channel

The FE channel:

- uses the public claimed sum `T` derived from the incoming CE inputs
- drives the CCS/evaluation sumcheck
- outputs a new row point `r'`

The NC channel:

- runs as a separate sumcheck
- uses claimed sum `0`
- outputs a new column-side point `s_col`

The `Π_CCS` output family has size:

- `1 + incoming_main.claims.len()`

Output ordering is:

- first the fresh step MCS-derived CE claim
- then the carried CE claims rewritten at the new transcript-derived point

Each output CE claim must satisfy:

- `r == r'`
- `s_col == s_col'`
- `fold_digest == header_digest`

MCS-derived outputs must expose `X` recomposed from public `x`.

Carried CE outputs keep their existing public `X`.

### Phase 2. `Π_RLC.FixedParams`

Inputs:

- the `Π_CCS` output CE family
- the aligned witness matrices for that family

Challenge sampling:

- sample `ρ_i` from the strict Goldilocks strong set using the supplied
  `NeoParams`
- do not widen `k_rho`

If the requested input count exceeds what the fixed params allow, proving fails.

The parent CE claim is formed by ring-linear mixing of:

- commitments
- `X`
- `y_ring`
- optional `y_zcol`

The parent CE claim keeps shared fields:

- common `r`
- common `s_col`
- `fold_digest` copied from the input family

`aux_openings` are mixed by the scalar projection of each `ρ_i` onto:

- `rho[(0, 0)]`

This is a repo-level CE rule, not a paper-core rule.

The mixed witness is:

- `Z_mix = Sigma rho_i * Z_i`

### Phase 3. `Π_DEC.FixedK`

Inputs:

- one parent CE claim
- one mixed witness matrix `Z_mix`

The shard wrapper sets:

- `k_dec = params.k_rho`

Then it splits:

- `Z_mix = Sigma b^i * Z_i`

using exactly that fixed width and balanced digits in the symmetric base-`b`
range.

If the split does not fit in the fixed width, proving fails.

Child commitments are constructed as follows:

- non-zero child witnesses are committed explicitly
- zero child witnesses reuse the zero commitment

The public `Π_DEC` checks must hold component-wise across the radix-`b`
recomposition ladder for:

- `X`
- `y_ring`
- `ct`
- `aux_openings`
- optional `y_zcol`
- commitment

The next carried state is:

- `claims = children`
- `witnesses = Z_split`

The child count is always:

- `params.k_rho`

## Session Rule

`run::prove_run` applies the one-step contract sequentially over all input
steps.

The only carried state threaded across steps is:

- `Carry`
- transcript state

After the first step, the main carry width is fixed at:

- `params.k_rho`

and every later main-lane `Π_CCS` call sees:

- one fresh MCS claim
- `params.k_rho` carried CE claims

So the steady-state `Π_RLC` fan-in is:

- `params.k_rho + 1`

The final run output is:

- `steps: Vec<StepProof>`
- `carried_claims`

where `carried_claims` must equal the carry after the last step.

## Finalization Rule

The packaged proof layer packages:

- all public step instances
- all per-step proof artifacts
- final carried CE claims

into:

- one public statement digest
- one proof digest

The digests are Poseidon2-based and bind:

- step labels
- MCS claims
- deferred extension metadata
- CE claims
- `Π_CCS` proof data
- `Π_RLC` challenges and parent
- `Π_DEC` children
- final carried CE claims

Verification of a packaged proof must:

1. recompute the statement digest
2. recompute the proof digest
3. rerun run verification
4. check that the verified final carry equals the public statement carry

## Hard Invariants

These are mandatory review rules for this variant.

1. `Π_CCS` output count is exactly `1 + incoming carry count`.
2. All CE claims entering one `Π_RLC` call share the same `r`.
3. `Π_CCS` output `fold_digest` equals the transcript-derived header digest.
4. If a CE claim carries the NC channel, it must carry both:
   `s_col` and `y_zcol`.
5. The shard wrapper never widens `params.k_rho`.
6. `Π_DEC` emits exactly `params.k_rho` children.
7. `Π_DEC` children must recombine to the parent for every public channel the
   parent exposes.
8. Deferred extension families are declarations only unless another proof object
   proves them.

## Out-of-Scope Claims

This spec does not claim:

- that `SplitNcV1` is theorem-equivalent to the single-sumcheck Section 7
  protocol
- that the repo CE wrapper fields are part of the paper CE surface
- that deferred extension families are satisfied by the main-lane proof

Those claims require separate proof or a different spec.
