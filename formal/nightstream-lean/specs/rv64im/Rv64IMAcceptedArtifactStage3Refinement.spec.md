# RV64IM Accepted-Artifact Stage 3 Refinement

## Purpose

Recover the Stage 3 refinement package directly from the recompute-first
RV64IM accepted-artifact surface.

## Inputs

- The accepted-artifact source/derived execution rows.
- The imported real-row projection induced by those execution rows.
- The imported Stage 3 summary view used for parity and theorem projections.

## Required construction

The owner reconstructs:

- the Stage 3 continuity rows and continuity bound,
- the Stage 3 row-projection bindings over the real-row prefix,
- the final halted boundary claim,
- the derived `Stage3RefinementPackage`,
- the resulting `Stage3ContinuitySemantics` and `Stage3ExportSemantics`.

## Exactness contract

Lean must not trust a Rust-assembled Stage 3 refinement object.

Lean recomputes the package from the accepted artifact and checks exact parity
against the imported Stage 3 summary wherever that summary is already exported:

- imported Stage 3 closure over execution rows,
- continuity-row count,
- row-binding count,
- final halted status,
- real-row sequence projection.

## Output

An executable recovery path `recoverStage3Refinement?` together with exactness
checks and the theorem-facing Stage 3 continuity/export consequences induced by
the recovered package.
