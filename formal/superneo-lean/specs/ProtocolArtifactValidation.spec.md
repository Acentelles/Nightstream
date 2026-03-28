# ProtocolArtifactValidation

## Goal

Validate concrete Rust-exported protocol artifacts inside Lean without
serializing proof terms from Rust.

## Mathematical target

For each generated protocol artifact family:

- build one compact `ProtocolTargetContext`,
- recover the theorem-native protocol-side owner required by the reduction
  stack,
- validate the accepted SumCheck witness carried by the artifact,
- derive the compact protocol predicates
  - `protocolTargetProp`
  - `ccsRelation`
  - `ceRelation`
- derive the reduction statements
  - `Π_CCS`
  - `Π_RLC`
  - `Π_DEC`
- and, for the final-route artifact family, derive the native Goldilocks final
  theorem shape under the theorem-level MSIS hardness assumption.

## Validation model

- Rust is allowed to export only data.
- Lean must reconstruct the corresponding proposition-level objects and prove
  the reduction predicates from that data.
- Executable booleans may be used as bridges only when the implementation
  proves the corresponding soundness theorem from them.

## Output expectations

- the generated protocol artifact module is accepted by Lean,
- the validation module proves the target predicates on the exported artifact,
- the runtime artifact check entrypoint reports success only when the executable
  sanity checks accept the valid exported artifact and reject the tampered one.
