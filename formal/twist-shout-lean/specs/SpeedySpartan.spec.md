# SpeedySpartan

## Purpose

Specify the paper's SpeedySpartan application built on the Shout memory-argument layer.

## Target Formulas

- The application-level construction and theorem statements in Section 9 that use Shout as a subprotocol.
- The bridge from the Shout theorem surface to the resulting SpeedySpartan claim.

## Paper Anchors

- `docs/twist-and-shout-paper/9_faster_snarks_for_non_uniform_computation.md`

## Module Mapping

- Spec: `specs/SpeedySpartan.spec.md`
- Interface: `TwistShout/SpeedySpartanInterface.lean`
- Implementation: `TwistShout/SpeedySpartan.lean`

## Contract Surface

- Definitions for the paper's SpeedySpartan construction.
- Theorems that reduce the application claim to Shout protocol assumptions and conclusions.
- Boundary statements for any application-specific batching or oracle interfaces.

## Boundary Assumptions

- The Shout theorem surfaces used by the application are available exactly as required by Section 9.
- Any application-specific commitments or public tables satisfy the paper's hypotheses.

## Dependency and Consumer Map

- Depends on: `ShoutCore`, `ShoutOneHot`, and the relevant fast-prover Shout variant.
- Consumed by: top-level application barrels and any later system-integration bridge.

## Out of Scope

- Standalone proof of Shout itself.
- Twist-based applications not identified as SpeedySpartan in the paper.
