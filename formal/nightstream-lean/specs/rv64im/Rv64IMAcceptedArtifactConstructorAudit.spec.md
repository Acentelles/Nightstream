# Rv64IMAcceptedArtifactConstructorAudit

## Purpose

This module owns the executable constructor audit from the exported RV64IM
accepted artifact into the exact theorem constructors
`ExactTraceBoundaries` and `ExactKernelBoundaries`.

## Mathematical target

For each generated accepted artifact, Lean must evaluate whether every field of
the exact trace boundary constructor and every field of the exact kernel
boundary constructor can be rebuilt from the exported low-level artifact layer
without trusting Rust-assembled summaries or claim bundles as primary inputs.

## Required behavior

- The audit must report trace-constructor coverage in the exact slot shape of
  `ExactTraceBoundaries`.
- The audit must report kernel-constructor coverage in the exact slot shape of
  `ExactKernelBoundaries`.
- Constructor success must require the corresponding proof-bearing object or
  proof obligation, not only derived digest agreement.
- If a constructor slot depends on another exact constructor object, the audit
  must reflect that dependency explicitly.
- Missing proof packages such as step-composition, temporal consistency,
  Stage 3 refinement, program binding, soundness accounting, bridge bindings,
  or row-binding coverage must cause the corresponding slot to fail even if
  related digests match.
- If an exact constructor slot is canonically derivable from another
  theorem-owned input, the audit must treat that derivation as sufficient. In
  particular, exact Stage 2 closure is satisfied by the temporal package via
  `temporal.stage2`; it is not a separate minimal export requirement.

## Output contract

- The module exposes per-case trace constructor checks.
- The module exposes per-case kernel constructor checks.
- The module exposes per-case reports listing missing trace slots and missing
  kernel slots.
- The module exposes aggregate booleans for “all generated cases can construct
  exact trace boundaries” and “all generated cases can construct exact kernel
  boundaries”.
