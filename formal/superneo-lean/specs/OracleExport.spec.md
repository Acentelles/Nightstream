# OracleExport Spec

## Purpose

Export deterministic Lean-authored JSON oracle fixtures for the Rust conformance layer.

## Required behavior

- Produce one versioned JSON file per oracle family under `formal/superneo-lean/generated-oracles/`.
- Treat Lean as the authoritative producer of expected values for the exported families.
- Include fully explicit inputs and expected outputs; consumers must not need to recompute omitted derived fields.
- Be deterministic: rerunning the exporter on unchanged code and inputs must yield byte-for-byte identical files.

## Oracle families

- ring multiplication and constant term
- coefficient-map roundtrips
- balanced decomposition and recomposition
- MLE tensor / folding alignment
- embedding / bar-lift / matrix transform
- interpolation / eq-lift
- Goldilocks low-norm invertibility windows

## Consumers

- Rust release-mode oracle tests load these files and compare runtime outputs against Lean-authored expectations.
- CI may regenerate the files and fail on diff to detect drift between generators and checked-in artifacts.
