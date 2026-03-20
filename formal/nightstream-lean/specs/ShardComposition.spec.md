# ShardComposition.spec.md

## Purpose

- **What it is**: The Nightstream composition theorem surface that applies a family policy to emitted obligation families.
- **What it is not**: It is not a new folding reduction and it does not re-prove Twist/Shout or SuperNeo.
- **Protocol role**: It proves how typed emitted families are classified into main-lane merge, separate fold, or final export.

## Target Formulas

- A family policy consists of:

$$
\mathrm{FamilyPolicy}(P) := \left(p_{\mathrm{main}}, S\right)
$$

where \(p_{\mathrm{main}} : P\) is the main-lane point and
\(S : \mathrm{RelationKind} \to P \to \mathrm{Prop}\) is the explicit separate-fold support predicate.

- The decision function is:

$$
\mathrm{decideFamily}(\Pi, \Gamma)
:=
\mathrm{classifyFamily}(\Pi.p_{\mathrm{main}}, \Pi.S, \Gamma).
$$

- CE projection families merge into the main lane exactly at the policy main point:

$$
\mathrm{ProjectionFamilyAt}(\mathrm{CE}, p, \Gamma)
\Longrightarrow
\left(
\mathrm{decideFamily}(\Pi, \Gamma) = \mathrm{mergeMain}
\iff
p = \Pi.p_{\mathrm{main}}
\right).
$$

- A non-main projection family with explicit support folds separately:

$$
\mathrm{ProjectionFamilyAt}(R, p, \Gamma)
\land
\neg \mathrm{MainLaneAdmissible}(\Pi.p_{\mathrm{main}}, \Gamma)
\land
\Pi.S(R,p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \Gamma) = \mathrm{foldSeparate}.
$$

- A non-main projection family without explicit support remains final:

$$
\mathrm{ProjectionFamilyAt}(R, p, \Gamma)
\land
\neg \mathrm{MainLaneAdmissible}(\Pi.p_{\mathrm{main}}, \Gamma)
\land
\neg \Pi.S(R,p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \Gamma) = \mathrm{exportFinal}.
$$

- Immediate Nightstream consequences:

$$
\Pi.S(\mathrm{ShoutReadEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{ShoutReadProjection}(p)) = \mathrm{foldSeparate}.
$$

$$
\neg \Pi.S(\mathrm{ShoutReadEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{ShoutReadProjection}(p)) = \mathrm{exportFinal}.
$$

$$
\Pi.S(\mathrm{TwistValEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{TwistValProjection}(p)) = \mathrm{foldSeparate}.
$$

$$
\neg \Pi.S(\mathrm{TwistValEval}, p)
\Longrightarrow
\mathrm{decideFamily}(\Pi, \mathrm{TwistValProjection}(p)) = \mathrm{exportFinal}.
$$

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
