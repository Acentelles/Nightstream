# CHIP-8 Kernel Specification

## Scope

Normative spec for the CHIP-8 proving kernel. Design principles:

1. obligations match `docs/soundness-specs/twist-and-shout-requirements.md`,
2. opcode proof obligations are allocated to the correct proving layer,
3. Shout/Twist soundness assumptions are discharged directly,
4. only row-local constraints are projected to the SuperNeo main lane; non-local
   obligations live in explicit auxiliary protocols.

Field: Goldilocks, `F = 2^64 - 2^32 + 1`.
Extension field: `K = F[u]/(u^2 + 1)`.

---

## 1. Commitment Bundle

A single Phase-0 commitment to the main-lane matrix does **not** authenticate
the Stage 2 memory polynomials.

The kernel commits the following objects before any stage-specific challenge is
sampled:

- `C_lane`: the 23 non-fixed main-lane column MLEs for the padded semantic lane
  `M_lane ∈ F^{T × 24}`, where rows `j ∈ [0, N)` are semantic and rows
  `j ∈ [N, T)` are the public pad rows from §3.2; the `ONE` coordinate is fixed
  separately as `1`.
- `C_fetch_ra`: the Stage-1 fetch one-hot address family over `ROMAddr × Cycle`.
- `C_decode_ra`: the Stage-1 decode one-hot address family over `Opcode × Cycle`.
- `C_alu_ra`: the Stage-1 ALU/branch one-hot address family over `AluKey × Cycle`.
- `C_eq4_ra`: the Stage-1 burst-equality one-hot address family over `Eq4Key × Cycle`.
- `C_decode_handoff`: the per-cycle Stage-1-to-Stage-2 decode-handoff surface.
- `C_reg`: the register-file Twist witness family over `Addr_reg × Cycle`.
- `C_ram`: the RAM Twist witness family over `Addr_ram × Cycle`.
- `C_rom_table`: the committed absolute ROM table.
- `C_decode_table`: the committed full-opcode decode table.
- `C_alu_table`: the committed `Add8Lo` subtable.
- `C_eq4_table`: the committed `Eq4` table.
- `meta_pub`: challenge-relevant public metadata: program image digest,
  `program_word_count`,
  table digests, trace length `N`, padding shape, domain-size choices,
  variable-order identifiers, zero/sink-address conventions, the absolute
  `program_base_addr`, the absolute self-loop padding address `pad_pc_word`, and
  initial-state digest(s).
  `meta_pub` is verifier-recomputed from public inputs and protocol constants;
  it is not accepted as prover-chosen metadata.

The transcript root is:

```text
root0 = H(
    C_lane,
    C_fetch_ra,
    C_decode_ra,
    C_alu_ra,
    C_eq4_ra,
    C_decode_handoff,
    C_reg,
    C_ram,
    C_rom_table,
    C_decode_table,
    C_alu_table,
    C_eq4_table,
    meta_pub
)
```

All later challenges are sampled only after `root0` is fixed.

This is the commitment-before-challenge discipline required by the Twist/Shout
soundness note.

### 1.1 Two commitment layers

This kernel uses two distinct commitment layers, and the bridge is the only place
they meet.

- Kernel opening commitments:
  - `C_lane`,
  - `C_fetch_ra`,
  - `C_decode_ra`,
  - `C_alu_ra`,
  - `C_eq4_ra`,
  - `C_decode_handoff`,
  - `C_reg`,
  - `C_ram`,
  - `C_rom_table`,
  - `C_decode_table`,
  - `C_alu_table`,
  - `C_eq4_table`.

  These are the MLE/opening commitments owned by the 3-stage kernel. They are the
  only commitments that may appear in `KernelOpeningManifest`.

- Root main-lane commitments:
  - `PreparedStep_j.mcs.c = Ajtai_commit(Z_j)`.

  These are root-prover commitments created only after bridge extraction. They are
  not equal to any `C_*` commitment, they are not opened as kernel claims, and
  they are not authenticated by `root0`.

Normative bridge invariant:

- open the 23 committed non-fixed lane coordinates of row `j` from `C_lane`,
- insert the fixed coordinate `ONE = 1`,
- compute `RootEncode(z_j) = (w_j, Z_j)`,
- recompute `Ajtai_commit(Z_j)`,
- compare it to `PreparedStep_j.mcs.c`.

Any implementation that conflates kernel opening commitments with root Ajtai
commitments is non-conforming.

### 1.2 Fixed hypercube domains and absolute ROM addressing

Every committed family is evaluated over an actual hypercube. This spec does not
permit symbolic domains like `log 18` or `log 4097`.

Named arities:

```text
ADDR_REG_BITS = 5     // 32-point register-address hypercube
ADDR_RAM_BITS = 13    // 8192-point RAM-address hypercube
ROM_ADDR_BITS  = 11   // 2048 CHIP-8 word addresses
CYCLE_BITS     = ceil_log2(N)
T              = 2^{CYCLE_BITS}
```

Normative domain rules:

- `Addr_reg` uses the full 5-bit hypercube:
  - active slots `0..17`,
  - padded slots `18..31`, which are inert and may never be selected.
- `Addr_ram` uses the full 13-bit hypercube:
  - active slots `0..4096`,
  - padded slots `4097..8191`, which are inert and may never be selected.
- `ROMAddr` uses the full 11-bit hypercube of absolute CHIP-8 word addresses
  `0..2047`.

Normative address model:

- `PC` and `NNN_WORD` are absolute CHIP-8 word addresses.
- `NNN_ADDR` is the raw absolute CHIP-8 byte address.
- On jump rows, Stage 1 authenticates `NNN_ADDR = 2 * NNN_WORD`.
- The fetch channel reads the absolute ROM word table at address `PC`.

Normative ROM-table layout:

- the committed ROM table is the full absolute 11-bit CHIP-8 word-address space,
- the loaded program image occupies
  `[program_base_addr / 2, program_base_addr / 2 + program_word_count)`,
- the public pad address `pad_pc_word` stores the self-loop padding opcode
  `Jump(2 * pad_pc_word)`,
- all other unused absolute ROM words are zero.

---

## 2. Soundness Boundary Against Twist-and-Shout

The kernel claims only the paper-level Shout/Twist PIOP soundness surfaces that
it actually instantiates, plus the extra instantiation terms.

### 2.1 Booleanity is **not** discharged by Ajtai norm bounds

Ajtai binding or small-norm witness bounds do **not** prove that one-hot entries
lie in `{0,1}`. Booleanity remains an explicit proof obligation unless some
separate gadget proves bitness.

### 2.1b Field-specific shortcut

The `2^{-1}` shortcut for the Hamming-weight-1 check is valid over Goldilocks
(characteristic ≠ 2). If this kernel were instantiated over a characteristic-2
field, the direct sumcheck must be used instead.

### 2.2 Multiple lookup channels and multiple read ports must be accounted for separately

- Stage 1 has at least four logical lookup channels:
  - fetch: `PC -> opcode_word`,
  - decode: `opcode_word -> decoded tuple`,
  - ALU/branch: selected operands `-> LOOKUP_OUTPUT`.
  - burst equality: `(X_IDX, x_bound_dec) -> BURST_LAST`.
- Stage 2 cannot use one register read-address family for all opcodes because
  CHIP-8 rows may need multiple simultaneous reads (`x`, `y`, and `I`).

Each instantiated Shout/Twist channel contributes its own theorem surface,
unless it is batched exactly as allowed by the paper.

### 2.3 Virtual-polynomial discipline

The following objects may be virtual only through checked reductions from
committed/authenticated sources:

- `opcode_word`,
- decoded fields such as `x_dec`, `y_dec`, `kk_dec`, `nnn_addr_dec`,
  `nnn_word_dec`,
- `alu_lhs`, `alu_rhs`,
- RAM addresses such as `I + X_IDX`,
- Stage-1 flattened address polynomials `raf_fetch`, `raf_decode`, `raf_alu`,
  `raf_eq4`
  derived from committed one-hot families,
- Stage 2 address polynomials `ra_*`, `wa_*`,
- Twist's `Val` evaluation claims.

The verifier must never accept a direct prover-supplied evaluation of those
objects as a soundness-carrying claim.

### 2.4 Authentic table evaluations

A table MLE must either:

- be verifier-computable at random points in `O(log K)` time, or
- come from a separately authenticated source under the relevant table
  commitment.

Normative rule for this kernel:

- `Identity` and `Equal8` may be verifier-computable directly.
- in v1, the padded ROM table, full-opcode decode table, `Add8Lo` subtable, and
  `Eq4` table are always committed under `C_rom_table`, `C_decode_table`,
  `C_alu_table`, and `C_eq4_table` and are always absorbed into `root0`,
- direct verifier evaluators may be used as cross-checks, but they do not make
  those four commitment fields optional in this spec.

Normative ALU mixed-evaluation rule:

- the Stage-1 ALU address family ranges over the full 18-bit key
  `(lookup_kind || lhs || rhs)`,
- the ALU value function over that 18-bit key is the mixed multilinear
  evaluator

```text
Val_alu(tag, lhs, rhs)
  = χ_NoLookup(tag) * 0
  + χ_Identity(tag) * Identity(lhs)
  + χ_Equal8(tag)  * Equal8(lhs, rhs)
  + χ_Add8Lo(tag)  * Add8Lo(lhs, rhs)
```

  where `χ_*` are the multilinear basis selectors for the 2-bit `lookup_kind`
  tag,
- `Identity` and `Equal8` are verifier-computable terms of that evaluator,
- `Add8Lo(lhs, rhs)` is authenticated under `C_alu_table` at the 16-bit
  projected point `r_add8lo_addr = (lhs, rhs)`,
- the verifier must use that exact mixed evaluator when checking the ALU Shout
  claim; it must not interpret `C_alu_table` as a standalone 18-bit combined
  table commitment.

### 2.4a Public-table authentication

Transcript binding of table commitments is not by itself semantic authentication
of the intended public tables.

Normative v1 rule:

- the verifier reconstructs the canonical public ROM / decode / Add8Lo / Eq4
  tables from
  `(vm_spec, public_program_image, program_base_addr, pad_pc_word, protocol version,
    domain-size choices, variable-order identifiers, and root-parameter identifiers)`,
- `meta_pub` is verifier-recomputed from that same public boundary and protocol
  constants; it is never accepted as prover-chosen metadata,
- for each public table commitment `C_rom_table`, `C_decode_table`,
  `C_alu_table`, and `C_eq4_table`, the verifier must either:
  1. recompute the commitment and check equality when the commitment scheme is
     deterministic, or
  2. verify an explicit binding proof from the commitment to the canonical
     public table digest,
- hashing prover-supplied table digests into `meta_pub` is not sufficient by
  itself.

---

## 3. Main Lane

The main lane contains only the row-local data that the SuperNeo spine needs.
Non-local lookup, memory-history, and continuity checks stay in kernel Stage 1,
kernel Stage 2, and kernel Stage 3.
The root main-lane prover is the sole owner of the row-local CCS proof over these
rows. The simple kernel projects and binds these rows, but does not duplicate the
same local proof inside the kernel.

### 3.1 Main-lane witness layout

The main lane uses a `24`-coordinate layout carrying the minimum control/address
data needed to project the row-local constraints into the main lane.

| Col | Name             | Meaning |
|-----|------------------|---------|
| 0   | ONE              | Constant `1` |
| 1   | PC               | Word-indexed PC before the row |
| 2   | PC_NEXT          | Word-indexed PC after the row |
| 3   | REG_X            | Value at the primary register slot for this row |
| 4   | REG_Y            | Secondary register-source value, or `0` when unused |
| 5   | REG_X_NEXT       | Next value for the primary register slot |
| 6   | I_REG            | `I` before the row |
| 7   | I_NEXT           | `I` after the row |
| 8   | KK               | Decoded `kk` immediate |
| 9   | NNN_ADDR         | Raw 12-bit byte address immediate used by `LdI` |
| 10  | NNN_WORD         | Word-index jump target used by `Jump` |
| 11  | MEM_VALUE        | Memory transfer value: store byte, load byte, or `0` |
| 12  | LOOKUP_OUTPUT    | ALU/branch lookup output, or `0` when inactive |
| 13  | WritesLookupToX  | Boolean |
| 14  | WritesMemToX     | Boolean |
| 15  | PreservesX       | Boolean |
| 16  | WritesNnnToI     | Boolean |
| 17  | IsJump           | Boolean |
| 18  | IsBranch         | Boolean |
| 19  | IsMemOp          | Boolean |
| 20  | X_IDX            | Primary register index; for burst ops this is the current burst index |
| 21  | Y_IDX            | Secondary register index when used |
| 22  | BURST_LAST       | Boolean; `1` iff this row is the last `Fx55/Fx65` micro-step |
| 23  | RAM_ADDR         | Numeric RAM address on active RAM rows, else `0` |

