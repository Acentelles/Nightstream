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
- `meta_pub`: the exact closed `KernelMetaPub` tuple for this protocol version.
  It contains the challenge-relevant public metadata that fixes the proved
  relation: program image digest, initial-state digest(s), table digests,
  protocol/version identifiers, field/extension identifiers, initialization
  mode, lowering / visibility-order convention, padding convention,
  public-table authentication mode, opening-reduction mode, trace length `N`,
  variable-order and domain-shape identifiers, zero/sink-address conventions,
  the absolute `program_base_addr`, the absolute self-loop padding address
  `pad_pc_word`, and the active `cycle_bits`.
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

`root0` is the transcript root digest over the exact kernel commitment bundle
and `meta_pub`. It is not itself a commitment family, and it is not a root-side
opening surface.

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
  `(vm_spec, public_program_image, program_base_addr, pad_pc_word,
    protocol version, domain-size choices, and variable-order identifiers)`,
- `meta_pub` is verifier-recomputed from that same public boundary and protocol
  constants; it is never accepted as prover-chosen metadata,
- v1 fixes one mandatory authentication path for those four public tables:
  each of `C_rom_table`, `C_decode_table`, `C_alu_table`, and `C_eq4_table`
  must be verifier-recomputable from that canonical table data, and the
  verifier must recompute the commitment and check equality,
- a v1 `SimpleKernelProof` therefore does **not** rely on optional public-table
  binding proofs for those four tables,
- any later protocol version that uses a non-deterministic table commitment for
  one of those public tables must add an explicit table-binding proof object to
  the proof boundary before that version is sound,
- hashing prover-supplied table digests into `meta_pub` is not sufficient by
  itself.

Verifier-cost note:

- this simple kernel boundary intentionally makes those four public tables
  verifier-recomputable and checks equality against the commitments fixed in
  `root0`;
- any recursive wrapper or succinct outer verifier that amortizes those checks
  is a later owner and is outside this simple-kernel theorem surface.

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

### 3.4 Lowering and visibility-order convention

The theorem-facing lowering convention fixed by this kernel is:

- each active semantic row is one CHIP-8 microstep;
- every row reads from its semantic `pre` state and writes only to its semantic
  `post` state;
- therefore Twist's "latest prior write" surface is consumed at row granularity:
  a read on row `j` observes the memory state determined before row `j`, not a
  same-row write that has not yet been exported into `post(j)`;
- row-to-row state transfer is owned separately by the adjacent-state theorem
  from §4.3a, not by silently treating same-row writes as immediately visible
  reads;
- public ROM/decode/ALU/Eq4 tables are separate Stage-1 Shout surfaces;
- the register file and RAM are separate Stage-2 Twist timelines, not one tagged
  shared address space;
- `Fx55` / `Fx65` lower to one authenticated burst microstep per cursor
  `i ∈ [0, x_bound]`, in increasing cursor order, with:
  - RAM address `pre.I + i`,
  - `StoreRegs`: write `RAM[pre.I + i] := pre.V[i]`,
  - `LoadRegs`: read `RAM[pre.I + i]` and write `post.V[i]`,
  - `BURST_LAST = 1` exactly on the final covered microstep.

This is the `lowering_convention_id = chip8_microstep_pre_post_v1` carried in
`meta_pub`. Any implementation that changes same-row visibility, burst row
order, or memory-space separation is proving a different relation and is
non-conforming unless it also changes the public metadata and theorem surface.

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
explicit continuity support relation over `C_lane`. By themselves they do not
yet state full adjacent machine-state equality across the semantic prefix.

### 4.3a Adjacent-state linking theorem obligation

The continuity support relation from §4.3 is necessary but not sufficient for
the strong semantic soundness claim of this kernel. It constrains only the
projected control-lane coordinates needed to keep the lane local across rows.
The kernel soundness theorem must also establish exact adjacent machine-state
linking across the semantic prefix.

Let `PreState(j)` and `PostState(j)` denote the semantic machine states
determined for row `j` by the authenticated Stage-1 / Stage-2 interpretation of
the opened row, together with the row-local root relation from §4.1.

Strong kernel soundness requires:

```text
forall j < N-1: PostState(j) = PreState(j+1)
```

This theorem is discharged compositionally. The intended proof path follows the
same shape Jolt uses for strong execution soundness: authenticate the temporal
evolution of each mutable state component, then derive whole-state equality
extensionally from those component facts. In this CHIP-8 kernel, the
soundness-carrying closure objects are:

- the theorem-level Stage-2 temporal closure object `Stage2TemporalContext`,
  which determines one shared register / `I` timeline and one shared RAM
  timeline over the semantic prefix together with per-row provenance into those
  same timelines;
- the theorem-level Stage-3 semantic bridge `PcAdjacentBridge`, which turns the
  checked shift/boundary surface plus authenticated row binding into adjacent-
  row `pc` equality;
- the row-local root relation and staged row interpretation, which identify
  `PreState(j)` / `PostState(j)` with those authenticated component values.

The closure path is intentionally explicit:

```text
Stage2TemporalContext
  + PcAdjacentBridge
  => TemporalInstantiation
  => TraceLinkBound
  => ExecutionCorrect
```

These are theorem-facing closure objects, not free external assumptions. Any
accepted-kernel boundary is complete only if that same closure path is
recoverable from the exact boundary data of §4.3b.

Normative rules:

- this is a theorem-level composition obligation, not a new direct opening
  claim and not a standalone Stage-3 scalar identity;
- Stage 3 owns only the continuity support relation, the start-boundary rule,
  and the final-boundary rule;
- the exact adjacent-state link must be justified by composing:
  - the root row-local relation from §4.1,
  - the Stage-1 / Stage-2 bindings that interpret the authenticated row,
  - one shared `Stage2TemporalContext` over the chunk,
  - one exact `PcAdjacentBridge` over the semantic prefix,
  - and the row-binding / bridge extraction that ties those facts to the same
    semantic row;
- any implementation that claims the strong theorem
  `accepted kernel proof => exact CHIP-8 execution trace` must discharge this
  adjacent-state linking obligation;
- a weaker theorem that stops at local row correctness, continuity support, and
  bridge export is not sufficient for this spec.

### 4.3b Exact-boundary closure requirement

The accepted-kernel boundary from this spec is an auditor-facing packaging of
the exact lower-layer boundary; it is not allowed to introduce a free
theorem-facing oracle.

Let the exact boundary data for one chunk consist of:

- the exact authenticated row/trace evidence for the semantic prefix and its
  padded extension;
- the simple-kernel public input / chunk-input boundary from §9.5;
- the exact kernel/root opening discipline from §9.4;
- and the exact transcript schedule from §12.

Then strong kernel soundness requires the following direct corollary:

- that exact boundary data determines the same theorem-level temporal-support
  contract needed by §4.3a, namely:
  - one shared `Stage2TemporalContext` over the chunk,
  - and one exact `PcAdjacentBridge` over the semantic prefix;
- equivalently, the same exact boundary data determines one accepted kernel
  boundary instance and therefore the same strong execution conclusion.

Normative rule:

- an implementation may expose the accepted-kernel boundary as a named audit
  package, but it may not require any additional theorem-facing temporal-
  support witness that is not itself determined by the exact boundary data
  above.

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

### 6.2b Register / I temporal consistency consequence

The explicit register `Val`-from-`Inc` theorem surface is not only a local
lookup sidecar. It also carries the temporal register-state consequences needed
by the strong adjacent-state linking theorem from §4.3a.

For the 16 CHIP-8 `V` registers and the distinguished `I` slot carried on the
same authenticated register timeline, the kernel must justify:

```text
forall j < N, idx in {0..15}: PreState(j).V[idx] = RegVal(idx, j)
forall j < N: PreState(j).I = RegVal(16, j)
```

and:

```text
forall j < N-1, idx in {0..15}: PostState(j).V[idx] = RegVal(idx, j+1)
forall j < N-1: PostState(j).I = RegVal(16, j+1)
```

These are theorem-level temporal consequences derived from the row-local
register interpretation, the authenticated register read/write batch, and the
explicit `RegVal` handoff rule. They are not additional direct openings and not
new primary commitments.

These row-local consequences are not yet the full Stage-2 closure object.
Accepted kernel evidence for one chunk must additionally determine one shared
chunk-global register timeline over the entire semantic prefix:

```text
forall idx in {0..15}, j in {0..N}: RegVal(idx, j)
forall j in {0..N}: RegVal(16, j)
```

together with per-row provenance showing that the local Stage-2 seeds for row
`j` read from and write back to that same shared timeline. No row may introduce
its own incompatible register timeline. This chunk-global register timeline is
the Stage-2 object later consumed by the adjacent-state closure from §4.3a.

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

### 6.4a RAM temporal consistency consequence

The explicit RAM `Val`-from-`Inc` theorem surface also carries the temporal RAM
consequences needed by the strong adjacent-state linking theorem from §4.3a.

For the fixed CHIP-8 RAM domain `0..4095`, the kernel must justify:

```text
forall j < N, addr in {0..4095}: PreState(j).RAM[addr] = RamVal(addr, j)
```

and:

```text
forall j < N-1, addr in {0..4095}: PostState(j).RAM[addr] = RamVal(addr, j+1)
```

These are theorem-level temporal consequences derived from the row-local RAM
interpretation, the authenticated RAM read/write batch, the RAM RAF support
relation, and the explicit `RamVal` handoff rule. They are not new direct
openings and not new primary commitments.

These row-local consequences are not yet the full Stage-2 closure object.
Accepted kernel evidence for one chunk must additionally determine one shared
chunk-global RAM timeline over the entire semantic prefix:

```text
forall addr in {0..4095}, j in {0..N}: RamVal(addr, j)
```

together with per-row provenance showing that the local Stage-2 RAM seeds for
row `j` read from and write back to that same shared timeline. No row may
introduce its own incompatible RAM timeline. This chunk-global RAM timeline is
the Stage-2 object later consumed by the adjacent-state closure from §4.3a.

### 6.4b Stage-2 temporal closure object

The theorem-level Stage-2 closure owner for one chunk is:

```text
Stage2TemporalContext {
    reg_timeline,
    ram_timeline,
    row_links,
}
```

Normative meaning:

- `reg_timeline` determines one shared register / `I` timeline over times
  `0..N`;
- `ram_timeline` determines one shared RAM timeline over times `0..N`;
- `row_links[j]` binds the authenticated Stage-2 register-side and RAM-side
  seeds for row `j` to times `j` and `j+1` of those same shared timelines;
- the row-local Stage-2 seeds from §6.2b and §6.4a are inputs to this object;
  they are not themselves the closure theorem consumed by strong kernel
  soundness;
- accepted kernel evidence for one chunk must determine one coherent
  `Stage2TemporalContext`; no row may be interpreted against a different
  incompatible register or RAM timeline.

Classification:

- `Stage2TemporalContext` is a theorem-level kernel closure object;
- it is not a direct opening claim, not a new commitment family, and not an
  audit/provenance summary.

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
- the transcript-bound public metadata therefore fixes
  `initialization_mode = authenticated_nonzero_init`.

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

Low-level padded-domain rule:

- the raw current openings at `r_shift` and the raw shifted values from
  `LaneShiftProof` are evaluations over the full padded `T`-row lane;
- before batching the Stage-3 continuity identity, the verifier subtracts the
  excluded suffix contributions:
  - current-side terms for rows `j ∈ [N-1, T)`,
  - shift-side terms for rows `j ∈ [N-1, T-1)`;
- those corrections are determined only by the authenticated last active row,
  the public pad-row rule, and the hypercube weights at `r_shift`;
- the theorem-facing Stage-3 continuity surface is the refined active-prefix
  relation after those explicit corrections, not the naive direct product of
  raw padded-domain openings.

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

These checks certify the Stage-3 continuity support relation used by the
stronger adjacent-state linking theorem from §4.3a; they do not by themselves
prove full post/pre machine-state equality across adjacent rows.

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

### 8.1c Stage-3 semantic `pc` bridge

The theorem-level Stage-3 semantic bridge consumed by strong kernel soundness
is:

```text
PcAdjacentBridge
```

Normative meaning:

- for every semantic adjacent pair `j < N-1`, the checked Stage-3 shift witness
  for row `j`, the current-row continuity witness, and the authenticated
  row-binding openings for rows `j` and `j+1` together determine:

  ```text
  PostState(j).pc = PreState(j+1).pc
  ```

- this bridge consumes the checked Stage-3 support objects from §8.1a and
  §8.1b together with the authenticated row-binding / bridge-binding path from
  §9.4;
- it is the theorem-level Stage-3 object used by the adjacent-state closure
  from §4.3a;
- it is not a direct opening claim, not a new reduction layer, and not an
  audit/provenance summary.

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

Scope warning:

- this opening-boundary material is complete only for the `simple` v1 kernel
  boundary defined here;
- on that boundary, `RootOpeningManifest` is an explicit ownership bucket that
  must remain empty;
- any later combined kernel-plus-root proof that exports root-owned openings
  must introduce its own explicit root opening schema rather than inferring one
  from this section.

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

There are two distinct grouping notions:

- direct kernel opening claims are keyed by `(commitment_id, point)`;
- later claim-space reduction groups are keyed by the narrower
  `(source, domain, point)` rule owned by `time_opening`, with member claims
  ordered canonically by their manifest ordinals within that group.

These must not be conflated. The first identifies one family-local direct
opening surface; the second identifies one transcript-local reduction bucket.

Same-surface collision rule:

- if two required direct openings land on the same `(commitment_id, point)`,
  they remain distinct direct claims only through their exact
  `polynomial_ids`;
- the `simple` boundary does not require canonical coalescing of such
  same-surface claims;
- canonical manifest order breaks same-surface ties by `polynomial_ids` in the
  commitment-local registry order;
- two distinct claims with the same
  `(commitment_id, point, polynomial_ids)` are illegal duplicates.

The opening boundary is split into two disjoint ownership buckets:

- `KernelOpeningManifest`: claims emitted by this 3-stage kernel before handoff.
- `RootOpeningManifest`: claims emitted later by the root prover.

`time_opening` verifies the union of both manifests, but the source/ownership tag
must remain explicit for every claim.

In this `simple` v1 kernel, `KernelOpeningManifest` contains exactly:

- `C_lane @ r_lookup` opening exactly the lane columns
  `{PC, KK, NNN_ADDR, NNN_WORD, REG_X, REG_Y, LOOKUP_OUTPUT,
    WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
    IsJump, IsBranch, IsMemOp, X_IDX, Y_IDX, BURST_LAST}`,
- `C_fetch_ra @ (r_fetch_addr, r_lookup)` for the Stage-1 fetch address family,
- `C_decode_ra @ (r_decode_addr, r_lookup)` for the Stage-1 decode address family,
- `C_alu_ra @ (r_alu_addr, r_lookup)` for the Stage-1 ALU/branch address family,
- `C_eq4_ra @ (r_eq4_addr, r_lookup)` for the Stage-1 burst-equality address family,
- `C_decode_handoff @ r_lookup` opening exactly
  `{handoff_uses_y, handoff_reads_ram, handoff_writes_ram}` for the Stage-1
  decode-handoff surface,
- `C_rom_table @ r_fetch_addr` for the ROM table,
- `C_decode_table @ r_decode_addr` opening exactly polynomial ids `0..21`
  in the canonical registry order from §13.10 for the full-opcode decode
  table,
- `C_alu_table @ r_add8lo_addr` for the `Add8Lo` subtable,
- `C_eq4_table @ r_eq4_addr` for the `Eq4` table,
- `C_lane @ r_twist_cycle` opening exactly the lane columns
  `{REG_X, REG_Y, REG_X_NEXT, I_REG, I_NEXT, MEM_VALUE,
    WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
    IsMemOp, X_IDX, Y_IDX, RAM_ADDR}`,
- `C_decode_handoff @ r_twist_cycle` opening exactly
  `{handoff_uses_y, handoff_reads_ram, handoff_writes_ram}` for the Stage-2
  decode-handoff surface,
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

These are the committed `C_decode_handoff` columns, not the decode-table output
columns. Stage 1 separately proves
`handoff_uses_y = uses_y_dec`,
`handoff_reads_ram = reads_ram_dec`, and
`handoff_writes_ram = writes_ram_dec`.

