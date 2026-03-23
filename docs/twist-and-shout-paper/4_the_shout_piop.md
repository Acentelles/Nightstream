## 4 The Shout PIOP

This section gives a complete description of the Shout PIOP (both the special case when  $d = 1$  and the case of general  $d$ ). We defer until Section 6 an explanation of how to quickly implement the prover in this PIOP.

### 4.1 A special case: $d = 1$

#### 4.1.1 Core Shout PIOP for $d = 1$

Figure 5 contains the core Shout PIOP when  $d = 1$ . It is identical to (the first sum-check invocation) in the Generalized-Lasso protocol [STW24].

<span id="page-38-2"></span>**Theorem 1.** Consider an instance of read-only memory-checking, and assume that for each  $j \in \{0, 1\}^{\log T}$ ,  $\tilde{\mathsf{ra}}(\cdot, j)$  is the one-hot representation of the address read at cycle  $j$ . Then the PIOP in Figure 5 has perfect completeness and soundness error  $(2\log(K) + \log(T))/|\mathbb{F}|$ .

*Proof.* Since  $\tilde{\mathsf{ra}}(\cdot, j)$  is the one-hot representation of the address read at cycle  $j$ ,  $\tilde{\mathsf{rv}}(j)$  is indeed the table

value stored at that address if and only if

<span id="page-39-0"></span>
$$\tilde{\mathbf{v}}(j) = \sum_{k \in \{0,1\}^{\log K}} \tilde{\mathbf{a}}(k, j) \cdot \tilde{\mathbf{v}}\mathbf{a}(k). \quad (22)$$

Both the left hand side and right hand side of Equation (22) are multilinear polynomials in  $j$ . Hence they are equal as formal polynomials if and only if this equality holds for all  $j \in \{0,1\}^{\log T}$ . By the Schwartz-Zippel lemma, up to soundness error  $\log(T)/|\mathbb{F}|$ , in order to check that the left hand side and right hand side are the same multilinear polynomial it suffices for  $\mathbf{V}$  to pick  $r_{\text{cycle}}$  at random from  $\mathbb{F}^{\log T}$  and confirm that

<span id="page-39-3"></span>
$$\tilde{\mathbf{v}}(r_{\text{cycle}}) = \sum_{k \in \{0,1\}^{\log K}} \tilde{\mathbf{a}}(k, r_{\text{cycle}}) \cdot \tilde{\mathbf{v}}\mathbf{a}(k). \quad (23)$$

Figure 5 applies the sum-check protocol to confirm this. The claim now follows from the completeness and soundness properties of the sum-check protocol (Section 3.3).  $\square$ 

According to our formulation of the memory-checking problem (Section 2.2), one should separately check that for each  $j \in \{0,1\}^{\log T}$ ,  $\tilde{\mathbf{a}}(\cdot, j)$  is indeed the one-hot representation of some address  $\mathbf{a}f(j) \in \{0,1,\dots,K-1\}$  that is read at cycle  $j$  (and query access to the multilinear polynomial  $\tilde{\mathbf{a}}f$  should be granted to the verifier). A PIOP for establishing this is given in Section 4.1.2 below.

We describe in Section 6.1 how to quickly implement the prover in core Shout PIOP when  $d = 1$ .

<span id="page-39-1"></span>

#### 4.1.2 Checking correctness of one-hot encodings

Suppose the prover has committed to (the multilinear extension of) a vector  $\mathbf{a} \in (\mathbb{F}^K)^T$  and is also prepared to grant the verifier query access to a  $\log(T)$ -variate multilinear virtual polynomial  $\tilde{\mathbf{a}}f$ . The prover claims that for each  $j \in \{0,1\}^{\log T}$ ,  $\tilde{\mathbf{a}}f(j) \in \{0,1,\dots,K-1\}$  and the vector  $\tilde{\mathbf{a}}(\cdot, j)$  as  $\cdot$  ranges over  $\{0,1\}^{\log K}$ , equals the one-hot encoding of  $\mathbf{a}f(j)$ . We describe a PIOP to check these claims. In other words, the PIOP allows the verifier to:

- Confirm that  $\tilde{\mathbf{a}}(k, j) \in \{0,1\}$  for all  $k \in \{0,1\}^{\log K}$ .
- Confirm that  $\tilde{\mathbf{a}}(k, j)$  equals 1 for exactly one register  $k \in \{0,1\}^{\log K}$ .
- Obtain query access to  $\tilde{\mathbf{a}}f(j)$ , where the  $k \in \{0,1\}^{\log K}$  from the previous bullet is the binary representation of  $\mathbf{a}f(j)$ .

**Checking the first bullet.** To check the first bullet point, simply apply the zero-check PIOP to confirm that for all  $(k, j) \in \{0,1\}^{\log K} \times \{0,1\}^{\log T}$ ,

$$\tilde{\mathbf{a}}(k, j)^2 - \tilde{\mathbf{a}}(k, j) = 0. \quad (24)$$

We will show later (Section 6.3) that the prover in this zero-check PIOP performs only  $O(K) + 2T$  field multiplications.

**Checking the second bullet.** The second bullet point is equivalent to the following constraint holding for all  $j \in \{0,1\}^{\log T}$ :

<span id="page-39-2"></span>
$$1 = \sum_{k \in \{0,1\}^{\log K}} \tilde{\mathbf{a}}(k, j). \quad (25)$$

Since the left hand side and right hand side of Equation (25) are both multilinear polynomials in  $j$  (in fact, the left hand side has degree 0), satisfaction of this constraint system implies that  $\tilde{\mathbf{a}}$  equals the right hand side

of Equation (27) as formal polynomials (and vice versa). Hence, the entire constraint system can be checked (with soundness error  $\log(T)/|\mathbb{F}|$ ) by having the verifier pick a random  $r' \in \mathbb{F}^{\log T}$  and confirming that

