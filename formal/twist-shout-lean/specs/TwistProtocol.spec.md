# TwistProtocol

## Purpose

Collect the theorem-facing modules that make up the paper's Twist layer.

## Paper Anchors

- `docs/twist-and-shout-paper/5_the_twist_piop.md`
- `docs/twist-and-shout-paper/8_fast_twist_prover_implementation.md`
- `docs/twist-and-shout-paper/B_details_of_the_widetilde_text_val_evaluation_sum_check_prover.md`

## Modules re-exported

- `TwistShout/TwistCore.lean`
- `TwistShout/TwistValueEval.lean`
- `TwistShout/FastTwistProver.lean`

## Contract Surface

- Re-export the core Twist relation, the `Val`-reconstruction layer, and the paper's Twist prover specialization.
- Preserve the dependency boundary from Twist to shared preliminaries and downstream applications.

## Out of Scope

- Shout's read-only memory protocol.
- SuperNeo-specific integration theorems.
