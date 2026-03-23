# Planning Request Context

This file preserves the architecture reasoning developed during planning for
`neo-fold-next`, especially where earlier phase plans were corrected after
re-reading Jolt and the SuperNeo paper.

The goal is to keep the high-signal conclusions and source-backed constraints
in one place so later work does not repeat the same mistakes.

## Scope

This note is about:

- how to think about `neo-fold-next`
- what Jolt is actually doing architecturally
- what SuperNeo actually fixes at the theorem level
- what is known vs not yet known about phase structure

This note is not the final architecture spec.

## Sources Re-Read

Primary sources used for the corrected conclusions:

- [`docs/superneo-paper/02_2_Technical_overview.md`](docs/superneo-paper/02_2_Technical_overview.md)
- [`docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md`](docs/superneo-paper/07_7_Neo_s_folding_scheme_for_CCS.md)
- [`docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md`](docs/jolt-paper/04-3_An_Overview_of_RISC-V_and_Jolts_Approach.md)
- [`docs/jolt-paper/08-7_Putting_It_all_Together_a_SNARK_for_RISC-V_Emulation.md`](docs/jolt-paper/08-7_Putting_It_all_Together_a_SNARK_for_RISC-V_Emulation.md)
- [`docs/jolt-paper/13-B_Overview_of_Memory-Checking_Arguments.md`](docs/jolt-paper/13-B_Overview_of_Memory-Checking_Arguments.md)
- [`external/jolt/jolt-core/src/zkvm/prover.rs`](external/jolt/jolt-core/src/zkvm/prover.rs)
- [`external/jolt/jolt-core/src/zkvm/verifier.rs`](external/jolt/jolt-core/src/zkvm/verifier.rs)
- supporting Jolt family modules under [`external/jolt/jolt-core/src/zkvm`](external/jolt/jolt-core/src/zkvm)

## Core Corrections

Several earlier planning ideas were wrong and were explicitly rejected:

1. Do not copy Jolt's stage count.
   Jolt having 8 stages does not imply `neo-fold-next` should have 8 stages.

2. Do not freeze a phase plan before the proof-family dependency graph exists.
   Real phases should come from proof dependencies, transcript epochs, verifier
   result boundaries, and opening reuse.

3. Do not hide Twist and Shout inside a vague bucket like
   `extension_authentication`.
   That blurs real mathematical ownership.

4. Do not call local CCS construction a proof phase.
   Constructing a relation instance is important, but it is not the same kind
   of protocol boundary as `Π_CCS`, `Π_RLC`, or `Π_DEC`.

5. Do not assume Twist/Shout outputs automatically become SuperNeo `CE` claims.
   That requires a new proved bridge. It does not come for free.

6. Do not model the prover as "one family per opcode."
   Jolt's efficiency comes from shared lookup/memory families and a small core
   constraint system, not from per-opcode proof families.

## What SuperNeo Actually Fixes

At theorem level, the core reduction spine is already known:

- `Π_CCS`
- `Π_RLC`
- `Π_DEC`

These are real protocol boundaries from the paper.

What this means:

- `Π_CCS` is not just "some internal helper"
- `Π_RLC` is not optional architectural sugar
- `Π_DEC` is not post-processing

They are the core reduction spine and should remain explicit in the prover.

Also:

- `Π_CCS` reduces a CCS instance plus carried evaluation state into fresh
  evaluation claims
- `Π_RLC` combines same-point evaluation claims
- `Π_DEC` decomposes a folded claim into bounded children for continued folding

## What Jolt Actually Teaches

The important lesson from Jolt is not "8 stages."

The important lessons are:

1. Keep one explicit top-level prover script.
2. Split stages by real proof-family dependency boundaries.
3. Keep the core constraint system small.
4. Push heavy instruction semantics into lookup families.
5. Keep memory-checking as separate proof families.
6. Centralize final openings at the end.

## Jolt Stage Breakdown

This is the concrete stage reading from the code, not a guessed summary.

