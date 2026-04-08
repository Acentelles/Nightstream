# RV64IM Kernel Specification

## Scope

Normative spec for the RV64IM proving kernel. Design principles:

1. obligations match `docs/soundness-specs/twist-and-shout-requirements.md`,
2. opcode proof obligations are allocated to the correct proving layer,
3. Shout/Twist soundness assumptions are discharged directly,
4. only row-local constraints are projected to the SuperNeo main lane; non-local
   obligations live in explicit auxiliary protocols,
5. uses a 3-stage architecture (Shout + Twist + Continuity/Bridge) with
   VM-specific semantics above a shared generic SuperNeo backend.

Field: Goldilocks, `F = 2^64 - 2^32 + 1`.
Extension field: `K = F_{q^2}`.

### 0.0 SuperNeo backend contract

This kernel sits above one concrete SuperNeo-style backend. The backend contract
is theorem-facing and is not an implementation detail.

Base parameters:

```text
q   = 2^64 - 2^32 + 1
F   = F_q
K   = F_{q^2}
η   = 81
Φη  = X^54 + X^27 + 1
d   = deg(Φη) = 54
R_F = F[X]/(Φη)
```

Norm and folding parameters are the public root-context parameters:

```text
(q, η, d, κ, m, b, k_rho, B, T, s, λ)
```

with:

```text
B = b^{k_rho}
s = 2
```

and the Π_RLC norm-growth guard:

```text
count · T · (b - 1) < b^{k_rho} = B,
```

where `count` is the number of CE claims combined in that Π_RLC invocation.

The root main-lane theorem uses the paper reduction stack:

```text
Π_SuperNeo := Π_DEC ∘ Π_RLC ∘ Π_CCS.
```

Chunk-local role split:

```text
Π_CCS : CCS(b, L)^K × CE(b, L)^k -> CE(b, L)^{K+k}
Π_RLC : CE(b, L)^{K+k} -> CE(B, L)
Π_DEC : CE(B, L) -> CE(b, L)^{k_rho}
```

where:

- the fresh semantic rows authenticated from the root lane instantiate the
  chunk’s fresh `CCS` claims,
- the carried main claims from the previous chunk instantiate the incoming `CE`
  claims,
- and `Π_DEC` restores the carried norm bound from `B` back to the base bound
  `b`.

The Π_RLC challenge domain is not an arbitrary field-scalar domain. A
conforming implementation must sample typed ring-scalar challenges

```text
ρ_i = rot(a_i) ∈ 𝒞 ⊂ R_F
```

from a strong sampling set `𝒞` fixed by the backend cyclotomic ring and small
coefficient alphabet. For the current Goldilocks backend:

```text
𝒞 = { rot(a) : a ∈ {-2,-1,0,1,2}^d }.
```

The root theorem package, root context id, and all theorem-facing verification
of root main-lane packages are bound to this backend contract. Replacing it with
arbitrary field-scalar RLC challenges, a different cyclotomic ring, or a
different extension field is non-conforming unless the public root context and
all theorem statements are updated accordingly.

### 0.1 Limb representation

Goldilocks `p = 2^64 - 2^32 + 1`. Since `p < 2^64`, not all 64-bit unsigned
values are uniquely representable as single field elements: values in
`[p, 2^64 - 1]` alias with small field elements in `[0, 2^32 - 2]`.

RV64IM register and memory values span the full `[0, 2^64)` range. This kernel
therefore represents every 64-bit machine value `V` as a **(lo32, hi32) limb
pair**:

```text
V_LO = V mod 2^32          ∈ [0, 2^32 - 1]
V_HI = floor(V / 2^32)     ∈ [0, 2^32 - 1]
```

Both limbs fit uniquely in Goldilocks with wide margin. Every column in the main
lane that carries a 64-bit value is stored as two adjacent columns `*_LO` and
`*_HI`.

Normative range obligation: every limb column must be proved to lie in
`[0, 2^32 - 1]`. This is discharged by byte decomposition during ALU/address
verification in Stage 1.

### 0.2 Target ISA subset

This v1 spec targets **RV64IM** (base 64-bit integer + standard multiply/divide
extension). It does **not** cover:

- Compressed instructions (C extension),
- Atomic instructions (A extension),
- Floating-point instructions (F/D extensions),
- Privileged instructions beyond ECALL,
- CSR instructions beyond the minimal set needed for termination.

All instructions are fixed 32-bit width. PC increments by 4 on non-branch/jump
rows.

This v1 kernel models only **aligned, non-trapping execution**:

- every executed instruction address is 4-byte aligned,
- every taken jump/branch target is 4-byte aligned,
- every data access is naturally aligned to its access width.

Instruction-address-misaligned and load/store-address-misaligned traps are out
of scope. A row that violates the required alignment is rejected rather than
modeled as a trap.

### 0.3 Supported instructions

**RV64I base:**

| Class | Instructions |
|-------|-------------|
| R-type arithmetic | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| I-type arithmetic | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU |
| RV64 W-variants | ADDW, SUBW, ADDIW, SLLW, SRLW, SRAW, SLLIW, SRLIW, SRAIW |
| Upper immediate | LUI, AUIPC |
| Loads | LB, LBU, LH, LHU, LW, LWU, LD |
| Stores | SB, SH, SW, SD |
| Branches | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| Jumps | JAL, JALR |
| System | ECALL, FENCE (treated as NOP) |

**RV64M multiply/divide:**

| Class | Instructions |
|-------|-------------|
| Multiply | MUL, MULH, MULHSU, MULHU |
| Divide | DIV, DIVU, REM, REMU |
| W-variants | MULW, DIVW, DIVUW, REMW, REMUW |

---

## 1. Commitment Bundle

The kernel commits the following objects before any stage-specific challenge is
sampled:

- `C_lane`: the `W - 1` non-fixed main-lane column MLEs for the padded semantic
  lane `M_lane ∈ F^{T × W}`, where rows `j ∈ [0, N)` are semantic and rows
  `j ∈ [N, T)` are the public pad rows from §3.2; the `ONE` coordinate is fixed
  separately as `1`.
- `C_bytecode_ra`: the Stage-1 expanded-bytecode one-hot address family over
  `BytecodeAddr × Cycle`.
- `C_alu_ra`: the Stage-1 ALU one-hot address family over
  `AluSlot × AluKey × Cycle`. It is one shared committed family whose canonical
  subchannel manifest and per-slot packing are fixed in §5.3.5a and §13.5.
- `C_branch_ra`: the Stage-1 branch-condition one-hot address family over
  `BranchSlot × BranchKey × Cycle`, with canonical per-slot packing fixed in
  §5.3.5a and §13.6.
- `C_decode_handoff`: the per-cycle Stage-1-to-Stage-2 decode-handoff surface.
- `C_reg`: the register-file Twist witness family over `Addr_reg × Cycle`.
- `C_ram`: the RAM Twist witness bundle. It contains cycle-only RAM increment
  limbs together with a chunked committed RAM-address family whose tensor
  product defines the virtual merged RAM address family consumed by Stage 2.
- `C_rom_table`: the committed program ROM table.
- `C_bytecode_table`: the committed per-program **expanded bytecode** table
  keyed by `BytecodeAddr`. Each row is one lowered virtual instruction. It
  binds the current expanded row to its originating architectural instruction
  (`instruction_word_arch`, `unexpanded_pc`), the row-local virtual opcode and
  operands, sequence-boundary flags, and the Stage-2 handoff metadata.
  `C_bytecode_table` is the canonical execution object used by Stage 1, not a
  padded descriptor attached to one architectural row.
- `C_alu_subtables`: committed byte-level ALU subtables (ADD8, AND8, OR8, XOR8,
  MUL8, LT8, EQ8, SHL8, SHR8, SIGNEXT8) plus compressed wide support relations
  such as `VALID_DIV0`, `VALID_UNSIGNED_REMAINDER`, `MULU_NO_OVERFLOW`, and
  `CHANGE_DIVISOR` — see §5.3.1 for full definitions.
- `C_branch_table`: the committed branch-condition evaluation table.
- `meta_pub`: challenge-relevant public metadata (see §9.5).

The transcript root is:

```text
root0 = H(
    C_lane,
    C_bytecode_ra,
    C_alu_ra,
    C_branch_ra,
    C_decode_handoff,
    C_reg,
    C_ram,
    C_rom_table,
    C_bytecode_table,
    C_alu_subtables,
    C_branch_table,
    meta_pub
)
```

All later challenges are sampled only after `root0` is fixed.

### 1.1 Two commitment layers

Kernel opening commitments and root main-lane Ajtai commitments are distinct and
meet only at the bridge.

- Kernel opening commitments: `C_lane`, `C_bytecode_ra`,
  `C_alu_ra`, `C_branch_ra`, `C_decode_handoff`, `C_reg`, `C_ram`,
  `C_rom_table`, `C_bytecode_table`, `C_alu_subtables`, `C_branch_table`.
- Root main-lane commitments: `PreparedStep_j.mcs.c = Ajtai_commit(Z_j)`.

Any implementation that conflates kernel opening commitments with root Ajtai
commitments is non-conforming.

### 1.2 Fixed hypercube domains

Named arities:

```text
ADDR_REG_BITS  = 7      // 128-point register-address hypercube
ADDR_RAM_BITS  = parameterized (default 21, i.e., 2M doubleword slots ≈ 16 MiB)
ROM_ADDR_BITS  = parameterized (program size dependent)
BYTECODE_ADDR_BITS = parameterized (lowered program size dependent)
INSTR_BITS     = 32     // instruction word width
CYCLE_BITS     = ceil_log2(N)
T              = 2^{CYCLE_BITS}
RAM_ADDR_D     = parameterized public chunk count for the RAM address family
RAM_CHUNK_BITS[i] = parameterized public RAM chunk widths with
                    Σ_i RAM_CHUNK_BITS[i] = ADDR_RAM_BITS
```

Normative domain rules:

- `Addr_reg` uses the full 7-bit hypercube:
  - active slots `0..31` = architectural registers `x0..x31`,
  - slots `32..39` = persistent virtual registers reserved for future
    architectural state extensions and sequence-local reserved state,
  - slots `40..47` = temporary virtual registers used by lowered instruction
    sequences,
  - slots `48..126` = additional virtual-register space reserved for future
    inline or VM-specific lowering patterns,
  - slot `127` = `⊥_reg` (sink for no-write rows and discarded x0 writes).
- `Addr_ram` uses the full `ADDR_RAM_BITS`-bit hypercube:
  - active slots `0..2^ADDR_RAM_BITS - 1` = addressable RAM doublewords,
  - the verifier maps physical byte addresses to RAM slots via the public
    decomposition
    `MEM_ADDR - RAM_BASE = 8 * ram_word_addr + ram_byte_off`.
- `ROMAddr` uses a `ROM_ADDR_BITS`-bit hypercube of instruction-word addresses.
  Each ROM slot holds one 32-bit instruction word.
- `BytecodeAddr` uses a `BYTECODE_ADDR_BITS`-bit hypercube of **expanded**
  bytecode rows produced after virtual-sequence lowering. Each row holds one
  lowered virtual instruction plus metadata for the architectural instruction it
  originated from.

Normative address model:

- `PC` is the **architectural** byte address (`unexpanded_pc`) of the owning
  architectural instruction. It may remain constant across several adjacent
  lowered rows that belong to the same virtual sequence.
- The active expanded bytecode row is selected by `C_bytecode_ra` over
  `BytecodeAddr × Cycle`. The expanded program counter is not a main-lane
  column; it is authenticated through the bytecode Shout instance and its
  folded `raf` claims.
- Since the C extension is out of scope, every semantic `PC` and every taken
  `JUMP_TARGET` must satisfy `addr[1:0] = 0`.
- Memory addresses are absolute byte addresses. Stage 2 derives
  `ram_word_addr` and `ram_byte_off` from `MEM_ADDR - RAM_BASE`, and alignment
  obligations are parameterized by `mem_width`.

Normative ROM-table layout:

- The ROM table is the program image stored as 32-bit instruction words.
- The loaded ELF program occupies `[0, program_word_count)`.
- The public pad address `pad_pc_word` stores a self-loop instruction
  `JAL x0, 0` (jump-to-self with no link write).
- All other unused ROM slots are zero (illegal instruction, trapped by
  `valid = 0` in preprocessing).
- `C_bytecode_table` uses the `BytecodeAddr` domain. Its rows are produced by
  a deterministic lowering pass from `C_rom_table`. Every expanded row stores:
  - `instruction_word_arch`: the originating 32-bit architectural instruction,
  - `unexpanded_pc`: the architectural byte address of that instruction,
  - `virtual_opcode`: the lowered virtual instruction executed on this row,
  - `is_virtual_instruction`, `is_first_in_sequence`, `is_last_in_sequence`,
  - register-address selectors, immediates, write/load/store/control-flow flags,
  - Stage-2 handoff fields.
- Conforming preprocessing must be deterministic from `(public_program_image,
  lowering_version_id)`.
- Conforming verification must bind the public program image to the committed
  tables themselves, not merely to public digests.
- For `C_rom_table`, the verifier must either:
  - recompute the table evaluator directly from the public ROM image at every
    queried point, or
  - recompute the exact committed object `C_rom_table` from the public ROM
    image and check equality with the absorbed commitment.
- For `C_bytecode_table`, the verifier must either:
  - recompute the lowered expanded-bytecode table evaluator directly from the
    public ROM image and declared `lowering_version_id` at every queried point,
    or
  - recompute the exact committed object `C_bytecode_table` from that same
    public lowering and check equality with the absorbed commitment.
- `rom_table_digest` and `bytecode_table_digest` inside `meta_pub` are public
  metadata only in this kernel version. They are not soundness-carrying binding
  objects and may not substitute for direct table evaluation or commitment
  recomputation.

---

## 2. Soundness Boundary Against Twist-and-Shout

### 2.1 Booleanity is **not** discharged by Ajtai norm bounds

Ajtai binding or small-norm witness bounds do **not** prove that one-hot entries
lie in `{0,1}`. Booleanity remains an explicit proof obligation unless some
separate gadget proves bitness.

### 2.1b Field-specific shortcut

The `2^{-1}` shortcut for the Hamming-weight-1 check is valid over Goldilocks
(characteristic ≠ 2). If this kernel were instantiated over a characteristic-2
field, the direct sumcheck must be used instead.

### 2.2 Multiple lookup channels and multiple read ports

Stage 1 has at least:

- expanded-bytecode fetch: `expanded_pc → lowered bytecode row`,
- bytecode metadata authentication: lowered row → operands, flags,
  `instruction_word_arch`, `unexpanded_pc`, sequence-boundary metadata,
- ALU: byte-decomposed computation verification,
- branch condition: `(op, rs1_bytes, rs2_bytes) → branch_taken`.

Stage 2 has two register read ports (rs1, rs2) and one conditional write port
(rd). In the expanded-bytecode model these ports range over the full virtual
register domain, not just architectural `x0..x31`.

### 2.3 Virtual-polynomial discipline

The following objects may be virtual only through checked reductions from
committed/authenticated sources:

- `instruction_word`,
- decoded fields,
- `alu_lhs`, `alu_rhs`, byte decompositions thereof,
- RAM addresses,
- Stage-1 flattened address polynomials,
- Stage-2 address polynomials,
- Twist `Val` evaluation claims.

The verifier must never accept a direct prover-supplied evaluation of those
objects as a soundness-carrying claim.

### 2.4 Authentic table evaluations

A table MLE must either:

- be verifier-computable at random points in `O(log K)` time, or
- come from a separately authenticated source under the relevant table
  commitment.

Normative rule for this kernel:

- In this v1 kernel, the ROM table, per-program expanded bytecode table, ALU
  subtables, and branch-condition table are all committed and absorbed into
  `root0` as one uniform-authentication choice.
- This is a kernel-version simplification, not a theorem of Twist/Shout.
- A future conforming kernel version may authenticate a read-only table by a
  direct verifier-computable evaluator instead of a commitment, but only if the
  exact public table object remains fixed in the theorem package and the
  resulting opening boundary is updated accordingly.
- Direct verifier-computable evaluators may be used as cross-checks in v1 but do
  not make commitments optional under this version of the spec.

---

## 3. Main Lane

### 3.1 Main-lane witness layout

The main lane uses a `W = 38` coordinate layout. Every 64-bit machine value is
stored as a `(LO, HI)` limb pair per §0.1. Each semantic row is one **expanded
bytecode row** after lowering, not one architectural RV64IM instruction.
`PC_*` denotes the architectural (`unexpanded`) PC of the owning instruction,
which may stay constant across multiple adjacent rows inside one lowered
sequence.

