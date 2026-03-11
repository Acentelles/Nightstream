# Rust Auditability Skill Draft

Purpose: guide AI agents toward Rust changes that are compact, structurally
sound, performance-aware, and easy for auditors to reason about.

This is a draft for a future project skill. It is not a claim that the entire
repo already follows every rule below.

For repo policy and command defaults, see [../AGENTS.md](../AGENTS.md). If this
file and `AGENTS.md` disagree, `AGENTS.md` wins.

---

## 1. North Star

When editing Rust in this repo, optimize for:

1. **Auditability**
   A reviewer should be able to trace important behavior back to a protocol,
   spec, invariant, or performance constraint without fighting through layers of
   helpers and abstractions.

2. **Low structural bloat**
   Avoid AI-shaped code: speculative abstraction, generic wrappers, helper
   explosion, and churn-only cleanup.

3. **Correctness confidence**
   Tests should exercise real crate behavior and fail under realistic
   regressions.

4. **Performance awareness**
   Do not add indirection, allocations, dynamic dispatch, or fragmented control
   flow in hot or protocol-critical paths without a concrete payoff.

5. **Local coherence**
   Prefer fitting the local crate/module pattern over forcing a global style
   rewrite.

This draft is intentionally opinionated. The intended backbone is:

- **Ousterhout**: deep modules, small interfaces, information hiding
- **Hickey**: simplicity over incidental complexity
- **Muratori**: explicitness and performance-aware skepticism of abstraction

The practical standard is:

- fewer concepts,
- fewer layers,
- fewer hidden control paths,
- one obvious place to look for each important invariant.

---

## 2. Operating Mode

Default behavior for AI edits:

1. Solve the task with the smallest credible change.
2. Prefer explicit code over generic frameworks.
3. Keep semantically related logic together.
4. Extract only when the abstraction is simpler than the repeated concrete code.
5. Prefer local clarity over theoretical purity.
6. If a rule adds ceremony without improving confidence, readability, or
   performance, do not apply it.

When unsure between two designs, prefer the one that:

- exposes fewer concepts,
- keeps the critical data flow in fewer places,
- and is easier to explain from inputs to outputs without hand-waving.

---

## 3. Structural Foundations

These are the core design rules. They matter more than formatting or stylistic
uniformity.

### 3.1 DRY means one source of truth for knowledge

DRY does **not** mean “remove all repetition.”

Use this distinction:

- **Bad duplication:** the same domain knowledge, invariant, formula, or policy
  is encoded in multiple places and can drift.
- **Acceptable repetition:** two local code blocks look similar but remain
  easier to understand, audit, or modify separately than a forced abstraction
  would be.

Default rule:

- extract when repetition hides a single source of truth,
- do **not** extract when the shared abstraction would hide protocol meaning or
  create indirection without real reuse.

**Enforcement rule:** duplicated protocol constants, claim ordering, invariants,
or transformation rules are a bug risk and should be consolidated. Superficially
similar local code is not automatically a DRY violation.

### 3.2 Abstraction threshold

Only add an abstraction when all of these are true:

1. the variation is already real, not guessed,
2. the abstraction is simpler than the duplicated concrete code,
3. the interface hides complexity instead of exporting more knobs,
4. the resulting code is easier to audit.

Do **not** add:

- traits for a single implementation,
- generic wrappers around one concrete type,
- builders for small obvious structs,
- framework-like helper layers for one call path.

**Enforcement rule:** reject abstractions that add names, files, or indirection
without reducing the number of ideas a reviewer must hold in their head.

### 3.3 Prefer deep modules with small interfaces

A good module hides mechanism but keeps meaning visible.

Prefer:

- a small public interface,
- substantial internal logic,
- clear ownership of one invariant or transformation.

Avoid:

- shallow modules that only forward calls,
- helper modules that mostly rename other helpers,
- splitting one invariant across many tiny files or wrappers.

**Enforcement rule:** a module should own one coherent invariant family or one
stage of the pipeline. If understanding one behavior requires jumping through
several “thin” modules, the design is too shallow.

### 3.4 Cohesion over fragmentation

Keep code that changes for the same reason together.

Good:

- setup + transform + final assertion for one invariant in one test,
- route-specific logic kept near the route,
- protocol-stage logic kept near the stage it implements.

