# Neo / Twist / Shout Glossary

This glossary fixes the local meaning of overloaded terms used in the Neo + Twist/Shout integration.

The terms are ordered by dependency: smaller local units first, larger grouping and proof-ownership terms later.

## Core Terms

### VM Step

A **VM step** is one executed trace row from the VM.

This is the smallest execution-level unit in this glossary.

### Folding Chunk

A **folding chunk** is one unit consumed by one iteration of the folding loop.

A chunk can represent:

- one VM step, or
- a user-defined batch of VM steps.

Each chunk is represented by one `StepWitnessBundle`, which carries:

- one CPU/MCS witness,
- the Twist instances for that same chunk,
- the Shout instances for that same chunk,
- and the chunk-local time columns.

### Instance

An **instance** is one logical memory or lookup object inside a chunk.

Examples:

- a Twist instance for one logical memory identified by `mem_id`,
- a Shout instance for one lookup table identified by `table_id`.

### Access Lane

An **access lane** is one parallel access slot inside one instance.

For Twist, one access lane is one canonical slice of witness columns:

- `ra_bits`,
- `wa_bits`,
- `has_read`,
- `has_write`,
- `wv`,
- `rv`,
- `inc_at_write_addr`.

For Shout, one access lane is one canonical slice:

- `addr_bits`,
- `has_lookup`,
- `val`.

This is a per-instance, per-chunk witness-layout concept.

### Shared Bus

The **shared bus** is the witness-column region jointly used by:

- the CPU CCS binding logic, and
- the auxiliary memory / lookup relations for the same chunk.

It is the common plumbing layer that lets the CPU trace and the memory/lookup arguments talk about the same per-time witness data.

### Sidecar

A **sidecar** is an auxiliary proving layer attached to the main CCS proof path.

It is not the core CCS relation itself. It consumes shared-bus openings and emits additional ME claims or obligations needed for memory-checking or lookup soundness.

In the current codebase, Twist/Shout integration lives in the shared CPU-bus memory-sidecar path.

### Projection

A **projection** is the step that turns a Twist/Shout paper-level virtual relation into an explicit verifier-facing obligation family.

In the current formal bridge, projection means:

- start from a Twist/Shout relation,
- produce one or more explicit obligations,
- keep their source as `twistShout`,
- and assign them a relation kind such as `twistShoutEval`, `opening`, or `final`.

This is **not** the same thing as a main-lane merge.

Projection means:

- virtual Twist/Shout relation -> explicit obligation family.

Main-lane merge means:

- a family is already admissible as `.ce` claims at the main point, so it can enter the main lane.

Right now those are separate steps. Projected Twist/Shout families do not automatically become main-lane families. Without a separate proved bridge turning some projected family into genuine `.ce` claims at the main point, the projected family must remain separate or be exported/finalized.

### Folding Lane

A **folding lane** is one RLC/DEC batch grouped by a shared evaluation point.

The important ones are:

- **main lane**: ME claims evaluated at the shared time point `r_time`,
- **val lane**: extra ME claims evaluated at `r_val`.

Shout lives on the main lane.

Twist lives on:

- the main lane for its read/write checks, and
- the val lane for its `Val`-evaluation obligations.

The val lane exists because Twist's `Val` reconstruction uses fresh sum-check challenges and therefore cannot be folded into the same single-point ME batch as `r_time`.

### Shard

A **shard** is a trace segment processed as one higher-level proving job.

A shard is a collection of folding chunks. It is **not** one giant shard-wide Twist or Shout instance.

## Current Integration Shape

For the current Neo integration, the correct mental model is:

- Twist and Shout are instantiated **per folding chunk**.
- They are integrated through the **shared CPU-bus sidecar** path.
- They are **not** one shard-wide sidecar merge that runs only once at the end.
- Shout contributes obligations on the **main lane**.
- Twist contributes obligations on the **main lane** and on the separate **val lane**.

## One-Line Summary

If you need the shortest version:

- **VM step** = one executed trace row.
- **chunk** = one fold iteration over one or more VM steps.
- **instance** = one logical memory/table object inside a chunk.
- **access lane** = one per-instance witness slice.
- **shared bus** = common witness columns for CPU and auxiliary memory/lookup logic.
- **sidecar** = auxiliary proof owner attached to CCS.
- **projection** = Twist/Shout virtual relation turned into explicit obligations.
- **folding lane** = one RLC/DEC batch at one evaluation point.
- **shard** = a proving job over a collection of chunks.
