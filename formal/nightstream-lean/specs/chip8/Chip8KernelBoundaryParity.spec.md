# Chip8KernelBoundaryParity Spec

## Purpose

- **What it is**: the theorem-facing owner map from the simple CHIP-8 kernel
  prose boundary to the exact Lean interfaces that own the corresponding
  machine-checked surfaces.
- **Key property**: this owner adds no new protocol logic; it freezes the
  authoritative interface list reviewers should use when the kernel spec names
  a theorem-facing owner.
- **Protocol role**: this is the anti-drift layer between
  `chip8-kernel.md` and the Lean owners for accepted openings, public-input
  binding, transcript binding, Stage-2 temporal closure, Stage-3 refinement,
  and bridge handoff.

## Scope

This owner re-exports only the small set of boundary-critical surfaces that the
simple kernel spec depends on directly:

- accepted opening / refinement objects
- concrete register-side Stage-2 session keys
- the explicit active-prefix Stage-3 refinement object
- public metadata absorb planning and transcript schedule surfaces
- the bundled public-input binding theorem surface
- the chunk-global Stage-2 temporal-context surface
- the Stage-3 `pc` adjacency bridge surface
- the row/bridge same-path handoff bundle

It does **not**:

- define any new opening rule, transcript event, or temporal theorem
- replace the underlying owner modules
- act as authorization for future non-simple kernel/root schemas

## Boundary Owner Map

| Kernel boundary topic | Authoritative owner | Lean surface re-exported here | Role |
|---|---|---|---|
| Accepted direct opening path | `Chip8OpeningBoundary` | `AcceptedDirectOpening`, `OpeningRefinement` | Exact direct-claim to exact-opening/refinement path used by the kernel boundary |
| Register-side Stage-2 session-key surface | `Chip8RegisterSessionBoundary` | `RegisterSessionKey`, `RegisterSessionKeyBound`, `regRaYKey_sink_iff_not_usesY`, `regWaKey_sink_iff_no_lane_write` | Makes the sink-inclusive register key domain machine-checked |
| Active-prefix Stage-3 refinement | `Chip8Stage3Refinement` | `ActivePrefixContinuityRefinement`, `continuityRowBound_of_activePrefixRefinement` | Makes the current-row accepted opening path explicit instead of implicit |
| Public metadata absorb plan | `Chip8MetaPubEncoding` | `KernelMetaPub`, `root0MetaPubAbsorbPlan` | Fixes the exact theorem-facing `meta_pub` surface absorbed into `root0` |
| Transcript event order | `Chip8TranscriptSchedule` | `KernelTranscriptSchedule`, `transcriptEvents` | Fixes the exact challenge/event schedule for the simple boundary |
| Concrete transcript specialization | `Chip8ConcreteTranscriptParity` | `root0DigestCursor` | Freezes the exact concrete Poseidon2 specialization used by Rust/Lean parity checks |
| Public-input binding | `Chip8KernelInputBinding` | `KernelPublicInputsBound`, `kernelPublicInputsBound_of_authenticatedInputs` | Makes public program/init/table/meta binding theorem-facing |
| Stage-2 temporal closure | `Chip8TwistTemporalInstantiation` | `Stage2TemporalContextBound`, `temporalInstantiationBound_of_stage2_and_bridge` | Packages the chunk-global Stage-2 temporal context used by strong trace closure |
| Stage-3 `pc` bridge | `Chip8PcContinuityBridge` | `PcAdjacentBridge`, `pcTemporalBound_of_adjacentBridge` | Owns the theorem-facing adjacent-row `pc` continuity bridge |
| Row/bridge same-path handoff | `Chip8BridgeBinding` | `BridgeBindingBundle`, `exists_bridgeBindingBundle_of_exactEvidence` | Owns the prepared-step binding object that reuses the same accepted row-opening path |

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Kernel/BoundaryParity.lean` | Thin theorem-facing owner map over the kernel boundary's authoritative Lean surfaces |
| `Nightstream/Chip8/Kernel/BoundaryParityInterface.lean` | Public re-export surface used by reviewers and downstream prose specs |

## Proof Obligations

- This owner must stay thin and re-export-only.
- It must not silently become a replacement for the underlying owners.
- If `chip8-kernel.md` changes which theorem-facing owner it cites, this map
  must be updated in the same patch.
- If a row in the map names a surface here, the re-export must point to the
  exact authoritative interface, not to a weaker convenience wrapper.
