# Projection.spec.md

## Purpose

- **What it is**: The bridge layer that treats Twist/Shout as a projection path that emits explicit obligation families.
- **What it is not**: It is not a new folding theorem and it does not assume that Twist/Shout outputs automatically enter the SuperNeo main lane.
- **Protocol role**: It records the sound paper-backed equalities that turn Twist/Shout virtual relations into verifier-facing evaluation obligations.

## Target Formulas

- Projection families are Twist/Shout-owned obligation families at one family, one relation, and one point:

$$
\mathrm{ProjectionFamilyAt}(F, R, p, \Gamma)
\iff
\Gamma \neq \varnothing
\land
\forall o \in \Gamma,\;
o.\mathrm{source} = \mathrm{twistShout}
\land
o.\mathrm{family} = F
\land
o.\mathrm{relation} = R
\land
o.\mathrm{point} = p.
$$

- Canonical singleton witness for a Twist/Shout-emitted CE obligation:

$$
\mathrm{CEProjection}(F, p) =
\left[(F, \mathrm{CE}, p, \mathrm{twistShout})\right]
$$

- Canonical singleton witnesses:

$$
\mathrm{ShoutReadProjection}(F, p_{\mathrm{shout}}) =
\left[(F, \mathrm{ShoutReadEval}, p_{\mathrm{shout}}, \mathrm{twistShout})\right]
$$

$$
\mathrm{TwistValProjection}(F, p_{\mathrm{twist}}) =
\left[(F, \mathrm{TwistValEval}, p_{\mathrm{twist}}, \mathrm{twistShout})\right]
$$

$$
\mathrm{OpeningProjection}(F, p) =
\left[(F, \mathrm{Opening}, p, \mathrm{twistShout})\right]
$$

$$
\mathrm{FinalProjection}(F, p) =
\left[(F, \mathrm{Final}, p, \mathrm{twistShout})\right]
$$

- This bridge layer therefore distinguishes two different Twist/Shout outcomes:
  - a projected family may emit a genuine `CE` obligation at a main-lane point,
  - or it may emit a non-`CE` auxiliary obligation such as
    `ShoutReadEval`, `TwistValEval`, `Opening`, or `Final`.

Only the first case is even eligible for main-lane merging; the second case
must remain outside the main lane unless a later owner proves a separate route.

- Shout paper-backed projection identity:

$$
\mathrm{ReadOnlyMemoryRelation}(\widetilde{Val}, addr, rv)
\Longrightarrow
\widetilde{rv}(r_{\mathrm{cycle}})
=
\mathrm{ReadCheckExpression}(ra, \widetilde{Val}, r_{\mathrm{cycle}}).
$$

- Twist paper-backed projection identity:

$$
\widetilde{\mathrm{Time}}(\mathrm{ReconstructedTimeTable}(Inc))
(r_{\mathrm{address}}, r_{\mathrm{cycle}})
=
\mathrm{ValEvaluationExpression}(Inc, r_{\mathrm{address}}, r_{\mathrm{cycle}}).
$$

## Dependency and Consumer Map

- **Depends on**:
  - `Nightstream/BridgeTypes.lean`
  - `Nightstream/ClaimedMemorySemantics.lean`
  - `TwistShout/ShoutCoreInterface.lean`
  - `TwistShout/TwistValueEvalInterface.lean`
- **Consumed by**:
  - later `MainLaneBridge`
  - later `ShardComposition`

## Out of Scope

- deciding whether a projected family folds or remains final
- transcript / Fiat-Shamir modeling
- PCS binding or opening proofs
