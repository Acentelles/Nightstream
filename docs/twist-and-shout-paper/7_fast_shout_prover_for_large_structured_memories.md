## 7 Fast Shout prover for large, structured memories

The sparse-dense sum-check protocol from (Generalized-)Lasso [STW24, Appendix G] is the key tool allowing the Shout prover to efficiently prove  $T$  lookups into (structured) memories of size vastly larger than  $T$ .

<span id="page-56-0"></span>

## 7.1 Sparse-dense sum-check protocol

### 7.1.1 Informal Overview

Consider two very large vectors  $a, b \in \mathbb{F}^N$  and suppose we want to compute their inner product

<span id="page-56-4"></span>
$$\langle a, b \rangle = \sum_{i=1}^{N} a_i \cdot b_i. \quad (59)$$

Say we want to outsource this work to an untrusted prover using the sum-check protocol. A standard application would apply the sum-check protocol to the polynomial  $\tilde{a} \cdot \tilde{b}$  where  $\tilde{a}$  and  $\tilde{b}$  are the multilinear extensions of  $a$  and  $b$  respectively. Note that  $\tilde{a} \cdot \tilde{b}$  is a polynomial in  $\log N$  variables with degree two in each variable. The standard linear-time prover implementation of the sum-check protocol in this context (Section 3.3) would require about  $4N$  field operations. However, the prover can be implemented far faster if  $a$  and  $b$  are structured in certain ways. [STW24, Appendix G] refers to such a fast prover implementation as the *sparse-dense sum-check protocol*.<sup>31</sup>

Suppose we use two (not necessarily multilinear) extensions  $\hat{a}$  and  $\hat{b}$  of  $a$  and  $b$ . At the end of round 1, when the first variable gets bound to  $r_1 \in \mathbb{F}$ , both  $\hat{a}$  and  $\hat{b}$  become  $(\log(N) - 1)$ -variate polynomials  $\hat{a}(r_1, x_2, \dots, x_{\log N})$  and  $\hat{b}(r_1, x_2, \dots, x_{\log N})$ . The sparse-dense sum-check protocol asks: how do these “new” polynomials relate to the “old” polynomials  $\hat{a}(x_1, \dots, x_{\log N})$  and  $\hat{b}(x_1, \dots, x_{\log N})$ ? In particular, is the relationship between  $\hat{a}(x_1, \dots, x_{\log N})$  and  $\hat{a}(r_1, x_2, \dots, x_{\log N})$  largely independent of  $x_2, \dots, x_{\log N}$ , and similarly for  $\hat{b}(x_1, \dots, x_{\log N})$  and  $\hat{b}(r_1, x_2, \dots, x_{\log N})$ ? If so, then major optimizations are possible.

Let  $r_i$  denote the random field element chosen by the sum-check verifier in round  $i$ . Suppose that we can chunk the entries of  $a$  and  $b$  into two groups,  $H(0)$  and  $H(1)$ , such that when variable one gets bound to  $r_1$ , each evaluation  $\hat{a}(i)$  for  $i \in H(0)$  gets multiplied by the same value (say  $m_{0,r_1}$ ) and similarly each term  $a_i$  of  $a$  in  $H(1)$  gets multiplied by  $m_{1,r_1}$ . Suppose further that each term  $b_i$  of  $b$  in  $H(0)$  (respectively,  $H(1)$ ) gets multiplied by the same value, say  $v_{0,r_1}$  and  $v_{1,r_1}$ .

**Illustrative example.** A key example to have in mind is