`W = 24`.

`ONE` is a semantic coordinate of every row, but it is not committed under
`C_lane`. The kernel and the root prover both treat it as the verifier-known
constant `1`.

### 3.2 Public pad-row rule

The padded trace length is `T = 2^{CYCLE_BITS}`. For every padded row
`j ∈ [N, T)`, the committed kernel surfaces use one public inert row rule.

Semantic pad row:

```text
ONE             = 1
PC              = pad_pc_word
PC_NEXT         = pad_pc_word
REG_X           = 0
REG_Y           = 0
REG_X_NEXT      = 0
I_REG           = 0
I_NEXT          = 0
KK              = 0
NNN_ADDR        = 2 * pad_pc_word
NNN_WORD        = pad_pc_word
MEM_VALUE       = 0
LOOKUP_OUTPUT   = 0
WritesLookupToX = 0
WritesMemToX    = 0
PreservesX      = 1
WritesNnnToI    = 0
IsJump          = 1
IsBranch        = 0
IsMemOp         = 0
X_IDX           = 0
Y_IDX           = 0
BURST_LAST      = 0
RAM_ADDR        = 0
```

Associated auxiliary padding rules:

- `C_decode_handoff` is all zero on padded rows.
- Stage-1 padded rows select:
  - `ra_fetch = pad_pc_word`,
  - `ra_decode = Jump(2 * pad_pc_word)`,
  - `ra_alu = NoLookup(0, 0)`,
  - `ra_eq4 = Eq4(0, 0)`.
- Stage-2 padded rows route all read/write families to sink/inert addresses and
  set `RegInc = 0`, `RamInc = 0`.
- Padded register addresses `18..31` and padded RAM addresses `4097..8191` are
  permanently zero/inert and may never be selected by any one-hot address family.

### 3.3 Uniform interpretation of the X lane

The X lane is total on every row.

- For ordinary `x`-based opcodes, `X_IDX = x_dec`.
- For `Fx55/Fx65`, `X_IDX` is the **current burst index**.
- For opcodes with no semantic `x` field, `X_IDX` is fixed by decode to `0`
  and the row is treated as preserving the dummy X lane.

This keeps the main lane uniform while making the actual write/no-write semantics
explicit in the projected row-local columns and the supporting kernel stages.

---

## 4. Root Main-Lane Row Relation

This section defines the row-local relation proved by the root main lane after
bridge handoff. The kernel does not duplicate this local proof.

### 4.1 Row-local R1CS

Boolean rows (`8` total):

```text
b · (b - 1) = 0
for b in {
  WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
  IsJump, IsBranch, IsMemOp, BURST_LAST
}
```

X-lane partition (`1` row):

```text
WritesLookupToX + WritesMemToX + PreservesX - 1 = 0
```

X-lane routing (`3` rows):

```text
WritesLookupToX · (REG_X_NEXT - LOOKUP_OUTPUT) = 0
WritesMemToX    · (REG_X_NEXT - MEM_VALUE)     = 0
PreservesX      · (REG_X_NEXT - REG_X)         = 0
```

I-lane routing (`1` row):

```text
WritesNnnToI · (NNN_ADDR - I_REG) = I_NEXT - I_REG
```

PC routing (`4` rows):

```text
IsJump   · (PC_NEXT - NNN_WORD)                  = 0
IsBranch · (PC_NEXT - PC - ONE - LOOKUP_OUTPUT)  = 0
IsMemOp  · (PC_NEXT - PC - BURST_LAST)           = 0
(ONE - IsJump - IsBranch - IsMemOp) · (PC_NEXT - PC - ONE) = 0
```

RAM-address routing (`2` rows):

```text
IsMemOp · (RAM_ADDR - I_REG - X_IDX) = 0
(ONE - IsMemOp) · RAM_ADDR = 0
```

Total row-local rows: `19`.

### 4.2 The root main lane does **not** prove opcode decode by itself

The root main lane only proves the local field equalities above.
It does **not** prove:

- that the flags are valid for the fetched opcode,
- that `KK`/`NNN_ADDR`/`NNN_WORD` are the decoded immediates,
- that `X_IDX`/`Y_IDX` are the decoded register indices,
- that `LOOKUP_OUTPUT` came from the correct public table,
- that `MEM_VALUE` matches RAM history,
- that the committed RAM one-hot family encodes the same numeric `RAM_ADDR`,
- or that register values come from the authenticated register file.

Those are discharged in kernel Stage 1, kernel Stage 2, and kernel Stage 3.

### 4.3 Continuity obligations exported to kernel Stage 3

Without execution-trace continuity, the proof only shows a bag of locally
consistent rows. The kernel enforces column-MLE shift checks over `C_lane`:

PC continuity:

```text
forall j < N-1: PC(j+1) = PC_NEXT(j)
```

Burst progression on intermediate `Fx55/Fx65` rows:

```text
forall j < N-1:
  IsMemOp(j) · (1 - BURST_LAST(j)) · (X_IDX(j+1) - X_IDX(j) - 1) = 0
```

Burst-start boundary:

```text
IsMemOp(0) · X_IDX(0) = 0
forall j < N-1:
  IsMemOp(j+1) · (1 - IsMemOp(j) + BURST_LAST(j)) · X_IDX(j+1) = 0
```

These are not projected as CCS rows. They are owned by kernel Stage 3 as an
explicit continuity support relation over `C_lane`.

---

## 5. Stage 1: Fetch, Decode, ALU/Branch, and Burst-Equality Lookups

### 5.0 Shared Stage-1 cycle point

Stage 1 uses one explicit shared cycle challenge

```text
r_lookup ∈ K^{CYCLE_BITS}
```

sampled once from the transcript before any Stage-1 linkage check is run.

Every Stage-1 Shout channel in this spec is instantiated at that same cycle
point `r_lookup`. The channel-specific address points
`r_fetch_addr`, `r_decode_addr`, `r_alu_addr`, and `r_eq4_addr` remain distinct
terminal points of their respective Stage-1 subprotocols, but they all bind to
the same shared Stage-1 cycle point.

### 5.1 Fetch channel

The fetch channel proves the virtual opcode polynomial:

```text
opcode_word(j) = ROM_abs[PC(j)]
```

using a Shout read-only lookup against the authenticated ROM table.

This channel has its own address family `ra_fetch`, its own one-hot proof
obligations, and its own Shout theorem surface unless batched exactly as allowed
by the paper. The one-hot family is committed under `C_fetch_ra`.

### 5.2 Full-opcode decode channel

The decode channel is keyed by the **full 16-bit fetched opcode**, not merely by
its coarse class.

The decode table outputs at least the following authenticated tuple:

```text
(valid,
 x_dec, y_dec, kk_dec, nnn_addr_dec, nnn_word_dec,
 writes_lookup_to_x_dec,
 writes_mem_to_x_dec,
 preserves_x_dec,
 writes_nnn_to_i_dec,
 is_jump_dec,
 is_branch_dec,
 is_memop_dec,
 is_store_dec,
 is_load_dec,
 reads_ram_dec,
 writes_ram_dec,
 uses_y_dec,
 lookup_kind_dec,
 lhs_selector_dec,
 rhs_selector_dec,
 x_bound_dec)
```

Normative checks performed against `C_lane` at the Stage-1 lane point `r_lookup`:

```text
valid = 1
KK  = kk_dec
NNN_ADDR = nnn_addr_dec
NNN_WORD = nnn_word_dec
WritesLookupToX = writes_lookup_to_x_dec
WritesMemToX    = writes_mem_to_x_dec
PreservesX      = preserves_x_dec
WritesNnnToI    = writes_nnn_to_i_dec
IsJump          = is_jump_dec
IsBranch        = is_branch_dec
IsMemOp         = is_memop_dec
```

Normative decode exclusivity invariants:

```text
(WritesLookupToX + WritesMemToX) * WritesNnnToI = 0
IsJump * IsBranch = 0
IsJump * IsMemOp  = 0
IsBranch * IsMemOp = 0
is_store_dec * is_load_dec = 0
is_store_dec + is_load_dec = is_memop_dec
reads_ram_dec * writes_ram_dec = 0
reads_ram_dec + writes_ram_dec = is_memop_dec
writes_ram_dec = is_store_dec
reads_ram_dec = is_load_dec
IsJump * (NNN_ADDR - NNN_WORD - NNN_WORD) = 0
```

Normative totality/default rules for inactive decode outputs:

- every decode output column is total over the full 16-bit opcode domain,
- fields that are semantically inactive on a row default to `0` unless stated
  otherwise,
- if `lookup_kind_dec = NoLookup`, then
  - `lhs_selector_dec = ConstZero`,
  - `rhs_selector_dec = ConstZero`,
  - `alu_lhs = 0`,
  - `alu_rhs = 0`,
  - the ALU lookup key is `(NoLookup, 0, 0)`,
  - and `LOOKUP_OUTPUT = 0`,
- if `IsMemOp = 0`, then
  - `x_bound_dec = 0`,
  - and `BURST_LAST = 0`,
- if an opcode has no semantic `kk`, `nnn`, `x`, or `y` field, the corresponding
  decoded field defaults to `0`.

If the ALU table is committed rather than verifier-computable, the NoLookup
branch is still enforced by the mixed evaluator rule
`Val_alu(NoLookup, lhs, rhs) = 0`.

Index/burst projection:

```text
if IsMemOp = 0 then X_IDX = x_dec
if uses_y_dec = 1 then Y_IDX = y_dec else Y_IDX = 0
if IsMemOp = 1 then BURST_LAST = burst_eq
if IsMemOp = 0 then BURST_LAST = 0
```

Stage 1 owns only the `Y_IDX` projection. The zeroing rule for `REG_Y` on
`uses_y_dec = 0` rows is discharged later in Stage 2 via sink-routed `RegRaY`
and the linkage `rv_y_claim = REG_Y`.

This channel's one-hot address family is committed under `C_decode_ra`.
The `NNN_ADDR`/`NNN_WORD` split is mandatory: `NNN_ADDR` is the raw byte address
used by `LdI`, while `NNN_WORD` is the normalized word target used by `Jump`. On
jump rows, Stage 1 authenticates the alignment relation
`NNN_ADDR = 2 * NNN_WORD`.

### 5.2b Decode-handoff surface

Some decode outputs are needed by Stage 2 but are not part of the root row-local
CCS. Those values are carried on a separate committed per-cycle surface:

```text
C_decode_handoff = {
    handoff_uses_y(j),
    handoff_reads_ram(j),
    handoff_writes_ram(j)
}
```

Stage 1 proves at `r_lookup` that:

```text
handoff_uses_y     = uses_y_dec
handoff_reads_ram  = reads_ram_dec
handoff_writes_ram = writes_ram_dec
```

Normative handoff meaning:

- `handoff_uses_y`, `handoff_reads_ram`, and `handoff_writes_ram` are committed
  cycle-indexed MLEs under `C_decode_handoff`,
- `C_decode_handoff` is a 3-column cycle commitment over all `T` rows; it is not
  a tuple of three scalars captured at `r_lookup`,
- Stage 1 proves, via the Stage-1 linkage batch at `r_lookup`, that those
  committed MLEs equal the corresponding authenticated decode-output
  polynomials over the cycle domain,
- Stage 2 later opens those same committed MLEs at `r_twist_cycle`.

