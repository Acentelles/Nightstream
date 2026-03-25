# RWASM Implementation Strategy

## Purpose

This document extracts the proving strategy implemented on the historical
`enzo/rwasm-bindings` branch into a clean-room specification.

It is not a migration guide for the old file layout.

It is a description of:

- the proving objective,
- the execution data boundary,
- the step-local arithmetization choices,
- the shared memory / lookup strategy,
- and the intentional shortcuts.

The target consumer is an engineer or agent re-implementing RWASM on top of the
current architecture without depending on the old branch structure.

## Objective

The historical RWASM path aimed to prove a narrow subset of rWASM execution
using Nightstream’s generic proving stack, with the smallest possible amount of
new machinery.

The core objective was:

1. accept concrete `rwasm::Tracer` output as the execution boundary,
2. normalize that into generic Nightstream step traces,
3. prove one machine step per CCS step,
4. directly arithmetize a small stack-local i32 subset,
5. reuse existing Twist/Shout infrastructure for memory and lookup obligations,
6. avoid designing a complete WASM-native kernel before the minimal proving path
   exists.

This was a prototype strategy with a narrow correctness envelope, not a full
WASM proving system.

## Non-Goals

The historical implementation did **not** attempt to provide:

- full WASM opcode coverage,
- full linear-memory soundness,
- full table soundness,
- chunked multi-step proving,
- cross-step continuity beyond the traced step boundary,
- complete semantics for all control-flow and stack-polymorphic operators,
- a final upstream architecture,
- or a self-contained kernel comparable in completeness to the CHIP-8 or RV64
  kernel specifications.

Any rewrite should treat those omissions as deliberate scope boundaries, not as
accidental bugs.

## First-Principles Constraints

These are necessities:

- the concrete execution source must be the rWASM tracer, not a re-executor,
- the proof boundary must state explicitly which memories are authenticated and
  which are merely observed,
- row-local opcode semantics belong in the step lane,
- non-local lookup / memory obligations belong in explicit auxiliary channels,
- the field representation must not silently alias full-width machine values,
- every packed-key shortcut must be justified against the field and transcript
  model.

These are conventions and may change:

- exact Rust module layout,
- exact witness column numbering,
- legacy `neo-fold` API shape,
- whether packed lookup families are routed through existing Route-A plumbing or
  a future kernel stage with a different owner.

## High-Level Architecture

The historical implementation had five conceptual layers.

### 1. Opcode metadata layer

Purpose:

- classify rWASM opcodes,
- define stack arity,
- define which operations are direct arithmetic vs lookup-routed,
- and assign stable Nightstream lookup ids.

Outputs:

- a `WasmOpcodeClass`,
- a `WasmShoutOpcode`,
- a canonical metadata row per opcode,
- a stable `WasmShoutOpcode -> ShoutId` mapping.

Important property:

- the metadata catalog is broader than the proved subset.
- the proving subset is an explicit policy choice on top of the catalog.

### 2. Tracer normalization layer

Purpose:

- convert `rwasm::Tracer` rows into generic per-step execution records.

Each normalized step carries:

- `pc_before`,
- `pc_after`,
- `opcode`,
- `halted`,
- a synthetic stack pointer before and after the row,
- stack-derived Twist events,
- optional linear-memory Twist writes,
- optional table Twist writes,
- optional lookup events for selected ALU operators.

Important property:

- the stack pointer is not read from the VM state; it is derived by replaying
  stack read/write arity row by row.

### 3. Fixed-width step witness layer

Purpose:

- define a compact witness for one normalized step.

The witness includes:

- `ONE` and a dedicated zero column,
- opcode / program-counter / stack-pointer columns,
- event counters,
- one Shout lane,
- explicit stack read/write lane columns,
- per-opcode selector columns,
- helper columns for direct arithmetic.

Important property:

- the layout is static and intentionally over-allocates some room.
- this keeps the prototype simple and compatible with shared-bus tail
  injection.

### 4. Direct step semantics layer

Purpose:

- prove the row-local relation for a narrow opcode subset.

This layer enforces:

