# Twist and Shout PIOP Soundness Boundary and Instantiation Obligations

## Purpose

This note specifies the conditions under which an implementation may claim the soundness bounds proved for the Twist and Shout interactive public-coin PIOPs in Sections 4 and 5 of the paper. It separates:

- the paper's theorem statements,
- the assumptions those theorem statements require,
- and the extra soundness terms and obligations introduced by a concrete instantiation.

Primary sources:

- `./docs/twist-and-shout-paper/2_overview_of_twist_and_shout_and_their_costs.md`
- `./docs/twist-and-shout-paper/4_the_shout_piop.md`
- `./docs/twist-and-shout-paper/5_the_twist_piop.md`

The paper is the source of truth for theorem statements. This note is an engineering boundary spec for preserving those PIOP statements in an instantiated protocol.

## Scope of the PIOP Soundness Claim

This note covers the soundness boundary of the interactive public-coin PIOPs for:

- Shout core lookup checking,
- Shout address-correctness and decode checking,
- and Twist core read/write memory checking.

It also explains how to compose those PIOP bounds into a concrete non-interactive argument-soundness budget.

It does **not** by itself specify:

- PCS binding or evaluation soundness,
- Fiat-Shamir or transcript-model soundness,
- knowledge soundness or extractability,
- PCS multi-opening or commitment-layer batching costs,
- or soundness of outer composition layers.

## Claimed Memory Semantics

### Shout

Acceptance means that, for every read cycle `j`, the claimed read value equals the fixed lookup-table value at the addressed location.

In the general `d`-dimensional formulation, the claimed relation is:

$$
\widetilde{\mathsf{rv}}(j)
=
\sum_{k=(k_1,\dots,k_d)\in(\{0,1\}^{\log(K)/d})^d}
\left(\prod_{i=1}^d \widetilde{\mathsf{ra}}_i(k_i,j)\right)
\cdot
\widetilde{\mathsf{Val}}(k).
$$

### Twist

Acceptance means that, for every read cycle `j`, the claimed read value equals the value from the most recent prior write to the same address.

Figure 9 / Theorem 4 states this relation under zero initialization:

$$
\mathsf{rv}(j)
=
\begin{cases}
\mathsf{wv}(j^*) & \text{if } j^* = \max\{j' < j : \mathsf{waf}(j') = \mathsf{raf}(j)\} \text{ exists}, \\
0 & \text{otherwise}.
\end{cases}
$$

Non-zero initialization is not covered by Theorem 4 verbatim merely by authenticating an initial-memory vector. To claim an analogous soundness boundary with non-zero initialization, an implementation must do one of the following:

1. Reduce the instance to the paper's zero-initialized setting, for example by a synthetic initialization phase or authenticated preload writes that are lowered as prior writes before any claimed read.
2. Prove a modified $\widetilde{\mathrm{Val}}$-evaluation identity whose definition includes an authenticated initial-memory term.

In either case, the initialization mode and any initial-memory descriptor are part of the claimed relation and must be fixed before dependent challenges.

## Paper-Level Soundness Claims

### Shout, `d = 1`

- Figure 5 / Theorem 1 is sound for read-only memory checking assuming each $\widetilde{\mathsf{ra}}(\cdot,j)$ is a correct one-hot read address. Its soundness error is

$$
\frac{2\log K + \log T}{|\mathbb{F}|}.
$$

- Figure 6 / Theorem 2 is the address-correctness-and-decode PIOP that discharges that assumption for the `d = 1` representation and grants verifier query access to the virtual address polynomial $\widetilde{\mathsf{raf}}$. Its soundness error is

$$
\frac{6\log K + 4\log T}{|\mathbb{F}|}.
$$

Engineering note: the rendered markdown for Theorem 2 later states a weaker sentence-level bound of $(2\log K + \log T)/|\mathbb{F}|$, which is inconsistent with the theorem header. This spec uses the theorem-header bound above as the conservative requirement.

### Shout, general `d`

- Figure 7 / Theorem 3 is sound assuming each read address is a correct `d`-dimensional one-hot encoding. Its soundness error is

$$
\frac{(d+2)\log T + 2\log K}{|\mathbb{F}|}.
$$

- Figure 8 / Theorem 3 is the address-correctness-and-decode PIOP for the general-`d` one-hot representation and grants verifier query access to the virtual address polynomial $\widetilde{\mathsf{raf}}$. Its soundness error is

$$
\frac{4d\log T + 6\log K}{|\mathbb{F}|}.
$$

