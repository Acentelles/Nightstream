# CoeffMaps

## Purpose

- **What it is**: The coefficient maps `cf : R_q → F_q^d` and `cf⁻¹ : F_q^d → R_q` that convert between the polynomial-ring representation and the field-vector representation, proved to be mutual inverses.
- **Key property**: `cfInv (cf a) = a` and `cf (cfInv v) = v` — perfect round-trip.
- **Protocol role**: `cf` and `cfInv` mediate between ring-algebraic operations (`mulRq`, norm bounds) and field-vector operations (embedding, MLE evaluation). The embedding `embed` (Definition 7) operates on `cf`-images, and the result is lifted back via `cfInv`.

## Target Formulas

- `cf(a) = a` (identity, since `Coeffs = Array F`)
- `cf⁻¹(v) = v` (identity)
- `cf⁻¹(cf(a)) = a` (round-trip)
- `cf(cf⁻¹(v)) = v` (round-trip)

## Paper Anchors

Source: ./formal/superneo-lean/SuperNeo.pdf.md

- Definition 2 (Coefficient maps), Section 4, lines 284-288: `cf : R_q → F_q^d` and `cf⁻¹ : F_q^d → R_q`.

## Module Mapping

| Lean file | Paper section |
|---|---|
| `SuperNeo/CoeffMaps.lean` | Definition 2 |

## Contract Surface

| Group | Lean symbol | Kind | Status | Guarantee |
|---|---|---|---|---|
| Maps | `cf` | def | Definitional | Identity on `Array F` |
| Maps | `cfInv` | def | Definitional | Identity on `Array F` |
| Round-trip | `cfInv_cf` | theorem | Proved | `cfInv (cf a) = a` |
| Round-trip | `cf_cfInv` | theorem | Proved | `cf (cfInv v) = v` |
| Size | `cf_size` | theorem | Proved | `(cf a).size = a.size` |
| Size | `cfInv_size` | theorem | Proved | `(cfInv v).size = v.size` |
| Compatibility | `ct_cf` | theorem | Proved | `ct (cf a) = ct a` |
| Compatibility | `ct_cfInv` | theorem | Proved | `ct (cfInv v) = ct v` |
| Shape | `hasRingDegreeShape_cf_iff` | theorem | Proved | Shape preserved by `cf` |
| Shape | `hasRingDegreeShape_cfInv_iff` | theorem | Proved | Shape iff `v.size = D` |
| Shape | `ringMulShapeProp_cf_iff` | theorem | Proved | Multiplication shape preserved |
| Bundle | `coeffMapRoundTripProp` | def | Definitional | Conjunction of both round-trips |
| Bundle | `coeffMapRoundTrip_theorem` | theorem | Proved | `coeffMapRoundTripProp v` for all `v` |

## Proof Obligations and Closure Plan

All obligations closed. Every theorem reduces to `rfl` since `cf` and `cfInv` are the identity function on the shared representation.

## Assumption Ledger

No open boundary assumptions in this module.

## Dependency and Consumer Map

Upstream dependencies:
- `SuperNeo/Ring.lean`: `Coeffs`, `ct`, `hasRingDegreeShape`, `mulRq`.

Downstream consumers:
- `SuperNeo/Embedding.lean`: uses `cf`/`cfInv` to convert between ring and field representations for `embedElem`.
- `SuperNeo/Thm3Core.lean`: uses `cfInv_cf` for the core embedding theorem.

## Implementation Plan

No further work required; module is proof-complete.

## Quality Expectations

All round-trip proofs should be `rfl`-reducible to confirm the representation is genuinely shared (no data copying).

## Acceptance Criteria

- `lake build` succeeds.
- No `sorry`.
- Both round-trip theorems discharge by `rfl`.

## Out of Scope

- NTT coefficient maps.
- `cf` extended to matrices/vectors of ring elements.
