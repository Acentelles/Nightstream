# Applications

## Purpose

Collect the paper's application-level constructions that consume the Shout/Twist
memory-argument layer to obtain faster SNARKs for non-uniform computation.

## Paper Anchors

- `docs/twist-and-shout-paper/9_faster_snarks_for_non_uniform_computation.md`

## Modules re-exported

- `TwistShout/SpeedySpartan.lean`
- `TwistShout/SpartanPP.lean`

## Contract Surface

- Re-export the theorem-facing surfaces for the paper's application layer.
- Preserve the dependency boundary from applications to the underlying memory arguments.

## Out of Scope

- Standalone formalization of protocols not treated as Twist/Shout applications in the paper.
- SuperNeo-specific integration theorems.
