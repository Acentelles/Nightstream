# nstream-midnight-bridge Specification

## 1. Scope

`nstream-midnight-bridge` owns the final Midnight proof backend for theorem-facing
RV64IM exports produced by `neo-fold-next`.

Its job is:

- take the recursive/export artifact defined by
  `crates/neo-fold-next/specs/riscv-recursive-proof.md`,
- encode the verifier for that artifact as a Midnight circuit,
- lower that circuit to a form accepted by unmodified `external/midnight-ledger`,
- and emit Midnight prover/verifier material plus a final Midnight proof.

It does not own:

- the RV64IM arithmetization,
- the SuperNeo backend contract,
- the inner folding relation,
- the recursive proof construction inside `neo-fold-next`,
- or the current proof-complete RV64IM transport object.

## 2. Fixed External Constraints

The bridge is constrained by the current Midnight stack.

1. `external/midnight-ledger` is treated as immutable.
2. The proof server accepts serialized ZKIR sources today:
   - `zkir::IrSource` (`v2`) by default,
   - `zkir_v3::IrSource` only behind Midnight's experimental feature.
3. Midnight proving uses its native proving system and verifier-key model.
4. Midnight prover parameters and verifier parameters are KZG-based:
   - `ParamsKZG<Bls12>`
   - `ParamsVerifierKZG<Bls12>`
5. Therefore the bridge must target Midnight-native proving, not a foreign final
   proof system.

Consequences:

- `neo-fold-next` should stop at the recursive/export artifact.
- `nstream-midnight-bridge` is the outer compression backend.
- The bridge must lower its verifier relation to accepted ZKIR.
- The bridge must not require ledger/runtime/proof-server patches.

## 3. Bridge Input From `neo-fold-next`

The bridge input is the theorem-facing recursive/export artifact, not the current
proof-complete public transport.

The bridge consumes:

- the canonical semantic statement, currently
  `stmt_RV64IM := (dig(P), n, z_0, z_n)` or the approved output projection
  variant from `riscv-recursive-proof.md`,
- the recursive/export proof artifact produced by `neo-fold-next`,
- and any minimal public terminal handle that the recursive backend requires.

The bridge does not consume as final theorem inputs:

- stage package digests,
- kernel opening digests,
- root lane columns,
- raw trace rows,
- witness-side duplication,
- or any other proof-complete audit sidecars.

## 4. Neo-Side Ground Truth

The bridge spec must match the actual Neo relation being exported.

### 4.1 Root RV64IM relation

The live RV64IM main lane is one uniform root relation, not per-opcode custom
R1CS.

Current owned facts:

- root semantic row width: `38`
- root public inputs: `1`
- root relation shape: fixed `29`-row R1CS embedding carried as CCS

The root relation is owned by:

- `crates/neo-fold-next/src/rv64im/ccs.rs`
- `crates/neo-fold-next/specs/riscv-kernel.md`

The “58” value in RV64IM parity code is not the root constraint count.

### 4.2 SuperNeo proof spine

The live proof spine is:

```text
Π_CCS -> Π_RLC -> Π_DEC
```

Both prover and verifier replay that sequence with Poseidon2 on the Nightstream
side.

`Π_CCS` already includes:

- FE sumcheck,
- NC sumcheck,
- public challenges,
- final running sums,
- and `header_digest`.

So the exported theorem being bridged is the full public-coin SuperNeo reduction
path over the fixed RV64IM root CCS, not just “29 equations per step.”

### 4.3 Current public RV64IM proof surface

Current `Rv64imProof` export is still proof-complete transport. Its public
digests and witness duplication are transitional bridge/audit surfaces only.

The bridge must treat those as implementation artifacts unless
`riscv-recursive-proof.md` explicitly preserves a minimal subset in the final
recursive/export statement.

## 5. Bridge Theorem

The bridge proves:

> the recursive/export artifact produced by `neo-fold-next` verifies under the
> Nightstream export relation, therefore the claimed RV64IM execution statement
> holds.

Operationally:

- `neo-fold-next` owns the inner folding relation and the recursive/export proof,
- `nstream-midnight-bridge` owns only the outer Midnight verifier circuit for
  that artifact,
