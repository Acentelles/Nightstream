# zkVM Main Lane vs Twist/Shout

This note explains the split between:

- the `main_lane` that proves core zkVM step semantics, and
- the `twist_shout` path that proves memory and lookup origin/consistency facts.

The short version is:

```text
main lane = proves use of values
Twist/Shout = proves origin of values
```

## High-Level Shape

For one shard, both sides talk about the same trace and same witness values.

```text
                 SAME SHARD / SAME WITNESS
                          |
      -------------------------------------------------
      |                       |                       |
      v                       v                       v
  main_lane                Twist                   Shout
  (CPU semantics)          (mutable state)         (read-only fetch / tables)
```

More concretely:

```text
same trace / same witness columns
        |
   -------------------------------
   |                             |
   v                             v
main R1CS/CCS                 Twist/Shout
CPU step semantics            memory / lookup semantics
   |                             |
   v                             v
CE claims                    extra obligations
```

So a real zkVM step usually has:

```text
valid step
  =
(main-lane CPU semantics)
AND
(Twist/Shout memory + lookup semantics)
```

## What Each Side Proves

The `main_lane` proves the step transition itself:

```text
- decode / control consistency
- ALU semantics
- pc_next
- writeback routing
- trace-transition glue
```

Twist and Shout prove that the values consumed by that transition came from the right places:

```text
- register / RAM reads return the correct latest value
- writes update mutable history correctly
- read-only table lookups return the correct public-table row/value
```

This means:

```text
main_lane does NOT prove:
  "this value really came from the right memory/table history"

Twist/Shout does NOT prove:
  "the CPU used this value correctly in the transition"
```

Together they prove:

```text
"the CPU used the correct values correctly"
```

## Concrete Example: `ADDI`

For one cycle, imagine these trace values:

```text
pc
inst
rs1_addr
rd_addr
imm
rs1_val
rd_new
pc_next
```

The proof split looks like this:

```text
bytecode[pc] ---------> inst -----------+
                                        |
register_file[rs1_addr] -> rs1_val -----+----> main_lane checks:
                                        |     rd_new = rs1_val + imm
imm ------------------------------------+     pc_next = pc + 4
                                        |     decode(inst) = ADDI
                                        |
                                        +----> Twist/Shout separately prove
                                              inst and rs1_val came from the
                                              right places
```

What each side proves:

```text
main_lane proves:
  decode(inst) = ADDI
  rd_new       = rs1_val + imm
  pc_next      = pc + 4
  writeback goes to rd_addr

Twist proves:
  rs1_val is the latest value stored at register rs1_addr
  writing rd_new to rd_addr is a valid next write to the register file

Shout proves:
  instruction fetched at pc really equals inst
  optional fixed decode/semantics lookup rows are correct
```

So acceptance means:

```text
"ADDI was executed correctly"
   =
"these inputs/outputs satisfy ADDI transition rules"
   AND
"rs1_val really came from the register file history"
   AND
"inst really came from the bytecode / public lookup table"
```

## Concrete Example: Instruction-Table Lookup

Suppose there is a fixed public table:

```text
T[address] = semantic row
```

where a row could contain:

```text
(opcode tag, flags, helper constants, output pattern, ...)
```

Then the proof split looks like this:

```text
                 public fixed table T
                        |
                        v
                 +--------------+
address -------->|    Shout     |----> proves claimed_row = T[address]
claimed_row ---->|              |
                 +--------------+
                        |
                        | claimed_row is now authenticated
                        v
                 +--------------+
inst ----------->|  main_lane   |----> proves row is the right one for this step
operands ------->|              |      and the step semantics are valid
claimed_row ---->|              |
                 +--------------+
```

Another way to read it:

```text
inst bits / operands
      |
      v
lookup address
      |
      +----------------------------+
      |                            |
      v                            v
Shout proves                  main_lane proves
table[address] = row          address came from inst/operands
                              row outputs are used consistently
                              transition matches that row
```

So:

```text
Shout does NOT prove:
  "the CPU used the row correctly"

main_lane does NOT prove:
  "the row really came from the public table"

together they prove:
  "the CPU used the correct public-table row correctly"
```

## Does Twist/Shout Become CE?

Not in the current model.

Right now the intended flow is:

```text
virtual Twist/Shout relation
    ->
explicit obligation
```

not:

```text
virtual Twist/Shout relation
    ->
CE claim in the SuperNeo main lane
```

So the current picture is:

```text
main_lane contribution:
  CE claims at p_main

twist_shout contribution:
  twistShoutEval obligations
  opening obligations
  final obligations
  CE claims = []
```

This means Twist/Shout is connected to the outer proof system through:

```text
- shared witness / trace values
- shared commitments
- shared transcript
- shared opening / packaging layer
```

but not yet through a proved reduction of the form:

```text
Twist/Shout obligation
    ->
CE claim at p_main
```

## Architectural Reading

The target owner split is:

```text
+--------------------------------------------------+
|                 shard::prover                    |
|          one owner of shard prove flow           |
+--------------------------------------------------+
             |                          |
             | calls                    | calls
             v                          v
+-----------------------+    +--------------------------+
| shard::main_lane      |    | shard::twist_shout      |
| owns SuperNeo CE path |    | owns Twist/Shout        |
| Pi_CCS -> Pi_RLC      |    | projection + extension  |
| -> Pi_DEC             |    | obligations             |
+-----------------------+    +--------------------------+
             |                          |
             | emits                    | emits
             v                          v
     main-lane CE family         projected obligation families
```

Then `shard::prover` classifies what came out:

```text
                   family Γ
                      |
          --------------------------------
          |                              |
          v                              v
all claims are CE at p_main ?       no
          |                              |
        yes                              v
          |                    separately supported
          v                    homogeneous family ?
     mergeMain                        |
                                      |
                            yes ------+------ no
                             |                |
                             v                v
                       foldSeparate      exportFinal
```

## Practical Takeaway

For a real zkVM step:

```text
main lane proves how the opcode behaves
Twist/Shout proves the fetched / lookup / memory values used by that opcode are correct
```

That is the intended division of labor.
