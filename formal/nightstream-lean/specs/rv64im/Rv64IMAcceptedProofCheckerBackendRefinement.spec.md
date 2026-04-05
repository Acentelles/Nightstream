# Rv64IMAcceptedProofCheckerBackendRefinement Spec

## Purpose

- **What it is**: the theorem-facing RV64IM owner that joins the accepted checker result to the stronger kernel-design bridge package.
- **What it is not**: it is not the accepted checker itself, and it does not re-own the kernel-design bridge theorem.
- **Protocol role**: it makes backend refinement explicit at the checker surface by pairing a checker result with a bridge package and proving that the checker's authenticated trace is exactly the trace routed into the selected-row `Π_CCS / Π_RLC / Π_DEC` consequences.

## Refinement Contract

This owner must expose:

- one package carrying an accepted checker result,
- one `KernelDesignBridgePackage` over the same authenticated trace,
- one explicit proof that the checker's authenticated trace is exactly `authenticatedChunkTrace_of_exactBoundaries` of the bridge package's exact trace,
- selected-row consequences showing that every routed selected row is backed by theorem-bearing `Π_CCS`, `Π_RLC`, and `Π_DEC` statements,
- direct selected-row consequences showing that the exact schedule-owned routed chunk carries those `Π_CCS / Π_RLC / Π_DEC` statements,
- one schedule-owned chunk-index consequence showing that every selected prepared step is owned by the exact chunk index chosen by the carried fold schedule,
- and a schedule-owned routing consequence showing that every selected prepared step is routed to the exact root chunk chosen by the carried fold schedule, not merely to an arbitrary chunk that contains the row.

## Ownership

This owner binds checker acceptance to the existing bridge theorem. It does not re-prove exact-boundary construction, the root execution theorem, or the SuperNeo backend theorems.
