# Chip8Stage3Refinement Spec

## Purpose

- **What it is**: the explicit refinement from the low-level padded Stage-3
  check to the row-local `ContinuityRowBound` surface consumed downstream.
- **Key property**: `continuityRowBound_of_paddedCheck`.
- **Protocol role**: this owner prevents the low-level padded-domain Stage-3
  check from being silently conflated with the theorem-facing row-local
  continuity theorem.

## Target Formula

Define one explicit refinement object

$$
\mathrm{ActivePrefixContinuityRefinement}(stepIdx,\dots,z)
$$

to package:

- one `PaddedContinuityCheckBound`,
- one accepted `C_{lane} @ bits\_le(stepIdx)` row-opening path,
- one row-binding claim for that same `stepIdx`,
- one proof that the row-binding claim determines the same semantic row `z`,
- and one proof that the corrected current-row Stage-3 coordinates equal the
  corresponding coordinates of `z`.

For one authenticated row `z`, if:

- `PaddedContinuityCheckBound` holds,
- the authenticated `currentRow` fields match `z`,
- the authenticated row-binding claim for the same `stepIdx` matches `z`,

then:

$$
\mathrm{ContinuityRowBound}(stepIdx,\dots,rowClaim,z).
$$

Normative meaning:

- the padded check owns the raw shifted/current evaluations and the explicit
  excluded-tail correction terms derived from the authenticated last active row
  and the public pad-row rule;
- the row-binding input here is **not** that last-active-row correction
  witness; it is the accepted `C_{lane} @ bits\_le(stepIdx)` row-binding path
  for the same semantic row `z`;
- this refinement is therefore the exact bridge from:
  1. one padded-domain Stage-3 check,
  2. one accepted current-row row-binding opening,
  3. one semantic-row identification,
  into the theorem-facing `ContinuityRowBound`.

This is the exact bridge used by evidence, trace, digest, and audit owners.

The theorem-facing constructor is:

$$
\mathrm{ActivePrefixContinuityRefinement}
\Longrightarrow
\mathrm{ContinuityRowBound}.
$$

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/Stage3/Stage3Refinement.lean` | Explicit active-prefix refinement from padded Stage-3 checks to row-local continuity |
| `Nightstream/Chip8/Stage3/Stage3RefinementInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Refinement | `ActivePrefixContinuityRefinement` | structure | Definitional | Packages one padded continuity check, one accepted current-row opening path, and one semantic-row identification into the exact refinement object |
| Theorem | `continuityRowBound_of_paddedCheck` | theorem | Theorem-Target | The padded check plus current-row/row-binding equalities yields `ContinuityRowBound` |
| Theorem | `continuityRowBound_of_activePrefixRefinement` | theorem | Theorem-Target | The explicit refinement object yields `ContinuityRowBound` directly |
