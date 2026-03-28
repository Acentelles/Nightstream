# VmBridgeRefinement Spec

## Purpose

- **What it is**: The generic Nightstream refinement surface connecting one VM-local release bridge to the canonical Nightstream release bridge.
- **What it is not**: It is not a VM execution theorem and it does not choose a concrete VM stage inventory.
- **Protocol role**: It fixes the exact condition under which a VM-local public bridge view and canonical stage-view list refine the generic `ReleaseBridge` surface, so later VM-local staged artifacts can target one canonical backend boundary.

## Target Formulas

Assume one generic release shape `shape`.

Assume one VM-local stage-view translation:

$$
\mathrm{toStageView} : \mathrm{VmStageView} \to \mathrm{ReleaseStageView}(shape),
$$

one VM-local canonical stage-view list `vmCanonicalStageViews`, one VM-local
public-view translation

$$
\mathrm{toPublicView} : \mathrm{VmPublicView} \to \mathrm{ReleaseBridgePublicView}(shape),
$$

and one VM-local public-view predicate `vmPublicViewBound(view, n)`.

Define the exact refinement predicate:

$$
\mathrm{RefinesReleaseBridge}
(shape,\ \mathrm{toStageView},\ \mathrm{vmCanonicalStageViews},\ \mathrm{toPublicView},\ \mathrm{vmPublicViewBound})
$$

iff:

$$
\mathrm{map}(\mathrm{toStageView},\ \mathrm{vmCanonicalStageViews})
=
\mathrm{canonicalStageViews}(shape),
$$

and

$$
\forall view,n,\;
\mathrm{vmPublicViewBound}(view,n)
\Longrightarrow
\mathrm{ReleaseBridgePublicViewBound}(shape,\ \mathrm{toPublicView}(view),\ n).
$$

The theorem-facing extraction targets are:

$$
\mathrm{RefinesReleaseBridge}(\cdots)
\Longrightarrow
\mathrm{map}(\mathrm{toStageView},\ \mathrm{vmCanonicalStageViews})
=
\mathrm{canonicalStageViews}(shape),
$$

and

$$
\mathrm{RefinesReleaseBridge}(\cdots)
\land
\mathrm{vmPublicViewBound}(view,n)
\Longrightarrow
\mathrm{ReleaseBridgePublicViewBound}(shape,\ \mathrm{toPublicView}(view),\ n).
$$

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Predicate | `RefinesReleaseBridge` | def | Definitional | Packages exact stage-view refinement plus exact public-view refinement |
| Theorem | `canonicalStageViews_eq_of_refines` | theorem | Theorem-Target | A refining VM bridge exposes the exact generic canonical stage-view list |
| Theorem | `releaseBridgePublicViewBound_of_refines` | theorem | Theorem-Target | A refining VM public view satisfies the exact generic public-view bound |
| Theorem | `releaseBridgePublicViewBound_of_publicView_eq` | theorem | Theorem-Target | Equality with the generic canonical constructor discharges the generic public-view bound directly |

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/ReleaseBridge.lean`
- **Consumed by**:
  - VM-local refinement owners such as CHIP-8
  - later Rust refinement theorems for `bridge/mod.rs`

## Proof Obligations

- A VM-local public bridge view may refine the generic bridge only by preserving the exact canonical stage inventory, exact prepared-step count, and exact fold schedule.
- A VM-local release bridge must prove exact refinement; heuristic correspondence is not sufficient.

## Out of Scope

- VM execution semantics
- stage-local payload semantics
- transcript / PCS instantiation
- final staged artifact packaging
