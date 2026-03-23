# Rv64IMSignedDivRemSoundness Spec

## Purpose

- **What it is**: The theorem-facing contract for signed `DIV*` / `REM*` lowerings.
- **What it is not**: It is not the concrete advice witness generation algorithm.
- **Protocol role**: It fixes the exact semantic targets for signed DIV/REM closure: divisor adjustment in the unique overflow case, remainder reconstruction from the dividend sign, and satisfaction of `SIGNED_DIVREM_SPEC`.

## Target Formulas

The change-divisor target is:

$$
\mathrm{ChangeDivisorCorrect}(N,\ D,\ D')
$$

meaning:

$$
D' =
\begin{cases}
1 & \text{if } N = -2^{63} \land D = -1 \\
D & \text{otherwise.}
\end{cases}
$$

The remainder-sign target is:

$$
\mathrm{RemainderFromDividendSign}(N,\ R_{abs},\ R_{signed})
$$

meaning:

$$
R_{signed} =
\begin{cases}
-R_{abs} & \text{if } N < 0 \\
R_{abs} & \text{otherwise.}
\end{cases}
$$

The main semantic target is:

$$
\mathrm{SignedDivRemSpec}(N,\ Q,\ D,\ R_{signed}).
$$

The module also fixes the signed opcode carrier
`SignedDivRemOpcode ∈ {DIV, REM, DIVW, REMW}` and the theorem-facing decoded-row
classifier `SignedDivRemOpcodeBound(row, opcode)`, which ties the semantic
opcode to the exact fetch/decode flags:

- `DIV`: `isDiv = true`, `isRem = false`, `isWOp = false`
- `REM`: `isDiv = false`, `isRem = true`, `isWOp = false`
- `DIVW`: `isDiv = true`, `isRem = false`, `isWOp = true`
- `REMW`: `isDiv = false`, `isRem = true`, `isWOp = true`

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/SignedDivRemSoundness.lean` | Signed DIV/REM theorem surface |
| `Nightstream/Rv64IM/Execution/SignedDivRemSoundnessInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Semantics | `ChangeDivisorCorrect` | def | Fixes the unique signed-overflow divisor adjustment |
| Semantics | `RemainderFromDividendSign` | def | Fixes dividend-sign-based remainder reconstruction |
| Semantics | `SignedDivRemSpec` | def | States the signed division/remainder semantic target |
| Semantics | `SignedDivRemOpcode` | inductive | Fixes the exact signed DIV/REM opcode |
| Semantics | `SignedDivRemOpcodeBound` | def | Binds the signed opcode to the decoded-row flags |
| Package | `SignedDivRemProofPackage` | structure | Packages the accepted signed DIV/REM proof obligations |

## Proof Obligations

- The overflow-case divisor adjustment is unique and deterministic.
- Signed remainder reconstruction uses the dividend sign, not the divisor sign.
- The accepted theorem package includes the semantic target, not just auxiliary lookup validity.
- Signed DIV/REM soundness is distinct from the unsigned no-overflow package and composes with it rather than replacing it.
- The theorem-facing surface must be strong enough to bind the signed soundness opcode to the exact decoded-row flags.

## Derived Consequences

From `SignedDivRemProofPackage` one must be able to extract:

- the signed opcode in `{DIV, REM, DIVW, REMW}`,
- `ChangeDivisorCorrect(dividend, divisor, changedDivisor)`,
- `RemainderFromDividendSign(dividend, remainderAbs, remainderSigned)`,
- `SignedDivRemSpec(dividend, quotient, divisor, remainderSigned)`.

## Out of Scope

- concrete row list for one opcode
- advice generation internals
