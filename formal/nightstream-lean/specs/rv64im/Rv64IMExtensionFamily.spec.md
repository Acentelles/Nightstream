# Rv64IMExtensionFamily Spec

## Purpose

- **What it is**: The concrete extension-family inventory for the RV64IM Nightstream kernel.
- **What it is not**: It is not a proof of RV64IM execution semantics and it does not define stage-local witnesses.
- **Protocol role**: It fixes the exact family names that the RV64IM release bridge classifies into canonical stages.

## Target Formulas

Define the concrete RV64IM extension-family type:

$$
\mathrm{ExtensionFamily}_{\mathrm{Rv64IM}}
\in
\{\mathrm{fetch},\ \mathrm{executionRow},\ \mathrm{aluSubtables},\ \mathrm{branchCondition},\ \mathrm{registerHistory},\ \mathrm{ramHistory}\}.
$$

These families name the exact external proof owners:

- `fetch`: readonly ROM fetch authentication
- `executionRow`: readonly execution-row authentication against the committed per-program execution table
- `aluSubtables`: readonly Stage-1 byte-level ALU subtable authentication
- `branchCondition`: readonly Stage-1 branch-condition authentication
- `registerHistory`: Stage-2 register Twist history
- `ramHistory`: Stage-2 RAM Twist history

The following proof owners are intentionally **not** modeled by this family
inventory because they are theorem surfaces rather than release-family ids:

- expanded-bytecode start/successor binding,
- Stage-2 temporal closure,
- PC-adjacent bridge,
- opening provenance / row binding,
- final-boundary claim.

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Family type | `Nightstream.Rv64IM.ExtensionFamily` | inductive | Definitional | Fixes the exact family inventory for RV64IM bridge classification |

## Dependency and Consumer Map

- **Depends on**:
  - no upstream Nightstream VM-local modules
- **Consumed by**:
  - `Nightstream/Rv64IM/ReleaseBridge.lean`
  - later RV64IM stage-local projection owners

## Proof Obligations

- The family inventory must be finite and explicit.
- Every later RV64IM release-stage and staged-bridge theorem must classify only these concrete family ids.

## Out of Scope

- stage order
- prepared-step export
- execution semantics
- transcript / PCS instantiation
- successor / provenance theorem surfaces
