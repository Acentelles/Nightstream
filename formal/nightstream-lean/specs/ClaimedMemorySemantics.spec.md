# ClaimedMemorySemantics.spec.md

## Purpose

- **What it is**: the theorem-facing statement of the read-only and read/write memory semantics that the composition layer is allowed to claim.
- **What it is not**: it is not a proof of Twist or Shout; it is the semantic target those protocols are supposed to certify.
- **Protocol role**: it gives the bridge one explicit notion of what a correct Shout read trace or Twist read/write trace means before any folding decision is considered.

## Target Formulas

- Read-only memory semantics:

$$
\mathrm{ShoutReadOnlySound}(\mathrm{table}, \mathrm{raf}, \mathrm{rv})
\iff
\forall j,\; \mathrm{rv}(j) = \mathrm{table}(\mathrm{raf}(j)).
$$

- No prior write to an address before cycle \(j\):

$$
\mathrm{NoPriorWrite}(\mathrm{waf}, a, j)
\iff
\forall j' < j,\; \mathrm{waf}(j') \neq a.
$$

- A latest write at cycle \(j^\*\) for address \(a\) before cycle \(j\):

$$
\mathrm{LatestWriteAt}(\mathrm{waf}, a, j^\*, j)
\iff
j^\* < j
\land
\mathrm{waf}(j^\*) = a
\land
\forall j' < j,\; \mathrm{waf}(j') = a \rightarrow j' \le j^\*.
$$

- Read/write memory semantics with authenticated initialization:

$$
\mathrm{TwistReadWriteSound}(\mathrm{init}, \mathrm{raf}, \mathrm{rv}, \mathrm{waf}, \mathrm{wv})
$$

means that for every read cycle \(j\):

$$
\mathrm{NoPriorWrite}(\mathrm{waf}, \mathrm{raf}(j), j)
\rightarrow
\mathrm{rv}(j) = \mathrm{init}(\mathrm{raf}(j)),
$$

and

$$
\forall j^\*,\;
\mathrm{LatestWriteAt}(\mathrm{waf}, \mathrm{raf}(j), j^\*, j)
\rightarrow
\mathrm{rv}(j) = \mathrm{wv}(j^\*).
$$

- Zero-initialization specialization:

$$
\mathrm{TwistReadWriteSoundZeroInit}
=
\mathrm{TwistReadWriteSound}(\lambda a.\, 0, \mathrm{raf}, \mathrm{rv}, \mathrm{waf}, \mathrm{wv}).
$$

## Dependency and Consumer Map

- **Depends on**: no proof-system internals; this is the semantic contract consumed by the bridge.
- **Consumed by**:
  - later `Projection`
  - later `MainLaneBridge`
  - later `ShardComposition`

## Out of Scope

- one-hot encodings
- sum-check soundness
- PCS / Fiat-Shamir / transcript modeling
- Rust refinement
