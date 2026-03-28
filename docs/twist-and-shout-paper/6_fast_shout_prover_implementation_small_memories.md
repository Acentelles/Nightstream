## 6 Fast Shout prover implementation (small memories)

This section explains how to implement the prover in the various invocations of the sum-check protocol in Shout. Our treatment assumes familiarity with the standard linear-time sum-check prover implementation [CTY11, Tha13] covered in the preliminaries (Section 3.3). In this section, we are generally focused upon the case that  $K = o(T)$ , and hence we do not seek to avoid additive terms in the prover time of  $O(K)$ . This is what we mean by “small” memories in the section title.

Because Shout with  $d = 1$  is a special case, we present the fast prover for  $d = 1$  in Section 6.1. before turning to the general case (Figures 7 and 8) in Sections 6.2 and 6.3.

<span id="page-48-0"></span>

### 6.1 Core Shout prover for $d = 1$

**An algorithm for small or unstructured memories.** Recall that the core Shout PIOP prover with  $d = 1$  (Figure 5) applies the sum-check protocol to prove that

<span id="page-48-3"></span>
$$\tilde{v}(r_{\text{cycle}}) = \sum_{k \in \{0,1\}^{\log K}} \tilde{a}(k, r_{\text{cycle}}) \cdot \tilde{\text{Val}}(k). \quad (42)$$

With  $T$  field multiplications, the prover can compute a vector  $E$  storing  $\tilde{e}(j, r_{\text{cycle}})$  as  $j$  ranges over  $\{0,1\}^{\log T}$  [VSBW13] (see Lemma 1). Given  $E$ , computing a vector  $F$  storing all  $\tilde{a}(k, r_{\text{cycle}})$  evaluations for all  $k \in \{0,1\}^{\log K}$  can be done with only additions and lookups into  $E$ . Specifically,  $\tilde{a}(k, r_{\text{cycle}}) = \sum_{j: \tilde{a}(k,j)=1} \tilde{e}(j, r_{\text{cycle}})$ . Given this array, the standard linear-time sum-check proving algorithm (Section 3.3) requires  $3K$  field multiplications.<sup>30</sup> Hence, the total number of field multiplications done by the core Shout PIOP prover is:  $T + 3K$ .

**Theorem 5.** The prover in the core Shout PIOP with  $d = 1$  (Figure 5) can be implemented in  $3K + T$  field multiplications.

**An algorithm for large, structured memories.** If  $K \gg T$ , we would not be happy with the additive  $2K$  factor in the prover runtime above. However, we generally do not expect Shout to be applied with  $d$  set to 1 in this case, as it would either lead to a very large commitment key (in the case of an elliptic curve commitment) or high time to compute commitments (in the case of a hashing-based commitment scheme, where 0s are not free to commit to). Still, for completeness, we outline a prover implementation that avoids this linear-in- $K$  term. This implementation is an immediate consequence of the sparse-dense sum-check protocol from [STW24, Appendix G].

Indeed, if  $T \gg K$  the vector  $F$  above is *sparse*: only (at most)  $T$  of its entries are non-zero. Suppose that  $K \le T^c$  for some constant  $c > 0$ . The sparse-dense sum-check protocol of [STW24, Appendix G] identifies conditions on  $\tilde{\text{Val}}$  that guarantee that the prover (in the sum-check protocol invoked to establish Equation (42) holds) runs in time  $O(c \cdot T)$ . [STW24, Appendix G] also showed that important lookup tables of size  $2^{64}$  arising in Jolt satisfy the necessary structural conditions for this runtime bound to hold. See Section 7.1 for further details.

<span id="page-48-1"></span>

### 6.2 Core Shout prover (general $d$ , small memories)

Recall that the core Shout PIOP for any  $d \ge 1$  (Figure 7) applies the sum-check protocol to check that

<span id="page-48-4"></span>
$$\tilde{v}(r_{\text{cycle}}) = \sum_{k=(k_1, \dots, k_d) \in \{0,1\}^{\log(K/d)^d}, j \in \{0,1\}^{\log T}} \tilde{e}(r_{\text{cycle}}, j) \left( \prod_{i=1}^{d} \tilde{a}_i(k_i, j) \right) \cdot \tilde{\text{Val}}(k). \quad (43)$$

<span id="page-48-2"></span>

<sup>30</sup>Section 3.3 states a time bound of  $2K$  field multiplications, but this does not account for the cost of computing the claimed answer, in this case  $\tilde{a}(k, r_{\text{cycle}})$ . Given the array  $F$ ,  $\tilde{a}(k, r_{\text{cycle}})$  can be computed with  $K$  additional field operations.

