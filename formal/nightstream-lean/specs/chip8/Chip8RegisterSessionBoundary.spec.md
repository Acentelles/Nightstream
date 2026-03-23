# Chip8RegisterSessionBoundary Spec

## Purpose

- **What it is**: the theorem-facing owner for the concrete register-side
  Stage-2 session-key surface used by the simple CHIP-8 kernel boundary.
- **Key property**: the register session-key domain is explicit and includes the
  sink slot `⊥_reg = 17`; sink-routed `regRaY` / `regWa` roles are part of the
  same closed authenticated register registry rather than an external side
  channel.
- **Protocol role**: this owner sits between decode-address binding and the
  generic Twist session-closure machinery. It does not re-own the generic
  closure theorem; it fixes the CHIP-8-local register key shape and the exact
  role-to-key constructors consumed by higher Stage-2 owners.

## Target Formulas

Define the concrete register-side key:

$$
\mathrm{RegisterSessionKey} = (\mathrm{cycleIndex}, \mathrm{regAddr})
$$

with admissible address domain:

$$
\mathrm{regAddr} \in \{0,\dots,15\} \cup \{16\} \cup \{17\}.
$$

Interpretation:

- `0..15` are `V[0]..V[15]`;
- `16` is the distinguished `I` slot;
- `17` is the sink slot `⊥_reg`.

This owner defines the exact role-local constructors:

- `regRaXKey(stepIdx, dec)`
- `regRaYKey(stepIdx, dec)`
- `regRaIKey(stepIdx, dec)`
- `regWaKey(stepIdx, dec)`

and proves the CHIP-8-local sink rules:

- `regRaYKey(stepIdx, dec).regAddr = 17` iff `dec.usesY = 0`
- `regWaKey(stepIdx, dec).regAddr = 17` iff the row performs no register write

It also proves the corresponding key-bound facts saying these constructors
always land in the admissible register session-key domain under the same
decode/address-shape hypotheses already used by the Stage-1 and Stage-2 owners.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Stage2/RegisterSessionBoundary.lean` | Concrete register-side Stage-2 session-key domain and role-to-key constructors |
| `Nightstream/Chip8/Stage2/RegisterSessionBoundaryInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Key | `RegisterSessionKey` | structure | Definitional | Concrete register-side session key `(cycleIndex, regAddr)` |
| Key | `RegisterSessionKeyBound` | def | Definitional | Admissible key domain includes active slots, `I`, and `⊥_reg` |
| Constructor | `regRaXKey` | def | Definitional | Concrete session key for the `regRaX` role on one row |
| Constructor | `regRaYKey` | def | Definitional | Concrete session key for the `regRaY` role on one row |
| Constructor | `regRaIKey` | def | Definitional | Concrete session key for the `regRaI` role on one row |
| Constructor | `regWaKey` | def | Definitional | Concrete session key for the `regWa` role on one row |
| Theorem | `regRaXKey_bound_of_activeXIndexBound` | theorem | Theorem-Target | The `regRaX` key lands in the admissible register domain |
| Theorem | `regRaYKey_bound_of_shape` | theorem | Theorem-Target | The `regRaY` key lands in the admissible register domain |
| Theorem | `regRaYKey_sink_iff_not_usesY` | theorem | Theorem-Target | `regRaY` uses the sink exactly on `usesY = 0` rows |
| Theorem | `regRaIKey_is_i` | theorem | Theorem-Target | `regRaI` always names the distinguished `I` slot |
| Theorem | `regWaKey_bound_of_shape` | theorem | Theorem-Target | The `regWa` key lands in the admissible register domain |
| Theorem | `regWaKey_sink_iff_no_lane_write` | theorem | Theorem-Target | `regWa` uses the sink exactly on rows with no register write |

## Proof Obligations

- This owner must stay register-side and key-shape-only.
- It must not weaken sink routing into a prose convention.
- It must not re-own generic Twist registry closure or whole-trace temporal
  reconstruction.
