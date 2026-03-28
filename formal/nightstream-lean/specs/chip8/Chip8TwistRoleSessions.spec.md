# Chip8TwistRoleSessions Spec

## Purpose

- **What it is**: The theorem-facing owner that turns one row-local Stage-2
  temporal seed into explicit named Twist session witnesses for the concrete
  CHIP-8 register and RAM roles used by that row.
- **Key property**: it replaces nested existential coverage facts with stable
  row-local session objects for `regRaX`, `regRaY`, `regRaI`, `regWa`, and the
  active RAM load/store role.
- **Protocol role**: This is still below the trace-global `RegVal` / `RamVal`
  timeline theorem. It does not reconstruct a whole time table; it only exports
  the row-local authenticated sessions that a later temporal reconstruction
  theorem must compose.

## Target Formulas

Given one Stage-2 seed

$$
\mathrm{Stage2TemporalSeedBound}(j, pre, post, dec, z),
$$

define a row-local register session package carrying explicit authenticated
session witnesses for:

- the `regRaX` read role,
- the `regRaY` read role,
- the `regRaI` read role,
- the `regWa` write role.

Each named witness must retain:

- membership in the authenticated register session registry,
- the exact `AddressProvenanceAt(dec, j, role, addr)` fact for the relevant
  role.

For RAM, define the conditional row-local session packages:

- `LoadRamRoleSession` on `dec.opcodeId = loadRegs`,
- `StoreRamRoleSession` on `dec.opcodeId = storeRegs`.

These packages retain:

- membership in the authenticated RAM session registry,
- the exact RAM read/write address provenance fact for the active role.

Finally, the module exports the generic claim-membership consequences:

$$
session \in registry
\Longrightarrow
read(session), write(session), val(session) \in \Gamma_3.
$$

It also exposes the internal Stage-2 session-coherence consequences already
carried by each authenticated witness:

$$
\mathrm{readKey}(session) = key(session),\quad
\mathrm{writeKey}(session) = key(session),\quad
\mathrm{valKey}(session) = key(session),
$$

and

$$
\mathrm{readVal}(session) = \mathrm{writeVal}(session)
\quad\land\quad
\mathrm{writeVal}(session) = \mathrm{valClaimVal}(session).
$$

For each named CHIP-8 role session, these equalities are re-exposed directly on
the extracted row-local object.

## Module Mapping

| Lean file | Local owner |
|---|---|
| `Nightstream/Chip8/TwistRoleSessions.lean` | Row-local extraction of explicit Twist session witnesses from one Stage-2 seed |
| `Nightstream/Chip8/TwistRoleSessionsInterface.lean` | Theorem-facing re-export surface |

## Contract Surface

| Group | Lean surface | Kind | Role | Guarantee |
|---|---|---|---|---|
| Session | `RegisterRoleSessions` | structure | Definitional | Names the row-local register-side authenticated sessions for `x`, `y`, `I`, and the row write role |
| Session | `LoadRamRoleSession` | structure | Definitional | Names the authenticated RAM read session on `loadRegs` rows |
| Session | `StoreRamRoleSession` | structure | Definitional | Names the authenticated RAM write session on `storeRegs` rows |
| Constructor | `registerRoleSessions_of_seed` | def | Theorem-Target | One Stage-2 seed yields explicit register-side session witnesses |
| Constructor | `loadRamRoleSession_of_seed` | def | Theorem-Target | A `loadRegs` Stage-2 seed yields the explicit RAM read session witness |
| Constructor | `storeRamRoleSession_of_seed` | def | Theorem-Target | A `storeRegs` Stage-2 seed yields the explicit RAM write session witness |
| Theorem | `twistSessionWitness_readKey_eq_key` | theorem | Theorem-Target | Any authenticated Twist session carries the exact read-side session-key equality from its provenance |
| Theorem | `twistSessionWitness_writeKey_eq_key` | theorem | Theorem-Target | Any authenticated Twist session carries the exact write-side session-key equality from its provenance |
| Theorem | `twistSessionWitness_valKey_eq_key` | theorem | Theorem-Target | Any authenticated Twist session carries the exact val-claim session-key equality from its provenance |
| Theorem | `twistSessionWitness_readVal_eq_writeVal` | theorem | Theorem-Target | Any authenticated Twist session carries one shared virtual value across its read and write claims |
| Theorem | `twistSessionWitness_writeVal_eq_valClaimVal` | theorem | Theorem-Target | Any authenticated Twist session carries one shared virtual value across its write and val claims |
| Theorem | `twistSessionWitness_readVal_eq_valClaimVal` | theorem | Theorem-Target | Any authenticated Twist session carries one shared virtual value across its read and val claims |
| Theorem | `registerSessionClaimsInΓ₃_of_seed` | theorem | Theorem-Target | Any named register-side session from the seed has all three claims in `Γ₃` |
| Theorem | `ramSessionClaimsInΓ₃_of_seed` | theorem | Theorem-Target | Any named RAM-side session from the seed has all three claims in `Γ₃` |
| Theorem | `registerRoleSessions_readX_valueCoherent` | theorem | Theorem-Target | The extracted `regRaX` session re-exposes the shared Stage-2 virtual value across its read/write/val claims |
| Theorem | `registerRoleSessions_readY_valueCoherent` | theorem | Theorem-Target | The extracted `regRaY` session re-exposes the shared Stage-2 virtual value across its read/write/val claims |
| Theorem | `registerRoleSessions_readI_valueCoherent` | theorem | Theorem-Target | The extracted `regRaI` session re-exposes the shared Stage-2 virtual value across its read/write/val claims |
| Theorem | `registerRoleSessions_writeReg_valueCoherent` | theorem | Theorem-Target | The extracted `regWa` session re-exposes the shared Stage-2 virtual value across its read/write/val claims |
| Theorem | `loadRamRoleSession_valueCoherent` | theorem | Theorem-Target | The extracted `loadRegs` RAM read session re-exposes the shared Stage-2 virtual value across its read/write/val claims |
| Theorem | `storeRamRoleSession_valueCoherent` | theorem | Theorem-Target | The extracted `storeRegs` RAM write session re-exposes the shared Stage-2 virtual value across its read/write/val claims |

## Proof Obligations

- This owner must stay row-local.
- It must not claim a trace-global `RegVal` or `RamVal` timeline.
- It must not weaken role provenance into bare claim membership; the role-level
  `AddressProvenanceAt` facts remain part of the exported object.

## Dependency and Consumer Map

- **Upstream dependencies**:
  - `Chip8EvidenceCoverage`
  - `Chip8WitnessMemoryBinding`
  - `Chip8RegisterSessionBoundary`
- **Downstream consumers**:
  - the future trace-global Stage-2 temporal reconstruction theorem
  - any audit/digest owner that needs explicit row-local session witnesses
