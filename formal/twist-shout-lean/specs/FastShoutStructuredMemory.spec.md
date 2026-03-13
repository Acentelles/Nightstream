# FastShoutStructuredMemory

## Purpose

Specify the Section 7 prover specialization for Shout on large structured memories.

## Target Formulas

- The structured-memory evaluation identities from Section 7.
- Equivalence between the structured prover path and the core Shout claim it accelerates.

## Paper Anchors

- `docs/twist-and-shout-paper/7_fast_shout_prover_for_large_structured_memories.md`

## Module Mapping

- Spec: `specs/FastShoutStructuredMemory.spec.md`
- Interface: `TwistShout/FastShoutStructuredMemoryInterface.lean`
- Implementation: `TwistShout/FastShoutStructuredMemory.lean`

## Contract Surface

- Definitions for the structured-memory prover objects and evaluation path.
- Theorems that the specialized prover preserves the Shout protocol relation.
- Boundary results connecting structured table access to verifier-visible queries.

## Boundary Assumptions

- The memory family satisfies the structure hypotheses stated in Section 7.
- The underlying Shout read-check and one-hot relations are already available.

## Dependency and Consumer Map

- Depends on: `ShoutCore`, `ShoutOneHot`, `MLE`, `SumCheck`.
- Consumed by: `SpeedySpartan` and any later structured-memory integration layer.

## Out of Scope

- Unstructured small-memory specializations from Section 6.
- Twist-specific stateful-memory arguments.
