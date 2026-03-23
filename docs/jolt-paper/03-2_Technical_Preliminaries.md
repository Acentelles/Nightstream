## 2 Technical Preliminaries

### 2.1 Multilinear extensions

An  $\ell$ -variate polynomial  $p: \mathbb{F}^\ell \to \mathbb{F}$  is said to be *multilinear* if  $p$  has degree at most one in each variable. Let  $f: \{0, 1\}^\ell \to \mathbb{F}$  be any function mapping the  $\ell$ -dimensional Boolean hypercube to a field  $\mathbb{F}$ . A polynomial  $g: \mathbb{F}^\ell \to \mathbb{F}$  is said to *extend*  $f$  if  $g(x) = f(x)$  for all  $x \in \{0, 1\}^\ell$ . It is well-known that for any  $f: \{0, 1\}^\ell \to \mathbb{F}$ , there is a unique *multilinear* polynomial  $\tilde{f}: \mathbb{F}^\ell \to \mathbb{F}$  that extends  $f$ . The polynomial  $\tilde{f}$  is referred to as the *multilinear extension* (MLE) of  $f$ .

**Multilinear extensions of vectors.** Given a vector  $u \in \mathbb{F}^m$ , we will often refer to the *multilinear extension* of  $u$  and denote this multilinear polynomial by  $\tilde{u}$ .  $\tilde{u}$  is obtained by viewing  $u$  as a function mapping  $\{0, 1\}^{\log m} \to \mathbb{F}$  in the natural way<sup>14</sup>: the function interprets its ( $\log m$ )-bit input  $(i_0, \dots, i_{\log m - 1})$  as the binary representation of an integer  $i$  between 0 and  $m - 1$ , and outputs  $u_i$ .  $\tilde{u}$  is defined to be the multilinear extension of this function.

**Lagrange interpolation.** An explicit expression for the MLE of any function is given by the following standard lemma (see [Tha22, Lemma 3.6]).

**Lemma 1.** *Let  $f: \{0, 1\}^\ell \to \mathbb{F}$  be any function. Then the following multilinear polynomial  $\tilde{f}$  extends  $f$ :*

$$\tilde{f}(x_0, \dots, x_{\ell-1}) = \sum_{w \in \{0, 1\}^\ell} f(w) \cdot \chi_w(x_0, \dots, x_{\ell-1}), \quad (2)$$

where, for any  $w = (w_0, \dots, w_{\ell-1})$ ,  $\chi_w(x_0, \dots, x_{\ell-1}) := \prod_{i=0}^{\ell-1} (x_i w_i + (1 - x_i)(1 - w_i))$ . Equivalently,

$$\chi_w(x_0, \dots, x_{\ell-1}) = \widetilde{\text{EQ}}(x_0, \dots, x_{\ell-1}, w_0, \dots, w_{\ell-1}).$$

The polynomials  $\{\chi_w: w \in \{0, 1\}^\ell\}$  are called the *Lagrange basis polynomials* for  $\ell$ -variate multilinear polynomials. The evaluations  $\{\tilde{f}(w): w \in \{0, 1\}^\ell\}$  are sometimes called the coefficients of  $\tilde{f}$  in the *Lagrange basis*, terminology that is justified by Equation (2).

---

<sup>14</sup>All logarithms in this paper are to base 2.

**SNARKs.** We adapt the definition provided in [KST22].

**Definition 2.1.** Consider a relation  $\mathcal{R}$  over public parameters, structure, instance, and witness tuples. A non-interactive argument of knowledge for  $\mathcal{R}$  consists of PPT algorithms  $(\mathcal{G}, \mathcal{P}, \mathcal{V})$  and deterministic  $\mathcal{K}$ , denoting the generator, the prover, the verifier and the encoder respectively with the following interface.

