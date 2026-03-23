# RV64IM Native ALU Opcode Result Trace Semantics

## Purpose

This module owns the lift of exact native-ALU opcode result facts from the
execution layer to the authenticated trace boundary.

## Theorem Surface

The module exposes trace-level theorems showing that, for any exact native-ALU
opcode with an active non-`x0` architectural write:

- the encoded Stage-1 `aluResult` equals the routed ALU writeback value,
- the authenticated register write value `wvReg` equals the encoded Stage-1
  `aluResult`,
- and the same conclusions are available from exact trace boundaries, not only
  from an already-built authenticated chunk trace.

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

This module does not re-own decode classification, write-activation routing,
generic Stage 1 / Stage 2 bindings, or the missing arithmetic evaluator that
interprets authenticated operands into the concrete ALU result word.
