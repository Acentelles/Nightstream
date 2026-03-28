# RV64IM Lean Formalization — Architecture Guide

## Purpose

This directory owns the Lean theorem surfaces for the RV64IM Nightstream kernel.
The target is **kernel closure**: authenticated Stage 1/2/3 evidence, plus
program binding, transcript conformance, bridge binding, and soundness
accounting, imply the RV64IM kernel soundness conclusion.

This guide is about **ownership**, not implementation history.

## Top-Level Shape

The ownership chain is:

- `Stage1/` owns row-local fetch, decode, execution-slot, and helper arithmetic facts.
- `Stage2/` owns register/RAM history projection, limb-pair Twist linkage, RAM virtualization, and temporal seeds.
- `Stage3/` owns active-prefix continuity, final-boundary facts, and prepared-step row bindings.
- `Execution/` owns semantic objects, committed-sequence correctness, opcode-class/family soundness packages, the exact word-arithmetic bundle, the exact native aligned-memory opcode bundle for `LD` / `SD`, and the exact narrow-memory RAM-side payload bundle.
- `Trace/` owns authenticated active-prefix trace closure.
- `Kernel/` owns program binding, transcript schedule, opening/bridge provenance, soundness accounting, and the top-level kernel conclusion.

The current `ExtensionFamily` inventory remains:

- `fetch`
- `executionRow`
- `aluSubtables`
- `branchCondition`
- `registerHistory`
- `ramHistory`

Release-artifact and audit families are intentionally out of scope for this wave.

## Dependency Flow

```text
Stage1.BytecodeFetchProjection
  + Stage1.FetchDecodeBinding
  + Stage1.ExecutionRowBinding
  + Stage1.TrivialPredicateArithmetic
  + Stage1.NarrowMemoryHelpers
    ↓
Execution.ExecutionSemantics
  + Execution.CommittedSequenceSoundness
  + Execution.AdviceSequenceSoundness
  + Execution.UnsignedDivRemSoundness
  + Execution.SignedDivRemSoundness
  + Execution.StepComposition
  + Execution.LoweringRefinement
    ↓
Stage2.RegisterHistoryProjection
  + Stage2.RamHistoryProjection
  + Stage2.TwistConcreteBinding
  + Stage2.TwistTemporalInstantiation
Stage3.ContinuityBridge
  + Stage3.Stage3Refinement
    ↓
Trace.ChunkInput
  + Trace.MainLaneTraceBoundary
  + Trace.RegisterTimeline
  + Trace.RamTimeline
  + Trace.TemporalConsistency
  + Trace.TraceLinkBoundary
  + Trace.AuthenticatedTrace
    ↓
Kernel.ProgramBinding
  + Kernel.OpeningProvenance
  + Kernel.BridgeBinding
  + Kernel.TranscriptSchedule
  + Kernel.SoundnessAccounting
  + Kernel.KernelSoundness
```

## Module Responsibilities

### Stage 1

- `BytecodeFetchProjection.lean`: fetch-family owner for authenticated expanded-bytecode rows.
- `FetchDecodeBinding.lean`: bytecode-to-decoded-row binding and architectural/virtual register routing discipline.
- `ExecutionRowBinding.lean`: execution-row channel, dense ALU/branch slot manifests, taken-target alignment, and the Stage-1 linkage batch.
- `TrivialPredicateArithmetic.lean`: arithmetic alignment and low-bit predicate obligations.
- `NarrowMemoryHelpers.lean`: `align_down_8`, `byte_offset_8`, `extract_extend`, and `blend`.

### Stage 2

- `RegisterHistoryProjection.lean`: register-history family and architectural/virtual register-domain bounds.
- `RamHistoryProjection.lean`: merged RAM address history, zero-row semantics, flattening, and store-payload/write-value binding.
- `TwistConcreteBinding.lean`: exact limb-pair lane-to-Twist linkage plus the authenticated non-zero-init register/RAM `Val` surfaces and their concrete shifted read/write-check consequences.
- `TwistTemporalInstantiation.lean`: the Stage-2 temporal package consumed by trace closure.

### Stage 3

- `ContinuityBridge.lean`: active-prefix PC continuity.
- `Stage3Refinement.lean`: final-boundary closure plus prepared-step row-binding export.

### Execution

