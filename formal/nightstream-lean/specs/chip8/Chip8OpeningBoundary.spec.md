# Chip8OpeningBoundary Spec

## Purpose

- **What it is**: The theorem-facing opening-manifest contract for the final
  CHIP-8 kernel.
- **Key property**: `kernelOpeningBoundary_conforms`: every kernel-owned opening
  claim references exactly one commitment fixed in `root0`, uses the exact
  commitment-local polynomial registry, and appears in the correct kernel/root
  ownership bucket.
- **Protocol role**: This is the boundary that prevents the kernel from
  overclaiming direct opening access to undeclared commitments or from
  conflating kernel-owned openings with later root-prover openings.

This module classifies opening claims and manifests only. It does **not** own
the checked Shout/Twist proofs themselves, the continuity reduction proof, or
semantic extraction from those claims.

## Target Formulas

### Kernel commitment surface

The final kernel fixes the following opening commitments before any
stage-specific challenge is sampled:

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

These are the only commitments that may appear in the kernel-owned opening
manifest.

The root prover later creates disjoint commitments, including the per-step
Ajtai commitments inside `PreparedStep`.

### Opening claim shape

Define the theorem-facing opening claim:

$$
\mathrm{OpeningClaim}
:=
(
\mathrm{source},
\mathrm{commitmentId},
\mathrm{point},
\mathrm{polynomialIds},
\mathrm{claimedValues},
\mathrm{digest}
).
$$

The commitment identifier is drawn from:

$$
\mathrm{CommitmentId}
:=
\mathrm{Lane}
\mid
\mathrm{FetchRa}
\mid
\mathrm{DecodeRa}
\mid
\mathrm{AluRa}
\mid
\mathrm{Eq4Ra}
\mid
\mathrm{DecodeHandoff}
\mid
\mathrm{RegTwist}
\mid
\mathrm{RamTwist}
\mid
\mathrm{RomTable}
\mid
\mathrm{DecodeTable}
\mid
\mathrm{AluTable}
\mid
\mathrm{Eq4Table}
\mid
\mathrm{RootProver}(\_).
$$

### Manifest ownership buckets

The opening boundary is split into two disjoint ownership buckets:

- `KernelOpeningManifest`
- `RootOpeningManifest`

The kernel manifest may reference only the commitments fixed in `root0`.
The root manifest may reference only commitments created after bridge
extraction.

### Grouping rule

There are two distinct grouping notions:

$$
(\mathrm{commitmentId}, \mathrm{point})
$$

for one family-local direct opening surface, and

$$
(\mathrm{source}, \mathrm{ordinal}, \mathrm{domain}, \mathrm{point})
$$

for one later claim-space reduction bucket.

This boundary owns the first notion. It does not identify witness-space fold
lanes and it does not collapse heterogeneous commitment families into one fold
carrier. On the `simple` boundary, a single global `JointOpeningFoldPlan` is
not merely unidentified; it is non-conforming and must be absent.

If two admissible direct opening claims share the same
`(commitmentId, point)`, they remain distinct only through their exact
`polynomialIds`. This boundary does not require same-surface coalescing, but it
does require deterministic tie-breaking by `polynomialIds` and it forbids two
distinct claims with the same `(commitmentId, point, polynomialIds)`.

### Kernel manifest shape

In this `simple` kernel boundary, the kernel-owned manifest contains exactly the
following direct openings:

- `C_lane @ r_lookup` for the Stage-1 lane columns
  `{PC, KK, NNN_ADDR, NNN_WORD, REG_X, REG_Y, LOOKUP_OUTPUT,
    WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
    IsJump, IsBranch, IsMemOp, X_IDX, Y_IDX, BURST_LAST}`
- `C_fetch_ra @ (r_fetch_addr, r_lookup)`
- `C_decode_ra @ (r_decode_addr, r_lookup)`
- `C_alu_ra @ (r_alu_addr, r_lookup)`
- `C_eq4_ra @ (r_eq4_addr, r_lookup)`
- `C_decode_handoff @ r_lookup` with exact polynomial subset
  `{uses_y_dec, reads_ram_dec, writes_ram_dec}`
