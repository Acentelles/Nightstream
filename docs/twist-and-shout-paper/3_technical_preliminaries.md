### 3 Technical preliminaries

#### 3.1 Prover costs in elliptic-curve-based SNARKs

**Cost of field operations.** On modern CPUs, multiplying two elements of a 256-bit prime field using Montgomery multiplication costs between 40 and 80 CPU cycles. Field additions for such fields are an order of magnitude cheaper.

**Elliptic curve commitments.** In order to understand the advantages of the method of increments, it is necessary to explain the prover cost profile in SNARKs that use elliptic curve commitments. Three points are paramount: (1) committing to 0s is “free” (2) commitment to “small” values is faster than committing to “big values”, and (3) under appropriate conditions, we can “ignore” the cost of computing evaluation proofs. Details follow.

Let  $\ell = \log(n)$  and  $p$  be an  $\ell$ -variate multilinear polynomial over a field  $\mathbb{F}$ . Let  $\mathbb{G}$  be a cryptographic group with scalar field equal to  $\mathbb{F}$ .

With elliptic-curve-based polynomial commitment schemes, the commitment to an  $\ell$ -variate multilinear polynomial  $p$  is simply a multi-exponentiation of size  $n = 2^\ell$ , namely:

<span id="page-28-0"></span>
$$\prod_{x_i \in \{0,1\}^\ell} g_i^{y_i} \quad (13)$$

where  $y_i = p(x_i)$  is the evaluation  $p$  at input  $x_i \in \{0,1\}^\ell$ . (In this paper, we treat  $\mathbb{G}$  as a multiplicative group, so the product in Equation (13) refers to the group operation.) Here, each  $g_i \in \mathbb{G}$  is an element of the *commitment key*, a publicly known vector of group elements of length  $n = 2^\ell$  that is needed to produce commitments.

Equation (13) is also referred to as a *Pedersen vector commitment*, with the vector at hand being the exponents in Equation (13), i.e., the vector  $y$  of evaluations of  $p$  as its input ranges over  $\{0,1\}^\ell$ . Accordingly, we will often refer to the procedure of committing to  $p$  as “committing to  $n = 2^\ell$  values”, those values being the entries of  $y$ .

<span id="page-28-1"></span>**Commitment costs.** The “smaller” the  $y_i$  values, the faster it is to compute the commitment in Equation (13). Specifically, using Pippenger’s bucketing algorithm, for any desired  $B \ll n$ , roughly one group operation is incurred for each  $y_i \in \{0,1,\dots,B\}$ , two group operations are incurred for each  $y_i \in \{B+1,\dots,B^2\}$ , and in general  $c$  group operations are required for each  $y_i \in \{B^{c-1}+1,\dots,B^d\}$ . In other words, committing to a  $c \log(n)$ -bit value  $y_i$  requires about  $c$  group operations.

Accordingly, in order to understand the cost of committing to a vector, it is not enough to analyze the *length* of the committed vector, one must also analyze how big or small the vector’s values are.

Notice in particular that if  $y_i = p(x_i) = 0$ , then  $g_i^{y_i} = 1$ , and hence the multi-exponentiation in Equation (13) is unaffected by the  $i$ ’th term. This means that committing to 0s is free for the prover, in the sense that any 0-values that are committed do not alter the commitment whatsoever.

We refer to the number of non-zero entries of  $y$  as the *sparsity* of  $p$  and of  $y$ . The above means that the time to commit to  $p$  and  $y$  depend only on the sparsity, and not the ambient dimension  $n = 2^\ell$ . The ambient dimension of  $y$  does factor into other prover costs, discussed shortly, but not into the time required to compute the commitment.

Another important special case is an exponent  $y_i = 1$ . The total contribution to the commitment of all such exponents can be computed with *exactly* one group operation per entry  $i$  with  $y_i = 1$ , as this contribution is:

$$\prod_{i: y_i=1} g_i.$$

Pippenger's bucketing algorithm achieves an amortized cost of *very close to* one group operation per committed value in  $\{2, \dots, B\}$ , but not exactly one. The smaller  $B$  is relative to the length  $n$  of the committed vector  $y$  (or more precisely, the number of entries of  $y$  outside of  $\{0, 1\}$ ), the closer the amortized cost of commitment is to one group operation per value  $y_i$  in  $\{2, \dots, B\}$ .

Not only is it fast to commit to small positive values via Equation (13), it is also fast to commit to “small negative values”, i.e., values in  $\{-B^d, \dots, -1\}$ . To do this, one can in preprocessing invert each element of the original commitment key, so that the commitment key becomes  $(g_1, \dots, g_n, h_1, \dots, h_n)$ , where  $h_i = g_i^{-1}$ . Then committing to a negative value  $y_i$  can be done by committing to the positive value  $-y_i$  using group element  $h_i$  in place of  $g_i$ . The Twist prover will need this in order to commit to “increments” quickly, since increments can be negative.

**The cost of computing evaluation proofs.** While *commitment time* depends only on the sparsity of  $p$  when using elliptic-curve-based polynomial commitment schemes, committed 0s are not literally free. They do affect the time required to compute evaluation proofs.

Specifically, if the committed vector  $y$  has length  $n$ , then evaluation proofs for multilinear polynomial commitment schemes like HyperKZG and Zeromorph require the prover to compute commitments to (i.e., multi-exponentiations over) a vector  $v$  of length  $n$  with *random* entries (in fact, several such vectors). If  $y$  is sparse and only contains small values, committing to  $v$  as required in the evaluation proof is potentially orders of magnitude more expensive than merely committing to  $y$ . This is because  $v$  is *not* sparse, nor are its entries small.

Furthermore, if using HyperKZG or Zeromorph, committed 0s also affect the size of the “powers-of-tau” SRS [KZG10] used by these commitment schemes. Specifically, to commit to an  $\ell$ -variate multilinear polynomial with these schemes, one needs an SRS of size  $2^\ell$  regardless of the sparsity of the committed polynomial.

Fortunately, both of the above issues (large evaluation proof computation time, and large SRS) can be addressed by the standard amortization technique described next.

### 3.1.1 Amortizing the cost of computing evaluation proofs via homomorphism