- the final portable proof is the Midnight proof emitted by this crate.

The bridge must not re-prove the full RV64IM execution relation directly.
Its circuit is verifier-sized, not execution-sized.

## 6. Required Midnight Output

The bridge must emit artifacts consumable by unmodified Midnight tooling:

- `ProvingKeyMaterial`
  - `prover_key`
  - `verifier_key`
  - `ir_source`
- `ProofPreimage`
- Midnight `ProofVersioned`
- Midnight `VerifierKey` suitable for contract installation

The default compatibility target is proof-server and contract usage through the
existing Midnight interfaces, not a custom side channel.

## 7. ZKIR Target

The bridge circuit must be emitted as ZKIR.

Default target:

- `zkir::IrSource` (`v2`)

Optional later target:

- `zkir_v3::IrSource`, but only as a separately versioned compatibility mode

`v2` is the default because it is accepted by Midnight proof-server without the
experimental feature.

The bridge must not depend on a custom serialized relation type.

## 8. Circuit Boundary

The Midnight circuit owns only the verification of the Nightstream recursive
artifact.

It must verify, at minimum:

- statement encoding is well-formed,
- the recursive/export proof bytes decode correctly,
- the Nightstream verifier relation accepts,
- the claimed public statement matches the verifier output,
- any minimal public terminal handle is bound if the recursive backend requires
  it.

It must not:

- reconstruct RV64IM execution rows,
- replay the proof-complete current bridge sidecars,
- or translate the full Neo root CCS into Midnight constraints.

The correct boundary is:

```text
Nightstream recursive/export verifier -> Midnight circuit -> Midnight proof
```

not:

```text
Neo RV64IM execution relation -> Midnight circuit
```

### 8.1 First Prototype Boundary

The first bridge prototype shall mirror the generic SuperNeo verifier spine in
`crates/neo-fold-next/src/verifier.rs`, not the current RV64IM proof-complete
verifier in `crates/neo-fold-next/src/rv64im/kernel/proof/verify.rs`.

Specifically, the first bridge unit should be a chunk verifier over:

- `PublicChunk`
- incoming carried `CE` claims
- `ChunkProof`

where `ChunkProof` owns:

- `Π_CCS` outputs and `PiCcsProof`,
- `Π_RLC` public artifact,
- `Π_DEC` public artifact.

The initial Midnight circuit should therefore mirror only these checks:

1. chunk metadata and transcript prelude,
2. `Π_CCS` verification,
3. `header_digest` and `fold_digest` consistency,
4. `Π_RLC` challenge replay and public parent recomputation,
5. `Π_DEC` public verification,
6. expected next-carried-claim binding.

It shall not mirror in the first prototype:

- current RV64IM packaged-proof verification,
- current stage package / kernel opening / root-lane audit surfaces,
- or the current proof/witness bundle digest web.

## 9. Public and Private Data Mapping

This crate must define a stable mapping from the Nightstream artifact into
Midnight's `ProofPreimage`.

Required roles:

- `inputs`
  - field encoding of the theorem-facing Nightstream statement
  - plus any minimal public terminal handle
- `private_transcript`
  - serialized recursive/export proof bytes
  - plus any bridge-private auxiliary witness needed by the ZKIR verifier
- `public_transcript_inputs`
  - empty unless the chosen ZKIR verifier architecture requires them
- `public_transcript_outputs`
  - empty unless the chosen ZKIR verifier architecture requires them
- `communications_commitment`
  - `None` unless the chosen ZKIR verifier architecture requires it
- `binding_input`
  - Midnight chain-owned binding input as supplied by the existing contract path
- `key_location`
  - stable versioned namespace for bridge keys

This mapping must be versioned explicitly. A change in recursive proof encoding,
statement encoding, or public handle layout must change the bridge version.

### 9.1 First Prototype Mapping

For the first chunk-verifier prototype, the split should be:

- `inputs`
  - bridge version,
  - chunk statement digest,
  - incoming-carried-claim digest,
  - expected output / next-carried-claim digest
