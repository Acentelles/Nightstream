# Rv64IMRootExecutionSemantics Spec

## Purpose

- **What it is**: The theorem-facing owner binding the chunked root main-lane CCS proof surface back to exact RV64IM execution semantics on the same authenticated rows.
- **What it is not**: It is not Twist/Shout, and it is not the full kernel-design bridge.
- **Protocol role**: It packages one exact authenticated trace boundary, one chunked root execution package, and the theorem-bearing refinement that turns the accepted root execution surface into `ExecutionCorrect` on the exact authenticated prefix.

## Core Principle

Twist/Shout authenticates selected rows and openings only.
It does not prove RV64IM execution semantics.

The root main-lane CCS / SuperNeo proof is the execution-proof surface.
This owner exists to bind that surface back to the same exact RV64IM rows and
prepared steps carried by the accepted trace boundary.

## Package

`RootExecutionSemanticsPackage` packages:

- one exact RV64IM trace boundary over `PreparedStepView`,
- one chunked root execution package over that same main-lane boundary,
- a proof that the main-lane boundaries are exactly shared,
- and a theorem-bearing refinement proving `ExecutionCorrect` on the exact authenticated prefix.

## Required Consequences

From the package one must be able to derive:

- `ExecutionCorrect` on the exact authenticated prefix,
- `ExecutionCorrect` on the underlying step-composition rows and prepared steps,
- the explicit fold-schedule validity and chunk-count facts carried by the root package,
- an explicit in-bounds owning-chunk routing fact for every authenticated row index under that schedule,
- the theorem-bearing backend package at the owning chunk index for every authenticated row index under that schedule,
- direct `Π_CCS / Π_RLC / Π_DEC` consequences at the owning chunk index for every authenticated row index under that schedule,
- and per-chunk `Π_CCS / Π_RLC / Π_DEC` consequences through the chunked root owner.

## Ownership

This owner binds exact RV64IM rows to the root execution theorem surface.
It does not re-prove stage-local semantics, Twist/Shout selection, or the full
kernel-design bridge over selected openings.
