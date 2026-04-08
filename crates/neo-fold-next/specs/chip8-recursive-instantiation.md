# CHIP-8 Recursive Instantiation

This file freezes the current repo-local recursive/export boundary for CHIP-8.

## Frozen Backend Choices

- `RecursiveBackend := NativeChunkTransitionRelationV1`
- `CompressionBackend := StatementBoundProofEnvelopeV1`
- `AccumulatorHandle := Poseidon2Digest32`

These names refer to the concrete Rust boundary implemented in
`chip8::proof`, not to an external SNARK backend.

## Frozen Recursive Unit

- The recursive/export unit is one canonical CHIP-8 chunk.
- The canonical chunk schedule is `FoldSchedule::RowsPerChunk(2)`.
- `prepared_steps` remains the native handoff from the CHIP-8 kernel into the
  folded main lane.
- The current repo-local recursive unit is an explicit chunk-transition
  relation, not a circuit that verifies a variable-length prior proof.

## Theorem-Facing Boundary

The theorem-facing API is:

- `Chip8Statement`
- `Chip8CompressedProof`
- `prove_recursive(...)`
- `verify_recursive(...)`

The theorem-facing statement binds:

- the CHIP-8 public input,
- the exact semantic step count,
- the fixed fold schedule and chunk count,
- the program digest,
- the final public machine state,
- and the terminal accumulator handle.

The theorem-facing verifier does not consume a separate public chunk or
public-step trace.

The current repo-local proof object is organized as:

- one kernel-export relation,
- plus one chunk-transition witness per canonical chunk.

The kernel-export relation has:

- a public side:
  - `execution_digest`,
  - `bridge_chunk_digests`;
- and a witness side:
  - one native `SimpleKernelProof`.

Each chunk transition has:

- a public side:
  - previous accumulator handle,
  - next accumulator handle,
  - chunk index,
  - chunk start index,
  - chunk length,
  - main chunk digest,
  - bridge chunk digest,
  - boundary digest;
- and a witness side:
  - the main-lane fold artifacts for that chunk:
    - `Π_CCS` outputs and proof,
    - `Π_RLC` artifact,
    - `Π_DEC` artifact.

The bridge chunk data are now bound through the kernel-export public side,
rather than by reading a second top-level replay object.

The current verifier checks the chunk transition directly from those fold
artifacts plus the public chunk, without reconstructing an intermediate
`ChunkProof` container.

This is a fixed-shape relation boundary whose chunk witness now carries the
main-lane fold artifacts directly and whose side lane is expressed as an
explicit kernel-export relation, but it is not yet a compressed SNARK proof.

The intended next replacement is:

- keep the same public chunk-transition relation shape,
- stop treating the current native bridge verification logic as the terminal
  theorem boundary and lift the same theorem into the actual folded relation,
- and only then add the final compression backend above the folded
  accumulator.

## Audit Boundary

Audit-only bridge summaries live behind:

- `Chip8AuditBundle`
- `prove_audit(...)`
- `verify_audit(...)`

That bundle owns:

- `KernelRowProjectionSummary`
- `KernelBridgeBindingSummary`
- `KernelSemanticEvidenceSummary`

Those objects are no longer first-class fields on `SimpleKernelOutput` or
`SimpleKernelProof`.
