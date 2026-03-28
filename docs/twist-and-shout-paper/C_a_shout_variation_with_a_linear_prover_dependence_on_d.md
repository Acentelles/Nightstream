## C A Shout variation with a linear prover dependence on $d$

Recall from Equation (30) that Shout simply applies the sum-check protocol to confirm that:

$$\tilde{\mathbf{v}}(r_{\text{cycle}}) = \sum_{k=(k_1, \dots, k_d) \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}(r_{\text{cycle}}, j) \left( \prod_{i=1}^{d} \tilde{\mathbf{r}}_i(k_i, j) \right) \cdot \tilde{\mathbf{v}}(k).$$

For very large values of  $d$ , a nuisance is that the final  $\log T$  rounds of this protocol cause the prover to incur roughly  $d^2 T$  field multiplications. Here, we describe an alternative application of the sum-check protocol that avoids quadratic dependence on  $d$  (but has a worse leading constant, and hence is only preferable when  $d$  is very large).

Let  $j_0, j_1, \dots, j_d$  each consist of  $\log T$  variables. Let  $\tilde{\mathbf{e}}(j_0, j_1, \dots, j_d)$  denote the multilinear extension of the function that evaluations to 1 if all  $d+1$  vectors  $j_0, \dots, j_d$  are equal, and zero otherwise. Then

<span id="page-89-2"></span>
$$\tilde{\mathbf{e}}(j_0, j_1, \dots, j_d) = \prod_{i=1}^{\log T} \left( \left( \prod_{k=0}^{d} (1 - j_{k,i}) \right) + \left( \prod_{k=1}^{d} j_{k,i} \right) \right). \quad (94)$$

Now, in our modified version of Shout, replace Equation (30) with:

<span id="page-89-0"></span>
$$\tilde{\mathbf{v}}(r_{\text{cycle}}) = \sum_{k=(k_1, \dots, k_d) \in \{0,1\}^{\log(K)/d}, j_1, \dots, j_d \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}(r_{\text{cycle}}, j_1, j_2, \dots, j_d) \left( \prod_{i=1}^{d} \tilde{\mathbf{r}}_i(k_i, j_i) \right) \cdot \tilde{\mathbf{v}}(k). \quad (95)$$

<span id="page-89-1"></span>Note that this invocation of the sum-check protocol has  $\log(K) + d \log T$  rounds rather than  $\log(K) + \log(T)$  rounds in the standard variant of Shout (i.e., applying sum-check to check Equation (30)). However, the total proof size remains  $O(\log(K) + d \log(T))$  field elements, as each of the final  $d \log T$  rounds in the new variant has the prover send a degree-2 polynomial (whereas in the standard variant the prover sent a degree- $d$  polynomial in each of the final  $\log T$  rounds).

**Theorem 7.** Shout (Figure (7)) with Equation (30) replaced by Equation (95) is perfectly complete and has soundness error  $O((\log(K) + d\log(T))/|\mathbb{F}|)$ .

*Proof.* The proof is identical to Theorem 3, except that we must establish that Equation (95) holds. To see this, observe that the right hand side of Equation (95) is a multilinear polynomial in  $r_{\text{cycle}}$ . So it suffices to establish that the right hand side and left hand side agree at all inputs  $r_{\text{cycle}} \in \{0, 1\}^{\log T}$ . Observe that for any term of the sum on the right hand side, if  $j_1, \dots, j_d \in \{0, 1\}^{\log T}$ , then  $\tilde{\text{eq}}(r_{\text{cycle}}, j_1, j_2, \dots, j_d) = 0$  unless

<span id="page-90-0"></span>
$$j_1 = j_2 = \dots = j_d = r_{\text{cycle}}, \quad (96)$$

and if this equality does hold then  $\tilde{\text{eq}}(r_{\text{cycle}}, j_1, j_2, \dots, j_d) = 1$ .

If Equation (96) does hold, then  $\left(\prod_{i=1}^d \tilde{r}_i(k_i, j_i)\right) = 1$  if the register with binary representation  $k = (k_1, \dots, k_d)$  is read at cycle  $r_{\text{cycle}}$ , and  $\left(\prod_{i=1}^d \tilde{r}_i(k_i, j_i)\right) = 0$  otherwise. Hence, the right hand side equals  $\tilde{\text{Val}}(k)$  where  $k$  is the register read at cycle  $r_{\text{cycle}}$ . The result follows.  $\square$ 

