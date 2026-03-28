# BridgeTypes.spec.md

## Purpose

- **What it is**: The typed bridge surface for composition-specific obligation families produced while combining SuperNeo with Twist/Shout.
- **What it is not**: It is not a restatement of either paper's standalone relations.
- **Protocol role**: It gives the composition layer one explicit place to classify obligations as:
  - merge into the SuperNeo main lane,
  - fold as a separate homogeneous family,
  - or remain final.

## Target Formulas

- Obligation shape:

$$
\mathrm{Obligation}(F, P) := (\mathrm{family}, \mathrm{relation}, \mathrm{point}, \mathrm{source}).
$$

- Non-empty foldability at one family, one relation, and one point:

$$
\mathrm{FoldableAt}(F, R, p, \Gamma)
\iff
\Gamma \neq \varnothing
\land
\forall o \in \Gamma,\;
o.\mathrm{family} = F
\land
o.\mathrm{relation} = R
\land
o.\mathrm{point} = p.
$$

- Homogeneity:
  this is necessary for folding, but not sufficient for separate folding.

$$
\mathrm{Homogeneous}(\Gamma)
\iff
\exists F,R,p,\; \mathrm{FoldableAt}(F,R,p,\Gamma).
$$

- Main-lane admissibility:

$$
\mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \Gamma)
\iff
\mathrm{FoldableAt}(f_{\mathrm{main}}, \mathrm{CE}, p_{\mathrm{main}}, \Gamma).
$$

- Explicit support for a separate fold family:

$$
\mathrm{SeparateFoldSupported}(S, \Gamma)
\iff
\exists F,R,p,\; S(F,R,p) \land \mathrm{FoldableAt}(F,R,p,\Gamma).
$$

## Dependency and Consumer Map

- **Depends on**:
  - `SuperNeo.PiCCSInterface`
  - `SuperNeo.PiRLCInterface`
  - `SuperNeo.PiDECInterface`
  - `TwistShout.ShoutCoreInterface`
  - `TwistShout.TwistValueEvalInterface`
- **Consumed by**:
  - `Nightstream/FoldAdmissibility.lean`
  - later `MainLaneBridge`
  - later `ShardComposition`

## Out of Scope

- transcript / Fiat-Shamir modeling
- PCS binding or opening proofs
- Rust refinement
