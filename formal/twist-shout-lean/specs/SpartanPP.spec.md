# SpartanPP

## Purpose

Specify the paper's Spartan++ application built on the Twist/Shout memory-argument layer.

## Target Formulas

- The Section 9 application-level construction and theorem statements labeled as Spartan++.
- The bridge from the underlying memory-argument surfaces to the resulting Spartan++ claim.

## Paper Anchors

- `docs/twist-and-shout-paper/9_faster_snarks_for_non_uniform_computation.md`

## Module Mapping

- Spec: `specs/SpartanPP.spec.md`
- Interface: `TwistShout/SpartanPPInterface.lean`
- Implementation: `TwistShout/SpartanPP.lean`

## Contract Surface

- Definitions for the paper's Spartan++ construction.
- Theorems that reduce the application claim to the required Shout/Twist theorem boundaries.
- Boundary statements for any application-specific oracle or batching interfaces.

## Boundary Assumptions

- The required Shout and Twist theorem surfaces are available exactly as used in Section 9.
- Any application-specific public data and commitments satisfy the paper's hypotheses.

## Dependency and Consumer Map

- Depends on: the relevant Shout/Twist core modules and their fast-prover refinements.
- Consumed by: top-level application barrels and any later system-integration bridge.

## Out of Scope

- Standalone proof of the underlying memory arguments.
- Application variants not identified as Spartan++ in the paper.