| Stage | Jolt label | What it actually does |
|---|---|---|
| 1 | Spartan Outer | Outer uni-skip plus outer remaining sumcheck |
| 2 | Product Virtual | Product-virtual uni-skip plus RAM read/write checking, instruction lookup claim reduction, RAM `raf` evaluation, output check |
| 3 | Instruction | Shift, instruction input, registers claim reduction |
| 4 | Registers+RAM | Registers read/write checking plus RAM value check |
| 5 | Value+Lookup | Instruction read `raf`, RAM RA reduction, registers value evaluation |
| 6 | OneHot+Hamming | Bytecode read `raf`, booleanity, RAM hamming/booleanity, RAM/lookup RA virtualization, increment claim reduction, advice reduction phase 1 |
| 7 | HammingWeight+ClaimReduction | Hamming-weight claim reduction plus advice reduction phase 2 |
| 8 | Dory opening | Joint final opening proof |

See the labels around:

- [`external/jolt/jolt-core/src/zkvm/prover.rs`](external/jolt/jolt-core/src/zkvm/prover.rs)
- especially the summary around line labels near the bottom of that file

## Why Jolt Stage 1 and Stage 2 Cannot Be One Real Stage

This was an important correction.

Stage 1 and Stage 2 cannot be one actual stage in Jolt as currently designed
because Stage 2 consumes state produced by Stage 1.

Concrete reasons:

1. Stage 2 parameter objects reuse Stage 1 openings and challenge-derived
   state.
2. Stage 2 RAM subprotocols also consume Stage 1-derived openings.
3. Stage 1 and Stage 2 have different uni-skip objects and different domains.
4. The verifier treats them as separate stage proofs.
5. The blindfold / ZK wrapper also expects them as separate stage blocks.

So:

- they can be one loose macro-cluster in prose
- they are not one real proof phase in Jolt

That correction matters because it killed the earlier habit of collapsing
families just because they feel semantically related.

## Jolt's zkVM Frontend Lesson

From the paper:

- Jolt avoids implementing each instruction's full semantics directly as a big
  constraint system.
- Instead, it uses lookup tables for instruction semantics and separate
  memory-checking for reads/writes.
- The main constraint system mainly prepares operands, builds queries, routes
  results, and glues state transitions together.

This is the core frontend lesson to copy.

Not:

- one family per opcode
- one R1CS block per opcode
- giant monolithic instruction constraints in the main lane

But:

- small core glue constraints
- lookup families for instruction semantics
- separate memory/history families

## The Useful High-Level Mental Model

This teaching note remains useful:

```text
main lane = proves use of values
Twist/Shout = proves origin of values
```

That is good intuition.

But it is too coarse to drive the architecture by itself.

Why it is insufficient:

- it hides the fact that Jolt has many proof families, not one `twist_shout`
  bucket
- it does not show actual dependency edges
- it can mislead later planning into a fake two-phase model

So the right use of that note is:

- keep it as an explanation artifact
- do not use it as the architecture source of truth

## Current Best Working Model

For a real zkVM step:

- the core CCS/R1CS-style lane should remain relatively small
- instruction semantics should mostly live in lookup families
- mutable read/write correctness should live in memory/history families
- `Π_CCS`, `Π_RLC`, and `Π_DEC` should stay explicit in the prover

This suggests a Jolt-aligned family graph closer to:

```text
program/trace
   |
   +--> bytecode_fetch
   +--> instruction_semantics_lookup
   +--> register_history
   +--> ram_history
   +--> auxiliary shape/range/claim-reduction support
   |
   +--> core_transition_glue
   |
   +--> Π_CCS
   +--> Π_RLC
   +--> Π_DEC
   +--> open_and_finalize
```

## Important Ownership Distinction

What should be explicit in the eventual prover script:

- witness or trace commitments
- any real Twist family steps
- any real Shout family steps
- construction of the core relation instance
- `Π_CCS`
- `Π_RLC`
- `Π_DEC`
- final openings and packaging

What should not be misnamed as proof phases unless later justified:

