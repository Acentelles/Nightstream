# ShoutProtocol

## Purpose

Collect the theorem-facing modules that make up the paper's Shout layer.

## Paper Anchors

- `docs/twist-and-shout-paper/4_the_shout_piop.md`
- `docs/twist-and-shout-paper/6_fast_shout_prover_implementation_small_memories.md`
- `docs/twist-and-shout-paper/7_fast_shout_prover_for_large_structured_memories.md`
- `docs/twist-and-shout-paper/C_a_shout_variation_with_a_linear_prover_dependence_on_d.md`

## Modules re-exported

- `TwistShout/ShoutCore.lean`
- `TwistShout/ShoutOneHot.lean`
- `TwistShout/FastShoutSmallMemory.lean`
- `TwistShout/FastShoutStructuredMemory.lean`
- `TwistShout/ShoutLinearVariant.lean`

## Contract Surface

- Re-export the core Shout relation, the one-hot enforcement layer, and the paper's Shout prover variants.
- Preserve the dependency boundary from Shout to shared preliminaries and to downstream applications.

## Out of Scope

- Twist's read-write memory protocol.
- SuperNeo-specific integration theorems.
