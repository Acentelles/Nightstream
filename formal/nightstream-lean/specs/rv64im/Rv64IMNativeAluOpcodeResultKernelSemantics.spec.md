# RV64IM Native ALU Opcode Result Kernel Semantics

## Purpose

This module owns the lift of exact native-ALU opcode result facts from the
execution layer to RV64IM kernel soundness and exact kernel boundaries.

## Theorem Surface

The module exposes kernel-level theorems showing that, for any exact native-ALU
opcode with an active non-`x0` architectural write:

- the encoded Stage-1 `aluResult` equals the routed ALU writeback value at the
  authenticated kernel boundary,
- the authenticated register write value `wvReg` equals the encoded Stage-1
  `aluResult`,
- and the same consequences are derivable from exact kernel boundaries through
  the Nightstream bridge.

Those consequences remain visible both generically and as exact opcode
specializations for:

- `ADD`
- `ADDI`
- `SUB`
- `AND`
- `ANDI`
- `OR`
- `ORI`
- `XOR`
- `XORI`
- `SLT`
- `SLTI`
- `SLTU`
- `SLTIU`
- `LUI`
- `AUIPC`

## Non-Goals

This module does not re-own trace construction, bridge binding, transcript
binding, or opcode-by-opcode arithmetic evaluation of the Stage-1 ALU result.
