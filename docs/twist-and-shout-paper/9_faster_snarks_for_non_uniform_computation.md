## 9 Faster SNARKs for non-uniform computation

This section describes SpeedySpartan and Spartan++, fast SNARKs for non-uniform circuits. A distinguishing aspect of both is that they incur minimal commitment costs: the prover simply commits to its witness, and the rest of the prover's work is field operations in the sum-check protocol and the cost to prove a polynomial evaluation (which, for appropriate polynomial commitment schemes, can be sub-linear in the size of the circuit). This improves significantly on Spartan and BabySpartan (and other prior SNARKs) for non-uniform circuits.

### 9.1 Overview

In this overview, let us consider the simple and clean setting of proving satisfiability of an arithmetic circuit consisting of fan-in two addition and multiplication gates over field  $\mathbb{F}$ . This treatment extends easily to more general constraint systems.

Suppose that the circuit has size  $T$  and consider two  $\log(T)$ -variate multilinear polynomials  $\tilde{z}_A$  and  $\tilde{z}_B$  that respectively capture the left and right inputs to each gate of the circuit and a third polynomial  $\tilde{z}$  that captures the output of each gate. The first two polynomials,  $\tilde{z}_A$  and  $\tilde{z}_B$  are *virtual polynomials*: they are not explicitly committed/sent by the SpeedySpartan prover. The third polynomial  $\tilde{z}$  is explicitly committed/sent by the prover.

**Overview of SpeedySpartan.** SpeedySpartan applies the sum-check protocol once to confirm that  $\tilde{z}$  respects the operation of its gate. That is, if  $j \in \{0, 1\}^{\log(T)}$  is the label of a multiplication gate, then the sum-check confirms that  $\tilde{z}_C(j) = \tilde{z}_A(j) \cdot \tilde{z}_B(j)$ , and similarly if  $j$  is an addition gate then the sum-check confirms that  $\tilde{z}_C(j) = \tilde{z}_A(j) + \tilde{z}_B(j)$ .

At the end of this sum-check, the verifier has to evaluate each of  $\tilde{z}_A$ , and  $\tilde{z}_B$  and  $\tilde{z}$  at a random point. Since  $\tilde{z}$  was explicitly committed by the prover, the evaluation of  $\tilde{z}$  can be obtained via the evaluation argument of the polynomial commitment scheme. Since  $\tilde{z}_A$  and  $\tilde{z}_B$  are virtual polynomials the verifier cannot obtain their evaluations directly. SpeedySpartan applies the sum-check protocol a second time to reduce the task of computing the necessary evaluations of  $\tilde{z}_A$  and  $\tilde{z}_B$  to the task of evaluating  $\tilde{z}$  at single point. In particular, this second sum-check invocation is simply the **Shout** read-checking sum-check (see Figure 7). That is, the left input  $\tilde{z}_A(j)$  to gate  $j$  is equal to the value *output* by some other gate  $j_L$ , and similarly the right input  $\tilde{z}_B(j)$  to  $j$  is the output of some gate  $j_R$ . This is the same as a *lookup* into the table whose entries are given by  $\tilde{z}$ . The wires of the circuit (i.e., the identities of the left and right inputs to each gate) determine the addresses that are looked up. In the context of SpeedySpartan, these addresses depend only on the circuit wires and hence can be committed (as in **Shout**) by an honest party in pre-processing. This a complete overview of the SpeedySpartan protocol.

**Overview of Spartan++.** Recall that Spartan is a SNARK for R1CS and that SuperSpartan extends it to CCS [STW23], a generalization of Plonkish, R1CS, and AIR. Spartan++ is essentially just SuperSpartan [STW23], but with an improved sparse polynomial commitment scheme used to commit to “constraint matrices”. Specifically, if the prover is claiming to know a solution vector  $z$  to an R1CS instance

$$Az \circ Bz = Cz,$$

(where, unlike in SpeedySpartan,  $A$ ,  $B$ , and  $C$ , may have many non-zeros per row), then Spartan has the multilinear extension polynomials  $\tilde{A}$ ,  $\tilde{B}$ , and  $\tilde{C}$  committed in pre-processing via Spark. In the online phase of Spartan, the sum-check protocol is applied several times, and at the end of these invocations, the Spartan verifier needs to evaluate  $\tilde{A}$ ,  $\tilde{B}$ , and  $\tilde{C}$  at a random point  $r$  (in the case of CCS, the verifier needs evaluations of  $\tilde{M}_0, \dots, \tilde{M}_{t-1}$  for a chosen value of  $t$ ). This evaluation in Spartan is provided by the prover along with a Spark evaluation proof. Spark uses the Lasso lookup argument internally, to perform lookups into a structured table storing all multilinear Lagrange basis polynomials evaluated at  $r$ . Spartan++ is the same, except we give a much faster sparse polynomial commitment scheme, based on **Shout** rather than Lasso. We call this scheme Spark++. Unlike Lasso, **Shout** allows the values returned by the to be virtual, which eliminates the primary bottleneck for the Spark prover (namely, committing to the values returned by the lookups; these values are random since  $r$  is random, and hence very slow to commit to).

## 9.2 Details of SpeedySpartan

### 9.2.1 Detailed protocol description

Our presentation below borrows text from BabySpartan [ST23]. Like BabySpartan [ST23], our focus here is on Plonkish constraint systems. For simplicity and easier adoption, we focus on degree-2 Plonkish, but the protocol readily applies to arbitrary degree Plonkish with custom gates. In particular, we use the definition from Plonk [GWC19, §6], which we state below.