So for one semantic prefix of length `N`, the simple kernel manifest contains
exactly `N + 17` direct kernel opening claims: 17 fixed non-row-binding claims
plus one `C_lane @ j_bits` row-binding claim for each `j ∈ [0, N)`.

For this `simple` boundary, the numbered list above is also the canonical
manifest order. The manifest ordinal, direct-claim digest identity, and the
deterministic in-group claim order used by later claim-space reduction objects
are all defined by exactly that stage-local order:

1. the 17 fixed claims in the order listed above; then
2. the `C_lane @ j_bits` row-binding claims in strictly increasing `row_index`.

No other kernel-owned direct opening claims are admissible in this `simple`
kernel spec. In particular:

- virtual values such as `RegVal` / `RamVal`,
- Stage-3 virtual shift values,
- claim-space reduction summaries,
- fold carriers,
- row-projection summaries,
- bridge-binding summaries,

are not direct opening claims and must not appear in either manifest.

No split or partial decode-table opening claims at `r_decode_addr` are
admissible in this `simple` v1 boundary.

`RegVal` and `RamVal` are virtual and never appear as primary `OpeningClaim`s`.

`RootOpeningManifest` contains only the openings owned by the root prover
(`Π_CCS -> Π_RLC -> Π_DEC`) after kernel handoff.

Kernel commitments and root commitments are intentionally disjoint:

- `KernelOpeningManifest` may only reference `C_*` commitments fixed in `root0`.
- `RootOpeningManifest` may only reference commitments created after bridge
  extraction, including the per-step root Ajtai commitments.
- on the `SimpleKernelProof` / `SimpleKernelOutput` boundary defined in this
  document, `RootOpeningManifest` is present only as an explicit ownership
  bucket and must be empty. Any non-empty root-owned manifest belongs to a later
  combined kernel-plus-root proof object, not to the simple kernel itself.

For this `simple` boundary, root-side binding is carried by the exact
`PreparedStep_j` export and the explicit `BridgeBinding_j` leaf, not by a
non-empty root opening manifest.

For this same `simple` boundary, "row-membership proof" means exactly the
accepted `C_lane @ j_bits` direct opening together with its exact lower-layer
opening witness and `OpeningRefinement`. There is no separate extra
row-membership PCS object beyond that authenticated opening path.

Any later combined kernel-plus-root proof that introduces root-owned openings
must add an explicit root-side schema containing at least:

- the exact root commitment inventory,
- the exact root opening-manifest entry kinds,
- canonical root-manifest ordering and uniqueness rules,
- the exact root-side refinement / provenance path from root opening claim to
  exported root-facing artifact.

That larger root-side schema must be introduced explicitly by the later owner;
it must not be inferred from the simple kernel boundary.

Later kernel stages do **not** consume Stage-1 lookup openings; each stage opens
its own claims independently.

### 9.3 Canonical manifest ordering and encoding

For the `simple` kernel boundary, the canonical `KernelOpeningManifest` order is
the exact numbered stage-local order fixed above. The generic sort key in this
section does **not** reorder that simple manifest. It is reserved only for
later owners whose manifests are not already fixed by the simple boundary, such
as a future non-empty root manifest.

If a later owner introduces claim-space summary registries, that owner must
define their ordering separately outside this opening-manifest section.

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

Canonical non-simple manifest sort key:

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

### 9.4 Opening provenance and semantic evidence chain

The direct opening manifests above are necessary but not sufficient for audit.
A third party must also be able to trace how each scalar opening used by Stage 1,
Stage 2, Stage 3, and the bridge is authenticated, reduced, and consumed.

This section defines that chain. It does **not** introduce any new kernel
commitment families beyond the `C_*` commitments fixed in `root0`.

#### 9.4.1 Exact lower-layer family openings

For every direct kernel opening claim, there must exist an exact lower-layer
opening witness against the referenced commitment family.

An audit-facing lower-layer opening object has the semantic shape:

```text
ExactOpeningWitness {
    commitment_id,
    point,
    polynomial_ids,
    commitments,       // commitment-local columns within that family
    claimed_values,    // one value per polynomial_id
    lower_layer_proof, // exact family opening witness
    proof_digest,
}
```

Normative rules:

- `commitment_id`, `point`, and `polynomial_ids` must match one direct
  `OpeningClaim` exactly.
- `claimed_values` must be the exact evaluation results of the referenced
  family-local polynomials at `point`.
- The lower-layer witness may use commitment-local digit evaluations,
  commitment-local reduction data, or an equivalent exact opening construction,
  but it must be sufficient to authenticate the `claimed_values` against the
  referenced family commitment.
- No lower-layer opening witness may authenticate values for a commitment family
  other than the one named by its `commitment_id`.

This requirement applies to every kernel-owned family:

- `C_lane`
- `C_fetch_ra`
- `C_decode_ra`
- `C_alu_ra`
- `C_eq4_ra`
- `C_decode_handoff`
- `C_reg`
- `C_ram`
- `C_rom_table`
- `C_decode_table`
- `C_alu_table`
- `C_eq4_table`

Canonical digest identity rule:

- every digest-bearing kernel opening object in this section is named by one
  Poseidon2 digest over its exact canonical labeled encoding;
- the canonical encoding order is the schema-field order shown in this spec;
- every ordered collection inside such an object must already be in the exact
  canonical order owned by this spec:
  - manifest-local claim order uses the canonical manifest order from §9.3,
  - `time_opening` group members use canonical manifest ordinal order inside the
    fixed `(source, domain, point)` bucket,
  - row-indexed collections use increasing `row_index`;
- point coordinates use the exact canonical coordinate encoding from §9.3;
- field elements and vectors of field elements use the transcript's canonical
  field-element absorption in the order shown;
- byte strings or proof bytes use the transcript's canonical byte absorption
  under fixed labels;
- the digest of a kernel-owned object is therefore deterministic from the
  values shown in its schema and from the exact canonical ordering rules above.

Backend-owned exception:

- `ExactOpeningWitness.lower_layer_proof` remains owned by the referenced
  commitment-family backend;
- `proof_digest` is therefore the canonical backend-owned digest of that exact
  lower-layer proof object, while `ExactOpeningWitness` itself is still named by
  its own kernel-owned canonical digest when later objects refer to the exact
  witness.

#### 9.4.1a Accepted opening verifier contract

For the `simple` kernel boundary, post-manifest opening verification is not left
abstract. A direct kernel opening claim is accepted only if the verifier can
exhibit the following exact chain:

```text
AcceptedDirectOpening {
    claim_digest,
    exact_opening_digest,
    refinement_digest,
}
```

with normative meaning:

- `claim_digest` names exactly one direct `OpeningClaim` in the canonical merged
  manifest order;
- `exact_opening_digest` names exactly one `ExactOpeningWitness` whose
  `commitment_id`, `point`, and `polynomial_ids` match that direct claim;
- that witness's `claimed_values` must equal the direct claim's
  `claimed_values` coordinatewise in the same `polynomial_ids` order;
- the verifier checks the `lower_layer_proof` inside that
  `ExactOpeningWitness` against the referenced commitment family and accepts the
  `claimed_values` only if that family-local opening verification succeeds;
- `refinement_digest` names exactly one `OpeningRefinement` binding
  `claim_digest` to `exact_opening_digest`.

The canonical `time_opening` grouping key used later in this section is:

```text
(source, domain, point)
```

where:

- `source` records whether the direct claim came from the kernel manifest or
  the root manifest;
- `domain` is the verifier-known evaluation-domain descriptor for the
  referenced commitment family;
- `point` is the exact opening point carried by the direct claim.
- each accepted direct claim still carries its canonical manifest `ordinal`
  within that `source`, but that ordinal is an ordering key inside the
  group rather than part of the grouping key itself.

`time_opening_summary` is an audit-only canonical ordered digest tree over these
accepted direct claims after lower-layer family opening verification. It is not
itself the verifier relation. The verifier relation is the successful existence
of the exact chain above for every direct manifest claim.

Classification:

- `AcceptedDirectOpening` is part of the soundness-carrying accepted-opening
  path: it packages one accepted direct claim, one exact lower-layer opening
  witness, and one refinement chain tying them together;
- `time_opening_summary` is an audit-only summary over those accepted chains;
- neither object is a new `OpeningClaim`, a new lower-layer opening witness, or
  a semantic theorem.

#### 9.4.2 OpeningRefinement

Every direct scalar opening used by semantic extraction must carry an explicit
refinement from the direct manifest claim to the lower-layer exact opening
witness.

```text
OpeningRefinement {
    commitment_id,
    point,
    polynomial_ids,
    claim_digest,
    opening_proof_digest,
    digest,
}
```

Normative rules:

- `claim_digest` must be the digest of exactly one direct `OpeningClaim`.
- `opening_proof_digest` must be the digest of exactly one exact lower-layer
  opening witness covering that claim.
- `OpeningRefinement` is a binding object only. It is not a new opening claim,
  not a new commitment, and not a substitute for the lower-layer opening proof.
- Every direct scalar consumed downstream through this opening boundary must be
  carried by exactly one accepted-opening path:
  one direct `OpeningClaim`,
  one exact `ExactOpeningWitness`,
  and one `OpeningRefinement`
  packaged by the corresponding `AcceptedDirectOpening`.
- The scalar projection of that accepted-opening path is an
  `AcceptedScalarOpening`.
- `OpeningRefinement` is therefore one component of the accepted-opening path
  only; it never substitutes for exact opening verification or coordinatewise
  equality between the direct claim values and the exact-opening witness values.

#### 9.4.3 Joint opening reduction over refined claims

The current `simple` kernel boundary does not export joint-opening reduction
artifacts. A future extended boundary may reduce refined opening claims for
efficiency, but any such reduction must remain explicit and transcript-bound.
The concrete mode identifier for this boundary is
`opening_reduction_mode_id = no_post_transcript_reduction_v1`.

This section owns only claim-space aggregation. It does **not** by itself define
or justify a witness-space fold lane. Reducing authenticated claims in
transcript space is allowed across heterogeneous kernel commitment families;
constructing a fold carrier is a separate later step with a strictly stronger
homogeneity requirement.

If a future proof instance chooses to export those optional claim-space
summaries, the
audit-facing reduction chain has four layers.

First, one summary per accepted direct opening:

```text
JointOpeningClaimSummary {
    accepted_opening_digest,
    reduced_commitment_ref,
    reduced_claim,
    digest,
}
```

This reduces one accepted direct opening across its local `polynomial_ids`
using fresh claim-local mixers `eta_0, ..., eta_{m-1}` sampled from a
dedicated post-transcript reduction domain after the accepted-opening
inventory is fixed. That reduction domain is bound to:

- the exact `AcceptedDirectOpening.digest`,
- the referenced commitment family from that accepted opening,
- the point from that accepted opening,
- the exact `polynomial_ids` from that accepted opening.

Second, one summary per canonical `time_opening` group:

```text
JointOpeningGroupSummary {
    group_digest,
    accepted_opening_digests,
    reduced_commitment_ref,
    reduced_claim,
    digest,
}
```

This reduces the claim summaries that share the same canonical
`time_opening` group using fresh group-local mixers sampled from a dedicated
post-transcript reduction domain bound to:

- the canonical reduction group digest,
- the ordered claim-summary digests in that group, where the order is the
  canonical manifest ordinal order within the fixed `(source, domain,
  point)` bucket.

Third, one explicit joint-opening unification proof:

```text
JointOpeningUnificationProof {
    claimed_sum,
    round_polys,
    r_unify,
}
```

This is a selector-style unification proof over the joint-opening groups. It is
separate from and in addition to any generic `time_opening` unification proof.

Fourth, one unified claim-space reduction summary:

```text
JointOpeningUnifiedClaimReduction {
    unified_commitment,
    unified_claim,
    digest,
}
```

This reduces the authenticated group summaries using fresh unification mixers
sampled only after the group summaries and joint-opening unification proof are
fixed. These mixers are internal to the optional reduction artifacts; they are
not Stage-1 / Stage-2 / Stage-3 transcript events from §12.

Normative scope restriction:

- these theorem-facing claim-space summaries carry only the authenticated source
  digests, the reduced claim value, the reduced commitment reference, and their
  own digest;
- any PCS-local digit decomposition or byte packing used internally by one
  lower-layer opening backend remains inside that lower-layer backend and is not
  part of the kernel theorem surface.

Normative meaning:

- `JointOpeningUnifiedClaimReduction` is still a claim-space reduction summary.
- `JointOpeningUnifiedClaimReduction` is not a witness-space
  fold lane and not an algebraic combined commitment unless a later
  homogeneous owner proves such a structure explicitly;
- It is **not** yet a CE / CCS fold object.
- Its existence does not imply that the underlying groups live in one
  homogeneous witness space.
- It may aggregate heterogeneous kernel commitment families so long as the
  underlying direct claims remain separately authenticated and the reduction is
  transcript-bound.
- In this v1 kernel, it must not be interpreted as a single kernel-wide
  witness-space fold lane.

Normative rules:

- none of the claim-local, group-local, or unification mixers may reuse any
  Stage-1, Stage-2, or Stage-3 challenge;
- specifically they must not reuse `r_lookup`, any Stage-1 address point, any
  Stage-1 lookup batching challenge, `r_twist_cycle`, `r_addr_reg`,
  `r_addr_ram`, any Stage-2 batching or linkage challenge, `r_shift`, or the
  Stage-3 continuity batching scalars;
- each reduction layer must use its own transcript domain separation;
- these reduction objects, if materialized at all, are post-transcript artifacts
  derived only after the kernel transcript closes;
- each reduction layer must be bound only after the previous layer's digests are
  fixed.

#### 9.4.4 Joint-opening fold carrier

The current `simple` kernel boundary does not export family-local folded
carriers. A future extended boundary may export deterministic family-local
folded carriers for a later root/opening lane, but if it does, those carriers
must be represented honestly.

```text
FoldBucketDescriptor {
    family_id,
    setup_id,
    structure_id,
    commitment_map_id,
    witness_layout_id,
    point_shape_id,
    common_point,
    encoded_width,
    fold_shape_id,
}