These three columns are the only Stage-1 decode outputs that remain live inputs to
Stage 2 after the Stage-1 lookup checks complete.

### 5.3 ALU/branch lookup channel

The ALU/branch channel uses the authenticated decode selectors to form the
virtual operands:

```text
alu_lhs = Sel(lhs_selector_dec; REG_X, REG_Y, KK, 0)
alu_rhs = Sel(rhs_selector_dec; REG_X, REG_Y, KK, 0)
```

and proves

```text
LOOKUP_OUTPUT = Val_alu(lookup_kind_dec, alu_lhs, alu_rhs)
```

with the following totality rule:

```text
if lookup_kind_dec = NoLookup then LOOKUP_OUTPUT = 0
```

This constrains `LOOKUP_OUTPUT` to zero on opcodes such as `Jump`, `LdI`, and
intermediate burst rows.

Normative ALU evaluator:

```text
Val_alu(tag, lhs, rhs)
  = χ_NoLookup(tag) * 0
  + χ_Identity(tag) * Identity(lhs)
  + χ_Equal8(tag)  * Equal8(lhs, rhs)
  + χ_Add8Lo(tag)  * Add8Lo(lhs, rhs)
```

where `χ_*` are the multilinear basis selectors for the 2-bit `lookup_kind`
tag. The `Add8Lo` branch is the only branch that may depend on `C_alu_table`;
the other three branches are verifier-computable.

Stage 1 opens `C_alu_table` only at the projected 16-bit point

```text
r_add8lo_addr = (r_alu_addr[2], ..., r_alu_addr[17]) = (r_lhs, r_rhs)
```

obtained by dropping the first two `lookup_kind` coordinates from the full
18-bit ALU-key point `r_alu_addr = (r_kind, r_lhs, r_rhs)`.

Normative table-construction rule:

```text
Val_alu(NoLookup, lhs, rhs) = 0 for all lhs, rhs
```

Together with the decode defaults from §5.2, this means NoLookup rows route both
operand selectors to the constant-zero slot, use the concrete key `(00, 0, 0)`,
and force `LOOKUP_OUTPUT = 0`.

This channel's one-hot address family is committed under `C_alu_ra`.

### 5.4 Burst-equality lookup channel

The simple kernel proves burst termination with a dedicated Stage-1 `Eq4` Shout
channel:

```text
burst_eq(j) = Eq4(X_IDX(j), x_bound_dec(j))
```

and checks:

```text
if IsMemOp = 1 then BURST_LAST = burst_eq
if IsMemOp = 0 then BURST_LAST = 0
```

The `Eq4` table remains the ordinary equality table, so in particular
`Eq4(0, 0) = 1`. Inactivity is enforced only by the explicit mask
`BURST_LAST = IsMemOp * burst_eq`; the table itself is not special-cased on
non-memory rows.

This channel's one-hot address family is committed under `C_eq4_ra`.

### 5.5 Address-correctness obligations for Stage 1

Every Stage-1 Shout channel has its own address-correctness obligations:

- Booleanity,
- Hamming-weight `1`,
- decode consistency.

Those obligations apply separately to at least:

- `ra_fetch`,
- `ra_decode`,
- `ra_alu`.
- `ra_eq4`.

Normative decode-consistency identities:

```text
Σ_a  ra_fetch(a, j)  · a = PC(j)
Σ_op ra_decode(op, j) · op = opcode_word(j)
Σ_k  ra_alu(k, j)    · k = flatten_alu_key(lookup_kind_dec(j), alu_lhs(j), alu_rhs(j))
Σ_k  ra_eq4(k, j)    · k = 16 · X_IDX(j) + x_bound_dec(j)
```

where:

```text
flatten_alu_key(kind, lhs, rhs) = 2^16 · kind + 2^8 · lhs + rhs
```

If the implementation batches them, the batch soundness term must be included.

### 5.5a Stage-1 linkage batch

The Stage-1 Shout subprotocols authenticate decode outputs, ALU outputs, burst
equality, and the readonly tables. The committed lane columns and
`C_decode_handoff` columns must then be linked back to those authenticated
objects by an explicit scalar equality batch at `r_lookup`.

Stage 1 samples `γ_lookup_link` and checks:

```text
ℓ0  = KK - kk_dec
ℓ1  = NNN_ADDR - nnn_addr_dec
ℓ2  = NNN_WORD - nnn_word_dec
ℓ3  = WritesLookupToX - writes_lookup_to_x_dec
ℓ4  = WritesMemToX - writes_mem_to_x_dec
ℓ5  = PreservesX - preserves_x_dec
ℓ6  = WritesNnnToI - writes_nnn_to_i_dec
ℓ7  = IsJump - is_jump_dec
ℓ8  = IsBranch - is_branch_dec
ℓ9  = IsMemOp - is_memop_dec
ℓ10 = LOOKUP_OUTPUT - Val_alu(lookup_kind_dec, alu_lhs, alu_rhs)
ℓ11 = BURST_LAST - IsMemOp * burst_eq
ℓ12 = (1 - IsMemOp) * (X_IDX - x_dec)
ℓ13 = uses_y_dec * (Y_IDX - y_dec) + (1 - uses_y_dec) * Y_IDX
ℓ14 = handoff_uses_y - uses_y_dec
ℓ15 = handoff_reads_ram - reads_ram_dec
ℓ16 = handoff_writes_ram - writes_ram_dec
```

and proves the single batched equality

```text
0 = ℓ0
  + γ_lookup_link   · ℓ1
  + γ_lookup_link^2 · ℓ2
  + ...
  + γ_lookup_link^16 · ℓ16
```

This is an instantiation-level linkage proof. It is not one of the theorem-level
Shout surfaces, so its soundness term is accounted separately in §10.

---

## 6. Stage 2: Twist Memory Checking

### 6.0 Shared Stage-2 cycle point

Stage 2 uses one explicit shared cycle challenge

```text
r_twist_cycle ∈ K^{CYCLE_BITS}
```

sampled once from the transcript before the Stage-2 Twist subprotocols are run.

Every Stage-2 register and RAM subclaim in this spec is instantiated at that
same cycle point `r_twist_cycle`. The address points `r_addr_reg` and
`r_addr_ram` remain separate terminal points of the register-side and RAM-side
subprotocols, but they both bind to that shared Stage-2 cycle point.

### 6.1 Register-file domain and ports

The register-file domain is extended with a sink address `⊥_reg`.

Real slots:

```text
0..15 -> V[0]..V[15]
16    -> I
17    -> ⊥_reg
```

Twist objects over `C_reg`:

- committed objects:
  - `RegInc(j)`,
  - read-address families:
  - `RegRaX(a, j)`,
  - `RegRaY(a, j)`,
  - `RegRaI(a, j)`,
- write-address family:
  - `RegWa(a, j)`.
- virtual object:
  - `RegVal(a, j)`, defined only through the explicit Twist `Val`-from-`Inc`
    relation and never as an independently committed polynomial.

Port meanings:

- `RegRaX` always reads the primary register slot `X_IDX`.
- `RegRaY` reads `Y_IDX` when `uses_y_dec = 1`, else reads `⊥_reg`.
- `RegRaI` always reads slot `16`.
- `RegWa` writes:
  - `X_IDX` when `WritesLookupToX or WritesMemToX`,
  - slot `16` when `WritesNnnToI`,
  - `⊥_reg` otherwise.

Sink semantics:

```text
RegVal(⊥_reg, 0) = 0
RegVal(⊥_reg, j+1) = RegVal(⊥_reg, j)
RegInc(j) = 0 whenever RegWa points to ⊥_reg
```

This preserves the theorem's exact one-hot assumption while still representing
"inactive" ports and "no write" rows.

Operational meaning:

- on an active non-sink register write, `RegInc(j)` is the committed write delta
  `new_value - old_value` for the addressed slot,
- on every other row, `RegInc(j) = 0`.

### 6.2 Register-file lane linkage

Stage 2 must open the relevant main-lane columns from `C_lane` at the Twist cycle
point `r_twist_cycle`, not by reusing openings from any other kernel stage.

Stage 2 also consumes the authenticated Stage-1 decode handoff columns from
`C_decode_handoff`. Those bits are not projected into the root main lane because
they are not part of the root row-local CCS relation. They are part of the
Stage-1-to-Stage-2 kernel interface and must be transcript-bound before any
Stage-2 challenge is sampled.

Required lane openings at `r_twist_cycle` include at least:

```text
REG_X, REG_Y, REG_X_NEXT, I_REG, I_NEXT,
WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
X_IDX, Y_IDX
```

Required authenticated Stage-1 decode-handoff openings from `C_decode_handoff` at
`r_twist_cycle` include at least:

```text
uses_y_dec, reads_ram_dec, writes_ram_dec
```

Register read claims:

```text
rv_x_claim = REG_X
rv_y_claim = REG_Y
rv_i_claim = I_REG
```

Register write claim:

```text
wv_reg_claim =
    (WritesLookupToX + WritesMemToX) * REG_X_NEXT
  + WritesNnnToI * I_NEXT
```

with sink routing enforcing `wv_reg_claim = 0` when `RegWa` points to `⊥_reg`.

These are scalar claims emitted by the Stage-2 Twist subproofs; the linkage
batch later proves they equal the opened lane/handoff values.

Register read/write batch:

Stage 2 samples `γ_reg` before the register read/write sumcheck and proves the
single batched identity

```text
claim_reg_rw = wv_reg_claim
             + γ_reg · rv_x_claim
             + γ_reg^2 · rv_y_claim
             + γ_reg^3 · rv_i_claim
```

with

```text
claim_reg_rw
= Σ_j eq(r_twist_cycle, j) · Σ_a (
      RegWa(a, j)  · (RegInc(j) + RegVal(a, j))
    + γ_reg   · RegRaX(a, j) · RegVal(a, j)
    + γ_reg^2 · RegRaY(a, j) · RegVal(a, j)
    + γ_reg^3 · RegRaI(a, j) · RegVal(a, j)
  )
```

This is the same random-linear-combination pattern Jolt uses for its
register read/write batch, extended to the extra authenticated `I` read port
used by CHIP-8.

Val handoff rule:

```text
reg_val_from_inc_proof authenticates RegVal(r_addr_reg, r_twist_cycle)
```

The register read/write batch and every later Stage-2 register-side subclaim may
consume only that authenticated `RegVal(r_addr_reg, r_twist_cycle)` evaluation.
They must not use a direct opening of `RegVal` from `C_reg`, because `RegVal` is
virtual and not a primary committed polynomial.

### 6.2a Stage-2 linkage batch

The Stage-2 read/write and RAF subprotocols consume scalar claims that must match
opened lane/handoff values. Those cross-surface equalities are explicit
instantiation-level checks, not free consequences of the Twist theorem surface.

Stage 2 samples `γ_twist_link` and checks:

```text
m0 = rv_x_claim - REG_X
m1 = rv_y_claim - REG_Y
m2 = rv_i_claim - I_REG
m3 = wv_reg_claim
   - ((WritesLookupToX + WritesMemToX) * REG_X_NEXT + WritesNnnToI * I_NEXT)
m4 = rv_ram_claim - handoff_reads_ram * MEM_VALUE
m5 = wv_ram_claim - handoff_writes_ram * MEM_VALUE
m6 = handoff_writes_ram * (MEM_VALUE - REG_X)
m7 = (1 - handoff_reads_ram - handoff_writes_ram) * MEM_VALUE
```

and proves the single batched equality

```text
0 = m0
  + γ_twist_link   · m1
  + γ_twist_link^2 · m2
  + γ_twist_link^3 · m3
  + γ_twist_link^4 · m4
  + γ_twist_link^5 · m5
  + γ_twist_link^6 · m6
  + γ_twist_link^7 · m7
```

This linkage batch is separate from the theorem-level Twist read/write/Val/RAF
surfaces and is accounted separately in §10.

### 6.3 RAM domain and ports

The RAM domain is extended with a sink address `⊥_ram = 4096`.

Real RAM slots:

```text
0..4095 -> RAM
4096    -> ⊥_ram
```

Twist objects over `C_ram`:

- committed objects:
  - `RamInc(j)`,
  - `RamRa(a, j)`,
  - `RamWa(a, j)`.
- virtual object:
  - `RamVal(a, j)`, defined only through the explicit Twist `Val`-from-`Inc`
    relation and never as an independently committed polynomial.

Port meanings:

- `RamRa` points to `RAM_ADDR` when `reads_ram_dec = 1`, else `⊥_ram`.
- `RamWa` points to `RAM_ADDR` when `writes_ram_dec = 1`, else `⊥_ram`.

Sink semantics:

```text
RamVal(⊥_ram, 0) = 0
RamVal(⊥_ram, j+1) = RamVal(⊥_ram, j)
RamInc(j) = 0 whenever RamWa points to ⊥_ram
```

Normative RAM-address rule:

```text
RAM_ADDR = I_REG + X_IDX on active RAM rows
RAM_ADDR = 0 otherwise
```

In `simple.rs`, that numeric address is proved by the root main-lane rows from
§4.1, while Stage 2 proves that the committed RAM one-hot family encodes the same
address over the fixed `0..4095` CHIP-8 RAM domain.

Operational meaning:

- on an active non-sink RAM write, `RamInc(j)` is the committed write delta
  `new_value - old_value` for the addressed RAM slot,
- on every other row, `RamInc(j) = 0`.

### 6.4 RAM lane linkage

Required main-lane openings from `C_lane` at `r_twist_cycle` include at least:

```text
REG_X, MEM_VALUE, IsMemOp, X_IDX, I_REG, RAM_ADDR
```

Totality rule for `MEM_VALUE`:

```text
if writes_ram_dec = 1 then MEM_VALUE = REG_X
if reads_ram_dec  = 1 then MEM_VALUE = RAM-read value
otherwise MEM_VALUE = 0
```

This constrains `MEM_VALUE` on every row.

The register-linkage columns from §6.2 and the RAM-linkage columns from §6.4 are
opened as one deduplicated batched `C_lane @ r_twist_cycle` opening. Shared
columns are opened once and reused by both subsystems.

Derived RAM read/write claims:

```text
rv_ram_claim = reads_ram_dec  · MEM_VALUE
wv_ram_claim = writes_ram_dec · MEM_VALUE
```

These are scalar claims emitted by the RAM-side Twist subproofs; the linkage
batch later proves they equal the opened lane/handoff values.

RAM read/write batch:

Stage 2 samples `γ_ram` before the RAM read/write sumcheck and proves the
single batched identity

```text
claim_ram_rw = rv_ram_claim + γ_ram · wv_ram_claim
```

with

```text
claim_ram_rw
= Σ_j eq(r_twist_cycle, j) · Σ_a (
      RamRa(a, j) · RamVal(a, j)
    + γ_ram · RamWa(a, j) · (RamInc(j) + RamVal(a, j))
  )
```

This is the same random-linear-combination pattern Jolt uses for RAM
read/write checking, adapted to the explicit separate `RamRa` / `RamWa`
families in this CHIP-8 kernel.

Val handoff rule:

```text
ram_val_from_inc_proof authenticates RamVal(r_addr_ram, r_twist_cycle)
```

The RAM read/write batch and the RAM RAF support proofs may consume only that
authenticated `RamVal(r_addr_ram, r_twist_cycle)` evaluation. They must not use
a direct opening of `RamVal` from `C_ram`, because `RamVal` is virtual and not a
primary committed polynomial.

### 6.5 RAM RAF support relation

Stage 2 also owns a Jolt-style RAM-address support relation tying the committed
RAM one-hot family back to the numeric lane address.

Define the address-only aggregated one-hot families at the Stage-2 cycle point
`r_twist_cycle`:

```text
ra_read(a)  = Σ_j eq(r_twist_cycle, j) · RamRa(a, j)
ra_write(a) = Σ_j eq(r_twist_cycle, j) · RamWa(a, j)
```

Define the CHIP-8 unmap polynomial over the fixed RAM domain:

```text
unmap_chip8(a) = a      for a in {0..4095}
unmap_chip8(⊥_ram) = 0
unmap_chip8(a) = 0      for a in {4097..8191}
```

Then Stage 2 proves the support identities:

```text
Σ_a ra_read(a)  · unmap_chip8(a) = reads_ram_dec  · RAM_ADDR
Σ_a ra_write(a) · unmap_chip8(a) = writes_ram_dec · RAM_ADDR
```

These support equations do not replace the raw sink-routing equations from §6.7.
`unmap_chip8(⊥_ram) = 0` is used only inside this numeric support relation; sink
selection itself is forced separately by the explicit raw-address identities.

The normalized address point `r_addr_ram` is shared across the RAM read/write,
RAM `Val`-from-`Inc`, and RAM RAF support relations after Stage-2 address-round
alignment, in the same spirit as Jolt's RAM-address schedule.

This is the fixed-domain CHIP-8 analogue of Jolt's RAM RAF evaluation.
It does two jobs at once:

- it binds the committed RAM address family to the same numeric `RAM_ADDR`
  projected into the main lane,
- and, because the active RAM domain is exactly `0..4095`, it discharges the
  effective RAM-range obligation without adding a separate ad hoc range gadget.

### 6.6 Twist subclaims that must remain explicit

For the register subsystem and the RAM subsystem separately, the proof keeps the
soundness-carrying Twist relations explicit.

Normative `simple` rule:

- register read/write checking is carried by one explicit batched proof
  `reg_rw_batched_proof`,
- RAM read/write checking is carried by one explicit batched proof
  `ram_rw_batched_proof`,
- `Val`-from-`Inc` evaluation remains separate for registers and RAM,
- RAM RAF support remains separate for read and write,
- address-correctness remains separate for every one-hot family.

Stage-2 batching is therefore partial and explicit. It does not collapse the
whole stage into one opaque “memory passed” proof.

### 6.7 Address-correctness obligations for Stage 2

Address-correctness is required for **every** Stage-2 address family:

- `RegRaX`,
- `RegRaY`,
- `RegRaI`,
- `RegWa`,
- `RamRa`,
- `RamWa`.

For each family, the kernel proves:

- Booleanity,
- Hamming-weight `1`,
- decode consistency.

Normative Stage-2 sink-routing rule:

The support/unmap equations used elsewhere do **not** by themselves force a
family to route to the sink on inactive rows. Sink-capable families therefore
also require explicit raw-address equations.

Stage-2 raw-address identities:

```text
Σ_a RegRaX(a, j) · a
  = X_IDX(j)

Σ_a RegRaY(a, j) · a
  = uses_y_dec(j) · Y_IDX(j) + (1 - uses_y_dec(j)) · 17

Σ_a RegRaI(a, j) · a
  = 16

Σ_a RegWa(a, j) · a
  = (WritesLookupToX(j) + WritesMemToX(j)) · X_IDX(j)
  + WritesNnnToI(j) · 16
  + (1 - WritesLookupToX(j) - WritesMemToX(j) - WritesNnnToI(j)) · 17

Σ_a RamRa(a, j) · a
  = reads_ram_dec(j) · RAM_ADDR(j) + (1 - reads_ram_dec(j)) · 4096

Σ_a RamWa(a, j) · a
  = writes_ram_dec(j) · RAM_ADDR(j) + (1 - writes_ram_dec(j)) · 4096
```

These equations force inactive rows to route to `⊥_reg = 17` or
`⊥_ram = 4096`, rather than merely unmapping to zero.

For the RAM families, these raw sink-routing equations are in addition to the
RAM RAF support equations from §6.5.

A `Σ wa(k,j) ≤ 1` rule does not discharge the paper's one-hot assumption.
Sink addresses are used instead.

### 6.8 Initial-state authentication

Initial-state authentication remains mandatory.

Register file:

```text
forall a in {0..16}: RegVal(a, 0) = init_reg[a]
RegVal(17, 0) = 0
```

RAM:

```text
forall a in {0..4095}: RamVal(a, 0) = init_ram[a]
RamVal(4096, 0) = 0
```

`init_reg` and `init_ram` fix the logical initial `RegVal` / `RamVal` surfaces.
They do not imply that `RegVal` or `RamVal` are separately committed polynomials.
They must be public or otherwise authenticated before any Stage-2 challenge is
sampled.

Normative initialization rule:

- the register subsystem uses the authenticated `init_reg` surface directly as
  the base case for the register `Val`-from-`Inc` identity,
- the RAM subsystem uses the authenticated `init_ram` surface directly as the
  base case for the RAM `Val`-from-`Inc` identity,
- this `simple` spec does **not** reduce non-zero RAM initialization to synthetic
  preload writes.
- equivalently, this spec chooses the modified non-zero-initialization `Val`
  identity permitted by
  [twist-and-shout-requirements.md](/Users/nicolasarqueros/starstream/develop/nightstream-clean-up/docs/soundness-specs/twist-and-shout-requirements.md),
  not the zero-init reduction-by-preload-writes route.

Concretely, the RAM `Val`-from-`Inc` relation is grounded as:

```text
RamVal(a, r_cycle) - init_ram_mle(a)
  = Σ_j RamInc(j) · RamWa(a, j) · LT(j, r_cycle)
```

and analogously for the final-time/sink-specialized forms used by the RAM
subclaims.

---

## 7. Opcode Coverage

Proof obligations by opcode class:

### 7.1 Supported subset note

This kernel version does **not** claim full CHIP-8 `8xy4` semantics.

- `AddImm` is the real carry-free CHIP-8 `7xkk` modulo-256 add.
- The register-register add supported here is `AddRegNoCarry`: it writes only the
  low-byte sum to `V[x]` and does not model the `VF` side effect of real CHIP-8
  `8xy4`.

A conforming extension that claims real `8xy4` must add an explicit authenticated
write path for `VF` or expand the instruction into multiple proved micro-steps.

### 7.2 Rows proved jointly by the kernel and the root main lane

- `LdImm`:
  - Stage 1 fetches opcode, decodes `x`, `kk`, authenticates `Identity(kk)`.
  - Stage 2 authenticates old `V[x]` and the write to `V[x]`.
  - The root main lane proves `REG_X_NEXT = LOOKUP_OUTPUT` and `PC_NEXT = PC + 1`.

- `AddImm`:
  - Stage 1 authenticates `Add8Lo(REG_X, KK)`.
  - Stage 2 authenticates old/new `V[x]`.
  - The root main lane proves routing.

- `Mov`:
  - Stage 1 authenticates `x`, `y`, and `Identity(REG_Y)`.
  - Stage 2 authenticates `V[x]` and `V[y]`.
  - The root main lane proves routing.

- `AddRegNoCarry`:
  - Stage 1 authenticates `x`, `y`, and the low-byte `Add8Lo(REG_X, REG_Y)`.
  - Stage 2 authenticates `V[x]` and `V[y]` plus the write to `V[x]`.
  - The root main lane proves routing.

- `SkipEqImm`:
  - Stage 1 authenticates `x`, `kk`, and `Equal8(REG_X, KK)`.
  - Stage 2 authenticates `V[x]`.
  - The root main lane proves `PC_NEXT = PC + 1 + LOOKUP_OUTPUT`.

- `Jump`:
  - Stage 1 authenticates `NNN_ADDR`, `NNN_WORD`, jump flags, and the alignment
    relation `NNN_ADDR = 2 * NNN_WORD`.
  - The root main lane proves `PC_NEXT = NNN_WORD`.

- `LdI`:
  - Stage 1 authenticates `NNN_ADDR` and `WritesNnnToI`.
  - Stage 2 authenticates the write to slot `I`.
  - The root main lane proves `I_NEXT = NNN_ADDR` and `PC_NEXT = PC + 1`.

- `StoreRegs (Fx55)` burst row:
  - Stage 1 authenticates that the fetched opcode is `Fx55`, that `X_IDX`
    is the current burst index, that `is_store_dec = 1`, that `is_load_dec = 0`,
    and that `BURST_LAST = burst_eq = Eq4(X_IDX, x_bound)`.
  - Stage 2 authenticates `REG_X = V[X_IDX]`, the RAM write at `RAM_ADDR`, and
    the Jolt-style RAM RAF relation tying the committed RAM family to `RAM_ADDR`.
  - The root main lane proves `RAM_ADDR = I_REG + X_IDX`,
    `REG_X_NEXT = REG_X`, and `PC_NEXT = PC + BURST_LAST`.