- generic setup buckets
- vague extension buckets
- local relation assembly
- helper-only reduction support

## Current Stable Ownership Assumptions

These are the boundaries that survived review:

| Owner | Stable meaning |
|---|---|
| `shard::prover` | explicit top-level prove script and transcript sequencing |
| `shard::main_lane` | builds the core relation instance handed to `Π_CCS` |
| `shard::twist` | owns Twist-family proof construction and outputs |
| `shard::shout` | owns Shout-family proof construction and outputs |
| `time_opening` | owns grouped opening reduction and joint-opening preparation |
| `proof` | owns typed proof artifacts and outgoing obligations |
| `session` | step collection, carry handling, facade APIs |
| `frontends` | tracing and adapter code |

## Family Dependency Table

This is the best current dependency table and should be treated as the real
planning artifact until a more detailed one is derived.

| Family | What it proves | Outside core CCS? | Depends on | Feeds into | Jolt analogue | Status |
|---|---|---|---|---|---|---|
| `bytecode_fetch` | instruction at `pc` is the real program instruction | yes | trace, program-code commitments or public table | core glue, maybe decode flags | readonly program-code reads | stable |
| `instruction_semantics_lookup` | claimed semantic row or result matches combined instruction lookup tables | yes | opcode/query values from trace, maybe fetched instruction bits | core glue | evaluation-table / Lasso path | stable |
| `register_history` | register reads and writes match latest register-file history | yes | trace, register access witnesses | core glue | registers RW/value families | stable |
| `ram_history` | load/store reads and writes match latest RAM history | yes | trace, RAM access witnesses | core glue | RAM RW/value families | stable |
| `aux_shape_range` | chunking, one-hot, booleanity, hamming/range, address-shape, virtual-claim support | probably yes | whichever family it supports | lookup/history families, maybe openings | Jolt stages 6-7 support families | open |
| `core_transition_glue` | given authenticated values, the CPU step transition is valid | no | trace plus outputs of fetch/history/lookup families | `Π_CCS` | small R1CS glue over authenticated values | stable |
| `Π_CCS` | reduce core CCS instance plus carried CE input to fresh CE claims | no | core CCS instance plus carried CE | `Π_RLC` | SuperNeo | stable |
| `Π_RLC` | combine admissible same-point CE claims | no | fresh CE plus carried CE | `Π_DEC` | SuperNeo | stable |
| `Π_DEC` | decompose folded CE to bounded carried children | no | folded CE | next-step carry | SuperNeo | stable |
| `open_and_finalize` | discharge openings and package outputs | terminal | all pending openings and proof artifacts | final proof plus local outputs | Jolt Stage 8 style terminal opening | stable |

## What Is Known vs Unknown

### Known

- We do not want one family per opcode.
- We do want a Jolt-like reduction of heavy instruction semantics into lookup
  families.
- We do want a relatively small core relation lane.
- We do want explicit `Π_CCS -> Π_RLC -> Π_DEC`.
- We do want final openings to stay terminal.

### Unknown

- whether Twist is one phase or several
- whether Shout is one phase or several
- whether fetch and instruction-semantics lookup share a transcript epoch
- whether register history and RAM history should remain separate all the way
  through
- whether `aux_shape_range` is one family or several
- whether any non-main family is separately foldable
- the exact prove-time order between Twist, Shout, and core relation assembly

## Review Standard For Any Future Phase Split

Do not promote something into a real prover phase unless at least one of these
is true:

- it produces a distinct proof object
- it requires a fresh transcript or challenge epoch
- later work consumes its openings or claims
- the verifier naturally treats it as a separate result block

If none of those are true, it is probably not a real phase.

## Practical Next Step

Do not guess a final phase plan yet.

Instead derive a more detailed dependency matrix for concrete step shapes, for
example:

- `ADDI`
- one load or store step
- one branch step

For each of those, record:

- traced values
- which families justify them
- which lookup/history families feed the core glue
- what must be carried
- what remains local/final

