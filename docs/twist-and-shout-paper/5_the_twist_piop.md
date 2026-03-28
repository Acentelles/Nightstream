## 5 The Twist PIOP

The core Twist PIOP is given in full in Figure 9. The PIOP in this figure is sound assuming that all one-hot encodings are provided correctly, i.e., that for all  $j \in \{0, 1\}^{\log T}$ ,  $\tilde{\mathbf{r}}\mathbf{a}(j)$  are  $\tilde{\mathbf{w}}\mathbf{a}(j)$  are the correct  $d$ -dimensional one-hot encodings of some values  $\tilde{\mathbf{r}}\mathbf{a}f(j)$  and  $\tilde{\mathbf{w}}\mathbf{a}f(j)$  in  $\{0, 1, \dots, K-1\}$ . To confirm this, one can invoke the one-hot-encoding-checking PIOP of Figure 8 (replacing  $\tilde{\mathbf{r}}\mathbf{a}_i$  and  $\tilde{\mathbf{r}}\mathbf{a}f$  with  $\tilde{\mathbf{w}}\mathbf{a}_i$  and  $\tilde{\mathbf{w}}\mathbf{a}f$  as appropriate).

**Theorem 4.** Figure 9 has perfect completeness and soundness error at most

$$((2d + 3) \log T + 3 \log K) / |\mathbb{F}|.$$

That is, the verifier in Figure 9 will reject with overwhelming probability if the claimed value of  $\tilde{\mathbf{r}}\mathbf{v}(r')$  does

1. As input,  $\mathcal{P}$  has already committed to the multilinear polynomials  $\widetilde{\text{Inc}}: \mathbb{F}^{\log K} \times \mathbb{F}^{\log T} \to \mathbb{F}$ ,  $\widetilde{\text{wv}}: \mathbb{F}^{\log T} \to \mathbb{F}$ , and  $\widetilde{\text{ra}}_1, \widetilde{\text{wa}}_1, \dots, \widetilde{\text{ra}}_d, \widetilde{\text{wa}}_d: \mathbb{F}^{\log(K)/d} \times \mathbb{F}^{\log T} \to \mathbb{F}$ . If the prover is honest, then  $\widetilde{\text{Inc}}$  is the MLE of the vector  $\text{Inc}$  defined via Equation (9).  $\widetilde{\text{Val}}: \mathbb{F}^{\log K} \times \mathbb{F}^{\log T}$  is a virtual polynomial that is defined as

$$\widetilde{\text{Val}}(k, j) = \sum_{j' \in \{0, 1\}^{\log T}} \widetilde{\text{Inc}}(k, j) \widetilde{\text{LT}}(j', j).$$

The prover wishes to give the verifier query access to the virtual polynomial  $\widetilde{\text{rv}}$ , defined as the unique multilinear polynomial satisfying that for all  $j \in \{0, 1\}^{\log T}$ ,

$$\widetilde{\text{rv}}(j) = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K/d)})^d} \left( \prod_{i=1}^d \widetilde{\text{ra}}_i(k_i, j) \right) \cdot \widetilde{\text{Val}}(k, j),$$

where  $\widetilde{\text{Val}}(k, j)$  is the value stored in register  $k$  during cycle  $j$  according to  $\widetilde{\text{wa}}$  and  $\widetilde{\text{wv}}$ .

2.  $\mathcal{V} \to \mathcal{P}$ : pick a desired evaluation point  $r' \in \mathbb{F}^{\log T}$  for  $\widetilde{\text{rv}}$  and send it to  $\mathcal{P}$ . Also pick  $r \in \mathbb{F}^{\log K}$  at random and send it to  $\mathcal{P}$ . Then  $\mathcal{V}$  and  $\mathcal{P}$  run the following two instances of the sum-check protocol in parallel:

3. **Read-checking sum-check.**  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to compute

$$\widetilde{\text{rv}}(r') = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K/d)})^d, j \in \{0, 1\}^{\log T}} \widetilde{\text{eq}}(r', j) \cdot \left( \prod_{i=1}^d \widetilde{\text{ra}}_i(k_i, j) \right) \cdot \widetilde{\text{Val}}(k, j) \quad (33)$$