FamilyLocalOpeningFoldCarrier {
    commitment_id,
    bucket_descriptor,
    shape,
    group_digests,
    r_fold,
    folded_commitment,
    folded_claim,
    digest,
}
```

Normative rules:

- on the current `simple` boundary, `FamilyLocalOpeningFoldCarrier` must be
  absent;
- `FamilyLocalOpeningFoldCarrier` is not an `OpeningClaim`.
- `FamilyLocalOpeningFoldCarrier` is not a new commitment family.
- `FamilyLocalOpeningFoldCarrier` is not by itself a CCS proof.
- It is only an authenticated deterministic carrier derived from the already
  checked joint-opening summaries.
- every exported fold carrier must be family-local and may contain groups from
  only one homogeneous witness space. Homogeneity here means:
  - one commitment family,
  - one commitment setup / committer surface,
  - one encoded witness width,
  - one fold-shape convention over the carried claims,
  - one CE / CCS structure identifier,
  - one commitment-map identifier,
  - one point shape / evaluation convention,
  - one common evaluation point value `r`,
- one witness-layout identifier.
- `bucket_descriptor` must expose those homogeneity discriminants explicitly;
  the verifier must be able to read one exact descriptor for the carried bucket
  rather than inferring homogeneity from implementation folklore.
- every source group named in `group_digests` must match the same exact
  `bucket_descriptor`.
- claims that differ in evaluation point value may be jointly summarized in
  claim space, but they must not appear in the same
  `FamilyLocalOpeningFoldCarrier`.
- `r_fold` must be sampled fresh from a bucket-local transcript domain bound to
  the family id and the source group digests.
- `folded_commitment` and `folded_claim` must be the exact linear combination
  induced by `r_fold` over the source group objects in that bucket.
- if the kernel opening set is heterogeneous, the kernel must either:
  - omit a single global fold carrier, or
  - export one fold carrier per homogeneous bucket.
- a single global heterogeneous fold carrier across heterogeneous commitment
  families is non-conforming.

For the current `simple` kernel boundary, the intended carrier shape is:

```text
FamilyLocalOpeningFoldCarrier {
    commitment_id,
    bucket_descriptor,
    shape,
    group_digests,
    r_fold,
    folded_commitment,
    folded_claim,
    digest,
}
```

where each bucket proof is family-local and all claims in that bucket live in
the same homogeneous witness space at one common evaluation point value.
`r_fold` is sampled fresh from a
bucket-local transcript domain, and the folded commitment / folded claim values
are the exact family-local linear combination induced by that point.
For the current v1 CHIP-8 kernel opening inventory, a single global
heterogeneous fold carrier is non-conforming and must be absent even when
claim-space summaries exist.

Any implementation that labels this carrier as a proved CCS lane before such a
lane actually exists is non-conforming.

#### 9.4.5 RowProjectionWitness

The semantic layer must carry one explicit positive row/view witness per
exported semantic row.

```text
RowProjectionWitness_j = {
    row_index: j,
    row_binding_accepted_opening_digest,
    semantic_row_digest,
    semantic_view_digest,
}
```

where:

- `row_binding_accepted_opening_digest` references the exact
  `AcceptedDirectOpening` whose direct claim is the `C_lane @ j_bits`
  row-binding opening used by Stage 3,
- `semantic_row_digest` commits to the canonical 24-coordinate row `z_j`, with
  the verifier-known coordinate `ONE = 1` inserted at position 0,
- `semantic_view_digest` commits to the derived row-local auxiliary view
  consumed by semantic extraction, but only for data that is purely local to
  the authenticated row plus verifier-known constants.

Normative rules:

- `RowProjectionWitness_j` must be tied to the same authenticated row-binding
  accepted opening that later feeds `PreparedStep_j`;
- the referenced accepted opening must package the exact row-binding direct
  claim, the exact lower-layer opening witness for that claim, and the exact
  refinement path tying those two together;
- the semantic view may include:
  - the 24-coordinate semantic row itself,
  - verifier-known fixed coordinates such as `ONE = 1`,
  - purely row-local derived projections such as the root-facing witness row and
    row-local aux fields that are definitionally determined by the authenticated
    row and public constants;
- the semantic view must **not** by itself claim provenance for:
  - Stage-1 decode tables or handoff bits,
  - Stage-2 virtual `Val` objects or closed Twist sessions,
  - Stage-3 start/final-boundary transfer facts,
  - any cross-row or session-level semantic fact;
- those non-local facts must remain justified by the explicit Stage-1 / Stage-2
  / Stage-3 proof objects and their own provenance predicates;
- no semantic fact may be extracted from an unauthenticated recomputation path
  that bypasses the row-binding claim.

#### 9.4.6 BridgeBindingSummary

The bridge must also carry one explicit binding object per exported semantic
row, connecting the same authenticated row-binding accepted opening to the
root-facing prepared step.

```text
BridgeBinding_j = {
    row_index: j,
    row_binding_accepted_opening_digest,
    prepared_step_digest,
}
```

Normative rules:

- the bridge binding object must reference the same accepted row-binding opening
  as the row-projection witness for row `j`;
- the bridge binding object and `RowProjectionWitness_j` must therefore share
  one exact `AcceptedDirectOpening`, not merely the same `row_index`, direct
  claim digest, or refinement digest;
- `prepared_step_digest` must commit to the exact `PreparedStep_j` object handed
  to the root prover;
- the verifier must check that `PreparedStep_j` is the exact canonical
  `RootEncode` image of the authenticated row before accepting the bridge
  binding; in particular it must check equality of the packed witness payload,
  the exposed witness slice, and the root commitment induced by that packed
  witness.

#### 9.4.7 Audit rule for recomputation

Verifier recomputation may be used as a cross-check, but not as the only
authentication mechanism.

Concretely:

- recomputing a lane/table/address value from public data or reconstructed trace
  data does not replace the direct opening claim for that value;
- recomputing a semantic row from `RowBindingClaim` does not replace the
  row-binding opening itself;
- recomputing `PreparedStep_j.mcs.c` from an opened row does not replace the
  requirement that the row itself first be authenticated against `C_lane`.

The mandatory soundness edges are:

```text
root0 commitment
  -> direct OpeningClaim
  -> ExactOpeningWitness
  -> OpeningRefinement
  -> AcceptedDirectOpening
  -> RowProjectionWitness
  -> BridgeBinding_j
  -> PreparedStep_j