Only after that should a final prove-time phase plan be frozen.

## Relation To The Current `neo-fold-next` Architecture Spec

The file:

- [`crates/neo-fold-next/specs/Architecture.spec.md`](crates/neo-fold-next/specs/Architecture.spec.md)

was intentionally stripped back to only the stable, source-grounded ownership
and review constraints.

This file exists to preserve the richer planning context and the mistakes that
were corrected, so that later planning can continue from the real state instead
of repeating the same false starts.

## Concrete Step Dependency Matrices

These are not final protocol claims. They are planning matrices for deriving the
real family graph from concrete zkVM step shapes.

The guiding rule is:

- if a step uses a value, some family must justify where that value came from
- the core glue should only prove that those values were used correctly
- the core glue should not re-implement the full heavy semantics when a lookup
  or memory family can carry them more cheaply

### Assumptions For These Matrices

These matrices assume a Jolt-like frontend style:

- instruction semantics are mostly pushed into lookup families
- memory correctness is pushed into history families
- the core CCS lane stays relatively small and mostly glues authenticated values
  into one valid CPU transition

These are planning assumptions, not yet frozen theorem boundaries.

### Step Shape: `ADDI`

Representative traced values:

- `pc`
- `inst`
- `opcode`
- `rs1_addr`
- `rd_addr`
- `imm`
- `rs1_val`
- `result`
- `pc_next`

The intended family split:

| Family | What it justifies for `ADDI` | Consumes | Produces | Feeds core glue? |
|---|---|---|---|---|
| `bytecode_fetch` | `inst` really is the program instruction at `pc` | `pc`, program code view | authenticated `inst` | yes |
| `instruction_semantics_lookup` | the claimed arithmetic result matches the semantics table for `(opcode, x, y)` | `opcode`, `x = rs1_val`, `y = imm` | authenticated `result` or semantic row | yes |
| `register_history` | `rs1_val` is the latest value at `rs1_addr`, and the write to `rd_addr` is consistent with the register trace | `rs1_addr`, `rd_addr`, register read/write witnesses | authenticated register read/write facts | yes |
| `ram_history` | unused for plain `ADDI` | none | none | no |
| `aux_shape_range` | chunking/range support for lookup and register-address structure if required | lookup or register-family witnesses | local support claims | indirectly |
| `core_transition_glue` | given authenticated `inst`, `rs1_val`, `imm`, and `result`, the CPU transition is a valid `ADDI` step | traced values plus authenticated outputs above | core CCS instance | n/a |
| `Π_CCS` | reduces the core CCS instance to fresh CE claims | core CCS instance + carried CE | fresh CE claims | n/a |
| `Π_RLC` | combines admissible CE claims | CE family | folded CE | n/a |
| `Π_DEC` | decomposes folded CE to next-step carry | folded CE | bounded children | n/a |
| `open_and_finalize` | discharges openings and packages outputs | all pending proof artifacts | carried outputs + local outputs | n/a |

What the core glue should check for `ADDI`:

- `inst` decodes to `ADDI`
- operand selection is correct: second input is `imm`, not `rs2`
- lookup query is formed from the right fields
- `result` is routed to `rd_addr`
- `pc_next = pc + 4`
- no unintended RAM effect occurs

What the core glue should not do:

- re-prove full addition semantics if that already lives in the instruction
  lookup family

### Step Shape: `LD`

Representative traced values:

- `pc`
- `inst`
- `opcode`
- `rs1_addr`
- `rd_addr`
- `imm`
- `base_val`
- `eff_addr`
- `loaded_bytes` or `loaded_word`
- `load_result`
- `pc_next`

The intended family split:

