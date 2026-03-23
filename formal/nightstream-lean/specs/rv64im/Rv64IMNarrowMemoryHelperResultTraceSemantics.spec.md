# Rv64IMNarrowMemoryHelperResultTraceSemantics Spec

## Purpose

- **What it is**: The trace-level owner that lifts exact narrow-memory
  helper-result consequences through authenticated RV64IM traces.
- **What it is not**: It is not the execution-level owner of the helper-result
  bridge and it does not re-own trace closure.
- **Protocol role**: It makes the exact `extractExtend` / `blend`
  `ALU_RESULT` consequences theorem-visible from `AuthenticatedChunkTrace` and
  `ExactTraceBoundaries`.

## Required Surface

- `exactNarrowMemoryHelperResultSemantics_of_authenticatedChunkTrace`
- `loadExtractHelperResult_of_authenticatedChunkTrace_narrowMemory`
- `storeBlendHelperResult_of_authenticatedChunkTrace_narrowMemory`
- `exactNarrowMemoryHelperResultSemantics_of_exactBoundaries`
- `loadExtractHelperResult_of_exactBoundaries_narrowMemory`
- `storeBlendHelperResult_of_exactBoundaries_narrowMemory`

## Proof Obligations

- The trace layer must preserve the exact helper-result formulas, not weaken
  them into row-shape facts.
- The lifted formulas must still be stated over the authenticated trace’s own
  `stepComposition` package.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Trace/NarrowMemoryHelperResultSemantics.lean` | Trace lift for exact narrow-memory helper-result theorems |
| `Nightstream/Rv64IM/Trace/NarrowMemoryHelperResultSemanticsInterface.lean` | Theorem-facing re-export surface |