- `LoadRegs (Fx65)` burst row:
  - Stage 1 authenticates that the fetched opcode is `Fx65`, that `X_IDX`
    is the current burst index, that `is_load_dec = 1`, that `is_store_dec = 0`,
    and that `BURST_LAST = burst_eq = Eq4(X_IDX, x_bound)`.
  - Stage 2 authenticates the RAM read at `RAM_ADDR`, the register write to
    `V[X_IDX]`, and the Jolt-style RAM RAF relation tying the committed RAM
    family to `RAM_ADDR`.
  - The root main lane proves `RAM_ADDR = I_REG + X_IDX`,
    `REG_X_NEXT = MEM_VALUE`, and `PC_NEXT = PC + BURST_LAST`.

### 7.3 Invalid opcodes

The decode table must output `valid = 0` for every unsupported opcode, and the
proof rejects whenever `valid != 1`.

---

## 8. Stage 3: Continuity and Bridge into SuperNeo Main Lane

Stage 3 owns:

- control-lane continuity,
- bridge projection into `PreparedStep`,
- row-binding between exported rows and `C_lane`.

It does **not** own the row-local CCS proof itself; the root main lane remains
the sole owner of that proof after handoff.

### 8.0 Shared Stage-3 cycle point

Stage 3 uses one explicit shared cycle challenge

```text
r_shift ∈ K^{CYCLE_BITS}
```

sampled once from the transcript before the Stage-3 shift reduction and
continuity check are run.

### 8.1 Continuity support relation

Continuity is a named soundness-carrying support relation, not prose.

Stage 3 uses one formalism only:

- current-row openings from `C_lane` at `r_shift`,
- authenticated shifted virtual values from `LaneShiftProof`,
- one random-point continuity identity evaluated at `r_shift` and masked by the
  public real-pair mask `PairMask_N`.

Define the verifier-computable real-pair mask:

```text
PairMask_N(j) = 1 for 0 <= j < N-1
PairMask_N(j) = 0 otherwise
```

and let `PairMask_N(X)` be its multilinear extension over the cycle hypercube.

### 8.1a LaneShift reduction

Stage 3 does not assume ad hoc access to `PC(j+1)`, `X_IDX(j+1)`, or
`IsMemOp(j+1)`. Instead it uses an explicit checked virtual reduction over
`C_lane`.

For each needed lane column `f ∈ {PC, X_IDX, IsMemOp}`, define the virtual shifted
column as the multilinear extension of the shifted-by-one vector
`[f(1), f(2), ..., f(T-1), 0]`:

```text
Shift[f](X) = Σ_{j=0}^{T-2} eq(X, j) · f(j+1)
```

At `X = r_shift`, Stage 3 produces a `LaneShiftProof` with:

```text
LaneShiftProof {
    point: r_shift,
    columns: [PC, X_IDX, IsMemOp],
    claimed_shift_values: [shift_pc, shift_x_idx, shift_is_memop],
    reduction_proof
}
```

Verifier obligations:

1. open the unshifted Stage-3 source columns from `C_lane` at `r_shift`,
2. verify `reduction_proof`, which soundly binds
   - `shift_pc = Shift[PC](r_shift)`,
   - `shift_x_idx = Shift[X_IDX](r_shift)`,
   - `shift_is_memop = Shift[IsMemOp](r_shift)`,
   to those committed lane columns,
3. use `shift_pc`, `shift_x_idx`, and `shift_is_memop` as the authenticated
   meanings of `PC(j+1)`, `X_IDX(j+1)`, and `IsMemOp(j+1)` in the continuity
   identity above.

There is no separate `C_shift` commitment. `LaneShiftProof` is a soundness-
carrying virtual reduction against `C_lane`, with its own transcript material,
claim shape, and accounting term.

Normative Stage-3 shift claim:

```text
LaneShiftClaim {
    source_commitment: C_lane,
    source_point: r_shift,
    source_columns: [PC, X_IDX, IsMemOp],
    shifted_columns: [Shift[PC], Shift[X_IDX], Shift[IsMemOp]],
    claimed_shift_values: [shift_pc, shift_x_idx, shift_is_memop],
}
```

`reduction_proof` is the concrete proof object that authenticates
`LaneShiftClaim`. It is not an `OpeningClaim`, and it does not introduce a new
commitment family; it is a checked virtual reduction whose only committed source
is `C_lane`.

Normative reduction contract:

- `LaneShiftReductionProof` proves the single batched virtual identity

```text
shift_batch
  = shift_pc
  + β_shift · shift_x_idx
  + β_shift^2 · shift_is_memop

shift_batch
  = Shift[PC](r_shift)
  + β_shift · Shift[X_IDX](r_shift)
  + β_shift^2 · Shift[IsMemOp](r_shift)
```

  for a transcript challenge `β_shift` derived inside the Stage-3 shift
  subprotocol,
- verification of `reduction_proof` must deterministically authenticate the
  three claimed shifted values from that single batched identity against the
  committed `C_lane` source columns,
- `β_shift` and the internal reduction transcript belong to
  `LaneShiftReductionProof`; they are not additional kernel opening claims.

### 8.1b ContinuityCheck

After `LaneShiftProof` authenticates

- `shift_pc = PC_plus(r_shift)`,
- `shift_x_idx = X_IDX_plus(r_shift)`,
- `shift_is_memop = IsMemOp_plus(r_shift)`,

Stage 3 opens the current-row columns

- `PC_NEXT`,
- `X_IDX`,
- `IsMemOp`,
- `BURST_LAST`

from `C_lane @ r_shift` and checks the batched continuity identity:

```text
δ_pc         = PairMask_N(r_shift) * (shift_pc - PC_NEXT)
δ_burst_step = PairMask_N(r_shift) * IsMemOp * (1 - BURST_LAST) * (shift_x_idx - X_IDX - 1)
δ_burst_reset= PairMask_N(r_shift) * shift_is_memop * (1 - IsMemOp + BURST_LAST) * shift_x_idx

δ_pc + β1 * δ_burst_step + β2 * δ_burst_reset = 0
```

Start-boundary rule:

- let `j0_bits = 0^{CYCLE_BITS}`,
- Stage 3 opens `IsMemOp` and `X_IDX` from `C_lane @ j0_bits`,
- and checks `IsMemOp(0) * X_IDX(0) = 0`.

Final-boundary rule:

- let `j_last_bits = bits_le(N - 1)` in the same little-endian cycle-bit order
  used by `C_lane`,
- Stage 3 opens `IsMemOp` and `BURST_LAST` from `C_lane @ j_last_bits`,
- and checks `IsMemOp(N-1) * (1 - BURST_LAST(N-1)) = 0`.

If a future chunked kernel permits carry-in or carry-out burst state, this rule
must be replaced by explicit chunk-boundary fields. This `simple` spec does not
permit chunks to start or end mid-burst.

Boundary interpretation:

- `PC(0)` is carried by the first semantic row and is not constrained by the
  continuity relation itself,
- the first active row must satisfy `PC(0) = initial_state.pc_word`, where
  `initial_state.pc_word` is part of the public initial machine state,
- for the standard CHIP-8 loader model, `initial_state.pc_word = program_base_addr / 2`,
- the last active row `j = N-1` is intentionally excluded from the continuity
  predecessor mask,
- the last active row must still satisfy the explicit final-boundary rule above,
- padded rows satisfy the public pad-row rule from §3.2 and do not induce extra
  semantic continuity obligations.

```text
ContinuityProof {
    point: r_shift,
    beta1,
    beta2,
    pair_mask_eval,
    current_row_opening_ref,
    shift_proof_ref,
    start_boundary_opening_ref,
    final_boundary_opening_ref,
}
```

Normative implementation hook:

- `ContinuityProof` consumes the `C_lane @ r_shift` current-row opening,
  `LaneShiftProof`, the `C_lane @ j0_bits` boundary opening, and the
  `C_lane @ j_last_bits` boundary opening,
- verification recomputes `δ_pc`, `δ_burst_step`, `δ_burst_reset`, and the two
  explicit boundary checks from those authenticated inputs,
- `pair_mask_eval = PairMask_N(r_shift)` is verifier-recomputable from public
  `N` and `T`; it is included only to pin the proof object shape.

### 8.2 What is projected

`PreparedStep_j` is built from row `j` of `M_lane` and contains exactly the data
needed for the root row-local CCS checks from §4.1.

Normative export rule:

- only semantic rows `j ∈ [0, N)` are exported through the bridge as
  `PreparedStep_j` / `PreparedStepInstance_j`,
- padded rows `j ∈ [N, T)` remain internal to kernel commitments and are never
  turned into root-lane steps.

### 8.3 What is not projected

The following are deferred auxiliary obligations:

- fetch correctness,
- decode correctness,
- ALU/branch lookup correctness,
- register-history correctness,
- RAM-history correctness,
- RAM RAF support checks,
- continuity support checks.

The bridge creates no new proof object for the deterministic **row extraction**
part, but this does **not** remove any of the separate Stage-1, Stage-2, or
Stage-3 soundness obligations.

### 8.4 Binding between kernel rows and root commitments

The aggregate identity `C_lane = Σ_j c_j` is **not** the binding mechanism.

For `simple.rs` v1, the normative bridge mechanism is:

- explicit row-opening / row-membership proofs from `C_lane`,
- followed by `RootEncode(z_j)`,
- followed by recomputation of the root Ajtai commitment
  `PreparedStep_j.mcs.c = Ajtai_commit(Z_j)`.

Formal linear row decomposition is a possible optimization, but it is not a
conforming alternative under this spec.

---

## 9. Opening Boundary

Opening claims are not uniformly against a single Phase-0 commitment. This
document defines only the kernel/root claim manifests. PCS batching and final
opening verification are external to this document and are owned by
`time_opening`.

### 9.1 OpeningClaim

```text
OpeningClaim {
    source,
    commitment_id,   // Lane | FetchRa | DecodeRa | AluRa | Eq4Ra | DecodeHandoff | RegTwist | RamTwist | RomTable | DecodeTable | AluTable | Eq4Table | RootProver(...)
    point,
    polynomial_ids,
    claimed_values,
    digest,
}
```

### 9.2 Grouping rule

Claims are grouped by `(commitment_id, point)`.

The opening boundary is split into two disjoint ownership buckets:

- `KernelOpeningManifest`: claims emitted by this 3-stage kernel before handoff.
- `RootOpeningManifest`: claims emitted later by the root prover.

`time_opening` verifies the union of both manifests, but the source/ownership tag
must remain explicit for every claim.

At minimum, `KernelOpeningManifest` contains:

- `C_lane @ r_lookup` opening exactly the lane columns
  `{PC, KK, NNN_ADDR, NNN_WORD, REG_X, REG_Y, LOOKUP_OUTPUT,
    WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
    IsJump, IsBranch, IsMemOp, X_IDX, Y_IDX, BURST_LAST}`,
- `C_fetch_ra @ (r_fetch_addr, r_lookup)` for the Stage-1 fetch address family,
- `C_decode_ra @ (r_decode_addr, r_lookup)` for the Stage-1 decode address family,
- `C_alu_ra @ (r_alu_addr, r_lookup)` for the Stage-1 ALU/branch address family,
- `C_eq4_ra @ (r_eq4_addr, r_lookup)` for the Stage-1 burst-equality address family,
- `C_decode_handoff @ r_lookup` for the Stage-1 decode-handoff columns,
- `C_rom_table @ r_fetch_addr` for the ROM table,
- `C_decode_table @ r_decode_addr` for the full-opcode decode table,
- `C_alu_table @ r_add8lo_addr` for the `Add8Lo` subtable,
- `C_eq4_table @ r_eq4_addr` for the `Eq4` table,
- `C_lane @ r_twist_cycle` opening exactly the lane columns
  `{REG_X, REG_Y, REG_X_NEXT, I_REG, I_NEXT, MEM_VALUE,
    WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
    IsMemOp, X_IDX, Y_IDX, RAM_ADDR}`,
