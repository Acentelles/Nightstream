# Rv64IMKernelSoundness Spec

## Purpose

- **What it is**: The top-level RV64IM kernel theorem surface.
- **What it is not**: It is not a stage-local package and it does not own release-artifact or audit metadata.
- **Protocol role**: It turns one accepted kernel boundary into the final theorem-facing kernel soundness conclusion.

## Accepted Boundary

`KernelSoundnessAccepted` packages:

- `ProgramBindingProofPackage`,
- `AuthenticatedChunkTrace`,
- conforming `root0` commitment bindings,
- a canonical transcript schedule over the exported-row count,
- kernel soundness accounting,
- bridge bindings covering the authenticated Stage-3 exported-row trace,
- row-binding coverage for every exported prepared step.

## Kernel Conclusion

`KernelSoundnessConclusion` exposes the same accepted objects as a final theorem-facing kernel conclusion. The canonical constructor theorem is:

- `kernelSoundness_of_acceptance`

and the stronger direct corollary is:

- `kernelSoundness_of_authenticatedTrace`

which packages a conclusion directly from program binding, authenticated trace, transcript schedule, bridge binding, and soundness accounting.

The exact-boundary constructor owner is
`Nightstream/Rv64IM/Kernel/ExactKernelBoundaries.lean`. Its canonical
constructors:

- `kernelSoundnessAccepted_of_exactBoundaries`
- `kernelSoundness_of_exactBoundaries`

must lift exact program/trace/transcript/bridge/accounting boundaries into the
canonical accepted boundary and final kernel conclusion.

The direct kernel-level opcode-class semantic lifting owner is
`Nightstream/Rv64IM/Kernel/OpcodeClassSemantics.lean`.

The direct kernel-level opcode-family semantic lifting owner is
`Nightstream/Rv64IM/Kernel/OpcodeFamilySemantics.lean`.

The direct kernel-level exact word-arithmetic lifting owner is
`Nightstream/Rv64IM/Kernel/WordArithmeticSemantics.lean`.

The direct kernel-level exact aligned-memory opcode lifting owner is
`Nightstream/Rv64IM/Kernel/AlignedMemoryOpcodeSemantics.lean`.

The direct kernel-level exact narrow-memory helper-result lifting owner is
`Nightstream/Rv64IM/Kernel/NarrowMemoryHelperResultSemantics.lean`.

The direct kernel-level exact narrow-memory RAM-side payload lifting owner is
`Nightstream/Rv64IM/Kernel/NarrowMemoryPayloadSemantics.lean`.

## Required Consequences

From the kernel conclusion one can extract:

- the public-program binding relation,
- the authenticated chunk trace,
- execution correctness of the authenticated semantic rows,
- execution correctness instantiated on the exact authenticated prefix,
- the main-lane trace boundary on the exact authenticated prefix,
- the trace-link boundary on the exact authenticated prefix,
- expanded-bytecode execution binding on the exact authenticated prefix,
- adjacent-state closure across the exact active semantic prefix,
- the full halted-execution claim from the final boundary,
- the PC-adjacent bridge package,
- the PC-adjacent bridge statement itself,
- exact pointwise equalities tying the kernel-visible PC bridge back to the
  Stage-2 pre/post state PC projection carried by the authenticated trace,
- prepared-step export alignment,
- prepared-step export alignment instantiated on the exact authenticated prefix,
- the exact concrete Twist binding package for the authenticated register/RAM lanes,
- the exact authenticated Stage-2 linkage batch,
- the authenticated register-only and RAM-only linkage consequences,
- the authenticated register write-value consequence on active register writes,
- the authenticated RAM load-value consequence on active loads,
- the authenticated RAM store-payload consequence on active stores,
- the authenticated zero-row RAM `memVal = 0` consequence on inactive RAM rows,
- the exact authenticated Stage-1 linkage batch for the execution row,
- the authenticated taken-target alignment discharge for the execution row,
- the authenticated Stage-1 unsigned no-overflow support relation,
- the exact canonical seven-proof opcode-class package carried by the authenticated trace,
- the exact canonical seven-family semantic bundle carried by the authenticated trace,
- the canonical exact native-ALU/multiply word-arithmetic bundle carried by the
  authenticated trace and lifted to the kernel boundary,
- the canonical exact native aligned-memory `LD` / `SD` opcode bundle carried
  by the authenticated trace and lifted to the kernel boundary,
- the canonical exact narrow-memory helper-result bundle carried by the
  authenticated trace and lifted to the kernel boundary,
- the canonical exact narrow-memory RAM-side payload bundle carried by the
  authenticated trace and lifted to the kernel boundary,
- temporary-register hygiene for the authenticated committed sequence,
- unsigned no-overflow, unsigned DIV/REM semantic closure, and unsigned DIV/REM determinism,
- signed divisor-adjustment, dividend-sign remainder reconstruction, and signed DIV/REM semantic closure,
- transcript equality with the canonical transcript schedule,
- row-binding coverage across all exported rows,
- exact indexwise bridge coverage across all exported rows,
- exact equality between each bridge provenance-chain prepared step and the
  Stage-3 prepared step exported at the same row-binding index,
- negligibility of the total kernel soundness error.

The theorem-facing kernel interface must re-export the constructors that recover
the exact family bundle, the exact word-arithmetic bundle, the exact aligned-memory
opcode bundle, the exact narrow-memory helper-result bundle, and the exact
narrow-memory RAM-side payload bundle from the final kernel conclusion.
