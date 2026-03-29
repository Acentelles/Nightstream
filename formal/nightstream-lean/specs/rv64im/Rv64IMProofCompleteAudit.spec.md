# Rv64IMProofCompleteAudit Spec

## Purpose

- **What it is**: The executable top-level audit deciding whether RV64IM is proof-complete at the Lean boundary.
- **What it is not**: It is not another parity report and it does not treat hidden witnesses or backend interface imports as closure.
- **Protocol role**: It is the guardrail that prevents Lean from reporting success when the accepted artifact still relies on stored exact-boundary witnesses or lacks backend refinement into `Π_CCS / Π_RLC / Π_DEC`.

## Closure Conditions

RV64IM is proof-complete only if all of the following hold:

- theorem-owned chunk layout exists and is used as the chunk authority,
- theorem-owned chunked root execution proof owner exists,
- the main-lane trace boundary carries the explicit theorem-owned fold schedule and canonical chunk partition,
- the transcript schedule carries explicit fold-schedule absorption and ordered per-chunk `Π_CCS / Π_RLC / Π_DEC` protocol slots,
- a separate theorem-owned root-execution-semantics owner exists above exact trace closure and binds the accepted chunked root execution proof back to the same authenticated rows,
- the accepted artifact does not store an exact-kernel-boundary witness,
- accepted-proof soundness does not store an exact-kernel-boundary witness,
- the checker result does not store an exact-kernel-boundary witness,
- the public proof boundary does not store an accepted-proof witness,
- the accepted checker owns the theorem-facing exact-boundary constructor used to package checker results,
- the Nightstream bridge theorem binds authenticated selected-row obligations into the accepted surface,
- the Nightstream bridge theorem binds the root main-lane execution proof into the accepted surface,
- the Nightstream bridge theorem binds the stage obligation packages into the accepted surface,
- the Nightstream bridge theorem binds the kernel opening claims into the accepted surface,
- the backend payload surface is not summary-only,
- the accepted checker owns backend refinement into the SuperNeo statements,
- every accepted artifact passes parity checks,
- every accepted artifact is theorem-complete,
- every accepted artifact constructs exact trace and exact kernel boundaries,
- every accepted artifact carries enough theorem-bearing data to justify the root-execution-semantics step that turns accepted row-local root CCS objects into RV64IM execution correctness on the authenticated rows,
- every accepted artifact carries enough theorem-bearing data to construct the
  full kernel-design bridge owner binding authenticated selection, root
  execution, stage obligations, and kernel openings,
- every accepted artifact carries backend payloads sufficient to refine into `Π_CCS / Π_RLC / Π_DEC`.

## Check Targets

- `proofCompleteStaticChecks`
- `proofCompleteStaticFailures`
- `proofCompleteCaseAccepted`
- `proofCompleteRustExportBlockers`
- `uniqueProofCompleteRustExportBlockers`
- `uniqueProofCompleteClosureBlockers`
- `validGeneratedRv64imProofCompleteCases`
- `validRv64imProofCompleteClosure`

## Dependency and Consumer Map

- **Depends on**:
- accepted-artifact parity checks
- accepted-artifact completeness audit
- exact constructor audit
- accepted-artifact root execution closure audit
- accepted-artifact root execution semantics closure audit
- accepted-artifact kernel-design bridge closure audit
- backend refinement audit
- **Consumed by**:
  - `CheckCli.lean`
  - `Main.lean`

## Out of Scope

- Rust payload generation
- generic non-RV64IM closure
- proof of the SuperNeo backend theorems themselves