- `C_decode_handoff @ r_twist_cycle` for the Stage-2 decode-handoff columns,
- `C_reg  @ (r_addr_reg, r_twist_cycle)` opening exactly
  `{RegInc, RegRaX, RegRaY, RegRaI, RegWa}` for register Twist,
- `C_ram  @ (r_addr_ram, r_twist_cycle)` opening exactly
  `{RamInc, RamRa, RamWa}` for RAM Twist and RAM RAF support,
- `C_lane @ r_shift` opening exactly the lane columns
  `{PC, PC_NEXT, X_IDX, IsMemOp, BURST_LAST}` for `LaneShiftProof` and
  `ContinuityCheck`,
- `C_lane @ j0_bits` opening `{IsMemOp, X_IDX}` for the Stage-3 start-boundary
  check,
- `C_lane @ j_last_bits` opening `{IsMemOp, BURST_LAST}` for the Stage-3
  final-boundary check,
- `C_lane @ j_bits` row-binding openings of the 23 non-fixed lane columns for
  every exported semantic row `j ∈ [0, N)`, in the canonical `C_lane` registry
  order.

`RegVal` and `RamVal` are virtual and never appear as primary `OpeningClaim`s`.

`RootOpeningManifest` contains only the openings owned by the root prover
(`Π_CCS -> Π_RLC -> Π_DEC`) after kernel handoff.

Kernel commitments and root commitments are intentionally disjoint:

- `KernelOpeningManifest` may only reference `C_*` commitments fixed in `root0`.
- `RootOpeningManifest` may only reference commitments created after bridge
  extraction, including the per-step root Ajtai commitments.

Later kernel stages do **not** consume Stage-1 lookup openings; each stage opens
its own claims independently.

### 9.3 Canonical manifest ordering and encoding

To keep `time_opening` and kernel verification deterministic, every
`KernelOpeningManifest` must use one canonical ordering.

Canonical `commitment_id` order:

```text
Lane
FetchRa
DecodeRa
AluRa
Eq4Ra
DecodeHandoff
RegTwist
RamTwist
RomTable
DecodeTable
AluTable
Eq4Table
RootProver(...)
```

Canonical manifest sort key:

```text
(commitment_id_order, point_arity, point_coordinates, polynomial_ids)
```

Normative rules:

- `polynomial_ids` must be strictly increasing in the local registry order of the
  referenced commitment family.
- `point_arity` is the number of coordinates in the evaluation point.
- `point_coordinates` are ordered exactly as the commitment family defines them in
  §13. For bivariate families this means address coordinates first, then cycle
  coordinates.
- Every point coordinate in `K` is serialized canonically as its two Goldilocks
  coefficients `(c0, c1)` in that order, each using the implementation's
  canonical field-element byte encoding.
- The manifest must not contain duplicate `(commitment_id, point, polynomial_ids)`
  entries.

`LaneShiftProof` is not an `OpeningClaim` and must not appear in either opening
manifest.

### 9.4 Rust-facing kernel boundary

The algebra above maps to the following Rust-facing boundary for `simple.rs`.

```text
SimpleKernelPublicInput {
    vm_spec,
    public_program_image,
    initial_state,
    transcript_seed,
}
```

```text
SimpleKernelWitness {
    semantic_trace_rows,
    semantic_aux_data,
}
```

```text
SimpleKernelProverInput {
    public: SimpleKernelPublicInput,
    witness: SimpleKernelWitness,
}
```

```text
SimpleKernelVerifierInput {
    public: SimpleKernelPublicInput,
}
```

Normative input rules:

- `semantic_trace_rows` contains exactly the `N` semantic rows of the chunk.
- `semantic_aux_data` contains exactly one auxiliary witness record per
  semantic row, in the same order.
- `semantic_trace_rows` must begin on an instruction boundary with no in-flight
  `Fx55/Fx65` burst state.
- `N >= 1`; this `simple` spec does not define an empty semantic chunk.
- `semantic_aux_data.len() = semantic_trace_rows.len() = N`.
- `initial_state` must include the public CHIP-8 start state needed by the
  kernel, including at least `pc_word`, the initialized register surface, and
  the initialized RAM image.
- the first semantic row of the chunk must agree with `initial_state`;
  in particular `PC(0) = initial_state.pc_word`.
- the kernel, not the caller, computes `T = 2^{ceil_log2(N)}` and appends the
  public pad suffix from §3.2 for all rows `j ∈ [N, T)`.
- all Stage 1 / Stage 2 / Stage 3 commitments and opening claims are taken over
  that padded `T`-row lane, while Stage 3 semantic boundary rules still use the
  explicit active prefix length `N`.
- the full `public_program_image` and `initial_state` may be used by the
  verifier to recompute or cross-check the committed ROM/init surfaces, but they
  do not make `C_rom_table`, `C_decode_table`, `C_alu_table`, or `C_eq4_table`
  optional in this spec.
- the root main-lane `CcsStructure` is canonical from §11.3 and is not
  caller-chosen.
- `vm_spec` canonically fixes the root witness-encoding parameters `root_params`
  used by `RootEncode`; no hidden caller-chosen `root_params` are permitted.

```text
Stage1ChannelProof {
    addr_point,
    core_proof,
    addr_correctness_proof,
    table_opening_claims,
}
```

```text
Stage1ShoutProof {
    cycle_point: r_lookup,
    fetch: Stage1ChannelProof,
    decode: Stage1ChannelProof,
    alu: Stage1ChannelProof,
    eq4: Stage1ChannelProof,
    gamma_lookup_link,
    lookup_linkage_proof,
    decode_handoff_openings,
}
```

```text
Stage2TwistProof {
    cycle_point: r_twist_cycle,
    reg_addr_point: r_addr_reg,
    ram_addr_point: r_addr_ram,
    gamma_reg,
    reg_rw_batched_proof,
    reg_val_from_inc_proof,
    reg_addr_correctness_proofs: {
        RegRaX,
        RegRaY,
        RegRaI,
        RegWa,
    },
    gamma_ram,
    ram_rw_batched_proof,
    ram_val_from_inc_proof,
    ram_raf_read_proof,
    ram_raf_write_proof,
    ram_addr_correctness_proofs: {
        RamRa,
        RamWa,
    },
    gamma_twist_link,
    twist_linkage_proof,
}
```

```text
LaneShiftProof {
    source_commitment: C_lane,
    source_point: r_shift,
    source_columns: [PC, X_IDX, IsMemOp],
    claimed_shift_values: [shift_pc, shift_x_idx, shift_is_memop],
    reduction_proof,
}
```

```text
LaneShiftReductionProof {
    source_opening_ref,
    internal_challenges,
    proof_bytes,
}
```

Normative implementation hook:

- `LaneShiftProof.reduction_proof` is a concrete `LaneShiftReductionProof`,
- it consumes only the `C_lane @ r_shift` source opening plus its own
  transcript-derived internal challenges,
- and verification must deterministically return the authenticated shifted
  values `(shift_pc, shift_x_idx, shift_is_memop)` from that object.

```text
ContinuityProof {
    point: r_shift,
    beta1,
    beta2,
    pair_mask_eval,
    current_row_opening_ref,
    shift_proof_ref,
    start_boundary_opening_ref,
    final_boundary_opening_ref,
}
```

```text
Stage3Proof {
    shift_proof: LaneShiftProof,
    continuity_proof: ContinuityProof,
    row_bindings: Vec<RowBindingClaim>,
}
```

```text
SimpleKernelProof {
    commitments: {
        C_lane,
        C_fetch_ra,
        C_decode_ra,
        C_alu_ra,
        C_eq4_ra,
        C_decode_handoff,
        C_reg,
        C_ram,
        C_rom_table,
        C_decode_table,
        C_alu_table,
        C_eq4_table,
    },
    meta_pub,
    stage1: Stage1ShoutProof,
    stage2: Stage2TwistProof,
    stage3: Stage3Proof,
    kernel_opening_manifest: KernelOpeningManifest,
}
```

```text
KernelMetaPub {
    program_image_digest,
    initial_state_digest,
    program_word_count,
    semantic_rows: N,
    padded_trace_length: T,
    pad_pc_word,
    program_base_addr,
    cycle_bits,
}
```

```text
RowBindingClaim {
    row_index,
    row_point_bits,
    opened_lane_values,
    opening_claim_ref,
    prepared_step_commitment,
}
```

```text
SimpleKernelOutput {
    prepared_steps: Vec<PreparedStep>,
    public_steps: Vec<PreparedStepInstance>,
    extension_proofs: SessionExtensionProofs,
    kernel_opening_manifest: KernelOpeningManifest,
}
```

Normative rule:

- `SimpleKernelProof` does not contain a duplicate root main-lane CCS proof.
- `KernelMetaPub.semantic_rows = N` and
  `KernelMetaPub.padded_trace_length = T = 2^{cycle_bits}`.
- `SimpleKernelOutput.prepared_steps` is the only bridge payload consumed by the
  root prover.
- `prepared_steps.len() = public_steps.len() = N`; these vectors contain exactly
  the semantic rows `j ∈ [0, N)` and never include padded rows.
- `extension_proofs` is empty for `simple.rs` v1; the sidecar obligations are
  discharged inside kernel Stage 1 / Stage 2 / Stage 3 before handoff rather
  than exported as deferred per-step extensions.
- `kernel_opening_manifest` contains only kernel-owned openings against the
  commitments fixed in `root0`.

The intended Rust entrypoints are:

```text
prove_simple_kernel(
    input: &SimpleKernelProverInput,
    transcript: &mut Poseidon2Transcript,
) -> Result<(SimpleKernelOutput, SimpleKernelProof), SimpleKernelError>
```

```text
verify_simple_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
    transcript: &mut Poseidon2Transcript,
) -> Result<SimpleKernelOutput, SimpleKernelError>
```

`verify_simple_kernel` must reconstruct the same `SimpleKernelOutput` that
`prove_simple_kernel` emitted before handing `prepared_steps` and
`kernel_opening_manifest` to the root prover.

---

## 10. Soundness Accounting

This kernel uses **parameterized** soundness accounting.

Let `ε_addr(d=1)` be the applicable Figure-6 / Figure-8 address-correctness term,
`ε_shout_core(d=1)` the applicable Shout core term, and `ε_twist_read`,
`ε_twist_write`, `ε_twist_val` the applicable Twist subclaim terms for the
instantiated port family. Let `ε_ram_raf_read` and `ε_ram_raf_write` be the
soundness terms for the two Jolt-style RAM RAF support identities from §6.5.
Let `ε_reg_rw_batch`, `ε_ram_rw_batch`, `ε_lookup_link`, and `ε_twist_link` be
the explicit random-linear-combination batching terms for:

- the Stage-2 register read/write batch,
- the Stage-2 RAM read/write batch,
- the Stage-1 linkage batch from §5.5a,
- and the Stage-2 linkage batch from §6.2a.

Then:

```text
ε_total <= ε_stage1
         + ε_stage2
         + ε_stage3
         + ε_batch
         + ε_PCS
         + ε_FS
         + ε_outer
```

with

```text
ε_stage1 = sum over Stage-1 Shout channels c of
             (ε_shout_core(c) + ε_addr(c))

ε_stage2 =
    sum over register read ports p in {X, Y, I} of ε_twist_read(p)
  + ε_twist_write(reg)
  + ε_twist_val(reg)
  + sum over register address families f in {RegRaX, RegRaY, RegRaI, RegWa} ε_addr(f)
  + ε_twist_read(ram)
  + ε_twist_write(ram)
  + ε_twist_val(ram)
  + ε_ram_raf_read
  + ε_ram_raf_write
  + ε_addr(RamRa)
  + ε_addr(RamWa)

ε_stage3 =
    ε_shift_reduce
  + ε_continuity

ε_batch =
    ε_reg_rw_batch
  + ε_ram_rw_batch
  + ε_lookup_link
  + ε_twist_link