- `C_rom_table @ r_fetch_addr`
- `C_decode_table @ r_decode_addr` with exact polynomial subset `0..21`
- `C_alu_table @ r_add8lo_addr`
- `C_eq4_table @ r_eq4_addr`
- `C_lane @ r_twist_cycle` for the Stage-2 lane columns
  `{REG_X, REG_Y, REG_X_NEXT, I_REG, I_NEXT, MEM_VALUE,
    WritesLookupToX, WritesMemToX, PreservesX, WritesNnnToI,
    IsMemOp, X_IDX, Y_IDX, RAM_ADDR}`
- `C_decode_handoff @ r_twist_cycle` with exact polynomial subset
  `{uses_y_dec, reads_ram_dec, writes_ram_dec}`
- `C_reg @ (r_addr_reg, r_twist_cycle)` with exact polynomial subset
  `{RegInc, RegRaX, RegRaY, RegRaI, RegWa}`
- `C_ram @ (r_addr_ram, r_twist_cycle)` with exact polynomial subset
  `{RamInc, RamRa, RamWa}`
- `C_lane @ r_shift` for `{PC, PC_NEXT, X_IDX, IsMemOp, BURST_LAST}`
- `C_lane @ j0_bits` for `{IsMemOp, X_IDX}`
- `C_lane @ j_last_bits` for `{IsMemOp, BURST_LAST}`
- `C_lane @ j_bits` for all 23 committed non-fixed lane coordinates of every
  exported semantic row

No other direct kernel opening claims are admissible in this `simple` kernel
boundary.

### Exact exclusions

The opening boundary must also state the exact exclusions:

- `LaneShiftProof` is not an `OpeningClaim`
- virtual `RegVal` and `RamVal` objects are not `OpeningClaim`s
- `KernelOpeningManifest` may not reference any root-prover commitment
- `RootOpeningManifest` may not reference any `C_*` commitment fixed in `root0`
- on the simple-kernel boundary, `RootOpeningManifest = ∅`
- claim-space reduction summaries are not opening claims
- fold carriers are not opening claims
- row-projection summaries are not opening claims
- bridge-binding summaries are not opening claims
- later kernel stages do not reuse Stage-1 openings; each stage opens its own
  direct claims independently
- no split or partial decode-table opening claims at `r_decode_addr` are
  admissible in this `simple` boundary

### Canonical manifest ordering

Define the canonical commitment-id order:

$$
\mathrm{Lane}
\prec
\mathrm{FetchRa}
\prec
\mathrm{DecodeRa}
\prec
\mathrm{AluRa}
\prec
\mathrm{Eq4Ra}
\prec
\mathrm{DecodeHandoff}
\prec
\mathrm{RegTwist}
\prec
\mathrm{RamTwist}
\prec
\mathrm{RomTable}
\prec
\mathrm{DecodeTable}
\prec
\mathrm{AluTable}
\prec
\mathrm{Eq4Table}
\prec
\mathrm{RootProver}(\_).
$$

The canonical manifest sort key is:

$$
(\mathrm{commitmentIdOrder}, \mathrm{pointArity},
\mathrm{pointCoordinates}, \mathrm{polynomialIds}).
$$

The boundary must enforce:

- strictly increasing `polynomialIds` in the local registry order
- point coordinates ordered exactly by the commitment's domain convention
- no duplicate `(commitmentId, point, polynomialIds)` entries
- same-surface ties, when present, ordered deterministically by
  `polynomialIds`

### Kernel opening boundary

Define:

$$
\mathrm{KernelOpeningBoundary}(kernelManifest, rootManifest)
$$

to mean:

- every kernel claim references a kernel commitment fixed in `root0`
- every root claim references only root-prover commitments
- the root manifest is empty on the simple-kernel boundary
- the kernel manifest satisfies the exact kernel-shape constraints above
- both manifests satisfy the canonical grouping and ordering rules

The main theorem target is:

$$
\mathrm{KernelOpeningBoundary}(kernelManifest, rootManifest)
\Longrightarrow
\text{no orphan or mis-owned opening claim exists}.
$$

## Paper Anchors

- **Source**: `./crates/neo-fold-next/specs/chip8-kernel.md`
- Anchors:
  - commitment bundle
  - two commitment layers
  - opening boundary
  - canonical manifest ordering

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/OpeningBoundary.lean` | Kernel/root opening-manifest ownership and conformance theorems |
| `Nightstream/Chip8/OpeningBoundaryInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Commitments | `CommitmentId` | def | Definitional | Enumerates every opening commitment class relevant to the kernel/root boundary |
| Claims | `OpeningClaim` | def | Definitional | Theorem-facing direct opening claim object |
| Manifests | `KernelOpeningManifest` | def | Definitional | Kernel-owned direct opening manifest |
| Manifests | `RootOpeningManifest` | def | Definitional | Root-prover direct opening manifest |
| Boundary | `KernelManifestShape` | def | Definitional | Exact required kernel-owned claim families and points |
| Boundary | `CanonicalManifestOrder` | def | Definitional | Canonical ordering and grouping rule |
| Boundary | `KernelOpeningBoundary` | def | Definitional | Complete kernel/root ownership and conformance predicate |
| Boundary | `SimpleBoundaryGlobalFoldPlanAbsent` | def | Definitional | The simple boundary exports no single global fold plan |
| Boundary | `LaneShiftSourceOpeningAppearsInManifest` | def | Definitional | Names the required `C_lane @ r_shift` direct opening inside the kernel manifest |
| Theorem | `kernelOpeningBoundary_conforms` | theorem | Theorem-Target | A conforming manifest contains only legal, correctly owned opening claims |
| Theorem | `laneShift_not_openingClaim` | theorem | Theorem-Target | `LaneShiftProof` is not part of either opening manifest |
| Theorem | `laneShiftSourceOpeningAppears_of_kernelManifestShape` | theorem | Theorem-Target | A conforming kernel manifest explicitly contains the Stage-3 `C_lane @ r_shift` source opening |
| Theorem | `kernel_root_commitments_disjoint` | theorem | Theorem-Target | Kernel and root opening commitments remain disjoint |

## Proof Obligations

- This module must model the final kernel/root manifest split explicitly.
- The theorem surface must enumerate the exact kernel opening commitments.
- Canonical manifest ordering and grouping must remain theorem-facing, not only
  implementation prose.
- The simple boundary must state the absence of one global fold plan
  theorem-facing, not only in the main kernel prose.
- `LaneShiftProof` must remain outside the direct opening-manifest type.
- The Stage-3 `C_lane @ r_shift` source opening must still appear explicitly in
  the kernel manifest even though `LaneShiftProof` itself is not an
  `OpeningClaim`.

## Assumption Ledger

- This module does not re-prove PCS batching or final opening verification.
- This module does not prove Shout or Twist checked reductions.
- This module does not prove semantic extraction from opening claims.

## Dependency and Consumer Map

- **Upstream dependencies**:
  - final kernel commitment surface from `chip8-kernel.md`
- **Downstream consumers**:
  - `Nightstream/Chip8/EvidenceCoverage.lean`
  - later Rust-refinement theorems for `KernelOpeningManifest`

## Implementation Plan

1. Define the exact opening claim and manifest objects.
2. Define the kernel/root ownership split and manifest shape.
3. Define canonical ordering and grouping.
4. Prove manifest conformance and exact exclusions.

## Quality Expectations

- Keep this module about direct opening ownership only.
- Specialize to the final kernel commitment inventory.
- Do not smuggle checked Shout/Twist relations into the direct opening manifest.

## Acceptance Criteria

1. `lake build Nightstream.Chip8.OpeningBoundary` succeeds.
2. The theorem surface matches the final kernel/root opening-manifest split.
3. Kernel and root commitment layers remain formally disjoint.
4. No `sorry`.

## Out of Scope

- checked Shout/Twist proof objects
- Stage-3 continuity reduction proofs
- semantic extraction
- final PCS opening verification
