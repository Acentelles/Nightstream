# Twist/Shout Coverage Audit

This document records the paper-to-Lean coverage boundary for
`formal/twist-shout-lean`.

## Closure Standard

A paper component counts as covered only when the corresponding mathematical
construction or claim is present as a Lean definition/theorem surface and the
package passes:

```bash
cd formal/twist-shout-lean
lake build
lake build TwistShoutTests
lake exe check
```

The closure criterion here is theorem-level coverage, not just executable checks.

## Scope

Included as theorem-bearing targets:

- Section 3 technical preliminaries
- Section 4 Shout
- Section 5 Twist
- Section 6 fast Shout for small memories
- Section 7 fast Shout for structured memories
- Section 8 fast Twist prover
- Section 9 applications
- Appendix B (`Val~` evaluation prover details)
- Appendix C (linear-in-`d` Shout variant)

Audited as intentionally non-formalized exposition:

- `00_abstract.md`
- `1_introduction.md`
- `2_overview_of_twist_and_shout_and_their_costs.md`
- `A_overview_of_offline_memory_checking_protocols.md`
- `10_references.md`

These sections are background, motivation, baselines, or bibliography rather
than theorem-bearing protocol targets for this package.

## Section Matrix

| Paper part | Lean coverage | Primary closure points |
|---|---|---|
| Section 3.1-3.3 | `EqPoly`, `MLE`, `SumCheck` | `eqPoly_eq_delta_of_isBitVec`, `mle_at_bitVec`, `mle_cons`, `mle_chiWeight`, `honestTranscript_verifierAccepted` |
| Section 3.4-3.5 | `OneHotEncoding`, `LessThanPoly` | `productEncoding_dOneHot`, `productEncoding_eq_delta`, `ltPoly_at_bitVec`, `mle_prefixTable` |
| Section 4 one-hot checks | `ShoutOneHot` | `ValidAddressColumns.booleanityExpression`, `ValidAddressColumns.hammingWeightExpression`, `ValidAddressColumns.addressValueExpression` |
| Section 4 read-only read-check | `ShoutCore` | `ReadOnlyMemoryRelation.readCheckIdentity`, `ReadOnlyMemoryRelation.readCheckAtBitCycle`, `ValidAddressColumns.readCheckFinalRoundTarget_atBooleanPoint` |
| Section 6 | `FastShoutSmallMemory` | `aggregatedReadCheck_eq_mle_readOracleTable`, `ValidAddressColumns.aggregatedReadCheck_eq_readCheckExpression`, `combinedShoutLeadingCost_eq_sum` |
| Section 7 | `FastShoutStructuredMemory` | `StructuredTableOracle.structuredReadCheckFinalRoundTarget_eq`, `StructuredTableOracle.readCheckFinalRoundTarget_atBooleanPoint`, `structuredShoutLeadingCost_eq_sum` |
| Section 5 core Twist | `TwistCore` | `ReadWriteMemoryRelation.readCheckIdentity`, `IncrementRelation.writeCheckIdentity`, `ValidAddressColumns.twistReadCheckFinalRoundTarget_atBooleanPoint`, `ValidAddressColumns.writeCheckFinalRoundTarget_atBooleanPoint` |
| Section 5 `Val` reconstruction | `TwistValueEval` | `virtualValue_at_bitCycle`, `timeTableMLE_reconstructedTimeTable`, `valEvaluationFinalRoundTarget_at_bitPoint` |
| Appendix B | `TwistValueEval`, `FastTwistProver` | `timeTableMLE_reconstructedTimeTable`, `valEvaluationOptimizedTotalCost`, Section 8 bridge theorems consuming the Appendix B evaluator |
| Section 8 | `FastTwistProver` | `writeCheckExpression_eq_writeWvExpression_sub_writeValueExpression`, `ValidAddressColumns.writeCheckExpression_eq_mle_sub_mle`, `alternativeTwistComponentLeadingCost_eq_sum`, `alternativeTwistTotalCost_eq_paperPlusGapAndSetup` |
| Appendix C | `ShoutLinearVariant` | `linearReadCheckExpression_eq_readCheckExpression`, `ValidAddressColumns.linearReadCheckFinalRoundTarget_atDiagonalBooleanPoint`, `linearVariantGruenCost_le_standardQuadratic` |
| Section 9.2 SpeedySpartan | `SpeedySpartan` | `PreprocessedLookup.readEval_eq_readCheckEval`, `DegreeTwoPlonkish.virtualConstraintEval_eq_shoutReducedConstraintEval`, `DegreeTwoPlonkish.verifierTarget_eq_shoutReducedVerifierTarget`, `speedySpartanFieldMultiplications_d2_diag` |
| Section 9.3 Spark++ / Spartan++ | `SpartanPP` | `SparkCommitment.supportTable_eq_indicator`, `SparkCommitment.sparkEval_eq_midpointReadCheckEval`, `SparseMatrixCommitment.verifierTarget_eq_shoutReducedVerifierTarget`, `SpartanPPInstance.zeroCheckClaim_eq_zero`, `spartanPPFieldMultiplications_d4_diag` |

