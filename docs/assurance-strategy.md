# Assurance Strategy for a Staged zkVM

We need confidence in two things:

1. The staged proof design is mathematically sound.
2. The Rust implementation actually matches that design.

These are different problems. We solve them with different layers.


## The three layers

```
+----------------------------------+
| Layer 1: Lean proofs             |
| Prove the staged design is       |
| mathematically sound.            |
+----------------+-----------------+
                 |
                 | defines the digest type
                 v
+----------------------------------+
| Layer 2: Differential testing    |
| Run same programs through Rust   |
| and Lean, compare digest values. |
| Fast feedback during development.|
+----------------+-----------------+
                 |
                 v
+----------------------------------+
| Layer 3: Lean checker            |
| Verify that the stage boundaries |
| in a Rust-produced proof connect |
| correctly per the proved design. |
| Mandatory for release builds.    |
+----------------------------------+
```

Production runs Rust only. The audit machinery stays out of the hot path.

```
Production:
  Rust verifier, nothing else.

CI / nightly / release:
  Lean proofs build.
  Differential tests run.
  Lean checker runs (mandatory for release).
```


## Why three layers

There are three separate questions:

```
Q1. Is the staged zkVM design itself sound?
    --> Layer 1: Lean proofs

Q2. Does the Rust code behave like the design during development?
    --> Layer 2: Differential testing

Q3. Do the stages in a real Rust-produced proof connect correctly?
    --> Layer 3: Lean checker
```


## Layer 1: Lean proofs — prove the design is sound

Lean proves the mathematical statement behind the staged zkVM.
In plain terms:

```
If Stage 1 facts hold,
and Stage 2 facts hold,
and Stage 3 facts hold,
and they all refer to the same authenticated inputs,
then the claimed zkVM execution is semantically correct.
```

This answers: "Is the design sound?"

It does not require proving all Rust code correct.

Where we stand today:

```
SuperNeo (folding protocol)      proof-complete   ~34K lines of Lean
Twist/Shout (memory checking)    proof-complete   ~7.2K lines of Lean
Nightstream bridge (composition) active           ~1K lines of Lean
```

SuperNeo carries one explicit assumption: MSIS hardness. This is
intentional and standard. Twist/Shout has zero assumptions on its
active path. The bridge layer composes both and owns the CHIP-8
kernel formalization.


## Layer 2: Differential testing — catch bugs during development

Run the same programs through Rust and through a Lean reference
model. Compare the outputs at a well-defined boundary.

```
            same program, same input
                   /          \
                  v            v
          +-----------+  +-----------+
          |   Rust    |  |   Lean    |
          | execution |  | execution |
          +-----+-----+  +-----+-----+
                |              |
                v              v
            digest          digest
                \              /
                 v            v
              +----------------+
              |    compare     |
              +----------------+
```

This is a fast feedback loop. It catches implementation bugs during
development and in CI. It does not prove correctness. It finds
divergences. The more programs you run, the more bugs you catch,
but you never get a proof of absence.

The comparison is only as good as what you compare. If the boundary
is vague, subtle bugs hide. This is why the digest type must be
defined precisely (see next section).


## Layer 3: Lean checker — verify stage boundaries connect correctly

A staged zkVM proof is not one monolithic thing. It is multiple
stages, each producing outputs that the next stage consumes as
inputs. The soundness of the whole proof depends on these handoffs
being correct.

```
         Stage 1          Stage 2          Stage 3
        +-------+        +-------+        +-------+
 in --> |       | --??--> |       | --??--> |       | --> out
        +-------+        +-------+        +-------+

The Lean checker verifies the ??'s:
  "Do the stages actually connect correctly?"
```

After Rust produces a proof, the Lean checker takes the inputs and
outputs of each stage and verifies that they fit together the way
the proved design requires. Concretely, it checks things like:

```
- Do Stage 2's inputs match Stage 1's outputs?
- Do Stage 3's inputs match Stage 2's outputs?
- Does the program ROM commitment stay consistent across stages?
- Do the stage boundaries satisfy the relations that the
  composition theorem requires?
```

The Rust verifier and the Lean checker do different jobs:

```
Rust verifier:   "Each stage's cryptography is internally valid."
                 (commitments open correctly, sum-check
                  transcripts verify, etc.)

Lean checker:    "The stages were stitched together correctly."
                 (the inputs and outputs at each boundary
                  satisfy the composition theorem's conditions.)
```

Neither alone is sufficient. The Rust verifier could pass on a
proof where each stage is individually valid but the stages don't
actually compose into a coherent execution. The Lean checker
catches that.

For release builds, the Lean checker is mandatory.

The distinction from Layer 2: differential testing checks "did Rust
and Lean agree on these particular test programs I chose?" The Lean
checker verifies "do the stage boundaries in this specific proof
that Rust just produced connect correctly?" One is sampling. The
other checks a concrete artifact.


## The digest type — the contract between Rust and Lean

The digest is not the final output of the proof. It is the inputs
and outputs at each stage boundary, collected into one structure.