- `private_transcript`
  - fixed field-vector encoding of `PublicChunk`,
  - fixed field-vector encoding of incoming carried claims,
  - fixed field-vector encoding of `ChunkProof`,
  - auxiliary arithmetic witness needed by Goldilocks and `K` gadgets

The first prototype should avoid exposing raw `ChunkProof` structure as public
inputs except for compact statement digests. The Midnight circuit should
recompute those digests from the private structured witness and constrain them
to match the public inputs.

## 10. Hashing Boundary

This spec draws a hard boundary between Nightstream-owned hashes and
Midnight-owned backend internals.

Nightstream-owned hashes inside the bridged verifier relation must remain
Poseidon2:

- statement digests,
- transcript replay for the Nightstream recursive/export verifier,
- any public accumulator handle digests,
- any bridge-owned digest packing inside the verified Nightstream artifact.

Midnight-owned proving internals are external backend details:

- Midnight prover transcript,
- Midnight verifier transcript,
- Midnight chain binding-input derivation.

`nstream-midnight-bridge` must not introduce any new bridge-local Blake2b or
SHA-256 prehashing on top of the Nightstream artifact. It may only rely on the
existing Midnight-native mechanisms already required by the chain.

## 11. Non-Goals

This crate does not do any of the following:

- convert the full Neo RV64IM R1CS/CCS relation into ZKIR,
- define a foreign final proof system and then wrap it inside Midnight,
- own the current `Rv64imProof` transport format as the final theorem,
- preserve current auxiliary digests as permanent theorem inputs by default,
- or depend on `tmp/removed-neo-midnight-bridge` as a protocol template.

The removed bridge is reference material only for:

- Goldilocks embedding tricks,
- digest packing patterns,
- and circuit sizing intuition.

## 12. Implementation Plan

| Step | Work | Output |
|---|---|---|
| 1 | Implement a minimal chunk-verifier reference boundary over `PublicChunk` + incoming carried claims + `ChunkProof`. | First bridge unit with fixed public/private split. |
| 2 | Define canonical field encoding for that chunk verifier's public digests and private witness vectors. | Stable prototype input layout. |
| 3 | Implement the chunk verifier relation in Rust first as a typed reference verifier over the encoded payload. | Reference verifier for circuit cross-checks. |
| 4 | Lower that chunk verifier relation to ZKIR v2. | `IrSource` generator or checked-in IR artifact. |
| 5 | Generate `ProvingKeyMaterial` for the prototype bridge circuit. | Midnight-native prover key, verifier key, and IR source. |
| 6 | Prove locally through Midnight proof-server using the prototype bridge preimage. | Passing `/check` and `/prove` smoke tests. |
| 7 | Generalize from the prototype unit to the final recursive/export artifact consumed from `neo-fold-next`. | Versioned final bridge input contract. |
| 8 | Install the verifier key on a contract entry point and prove a real contract path on local Midnight infrastructure. | End-to-end contract verification. |
| 9 | Add size and cost measurements for bridge proof generation and verification. | Feasibility gate for chain use. |

## 13. Acceptance Criteria

The bridge is complete only when all of the following are true:

1. `neo-fold-next` exports a recursive/theorem-facing artifact without
   proof-complete sidecars as the final public proof.
2. `nstream-midnight-bridge` converts that artifact into Midnight
   `ProvingKeyMaterial` and `ProofPreimage`.
3. Midnight proof-server can prove and check the bridge circuit without any
   ledger modifications.
4. A verifier key for the bridge circuit can be installed for a contract entry
   point.
5. A contract path can accept the resulting Midnight proof.
6. The bridged public statement remains the Nightstream theorem, not a replay of
   current Neo transport digests.

## 14. Immediate Next Work

The next implementation tasks are:

1. define the first bridge unit as a chunk verifier over `PublicChunk`,
   incoming carried claims, and `ChunkProof`,
2. choose the field-vector encoding for that prototype witness inside Midnight,
3. build a minimal typed reference verifier for the prototype unit in
   `nstream-midnight-bridge`,
4. add a first ZKIR smoke test proving that verifier-shaped prototype through
   Midnight proof-server,
5. then freeze the final recursive/export artifact that `neo-fold-next` will
   hand to the bridge.