Bad:

- one invariant spread across five helpers,
- one function split only to satisfy “small function” aesthetics,
- data flow that jumps across files without hiding meaningful complexity.

**Enforcement rule:** code that changes for the same reason should stay
together. Splitting is justified by semantic boundaries, not by line count
alone.

### 3.5 Direct data flow beats indirection

In protocol and proof code, the reader should be able to follow values from:

- input
- transform
- commitment/claim/proof object
- output / assertion

Prefer:

- direct function calls,
- explicit data transformations,
- obvious ownership and movement of values.

Avoid:

- wrapper-on-wrapper APIs,
- “clever” plumbing that obscures where values come from,
- helper chains that require hopping around the file to understand one step.

**Enforcement rule:** in protocol, proof, transcript, and reduction code, a
reviewer should be able to trace critical values through the implementation
without reconstructing hidden control flow.

### 3.6 Performance-sensitive structure

In hot paths or protocol-critical code, treat abstraction as suspect until it is
earned.

Be cautious about:

- extra allocations,
- dynamic dispatch,
- fragmented tiny wrappers,
- data reshaping done only for aesthetic cleanliness,
- helper decomposition that blocks local reasoning about loops or constraints.

The question is not “is this cleaner?” The question is:

- does this preserve or improve performance,
- while still making the code easier to reason about?

**Enforcement rule:** in hot or protocol-critical paths, new abstraction,
allocation, dispatch, cloning, or reshaping needs an explicit reason. “Looks
cleaner” is not enough.

### 3.7 Information hiding must hide mechanism, not meaning

Hide:

- storage details,
- helper machinery,
- repetitive setup,
- low-level encoding mechanics.

Do not hide:

- protocol stage boundaries,
- claim semantics,
- important invariants,
- performance-critical decisions.

**Enforcement rule:** if an abstraction hides the meaning of a protocol step or
proof obligation, it is the wrong abstraction even if it shortens the code.

### 3.8 Large orchestration functions must be split by phase

Large functions are not automatically bad. Large functions that mix multiple
semantic phases, unrelated responsibilities, or evolving state in one place are
bad.

When refactoring a large orchestrator, split by **phase boundary**, not by line
count.

Good phase boundaries usually look like:

- input validation and preflight,
- preprocessing / context construction,
- one-step transition logic,
- finalization / packaging,
- verification / reporting,
- audit or instrumentation export.

Bad splits usually look like:

- tiny wrappers that only forward half the parameters,
- helpers extracted only because a block “looks long,”
- moving code into `utils` without clarifying ownership,
- turning one readable function into a call graph maze.

If a function is large because it coordinates a pipeline, the refactor should:

1. identify the semantic phases,
2. give each phase one clear input/output boundary,
3. keep each phase internally explicit,
4. return structured outputs instead of mutating unrelated locals from afar.

**Enforcement rule:** split orchestration by semantic phase, not by aesthetic
function size.

### 3.9 Reduce giant parameter lists with semantic context, not wrappers

A long parameter list is a problem when it signals that the function is being
asked to reason about too many unrelated things at once.

The same rule applies to large unnamed return tuples. If the caller has to
remember “what position 4 means,” the return shape is too implicit.

The right fix is usually **not**:

- more forwarding helpers,
- more optional knobs,
- more generic builders.

The right fix is:

- group stable environment/configuration into an explicit context struct,
- group evolving mutable state into an explicit phase/state struct,
- separate protocol inputs from debug/audit/instrumentation outputs,
- use named result structs when a function returns multiple semantically distinct
  values,
- make optional behaviors explicit at phase boundaries instead of threading them
  through every helper.

Only introduce a context struct when the grouped fields are genuinely one
semantic unit. Do not create “parameter bags” that hide incoherent design.

**Enforcement rule:** context/state structs must represent real semantic
groupings, not just silence a long signature or an unreadable return tuple.

### 3.10 Mutable state should evolve in owned bundles

When several values evolve together across a sequence of steps, they should be
owned together.

Prefer:

- one explicit state struct per evolving phase,
- clear “state in, state out” transitions,
- local mutation inside the phase that owns it.

Avoid:

- long functions with many unrelated mutable locals,
- mutation of values whose relationship is only implicit,
- helper chains that mutate shared state from several places.

