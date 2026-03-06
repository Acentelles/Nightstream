# ProtocolTarget Spec

## Purpose

- **What it is**: A layer that binds Theorem 3 and arithmetic obligations into one target context (`ProtocolTargetContext`), then derives the core target proposition `protocolTargetProp` used by protocol relations.
- **Key property**: both `ProtocolTargetAssumptions ctx → protocolTargetProp ctx` and `ProtocolTargetNativeAssumptions ctx → protocolTargetProp ctx`; the target proposition conjoins thm3, split terminal zero, eval homomorphism, module assumptions, sampling, MLE identity, interpolation, and invertibility.
- **Protocol role**: ProtocolRelations uses `protocolTargetProp` to define CCS/CE relations; PiCCS and downstream reductions depend on this target.

## Target Formulas (Paper → Lean)

- `protocolTargetProp ctx ↔ thm3CoreAssumption ctx.bar ∧ splitBase2TerminalZeroProp ctx.splitScalar ctx.kSplit ∧ evalHomAssumption ... ∧ vecModuleAssumption ... ∧ scalarModuleAssumption ... ∧ samplingExpansionProp ... ∧ qVals.size = 2^r.size ∧ mleEval qVals r = mleInnerProductForm qVals r ∧ interpolationProp ... ∧ invertibleRq ctx.invDelta`
- `ProtocolTargetAssumptions ctx → protocolTargetProp ctx`
- `ProtocolTargetNativeAssumptions ctx → protocolTargetProp ctx`

## Paper Anchors

- Source: `./formal/superneo-lean/SuperNeo.pdf.md`
- Anchors:
  - Section 7 (Neo's folding scheme for CCS), lines 447–481: Relations (Definitions 11–13), Global Reduction Parameters (Definition 14)
  - Section 7.3 (Π_CCS), lines 481–547: Interactive reduction for CCS

## Module Mapping

- Implementation: `SuperNeo.ProtocolTarget`
- Interface: `SuperNeo.ProtocolTargetInterface`

## Contract Surface

| Contract group | Lean surface | Preconditions | Guarantee | Role | Used by |
|---|---|---|---|---|---|
| Context | `ProtocolTargetContext` | None | Bundles bar, m, r, rho1, rho2, hVec, hScal, splitScalar, kSplit, invDelta, cset, samples, xs, ys, qVals, coeffs, xEval, expectedEval | Definitional | ProtocolRelations, PiCCS |
| Assumptions | `ProtocolTargetAssumptions ctx` | None | Bundles thm3, arithmetic (ArithmeticObligations), direct witness `invertibleRq ctx.invDelta` | Definitional | — |
| Assumptions | `ProtocolTargetNativeAssumptions ctx` | `ctx.bar = nativeBarMatrix` | Bundles native bar equality, arithmetic (ArithmeticObligations), direct witness `invertibleRq ctx.invDelta` | Definitional | ProtocolRelations native path |
| Compatibility | `ProtocolTargetAssumptions.of_lowNormBoundary` / `ProtocolTargetNativeAssumptions.of_lowNormBoundary` | low-norm boundary + arithmetic window | Derives direct `invertibleRq` witness from low-norm boundary | Theorem-Target | Legacy assumption wiring |
| Target prop | `protocolTargetProp ctx` | None | Conjunction of all protocol-target predicates | Definitional | ProtocolRelations |
| Derivation | `protocolTargetProp_of_assumptions` | `ProtocolTargetAssumptions ctx` | `protocolTargetProp ctx` | Theorem-Target | ProtocolRelations |
| Derivation | `protocolTargetProp_of_native_assumptions` | `ProtocolTargetNativeAssumptions ctx` | `protocolTargetProp ctx` | Theorem-Target | ProtocolRelations native path |

## Proof Obligations and Closure Plan

All local obligations closed. `protocolTargetProp_of_assumptions` and `protocolTargetProp_of_native_assumptions` derive the target from their bundles using direct `invertibleRq` witnesses.

## Assumption Ledger

No open proof obligations inside this module. Native closure still depends on upstream `thm3CoreAssumption_native` (declared in `Thm3Core`).

## Dependency and Consumer Map

- Upstream dependencies:
  - `SuperNeo/Thm3Core.lean`: imports `thm3CoreAssumption`
  - `SuperNeo/ArithmeticObligations.lean`: uses `ArithmeticObligations` for arithmetic bundle
- Downstream consumers:
  - `SuperNeo/ProtocolRelations.lean`: uses `protocolTargetProp`, `protocolTargetProp_of_assumptions`, `ProtocolTargetContext` to define CCS/CE relations
  - `SuperNeo/PiCCS.lean`: depends on ProtocolRelations
  - `SuperNeo/ProtocolTheorem.lean`: uses `ProtocolTargetContext` for final theorem shape

## Implementation Plan

1. `ProtocolTargetContext` structure holds all protocol parameters.
2. `ProtocolTargetAssumptions` bundles thm3, arithmetic obligations, and low-norm invertibility.
3. `ProtocolTargetNativeAssumptions` bundles `ctx.bar = nativeBarMatrix`, arithmetic obligations, and low-norm invertibility.
4. `protocolTargetProp` defined as conjunction of target predicates.
5. `protocolTargetProp_of_assumptions` and `protocolTargetProp_of_native_assumptions` proved by projection + low-norm invertibility.

## Quality Expectations

- No `sorry` in any theorem.
- All declarations proved natively.

## Acceptance Criteria

1. `lake build` succeeds.
2. `lake exe check` succeeds.
3. All surfaces exported through the interface.

## Out of Scope

- Concrete instantiation of `ProtocolTargetAssumptions` / `ProtocolTargetNativeAssumptions`; that belongs to protocol setup.
- `matrixTransformAssumption_of_thm3CoreAssumption` is re-exported from MatrixTransform for consumers; closure is in MatrixTransform.