```

The exact adjacent-state linking theorem from §4.3a sits above these mandatory
edges. It is not a new opening object or summary object; it is the semantic
composition consequence that ties the authenticated local rows into one exact
execution trace.

Optional claim-space aggregation edges are:

```text
AcceptedDirectOpening
  -> JointOpeningClaimSummary
  -> JointOpeningGroupSummary
  -> JointOpeningUnificationProof
  -> JointOpeningUnifiedClaimReduction
```

Optional witness-space fold-carrier edges are:

```text
JointOpeningGroupSummary
  -> FamilyLocalOpeningFoldCarrier(commitment_id = one homogeneous family)
```

Claim-space aggregation does not imply witness-space foldability.

Any implementation that skips one of the mandatory binding edges above and
replaces it with an unauthenticated recomputation shortcut is non-conforming.

#### 9.4.8 Object classification

To keep the opening boundary auditor-visible, every opening-related object in
this section is classified as exactly one of the following:

- theorem / soundness-carrying:
  - direct `OpeningClaim`,
  - `AcceptedDirectOpening`,
  - lower-layer `ExactOpeningWitness`,
  - `OpeningRefinement`,
  - the exact Stage-1 / Stage-2 / Stage-3 checked objects that consume those
    openings,
  - the exact adjacent-state linking theorem from §4.3a;
- protocol-binding:
  - `root0`,
  - `KernelOpeningManifest`,
  - `RootOpeningManifest`,
  - canonical manifest ordering / grouping,
  - the transcript schedule and domain-separation rules that bind any present
    claim-space reduction objects;
- mandatory provenance:
  - `RowProjectionWitness_j`,
  - `BridgeBinding_j`;
- optional implementation-side carrier / summary:
  - `JointOpeningClaimSummary`,
  - `JointOpeningGroupSummary`,
  - `JointOpeningUnificationProof`,
  - `JointOpeningUnifiedClaimReduction`,
  - `FamilyLocalOpeningFoldCarrier`.

Normative consequences:

- no optional carrier / summary object is a new direct opening claim;
- no optional carrier / summary object replaces `ExactOpeningWitness` or
  `OpeningRefinement`;
- `RowProjectionWitness_j` and `BridgeBinding_j` are mandatory binding edges,
  but they are provenance leaves rather than new semantic theorems;
- optional claim-space summaries may reference only accepted openings and their
  canonical digests; they may not summarize raw unaccepted manifest claims;
- `JointOpeningUnifiedClaimReduction` remains an optional claim-space reduction
  summary;
- `FamilyLocalOpeningFoldCarrier` is an optional family-local carrier and is not
  by itself a proved CCS lane.

Stage-obligation carrier map for the `simple` boundary:

The theorem-facing owner map for the Lean surfaces named in this section is
`Chip8KernelBoundaryParity`. That owner adds no new protocol logic; it is the
thin owner-index tying this boundary text to the exact Lean interfaces that own
accepted openings, transcript/public-input binding, Stage-2 temporal support,
Stage-3 refinement, and bridge handoff.

| Obligation | Exact carrier(s) on this boundary |
| --- | --- |
| Public-input binding | `SimpleKernelPublicInput`, `KernelMetaPub`, the canonical `root0` absorb sequence from §9.5 / §12, and the later theorem-facing `KernelPublicInputsBound` owner |
| Stage-1 authentic table access | The corresponding `Stage1ChannelProof.table_opening_claims` entry together with the accepted-opening path for the matching committed table or handoff opening in `KernelOpeningManifest` |
| Stage-1 address correctness | `Stage1ChannelProof.addr_correctness_proof` for each of `fetch`, `decode`, `alu`, and `eq4`, in canonical channel order |
| Stage-1 decode-handoff authenticity | `Stage1ShoutProof.decode_handoff_openings` together with the accepted-opening path for `C_decode_handoff @ r_lookup`, plus the Stage-1 equalities from §9.2 tying those committed bits to the decode outputs |
| Stage-2 register closure | `Stage2TwistProof.reg_rw_batched_proof`, `reg_val_from_inc_proof`, `reg_session_registry`, `reg_session_closure_proof`, and `reg_addr_correctness_proofs` |
| Stage-2 RAM closure | `Stage2TwistProof.ram_rw_batched_proof`, `ram_val_from_inc_proof`, `ram_raf_read_proof`, `ram_raf_write_proof`, `ram_session_registry`, `ram_session_closure_proof`, and `ram_addr_correctness_proofs` |
| Stage-2 non-zero-init base case | The public `initial_state`, `KernelMetaPub.init_mode_id = authenticated_nonzero_init`, and the Stage-2 `Val`-from-`Inc` proofs interpreted with the modified non-zero-init identity from §6.8 |
| Stage-3 continuity and boundary checks | `Stage3Proof.shift_proof`, `padded_continuity_check`, `continuity_refinement`, and `continuity_proof`, together with the accepted-opening paths for the current-row, `j0_bits`, and `j_last_bits` direct openings consumed by those checks |
| Row binding for one exported row | The row's `RowBindingClaim` together with the accepted `C_lane @ j_bits` direct opening path named by that claim |
| Bridge binding for one exported row | `BridgeBinding_j`, with verifier-side recomputation that the authenticated row is exactly the row encoded by `PreparedStep_j` |
| Same-path row/bridge reuse | `RowProjectionWitness_j` and `BridgeBinding_j` must share one exact `AcceptedDirectOpening` for that row-binding claim |

Manifest-to-theorem coverage matrix for the `simple` boundary:

| Manifest item | Primary theorem owner(s) | Exact consumer on this boundary | Opening role | Bridge/root handoff |
| --- | --- | --- | --- | --- |
| `C_lane @ r_lookup` | `Stage1AuthenticatedBundle` | Stage-1 row/view and linkage scalars | accepted direct opening | no |
| `C_fetch_ra @ (r_fetch_addr, r_lookup)` | `Stage1AuthenticatedBundle` | `Stage1ShoutProof.fetch` | committed address-family opening used by checked Shout claims | no |
| `C_decode_ra @ (r_decode_addr, r_lookup)` | `Stage1AuthenticatedBundle` | `Stage1ShoutProof.decode` | committed address-family opening used by checked Shout claims | no |
| `C_alu_ra @ (r_alu_addr, r_lookup)` | `Stage1AuthenticatedBundle` | `Stage1ShoutProof.alu` | committed address-family opening used by checked Shout claims | no |
| `C_eq4_ra @ (r_eq4_addr, r_lookup)` | `Stage1AuthenticatedBundle` | `Stage1ShoutProof.eq4` | committed address-family opening used by checked Shout claims | no |
| `C_decode_handoff @ r_lookup` | `Stage1AuthenticatedBundle` | `Stage1ShoutProof.decode_handoff_openings` | accepted direct opening plus Stage-1 handoff equalities | no |
| `C_rom_table @ r_fetch_addr` | `Stage1AuthenticatedBundle` | `Stage1ChannelProof.table_opening_claims` for `fetch` | accepted committed public-table opening | no |
| `C_decode_table @ r_decode_addr` | `Stage1AuthenticatedBundle` | `Stage1ChannelProof.table_opening_claims` for `decode` | accepted committed public-table opening | no |
| `C_alu_table @ r_add8lo_addr` | `Stage1AuthenticatedBundle` | `Stage1ChannelProof.table_opening_claims` for `alu` | accepted committed public-table opening | no |
| `C_eq4_table @ r_eq4_addr` | `Stage1AuthenticatedBundle` | `Stage1ChannelProof.table_opening_claims` for `eq4` | accepted committed public-table opening | no |
| `C_lane @ r_twist_cycle` | `Stage2AuthenticatedBundle` | Stage-2 linkage scalars and lane-derived memory values | accepted direct opening | no |
| `C_decode_handoff @ r_twist_cycle` | `Stage2AuthenticatedBundle` | Stage-2 decode-handoff linkage | accepted direct opening | no |
| `C_reg @ (r_addr_reg, r_twist_cycle)` | `Stage2AuthenticatedBundle` | register read/write batching, `Val`-from-`Inc`, and address correctness | accepted committed Twist opening | no |
| `C_ram @ (r_addr_ram, r_twist_cycle)` | `Stage2AuthenticatedBundle` | RAM read/write batching, `Val`-from-`Inc`, RAF support, and address correctness | accepted committed Twist opening | no |
| `C_lane @ r_shift` | `Stage3AuthenticatedBundle` | lane-shift and padded continuity source opening | accepted direct opening | no |
| `C_lane @ j0_bits` | `Stage3AuthenticatedBundle` | start-boundary bundle | accepted direct opening | no |
| `C_lane @ j_last_bits` | `Stage3AuthenticatedBundle` | final-boundary bundle | accepted direct opening | no |
| `C_lane @ j_bits` for each exported row `j` | `RowBound`, `RowProjectionWitness_j`, `BridgeBinding_j`, root handoff | per-row semantic extraction and prepared-step binding | one shared `AcceptedDirectOpening` per exported row | yes, via `PreparedStep_j` |

### 9.5 Rust-facing kernel boundary

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

Normative Stage-1 table-auth mode for the `simple` kernel:

- the concrete mode identifier for this boundary is
  `table_auth_mode_id = committed_public_tables_v1`;

- `table_opening_claims` contains only commitment-backed public-table openings.
- for `fetch`, the table-auth surface is the exact `C_rom_table @ r_fetch_addr`
  opening;
- for `decode`, the table-auth surface is the exact
  `C_decode_table @ r_decode_addr` opening;
- for `alu`, the table-auth surface is the exact `C_alu_table @ r_add8lo_addr`
  opening whenever the current row uses that subtable;
- for `eq4`, the table-auth surface is the exact `C_eq4_table @ r_eq4_addr`
  opening whenever the current row uses that table;
- verifier-local helper evaluators such as identity or equality shims may still
  exist as explicit local helper objects, but they are not
  `table_opening_claims` and they do not replace the committed public tables.

```text
Stage2TwistProof {
    cycle_point: r_twist_cycle,
    reg_addr_point: r_addr_reg,
    ram_addr_point: r_addr_ram,
    gamma_reg,
    reg_rw_batched_proof,
    reg_val_from_inc_proof,
    reg_session_registry,
    reg_session_closure_proof,
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
    ram_session_registry,
    ram_session_closure_proof,
    ram_addr_correctness_proofs: {
        RamRa,
        RamWa,
    },
    gamma_twist_link,
    twist_linkage_proof,
}
```

Normative Stage-2 session schema:

```text
RegisterSessionKey = (cycle_index, reg_addr)
RamSessionKey      = (cycle_index, ram_addr)

