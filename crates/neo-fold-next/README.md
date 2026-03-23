# neo-fold-next

`neo-fold-next` owns the active Rust proving path for:

- the generic SuperNeo shard spine,
- shared final opening/finalization boundaries,
- VM contract descriptions,
- and the current CHIP-8 frontend + simple-kernel audit path.

## Current owner map

- `proof`: generic session proof boundary
- `opening`: shared opening-claim and time-opening summary boundary
- `step_build`: frontend-produced step packaging and extension records
- `prover`, `verifier`: explicit `Π_CCS -> Π_RLC -> Π_DEC`
- `run`: session orchestration over prepared steps
- `time_opening`: shared grouped opening reduction/unification
- `finalize`: final packaged proof/public statement boundary
- `vm`: static VM architecture contracts
- `chip8`: CHIP-8 machine frontend, staged kernel, and audit surfaces

## Important constraints

- Rust structure should follow runtime ownership, not Lean file layout.
- The exact Rust↔Lean protocol boundary must remain stable.
- The audit path should stay narrow and out of the hot path by default.
- Public APIs should be curated; internal owners should be imported directly by
  tests and tooling when they are intentionally exercising internals.

## Planning docs

- [specs/neo-fold-next-rust-structure-plan.md](./specs/neo-fold-next-rust-structure-plan.md)
- [specs/chip8-rust-lean-boundary.md](./specs/chip8-rust-lean-boundary.md)
- [specs/chip8-rust-file-structure-plan.md](./specs/chip8-rust-file-structure-plan.md)
- [specs/chip8-kernel.md](./specs/chip8-kernel.md)
- [specs/riscv-kernel.md](./specs/riscv-kernel.md)