This type must be defined in Lean, not in Rust.

If Rust defines what it exports, the format drifts toward whatever
is convenient for the implementation. If Lean defines the type, the
format is dictated by what the proofs actually need. Drift becomes
a type error, not a silent bug.

```
Correct direction:
  Lean defines the digest type (from proof surfaces)
  --> Rust must populate that type
  --> Lean checker verifies the populated instance

Wrong direction:
  Rust decides what to export --> Lean checks it
```

Concretely, the digest type is the minimal structure that the
composition theorem quantifies over:

```
StagedExecutionDigest :=
  program_rom_commitment   : Hash
  stage1_output            : Stage1PublicSurface
  stage2_output            : Stage2PublicSurface
  stage3_continuity        : ContinuityBridgeSurface
  final_semantic_result    : ExecutionResult
```

Each sub-type already exists (or is derivable from) the interfaces
in the Nightstream bridge layer. The composition theorem in
StepComposition.lean already consumes these surfaces. The digest
type falls out of what that theorem needs.

Both Rust and Lean produce values of this type. In Layer 2, we
compare them. In Layer 3, the Lean checker verifies the Rust-
produced instance.


## Key design decisions

Three decisions that shaped this strategy.


### Decision 1: The Lean checker is mandatory, not optional

A common pattern is to treat formal-methods tooling as a nice extra
that runs when someone remembers to turn it on. We do the opposite.

```
              Development          Release
              ---------            -------
Fast loop:    Rust vs Lean         Rust vs Lean
              diff testing         diff testing
              (catches bugs)       (catches bugs)

Assurance     --                   Lean checker
gate:                              (mandatory)
```

Differential testing is the fast feedback loop. It runs in CI and
catches regressions early. But it is sampling: it only covers the
programs you thought to test.

The Lean checker is the gate. If you are shipping a release, the
checker runs. If it fails, you do not ship.


### Decision 2: Lean defines the contract, not Rust

The digest type lives in Lean because the proofs live in Lean.

If Rust defines the export format, the format reflects
implementation internals. Fields get added because they are easy to
export, not because they matter semantically. Over time, the Lean
checker ends up validating a shape that no theorem actually covers.

If Lean defines the type, every field in the digest is a field that
some theorem consumes. If Rust cannot populate a field, that is a
signal that the implementation has diverged from the design. The
type itself enforces alignment.

```
Lean proof surfaces
        |
        | defines
        v
StagedExecutionDigest (Lean type)
        |
        | Rust serializes into
        v
Rust digest export
        |
        | Lean checker verifies
        v
pass / fail
```

The Nightstream bridge layer already has the right skeleton for
this. StepComposition.lean composes stage-boundary surfaces, so
the digest type falls out of what that theorem consumes.


### Decision 3: One explicit type for the semantic boundary

The comparison boundary between Rust and Lean is not a list of
ad-hoc fields. It is a single Lean-defined type that both sides
must produce.

This makes differential testing precise: you are comparing
instances of the same type, not eyeballing whether two outputs
"look similar." And it makes the Lean checker a type-check,
not a heuristic.


## How this stays zero-overhead in production

Production builds do not include the audit path.

```
Default production build:
  verify() --> Rust verifier only

Audit / release build:
  verify() --> Rust verifier
                 |
                 +--> export digest
                 |
                 +--> Lean checker
```

If we gate this behind a Rust feature, that feature controls:

```
Yes:                          No:
  digest export                 verifier semantics
  Lean checker invocation       protocol rules
  audit-only tests              hot-path behavior
```

The feature means "include audit tooling in this build."
It does not mean "change how verification works."


## Full picture

```
+-------------------------------+
| Lean proofs                   |
| staged design is sound        |
| (SuperNeo + Twist/Shout +     |
|  Nightstream bridge)          |
+---------------+---------------+
                |
                v
  defines StagedExecutionDigest
                |
        +-------+-------+
        |               |
        v               v
+---------------+ +---------------+
| Rust produces | | Lean produces |
| digest values | | digest values |
+-------+-------+ +-------+-------+
        |               |
        v               v
+-------------------------------+
| Development: diff testing     |
| compare digests on many       |
| programs, fast CI feedback    |
+-------------------------------+
        |
        v (release qualification)
+-------------------------------+
| Release: Lean checker         |
| verify stage boundaries in    |
| Rust digest connect correctly |
| mandatory for release builds  |
+-------------------------------+
```


## Summary

```
Layer 1  Lean proofs             The design is proved sound.

Layer 2  Differential testing    Rust and Lean agree on real
                                 programs during development.
                                 Fast CI feedback.

Layer 3  Lean checker            The stage boundaries in a
                                 specific Rust-produced proof
                                 connect correctly per the
                                 proved design.
                                 Mandatory for releases.
```

The three layers address different risks at different costs.
Layer 1 is done once and maintained. Layer 2 runs continuously
and cheaply. Layer 3 runs at release time and gives the strongest
guarantee short of verifying the Rust code itself.

Production stays Rust-only. The Lean machinery exists for
confidence, not for runtime.