| Family | What it justifies for `LD` | Consumes | Produces | Feeds core glue? |
|---|---|---|---|---|
| `bytecode_fetch` | `inst` really is the program instruction at `pc` | `pc`, program code view | authenticated `inst` | yes |
| `instruction_semantics_lookup` | any lookup-driven load semantics, such as sign/zero-extension helpers or byte-layout helpers, are correct | opcode plus prepared query inputs | authenticated semantic result or helper row | yes, if used |
| `register_history` | `base_val` is the latest value at `rs1_addr`; writeback to `rd_addr` is consistent | register read/write witnesses | authenticated register facts | yes |
| `ram_history` | bytes or word read at `eff_addr` are the latest RAM contents and are read consistently | memory read witness, effective-address-related trace values | authenticated RAM read facts | yes |
| `aux_shape_range` | byte decomposition, range checks, chunking, one-hot or address-shape support if needed | RAM or lookup-family witnesses | local support claims | indirectly |
| `core_transition_glue` | given authenticated instruction, base register, effective address, RAM read, and final load result, the CPU transition is a valid load | traced values plus authenticated outputs above | core CCS instance | n/a |
| `Π_CCS` | reduces the core CCS instance to fresh CE claims | core CCS instance + carried CE | fresh CE claims | n/a |
| `Π_RLC` | combines admissible CE claims | CE family | folded CE | n/a |
| `Π_DEC` | decomposes folded CE to next-step carry | folded CE | bounded children | n/a |
| `open_and_finalize` | discharges openings and packages outputs | all pending proof artifacts | carried outputs + local outputs | n/a |

What the core glue should check for `LD`:

- `inst` decodes to the intended load variant
- `eff_addr` is derived correctly from base plus immediate
- the RAM read is routed into the right byte or word assembly path
- any sign or zero extension is applied correctly
- the final load result is written to `rd_addr`
- `pc_next = pc + 4`

What the core glue should not do:

- re-prove "latest RAM value at this address" itself
- absorb the full byte-addressable memory semantics into the main lane

#### `SD` Delta

For `SD`, the same split largely remains, but:

- `register_history` authenticates both the base register and the store-value
  source register
- `ram_history` authenticates the RAM write rather than a RAM read
- there is no register writeback result to `rd`
- the core glue checks store-address derivation, byte routing, and `pc_next`

### Step Shape: `BEQ`

Representative traced values:

- `pc`
- `inst`
- `opcode`
- `rs1_addr`
- `rs2_addr`
- `imm`
- `rs1_val`
- `rs2_val`
- `branch_taken`
- `pc_next`

The intended family split:

| Family | What it justifies for `BEQ` | Consumes | Produces | Feeds core glue? |
|---|---|---|---|---|
| `bytecode_fetch` | `inst` really is the program instruction at `pc` | `pc`, program code view | authenticated `inst` | yes |
| `instruction_semantics_lookup` | branch predicate semantics or comparison semantics are correct for the prepared query | `opcode`, `rs1_val`, `rs2_val` | authenticated `branch_taken` or semantic row | yes |
| `register_history` | `rs1_val` and `rs2_val` are the latest register values | register read witnesses | authenticated register read facts | yes |
| `ram_history` | unused for plain `BEQ` | none | none | no |
| `aux_shape_range` | chunking/range support for lookup representation if required | lookup-family witnesses | local support claims | indirectly |
| `core_transition_glue` | given authenticated compare inputs and branch decision, the CPU transition is a valid `BEQ` step | traced values plus authenticated outputs above | core CCS instance | n/a |
| `Π_CCS` | reduces the core CCS instance to fresh CE claims | core CCS instance + carried CE | fresh CE claims | n/a |
| `Π_RLC` | combines admissible CE claims | CE family | folded CE | n/a |
| `Π_DEC` | decomposes folded CE to next-step carry | folded CE | bounded children | n/a |
| `open_and_finalize` | discharges openings and packages outputs | all pending proof artifacts | carried outputs + local outputs | n/a |

What the core glue should check for `BEQ`:

- `inst` decodes to `BEQ`
- the comparison query is built from the right register values
- `branch_taken` is the authenticated branch predicate result
- `pc_next = pc + imm` if taken, else `pc + 4`
- no register or RAM write is spuriously introduced

### Cross-Step Observations From These Matrices

These concrete examples support a few planning conclusions:

1. `bytecode_fetch` is not optional.
   It appears in every representative step.

2. `instruction_semantics_lookup` should be one shared family, not one family
   per opcode.
   The query changes by opcode; the proof-family concept does not need to.

3. `register_history` is also a shared family.
   It is reused by arithmetic, branch, and memory steps.

4. `ram_history` is selective.
   It is only active for memory-touching steps.

5. `core_transition_glue` should stay small.
   It should check routing, query formation, state-update glue, and step-shape
   consistency, while relying on lookup/history families for the expensive
   semantic assertions.

6. These examples still do not prove the final phase structure.
   They only show the family graph is richer than `main_lane` vs
   `twist_shout`.

## Immediate Next Derivation Target

The next concrete planning artifact should be a dependency or epoch table with
these columns:

- `family`
- `fresh transcript epoch?`
- `opening ids produced`
- `opening ids consumed`
- `can batch with`
- `must precede`
- `proof artifact emitted`

That is the artifact that should determine real prover phases.

## Provisional Epoch / Dependency Table

This table is the next refinement step. It is still provisional, but it is much
closer to a real phase derivation than any earlier guessed phase list.

Interpretation rules:

- `fresh transcript epoch? = yes` means the family almost certainly needs fresh
  verifier challenges after prior commitments/messages.
- `no` means it looks like local construction or a deterministic check, not a
  challenge-bearing proof boundary.
- `unknown` means the current source reading is not enough to safely collapse or
  split it.

| Family | Fresh transcript epoch? | Opening ids produced | Opening ids consumed | Can batch with | Must precede | Proof artifact emitted |
|---|---|---|---|---|---|---|
| `trace_commitments_and_preamble` | yes | commitment openings for traced witness columns | none | n/a | everything else | trace commitments + transcript preamble state |
| `bytecode_fetch` | yes | readonly fetch openings / claims | trace commitments | maybe `instruction_semantics_lookup`, but not yet proven | `core_transition_glue` | readonly fetch proof data |
| `instruction_semantics_lookup` | yes | lookup openings / semantic-row claims | trace commitments, maybe fetched instruction bits | maybe `bytecode_fetch`, maybe other readonly lookup families, unknown | `core_transition_glue` | lookup proof data |
| `register_history` | yes | register read/write openings / history claims | trace commitments | maybe parts of `ram_history` if proof shape truly matches; unknown | `core_transition_glue` | register-history proof data |
| `ram_history` | yes when active | RAM read/write openings / history claims | trace commitments | maybe parts of `register_history`; unknown | `core_transition_glue` | RAM-history proof data |
| `aux_shape_range` | likely yes when implemented as proof families; otherwise local | support openings / auxiliary claims | whichever family it supports | support families with matching proof shape only | whichever lookup/history family depends on it, maybe also `open_and_finalize` | support-proof data or local checks |
| `core_transition_glue` | no | none directly; builds a core CCS instance | authenticated outputs from fetch/lookup/history families + traced values | n/a | `Π_CCS` | core CCS instance |
| `Π_CCS` | yes | fresh main-lane CE claims at the main point | core CCS instance + prior carried CE family | only other claims that are already admissible as the same CE family at the same point | `Π_RLC` | `Π_CCS` proof + fresh CE family |
| `classification_gate` | no | none; partition of collected families | `Π_CCS` outputs + sibling family outputs | n/a | `Π_RLC`, `Π_DEC`, `open_and_finalize` | merge/fold/export decisions |
| `Π_RLC` | yes | folded CE claim | admissible CE family | admissible same-point CE family only | `Π_DEC` | `Π_RLC` proof + folded CE |
| `Π_DEC` | no or protocol-fixed | next-step carried CE children | folded CE claim | n/a | next step, `open_and_finalize` | `Π_DEC` proof + carried children |
| `open_and_finalize` | yes | final joint opening claims / packaged outputs | all pending openings from prior families | all remaining opening work by design | final output only | typed proof artifact + carried outputs + local/final outputs |

