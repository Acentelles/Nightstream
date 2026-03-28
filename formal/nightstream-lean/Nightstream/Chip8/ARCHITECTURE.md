# CHIP-8 Lean Formalization — Architecture Guide

## How to Read This Codebase

This is a formal verification of the CHIP-8 kernel in Lean 4. It proves that
the kernel soundness conclusion holds given authenticated evidence from the
folding scheme. **Zero `sorry` statements remain** — every theorem is fully proved.

**Start here:** `Kernel/KernelSoundness.lean` — this is the top-level theorem.
Everything else feeds into it.

---

## Top-Level Theorem

```
kernelSoundness_of_exactBoundaries
  (hTrace    : ExactTraceEvidence frames)
  (hChunk    : SimpleKernelChunkInput init N (traceOf frames))
  (hBoundary : ExactKernelOpeningBoundary pts kernelManifest rootManifest)
  (hSchedule : KernelTranscriptSchedule N events)
  ⊢ KernelSoundnessConclusion ...
```

Four hypotheses → one conclusion. Everything in this codebase exists to
construct, decompose, or verify one of these four hypotheses.

| Hypothesis | What it means | Key files |
|---|---|---|
| `hTrace` | Every execution frame is semantically correct (fetch/decode/execute/memory/routing all check out) | `Trace/AuthenticatedTrace*.lean`, `Stage2/EvidenceCoverage.lean` |
| `hChunk` | The trace starts from `init`, has the declared row count, and frames are linked | `Trace/ChunkInput.lean` |
| `hBoundary` | Opening manifests have correct shape, ordering, and commitment separation | `Kernel/OpeningBoundary.lean` |
| `hSchedule` | Fiat-Shamir transcript events are in correct phase order, row bindings cover all rows | `Kernel/TranscriptSchedule.lean` |

The conclusion bundles: execution correctness, temporal consistency, continuity,
prepared-step export for the root prover, and negligible soundness error.

---

## Supported Opcodes (9)

Defined in `Stage1/FetchDecodeBinding.lean` as `OpcodeId`:

| Opcode | Name | Behavior |
|---|---|---|
| `ldImm` | Load immediate | `Vx ← kk` |
| `addImm` | Add immediate | `Vx ← Vx + kk` (mod 256) |
| `mov` | Move register | `Vx ← Vy` |
| `addReg` | Add register | `Vx ← Vx + Vy` (mod 256) |
| `skipEqImm` | Skip if equal | `PC += (Vx == kk) ? 2 : 1` |
| `jump` | Jump | `PC ← nnn` |
| `ldI` | Load I | `I ← nnn` |
| `storeRegs` | Store registers | `RAM[I+0..I+x] ← V[0..x]` (burst) |
| `loadRegs` | Load registers | `V[0..x] ← RAM[I+0..I+x]` (burst) |

State: `PC` (12-bit), `I` (12-bit), `V[0..15]` (8-bit), `RAM[0..4095]` (8-bit).

---

## Directory Layout

```
Chip8/
├── Stage1/          ← Fetch, decode, routing (row-local constraints)
├── Stage2/          ← Memory binding, Twist sessions, temporal seeds, evidence coverage
├── Stage3/          ← Continuity bridge, PC temporal continuity
├── Execution/       ← Step composition, execution semantics, burst sessions
├── Trace/           ← Authenticated traces, chunk input, register/RAM timelines
└── Kernel/          ← Opening boundary, transcript schedule, soundness accounting,
                       top-level soundness theorem, digest & audit
```

---

## Dependency Flow (Bottom → Top)

```
Stage1/Routing.lean                   ← CCS row-local constraints (leaf)
  ↓
Stage1/FetchDecodeBinding.lean        ← ROM fetch + opcode decode
  ↓
Stage1/DecodeAddressBinding.lean      ← Address/key projection from decoded instructions
  ↓
Stage2/WitnessMemoryBinding.lean      ← Register/RAM lane values from witness
  ↓
Execution/ExecutionSemantics.lean     ← Per-instruction state transition rules
  ↓
Execution/StepComposition.lean        ← Compose row-local bounds → instruction correctness
  ↓
Stage2/EvidenceCoverage.lean          ← Bridge kernel proof objects → semantic facts
  ↓
Trace/AuthenticatedTrace.lean         ← Close row-local evidence → chunk-level trace
  ↓
Kernel/KernelSoundness.lean           ← TOP-LEVEL THEOREM
```