```

If the implementation batches any subset of these channels/ports, it may add the
paper's random-linear-combination batching term, but it may not silently delete
a theorem surface from the accounting.

A simplified formula like `ε_stage2 = Theorem4 + 2 * address-correctness` is
insufficient because the design uses more than one logical read family.

---

## 11. Main-Lane CCS Embedding

The root main-lane row-local equations from §4.1 must map to a concrete
`CcsStructure<F>` so that two implementations produce the same main-lane
instance.

### 11.1 Witness vector layout

The witness vector `z` for each row `j` of `M_lane` is the 24-coordinate semantic row
itself, with column 0 (`ONE = 1`) as the single public input:

```text
z[0]  = ONE = 1                  (public, m_in = 1)
z[1]  = PC
z[2]  = PC_NEXT
z[3]  = REG_X
z[4]  = REG_Y
z[5]  = REG_X_NEXT
z[6]  = I_REG
z[7]  = I_NEXT
z[8]  = KK
z[9]  = NNN_ADDR
z[10] = NNN_WORD
z[11] = MEM_VALUE
z[12] = LOOKUP_OUTPUT
z[13] = WritesLookupToX
z[14] = WritesMemToX
z[15] = PreservesX
z[16] = WritesNnnToI
z[17] = IsJump
z[18] = IsBranch
z[19] = IsMemOp
z[20] = X_IDX
z[21] = Y_IDX
z[22] = BURST_LAST
z[23] = RAM_ADDR
```

Width `W = 24`. Public inputs: `x = [z[0]]`. Private witness: `w` is
coordinates 1 through 23 inclusive of `z`.

In the kernel boundary, `z[0] = ONE` is reconstructed as the fixed verifier-known
constant `1`; it is not opened from `C_lane`.

### 11.2 PreparedStep construction

```text
let RootEncode(z_j) = (w_j, Z_j)

PreparedStep_j = {
    label: debug_only_label,
    mcs: CcsClaim {
        c: Ajtai_commit(Z_j),
        x: [F::ONE],
        m_in: 1,
    },
    witness: CcsWitness {
        w: w_j,
        Z: Z_j,
    },
    deferred_extensions: [],
}
```

Normative rule for `RootEncode`:

- `z_j` is the raw 24-field semantic row used by the root main-lane row-local CCS.
- `w_j` is coordinates 1 through 23 inclusive of `z_j`.
- `Z_j` is the canonical norm-bounded witness representation consumed by the root
  prover for that row.
- For the Rust root-spine targeted by this spec, that canonical representation is
  the existing packed witness encoding implemented at
  `neo_memory::ajtai::encode_vector_for_ccs_m` in
  [ajtai.rs](/Users/nicolasarqueros/starstream/develop/nightstream-clean-up/crates/neo-memory/src/ajtai.rs):
  `Z_j = neo_memory::ajtai::encode_vector_for_ccs_m(root_params, 24, z_j)`.
- Equivalently, `Z_j ∈ F^{D × ceil(24 / D)}` with layout determined only by that
  canonical encoding function and the public `root_params`.
- Balanced base-`b` digit decomposition is a later NC/range-check view of the
  packed witness. It is **not** part of `RootEncode`.
- `Z_j` is therefore **not** an ad hoc bridge-local row-major packing choice. The
  bridge and verifier must use exactly the same canonical `RootEncode` function
  and the same `root_params` instance as the root prover. Hand-rolled alternative
  packings are non-conforming.
- In this spec, `root_params` are canonically fixed by `vm_spec` together with
  the root protocol version bound into public metadata. The verifier reconstructs
  them from that public boundary; they are not hidden prover-side parameters.
- `debug_only_label` is not part of the proof statement and is ignored by the
  verifier. Conforming implementations may omit it or derive any deterministic
  debug string from verifier-available data.
- `deferred_extensions` is empty in this `simple` kernel because Stage 1, Stage 2,
  and Stage 3 discharge those auxiliary surfaces before root handoff; there is
  no remaining per-step sidecar obligation exported to the root prover.

### 11.3 R1CS → CCS conversion

The 19 R1CS rows from §4.1 are converted via `r1cs_to_ccs(A, B, C)` where
`A`, `B`, `C` are `19 × 24` sparse matrices encoding the following canonical row
triples in the column order above:

```text
Row 0:  L = WritesLookupToX,                   R = WritesLookupToX - ONE,                  O = 0
Row 1:  L = WritesMemToX,                      R = WritesMemToX - ONE,                     O = 0
Row 2:  L = PreservesX,                        R = PreservesX - ONE,                       O = 0
Row 3:  L = WritesNnnToI,                      R = WritesNnnToI - ONE,                     O = 0
Row 4:  L = IsJump,                            R = IsJump - ONE,                           O = 0
Row 5:  L = IsBranch,                          R = IsBranch - ONE,                         O = 0
Row 6:  L = IsMemOp,                           R = IsMemOp - ONE,                          O = 0
Row 7:  L = BURST_LAST,                        R = BURST_LAST - ONE,                       O = 0
Row 8:  L = WritesLookupToX + WritesMemToX + PreservesX - ONE,
        R = ONE,                               O = 0
Row 9:  L = WritesLookupToX,                   R = REG_X_NEXT - LOOKUP_OUTPUT,             O = 0
Row 10: L = WritesMemToX,                      R = REG_X_NEXT - MEM_VALUE,                 O = 0
Row 11: L = PreservesX,                        R = REG_X_NEXT - REG_X,                     O = 0
Row 12: L = WritesNnnToI,                      R = NNN_ADDR - I_REG,                       O = I_NEXT - I_REG
Row 13: L = IsJump,                            R = PC_NEXT - NNN_WORD,                     O = 0
Row 14: L = IsBranch,                          R = PC_NEXT - PC - ONE - LOOKUP_OUTPUT,     O = 0
Row 15: L = IsMemOp,                           R = PC_NEXT - PC - BURST_LAST,              O = 0
Row 16: L = ONE - IsJump - IsBranch - IsMemOp,
        R = PC_NEXT - PC - ONE,                O = 0
Row 17: L = IsMemOp,                           R = RAM_ADDR - I_REG - X_IDX,               O = 0
Row 18: L = ONE - IsMemOp,                     R = RAM_ADDR,                               O = 0
```

The resulting `CcsStructure<F>` is shared across all steps (same structure for
every row). An implementation may materialize the structure directly as sparse
`A/B/C` matrices or derive it mechanically from the canonical row triples above,
but the induced matrices must be identical.

---

## 12. Transcript Schedule

The exact Fiat-Shamir ordering for the 3-stage kernel:

```text
1. transcript = Poseidon2Transcript::new(b"chip8-kernel")
2. absorb(
       C_lane,
       C_fetch_ra,
       C_decode_ra,
       C_alu_ra,
       C_eq4_ra,
       C_decode_handoff,
       C_reg,
       C_ram,
       C_rom_table,
       C_decode_table,
       C_alu_table,
       C_eq4_table,
       meta_pub
   )
   --> root0 fixed. All later challenges sampled from here.

3. Stage 1 (Shout):
   - sample the shared Stage-1 cycle point `r_lookup ∈ K^{CYCLE_BITS}`
   - fetch sumcheck rounds → transcript
   - decode sumcheck rounds → transcript
   - ALU/branch sumcheck rounds → transcript
   - Eq4 sumcheck rounds → transcript
   - address-correctness subchecks in canonical order
     `fetch -> decode -> alu -> eq4` → transcript
   - record terminal point `r_fetch_addr ∈ K^{ROM_ADDR_BITS} = K^{11}`
     returned by the Stage-1 fetch subprotocol
   - record terminal point `r_decode_addr ∈ K^{16}`
     returned by the Stage-1 decode subprotocol
   - record terminal point `r_alu_addr ∈ K^{18}`
     returned by the Stage-1 ALU subprotocol
     // (lookup_kind, lhs, rhs) = (2, 8, 8) bits
   - define `r_add8lo_addr = (r_alu_addr[2], ..., r_alu_addr[17]) ∈ K^{16}`
   - record terminal point `r_eq4_addr ∈ K^{8}`
     returned by the Stage-1 Eq4 subprotocol
     // (x_idx, x_bound) = (4, 4) bits
   - sample γ_lookup_link for the Stage-1 linkage batch
   - Stage-1 linkage batch at r_lookup → transcript

4. Stage 2 (Twist):
   - sample the shared Stage-2 cycle point `r_twist_cycle ∈ K^{CYCLE_BITS}`
   - sample γ_reg for register read/write batching
   - reg read/write batched sumcheck → transcript
   - reg Val-from-Inc sumcheck → transcript
   - sample γ_ram for RAM read/write batching
   - ram read/write batched sumcheck → transcript
   - ram Val-from-Inc sumcheck → transcript
   - ram RAF read support sumcheck → transcript
   - ram RAF write support sumcheck → transcript
   - address-correctness subchecks in canonical order
     `RegRaX -> RegRaY -> RegRaI -> RegWa -> RamRa -> RamWa` → transcript
   - record terminal point `r_addr_reg ∈ K^{ADDR_REG_BITS} = K^{5}`
     returned by the Stage-2 register subprotocol
   - record terminal point `r_addr_ram ∈ K^{ADDR_RAM_BITS} = K^{13}`
     returned by the Stage-2 RAM subprotocol
   - sample γ_twist_link for the Stage-2 linkage batch
   - Stage-2 linkage batch at r_twist_cycle → transcript

5. Stage 3 (continuity + bridge):
   - sample β1, β2 for continuity batching
   - sample the shared Stage-3 cycle point `r_shift ∈ K^{CYCLE_BITS}`
   - lane-shift reduction proof over C_lane at r_shift → transcript
   - continuity check at r_shift over current-row openings + shifted values → transcript
   - open C_lane at j0_bits for the start-boundary check → transcript
   - open C_lane at j_last_bits for the final-boundary check → transcript
   - row-binding openings / row-membership proofs for each exported semantic row
     `j ∈ [0, N)` → transcript

6. Emit kernel opening claims.
   Hand off PreparedSteps + opening claims to root prover.
```

Each "sample" is a `transcript.challenge_field()` call. Each "absorb" is a
`transcript.append_*()` call. The order is strict and sequential.

Normative point-generation rule:

- `r_lookup`, `r_twist_cycle`, and `r_shift` are explicit shared stage-cycle
  challenges drawn exactly once from the transcript,
- `r_fetch_addr`, `r_decode_addr`, `r_alu_addr`, `r_eq4_addr`, `r_addr_reg`,
  and `r_addr_ram` are the transcript-derived terminal points of their
  respective proof subprotocols and are recorded, not re-sampled,
- `r_add8lo_addr` is a deterministic projection of `r_alu_addr`, not an
  independent Fiat-Shamir challenge.

---

## 13. Committed Polynomial Coordinates

### 13.1 C_lane

- Domain: `CYCLE_BITS` variables (cycle index, little-endian bit ordering)
- Width: 23 committed non-fixed column polynomials, each of length `T`
  (padded to next power of 2)
- Padding: `C_lane` stores the 23 non-fixed coordinates of the public pad-row rule;
  the fixed coordinate `ONE = 1` is not committed under `C_lane`
- Polynomial IDs, in canonical registry order:
  `PC`, `PC_NEXT`, `REG_X`, `REG_Y`, `REG_X_NEXT`, `I_REG`, `I_NEXT`, `KK`,
  `NNN_ADDR`, `NNN_WORD`, `MEM_VALUE`, `LOOKUP_OUTPUT`, `WritesLookupToX`,
  `WritesMemToX`, `PreservesX`, `WritesNnnToI`, `IsJump`, `IsBranch`,
  `IsMemOp`, `X_IDX`, `Y_IDX`, `BURST_LAST`, `RAM_ADDR`
- Opened at: `r_lookup`, `r_twist_cycle`, `r_shift`, `j0_bits`, and row indices
  `j_last_bits`, and row indices `j_bits`

### 13.2 C_reg

- Domain: `ADDR_REG_BITS + CYCLE_BITS = 5 + CYCLE_BITS` variables (address × cycle)
- Variable order: address bits first (big-endian), then cycle bits (little-endian)
- Address space:
  - active slots `0..17` = `V[0..15], I, ⊥_reg`
  - padded slots `18..31`, permanently inert
- Polynomials:
  - `RegInc(j)`: 1 polynomial over cycle only, embedded over the full address
    hypercube as
    `RegInc_embed(a, j) = RegInc(j)` for every 5-bit address `a`
  - `RegRaX(a, j)`, `RegRaY(a, j)`, `RegRaI(a, j)`: 3 one-hot address families
  - `RegWa(a, j)`: 1 one-hot address family
  - logical virtual `RegVal(a, j)`, opened only through the explicit Val-from-Inc
    reduction and not as a primary committed polynomial
- Polynomial IDs:
  - `0 = RegInc`
  - `1 = RegRaX`
  - `2 = RegRaY`
  - `3 = RegRaI`
  - `4 = RegWa`
- Padding:
  - sink slot ⊥_reg (addr 17) has `Val = 0`, all ra/wa = 0
    except when explicitly routed by sink semantics
  - padded slots `18..31` have `Val = 0`, all ra/wa = 0`