- $\mathcal{G}(1^\lambda) \to \text{pp}$ : On input security parameter  $\lambda$ , samples public parameters  $\text{pp}$ .
- $\mathcal{K}(\text{pp}, \mathbf{s}) \to (\text{pk}, \text{vk})$ : On input structure  $\mathbf{s}$ , representing common structure among instances, outputs the prover key  $\text{pk}$  and verifier key  $\text{vk}$ .
- $\mathcal{P}(\text{pk}, u, w) \to \pi$ : On input instance  $u$  and witness  $w$ , outputs a proof  $\pi$  proving that  $(\text{pp}, \mathbf{s}, u, w) \in \mathcal{R}$ .
- $\mathcal{V}(\text{vk}, u, \pi) \to \{0, 1\}$ : On input the verifier key  $\text{vk}$ , instance  $u$ , and a proof  $\pi$ , outputs 1 if the instance is accepting and 0 otherwise.

A non-interactive argument of knowledge satisfies completeness if for any PPT adversary  $\mathcal{A}$

$$\Pr \left[ \mathcal{V}(\text{vk}, u, \pi) = 1 \mid \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda), \\ (\mathbf{s}, (u, w)) \leftarrow \mathcal{A}(\text{pp}), \\ (\text{pp}, \mathbf{s}, u, w) \in \mathcal{R}, \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \mathbf{s}), \\ \pi \leftarrow \mathcal{P}(\text{pk}, u, w) \end{array} \right] = 1.$$

A non-interactive argument of knowledge satisfies knowledge soundness if for all PPT adversaries  $\mathcal{A}$  there exists a PPT extractor  $\mathcal{E}$  such that for all randomness  $\rho$

$$\Pr \left[ \begin{array}{l} \mathcal{V}(\text{vk}, u, \pi) = 1, \\ (\text{pp}, \mathbf{s}, u, w) \notin \mathcal{R} \end{array} \mid \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda), \\ (\mathbf{s}, u, \pi) \leftarrow \mathcal{A}(\text{pp}; \rho), \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \mathbf{s}), \\ w \leftarrow \mathcal{E}(\text{pp}, \rho) \end{array} \right] = \text{negl}(\lambda).$$

A non-interactive argument of knowledge is succinct if the verifier's time to check the proof  $\pi$  and the size of the proof  $\pi$  are at most polylogarithmic in the size of the statement proven.

**Polynomial commitment schemes.** We adapt the definition from [BFS20]. A polynomial commitment scheme for multilinear polynomials is a tuple of four protocols  $\text{PC} = (\text{Gen}, \text{Commit}, \text{Open}, \text{Eval})$ :

- $\text{pp} \leftarrow \text{Gen}(1^\lambda, \ell)$ : takes as input  $\ell$  (the number of variables in a multilinear polynomial); produces public parameters  $\text{pp}$ .
- $\mathcal{C} \leftarrow \text{Commit}(\text{pp}, \mathcal{G})$ : takes as input a  $\ell$ -variate multilinear polynomial over a finite field  $\mathcal{G} \in \mathbb{F}[\ell]$ ; produces a commitment  $\mathcal{C}$ .
- $b \leftarrow \text{Open}(\text{pp}, \mathcal{C}, \mathcal{G})$ : verifies the opening of commitment  $\mathcal{C}$  to the  $\ell$ -variate multilinear polynomial  $\mathcal{G} \in \mathbb{F}[\ell]$ ; outputs  $b \in \{0, 1\}$ .
- $b \leftarrow \text{Eval}(\text{pp}, \mathcal{C}, r, v, \ell, \mathcal{G})$  is a protocol between a PPT prover  $\mathcal{P}$  and verifier  $\mathcal{V}$ . Both  $\mathcal{V}$  and  $\mathcal{P}$  hold a commitment  $\mathcal{C}$ , the number of variables  $\ell$ , a scalar  $v \in \mathbb{F}$ , and  $r \in \mathbb{F}^\ell$ .  $\mathcal{P}$  additionally knows a  $\ell$ -variate multilinear polynomial  $\mathcal{G} \in \mathbb{F}[\ell]$ .  $\mathcal{P}$  attempts to convince  $\mathcal{V}$  that  $\mathcal{G}(r) = v$ . At the end of the protocol,  $\mathcal{V}$  outputs  $b \in \{0, 1\}$ .

