# Rv64IMKernelDesignBridge Spec

## Purpose

- **What it is**: The theorem-facing bridge owner for the RV64IM kernel design.
- **What it is not**: It is not Twist/Shout itself, and it is not the root execution theorem itself.
- **Protocol role**: It binds one authenticated selected-row/opening surface, one root main-lane execution surface, the exact Stage 1 / Stage 2 / Stage 3 theorem packages, and the kernel opening provenance surface into one accepted theorem object.

## Core Principle

Twist/Shout proves authenticated selection/opening obligations only.
It does not prove RV64IM opcode execution correctness.

RV64IM execution correctness comes from the root main-lane chunked CCS proof and
its SuperNeo `Π_CCS / Π_RLC / Π_DEC` consequences.

The bridge owner exists to prove that these two surfaces refer to the same
selected semantic rows.

## Bridge Package

`KernelDesignBridgePackage` packages:

- one exact RV64IM authenticated trace package,
- one root-execution-semantics package whose root execution surface is bound to that same main-lane boundary,
- one routed witness per exported Stage 3 row-binding index,
- and the proof that these routed witnesses cover the full exported Stage 3 row-binding list.

Each routed witness must contain:

- one kernel opening provenance witness for the exported row-binding index,
- one root-main-lane prepared step at that same exported index,
- a proof that the provenance-chain prepared step is exactly that root prepared step,
- one routed root chunk proof package,
- and a proof that the routed prepared-step row index is covered by that chunk's canonical row-label list.

## Required Consequences

From the bridge package one must be able to derive:

- every exported Stage 3 row-binding index has one authenticated opening witness at that same index,
- every such authenticated selected row is bound to one root-main-lane prepared step,
- every such prepared step is routed to one chunk carrying `Π_CCS`, `Π_RLC`, and `Π_DEC`,
- the exact trace execution theorem still holds on the same authenticated rows,
- Stage 2 authenticated-history semantics still hold on the same authenticated rows,
- and the exact Stage 3 halted-execution consequence still holds on the same authenticated rows.

## Ownership

This owner binds theorem surfaces together. It does not re-prove Twist/Shout,
Stage 1 local semantics, Stage 2 local semantics, Stage 3 continuity, or the
SuperNeo backend protocols.