If multiple fields always move together conceptually, make that relationship
explicit in the type structure.

**Enforcement rule:** if a reviewer has to infer which mutable values belong to
the same protocol state, the design is too implicit.

---

## 4. Hard Rules

These are the default non-negotiables unless the user explicitly approves an
exception.

### 4.1 Do not add AI bloat

- Do not add helpers, traits, wrappers, builders, or generic layers unless they
  are justified by real reuse or a concrete reduction in risk.
- Do not rewrite unrelated code just to make the diff look more uniform.
- Do not introduce new Rust features or environment variables unless explicitly
  approved.
- Do not introduce “cleanup” abstractions whose main benefit is aesthetic
  symmetry.
- Do not create API families that enumerate combinations of optional features.
  Prefer one entry point with an options struct when the alternative is a
  combinatorial wrapper surface.

### 4.2 Tests must check real behavior

- Tests must call real crate code, not a local re-implementation of the logic
  under test.
- A test must be able to fail under a realistic regression.
- Do not add compile-checks or tautologies disguised as behavior tests.
- If a bug is being fixed and the best expression is a test, that test should
  fail before the fix.
- Tests should be organized around invariants, failure modes, and contract
  boundaries, not just API surface shape.

### 4.3 Follow repo policy for placement and commands

- Prefer files under `tests/` for new test coverage, per
  [../AGENTS.md](../AGENTS.md).
- Do not add tests inside implementation files.
- Existing `spec-tests/` suites are a local crate convention; when editing one,
  follow the local pattern instead of doing churn-only moves.
- Use deterministic seeded RNGs in randomized tests.
- Use `FoldingMode::Optimized` in tests unless the user explicitly approves
  `PaperExact`.
- After modifying Rust code, run `cargo fmt --all` unless the user explicitly
  says not to.
- When running tests, prefer release mode per [../AGENTS.md](../AGENTS.md).

---

## 5. Preferred Edit Heuristics

These are strong defaults, but they are subordinate to the structural rules
above.

### 5.1 Inline first, extract second

Use this default:

- first use: inline
- second or third real use: consider a small helper
- repeated cross-file use: consider a shared helper

Do not extract just because a block “looks long.” Extract when the name,
interface, and reuse make the code easier to understand.

Do not use “tiny function” style as a goal by itself. A function should be as
small as needed to express one semantic step clearly, and no smaller.

When the problem is a giant coordinator, do not respond with a dozen
single-screen wrappers. Extract meaningful phases with explicit state
boundaries.

### 5.2 Name for the paper/spec reader

Prefer names that reflect:

- the protocol stage,
- the algebraic object,
- the role in the proof or reduction,
- the actual invariant being checked.

Avoid vague names like:

- `tmp`
- `aux2`
- `helper`
- `thing`

unless the scope is tiny and the meaning is completely obvious.

Prefer names that reveal the invariant or stage role over names that merely
sound generic or reusable.

### 5.3 Comment the why

Good comments explain:

- protocol context,
- mathematical reason for a transformation,
- why an ordering or bound matters,
- what coverage is intentionally elsewhere.

Bad comments:

- narrate obvious syntax,
- describe what the next line literally does,
- claim coverage that is not actually present.

### 5.4 Keep assertions informative

Nontrivial assertions should include enough context to debug failures quickly.

Good:

```rust
assert_eq!(
    z_recon[(r, c)],
    z[(r, c)],
    "DEC round-trip failed at ({r},{c}), b={b}, k={k}"
);
```

---

## 6. Test Architecture Guidance

### 6.1 What good tests look like

A good test usually:

1. arranges concrete inputs,
2. calls real crate behavior,
3. asserts a real property.

It should be readable without a second layer of interpretation.

Prefer tests that answer:

- what invariant is being checked,
- what regression would break it,
- why this particular setup is enough.

### 6.2 Shared helpers

Use shared helpers when they reduce repeated setup or repeated comparison logic.

Good helper categories:

- deterministic RNG constructors,
- small field/value constructors,
- repeated reconstruction helpers,
- small assertion helpers.

Bad helper categories:

- hidden copies of the production algorithm,
- giant setup DSLs,
- helper hierarchies bigger than the tests they support.

If a helper makes the test harder to mentally execute, the helper is probably a
mistake.