- selector booleanness,
- stack pointer update,
- PC update,
- lane occupancy consistency,
- and direct arithmetic relations for selected operations.

### 5. Lookup / memory auxiliary layer

Purpose:

- route supported lookup-like opcodes through existing lookup machinery,
- route stack accesses through existing shared memory machinery.

Important property:

- stack memory is the only memory explicitly wired into the proof path.
- linear memory and table writes were traced but not part of the authenticated
  state transition in the prototype.

## Trace Boundary

### Input

The execution boundary is `rwasm::Tracer`.

Every tracer row is treated as one semantic step with:

- one opcode,
- one current program counter,
- optional stack interface values in the tracer slots usually referred to as
  `a`, `b`, `c`,
- optional linear-memory changes,
- optional table changes.

### Program counter model

The normalized `pc_after` is inferred as:

- the next row’s program counter when a next row exists,
- otherwise `pc_before + 1` for the final row.

This is a convenience boundary, not a claim that all WASM instructions have
 unit stride. It is simply how the prototype interpreted the tracer sequence.

### Halt model

Rows were marked as halting on:

- `Return`,
- `Trap`.

### Stack pointer model

The normalized trace maintains a synthetic stack pointer `sp`.

Per row:

1. determine `(stack_reads, stack_writes)` from opcode metadata,
2. set `sp_before = sp`,
3. compute `sp_after = sp_before - stack_reads + stack_writes`,
4. write `sp_before` and `sp_after` into the normalized step state,
5. carry `sp_after` into the next row.

This model is part of the proving contract.

## Stack Lane Convention

The historical implementation fixed exactly three stack memory lanes:

- lane 0: read-only `read0`,
- lane 1: read/write `read1 + write1`,
- lane 2: read-only `read2`.

The convention is lane-oriented, not abstract-stack-oriented.

### Unary operations

- `read0 = sp_before - 1`
- `write1 = sp_after - 1`

### Binary operations

- `read0 = sp_before - 2`
- `read1 = sp_before - 1`
- `write1 = sp_after - 1`

### Ternary stack operations

- `read0 = sp_before - 3`
- `read1 = sp_before - 2`
- `read2 = sp_before - 1`
- `write1 = sp_after - 1`

This asymmetry was intentional because lane 1 was the only write-capable lane.

## Supported Semantic Envelope

The proved subset split into two categories.

### Directly arithmetized operations

These were enforced directly in the step circuit:

- `i32.const`
- `i32.add`
- `i32.sub`
- `i32.popcnt`
- `select`
- `br_if_eqz`
- `return`

Important notes:

- `select` used a simplified condition model: the condition was constrained as
  boolean rather than full WASM “nonzero means true”.
- `br_if_eqz` used helper columns for “taken” and branch delta.

### Lookup-routed operations

These were routed through packed lookup-style relations:

- `i32.mul`
- `i32.and`
- `i32.or`
- `i32.xor`
- `i32.eqz`
- `i32.eq`
- `i32.ne`
- `i32.lt_s`
- `i32.lt_u`

The step witness still exposed the row-local stack I/O and lookup lane
metadata, but the heavy semantic check was delegated to the auxiliary proving
path.

## Lookup Strategy

### Stable lookup ids

Each `WasmShoutOpcode` maps to a stable Nightstream lookup id in a dedicated
WASM range.

A rewrite should preserve stable ids so plan/debug output stays interpretable.

### Packed-key relation strategy

The historical implementation did **not** use dense bit-addressed lookup tables
for the supported RWASM ALU families.

Instead it used metadata-driven packed relations:

- the lookup lane’s address region was repurposed to hold packed helper columns,
- correctness came from the packed relation plus auxiliary checks,
- ordinary table MLE evaluation was not the soundness carrier for these families.

This matches the same architectural role as packed RV32/RV64 opcode relations.

### Relation reuse

Where semantics were already available in the RISC-V packed relation family, the
implementation reused them.

Examples:

- `i32.and`, `i32.or`, `i32.xor`, `i32.mul` reused existing packed arithmetic /
  bitwise relations.

Other operations used WASM-specific helper-column layouts but still fit the same
packed-lookup proving pattern.

### Key-binding shortcut

