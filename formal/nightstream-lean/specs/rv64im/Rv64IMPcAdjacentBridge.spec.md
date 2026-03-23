# Rv64IMPcAdjacentBridge Spec

## Purpose

- **What it is**: The theorem-facing contract for the Stage-3 PC adjacency bridge.
- **What it is not**: It is not the full continuity prover and it does not define register or RAM state closure.
- **Protocol role**: It fixes the exact statement that the PC projection of `PostState(j)` equals the PC projection of `PreState(j+1)` for every active adjacent pair.

## Target Formulas

Fix:

- `postPc : Nat → Pc`
- `prePc : Nat → Pc`
- `semanticRows : Nat`

The bridge target is:

$$
\mathrm{PcAdjacentBridge}(\mathrm{postPc},\ \mathrm{prePc},\ \mathrm{semanticRows})
$$

meaning:

$$
\forall j,\ j + 1 < \mathrm{semanticRows}
\Longrightarrow
\mathrm{postPc}(j) = \mathrm{prePc}(j + 1).
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/PcAdjacentBridge.lean` | PC-adjacent bridge theorem surface |
| `Nightstream/Rv64IM/Execution/PcAdjacentBridgeInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Guarantee |
|---|---|---|---|
| Semantics | `PcAdjacentBridge` | def | States exact adjacent PC equality |
| Package | `PcAdjacentBridgeProofPackage` | structure | Packages the bridge theorem target |

## Proof Obligations

- The bridge ranges over the exact active semantic prefix `[0, N)`.
- The bridge is separate from register/RAM temporal closure and from root-row export.

## Out of Scope

- register history
- RAM history
- expanded-bytecode successor
