# EqPoly

## Purpose

Specify the multilinear equality polynomial `eq~(x, b)` used to interpolate Boolean-cube data.

## Target Formulas

- Equation (15): `eq~(x, b) = ∏_i (x_i b_i + (1 - x_i)(1 - b_i))`.
- Boolean-cube indicator law: on Boolean points, `eq~(x, b)` is `1` when `x = b` and `0` otherwise.

## Paper Anchors

- `docs/twist-and-shout-paper/3_technical_preliminaries.md`
- `docs/twist-and-shout-ai-summary.md`

## Module Mapping

- Spec: `specs/EqPoly.spec.md`
- Interface: `TwistShout/EqPolyInterface.lean`
- Implementation: `TwistShout/EqPoly.lean`

## Contract Surface

- A field-parametric definition of the multilinear equality polynomial.
- Boolean-point indicator theorems and normalization lemmas.
- Factorization lemmas consumed by multilinear extension and sum-check modules.

## Boundary Assumptions

- The ambient scalar carrier is a field.
- Boolean indices are represented as finite bit-tuples.

## Dependency and Consumer Map

- Depends on: field-parametric algebra and finite Boolean-cube indexing.
- Consumed by: `MLE`, `SumCheck`, `ShoutCore`, `TwistCore`, `TwistValueEval`.

## Out of Scope

- Goldilocks-specific instantiations.
- SuperNeo protocol-specific reductions or security claims.