**Definition 2.2.** A tuple of four protocols  $(\text{Gen}, \text{Commit}, \text{Open}, \text{Eval})$  is an extractable polynomial commitment scheme for multilinear polynomials over a finite field  $\mathbb{F}$  if the following conditions hold.

- **Completeness.** For any  $\ell$ -variate multilinear polynomial  $\mathcal{G} \in \mathbb{F}[\ell]$ ,

$$\Pr \left\{ \begin{array}{l} \text{pp} \leftarrow \text{Gen}(1^\lambda, \ell); \mathcal{C} \leftarrow \text{Commit}(\text{pp}, \mathcal{G}); \\ \text{Eval}(\text{pp}, \mathcal{C}, r, v, \ell, \mathcal{G}) = 1 \land v = \mathcal{G}(r) \end{array} \right\} \ge 1 - \text{negl}(\lambda)$$

- **Binding.** For any PPT adversary  $\mathcal{A}$ , size parameter  $\ell \ge 1$ ,

$$\Pr \left\{ \begin{array}{l} \text{pp} \leftarrow \text{Gen}(1^\lambda, \ell); (\mathcal{C}, \mathcal{G}_0, \mathcal{G}_1) = \mathcal{A}(\text{pp}); \\ b_0 \leftarrow \text{Open}(\text{pp}, \mathcal{C}, \mathcal{G}_0); b_1 \leftarrow \text{Open}(\text{pp}, \mathcal{C}, \mathcal{G}_1): \\ b_0 = b_1 \neq 0 \wedge \mathcal{G}_0 \neq \mathcal{G}_1 \end{array} \right\} \le \text{negl}(\lambda)$$

- **Knowledge soundness.** *Eval* is a succinct argument of knowledge for the following NP relation given  $\text{pp} \leftarrow \text{Gen}(1^\lambda, \ell)$ :

$$\mathcal{R}_{\text{Eval}}(\text{pp}) = \{ \langle (\mathcal{C}, r, v), (\mathcal{G}) \rangle : \mathcal{G} \in \mathbb{F}[\mu] \wedge \mathcal{G}(r) = v \wedge \text{Open}(\text{pp}, \mathcal{C}, \mathcal{G}) = 1 \}.$$

### 2.2 Polynomial IOPs and polynomial commitments

Modern SNARKs are constructed by combining a type of interactive protocol called a *polynomial IOP* [BFS20] with a cryptographic primitive called a *polynomial commitment scheme* [KZG10]. The combination yields a succinct *interactive* argument, which can then be rendered non-interactive via the Fiat-Shamir transformation [FS86], yielding a SNARK.

Roughly, a polynomial IOP is an interactive protocol where, in one or more rounds, the prover may “send” to the verifier a very large polynomial  $g$ . Because  $g$  is so large, one does not wish for the verifier to read a complete description of  $g$ . Instead, in any efficient polynomial IOP, the verifier only “queries”  $g$  at one point (or a handful of points). This means that the only information the verifier needs about  $g$  to check that the prover is behaving honestly is one (or a few) evaluations of  $g$ .

In turn, a polynomial commitment scheme enables an untrusted prover to succinctly *commit* to a polynomial  $g$ , and later provide to the verifier any evaluation  $g(r)$  for a point  $r$  chosen by the verifier, along with a proof that the returned value is indeed consistent with the committed polynomial. Essentially, a polynomial commitment scheme is exactly the cryptographic primitive that one needs to obtain a succinct argument from a polynomial IOP. Rather than having the prover send a large polynomial  $g$  to the verifier as in the polynomial IOP, the argument system prover instead cryptographically commits to  $g$  and later reveals any evaluations of  $g$  required by the verifier to perform its checks.