TwistSessionEntry {
    key,
    read_claim_ref,
    write_claim_ref,
    val_claim_ref,
    addr_provenance_refs,
    raf_provenance_refs,     // RAM side only
    exported_role_refs,
}
```

where:

- `cycle_index` is the active semantic row index `j`;
- `reg_addr ∈ {0, ..., 17}` ranges over `V[0..15]`, the distinguished `I`
  slot at address `16`, and the sink slot `⊥_reg = 17`;
- `ram_addr ∈ {0, ..., 4096}` ranges over `RAM[0..4095]` together with the sink
  slot `⊥_ram = 4096`;
- one session key names one logical timeline cell `(j, addr)` on one
  authenticated Twist family, not one port occurrence and not a multiset of
  unrelated claims;
- if two Stage-2 roles touch the same logical cell on the same row, they must
  resolve to the same session key and therefore to the same registry entry.
- sink-routed register roles are therefore not exempt from register-session
  closure; they resolve through the same `RegisterSessionKey` space using
  `reg_addr = 17`, and the sink semantics from §6.1 force the carried
  read/write/`Val` consequence to remain the authenticated zero timeline.
- the theorem-facing formal owner for this concrete register-side key surface is
  `Chip8RegisterSessionBoundary`; later Stage-2 evidence and trace owners must
  import that exact keying discipline rather than restating the address range in
  free-form prose.

Normative Stage-2 session-closure rule:

- `reg_session_registry` enumerates the authenticated register-side Twist
  sessions consumed by this chunk as explicit
  `RegisterSessionKey -> TwistSessionEntry` bindings;
- `reg_session_closure_proof` proves that the register-side read/write/`Val`
  claims, address-correctness claims, and any row-local register semantic
  extraction all refer to that one closed authenticated registry, with totality
  and uniqueness by session key;
- `ram_session_registry` enumerates the authenticated RAM-side Twist sessions
  consumed by this chunk as explicit `RamSessionKey -> TwistSessionEntry`
  bindings;
- `ram_session_closure_proof` proves that the RAM-side read/write/`Val` claims,
  RAF support, address-correctness claims, and any row-local RAM semantic
  extraction all refer to that one closed authenticated registry, with totality
  and uniqueness by session key.
- totality means every Stage-2 read claim, write claim, `Val` claim,
  address-correctness consequence, RAF consequence, and row-local semantic
  extraction consumed later by the strong trace theorem resolves through some
  entry in the appropriate registry;
- uniqueness means each session key has exactly one entry, and that entry owns
  exactly one coherent read/write/`Val` triple for that logical cell;
- coherence means `readKey = writeKey = valKey = key(entry)` and the carried
  `readVal`, `writeVal`, and `valClaimVal` agree on one shared authenticated
  virtual value.

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
PaddedContinuityCheckProof {
    point: r_shift,
    beta1,
    beta2,
    pair_mask_eval,
    raw_current_row_opening_ref,
    raw_shift_proof_ref,
    excluded_tail_correction_bundle,
}
```