$$\hat{b}(x) = \tilde{\text{eq}}(r', x),$$

for some random vector  $r' \in \mathbb{F}^{\log N}$ . Then for any  $x = (k, y)$  with  $k \in \{0, 1\}$  and  $y \in \{0, 1\}^{\log(N)-1}$ ,

$$\hat{b}(r_1, y) / \hat{b}(k, y) = \tilde{\text{eq}}(r'_1, r_1) / \tilde{\text{eq}}(r'_1, k).$$

In other words, changing the first coordinate fed to  $\hat{b}$  from  $k$  to  $r_1$  results in a multiplicative update that depends only on  $k$ ,  $r_1$ , and  $r'_1$ .

Hence, letting  $H_0$  and  $H_1$  denote points in  $\{0, 1\}^{\log(N)}$  of the form  $(0, y)$  and  $(1, y)$  respectively,  $\hat{b}$  satisfies the informal condition above if we define

<span id="page-56-2"></span>
$$v_{0,r_1} = \tilde{\text{eq}}(r'_1, r_1) / (1 - r'_1) \quad (60)$$

and

<span id="page-56-3"></span>
$$v_{1,r_1} = \tilde{\text{eq}}(r'_1, r_1) / r'_1. \quad (61)$$

Meanwhile, if  $\hat{a}$  is multilinear (i.e.,  $\hat{a} = \tilde{a}$ ) then by Fact 3.1,

<span id="page-56-5"></span>
$$\hat{a}(r_1, y) = (1 - r_1)\hat{a}(0, y) + r_1\hat{a}(1, y). \quad (62)$$

So in this example, we have the following expression for the prescribed prover’s message in round two of sum-check, where  $r_1$  is the random challenge in round 1:

<span id="page-56-1"></span>

<sup>31</sup>To clarify, the term “sparse-dense sum-check protocol” used in [STW24, Appendix G] refers to a fast *prover implementation*. The protocol itself (i.e., the checks the verifier does on the prover’s messages) is no different than in the standard sum-check protocol.

$$\begin{aligned}s_1(r_1) &= \sum_{y \in \{0,1\}^{\log(N)-1}} \tilde{a}(r_1, y) \cdot \hat{b}(r_1, y) \\&= \left( \sum_{(0,y) : y \in \{0,1\}^{\log(N)-1}} (1-r_1)\hat{a}(0, y) \cdot \hat{b}(r_1, y) \right) + \left( \sum_{(1,y) : y \in \{0,1\}^{\log(N)-1}} r_1\hat{a}(1, y) \cdot \hat{b}(r_1, y) \right) \\&= \left( \sum_{i \in H(0)} a_i \cdot b_i \cdot (1-r_1) \cdot v_{0,r_1} \right) + \left( \sum_{i \in H(1)} (1-r_1) \cdot a_i \cdot b_i \cdot r_1 \cdot v_{1,r_1} \right),\end{aligned}$$

where  $v_{0,r_1}$  and  $v_{1,r_1}$  are defined in Equations (60) and (61).

This means that in moving from the sum defining the prover's claim at the start of round 1 (Expression (59)) to the sum defining the prover's claim at the start of round 2, every term  $a_i b_i$  for an  $i \in H(0)$  gets multiplied by the same factor, namely  $(1-r_1) \cdot v_{0,r_1}$ , and similarly for every term for an  $i \in H(1)$ . Rather than performing this multiplication for each term individually, it is much faster to first *aggregate* (i.e., sum up) all the terms  $a_i \cdot b_i$  in  $H(0)$  and  $H(1)$  respectively, and just multiply each aggregated value by the relevant factor. This costs only two multiplications *in total across all terms*, rather than one for each of the  $N$  terms.

This is the key idea in the sparse-dense sum-check protocol from [STW24, Appendix G]. In round  $i$ , there are  $2^i$  relevant groups (one group for each  $k \in \{0,1\}^i$ , with the  $k$ th group capturing all terms whose binary representations begin with  $k$ ). At the end of round  $i$ , when variable  $i$  gets round to  $r_i \in \mathbb{F}$ , each term within a group gets multiplied by the same value.

If  $N$  is considered too large for linear-in- $N$  prover time to be acceptable, say, because only  $T \ll N$  terms  $a_i \cdot b_i$  are non-zero, then the sparse-dense sum-check protocol is capable of running in time  $O(CT)$  where  $C$  is any integer such that  $N \le T^C$ .

The sparse-dense sum-check protocol also applies when binding the  $j$ th variable to  $r_i$  causes each  $\hat{b}$ 's value to change by an additive rather than multiplicative factor that depends only on  $r_j$ . This is explained in detail in [STW24, Appendix G]. The canonical example to have in mind here is

$$\hat{b}(x) = \sum_{i=1}^{\log N} 2^{i-1} x_i,$$

which arises when applying Generalized-Lasso or Shout to a “range-check” table storing all field elements in  $\{0, 1, \dots, N-1\}$ . In this case, changing  $x_i$  from  $c$  to  $r_i$  increases  $\hat{b}(x)$  by an additive factor of  $2^{i-1}(r_i - c)$ .

## 7.2 Extension to the Booleanity-checking sum-check when $K^{1/d} \gg T$

**Overview.** Recall that in the Booleanity-checking sum-check (Line 3 of Figure 8), the sum-check protocol is applied to compute

$$\sum_{k \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}\tilde{q}(r, k)\tilde{\mathbf{e}}\tilde{q}(r', j) \left( \tilde{\mathbf{r}}\tilde{a}_i(k, j)^2 - \tilde{\mathbf{r}}\tilde{a}_i(k, j) \right).$$

Let us first focus on the “sub-sum”

$$\sum_{k \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}\tilde{q}(r, k)\tilde{\mathbf{e}}\tilde{q}(r', j)\tilde{\mathbf{r}}\tilde{a}_i(k, j)^2,$$

as this is the heart of the protocol.

Let

$$\hat{a}(k, j) = \tilde{\mathbf{r}}\tilde{a}_i(k, j)^2$$

and

$$\hat{b}(k, j) = \tilde{\mathbf{eq}}(r, k) \tilde{\mathbf{eq}}(r', j).$$

The treatment of the sparse-dense sum-check protocol in [STW24, Appendix G] assumes  $\hat{a}$  is multilinear, i.e.,  $\hat{a} = \tilde{a}$ . This is not the case here, as  $\hat{a}$  is the square of a multilinear polynomial.

Fortunately,  $\tilde{r}\tilde{a}_i(k, j)$  satisfies an “ultrastructured” sparseness property: for each  $j \in \{0, 1\}^{\log T}$ , there is at most (in fact, exactly) one  $k \in \{0, 1\}^{\log(K)/d}$  such that  $\tilde{r}\tilde{a}_i(k, j) \neq 0$ . Exploiting this property ensures that the sparse-dense sum-check protocol still applies to the Booleanity-checking sum-check. At a high level, what’s going on is the following.

The treatment in [STW24, Appendix G] exploited that when  $\hat{a}(k, j)$  is multilinear, Equation (62) holds, which roughly states that binding the first variable of  $\hat{a}$  to  $r_1$  causes the resulting evaluations of  $\hat{a}(r_1, y)$  to be a linear combination of  $\hat{a}(0, y)$  and  $\hat{a}(1, y)$ . When  $\hat{a}(k, j) = \tilde{r}\tilde{a}_i(k, j)^2$ , Equation (62) does not hold, but something just as nice does: if  $k$  is the unique value in  $\{0, 1\}^{\log(K)/d}$  with  $\tilde{r}\tilde{a}_i(k, j) \neq 0$ , then assuming wlog that the first entry of  $k$  is 0, and letting  $y$  denote the remaining  $\log(K)/d + \log(T) - 1$  entries of  $(k, j)$ , it holds that:

$$\tilde{r}\tilde{a}_i^2(r_1, y) = ((1 - r_1)\tilde{r}\tilde{a}_i(0, y) + r_1\tilde{r}\tilde{a}_i(1, y))^2 = (1 - r_1)^2\tilde{r}\tilde{a}_i(0, y)^2 = (1 - r_1)^2\hat{a}(0, y).$$

In other words, binding variable one to  $r_1$  causes  $\hat{a}(k, j)$  to get multiplied by a factor  $(1 - r_1)^2$  that only depends on the first coordinate of  $k$  and on  $r_1$ .

**Algorithm details.** As in the overview above, let

$$\hat{a}(k, j) = \tilde{r}\tilde{a}_i(k, j)^2$$

and

$$\hat{b}(k, j) = \tilde{\mathbf{eq}}(r, k) \tilde{\mathbf{eq}}(r', j)$$

and suppose we apply the sum-check protocol to compute

<span id="page-58-0"></span>
$$\sum_{k \in \{0, 1\}^{\log(K)/d}, j \in \{0, 1\}^{\log T}} \hat{a}(k, j) \cdot \hat{b}(k, j). \quad (63)$$

Let  $c \ge 1$  be a positive integer such that  $cK^{1/(cd)} = o(T)$ . For simplicity, assume  $\log(K)/d$  is divisible by  $c$ . We will break each  $k \in \{0, 1\}^{\log(K)/d}$  into  $c$  chunks each of size  $\log(K)/(cd)$ , writing

$$k = (k_1, \dots, k_c) \in \left(\{0, 1\}^{\log(K)/(dc)}\right)^c.$$

Similarly, write

$$r = (r_1, \dots, r_c) \in \left(\mathbb{F}^{\log(K)/(dc)}\right)^c.$$

**Evaluating all  $\hat{b}(k, j)$  values.** The first thing the prover needs to do is compute  $\hat{b}(k, j)$  for all  $(k, j) \in \{0, 1\}^{\log(K)/d} \times \{0, 1\}^{\log T}$  such that  $\hat{a}(k, j) \neq 0$ . In Booleanity-checking where  $\hat{b}(k, j) = \tilde{\mathbf{eq}}(k, r) \cdot \tilde{\mathbf{eq}}(j, r')$ , this can be done with

$$(c + 1) \cdot K^{1/(cd)} + T$$

field multiplications as follows. First, the prover computes  $c + 1$  tables, each of size  $K^{1/(dc)}$ , storing for each  $\ell \in \{1, \dots, c\}$ , the values  $\tilde{\mathbf{eq}}(r_\ell, x)$  as  $x$  ranges over  $\{0, 1\}^{\log(K)/(cd)}$ , as well as a table storing  $\tilde{\mathbf{eq}}(r', x)$  as  $x$  ranges over the same domain  $\{0, 1\}^{\log T}$ . This requires  $c \cdot K^{1/(dc)} + T$  multiplications in total (by Lemma 1). Given these tables, for any desired  $(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ ,  $\hat{b}(k, j)$  can be evaluated with one lookup into each of the  $c + 1$  tables followed by  $c$  multiplications.

**Building a partial sum tree.** Before the start of the protocol, the prover builds a “tree of partial sums”. Specifically, for each  $k_1 \in \{0, 1\}^{\log(K)/(cd)}$ , let

$$L(k_1) = \sum_{k=(k_1, k') \in \{0, 1\}^{\log(K)/(cd)} \times \{0, 1\}^{\log(K)/d - \log(K)/(cd)}, j \in \{0, 1\}^{\log T}} \hat{a}(k, j) \cdot \hat{b}(k, j).$$

The prover builds a binary tree over these leaf values, with each interior node storing the sum of its children. Note that the tree has  $2^{\log(K)/(cd)} = K^{1/(cd)} = o(T)$  leaves. This step requires  $(c+1)T$  field multiplications in total, because there are  $T$  non-zero entries of  $\hat{a}(k, j)$  and for each such entry,  $\hat{b}(k, j)$  can be computed with  $c$  multiplications and then multiplied by  $\hat{a}(k, j)$  with a single additional multiplication.

Let us index the internal nodes at distance  $i$  from the root by  $\{0, 1\}^i$  (we will label the root by  $\emptyset$ ). This ensures that the root of the tree,  $L(\emptyset)$  computes the entire sum in Expression (63).

**Round one message.** The round-1 message of the prover can computed via a constant number of field operations (and inversions) given the values stored at the two children of the root. Indeed,

$$s_1(0) = \sum_{k=(0, k') \in \{0, 1\} \times \{0, 1\}^{\log(K)/d - 1}, j \in \{0, 1\}^{\log T}} \hat{a}(k, j) \cdot \hat{b}(k, j),$$

and this quantity is equal to  $L(0)$  (the left child of the root). Similarly,  $s_1(2)$  is a constant-time-computable linear combination of  $L(0)$  and  $L(1)$ :

$$s_1(2) = (\tilde{\mathbf{eq}}(2, 0)^2 \cdot \tilde{\mathbf{eq}}(2, r_1) \cdot (1 - r_1)^{-1}) \cdot L(0) + (\tilde{\mathbf{eq}}(2, 1)^2 \tilde{\mathbf{eq}}(2, r_1) \cdot r_1^{-1}) \cdot L(1).$$

This equality holds by the following reasoning. For each  $k = (0, k')$  and each  $j \in \{0, 1\}^{\log T}$  satisfying  $\tilde{r}\tilde{a}_i(k, j) \neq 0$ , it holds that  $\tilde{r}\tilde{a}_i(k, j) = 1$  and  $\tilde{r}\tilde{a}_i(2, k', j) = \tilde{\mathbf{eq}}(2, 0)^2$ . Meanwhile,

$$\hat{b}(2, k', j) = \tilde{\mathbf{eq}}((2, k'), r) \cdot \tilde{\mathbf{eq}}(r', j) = \tilde{\mathbf{eq}}(2, r_1) \cdot (1 - r_1)^{-1} \cdot \hat{b}(k, j).$$

Similarly, for each  $k = (1, k')$  and each  $j \in \{0, 1\}^{\log T}$  satisfying  $\tilde{r}\tilde{a}_i(k, j) \neq 0$ , it holds that  $\tilde{r}\tilde{a}_i(k, j) = 1$  and  $\tilde{r}\tilde{a}_i(2, k', j) = \tilde{\mathbf{eq}}(2, 1)^2$ , and

$$\hat{b}(2, k', j) = \tilde{\mathbf{eq}}(2, k', r) \cdot \tilde{\mathbf{eq}}(r', j) = \tilde{\mathbf{eq}}(2, r_1) \cdot r_1^{-1} \cdot \hat{b}(k, j).$$

(Even though each round’s sum-check prover message  $s_i$  is a degree-3 univariate polynomial, Gruen [Gru24, Section 3] shows how a slight modification of the protocol allows the prover to only send  $s_i(0)$  and  $s_i(2)$  in each round, see Section 3.6.1).

**Round two message.** At the end of round 1, the verifier sends the random value  $r_1$ . Similar to round 1, the prover’s round-2 message is a quickly-computable linear combination of the four values stored at level two of the tree (grandchildren of the root). Indeed,

$$s_2(0) = \sum_{k' \in \{0, 1\}^{\log(K)/d - 2}, j \in \{0, 1\}^{\log T}} \hat{a}(r_1, 0, k', j) \cdot \hat{b}(r_1, 0, k', j).$$

Recall that for each  $j \in \{0, 1\}^{\log T}$ , the prover can quickly ascertain the unique  $k'' \in \{0, 1\}^{\log(T)-1}$  for which  $\hat{a}(r_1, k'', j) \neq 0$ , and quickly compute the factor  $m_{k_1'}$  (which depends only on  $r_1$  and  $k_1'$ ) such that

$$\hat{a}(r_1, k'', j) = m \cdot \hat{a}(k', j),$$

where  $k' \in \{0, 1\}^{\log K}$  is the unique vector such that  $\hat{a}(k', j) \neq 0$ . Similarly, we have assumed that the prover can quickly compute the factors  $v_0, v_1$  (which depend on only  $r_1$ ) such that  $\hat{b}(r_1, 0, k', j) = v_0 \cdot \hat{b}(0, 0, k', j)$  and  $\hat{b}(r_1, 0, k', j) = v_1 \cdot \hat{b}(0, 1, k', j)$ . Hence,

$$s_2(0) = m_0 v_0 L(0, 0) + m_0 v_1 L(0, 1).$$

Similarly,  $s_2(2)$  is a quickly-computable linear combination of the four nodes at distance two from the root:  $L(0, 0)$ ,  $L(0, 1)$ ,  $L(1, 0)$ ,  $L(1, 1)$ :

$$s_2(2) = c_{0,0} \cdot L(0, 0) + c_{0,1} L(0, 1) + c_{1,0} L(1, 0) + c_{1,1} L(1, 1),$$

where for each  $k_1, k_2 \in \{0, 1\}$ ,

$$c_{k_1, k_2} = m_{k_1, k_2} v_{k_1, k_2},$$

where

$$m_{k_1, k_2} = \tilde{\mathbf{eq}}(r_1, k_1)^2 \cdot \tilde{\mathbf{eq}}(2, k_2)^2$$

and

$$v_{k_1, k_2} = \tilde{\mathbf{eq}}(k_1, r_1)^{-1} \cdot \tilde{\mathbf{eq}}(r_1, r_1) \cdot \tilde{\mathbf{eq}}(2, r_2) \cdot \tilde{\mathbf{eq}}(k_2, r_2)^{-1}.$$

**Round  $i \le \log(K)/(cd)$ .** In general,  $s_i(0)$  and  $s_i(2)$  are each quickly-computable linear combinations of the nodes at distance  $i$  from the root. For example, when  $\hat{a} = \tilde{\mathbf{ra}}_i^2$  and  $\hat{b}(k, j) = \tilde{\mathbf{eq}}(r, k) \cdot \tilde{\mathbf{eq}}(r', j)$ , then:

$$s_2(2) = \sum_{k \in \{0, 1\}^i} c_k \cdot L(k),$$

where  $c_k = m_k \cdot v_k$ , defined as follows:

$$m_k = \tilde{\mathbf{eq}}(r_1, \dots, r_{i-1}, 2, k)^2$$

and

$$v_k = \tilde{\mathbf{eq}}(k, (r_1, \dots, r_i))^{-1} \cdot \tilde{\mathbf{eq}}(r_1, \dots, r_i, r_1, \dots, r_i).$$

Each round  $i \le \log(K)/(cd)$  can be implemented in roughly  $O(2^i)$  field operations.<sup>32</sup>

**Tree-recomputation procedure.** The prover performs a tree-recomputation procedure at the end of round  $\log(K)/(cd)$ . Specifically, the prover computes, for every  $j \in \{0, 1\}^{\log T}$ , the unique  $k = (k_2, \dots, k_c) \in \{0, 1\}^{(c-1) \cdot \log(K)/(cd)}$  such that  $\hat{a}(r_1, \dots, r_{\log(K)/c}, k, j) \neq 0$ , and moreover for this  $k$ , the prover can compute both  $\hat{a}(r_1, \dots, r_{\log(K)/c}, k, j)$  and  $\hat{b}(r_1, \dots, r_{\log(K)/c}, k, j)$ .

Indeed, by Lemma 1, with  $K^{1/(cd)}$  multiplications the prover can compute  $\tilde{\mathbf{eq}}(r_1, \dots, r_{\log(K)/(cd)}, k')$  for all  $k' \in \{0, 1\}^{\log(K)/(cd)}$ . Since  $\hat{a} = \tilde{\mathbf{ra}}_i^2$ , each quantity  $\hat{a}(r_1, \dots, r_{\log(K)/(cd)}, k, j)$  can be identified with a single lookup into this table followed by a squaring operation. Similarly, for each non-zero  $\hat{a}(r_1, \dots, r_{\log(K)/(cd)}, k, j)$ , the value  $\hat{b}(r_1, \dots, r_{\log(K)/(cd)}, k, j)$  can also be computed with one multiplication given partial products computed and stored during the course of the procedure computing  $\hat{b}(k, j)$  for all relevant values of  $(k, j)$  while building the partial sum tree prior to the start of round 1. This is  $2T + K^{1/(cd)}$  field multiplications in total.

<span id="page-60-0"></span>

<sup>32</sup>More precisely, by using a batch-inversion procedure, it's possible to implement round  $i$  in with  $O(2^i)$  field multiplications and one inversion.

Given these quantities, the prover can construct, with  $T$  more multiplications, a new partial-sum tree with  $T$  leaves, such that leaf  $k'$  stores

$$\sum_{k=(k_1,k',k_3,\dots,k_c) \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \hat{a}(r_1, \dots, r_{\log(K)/c}, k', k_2, \dots, k_c) \cdot \hat{b}(r_1, \dots, r_{\log(K)/(cd)}, k', k_2, \dots, k_c).$$

The next  $\log(K)/(cd)$  rounds proceed analogously to the first  $\log(K)/(cd)$  rounds, followed by another tree-recomputation step, and so on until the first  $\log(K)/d$  rounds are complete.

The final  $\log T$  rounds can then be implemented exactly as in the case of small memory sizes (Section 6.3). The total cost for these final  $\log T$  rounds is  $5dT$  field operations (Section 6.3 implemented those rounds with only  $3dT$  multiplications, but  $2dT$  multiplications were saved there by exploiting that  $K^{1/d} = o(T)$ , which does not hold here if  $c > 1$ ).

**The full Booleanity-checking sum-check.** Recall that the Booleanity-checking sum-check actually applies the sum-check protocol to compute

$$\sum_{k \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r, k) \tilde{\mathbf{e}}\mathbf{q}(r', j) (\tilde{\mathbf{r}}\tilde{\mathbf{a}}_i(k, j)^2 - \tilde{\mathbf{r}}\tilde{\mathbf{a}}_i(k, j)).$$

We have explained above how to apply the sum-check protocol to compute

<span id="page-61-0"></span>
$$\sum_{k \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r, k) \tilde{\mathbf{e}}\mathbf{q}(r', j) \tilde{\mathbf{r}}\tilde{\mathbf{a}}_i(k, j)^2. \quad (64)$$

It suffices to now explain how to apply the sum-check prover to compute

<span id="page-61-1"></span>
$$\sum_{k \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}\mathbf{q}(r, k) \tilde{\mathbf{e}}\mathbf{q}(r', j) \tilde{\mathbf{r}}\tilde{\mathbf{a}}_i(k, j), \quad (65)$$

since in the Booleanity-checking sum-check the prover's message in each round is just the difference between the corresponding message for Expressions (64) and (65).

Walking through the algorithm described above for proving Expression (64) and modifying it appropriately for Expression (65), it is easy to see that the sum-check prover for Expression (65) only needs to do  $O(cK^{1/(cd)})$  additional field multiplications on top of what the prover for Expression (65) does. In other words, “handling” Expression (65) in addition to Expression (64) does not substantially change the prover cost.

**Cost summary for Booleanity-checking when  $K^{1/d} \gg T$ .** In total, across all  $i = 1, \dots, d$ , the Booleanity-checking prover performs the following field multiplications:

- $c \cdot K^{1/(cd)} + T$  multiplications in pre-computation to evaluate  $\tilde{\mathbf{e}}\mathbf{q}$  polynomials at appropriate points.
- $d(c+1)T$  more multiplications to build the  $d$  partial-sum trees prior to round one.
- $O(dK^{1/(cd)})$  to compute the first  $\log(K)/(dc)$  rounds worth of messages given these trees.
- $3dT + O(dK^{1/(cd)})$  field multiplications every time the partial-sum tree is rebuilt and the next  $\log(K)/(cd)$  rounds of messages are computed.
- $5dT$  field multiplications in the final  $\log(T)$  rounds.

Since the partial sum tree for each  $i = 1, \dots, d$  is rebuilt  $c-1$  times, this means the prover performs

$$O(dcK^{1/(dc)}) + (d(c+1) + 3d(c-1) + 5d + 1)T = O(dcK^{1/(dc)}) + (4dc + 3d + 1)T$$

field multiplications in total.

For example, if  $c = 2$  and  $d = 2$ , this is  $O(K^{1/4}) + 23T$  field multiplications. This is an appropriate setting of parameters when  $K = 2^{64}$  as arises in Jolt (see Application 4 in Section 2.8), as in this case  $K^{1/4} = 2^{16}$ , which is substantially less than typical values of  $T$ .

### 7.3 Shout's read-checking sum-check

Recall that the read-checking sum-check within Shout (Line 3 in Figure 7) applies the sum-check protocol to confirm that  $\tilde{r}(r_{\text{cycle}})$  equals:

$$\sum_{k=(k_1, \dots, k_d) \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\text{eq}}(r_{\text{cycle}}, j) \left( \prod_{i=1}^{d} \tilde{r}_{a_i}(k_i, j) \right) \cdot \tilde{\text{Val}}(k). \quad (66)$$

[STW24, Appendix G] showed that the  $\tilde{\text{Val}}$  polynomials corresponding to the lookup tables arising in the Jolt RISC-V zkVM satisfy the conditions necessary to apply the sparse-dense sum-check protocol to compute

$$\sum_{k \in \{0,1\}^{\log K}} \hat{a}(k) \cdot \tilde{\text{Val}}(k) \quad (67)$$

for any sparse, multilinear polynomial  $\hat{a}$ . It extends trivially to also handle the case that  $\hat{a}$  takes an additional  $\log T$  variables and the sum is over  $K T$  terms rather than  $K$ , i.e.,

<span id="page-62-0"></span>
$$\sum_{(k,j) \in \{0,1\}^{\log K} \times \{0,1\}^{\log T}} \hat{a}(k, j) \cdot \tilde{\text{Val}}(k). \quad (68)$$

To implement the read-checking sum-check prover quickly, we would like to apply the sparse-dense sum-check protocol to compute

$$\sum_{(k,j) \in \{0,1\}^{\log K} \times \{0,1\}^{\log T}, k=(k_1, \dots, k_d) \in \{0,1\}^{\log(K)/d}} \hat{a}(k, j) \cdot \hat{b}(k, j),$$

with  $\hat{a}(k, j) = \tilde{\text{eq}}(r_{\text{cycle}}, j) \cdot \prod_{i=1}^{d} \tilde{r}_{a_i}(k_i, j)$  and  $\hat{b}(k, j) = \tilde{\text{Val}}(k)$ . However, this does not *quite* map into the formulation of Expression (68), because  $\left( \prod_{i=1}^{d} \tilde{r}_{a_i}(k_i, j) \right)$  does not have degree one in each variable of  $j$  (though it *does* have degree one in each variable of  $k_1, \dots, k_d$ ). Fortunately, this issue is not substantive. Since  $\left( \prod_{i=1}^{d} \tilde{r}_{a_i}(k_i, j) \right)$  is multilinear with respect to the variables of  $k_1, \dots, k_d$ , we can still apply the sparse-dense sum-check protocol for the first  $\log K$  rounds of the read-checking sum-check, and then “switch over” to the standard linear-time prover algorithm (Section 3.3) for the final  $\log T$  rounds. If  $C$  is an integer such that  $K^{1/C} = o(T)$ , then the resulting total prover cost for the first  $\log K$  rounds is, up to low-order terms,  $2CT$  field multiplications.

The final  $\log T$  rounds of Shout proceed identically to the case of small memories (Section 6.2), requiring  $d^2 T$  multiplications up to low-order terms.

**Remark 2.** [STW24, Appendix G] also describes two prover algorithms that are simpler but slower than the one that uses just  $2dCT$  field multiplications to implement the first  $\log K$  rounds above. These simpler algorithms replace  $2dc$  with an  $O(\log^2 K)$  and  $O(\log K)$  factor respectively. Even these simpler algorithms may be fast enough for Shout to improve on Lasso as applied in Jolt.

### 7.4 The $\tilde{\text{raf}}$ -evaluation sum-check and Hamming-weight-one check when $K \gg T$

As pointed out in Section 6.3, the  $\tilde{\text{raf}}$ -evaluation sum-check of Figure 8 is identical to the read-checking sum-check in the core Shout PIOP, just with  $\tilde{\text{Val}}(k)$  replaced with

$$\sum_{i=1}^{d} \sum_{\ell=0}^{\log(K)/d-1} 2^{i \cdot \log(K)/d + \ell} \cdot k_{i,\ell},$$

which is the MLE of the function that maps  $k$  to  $\text{int}(k)$ . In other words, the  $\tilde{\text{raf}}$ -evaluation sum-check is equivalent to checking reads into the table whose  $k$ 'th entry is  $f(k)$ . As further observed in Section 6.3, in

applications the prover can set  $r_{\text{cycle}}$  in the core **Shout** PIOP equal to  $r'_{\text{cycle}}$  (the random point at which the verifier wishes to evaluate  $\tilde{\text{raf}}$  via the  $\tilde{\text{raf}}$ -evaluation sum-check). Then running the  $\tilde{\text{raf}}$ -evaluation sum-check and the read-checking sum-check in a batched manner per Section 4.2.1 is equivalent to replacing the lookup table  $\tilde{\text{Val}}(k)$  with  $\tilde{\text{Val}}(k) + z \cdot \tilde{\text{int}}(k)$ . The first  $\log K$  rounds of the batched sum-check can be implemented by separately applying the read-checking sum-check to the two tables with MLEs given by  $\tilde{\text{Val}}$  and  $\tilde{\text{int}}$ , with the latter costing  $cT + o(T)$  multiplications for the prover. The final  $\log T$  rounds of the batched protocol are no more expensive than the read-checking sum-check alone, as the value  $\tilde{\text{Val}}(r''')$  in the read-checking sum-check (where  $r'''$  is the verifier's random challenges chosen over the course of the first  $\log K$  rounds) is simply replaced in the batched sum-check with  $\tilde{\text{Val}}(r''') + z \cdot \tilde{\text{int}}(r''')$ .

**Hamming weight one check.** Checking that each committed address has Hamming weight one (Line 4 of Figure 8) can be directly implemented with  $O(dK^{1/d})$  field multiplications after the prover computes an array storing  $\tilde{\text{eq}}(j, r''_{\text{cycle}})$  for all  $j \in \{0, 1\}^{\log T}$  (which, for appropriate choice of  $r''_{\text{cycle}}$ , will have already been computed elsewhere within **Shout**). If  $c > 1$  so  $O(dK^{1/d})$  time is not acceptable, the original sparse-dense sum-check protocol applies with  $\hat{a}(k) = \tilde{\text{ra}}_i(k, r''_{\text{cycle}})$  and  $\hat{b} = 1$  and achieves cost  $cT + O(CK^{1/C})$  field multiplications, where  $C = cd$ .

## 7.5 Cost summary for **Shout** when $K \gg T$

In summary, for gigantic structured memories where  $K^{1/C} = o(T)$ , the **Shout** prover incurs the following costs up to low-order terms:

- $2T$  multiplications for evaluating  $\tilde{\text{rv}}(r_{\text{cycle}})$  before applying the read-checking sum-check.
- $(2C + d^2)T$  multiplications for the read-checking sum-check.
- $(4C + 3d)T$  for Booleanity checking.<sup>33</sup>
- $CT$  for the  $\tilde{\text{raf}}$ -evaluation sum-check.
- $cT$  for the Hamming-weight-one-checking sum-check if  $c > 1$ .

In total, this is at most  $(7C + d^2 + 3d + c + 2)T$  multiplications.