### Current Best Read Of Likely Epoch Boundaries

This is not frozen, but it is the best current read:

1. `trace_commitments_and_preamble`
2. one or more readonly lookup epochs
3. one or more mutable-history epochs
4. optional auxiliary support epochs
5. local `core_transition_glue`
6. `Π_CCS`
7. `Π_RLC`
8. protocol-fixed `Π_DEC`
9. `open_and_finalize`

Important caution:

- this is still not a final numbered stage plan
- the unresolved question is how many readonly / mutable / support epochs exist
- those should be derived from actual opening and challenge dependencies, not
  from aesthetics

### Strongest Current Unknowns

These are the exact questions that should determine the final phase split:

1. Can `bytecode_fetch` and `instruction_semantics_lookup` share one transcript
   epoch?
2. Can `register_history` and `ram_history` share one epoch, or do they produce
   different enough claim/opening structures that they should stay separate?
3. Is `aux_shape_range` a real proof family, or mostly support logic embedded in
   the families it serves?
4. Does any non-main family become separately foldable, or do they all remain
   local/final plus opening work?
5. Does `Π_DEC` require its own meaningful transcript epoch in the actual
   instantiation, or is it effectively a deterministic decomposition boundary?

### Phase-Derivation Rule

The eventual prove-time phases should be read off from this table, not guessed
beforehand:

- if two rows share the same challenge epoch and no row depends on the other's
  outputs, they may collapse
- if a row consumes another row's openings or challenge-derived claims, they
  are different phases
- if the verifier would naturally store them as separate result objects, they
  are probably different phases

## Jolt Comparison Table

This table is not saying we should mechanically copy Jolt.

It is saying:

- identify what Jolt is doing
- decide whether the role is one we also need
- decide whether to copy, adapt, or reject it

The standard here is:

- `copy` if the role and dependency shape match closely
- `adapt` if the role is real but the exact Jolt structure is too Jolt-specific
- `reject` if it is not part of the right architecture for `neo-fold-next`

| Jolt stage or family | Our intended family or boundary | Same role? | Same dependency pattern? | Copy / adapt / reject | Why |
|---|---|---|---|---|---|
| Stage 1 `Spartan Outer` | `Π_CCS` core reduction entry boundary | partial | partial | adapt | Jolt Stage 1 is the start of Spartan's proving spine; we also need an explicit core reduction entry boundary, but ours is the SuperNeo `Π_CCS` theorem surface, not Jolt's exact outer-Spartan object |
| Stage 2 `Product Virtual` | no single direct analogue; spread across lookup/history families plus auxiliary claim reductions | partial | no | adapt | The role is real: batched downstream families that consume earlier openings. But the concrete family mix is Jolt-specific |
| Stage 3 `Instruction` | parts of `instruction_semantics_lookup` plus possible core operand/query glue | partial | partial | adapt | We also need instruction-query construction and later semantic checks, but not in Jolt's exact family boundaries |
| Stage 4 `Registers+RAM` | `register_history` + `ram_history` | yes | likely yes in spirit, not exact form | adapt | We definitely need mutable history families. Exact splitting and opening structure still need to be derived |
| Stage 5 `Value+Lookup` | `instruction_semantics_lookup` plus later history-claim reductions | yes | partial | adapt | This is close to the "prove lookup-driven values and reduce related claims" role we expect, but exact decomposition will differ |
| Stage 6 `OneHot+Hamming` | `aux_shape_range` support families | yes | likely yes | adapt | We probably need analogous support families, but only where they are justified by our actual chosen lookup/history schemes |
| Stage 7 `HammingWeight+ClaimReduction` | later auxiliary reductions, if any | yes | unknown | adapt | The role exists conceptually, but it is premature to hard-code a matching phase before our dependency graph exists |
| Stage 8 `Dory batch opening` | `open_and_finalize` | yes | yes | copy at role level, adapt at mechanism level | We absolutely want one terminal opening/finalization boundary. The concrete PCS/opening mechanism may differ |
| Jolt unified instruction evaluation table | `instruction_semantics_lookup` | yes | yes | copy at architecture level, adapt at math/details | This is one of the clearest lessons to copy: do not prove every opcode in the core lane |
| Jolt readonly program-code reads | `bytecode_fetch` | yes | yes | copy at role level, adapt at implementation | Every step needs authenticated instruction fetch |
| Jolt registers memory-checking | `register_history` | yes | yes | copy at role level, adapt at proof details | Shared register-history family is clearly the right shape |
| Jolt RAM memory-checking | `ram_history` | yes | yes | copy at role level, adapt at proof details | Separate RAM history is also clearly the right shape |
| Jolt one family per actual stage proof object | explicit prover-visible family boundaries | yes | yes | copy | This is one of the most important architectural lessons: keep real proof-family boundaries visible |
| Jolt exact count of 8 stages | fixed `neo-fold-next` stage count | no | no | reject | This was an explicit mistake in earlier planning |
| Jolt exact family names | direct naming copy | no | no | reject | Our names should reflect our own ownership boundaries, not imported labels |
| Jolt exact split between Stage 3/4/5/6/7 | fixed prove-time stage plan today | no | no | reject for now | The correct split must come from our own dependency table, not stage mimicry |
| giant core per-opcode constraint encoding | `core_transition_glue` doing full instruction semantics | no | no | reject | Opposite of the main Jolt frontend lesson |
| vague `twist_shout` mega-bucket | one giant extension phase | no | no | reject | Too coarse; hides the real family graph |