Before the sum-check protocol even begins, the prover can compute the following array  $E^*$  with one entry per  $j \in \{0, 1\}^{\log T}$ .

<span id="page-49-1"></span>
$$E^* \text{ stores } \tilde{\mathbf{eq}}(r_{\text{cycle}}, j) \text{ for all } j \in \{0, 1\}^{\log T}. \quad (44)$$

This array  $E^*$  is useful later in the protocol.

Turning to the sum-check invocation, we bind the variables of the register  $k \in \{0, 1\}^{\log K}$  before the variables of the cycle  $j \in \{0, 1\}^{\log T}$ .

### 6.2.1 The first $\log K$ rounds of sum-check

The prover's message in the first  $\log K$  rounds is independent of  $d$ , in the following sense: the prover messages sent in the first  $\log K$  rounds is the same if the term

<span id="page-49-0"></span>
$$\prod_{i=1}^{d} \tilde{\mathbf{ra}}_i(k_i, j) \quad (45)$$

in Expression (43) is replaced with the multilinear polynomial  $\tilde{\mathbf{ra}}(k_1, \dots, k_d, j)$  that takes the same values as Expression (45) over inputs in  $\{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ . This is because the first  $\log(K)$  rounds of the sum-check protocol bind variables only the variables in  $k = (k_1, \dots, k_d)$ , and Expression (45) has degree one in the variables of  $k$ —it only has degree more than one in the variables of  $j$ . So changing the degree of Expression (43) in  $j$  without changing its evaluations over the relevant domain does not alter the sum-check prover's message in the first  $\log K$  rounds.

Hence, for simplicity of notation, let us focus on the case the  $d = 1$  for the first  $\log K$  rounds.

Our first key observation is that for the first  $\log K$  rounds, and each register  $k \in \{0, 1\}^{\log K}$ , each cycle at which register  $k$  is read “contributes identically” to Expression (43). Accordingly, for each register  $k$ , we can “aggregate” together at the start of the protocol all cycles  $j$  at which register  $k$  is read. Details follow.

**A key fact.** The following is a key consequence of the fact that  $\mathbf{ra}(k, j)$  is a unit vector for each cycle  $j$ . Consider the set of values  $\tilde{\mathbf{ra}}(r_1, \dots, r_m, y)$  as  $y = (y_{\text{mem}}, y_{\text{cycle}})$  ranges over  $\{0, 1\}^{\log(K)-m} \times \{0, 1\}^{\log T}$ . For any round  $m \le \log K$ , for each  $y_{\text{cycle}} \in \{0, 1\}^{\log T}$ , this set of values is highly structured: there is exactly one  $y_{\text{mem}} \in \{0, 1\}^{\log(K)-m}$  for which  $\tilde{\mathbf{ra}}(r_1, \dots, r_m, y_{\text{mem}}, y_{\text{cycle}})$  is non-zero, and if register  $k \in \{0, 1\}^{\log K}$  was read in cycle  $y_{\text{cycle}}$ , then this non-zero value equals

<span id="page-49-2"></span>
$$\tilde{\mathbf{eq}}((k_1, \dots, k_m), (r_1, \dots, r_m)). \quad (46)$$

**The prover's data structures for the first  $\log K$  rounds.** The prover maintains two arrays that initially store  $K$  values and halve in size each round. Let's call these two arrays  $A$  and  $C$ .

 $A[k]$  initially stores  $\tilde{\mathbf{Val}}(k)$ . And  $C[k]$  initially stores

$$v_k := \sum_{j \in \{0, 1\}^{\log T} : \tilde{\mathbf{ra}}(k, j) = 1} \tilde{\mathbf{eq}}(r_{\text{cycle}}, j). \quad (47)$$

Initializing  $C$  costs no field multiplications since each entry of  $C$  is a sum of entries of the already-computed array  $E^*$  (Expression (44)).

At the end of round  $m$ , when the verifier sends the prover the random challenge  $r_m$ , the prover binds the  $A$  and  $C$  arrays as in Section 3.3. That is, for each  $k \in \{0, 1\}^{\log(K)-m}$ , the prover sets

$$A[k] \leftarrow (1 - r_m)A[k, 0] + r_m A[k, 1] = A[k, 0] + r_m \cdot (A[k, 1] - A[k, 0])$$

$$C[k] \leftarrow (1 - r_m)C[k, 0] + r_m C[k, 1] = C[k, 0] + r_m \cdot (C[k, 1] - C[k, 0]).$$

By Fact 3.1, this ensures that after round  $m$ ,  $A[k]$  stores  $\tilde{\mathbf{Val}}(r_1, \dots, r_m, k)$  and

<span id="page-49-3"></span>
$$C'[k] = \sum_{k'=(k', k) \in \{0, 1\}^m \times \{0, 1\}^{\log(K)-m}} v_{k'} \cdot \tilde{\mathbf{eq}}(r_1, \dots, r_m, k'). \quad (48)$$

**Leveraging the data structures.** In the middle of round  $m$ , for any  $k \in \{0, 1\}^{\log(K)-m}$ , let us use

<span id="page-50-1"></span><span id="page-50-0"></span>
$$A[c', k]$$

as shorthand for

<span id="page-50-3"></span>
$$(1 - c') \cdot A[0, k] + c' \cdot A[1, k], \quad (49)$$

and similarly with  $C$  in place of  $A$ . Then with the above data structures, the following holds. For each  $c' \in \{0, 2\}$ , the prescribed prover message  $s_m$  in round  $m$  includes  $s_m(c')$ , which equals:

$$s_m(c') = \sum_{k \in \{0, 1\}^{\log(K)-m}} \widetilde{\text{Val}}(r_1, \dots, r_{m-1}, c', k) \left( \sum_{j \in \{0, 1\}^{\log T}} \tilde{\text{eq}}(r'', j) \tilde{r}\tilde{a}(r_1, \dots, r_{m-1}, c', k, j) \right) \quad (50)$$

$$= \sum_{k \in \{0, 1\}^{\log(K)-m}} A[c', k] \cdot C'[c', k]. \quad (51)$$

This last equality exploits Fact 3.1, as well as the key fact above, that for each  $j \in \{0, 1\}^{\log T}$ ,  $\tilde{r}\tilde{a}(r_1, \dots, r_{m-1}, c', k, j)$  is non-zero for exactly one value of  $k \in \{0, 1\}^{\log(K)-m}$ , and per Equation (46), at this  $k$  its value is precisely  $\tilde{\text{eq}}(k', r_1, \dots, r_{m-1}, c')$  where  $k'$  is the first  $m$  coordinates of the register read at cycle  $j$ . By Equation (48), this means that the quantity in parenthesis in Expression (50) precisely equals  $C[c', k]$ .

Thus, we have shown that the prover in the first  $\log K$  rounds of the sum-check protocol applied to Expression (43), the prover performs at most  $4K$  multiplications (not counting the construction of  $E^*$  which we already charged for in the evaluation of  $\tilde{r}\tilde{v}(r_{\text{cycle}})$ ). Here is the accounting:

- $K$  multiplications to bind the  $A$  array.
- $K$  to bind the  $C'$  array.
- $3 \cdot K$  across all rounds  $m$  to evaluate Expression (51) given these arrays (see Footnote 30 for an explanation of why this cost is  $3K$  and not  $2K$ ).

### 6.2.2 The final $\log T$ rounds of sum-check

The degree of the univariate polynomial the prover sends in each of the last  $d$  rounds is  $d+1$ , so the prover time in the last  $d$  rounds does grow with  $d$ . Nonetheless, for simplicity let us begin by considering the case  $d=1$ . Let  $\tau = (r_1, \dots, r_{\log K}) \in \mathbb{F}^{\log K}$  denote the random challenges chosen during the first  $\log K$  rounds of Shout's sum-check protocol invocation. Per Equation (43), the final  $\log T$  rounds are intended to compute:

<span id="page-50-2"></span>
$$\widetilde{\text{Val}}(\tau) \sum_{j \in \{0, 1\}^{\log T}} \tilde{\text{eq}}(r_{\text{cycle}}, j) \cdot \tilde{r}\tilde{a}(\tau, j). \quad (52)$$

With  $K$  field multiplications, the prover can compute an array  $E$  of length  $T$  whose  $j$ 'th entry stores  $\tilde{r}\tilde{a}(\tau, j)$  (as  $j$  ranges over  $\{0, 1\}^{\log T}$ ). Indeed, per Equation (46),  $\tilde{r}\tilde{a}(\tau, j)$  simply equals  $\tilde{\text{eq}}(\tau, k)$  where  $k \in \{0, 1\}^{\log K}$  is the register read at cycle  $j$ . And it's known how to compute a size- $K$  array storing all evaluations  $\tilde{\text{eq}}(\tau, k)$  for  $k \in \{0, 1\}^{\log K}$  with  $K$  field multiplications (see Lemma 1). Each entry of  $E$  can be computed with one lookup into this size- $K$  array.

With this array  $E$  in hand, as well as the array  $E^*$  computed before round one (see Expression (44)), the standard linear-time sum-check proving algorithm (Section 3.3) implements the sum-check prover applied to compute Expression (52) with only about  $4T$  field multiplications:  $T$  for binding the array  $E$  round-over-round,  $T$  for binding the array  $E^*$  round-over-round, and  $2T$  more for evaluating  $s_i(0)$  and  $s_i(2)$  in each round  $i = \log(K) + 1, \dots, \log(K) + \log(T)$ . In fact, now-standard optimizations [DT24, Gru24] reduce this to  $2T$ , as the optimization of [Gru24, Section 3] covered in Section 3.6.1 eliminates the need to evaluate  $s_i(2)$  and [DT24] eliminates the cost of binding the array  $E^*$ . We even discuss below a final optimization that effectively eliminates the cost of binding  $E$  when  $K = o(T)$ . That brings the total number of prover multiplications for the final  $\log T$  rounds down to only about  $T$  when  $d=1$  and  $K = o(T)$ .

<span id="page-51-2"></span>**An optimization leveraging small memory size.** When  $K = o(T)$ , the following additional optimization applies. Since  $\tilde{r}(\tau, j)$  takes on at most  $K$  distinct values across all  $j \in \{0, 1\}^{\log T}$ ,  $\tilde{r}(\tau, r_{\log(K)+1}, \dots, r_m, j)$  takes on at most  $K^{2^m}$  distinct values as  $j$  ranges over  $\{0, 1\}^{\log(T)-m}$ . In fact, each of these  $K^{2^m}$  values is a size- $2^m$  sum of values from a set  $S$  of size  $K \cdot 2^m$  quantities that can all be computed in  $O(K 2^m)$  time. Namely,  $S$  consists of each of the  $K$  distinct values in  $\tilde{r}(\tau, j)$ , times a value of the form  $\tilde{e}q(r_{\log(K)+1}, \dots, r_m, j')$  as  $j'$  ranges over  $\{0, 1\}^m$ . This means that as long as  $K \cdot 2^m \ll T$ , we can speed up the task of binding  $\tilde{r}$  for each of the first  $m$  rounds. Rather than costing  $T/2^j$  field multiplications at the end of round  $j$ , it can instead cost  $O(K \cdot 2^m)$  field multiplications.

**General  $d$ .** For general  $d > 1$ , the prover in each of the final  $\log T$  rounds sends a univariate polynomial of degree  $d+1$ . There are also  $d$  arrays tracking evaluations of  $\tilde{r}_1, \dots, \tilde{r}_d$ , rather than the single array  $E$  considered above when we focused on the case that  $d = 1$ . As long as  $K^{1/d} = o(T)$ , the optimization above that nearly eliminates the cost of binding  $E$  applies to binding each of these  $d$  arrays.

Thus, when  $K = o(T)$ , the prover cost of the final  $\log(T)$  rounds for general  $d$  is, up to low-order terms,  $d^2 T$  field multiplications. This simply amounts to applying the standard linear-time sum-check prover algorithm from Section 3.3, combined with the various optimizations described above.

To summarize the costs:

- $T$  field multiplications to compute the array  $E^*$ .
- $5K$  additional multiplications to implement the first  $\log K$  rounds.
- $dT$  multiplications to bind the arrays of  $\tilde{r}_1, \dots, \tilde{r}_d$  evaluations over the final  $\log T$  rounds. This cost falls to  $o(T)$  if  $K^{1/d} = o(T)$ .
- $d^2 T$  multiplications given the above arrays to evaluate the prover's messages over the final  $\log T$  rounds.

We have established the following theorem.

**Theorem 6.** For  $d > 1$ , the core **Shout PIOP prover** (Figure 7) can be implemented with  $(d^2 + d + 1)T + 5K + o(T)$  field multiplications. If  $K^{1/d} = o(T)$ , this falls to  $(d^2 + 1)T + 5K + o(T)$ .

<span id="page-51-0"></span>

### 6.3 Booleanity-checking and one-hot-encoding-checking

Here is how to efficiently implement the prover in the PIOP of Figure 8 when an additive  $O(K^{1/d} \log(K))$  term in the prover cost is acceptable. When  $K^{1/d} \log(K)$  is bigger than  $T$ , one should instead use our generalization of the sparse-dense sum-check protocol given later, in Section 7 (that protocol has a much better dependence on  $K$ , but a worse dependence on  $T$ , by a significant constant factor).

Let us start with the Booleanity-checking sum-check invocation (Line 3 of Figure 8), which for each  $i = 1, \dots, d$  applies the sum-check protocol to confirm that

$$0 = \sum_{k \in \{0, 1\}^{\log(K)/d}, j \in \{0, 1\}^{\log T}} \tilde{e}q(r, k) \tilde{e}q(r', j) \left( \tilde{r}_i(k, j)^2 - \tilde{r}_i(k, j) \right).$$

We bind the  $\log(K)/d$  variables of  $k$  first, followed by the  $\log T$  variables of  $j$ .

**First  $\log(K)/d$  rounds.** Before the first round, the prover builds arrays  $B$  and  $D$  of size  $K^{1/d}$  and  $T$  respectively, storing the following values:

$$B \text{ stores } \tilde{e}q(r, k) \text{ for all } k \in \{0, 1\}^{\log(K)/d} \quad (53)$$

and

<span id="page-51-1"></span>
$$D \text{ stores } \tilde{e}q(r', j) \text{ for all } j \in \{0, 1\}^{\log T}. \quad (54)$$

By Lemma 1, computing  $B$  requires  $K^{1/d}$  field multiplications, while computing  $D$  requires  $T$  field multiplications.

At the end of round  $m$ , let  $r = (r_1, \dots, r_m)$  denote the random values chosen by the sum-check prover in the first  $m$  rounds. Via standard binding techniques (Section 3.3), the prover can ensure that at the end of round  $m$ , the array  $B$  has shrunk to length  $K^{1/d}/2^m$ , and for every  $k' \in \{0, 1\}^{\log(K)/d - m}$ ,  $B[k']$  stores  $\tilde{\mathbf{e}}\mathbf{q}(r, r_1, \dots, r_m, k')$ .

Recall from Equation (46) that for at the end of any round  $m \le \log(K)/d$  when  $r_m$  is selected, for each  $y_{\text{cycle}} \in \{0, 1\}^{\log T}$ , there is exactly one  $y'_{\text{mem}} \in \{0, 1\}^{\log(K)/d - m}$  for which  $\tilde{\mathbf{r}}\mathbf{a}_i(r_1, \dots, r_m, y'_{\text{mem}}, y_{\text{cycle}})$  is non-zero, and if register  $k \in \{0, 1\}^{\log K}$  was read in cycle  $y_{\text{cycle}}$ , then this non-zero value equals

$$\tilde{\mathbf{e}}\mathbf{q}((k_1, \dots, k_m), (r_1, \dots, r_m)).$$

The prover can maintain an array  $F$  that at the end of round  $m$  has size  $2^m$  and stores all  $2^m$  such values, i.e.,

<span id="page-52-1"></span>
$$F \text{ stores } \tilde{\mathbf{e}}\mathbf{q}((k_1, \dots, k_m), (r_1, \dots, r_m)) \text{ for all } (k_1, \dots, k_m) \in \{0, 1\}^m \quad (55)$$

Via standard techniques (see Lemma 1), maintaining  $F$  costs  $K^{1/d}$  field multiplications across the first  $\log(K)/d$  rounds.

Next, consider a specific  $i$  from the set  $\{1, \dots, d\}$ . The prover can, with only additions, before the protocol begins, compute a size- $K^{1/d}$  array  $G_i$  that for  $k \in \{0, 1\}^{\log(K)/d}$  stores

$$G_i[k] = \sum_{j \in \{0, 1\}^{\log T} : \tilde{\mathbf{r}}\mathbf{a}_i(k, j) = 1} D[j].$$

In the middle of round  $m$ , as per Expression (49), let us use  $B[c', k']$  as shorthand for

$$(1 - c') \cdot B[0, k'] + c' \cdot B[1, k'].$$

and  $F[k_1, \dots, k_{m-1}, c']$  as shorthand for

$$F[k_1, \dots, k_{m-1}] \cdot \tilde{\mathbf{e}}\mathbf{q}(k_m, c'),$$

and where in the middle of round  $m = 1$ , the factor  $F[k_1, \dots, k_{m-1}]$  is simply 1.

The prover's message  $s_m$  in round  $m \le \log(K)/d$  of sum-check for the  $i$ 'th Booleanity check satisfies that  $s_m(c)$  equals:

$$\sum_{k=(k_1, \dots, k_m, k') \in \{0, 1\}^m \times \{0, 1\}^{\log(K)/d - m}} G_i[k] \cdot B[c, k'] \cdot (F[k_1, \dots, k_{m-1}, c]^2 - F[k_1, \dots, k_{m-1}, c]). \quad (56)$$

In round  $m$ , the prover has to evaluate  $s_m(c)$  for all relevant values of  $c$ . Using Gruen's technique (Section 3.6.1), there are 2 relevant values of  $c$ , say  $c \in \{0, 2\}$ . Given the arrays  $G_i$ ,  $B$ , and  $F$ , both  $s_m(0)$  and  $s_m(2)$  can be computed via Expression (56) with the following total number of multiplications:

<span id="page-52-0"></span>
$$2^m + 2K^{1/d}.$$

Here, the  $2^m$  multiplications are needed to compute  $F[k_1, \dots, k_{m-1}, c]^2$  from  $F[k_1, \dots, k_{m-1}, c]$  for all  $2^m$  relevant values of  $(k_1, \dots, k_{m-1}, c)$ .

The above description refers to implementing the Booleanity-checking sum-check for a single  $i$ . That sum-check in fact must be applied  $d$  times (once for each  $i = 1, \dots, d$ ). However, a full  $d$ -fold cost increase does not quite occur, since several arrays can be reused between for all  $i = 1, \dots, d$ . This holds in particular for arrays  $B$ ,  $D$ , and  $F$ .

In summary, across the first  $\log(K)/d$  rounds of the sum-check protocol, the prover's costs are as follows.

- $K^{1/d}$  field multiplications to build the array  $B$ .

- $T$  multiplications to build  $D$ .
- $K^{1/d}$  multiplications to bind the array  $B$  across all rounds.
- $K^{1/d}$  multiplications to build up the array  $F$  across all  $\log(K)/d$  rounds.
- $K^{1/d}$  multiplications to  $F[k_1, \dots, k_{m-1}, c]^2$  for all relevant values of  $(k_1, \dots, k_{m-1}, c)$  across all rounds  $m$ .
- For each  $i = 1, \dots, d$ ,  $2K^{1/d} \log(K^{1/d})$  field multiplications to evaluate  $s_1(c), \dots, s_m(c)$  across all  $\log(K)/d$  rounds for  $c \in \{0, 2\}$  given the above arrays. Across all  $i = 1, \dots, d$ , this is  $2K^{1/d} \cdot \log(K)$  multiplications total.

Summing the above yields  $T + (2 \log(K) + 4) \cdot K^{1/d}$  field multiplications in total for the first  $\log(K)/d$  rounds for all  $d$  Booleanity-checking sum-check invocations across all  $i = 1, \dots, d$ .

**Last  $\log T$  rounds.** The last  $\log T$  rounds of sum-check are used to compute

$$\begin{aligned} & \tilde{\mathsf{eq}}(r, r) \cdot \sum_{j \in \{0, 1\}^{\log T}} \tilde{\mathsf{eq}}(r'_{\mathsf{cycle}}, j) (\tilde{\mathsf{ra}}_i(r, j)^2 - \tilde{\mathsf{ra}}_i(r, j)) \\ & = \tilde{\mathsf{eq}}(r, r) \cdot \sum_{j \in \{0, 1\}^{\log T}} D[j] \cdot (\tilde{\mathsf{ra}}_i(r, j)^2 - \tilde{\mathsf{ra}}_i(r, j)) \end{aligned} \quad (57)$$

Given the contents of the size- $K^{1/d}$  array  $F$  (Expression (55)) at the end of round  $\log(K)/d$ , the prover can, with no further multiplications, construct for each  $i = 1, \dots, d$ , an array  $H_i$  of length  $T$  such that

<span id="page-53-0"></span>
$$H_i[j] = \tilde{\mathsf{ra}}_i(r, j).$$

Indeed by Equation (46), if  $k$  is the register read at cycle  $j$  then

$$\tilde{\mathsf{ra}}_i(r, j) = \tilde{\mathsf{eq}}(k, r),$$

and at the end of round  $\log(K)/d$  this value is simply equal to  $F[k]$ . Then Expression (57) equals:

$$\tilde{\mathsf{eq}}(r, r) \cdot \sum_{j \in \{0, 1\}^{\log T}} D[j] \cdot (H_i[j] \cdot H_i[j] - H_i[j]).$$

Given the arrays  $H_i$  and  $D$ , the standard linear-time sum-check proving algorithm (Section 3.3) implements the final  $\log(T)$  rounds of the sum-check protocol (i.e., applies the sum-check protocol to compute Expression (57)) with the following costs, for each  $i = 1, \dots, d$ .

- $T$  field multiplications to bind the array  $D$  across all  $\log T$  rounds.
- $dT$  field multiplications to bind the arrays  $H_1, \dots, H_d$  across all  $\log T$  rounds.
- $2 \cdot 2 \cdot d \cdot T$  field multiplications suffice to complete the prover's work given the above arrays.

Hence, without further optimization, the total cost for the prover of the last  $\log T$  rounds is  $(5d + 1)T$  field multiplications. Added to the cost of the first  $\log K$  rounds, this is  $(5d + 2)T + O(K^{1/d} \log(K))$  field multiplications. However, further significant further optimizations are possible.

#### Further optimizations.

- So long as  $\tilde{\mathsf{ra}}_1, \dots, \tilde{\mathsf{ra}}_d$  are committed before the core **Shout** PIOP (Figure 7) commences, one can set  $r'$  in Figure 8 to  $r_{\mathsf{cycle}}$ , i.e., share verifier-chosen randomness between the core **Shout** PIOP and the one-hot-encoding-checking PIOP. This makes the array  $D$  (Expression (54)) built by the Booleanity-checking prover the same as the array  $E^*$  (Expression (44)) built by the core **Shout** PIOP prover. This eliminates  $T$  field multiplications from the cost of the Booleanity-checking prover (and thereby renders the number of prover field multiplications for the first  $\log(K/d)$  rounds independent of  $T$ ).

- The techniques of Dao and Thaler [DT24] directly apply to reduce the cost of binding the array  $D = E^*$  to a low-order number of field multiplications (i.e.,  $O(\sqrt{T})$  of them). Ignoring low-order terms, this eliminates another  $T$  field multiplications from the prover's cost.
- Exactly as in the final  $\log(T)$  rounds of the core Shout PIOP (Section 6.2.2), in round  $\log(K)/d + m$  of sum-check, the number of distinct values in each array  $H_1, \dots, H_d$  is at most  $K^{2^m}$ , and each of these values is a sum of at most  $2^m$  elements of a set of size  $2^m \cdot K$  (and all quantities in this set can be computed in time  $O(K 2^m)$ ). This can be exploited to save most of the  $T$  multiplications devoted to binding each of the arrays  $H_1, \dots, H_d$ . It also saves the work of squaring  $H_1[c, x'], \dots, H_d[c, x']$  for each  $x' \in \{0, 1\}^{\log(T)-t}$  in each sum-check round, for each evaluation point  $c$ . This is a total of  $2dT$  multiplications saved in total.

This brings to the total number of prover multiplications for Booleanity-checking down from  $(5d + 2)T + O(K^{1/d} \log K)$  to essentially  $3dT + O(K^{1/d} \log K)$ .

 **$\tilde{\mathbf{r}}\mathbf{a}\mathbf{f}$ -evaluation sum-check when  $d = 1$  (Line 6 of Figure 6).** This is a  $\log(K)$ -round sum-check protocol. The prover sends a degree-2 univariate polynomial in each round. It's easy to make the prover run in time  $O(K)$  once given an  $E$  array of length  $K$ , that stores at cell  $k' \in \{0, 1\}^{\log(K)}$  the value  $\tilde{\mathbf{r}}\mathbf{a}(k', r'_{\text{cycle}})$ . Observe that

<span id="page-54-0"></span>
$$\tilde{\mathbf{r}}\mathbf{a}(k', r'_{\text{cycle}}) = \sum_{j \in \{0, 1\}^{\log T} : \tilde{\mathbf{r}}\mathbf{a}(k', j) = 1} \tilde{\mathbf{e}}\mathbf{q}(j, r'_{\text{cycle}}). \quad (58)$$

Hence, if given an array  $D'$  of size  $T$  storing all values of them form  $\tilde{\mathbf{e}}\mathbf{q}(j, r'_{\text{cycle}})$  as  $j$  ranges over  $\{0, 1\}^{\log T}$ , the array  $E$  can be computed with no additional multiplications.  $D'$  can be computed with  $T$  field multiplications.

However, if  $K = o(T)$ , this procedure can be optimized further to avoid even the  $T$  multiplications needed to build  $D'$ , using techniques similar to those in [DT24] that exploit multiplicative structure in the definition of  $\tilde{\mathbf{e}}\mathbf{q}$  (Equation (15)). This is done by avoiding building the “full” size- $T$  array  $D'$ , whose sole purpose is to help initialize the array  $E$ . Instead, the prover builds a smaller array  $D''$  of size  $T/2^\ell$  whose definition is identical to  $D'$  but “leaves out” the last  $\ell$  coordinates of  $j$  and  $r'_{\text{cycle}}$ . Specifically, for each  $j' \in \{0, 1\}^{\log(T)-\ell}$ , letting  $r = r'_{\text{cycle}}$ ,

$$D''[j'] \leftarrow \prod_{m=1}^{\log(T)-\ell} \tilde{\mathbf{e}}\mathbf{q}(r_m, j_m).$$

The prover also builds an array  $D'''$  of size  $2^\ell$  the “incorporates” the last  $\ell$  coordinates that were left out of the definition of  $D''$ . That is, for all  $j'' \in \{0, 1\}^\ell$ ,

$$D'''[j''] \leftarrow \prod_{m=1}^{i} \tilde{\mathbf{e}}\mathbf{q}(r_{\log(T)-m+\ell}, j'_m).$$

Then, for each register address  $k' \in \{0, 1\}^{K/d}$ , the prover computes  $2^\ell$  quantities, one per  $j'' \in \{0, 1\}^\ell$ , namely:

$$v_{k', j''} := \sum_{j=(j', j'') \in \{0, 1\}^{\log(T)-\ell} \times \{0, 1\}^\ell : \tilde{\mathbf{r}}\mathbf{a}(k', j) = 1} D''[j'].$$

Then recalling from Equation (58) that

$$D'[k'] = \sum_{j \in \{0, 1\}^{\log T} : \tilde{\mathbf{r}}\mathbf{a}(k', j) = 1} \tilde{\mathbf{e}}\mathbf{q}(r'_{\text{cycle}}, j),$$

it follows that

$$D'[k'] = \sum_{j'' \in \{0, 1\}^\ell} D'''[j''] \cdot v_{k', j''}.$$

The cost of this protocol for building  $E_i$  is  $T/2^\ell + 2^{\ell+1}$  field multiplications. Minimizing this quantity, the cost to compute the array  $E$  is  $O(\sqrt{TK}) = o(T)$  multiplications.

**Hamming-weight-one check for general  $d$  (Line 4 of Figure 8).** This sum-check (for general  $d$ ) is similar to the  $\tilde{\text{raf}}$ -evaluation sum-check for  $d = 1$ , but even simpler, as the prover only sends a degree-1 polynomial in each round. Given the arrays  $E_i$  computed for the  $\tilde{\text{raf}}$ -evaluation sum-check, the Hamming-weight-one sum-check prover can be implemented with  $O(dK^{1/d})$  field multiplications if  $dK^{1/d} = o(T)$ .

<span id="page-55-1"></span> **$\tilde{\text{raf}}$ -evaluation sum-check for  $d > 1$  (Line 5 of Figure 8).** Recall that here the sum-check protocol is applied to compute:

$$\sum_{k=(k_1,\dots,k_d) \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\text{eq}}(r'_{\text{cycle}}, j) \left( \sum_{i=1}^{d} \sum_{\ell=0}^{\log(K)/d-1} 2^{i \cdot \log(K)/d + \ell} \cdot k_{i,\ell} \right) \cdot \prod_{i=1}^{d} \tilde{r}_i(k_i, j).$$

This is similar to the read-checking sum-check in Shout, which was applied to compute:

$$\sum_{k=(k_1,\dots,k_d) \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\text{eq}}(r'_{\text{cycle}}, j) \left( \prod_{i=1}^{d} \tilde{r}_i(k_i, j) \right) \cdot \tilde{\text{Val}}(k).$$

The only difference is that the  $\tilde{\text{raf}}$ -evaluation sum-check replaces  $\tilde{\text{Val}}(k)$  with

$$\sum_{i=1}^{d} \sum_{\ell=0}^{\log(K)/d-1} 2^{i \cdot \log(K)/d + \ell} \cdot k_{i,\ell},$$

which is the MLE of the function that maps  $k$  to  $\text{int}(k)$ .

In applications, one can set the random value  $r_{\text{cycle}}$  chosen by the verifier before the read-checking PIOP to equal  $r'_{\text{cycle}}$ . In this case, the prover in the  $\tilde{\text{raf}}$ -evaluation sum-check can be implemented with only  $K$  field multiplications of additional work, by batching Shout's core read-checking sum-check instance with the  $\tilde{\text{raf}}$ -evaluation sum-check per Section 4.2.1. Effectively, at the start of both sum-checks, the prover simply replaces  $\tilde{\text{Val}}(k)$  with  $\tilde{\text{Val}}(k) + z \cdot \tilde{\text{int}}(k)$ , where  $z$  is randomness used in the standard batching technique of Section 4.2.1.

## 6.4 Cost summary for the combined Shout prover

Suppose  $K = o(T)$ . In this case, recall Section 6.2 gave an upper bound for the core Shout PIOP prover (Figure 5) of roughly the following number of field multiplications:

$$(d^2 + 2)T.$$

And Section 6.3 gave an upper bound for the one-hot-encoding-checking PIOP prover (Figure 8) of  $O(K^{1/d} \log K) + 3dT$  when  $K^{1/d} \log K = o(T)$ . Summing the two, when  $K = o(T)$  and  $K^{1/d} \log K = o(T)$ , the total prover work is at most

$$(d^2 + 3d + 2) \cdot T.$$

<span id="page-55-0"></span>
