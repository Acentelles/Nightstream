# Finalize

## Purpose

- **What it is**: A downstream Rust finalization hook that consumes outgoing obligations after shard or session verification.
- **What it owns**: The `ObligationFinalizer` trait and the `FinalizeReport` surface.
- **What it must not do**: Re-run shard proving, reinterpret obligations, or become a second protocol verifier with independent semantics.

## Architectural Position

- **Layer**: Rust-only strengthening / discharge hook
- **Direct paper theorem owner?** No. This module is outside the paper-core theorem surface.
- **Consumes lower-layer semantics from**: [ShardFolding.spec.md](crates/neo-fold/specs/ShardFolding.spec.md), [Session.spec.md](crates/neo-fold/specs/Session.spec.md), [ShardProofTypes.spec.md](crates/neo-fold/specs/ShardProofTypes.spec.md)
- **Exports semantics to**: downstream domain-specific finalizer implementations
- **Erasure rule**: erasing finalization-specific metadata or downstream reports must leave the same lower outgoing obligation surface.

## Target Formulas (Paper -> Rust)

| Paper notion | Paper anchor | Rust surface | Meaning in this crate |
|---|---|---|---|
| final discharge of folded obligations | SuperNeo final theorem path | `ObligationFinalizer<Cmt, F, K>` | Final consumer of the outgoing folded obligations |
| explicit finalization result | implementation support | `FinalizeReport` | Named report over finalization |

## Direct Paper Anchors

This module is not a direct paper-theorem owner.

## Context Anchors

- `crates/neo-fold/specs/Architecture.spec.md`
- `docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`
  - final Section 7 folded obligations
- `docs/architecture/how-superneo-works.md`
  - how the Rust verification/finalization path fits the overall system
- `formal/superneo-lean/SuperNeo.pdf.md`
  - final theorem route consumed by the Lean formalization

## Lean Cross-Reference

| Lean spec | Lean module | Relationship |
|---|---|---|
| `formal/superneo-lean/specs/ProtocolTheorem.spec.md` | `SuperNeo/ProtocolTheorem.lean` | Final theorem consumes the folded obligation surface |
| `formal/superneo-lean/specs/RustRefinement/NeoFoldSessionValidation.spec.md` | `SuperNeo/RustRefinement/NeoFoldSessionValidation.lean` | Session-level validators ensure the outgoing obligations being finalized are well-formed |

## Contract Surface

| Rust symbol | Kind | Role | Contract |
|---|---|---|---|
| `FinalizeReport` | struct | Core | Named finalization result/report |
| `ObligationFinalizer<Cmt, F, K>` | trait | Core | Final checker over outgoing obligations; one owner for “is the folded proof fully discharged?” |

## Invariant Obligations

| Invariant | Why it matters | Expected checks |
|---|---|---|
| Finalization consumes the exact outgoing obligations from shard/session verification | Prevents final-gate drift | Integration/session tests |
| Finalization may strengthen acceptance but must not reinterpret obligation meaning | Prevents hidden semantic drift | Code review and integration tests |
| Finalizers fail clearly on incomplete or inconsistent obligation sets | Prevents accidental acceptance through partial discharge | Integration tests |

## Assumption Ledger

| Assumption | Source | Why this layer relies on it |
|---|---|---|
| Shard/session outgoing obligations are already correct | shard/session specs | Finalization consumes them; it does not construct them |
| Finalizer implementations are domain-specific and may add stronger checks | downstream consumers | The trait intentionally allows stronger domain-specific discharge |

## Dependency and Consumer Map

Upstream dependencies:
- `neo-fold::shard_proof_types`

Primary consumers:
- `neo-fold::shard::verify_api`
- session/trace frontends that finalize verification

## Lean Oracle and Refinement Conformance

No direct Lean oracle is expected here. Conformance is indirect through the shard/session obligation surface that the finalizer consumes.

## Quality Expectations

- The finalizer contract must stay small and explicit.
- Finalization code should not become a second verifier.
- Different finalizers may strengthen acceptance, but none may weaken the underlying folded obligation semantics.

## Acceptance Criteria

1. Finalization succeeds on valid outgoing obligations.
2. Finalization rejects invalid or incomplete outgoing obligations.
3. Finalization stays downstream of shard/session verification rather than duplicating its semantics.

## Out of Scope

- Shard proving
- Session orchestration
- Trace frontends