| Col | Name | Meaning |
|-----|------|---------|
| 0 | ONE | Constant `1` |
| 1 | PC_LO | Low 32 bits of byte-addressed PC before row |
| 2 | PC_HI | High 32 bits of PC before row |
| 3 | PC_NEXT_LO | Low 32 bits of PC after row |
| 4 | PC_NEXT_HI | High 32 bits of PC after row |
| 5 | RS1_LO | Value at source register 1, low 32 bits |
| 6 | RS1_HI | Value at source register 1, high 32 bits |
| 7 | RS2_LO | Value at source register 2, low 32 bits |
| 8 | RS2_HI | Value at source register 2, high 32 bits |
| 9 | RD_NEXT_LO | Next value for destination register, low 32 bits |
| 10 | RD_NEXT_HI | Next value for destination register, high 32 bits |
| 11 | IMM_LO | Decoded sign-extended immediate, low 32 bits |
| 12 | IMM_HI | Decoded sign-extended immediate, high 32 bits |
| 13 | ALU_OUT_LO | ALU/computation result, low 32 bits |
| 14 | ALU_OUT_HI | ALU/computation result, high 32 bits |
| 15 | STEP_PC_LO | PC + 4, low 32 bits |
| 16 | STEP_PC_HI | PC + 4, high 32 bits |
| 17 | JUMP_TARGET_LO | Jump/branch target address, low 32 bits |
| 18 | JUMP_TARGET_HI | Jump/branch target address, high 32 bits |
| 19 | MEM_ADDR_LO | Memory address, low 32 bits |
| 20 | MEM_ADDR_HI | Memory address, high 32 bits |
| 21 | MEM_VAL_LO | Memory transfer value, low 32 bits |
| 22 | MEM_VAL_HI | Memory transfer value, high 32 bits |
| 23 | RD_IDX | Destination register address in `Addr_reg` |
| 24 | RS1_IDX | Source register 1 address in `Addr_reg` |
| 25 | RS2_IDX | Source register 2 address in `Addr_reg` |
| 26 | WritesAluToRd | Boolean: rd receives ALU_OUT |
| 27 | WritesMemToRd | Boolean: rd receives MEM_VAL (loads) |
| 28 | PreservesRd | Boolean: no rd write (stores, branches, fence, ecall) |
| 29 | IsJal | Boolean |
| 30 | IsJalr | Boolean |
| 31 | IsBranch | Boolean |
| 32 | BranchTaken | Boolean: 1 if branch condition true, 0 otherwise |
| 33 | BranchTakenMux | Boolean: `IsBranch · BranchTaken` |
| 34 | IsLoad | Boolean |
| 35 | IsStore | Boolean |
| 36 | UsesRs2 | Boolean: does instruction read rs2? |
| 37 | AdvanceArchPc | Boolean: 1 iff this row advances architectural control flow |

`W = 38`.

`ONE` is a semantic coordinate of every row, but it is not committed under
`C_lane`. The kernel and the root prover both treat it as the verifier-known
constant `1`.

Normative row meaning:

- The row opcode is the `virtual_opcode` authenticated from `C_bytecode_table`.
- `ALU_OUT` carries the primary result of that lowered virtual instruction.
- `RD_IDX`, `RS1_IDX`, and `RS2_IDX` range over the full register domain,
  including virtual registers.
- Every lowered sequence has one unique **effect row** whose row-local result
  and authenticated write/RAM action realizes the architectural opcode meaning.
- Rows strictly before the **commit row** of their lowered sequence must satisfy
  `PC_NEXT = PC` with `AdvanceArchPc = 0`.
- Every lowered sequence has one unique **commit row** at or after the effect
  row. Only the commit row may set `AdvanceArchPc = 1`, in which case
  `PC_NEXT` advances to the architectural fallthrough address or control-flow
  target.
- Architectural writes are a subset of register writes: the effect row may
  target an architectural `rd` or perform the architectural RAM action, while
  non-effect rows may target only virtual registers.
- If the commit row strictly follows the effect row, the intervening
  **closure-suffix rows** may touch only scratch virtual registers, may not
  introduce any additional architectural or RAM effect, and must be justified
  by a lowering-refinement theorem package.

Normative JUMP_TARGET meaning:

| Lowered row class | JUMP_TARGET meaning |
|-------------------|---------------------|
| sequence-final JAL row | `PC + IMM` |
| sequence-final JALR row | `(RS1 + IMM) & ~1` |
| sequence-final branch row | `PC + IMM` |
| all other rows | `0` |

Stage 1 proves JUMP_TARGET correctness. The main lane R1CS only routes
JUMP_TARGET to PC_NEXT.

Normative taken-target alignment rule:

- On every row with `IsJal + IsJalr + BranchTakenMux = 1`, Stage 1 must also
  prove `Align(4, JUMP_TARGET) = 1`.
- For `JAL` and taken branch rows, this is discharged on `PC + IMM`.
- For `JALR`, Stage 1 first proves `JUMP_TARGET = (RS1 + IMM) & ~1`, then
  separately proves bit 1 is zero so that the final routed target satisfies
  `JUMP_TARGET[1:0] = 0`. Clearing bit 0 alone is not sufficient.

Normative STEP_PC meaning:

`STEP_PC = PC + 4` is the architectural fallthrough address of the owning
instruction. It is constant across all rows in the same lowered sequence. Stage
1 proves correctness by authenticating `PC` from `C_bytecode_table` and
deriving `STEP_PC`.

### 3.2 Public pad-row rule

The padded trace length is `T = 2^{CYCLE_BITS}`. For every padded row
`j ∈ [N, T)`, the kernel uses the public inert row:

```text
ONE             = 1
PC_LO           = pad_pc_lo
PC_HI           = pad_pc_hi
PC_NEXT_LO      = pad_pc_lo
PC_NEXT_HI      = pad_pc_hi
RS1_LO          = 0
RS1_HI          = 0
RS2_LO          = 0
RS2_HI          = 0
RD_NEXT_LO      = 0
RD_NEXT_HI      = 0
IMM_LO          = 0
IMM_HI          = 0
ALU_OUT_LO      = pad_step_pc_lo       // = pad_pc + 4
ALU_OUT_HI      = pad_step_pc_hi
STEP_PC_LO      = pad_step_pc_lo
STEP_PC_HI      = pad_step_pc_hi
JUMP_TARGET_LO  = pad_pc_lo
JUMP_TARGET_HI  = pad_pc_hi
MEM_ADDR_LO     = 0
MEM_ADDR_HI     = 0
MEM_VAL_LO      = 0
MEM_VAL_HI      = 0
RD_IDX          = 0
RS1_IDX         = 0
RS2_IDX         = 0
WritesAluToRd   = 0
WritesMemToRd   = 0
PreservesRd     = 1
IsJal           = 1
IsJalr          = 0
IsBranch        = 0
BranchTaken     = 0
BranchTakenMux  = 0
IsLoad          = 0
IsStore         = 0
UsesRs2         = 0
AdvanceArchPc   = 1
```

The pad instruction is `JAL x0, 0` (self-loop with link to x0, which is
discarded). `IsJal = 1` and `PreservesRd = 1` because `RD_IDX = 0` triggers x0
sink routing (rd write discarded).

Note: `IsJal = 1` selects `PC_NEXT = JUMP_TARGET = pad_pc`, producing a
self-loop. `PreservesRd = 1` means no register write. This satisfies the R1CS
partition `WritesAluToRd + WritesMemToRd + PreservesRd = 1`.

Wait — `IsJal = 1` would normally mean `WritesAluToRd = 1` for the link address.
For the pad row with `RD_IDX = 0`, the decode outputs `PreservesRd = 1`
(overriding the normal JAL rd-write because x0 writes are discarded). This is a
normative decode-level convention: when `rd = x0`, the expanded bytecode row
outputs `PreservesRd = 1` regardless of instruction class.

### 3.3 Register x0 semantics

RISC-V `x0` is hardwired to zero: reads return 0, writes are discarded.

In this kernel:

- `RegValLo(0, j) = RegValHi(0, j) = 0` for all `j` (initial value 0, never
  modified).
- When an instruction writes to `rd = x0`: the expanded bytecode row sets
  `PreservesRd = 1` and `RD_NEXT = 0`. The register Twist routes writes to
  `⊥_reg` (sink slot 127) with `RegIncLo = RegIncHi = 0`.
- When an instruction reads `rs1 = x0` or `rs2 = x0`: `RS1 = 0` or `RS2 = 0`
  (authenticated by Stage 2 via `RegValLo(0, j) = RegValHi(0, j) = 0`).

This avoids special-casing x0 in the main lane R1CS: the expanded bytecode row handles
the x0 convention, and the Twist sink handles the memory model.

---

## 4. Root Main-Lane Row Relation

### 4.1 Row-local R1CS

Boolean rows (11 total):

```text
b · (b - 1) = 0
for b in {
  WritesAluToRd, WritesMemToRd, PreservesRd,
  IsJal, IsJalr, IsBranch, BranchTaken,
  IsLoad, IsStore, UsesRs2, AdvanceArchPc
}
```

BranchTakenMux product (1 row):

```text
IsBranch · BranchTaken = BranchTakenMux
```

RD-lane partition (1 row):

```text
WritesAluToRd + WritesMemToRd + PreservesRd - 1 = 0
```

RD-lane routing (6 rows):

```text
WritesAluToRd · (RD_NEXT_LO - ALU_OUT_LO) = 0
WritesAluToRd · (RD_NEXT_HI - ALU_OUT_HI) = 0
WritesMemToRd · (RD_NEXT_LO - MEM_VAL_LO) = 0
WritesMemToRd · (RD_NEXT_HI - MEM_VAL_HI) = 0
PreservesRd   · RD_NEXT_LO                 = 0
PreservesRd   · RD_NEXT_HI                 = 0
```

Expanded-sequence PC routing (6 rows):

```text
(IsJal + IsJalr + BranchTakenMux) · (PC_NEXT_LO - JUMP_TARGET_LO)       = 0
(IsJal + IsJalr + BranchTakenMux) · (PC_NEXT_HI - JUMP_TARGET_HI)       = 0
(AdvanceArchPc - IsJal - IsJalr - BranchTakenMux) · (PC_NEXT_LO - STEP_PC_LO) = 0
(AdvanceArchPc - IsJal - IsJalr - BranchTakenMux) · (PC_NEXT_HI - STEP_PC_HI) = 0
(ONE - AdvanceArchPc) · (PC_NEXT_LO - PC_LO)                            = 0
(ONE - AdvanceArchPc) · (PC_NEXT_HI - PC_HI)                            = 0
```

This makes the multi-row execution law explicit: intermediate rows hold the
architectural PC, and only rows with `AdvanceArchPc = 1` may route to
`STEP_PC` or `JUMP_TARGET`.

MEM_ADDR inactive (2 rows):

```text
(ONE - IsLoad - IsStore) · MEM_ADDR_LO = 0
(ONE - IsLoad - IsStore) · MEM_ADDR_HI = 0
```

MEM_VAL inactive (2 rows):

```text
(ONE - IsLoad - IsStore) · MEM_VAL_LO = 0
(ONE - IsLoad - IsStore) · MEM_VAL_HI = 0
```

Total row-local rows: 11 + 1 + 1 + 6 + 6 + 2 + 2 = **29**.

### 4.2 The root main lane does **not** prove opcode correctness by itself

The root main lane only proves the local routing equalities above. It does
**not** prove:

- that the flags are valid for the fetched lowered bytecode row,
- that IMM is the correct decoded immediate,
- that ALU_OUT is the correct computation result,
- that STEP_PC = PC + 4,
- that JUMP_TARGET is the correct branch/jump target,
- that MEM_ADDR = RS1 + IMM,
- that MEM_VAL matches RAM history,
- that register values come from the authenticated register file,
- that BranchTaken is the correct branch condition outcome.

Those are discharged in kernel Stage 1, kernel Stage 2, and kernel Stage 3.

### 4.3 Continuity obligations exported to kernel Stage 3

PC continuity:

```text
forall j < N-1: PC(j+1) = PC_NEXT(j)
```

where `PC(j+1)` denotes the two-limb value `(PC_LO(j+1), PC_HI(j+1))` and
`PC_NEXT(j)` denotes `(PC_NEXT_LO(j), PC_NEXT_HI(j))`.

RV64IM has no multi-row burst instructions, so there is no burst-progression or
burst-start-boundary check.

### 4.3a Adjacent-state linking theorem obligation

Strong kernel soundness requires:

```text
forall j < N-1: PostState(j) = PreState(j+1)
```

The closure objects are:

- `Stage2TemporalContext`: one shared register timeline and one shared RAM
  timeline over the semantic prefix,
- `PcAdjacentBridge`: the Stage-3 shift/continuity surface proves adjacent-row
  PC equality.

Concretely:

- `PreState(j)` is the architectural-plus-virtual machine state immediately
  before expanded row `j`,
- `PostState(j)` is the architectural-plus-virtual machine state immediately
  after expanded row `j`,
- the register component of `PostState(j)` is read from the paired register
  timeline `(RegValLo(_, j+1), RegValHi(_, j+1))`,
- the RAM component of `PostState(j)` is read from the paired RAM timeline
  `(RamValLo(_, j+1), RamValHi(_, j+1))`,
- the PC component of `PostState(j)` is `PC_NEXT(j)`,
- `PreState(j+1)` is read from those same time-`j+1` objects.

### 4.3b Exact-boundary closure requirement

Kernel soundness is defined only for the exact active semantic prefix
`j ∈ [0, N)`. The closure obligations above must hold:

- for every active adjacent pair `j < N - 1`,
- with no appeal to pad-row state for semantic closure,
- with the final active row excluded from predecessor-style continuity masking,
- and with Stage 1, Stage 2, and Stage 3 all interpreted over the same active
  prefix length `N`.

Any implementation that proves only a padded-trace closure statement while
leaving the exact active prefix implicit is non-conforming.

---

## 5. Stage 1: Fetch, Decode, and Computation Verification

### 5.0 Shared Stage-1 cycle point

Stage 1 uses one explicit shared cycle challenge

```text
r_lookup ∈ K^{CYCLE_BITS}
```

sampled once from the transcript before the Stage-1 bytecode, ALU,
branch-condition, and linkage checks are run.

### 5.1 Fetch channel

The fetch channel proves that cycle `j` executes exactly one lowered row from
the committed expanded bytecode:

```text
bytecode_row(j) = Bytecode[expanded_pc(j)]
```

using a Shout read-only lookup against `C_bytecode_table` with one-hot address
family `C_bytecode_ra`.

Normative fetch obligations:

- the fetched row exposes `instruction_word_arch`, `unexpanded_pc`,
  `virtual_opcode`, operand selectors, flags, and Stage-2 handoff metadata,
- `expanded_pc` itself is authenticated through the bytecode Shout instance and
  its folded `raf` claims; it is not a root-lane column,
- every row marked `is_first_in_sequence = 1` additionally proves
  `instruction_word_arch = ROM[unexpanded_pc / 4]` against `C_rom_table`,
- rows inside the same lowered sequence share the same `instruction_word_arch`
  and `unexpanded_pc`.

Additional fetch-side alignment obligation:

```text
PC_LO mod 4 = 0
```

This is discharged from the byte decomposition already required for limb range
proofs. Because the C extension is unsupported, any row with `PC[1:0] != 0` is
invalid.

### 5.1b Expanded bytecode successor law

The execution trace uses `expanded_pc` to fetch from `C_bytecode_table`. The
expanded-bytecode successor law is normative:

- **Start rule:** At cycle `j = 0`,
  ```text
  expanded_pc(0) = Entrypoint(PC(0))
  ```
  where `Entrypoint(addr)` is the deterministic lowering-induced map from an
  architectural byte address to the first expanded bytecode row with that
  `unexpanded_pc = addr`.
- **Successor rule:** For every active adjacent pair `0 <= j < N - 1`,
  ```text
  if is_last_in_sequence(j) = 0:
      expanded_pc(j + 1) = expanded_pc(j) + 1
  else:
      expanded_pc(j + 1) = Entrypoint(PC_NEXT(j))
  ```
- **Authentication rule:** Stage 1 proves these relations using the bytecode
  Shout `raf` surface together with an explicit start-boundary entrypoint claim.

### 5.2 Expanded bytecode row channel

The authentication channel is keyed by `BytecodeAddr = expanded_pc`, not by the
universal 32-bit instruction space and not by the architectural ROM address.

The expanded bytecode row outputs at least:

```text
(valid,
 instruction_word_arch,
 virtual_opcode,
 unexpanded_pc_lo_dec, unexpanded_pc_hi_dec,
 is_virtual_instruction_dec,
 is_first_in_sequence_dec,
 is_last_in_sequence_dec,
 rd_dec, rs1_dec, rs2_dec,
 imm_lo_dec, imm_hi_dec,
 writes_alu_to_rd_dec,
 writes_mem_to_rd_dec,
 preserves_rd_dec,
 is_jal_dec, is_jalr_dec, is_branch_dec,
 is_load_dec, is_store_dec,
 uses_rs2_dec,
 alu_op_dec,
 branch_op_dec,
 mem_width_dec,
 mem_unsigned_dec,
 divrem_kind_dec,
 is_w_op_dec,
 is_mul_dec, is_div_dec, is_rem_dec)
```

Normative checks performed against `C_lane` at the Stage-1 cycle point
`r_lookup`:

```text
valid = 1
PC_LO               = unexpanded_pc_lo_dec
PC_HI               = unexpanded_pc_hi_dec
RD_IDX             = rd_dec
RS1_IDX            = rs1_dec
RS2_IDX            = rs2_dec
IMM_LO             = imm_lo_dec
IMM_HI             = imm_hi_dec
WritesAluToRd      = writes_alu_to_rd_dec
WritesMemToRd      = writes_mem_to_rd_dec
PreservesRd        = preserves_rd_dec
IsJal              = is_jal_dec
IsJalr             = is_jalr_dec
IsBranch           = is_branch_dec
IsLoad             = is_load_dec
IsStore            = is_store_dec
UsesRs2            = uses_rs2_dec
AdvanceArchPc      = is_last_in_sequence_dec
```

Normative bytecode-row invariants:

- `instruction_word_arch` and `unexpanded_pc` are constant across all rows in
  one lowered sequence.
- `is_first_in_sequence_dec` and `is_last_in_sequence_dec` partition the
  sequence boundaries.