**Definition 9.1 (Plonkish).** Consider a finite field  $\mathbb{F}$ . Let the public parameters consist of size bounds  $m, n, \ell \in \mathbb{N}$ , with  $\ell < n$ . The Plonkish structure consists of: (1) vectors  $q_m, q_l, q_r, q_o, q_c \in \mathbb{F}^m$ , and (2) a set of vectors  $(a, b, c) \in [n]^m$  specifying the left, right, and output indices in a vector containing public IO and witness. An instance  $x \in \mathbb{F}^\ell$  consists of public IO and is satisfied by a witness  $w \in \mathbb{F}^{n-\ell}$  if the following holds for all  $i \in [m]$ .  $(q_l)_i \cdot z_{a_i} + (q_r)_i \cdot z_{b_i} + (q_o)_i \cdot z_{c_i} + (q_m)_i \cdot (z_{a_i} \cdot z_{b_i}) + (q_c)_i = 0$ , where  $z = (w, x)$  and  $z_{a_i}$  denotes the entry of  $z$  at index provided by the  $i$ th entry of vector  $a$ .

Note that Plonkish is a special case of CCS [STW23]. Observe that the vector  $z$  can be viewed as a lookup table and its entries are “looked up” at indices provided by vectors  $a, b$ , and  $c$ . In the language of CCS, we can represent these indices as three sparse matrices. Let  $A, B, C \in \mathbb{F}^{m \times n}$  denote those matrices. In particular,

for all  $i \in [m]$ , the  $i$ th row of  $A$  (similarly  $B$  and  $C$ ) is the unit vector that encodes the position specified by the  $i$ th entry of vector  $a$  (similarly  $b$  and  $c$ ). In other words, each row of  $A, B, C$  contains a single non-zero entry of 1 so that the matrix-vector products  $Az, Bz, Cz$  “lookup” the correct entry of  $z$ . Thus, we can express the Plonkish satisfiability check as follows:

$$q_l \circ Az + q_r \circ Bz + q_o \circ Cz + q_m \circ Az \circ Bz + q_c = 0$$

SpeedySpartan can use any multilinear polynomial commitment scheme. In a preprocessing phase, the verifier (or other honest party) commits to polynomials that encode the circuit structure (i.e., sparse matrices  $A, B, C$ ) using a multilinear polynomial commitment scheme. In the online phase, the prover begins by committing to its purported witness  $\tilde{w}$ . The prover then reduces the circuit satisfiability check to claims about evaluations of  $\tilde{w}$  and polynomials committed in the preprocessing phase. Finally, the prover uses the polynomial evaluation argument of the polynomial commitment scheme to prove those claimed evaluations.

Figure 10 depicts the SpeedySpartan PIOP in full. Below, we describe via prose the resulting SNARK one obtains by combining the PIOP with a multilinear polynomial commitment scheme.

**Preprocessing phase.** In a preprocessing step, the verifier (or another trusted party) computes commitments to the multilinear extensions of the matrices  $A, B, C \in \mathbb{F}^{m \times n}$ . Each row in these matrices is a unit vector, i.e., each row contains a single entry equal to 1 (the rest are zeros). In other words, each matrix proves the one-hot encodings of  $m$  addresses into a table of size  $n$ .

For a chosen parameter  $d \ge 2$ , the commitment to each sparse matrix encodes  $m$  lookup addresses using  $d$ -dimensional one-hot encodings (Section 3.7). Since this commitment is created by the verifier (or another trusted party), there is no need to ensure, as part of Shout, that the underlying vectors are one-hot encodings. That is, Booleanity-checking and additional checks from Figure 8 are not needed. This is analogous to how in Spartan’s preprocessing step [Set20], there is no need to prove the correctness of timestamps in its use of offline memory checking procedure.

**Online phase.** Without loss of generality, let  $m$  and  $n$  be powers of 2 and that  $\ell = n/2$ . Let  $s = \log m, s' = \log n$ . For a purported witness  $w \in \mathbb{F}^{n-\ell}$  and public IO  $x \in \mathbb{F}^\ell$ , let  $z = (w, x) \in \mathbb{F}^n$ . We can view the vector  $z$  as a function with the signature  $\{0, 1\}^{s'} \to \mathbb{F}$ . Similarly, we can view the sparse matrices  $A, B, C$  as functions with the following signature:  $\{0, 1\}^m \times \{0, 1\}^n \to \mathbb{F}$ . Crucially, in our target setting, each row of these sparse matrices is a unit vector (i.e., there is a single non-zero entry of 1 and the rest are zeros).

For all  $x \in \{0, 1\}^s$  and  $M \in \{A, B, C\}$ , let

