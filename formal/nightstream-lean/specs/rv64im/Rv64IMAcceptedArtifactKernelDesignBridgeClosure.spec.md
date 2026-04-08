# Rv64IMAcceptedArtifactKernelDesignBridgeClosure Spec

## Purpose

- **What it is**: An executable Lean audit for whether the exported RV64IM accepted artifact is strong enough to construct the full kernel-design bridge owner.
- **What it is not**: It is not the bridge theorem itself.
- **Protocol role**: It prevents Lean from silently treating summary parity or transcript coherence as if they were enough to bind authenticated selection, root execution, stage obligations, and kernel openings into one theorem surface.

## Acceptance Rule

The audit accepts an artifact case only if Lean can identify, from the lowest
practical Rust export layer:

- a separate theorem-owned required bridge export surface owner stating the exact selected-row / stage / opening objects Rust must export,
- theorem-bearing authenticated selection/opening payloads,
- theorem-bearing selected-row-to-prepared-step bindings,
- theorem-bearing selected-row-to-schedule-owned-root-chunk routing bindings,
- theorem-bearing Stage 1 / Stage 2 / Stage 3 obligation payloads,
- theorem-bearing kernel opening provenance payloads,
- and the already-required root-execution-semantics closure surface.

If any of these surfaces is missing, summary-only, or digest-only, the audit
must fail and report the missing field names.

It must also report the exact missing Rust theorem-bearing export objects in a
machine-readable blocker list so closure cannot be overstated by generic
"payload surface absent" booleans.

## Required Negative Coverage

This audit must reject at least the following closure gaps:

- coherent exported summaries with no authenticated selected-row payloads,
- coherent root execution digests with no theorem-bearing schedule-owned row-routing payloads,
- coherent stage summaries with no theorem-bearing stage packages,
- coherent opening digests with no opening provenance chains,
- and the original miss where a dummy main-lane/backend proof object is hidden
  behind coherent exported digests.
