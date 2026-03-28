# Rv64IMUnsignedDivRemSoundness Spec

## Purpose

- **What it is**: The theorem-facing contract for unsigned `DIVU`, `REMU`, `DIVUW`, and `REMUW`.
- **What it is not**: It is not advice generation and it does not own signed DIV/REM behavior.
- **Protocol role**: It fixes the semantic no-overflow guard and the exact unsigned division/remainder target used by committed sequence proofs.

## Target Formulas

Define:

$$
\mathrm{maxUnsigned64} := 2^{64} - 1.
$$

The unsigned multiplication no-overflow guard is:

$$
\mathrm{MulUNoOverflow}(Q, D) \iff Q \cdot D < 2^{64}.
$$

The unsigned division/remainder semantic target is:

$$
\mathrm{UnsignedDivRemSpec}(N, Q, D, R)
$$

meaning:

- if `D = 0`, then `Q = maxUnsigned64` and `R = N`,
- otherwise `MulUNoOverflow(Q, D)` holds, `N = Q · D + R`, and `R < D`.

## Package

`UnsignedDivRemSoundnessProofPackage` fixes:

- the opcode in `{DIVU, REMU, DIVUW, REMUW}`,
- the committed sequence and touched-state set,
- `dividend`, `divisor`, `quotient`, and `remainder`,
- the `MulUNoOverflow` proof,
- the `UnsignedDivRemSpec` proof,
- determinism of the accepted unsigned DIV/REM witness values.

The module also fixes the theorem-facing decoded-row classifier
`UnsignedDivRemOpcodeBound(row, opcode)`, which ties the semantic opcode to the
exact fetch/decode flags:

- `DIVU`: `isDiv = true`, `isRem = false`, `isWOp = false`
- `REMU`: `isDiv = false`, `isRem = true`, `isWOp = false`
- `DIVUW`: `isDiv = true`, `isRem = false`, `isWOp = true`
- `REMUW`: `isDiv = false`, `isRem = true`, `isWOp = true`

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/UnsignedDivRemSoundness.lean` | Unsigned DIV/REM theorem surface |
| `Nightstream/Rv64IM/Execution/UnsignedDivRemSoundnessInterface.lean` | Theorem-facing re-export surface |

## Proof Obligations

- The committed unsigned DIV/REM sequence proves no modular-wraparound quotient witness is accepted.
- The accepted quotient/remainder pair is deterministic.
- The W-variants inherit the same unsigned theorem surface rather than a separate weaker one.
- The theorem-facing surface must be strong enough to bind the unsigned soundness opcode to the exact decoded-row flags.

## Out of Scope

- signed divisor adjustment
- dividend-sign remainder reconstruction