$$\tilde{z}_M(x) = \left( \sum_{y \in \{0, 1\}^{s'}} \tilde{M}(x, y) \cdot \tilde{z}(y) \right)$$

Also, let

<span id="page-73-0"></span>
$$f(x) = (\tilde{q}_l(x) \cdot \tilde{z}_A(x) + \tilde{q}_r(x) \cdot \tilde{z}_B(x) + \tilde{q}_o(x) \cdot \tilde{z}_C(x) + \tilde{q}_m(x) \cdot \tilde{z}_A(x) \cdot \tilde{z}_B(x) + \tilde{q}_c(x)) \quad (82)$$

The prover begins by sending a commitment to its purported witness  $\tilde{w}$ . To check satisfiability, the verifier selects a random  $\tau \in \mathbb{F}^s$ , and applies the sum-check protocol to the polynomial

$$g(x) = \tilde{\mathbf{e}}q(\tau, x) \cdot f(x),$$

using it to confirm that

$$0 = \sum_{x \in \{0, 1\}^s} g(x).$$

If  $z$  satisfies the constraint system then this equality is guaranteed to hold, and if  $z$  does not satisfy the constraint system then this equality will fail to hold with probability at least  $1 - O(s)/|\mathbb{F}|$ . We call this the “Spartan-sum-check” since this sum-check invocation is exactly how Spartan begins [Set20].

**Preprocessing phase.** The input to this step includes sparse matrices  $A, B, C \in \mathbb{F}^{m \times n}$ , where each row of the sparse matrix is a unit vector, and vectors  $q_l, q_r, q_o, q_m, q_c \in \mathbb{F}^m$ . The preprocessing phase outputs a set of polynomials for which the verifier has a query access.

- Output  $(\tilde{q}_l, \tilde{q}_r, \tilde{q}_o, \tilde{q}_m, \tilde{q}_c, \tilde{\text{addr}}_A, \tilde{\text{addr}}_B, \tilde{\text{addr}}_C)$ , where for  $M \in \{A, B, C\}$ ,  $\tilde{\text{addr}}_M$  is the vector of size  $m \cdot d \cdot n^{1/d}$  listing the  $d$ -dimensional one-hot encodings of addresses provided in  $M$  per Section 3.7 (i.e., viewing each row of  $M$  as the one-hot encoding of an address into a lookup table of size  $n$ ).  $\tilde{\text{addr}}_M$  is sent as  $d$  separate polynomials  $\tilde{\text{addr}}_{M,1}, \dots, \tilde{\text{addr}}_{M,d}$  each of size  $m \cdot n^{1/d}$ .

**Online phase.** The prover is given as input a purported witness vector  $w \in \mathbb{F}^{n-\ell}$  and a public IO vector  $x \in \mathbb{F}^\ell$ . The verifier is given as input  $x \in \mathbb{F}^\ell$ .

1. $\mathcal{P} \to \mathcal{V}$ : A purported witness polynomial  $\tilde{w}$ .
2. $\mathcal{V} \to \mathcal{P}$ : pick  $\tau \in \mathbb{F}^s$  at random and send it to  $\mathcal{P}$ .
3. $\mathcal{V} \leftrightarrow \mathcal{P}$ : Let  $f$  be defined as per Equation (82) (degree-2 Plonkish) or (83) (arithmetic circuits).  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that

$$0 = \sum_{x \in \{0,1\}^s} \text{eq}(\tau, x) \cdot f(x).$$

At the end of the sum-check protocol, the verifier is left with checking whether

$$c = \text{eq}(\tau, r) \cdot f(r),$$

where  $c$  and  $r$  are determined over the course of the sum-check protocol.

1. $\mathcal{P} \to \mathcal{V}$ : Let  $z = (w, x)$ , and  $z_A = A \cdot z$ ,  $z_B = B \cdot z$  and  $z_C = C \cdot z$ . Send  $v_A, v_B, v_C$  defined as follows:

$$v_A \leftarrow \tilde{z}_A(r), \quad v_B \leftarrow \tilde{z}_B(r), \quad v_C \leftarrow \tilde{z}_C(r).$$

1. $\mathcal{V}$ : Let  $e = \text{eq}(\tau, r)$ , and obtain the following values by querying polynomials committed during pre-processing:  $v_l \leftarrow \tilde{q}_l(r), v_r \leftarrow \tilde{q}_r(r), v_o \leftarrow \tilde{q}_o, v_c \leftarrow \tilde{q}_c$ . Reject if

$$c \neq e \cdot (v_l \cdot v_A + v_r \cdot v_B + v_o \cdot v_C + v_m \cdot v_A \cdot v_B + v_c).$$

1. $\mathcal{V} \leftrightarrow \mathcal{P}$ : Apply the core Shout PIOP with addresses from the preprocessing phase ( $\text{addr}_A, \text{addr}_B, \text{addr}_C$ ) to validate claims  $v_A, v_B, v_C$ . That is, for  $M \in \{A, B, C\}$ , apply the sum-check protocol to confirm that:

$$v_M = \sum_{\substack{k=(k_1, \dots, k_d) \in \{0,1\}^{\log(\kappa)/d}, j \in \{0,1\}^{\log T}}} \tilde{\text{eq}}(r, j) \left( \prod_{i=1}^{d} \tilde{\text{addr}}_{M,i}(k_i, j) \right) \cdot \tilde{z}(k). \quad (81)$$

This is equivalent to the Shout read-checking sum-check (Equation (30)) to check the claim that  $v_M = \tilde{z}_M(r)$  where  $\tilde{z}_M$  is the MLE of the purported read values (denoted  $\tilde{r}$  in Equation (30)),  $\tilde{z}$  is the MLE of the lookup table (denoted  $\tilde{\text{Val}}$  in Equation (30)), and  $\tilde{\text{addr}}_{M,1}, \dots, \tilde{\text{addr}}_{M,d}$  together represent the  $d$ -dimensional one-hot encoding of the addresses (denoted  $\tilde{r}_1, \dots, \tilde{r}_d$  in Equation (30)).

<span id="page-74-0"></span>

Figure 10: The description of SpeedySpartan PIOP. Let  $d$  denote the parameter chosen for Shout.

At the end of this invocation of the sum-check protocol, the verifier has to evaluate  $\tilde{z}_A(r)$ ,  $\tilde{z}_B(r)$  and  $\tilde{z}_C(r)$ , where  $r \in \mathbb{F}^s$  is a random point chosen over the course of the sum-check protocol. Hence, the invocation of the sum-check protocol reduced the task of checking that  $z$  satisfies the constraint system, to the task of evaluating the multilinear extensions of  $z_A, z_B$ , and  $z_C$  each at a random point  $r \in \mathbb{F}^s$ .

Recall that by design, each row of  $A, B, C$  has a single non-zero entry (i.e., viewing  $z$  as a lookup table, each row of  $A, B$ , and  $C$  is the one-hot encoding of some address of  $z$ ). So, we invoke the Shout protocol to prove the desired evaluations of  $\tilde{z}_A, \tilde{z}_B$ , and  $\tilde{z}_C$  at  $r$ . In more detail, by using the Shout read-checking sum-check (Equation (30)), the prover reduces the claims about  $\tilde{z}_A(r), \tilde{z}_B(r)$ , and  $\tilde{z}_C(r)$  into evaluations claims about the lookup table  $\tilde{z}$  and polynomials committed in the preprocessing phase.<sup>35</sup> The prover then proves the evaluations of these committed polynomials using a polynomial evaluation argument.

Note that multiple invocations of the sum-check protocol and polynomial evaluation arguments, arising from running Shout for each of  $\tilde{z}_A, \tilde{z}_B, \tilde{z}_C$ , can be batched together using standard techniques (see Sections 4.2.1 and 3.1.1 for details).

### 9.2.2 The special case of arithmetic circuit satisfiability

Arithmetic circuit satisfiability trivially reduces to the following special case of Plonkish:

<span id="page-75-0"></span>
$$f(x) = (1 - \tilde{q}_m(x)) \cdot (\tilde{z}_A(x) + \tilde{z}_B(x)) + \tilde{q}_m(x) \cdot \tilde{z}_A(x) \cdot \tilde{z}_B(x) \quad (83)$$

Here,  $q_m(x) = 1$  if gate  $x$  is a multiplication gate, and equals 0 otherwise. For simplicity and ease of comparing to prior works, we focus on this special case when assessing the costs of SpeedySpartan

### 9.2.3 SpeedySpartan: Analysis of costs

<span id="page-75-3"></span>**Polynomial evaluation proofs and the choice of commitment scheme.** SpeedySpartan's speedups relative to prior work are largest when polynomial evaluation proofs are not a major contributor to prover time. There are several reasons this could be the case. One is that SpeedySpartan can be instantiated with a commitment scheme that comes with very fast evaluation proofs. Another, discussed in Section 3.1.1, is that in applications where many different instances of (one or more) constraint systems arise, folding techniques can ensure only a single evaluation proof needs to be produced across all instances.

We now discuss attractive choices of polynomial commitment schemes that lead to fast SpeedySpartan prover even in settings that are not amenable to folding techniques.

<span id="page-75-4"></span>**Commitment schemes with fast evaluation proof computation.** For fast evaluation proof computation, the most extreme choice is Hyrax [WTS+18]. In Hyrax, the prover simply performs a linear number of field multiplications, which are required anyway to compute the requested evaluation. Moreover, if the committed polynomial is sparse (as is the case in SpeedySpartan), the Hyrax prover's field work grows linearly with the sparsity of the polynomial (i.e., the number of non-zeros). More precisely, if  $M$  out of  $N$  entries of the committed vector are non-zero, the Hyrax prover's work during evaluation proof computation is  $N + O(\sqrt{M})$  field multiplications.

This is a perfect fit to ensure a very fast SpeedySpartan prover. On top of this, Hyrax is transparent and has sublinear (square-root) size commitment key. The downside of Hyrax is that its commitment size and evaluation proof size are fairly large: they are each  $\sqrt{N}$  field and group elements where  $N$  is the size of the committed polynomial. In summary, Hyrax is an attractive choice for SpeedySpartan when prover time is a top priority and sublinear-but-large verifier costs are acceptable.

Another commitment scheme with fast evaluation proof computation is Dory [Lee21]. Indeed, Dory can be seen as a refinement of both Hyrax and Bulletproofs/IPA [BBB+18, BCC+16], and inherits the fast evaluation proofs from Hyrax.<sup>36</sup> Dory evaluation proofs entail the same field work as in Hyrax evaluation proof computation, plus some extra cryptographic work that is asymptotically sublinear. This cryptographic work

<span id="page-75-1"></span>

<sup>35</sup>More precisely, if  $z = (w, x)$  for a public vector  $x$ , then the prover commits to  $\tilde{w}$ , and  $\tilde{z}(r)$  can be evaluated efficiently with one evaluation query to  $\tilde{w}$ . See [Set20, STW23] for details.

<span id="page-75-2"></span>

<sup>36</sup>Essentially, the Dory committer uses pairings to commit to a Hyrax commitment, thereby obviating the  $\sqrt{n}$  commitment size of Hyrax. For evaluation proofs, the Dory prover uses a protocol reminiscent of Bulletproofs/IPA to succinctly prove that it (a) knows a Hyrax commitment that opens the Dory commitment and (b) knows a valid Hyrax evaluation proof. It thereby obviates the  $\sqrt{n}$  evaluation proof size of Hyrax.

consists of roughly  $16\sqrt{N}$  scalar multiplications in  $\mathbb{G}_1$  or  $\mathbb{G}_2$  of a pairing-friendly group, and 6 multi-pairings of size  $\sqrt{N}/2^i$  for each  $i = 1, \dots, \log N$ .

Because pairings are concretely expensive (one pairing is equivalent in cost to about 4000 group operations), these evaluation proofs can be the concrete prover bottleneck (i.e., more expensive than committing or sum-check-proving in SpeedySpartan) unless  $N$  is not too small. This effect is somewhat amplified in SpeedySpartan, because some polynomials arising in the protocol (which are committed in pre-processing) are of slightly superlinear size  $m \cdot n^{1/d}$ . These polynomials have only  $m$  non-zero coefficients, so they do not require superlinear time to commit to even in pre-processing, but this does mean that the  $O(\sqrt{N})$  cryptographic costs arising in Dory evaluation proof computation apply with  $N = m \cdot n^{1/d}$ . So while  $O(\sqrt{N}) = O(\sqrt{m} \cdot n^{1/2d})$  is still sub-linear in  $m$  and  $n$  (and hence evaluation proof computation is asymptotically a low-order prover cost), it can be a concrete SpeedySpartan prover bottleneck if the circuit is small and the parameter  $d$  is small. If this is the case, per Section 3.1.1 one can always further lower the cost of Dory evaluation proof computation by a factor of  $\log T$  with a constant-factor increase in verifier costs, by increasing the commitment size from one target group element to  $\log T$  group elements.

Calculations with our analytic cost model (Section 3.1.2) show that Dory evaluation proofs represent a small fraction of total prover time (at most 30%) so long as  $m$  and  $n$  are at least  $2^{26}$  and  $d \ge 3$ .

<span id="page-76-0"></span>**Challenges with HyperKZG or Bulletproofs.** HyperKZG [ZSC24] and Bulletproofs/IPA [BCC $^{+16}$ , BBB $^{+18}$ ] have expensive evaluation proof computation, as evaluation proofs require the prover to commit to a linear number of random field elements. As discussed above, this issue is amplified in the context of SpeedySpartan because some committed polynomials have size  $m \cdot n^{1/d}$  (though they have sparsity only  $m$ ). This means the commitment key size when using HyperKZG or Bulletproofs is slightly superlinear  $m \cdot n^{1/d}$ , and the evaluation proofs require committing to  $O(m \cdot n^{1/d})$  random field elements. On top of that, unlike Hyrax and Dory, the field work required to compute evaluation proofs grows with the size  $m \cdot n^{1/d}$  of the committed polynomial and not only its sparsity  $m$ . For these reasons, HyperKZG and Bulletproofs appear to be poor fits for SpeedySpartan.

**Detailed costs for SpeedySpartan.** As a running example throughout this section, we consider the case of  $d = 2$  and Hyrax as the choice of polynomial commitment scheme. This leads to a very fast SpeedySpartan prover and achieves non-trivial verifier costs of  $O(m^{1/2}n^{1/4})$ . In this running example, we set  $m = n = 2^{24}$  for concreteness. We also assume that the entries of the witness vector  $z$  are all “small” (see Section 2.1) and hence fast to commit to. This is indeed the case in many applications (where the entries of  $z$  often represent bit or byte decompositions, or 32-bit values).

**Size of proving key.** When Hyrax (or Dory) is used in SpeedySpartan, the (transparently generated) commitment key consists of  $\sqrt{m} \cdot n^{1/d}$  group elements. For example, if  $m = n = 2^{24}$  and  $d = 2$ , this is only  $2^{18}$  group elements, translating to MBs of space.

**Pre-processing.** Pre-processing in SpeedySpartan requires committing to  $3dm$  unit vectors each of length  $n^{1/d}$ , plus 5 vectors of length  $m$ . With Hyrax, committing to the unit vectors requires  $dm$  group operations, while committing to the other 5 vectors (assuming they have small entries per Section 2.1) requires roughly  $5m$  group operations.

**Online phase prover costs.** In SpeedySpartan, during the online phase, the prover only commits to the witness vector  $z$  and nothing else (more precisely, the prover commits to the MLE of its purported witness vector  $w$  of length  $n - \ell$ ). Thus, if the witness vector contains “small” field elements, then the prover only commits to small field elements.

Then the SpeedySpartan prover applies the sum-check protocol several times. Once is the Spartan sum-check, and the other is Shout’s read-checking sum-check, applied to twice in parallel (once for each matrix  $A$  and  $B$ ). The Spartan sum-check can be implemented with  $9m$  field multiplications. This is the cost of the standard linear-time sum-check proving algorithm (Section 3.3) combined with optimizations of Dao and Thaler [DT24] and Gruen [Gru24] (see Section 3.6.1). As a modest additional optimization, we also exploit

<span id="page-77-0"></span>

|                                                        | Plonk<br>(small proof) | Plonk<br>(fast prover) | BabySpartan       | SpeedySpartan<br>( $d = 2$ ) | SpeedySpartan<br>( $d = 3$ ) |
|--------------------------------------------------------|------------------------|------------------------|-------------------|------------------------------|------------------------------|
| Committed field elements<br>(excluding pre-processing) | 8m random<br>3m small  | 6m random<br>3m small  | 3m + n small      | n small                      | n small                      |
| Field multiplications                                  | $54m \log m$           | $54m \log m$           | $33m + 24n$       | $19m + 8n$                   | $29m + 8n$                   |
| Total field multiplications<br>(approximate)           | $54m \log m + 546m$    | $54m \log m + 414m$    | $51m + 30n$       | $19m + 14n$                  | $29m + 14n$                  |
| Total field multiplications<br>(for $m = n = 2^{24}$ ) | $1842 \cdot 2^{20}$    | $1710 \cdot 2^{24}$    | $81 \cdot 2^{24}$ | $33 \cdot 2^{24}$            | $43 \cdot 2^{24}$            |

Figure 11: Prover costs for SpeedySpartan compared with two versions of Plonk [GWC19] and BabySpartan when applied to arithmetic circuits of fan-in two ( $n$  is the total witness size and  $m$  is the number of constraints (i.e.,  $n - m$  is the number of auxiliary, unconstrained inputs). For simplicity we assume  $m = n$  when stating Plonk's costs. When translating committed field elements to field multiplications, we treat each small committed field element as costing one group operation, each random committed field element as costing 11 group operations, and each group operation as costing 6 field operations. See Section 3.1.2 for justification of these translations. The qualitative comparison between protocols is insensitive to these precise choices.

here that  $q_m(x) \in \{0, 1\}$  for all  $x \in \{0, 1\}^{\log m}$ . This ensures that binding the array storing  $q_m$  evaluations produces only  $2^{O(i)}$  distinct values in round  $i$ , which ensures that the prover only incurs  $2^{O(i)}$  multiplications to bind the array in that round.

Per Theorem 6 with  $T = m$ ,  $m = n$  and  $d = 3$ , both invocations of the Shout read-checking sum-check costs  $(d^2 + 2)m + 4n + o(m)$  field operations. Of these,  $m$  field multiplications are devoted to the prover evaluating  $\tilde{\zeta}_A(r)$  and  $\tilde{\zeta}_B(r)$ , which is already done over the course of the Spartan sum-check and accounted for in the costs reported there. So the actual cost of each of these three invocations is  $(d^2 + 1)m + 4n + o(m)$ . For  $d = 2$  and  $m = n$ , this simplifies to about  $9m$  field multiplications per invocation of Shout, and hence  $18m$  across both invocations.

In total, the SpeedySpartan prover performs  $25m$  field multiplications across all invocations of the sum-check protocol.

The SpeedySpartan prover must also provide an evaluation for each committed polynomial. Per the discussion in Section 9.2.3, we focus on settings where this is not a significant contributor to prover time.

**Verifier costs.** The proof size is  $O(d \log(n + m))$  field elements, plus the polynomial evaluation proof provided for each committed polynomial. If desired, standard techniques can batch these evaluation proofs at minimal cost to the prover, ensuring that only a single evaluation proof is provided and verified (see for example [GLH $^{+24}$ , Section 5]). The verifier's runtime is  $O(d \log(n + m))$  field operations plus the cost of checking the polynomial evaluation proof(s).

#### 9.2.4 Comparison of SpeedySpartan with Plonk and BabySpartan

Figure 11 reports quantitative prover costs for Plonk, BabySpartan, and SpeedySpartan. The reported costs apply when these protocols are combined with any elliptic-curve commitment scheme like Hyrax and Dory. The reported costs also apply to HyperKZG and Bulletproofs/IPA, but these commitment schemes are poor fits for SpeedySpartan due to high evaluation proof computation time and commitment key size ( $\S 9.2.3$ ).

We use the reported costs from Plonk [GWC19]. We omit other natural baselines such as HyperPlonk [CBBZ23] as BabySpartan is strictly faster than these baselines. For all schemes, we ignore the cost of evaluation proof computation. This is justified for SpeedySpartan by the discussion above (i.e., we are focused either on choices of commitment schemes for which this is not a significant prover cost, or settings where this cost is insignificant for other reasons).

The comparison can be summarized as follows. With  $d = 2$ , SpeedySpartan improves over the field multiplications performed by the Plonk prover by roughly  $50\times$ , and improves the commitment costs by about  $75\times$ . For commitment costs, the large improvement comes both because SpeedySpartan commits to about  $9\times$ 

fewer field elements than Plonk, and because all of the values committed by the SpeedySpartan prover are small, while  $2/3$  of the values committed by the Plonk prover are random (recall from Sections 2.1 and 3.1.2 that random values take an order of magnitude more time to commit to than small ones). SpeedySpartan with  $d = 2$  improves over the commitment cost of BabySpartan by about  $4\times$ , and over the field work of BabySpartan by about  $2\times$ .

With  $d = 3$ , the field work of SpeedySpartan increases about 30% relative to  $d = 2$ , and the online commitment costs remain the same. The reason to consider higher values of  $d$  is that commitment key size, evaluation proof size, evaluation proof computation time (in the case of Dory), and pre-processing time all decrease as  $d$  grows.

### 9.2.5 Obtaining a folding scheme from SpeedySpartan

Like how an “early stopping” (Super)Spartan leads to HyperNova [KS24a], SpeedySpartan leads to a folding scheme for Plonkish with attractive characteristics: the folding scheme can fold multiple Plonkish instances defined with respect to Plonkish constraint systems that do *not* necessarily share the same circuit structure. Compared to a naive solution that achieves this property, a SpeedySpartan-based solution has far better costs. In fact, the costs are similar to HyperNova: the prover simply commits to its witness and incurs some field operations in the sum-check protocol. The verifier circuit size is logarithmic in the circuit sizes, which is similar to HyperNova’s. We leave it to the future work to improve the size of the verifier circuit with ideas from NeutronNova to use an early-stopping sum-check protocol [KS24b].

## 9.3 Details of Spartan++

### 9.3.1 Spark++: A faster commitment scheme for sparse polynomials

**Commitment phase.** Let  $p$  be a  $T$ -sparse multilinear polynomial to be committed. This means  $p$  is a polynomial in  $\ell$  variables, so  $p$  has size  $2^\ell$ , but there are only  $T = o(2^\ell)$  values of  $x \in \{0, 1\}^\ell$  such that  $p(x) \neq 0$ . Let  $S = \{x \in \{0, 1\}^\ell : p(x) \neq 0\}$ . For simplicity, let us assume that  $p(x) \in \{0, 1\}$  for all  $x \in \{0, 1\}^\ell$ ; this is sufficient to give a SNARK for arithmetic circuits, and the below protocol easily extends (with some increased costs) to eliminate this assumption.

Consider a memory of size  $K = 2^\ell$ . Associate each index of memory with an input  $x \in \{0, 1\}^\ell$ . For parameter  $d \ge 1$ , the commitment to  $p$  is simple the  $d$ -dimensional one-hot encoding of each  $x \in S$ . That is, the commitment to  $p$  consists of  $d$  committed polynomials  $\tilde{r}_1, \dots, \tilde{r}_d$ , where for each  $j \in \{0, 1\}^{\log T}$ ,  $\tilde{r}_1(\cdot, j), \dots, \tilde{r}_d(\cdot, j)$  provides the  $d$ -dimensional one-hot encoding of the  $j$ ’th element of  $S$ .

If the commitment were computed by an untrusted party, any verifier, before running the evaluation phase, would need to run the one-hot-encoding-checking PIOP (Figure 6) to ensure that the commitment to  $p$  is a valid list of  $d$ -dimensional one-hot encodings. However, in the context of Spartan++, the commitments to sparse polynomials  $p$  are all computed by an honest party and hence these checks can be omitted.

**Evaluation phase.** Suppose the verifier requests  $p(r)$ . By multilinear Lagrange interpolation and the assumption that  $p(x) \in \{0, 1\}$  for all  $x \in \{0, 1\}^\ell$ , we can write:

$$p(r) = \sum_{k_1, \dots, k_d \in \{0, 1\}^{\ell/d}, j \in \{0, 1\}^{\log T}} \left( \prod_{i=1}^{d} \tilde{r}_i(k_i, j) \right) \cdot \tilde{e}(k, r).$$

In other words, if we consider the lookup table of size  $K = 2^\ell$  whose  $k$ ’th entry (for  $k \in \{0, 1\}^\ell$ ) is  $\tilde{e}(k, r)$ , and we consider  $S$  to be a list of  $T$  addresses for lookups into this table, then  $p(r)$  is simply

<span id="page-78-0"></span>
$$\sum_{j \in \{0, 1\}^{\log T}} \tilde{r}(j), \quad (84)$$

where  $\tilde{r}$  is the MLE of the values returned by the lookups.

Based on Equation (84), to prove the correct value of  $p(r)$ , the prover has two options. One is to apply the sum-check protocol to compute Expression (84), at the end of which the verifier has to evaluate  $\tilde{r}(r')$  for a random  $r' \in \mathbb{F}^{\log T}$ . The verifier can then accomplish this using Shout's read-checking sum-check applied to the table above. The other option is to observe that Expression (84) equals  $T \cdot \tilde{r}(2^{-1}, \dots, 2^{-1})$  (this observation also arose surrounding Equation (26) in Section 4.1.2), and apply Shout's read-checking sum-check to compute this particular evaluation of  $\tilde{r}$ .

Note that the table to which Shout is applied above is MLE-structured. Indeed, for this table  $\tilde{\text{Val}}(k) = \tilde{\text{eq}}(k, r)$ , which can clearly be evaluated at any point  $k \in \mathbb{F}^\ell$  in  $O(\log K) = O(\ell)$  time, via Equation (15).

**Costs.** Committing to the sparse polynomial  $p$  entails committing to  $d$  vectors, each with  $T$  1s and  $K^{1/d}$  0s. The evaluation phase involves applying Shout to  $T$  lookups into a table of size  $K = 2^\ell$ . This is a canonical table to which the sparse-dense sum-check protocol applies (Section 7.1), enabling the Shout prover to run in time  $O(CT)$  where  $C$  is such that  $K \le T^C$ .

### 9.3.2 Details of Spartan++

Recall that Spartan++ is essentially just SuperSpartan, but with the Spark sparse polynomial commitment scheme replaced with Spark++. Here, we spell out the details. For ease of exposition, we focus on R1CS (a special case of CCS) and Spartan (a special case of SuperSpartan).

**A special case of R1CS capturing arithmetic circuits.** In Spartan++ the prover only commits to the values (i.e., outputs)  $w$  of multiplication gates. If there are  $M$  multiplication gates, then  $w \in \mathbb{F}^M$ , and the prover begins the protocol by committing to the multilinear extension  $\tilde{w}$ .

Let  $z = (w, x) \in \mathbb{F}^n$  where  $x \in \mathbb{F}^{n-M}$  is public input. Ensuring that  $w$  indeed contains the correct value of every multiplication gate entails proving that  $z$  satisfies  $M$  rank-one constraints. Specifically, if  $a_i$  and  $b_i$  are the left and right inputs to multiplication gate  $i$ , then the  $i$ 'th constraint is simply

$$a_i \cdot b_i = w_i.$$

Let us express this constraint system as  $Az \circ Bz = w$  where  $A$  and  $B$  are appropriate matrices in  $\mathbb{F}^{M \times n}$ . Note that, unlike in SpeedySpartan, any particular row of  $A$  and  $B$  may have many non-zero entries (addition gates in the circuit lead to non-zero entries in  $A$  and  $B$ , but addition gates do not increase the number of rows). Further, notice that all of the non-zero entries of these matrices are equal to 1.

**The Spartan++ protocol.** In pre-processing, an honest party commits to  $\tilde{A}$  and  $\tilde{B}$  using Spark++.

In the online phase, as in Spartan, the prover first applies the standard zero-check PIOP (Section 3.6) to confirm that all constraints are satisfied. That is, letting  $a = Az$  and  $b = Bz$ , the verifier picks a random  $r \in \mathbb{F}^{\log M}$  and checks that

<span id="page-79-0"></span>
$$0 = \sum_{x \in \{0,1\}^{\log M}} \tilde{\text{eq}}(r, x) \cdot (\tilde{a}(x) \cdot \tilde{b}(x) - \tilde{w}(x)). \quad (85)$$

At the end of the sum-check protocol, the verifier has to evaluate  $\tilde{a}(r')$ ,  $\tilde{b}(r')$ ,  $\tilde{w}(r')$  and  $\tilde{\text{eq}}(r, r')$  where  $r' \in \mathbb{F}^{\log M}$  is the randomness chosen round-over-round during the sum-check protocol. The evaluation  $\tilde{w}(r')$  can be obtained from the commitment to  $\tilde{w}(r')$ , and  $\tilde{\text{eq}}(r, r')$  can be computed in  $O(\log M)$  time. But  $\tilde{a}$  and  $\tilde{b}$  are not committed—they are effectively virtual polynomials. Hence,  $\tilde{a}(r')$  and  $\tilde{b}(r')$  are computed with an additional application of the sum-check protocol, applied to compute the right hand sides of the following two expressions for  $\tilde{a}(r')$  and  $\tilde{b}(r')$ :

$$\tilde{a}(r') = \sum_{j \in \{0,1\}^{\log n}} \tilde{A}(r', j) \cdot \tilde{z}(j),$$

and

$$\tilde{b}(r') = \sum_{j \in \{0,1\}^{\log n}} \tilde{B}(r', j) \cdot \tilde{z}(j).$$

At the end of these two instances of sum-check (which can be run in parallel and batched per Section 4.2.1), the verifier needs to evaluate  $\tilde{A}(r', r'')$ ,  $\tilde{B}(r', r'')$  and  $\tilde{z}(r'')$  where  $r''$  denotes the randomness chosen over the course of the two parallel sum-check instances. The evaluation  $\tilde{z}(r'')$  can be obtained from the commitment to  $\tilde{z}$ . The evaluations of  $\tilde{A}$  and  $\tilde{B}$  are obtained via Spark++.

**Prover Costs.** Assume for simplicity that  $A$  and  $B$  have the same number of non-zero entries and that this number is  $T$  ( $T$  is proportional to total number of gates in the circuit, counting both addition and multiplication gates).

Given the vectors  $a = Az$  and  $b = Bz$ , the first sum-check (to compute Expression (85)) costs  $5M$  field operations (see [DT24] for full details), while the other two sum-check invocations (to compute  $\tilde{a}(r')$  and  $\tilde{b}(r')$ ) together cost  $M + 5n$  multiplications. In total this is  $6M + 5n$  multiplications for the prover.

It remains to account for the prover cost of applying Shout. Shout is applied to perform  $2T$  lookups into a table of size  $M \cdot n$ , and this table is amenable to the sparse-dense sum-check protocol (Section 7.1). Hence, the cost is at most  $2(d^2 + 4)T$  field multiplications for the prover.

The prover must also provide one evaluation of each committed polynomial  $\tilde{r}_i$ . If Hyrax is the commitment scheme used, this costs  $T$  field multiplications for the prover (and no cryptographic operations), with the field operations needed simply to compute the requested evaluations. If Dory is the commitment scheme used, then additionally several multi-pairings and scalar multiplications all of size at most  $\sqrt{(Mn)^{1/d}} \cdot T$  are also required (see Section 9.2.3 for details of what Dory evaluation proofs entail). Asymptotically this is a low-order cost relative to the linear field work required in Shout, though concretely it may be a prover bottleneck unless  $d$  is fairly large, say  $d \ge 4$ .

Most applications have a small number of public inputs, and hence  $n \approx m$ . Then the above costs can be summarized as follows. Ignoring the (asymptotically low-order) costs of computing evaluation proofs, the Spartan++ prover commits only to the values of all  $M$  multiplication gates in the circuit, and performs the following number of field multiplications:

$$6M + 5n + 2(d^2 + 5)T \approx 11M + (2d^2 + 10)T.$$

For  $d = 4$  this translates to about 42 field multiplications per addition gate and 53 per multiplication gate. This is concretely slower than SpeedySpartan (see Figure 11) though it is interesting that the Spartan++ prover's commitment costs grow only with  $M$ , the number of multiplication gates.

Despite being slower than SpeedySpartan, Spartan++ is about 6× faster than Spartan itself. The cost analysis for Spartan underlying this comparison is as follows. Recall that Spartan applies Spark to  $\tilde{A}$  and  $\tilde{B}$ , and that Spark applies Lasso internally. In this application of Lasso, the prover commits to 2 random field elements per non-zero entry of  $A$  and  $B$ . This translates to about 22 group operations per non-zero, which is roughly equivalent to  $22 \cdot 6 = 132$  field operations. On top of the commitment costs, the prover also performs 24 field operations within Lasso. So this yields 156 field operations per non-zero matrix entry. Since there are  $2T$  non-zeros between the two matrices, this is about  $312T$  field operations in total to implement Lasso-within-Spark-within-Spartan. This is about 6× the prover cost of Spartan++ with  $d = 4$ .

**Disclosures.** Justin Thaler is a Research Partner at a16z crypto and is an investor in various blockchain-based platforms, as well as in the crypto ecosystem more broadly (for general a16z disclosures, see <https://www.a16z.com/disclosures/>).

<span id="page-81-2"></span><span id="page-81-1"></span><span id="page-81-0"></span>