- `ExecutionSemantics.lean`: semantic objects such as `ArchitecturalState`, `ExpandedRow`, `PreparedStepView`, and `ExecutionCorrect`.
- `StepComposition.lean`: opcode-class proof owner that composes stage-local facts into committed-sequence execution correctness.
- `LoweringRefinement.lean`: theorem owner that relates a concrete committed lowering to the reference lowering catalog via effect-row identification, commit-row export, and closure-suffix inertness.
- `ExactOpcodeClassSemantics.lean`: exact semantic consequences for the canonical opcode-class proof package.
- `ExactOpcodeFamilySemantics.lean`: exact family-level semantic consequences above opcode-class closure, including control-flow alignment, unsigned no-overflow/determinism, signed divisor/remainder facts, and temporary-register hygiene.
- `ExactWordArithmeticSemantics.lean`: one canonical execution-level bundle for exact native-ALU, word/shift, and multiply word-arithmetic consequences above exact family closure.
- `ExactAlignedMemoryOpcodeSemantics.lean`: one canonical execution-level bundle for exact native aligned-memory `LD` / `SD` consequences above `StepComposition`, including decoded-row / RAM-role agreement, exact load/store routing, and authenticated raw load-word / store-payload equalities.
- `ExactNarrowMemoryPayloadSemantics.lean`: one canonical execution-level bundle for exact narrow-memory RAM-side consequences already justified by `StepComposition`, namely aligned-address decomposition, authenticated raw load words, inactive helper-row RAM silence, authenticated store payloads, and memory writeback routing.
- `WordShiftWordArithmetic.lean`: exact opcode-specialized word-width arithmetic consequences, including the corrected `SRAW` / `SRAIW` path.
- `UnsignedDivRemSoundness.lean`: unsigned `DIV*` / `REM*` theorem package, including `MULU_NO_OVERFLOW`.
- `SignedDivRemSoundness.lean`: signed `DIV*` / `REM*` theorem package, including `CHANGE_DIVISOR` and dividend-sign remainder reconstruction.

### Trace

- `ChunkInput.lean`: exact active semantic prefix and halted-boundary scope.
- `MainLaneTraceBoundary.lean`: exported semantic rows and prepared-step alignment.
- `RegisterTimeline.lean` / `RamTimeline.lean`: chunk-level register and RAM timeline closure.
- `TemporalConsistency.lean`: shared whole-state temporal closure.
- `TraceLinkBoundary.lean`: exact row-to-row link contract over the active prefix.
- `AuthenticatedTrace.lean`: final trace theorem owner connecting authenticated Stage1/2/3 evidence to execution-correct rows, temporal closure, and prepared-step export shape.
- `OpcodeClassSemantics.lean`: trace-level lifting of exact opcode-class semantic bundles.
- `OpcodeFamilySemantics.lean`: trace-level lifting of exact opcode-family semantic bundles.
- `AlignedMemoryOpcodeSemantics.lean`: trace-level lifting of the exact native aligned-memory `LD` / `SD` opcode bundle.
- `WordArithmeticSemantics.lean`: trace-level lifting of the exact native-ALU/word-shift/multiply word-arithmetic bundle.
- `NarrowMemoryPayloadSemantics.lean`: trace-level lifting of the exact narrow-memory RAM-side payload bundle.
- `WordShiftWordArithmetic.lean`: direct trace-level lifting of exact word/shift word-result and authenticated writeback equalities.

### Kernel

- `ProgramBinding.lean`: public program image and lowering version bind the ROM and expanded-bytecode commitments.
- `OpeningProvenance.lean`: exact opening-to-row provenance chain.
- `BridgeBinding.lean`: exported prepared-step coverage for Stage 3 row bindings.
- `TranscriptSchedule.lean`: canonical Fiat-Shamir event order.
- `SoundnessAccounting.lean`: negligible-error aggregation.
- `KernelSoundness.lean`: accepted-boundary theorem and final kernel conclusion.
- `OpcodeClassSemantics.lean`: kernel-level lifting of exact opcode-class semantic bundles.
- `OpcodeFamilySemantics.lean`: kernel-level lifting of exact opcode-family semantic bundles.
- `AlignedMemoryOpcodeSemantics.lean`: kernel-level lifting of the exact native aligned-memory `LD` / `SD` opcode bundle.
- `WordArithmeticSemantics.lean`: kernel-level lifting of the exact native-ALU/word-shift/multiply word-arithmetic bundle.
- `NarrowMemoryPayloadSemantics.lean`: kernel-level lifting of the exact narrow-memory RAM-side payload bundle.
- `WordShiftWordArithmetic.lean`: direct kernel-level lifting of exact word/shift word-result and authenticated writeback equalities.

## Kernel-Closure Target

The top-level target is:

- an accepted RV64IM kernel boundary,
- implying authenticated execution-correct trace closure,
- adjacent-state closure on the exact active semantic prefix,
- prepared-step export and row-binding coverage,
- full halted execution ending in sequence-final `ECALL`,
- transcript conformance,
- negligible total soundness error.

That is the closure boundary Rust should implement against.