### Twist

- Figure 9 / Theorem 4 is sound assuming both the read-address family and the write-address family are correct `d`-dimensional one-hot encodings. Its soundness error is

$$
\frac{(2d+3)\log T + 3\log K}{|\mathbb{F}|}.
$$

- Theorem 4's soundness argument is carried by three distinct checked relations: the read-checking sum-check in Equation (33), the write-checking sum-check in Equation (34), and the $\widetilde{\mathrm{Val}}$-evaluation sum-check implementing Equation (36).

## Shape, Padding, and Machine-Lowering Assumptions

These conditions determine what concrete claim is actually being proved. They must be fixed explicitly rather than left implicit.

1. **Cube shape.** The paper's notation assumes a clean Boolean-cube presentation: `K` and `T` are powers of two, and in general `d`, the tensorization is well formed, equivalently that `log K / d` is integral. A concrete implementation must either restrict to such instances or define an explicit embedding into a larger cube.
2. **Padding convention is semantic.** If padding or embedding is used, the padded address space, padded cycle space, dummy rows, unused addresses, and the rule for reads or writes touching padded points must be part of the statement. Different padding conventions are different claims.
3. **Machine lowering and visibility order.** A concrete machine must specify how its execution lowers to the paper's alternating memory-cycle model, including multiple reads or writes inside one CPU step, same-step visibility, and whether code, registers, and RAM are separate instances or share one tagged address space. Twist proves "latest prior write," not "same-cycle or prior write," so the lowering must define exactly which writes count as prior for each read.

## Assumptions That Must Be Discharged Elsewhere

To claim the paper's soundness bounds, an implementation must discharge the following assumptions explicitly.

1. **Address validity.** Shout core theorems assume valid one-hot read addresses. Twist assumes valid one-hot read and write addresses. At the theorem boundary, address validity means Hamming-weight `1` for each one-hot family, plus Booleanity unless Booleanity is enforced by the commitment layer itself.
2. **Decode consistency and virtual-address query access.** Decode consistency between a one-hot family and its decoded field-address representation is additionally required whenever the outer protocol uses field-address representations, or whenever the implementation claims verifier query access to virtual $\widetilde{\mathsf{raf}}$ or $\widetilde{\mathsf{waf}}$. Figure 6 / Figure 8 discharge both address validity and this stronger decode-and-query-access surface. An implementation may also discharge them with an equivalent stronger primitive.
3. **Authentic table evaluations.** Shout's core PIOPs assume an agreed lookup table $\widetilde{\mathsf{Val}}$ whose multilinear extension the verifier can evaluate at random points in $O(\log K)$ time. If that is not true, then table evaluations must come from a separately authenticated source. This is part of the soundness boundary of the core Shout PIOP, not an implementation preference.
4. **Initial-memory handling.** The theorem-level Twist boundary uses Equation (36), where $\widetilde{\mathrm{Val}}$ is defined from $\widetilde{\mathrm{Inc}}$ via the less-than sum-check. For non-zero initialization, authenticating an initial-memory vector is necessary but not sufficient. The implementation must either reduce to the zero-init setting or prove the modified $\widetilde{\mathrm{Val}}$ identity described above.

### Virtual-Polynomial Discipline

| Protocol | Committed or otherwise authenticated base objects | Virtual objects allowed at the theorem boundary |
| --- | --- | --- |
| Shout | Read-address one-hot family; lookup-table polynomial is public and verifier-evaluable, or separately authenticated | $\widetilde{\mathsf{raf}}$, $\widetilde{\mathsf{rv}}$ |
| Twist | $\widetilde{\mathrm{Inc}}$, $\widetilde{\mathrm{wv}}$, read-address one-hot family, write-address one-hot family, and any authenticated initial-memory descriptor required by the chosen initialization mode | $\widetilde{\mathrm{Val}}$, $\widetilde{\mathsf{rv}}$, and $\widetilde{\mathsf{raf}}$ / $\widetilde{\mathsf{waf}}$ only if granted by separate checked reductions |

Virtual objects may be queried only through the paper's checked reductions that grant verifier query access. Raw prover-supplied openings of virtual polynomials are not soundness-carrying objects.

## Normative Implementation Requirements

The rules in this section are not new theorem statements. They are the implementation obligations needed to preserve the paper-level claims above.