Whether or not a SNARK requires a trusted setup, as well as whether or not it is plausibly post-quantum secure, is determined by the polynomial commitment scheme used. If the polynomial commitment scheme does not require a trusted setup, neither does the resulting SNARK, and similarly if the polynomial commitment scheme is plausibly binding against quantum adversaries, then the SNARK is plausibly post-quantum sound.

Lasso can make use of any commitment schemes for *multilinear* polynomials  $g$ .<sup>15</sup> Here an  $\ell$ -variate multilinear polynomial  $g: \mathbb{F}^\ell \to \mathbb{F}$  is a polynomial of degree at most one in each variable.

### 2.3 Lookup arguments

Lookup arguments allow a prover to commit to two vectors  $a \in \mathbb{F}^m$  and  $b \in \mathbb{F}^m$  (with a polynomial commitment scheme) and prove that each entry  $a_i$  of vector  $a$  resides in index  $b_i$  of a pre-determined lookup table  $T \in \mathbb{F}^N$ . That is, For each  $i = 1, \dots, m$ ,  $a_i = T[b_i]$ . Here, to emphasize the interpretation of  $T$  as a table, we use square brackets  $T[i]$  to denote the  $i$ ’th entry of  $T$ . Here, if  $b_i \notin \{1, \dots, N\}$ , then  $t[b_i]$  is undefined, and hence  $a_i \neq T[b_i]$ . We refer to  $a$  as the vector of *looked-up values* and  $b$  as the vector of *indices*.

**Definition 2.3** (Lookup arguments, indexed variant). *Let  $PC = (\text{Gen}, \text{Commit}, \text{Open}, \text{Eval})$  be an extractable polynomial commitment scheme for multilinear polynomials over  $\mathbb{F}$ . A lookup argument (for indexed lookups) for table  $T \in \mathbb{F}^N$  is a SNARK for the relation*

$$\{(\text{pp}, \mathcal{C}_1, \mathcal{C}_2, w = (a, b)) : a, b \in \mathbb{F}^m \wedge a_i = T[b_i] \text{ for all } i \in \{1, \dots, m\} \wedge \text{Open}(\text{pp}, \mathcal{C}_1, \tilde{a}) = 1 \wedge \text{Open}(\text{pp}, \mathcal{C}_2, \tilde{b}) = 1\}.$$

Here  $w = (a, b) \in \mathbb{F}^m \times \mathbb{F}^m$  is the witness, while  $\text{pp}$ ,  $\mathcal{C}_1$ , and  $\mathcal{C}_2$  are public inputs.

<sup>15</sup> Any univariate polynomial commitment scheme can be transformed into a multilinear one, though the transformations introduce some overhead (see, e.g., [CBBZ23, BCHO22, ZXZS20]).

Definition 2.3 captures so-called *indexed* lookup arguments (this terminology was introduced in our companion work [STW23]). Other works consider *unindexed* lookup arguments, in which only the vector  $a \in \mathbb{F}^m$  of looked-up values is committed, and the prover claims that *there exists* a vector  $b$  of indices such that  $a_i = T[b_i]$  for all  $i = 1, \dots, m$ .

**Definition 2.4** (Lookup arguments, unindexed variant). *Let  $PC = (\text{Gen}, \text{Commit}, \text{Open}, \text{Eval})$  be an extractable polynomial commitment scheme for multilinear polynomials over  $\mathbb{F}$ . A lookup argument (for indexed lookups) for table  $T \in \mathbb{F}^N$  is a SNARK for the relation*

$$\{(\text{pp}, \mathcal{C}_1, \mathcal{C}_2, a) : a \in \mathbb{F}^m \land \text{for all } i \in \{1, \dots, m\}, \text{ there exists } b_i \text{ such that } a_i = T[b_i] \land \text{Open}(\text{pp}, \mathcal{C}_1, \tilde{a}) = 1\}.$$

