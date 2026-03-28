# Rv64IMExactKernelBoundaries Spec

## Purpose

- **What it is**: The exact-boundary constructor surface for RV64IM kernel soundness.
- **What it is not**: It is not a replacement for `Rv64IMKernelSoundness`; it is the exact accepted-boundary entrypoint into that theorem surface.
- **Protocol role**: It packages exact program, trace, transcript, bridge, and accounting boundaries and lifts them into the canonical kernel soundness conclusion.

## Exact Boundary Package

`ExactKernelBoundaries` packages:

- `ProgramBindingProofPackage`,
- `ExactTraceBoundaries`,
- conforming `root0` bindings,
- canonical transcript schedule,
- kernel soundness accounting,
- exact Stage-3 bridge bindings,
- row-binding coverage over the exact exported row-binding list.

The module also owns the minimal theorem-owned constructor contract
`MinimalExactKernelInputs`. This minimal contract carries the smallest
kernel-level proof-bearing inputs needed to build `ExactKernelBoundaries`
without trusting Rust summaries. The transcript events, transcript schedule,
and row-binding coverage are derived canonically from conforming `root0`
bindings and the exact trace export length; they are not separate minimal
inputs.

## Canonical Constructors

The module must expose:

- `exactKernelBoundaries_of_minimalKernelInputs`
- `exactKernelBoundaries_of_minimalKernelInputPackage`
- `kernelSoundnessAccepted_of_exactBoundaries`
- `kernelSoundness_of_exactBoundaries`

so that one exact kernel-boundary package yields the canonical
`KernelSoundnessAccepted` object and the final `KernelSoundnessConclusion`.

## Required Consequences

From exact kernel boundaries one must be able to derive:

- whole-prefix `ExecutionCorrect`,
- exact prepared-step bridge equality at every exported row-binding index,
- the exact canonical seven-proof opcode-class package carried by the exact kernel boundary,
- the exact canonical seven-family semantic bundle carried by the exact kernel boundary,
- the canonical exact native-ALU/word-shift/multiply word-arithmetic bundle
  carried by the exact kernel boundary,
- the canonical exact native aligned-memory `LD` / `SD` opcode bundle carried
  by the exact kernel boundary,
- the canonical exact narrow-memory helper-result bundle carried by the exact
  kernel boundary,
- the canonical exact narrow-memory RAM-side payload bundle carried by the
  exact kernel boundary.

The theorem-facing exact-kernel-boundary interface must re-export the
constructors that recover the exact family bundle, the exact word-arithmetic
bundle, the exact aligned-memory opcode bundle, the exact narrow-memory
helper-result bundle, and the exact narrow-memory RAM-side payload bundle from
exact kernel boundaries.

## Ownership

This module owns only the passage from exact kernel boundaries to the canonical
RV64IM kernel soundness surface.
