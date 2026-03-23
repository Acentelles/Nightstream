# Rv64IMControlFlowOpcodeSemantics Spec

## Purpose

- **What it is**: The exact opcode-level owner for control-flow semantics above control-flow lowering semantics.
- **What it is not**: It is not the Stage-1 row-binding owner, not the generic control-flow family bundle, and not the kernel theorem owner.
- **Protocol role**: It closes the remaining exact-opcode gap for `JAL`, `JALR`, and exact branch opcodes by tying theorem-facing control-flow opcodes to the authenticated decoded row and re-exposing the taken-target alignment consequence at opcode granularity.

## Central Objects

`ControlFlowOpcode(BranchOp)` is the theorem-facing control-flow opcode carrier:

- `jal`
- `jalr`
- `branch(op)`

where `op : BranchOp` is the exact decoded branch-op value carried by the Stage-1 decoded row.

`ControlFlowOpcodeBound(row, opcode)` fixes the exact decoded-row/opcode correspondence:

- `jal` means `isJal = 1`, `isJalr = 0`, `isBranch = 0`,
- `jalr` means `isJal = 0`, `isJalr = 1`, `isBranch = 0`,
- `branch(op)` means `isJal = 0`, `isJalr = 0`, `isBranch = 1`, and `branchOp = op`.

With a concrete RV64 branch-op instantiation, `branch(op)` specializes to the exact architectural branch opcodes `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, and `BGEU`.

## Inputs

The module ranges over:

- one `StepCompositionProofPackage`,
- one `ExactOpcodeFamilySemantics(pkg)`.

It therefore inherits:

- the theorem-facing equality `executionRow.row = decodedRow`,
- the exact Stage-1 linkage package,
- the exact control-flow lowering owner,
- the authenticated taken-target alignment discharge.

## Required Theorem Surface

The module must expose:

- `ControlFlowOpcode`
- `ControlFlowOpcodeBound`
- `isJal_of_controlFlowOpcodeBound`
- `isJalr_of_controlFlowOpcodeBound`
- `isBranch_of_controlFlowOpcodeBound`
- `branchOp_of_controlFlowOpcodeBound`
- `jal_flags_of_controlFlowOpcodeSemantics`
- `jalr_flags_of_controlFlowOpcodeSemantics`
- `branch_flags_of_controlFlowOpcodeSemantics`
- `lane_isJal_of_controlFlowOpcodeSemantics`
- `lane_isJalr_of_controlFlowOpcodeSemantics`
- `lane_isBranch_of_controlFlowOpcodeSemantics`
- `branchOp_of_controlFlowOpcodeSemantics`
- `takenTargetAlignment_of_jalOpcodeSemantics`
- `takenTargetAlignment_of_jalrOpcodeSemantics`
- `takenBranchMux_of_controlFlowOpcodeSemantics`
- `takenTargetAlignment_of_takenBranchOpcodeSemantics`
- `sequenceCorrect_of_controlFlowOpcodeSemantics`
- `sequenceDeterministic_of_controlFlowOpcodeSemantics`

## Proof Obligations

- The opcode layer must not invent a separate hidden branch-op carrier; it must use the exact `branchOp` value already carried by the decoded row.
- The opcode layer must factor through the theorem-facing equality between `decodedRow` and `executionRow.row`; it may not silently treat those Stage-1 carriers as interchangeable by convention.
- `JAL` and `JALR` must re-expose the authenticated taken-target alignment consequence at exact opcode granularity.
- Taken branch rows must re-expose the authenticated `BranchTakenMux = 1` consequence needed to trigger the alignment discharge.
- Sequence correctness and determinism remain theorem-visible at opcode granularity through the preserved control-flow committed-sequence package.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Rv64IM/Execution/ControlFlowOpcodeSemantics.lean` | Control-flow exact opcode semantic owner |
| `Nightstream/Rv64IM/Execution/ControlFlowOpcodeSemanticsInterface.lean` | Theorem-facing re-export surface |
