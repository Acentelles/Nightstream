# MainLaneBridge.spec.md

## Purpose

- **What it is**: The bridge layer that decides when a projected obligation family may enter the SuperNeo main lane.
- **What it is not**: It is not an implementation-stage script and it does not add new reductions.
- **Protocol role**: It proves that Twist/Shout projection outputs remain outside the main lane unless they are genuinely CE claims at the main evaluation point.

## Target Formulas

- Generic exclusion rule:

$$
\mathrm{ProjectionFamilyAt}(R, p, \Gamma)
\land
R \neq \mathrm{CE}
\Longrightarrow
\neg \mathrm{MainLaneAdmissible}(p_{\mathrm{main}}, \Gamma).
$$

- Exact merge condition for CE projection families:

$$
\mathrm{ProjectionFamilyAt}(\mathrm{CE}, p, \Gamma)
\Longrightarrow
\left(
\mathrm{MainLaneAdmissible}(p_{\mathrm{main}}, \Gamma)
\iff
p = p_{\mathrm{main}}
\right).
$$

- Immediate consequence for the current Twist/Shout bridge:

$$
\neg \mathrm{MainLaneAdmissible}(p_{\mathrm{main}}, \mathrm{ShoutReadProjection}(p)).
$$

$$
\neg \mathrm{MainLaneAdmissible}(p_{\mathrm{main}}, \mathrm{TwistValProjection}(p)).
$$

The reason is structural, not heuristic:
those projection families are emitted as `ShoutReadEval` and `TwistValEval`
obligations, not CE obligations.

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/Projection.lean`
  - `Nightstream/FoldAdmissibility.lean`
- **Consumed by**:
  - later `ShardComposition`
  - later Rust-refinement theorems

## Out of Scope

- separate-fold support for non-main families
- final obligation discharge
- transcript / PCS instantiation