### 6.3 `spec-tests/` vs `tests/`

Use this rule:

- for new test coverage in new areas: prefer `tests/`
- for existing `spec-tests/` crates: follow the local convention unless moving
  files would buy real simplification or clarity

The goal is better tests, not directory churn.

### 6.4 Spec-derived test doc comments

For spec-derived tests, `///` comments that name the relevant spec or invariant
are a strong default.

For general integration or oracle tests, explain what is being checked, but do
not force an artificial spec reference if that makes the test less honest.

---

## 7. Anti-Patterns

Avoid these unless there is a very strong task-specific reason.

### 7.1 Local clones of production logic in tests

If the test mostly re-implements the algorithm, it is weak.

### 7.2 Churn-only cleanup

Do not rename, reorder, wrap, or restyle unrelated code just to make the diff
look nicer.

### 7.3 Speculative abstraction

Do not add traits, generic structs, or configurable frameworks for variation
the repo does not actually need yet.

This includes “future-proofing” abstractions added without two real use cases or
without a user-approved concrete need.

### 7.4 Helper explosion

Do not split one understandable block into many tiny helpers unless the helpers
meaningfully reduce repetition or make the invariant clearer.

If reading one behavior requires hopping helper-to-helper to reconstruct what
actually happens, the code is too fragmented.

### 7.5 Ceremony over confidence

Do not add patterns that increase ritual without increasing:

- correctness confidence,
- auditability,
- readability,
- performance.

### 7.6 Performance-oblivious refactors

Do not introduce extra allocations, indirection, dynamic dispatch, or scattered
tiny wrappers in performance-sensitive or protocol-critical code without a
concrete reason.

### 7.7 Shallow-module decomposition

Do not split code into multiple files/modules if the split mostly creates
forwarders, wrappers, or naming layers instead of hiding real complexity.

### 7.8 API combinatorics

Do not build public or crate-internal API surfaces by multiplying wrappers over
independent optional behaviors.

Examples of the smell:

- one function per combination of audit / context / output-binding / timing,
- one function per combination of verification/proving extras,
- convenience wrappers that differ only by toggling a small number of flags.

When optional features are genuinely independent, prefer:

- one primary entry point,
- one explicit options/config struct,
- one result struct if outputs vary.

**Why:** combinatorial wrapper APIs increase surface area, drift risk, and
review burden without adding new semantic structure.

---

## 8. Self-Review Checklist For AI Edits

Before finishing a Rust change, check:

- [ ] Did I solve the task with the smallest credible change?
- [ ] Did I remove duplication of knowledge rather than just similar-looking code?
- [ ] Is every abstraction simpler than the concrete code it replaced?
- [ ] If I touched a large orchestrator, did I split it by semantic phase rather than line count?
- [ ] If I introduced a context/state struct, does it represent a real semantic grouping?
- [ ] If I changed a large return shape, is it named and self-describing rather than a positional tuple?
- [ ] Did I avoid shallow-module decomposition and helper layering?
- [ ] Did I avoid combinatorial wrapper/API growth for optional features?
- [ ] Did I keep semantically related logic together?
- [ ] Can a reviewer trace the critical data flow without reconstructing hidden plumbing?
- [ ] Does the code read more clearly to an auditor than before?
- [ ] Did I preserve local crate/module conventions where that was cheaper and clearer than restyling?
- [ ] Do the tests hit real crate behavior?
- [ ] Can the tests fail for a realistic regression?
- [ ] Did I avoid fake coverage and tautologies?
- [ ] Did I run `cargo fmt --all` after Rust edits?
- [ ] Did I run the relevant release-mode tests or explain why not?
- [ ] Did I keep comments honest about what is and is not guaranteed?

---

## 9. Good Example Shapes

These are examples of useful local patterns, not universal laws.

| File | Why it is a useful example |
|---|---|
| `crates/neo-math/spec-tests/ring.rs` | Short property-focused tests against real ring behavior |
| `crates/neo-math/spec-tests/goldilocks.rs` | Math-grounded tests with reasoning comments |
| `crates/neo-ccs/spec-tests/relations.rs` | Larger spec-derived test file with readable structure |
| `crates/neo-math/spec-tests/common/mod.rs` | Small helper module with low ceremony |

Use these as patterns to adapt, not templates to cargo-cult.
