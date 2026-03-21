# MainLaneBridge.spec.md

## Purpose

- **What it is**: The bridge layer that decides when a projected obligation family may enter the SuperNeo main lane.
- **What it is not**: It is not an implementation-stage script and it does not add new reductions.
- **Protocol role**: It proves that Twist/Shout projection outputs remain outside the main lane unless they are genuinely CE claims at the main evaluation point.

## Target Formulas

- Generic exclusion rule:

$$
\mathrm{ProjectionFamilyAt}(F, R, p, \Gamma)
\land
R \neq \mathrm{CE}
\Longrightarrow
\neg \mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \Gamma).
$$

- Exact merge condition for CE projection families:

$$
\mathrm{ProjectionFamilyAt}(F, \mathrm{CE}, p, \Gamma)
\Longrightarrow
\left(
\mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \Gamma)
\iff
F = f_{\mathrm{main}} \land p = p_{\mathrm{main}}
\right).
$$

- Direct `CE`-projection corollary:

$$
\mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \mathrm{CEProjection}(F, p))
\iff
F = f_{\mathrm{main}} \land p = p_{\mathrm{main}}.
$$

- Immediate consequence for the current Twist/Shout bridge:

$$
\neg \mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \mathrm{ShoutReadProjection}(F, p)).
$$

$$
\neg \mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \mathrm{TwistValProjection}(F, p)).
$$

The reason is structural, not heuristic:

- `CEProjection(F, p)` is emitted as a genuine `CE` family and is therefore
  eligible for main-lane merging exactly when `F = f_main` and `p = p_main`;
- `ShoutReadProjection(F, p)` and `TwistValProjection(F, p)` are emitted as
  non-`CE` families, so they remain outside the main lane regardless of the
  chosen family id.

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
