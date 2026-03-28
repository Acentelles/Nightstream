# FoldAdmissibility.spec.md

## Purpose

- **What it is**: The bridge theorem surface deciding which obligation families may enter the SuperNeo main lane.
- **Key rule**: only non-empty CE families at the main evaluation point may merge into the main lane.
- **Protocol role**: it prevents the Rust architecture from silently projecting unrelated Twist/Shout obligations into SuperNeo folding.

## Target Formulas

- Main-lane admissibility:

$$
\mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \Gamma)
\iff
\Gamma \neq \varnothing
\land
\forall o \in \Gamma,\;
o.\mathrm{family} = f_{\mathrm{main}}
\land
o.\mathrm{relation} = \mathrm{CE}
\land
o.\mathrm{point} = p_{\mathrm{main}}.
$$

- Separate-fold admissibility relative to an explicit support predicate \(S\):

$$
\mathrm{SeparateFoldSupported}(S, \Gamma)
\iff
\exists F,R,p,\; S(F,R,p) \land \mathrm{FoldableAt}(F,R,p,\Gamma).
$$

- Decision rule:

$$
\mathrm{classifyFamily}(f_{\mathrm{main}}, p_{\mathrm{main}}, S, \Gamma)
=
\begin{cases}
\mathrm{mergeMain} & \text{if } \mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \Gamma), \\
\mathrm{foldSeparate} & \text{if } \neg \mathrm{MainLaneAdmissible}(f_{\mathrm{main}}, p_{\mathrm{main}}, \Gamma)\; \land\; \mathrm{SeparateFoldSupported}(S,\Gamma), \\
\mathrm{exportFinal} & \text{otherwise.}
\end{cases}
$$

## Theorem Targets

- `mainLaneAdmissible_implies_homogeneous`
- `separateFoldSupported_implies_homogeneous`
- `classifyFamily_eq_mergeMain_of_mainLaneAdmissible`
- `classifyFamily_eq_foldSeparate_of_separateFoldSupported_not_main`
- `classifyFamily_eq_exportFinal_of_not_homogeneous`
- `classifyFamily_eq_exportFinal_of_not_main_no_support`
- `mergeMain_members_have_main_shape`

## Dependency and Consumer Map

- **Depends on**: `Nightstream/BridgeTypes.lean`
- **Consumed by**:
  - later `MainLaneBridge`
  - later `ShardComposition`
  - later Rust-refinement mapping for `shard::main_lane` and `shard::twist_shout`

## Out of Scope

- proving that a separate homogeneous family is itself reducible by SuperNeo
- proving PCS or transcript soundness
- any line-by-line Rust correspondence
