# Chip8RamTimeline Spec

## Purpose

- **What it is**: The theorem-facing owner for the RAM timeline of one
  authenticated CHIP-8 trace.
- **Key property**: it fixes the exact temporal contract that identifies each
  row's authenticated RAM pre-state with the Stage-2 `RamVal` timeline at time
  `j`, and each adjacent row's authenticated RAM post-state with the same
  timeline at time `j+1`.
- **Protocol role**: This is the RAM-side Stage-2 temporal owner used by
  `Chip8TemporalConsistency`; it does not re-own row-local Stage-2 binding or
  cryptographic extraction.

## Target Formulas

Let `trace` be one CHIP-8 execution trace and let

$$
\mathrm{RamVal} : \{0,\dots,4095\} \times \mathbb{N} \to \mathbb{N}
$$

be the concrete Stage-2 RAM timeline.

Define:

$$
\mathrm{RamTemporalBoundFrom}(\mathrm{RamVal}, k, trace)
$$

to mean:

- for the head row at absolute time `k`, `pre.ram(addr) = RamVal(addr,k)` for
  every active CHIP-8 RAM address
- for every adjacent pair, `post.ram(addr) = RamVal(addr,k+1)` for every RAM
  address
- the tail satisfies the same property at absolute time `k+1`

and define:

$$
\mathrm{RamTemporalBound}(\mathrm{RamVal}, trace)
:=
\mathrm{RamTemporalBoundFrom}(\mathrm{RamVal}, 0, trace).
$$

Define the adjacent RAM handoff law:

$$
\mathrm{RamAdjacentBound}(current,next)
:=
\forall addr,\; current.post.ram(addr) = next.pre.ram(addr).
$$

The core theorem target is:

$$
\mathrm{RamTemporalBoundFrom}(\mathrm{RamVal}, k, current :: next :: rest)
\Longrightarrow
\mathrm{RamAdjacentBound}(current,next).
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/RamTimeline.lean` | RAM temporal contract for one trace |
| `Nightstream/Chip8/RamTimelineInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Temporal | `RamValueTimeline` | abbrev | Definitional | Canonical RAM timeline type |
| Temporal | `RamTemporalBoundFrom` | def | Definitional | Absolute-time RAM trace contract |
| Temporal | `RamTemporalBound` | def | Definitional | Trace-start-at-zero specialization |
| Temporal | `RamAdjacentBound` | def | Definitional | One-step RAM handoff law |
| Theorem | `ramAdjacentBound_of_ramTemporalBoundFrom` | theorem | Theorem-Target | Timeline consistency yields one adjacent RAM link |

## Proof Obligations

- This owner must range over the whole CHIP-8 RAM surface, not only the
  current read/write port.
- It must not re-own register / `I` or `pc` continuity.

## Dependency and Consumer Map

- **Upstream dependencies**:
  - `Chip8WitnessMemoryBinding`
  - `Chip8ExecutionSemantics`
- **Downstream consumers**:
  - `Chip8TemporalConsistency`
  - any stronger trace closure that needs exact RAM handoff