## C.1 Fast prover implementation

**First  $\log K$  rounds.** The first  $\log K$  rounds of this sum-check invocation proceed identically to the standard variant of Shout (in these rounds, the prover message is no different between the two variants). The reader may be initially surprised by this because Expression (95) has  $K \cdot T^d$  terms while Expression (30) only has  $K \cdot T$  terms. However, per the proof of Theorem 7, the factor  $\tilde{\text{eq}}(r_{\text{cycle}}, j_1, j_2, \dots, j_d)$  evaluates to 0 over  $(\{0, 1\}^{\log T})^d$  unless  $j_1 = j_2 = \dots = j_d$ . This means that in the first  $\log K$  rounds (where only variables of  $k$  are being bound, not variables of  $j_1, \dots, j_d$ ),  $j_1, \dots, j_d$  effectively act as a single entity  $j \in \{0, 1\}^{\log T}$ , and this leads to the same prover messages as in the original Shout protocol for these rounds.

**Final  $d \log T$  rounds.** Let  $r = (r_1, \dots, r_d) \in (\mathbb{F}^{\log(K)/d})^d$  denote the randomness chosen by the verifier across the first  $\log K$  rounds of sum-check. Then the final  $d \log T$  rounds compute the following sum:

<span id="page-90-1"></span>
$$\tilde{\text{Val}}(r) \cdot \sum_{j_1, \dots, j_d \in \{0, 1\}^{\log T}} \tilde{\text{eq}}(r_{\text{cycle}}, j_1, j_2, \dots, j_d) \left(\prod_{i=1}^d \tilde{r}_i(r_i, j_i)\right). \quad (97)$$

We bind the first variable of  $j_1, j_2, \dots, j_d$  in sequence, followed by the second variable of each, and so on. Let us call the first  $d$  rounds “Stage 1” (i.e., when we bind the first variable of each of  $j_1, j_2, \dots, j_d$ ), the next  $d$  rounds Stage 2, and so forth.

**The key insight for a fast prover.** While there are  $T^d$  terms in Expression (97), round-over-round almost all of them are zero. Specifically,  $\tilde{\text{eq}}(r_{\text{cycle}}, j_1, j_2, \dots, j_d)$  is a product of  $\log(T)$  terms, one per variable in each  $j_i$ —intuitively, it tests equality of  $j_1, \dots, j_d$  “bitwise”. Since  $\tilde{\text{eq}}$  checks equality of each bit independently, it turns out that in each round of the protocol, the prover need only consider terms that agree in all but their first bit. This keeps the total prover time in each round of Stage  $S$  to  $T/2^S$ . Since there are  $d$  rounds in each stage, this is  $O(\sum_{S=1}^{\log T} dT/2^S) = O(dT)$  time in total.

### C.1.1 Detailed prover algorithm description for $d = 2$

To simplify notation, we begin with a description of the prover algorithm in the case  $d = 2$ . Further, let  $r' = r_{\text{cycle}}$ .

Consider the first round within Stage  $i$ . This is round  $t = 2(i-1) + 1$  within the final  $d \log T$  rounds of the sum-check applied to compute Expression (95), and round  $t' = \log(K) + t$  within the entire modified-Shout protocol.

Let  $w_1 = (w_{1,1}, \dots, w_{1,i-1}) \in \mathbb{F}^{i-1}$  denote the vector of random values chosen for the first  $i-1$  coordinates of  $j_1$  across the already-completed  $i-1$  stages, and similarly let  $w_2 = (w_{2,1}, \dots, w_{2,i-1})$ .