## Equation-Level Spine

This is the minimum equation-level spine needed to claim paper closure.

- Equation (15): `EqPoly.eqPoly` and `MLE.chiWeight`
- Equation (16): `SumCheck.hypercubeSum`, `honestTranscript_initialRoundConsistent`, `honestTranscript_verifierAccepted`
- Equation (4): `ShoutCore.readCheckExpression`, `ReadOnlyMemoryRelation.readCheckIdentity`
- Equation (66): `ShoutCore.readCheckExpression`, `ValidAddressColumns.readCheckFinalRoundTarget_atBooleanPoint`
- Equation (8): `TwistCore.rwReadCheckExpression`, `ReadWriteMemoryRelation.readCheckIdentity`
- Equation (9): `TwistCore.IncrementRelation`, `IncrementRelation.writeCheckIdentity`
- Section 5 `Val` prefix reconstruction path: `LessThanPoly.prefixExpression`, `TwistValueEval.virtualValue`, `timeTableMLE_reconstructedTimeTable`
- Section 6 optimized Shout aggregation: `aggregatedCycleWeight`, `aggregatedReadCheck_eq_mle_readOracleTable`
- Section 7 structured-table Shout: `StructuredTableOracle`, `structuredReadCheckFinalRoundTarget`
- Section 8 optimized Twist write-side reductions: `writeValueExpression`, `writeWvExpression`, `writeCheckExpression_eq_writeWvExpression_sub_writeValueExpression`
- Equation (84): `SparkCommitment.sparkEval_eq_sum_lookupValues`
- Spark++ midpoint route from Section 9.3.1: `SparkCommitment.sparkEval_eq_midpointReadCheckEval`
- Equation (85): `SpartanPPInstance.zeroCheckClaim`, `SpartanPPInstance.zeroCheckClaim_eq_zero`

## Figure / Cost Coverage

Overview figures in Section 2 are treated as summaries of later formulas, not as
independent proof targets. Their Lean closures live downstream:

- Figure 1 and Section 8 summaries: `FastTwistProver`
- Figure 2 and Section 6 summaries: `FastShoutSmallMemory`
- Figure 3 and Section 7 summaries: `FastShoutStructuredMemory`
- Figure 11 / Section 9.2.3: `SpeedySpartan`
- Section 9.3.2 prover totals: `SpartanPP`

## Verified Paper Errata

- Section 8.3 alternative-algorithm summary is inconsistent with the component
  bullets. Lean keeps both the published formula and the component-derived sum in
  `FastTwistProver`.
- Section 9.2.3 states `25m` on the `d = 2, m = n` diagonal, while the paper's
  own general formula and Figure 11 give `27m`. Lean follows the general formula.

## Audit Result

The theorem-bearing protocol content of the Twist/Shout paper is covered by the
current package boundary:

- shared preliminaries: Section 3
- Shout: Sections 4, 6, 7, Appendix C
- Twist: Sections 5, 8, Appendix B
- applications: Section 9

What remains after this audit is not additional paper closure work inside this
package. The remaining tasks are downstream:

- shared-core extraction
- SuperNeo/Nightstream bridge theorems
- optional stronger documentation of the paper-to-Lean map at the per-equation level