### Highest-Confidence "Copy" Conclusions

These are the strongest conclusions from the comparison:

1. Keep one explicit top-level prover script.
2. Keep final openings terminal.
3. Keep instruction semantics mostly out of the core lane.
4. Keep register and RAM history as explicit families.
5. Keep proof-family boundaries visible in the prover.

### Highest-Confidence "Reject" Conclusions

These are the strongest things not to do:

1. Do not copy Jolt's exact stage count.
2. Do not freeze Jolt's exact stage split into `neo-fold-next`.
3. Do not put full opcode semantics into the core CCS lane.
4. Do not collapse all non-core work into one `twist_shout` bucket.

### Highest-Confidence "Adapt" Conclusions

These are the things we almost certainly need, but in our own source-grounded
shape:

1. a shared instruction-semantics lookup family
2. shared register-history and RAM-history families
3. auxiliary range / shape / virtualization support only where the selected
   proof systems actually need them
4. a final opening layer that gathers what the earlier families emitted

## Frozen Scaffold Tree

The Rust scaffold was updated to match the current highest-confidence ownership
split.

Old coarse top-level modules removed:

- `instruction_lookup`
- `memory_sidecar`
- flat `shard.rs`

Current tree:

```text
crates/neo-fold-next/src/
  lib.rs
  proof.rs
  session.rs
  frontends.rs
  time_opening.rs
  output_binding.rs
  finalize.rs
  shard/
    mod.rs
    prover.rs
    verifier.rs
    main_lane.rs
    shout/
      mod.rs
      bytecode_fetch.rs
      instruction_semantics_lookup.rs
    twist/
      mod.rs
      register_history.rs
      ram_history.rs
```

Why this tree was frozen now:

1. `shard::prover` and `shard::verifier` are real top-level owners.
2. `main_lane` is a real stable owner for core relation construction.
3. `shout` and `twist` are real stable owners.
4. `bytecode_fetch`, `instruction_semantics_lookup`, `register_history`, and
   `ram_history` are the current highest-confidence concrete families.
5. `aux_shape_range` was intentionally not frozen into its own module yet
   because that split is still dependency-sensitive.

What is still intentionally not frozen in the scaffold:

- exact internal subfamilies under `shout`
- exact internal subfamilies under `twist`
- whether auxiliary support logic becomes standalone modules
- whether any family deserves a separate reduction helper module

Rule:

- freeze only owners that survived the source-backed review
- delay module proliferation until the dependency table proves it is needed