```text
ActivePrefixContinuityRefinement {
    padded_check_ref,
    corrected_current_row_ref,
    corrected_shift_values_ref,
    row_binding_ref,
}
```

```text
ContinuityProof {
    padded_check_ref,
    active_prefix_refinement_ref,
    start_boundary_opening_ref,
    final_boundary_opening_ref,
}
```

```text
Stage3Proof {
    shift_proof: LaneShiftProof,
    padded_continuity_check: PaddedContinuityCheckProof,
    continuity_refinement: ActivePrefixContinuityRefinement,
    continuity_proof: ContinuityProof,
    row_bindings: Vec<RowBindingClaim>,
}
```

Normative Stage-3 refinement rule:

- `PaddedContinuityCheckProof` owns the raw padded-domain current-row opening,
  the raw shifted values from `LaneShiftProof`, and the explicit excluded-tail
  correction bundle from §8.1b;
- `ActivePrefixContinuityRefinement` is the theorem-facing bridge from that
  padded-domain check to the refined active-prefix continuity relation;
- `row_binding_ref` inside `ActivePrefixContinuityRefinement` must reference the
  exact accepted `C_lane @ bits_le(stepIdx)` row-binding opening for the same
  semantic row whose current-row coordinates are identified by
  `corrected_current_row_ref`; it is not a free-form provenance label and it is
  not the last-active-row correction witness unless `stepIdx = N - 1`;
- the authenticated last-active-row data needed to remove the padded suffix
  lives in `excluded_tail_correction_bundle`, not in `row_binding_ref`;
- `ActivePrefixContinuityRefinement` is a post-transcript theorem/provenance
  object derived from already accepted openings and the padded check; it does
  not sample challenges and it does not add new manifest entries;
- the theorem-facing formal owner for this exact refinement object is
  `Chip8Stage3Refinement`; later evidence/trace owners must consume that typed
  refinement surface rather than silently collapsing the padded-domain check and
  the current-row accepted opening into one unnamed helper object;