Parallel tracks merge at `KernelSoundness`:

```
Stage3/ContinuityBridge.lean ─────────┐
Stage3/PcContinuityBridge.lean ────────┤
Trace/RegisterTimeline.lean ───────────┤
Trace/RamTimeline.lean ────────────────┤
Trace/TemporalConsistency.lean ────────┤
Kernel/OpeningBoundary.lean ───────────┤
Kernel/TranscriptSchedule.lean ────────┤
Kernel/SoundnessAccounting.lean ───────┼──→ KernelSoundness.lean
Execution/BurstSession.lean ───────────┘
```

---

## Three-Layer Pattern

Every module follows:

| Layer | File | Purpose |
|---|---|---|
| Human spec | `specs/chip8/Chip8<Name>.spec.md` | What the module must achieve (stateless, timeless) |
| Interface | `<Dir>/<Name>Interface.lean` | Stable re-export boundary (`abbrev` declarations) |
| Implementation | `<Dir>/<Name>.lean` | Actual definitions, structures, and proofs |

---

## Module → Spec Mapping

| Directory | Implementation | Spec |
|---|---|---|
| **Stage1** | `Routing.lean` | `Chip8Routing.spec.md` |
| | `FetchDecodeBinding.lean` | `Chip8FetchDecodeBinding.spec.md` |
| | `DecodeAddressBinding.lean` | `Chip8DecodeAddressBinding.spec.md` |
| **Stage2** | `WitnessMemoryBinding.lean` | `Chip8WitnessMemoryBinding.spec.md` |
| | `EvidenceCoverage.lean` | `Chip8EvidenceCoverage.spec.md` |
| | `TwistConcreteBinding.lean` | `Chip8TwistConcreteBinding.spec.md` |
| | `TwistRoleSessions.lean` | `Chip8TwistRoleSessions.spec.md` |
| | `TwistTraceRoleSessions.lean` | `Chip8TwistTraceRoleSessions.spec.md` |
| | `TwistTemporalInstantiation.lean` | `Chip8TwistTemporalInstantiation.spec.md` |
| **Stage3** | `ContinuityBridge.lean` | `Chip8ContinuityBridge.spec.md` |
| | `PcContinuityBridge.lean` | `Chip8PcContinuityBridge.spec.md` |
| **Execution** | `ExecutionSemantics.lean` | `Chip8ExecutionSemantics.spec.md` |
| | `StepComposition.lean` | `Chip8StepComposition.spec.md` |
| | `BurstSession.lean` | `Chip8BurstSession.spec.md` |
| **Trace** | `AuthenticatedTrace.lean` | `Chip8AuthenticatedTrace.spec.md` |
| | `ChunkInput.lean` | `Chip8ChunkInput.spec.md` |
| | `RegisterTimeline.lean` | `Chip8RegisterTimeline.spec.md` |
| | `RamTimeline.lean` | `Chip8RamTimeline.spec.md` |
| | `TemporalConsistency.lean` | `Chip8TemporalConsistency.spec.md` |
| | `MainLaneTraceBoundary.lean` | `Chip8MainLaneTraceBoundary.spec.md` |
| | `TraceLinkBoundary.lean` | `Chip8TraceLinkBoundary.spec.md` |
| **Kernel** | `KernelSoundness.lean` | `Chip8KernelSoundness.spec.md` |
| | `OpeningBoundary.lean` | `Chip8OpeningBoundary.spec.md` |
| | `TranscriptSchedule.lean` | `Chip8TranscriptSchedule.spec.md` |
| | `SoundnessAccounting.lean` | `Chip8SoundnessAccounting.spec.md` |
| | `RomScheduleBinding.lean` | `Chip8RomScheduleBinding.spec.md` |
| | `BridgeBinding.lean` | `Chip8BridgeBinding.spec.md` |
| | `StagedExecutionDigest.lean` | `Chip8StagedExecutionDigest.spec.md` |
| | `KernelExecutionDigest.lean` | `Chip8KernelExecutionDigest.spec.md` |
| | `KernelDigestAuditBoundary.lean` | `Chip8KernelDigestAuditBoundary.spec.md` |
| | `KernelArtifactAudit.lean` | `Chip8KernelArtifactAudit.spec.md` |
| | `ArtifactAudit.lean` | `Chip8ArtifactAudit.spec.md` |

