# RustRefinement/NeoFoldStepSemanticValidation

## Purpose

Specify a Rust-only validation layer for projected paper-core per-step semantic
obligations on real exported `neo-fold` artifacts.

This is not a paper theorem. It is a conformance layer over Rust-exported
artifacts after erasing Rust-only sidecars.

## Mathematical target

For each exported valid artifact, the validator checks:

1. For every exported step index, the projected paper-core step-semantic
   predicate holds:
   - current-step CE semantics
   - main-lane carried/current/parent/child witness-chain semantics
   - auxiliary-lane witness-chain semantics

2. The module exposes:
   - an executable Boolean view for one artifact,
   - a direct corpus Boolean over the generated valid artifact family,
   - and the bridge from implementation artifact acceptance to those projected
     semantic checks.

3. The module exposes the bridge from:
   - implementation artifact acceptance
   - to projected paper-core per-step semantic checks.

## Scope

This spec is intentionally narrower than the full artifact/session refinement
layers. It focuses only on:
- projected per-step semantic obligations
- real exported Rust artifact corpus
- executable validation for the slow Rust-refinement lane

It does not restate chain checks, final obligation checks, or session glue.