Here  $a \in \mathbb{F}^m \times \mathbb{F}^m$  is the witness, while  $\text{pp}$  and  $\mathcal{C}_1$  are public inputs.

Jolt primarily requires indexed lookups. However, a few instructions (namely ADVICE and MOVE) require range checks, which are naturally handled by unordered lookups (to prove that a value is in the range  $\{0, \dots, 2^L - 1\}$ , perform an unordered lookup into the table  $T$  with  $T[i] = i$  for  $i = \{0, \dots, 2^L - 1\}$ ).

There are natural reductions in both directions, i.e., unindexed lookup arguments can be transformed into index lookup arguments and vice versa. To obtain an unindexed lookup argument from an indexed one,  $\mathcal{P}$  separately commits to the index vector  $b$  and applies the indexed lookup argument. Obtaining an indexed lookup argument from an unindexed one is slightly more complicated and is detailed in our companion paper [STW23, Appendix A]. Our companion work, Lasso, described below, directly yields an indexed lookup argument, and hence does not require this transformation.

**A companion work: Lasso.** Our companion work [STW23] introduces a family of lookup arguments called Lasso. The lookup arguments in this family are the first that do not require any party to cryptographically commit to the table vector  $T \in \mathbb{F}^N$ , so long as  $T$  satisfies one of the two structural properties defined below.

**Definition 2.5** (MLE-structured tables). *We say that a vector  $T \in \mathbb{F}^N$  is MLE-structured if for any input  $r \in \mathbb{F}^{\log(N)}$ ,  $\tilde{T}(r)$  can be evaluated with  $O(\log(N))$  field operations.*

**Definition 2.6** (Decomposable tables). *Let  $T \in \mathbb{F}^N$ . We say that  $T$  is  $c$ -decomposable if there exist a constant  $k$  and  $\alpha \le kc$  tables  $T_1, \dots, T_\alpha$  each of size  $N^{1/c}$  and each MLE-structured, as well as a multilinear  $\alpha$ -variate polynomial  $g$  such that the following holds. As in Section 2.1, let us view  $T$  as a function mapping  $\{0, 1\}^{\log N}$  to  $\mathbb{F}$  in the natural way, and view each  $T_i$  as a function mapping  $\{0, 1\}^{\log(N)/c} \to \mathbb{F}$ . Then for any  $r \in \{0, 1\}^{\log N}$ , writing  $r = (r_1, \dots, r_c) \in \{0, 1\}^{\log(N)/c}$ ,*

$$T[r] = g(T_1[r_1], \dots, T_k[r_1], T_{k+1}[r_2], \dots, T_{2k}[r_2], \dots, T_{\alpha-k+1}[r_c], \dots, T_\alpha[r_c]).$$

We refer to  $T_1, \dots, T_\alpha$  as sub-tables.

For any constant  $c > 0$  and any  $c$ -decomposable table, our companion paper gives a lookup argument called Lasso, in which the prover commits to roughly  $3cm + cN^{1/c}$  field elements. Moreover, all of these field elements are *small*, meaning that they are all in  $\{0, \dots, m\}$  (specifically, they are counts for the number of times each entry of each subtable is read), or are elements of the subtables  $T_1, \dots, T_\alpha$ . The verifier performs  $O(\log(m) \log \log(m))$  hash evaluations and field operations, processes one evaluation proof from the polynomial commitment scheme applied to a multilinear polynomial in  $\log m$  variables, and evaluates  $\tilde{T}_1, \dots, \tilde{T}_\alpha$  each at a single randomly chosen point.

Our companion paper also describes a lookup argument called Generalized-Lasso, which applies to any MLE-structured table, not just decomposable ones.<sup>16</sup> The main disadvantage of Generalized-Lasso relative to Lasso is that  $cm$  out of the  $3cm + cN^{1/c}$  field elements committed by the Generalized-Lasso prover are random rather than small. As described in Section 1.3.1, such field elements can take an order of magnitude more work to commit to than small field elements.