- **Commitment-before-challenge discipline.** Challenges for a subprotocol must be sampled only after all committed polynomials relevant to that subprotocol, and all challenge-relevant public metadata, are fixed in the transcript. At minimum this metadata includes the field identifier, `K`, `T`, `d`, the padding or embedding convention, the lowering or visibility-order convention, zero-init versus non-zero-init mode, any initial-memory digest or public descriptor, the lookup-table digest or verifier-side evaluator descriptor, batching choices, and all commitments whose openings will be checked against later challenges.
- **Address-validity and decode obligations are distinct.** Booleanity, Hamming weight `1`, and decode consistency are separate obligations. For the theorem-level valid one-hot assumption, Hamming weight `1` is mandatory and Booleanity may be omitted only if the commitment layer itself enforces it. Decode consistency is additionally mandatory only when the outer protocol uses decoded field-address representations, or when the implementation claims verifier query access to virtual $\widetilde{\mathsf{raf}}$ or $\widetilde{\mathsf{waf}}$.
- **Twist dependency chain must remain intact.** Under the paper's zero-init statement, the implementation must preserve the exact soundness chain $\mathrm{Inc} \to \mathrm{Val} \to \mathrm{rv}$. Under a non-zero-init extension, the implementation must preserve the corresponding proved chain from the chosen modified identity. The read-checking, write-checking, and $\widetilde{\mathrm{Val}}$-evaluation checks remain separate soundness-carrying claims. Do not replace them with an unproved "memory check passed" flag.
- **PIOP batching only where the paper allows it.** Random-linear-combination batching as in Section 4.2.1 is a PIOP-level optimization. For `t` batched claims, it adds at most `t / |\mathbb{F}|` extra soundness error, accounted for as $\varepsilon_{\mathrm{PIOP\_batch}}$.
- **PCS batching is separate.** Any PCS multi-opening batching or commitment-layer batching cost belongs in $\varepsilon_{\mathrm{PCS}}$, not in $\varepsilon_{\mathrm{PIOP\_batch}}$.
- **Field-specific shortcut restriction.** The `2^{-1}` shortcut for the Hamming-weight check is valid only outside characteristic `2`. Over characteristic `2`, the direct sum-check must be used.

## Instantiation-Level Argument-Soundness Accounting

For a concrete non-interactive instantiation, the total argument-soundness budget, not a knowledge-soundness or extractability claim, must account for the paper-level PIOP error and every extra error source introduced by the instantiation:

$$
\varepsilon_{\mathrm{total}}
\le
\varepsilon_{\mathrm{PIOP}}
+ \varepsilon_{\mathrm{PIOP\_batch}}
+ \varepsilon_{\mathrm{PCS}}
+ \varepsilon_{\mathrm{Fiat\text{-}Shamir}}
+ \varepsilon_{\mathrm{outer\ composition}}.
$$

Here, $\varepsilon_{\mathrm{PIOP}}$ is the sum of the paper theorem surfaces actually used, including any separate one-hot-check PIOPs that are needed to discharge the assumptions of the core Shout or Twist theorems, plus any additional proved PIOP surface required by a non-zero-init extension. $\varepsilon_{\mathrm{PIOP\_batch}}$ covers only Section 4.2.1-style random-linear-combination batching. $\varepsilon_{\mathrm{PCS}}$ covers commitment binding, evaluation soundness, and any PCS-side batching or multi-opening analysis.

### Derived Accounting Examples

These are derived examples, not theorem statements.

- **Shout, general `d`, with Figure 8 used to discharge address correctness**

$$
\varepsilon_{\mathrm{total}}
\le
\frac{(d+2)\log T + 2\log K}{|\mathbb{F}|}
+ \frac{4d\log T + 6\log K}{|\mathbb{F}|}
+ \varepsilon_{\mathrm{PIOP\_batch}}
+ \varepsilon_{\mathrm{PCS}}
+ \varepsilon_{\mathrm{Fiat\text{-}Shamir}}
+ \varepsilon_{\mathrm{outer\ composition}}.
$$

- **Twist, general `d`, with Figure 8 used for both read and write addresses**

$$
\varepsilon_{\mathrm{total}}
\le
\frac{(2d+3)\log T + 3\log K}{|\mathbb{F}|}
+ 2 \cdot \frac{4d\log T + 6\log K}{|\mathbb{F}|}
+ \varepsilon_{\mathrm{PIOP\_batch}}
+ \varepsilon_{\mathrm{PCS}}
+ \varepsilon_{\mathrm{Fiat\text{-}Shamir}}
+ \varepsilon_{\mathrm{outer\ composition}}.
$$
