# RV64IM Rust ↔ Lean Exact-Parity Contract

This document freezes the sharded RV64IM parity corpus used to validate the
Rust implementation against an independent Lean recomputation.

## Scope

This contract covers a small sharded corpus built around the first
representative vertical slice and then widened inside the already-supported
opcode surface:

- `vertical_add_sd_ld_ecall`
- `native_add_chain_x0_ecall`
- `native_logic_compare_chain_ecall`
- `native_shift_chain_ecall`
- `native_sub_lui_auipc_fence_ecall`
- `narrow_memory_load_extract_extend_ecall`
- `narrow_memory_store_blend_ecall`
- `multiply_low_mul_mulw_ecall`
- `multiply_high_mulh_mulhu_mulhsu_ecall`
- `unsigned_divrem_chain_ecall`
- `signed_divrem_chain_ecall`
- `aligned_negative_offset_roundtrip`
- `control_flow_ecall_only`
- `control_flow_jal_skip_ecall`
- `control_flow_jalr_skip_ecall`
- `control_flow_beq_taken_skip_ecall`
- `control_flow_bne_taken_skip_ecall`
- `control_flow_blt_taken_skip_ecall`
- `control_flow_bge_taken_skip_ecall`
- `control_flow_bltu_taken_skip_ecall`
- `control_flow_bgeu_taken_skip_ecall`

Each case is represented by one authoritative Rust source artifact and one
Rust-derived comparison artifact.

## Trust Boundary

Rust remains the live implementation of the slice.

Lean is the independent checker. For parity testing:

- `Rv64imParitySourceCase` is the authoritative imported input.
- `Rv64imParityDerivedCase` is the Rust-computed equality target.
- Lean must decode, execute, lower, rebuild stage summaries, rebuild the
  transcript, and compare the recomputed result against
  `Rv64imParityDerivedCase`.

If Lean can recompute a field from `Rv64imParitySourceCase`, that field is not
trusted merely because Rust emitted it.

## Source Artifact

`Rv64imParitySourceCase` contains only:

- case manifest and family tags
- program start PC
- raw 32-bit program words
- initial 64-bit register file
- initial aligned RAM words
- transcript seed

This is the lowest practical slice-local export layer for the current vertical
slice.

## Derived Artifact

`Rv64imParityDerivedCase` must contain exact Rust outputs for:

- execution rows
- Stage 1 row-binding/helper-result summaries
- Stage 2 register history, RAM history, and Twist-link summaries
- Stage 3 continuity/export summaries
- Fiat-Shamir transcript event log and checkpoints
- kernel-facing digest/accounting/final-state summary

## Fiat-Shamir Transcript Parity

Transcript parity is mandatory and explicit.

Rust must export, and Lean must exactly match:

- transcript app label
- ordered event list
- event labels
- absorbed message payloads
- absorbed `u64` vectors
- cursor snapshots before and after each event
- challenge outputs
- digest outputs

Equality is required checkpoint by checkpoint, not just at the final digest.

## Hard-Opcode Expansion Parity

Hard opcode composition is represented only through the expanded execution
trace.

For the current corpus:

- multiply helper instructions are trace-integrated and must match through
  `executionRows`, `stage1`, and `stage2`, including helper rows and
  scratch-register traffic
- signed/unsigned div/rem helper instructions are also trace-integrated and
  must match through the same expanded-row and staged-summary surfaces

There is no separate sidecar virtual-sequence artifact in the parity boundary.

## Acceptance Rule

The slice is accepted only if Lean recomputation yields exact equality for:

- expanded execution rows, including trace-integrated helper rows
- Stage 1 summaries
- Stage 2 summaries
- Stage 3 summaries
- transcript event log and checkpoints
- kernel digests and final halted state

## Sharding Rule

Generated Lean imports must stay sharded from day one:

- one generated source module per case
- one generated derived module per case
- one small index module per family
- one small all-cases index module
- one small top-level imported corpus module

Changing one case must rebuild only that case’s generated modules and the small
family/all-cases/check modules.