- `is_first_in_sequence_dec` and `is_last_in_sequence_dec` are proof-bearing
  control flags: they drive the expanded-bytecode successor law and
  `AdvanceArchPc`.
- `is_virtual_instruction_dec = 0` is allowed only when the lowered row is the
  architectural instruction itself with no extra virtualization.
- register selectors range over the full `Addr_reg` domain, so `rd_dec`,
  `rs1_dec`, and `rs2_dec` may denote architectural or virtual registers.
- Jolt-style sequence hygiene is enforced at the committed bytecode level:
  if `is_last_in_sequence_dec = 0` and
  `writes_alu_to_rd_dec + writes_mem_to_rd_dec = 1`, then
  `rd_dec ∈ {32..126} ∪ {127}`. Non-final rows may therefore target only the
  authenticated virtual-register range or the sink, never architectural
  registers `0..31`.
- a conforming prover may not replace the committed `virtual_opcode` or any of
  its metadata with a different internal decomposition.

Normative decode rules:

- When `rd_dec = 0` (x0): `preserves_rd_dec = 1`, `writes_alu_to_rd_dec = 0`,
  `writes_mem_to_rd_dec = 0`.
- Architectural-format rules apply to the **owning architectural instruction**
  (`instruction_word_arch`), but the lowered row may legitimately target
  virtual registers instead of architectural ones.

Normative decode exclusivity invariants:

```text
IsJal * IsJalr = 0
IsJal * IsBranch = 0
IsJalr * IsBranch = 0
IsLoad * IsStore = 0
(IsLoad + IsStore) * IsJal = 0
(IsLoad + IsStore) * IsJalr = 0
(IsLoad + IsStore) * IsBranch = 0
is_mul_dec * (is_div_dec + is_rem_dec) = 0
is_div_dec * is_rem_dec = 0
```

### 5.2b Decode-handoff surface

Decode outputs needed by Stage 2 but not in the root CCS:

```text
C_decode_handoff = {
    handoff_uses_rs2(j),
    handoff_is_load(j),
    handoff_is_store(j),
    handoff_mem_width(j),
    handoff_mem_unsigned(j),
    handoff_is_first_in_sequence(j),
    handoff_is_last_in_sequence(j),
}
```

Stage 1 proves at `r_lookup` that these match the authenticated decode outputs.

### 5.3 Expanded bytecode after lowering

Following Jolt's virtual-composition discipline, every supported architectural
instruction is assigned during preprocessing one fixed finite **virtual
sequence**, and the kernel commits the fully **expanded bytecode** after that
lowering. The sequence is independent of witness values and runtime inputs; it
depends only on the authenticated architectural instruction row.

This is now the normative execution model:

- one semantic kernel row = one expanded bytecode row,
- the committed expanded bytecode, not the prover, chooses the decomposition,
- any cross-row temporary state must live in authenticated virtual registers,
- architectural instruction semantics are recovered as the net effect of one
  committed sequence.

`C_bytecode_table` is therefore the canonical execution object. There is no
collapsed in-row replay surface and no padded descriptor that stands in for
uncommitted substeps.

Reference and concrete lowering are distinct notions in this kernel:

- the tables in §5.3.4 define the **reference lowering**, which fixes the
  human-readable semantic core of each architectural opcode lowering,
- a concrete implementation may commit a different but deterministic lowered
  sequence if it is selected by `lowering_version_id`, absorbed into `root0`,
  and accompanied by a theorem package proving that the committed sequence
  refines the reference lowering at the exact kernel boundary,
- that refinement package must identify the unique effect row, prove
  correctness and determinism for the full committed sequence, and prove that
  any extra closure-suffix rows are semantically inert outside the scratch
  virtual-register domain.

### 5.3.1 Subtable and relation substrate

The primitive execution substrate remains byte-level Shout subtables. Word-width
(64-bit) direct subtables would require `2^128`-entry lookup tables, which are
infeasible without a different proof system. The expanded bytecode is therefore
built from smaller virtual instructions whose semantics reduce to the following
committed subtables.

Byte-local arithmetic and logic instructions reduce to the following committed
subtables (`C_alu_subtables`). Every byte-level subtable fits in `2^{16}` or
`2^{17}` entries.

| Subtable | Domain | Semantics |
|----------|--------|-----------|
| `ADD8(a,b,cin)` | `[0,256)^2 × {0,1}` | `sum = (a+b+cin) mod 256`, `cout = (a+b+cin) ≥ 256` |
| `AND8(a,b)` | `[0,256)^2` | `a & b` |
| `OR8(a,b)` | `[0,256)^2` | `a \| b` |
| `XOR8(a,b)` | `[0,256)^2` | `a ^ b` |
| `MUL8(a,b)` | `[0,256)^2` | `a * b` (16-bit result, two output bytes) |
| `LT8(a,b)` | `[0,256)^2` | `1` if `a < b` (unsigned), `0` otherwise |
| `EQ8(a,b)` | `[0,256)^2` | `1` if `a == b`, `0` otherwise |
| `SHL8(a,s)` | `[0,256) × [0,8)` | `(a << s) & 0xFF`, plus spillover bits |
| `SHR8(a,s)` | `[0,256) × [0,8)` | `a >> s`, plus spillover bits |
| `SIGNEXT8(a)` | `[0,256)` | `0xFF` if `a ≥ 128`, `0x00` otherwise |

Branch-condition subtables (committed under `C_branch_table`):

| Subtable | Domain | Semantics |
|----------|--------|-----------|
| `EQ8` | `[0,256)^2` | `1` if `a == b` |
| `LT8` | `[0,256)^2` | `1` if `a < b` (unsigned byte) |
| `SIGNBIT8(a)` | `[0,256)` | `a >> 7` (sign bit of byte) |

Alignment predicates do **not** require a separate committed table. `Align(2)`,
`Align(4)`, and `Align(8)` are discharged directly from the low byte
decomposition of `PC_LO`, `JUMP_TARGET_LO`, and `MEM_ADDR_LO`.

Normative rule for trivial predicates:

- the expanded bytecode may still expose such a predicate as a first-class
  virtual instruction for uniform lowering and theorem surfaces,
- but when the predicate depends only on already-opened low bits or bytes, its
  proof rule should be direct arithmetic in the same row rather than a separate
  committed lookup family,
- in particular, natural-alignment checks are arithmetic obligations, not a
  mandatory alignment-table subsystem.

The division/remainder corner-case support relations are also committed under
`C_alu_subtables`, but not as naive `2^128` materialized tables. Instead they
are authenticated as dedicated compressed lookup relations, in the same spirit
as Jolt's prefix/suffix decomposition for wide validity tables.

| Relation | Inputs | Semantics |
|----------|--------|-----------|
| `VALID_DIV0(divisor, quotient)` | `(d, q)` | `1` iff `d != 0` or `q = 2^64 - 1` |
| `VALID_UNSIGNED_REMAINDER(remainder, divisor)` | `(r, d)` | `1` iff `d = 0` or `r <_u d` |
| `MULU_NO_OVERFLOW(multiplier, multiplicand)` | `(q, d)` | `1` iff the unsigned product `q × d` fits in 64 bits, equivalently iff the high 64 bits of the 128-bit product are zero |
| `CHANGE_DIVISOR(dividend, divisor, adjusted_divisor)` | `(n, d, d')` | `1` iff `d' = 1` in the unique signed-overflow case `n = INT_MIN` and `d = -1`, else `d' = d` |

These are normative proof objects, not prose side conditions. The exact ISA
target for signed division and remainder is the joint semantic relation
`SIGNED_DIVREM_SPEC(N, Q, D, R)`, interpreted over 64-bit two's-complement
values:

- if `D = 0`, then `Q = 2^64 - 1` and `R = N`,
- else if `N = INT_MIN` and `D = -1`, then `Q = INT_MIN` and `R = 0`,
- else `N = Q × D + R (mod 2^64)`, `|R| <_u |D|`, and `R = 0` or
  `sign(R) = sign(N)`.

A standalone binary predicate on `(R, D)` is not sufficient to capture signed
RV64IM semantics. Conforming signed `DIV` / `REM` lowerings must prove the
joint dividend-aware relation above.

### 5.3.2 Primitive virtual-instruction catalog

Each virtual instruction maps to a bounded number of subtable queries.
Carry/borrow wires between queries are **Stage-1 auxiliary witness** (not
main-lane columns). Row-local auxiliaries may be used only within one row. Any
value that survives to a later row in the same lowered sequence must be written
to an authenticated virtual register in `Addr_reg`.

**Arithmetic virtual instructions:**

| Virtual instruction | Semantics | Subtable queries | Aux witness |
|------|-----------|------------------|-------------|
| `VAdd64(a, b)` | `(a + b) mod 2^64` | 8× ADD8, chained carries | 7 carry bits |
| `VSub64(a, b)` | `(a - b) mod 2^64` | 8× ADD8 with `b' = ~b`, `cin_0 = 1` | 7 carry bits |
| `VAnd64(a, b)` | `a & b` | 8× AND8 | none |
| `VOr64(a, b)` | `a \| b` | 8× OR8 | none |
| `VXor64(a, b)` | `a ^ b` | 8× XOR8 | none |
| `VMul64(a, b)` | low 64 bits of `a × b` | 64× MUL8 + carry accumulation | partial sums |
| `VMulHigh64(a, b, sign)` | high 64 bits of `a × b` | 64× MUL8 + carry accumulation | partial sums |

