# ShardComposition.spec.md

## Purpose

- **What it is**: The Nightstream composition theorem surface that applies a family policy to emitted obligation families.
- **What it is not**: It is not a new folding reduction and it does not re-prove Twist/Shout or SuperNeo.
- **Protocol role**: It proves how typed emitted families are classified into main-lane merge, separate fold, or final export.

## Target Formulas

- A family policy consists of:

$$
\mathrm{FamilyPolicy}(F, P) := \left(f_{\mathrm{main}}, p_{\mathrm{main}}, S\right)
$$

where \(f_{\mathrm{main}} : F\) is the main-lane family id,
\(p_{\mathrm{main}} : P\) is the main-lane point, and
\(S : F \to \mathrm{RelationKind} \to P \to \mathrm{Prop}\) is the explicit separate-fold support predicate.

- The decision function is:

$$
\mathrm{decideFamily}(\Pi, \Gamma)
:=
\mathrm{classifyFamily}(\Pi.f_{\mathrm{main}}, \Pi.p_{\mathrm{main}}, \Pi.S, \Gamma).
$$

- CE projection families merge into the main lane exactly at the policy main point:

$$
\mathrm{ProjectionFamilyAt}(F, \mathrm{CE}, p, \Gamma)
\Longrightarrow
\left(
\mathrm{decideFamily}(\Pi, \Gamma) = \mathrm{mergeMain}
\iff
F = \Pi.f_{\mathrm{main}} \land p = \Pi.p_{\mathrm{main}}
\right).
$$

- In particular:

$$
\mathrm{decideFamily}(\Pi, \mathrm{CEProjection}(F, p)) = \mathrm{mergeMain}
\iff
F = \Pi.f_{\mathrm{main}} \land p = \Pi.p_{\mathrm{main}}.
$$

- A non-main projection family with explicit support folds separately:

$$
\mathrm{ProjectionFamilyAt}(F, R, p, \Gamma)
\land
\neg \mathrm{MainLaneAdmissible}(\Pi.f_{\mathrm{main}}, \Pi.p_{\mathrm{main}}, \Gamma)
\land
\Pi.S(F,R,p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \Gamma) = \mathrm{foldSeparate}.
$$

- A non-main projection family without explicit support remains final:

$$
\mathrm{ProjectionFamilyAt}(F, R, p, \Gamma)
\land
\neg \mathrm{MainLaneAdmissible}(\Pi.f_{\mathrm{main}}, \Pi.p_{\mathrm{main}}, \Gamma)
\land
\neg \Pi.S(F,R,p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \Gamma) = \mathrm{exportFinal}.
$$

- Immediate Nightstream consequences:

$$
\Pi.S(F, \mathrm{ShoutReadEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{ShoutReadProjection}(F, p)) = \mathrm{foldSeparate}.
$$

$$
\neg \Pi.S(F, \mathrm{ShoutReadEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{ShoutReadProjection}(F, p)) = \mathrm{exportFinal}.
$$

$$
\Pi.S(F, \mathrm{TwistValEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{TwistValProjection}(F, p)) = \mathrm{foldSeparate}.
$$

$$
\neg \Pi.S(F, \mathrm{TwistValEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{TwistValProjection}(F, p)) = \mathrm{exportFinal}.
$$

For a `CEProjection(F, p)` away from the policy main lane, the same generic
classification rule applies:

- with explicit support for `(\mathrm{CE}, F, p)`, it folds separately;
- without that support, it remains final.

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/MainLaneBridge.lean`
- **Consumed by**:
  - later Rust-refinement theorems for shard-step routing
  - later transcript/opening composition theorems

## Out of Scope

- proving that an explicitly supported family satisfies a standalone reduction theorem
- transcript / Fiat-Shamir modeling
- PCS binding or opening proofs