<span id="page-40-1"></span>
$$1 = \sum_{k \in \{0,1\}^{\log K}} \tilde{r}\tilde{a}(k, r'). \quad (26)$$

Since  $\tilde{b}$  is multilinear, it is easy to see that, so long as the field characteristic is greater than 2, this sum is in fact equal to

$$K \cdot \tilde{r}\tilde{a}(2^{-1}, \dots, 2^{-1}, r'),$$

(see for example [AW09, End of Section 1.4] for reference). And so Equation (26) can be confirmed to hold by the verifier with a single evaluation query to  $\tilde{r}\tilde{a}$ , at point  $(2^{-1}, \dots, 2^{-1}, r')$ .

This technique does not work over binary fields (where  $2^{-1}$  is undefined). In that case, one can simply apply the sum-check protocol directly to compute Equation (26). This has the additional benefit that it lowers the number of evaluation queries to  $\tilde{r}\tilde{a}$  performed by the verifier (i.e., by running this sum-check in parallel with the one used to check the third bullet below, we can ensure that both sum-checks wind up evaluating  $\tilde{r}\tilde{a}$  at the same point).

**Checking the third bullet.** Given the first two bullet points hold, the third bullet point is equivalent to to the following constraint holding for all  $j \in \{0,1\}^{\log T}$ :

<span id="page-40-0"></span>
$$\tilde{a}(j) = \sum_{k \in \{0,1\}^{\log K}} \left( \sum_{i=0}^{\log(K)-1} 2^i k_i \right) \cdot \tilde{r}\tilde{a}(k, j). \quad (27)$$

Since the left hand side and right hand side of Equation (27) are both multilinear polynomials in  $j$ , satisfaction of this constraint system implies that  $\tilde{a}$  equals the right hand side of Equation (27) as formal polynomials (and vice versa). Hence, the entire constraint system can be checked (with soundness error  $\log(T)/|\mathbb{F}|$ ) by having the verifier pick a random  $r' \in \mathbb{F}^{\log T}$  and confirming that

$$\tilde{r}\tilde{a}f(r') = \sum_{k \in \{0,1\}^{\log K}} \left( \sum_{i=0}^{\log(K)-1} 2^i k_i \right) \cdot \tilde{r}\tilde{a}(k, r').$$

The verifier can obtain the evaluation  $\tilde{r}\tilde{a}f(r)$  from the commitment to  $\tilde{r}\tilde{a}f$ . To compute

$$\sum_{k \in \{0,1\}^{\log K}} \left( \sum_{i=0}^{\log(K)-1} 2^i k_i \right) \cdot \tilde{r}\tilde{a}(k, r'),$$

the prover and verifier can apply the sum-check protocol, at the end of which the verifier needs to evaluate  $\tilde{r}\tilde{a}(r, r')$  for a random point  $(r, r') \in \mathbb{F}^{\log K} \times \mathbb{F}^{\log T}$ . This evaluation can be obtained by the verifier from the commitment to  $\tilde{r}\tilde{a}$ .

Figure 6 provides the entire PIOP. The following theorem is immediate from completeness and soundness of the sum-check protocol and the discussion above.

<span id="page-40-2"></span>**Theorem 2.** Figure 6 satisfies perfect completeness and has soundness error  $(6 \log(K) + 4 \log(T))/|\mathbb{F}|$ . That is, if  $\tilde{r}\tilde{a}(j)$  is not the one-hot encoding of some value  $\tilde{r}\tilde{a}f(j) \in \{0,1,\dots,K-1\}$  for all  $j \in \{0,1\}^{\log T}$ , or if the claim that  $\tilde{r}\tilde{a}f(r') = y$  is false, the verifier will accept with probability at most  $(2 \log(K) + \log(T))/|\mathbb{F}|$ .

*Proof.* First, suppose that for some  $j \in \{0,1\}^{\log T}$ ,  $\tilde{r}\tilde{a}(\cdot, j)$  is not the correct one-hot-representation of some value in  $\{0,1,\dots,K-1\}$ . Then either  $\tilde{r}\tilde{a}(k, j) \notin \{0,1\}$  for some  $k \in \{0,1\}^{\log K}$ , or  $\sum_{k \in \{0,1\}^{\log K}} \tilde{r}\tilde{a}(k, j) \neq 1$ . We claim this implies that the verifier in Figure 6 rejects with sufficiently high probability.

Observe that the following polynomial  $g(r, r')$  is multilinear:

$$g(r, r') = \sum_{k \in \{0,1\}^{\log K}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{eq}}(r, k) \tilde{\mathbf{eq}}(r', j) (\tilde{\mathbf{ra}}(k, j)^2 - \tilde{\mathbf{ra}}(k, j)).$$

Furthermore, if there is any  $(k, j) \in \{0,1\}^{\log K} \times \{0,1\}^{\log T}$  such that  $\tilde{\mathbf{ra}}(k, j) \notin \{0, 1\}$ ,  $g$  is not the identically-zero polynomial. Hence, by the Schwartz-Zippel lemma, with probability at least  $1 - (\log(K) + \log(T))/|\mathbb{F}|$  over the random choice of  $r, r'$ , Equation (29) fails to hold. In this event, the soundness guarantee of the sum-check protocol ensures that the verifier rejects within the Booleanity-checking sum-check with probability at least  $1 - 3(\log(K) + \log(T))/|\mathbb{F}|$ .

Let  $h(j) = \sum_{k \in \{0,1\}^{\log K}} \tilde{\mathbf{ra}}(k, j)$ .  $h$  is multilinear in  $j$ , and if there is any  $j \in \{0,1\}^{\log T}$  for which  $h(j) \neq 1$ , then  $h$  is not the identically-1 polynomial. In this case, by the Schwartz-Zippel lemma, with probability at least  $1 - \log(T)/|\mathbb{F}|$  over the random choice of  $r_{\text{cycle}}$ ,  $1 = h(r_{\text{cycle}})$  will fail to hold. In this event, the soundness guarantee of the sum-check protocol ensures that the verifier will reject in the Hamming weight 1 check with probability at least  $1 - \log(K)/|\mathbb{F}|$ . This completes the proof of the claim.

Finally, suppose that  $\tilde{\mathbf{raf}}(r_{\text{cycle}}) \neq y$ . We claim that  $\tilde{\mathbf{raf}}(r_{\text{cycle}})$  satisfies the following equality:

<span id="page-41-0"></span>
$$\tilde{\mathbf{raf}}(r_{\text{cycle}}) = \sum_{k \in \{0,1\}^{\log K}} \left( \sum_{i=0}^{\log(K)-1} 2^i \cdot k_i \right) \cdot \tilde{\mathbf{ra}}(k, r_{\text{cycle}}), \quad (28)$$

Indeed, the right hand side of this equation is multilinear in  $r_{\text{cycle}}$  and agrees with  $\tilde{\mathbf{raf}}$  whenever  $r_{\text{cycle}} \in \{0,1\}^{\log T}$ . Since  $\{0,1\}^{\log T}$  is an interpolating set for multilinear polynomials, the left hand side and right hand side must be equal as formal polynomials in  $r_{\text{cycle}}$ .

Hence, if  $\tilde{\mathbf{raf}}(r_{\text{cycle}}) \neq y$ , soundness of the sum-check protocol guarantees that the verifier will reject in the  $\tilde{\mathbf{raf}}$ -evaluation sum-check invocation with probability at least  $1 - 2\log(K)/|\mathbb{F}|$ . This completes the proof of the soundness property stated in the theorem.

Perfect completeness is immediate from perfect completeness of the sum-check protocol, combined with the following facts:

- If every  $\tilde{\mathbf{ra}}(\cdot, j)$  is a valid one-hot encoding for all  $j \in \{0,1\}^{\log T}$ , then  $\tilde{\mathbf{ra}}(k, j) \in \{0,1\}$  for all  $(k, j) \in \{0,1\}^{\log(K)} \times \{0,1\}^{\log T}$ , and hence  $\tilde{\mathbf{ra}}(k, j)^2 - \tilde{\mathbf{ra}}(k, j) = 0$ .
- If every  $\tilde{\mathbf{ra}}(\cdot, j)$  is a valid one-hot encoding for all  $j \in \{0,1\}^{\log T}$ , then  $\sum_{k \in \{0,1\}^{\log K}} \tilde{\mathbf{ra}}(k, j) = 1$  for all  $j \in \{0,1\}^{\log T}$ , and since the left hand side is a multilinear polynomial in  $j$  and  $\{0,1\}^{\log T}$  is an interpolating set for such polynomials, this implies  $\sum_{k \in \{0,1\}^{\log K}} \tilde{\mathbf{ra}}(k, j) = 1$  holds for all  $j \in \mathbb{F}^{\log T}$ .
- Equation (28) holds.

This completes the proof of the theorem.  $\square$ 

## 4.2 Shout for general $d$

Figure 7 has pseudocode for the core Shout PIOP for a general parameter  $d$ , and Figure 8 specifies the PIOP for proving correctness of  $d$ -dimensional one-hot encodings, for general  $d$ .

**Theorem 3.** Figures 7 and 8 satisfy perfect completeness. Assuming each address  $\tilde{\mathbf{ra}}(\cdot, j)$  for  $j \in \{0,1\}^{\log T}$  is indeed the  $d$ -dimensional one-hot encodings of some value  $\tilde{\mathbf{raf}}(j) \in \{0,1,\dots,K-1\}$ , Figure 7 has soundness error at most

$$((d+2)\log T + 2\log K)/|\mathbb{F}|.$$

Figure 8 has soundness error at most

$$(4d\log T + 6\log K)/|\mathbb{F}|.$$

1. As input,  $\mathcal{P}$  has already committed to a multilinear polynomial  $\tilde{r}\mathbf{a}: \mathbb{F}^{\log K} \times \mathbb{F}^{\log T} \to \mathbb{F}$ .  $\mathcal{P}$  claims that for each  $j \in \{0, 1\}^{\log T}$ ,  $\tilde{r}\mathbf{a}(\cdot, j)$  is the one-hot representation of some value  $\tilde{\mathbf{r}}\mathbf{a}(j) \in \{0, 1, \dots, K-1\}$ , and (optionally) that  $\tilde{\mathbf{r}}\mathbf{a}(r_{\text{cycle}}) = y$ .

2.  $\mathcal{V}$  picks  $r \in \mathbb{F}^{\log K}$  and  $r' \in \mathbb{F}^{\log T}$  at random and sends  $(r, r')$  to  $\mathcal{P}$ .

<span id="page-42-2"></span>3. (**Booleanity check**):  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that

<span id="page-42-1"></span>
$$0 = \sum_{k \in \{0, 1\}^{\log K}, j \in \{0, 1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r, k) \tilde{\mathbf{e}}\mathbf{q}(r', j) (\tilde{r}\mathbf{a}(k, j)^2 - \tilde{r}\mathbf{a}(k, j)). \quad (29)$$

4. Let  $(r'_{\text{address}}, r'_{\text{cycle}}) \in \mathbb{F}^{\log K} \times \mathbb{F}^{\log T}$  be the randomness chosen over the course of the sum-check protocol invoked in Line 3.

<span id="page-42-3"></span>5. (**Hamming weight 1 check**):  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that

$$1 = \sum_{k \in \{0, 1\}^{\log K}} \tilde{r}\mathbf{a}(k, r'_{\text{cycle}}).$$

<span id="page-42-4"></span>6. ( **$\tilde{\mathbf{r}}\mathbf{a}$ -evaluation sum-check**): In parallel with the sum-check invocation in Line 5,  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that

$$y = \sum_{k \in \{0, 1\}^{\log K}} \left( \sum_{i=0}^{\log(K)-1} 2^i \cdot k_i \right) \cdot \tilde{r}\mathbf{a}(k, r_{\text{cycle}}).$$

Let  $r''_{\text{address}}$  be the randomness chosen by the verifier over the course of this sum-check instance.

7. To perform  $\mathcal{V}$ 's check in the final round of the two sum-checks (Lines 3 and 6), and  $\mathcal{V}$ 's check in Line 5,  $\mathcal{V}$  evaluates  $\tilde{\mathbf{e}}\mathbf{q}(r, r'_{\text{address}})$  and  $\tilde{\mathbf{e}}\mathbf{q}(r', r'_{\text{cycle}})$  on its own, and evaluates  $\tilde{r}\mathbf{a}(r'_{\text{address}}, r_{\text{cycle}})$ , and  $\tilde{r}\mathbf{a}(r''_{\text{address}}, r'_{\text{cycle}})$  with two queries to  $\tilde{r}\mathbf{a}$ . Alternatively, standard techniques can reduce these two evaluations to a single evaluation of  $\tilde{r}\mathbf{a}$ .

<span id="page-42-0"></span>Figure 6: A PIOP for checking that for each  $j \in \{0, 1\}^T$ ,  $\tilde{r}\mathbf{a}(\cdot, j)$  is the (one-dimensional) one-hot representation of some value  $\tilde{\mathbf{r}}\mathbf{a}(j) \in \{0, 1, \dots, K-1\}$ . This PIOP also grants the verifier query access to the virtual polynomial  $\tilde{\mathbf{r}}\mathbf{a}$  (i.e., when only  $\tilde{r}\mathbf{a}$ , not  $\tilde{\mathbf{r}}\mathbf{a}$ , is sent/committed by the prover).

That is, the verifier in Figure 7 will reject with overwhelming probability if there is any  $j \in \{0, 1\}^{\log T}$  such that  $\tilde{\mathbf{r}}\mathbf{a}(j) \neq \tilde{\mathbf{r}}\mathbf{a}(k)$ , where  $k \in \{0, 1\}^{\log K}$  is the binary representation of the address whose  $d$ -dimensional one-hot encoding is given by  $(\tilde{r}\mathbf{a}_1(j), \dots, \tilde{r}\mathbf{a}_d(j))$ .

*Proof.* The completeness and soundness of Figure 8 is nearly identical to Theorem 2. The main difference is that in place of Equation (28), we now invoke that:

$$\tilde{\mathbf{r}}\mathbf{a}(r'_{\text{cycle}}) = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d, j \in \{0, 1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r'_{\text{cycle}}, j) \left( \sum_{i=1}^{d} \sum_{\ell=0}^{\log(K)/d - 1} 2^{i \cdot \log(K)/d + \ell} \cdot k_{i, \ell} \right) \cdot \prod_{i=1}^{d} \tilde{r}\mathbf{a}_i(k_i, j).$$

This equality holds by the following reasoning. The right hand side is multilinear in  $r'_{\text{cycle}}$ . Since  $\{0, 1\}^{\log T}$  is an interpolating set for multilinear polynomials, we can conclude that the right hand side and left hand side are equal as a formal polynomials (and thus agree at all  $r'_{\text{cycle}} \in \mathbb{F}^{\log T}$ ) so long as they agree whenever whenever  $r'_{\text{cycle}} \in \{0, 1\}^{\log T}$ . To see that this is the case, observe that if  $r'_{\text{cycle}}$  and  $j$  are both in  $\{0, 1\}^{\log T}$ ,

1. $\mathcal{P}$  and  $\mathcal{V}$  have agreed upon a size- $K$  lookup table whose multilinear extension is given by  $\widetilde{\mathsf{Val}}$  (which we assume to be evaluable in  $O(\log K)$  time).  $\mathcal{P}$  has already committed to multilinear polynomials  $\widetilde{\mathsf{ra}}_1, \dots, \widetilde{\mathsf{ra}}_d: \mathbb{F}^{\log(K)/d} \times \mathbb{F}^{\log T} \to \mathbb{F}$ .  $\mathcal{P}$  wishes to give the verifier query access to the virtual polynomial  $\widetilde{\mathsf{rv}}: \mathbb{F}^{\log T} \to \mathbb{F}$ , defined as the unique multilinear polynomial satisfying that: for all  $j \in \{0, 1\}^{\log T}$ ,

$$\widetilde{\mathsf{rv}}(j) = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d} \left( \prod_{i=1}^d \widetilde{\mathsf{ra}}_i(k_i, j) \right) \cdot \widetilde{\mathsf{Val}}(k).$$

1. $\mathcal{V} \to \mathcal{P}$ : pick the desired evaluation point  $r_{\mathsf{cycle}} \in \mathbb{F}^{\log T}$  at random and send it to  $\mathcal{P}$ .

1. **(Read-checking for Shout)**:  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that

<span id="page-43-2"></span>
$$\widetilde{\mathsf{rv}}(r_{\mathsf{cycle}}) = \sum_{\substack{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d, j \in \{0, 1\}^{\log T}}} \widetilde{\mathsf{eq}}(r_{\mathsf{cycle}}, j) \left( \prod_{i=1}^d \widetilde{\mathsf{ra}}_i(k_i, j) \right) \cdot \widetilde{\mathsf{Val}}(k). \quad (30)$$

1. Let  $r_{\mathsf{address}} = (r_{\mathsf{address}}^{(1)}, \dots, r_{\mathsf{address}}^{(d)}) \in (\mathbb{F}^{\log(K)/d})^d$  denote the randomness chosen over the first  $\log(K)$  rounds of the sum-check protocol and  $r'_{\mathsf{cycle}}$  the randomness over the final  $\log T$  rounds. To perform  $\mathcal{V}$ 's check in the final round of the sum-check protocol,  $\mathcal{V}$  queries the committed polynomials  $\widetilde{\mathsf{ra}}_1, \dots, \widetilde{\mathsf{ra}}_d$  respectively at  $(r_{\mathsf{address}}^{(i)}, r'_{\mathsf{cycle}})$ , and evaluates  $\widetilde{\mathsf{Val}}$  at  $r_{\mathsf{address}}$  in  $O(\log K)$  time.

<span id="page-43-0"></span>

Figure 7: The core Shout PIOP with integer parameter  $d > 1$ , assuming the lookup table is MLE-structured (i.e.,  $\mathcal{V}$  can evaluate  $\mathsf{Val}$  at a random input in  $O(\log K)$  time).

then  $\widetilde{\mathsf{eq}}(r'_{\mathsf{cycle}}, j) = 0$  unless  $j = r'_{\mathsf{cycle}}$ . In this case,  $\widetilde{\mathsf{eq}}(r'_{\mathsf{cycle}}, j) = 1$ , while

$$\mathsf{raf}(j) = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d} \left( \sum_{i=1}^d \sum_{\ell=0}^{\log(K)/d-1} 2^{i \cdot \log(K)/d + \ell} \cdot k_{i, \ell} \right) \cdot \prod_{i=1}^d \widetilde{\mathsf{ra}}_i(k_i, j)$$

is immediate from the definition of  $d$ -dimensional one-hot encodings (Section 3.7).

Similarly, completeness and soundness of Figure 7 is nearly identical to Theorem 1, except that we replace Equation (23) with

<span id="page-43-1"></span>
$$\widetilde{\mathsf{rv}}(r_{\mathsf{cycle}}) = \sum_{\substack{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d, j \in \{0, 1\}^{\log T}}} \widetilde{\mathsf{eq}}(r_{\mathsf{cycle}}, j) \left( \prod_{i=1}^d \widetilde{\mathsf{ra}}_i(k_i, j) \right) \cdot \widetilde{\mathsf{Val}}(k). \quad (31)$$

To see that Equation (31) holds, observe that the right hand side is multilinear in  $r_{\mathsf{cycle}}$ . Since  $\{0, 1\}^{\log T}$  is an interpolating set for multilinear polynomials, to show the equality holds for all  $r_{\mathsf{cycle}} \in \mathbb{F}^{\log T}$ , it suffices to show the right hand side and left hand side agree whenever  $r_{\mathsf{cycle}} \in \{0, 1\}^{\log T}$ . To see this, observe that  $\widetilde{\mathsf{eq}}(r_{\mathsf{cycle}}, j) = 0$  if  $j \in \{0, 1\}^{\log T}$  unless  $j = r_{\mathsf{cycle}}$ , in which case  $\widetilde{\mathsf{eq}}(r_{\mathsf{cycle}}, j) = 1$ . Meanwhile, by the definition of  $d$ -dimensional one-hot encoding of addresses (Section 3.7),  $\widetilde{\mathsf{rv}}(j) = \left( \prod_{i=1}^d \widetilde{\mathsf{ra}}_i(k_i, j) \right) \cdot \widetilde{\mathsf{Val}}(k).$   $\square$ 

#### 4.2.1 A standard optimization for verifier costs: Batching parallel sum-check instances

A standard technique to control proof size when running  $t > 1$  parallel sum-check instances is to instead apply a single instance of the sum-check protocol to a random linear combination of the  $t$  claims. In other words, the verifier picks  $z \in \mathbb{F}$  at random, sends  $z$  to the prover, and then the prover applies the sum-check protocol a single time, to prove that:

1. As input,  $\mathcal{P}$  has already committed to multilinear polynomials  $\tilde{\mathbf{r}}\mathbf{a}_1, \dots, \tilde{\mathbf{r}}\mathbf{a}_d: \mathbb{F}^{\log K} \times \mathbb{F}^{\log T} \to \mathbb{F}$ .  $\mathcal{P}$  claims that for each  $j \in \{0, 1\}^T$ ,  $\tilde{\mathbf{r}}\mathbf{a}_1(\cdot, j), \dots, \tilde{\mathbf{r}}\mathbf{a}_d(j)$  is the correct  $d$ -dimensional one-hot representation of some value  $\tilde{\mathbf{r}}\mathbf{a}f(j) \in \{0, 1, \dots, K-1\}$ , and also (optionally) that  $\tilde{\mathbf{r}}\mathbf{a}f(r'_{\text{cycle}}) = y$ .
2. $\mathcal{V}$  picks  $r \in \mathbb{F}^{\log(K)/d}$  and  $r' \in \mathbb{F}^{\log T}$  at random and sends  $(r, r')$  to  $\mathcal{P}$ . Assuming that  $r'_{\text{cycle}}$  was chosen by the verifier at random after  $\tilde{\mathbf{r}}\mathbf{a}_1, \dots, \tilde{\mathbf{r}}\mathbf{a}_d$  and  $\tilde{\mathbf{r}}\mathbf{v}$  were committed, then  $\mathcal{V}$  can set  $r' = r'_{\text{cycle}}$ .
3. **(Booleanity check)**:  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol  $d$  times in parallel to confirm that for  $i = 1, \dots, d$ ,

<span id="page-44-1"></span>
$$0 = \sum_{k \in \{0, 1\}^{\log(K)/d}, j \in \{0, 1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r, k) \tilde{\mathbf{e}}\mathbf{q}(r', j) (\tilde{\mathbf{r}}\mathbf{a}_i(k, j)^2 - \tilde{\mathbf{r}}\mathbf{a}_i(k, j)).$$

1. **(Hamming weight 1 check)**: Let  $r'_{\text{cycle}} \in \mathbb{F}^{\log T}$  be any value chosen at random by  $\mathcal{V}$  after  $\tilde{\mathbf{r}}\mathbf{a}_i$  was committed. For each  $i = 1, \dots, d$ ,  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that

$$1 = \sum_{k_i \in \{0, 1\}^{\log(K)/d}} \tilde{\mathbf{r}}\mathbf{a}_i(k_i, r'_{\text{cycle}}).$$

1. **( $\tilde{\mathbf{r}}\mathbf{a}f$ -evaluation sum-check)**: In parallel with the Booleanity check (and the read-checking sum-check from the core Shout PIOP, see Line 3 of Figure 7),  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that

$$y = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d, j \in \{0, 1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r'_{\text{cycle}}, j) \left( \sum_{i=1}^{d} \sum_{\ell=0}^{\log(K)/d-1} 2^{i \cdot \log(K)/d + \ell} \cdot k_{i, \ell} \right) \cdot \prod_{i=1}^{d} \tilde{\mathbf{r}}\mathbf{a}_i(k_i, j).$$

<span id="page-44-0"></span>Figure 8: A PIOP for checking that for each  $j \in \{0, 1\}^T$ ,  $\tilde{\mathbf{r}}\mathbf{a}_1(\cdot, j), \dots, \tilde{\mathbf{r}}\mathbf{a}_d(j)$  is the correct  $d$ -dimensional one-hot representation of some value  $\tilde{\mathbf{r}}\mathbf{a}f(j) \in \{0, 1, \dots, K-1\}$ , and also granting the verifier query access to the virtual polynomial  $\tilde{\mathbf{r}}\mathbf{a}f$  (i.e., enabling only  $\tilde{\mathbf{r}}\mathbf{a}$ , not  $\tilde{\mathbf{r}}\mathbf{a}f$ , to be sent/committed by the prover). Some hashing-based commitment schemes directly ensure Booleanity of committed values, in which case the Booleanity check (Line 3) can be omitted.

$$0 = \sum_{i=1}^{t} z^{\ell-1} \cdot \sum_{k \in \{0, 1\}^{\log(K)/d}, j \in \{0, 1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r, k) \tilde{\mathbf{e}}\mathbf{q}(r', j) (\tilde{\mathbf{r}}\mathbf{a}_i(k, j)^2 - \tilde{\mathbf{r}}\mathbf{a}_i(k, j)). \quad (32)$$

This adds at most  $t/|\mathbb{F}|$  to the soundness error, and avoids a  $t$ -fold increase in proof size. In the context of Twist and Shout, it can also have prover time benefits (see for example Section 6.3).