4. **Write-checking sum-check.** In parallel with the read-checking sum-check,  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to confirm that  $\widetilde{\text{Inc}}(r, r')$  equals:

$$\sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K/d)})^d, j \in \{0, 1\}^{\log T}} \widetilde{\text{eq}}(r, k) \cdot \widetilde{\text{eq}}(r', j) \cdot \left( \prod_{i=1}^d \widetilde{\text{wa}}_i(k_i, j) \right) \cdot \left( \widetilde{\text{wv}}(j) - \widetilde{\text{Val}}(k, j) \right). \quad (34)$$

5. At the end of the above instances of the sum-check protocol, for random values  $r_{\text{address}}, r_{\text{cycle}}$ , the verifier has to evaluate  $\widetilde{\text{wa}}(r_{\text{address}}, r_{\text{cycle}})$ ,  $\widetilde{\text{wv}}(r_{\text{cycle}})$ ,  $\widetilde{\text{ra}}(r_{\text{address}}, r_{\text{cycle}})$  and  $\widetilde{\text{Val}}(r_{\text{address}}, r_{\text{cycle}})$ . The  $\widetilde{\text{wa}}$ ,  $\widetilde{\text{wv}}$ , and  $\widetilde{\text{ra}}$  evaluations are obtained directly from the commitments to these polynomials. The  $\widetilde{\text{Val}}$  evaluation is obtained from the  $\widetilde{\text{Val}}$ -evaluation sum-check below.

6.  **$\widetilde{\text{Val}}$ -evaluation sum-check.**  $\mathcal{V}$  and  $\mathcal{P}$  apply the sum-check protocol to compute

$$\widetilde{\text{Val}}(r_{\text{address}}, r_{\text{cycle}}) = \sum_{j' \in \{0, 1\}^{\log T}} \widetilde{\text{Inc}}(r_{\text{address}}, j') \cdot \widetilde{\text{LT}}(j', r_{\text{cycle}}).$$

7. To perform  $\mathcal{V}$ 's check in the final round of this sum-check protocol, the verifier has to evaluate  $\widetilde{\text{Inc}}$  at a random point and  $\widetilde{\text{LT}}$ . The verifier computes the  $\widetilde{\text{LT}}$  evaluation on its own in  $O(\log T)$  time. The evaluation of  $\widetilde{\text{Inc}}$  is obtained via the commitment to  $\widetilde{\text{Inc}}$ .

<span id="page-45-0"></span>

Figure 9: The core  $\text{Twist PIOP}$  for parameter  $d \ge 1$ , ignoring checking correctness of one-hot decompositions (which is covered in Figure 8).

not actually equal  $\widetilde{\text{rv}}(r')$  for the unique multilinear polynomial satisfying that for all  $j \in \{0, 1\}^{\log T}$ ,

$$\widetilde{\text{rv}}(j) \neq \widetilde{\text{Val}}(k, j), \quad (35)$$

where  $k \in \{0, 1\}^{\log K}$  is the binary representation of the address whose  $d$ -dimensional one-hot encoding is given by  $(\widetilde{\text{ra}}_1(j), \dots, \widetilde{\text{ra}}_d(j))$ , and  $\widetilde{\text{Val}}(k, j)$  is the value most recently written to address  $k$  prior to the  $j$ 'th

write operation.

*Proof.* We begin with the soundness analysis.

**Defining some polynomials.** Let  $\widetilde{\text{cInc}}$  denote the actual MLE of the “correct” increments implies by the write operations specified by  $\widetilde{\text{wa}}$  and  $\widetilde{\text{wv}}$  (as opposed to  $\widetilde{\text{Inc}}$ , which denotes the committed multilinear polynomial that is *claimed* by the prover to equal  $\widetilde{\text{cInc}}$ ). Similarly, let  $\widetilde{\text{cRV}}$  denote the MLE of the “correct” values returned by each read operation. Finally, let  $\widetilde{\text{cVal}}(k, j)$  denote the MLE of the “correct” values stored in register  $k$  after  $j-1$  writes have occurred, while  $\widetilde{\text{Val}}(k, j)$  denotes the multilinear polynomial defined via:

<span id="page-46-0"></span>
$$\widetilde{\text{Val}}(k, j) = \sum_{j' \in \{0, 1\}^{\log T}} \widetilde{\text{Inc}}(k, j') \cdot \widetilde{\text{LT}}(j', j). \quad (36)$$

**Relationships between these polynomials.** Note that for all  $(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ ,

<span id="page-46-1"></span>
$$\widetilde{\text{cInc}}(k, j) = \left( \prod_{i=1}^{d} \widetilde{\text{ra}}_i(k, j) \right) \left( \widetilde{\text{wv}}(j) - \widetilde{\text{cVal}}(k, j) \right). \quad (37)$$

(This is not an equality of formal polynomials, since the right hand side is not multilinear in  $k$  and  $j$ , but the equality does hold at all inputs in  $\{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ ).

In addition,

<span id="page-46-2"></span>
$$\widetilde{\text{cVal}}(k, j) = \sum_{j' \in \{0, 1\}^{\log T}} \widetilde{\text{cInc}}(k, j') \cdot \widetilde{\text{LT}}(j', j). \quad (38)$$

This is an equality of formal polynomials, since the right hand side is multilinear in  $k$  and  $j$  and the agrees with the left hand side pointwise over the interpolating set  $\{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ .

Finally, note that

<span id="page-46-3"></span>
$$\widetilde{\text{cRV}}(r') = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d, j \in \{0, 1\}^{\log T}} \widetilde{\text{eq}}(r', j) \cdot \left( \prod_{i=1}^{d} \widetilde{\text{ra}}_i(k_i, j) \right) \cdot \widetilde{\text{cVal}}(k, j). \quad (39)$$

This too is an equality of formal polynomials. Indeed, the left and side and right hand side are both multilinear in  $r'$ , so we need only confirm that they agree at all  $r'$  in the interpolating set  $\{0, 1\}^{\log T}$ . When  $r'$  is in this set, then  $\widetilde{\text{eq}}(r', j)$  equals 0 unless  $j = j'$ , in which case  $\widetilde{\text{eq}}(r', j) = 1$ . And for  $j = r'$ , it indeed holds that

$$\widetilde{\text{cRV}}(r') = \sum_{k=(k_1, \dots, k_d) \in (\{0, 1\}^{\log(K)/d})^d} \left( \prod_{i=1}^{d} \widetilde{\text{ra}}_i(k_i, j) \right) \cdot \widetilde{\text{cVal}}(k, j).$$

**Overview of the soundness analysis.** Informally, the soundness analysis proceeds via a three-step argument:

- The read-checking sum-check correctly grants query access to  $\widetilde{\text{cRV}}$  assuming  $\widetilde{\text{Val}} = \widetilde{\text{cVal}}$ .
- The write-checking sum-check makes sure that  $\widetilde{\text{Inc}} = \widetilde{\text{cInc}}$ , also assuming  $\widetilde{\text{Val}} = \widetilde{\text{cVal}}$ .
- The  $\widetilde{\text{Val}}$ -evaluation sum-check makes sure that  $\widetilde{\text{Val}} = \widetilde{\text{cVal}}$  assuming that  $\widetilde{\text{Inc}} = \widetilde{\text{cInc}}$ .

As written, the second and third bulletpoints introduce circular assumptions, so the soundness analysis cannot actually proceed in this manner. Fortunately, the assumption in the third bulletpoint is stronger than what is actually needed. In order for the  $\widetilde{\text{Val}}$ -evaluation sum-check to ensure that  $\widetilde{\text{Val}}(k, j) = \widetilde{\text{cVal}}(k, j)$  for a given  $k \in \{0, 1\}^{\log K}$  and  $j \in \{0, 1\}^{\log T}$ , one need only assume that  $\widetilde{\text{Inc}}(k, j') = \widetilde{\text{cInc}}(k, j')$  for all  $j'$  such that  $\widetilde{\text{LT}}(j', j) = 1$  (which we’ll henceforth denote by  $j' < j$  as shorthand). This means that we can avoid circular assumptions in our soundness analysis by focusing on the smallest such  $j$  for which  $\widetilde{\text{Val}}(k, j) \neq \widetilde{\text{cVal}}(k, j)$ .

**Formal soundness analysis.** First, suppose that  $\widetilde{\text{Inc}}$  and  $\widetilde{\text{cInc}}$  are not the same polynomial. Since they are both multilinear and  $\{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$  is an interpolating set for multilinear polynomials, this means there is at least one input  $(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$  such that  $\widetilde{\text{Inc}}(k, j) \neq \widetilde{\text{cInc}}(k, j)$ . Let  $(k^*, j^*)$  be one such input with the smallest possible value of  $j^*$ . That is, for all  $j' < j^*$  and all  $k \in \{0, 1\}^{\log K}$ , we assume that  $\widetilde{\text{Inc}}(k, j') = \widetilde{\text{cInc}}(k, j')$ . It follows then, by the definition of  $\widetilde{\text{Val}}$  (Equation (36)), that  $\widetilde{\text{Val}}(k^*, j^*) = \widetilde{\text{cVal}}(k^*, j^*)$ . But this means that

$$\widetilde{\text{cInc}}(k^*, j^*) = \left( \prod_{i=1}^{d} \widetilde{r\alpha}_i(k^*, j^*) \right) \left( \widetilde{wv}(j^*) - \widetilde{\text{cVal}}(k^*, j^*) \right) = \left( \prod_{i=1}^{d} \widetilde{r\alpha}_i(k^*, j^*) \right) \left( \widetilde{wv}(j^*) - \widetilde{\text{Val}}(k^*, j^*) \right),$$

where the first equality holds by Equation (37) and the final equality holds because  $\widetilde{\text{Val}}(k^*, j^*) = \widetilde{\text{cVal}}(k^*, j^*)$ . Since  $\widetilde{\text{Inc}}(k^*, j^*) \neq \widetilde{\text{cInc}}(k^*, j^*)$  by assumption, we conclude that

<span id="page-47-0"></span>
$$\widetilde{\text{Inc}}(k^*, j^*) \neq \left( \prod_{i=1}^{d} \widetilde{r\alpha}_i(k^*, j^*) \right) \left( \widetilde{wv}(j^*) - \widetilde{\text{Val}}(k^*, j^*) \right). \quad (40)$$

Let

$$h(k^*, j^*) = \sum_{k=(k_1, \dots, k_d) \in \{0, 1\}^{\log(K)/d}, j \in \{0, 1\}^{\log T}} \widetilde{eq}(k^*, k) \cdot \widetilde{eq}(j^*, j) \cdot \left( \prod_{i=1}^{d} \widetilde{w\alpha}_i(k_i, j) \right) \cdot \left( \widetilde{wv}(j) - \widetilde{\text{Val}}(k, j) \right).$$

It is easily seen that  $h(k^*, j^*)$  equals the right hand side of Expression (40), and hence  $\widetilde{\text{Inc}}(k^*, j^*) \neq h(k^*, j^*)$ . Since  $h$  and  $\widetilde{\text{Inc}}$  are both multilinear polynomials, and they are distinct, the Schwartz-Zippel lemma implies that with probability at least

$$1 - (\log(K) + \log(T))/|\mathbb{F}|,$$

 $\widetilde{\text{Inc}}(r, r') \neq h(r, r')$  when  $(r, r')$  is chosen at random from  $\mathbb{F}^{\log K} \times \mathbb{F}^{\log T}$ . By soundness of the sum-check protocol, in this event the write-checking sum-check verifier rejects with probability at least

$$1 - (d \log(T) + \log(K))/|\mathbb{F}|.$$

Thus, if the verifier accepts with probability more than  $((d+1)\log(T) + 2\log(K))/|\mathbb{F}|$ , then  $\widetilde{\text{Inc}} = \widetilde{\text{cInc}}$ . We assume henceforth that indeed  $\widetilde{\text{Inc}} = \widetilde{\text{cInc}}$ . Then by Equation (38) and soundness of the sum-check protocol as invoked, we conclude (up to an additional soundness error of  $2\log(T)/|\mathbb{F}|$ ) that for whatever evaluation point  $(r_{\text{address}}, r_{\text{cycle}})$  on which the  $\widetilde{\text{Val}}$ -evaluation sum-check is invoked, it holds that

$$\widetilde{\text{Val}}(r_{\text{address}}, r_{\text{cycle}}) = \widetilde{\text{cVal}}(r_{\text{address}}, r_{\text{cycle}}). \quad (41)$$

Absorbing  $2\log(T)/|\mathbb{F}|$  into the soundness error, we assume henceforth that  $\widetilde{\text{Val}}$  and  $\widetilde{\text{cVal}}$  agree at the point  $(r_{\text{address}}, r_{\text{cycle}})$  at which the  $\widetilde{\text{Val}}$ -evaluation sum-check is applied.

It follows by Equation (39) and soundness of the sum-check protocol, the verifier will reject during the read-checking sum-check with probability at least  $(d\log(T) + \log(K))/|\mathbb{F}|$ . This completes the soundness analysis.

The total soundness error according to the above analysis is at most  $((2d+3)\log(T) + 3\log(K))/|\mathbb{F}|$ .

Perfect completeness is an easy consequence of completeness of the sum-check protocol and Equations (37) and (38). Equation (37) ensures that the write-checking sum-check is perfectly complete and Equation (38) ensures that the  $\widetilde{\text{Val}}$ -evaluation sum-check is perfectly complete.

□

![](_page_47_Picture_162.jpeg)
