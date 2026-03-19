# neo-fold-next

Clean rewrite scaffold for `neo-fold`.

This crate exists to rebuild the `neo-fold` ownership graph with a smaller,
clearer surface:

- `shard` owns the explicit shard prover/verifier scripts plus the core family
  owners that feed them
- `run` owns orchestration only
- `time_opening` owns grouped opening and joint-opening work
- `proof` owns the typed artifact boundary
- `frontends` turn traces or circuits into shard/run inputs
- `output_binding` and `finalize` are Rust-only strengthenings downstream of
  the core proof path

Current status: scaffold only. No protocol implementation has been migrated yet.

Current scope decision:

- do not implement a maintained RISC-V frontend in `neo-fold-next` yet
- focus first on paper-core shard proving plus a thin run facade over
  host-prepared step inputs

Planning docs:

- `specs/Architecture.spec.md`: stateless ownership contract
- `ARCHITECTURE_PLAN.md`: concrete rewrite and migration plan

Rewrite rules:

- keep ownership boundaries explicit
- avoid wrapper-on-wrapper APIs
- avoid helper explosion
- keep frontends and strengthenings out of theorem-owning modules
- keep `run` as a facade, not a second proving hub
- keep heavy instruction semantics in explicit lookup families rather than
  inflating the core relation lane

The first implementation target for this crate should be a thin, auditable
paper-core shard path with:

- explicit `Π_CCS -> Π_RLC -> Π_DEC` in the prover
- a small core relation builder
- explicit Shout and Twist family owners
- no compatibility API layer unless a real caller needs it