**Simplifying the prover's message definition.** The prover's prescribed message  $s_{t'}$  in round  $t'$  of our modified version of Shout satisfies:

$$s_t(c) = \widetilde{\text{Val}}(r) \cdot \sum_{j_1' \in \{0,1\}^{\log(T)-i}, j_2' \in \{0,1\}^{\log(T)-i+1}} \tilde{\mathbf{e}}(r', (w_1, c, j_1'), (w_2, j_2')) \cdot \tilde{\mathbf{r}}\mathbf{a}_1(r, w_1, c, j_1') \cdot \tilde{\mathbf{r}}\mathbf{a}_2(r, w_2, j_2').$$

Clearly,  $\tilde{\mathbf{e}}(r', (w_1, c, j_1'), (w_2, j_2')) = 0$  unless  $j_{2,>1}' = j_1'$ . So this sum simplifies to

<span id="page-91-0"></span>
$$\widetilde{\text{Val}}(r) \cdot \sum_{j_1' \in \{0,1\}^{\log(T)-i}, b \in \{0,1\}} \tilde{\mathbf{e}}(r', (w_1, c, j_1'), (w_2, b, j_1')) \cdot \tilde{\mathbf{r}}\mathbf{a}_1(r, w_1, c, j_1') \cdot \tilde{\mathbf{r}}\mathbf{a}_2(r, w_2, b, j_1'). \quad (98)$$

For any vector  $x \in \mathbb{F}^{\log T}$ , let  $x_{>i}$  denote the last  $\log(T) - i$  coordinates of  $x$ . By Equation (94),

$$\tilde{\mathbf{e}}(r', (w_1, c, j_1'), (w_2, b, j_1')) = \left( \prod_{\ell=1}^{i-1} (r_\ell' w_{1,\ell} w_{2,\ell} + (1 - r_\ell')(1 - w_{1,\ell})(1 - w_{2,\ell})) \right) \cdot \tilde{\mathbf{e}}(r_{>i}', c, b) \cdot \tilde{\mathbf{e}}(r_{>i}', w_{1,>i}, w_{2,>i}).$$

Hence, letting

<span id="page-91-2"></span>
$$C = \widetilde{\text{Val}}(r) \cdot \left( \prod_{\ell=1}^{i-1} (r_\ell' w_{1,\ell} w_{2,\ell} + (1 - r_\ell')(1 - w_{1,\ell})(1 - w_{2,\ell})) \right), \quad (99)$$

Expression (98) equals:

$$C \cdot \sum_{j_1' \in \{0,1\}^{\log(T)-i}, b \in \{0,1\}} \tilde{\mathbf{e}}(r_{>i}', c, b) \cdot \tilde{\mathbf{e}}(r_{>i}', j_1', j_1') \cdot \tilde{\mathbf{r}}\mathbf{a}_1(r, w_1, c, j_1') \cdot \tilde{\mathbf{r}}\mathbf{a}_2(r, w_2, b, j_1'). \quad (100)$$

Furthermore, note that for  $j_1' \in \{0,1\}^{\log(T)-i}$ ,

<span id="page-91-3"></span><span id="page-91-1"></span>
$$\tilde{\mathbf{e}}(r_{>i}', j_1', j_1') = \tilde{\mathbf{e}}(r_{>i}', j_1', j_1'),$$

where the polynomial  $\tilde{\mathbf{e}}$  on the right hand side refers to Equation (15). Hence, Expression (100) equals:

$$C \cdot \sum_{j_1' \in \{0,1\}^{\log(T)-i}, b \in \{0,1\}} \tilde{\mathbf{e}}(r_{>i}', c, b) \cdot \tilde{\mathbf{e}}(r_{>i}', j_1') \cdot \tilde{\mathbf{r}}\mathbf{a}_1(r, w_1, c, j_1') \cdot \tilde{\mathbf{r}}\mathbf{a}_2(r, w_2, b, j_1'). \quad (101)$$

Similarly, turning our attention to the prover's message in round  $t+1$ ,

<span id="page-91-4"></span>
$$s_{t+1}(c) = C \cdot \tilde{\mathbf{e}}(r_{>i}', w_{1,i}, c) \cdot \sum_{j_2' \in \{0,1\}^{\log(T)-i}} \tilde{\mathbf{e}}(r_{>i}', j_2') \cdot \tilde{\mathbf{r}}\mathbf{a}_1(r, w_1, r_{1,i}, j_2') \cdot \tilde{\mathbf{r}}\mathbf{a}_2(r, w_2, c, j_2'). \quad (102)$$

**Prover algorithm and cost accounting for  $d = 2$ .** Before the final  $d \log T$  rounds of Shout's read-checking sum-check protocol begin, the prover computes and stores  $\log(T) - 1$  arrays  $E_{\log(T)-1}, \dots, E_1$ , where  $E_i$  contains all evaluations  $\tilde{\mathbf{e}}(r_{>i}, j_{>i})$  as  $j_{>i}$  ranges over  $\{0,1\}^{\log(T)-i}$ . Also, at the start of these final  $\log T$  rounds, the prover will have already computed two arrays, say  $A_1$  and  $A_2$ , that store all evaluations of the form  $\tilde{\mathbf{r}}\mathbf{a}_1(r', j)$  and  $\tilde{\mathbf{r}}\mathbf{a}_2(r', j)$  as  $j$  ranges over  $\{0,1\}^{\log T}$ . As per the standard linear-time sum-check prover algorithm (Section 3.3), the prover will bind  $A_1$  and  $A_2$  (see Equation (20)) as appropriate round-over-round. Per Section 6.2.2, if  $K^{1/d} = o(T)$ , the cost of binding these arrays round-over-round is a low-order cost, so we ignore it in our accounting below.

The prover can maintain the value  $C$  from Equation (99) round-over-round with only a constant number of field multiplications per round.

During the first round in Stage  $i$ , with prover message given by Expression (101). Note that for  $c = 0$ ,  $\tilde{\mathbf{e}}(r', c, b) = 0$  if  $b = 1$ , so for  $c = 0$   $b = 1$  need not be considered at all by the prover. In addition,  $\tilde{\mathbf{e}}(r'_{>i}, j'_1)$  can be obtained with a single lookup into  $E_i$ . The prover can compute Expression (101) for  $c = 0$  with  $2T/2^i + O(1)$  field multiplications. Expression (101) for  $c = 2$  can be computed with  $4T/2^i + O(1)$  multiplications (twice as many as for  $c = 0$  because both  $b = 0$  and  $b = 1$  must be considered when  $c = 2$ ).

The prover's message for second round of Stage  $i$  (Expression (102)) requires at most  $4T/2^i$  field multiplications, with  $2T/2^i$  required for  $c = 0$  and the same number required for  $c = 2$ .

Hence, each stage  $i = 1, \dots, \log(T)$  requires  $10T/2^i$  field multiplications for the prover. Summing across all  $i$ , this is at most  $10T$  multiplications. Accounting also for the  $T/2$  multiplications to compute the arrays  $E_{\log(T)-1}, \dots, E_1$ , in total across all stages  $i$  this is  $10.5 \cdot T$  field multiplications.

**An optimization when  $K^{1/d}$  is  $o(\sqrt{T})$ .** When  $K^{1/d} = o(\sqrt{T})$ , a significant optimization is possible, similar to the one described in Section 6.2.2 that renders binding the arrays  $A_1$  and  $A_2$  a low-order cost. At the start of the final  $d \log T$  rounds of sum-check, for each  $\ell \in \{1, 2\}$ ,  $\tilde{\mathbf{r}}_{\ell}(r, j)$  takes on only  $K^{1/d}$  distinct values as  $j$  ranges over  $\{0, 1\}^{\log T}$ . Hence, all possible products of the form  $\tilde{\mathbf{r}}_{\ell_1}(r, j_1) \cdot \tilde{\mathbf{r}}_{\ell_2}(r, j_2)$  as  $j_1$  and  $j_2$  range over  $\{0, 1, 2\} \times \{0, 1\}^{\log(T)-1}$  can be computed and stored in a table of size  $O(K^{2/d})$ , thereby saving the prover the need to incur  $T$  field multiplications to compute such quantities arising in Expression (100) for round  $\log(T) + 1$ . Similar optimizations apply for several rounds, with the size of the lookup table of “pre-computed products of  $\tilde{\mathbf{r}}_{\ell_1}$  and  $\tilde{\mathbf{r}}_{\ell_2}$  evaluations” growing (rapidly) round-over-round. After a few rounds, the lookup tables would have size larger than  $T$  and this optimization is no longer helpful.

Depending on how much smaller  $K^{1/d}$  is than  $\sqrt{T}$ , this can save up to about half of the  $10T$  field multiplications accounted for above. This yields a total number of multiplications of roughly  $5.5 \cdot T$ .

### C.1.2 General $d$ : Simplifying the prover's message definition

Consider the first round in stage  $i$ . This is round  $t' = \log(K) + t$  where  $t = d(i-1) + 1 = di - d + 1$ . The prover's prescribed message  $s_{t'}$  in round  $t'$  satisfies:

$$s_{t'}(c) = \widetilde{\mathbf{Val}}(r) \cdot \sum_{j'_1 \in \{0, 1\}^{\log(T)-i}, j'_2, \dots, j'_d \in \{0, 1\}^{\log(T)-i+1}} \tilde{\mathbf{e}}(r', (w_1, c, j'_1), (w_2, j'_2), \dots, (w_d, j'_d)) \cdot \tilde{\mathbf{r}}_{\ell_1}(r, w_1, c, j'_1) \cdot \prod_{\ell=2}^{d} \tilde{\mathbf{r}}_{\ell}(r, w_{\ell}, j'_{\ell}).$$

Clearly,  $\tilde{\mathbf{e}}(r', (w_1, c, j'_1), (w_2, j'_2), \dots, (w_d, j'_d)) = 0$  unless  $j'_1 = j'_{2, >1} = \dots = j'_{d, >1}$ . So this sum simplifies to

<span id="page-92-0"></span>
$$s_i(c) = \widetilde{\mathbf{Val}}(r) \cdot \sum_{j'_1 \in \{0, 1\}^{\log(T)-i}, b \in \{0, 1\}} \tilde{\mathbf{e}}(r', (w_1, c, j'_1), (w_2, b, j'_1), \dots, (w_d, b, j'_1)) \cdot \tilde{\mathbf{r}}_{\ell_1}(r, w_1, c, j'_1) \prod_{\ell=2}^{d} \tilde{\mathbf{r}}_{\ell}(r, w_{\ell}, b, j'_1). \quad (103)$$

Let

$$D = \left( \prod_{z=1}^{i-1} \left( r'_z \left( \prod_{\ell=1}^{d} w_{\ell, z} w_{2, z} \right) + (1 - r'_z) \left( \prod_{\ell=1}^{d} (1 - w_{\ell, z}) \right) \right) \right).$$

By Equation (94), for  $b \in \{0, 1\}$ ,

$$\tilde{\mathbf{e}}(r', (w_1, c, j'_1), (w_2, b, j'_1), \dots, (w_d, b, j'_1)) = D \cdot \tilde{\mathbf{e}}(r'_i, c, b) \cdot \tilde{\mathbf{e}}(r'_{>i}, j'_1, j'_1, \dots, j'_1).$$

Hence, letting

<span id="page-92-1"></span>
$$C = \widetilde{\mathbf{Val}}(r) \cdot D, \quad (104)$$

Expression (103) equals:

$$C \cdot \sum_{j_1' \in \{0,1\}^{\log(T)-i}, b \in \{0,1\}} \tilde{\mathbf{eq}}(r_i', c, b) \cdot \tilde{\mathbf{eq}}(r_{>i}', j_1', j_1', \dots, j_1') \cdot \tilde{\mathbf{ra}}_1(r, w_1, c, j_1') \cdot \prod_{\ell=2}^{d} \tilde{\mathbf{ra}}_{\ell}(r, w_{\ell}, b, j_1'). \quad (105)$$

Furthermore, note that for  $j_1' \in \{0,1\}^{\log(T)-i}$ ,

$$\tilde{\mathbf{eq}}(r_{>i}', j_1', j_1', \dots, j_1') = \tilde{\mathbf{eq}}(r_{>i}', j_1'),$$

where the polynomial  $\tilde{\mathbf{eq}}$  on the right hand side refers to Equation (15). Hence, Expression (100) equals:

$$C \cdot \sum_{j_1' \in \{0,1\}^{\log(T)-i}, b \in \{0,1\}} \tilde{\mathbf{eq}}(r_i', c, b) \cdot \tilde{\mathbf{eq}}(r_{>i}', j_1') \cdot \tilde{\mathbf{ra}}_1(r, w_1, c, j_1') \cdot \prod_{\ell=2}^{d} \tilde{\mathbf{ra}}_{\ell}(r, w_{\ell}, b, j_1'). \quad (106)$$

Similarly, turning our attention to the prover's message in round  $M$  of Stage  $i$ , for  $M = 2, \dots, d-1$ , let

<span id="page-93-0"></span>
$$C' = C \cdot \tilde{\mathbf{eq}}(r_i', w_{1,i}, w_{2,i}, \dots, w_{M-1,i}, c).$$

Then

$$s_{\nu+M-1}(c) = C' \cdot \sum_{j_M' \in \{0,1\}^{\log(T)-i}, b \in \{0,1\}} \tilde{\mathbf{eq}}(r_{>i}', j_M') \cdot \left( \prod_{N=1}^{M-1} \tilde{\mathbf{ra}}_N(r, w_{N,i}, j_M') \right) \cdot \tilde{\mathbf{ra}}_M(r, w_M, c, j_M') \cdot \left( \prod_{\ell=M+1}^{d} \tilde{\mathbf{ra}}_{\ell}(r, w_{\ell}, b, j_M') \right). \quad (107)$$

Finally, for round  $M = d$  of Stage  $i$ , the prover's message is:

$$s_{\nu+M-1}(c) = C' \cdot \sum_{j_M' \in \{0,1\}^{\log(T)-i}} \tilde{\mathbf{eq}}(r_{>i}', j_M') \cdot \left( \prod_{N=1}^{M-1} \tilde{\mathbf{ra}}_N(r, w_{N,i}, j_M') \right) \cdot \tilde{\mathbf{ra}}_M(r, w_M, c, j_M'). \quad (108)$$

**Prover algorithm for general  $d$ .** Before the final  $d \log T$  rounds of Shout's read-checking sum-check protocol begin, the prover computes and stores  $\log(T) - 1$  arrays  $E_{\log(T)-1}, \dots, E_1$ , where  $E_i$  contains all evaluations  $\tilde{\mathbf{eq}}(r_{>i}, j_{>i})$  as  $j_{>i}$  ranges over  $\{0,1\}^{\log(T)-i}$ . Also, at the start of these final  $\log T$  rounds, the prover will have already computed  $d$  arrays, say  $A_1, A_2, \dots, A_d$ , such that  $A_{\ell}$  stores all evaluations of the form  $\tilde{\mathbf{ra}}_{\ell}(r', j)$  as  $j$  ranges over  $\{0,1\}^{\log T}$ . As per the standard linear-time sum-check prover algorithm (Section 3.3), the prover will bind each  $A_{\ell}$  (see Equation (20)) as appropriate round-over-round.

The prover can maintain the value  $C$  from Equation (104) round-over-round with only a constant number of field multiplications per round.

For each  $j_M' \in \{0,1\}^{\log(T)-i}$ , the prover can compute

<span id="page-93-3"></span><span id="page-93-1"></span>
$$\left( \prod_{\ell=M+1}^{d} \tilde{\mathbf{ra}}_{\ell}(r, w_{\ell}, b, j_M') \right) \quad (109)$$

for all relevant values of  $M$  (i.e., for  $M = d-1, d-2, \dots, 1$ ) with  $d-2$  multiplications. So that's  $(d-2)T/2^i$  multiplications in total across all  $j_M' \in \{0,1\}^{\log(T)-i}$ .

Also, across all  $d$  rounds  $M$  of Stage  $i$ , the prover can also compute

<span id="page-93-2"></span>
$$\left( \prod_{N=1}^{M-1} \tilde{\mathbf{ra}}_N(r, w_{N,i}, j_M') \right) \quad (110)$$

with  $(d - 2) \cdot T/2^i$  multiplications in total.

Given these values, for round  $M = 1, \dots, d - 1$  in Stage  $i$ , the prover can compute its message (Expression (107)) at  $c = 0$  with  $2 \cdot T/2^i$  field multiplications and at  $c = 2$  with  $4 \cdot T/2^i$  field multiplications (up to additive  $O(d)$  terms). For round  $d$ , due to the lack of a sum over  $b \in \{0, 1\}$ , the evaluation of the prover's message at each of  $c = 0$  and  $c = 2$  takes  $2T/2^i$  field multiplications.

Summarizing the costs:

- $T/2$  to compute the  $E_i$  arrays before the start of the final  $d \log T$  rounds of the sum-check protocol.
- $2(d - 2)T$  to compute the products in Expression 109 and (110).
- $6(d - 1)T$  for the first  $d - 1$  rounds of all stages in total.
- $4T$  for the final round of all stages in total.

The total number is multiplications is therefore

$$(8d - 5.5)T.$$

### Additional optimizations.

- In the final round of every stage, Gruen's optimization (Section 3.6.1) applies. Recall that Gruen's optimization considers applying sum-check to polynomials of the form  $\tilde{\mathbf{eq}}(r', x) \cdot g(x)$  and avoids  $\tilde{\mathbf{eq}}(r', x)$  from contributing to the degree of the univariate polynomial  $s_t(c)$  the prover computes in each round  $t$ . This same technique applies to the factor

<span id="page-94-0"></span>
$$\tilde{\mathbf{eq}}(r'_i, w_{1,i}, w_{2,i}, \dots, w_{M-1,i}, c) \quad (111)$$

appearing above in the definition of  $C'$  and hence Equation (108) capturing the prover's message in the final round of stage  $i$ . The key property that ensures Gruen's optimization applies is that all values other than  $c$  appearing in Expression (111) are fixed. In other words,  $r'_i, w_{1,i}, \dots, w_{M-1,i}$  are *not* being summed over in the final round of stage  $i$ . Accordingly Expression (108) is a degree-1 polynomial in  $c$  alone. This is all Gruen's optimization needs in order to apply.

This reduces the  $4T$  multiplications required for the final round of all stages down to  $2T$ . Hence, it reduces total prover multiplications from  $(8d - 5.5)T$  down to

$$(8d - 7.5)T.$$

- The optimization that we described in the case of  $d = 2$  that applies when  $K^{1/d}$  is  $o(\sqrt{T})$  also applies for general  $d$ . In the context of  $d > 2$ , this optimization can be used to save a significant fraction of the  $2(d - 2)T$  multiplications needed to compute the products in Expression 109 and (110). Details follow.

This optimization is primarily applicable when combining Shout with a binary-field hashing-based commitment scheme like Binius [DP23, DP24] or Blaze [BCF+24], as this is the context in which  $d$  may get set quite large (and hence  $K^{1/d}$  quite small) especially when considering gigantic, structured tables. For instance, if  $K = 2^{64}$  then setting  $d = 16$  is natural (see Section 2.8). In this case,  $K^{1/d}$  is just  $2^4 = 16$ .

**Optimization details.** For each fixed  $i = 1, \dots, d$ , the evaluations  $\tilde{\mathbf{ra}}_i(r, j)$  take on only  $K^{1/d}$  as  $j$  ranges over  $\{0, 1\}^{\log T}$ . Hence, during round  $\log(K) + 1$  of the modified-Shout protocol, for any integer  $\ell > 1$ , the prover can compute lookups tables of size  $K^{2/d}, K^{3/d}, \dots, K^{\ell/d}$ , with the  $i$ 'th table storing all *possible* products of the form

<span id="page-94-1"></span>
$$\prod_{v=M-i}^{M} \mathbf{ra}_v(r, j), \quad (112)$$

for  $j \in \{0, 1\}^{\log T}$ , since there are only  $K^{i/d}$  such values. After this table is computed, the prover can compute Expression (109) (i.e., the actual quantities of Expression (112) for all  $T$  values of  $j \in \{0, 1\}^{\log T}$ )

with a single lookup into this table for each  $j$ . This saves  $(\ell - 1) \cdot T$  multiplications. A similar technique applies for computing Expression (110) in round  $\log(K) + 1$ , but the  $i$ 'th table has size  $4K^{2id}$  in this case, and similarly for computing Expression (109) in round  $\log(K) + 2$ , and so on.

In the context of  $K = 2^{64}$  and  $d = 16$ , using a handful of tables each of size at most  $2^{20}$  (i.e., several dozen MBs of space), this can save  $5T$  multiplications:  $3T$  during the computation of Expression (110) in round  $\log(K) + 1$  with  $\ell$  set to 4,  $T$  during the computation of Expression (110) in round  $\log(K) + 1$  with  $\ell$  set to 2, and  $T$  during the computation of Expression (109) in round  $\log(K) + 1$ . This brings the total number of prover field multiplications in this application down to  $8d - 12.5T$ .