---

## How to Check Soundness

### 1. Build everything (proves all theorems)

```bash
cd formal/nightstream-lean
lake build
```

Zero `sorry` = every theorem is machine-checked. If it builds, it's proved.

### 2. Run the import-wall checker

```bash
lake exe nightstream
```

Verifies no test/regression/generated code leaks into the proof namespace.

### 3. Check completeness manually

**Opcode coverage:** Every `OpcodeId` constructor (`ldImm`, `addImm`, ..., `loadRegs`)
must have a corresponding case in:
- `StepComposition.lean` — `LookupBound`, `MemoryBound`
- `ExecutionSemantics.lean` — `MicrostepCorrect`, `InstructionCorrect`
- `Routing.lean` — `BehaviorClass` mapping + `behaviorFlags`

**State coverage:** `TemporalConsistency.lean` bundles:
- `RegisterValueTimeline` — all 16 registers
- `RamValueTimeline` — all 4096 RAM cells
- PC and I — via `PcContinuityBridge.lean` and routing

**Transcript coverage:** `TranscriptSchedule.lean` defines the exact event sequence.
`rowBindingCoverage` in `KernelSoundnessConclusion` proves that every row index
`j < N` has a corresponding `rowBinding j` event.

**Opening coverage:** `ExactKernelOpeningBoundary` in `OpeningBoundary.lean` proves
manifest shape, canonical ordering, and commitment separation between kernel and root.

---

## Witness Layout (24 columns)

Defined in `Stage1/Routing.lean`:

| Index | Name | Meaning |
|---|---|---|
| 0 | `colOne` | Constant 1 |
| 1 | `colPc` | Program counter (pre) |
| 2 | `colPcNext` | Program counter (post) |
| 3 | `colRegX` | Register Vx value (pre) |
| 4 | `colRegY` | Register Vy value (pre) |
| 5 | `colRegXNext` | Register Vx value (post) |
| 6 | `colIReg` | I register (pre) |
| 7 | `colINext` | I register (post) |
| 8 | `colKk` | Immediate 8-bit value |
| 9 | `colNnnAddr` | 12-bit address from opcode |
| 10 | `colNnnWord` | 12-bit word from opcode |
| 11 | `colMemValue` | Memory read value |
| 12 | `colLookupOutput` | Lookup table output |
| 13 | `colWritesLookupToX` | Flag: route lookup → Vx |
| 14 | `colWritesMemToX` | Flag: route memory → Vx |
| 15 | `colPreservesX` | Flag: preserve Vx |
| 16 | `colWritesNnnToI` | Flag: write nnn → I |
| 17 | `colIsJump` | Flag: jump instruction |
| 18 | `colIsBranch` | Flag: conditional branch |
| 19 | `colIsMemOp` | Flag: memory operation (burst) |
| 20 | `colXIdx` | X register index |
| 21 | `colYIdx` | Y register index |
| 22 | `colBurstLast` | Flag: last microstep of burst |
| 23 | `colRamAddr` | Computed RAM address |

---

## Key Definitions Quick Reference

| Definition | File | What it means |
|---|---|---|
| `ExecutionCorrect` | `Execution/ExecutionSemantics.lean` | Trace is linked, every frame is semantically correct, continuity holds, boundaries match |
| `ExactFrameEvidence` | `Trace/AuthenticatedTrace.lean` | One row of authenticated kernel evidence (all stages check out) |
| `AuthenticatedChunkTraceBound` | `Trace/AuthenticatedTraceCore.lean` | Frame bounds + continuity + boundaries packaged as authenticated bundle |
| `KernelSoundnessConclusion` | `Kernel/KernelSoundness.lean` | The full soundness bundle: trace, temporal, continuity, prepared-step export, negligible error |
| `ExactKernelOpeningBoundary` | `Kernel/OpeningBoundary.lean` | Manifest shape + ordering + commitment separation |
| `KernelTranscriptSchedule` | `Kernel/TranscriptSchedule.lean` | Exact Fiat-Shamir event ordering with phase separation |

---

## Statistics

- **70 files** (37 implementation + 33 interface)
- **~25,000 LOC**
- **0 sorry** — fully proved
- **32 spec files** in `specs/chip8/`
- **9 opcodes** formally verified
- **24-column witness layout**
- **~45 transcript events** tracked in protocol order
