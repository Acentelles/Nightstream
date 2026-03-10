# RustRefinement/NeoFoldRefinement

## Goal

Separate the paper semantics of SuperNeo folding from the richer Rust
implementation artifact format.

This spec is **not** a new paper theorem. It is a refinement contract for the
Rust-exported `neo-fold` artifacts and validators.

## Why this exists

The paper CE / folding relations are defined over the mathematical claim and
witness objects used in Section 7.

The Rust implementation exports strictly richer claim objects that also carry
implementation-sidecar metadata such as:

- fold digests,
- step coordinates,
- statement offsets,
- statement lengths.

Those fields are allowed only if they form a **conservative extension** of the
paper protocol:

- they may make the implementation verifier stricter,
- they may reject malformed implementation artifacts,
- but they must not create new accepting executions that do not correspond to a
  valid paper execution.

## Mathematical target

The refinement layer must provide:

1. A paper-core CE claim view that erases implementation-sidecar metadata.
2. A paper-core folding-lane view that erases implementation-sidecar metadata
   transitively through inputs, parent, and children.
3. A theorem target showing that implementation-level CE acceptance implies
   acceptance of the projected paper-core CE claim.
4. A theorem target showing that implementation-level `Π_RLC` acceptance
   implies acceptance of the projected paper-core folding lane.
5. A theorem target showing that implementation-level `Π_DEC` acceptance
   implies acceptance of the projected paper-core folding lane.
6. A whole-artifact refinement target for Rust-exported `neo-fold` artifacts.
   The first required concrete instance is that accepted implementation
   artifacts imply the projected paper-core chain and final exported-claim
   obligations.
7. A concrete CE refinement theorem for the current Rust-exported witness check:
   acceptance of the implementation CE witness predicate must imply acceptance
   of the projected paper-core CE claim.
8. A concrete `Π_RLC` parent refinement theorem for the current Rust-exported
   lane-parent check: acceptance of the implementation parent predicate must
   imply acceptance of the projected paper-core parent predicate.
9. A concrete `Π_DEC` parent refinement theorem for the current Rust-exported
   lane-parent check: acceptance of the implementation parent predicate must
   imply acceptance of the projected paper-core parent predicate.
10. A concrete full folding-lane refinement theorem for the current Rust
    validator: acceptance of the implementation lane predicate must imply that
    the projected paper-core lane satisfies both the induced `Π_RLC` and
    `Π_DEC` parent predicates.
11. A concrete whole-artifact core refinement theorem for the current Rust
    validator: acceptance of the implementation artifact predicate must imply
    the projected paper-core chain and final exported-claim obligations.
12. A stronger whole-artifact core refinement theorem for the current Rust
    validator: acceptance of the implementation artifact predicate must also
    imply paper-core acceptance of the initial accumulator CE witnesses.
13. A whole-artifact per-step refinement theorem for the current Rust
    validator: acceptance of the implementation artifact predicate must imply
    the projected paper-core folding relation obligations for every exported
    step.
14. A strongest current whole-artifact refinement theorem for the current Rust
    validator: acceptance of the implementation artifact predicate must imply
    the combined projected paper-core chain/final obligations, initial
    accumulator CE witness obligations, and per-step folding relation
    obligations.
15. An executable Boolean view of the strongest current projected paper-core
    artifact predicate for each generated valid `neo-fold` scenario.
16. A runner-friendly corpus view that maps the current generated valid
    `neo-fold` corpus to those Booleans for executable validation and CI
    reporting.
17. A theorem connecting the per-artifact Boolean predicate to the strongest
    current projected paper-core artifact proposition, so a `true` result can
    be lifted back into the mathematical refinement statement.

## Safety criterion

The refinement is acceptable only if the extra Rust metadata is
**consistency-only**:

- accepted implementation artifacts project to valid paper-core obligations,
- rejected implementation artifacts may still correspond to valid paper
  artifacts,
- but accepted implementation artifacts must never project to invalid paper
  artifacts.

This is the precise condition under which the paper proof remains applicable to
the richer Rust artifact format.

## Non-goals

- This spec does not redefine the paper CE / folding relations.
- This spec does not claim that the paper itself contains the sidecar metadata.
- This spec does not replace the paper-level `Π_CCS`, `Π_RLC`, `Π_DEC`, or
  final theorem.

## Output expectations

- the formalization exposes an explicit projection from implementation claims to
  paper-core claims,
- the formalization exposes theorem statement shapes for CE / `Π_RLC` /
  `Π_DEC` / whole-artifact refinement,
- future implementation validators can prove their stronger Rust-side checks
  refine the paper-core protocol instead of silently redefining it.