**Shift virtual instructions** (inspired by Jolt's bitmask + apply pattern):

| Virtual instruction | Semantics | Decomposition |
|------|-----------|---------------|
| `VShiftLeft64(a, shamt)` | `a << shamt` | 1. `byte_shift = shamt >> 3`, `bit_shift = shamt & 7`. 2. Rearrange source bytes by `byte_shift` (zero-fill low). 3. For each adjacent byte pair, apply `SHL8` by `bit_shift` with spillover from lower byte. |
| `VShiftRightLogical64(a, shamt)` | `a >> shamt` (unsigned) | 1. `byte_shift = shamt >> 3`, `bit_shift = shamt & 7`. 2. Rearrange source bytes by `byte_shift` (zero-fill high). 3. For each adjacent byte pair, apply `SHR8` by `bit_shift` with spillover from upper byte. |
| `VShiftRightArith64(a, shamt)` | `a >> shamt` (signed) | Same as logical right shift but: high bytes filled with `SIGNEXT8(a[7])` instead of zero. |

Shift virtual-instruction query cost: up to 8× `SHL8`/`SHR8` + 1× `SIGNEXT8` for
arithmetic right shift. The `byte_shift` routing is **not** unconstrained
witness selection. Stage 1 decomposes
`shamt = 8 * byte_shift + bit_shift` with `byte_shift ∈ [0,8)` and
`bit_shift ∈ [0,8)`, and enforces by direct selector arithmetic that the routed
byte tuple given to the `SHL8` / `SHR8` subtables is exactly the source tuple
shifted by `byte_shift` bytes.

**Comparison virtual instructions:**

| Virtual instruction | Semantics | Decomposition |
|------|-----------|---------------|
| `VCompareEq64(a, b)` | `1` if `a == b` | 8× EQ8, AND-reduce: all bytes equal ⟹ words equal. |
| `VCompareLtU64(a, b)` | `1` if `a <_u b` | Scan bytes MSB→LSB: find first byte where `a[i] ≠ b[i]`, check `LT8(a[i], b[i])`. Uses 8× EQ8 + 8× LT8 with priority logic. |
| `VCompareLtS64(a, b)` | `1` if `a <_s b` | Same as unsigned but flip sign-bit comparison on MSB: `SIGNBIT8(a[7]) > SIGNBIT8(b[7])` ⟹ `a < b`; equal signs ⟹ unsigned comparison on remaining bytes. |
| `VCompareGeU64(a, b)` | `1` if `a >=_u b` | `1 - VCompareLtU64(a, b)` (negation, no extra queries). |
| `VCompareGeS64(a, b)` | `1` if `a >=_s b` | `1 - VCompareLtS64(a, b)`. |
| `VCompareNeq64(a, b)` | `1` if `a ≠ b` | `1 - VCompareEq64(a, b)`. |

**Truncation / extension virtual instructions:**

| Virtual instruction | Semantics | Subtable queries |
|------|-----------|------------------|
| `VMove(a)` | Copy `a` unchanged | None (direct equality support relation). |
| `VMovSign(a)` | Replicate the sign bit of `a` to all bits | 1× SIGNEXT8 on the top byte, then broadcast. |
| `VTruncate32(a)` | `a[31:0]` (keep low 4 bytes, zero high 4) | None (direct byte-equality and zero-high-byte constraints). |
| `VSignExtend32(a)` | Sign-extend `a[31:0]` to 64 bits | 1× SIGNEXT8 on byte 3; set bytes 4–7 to sign-fill. |
| `VZeroExtend(a, w)` | Zero-extend `w`-byte value to 64 bits | None (direct byte-equality, zero-high-byte, and width-range constraints). |
| `VSignExtend(a, w)` | Sign-extend `w`-byte value to 64 bits | 1× SIGNEXT8 on byte `w-1`; set upper bytes to sign-fill. |

Normative support relations for direct-arithmetic helper rows:

- `VMove(a)` proves `ALU_OUT = a` exactly.
- `VTruncate32(a)` proves `ALU_OUT[31:0] = a[31:0]` and `ALU_OUT[63:32] = 0`.
- `VZeroExtend(a, w)` proves the low `w` bytes equal the source bytes and the
  upper `8 - w` bytes are zero.
- `VNoop()` proves `ALU_OUT` equals the row's prescribed pass-through value from
  authenticated decode metadata. In particular, `LUI` binds `ALU_OUT = IMM`,
  while `FENCE` binds `ALU_OUT = 0`.

**Control / assertion virtual instructions** (following Jolt's virtual assertion pattern):

| Virtual instruction | Semantics | Decomposition |
|------|-----------|---------------|
| `VChangeDivisor(dividend, divisor)` | Return `1` in the unique signed-overflow case `dividend = INT_MIN` and `divisor = -1`, else return `divisor` unchanged | 1× `CHANGE_DIVISOR`. |
| `VAdvice(value)` | Accept untrusted prover advice with no standalone proof power | None — value is aux witness and is accepted only through the downstream fixed-sequence theorems. |
| `VAssertEq(a, b)` | Assert `a = b` | `VCompareEq64(a, b)` must yield 1. |
| `VAssertLtU(a, b)` | Assert `a <_u b` | `VCompareLtU64(a, b)` must yield 1. |
| `VAssertLteU(a, b)` | Assert `a <=_u b` | `VCompareLtU64(b, a)` must yield 0. |
| `VAssertEqSigns(a, b)` | Assert `sign(a) = sign(b)` | Compare sign bits of the top bytes. |
| `VAssertLtAbs(a, b)` | Assert `|a| < |b|` on two's-complement inputs | Reduce to absolute-value bytes then `VCompareLtU64`. |
| `VAssertAligned(a, w)` | Assert `a` is naturally aligned to `w ∈ {1,2,4,8}` bytes | Arithmetic semantics on the low bits of `a`; no dedicated alignment table is required. |
| `VAssertValidDiv0(divisor, quotient)` | Assert `VALID_DIV0(divisor, quotient) = 1` | 1× `VALID_DIV0`. |
| `VAssertValidUnsignedRemainder(r, d)` | Assert `VALID_UNSIGNED_REMAINDER(r, d) = 1` | 1× `VALID_UNSIGNED_REMAINDER`. |
| `VAssertMulUNoOverflow(q, d)` | Assert `MULU_NO_OVERFLOW(q, d) = 1` | 1× `MULU_NO_OVERFLOW`. |
| `VClearBit0(a)` | `a & ~1` | 1× AND8 on byte 0 with `0xFE`; bytes 1–7 unchanged. |
| `VNoop()` | Identity — no queries | Used for pass-through (e.g., LUI). |

**Memory-support virtual instructions** (used to keep RAM checking word-addressed):

| Virtual instruction | Semantics | Proof owner |
|------|-----------|-------------|
| `VLoadAligned64(addr)` | Read one aligned 64-bit RAM word at `addr` | Stage 2 RAM Twist |
| `VStoreAligned64(addr, value)` | Write one aligned 64-bit RAM word at `addr` | Stage 2 RAM Twist |
| `VExtractLoad(word, off, w, unsigned)` | Extract width-`w` subword from aligned RAM word and sign/zero extend | Stage 1 arithmetic support relation |
| `VBlendStore(word, src, off, w)` | Blend a width-`w` store value into an aligned RAM word | Stage 1 arithmetic support relation |

Normative helper-row arithmetic for narrow memory:

Let

```text
Byte_k(x) ∈ {0..255}   for k ∈ {0..7}
x = Σ_{k=0}^7 2^{8k} · Byte_k(x)
```

and let `addr64 = UInt64(addr_lo, addr_hi)`. Then the helper relations are:

```text
align_down_8(addr64) = addr64 - (addr64 mod 8)
byte_offset_8(addr64) = addr64 mod 8
```

with `byte_offset_8(addr64) = ram_byte_off` on the authenticated Stage-2 memory
rows.

The narrow-load extraction relation is:

```text
extract_raw(word, off, w)
  = Σ_{k=0}^{w-1} 2^{8k} · Byte_{off + k}(word)

extract_extend(word, off, w, unsigned)
  = if unsigned = 1 then
      extract_raw(word, off, w)
    else
      extract_raw(word, off, w)
      + Σ_{k=w}^{7} 2^{8k} · sign_fill(word, off, w)
```

where

```text
sign_fill(word, off, w) =
  if Byte_{off + w - 1}(word) ≥ 128 then 255 else 0
```

The narrow-store blend relation is:

```text
blend(word, src, off, w)
  = Σ_{k : k < off or k ≥ off + w} 2^{8k} · Byte_k(word)
    + Σ_{k=0}^{w-1} 2^{8(off + k)} · Byte_k(src)
```

Therefore:

- `VLoadAligned64(addr)` proves `MEM_ADDR = align_down_8(addr)` and carries the
  authenticated aligned word,
- `VExtractLoad(word, off, w, unsigned)` proves
  `ALU_OUT = extract_extend(word, off, w, unsigned)` with
  `off = byte_offset_8(addr)`,
- `VBlendStore(word, src, off, w)` proves
  `ALU_OUT = blend(word, src, off, w)` with `off = byte_offset_8(addr)`,
- `VStoreAligned64(addr, value)` proves `MEM_ADDR = align_down_8(addr)` and
  uses `value` as the intended aligned-word store payload.

### 5.3.3 Lowering rules and sequence-boundary semantics

This spec fixes one public constant:

```text
MAX_VSEQ_LEN = 24
```

Lowering rules:

- every architectural instruction lowers to a finite sequence of expanded rows
  of length in `[1, MAX_VSEQ_LEN]`,
- every lowered row has one committed `virtual_opcode`,
- all rows in the sequence carry the same `instruction_word_arch` and
  `unexpanded_pc`,
- exactly one row is marked `is_first_in_sequence`,
- exactly one row is marked `is_last_in_sequence`.

Normative composition rules:

1. Each semantic row authenticates exactly one committed lowered bytecode row
   from `C_bytecode_table`.
2. The expanded sequence order is committed and deterministic. There is no
   prover-chosen hidden DAG, hidden interpreter, or unbound substep surface.
3. Intermediate sequence values may flow across rows only through authenticated
   virtual registers.
4. `STEP_PC = PC + 4` is an architectural-sequence invariant shared by all rows
   in the same lowered sequence.
5. Non-final rows in a sequence must satisfy `PC_NEXT = PC`, and may update only
   the state permitted by their committed lowered opcode.
6. Sequence-final rows are the only rows that may change architectural control
   flow (`PC_NEXT ≠ PC`) or commit the final architectural `rd` value.
7. Assertion instructions (`VAssertEq`, `VAssertLtU`, `VAssertLteU`,
   `VAssertEqSigns`, `VAssertLtAbs`, `VAssertAligned`,
   `VAssertValidDiv0`, `VAssertValidUnsignedRemainder`,
   `VAssertMulUNoOverflow`) must evaluate to true on their own rows.
8. Every multi-row lowered sequence must come with a correctness theorem over
   its fixed committed row list, fixed touched-state set, and fixed
   sequence-boundary result row: for all architectural inputs and fixed
   authenticated reads, if all row assertions in that committed sequence hold,
   then the committed sequence output and state effect match the RV64IM ISA
   semantics for that instruction and all state outside the touched set is
   preserved.
9. Every multi-row lowered sequence must also come with a determinism theorem:
   for the same fixed committed row list, fixed touched-state set, fixed
   architectural inputs, and fixed authenticated reads, no two satisfying
   witness assignments may produce different committed outputs, different
   committed state effects, or different sequence-boundary architectural
   results.
10. Any lowered sequence that reads `VAdvice` is a special case of rules 8 and
    9. Its accepted theorem package may quantify over advice assignments, but
    it must still bind the same fixed committed sequence metadata and the same
    preserved-state obligation. `VAdvice` carries no standalone semantic proof
    power outside those committed-sequence obligations.
11. Strong soundness therefore requires a lowering-equivalence theorem package
    for every multi-row architectural lowering, not only for advice-backed
    sequences.
12. In particular, the signed `DIV` / `REM` lowerings must prove
    `SIGNED_DIVREM_SPEC(RS1, Q, RS2, R_signed)`; a standalone binary
    signed-remainder predicate is non-conforming.

These advice obligations are theorem obligations, not implementation notes. An
integration may discharge them with Lean, SMT, or an equivalent machine-
checkable proof system; hand inspection or prose argument is non-conforming.

### 5.3.4 Reference per-instruction virtual sequences

The expanded bytecode table selects one fixed lowered sequence for each
architectural instruction class. The sequences below define the **reference**
lowering. A conforming concrete lowering may refine these sequences under the
admissibility contract of §5.3.5. Single-row sequences are allowed; those rows
carry `is_virtual_instruction = 0` and execute the architectural opcode
directly. Multi-row sequences use helper virtual instructions with
`is_virtual_instruction = 1`. Below, `op1 = RS1` and `op2 = RS2` (R-type) or
`IMM` (I-type).

Normative reading rule:

- each line `v0`, `v1`, `s0`, `s1`, ... below denotes **one expanded bytecode
  row**,
- consecutive lines belong to consecutive rows in the same committed lowered
  sequence,
- they are **not** slots replayed inside one kernel row,
- intermediate names (`t0`, `h0`, `Q`, `R`, etc.) denote values carried through
  authenticated virtual-register state or row-local outputs as required by the
  lowered row semantics.

**ADD / ADDI:**

```text
v0: VAdd64(op1, op2)                 → ALU_OUT
```

**SUB:**

```text
v0: VSub64(RS1, RS2)                 → ALU_OUT
```

**AND / ANDI:**

```text
v0: VAnd64(op1, op2)                 → ALU_OUT
```

**OR / ORI:**

```text
v0: VOr64(op1, op2)                  → ALU_OUT
```

**XOR / XORI:**

```text
v0: VXor64(op1, op2)                 → ALU_OUT
```

**SLL / SLLI:**

```text
v0: VShiftLeft64(RS1, op2[5:0])      → ALU_OUT
```

**SRL / SRLI:**

```text
v0: VShiftRightLogical64(RS1, op2[5:0])  → ALU_OUT
```

**SRA / SRAI:**

```text
v0: VShiftRightArith64(RS1, op2[5:0])    → ALU_OUT
```

**SLT / SLTI:**

```text
v0: VCompareLtS64(RS1, op2)          → ALU_OUT   // 0 or 1
```

**SLTU / SLTIU:**

```text
v0: VCompareLtU64(RS1, op2)          → ALU_OUT   // 0 or 1
```

**ADDW / ADDIW:**

```text
v0: VTruncate32(op1)                 → t0
v1: VTruncate32(op2)                 → t1
v2: VAdd64(t0, t1)                   → t2
v3: VSignExtend32(t2)                → ALU_OUT
```

**SUBW:**

```text
v0: VTruncate32(RS1)                 → t0
v1: VTruncate32(RS2)                 → t1
v2: VSub64(t0, t1)                   → t2
v3: VSignExtend32(t2)                → ALU_OUT
```

**SLLW / SLLIW:**

```text
v0: VTruncate32(RS1)                 → t0
v1: VShiftLeft64(t0, op2[4:0])       → t1
v2: VSignExtend32(t1)                → ALU_OUT
```

**SRLW / SRLIW:**

```text
v0: VTruncate32(RS1)                 → t0
v1: VShiftRightLogical64(t0, op2[4:0])   → t1
v2: VSignExtend32(t1)                → ALU_OUT
```

**SRAW / SRAIW:**

```text
v0: VSignExtend32(RS1)               → t0
v1: VShiftRightArith64(t0, op2[4:0]) → t1
v2: VSignExtend32(t1)                → ALU_OUT
```

**LUI:**

```text
v0: VNoop()                          → ALU_OUT = IMM
```

IMM already sign-extended to 64 bits by the expanded bytecode row.

**AUIPC:**

```text
v0: VAdd64(PC, IMM)                  → ALU_OUT
```

**JAL:**

```text
v0: native JAL row                   // ALU_OUT = PC + 4, JUMP_TARGET = PC + IMM,
                                     // WritesAluToRd = 1, PC_NEXT = JUMP_TARGET
```

**JALR:**

```text
v0: native JALR row                  // ALU_OUT = PC + 4, JUMP_TARGET = (RS1 + IMM) & ~1,
                                     // WritesAluToRd = 1, PC_NEXT = JUMP_TARGET
```

**BEQ:**

```text
v0: native BEQ row                   // BranchTaken = (RS1 == RS2),
                                     // JUMP_TARGET = PC + IMM, PC_NEXT routed by flags
```

**BNE:**

```text
v0: native BNE row
```

**BLT:**

```text
v0: native BLT row
```

**BGE:**

```text
v0: native BGE row
```

**BLTU:**

```text
v0: native BLTU row
```

**BGEU:**

```text
v0: native BGEU row
```

**LD** (aligned 64-bit load):

```text
v0: native LD row                    // MEM_ADDR = RS1 + IMM, aligned 64-bit RAM read,
                                     // WritesMemToRd = 1
```

**LB / LBU / LH / LHU / LW / LWU** (narrow loads lowered through aligned word RAM):

```text
v0: VAdd64(RS1, IMM)                 → t_addr
v1: VLoadAligned64(t_addr & ~7)      → t_word
v2: VExtractLoad(t_word, t_addr[2:0], mem_width_dec, mem_unsigned_dec)
                                    → ALU_OUT
```

The aligned-word load row writes the raw 64-bit RAM word into a temporary
virtual register. The final extract row is a pure Stage-1 row that writes the
architectural destination register via `ALU_OUT`.

**SD** (aligned 64-bit store):

```text
v0: native SD row                    // MEM_ADDR = RS1 + IMM, aligned 64-bit RAM write
```

**SB / SH / SW** (narrow stores lowered through aligned word RAM):

```text
v0: VAdd64(RS1, IMM)                 → t_addr
v1: VLoadAligned64(t_addr & ~7)      → t_word
v2: VBlendStore(t_word, RS2, t_addr[2:0], mem_width_dec)
                                    → t_new_word
v3: VStoreAligned64(t_addr & ~7, t_new_word)
```

The final aligned store row reads `t_new_word` through its authenticated `RS2`
port and commits the RAM write there. The blend row itself is a pure Stage-1
row with no Stage-2 RAM effect.

**MUL:**

```text
v0: VMul64(RS1, RS2)                 → ALU_OUT       // low 64 bits
```

**MULH** (signed × signed → high 64), following Jolt's virtual-composition pattern:

```text
s0: VMovSign(RS1)                    → sx
s1: VMovSign(RS2)                    → sy
s2: VMulHigh64(RS1, RS2, Unsigned)   → h0
s3: VMul64(sx, RS2)                  → h1
s4: VMul64(sy, RS1)                  → h2
s5: VAdd64(h0, h1)                   → t0
s6: VAdd64(t0, h2)                   → ALU_OUT
```

**MULHU** (unsigned × unsigned → high 64):

```text
v0: VMulHigh64(RS1, RS2, Unsigned)   → ALU_OUT
```

**MULHSU** (signed × unsigned → high 64), following Jolt's virtual-composition pattern:

```text
s0: VMovSign(RS1)                    → sx
s1: VMulHigh64(RS1, RS2, Unsigned)   → h0
s2: VMul64(sx, RS2)                  → h1
s3: VAdd64(h0, h1)                   → ALU_OUT
```

**MULW:**

```text
v0: VTruncate32(RS1)                 → t0
v1: VTruncate32(RS2)                 → t1
v2: VMul64(t0, t1)                   → t2
v3: VSignExtend32(t2)                → ALU_OUT
```

**DIVU** (unsigned), using Jolt-style advice + validity instructions:

```text
s0: VAdvice()                        → Q
s1: VAdvice()                        → R
s2: VAssertValidDiv0(RS2, Q)
s3: VAssertMulUNoOverflow(Q, RS2)
s4: VMul64(Q, RS2)                   → qd
s5: VAssertValidUnsignedRemainder(R, RS2)
s6: VAssertLteU(qd, RS1)
s7: VAdd64(qd, R)                    → t0
s8: VAssertEq(t0, RS1)
s9: VMove(Q)                         → ALU_OUT
```

**REMU:** Same checked sequence as DIVU but `s9: VMove(R) -> ALU_OUT`.

**DIV** (signed), using Jolt-style advice + adjusted divisor + dividend-signed
remainder reconstruction:

```text
s0:  VAdvice()                       → Q
s1:  VAdvice()                       → R_abs
s2:  VAssertValidDiv0(RS2, Q)
s3:  VChangeDivisor(RS1, RS2)        → D_adj
s4:  VMulHigh64(Q, D_adj, Signed)    → qd_hi
s5:  VMul64(Q, D_adj)                → qd_lo
s6:  VMovSign(qd_lo)                 → qd_sign
s7:  VAssertEq(qd_hi, qd_sign)
s8:  VMovSign(RS1)                   → n_sign
s9:  VXor64(R_abs, n_sign)           → t0
s10: VSub64(t0, n_sign)              → R_signed
s11: VAdd64(qd_lo, R_signed)         → t1
s12: VAssertEq(t1, RS1)
s13: VMovSign(D_adj)                 → d_sign
s14: VXor64(D_adj, d_sign)           → t2
s15: VSub64(t2, d_sign)              → D_abs
s16: VAssertValidUnsignedRemainder(R_abs, D_abs)
s17: VMove(Q)                        → ALU_OUT
```

**REM:** Same checked sequence as DIV but `s17: VMove(R_signed) -> ALU_OUT`.

**DIVW / DIVUW / REMW / REMUW:** Same signed/unsigned structure as their 64-bit
counterparts, wrapped in 32-bit truncation and final sign-extension:

```text
v0:  VTruncate32(RS1)                → a0
v1:  VTruncate32(RS2)                → b0
v2:  VSignExtend32(a0) or VZeroExtend(a0, 4) → a
v3:  VSignExtend32(b0) or VZeroExtend(b0, 4) → b
v4–...: the corresponding 32-bit div/rem lowered sequence on a, b, producing
        `result32` on its final inner row
v_last: VSignExtend32(result32)      → ALU_OUT
```

**ECALL:**

```text
(no ALU virtual instructions; termination signal)
```

### 5.3.5 Admissible concrete lowerings and refinement

A concrete lowered sequence chosen by `lowering_version_id` is conforming if
and only if it satisfies all of the following:

1. It is a deterministic function of the authenticated architectural row and
   the declared lowering version, not of prover-chosen witness values.
2. Every committed row in the concrete sequence is authenticated from
   `C_bytecode_table`; there is no uncommitted replay layer.
3. The sequence has one unique **effect row** whose row-local result and
   authenticated write/RAM action realizes the reference lowering’s semantic
   architectural effect.
4. The sequence has one unique **commit row** at or after the effect row. Only
   the commit row may export architectural `PC_NEXT`, `AdvanceArchPc`, and the
   terminating bit to later rows/stages.
5. Any rows strictly between the effect row and the commit row form a
   **closure suffix**. Closure-suffix rows may:
   - read and write only scratch virtual registers from the declared temporary
     lowering range,
   - reset or normalize that scratch state,
   - not write architectural registers,
   - not perform RAM reads or writes,
   - not introduce fresh advice beyond what the effect row and preceding helper
     rows already justified.
6. The net pre/post architectural state, RAM effect, and exported prepared-step
   boundary of the concrete sequence equal those of the reference lowering.
7. Stage 1, Stage 2, and Stage 3 are interpreted over the full committed
   concrete sequence, not over a normalized or collapsed projection.
8. The implementation ships one machine-checkable refinement theorem package
   proving:
   - deterministic normalization from concrete sequence to reference lowering,
   - exact effect-row identification,
   - effect-row correctness,
   - closure-suffix inertness outside scratch virtual registers,
   - preservation of the exact execution, trace, and kernel theorem surfaces.

The refinement package is the normative bridge between an optimized
Jolt-inspired concrete lowering and the reference lowering catalog above.

**FENCE:**

```text
v0: VNoop()                          → ALU_OUT = 0
```

### 5.3.5 Virtual-sequence query cost summary

The table below is stated **per expanded bytecode row**, not per architectural
instruction. A multi-row lowered sequence pays the sum of its constituent row
costs.

| Lowered row class | Max Shout queries per row |
|-------------------|---------------------------|
| Bitwise (AND, OR, XOR) | 8 |
| Addition / subtraction | 8 |
| Shifts (SLL, SRL, SRA) | 8 shift lookups (+1 `SIGNEXT8` for arithmetic right shift; byte routing is direct arithmetic, not a lookup slot) |
| Comparison (SLT, branch) | ≤ 16 (8 EQ + 8 LT) |
| MUL (low 64) | 64 (8×8 byte pairs) + carry |
| MULH variants (high 64) | 64 + carry |
| DIV / REM support rows (`VChangeDivisor`, validity, unsigned-overflow guard, equality) | O(1) |
| DIV / REM multiply rows (`VMul64`, `VMulHigh64`) | 64 + carry |
| DIV / REM sign-recovery rows (`VMovSign`, `VXor64`, `VSub64`) | 8 |
| W-variants | Same as base op + 1 SIGNEXT8 |
| Native `LD` / `SD` | 8 (address addition) + O(1) alignment |
| Narrow loads / stores | 8 (address) on address rows; aligned RAM word access and extract/blend are charged on their own lowered rows |
| LUI / FENCE / ECALL | 0–8 |

Plus 8 queries on any row that explicitly computes `STEP_PC = PC + 4`.

The maximum per-row lookup-slot budget is dominated by multiplication-class
rows (64 `MUL8` slots). Carry accumulation, byte routing, and other direct
arithmetic support relations do not consume additional `C_alu_ra` slots.

### 5.3.5a Canonical Stage-1 slot manifests

Nightstream v1 uses fixed Jolt-style dense slot manifests for all per-row Stage-1
lookup carriers. A row may leave trailing slots unused, but it may not reorder
or prover-choose the live slots.

Define the public slot budgets:

```text
MAX_ALU_QUERY_SLOTS    = 64
MAX_BRANCH_QUERY_SLOTS = 16
```

ALU channel manifest (`C_alu_ra`):

- slots are indexed by `slot ∈ {0..63}`,
- for each cycle `j` and slot `slot`, the slice `ra_alu(slot, -, j)` has
  Hamming weight `slot_used_alu(slot, j) ∈ {0,1}`,
- `slot_used_alu(slot, j)` is a deterministic function of the committed
  `virtual_opcode`, the row's committed operands, and the canonical packing
  below,
- unused slots are all-zero and contribute no address-correctness claim beyond
  the explicit zero/Hamming-weight-0 proof.

Canonical ALU slot packing:

- byte-parallel rows that issue one query per destination byte (`ADD8`, `AND8`,
  `OR8`, `XOR8`, `SHL8`, `SHR8`, equality-by-byte support, sign-extend-by-byte
  support) use slots `0..7` in byte order,
- unary single-query rows (`SIGNEXT8`, `CHANGE_DIVISOR`, `VALID_DIV0`,
  `VALID_UNSIGNED_REMAINDER`, `MULU_NO_OVERFLOW`, `VClearBit0`) use slot `0`,
- `VMul64` and `VMulHigh64` use the full dense product grid
  `slot = 8 * lhs_byte_index + rhs_byte_index`,
- `STEP_PC = PC + 4` uses byte-add slots `0..7`,
- direct arithmetic support relations such as `VMove`, `VTruncate32`,
  `VZeroExtend`, byte routing for shifts, and carry/borrow consistency are not
  lookup slots and therefore do not occupy `C_alu_ra`.

Branch channel manifest (`C_branch_ra`):

- slots are indexed by `slot ∈ {0..15}`,
- for each cycle `j` and slot `slot`, the slice `ra_branch(slot, -, j)` has
  Hamming weight `slot_used_branch(slot, j) ∈ {0,1}`,
- equality-comparison bytes use slots `0..7`,
- ordering-comparison bytes use slots `8..15`,
- unused branch slots are all-zero.

This dense manifest is normative. Any implementation that reorders live slots,
compresses them with prover-chosen packing, or silently allocates extra slot
families is non-conforming.

### 5.4 Branch-condition channel

The branch-condition channel proves:

```text
BranchTaken = BranchCond(branch_op_dec, RS1, RS2)
```

using the comparison virtual instructions from §5.3.2:

| branch_op | Virtual instruction | Output |
|-----------|---------------------|--------|
| BEQ | `VCompareEq64(RS1, RS2)` | `1` if equal |
| BNE | `VCompareNeq64(RS1, RS2)` | `1` if not equal |
| BLT | `VCompareLtS64(RS1, RS2)` | `1` if signed less-than |
| BGE | `VCompareGeS64(RS1, RS2)` | `1` if signed greater-or-equal |
| BLTU | `VCompareLtU64(RS1, RS2)` | `1` if unsigned less-than |
| BGEU | `VCompareGeU64(RS1, RS2)` | `1` if unsigned greater-or-equal |

For non-branch instructions: `BranchTaken = 0` (no comparison queries issued).

Each comparison virtual instruction resolves to byte-level Shout queries against `C_branch_table`
with one-hot address family `C_branch_ra`. The byte-level comparison reduction
(MSB→LSB priority scan for ordering, AND-reduce for equality) is carried out
with Stage-1 auxiliary witness bits for inter-byte priority propagation. Branch
rows use the canonical branch-slot packing from §5.3.5a: equality queries
occupy slots `0..7`, ordering queries occupy slots `8..15`.

### 5.5 Address-correctness obligations for Stage 1

Address-correctness is required for every Stage-1 one-hot address family.

For each family, the kernel proves:

- Booleanity,
- family-prescribed Hamming weight (`1` for bytecode fetch, `slot_used_alu` per
  ALU slot, `slot_used_branch` per branch slot),
- consistency with the authenticated decoded key/address tuple for that family.

These obligations remain explicit per family even when later transcript
challenges batch openings or linkage identities.

### 5.5a Stage-1 linkage batch

Stage 1 samples `γ_lookup_link` and proves the batched equality linking
`C_lane` and `C_decode_handoff` openings to authenticated decode/ALU outputs:

```text
ℓ0  = PC_LO - unexpanded_pc_lo_dec
ℓ1  = PC_HI - unexpanded_pc_hi_dec
ℓ2  = RD_IDX - rd_dec
ℓ3  = RS1_IDX - rs1_dec
ℓ4  = RS2_IDX - rs2_dec
ℓ5  = IMM_LO - imm_lo_dec
ℓ6  = IMM_HI - imm_hi_dec
ℓ7  = WritesAluToRd - writes_alu_to_rd_dec
ℓ8  = WritesMemToRd - writes_mem_to_rd_dec
ℓ9  = PreservesRd - preserves_rd_dec
ℓ10 = IsJal - is_jal_dec
ℓ11 = IsJalr - is_jalr_dec
ℓ12 = IsBranch - is_branch_dec
ℓ13 = IsLoad - is_load_dec
ℓ14 = IsStore - is_store_dec
ℓ15 = UsesRs2 - uses_rs2_dec
ℓ16 = AdvanceArchPc - is_last_in_sequence_dec
ℓ17 = ALU_OUT_LO - alu_result_lo
ℓ18 = ALU_OUT_HI - alu_result_hi
ℓ19 = STEP_PC_LO - step_pc_result_lo
ℓ20 = STEP_PC_HI - step_pc_result_hi
ℓ21 = JUMP_TARGET_LO - jump_target_result_lo
ℓ22 = JUMP_TARGET_HI - jump_target_result_hi
ℓ23 = MEM_ADDR_LO - mem_addr_result_lo
ℓ24 = MEM_ADDR_HI - mem_addr_result_hi
ℓ25 = BranchTaken - branch_taken_result
ℓ26 = BranchTakenMux - IsBranch * BranchTaken
ℓ27 = handoff_uses_rs2 - uses_rs2_dec
ℓ28 = handoff_is_load - is_load_dec
ℓ29 = handoff_is_store - is_store_dec
ℓ30 = handoff_mem_width - mem_width_dec
ℓ31 = handoff_mem_unsigned - mem_unsigned_dec
ℓ32 = handoff_is_first_in_sequence - is_first_in_sequence_dec
ℓ33 = handoff_is_last_in_sequence - is_last_in_sequence_dec
```

and proves:

```text
0 = ℓ0 + γ_lookup_link · ℓ1 + γ_lookup_link^2 · ℓ2 + ... + γ_lookup_link^33 · ℓ33
```

---

## 6. Stage 2: Twist Memory Checking

### 6.0 Shared Stage-2 cycle point

```text
r_twist_cycle ∈ K^{CYCLE_BITS}
```

### 6.1 Register-file domain and ports

The register-file domain:

```text
0..31   -> x0..x31 (architectural integer registers)
32..39  -> persistent virtual registers
40..47  -> temporary virtual registers
48..126 -> reserved virtual-register space
127     -> ⊥_reg (sink for no-write rows and x0 writes)
```

`ADDR_REG_BITS = 7` (128-point hypercube, active slots 0..127).

Twist objects over `C_reg`:

- committed:
  - `RegIncLo(j)`, `RegIncHi(j)`: write delta limbs per cycle,
  - `RegRa1(a, j)`: one-hot read-address for rs1,
  - `RegRa2(a, j)`: one-hot read-address for rs2,
  - `RegWa(a, j)`: one-hot write-address for rd.
- virtual:
  - `RegValLo(a, j)`, `RegValHi(a, j)`: defined only through the per-limb
    Val-from-Inc relations.

Port meanings:

- `RegRa1` always reads `RS1_IDX`.
- `RegRa2` reads `RS2_IDX` when `UsesRs2 = 1`, else reads `⊥_reg`.
- `RegWa` writes:
  - `RD_IDX` when `WritesAluToRd = 1` or `WritesMemToRd = 1`, and `RD_IDX ≠ 0`,
  - `⊥_reg` when `PreservesRd = 1` or `RD_IDX = 0`.

Sink semantics:

```text
RegValLo(⊥_reg, 0) = 0
RegValHi(⊥_reg, 0) = 0
RegValLo(⊥_reg, j+1) = RegValLo(⊥_reg, j)
RegValHi(⊥_reg, j+1) = RegValHi(⊥_reg, j)
RegIncLo(j) = 0 whenever RegWa points to ⊥_reg
RegIncHi(j) = 0 whenever RegWa points to ⊥_reg
```

x0 semantics:

```text
RegValLo(0, 0) = 0
RegValHi(0, 0) = 0
RegValLo(0, j+1) = RegValLo(0, j) = 0
RegValHi(0, j+1) = RegValHi(0, j) = 0
```

All writes to x0 are routed to `⊥_reg` instead, so x0 is never modified.

Normative virtual-register rule:

- any value that persists across more than one lowered row must live in the
  authenticated limb pair `(RegValLo(a, j), RegValHi(a, j))` for some
  virtual-register address `a ∈ {32..126}`,
- row-local auxiliary witness may not be used to carry values across rows,
- a conforming lowering must not rely on implicit sequence-local scratch state
  outside the authenticated register timeline,
- temporary virtual registers `40..47` are **write-before-read within each
  lowered sequence**,
- the first read of a temporary virtual register in a sequence must be preceded
  by a write to that same register earlier in the same committed sequence,
- correctness theorems for lowered sequences must therefore hold for arbitrary
  prior values of temporary virtual registers, since a conforming sequence may
  not depend on stale temporary-register contents from earlier sequences.

### 6.2 Register-file lane linkage

Stage 2 opens the relevant main-lane columns from `C_lane` at `r_twist_cycle`.

Register read claims (two limbs each):

```text
rv_rs1_lo_claim = RS1_LO
rv_rs1_hi_claim = RS1_HI
rv_rs2_lo_claim = RS2_LO
rv_rs2_hi_claim = RS2_HI
```

Register write claim:

```text
wv_reg_lo_claim = (WritesAluToRd + WritesMemToRd) * RD_NEXT_LO
wv_reg_hi_claim = (WritesAluToRd + WritesMemToRd) * RD_NEXT_HI
```

With sink routing enforcing `wv_reg_claim = 0` when `RegWa` points to `⊥_reg`.

Register read/write batch:

Stage 2 samples `γ_reg` and proves one explicit batched identity matching the
two register-read claims and one register-write claim to the authenticated Twist
objects `RegValLo`, `RegValHi`, `RegIncLo`, `RegIncHi`, `RegRa1`, `RegRa2`,
and `RegWa`.

The register `Val`-from-`Inc` relation remains a separate soundness-carrying
subclaim. Stage 2 does not collapse the whole register subsystem into one opaque
"registers passed" proof.

The batch includes rs1 and rs2 read claims and one rd write claim, each as a
paired `(lo32, hi32)` value claim.

### 6.2a Stage-2 linkage batch

Stage 2 samples `γ_twist_link` and checks:

```text
m0  = rv_rs1_lo_claim - RS1_LO
m1  = rv_rs1_hi_claim - RS1_HI
m2  = rv_rs2_lo_claim - RS2_LO
m3  = rv_rs2_hi_claim - RS2_HI
m4  = wv_reg_lo_claim - ((WritesAluToRd + WritesMemToRd) * RD_NEXT_LO)
m5  = wv_reg_hi_claim - ((WritesAluToRd + WritesMemToRd) * RD_NEXT_HI)
m6  = handoff_is_load * (MEM_VAL_LO - rv_ram_word_lo)
m7  = handoff_is_load * (MEM_VAL_HI - rv_ram_word_hi)
m8  = handoff_is_store * (MEM_VAL_LO - RS2_LO)
m9  = handoff_is_store * (MEM_VAL_HI - RS2_HI)
m10 = handoff_is_store * (wv_ram_word_lo - MEM_VAL_LO)
m11 = handoff_is_store * (wv_ram_word_hi - MEM_VAL_HI)
m12 = (1 - handoff_is_load - handoff_is_store) * MEM_VAL_LO
m13 = (1 - handoff_is_load - handoff_is_store) * MEM_VAL_HI
```

Batched as:

```text
0 = m0 + γ_twist_link · m1 + ... + γ_twist_link^13 · m13
```

On load rows, `MEM_VAL` carries the raw authenticated 64-bit RAM word. This is
the final architectural load value for native `LD`, and the temporary virtual
register payload for lowered narrow loads. On store rows, `MEM_VAL` is
constrained to match the current `RS2` selector, which may denote the
architectural `rs2` value or an intermediate blended virtual register.

The authenticated RAM-word claims `rv_ram_word_*` and `wv_ram_word_*` are
constrained entirely inside the RAM Twist read/write relation. Under the
Jolt-style RAM write-value virtualization rule, store rows satisfy
`wv_ram_word_* = rv_ram_word_* + RamInc*`, while load and no-op rows satisfy
`RamInc* = 0`. The Stage-2 linkage batch additionally binds the authenticated
store write value to the intended payload:

```text
handoff_is_store = 1 -> wv_ram_word = MEM_VAL = RS2
```

For native `SD`, this is the architectural store word. For `VStoreAligned64`,
this is the already-blended aligned word carried through the committed virtual
register path. Narrow-load extraction and narrow-store blending occur only on
the separate pure Stage-1 rows from the lowered sequence.

### 6.2b Register temporal consistency consequence

Define the limb reassembly map:

```text
UInt64(lo, hi) = lo + 2^32 · hi
```

For the architectural register projection:

```text
forall j < N, idx in {0..31}:
  PreState(j).x[idx] = UInt64(RegValLo(idx, j), RegValHi(idx, j))
forall j < N-1, idx in {0..31}:
  PostState(j).x[idx] = UInt64(RegValLo(idx, j+1), RegValHi(idx, j+1))
```

The virtual-register projection uses the same authenticated timeline on the
virtual address range `idx ∈ {32..126}`.

### 6.3 RAM domain and ports

The RAM domain:

```text
0..2^ADDR_RAM_BITS - 1   -> addressable RAM doublewords
```

RAM address chunking parameters:

```text
RAM_ADDR_D >= 1
ADDR_RAM_BITS
  = RAM_CHUNK_BITS[0] + RAM_CHUNK_BITS[1] + ... + RAM_CHUNK_BITS[RAM_ADDR_D - 1]
```

These chunk parameters are public, fixed before `root0`, and included in
`KernelMetaPub`. They determine how the committed RAM-address family is
partitioned so the prover may use the local Jolt-style RAM algorithm even when
the full RAM address space is too large for a single committed address
polynomial.

Twist objects over `C_ram`:

- committed:
  - `RamIncLo(j)`, `RamIncHi(j)`: cycle-only RAM delta limbs,
  - `RamA_i(a_i, j)` for `i ∈ {0..RAM_ADDR_D-1}`: chunk-`i` committed one-hot
    RAM-address factors over `2^{RAM_CHUNK_BITS[i]} × T`.
- virtual:
  - `RamA(a, j)`: the merged RAM one-hot address family over the full RAM
    address hypercube,
  - `RamValLo(a, j)`, `RamValHi(a, j)`.

Virtual merged-address definition:

```text
For a = (a_0, a_1, ..., a_{RAM_ADDR_D - 1}) with each a_i in the chunk-i domain,
RamA(a, j) = ∏_{i=0}^{RAM_ADDR_D - 1} RamA_i(a_i, j)

flatten_ram_addr(a)
  = Σ_{i=0}^{RAM_ADDR_D - 1}
      a_i · 2^{Σ_{k=i+1}^{RAM_ADDR_D - 1} RAM_CHUNK_BITS[k]}
```

Stage 2 performs RAM read checking, write checking, `Val` evaluation, RAF
support, and guest-address support **as if** `d = 1`, i.e. over the virtual
merged `RamA`. A separate RAM `ra`-virtualization sumcheck binds every queried
evaluation of `RamA` back to the committed chunk factors `RamA_i`.

Port meanings:

- `active_mem = handoff_is_load + handoff_is_store`,
- when `active_mem = 1`, each committed row of every `RamA_i` has Hamming
  weight `1` and together they encode the active `ram_word_addr`,
- when `active_mem = 0`, every committed row of every `RamA_i` is all zero,
- `RamIncLo = RamIncHi = 0` whenever `handoff_is_store = 0`,
- on load rows, the merged RAM address is active, the authenticated current RAM
  word is exposed as `rv_ram_word_*`, and the virtual writeback is a no-op
  because `RamInc* = 0`,
- on store rows, the merged RAM address is active, the authenticated current
  RAM word is read at that same address, and the effective write value is
  virtualized as `wv_ram_word_* = rv_ram_word_* + RamInc*`.

Zero-row semantics:

```text
active_mem(j) = 0 -> forall i, forall a_i: RamA_i(a_i, j) = 0
handoff_is_store(j) = 0 -> RamIncLo(j) = 0
handoff_is_store(j) = 0 -> RamIncHi(j) = 0
```

### 6.3a Memory width handling

RV64IM supports byte (8-bit), halfword (16-bit), word (32-bit), and doubleword
(64-bit) memory accesses. Width handling is enforced jointly by Stage 1 and
Stage 2:

- Stage 1 proves the effective address and the natural-alignment predicate
  `Align(mem_width_dec, MEM_ADDR)`.
- `Align` is a direct arithmetic predicate on `ram_byte_off` / low address
  bits; it does not require a dedicated alignment lookup family or a separate
  extra RAM row.
- Stage 2 derives
  `MEM_ADDR - RAM_BASE = 8 * ram_word_addr + ram_byte_off`
  with `ram_byte_off ∈ {0..7}`.
- The natural-alignment predicate is the explicit arithmetic relation:
  ```text
  Align(1, MEM_ADDR) = 1
  Align(2, MEM_ADDR) = 1  iff  ram_byte_off mod 2 = 0
  Align(4, MEM_ADDR) = 1  iff  ram_byte_off mod 4 = 0
  Align(8, MEM_ADDR) = 1  iff  ram_byte_off = 0
  ```
  Equivalently, on the derived residue `ram_byte_off`:
  ```text
  width = 1 -> ram_byte_off ∈ {0,1,2,3,4,5,6,7}
  width = 2 -> ram_byte_off ∈ {0,2,4,6}
  width = 4 -> ram_byte_off ∈ {0,4}
  width = 8 -> ram_byte_off ∈ {0}
  ```
- The Stage-2 RAM protocol owns only **aligned 64-bit RAM rows**:
  - native `LD` and `VLoadAligned64` perform a pure authenticated 64-bit read,
    expose the raw word as `MEM_VAL`, and may write it into an architectural or
    virtual register,
  - native `SD` and `VStoreAligned64` perform a pure authenticated 64-bit
    write, consuming the current `RS2` selector as the 64-bit word to write.
- Narrow loads and stores are real multi-row lowered sequences:
  - `VLoadAligned64` owns the RAM read and writes the raw word into a temporary
    virtual register,
  - `VExtractLoad` is a pure Stage-1 row proving
    `extract_extend(word, off, w, unsigned)`,
  - `VBlendStore` is a pure Stage-1 row proving
    `blend(word, src, off, w)`,
  - `VStoreAligned64` owns the RAM write on the already-blended aligned word.
- Concretely, `extract_extend(word, off, w, unsigned)` returns the width-`w`
  byte slice of `word` starting at byte offset `off`, then zero-extends or
  sign-extends it to 64 bits according to `unsigned`.
- `blend(word, src, off, w)` returns the aligned 64-bit word obtained by
  replacing bytes `[off, off + w)` of `word` with the low `w` bytes of `src`.

Natural alignment requirements:

| Width | Alignment | Allowed `ram_byte_off` |
|-------|-----------|-------------------------|
| Byte (8-bit) | 1 byte | `0..7` |
| Halfword (16-bit) | 2 bytes | `{0,2,4,6}` |
| Word (32-bit) | 4 bytes | `{0,4}` |
| Doubleword (64-bit) | 8 bytes | `{0}` |

Therefore Stage 2 uses one merged authenticated RAM-address family per row.
Logical reads and logical writes share that address family in the Jolt style;
there are no per-byte RAM Twist port families in this kernel.

### 6.4 RAM lane linkage

Required main-lane openings from `C_lane` at `r_twist_cycle` include at least:

```text
RS1_LO, RS1_HI, RS2_LO, RS2_HI,
RD_NEXT_LO, RD_NEXT_HI,
MEM_ADDR_LO, MEM_ADDR_HI,
MEM_VAL_LO, MEM_VAL_HI,
WritesAluToRd, WritesMemToRd, PreservesRd,
IsLoad, IsStore, UsesRs2,
RD_IDX, RS1_IDX, RS2_IDX
```

Plus `C_decode_handoff` openings at `r_twist_cycle`.

### 6.4a RAM temporal consistency consequence

For the active RAM-word projection:

```text
forall j < N, word in RAMWords:
  PreState(j).mem_word[word] = UInt64(RamValLo(word, j), RamValHi(word, j))
forall j < N-1, word in RAMWords:
  PostState(j).mem_word[word] = UInt64(RamValLo(word, j+1), RamValHi(word, j+1))
```

### 6.4b Stage-2 temporal closure object

```text
Stage2TemporalContext {
    reg_timeline,
    ram_timeline,
    row_links,
}
```

Normative meaning:

- `reg_timeline` is the single authenticated register-value evolution over all
  active rows `j ∈ [0, N]`, concretely the paired limb timelines
  `(RegValLo, RegValHi)`,
- `ram_timeline` is the single authenticated RAM-value evolution over all
  active rows `j ∈ [0, N]`, concretely the paired limb timelines
  `(RamValLo, RamValHi)`,
- `row_links` packages the consequences that each row's authenticated reads come
  from time `j`, each row's authenticated writes land in time `j + 1`, and
  untouched locations preserve their prior value,
- together these objects provide the state portion of
  `PostState(j) = PreState(j+1)` for every active adjacent pair.

### 6.5 RAM RAF support relation

Stage 2 also owns a Jolt-style RAM-address support relation tying the committed
RAM one-hot family back to the numeric aligned memory address.

Define the address-only virtual merged one-hot family at the Stage-2 cycle
point `r_twist_cycle`:

```text
ra_mem(a) = Σ_j eq(r_twist_cycle, j) · RamA(a, j)
hw_ram_i(j) = Σ_{a_i} RamA_i(a_i, j)   for each i ∈ {0..RAM_ADDR_D - 1}
```

Define the aligned byte address carried by the current row:

```text
aligned_mem_addr = MEM_ADDR - ram_byte_off
```

Define the RV64IM unmap polynomial over the fixed RAM-word domain:

```text
unmap_rv64im(a) = RAM_BASE + 8 * flatten_ram_addr(a)
```

Let `active_mem = handoff_is_load + handoff_is_store`. Then Stage 2 proves the
support identities:

```text
Σ_a ra_mem(a) · unmap_rv64im(a) = active_mem · aligned_mem_addr
∀ i:
  Σ_j eq(r_twist_cycle, j) · (hw_ram_i(j) - active_mem(j)) = 0
∀ i:
  Σ_j eq(r_twist_cycle, j) · (hw_ram_i(j)^2 - hw_ram_i(j)) = 0
```

The first equation is the numeric guest-address support identity. The factorwise
Hamming and Hamming-Booleanity equations are the Jolt-style one-hot / zero-row
constraints on the committed chunk factors `RamA_i`, needed because no-op
memory rows are represented as all-zero address rows instead of sink-routed
one-hot rows.

The normalized address point `r_addr_ram` is shared across the RAM read/write,
RAM `Val`-from-`Inc`, RAM RAF support, RAM guest-address support, and RAM
`ra`-virtualization relations after Stage-2 address-round alignment. The
factorwise Hamming and Hamming-Booleanity claims use the Stage-2 cycle point
`r_twist_cycle` only.

There is one RAF support equation for the virtual merged `RamA`, together with
one explicit RAM `ra`-virtualization equation binding that virtual family back
to the committed chunk factors `RamA_i`. Concretely, at the queried RAM point
`r_addr_ram = (r_0, r_1, ..., r_{RAM_ADDR_D - 1})` and cycle point
`r_twist_cycle`, Stage 2 proves:

```text
RamA(r_addr_ram, r_twist_cycle)
  = Σ_j eq(r_twist_cycle, j) · ( ∏_{i=0}^{RAM_ADDR_D - 1} RamA_i(r_i, j) )
```

### 6.6 Twist subclaims

For the register subsystem and the RAM subsystem separately, the proof keeps the
soundness-carrying Twist relations explicit.

Normative Stage-2 batching rule:

- register read/write checking is carried by one explicit batched proof,
- RAM read/write checking is carried by one explicit batched proof over the
  virtual merged `RamA`,
- `Val`-from-`Inc` evaluation remains separate for registers and RAM,
- RAM RAF support remains separate,
- RAM guest-address support remains separate,
- per-factor RAM Hamming and Hamming-Booleanity remain separate,
- RAM `ra`-virtualization remains separate,
- address-correctness remains separate for every register one-hot family and
  for the virtual merged RAM one-hot family.

Stage-2 batching is therefore partial and explicit. It does not collapse the
whole stage into one opaque "memory passed" proof.

### 6.7 Address-correctness obligations for Stage 2

Address-correctness for every Stage-2 address family:

- `RegRa1`, `RegRa2`, `RegWa`,
- virtual merged `RamA`.

The committed RAM chunk factors `RamA_i` do not carry separate guest-address
equations. They are bound to the guest-address statement only through the
explicit RAM `ra`-virtualization identity from §6.5.

Stage-2 raw-address identities:

```text
Σ_a RegRa1(a, j) · a = RS1_IDX(j)

Σ_a RegRa2(a, j) · a
  = handoff_uses_rs2(j) · RS2_IDX(j) + (1 - handoff_uses_rs2(j)) · 127

Σ_a RegWa(a, j) · a
  = (WritesAluToRd(j) + WritesMemToRd(j)) · (1 - eq_zero(RD_IDX(j))) · RD_IDX(j)
  + (1 - (WritesAluToRd(j) + WritesMemToRd(j)) · (1 - eq_zero(RD_IDX(j)))) · 127
```

where `eq_zero(RD_IDX)` is `1` when `RD_IDX = 0`, proved via the decode
channel (since `rd_dec = 0` forces `PreservesRd = 1`, the write-active ×
non-zero-RD_IDX product is computable from the existing boolean flags).

Simplified form using the decode convention `PreservesRd = 1` when `rd = 0`:

```text
Σ_a RegWa(a, j) · a
  = (WritesAluToRd(j) + WritesMemToRd(j)) · RD_IDX(j)
  + PreservesRd(j) · 127
```

This works because when `RD_IDX = 0`, `PreservesRd = 1`, so the second term
selects the sink. When `RD_IDX ≠ 0` and a write is active, `PreservesRd = 0`,
so only the first term contributes.

RAM word-address identities:

```text
ram_byte_addr(j) = MEM_ADDR(j) - RAM_BASE
ram_byte_addr(j) = 8 * ram_word_addr(j) + ram_byte_off(j)
0 <= ram_byte_off(j) < 8

active_mem(j) = handoff_is_load(j) + handoff_is_store(j)

Σ_a RamA(a, j) · flatten_ram_addr(a) = active_mem(j) * ram_word_addr(j)
```

The address decomposition above is an integer statement on the limb-reassembled
64-bit address, not merely a field equation. On every active memory row:

```text
UInt64(MEM_ADDR_LO(j), MEM_ADDR_HI(j)) - RAM_BASE
  = 8 * ram_word_addr(j) + ram_byte_off(j)
0 <= ram_word_addr(j) < 2^ADDR_RAM_BITS
0 <= ram_byte_off(j) < 8
```

The aligned RAM witness index is therefore unique. The virtual merged RAM
address family carries no sink row; inactive memory rows are all-zero rows
instead:

```text
active_mem(j) = 0 -> forall a: RamA(a, j) = 0
active_mem(j) = 1 -> Σ_a RamA(a, j) = 1
```

Natural-alignment constraints additionally require:

```text
Align(handoff_mem_width(j), MEM_ADDR(j)) = 1
```

### 6.8 Initial-state authentication

Register file:

```text
forall a in {0..31}:
  RegValLo(a, 0) = init_reg_lo[a]
  RegValHi(a, 0) = init_reg_hi[a]
forall a in {32..126}:
  RegValLo(a, 0) = 0
  RegValHi(a, 0) = 0
RegValLo(127, 0) = 0   // sink
RegValHi(127, 0) = 0   // sink
```

where `init_reg_lo[a] = init_reg[a] mod 2^32` and
`init_reg_hi[a] = floor(init_reg[a] / 2^32)`. In particular, `init_reg[0] = 0`
(x0 hardwired), `init_reg[2] = initial_sp` (stack pointer), and other
registers follow the program's initial state.

RAM:

```text
forall a in {0..2^ADDR_RAM_BITS - 1}:
  RamValLo(a, 0) = init_ram_word_lo[a]
  RamValHi(a, 0) = init_ram_word_hi[a]
```

`init_ram_word_lo[a] = init_ram_word[a] mod 2^32` and
`init_ram_word_hi[a] = floor(init_ram_word[a] / 2^32)`, where `init_ram_word`
is the 64-bit packed RAM image derived from the loaded ELF data segment, zeroed
heap, and initial stack.

Normative initialization rule:

- this kernel uses the authenticated non-zero-initialization `Val` identity,
  not synthetic preload writes,
- the transcript-bound metadata fixes
  `initialization_mode_id = authenticated_nonzero_init`,
- `init_reg` and `init_ram_word` must be public or otherwise authenticated
  before any Stage-2 challenge is sampled.

Concretely, the register `Val`-from-`Inc` relation is grounded per limb as:

```text
RegValLo(a, r_cycle) - init_reg_lo_mle(a)
  = Σ_j RegIncLo(j) · RegWa(a, j) · LT(j, r_cycle)

RegValHi(a, r_cycle) - init_reg_hi_mle(a)
  = Σ_j RegIncHi(j) · RegWa(a, j) · LT(j, r_cycle)
```

and the RAM `Val`-from-`Inc` relation is grounded per limb as:

```text
RamValLo(a, r_cycle) - init_ram_word_lo_mle(a)
  = Σ_j RamIncLo(j) · RamA(a, j) · LT(j, r_cycle)

RamValHi(a, r_cycle) - init_ram_word_hi_mle(a)
  = Σ_j RamIncHi(j) · RamA(a, j) · LT(j, r_cycle)
```

with the same sink-specialized and final-time-specialized consequences used by
the Stage-2 subclaims.

---

## 7. Opcode Coverage

### 7.1 Supported subset

This v1 kernel covers all RV64IM instructions listed in §0.3.

### 7.2 Per-class proof obligations

Architectural coverage is defined by deterministic lowering into expanded
bytecode (§5.3.4) plus per-row soundness of the resulting lowered rows.

The proof obligations are:

1. **Lowering determinism.**
   The verifier accepts only bytecode produced by the deterministic lowering
   algorithm for the public ROM image and the declared lowering version.
2. **Per-row correctness.**
   Every expanded row is authenticated against `C_bytecode_table`, and its
   row-local ALU, control-flow, and RAM effects are proved by Stage 1, Stage 2,
   and the root row relation.
3. **Sequence-boundary correctness.**
   Non-final rows preserve the architectural PC (`PC_NEXT = PC`), while
   sequence-final rows apply the architectural control-flow result.
4. **Committed-sequence correctness.**
   Every multi-row lowering must satisfy the fixed-sequence correctness theorem
   from §5.3.3.
5. **Committed-sequence determinism.**
   Every multi-row lowering must satisfy the fixed-sequence determinism theorem
   from §5.3.3.
6. **Advice-sequence specialization.**
   Any lowered sequence that uses `VAdvice` must satisfy the advice-specialized
   instance of those same fixed-sequence obligations.

Normative lowering classes:

- R-type, I-type, `LUI`, `AUIPC`, `JAL`, `JALR`, branches, `LD`, `SD`, and the
  non-div/rem multiply instructions may lower to one native row.
- W-variants may lower to a short sequence using `VTruncate32` and
  `VSignExtend32`.
- Narrow loads/stores (`LB`, `LBU`, `LH`, `LHU`, `LW`, `LWU`, `SB`, `SH`, `SW`)
  lower through aligned 64-bit RAM word access plus `VExtractLoad` or
  `VBlendStore`.
- `DIV*` and `REM*` lower through advice-backed verification sequences that use
  the explicit validity relations from §5.3.1.
- `ECALL` lowers to a terminating row; `FENCE` lowers to a no-op row.

### 7.3 Invalid instructions

The expanded bytecode table outputs `valid = 0` for every unsupported or
malformed lowered row.
The proof rejects whenever `valid ≠ 1`.

---

## 8. Stage 3: Continuity and Bridge into SuperNeo Main Lane

### 8.0 Shared Stage-3 cycle point

```text
r_shift ∈ K^{CYCLE_BITS}
```

### 8.1 Continuity support relation

Stage 3 uses:

- current-row openings from `C_lane` at `r_shift`,
- authenticated shifted virtual values from `LaneShiftProof`,
- the folded bytecode-`raf` claims from the Stage-1 bytecode Shout instance,
- one random-point continuity identity evaluated at `r_shift` and masked by
  `PairMask_N`.

```text
PairMask_N(j) = 1 for 0 ≤ j < N-1
PairMask_N(j) = 0 otherwise
```

### 8.1a LaneShift reduction

For RV64IM expanded bytecode, the shifted lane columns still use the
architectural (`unexpanded`) PC, not the expanded bytecode index:

```text
LaneShiftProof {
    point: r_shift,
    columns: [PC_LO, PC_HI],
    claimed_shift_values: [shift_pc_lo, shift_pc_hi],
    reduction_proof,
}
```

Only architectural PC needs shifting in `C_lane`. Expanded-bytecode adjacency is
owned by the bytecode Shout `raf` claims, not by extra main-lane columns.

### 8.1b ContinuityCheck

Stage 3 opens `PC_NEXT_LO`, `PC_NEXT_HI` from `C_lane @ r_shift` and checks:

```text
δ_pc_lo = PairMask_N(r_shift) * (shift_pc_lo - PC_NEXT_LO)
δ_pc_hi = PairMask_N(r_shift) * (shift_pc_hi - PC_NEXT_HI)

δ_pc_lo + β1 * δ_pc_hi = 0
```

Start-boundary rule:

- let `j0_bits = 0^{CYCLE_BITS}`,
- Stage 3 opens `PC_LO` and `PC_HI` from `C_lane @ j0_bits`,
- and checks `PC_LO(0) = initial_state.pc_lo` and
  `PC_HI(0) = initial_state.pc_hi`.

Final-boundary rule:

- The last active row `j = N-1` is excluded from the continuity predecessor
  mask.
- This kernel version proves a **full halted execution claim**, not a
  prover-chosen valid prefix claim.
- Therefore the last active row must be a terminating sequence-final `ECALL`
  row from the committed expanded bytecode table.
- Valid-prefix proofs whose last active row is non-terminating are
  non-conforming.

### 8.1c Stage-3 semantic PC bridge

The theorem-level Stage-3 semantic bridge consumed by strong kernel soundness
is:

```text
PcAdjacentBridge
```

Normative meaning:

- for every semantic adjacent pair `j < N-1`, the checked Stage-3 shift witness
  for row `j`, the current-row continuity witness, and the authenticated
  row-binding openings for rows `j` and `j + 1` together determine:

  ```text
  PostState(j).pc = PreState(j+1).pc
  ```

- this bridge consumes the checked Stage-3 support objects from §8.1a and
  §8.1b together with the authenticated row-binding / bridge-binding path from
  §9.4,
- it is the theorem-level Stage-3 object used by the adjacent-state closure
  from §4.3a,
- it is not a direct opening claim, not a new reduction layer, and not an
  audit/provenance summary.

### 8.2 What is projected

All semantic expanded rows `j ∈ [0, N)` are projected into the theorem package
through the root main-lane row-local CCS relation from §11. A conforming proof
may expose that projection either as per-row `PreparedStep_j` objects or as an
equivalent folded root proof package, but the kernel theorem is defined over
the expanded semantic trace itself, not merely over exported summaries of it. A
future bridge layer may additionally expose architectural-sequence boundaries,
but the kernel proof object is defined over the expanded trace.

The packaging of that root theorem is parameterized by one proof-bound fold
schedule:

```text
FoldSchedule ::= WholeTrace | RowsPerChunk(n), where n >= 1
```

Let the active semantic interval be `[0, N)`. The schedule induces one ordered
contiguous chunk partition:

- `WholeTrace` means one chunk covering all semantic rows,
- `RowsPerChunk(n)` means consecutive chunks of size at most `n`, with every
  non-final chunk of size exactly `n`,
- there are no overlaps, no skipped rows, and no out-of-order chunks.

For each chunk `q`, the root theorem runs exactly:

- one `Π_CCS` over the fresh semantic rows in that chunk plus the carried CE
  claims from the previous chunk,
- one `Π_RLC` using transcript-derived ring-scalar challenges
  `ρ_i ∈ 𝒞 ⊂ R_F`,
- one `Π_DEC`.

`RowsPerChunk(1)` is therefore the legacy per-row fold cadence. The theorem-
facing default for RV64IM is `WholeTrace`.

### 8.3 What is not projected

The following are deferred auxiliary obligations:

- expanded-bytecode fetch correctness,
- bytecode metadata authentication and decode correctness,
- ALU support-relation correctness,
- branch-condition correctness,
- register-history correctness,
- RAM-history correctness,
- RAM RAF support checks,
- expanded-bytecode successor/authentication checks,
- continuity support checks.

The bridge creates no new proof object for the deterministic row-extraction
part, but this does **not** remove any of the separate Stage-1, Stage-2, or
Stage-3 soundness obligations.

### 8.4 Binding between kernel rows and root commitments

The aggregate identity `C_lane = Σ_j c_j` is **not** the binding mechanism.

For this kernel version, the normative bridge mechanism is:

- explicit row-opening / row-membership proofs from `C_lane`,
- followed by `RootEncode(z_j)`,
- followed by an accepted root main-lane CCS proof package whose carried
  `FoldSchedule` and chunk partition include the authenticated semantic row,
- with recomputation of the root Ajtai commitment
  `PreparedStep_j.mcs.c = Ajtai_commit(Z_j)` required whenever a private
  `PreparedStep_j` helper is exported.

Formal linear row decomposition is a possible optimization, but it is not a
conforming alternative under this spec.

---

## 9. Opening Boundary

### 9.1 OpeningClaim

```text
OpeningClaim {
    source,
    commitment_id,   // Lane | BytecodeRa | AluRa | BranchRa | DecodeHandoff |
                     // RegTwist | RamTwist | RomTable | BytecodeTable |
                     // AluSubtables | BranchTable | RootProver(...)
    family_object_id,
    point,
    selected_refs,
    digest,
}
```

`family_object_id` names one committed family object under the chosen
`commitment_id`. `selected_refs` is the canonical list of selected members of
that family at `point`, ordered in the local family registry order. Each
selected ref carries enough information to bind:

- the logical member index inside the family,
- the logical opening identity for that exact `(family_object_id, point,
  logical_member_index)` request,
- the opened value digest.

The theorem-facing opening boundary owns committed family objects and canonical
selected refs. It does not require proof-style transport of one fresh exact
opening witness per consumer of the same family work.

### 9.2 Grouping rule

There are two distinct grouping notions:

- direct kernel opening claims are keyed by
  `(commitment_id, family_object_id, point)`,
- later claim-space reduction groups are keyed by the narrower
  `(source, domain, point)` rule owned by `time_opening`, with member claims
  ordered canonically by their manifest ordinals within that group.

These must not be conflated. The first identifies one family-local direct
opening surface; the second identifies one transcript-local reduction bucket.

Same-surface collision rule:

- if two required direct openings land on the same
  `(commitment_id, family_object_id, point)`, they must alias to one canonical
  direct opening surface,
- consumers of that same-family surface contribute additional `selected_refs`
  to that one claim instead of creating parallel claims,
- canonical manifest order breaks same-surface ties by the local family member
  order inside `selected_refs`,
- two distinct claims with the same
  `(commitment_id, family_object_id, point)` are illegal duplicates,
- two distinct selected refs with the same logical opening identity are illegal
  duplicates.

The opening boundary is split into two disjoint ownership buckets:

- `KernelOpeningManifest`: claims emitted by this 3-stage kernel before handoff,
- `RootOpeningManifest`: claims emitted later by the root prover.

`time_opening` verifies the union of both manifests, but the source/ownership
tag must remain explicit for every claim.

### 9.3 Canonical manifest ordering and encoding

For this kernel boundary, the canonical `KernelOpeningManifest` order is the
exact numbered stage-local order fixed above. The generic sort key in this
section does **not** reorder that manifest. It is reserved only for later
owners whose manifests are not already fixed by the kernel boundary, such as a
future non-empty root manifest or later claim-space summary objects.

Canonical `commitment_id` order:

```text
Lane
BytecodeRa
AluRa
BranchRa
DecodeHandoff
RegTwist
RamTwist
RomTable
BytecodeTable
AluSubtables
BranchTable
RootProver(...)
```

Canonical non-kernel-fixed manifest sort key:

```text
(commitment_id_order, family_object_id, point_arity, point_coordinates, selected_refs)
```

Normative rules:

- `selected_refs` must be strictly increasing in the local registry order of
  the referenced commitment family,
- `point_arity` is the number of coordinates in the evaluation point,
- `point_coordinates` are ordered exactly as the commitment family defines them
  in §13. For bivariate families this means address coordinates first, then
  cycle coordinates. For `C_ram`, this rule is polynomial-local: cycle-only for
  `RamIncLo/Hi`, and chunk-address bits first then cycle bits for each
  committed `RamA_i`,
- every point coordinate in `K` is serialized canonically as its two
  Goldilocks coefficients `(c0, c1)` in that order, each using the
  implementation's canonical field-element byte encoding,
- the manifest must not contain duplicate
  `(commitment_id, family_object_id, point)` entries,
- `LaneShiftProof` and other transcript-local reduction proofs are not
  `OpeningClaim`s and must not appear in either opening manifest.

### 9.4 Opening provenance

The soundness-carrying opening provenance chain is:

```text
root0 → committed family object → OpeningClaim(selected refs)
      → OpeningRefinement → RowProjectionWitness
      → RootMainLaneRowProof → BridgeBinding → claim summaries
```

This chain must remain explicit: commitment binding, selected-opening
authentication, semantic row projection, root main-lane row-proof checking, and
bridge binding are distinct obligations even when one implementation function
verifies them together. `PreparedStep` may exist as a private audit artifact,
but it is not itself the normative theorem-facing provenance object.

### 9.5 Rust-facing kernel boundary

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

`semantic_trace_rows` is the expanded-row trace after lowering, not the raw
architectural instruction trace.

`initial_state` includes at least:
- `pc_lo`, `pc_hi`: initial program counter (byte address),
- `registers[0..31]`: initial register values (x0 = 0, x2 = initial SP, etc.),
- `ram_image`: initial RAM contents (ELF data segment + zeroed heap/stack).

```text
KernelMetaPub {
    program_image_digest,
    initial_state_digest,
    rom_table_digest,
    bytecode_table_digest,
    alu_subtable_digests,
    branch_table_digest,
    transcript_seed_digest,
    protocol_version_id,
    lowering_version_id,
    root_params_id,
    variable_order_id,
    domain_shape_id,
    sink_convention_id,
    initialization_mode_id,
    program_word_count,
    bytecode_row_count,
    semantic_rows: N,
    padded_trace_length: T,
    pad_pc_lo,
    pad_pc_hi,
    ram_base,
    addr_ram_bits,
    ram_addr_d,
    ram_chunk_bits[0..ram_addr_d-1],
    cycle_bits,
}
```

Stage proof structures are split by stage as follows:

- `Stage1ShoutProof` includes expanded-bytecode authentication, the explicit
  entrypoint/start-boundary claim for `expanded_pc(0)`, folded bytecode-`raf`
  claims, ALU (with sub-channels), and branch-condition channel proofs.
- `Stage2TwistProof` includes register (2 read ports + 1 write port) and RAM
  (merged RAM-address family, zero-row Hamming Booleanity, cycle-only RAM
  increments, and RAM `ra` virtualization) proofs.
- `Stage3Proof` includes shift proof (PC only, no burst), continuity check,
  and row bindings.
- `RootMainLaneProof` includes the accepted row-local CCS proof package over
  the authenticated semantic rows from §11, exported either per row or in an
  equivalent folded form.

---

## 10. Soundness Accounting

The total soundness bound is parameterized by the instantiated Stage-1, Stage-2,
Stage-3, batching, PCS, Fiat-Shamir, and outer-proof channels:

```text
ε_total ≤ ε_stage1 + ε_stage2 + ε_stage3 + ε_batch + ε_PCS + ε_FS + ε_outer
```

with:

```text
ε_stage1 =
    ε_shout_core(bytecode)
  + ε_addr(bytecode)
  + ε_raf(bytecode)
  + sum over Stage-1 ALU sub-channels c of (ε_shout_core(c) + ε_addr(c))
  + ε_shout_core(branch)
  + ε_addr(branch)

ε_stage2 =
    sum over register read ports {Ra1, Ra2} of ε_twist_read(p)
  + ε_twist_write(reg)
  + ε_twist_val(reg)
  + sum over register address families {RegRa1, RegRa2, RegWa} of ε_addr(f)
  + ε_twist_read(RamA)
  + ε_twist_write(RamA)
  + ε_twist_val(ram)
  + ε_raf(RamA)
  + ε_addr(RamA)
  + sum over RAM chunk factors i of ε_hamming_bool(ram_i)
  + ε_ra_virtualize(ram)

ε_stage3 = ε_shift_reduce + ε_continuity

ε_batch = ε_reg_rw_batch + ε_ram_rw_batch + ε_lookup_link + ε_twist_link
```

---

## 11. Main-Lane CCS Embedding

### 11.1 Witness vector layout

```text
z[0]  = ONE = 1                (public, m_in = 1)
z[1]  = PC_LO
z[2]  = PC_HI
z[3]  = PC_NEXT_LO
z[4]  = PC_NEXT_HI
z[5]  = RS1_LO
z[6]  = RS1_HI
z[7]  = RS2_LO
z[8]  = RS2_HI
z[9]  = RD_NEXT_LO
z[10] = RD_NEXT_HI
z[11] = IMM_LO
z[12] = IMM_HI
z[13] = ALU_OUT_LO
z[14] = ALU_OUT_HI
z[15] = STEP_PC_LO
z[16] = STEP_PC_HI
z[17] = JUMP_TARGET_LO
z[18] = JUMP_TARGET_HI
z[19] = MEM_ADDR_LO
z[20] = MEM_ADDR_HI
z[21] = MEM_VAL_LO
z[22] = MEM_VAL_HI
z[23] = RD_IDX
z[24] = RS1_IDX
z[25] = RS2_IDX
z[26] = WritesAluToRd
z[27] = WritesMemToRd
z[28] = PreservesRd
z[29] = IsJal
z[30] = IsJalr
z[31] = IsBranch
z[32] = BranchTaken
z[33] = BranchTakenMux
z[34] = IsLoad
z[35] = IsStore
z[36] = UsesRs2
z[37] = AdvanceArchPc
```

Width `W = 38`. Public inputs: `x = [z[0]]`.

`z[23..25]` range over the full `Addr_reg` domain, not just architectural
register indices.

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

`RootEncode` is normative because it fixes the canonical witness encoding for a
semantic row. `PreparedStep_j` is not a required theorem-facing object. A
conforming proof may expose it as a private audit helper, but the public kernel
boundary is owned by:

- one committed root lane family for the full `38 × T` semantic-row object,
- canonical selected row refs into that committed family,
- an accepted root main-lane CCS proof package over the authenticated semantic
  rows, parameterized by a proof-carried `FoldSchedule`,
- bridge and stage claim summaries derived from those selected refs.

### 11.2a Root fold schedule

The root main-lane theorem package carries one theorem-facing fold schedule:

```text
FoldSchedule ::= WholeTrace | RowsPerChunk(n), where n >= 1
```

Normative rules:

1. the schedule is public proof metadata carried by the root theorem package,
2. the verifier derives the chunk count from that schedule and the active
   semantic row count; it is not a separate verifier input,
3. the schedule partitions the active semantic interval `[0, N)` into one
   ordered contiguous chunk list,
4. each chunk runs exactly one `Π_CCS`, one `Π_RLC`, and one `Π_DEC`,
5. each chunk’s `Π_RLC` samples typed ring-scalar challenges `ρ_i ∈ 𝒞 ⊂ R_F`
   from the carried backend challenge domain; arbitrary field-scalar mixing is
   non-conforming,
6. `WholeTrace` means one root fold round for the entire active semantic
   interval,
7. `RowsPerChunk(1)` reproduces the legacy per-row root fold cadence.

Normative rule for `RootEncode`:

- `z_j` is the raw 38-field semantic row used by the root main-lane row-local
  CCS,
- `w_j` is coordinates 1 through 37 inclusive of `z_j`,
- `Z_j` is the canonical norm-bounded witness representation consumed by the
  root prover for that row, defined as follows:
  1. let `m = 38`,
  2. let `D := d = 54`, the SuperNeo ring degree fixed by `Φ81(X) = X^54 + X^27 + 1`,
  3. let `cols = ceil(m / D)`,
  4. form the canonical padded witness vector
     `z_pad = [z_j[0], z_j[1], ..., z_j[37], 0, ..., 0] ∈ F^{cols * D}`,
     where padding zeros are appended only at the tail until the length is
     exactly `cols * D`,
  5. reshape `z_pad` into a `D × cols` matrix by columns: the entry at row
     `r ∈ [0, D)` and column `c ∈ [0, cols)` is `z_pad[c * D + r]`,
  6. apply the canonical Ajtai witness encoding induced by the public
     `root_params` to that `D × cols` matrix to obtain `Z_j`,
- equivalently, `Z_j ∈ F^{D × ceil(38 / D)}` with the column-major placement of
  the padded semantic row fixed exactly by the previous rule,
- any implementation helper such as
  `encode_vector_for_full_width(root_params, 38, z_j)` is conforming only if it
  produces exactly that same `Z_j`.

### 11.3 R1CS → CCS conversion

The 29 R1CS rows from §4.1 are converted via `r1cs_to_ccs(A, B, C)` where
`A`, `B`, `C` are `29 × 38` sparse matrices encoding the canonical row
triples:

```text
Row 0:  L = WritesAluToRd,              R = WritesAluToRd - ONE,              O = 0
Row 1:  L = WritesMemToRd,              R = WritesMemToRd - ONE,              O = 0
Row 2:  L = PreservesRd,                R = PreservesRd - ONE,                O = 0
Row 3:  L = IsJal,                      R = IsJal - ONE,                      O = 0
Row 4:  L = IsJalr,                     R = IsJalr - ONE,                     O = 0
Row 5:  L = IsBranch,                   R = IsBranch - ONE,                   O = 0
Row 6:  L = BranchTaken,                R = BranchTaken - ONE,                O = 0
Row 7:  L = IsLoad,                     R = IsLoad - ONE,                     O = 0
Row 8:  L = IsStore,                    R = IsStore - ONE,                    O = 0
Row 9:  L = UsesRs2,                    R = UsesRs2 - ONE,                    O = 0
Row 10: L = AdvanceArchPc,              R = AdvanceArchPc - ONE,              O = 0
Row 11: L = IsBranch,                   R = BranchTaken,                      O = BranchTakenMux
Row 12: L = WritesAluToRd + WritesMemToRd + PreservesRd - ONE,
        R = ONE,                        O = 0
Row 13: L = WritesAluToRd,              R = RD_NEXT_LO - ALU_OUT_LO,         O = 0
Row 14: L = WritesAluToRd,              R = RD_NEXT_HI - ALU_OUT_HI,         O = 0
Row 15: L = WritesMemToRd,              R = RD_NEXT_LO - MEM_VAL_LO,         O = 0
Row 16: L = WritesMemToRd,              R = RD_NEXT_HI - MEM_VAL_HI,         O = 0
Row 17: L = PreservesRd,                R = RD_NEXT_LO,                       O = 0
Row 18: L = PreservesRd,                R = RD_NEXT_HI,                       O = 0
Row 19: L = IsJal + IsJalr + BranchTakenMux,
        R = PC_NEXT_LO - JUMP_TARGET_LO,
        O = 0
Row 20: L = IsJal + IsJalr + BranchTakenMux,
        R = PC_NEXT_HI - JUMP_TARGET_HI,
        O = 0
Row 21: L = AdvanceArchPc - IsJal - IsJalr - BranchTakenMux,
        R = PC_NEXT_LO - STEP_PC_LO,   O = 0
Row 22: L = AdvanceArchPc - IsJal - IsJalr - BranchTakenMux,
        R = PC_NEXT_HI - STEP_PC_HI,   O = 0
Row 23: L = ONE - AdvanceArchPc,        R = PC_NEXT_LO - PC_LO,              O = 0
Row 24: L = ONE - AdvanceArchPc,        R = PC_NEXT_HI - PC_HI,              O = 0
Row 25: L = ONE - IsLoad - IsStore,     R = MEM_ADDR_LO,                     O = 0
Row 26: L = ONE - IsLoad - IsStore,     R = MEM_ADDR_HI,                     O = 0
Row 27: L = ONE - IsLoad - IsStore,     R = MEM_VAL_LO,                      O = 0
Row 28: L = ONE - IsLoad - IsStore,     R = MEM_VAL_HI,                      O = 0
```

---

## 12. Transcript Schedule

```text
1. transcript = Poseidon2Transcript::new(b"riscv64im-kernel")

2. absorb(
       C_lane,
       C_bytecode_ra,
       C_alu_ra,
       C_branch_ra,
       C_decode_handoff,
       C_reg,
       C_ram,
       C_rom_table,
       C_bytecode_table,
       C_alu_subtables,
       C_branch_table,
       meta_pub
   )
   --> root0 fixed.

3. Stage 1 (Shout):
   - sample r_lookup ∈ K^{CYCLE_BITS}
   - expanded-bytecode sumcheck → transcript
   - folded bytecode-raf claims (entrypoint / shift-side) → transcript
   - ALU sub-channel sumchecks (in canonical sub-channel order) → transcript
   - branch-condition sumcheck → transcript
   - address-correctness subchecks in canonical order → transcript
   - record terminal points (r_bytecode_addr, r_alu_addr, r_branch_addr)
   - sample γ_lookup_link
   - Stage-1 linkage batch → transcript

4. Stage 2 (Twist):
   - sample r_twist_cycle ∈ K^{CYCLE_BITS}
   - sample γ_reg
   - reg read/write batched sumcheck → transcript
   - reg Val-from-Inc sumcheck → transcript
   - sample γ_ram
   - ram read/write batched sumcheck over virtual merged RamA → transcript
   - ram Val-from-Inc sumcheck over virtual merged RamA → transcript
   - ram RAF support sumcheck over virtual merged RamA → transcript
   - ram guest-address support sumcheck over virtual merged RamA → transcript
   - per-factor ram Hamming + Hamming Booleanity sumchecks for `RamA_i`
     → transcript
   - ram ra-virtualization sumcheck binding virtual RamA to committed RamA_i
     → transcript
   - address-correctness subchecks in canonical order
     (RegRa1 → RegRa2 → RegWa → RamA) → transcript
   - record terminal points (r_addr_reg, r_addr_ram)
   - sample γ_twist_link
   - Stage-2 linkage batch → transcript

5. Stage 3 (continuity + bridge):
   - sample β1 for continuity batching
   - sample r_shift ∈ K^{CYCLE_BITS}
   - lane-shift reduction proof over C_lane at r_shift → transcript
   - continuity check at r_shift → transcript
   - open C_lane at j0_bits for start-boundary PC check → transcript
   - row-binding openings for each exported semantic row j ∈ [0, N) → transcript

6. Opening verification and reduction.

7. Emit kernel proof/output artifacts.
```

---

## 13. Committed Polynomial Coordinates

### 13.1 C_lane

- Domain: `CYCLE_BITS` variables
- Width: 37 committed non-fixed column polynomials (W - 1 = 37)
- Polynomial IDs in canonical registry order:
  `PC_LO`, `PC_HI`, `PC_NEXT_LO`, `PC_NEXT_HI`,
  `RS1_LO`, `RS1_HI`, `RS2_LO`, `RS2_HI`,
  `RD_NEXT_LO`, `RD_NEXT_HI`, `IMM_LO`, `IMM_HI`,
  `ALU_OUT_LO`, `ALU_OUT_HI`, `STEP_PC_LO`, `STEP_PC_HI`,
  `JUMP_TARGET_LO`, `JUMP_TARGET_HI`, `MEM_ADDR_LO`, `MEM_ADDR_HI`,
  `MEM_VAL_LO`, `MEM_VAL_HI`, `RD_IDX`, `RS1_IDX`, `RS2_IDX`,
  `WritesAluToRd`, `WritesMemToRd`, `PreservesRd`,
  `IsJal`, `IsJalr`, `IsBranch`, `BranchTaken`, `BranchTakenMux`,
  `IsLoad`, `IsStore`, `UsesRs2`, `AdvanceArchPc`

### 13.2 C_reg

- Domain: `ADDR_REG_BITS + CYCLE_BITS = 7 + CYCLE_BITS` variables
- Variable order: address bits first (big-endian), then cycle bits (LE)
- Address space: active 0..127 = architectural + virtual registers + `⊥_reg`
- Polynomials: `RegIncLo`, `RegIncHi`, `RegRa1`, `RegRa2`, `RegWa`
- Polynomial IDs:
  `0 = RegIncLo`, `1 = RegIncHi`, `2 = RegRa1`, `3 = RegRa2`, `4 = RegWa`

### 13.3 C_bytecode_ra

- Domain: `BYTECODE_ADDR_BITS + CYCLE_BITS`
- Polynomial: `ra_bytecode(addr, j)`

### 13.4 C_decode_handoff

- Domain: `CYCLE_BITS`
- Width: 7 columns: `handoff_uses_rs2`, `handoff_is_load`, `handoff_is_store`,
  `handoff_mem_width`, `handoff_mem_unsigned`,
  `handoff_is_first_in_sequence`, `handoff_is_last_in_sequence`

### 13.5 C_alu_ra

- Domain: `ALU_SLOT_BITS + ALU_KEY_BITS + CYCLE_BITS`
- `ALU_SLOT_BITS = ceil_log2(MAX_ALU_QUERY_SLOTS) = 6`
- `C_alu_ra` is one shared committed slotized one-hot address family with
  polynomial `ra_alu(slot, key, j)`. `AluKey` carries a canonical subchannel id
  plus the subchannel-local operands.
- Canonical subchannel order:
  `ADD8`, `AND8`, `OR8`, `XOR8`, `MUL8`, `LT8`, `EQ8`, `SHL8`, `SHR8`,
  `SIGNEXT8`, `VALID_DIV0`, `VALID_UNSIGNED_REMAINDER`,
  `MULU_NO_OVERFLOW`, `CHANGE_DIVISOR`.
- Canonical slot packing and per-slot Hamming-weight obligations are fixed in
  §5.3.5a.
- Splitting this manifest into prover-chosen per-subchannel commitments is
  non-conforming.

### 13.6 C_branch_ra

- Domain: `BRANCH_SLOT_BITS + BRANCH_KEY_BITS + CYCLE_BITS`
- `BRANCH_SLOT_BITS = ceil_log2(MAX_BRANCH_QUERY_SLOTS) = 4`
- `C_branch_ra` is the slotized branch one-hot address family with polynomial
  `ra_branch(slot, key, j)`.
- `BranchKey` carries the canonical branch subchannel id plus the slot-local
  comparison operands. The canonical branch subchannel order is `EQ8`, `LT8`.
- Canonical slot packing and per-slot Hamming-weight obligations are fixed in
  §5.3.5a.

### 13.7 C_ram

- `C_ram` is a mixed-arity RAM Twist bundle.
- Canonical local registry order:
  - `0 = RamIncLo`
  - `1 = RamIncHi`
  - `2 + i = RamA_i` for `i ∈ {0..RAM_ADDR_D-1}`
- Cycle-only polynomials:
  - `RamIncLo(j)`, `RamIncHi(j)` on the `CYCLE_BITS` domain.
- Chunk-address polynomials:
  - for each `i ∈ {0..RAM_ADDR_D-1}`, `RamA_i(a_i, j)` on the
    `RAM_CHUNK_BITS[i] + CYCLE_BITS` domain with variable order
    `chunk_i address bits` first, then cycle bits.
- The virtual merged `RamA(a, j)` is **not** committed directly. It is defined
  as the tensor product of the committed factors `RamA_i` and is the address
  family consumed by RAM read/write checking, RAM `Val`-from-`Inc`, RAM RAF
  support, RAM guest-address support, and RAM address-correctness.
- No-op RAM rows are encoded by all-zero rows in every `RamA_i`, not by a sink
  address.

### 13.8 C_rom_table

- Domain: `ROM_ADDR_BITS`
- Table: program ROM (32-bit instruction words)

### 13.9 C_bytecode_table

- Domain: `BYTECODE_ADDR_BITS`
- Output polynomial IDs in canonical order matching the expanded-bytecode tuple
  from §5.2: `instruction_word_arch`, `unexpanded_pc`, `virtual_opcode`,
  sequence-boundary flags, register selectors, immediates, row flags, and
  Stage-2 handoff metadata.

### 13.10 C_alu_subtables

- Multiple committed lookup families for Stage-1 virtual instructions:
  byte-level arithmetic/logical subtables plus compressed wide support
  relations (`VALID_DIV0`, `VALID_UNSIGNED_REMAINDER`,
  `MULU_NO_OVERFLOW`,
  `CHANGE_DIVISOR`).
- Exact inventory per §5.3.

### 13.11 C_branch_table

- Domain: `BRANCH_KEY_BITS`
- Table: branch condition evaluation with canonical `EQ8` / `LT8` subchannel
  registry matching `C_branch_ra`.

---

## 14. Bridge Binding Mechanism

This section restates the normative bridge mechanism from §8.4:

- one committed root lane family `C_lane` for the full semantic-row object,
- canonical selected row refs against that committed family for the rows needed
  by the bridge,
- `RootEncode(z_j)` only as the local encoding rule for a selected semantic
  row,
- root main-lane proof binding from authenticated selected rows to the accepted
  chunk-scheduled CCS theorem package,
- bridge binding from those authenticated and proved rows to the accepted
  row-local claim summaries.

Bridge verifier algorithm for row `j`:

1. Verify that the selected row refs for `j_bits` are authenticated against the
   committed root lane family object.
2. Recover `z_j` from those authenticated lane values by prepending `ONE = 1`.
3. Compute `RootEncode(z_j)`.
4. Verify that the resulting row-local encoding is accepted by the root
   main-lane CCS proof package for the unique chunk containing row `j`, under
   the proof-carried `FoldSchedule`.
5. Bind the accepted row-local execution object to the accepted bridge summary
   for row `j`.
6. If a private `PreparedStep_j` helper is exported, check that it is derived
   from the same `RootEncode(z_j)` object. This helper check is optional and
   not part of the required theorem-facing surface.

When multiple consumers request the same `(C_lane, j_bits)` row, the verifier
authenticates that selected row once and reuses it for all downstream bridge,
stage, and kernel-opening obligations.

---

## 15. Conformance Requirements

An RV64IM integration may claim conformance to this spec only if:

1. Stage 1 uses an authenticated expanded-bytecode channel keyed by
   `BytecodeAddr`, not the universal 32-bit instruction space and not a
   collapsed per-architectural-row descriptor.
2. Stage 2 uses port-correct register and RAM Twist instances over a register
   domain that includes authenticated virtual registers; register no-write rows
   and x0 writes use `⊥_reg`, while RAM uses a Jolt-style merged address family
   with all-zero no-op rows and cycle-only RAM increments.
3. Twist lane linkage uses Stage-2 cycle-point openings, not re-used Stage-1
   openings.
4. 64-bit values are represented as (lo32, hi32) limb pairs with range proofs.
5. The expanded bytecode row enforces `PreservesRd = 1` when `rd = x0`, ensuring
   x0 is never modified.
6. Multi-byte memory accesses use word-addressed RAM with one merged
   authenticated RAM-address family per row; aligned-word RAM rows expose the
   current authenticated 64-bit RAM word and, on store rows, an authenticated
   writeback delta, while narrow accesses lower into those RAM rows plus
   separate pure Stage-1 extract/blend rows.
7. The committed main lane includes `AdvanceArchPc`, and Stage 3 enforces
   `PC(j+1) = PC_NEXT(j)` continuity on the expanded-row trace together with the
   rule that non-final rows hold the architectural PC.
8. Stage 3 enforces the start-boundary
   PC check on the expanded-row trace, while expanded-bytecode adjacency is
   enforced by the bytecode `raf` claims.
9. Stage 1 proves taken control-flow target alignment: every routed
   `JUMP_TARGET` on `JAL`, taken branch, or `JALR` rows satisfies
   `Align(4, JUMP_TARGET) = 1`.
10. Booleanity is explicitly proved; Ajtai norm bounds do not substitute.
11. In this v1 kernel, all read-only tables are committed and absorbed into
    `root0` as one uniform-authentication choice. This is stricter than the
    minimum Twist/Shout requirement and is not itself a theorem of the paper.
12. The bridge uses canonical selected openings against one committed root lane
    family object `C_lane`; repeated work on the same `(family, point)` aliases
    to one authenticated opening surface rather than spawning one fresh
    theorem-facing row-opening object per consumer.
13. Authenticated selected openings against `C_lane` do not by themselves close
    the root execution theorem. A conforming proof must also verify the root
    main-lane row-local CCS relation from §11 through an accepted theorem
    package whose `FoldSchedule` is carried inside the proof boundary. Summary-
    only or digest-only binding of semantic rows is non-conforming.
14. The root theorem package must reject invalid chunk schedules, including
    `RowsPerChunk(0)`, non-contiguous partitions, skipped rows, overlapping
    rows, or chunk metadata inconsistent with the carried `FoldSchedule`.
15. Kernel and root opening manifests are disjoint.
16. Strong kernel soundness requires the adjacent-state theorem via
    `Stage2TemporalContext` and `PcAdjacentBridge`.
17. Division/remainder uses advice + verification with dedicated authenticated
    support relations for divide-by-zero, unsigned remainder bounds, and
    overflow-case divisor adjustment, together with explicit reconstruction of
    the signed remainder from the dividend sign and a proof of
    `SIGNED_DIVREM_SPEC`; prose-only corner-case handling is non-conforming.
18. Lowering from ROM to expanded bytecode is deterministic and part of the
    accepted theorem package. Conforming verification must bind the public ROM
    image and declared `lowering_version_id` directly to `C_rom_table` and
    `C_bytecode_table` by table evaluation or commitment recomputation;
    prover-chosen lowering or digest-only binding paths are non-conforming.
19. The exact kernel boundary determines the accepted theorem package without
    additional external temporal-support premises.
20. Trivial predicates that depend only on already-opened low bits or bytes may
    be represented as virtual instructions, but their proof rule is direct
    arithmetic unless a separate lookup family is explicitly justified by a
    measured prover-cost win.
20. Every multi-row lowered sequence ships with machine-checkable correctness
    and determinism proofs; prose-only reasoning or empirical tests are
    non-conforming.
21. RAM chunking parameters (`ram_addr_d`, `ram_chunk_bits`) are public,
    absorbed into `root0`, and match the committed `C_ram` address-factor
    bundle; prover-private RAM chunking or hidden `ra`-virtualization layouts
    are non-conforming.
22. Accepted proofs attest a full halted execution ending in a sequence-final
    terminating `ECALL` row. Valid-prefix claims are non-conforming in this
    kernel version.

---

## 16. Shared Backend Integration

This kernel plugs into a shared generic SuperNeo backend
(`prover.rs`, `verifier.rs`, `run.rs`, `time_opening.rs`, `finalize.rs`).
Repository builds may select VM kernels via compile-time feature flags. The
RV64IM-facing requirement is only that the backend be VM-polymorphic and that
selecting `rv64im` activates the RV64IM-specific witnesses, tables, and staged
proof code.

Example feature declaration:

```toml
[features]
rv64im = []
```

Other VM-specific feature flags may coexist in the repository, and a repository
configuration may choose some other feature as the default. Those choices are
implementation details, not part of the RV64IM theorem surface.

The `vm/` trait layer (`VmSpec`, `VmTraceBuilder`) provides the abstraction
boundary. The RV64IM kernel implements these traits with its own:

- `layout.rs`, `isa.rs`, `ccs.rs`: witness layout, opcode/state/decode, and CCS contract
- `tables.rs`: lowering logic, bytecode metadata, ALU tables
- `execute.rs`, `lower.rs`, `builder.rs`: execution engine, witness lowering, and step packaging
- `stage1/`, `stage2/`, `stage3/`: kernel proofs
- `kernel/`: kernel boundary (prove/verify entry points)

Shared infrastructure (`proof.rs`, `opening.rs`, `step_build.rs`, `prover.rs`,
`verifier.rs`, `run.rs`, `finalize.rs`, `time_opening.rs`) must stay
parameterized by the VM spec or otherwise remain VM-agnostic. Any shared-code
identifier, enum, helper, or extension path that hardcodes some other VM kernel
must be generalized to a VM-polymorphic equivalent before the RV64IM kernel can
plug in cleanly.