Elliptic curve commitment schemes automatically come with extremely powerful amortization properties for evaluation proofs that render this concern moot, at least so long as  $n$  is not *too* much bigger than  $m$ . For example, let  $\ell = \ell_1 + \ell_2$ . Rather than committing to  $p$  directly, instead commit to  $2^{\ell_1}$  different  $\ell_2$ -variate multilinear polynomials, where for each  $z \in \{0, 1\}^{\ell_1}$ , the  $z$ 'th committed polynomial is  $g_z(x) = p(z, x)$ .

Suppose the verifier requests the evaluation  $p(r, r')$  for  $r \in \mathbb{F}^{\ell_1}$  and  $r' \in \mathbb{F}^{\ell_2}$ . The verifier on its own can, via homomorphism, compute a commitment to the  $\ell_2$ -variate polynomial  $g(x) = p(r, x)$ , and the prover merely needs to provide an evaluation proof for  $g(r_2)$ . Computing this evaluation proof is roughly  $2^{\ell_1}$  times cheaper than computing an evaluation proof if  $p$  had been committed directly.

The downside of this technique is that the commitment size grows by a factor of  $2^{\ell_1}$ , and the verifier has to perform  $2^{\ell_1}$  group exponentiations<sup>25</sup> to homomorphically compute the commitment to  $g(x) = p(r, x)$ . In many contexts, this is an acceptable increase in verifier costs even for  $2^{\ell_1}$  in the dozens or hundreds. For example, HyperKZG and Zeromorph evaluation proofs require the verifier to do a couple of dozen group exponentiations regardless, so having the verifier do an extra couple of dozen exponentiations at most doubles verifier costs. And SNARK verifiers do more than merely process commitments, so doubling the verifier's costs to process commitments may mean less than a doubling of total verifier costs.

<span id="page-29-0"></span>**Even more powerful amortization via folding.** A related reason that the cost of polynomial evaluation proofs can often be ignored is the use of folding schemes. Folding schemes are closely related to the above amortization procedure, except that by invoking recursion, they avoid the  $2^{\ell_1}$ -factor increase in verifier costs.

<span id="page-29-1"></span>

<sup>25</sup>More precisely, a multi-exponentiation of length  $2^{\ell_1}$ .

Here is a sketch what folding schemes can accomplish in the context of zkVMs. Say a prover wants to prove it ran a RISC-V program correctly for  $C$  cycles. To bound the prover's memory usage, one can split the computation up into, say,  $C/S$  shards each consisting of  $S$  cycles. One can apply a zkVM to prove correct execution of each shard separately, and then use folding techniques to recursively aggregate the proofs. Specifically, represent the zkVM verifier (*minus* verification of polynomial evaluation proofs, as such claims can be “accumulated” similar to the above example, rather than verified directly) via a constraint system like R1CS. Then proving that one knows a valid proof for each of the  $C/S$  shards is equivalent to proving that one knows satisfying assignments for  $C/S$  instances of the constraint system, one per shard. One can apply an efficient folding procedure such as Nova [KST22] to obtain a single “folded” instance of the constraint system such that knowledge of a satisfying assignment to the folded instance is equivalent to knowledge of a satisfying assignment of all  $C/S$  original instances. Section 2.9.3 provides more details.

The key point for our purposes is that in this setting, only a single polynomial evaluation needs to be provided, for a polynomial whose size is proportional to the size of a *single* shard.<sup>26</sup> That is, by breaking the CPU's execution into  $C/S$  shards and applying folding, one obtains a roughly  $(C/S)$ -fold reduction in the cost of computing an evaluation proof, compared to if the entire  $C$ -cycle CPU execution was proved in a monolithic fashion.

For the reasons above, it is often reasonable to ignore the computation of polynomial evaluation proofs when analyzing SNARK prover costs. Henceforth in this work, we do this.

**Comparison to sparse polynomial commitment schemes.** Readers may wonder about the relationship between the discussion above and the notion of *sparse polynomial commitment schemes* such as Spark [Set20]. These are polynomial commitment schemes that enable the prover to efficiently commit to an  $\ell$ -variate multilinear polynomial  $p$  in time proportional to the number  $T$  of inputs  $x \in \{0, 1\}^\ell$  such that  $p(x) \neq 0$ . We refer to  $T$  as the *sparsity* of  $p$ . Haven't we just asserted that a simple Pedersen vector commitment achieves exactly this property, and also that the cost of evaluation proofs can be ignored due to amortization techniques? Doesn't that mean that any elliptic-curve based polynomial commitment scheme immediately gives a sparse polynomial commitment scheme?

The answer is that sparse polynomial commitment schemes like Spark are generally targeted at settings where  $n = 2^\ell$  is so much larger than the sparsity  $T$  that the cost of computing evaluation proofs *cannot* be ignored, even given the excellent amortization properties described above.

For example, the situation where  $n = T^2$  naturally arises in SNARKs for R1CS or circuit satisfiability, and this is the setting that motivated the development of Spark (and also arises in our study of SNARKs for non-uniform constraint systems, see Section 9). In the zkVM context,  $n$  turns out to equal  $K \cdot T$  where  $K$  is the size of the memory being checked. There are two potential differences between our setting and Spark's:

- We are interested in settings where  $T$  is in the millions or billions or larger (in a zkVM context,  $T$  corresponds roughly to the number of cycles in the VM's execution), but where  $K$  may (or may not) be much smaller. For example, in the setting of RISC-V registers,  $K$  is just 32. This is a setting where the cost of evaluation proofs can definitely be ignored due to amortization, but this this may not be the case if  $n \ge T^2$  as considered in Spark.
- Spark is a polynomial commitment scheme for *arbitrary* sparse polynomials. Whereas, *Twist* and *Shout* do not need to commit to arbitrary sparse polynomials, but rather to polynomials whose evaluations can be viewed as a  $K \times T$  matrix that have *exactly one non-zero entry per row*. Nonetheless, we show in Section 9.3.1 that *Shout* indirectly yields a general sparse polynomial commitment scheme, a major improvement over Spark that we call *Spark++*.

<span id="page-30-0"></span>

<sup>26</sup>This ability to avoid having the prover produce a polynomial evaluation proof for each shard, and avoid recursively proving that it verified such a proof, is a key benefit of folding schemes compared to the “brute force recursion” [Tea22, COS20] that is used today by all zkVMs that avoid elliptic curves.

### 3.1.2 An analytic cost model: relating group operations to field operations

When committing to a multilinear polynomial  $p$  defined over field  $\mathbb{F}$  using an elliptic curve group  $\mathbb{G}$ ,  $\mathbb{F}$  will always be the *scalar field* of  $\mathbb{G}$ , which is why we can interpret evaluations of  $p$  as *exponents* of group elements in Equation (13). Elements of  $\mathbb{G}$  correspond to pairs of elements  $(x, y)$  in a *different* field  $\mathbb{B}$  called the *base field* of  $\mathbb{G}$ . And group operations are naturally defined in terms of base field operations. Specifically, multiplying two group elements together typically requires about 6 base-field multiplications [GW20a].

Despite the fact that  $\mathbb{B}$  and  $\mathbb{F}$  are different fields, often operations in  $\mathbb{B}$  and  $\mathbb{F}$  have the same cost. For example, if the elliptic curve is BN254, both field implementations involve 256-bit Montgomery arithmetic [Mon85]. This allows us to directly relate the cost of group operations to  $\mathbb{F}$ -operations: a single operation in  $\mathbb{G}$  has roughly the same cost as 6 multiplications in  $\mathbb{F}$ . We ignore the cost of field additions, as in 256-bit fields they are an order of magnitude cheaper than field multiplications.

Some pairing-friendly curves, like BLS12-381, have a larger base field than scalar field (e.g., the base field is 381 bits for BLS12-381 while the scalar field is only 256 bits). For these fields and curves, the method of increments is still attractive relative to memory-checking techniques. This is because the method of increments has substantially lower commitment costs compared to memory-checking techniques (by commitment costs, we mean the number of group operations required to commit to data). And the bigger the base field of the elliptic curve group, the more expensive those group operations are.

**Summary of our analytic cost model.** On CPUs, we consider a 256-bit field multiplication to be 40-80 times more expensive than a native multiplication of two 64-bit data types [MvOV01, Chapter 14]. We consider a group operation (often called a group addition, using additive-group terminology) to be roughly 6 times as expensive as a field operation [GW20a]. We treat small committed values as costing exactly one group operation (see Section 2.1, especially Footnote 7, and Section 3.1 for discussion). We treat random values as costing about 11 group operations to commit to (as this is an optimistic bound on the runtime of Pippenger’s algorithm at realistic input sizes [EHB22]). We ignore field additions, as well as multiplications by small constants such as 2, since  $2x = x + x$ .

A scalar multiplication (aka group exponentiation) by an arbitrary field element is equivalent in cost to roughly 400 group operations via the standard double-and-add algorithm, and a pairing evaluation is equivalent in cost to roughly 10 scalar multiplications.

**Caveats.** Of course, any such cost model will only approximately match actual system performance. Different cryptographic groups have different base field sizes, and real hardware is complicated (e.g., some operations are memory-bound rather than compute bound). However, the above approximate costs are carefully informed by examination of how field operations and group operations are actually computed, as well as by microbenchmarks.

Any inaccuracies in our cost model generally understate our improvements over prior works. For example, we treat all small committed values as costing exactly one group operation, when in fact committing to a 1-value truly requires one group operation, and committing to larger-but-still-small values is somewhat more expensive. Since our protocols commit to more 1-values and fewer larger-but-still-small values than prior work, this cost model understates our speedups.

## 3.2 Multilinear extensions

Our treatment of multilinear extension polynomials, polynomial commitment schemes, and SNARKs is standard and taken verbatim from Setty and Thaler [STW23].

An  $\ell$ -variate polynomial  $p: \mathbb{F}^\ell \to \mathbb{F}$  is said to be *multilinear* if  $p$  has degree at most one in each variable. Let  $f: \{0, 1\}^\ell \to \mathbb{F}$  be any function mapping the  $\ell$ -dimensional Boolean hypercube to a field  $\mathbb{F}$ . A polynomial  $g: \mathbb{F}^\ell \to \mathbb{F}$  is said to *extend*  $f$  if  $g(x) = f(x)$  for all  $x \in \{0, 1\}^\ell$ . It is well-known that for any  $f: \{0, 1\}^\ell \to \mathbb{F}$ , there is a unique *multilinear* polynomial  $\tilde{f}: \mathbb{F}^\ell \to \mathbb{F}$  that extends  $f$ . The polynomial  $\tilde{f}$  is referred to as the *multilinear extension* (MLE) of  $f$ .

A basic fact about multilinear polynomials is the following.

<span id="page-32-4"></span>**Fact 3.1.** Let  $p: \mathbb{F}^n \to \mathbb{F}$  be any multilinear polynomial. Then for any  $c \in \mathbb{F}$  and any  $x' \in \{0, 1\}^{n-1}$ ,

<span id="page-32-0"></span>
$$p(c, x') = (1 - c) \cdot p(0, x') + c \cdot p(1, x'). \quad (14)$$

*Proof.* The right and left hand sides of Equation (14) are both multilinear polynomials and are easily seen to evaluate to the same value whenever  $(c, x') \in \{0, 1\} \times \{0, 1\}^{n-1}$ . Since  $\{0, 1\}^n$  is an interpolating set for multilinear polynomials, the left hand side and right hand side of Equation (14) must be equal for all  $c \in \mathbb{F}$  (and any  $x' \in \mathbb{F}^{n-1}$  as well).  $\square$ 

The right hand side of Equation (14) can be computed with a single field multiplication, as it equals  $p(0, x') + c \cdot (p(1, x') - p(0, x'))$ .

A particular multilinear extension that arises frequently in the design of interactive proofs is the  $\tilde{\text{eq}}$  is the MLE of the function  $\text{eq}: \{0, 1\}^s \times \{0, 1\}^s \to \mathbb{F}$  defined as follows:

<span id="page-32-1"></span>
$$\text{eq}(x, e) = \begin{cases} 1 & \text{if } x = e \\ 0 & \text{otherwise.} \end{cases}$$

An explicit expression for  $\tilde{\text{eq}}$  is:

$$\tilde{\text{eq}}(x, e) = \prod_{i=1}^{s} (x_i e_i + (1 - x_i)(1 - e_i)). \quad (15)$$

Indeed, one can easily check that the right hand side of Equation (15) is a multilinear polynomial, and that if evaluated at any input  $(x, e) \in \{0, 1\}^s \times \{0, 1\}^s$ , it outputs 1 if  $x = e$  and 0 otherwise. Hence, the right hand side of Equation (15) is the unique multilinear polynomial extending  $\text{eq}$ . Equation (15) implies that  $\tilde{\text{eq}}(r_1, r_2)$  can be evaluated at any point  $(r_1, r_2) \in \mathbb{F}^s \times \mathbb{F}^s$  in  $O(s)$  time.<sup>27</sup>

Another multilinear extension that we will make use of is the MLE of the *less-than* function. Given any vector  $j = (j_1, \dots, j_{\log T}) \in \{0, 1\}^{\log T}$ , define

$$\text{int}(j) = \sum_{i=1}^{\log T} 2^{i-1} \cdot j_i.$$

That is,  $\text{int}(j)$  is the integer whose binary representation is  $j$ . Then define

$$\text{LT}(j', j) = \begin{cases} 1 & \text{if } \text{int}(j') < \text{int}(j) \\ 0 & \text{otherwise.} \end{cases}$$

It was shown in [STW24, Appendix G, see Equation 58 on Page 56] that  $\tilde{\text{LT}}$  can be evaluated at any input  $(r', r) \in \mathbb{F}^{\log T} \times \mathbb{F}^{\log T}$  with  $O(\log T)$  field operations. See also Appendix B.

**Multilinear extensions of vectors.** Given a vector  $u \in \mathbb{F}^m$ , we will often refer to the *multilinear extension of  $u$*  and denote this multilinear polynomial by  $\tilde{u}$ .  $\tilde{u}$  is obtained by viewing  $u$  as a function mapping  $\{0, 1\}^{\log m} \to \mathbb{F}$  in the natural way<sup>28</sup>: the function interprets its  $(\log m)$ -bit input  $(i_0, \dots, i_{\log m - 1})$  as the binary representation of an integer  $i$  between 0 and  $m - 1$ , and outputs  $u_i$ .  $\tilde{u}$  is defined to be the multilinear extension of this function.

<span id="page-32-2"></span>

<sup>27</sup>Throughout this manuscript, we consider any field addition or multiplication to require constant time.

<span id="page-32-3"></span>

<sup>28</sup>All logarithms in this paper are to base 2.

**Multilinear Lagrange interpolation.** An explicit expression for the MLE of a vector  $u \in \mathbb{F}^m$  is as follows:

$$\tilde{u}(x) = \sum_{y \in \{0,1\}^{\log m}} u_y \cdot \tilde{\mathbf{eq}}(y, x).$$

Indeed, it is easily checked that the right hand side of the above equality is multilinear in  $x$ , and for any  $x \in \{0,1\}^{\log m}$  the right hand side equals  $u_x$ . Hence, the right hand side is the unique multilinear extension of  $u$ .

For each  $y \in \{0,1\}^{\log m}$ , the multilinear polynomial

$$x \mapsto \tilde{\mathbf{eq}}(y, x) = \prod_{i=1}^{\log m} (y_i x_i + (1 - y_i)(1 - x_i))$$

is called the  $y$ th multilinear Lagrange basis polynomial.

The following lemma is well-known [VSBW13].

**Lemma 1** (Vu et al. [VSBW13]). Given as input a point  $r \in \mathbb{F}^{\log m}$ , it is possible to evaluate all Lagrange basis polynomials at  $r$  using only  $m$  field multiplications. Given a vector  $u \in \mathbb{F}^m$ , it is possible to compute  $\tilde{u}(r)$  with  $2m$  field multiplications.

*Proof.* For  $i = 1, \dots, m$ , define  $A_i$  to be the array of length  $2^i$ , with entries indexed by  $x \in \{0,1\}^i$ , such that  $A_i[x] = \tilde{\mathbf{eq}}(x, r_1, \dots, r_i)$ . Then

$$A_{i+1}[x, 1] = r_i \cdot A_i[x]$$

and

$$A_{i+1}[x, 0] = (1 - r_i) \cdot A_i[x] = A_i[x] - A_{i+1}[x, 1].$$

 $A_{\log m}$  contains the desired evaluations. The total cost to compute  $A_{\log m}$  is  $1 + 2 + \dots + m/2 = m$  multiplications. See [Rot24] for an alternative algorithm.

Given a vector  $u \in \mathbb{F}^m$ ,  $\tilde{u}(r)$  is simply the inner product of  $u$  with  $A_{\log m}$ . This inner product can be computed with  $m$  field multiplications (on top of the  $m$  required to compute  $A_{\log m}$ ).  $\square$ 

### 3.3 The sum-check protocol

Let  $g$  be some  $\ell$ -variate polynomial defined over a finite field  $\mathbb{F}$ . The purpose of the sum-check protocol is for prover to provide the verifier with the following sum:

$$H := \sum_{b \in \{0,1\}^{\ell}} g(b). \quad (16)$$

To compute  $H$  unaided, the verifier would have to evaluate  $g$  at all  $2^{\ell}$  points in  $\{0,1\}^{\ell}$  and sum the results. The sum-check protocol allows the verifier to offload this hard work to the prover. It consists of  $\ell$  rounds, one per variable of  $g$ . In round  $i$ , the prover sends a message consisting of  $d_i$  field elements, where  $d_i$  is the degree of  $g$  in its  $i$ th variable, and the verifier responds with a single (randomly chosen) field element. If the prover is honest, this polynomial (in the single variable  $X_i$ ) is

$$\sum_{(b_{i+1}, \dots, b_{\ell-1}) \in \{0,1\}^{\ell-i}} g(r_0, \dots, r_{i-1}, X_i, b_{i+1}, \dots, b_{\ell-1}). \quad (17)$$

Here, we are indexing both the rounds of the sum-check protocol and the variables of  $g$  starting from zero (i.e., indexing them by  $\{0,1,\dots,\ell-1\}$ ), and  $r_0, \dots, r_{i-1}$  are random field elements chosen by the verifier across rounds  $0, \dots, i-1$  of the protocol.

The protocol has perfect completeness, and soundness error  $(\sum_{i=1}^{\ell} d_i) / |\mathbb{F}|$ . The verifier's runtime is  $O(\sum_{i=1}^{\ell} d_i)$ , plus the time required to evaluate  $g$  at a single point  $r \in \mathbb{F}^{\ell}$ . In the typical case that  $d_i = O(1)$ 

for each round  $i$ , this means the total verifier time is  $O(\ell)$ , plus the time required to evaluate  $g$  at a single point  $r \in \mathbb{F}^\ell$ . This is exponentially faster than the  $2^\ell$  time that would generally be required for the verifier to compute  $H$ . See [AB09, Chapter 8] or [Tha22, §4.1] for details.

**Review of linear-time sum-check proving.** Suppose the sum-check protocol is applied to compute  $\sum_{x \in \{0,1\}^n} \tilde{\text{eq}}(r', x) \cdot g(x)$  for some fixed  $r' \in \mathbb{F}^n$ , where

$$g(x) = \prod_{i=1}^{\ell} p_i(x), \quad (18)$$

and where each  $p_i$  is multilinear. Let  $N = 2^n$ . The standard linear-time sum-check prover algorithm [CTY11, Tha13] has the prover begin by storing arrays  $A_1, \dots, A_\ell$  each of size  $N$  with entries indexed by  $\{0,1\}^n$ , where  $A_i(x)$  stores  $p_i(x)$ . The prover also stores an array  $B$  containing all evaluations  $\tilde{\text{eq}}(r, x)$  as  $x$  ranges over  $\{0,1\}^n$ . It is known how to build this array with  $N$  field multiplications in total.

In round  $m$  of the sum-check protocol, for each  $c' \in \{0,1,2,\dots,\ell+1\}$ , the must compute

<span id="page-34-0"></span>
$$s_m(c') = \sum_{y \in \{0,1\}^{n-m}} \text{eq}(r', r_1, \dots, r_{m-1}, c', y) g(r_1, \dots, r_{m-1}, c, y), \quad (19)$$

where  $s_m$  is the degree- $(\ell+1)$  univariate polynomial sent by the sum-check prover in round  $\ell$ .

Accordingly, the sum-check prover at the start of each round  $m$  makes sure that  $A_i$  stores  $p_i(r_1, \dots, r_{m-1}, y)$  as  $y$  ranges over  $\{0,1\}^{n-(m-1)}$ . By Fact 3.1, the following procedure suffices to ensure this. At the end of each round  $m$ , when the verifier selects that round's random challenge  $r_m \in \mathbb{F}$ , the sum-check prover updates each entry  $A_i(y)$  for  $y \in \{0,1\}^{n-m}$  to:

$$A_i(y) \leftarrow p_i(r_1, \dots, r_m, y) = (1 - r_m) \cdot p_i(r_1, \dots, r_{m-1}, 0, y) + r_m \cdot p_i(r_1, \dots, r_{m-1}, 1, y) \\ = A_i(0, y) + r_m \cdot (A_i(y, 1) - A_i(y, 0)). \quad (20)$$

We refer to this procedure as the prover *binding* the  $m$ 'th variable to  $r_m$ . A similar update is performed on the array  $B$  of evaluations  $\tilde{\text{eq}}(r', r_1, \dots, r_m, y)$ .

Given the  $A_i$  arrays at each round  $m$ , the prover can evaluate  $g(r_1, \dots, r_{m-1}, c', y)$  for the  $\ell+2$  relevant points  $c'$  and all  $y \in \{0,1\}^{n-m}$  with  $\ell-1$  field multiplications per point. Multiplying  $g(r_1, \dots, r_{m-1}, c', y)$  by the value  $\tilde{\text{eq}}(r', r_1, \dots, r_{m-1}, c', y)$  (which is easily derivable from the array  $B$  without additional general field multiplications) costs an additional field multiplication per point, and this counts all field operations needed to compute the quantities appearing in Equation (19).

Hence, the prover's total work across all rounds of the sum-check protocol is  $\ell \cdot N$  field multiplications across all binding operations for the arrays  $A_1, \dots, A_\ell$ , plus  $2N$  operations to compute and then bind the  $B$  array, plus  $\ell \cdot (\ell+2) \cdot N$  field multiplications across all rounds to compute the prover's messages given the arrays  $A_1, \dots, A_\ell$ . That is

$$(\ell^2 + 3\ell + 2)N$$

field multiplications in total.

Recent optimizations have brought this cost down. Dao and Thaler [DT24] show how to effectively eliminate the  $2N$  operations required to build and bind the  $B$  array of  $\tilde{\text{eq}}$  evaluations. And it's well-known that the prover need not consider the evaluation point  $c' = 1$  in each round because when the prover is honest,  $s_m(1) = s_{m-1}(r_{m-1}) - s_m(0)$ . On top of this, Gruen [Gru24] effectively showed that the evaluation point  $\ell+1$  can be omitted as well (see Section 3.6.1 for details). Combining these optimizations, the number of field multiplications performed by the prover falls to roughly

$$(\ell^2 + \ell) \cdot N.$$

### 3.4 SNARKs and commitment schemes

**SNARKs** We adapt the definition provided in [KST22].

**Definition 3.1.** Consider a relation  $R$  over public parameters, structure, instance, and witness tuples. A non-interactive argument of knowledge for  $R$  consists of PPT algorithms  $(\mathcal{G}, \mathcal{P}, \mathcal{V})$  and deterministic  $\mathcal{K}$ , denoting the generator, the prover, the verifier and the encoder respectively with the following interface.

- $\mathcal{G}(1^\lambda) \to \text{pp}$ : On input security parameter  $\lambda$ , samples public parameters  $\text{pp}$ .
- $\mathcal{K}(\text{pp}, s) \to (pk, vk)$ : On input structure  $s$ , representing common structure among instances, outputs the prover key  $pk$  and verifier key  $vk$ .
- $\mathcal{P}(pk, u, w) \to \pi$ : On input instance  $u$  and witness  $w$ , outputs a proof  $\pi$  proving that  $(\text{pp}, s, u, w) \in R$ .
- $\mathcal{V}(vk, u, \pi) \to \{0, 1\}$ : On input the verifier key  $vk$ , instance  $u$ , and a proof  $\pi$ , outputs 1 if the instance is accepting and 0 otherwise.

A non-interactive argument of knowledge satisfies completeness if for any PPT adversary  $\mathcal{A}$ 

$$\Pr \left[ \mathcal{V}(vk, u, \pi) = 1 \middle| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda), \\ (s, (u, w)) \leftarrow \mathcal{A}(\text{pp}), \\ (\text{pp}, s, u, w) \in R, \\ (pk, vk) \leftarrow \mathcal{K}(\text{pp}, s), \\ \pi \leftarrow \mathcal{P}(pk, u, w) \end{array} \right] = 1.$$

A non-interactive argument of knowledge satisfies knowledge soundness if for all PPT adversaries  $\mathcal{A}$  there exists a PPT extractor  $\mathcal{E}$  such that for all randomness  $\rho$ 

$$\Pr \left[ \begin{array}{l} \mathcal{V}(vk, u, \pi) = 1, \\ (\text{pp}, s, u, w) \notin R \end{array} \middle| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda), \\ (s, u, \pi) \leftarrow \mathcal{A}(\text{pp}; \rho), \\ (pk, vk) \leftarrow \mathcal{K}(\text{pp}, s), \\ w \leftarrow \mathcal{E}(\text{pp}, \rho) \end{array} \right] = \text{negl}(\lambda).$$

A non-interactive argument of knowledge is succinct if the verifier's time to check the proof  $\pi$  and the size of the proof  $\pi$  are at most polylogarithmic in the size of the statement proven.

**Polynomial commitment scheme** We adapt the definition from [BFS20]. A polynomial commitment scheme for multilinear polynomials is a tuple of four protocols  $\text{PC} = (\text{Gen}, \text{Commit}, \text{Open}, \text{Eval})$ :

- $\text{pp} \leftarrow \text{Gen}(1^\lambda, \ell)$ : takes as input  $\ell$  (the number of variables in a multilinear polynomial); produces public parameters  $\text{pp}$ .
- $\mathcal{C} \leftarrow \text{Commit}(\text{pp}, g)$ : takes as input a  $\ell$ -variate multilinear polynomial over a finite field  $g \in \mathbb{F}[\ell]$ ; produces a commitment  $\mathcal{C}$ .
- $b \leftarrow \text{Open}(\text{pp}, \mathcal{C}, g)$ : verifies the opening of commitment  $\mathcal{C}$  to the  $\ell$ -variate multilinear polynomial  $g \in \mathbb{F}[\ell]$ ; outputs  $b \in \{0, 1\}$ .
- $b \leftarrow \text{Eval}(\text{pp}, \mathcal{C}, r, v, \ell, g)$  is a protocol between a PPT prover  $\mathcal{P}$  and verifier  $\mathcal{V}$ . Both  $\mathcal{V}$  and  $\mathcal{P}$  hold a commitment  $\mathcal{C}$ , the number of variables  $\ell$ , a scalar  $v \in \mathbb{F}$ , and  $r \in \mathbb{F}^\ell$ .  $\mathcal{P}$  additionally knows a  $\ell$ -variate multilinear polynomial  $g \in \mathbb{F}[\ell]$ .  $\mathcal{P}$  attempts to convince  $\mathcal{V}$  that  $g(r) = v$ . At the end of the protocol,  $\mathcal{V}$  outputs  $b \in \{0, 1\}$ .

**Definition 3.2.** A tuple of four protocols  $(\text{Gen}, \text{Commit}, \text{Open}, \text{Eval})$  is an extractable polynomial commitment scheme for multilinear polynomials over a finite field  $\mathbb{F}$  if the following conditions hold.

- **Completeness.** For any  $\ell$ -variate multilinear polynomial  $g \in \mathbb{F}[\ell]$ ,

$$\Pr \left\{ \begin{array}{l} \text{pp} \leftarrow \text{Gen}(1^\lambda, \ell); \mathcal{C} \leftarrow \text{Commit}(\text{pp}, g); \\ \text{Eval}(\text{pp}, \mathcal{C}, r, v, \ell, g) = 1 \land v = g(r) \end{array} \right\} \ge 1 - \text{negl}(\lambda)$$

• **Binding.** For any PPT adversary  $\mathcal{A}$ , size parameter  $\ell \ge 1$ ,

$$\Pr \left\{ \begin{array}{l} \text{pp} \leftarrow \text{Gen}(1^\lambda, \ell); (\mathcal{C}, g_0, g_1) = \mathcal{A}(\text{pp}); \\ b_0 \leftarrow \text{Open}(\text{pp}, \mathcal{C}, g_0); b_1 \leftarrow \text{Open}(\text{pp}, \mathcal{C}, g_1); \\ b_0 = b_1 \neq 0 \land g_0 \neq g_1 \end{array} \right\} \le \text{negl}(\lambda)$$

• **Knowledge soundness.**  $\text{Eval}$  is a succinct argument of knowledge for the following NP relation given  $\text{pp} \leftarrow \text{Gen}(1^\lambda, \ell)$ .

$$\mathcal{R}_{\text{Eval}}(\text{pp}) = \{ \langle (\mathcal{C}, r, v), (g) \rangle : g \in \mathbb{F}[\mu] \land g(r) = v \land \text{Open}(\text{pp}, \mathcal{C}, g) = 1 \}$$

### 3.5 Polynomial IOPs and polynomial commitments

Modern SNARKs are constructed by combining a type of interactive protocol called a *polynomial IOP* [BFS20] with a cryptographic primitive called a *polynomial commitment scheme* [KZG10]. The combination yields a succinct *interactive* argument, which can then be rendered non-interactive via the Fiat-Shamir transformation [FS86b], yielding a SNARK.

Roughly, a polynomial IOP is an interactive protocol where, in one or more rounds, the prover may “send” to the verifier a very large polynomial  $g$ . Because  $g$  is so large, one does not wish for the verifier to read a complete description of  $g$ . Instead, in any efficient polynomial IOP, the verifier only “queries”  $g$  at one point (or a handful of points). This means that the only information the verifier needs about  $g$  to check that the prover is behaving honestly is one (or a few) evaluations of  $g$ .

In turn, a polynomial commitment scheme enables an untrusted prover to succinctly *commit* to a polynomial  $g$ , and later provide to the verifier any evaluation  $g(r)$  for a point  $r$  chosen by the verifier, along with a proof that the returned value is indeed consistent with the committed polynomial. Essentially, a polynomial commitment scheme is exactly the cryptographic primitive that one needs to obtain a succinct argument from a polynomial IOP. Rather than having the prover send a large polynomial  $g$  to the verifier as in the polynomial IOP, the argument system prover instead cryptographically commits to  $g$  and later reveals any evaluations of  $g$  required by the verifier to perform its checks.

**Costs of some specific polynomial commitment schemes.** The following elliptic-curve-based polynomial commitments are of particular interest to us. Two are HyperKZG and Zeromorph [ZSC24, KT23]. These are homomorphic commitment schemes for multilinear polynomials. The commitment consists of one group element in a pairing friendly group  $\mathbb{G}_1$ , and committing to an  $\ell$ -variate multilinear polynomial  $p$  consists of applying an MSM to the vector of evaluations of  $p$  across all inputs in  $\{0, 1\}^\ell$ . The commitment key is the powers-of-tau SRS (also used in KZG commitments [KZG10]) of size  $N = 2^\ell$ . Evaluation proofs have logarithmic size and verifying them requires performing two or three pairings and an MSM of logarithmic size. Computing the evaluation proof requires, for each  $i = 1, \dots, \ell$ , a constant number of MSMs of length  $2^i$  (the scalars in this MSM are random field elements, if the evaluation point is random).

Dory [Lee21] is a transparent elliptic-curve-based polynomial commitment scheme that also uses pairings. An attractive property of Dory is that its commitment key is sublinear size, consisting of only  $\sqrt{N}$  elements of  $\mathbb{G}_1$  and  $\sqrt{N}$  elements of  $\mathbb{G}_2$ . Committing to an  $\ell$ -variate multilinear polynomial entails performing roughly  $\sqrt{N}$  MSMs each of length  $\sqrt{N}$  (as with HyperKZG and Zeromorph, the scalars the MSMs are applied to comprise evaluations of  $p$  across all inputs in  $\{0, 1\}^\ell$ ). In addition, committing requires computing a *multi-pairing* of size  $\sqrt{N}$ .<sup>29</sup> Dory has a transparent linear-time pre-processing phase, which produces a verification key of size just  $O(\log N)$ . Evaluation proofs consist of  $6 \log N$  target group elements and verifying them involves logarithmically many scalar multiplications in the target group.

### 3.6 Zero-check PIOP

Let  $g$  be an  $\ell$ -variate polynomial of, say, constant degree in each variable. The following standard interactive proof establishes that  $g(x) = 0$  for all  $x \in \{0, 1\}^\ell$ , while requiring the verifier to merely evaluate  $g$  at a single point in  $\mathbb{F}^\ell$  (after processing a proof consisting of  $O(\ell)$  field elements).

<span id="page-36-0"></span>

<sup>29</sup>A multi-pairing of size  $S$  is an expression of the form  $\prod_{i=1}^{S} e(a_i, b_i)$  where each  $a_i \in \mathbb{G}_1$  and  $b_i \in \mathbb{G}_2$ .

The verifier picks an input  $r \in \mathbb{F}^\ell$  at random. The prover and verifier apply the sum-check protocol to confirm that

<span id="page-37-0"></span>
$$0 = \sum_{x \in \{0,1\}^\ell} \tilde{\mathbf{eq}}(r, x) \cdot g(x). \quad (21)$$

This PIOP is perfectly complete. By a direct application of the Schwartz-Zippel lemma, the soundness error is  $\ell/|\mathbb{F}|$  (plus the soundness error of the sum-check protocol itself).

### 3.6.1 An optimization of Gruen

Suppose the polynomial  $g(x)$  in Equation (21) has degree  $d$  in each variable of  $x$ . Then  $\tilde{\mathbf{eq}}(r, x) \cdot g(x)$  has degree  $d+1$  in each variable of  $x$ . As a consequence, when applying the sum-check protocol to  $\tilde{\mathbf{eq}}(r, x) \cdot g(x)$ , the prover's message  $s_i(X)$  in each round  $i$  is a univariate polynomial of degree  $d+1$ . This has implications for prover time: the prover must evaluate  $s_i$  at  $d+2$  points, say  $\{0, 1, \dots, d+1\}$  (in fact, the evaluation  $s_i(1)$  can be omitted and/or had “for free” as it is quickly derivable from  $s_i(0)$  and  $s_{i-1}$ . See Section 3.3 for details).

Gruen [Gru24, Section 3] shows that the sum-check protocol can be modified so that in each round  $i$  the prover only has to compute a degree- $d$  polynomial  $s'_i$ , not the degree  $d+1$  polynomial  $s_i$  (and  $s_i$  can then be derived from  $s'_i$ , in time that depends only on  $d$ ). This saves the prover the work of evaluating the relevant polynomial at one point (say, point  $d+1$ ). (Gruen describes his optimization as having the prover send  $s'_i$  instead of  $s_i$ , but this requires modifying the standard sum-check verifier so as to process  $s'_i$  rather than  $s_i$ . We prefer to leave the standard sum-check verification procedure unchanged).

The idea is roughly to define  $s'_i$  to “leave out” the contribution of  $\tilde{\mathbf{eq}}(r, x)$  to  $s_i$  when defining  $s'_i$ . This reduces the degree of  $s_i$  by one. More precisely, since  $\tilde{\mathbf{eq}}(r, x)$  factors into a product of terms where each term depends on a single variable,  $s'_i$  leaves out the contribution of variable  $i$  to  $\tilde{\mathbf{eq}}(r, x)$ . This contribution is independent of the other variables still being summed over in round  $i$ , so the prover can “add this contribution back in” (i.e., compute  $s_i$  from  $s'_i$ ) in time independent of the number of terms being summed.

Specifically, if  $(r_1, \dots, r_{i-1})$  denotes the randomness chosen by the sum-check verifier in rounds  $1, \dots, i-1$ , then recall that

$$s_i(c) = \sum_{x' \in \{0,1\}^{\ell-i}} \tilde{\mathbf{eq}}(r, r_1, \dots, r_{i-1}, c, x') \cdot g(r_1, \dots, r_{i-1}, c, x') \\ = \left( \prod_{j=1}^{i-1} (r_j r_j + (1-r_j)(1-r_j)) \right) \cdot \underbrace{(r_i c + (1-r_i)(1-c))}_{\text{call this factor } B(c)} \cdot \sum_{x' \in \{0,1\}^{\ell-i}} \underbrace{\tilde{\mathbf{eq}}(r_{i+1}, \dots, r_\ell, x') g(r_1, \dots, r_{i-1}, c, x')}_{\text{call this factor } C(c)}.$$

The modified polynomial  $s'_i(X)$  for round  $i$  is

$$s'_i(c) = A \cdot C(c).$$

Crucially, for each  $c \in \{0, \dots, d+1\}$ ,  $s_i(c) = s'_i(c) \cdot B(c)$ . Effectively, this modification has removed from the prover's message  $s_i(c)$  the degree-1 factor  $B(c)$  that the  $i$ th variable of  $x$  contributed to the term  $\tilde{\mathbf{eq}}(r, x)$ .

The prover can compute  $s'_i(c)$  for  $d+1$  points via the standard linear-time sum-check proving algorithm (Section 3.3). These  $d+1$  evaluations fully specify  $s'_i$  since  $s'_i$  has degree  $d$  rather than  $d+1$  (note that, per a standard observation, the evaluation  $s'_i(0)$  can be computed in constant time from  $s'_i(1)$  and  $s_i(0)$ ).

So once the prover has computed  $s'_i$ , in time that depends only on  $d$  it can compute  $s_i(c)$  at the  $d+2$  points  $c \in \{0, \dots, d+1\}$ , thereby fully specifying  $s_i$ .

1. $\mathcal{P}$  and  $\mathcal{V}$  have agreed upon a size- $K$  lookup table whose multilinear extension is given by  $\tilde{\mathsf{Val}}$  (which we assume to be evaluable in  $O(\log K)$  time), and  $\mathcal{P}$  has already committed to a multilinear polynomial  $\tilde{\mathsf{ra}}: \mathbb{F}^{\log K} \times \mathbb{F}^{\log T} \to \mathbb{F}$ .  $\mathcal{P}$  wishes to give the verifier query access to the virtual polynomial  $\tilde{\mathsf{rv}}: \mathbb{F}^{\log T} \to \mathbb{F}$ , defined as the unique multilinear polynomial satisfying that: for all  $j \in \{0, 1\}^{\log T}$ ,  $\tilde{\mathsf{rv}}(j) = \sum_{k \in \{0, 1\}^{\log K}} \tilde{\mathsf{ra}}(k, j) \cdot \tilde{\mathsf{Val}}(k)$ .
2. $\mathcal{V} \to \mathcal{P}$ : pick the desired evaluation point  $r_{\mathsf{cycle}} \in \mathbb{F}^{\log T}$  send it to  $\mathcal{P}$ .
3. $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to compute
   $$\tilde{\mathsf{rv}}(r_{\mathsf{cycle}}) = \sum_{k \in \{0, 1\}^{\log K}} \tilde{\mathsf{ra}}(k, r_{\mathsf{cycle}}) \cdot \tilde{\mathsf{Val}}(k).$$
4. Let  $r_{\mathsf{address}}$  denote the randomness chosen over the course of the sum-check protocol. To perform  $\mathcal{V}$ 's check in the final round of the sum-check protocol,  $\mathcal{V}$  evaluates the committed polynomial  $\tilde{\mathsf{ra}}$  respectively at the random point  $(r_{\mathsf{address}}, r_{\mathsf{cycle}})$ , and  $\mathcal{V}$  evaluates  $\tilde{\mathsf{Val}}(r_{\mathsf{address}})$  directly in  $O(\log K)$  time.

<span id="page-38-0"></span>Figure 5: The core Shout PIOP when  $d = 1$ , assuming the lookup table is MLE-structured (i.e.,  $\mathcal{V}$  can evaluate  $\tilde{\mathsf{Val}}$  at a random input in  $O(\log K)$  time).

<span id="page-38-1"></span>

### 3.7 One-hot encodings

Fix  $K$  and let  $z \in \{0, 1, \dots, K-1\} \subseteq \mathbb{F}$ . The (one-dimensional) *one-hot encoding* of  $z$  is the unit vector  $e_z \in \mathbb{F}^K$  whose  $z$ 'th entry is 1 and all other entries of which are 0.

Next, let us assume for simplicity that  $K^{1/d}$  is an integer. For  $d > 1$ , the  $d$ -dimensional one-hot encoding of  $z$  refers to the collection of  $d$  unit vectors, say  $v_1, \dots, v_d$ , each of length  $K^{1/d}$ , whose tensor product  $v_1 \otimes v_2 \cdots \otimes v_d$  equals  $e_z$ . In other words, if we index the  $K$  entries of  $e_z$  by  $k = (k_1, \dots, k_d) \in \{0, \dots, K^{1/d} - 1\}^d$ , then  $v_1, \dots, v_d$  are the unique unit vectors such that the  $k$ 'th entry of  $e_z$  equals

$$\prod_{i=1}^{d} v_i(k_i).$$

This implies that, if  $z$  itself corresponds to  $(z_1, \dots, z_d)$  via the natural bijection between  $\{0, \dots, K-1\}$  and  $\{0, \dots, K^{1/d} - 1\}^d$ , then  $v_i = e_{z_i} \in \{0, 1\}^{K^{1/d}}$  for  $i = 1, \dots, d$ .
