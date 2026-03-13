# Preliminaries

## Purpose

Collect the paper's technical preliminaries that are shared by both Shout and Twist.

## Paper Anchors

- `docs/twist-and-shout-paper/3_technical_preliminaries.md`

## Modules re-exported

- `TwistShout/EqPoly.lean`
- `TwistShout/MLE.lean`
- `TwistShout/SumCheck.lean`
- `TwistShout/OneHotEncoding.lean`
- `TwistShout/LessThanPoly.lean`

## Contract Surface

- Re-export the common theorem-facing surfaces used by both memory protocols.
- Preserve a clean dependency boundary from shared algebraic tools to protocol-specific arguments.

## Out of Scope

- Read-only memory protocol logic.
- Read-write memory protocol logic.
- Application-level protocol instantiations.