- `ContinuityProof` is the active-prefix continuity object consumed later by the
  semantic `pc` bridge; it must refer to both the padded check and the
  refinement rather than silently identifying the raw padded-domain check with
  the theorem-facing relation.

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
    root_opening_manifest: RootOpeningManifest,
    exact_opening_artifacts,     // per-family exact opening witnesses for every kernel claim
    time_opening_summary,
    opening_refinement_summary,
    joint_opening_summary,       // future extension only; absent on the simple boundary
    joint_opening_fold_bucket_proofs, // future extension only; absent on the simple boundary
    row_projection_summary,
    bridge_binding_summary,
    semantic_evidence_summary,   // optional non-normative audit digest
}
```

On the simple boundary, `joint_opening_summary` and
`joint_opening_fold_bucket_proofs` must be omitted entirely. This accepted
boundary exports no claim-space summaries and no family-local fold carriers.

```text
KernelMetaPub {
    program_image_digest,
    initial_state_digest,
    rom_table_digest,
    decode_table_digest,
    alu_table_digest,
    eq4_table_digest,
    transcript_seed_digest,
    protocol_version_id,
    field_id,
    extension_field_id,
    root_params_id,
    variable_order_id,
    domain_shape_id,
    sink_convention_id,
    init_mode_id,
    lowering_convention_id,
    padding_convention_id,
    table_auth_mode_id,
    opening_reduction_mode_id,
    program_word_count,
    semantic_rows: N,
    padded_trace_length: T,
    pad_pc_word,
    program_base_addr,
    cycle_bits,
}
```

`KernelMetaPub` is the single canonical public-metadata object absorbed into
`root0` and reused by later verifier-side table/root reconstruction. Any
challenge-relevant public parameter not represented directly by one of these
fields must be a deterministic function of:

- `vm_spec`,
- the public program image,
- the public initial state,
- and the protocol version already fixed by the surrounding proof system.

No later stage may rely on hidden prover-side public metadata that is outside
this boundary.

Version-gating rule:

- `KernelMetaPub` is closed for this simple kernel version;
- any later relation-shaping parameter that is not already a deterministic
  function of the existing public boundary must be added to `KernelMetaPub` and
  therefore to `root0` under a new protocol-version identifier before that
  later version is conforming.

Normative relation-shaping mode identifiers for this `simple` boundary:

| Field | Allowed value on this boundary | Exact meaning |
| --- | --- | --- |
| `init_mode_id` | `authenticated_nonzero_init` | Stage-2 `Val` chains use authenticated initial register/RAM surfaces directly, as specified in §6.8 |
| `lowering_convention_id` | `chip8_microstep_pre_post_v1` | the exact row-granular lowering and same-row visibility discipline from §3.4, including separate register/RAM timelines and `Fx55/Fx65` burst decomposition |
| `table_auth_mode_id` | `committed_public_tables_v1` | fetch/decode/ALU/Eq4 table authentication is carried by the exact committed public-table openings listed under the Stage-1 table-auth rule; verifier-local evaluators are cross-checks only |
| `opening_reduction_mode_id` | `no_post_transcript_reduction_v1` | the simple boundary exports no claim-space reduction summaries and no family-local fold carriers |

These mode identifiers are not free-form debug labels. Under the current
`protocol_version_id`, any other value is non-conforming.

Canonical `meta_pub` absorption rule:

- the simple kernel does not hash an implementation-defined serialized Rust
  struct into `root0`;
- instead, `meta_pub` is absorbed by one exact labeled transcript sequence:

```text
append_u64s("chip8/root0/version", [protocol_version_id])
append_u64s("chip8/root0/field_id", [field_id])
append_u64s("chip8/root0/extension_field_id", [extension_field_id])
append_message("chip8/root0/program_image_digest", program_image_digest)
append_message("chip8/root0/initial_state_digest", initial_state_digest)
append_message("chip8/root0/rom_table_digest", rom_table_digest)
append_message("chip8/root0/decode_table_digest", decode_table_digest)
append_message("chip8/root0/alu_table_digest", alu_table_digest)
append_message("chip8/root0/eq4_table_digest", eq4_table_digest)
append_message("chip8/root0/transcript_seed_digest", transcript_seed_digest)
append_message("chip8/root0/root_params_id", root_params_id)
append_u64s(
  "chip8/root0/meta_pub",
  [
    variable_order_id,
    domain_shape_id,
    sink_convention_id,
    init_mode_id,
    lowering_convention_id,
    padding_convention_id,
    table_auth_mode_id,
    opening_reduction_mode_id,
    program_word_count,
    semantic_rows,
    padded_trace_length,
    pad_pc_word,
    program_base_addr,
    cycle_bits,
  ],
)
```

- each `append_message` call uses the transcript's canonical byte absorption for
  that byte string;
- each `append_u64s` call uses the transcript's canonical `u64` absorption in
  the order shown above;
- any prover or verifier that absorbs `KernelMetaPub` with a different field
  order, label sequence, or packed representation is non-conforming even if the
  logical field values agree.

```text
RowBindingClaim {
    row_index,
    row_point_bits,
    opened_lane_values,
    opening_claim_ref,
}
```

`RowBindingClaim` is intentionally pure row-binding metadata. Any prepared-step
material belongs to `BridgeBinding_j`, not to the row-binding claim itself.

```text
SimpleKernelOutput {
    prepared_steps: Vec<PreparedStep>,
    public_steps: Vec<PreparedStepInstance>,
    kernel_opening_manifest: KernelOpeningManifest,
    root_opening_manifest: RootOpeningManifest,
    joint_opening_fold_bucket_proofs, // future extension only; absent on the simple boundary
    row_projection_summary,
    bridge_binding_summary,
    semantic_evidence_summary,   // optional non-normative audit digest
}
```

`SimpleKernelProof` is the proof-side accepted-opening surface. It carries
`exact_opening_artifacts`, `time_opening_summary`,
`opening_refinement_summary`, and, on future non-simple boundaries, any
claim-space reduction summaries. `SimpleKernelOutput` is the bridge / audit
export surface. It does not duplicate the proof-side accepted-opening artifacts.

Normative boundary rules:

- `SimpleKernelProof` does not contain a duplicate root main-lane CCS proof.
- `KernelMetaPub.semantic_rows = N` and
  `KernelMetaPub.padded_trace_length = T = 2^{cycle_bits}`.
- `SimpleKernelOutput.prepared_steps` is the only bridge payload consumed by the
  root prover.
- `prepared_steps.len() = public_steps.len() = N`; these vectors contain exactly
  the semantic rows `j ∈ [0, N)` and never include padded rows.
- `kernel_opening_manifest` contains only kernel-owned openings against the
  commitments fixed in `root0`.
- `root_opening_manifest` contains only root-owned openings created after bridge
  extraction; it must be disjoint from `kernel_opening_manifest`.
  On the simple-kernel boundary it must be empty.
- `SimpleKernelProof.exact_opening_artifacts` must be sufficient to authenticate
  every direct kernel opening claim in `kernel_opening_manifest`.
- `SimpleKernelProof.opening_refinement_summary`, and, on any future non-simple
  boundary, `SimpleKernelProof.joint_opening_summary`,
  any materialized `joint_opening_fold_bucket_proofs` export surface,
  `SimpleKernelOutput.row_projection_summary`,
  `SimpleKernelOutput.bridge_binding_summary`, and
  `SimpleKernelOutput.semantic_evidence_summary` are audit/provenance objects
  only; none of them introduces a new commitment family or replaces the
  lower-layer exact opening requirement.
- on the simple boundary, `SimpleKernelProof.joint_opening_summary` and
  any materialized `joint_opening_fold_bucket_proofs` export surface must be
  absent.
- `row_projection_summary` and `bridge_binding_summary` are canonical ordered
  summary trees over the exact per-row `RowProjectionWitness_j` and
  `BridgeBinding_j` leaves for `j ∈ [0, N)`, with verifier-accessible row-index
  mapping.
- `semantic_evidence_summary` is an optional non-normative audit digest over the
  already-owned theorem-facing semantic surfaces. It may summarize the Stage-2
  temporal seeds, the chunk-global temporal support package, and the Stage-3
  `pc` support path, but the strong theorem from §4.3a must never depend on this
  digest as if it were a standalone proof object.
- the exact kernel boundary above must be sufficient, together with the public
  chunk input from §9.5, to recover the accepted-kernel theorem package and the
  strong execution conclusion of §4.3a without any extra external temporal-
  support premise.

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
  prover for that row, defined here as follows:
  1. let `m = 24`;
  2. let `cols = ceil(m / D)`;
  3. form the canonical padded witness vector
     `z_pad = [z_j[0], z_j[1], ..., z_j[23], 0, ..., 0] ∈ F^{cols * D}`,
     where padding zeros are appended only at the tail until the length is
     exactly `cols * D`;
  4. reshape `z_pad` into a `D × cols` matrix by columns:
     the entry at row `r ∈ [0, D)` and column `c ∈ [0, cols)` is
     `z_pad[c * D + r]`;
  5. apply the canonical Ajtai witness encoding induced by the public
     `root_params` to that `D × cols` matrix to obtain `Z_j`.
- Equivalently, `Z_j ∈ F^{D × ceil(24 / D)}` with the column-major placement of
  the padded semantic row fixed exactly by the previous rule.
- Any implementation helper such as `encode_vector_for_ccs_m(root_params, 24, z_j)`
  is conforming only if it implements exactly this algorithm.
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

6. Close the kernel transcript:
   - emit `KernelOpeningManifest` and the empty `RootOpeningManifest`
   - this manifest emission is the final transcript event of the `simple`
     kernel schedule

7. Post-transcript opening verification and reduction artifacts:
   - verify one exact family opening witness for every direct manifest claim in
     canonical order
   - materialize one `OpeningRefinement` for every accepted direct claim / exact
     opening pair
   - if a future non-simple format re-enables claim-space reduction artifacts,
     derive the canonical `time_opening` groups by
     `(source, domain, point)`,
     keeping canonical manifest ordinals only as the deterministic ordering key
     of claims inside each group
   - any such reduction artifacts remain post-transcript
     provenance/summarization carriers only; they do not by themselves
     authorize any witness-space fold lane

8. Emit kernel proof/output artifacts.
   Hand off PreparedSteps + accepted kernel opening artifacts to root prover.
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

Auditor-facing prerequisite table:

- `r_lookup`
  - must already be bound: the actual `root0` commitment digests/encodings in
    the canonical inventory order, and then the exact labeled `meta_pub`
    absorb sequence
  - must not yet depend on: any Stage-1 sumcheck transcript, terminal point, or
    later-stage event
- `γ_lookup_link`
  - must already be bound: `r_lookup`, all Stage-1 Shout transcript events, and
    the recorded Stage-1 terminal points
  - must not yet depend on: any Stage-2 or Stage-3 event
- `r_twist_cycle`
  - must already be bound: the complete Stage-1 transcript including
    `γ_lookup_link`
  - must not yet depend on: any Stage-2 terminal point or later-stage event
- `γ_reg`, `γ_ram`, `γ_twist_link`
  - must already be bound: `r_twist_cycle` and the preceding Stage-2 transcript
    events in exact local order
  - must not yet depend on: any Stage-3 event
- `β1`, `β2`, `r_shift`
  - must already be bound: the complete Stage-1 and Stage-2 transcripts
  - must not yet depend on: any Stage-3 row-binding or later post-transcript
    reduction artifact
- claim-local mixers, group-local mixers, and unification mixers
  - if a future non-simple format materializes them, they belong to dedicated
    post-transcript reduction domains and are not events in the kernel
    transcript schedule from this section
  - must not reuse: `r_lookup`, any Stage-1 address point, `γ_lookup_link`,
    `r_twist_cycle`, `r_addr_reg`, `r_addr_ram`, `γ_reg`, `γ_ram`,
    `γ_twist_link`, `β1`, `β2`, or `r_shift`

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
4. Check `PreparedStep_j.witness.Z = Z_j`.
5. Recompute `c_j = Ajtai_commit(Z_j)`.
6. Check `c_j = PreparedStep_j.mcs.c`.
7. Check `PreparedStep_j.witness.w = w_j`.
8. Check `PreparedStep_j.mcs.x = [F::ONE]` and `PreparedStep_j.mcs.m_in = 1`.

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

Verifier-cost note:

- this v1 bridge is intentionally linear in the number of exported semantic
  rows;
- any later recursive wrapper, folded bridge, or succinct outer proof that
  amortizes those row-by-row checks is outside the simple-kernel theorem
  surface and must be introduced explicitly by a later owner.

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
13. Strong kernel soundness additionally requires the theorem-level adjacent
    machine-state link `PostState(j) = PreState(j+1)` for every semantic
    `j < N-1`. That link must be discharged compositionally from:
    - one shared `Stage2TemporalContext`,
    - one exact `PcAdjacentBridge`,
    - and the row-local semantic binding of those authenticated values to
      `PreState` / `PostState`.
    Control-lane continuity alone, or row-local Stage-2 seeds alone, are not
    accepted as sufficient trace theorems under this spec.
14. The exact lower-layer kernel boundary for one chunk must determine the same
    accepted-kernel theorem package used for auditing. A conforming
    implementation may expose that accepted package as a named verifier
    boundary, but it may not require an additional theorem-facing temporal-
    support witness that is outside the exact boundary data already fixed by
    the chunk input, exact openings/refinements, and transcript schedule.