<sup>16</sup>In fact, Generalized-Lasso applies to any table with *some* low-degree extension, not necessarily its multilinear one, that is evaluable in logarithmic time.

**The relationship between MLE-structured and decomposable tables.** For any decomposable table  $T \in \mathbb{F}^N$ , there is some low-degree extension  $\hat{T}$  of  $T$  (namely, an extension of degree at most  $k$  in each variable) that can be evaluated in  $O(\log N)$  time. Specifically, the extension polynomial is

$$\hat{T}(r) = g(\tilde{T}_1(r_1), \dots, \tilde{T}_\alpha(r_c)).$$

In general,  $\hat{T}$  is not necessarily multilinear, so a table being decomposable does not necessarily imply that it is MLE-structured. But Generalized-Lasso actually applies to any table with a low-degree extension that is evaluable in logarithmic time. In this sense, decomposability (the condition required to apply Lasso) is a strictly stronger condition than what is necessary to apply Generalized-Lasso.

In Jolt, we show *all* lookup tables used are *both*  $c$ -decomposable (for any integer  $c > 0$ ) as well as MLE-structured. We choose to apply Lasso rather than Generalized-Lasso due to its superior efficiency (which comes from the prover only committing to small field elements, avoiding the need to commit to random field elements). On the other hand, we believe that there would be meaningful improvements in simplicity of implementation if Jolt used Generalized-Lasso rather than Lasso. Arguably, the performance loss from using Generalized-Lasso in place of Lasso is justified by the simplicity benefits. See Section 7 for further discussion.

### 2.4 Offline Memory Checking

Any SNARK for VM execution has to perform *memory-checking*. This means that the prover must be able to commit to an execution trace for the VM (that is, a step-by-step record of what the VM did over the course of its execution), and the verifier has to find a way to confirm that the prover maintained memory correctly throughout the entire execution trace. In other words, the value purportedly returned by any read operation in the execution trace must equal the value most recently written to the appropriate memory cell. We use the term *memory-checking argument* to refer to a SNARK for the above functionality. Note that a lookup table  $T \in \mathbb{F}^N$  can be viewed as a read-only memory of size  $N$ , with memory cell  $i$  initialized to  $T[i]$ . Hence, a lookup argument for indexed lookups (Definition 2.3) is equivalent to a memory-checking argument for read-only memories.

A variety of memory-checking arguments have been described in the research literature [ZGK<sup>+</sup>18, BCG<sup>+</sup>18, STW23, BFR<sup>+</sup>13, BSCGT13] (with the underlying techniques rediscovered multiple times). The most efficient are based on lightweight fingerprinting techniques for the closely related problem of *offline memory checking* [Lip89, BEG<sup>+</sup>91]. In this work, we use such an argument due to Spice [SAGL18], but optimize it using Lasso. For completeness, we provide an overview of other memory-checking arguments in Appendix B, and Spice’s in particular in Appendix B.3.

### 2.5 R1CS

The Jolt prover convinces the verifier that it correctly ran a VM for some number of steps on a specified input. Most of the VM’s work is verified in Jolt via a lookup argument and a memory-checking arguments. The remaining checks are simple and can be captured via any natural constraint system. One such option is the standard notion of rank-one constraint systems, defined next.

**Definition 2.7.** An R1CS instance is a tuple  $(\mathbb{F}, A, B, C, M, M', N, x)$ , where  $A, B, C \in \mathbb{F}^{M \times M'}$ ,  $M' \ge |x|+1$ ,  $x$  denotes the public input and output, and there are at most  $N$  non-zero entries in each matrix. A vector  $z = (w, 1, x) \in \mathbb{F}^{M'}$  is said to satisfy the instance if  $A \cdot z \circ B \cdot z = C \cdot z$ , where  $\cdot$  denotes matrix-vector product and  $\circ$  denotes Hadamard (i.e., entrywise) product.
