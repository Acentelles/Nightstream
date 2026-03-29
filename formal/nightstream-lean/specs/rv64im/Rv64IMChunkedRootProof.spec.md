# Rv64IMChunkedRootProof Spec

## Purpose

- **What it is**: The theorem-facing root execution proof owner for the RV64IM main lane under an explicit fold schedule and canonical chunk layout.
- **What it is not**: It is not a Twist/Shout selection proof, it is not the Nightstream bridge theorem, and it does not accept digest-only proof summaries.
- **Protocol role**: It packages the chunked root execution proof surface that later artifact-refinement owners must reconstruct from Rust-exported payloads.

## Target Formula

`ChunkedRootProofPackage(mainLane, chunkProofs)` means:

- `mainLane` carries the exact semantic-row count, prepared-step export, fold schedule, and canonical chunk partition,
- `chunkProofs.length = mainLane.chunks.length`,
- for every chunk index `j`, the `j`th backend package names that same chunk,
- every backend package carries the exact row-label set induced by that chunk,
- every backend package carries a theorem-owned SuperNeo protocol target context,
- and from that context the package proves:
  - `Π_CCS` strong,
  - `Π_RLC` weak,
  - `Π_DEC` knowledge.

The package therefore owns the theorem-facing root execution surface:

- execution semantics are justified by the chunked root main-lane CCS / SuperNeo proof route,
- fold cadence is explicit,
- `WholeTrace` is the one-chunk special case,
- and no theorem-facing acceptance path may replace per-chunk backend statements with digest-only summaries.

## Theorem Targets

- `chunkedRootProof_scheduleValid`
- `chunkedRootProof_chunksLayout`
- `chunkedRootProof_chunkCount`
- `backendPackageAtIndex_of_chunkedRootProof`
- `piCCS_atIndex_of_chunkedRootProof`
- `piRLC_atIndex_of_chunkedRootProof`
- `piDEC_atIndex_of_chunkedRootProof`

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/ChunkLayout.lean`
  - `Nightstream/Rv64IM/Trace/MainLaneTraceBoundary.lean`
  - `formal/superneo-lean/SuperNeo/PiCCSInterface.lean`
  - `formal/superneo-lean/SuperNeo/PiRLCInterface.lean`
  - `formal/superneo-lean/SuperNeo/PiDECInterface.lean`
- **Consumed by**:
  - RV64IM backend-refinement owners
  - RV64IM proof-completeness audit
  - future RV64IM bridge owners that must bind authenticated selection to root execution

## Out of Scope

- Rust payload generation
- reconstruction of backend contexts from exported artifacts
- Twist/Shout authenticated selection/opening proofs
- final Nightstream bridge closure