- Opened at: `(r_addr_reg, r_twist_cycle)`

### 13.3 C_fetch_ra

- Domain: `ROM_ADDR_BITS + CYCLE_BITS = 11 + CYCLE_BITS` variables (absolute ROM address × cycle)
- Variable order: address bits first (big-endian), then cycle bits (little-endian)
- Polynomial:
  - `ra_fetch(addr, j)`: one-hot read-address family for the ROM fetch channel
- Padding:
  - the ROM table is the full absolute 2048-word CHIP-8 address space,
  - the loaded program occupies its public absolute interval,
  - `pad_pc_word` stores the self-loop pad opcode,
  - all other unused addresses are zero
- Opened at: `(r_fetch_addr, r_lookup)`

### 13.4 C_decode_handoff

- Domain: `CYCLE_BITS` variables (cycle index, little-endian bit ordering)
- Width: 3 column polynomials:
  - `handoff_uses_y`
  - `handoff_reads_ram`
  - `handoff_writes_ram`
- Polynomial IDs:
  - `0 = handoff_uses_y`
  - `1 = handoff_reads_ram`
  - `2 = handoff_writes_ram`
- Padding: all three columns are zero on padded rows
- Opened at: `r_lookup`, `r_twist_cycle`

### 13.5 C_decode_ra

- Domain: `16 + CYCLE_BITS` variables (opcode word × cycle)
- Variable order: opcode bits first (big-endian), then cycle bits (little-endian)
- Polynomial:
  - `ra_decode(opcode, j)`: one-hot read-address family for the decode channel
- Opened at: `(r_decode_addr, r_lookup)`

### 13.6 C_alu_ra

- Domain: `18 + CYCLE_BITS` variables (`lookup_kind || lhs || rhs` × cycle)
- Variable order: 2-bit `lookup_kind` tag first, then 8-bit `lhs`, then 8-bit
  `rhs`, then cycle bits (little-endian)
- Bit order within each tagged address subfield is big-endian:
  - `lookup_kind = (k1, k0)`,
  - `lhs = (lhs_7, ..., lhs_0)`,
  - `rhs = (rhs_7, ..., rhs_0)`.
- `lookup_kind` encoding:
  - `00 = NoLookup`
  - `01 = Identity`
  - `10 = Equal8`
  - `11 = Add8Lo`
- Polynomial:
  - `ra_alu(key, j)`: one-hot read-address family for the ALU/branch channel
- Opened at: `(r_alu_addr, r_lookup)`

### 13.7 C_eq4_ra

- Domain: `8 + CYCLE_BITS` variables (`x_idx || x_bound` × cycle)
- Variable order: 4-bit `x_idx` first, then 4-bit `x_bound`, then cycle bits
  (little-endian)
- Bit order within each 4-bit subfield is big-endian:
  - `x_idx = (x3, x2, x1, x0)`,
  - `x_bound = (b3, b2, b1, b0)`.
- Polynomial:
  - `ra_eq4(key, j)`: one-hot read-address family for the burst-equality channel
- Opened at: `(r_eq4_addr, r_lookup)`

### 13.8 C_ram

- Domain: `ADDR_RAM_BITS + CYCLE_BITS = 13 + CYCLE_BITS` variables (address × cycle)
- Variable order: address bits first (big-endian), then cycle bits (little-endian)
- Address space:
  - active slots `0..4096` = `RAM[0..4095], ⊥_ram`
  - padded slots `4097..8191`, permanently inert
- Polynomials:
  - `RamInc(j)`: 1 polynomial over cycle, embedded over the full address
    hypercube as
    `RamInc_embed(a, j) = RamInc(j)` for every 13-bit address `a`
  - `RamRa(a, j)`, `RamWa(a, j)`: 2 one-hot address families
  - logical virtual `RamVal(a, j)`, opened only through the explicit Val-from-Inc
    reduction and not as a primary committed polynomial
- Polynomial IDs:
  - `0 = RamInc`
  - `1 = RamRa`
  - `2 = RamWa`
- Padding:
  - sink slot ⊥_ram (addr 4096) satisfies the sink/no-write rules from §6.3,
  - padded slots `4097..8191` have `Val = 0`, all ra/wa = 0`
- Opened at: `(r_addr_ram, r_twist_cycle)`

### 13.9 C_rom_table

- Domain: `ROM_ADDR_BITS = 11` variables
- Table: absolute CHIP-8 ROM word table
- Opened at: `r_fetch_addr`

### 13.10 C_decode_table

- Domain: `16` variables
- Table: full-opcode decode table, output width = 22 fields
- Output polynomial IDs:
  - `0 = valid`
  - `1 = x_dec`
  - `2 = y_dec`
  - `3 = kk_dec`
  - `4 = nnn_addr_dec`
  - `5 = nnn_word_dec`
  - `6 = writes_lookup_to_x_dec`
  - `7 = writes_mem_to_x_dec`
  - `8 = preserves_x_dec`
  - `9 = writes_nnn_to_i_dec`
  - `10 = is_jump_dec`
  - `11 = is_branch_dec`
  - `12 = is_memop_dec`
  - `13 = is_store_dec`
  - `14 = is_load_dec`
  - `15 = reads_ram_dec`
  - `16 = writes_ram_dec`
  - `17 = uses_y_dec`
  - `18 = lookup_kind_dec`
  - `19 = lhs_selector_dec`
  - `20 = rhs_selector_dec`
  - `21 = x_bound_dec`
- Opened at: `r_decode_addr`

### 13.11 C_alu_table

- Domain: `16` variables
- Table: the `Add8Lo(lhs, rhs)` subtable only
- This is **not** a standalone 18-bit combined ALU table. The full ALU evaluator
  is the mixed function `Val_alu(tag, lhs, rhs)` from §5.3 / §2.4.
- Opening point:
  - `r_add8lo_addr = (r_lhs, r_rhs)`,
  - where `r_add8lo_addr` is the 16-bit suffix of the Stage-1 ALU point
    `r_alu_addr = (r_kind, r_lhs, r_rhs)`
- Opened at: `r_add8lo_addr`

### 13.12 C_eq4_table

- Domain: `8` variables
- Table: `Eq4`
- Opened at: `r_eq4_addr`

---

## 14. Bridge Binding Mechanism

For `simple.rs` v1, the chosen mechanism is **explicit row-opening proofs
against `C_lane`**, not the aggregate identity `C_lane = Σ_j c_j`.

Rationale: unless the commitment layer exposes a formally specified linear row
decomposition that the verifier can check, the bridge must prove each exported
row's membership in `C_lane` via column openings at that row index.

Concretely, for each exported semantic row `j ∈ [0, N)`, the bridge owns a
`RowBindingClaim` instance:

```text
RowBindingClaim_j = {
    row_index: j,
    row_point_bits: j_bits,
    opened_lane_values: all non-fixed coordinates of z_j,
    opening_claim_ref,
    prepared_step_commitment: PreparedStep_j.mcs.c,
}
```

where `j_bits` is the binary encoding of the row index in the same little-endian
cycle-bit order used by `C_lane`, and the claimed row data are the 23 committed
non-fixed lane-column values opened from `C_lane` at that point,
and `z_j[0] = ONE = 1` is inserted as a fixed constant by the verifier.

Bridge verifier algorithm for row `j`:

1. Verify the batched opening of the 23 committed non-fixed lane columns at
   `j_bits` under `C_lane`.
2. Recover the opened semantic row `z_j` by prepending the fixed coordinate
   `ONE = 1`.
3. Compute `RootEncode(z_j) = (w_j, Z_j)` exactly as in §11.2, using the
   canonical SuperNeo packed witness encoding for `Z_j`.
4. Recompute `c_j = Ajtai_commit(Z_j)`.
5. Check `c_j = PreparedStep_j.mcs.c`.
6. Check `PreparedStep_j.witness.w = w_j`.
7. Check `PreparedStep_j.mcs.x = [F::ONE]` and `PreparedStep_j.mcs.m_in = 1`.

Only after those checks may the root prover consume `PreparedStep_j` for the
main-lane CCS proof.

Batching rule:

- The bridge may batch the 23 committed non-fixed lane-column openings for a
  single row at `j_bits`.
- The v1 chunk rule is:
  - one batched opening object per exported semantic row `j ∈ [0, N)`,
    covering all 23 committed non-fixed lane columns at `j_bits`,
  - no additional chunk-level bridge batch across distinct row-binding claims.
- A verifier must still be able to recover the specific opened row `z_j` for
  every exported `PreparedStep_j`.

---

## 15. Conformance Requirements

A CHIP-8 integration may claim conformance to this spec only if all of the
following are true.

1. Stage 1 uses separate authenticated fetch, decode, ALU/branch, and burst-
   equality channels, or an explicitly batched equivalent with soundness
   accounted for.
2. Stage 2 uses port-correct register and RAM Twist instances, plus the
   Jolt-style RAM RAF support relation tying `C_ram` back to `RAM_ADDR`, with
   sink addresses for inactive/no-write rows, not `<= 1` write-weight shortcuts.
3. Twist lane linkage is done with main-lane openings at the **Stage 2 cycle
   point**, not re-used from the Stage-1 lookup point, and Stage-2-only decode
   bits come from the separately committed `C_decode_handoff` surface.
4. The main lane includes enough projected control/address columns to make
   intermediate `Fx55/Fx65` rows local (`X_IDX`, `BURST_LAST`, `RAM_ADDR`) and
   keeps byte-address and word-address immediates distinct (`NNN_ADDR`,
   `NNN_WORD`).
5. The padded trace uses the public pad-row rule from §3.2, including inert
   Stage-1/Stage-2 padding semantics and the absolute self-loop `pad_pc_word`.
6. The control lane enforces `PC(j+1) = PC_NEXT(j)`, burst progression, the
   explicit start-boundary rule `IsMemOp(0) * X_IDX(0) = 0`, and the explicit
   final-boundary rule `IsMemOp(N-1) * (1 - BURST_LAST(N-1)) = 0`.
7. Chunks must begin and end on instruction boundaries with no in-flight
   `Fx55/Fx65` burst state. A kernel that supports carry-in or carry-out burst
   state must add explicit boundary fields and is outside this spec.
8. Booleanity is explicitly proved; Ajtai norm bounds do not substitute for it.
9. In this v1 spec, table evaluations are always separately authenticated under
   the appropriate table commitments (`C_rom_table`, `C_decode_table`,
   `C_alu_table`, `C_eq4_table`) and those commitments are always absorbed into
   `root0`. Direct verifier-computable evaluators may be used only as
   cross-checks; they do not replace the committed table surfaces.
10. The bridge's row-binding claim uses explicit row-opening proofs against
   `C_lane`, one row at a time for semantic rows `j ∈ [0, N)`, and the verifier
   recomputes the exported main-lane commitment from each opened row via the
   canonical `RootEncode` path.
11. Kernel-owned openings and root-prover-owned openings are emitted in separate
   manifests with explicit source tags before they are merged by `time_opening`.
12. The simple kernel does not duplicate the root row-local CCS proof; it only
    proves sidecars, continuity, and bridge binding into that root proof.
