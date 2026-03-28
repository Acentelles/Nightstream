# RustRefinement/NeoFoldRelationValidation

## Purpose

Specify a Rust-only validation layer for projected paper-core per-step folding
relations on real exported `neo-fold` artifacts.

This is not a paper theorem. It is a conformance layer over Rust-exported
artifacts after erasing Rust-only sidecars.

## Mathematical target

For each exported valid artifact, the validator checks:

1. For every exported step index, the projected paper-core relation predicate
   holds:
   - projected main-lane `Π_RLC` / `Π_DEC` parent obligations
   - projected auxiliary-lane singleton-input linkage
   - projected stage-8 lane folding obligations

2. The module exposes:
   - an executable Boolean view for one artifact,
   - a direct corpus Boolean over the generated valid artifact family,
   - and the bridge from implementation acceptance to those projected checks
     for artifact families where the stronger implementation predicate is the
     right acceptance surface.

3. The module exposes the bridge from:
   - implementation artifact acceptance
   - to projected paper-core per-step folding relation checks.

## Scope

This spec is intentionally narrower than the full artifact/session refinement
layers. It focuses only on:
- projected per-step relation obligations
- real exported Rust artifact corpus
- executable validation for the slow Rust-refinement lane

It does not restate chain checks, final obligation checks, or session glue.