The historical branch intentionally avoided binding the full packed lookup key as
one field element when the encoding was not injective in Goldilocks.

Consequence:

- key binding at the CPU-to-bus boundary was disabled by default for those
  families,
- soundness came from helper-column relations plus the auxiliary protocol,
- not from naive equality of a single packed key field element.

Any rewrite must keep this issue explicit. It may improve the design by moving
to multi-column key binding, but it must not silently reintroduce aliasing.

## Memory Strategy

### Authenticated memory

The only memory explicitly wired into the proof path was the stack memory
interface.

The stack was modeled as:

- one Twist instance,
- caller-provided capacity `stack_k`,
- `n_side = 2`,
- `d = log2(stack_k)`,
- `lanes = 3`.

### Observed but not fully authenticated memory

The tracer adapter could emit:

- linear-memory byte writes,
- table writes.

However, the prototype did not carry those channels into the step circuit and
did not authenticate them in the main proof path.

That distinction must remain explicit in any rewrite documentation.

## Step Witness Semantics

Each normalized step produced one witness vector `z`.

The historical shape was:

- `x = z[0..m_in]`,
- `w = z[m_in..]`.

The public prefix was intentionally tiny.

The witness carried:

- core row state,
- stack lane selectors / addresses / values,
- one lookup lane,
- helper columns only for the currently supported direct relations.

The witness fill order was conceptually:

1. initialize all columns to zero,
2. fill fixed global columns,
3. fill opcode selector columns,
4. recover stack lane events from the normalized step,
5. fill stack lane columns,
6. fill helper columns for direct arithmetic,
7. fill lookup lane metadata when a lookup-routed opcode is active.

## Testing Envelope

The historical tests validated two kinds of behavior.

### Direct CCS-only proving

This covered direct step semantics without full auxiliary lookup obligations.

Examples:

- `i32.const + i32.add`,
- `i32.sub`,
- `i32.popcnt`.

### Full auxiliary path proving

This covered the stack memory wiring plus packed lookup routing.

Examples:

- `i32.mul`,
- `i32.and`,
- `i32.or`,
- `i32.xor`,
- `i32.eq`,
- `i32.ne`,
- `i32.lt_s`,
- `i32.lt_u`,
- `i32.eqz`.

That set defines the minimum supported proving envelope of the prototype.

## Intentional Trade-Offs

### One-step chunks only

The prototype fixed one normalized step per proof step.

This kept the design narrow and avoided continuity / chunk-boundary complexity.

### Narrow stack-only state proof

The prototype chose to prove stack semantics first because:

- the tracer already exposed stack interface values,
- stack-local arithmetic is enough to validate a meaningful opcode subset,
- it avoided needing a full WASM memory model before the frontend shape was
  understood.

### Direct semantics where cheap, lookup routing where convenient

The design split was pragmatic, not ideological:

- direct constraints were used when the row-local arithmetic was small and clear,
- packed lookup routing was used when an existing relation already matched or
  when a helper-column lookup was simpler than a wider direct circuit.

### Metadata-first coverage

The opcode catalog intentionally got ahead of the proved subset.

That was useful because it separated:

- “this opcode exists in the frontend taxonomy”
- from
- “this opcode is currently proved”.

## Clean-Room Reimplementation Requirements

A rewrite should preserve these compatibility points:

- the trace boundary is concrete `rwasm::Tracer`,
- stack pointer is replayed from opcode arity,
- the three-lane stack convention remains explicit unless deliberately changed,
- stable lookup ids remain stable,
- direct-vs-auxiliary semantic split remains explicit,
- documentation states exactly which memories are proved.

The following may safely change:

- exact Rust module layout,
- exact witness column numbering,
- exact frontend API,
- exact auxiliary protocol owner,
- whether packed keys become multi-column,
- whether a richer memory model is added later.

## Summary

The historical RWASM branch should be understood as:

- a concrete tracer adapter,
- a narrow fixed-width step-lane arithmetization,
- a stack Twist proof surface,
- and a packed lookup reuse layer for selected i32 operators.

It was not a full kernel, and it should not be reimplemented as one in the
first pass.
