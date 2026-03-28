# Chip8RegisterTimeline Spec

## Purpose

- **What it is**: The theorem-facing owner for the register / `I` timeline of
  one authenticated CHIP-8 trace.
- **Key property**: it fixes the exact temporal contract that identifies each
  row's authenticated register pre-state with the Stage-2 `RegVal` timeline at
  time `j`, and each adjacent row's authenticated register post-state with the
  same timeline at time `j+1`.
- **Protocol role**: This is the register-side Stage-2 temporal owner used by
  `Chip8TemporalConsistency`; it does not re-own row-local Stage-2 binding or
  direct cryptographic extraction.

## Target Formulas

Let `trace` be one CHIP-8 execution trace and let

$$
\mathrm{RegVal} : \{0,\dots,16\} \times \mathbb{N} \to \mathbb{N}
$$

be the concrete Stage-2 register timeline, where address `16` denotes `I`.

Define:

$$
\mathrm{RegisterTemporalBoundFrom}(\mathrm{RegVal}, k, trace)
$$

to mean:

- for the head row at absolute time `k`, `pre.v(idx) = RegVal(idx,k)` for all
  `idx ∈ {0,\dots,15}`
- for the head row at absolute time `k`, `pre.i = RegVal(16,k)`
- for every adjacent pair, `post.v(idx) = RegVal(idx,k+1)` and
  `post.i = RegVal(16,k+1)`
- the tail satisfies the same property at absolute time `k+1`

and define:

$$
\mathrm{RegisterTemporalBound}(\mathrm{RegVal}, trace)
:=
\mathrm{RegisterTemporalBoundFrom}(\mathrm{RegVal}, 0, trace).
$$

Define the adjacent register/I handoff law:

$$
\mathrm{RegisterAdjacentBound}(current,next)
$$

to mean:

$$
current.post.i = next.pre.i
\land
\forall idx,\; current.post.v(idx) = next.pre.v(idx).
$$

The core theorem target is:

$$
\mathrm{RegisterTemporalBoundFrom}(\mathrm{RegVal}, k, current :: next :: rest)
\Longrightarrow
\mathrm{RegisterAdjacentBound}(current,next).
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/RegisterTimeline.lean` | Register / `I` temporal contract for one trace |
| `Nightstream/Chip8/RegisterTimelineInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Temporal | `RegisterValueTimeline` | abbrev | Definitional | Canonical register / `I` timeline type |
| Temporal | `RegisterTemporalBoundFrom` | def | Definitional | Absolute-time register / `I` trace contract |
| Temporal | `RegisterTemporalBound` | def | Definitional | Trace-start-at-zero specialization |
| Temporal | `RegisterAdjacentBound` | def | Definitional | One-step register / `I` handoff law |
| Theorem | `registerAdjacentBound_of_registerTemporalBoundFrom` | theorem | Theorem-Target | Timeline consistency yields one adjacent register / `I` link |

## Proof Obligations

- This owner must use the exact CHIP-8 mutable register state:
  `V[0..15]` and `I`.
- It must not weaken the contract to only the active `x`/`y` registers.
- It must not re-own RAM or `pc` continuity.

## Dependency and Consumer Map

- **Upstream dependencies**:
  - `Chip8WitnessMemoryBinding`
  - `Chip8ExecutionSemantics`
- **Downstream consumers**:
  - `Chip8TemporalConsistency`
  - any stronger trace closure that needs exact register / `I` handoff
