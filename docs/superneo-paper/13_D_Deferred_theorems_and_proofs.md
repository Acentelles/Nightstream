## D Deferred theorems and proofs

### D.1 Proof of Matrix-Vector Product Transformation (Theorem 4)

*Proof.* Let  $M_1, \dots, M_m \in \mathbb{F}^{n_F}$  be the rows of  $M$ . Define  $z_1, \dots, z_{n_R} \in \mathbb{F}^d$  and  $M_{i,1}, \dots, M_{i,n_R} \in \mathbb{F}^d$  (for all  $i \in [m]$ ) to be the partition of vector  $z$  and row  $M_i$  into  $d$ -sized sub-vectors, respectively. We must have that for all  $i \in [m]$ ,

$$\text{ct}((\vec{M}_i, z)) = \sum_{j \in [n_R]} \text{ct}(\vec{M}_{i,j} \cdot z_j) = \sum_{j \in [n_R]} \langle M_{i,j}, z_j \rangle = \langle M_i, z \rangle$$

The first equality is true because, by definition of inner product,  $\langle \vec{M}_i, z \rangle = \sum_{j \in [n_R]} \vec{M}_{i,j} \cdot z_j$  and the constant term of a sum of polynomials is equal to the sum of the constant terms of the polynomials. The second equality follows from Theorem 3. The third inequality follows from  $(M_{i,j})_j$  and  $(z_j)_j$  being partitions of  $M_i$  and  $z$ , respectively. Since, for all  $i \in [m]$  (i.e. for each row), we have  $\text{ct}((\vec{M}_i, z)) = \langle M_i, z \rangle$ , we must have that  $Mz = \text{ct}(\vec{M}z)$ .  $\square$

### D.2 Proof of Evaluation Homomorphism (Theorem 5)

*Proof.* First, we will prove that  $c = \mathcal{L}(z)$ . Since  $\mathcal{L}$  is a  $\mathbb{R}_F$ -module homomorphism, the following holds

$$c = \sum_{i \in [\ell]} \rho_i c_i = \sum_{i \in [\ell]} \rho_i \mathcal{L}(z_i) = \mathcal{L} \left( \sum_{i \in [\ell]} \rho_i z_i \right) = \mathcal{L}(z).$$

Now, we will prove that  $y = \widetilde{\mathbf{M}z}(r)$ . Since multilinear evaluation  $\mathbf{z} \mapsto \widetilde{\mathbf{M}z}(r) = \langle \widetilde{\mathbf{M}z}, \hat{r} \rangle$  is a linear map over  $\mathbb{R}_K$  (i.e. is a  $\mathbb{R}_K$ -module homomorphism), the following holds

$$y = \sum_{i \in [\ell]} \rho_i y_i = \sum_{i \in [\ell]} \rho_i \cdot \widetilde{\mathbf{M}z_i}(r) = \widetilde{\mathbf{M}} \cdot \left( \sum_{i \in [\ell]} \rho_i \cdot z_i \right)(r) = \widetilde{\mathbf{M}z}(r)$$

Finally, by Remark 2, we have that for all  $i \in [\ell]$ ,  $\text{ct}(y_i) = \widetilde{\mathbf{M}z_i}(r)$  and  $\text{ct}(y) = \widetilde{\mathbf{M}z}(r)$ . This concludes our proof.  $\square$

### D.3 Proof of Composition Theorem (Theorem 6)

*Proof.* Consider an arbitrary expected polynomial-time adversary  $(\mathcal{A}, \mathcal{P}^*)$  for the composition  $\Pi := \Pi_2 \circ \Pi_1$  with success probability  $\epsilon(\mathcal{A}, \mathcal{P}^*) \ge 1/\text{poly}(\lambda)$ . Without loss of generality, the adversary  $\mathcal{P}^*$  can be split into two adversaries  $(\mathcal{P}_1^*, \mathcal{P}_2^*)$  such that given  $\text{pp} \leftarrow \mathcal{G}(1^\lambda)$ ,  $(s, u_1, \text{st}_1) \leftarrow \mathcal{A}(\text{pp})$ , and  $(\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, s)$ ,

$$\begin{aligned} & - \langle \mathcal{P}_1^*, \mathcal{V}_1 \rangle((\text{pk}, \text{vk}), u_1, \text{st}_1) \to (u_2, \text{st}_2) \\ & - \langle \mathcal{P}_2^*, \mathcal{V}_2 \rangle((\text{pk}, \text{vk}), u_2, \text{st}_2) \to (u_3, w_3) \end{aligned}$$

Furthermore, we assume that  $\mathcal{A}$  outputs  $\text{st}_1$  which contains  $(s, \text{pp})$ ; otherwise, we could trivially construct an adversary  $\mathcal{A}'$  with an identical distribution of prior outputs that does so. First, we construct an adversary  $\mathcal{A}_2 := (\mathcal{B}_2, \mathcal{B}'_2)$  for  $\Pi_2$ :

|                                                                                                                                        |
|----------------------------------------------------------------------------------------------------------------------------------------|
| $\mathcal{B}_2(\text{pp}) \to (s, \text{st}_1) :$                                                                                      |
| 1. $(s, u_1, \text{st}_1) \leftarrow \mathcal{A}(\text{pp})$ .                                                                         |
| 2. Output $(s, \text{st}_1)$ .                                                                                                         |
| $\mathcal{B}'_2(\text{st}_1) \to (u_2, \text{st}_2) :$                                                                                 |
| 1. Parse $\text{st}_1$ to obtain $(s, \text{pp})$ .                                                                                    |
| 2. $(\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, s)$ .                                                                     |
| 3. Simulate $(u_2, \text{st}_2) \leftarrow \langle \mathcal{P}_1^*, \mathcal{V}_1 \rangle((\text{pk}, \text{vk}), u_1, \text{st}_1)$ . |
| 4. Output $(u_2, \text{st}_2)$ .                                                                                                       |
| $\mathcal{A}_2(\text{pp}) \to (s, u_2, \text{st}_2) :$                                                                                 |
| 1. $(s, \text{st}_1) \leftarrow \mathcal{B}_2(\text{pp})$ .                                                                            |
| 2. $(u_2, \text{st}_2) \leftarrow \mathcal{B}'_2(\text{st}_1)$ .                                                                       |
| 3. Output $(s, u_2, \text{st}_2)$ .                                                                                                    |

Observe that, by construction, the success probability  $\epsilon(\mathcal{A}_2, \mathcal{P}_2^*)$  of adversary  $(\mathcal{A}_2, \mathcal{P}_2^*)$  for  $\Pi_2$  is equal to the success probability  $\epsilon(\mathcal{A}, \mathcal{P}^*)$  of adversary  $(\mathcal{A}, \mathcal{P}^*)$  for  $\Pi$ . Since  $\Pi_1$  is  $\phi$ -restricted, we must have

$$\Pr \left[ \begin{array}{c} u_2, u'_2 \neq \perp \\ \downarrow \\ \phi(u_2) = \phi(u'_2) \end{array} \middle| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (s, \text{st}_1) \leftarrow \mathcal{B}_2(\text{pp}) \\ (u_2, \text{st}_2) \leftarrow \mathcal{B}'_2(\text{st}_1) \\ (u'_2, \text{st}'_2) \leftarrow \mathcal{B}'_2(\text{st}_1) \end{array} \right] = 1, \quad (1)$$

Thus, we have by (1) and the  $\phi$ -relaxed knowledge soundness of  $\Pi_2$  that there exists an expected polynomial-time extractor  $\mathcal{E}_2$  such that

$$\Pr \left[ \begin{array}{l} (\text{pp}, \text{s}, u_2, w_2) \in \mathcal{R}'_2 \\ \left| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\text{s}, u_2, \text{st}_2) \leftarrow \mathcal{A}_2(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s}) \\ w_2 \leftarrow \mathcal{E}_2(\text{pp}, \text{s}, u_2, \text{st}_2) \end{array} \right. \end{array} \right] \ge \epsilon(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda) \quad (2)$$

$$\text{and} \quad \Pr \left[ \begin{array}{l} w_2, w'_2 \neq \perp \\ \wedge w_2 \neq w'_2 \\ \left| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\text{s}, \text{st}_1) \leftarrow \mathcal{B}_2(\text{pp}) \\ (u_2, \text{st}_2) \leftarrow \mathcal{B}'_2(\text{st}_1) \\ w_2 \leftarrow \mathcal{E}_2(\text{pp}, \text{s}, u_2, \text{st}_2) \\ (u'_2, \text{st}'_2) \leftarrow \mathcal{B}'_2(\text{st}_1) \\ w'_2 \leftarrow \mathcal{E}_2(\text{pp}, \text{s}, u'_2, \text{st}'_2) \end{array} \right. \end{array} \right] \le \text{negl}(\lambda) \quad (3)$$

Next, we will construct an adversary  $\mathcal{P}_1^{**}$  for  $\Pi_1$ :

$\mathcal{P}_1^{**}(\text{pk}, u_1, \text{st}_1) \rightarrow w_2 :$ 

1. Parse  $\text{st}_1$  to obtain  $(\text{s}, \text{pp})$ .
2.  $(\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s})$ .
3. Simulate  $(u_2, \text{st}_2) \leftarrow \langle \mathcal{P}_1^*, \mathcal{V}_1 \rangle((\text{pk}, \text{vk}), u_1, \text{st}_1)$ .
4.  $w_2 \leftarrow \mathcal{E}_2(\text{pp}, \text{s}, u_2, \text{st}_2)$ .
5. Output  $w_2$ .

Observe that, by construction, the relaxed success probability  $\epsilon'(\mathcal{A}, \mathcal{P}_1^{**})$  of adversary  $(\mathcal{A}, \mathcal{P}_1^{**})$  for  $\Pi_1$  is equal to  $\epsilon(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda) \ge 1/\text{poly}(\lambda)$  which is the success probability of the relaxed extractor  $\mathcal{E}_2$  from equation (2). Furthermore, by equation (3) and construction of  $(\mathcal{B}_2, \mathcal{B}'_2)$ , we must have that

$$\Pr \left[ \begin{array}{l} w_2, w'_2 \neq \perp \\ \wedge \\ w_2 \neq w'_2 \\ \left| \begin{array}{l} \text{pp} \leftarrow \text{Gen}(1^\lambda) \\ (\text{s}, u_1, \text{st}_1) \leftarrow \mathcal{A}(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s}) \\ (u_2, w_2) \leftarrow \langle \mathcal{P}_1^{**}, \mathcal{V} \rangle((\text{pk}, \text{vk}), u_1, \text{st}_1) \\ (u'_2, w'_2) \leftarrow \langle \mathcal{P}_1^{**}, \mathcal{V} \rangle((\text{pk}, \text{vk}), u_1, \text{st}_1) \end{array} \right. \end{array} \right] \le \text{negl}(\lambda) \quad (4)$$

Thus, we have by (4) and the restricted knowledge soundness of  $\Pi_1$  that there exists an expected polynomial-time extractor  $\mathcal{E}_1$  such that

$$\Pr \left[ \begin{array}{l} (\text{pp}, \text{s}, u_1, w_1) \in \mathcal{R}_1 \\ \left| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\text{s}, u_1, \text{st}_1) \leftarrow \mathcal{A}(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s}) \\ w_1 \leftarrow \mathcal{E}_1(\text{pp}, \text{s}, u_1, \text{st}_1) \end{array} \right. \end{array} \right] \ge \epsilon(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda) \quad (5)$$

In conclusion, we have constructed an extractor  $\mathcal{E} := \mathcal{E}_1$  with respect to adversary  $(\mathcal{A}, \mathcal{P}^*)$  such that

$$\Pr \left[ \begin{array}{l} (\text{pp}, \text{s}, u_1, w_1) \in \mathcal{R}_1 \\ \left| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\text{s}, u_1, \text{st}_1) \leftarrow \mathcal{A}(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s}) \\ w_1 \leftarrow \mathcal{E}(\text{pp}, \text{s}, u_1, \text{st}_1) \end{array} \right. \end{array} \right] \ge \epsilon(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda).$$

Thus,  $\Pi := \Pi_2 \circ \Pi_1$  is knowledge sound.  $\square$

### D.4 Proofs for $\Pi_{\text{ccs}}$

We first provide a lemma that will be helpful for both the security and completeness of the interactive reduction.

**Lemma 7.** *Consider the following arbitrary items:*

$$\begin{aligned} & \text{structure } \mathbf{s}, \quad \text{vectors } z_1, \dots, z_{K+k} \in \mathbb{F}^{n_{\mathbf{F}}}, \\ & \text{point } r \in \mathbb{K}^{\log m}, \quad \text{evaluations } (\{y_{i,j} \in \mathbb{R}_{\mathbb{K}}\}_{j \in [t]})_{i=K+1}^{K+k}. \end{aligned}$$

Similarly to  $\Pi_{\text{ccs}}$  (Section 7.3), define polynomials

$$\begin{aligned} F(\vec{X}, C) &:= \sum_{i=1}^{K} C^{i-1} \cdot f(\overline{M_1 z_i}(\vec{X}), \dots, \overline{M_t z_i}(\vec{X})) \\ \text{NC}(\vec{X}, C) &:= \sum_{i=1}^{K+k} C^{i-1} \cdot \prod_{j=b+1}^{b-1} (\overline{z_i}(\vec{X}) - j) \\ \text{Eval}(\vec{X}, C) &:= \text{eq}(\vec{X}, r) \cdot \sum_{i=K+1}^{K+k} \sum_{j=1}^{t} \sum_{\ell=1}^{d} C^{\mathbb{I}(i,j,\ell)} \cdot \overline{\text{cf}(\overline{M_j z_i})_{\ell}(\vec{X})} \\ Q(\vec{X}, \vec{A}, C) &:= \text{eq}(\vec{X}, \vec{A}) \cdot (F(\vec{X}, C) + C^K \cdot \text{NC}(\vec{X}, C)) + C^{2K+k} \cdot \text{Eval}(\vec{X}, C) \end{aligned}$$

$$T(C) := \sum_{i=K+1}^{K+k} \sum_{j=1}^{t} \sum_{\ell=1}^{d} C^{\mathbb{I}(i,j,\ell)} \cdot \text{cf}(y_{i,j})_{\ell}$$

where challenges  $\alpha \in \mathbb{K}^{\log m}$  and  $\gamma \in \mathbb{K}$  are replaced by indeterminate variables  $\vec{A} := (A_1, \dots, A_{\log m})$  and  $C$ , respectively.

We must have  $T(C) = \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C)$  if and only if

1.  $f(\overline{M_1 z_i}, \dots, \overline{M_t z_i}) \in \mathcal{ZS}_{\log m}$  for all  $i \in [K]$ ,
2. and for all  $i \in [K+k]$ ,  $\|z_i\|_{\infty} < b$ ,
3. and for all  $i \in [K+1, K+k]$  and  $j \in [t]$ ,  $y_{i,j} = \overline{\text{cf}(\overline{M_j z_i})}(r)$ .

*Proof.* By definition of  $T(C)$ ,

$$T(C) = \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C)$$

if and only if

$$\sum_{i=K+1}^{K+k} \sum_{j=1}^{t} \sum_{\ell=1}^{d} C^{\mathbb{I}(i,j,\ell)} \cdot \text{cf}(y_{i,j})_{\ell} = \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C) \quad (6)$$

Since powers of  $C$  are linearly independent, Equation (6) occurs if and only if

$$\forall i \in [K], \quad 0 = \sum_{\vec{x} \in \{0,1\}^{\log m}} \text{eq}(\vec{x}, \vec{A}) \cdot f(\overline{M_1 z_i}(\vec{x}), \dots, \overline{M_t z_i}(\vec{x})), \quad (7)$$

$$\forall i \in [K + k], \quad 0 = \sum_{\vec{x} \in \{0,1\}^{\log m}} \text{eq}(\vec{x}, \vec{A}) \cdot \prod_{j=-b-1}^{b-1} (\widetilde{z}_i(\vec{x}) - j), \quad (8)$$

$$\forall i \in [K + 1, K + k], \quad \forall j \in [t], \quad \forall \ell \in [d], \quad \text{cf}(y_{i,j})_\ell = \sum_{\vec{x} \in \{0,1\}^{\log m}} \text{eq}(\vec{x}, r) \cdot \overline{\text{cf}(\vec{M}_j \vec{z}_i)_\ell}(\vec{x}) \quad (9)$$

By Lemma 6, Equation (7) and Equation (8) occur if and only if

1.  $f(\overline{\vec{M}_1 \vec{z}_i}, \dots, \overline{\vec{M}_t \vec{z}_i}) \in \mathbb{Z}S_{\log m}$  for all  $i \in [K]$  (Item 1),
2.  $\prod_{j=-b-1}^{b-1} (\widetilde{z}_i(\vec{x}) - j) \in \mathbb{Z}S_{\log m}$  for all  $i \in [K + k]$

Over a field, we must have  $\prod_{j=-b-1}^{b-1} (\widetilde{z}_i(\vec{x}) - j) \in \mathbb{Z}S_{\log m}$  if and only if for all  $i \in [K + k]$ ,  $\|z_i\|_\infty < b$  (Item 2). By definition of multilinear extension and Remark 2, we must have that

$$\forall i \in [K + 1, K + k], \forall j \in [t], \quad \forall \ell \in [d], \quad \text{cf}(y_{i,j})_\ell = \sum_{\vec{x} \in \{0,1\}^{\log m}} \text{eq}(\vec{x}, r) \cdot \overline{\text{cf}(\vec{M}_j \vec{z}_i)_\ell}(\vec{x}) \quad (\text{Equation (9)})$$

if and only if

$$\forall i \in [K + 1, K + k], \forall j \in [t], \quad y_{i,j} = \overline{\vec{M}_j \vec{z}_i}(r) \quad (\text{Item 3})$$

In conclusion, we have shown

$$T(C) = \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C)$$

if and only if (Item 1), (Item 2), and (Item 3).  $\square$

**Lemma 8.** *The interactive reduction  $\Pi_{\text{CCS}} : \text{CCS}(b, \mathcal{L})^K \times \text{CE}(b, \mathcal{L})^k \to \text{CE}(b, \mathcal{L})^{K+k}$  is complete and public coin.*

*Proof. Completeness.* Assume the original input tuples belong to relations  $\text{CCS}(b, \mathcal{L})$  (Definition 12) and  $\text{CE}(b, \mathcal{L})$  (Definition 13). We will first argue that the sum-check verifier in step 2 passes. Then, we will argue that the evaluation claim check in step 4 passes. Finally, we will argue that output tuples belong to  $\text{CE}(b, \mathcal{L})^{K+k}$ .

By the definition of relations  $\text{CCS}(b, \mathcal{L})$  (Definition 12) and  $\text{CE}(b, \mathcal{L})$  (Definition 13), we must have that (Item 1), (Item 2), and (Item 3) from Lemma 7 hold. Therefore, we must have that

$$T(C) = \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C).$$

Thus, for any choice of challenges  $\alpha \in \mathbb{K}^{\log m}$  and  $\gamma \in \mathbb{K}$  chosen in step 1,

$$T(\gamma) = \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \alpha, \gamma).$$

Thus, by the completeness of the sum-check protocol (Definition 6), we must have that the sum-check verifier (step 2) always passes.

By step 3 and Remark 2, we must have that

$$\text{ct}(y'_{i,j}) = \overline{\widehat{M}_j z_i}(r')$$

for all  $i \in [K+k]$  and  $j \in [t]$ . Since  $M_1 = I_n$ , we must have that

$$\text{ct}(y'_{i,1}) = \widetilde{z}_i(r')$$

for all  $i \in [K+k]$ . Finally, by Remark 2, we must have that

$$\text{cf}(y'_{i,j})_\ell = \overline{\text{cf}(\widehat{M}_j z_i)_\ell}(r')$$

for all  $i \in [K+1, K+k], j \in [t], \ell \in [d]$ . By definition of  $Q(\vec{X})$  in step 2, we must have that

$$Q(r') = \text{eq}(r', \alpha) \cdot (F + \gamma^K \cdot N) + \gamma^{2K+k} \cdot E$$

for values  $F, N, E$  derived in step 4. Thus, the verifier check in step 4 passes.

Observe that  $\Pi_{\text{CCS}}$  outputs exactly the original structure  $s$ , commitments  $(c_i)_{i \in [K+k]}$ , vectors  $(z_i)_{i \in [K+k]}$ , and instances  $(x_i)_{i \in [K+k]}$ . Thus, by the definition of  $\text{CCS}(b, \mathcal{L})$ , we must have immediately that every condition in  $\text{CE}(b, \mathcal{L})$  is satisfied for all the  $K+k$  tuples, except that

$$\forall i \in [K+k], j \in [t], \quad y'_{i,j} = \overline{\widehat{M}_j z_i}(r').$$

However, this is exactly what is computed by the honest prover in step 3. Therefore, the output tuples do belong to  $\text{CE}(b, \mathcal{L})^{K+k}$  as required.

**Public coin.** The sum-check protocol itself is a public-coin protocol. The remaining randomness from the verifier are the challenges  $\alpha \in \mathbb{K}^{\log m}$ ,  $\gamma \in \mathbb{K}$ , which are sampled uniformly at random and sent to the prover.  $\square$

We prove conditions (i) and (ii) of weak interactive reductions (Definition 9).

*Proof.*

**Proof of (i)** By construction, the verifier trivially sets the commitments in the output instance  $u_2$  to be the original commitments  $(c_i)_{i \in [K+k]}$  from the input instance  $u_1$ . Hence, for repeated executions with respect to the same input instance  $u_1$  with output instances  $u_2, u'_2$ , the commitments in these output instances must be the same.

**Proof of (ii)** Consider an arbitrary expected polynomial-time adversary  $(\mathcal{A}, \mathcal{P}^*)$ , such that the relaxed success probability of the adversary  $\epsilon'(\mathcal{A}, \mathcal{P}^*) \ge 1/\text{poly}(\lambda)$  and

$$\Pr \left[ \begin{array}{l} w_2, w'_2 \neq \perp \\ \wedge \\ w_2 \neq w'_2 \end{array} \left| \begin{array}{l} \text{pp} \leftarrow \text{Gen}(1^\lambda) \\ (s, u_1, \text{st}) \leftarrow \mathcal{A}(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, s) \\ (u_2, w_2) \leftarrow \langle \mathcal{P}^*, \mathcal{V} \rangle((\text{pk}, \text{vk}), u_1, \text{st}) \\ (u'_2, w'_2) \leftarrow \langle \mathcal{P}^*, \mathcal{V} \rangle((\text{pk}, \text{vk}), u_1, \text{st}) \end{array} \right. \right] \le \text{negl}(\lambda) \quad (10)$$

then we will show that there exists an expected polynomial-time extractor  $\mathcal{E}$  such that

$$\Pr \left[ \left( \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\text{s}, u_1, \text{st}) \leftarrow \mathcal{A}(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s}) \\ w_1 \leftarrow \mathcal{E}(\text{pp}, \text{s}, u_1, \text{st}) \end{array} \right) \in \mathcal{R}_1 \right] \ge \epsilon'(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda).$$

Namely, the following extractor  $\mathcal{E}$ ,

$\mathcal{E}(\text{pp}, \text{s}, u_1, \text{st}) \rightarrow w_1 :$ 

1.  $(\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s}).$
2. Assign  $\text{result} := \perp.$
3. While  $\text{result} = \perp:$ 
  - Simulate  $\text{result} \leftarrow \langle \mathcal{P}_1^*, \mathcal{V}_1 \rangle((\text{pk}, \text{vk}), u_1, \text{st}^*)$
  - If  $\text{result} \neq \perp$ 
    - Parse  $(u_2, w_2) \leftarrow \text{result}.$
    - If  $(\text{pp}, \text{s}, u_2, w_2) \notin \mathcal{R}'_2$ , then set  $\text{result} = \perp.$
4. Simulate  $\text{result}' \leftarrow \langle \mathcal{P}_1^*, \mathcal{V}_1 \rangle((\text{pk}, \text{vk}), u_1, \text{st}^*)$
5. If  $\text{result}' \neq \perp:$ 
  - Parse  $(u'_2, w'_2) \leftarrow \text{result}'.$
  - If  $(\text{pp}, \text{s}, u'_2, w'_2) \notin \mathcal{R}'_2$ , then set  $\text{result}' = \perp.$
6. If  $\text{result}' = \perp$ , then output  $\perp.$
7. Parse  $(u_2, w_2) \leftarrow \text{result}$  and  $(u'_2, w'_2) \leftarrow \text{result}'.$
8. If  $w_2 \neq w'_2$ , then output  $\perp.$
9. Parse  $(z_1, \dots, z_K, z_{K+1}, \dots, z_{K+k}) \leftarrow w_2.$
10. For all  $i \in [K]$ , assign  $w_i^{\text{CCS}} \leftarrow z_i[n_{\text{F,in}}:].$
11. Output  $w_1 := (w_1^{\text{CCS}}, \dots, w_K^{\text{CCS}}, z_{K+1}, \dots, z_{K+k}).$

*Extractor runtime.* We will show that the extractor  $\mathcal{E}$  makes at most  $1 + 1/\epsilon'(\mathcal{A}, \mathcal{P}^*)$  calls to  $\mathcal{P}^*$  in expectation. Since  $\epsilon'(\mathcal{A}, \mathcal{P}^*) \ge 1/\text{poly}(\lambda)$ , we have that the extractor makes at most a polynomial number of calls to  $\mathcal{P}^*$  in expectation. Hence, since  $\mathcal{K}$  and  $\mathcal{V}_1$  run in  $\text{poly}(\lambda)$  time, we have that overall the extractor runs in expected polynomial-time.

By construction, the while loop (Item 3) terminates when the adversary  $(\mathcal{A}, \mathcal{P}^*)$  succeeds. Since the relaxed success probability is  $\epsilon'(\mathcal{A}, \mathcal{P}^*)$ , the while loop executes  $1/\epsilon'(\mathcal{A}, \mathcal{P}^*)$  times in expectation. This implies the while loop performs  $1/\epsilon'(\mathcal{A}, \mathcal{P}^*)$  calls to  $\mathcal{P}^*$  in expectation. Finally, Item 4 performs one call to  $\mathcal{P}^*.$

*Extractor success probability.* First, we will show

$$\Pr \left[ \begin{array}{l} \text{result}' \neq \perp \\ \wedge \\ w_2 = w'_2 \end{array} \left| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\text{s}, u_1, \text{st}) \leftarrow \mathcal{A}(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \text{s}) \\ w_1 \leftarrow \mathcal{E}(\text{pp}, \text{s}, u_1, \text{st}) \end{array} \right. \right] \ge \epsilon'(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda). \quad (11)$$

Item 5 exactly checks that the simulated adversary in Item 4 succeeds. Thus, the event that  $\text{result}' \neq \perp$  occurs with probability  $\epsilon'(\mathcal{A}, \mathcal{P}^*)$ . Assume that the event  $\text{result}' \neq \perp$  occurs. By (10),  $w_2 \neq w'_2$  with at most  $\text{negl}(\lambda)$  probability. Thus, all together, we have (11) holds.

Assume that the event  $\text{result}' \neq \perp \land w_2 = w'_2$  occurs, which implies the extractor outputs a witness  $w_1 := (w_1^{\text{CCS}}, \dots, w_K^{\text{CCS}}, z_{K+1}, \dots, z_{K+k}) \neq \perp$  (as the extractor passes the checks in Item 6 and Item 8). We will show that  $(\text{pp}, \mathbf{s}, u_1, w_1) \notin \mathcal{R}_1$  with probability at most  $\text{negl}(\lambda)$ . Hence,

$$\Pr \left[ \begin{array}{l} (\text{pp}, \mathbf{s}, u_1, w_1) \in \mathcal{R}_1 \\ \left| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\mathbf{s}, u_1, \text{st}) \leftarrow \mathcal{A}(\text{pp}) \\ (\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \mathbf{s}) \\ w_1 \leftarrow \mathcal{E}(\text{pp}, \mathbf{s}, u_1, \text{st}) \end{array} \right. \end{array} \right]$$

$$\ge (\epsilon'(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda)) - \text{negl}(\lambda) = \epsilon'(\mathcal{A}, \mathcal{P}^*) - \text{negl}(\lambda).$$

Since  $\text{result}' \neq \perp$ , by construction (Item 5), we must have  $(\text{pp}, \mathbf{s}, u'_2, w'_2) \in \mathcal{R}'_2$  and during the simulation  $\langle \mathcal{P}_1^*, \mathcal{V}_1 \rangle((\text{pk}, \text{vk}), u_1, \text{st}^*)$  in Item 4, the verifier  $\mathcal{V}_1$  did not abort. Namely, that the sum-check verifier in (step 2) did not abort and the evaluation checks (step 4) were satisfied. By definition of  $\mathcal{R}'_2 = \text{CE}(q/2, \mathcal{L})^{K+k}$ , we must know that for all  $i \in [K+k]$ ,

$$\mathbf{x}_i := \mathcal{L}_{\text{in}}(\mathbf{z}_i) \quad \text{and} \quad c_i := \mathcal{L}(\mathbf{z}_i). \quad (12)$$

By the definition of  $\mathcal{L}_{\text{in}}$  (Definition 14), Equation (12) also implies that for all  $i \in [K+k]$ , the first  $n_{\text{in}}$  entries of  $\mathbf{z}_i$  are equal to  $\mathbf{x}_i$  (from input instance  $u_1$ ).

Assume that  $(\text{pp}, \mathbf{s}, u_1, w_1) \notin \mathcal{R}_1$ . Recall that  $\mathcal{R}_1 := \text{CCS}(b, \mathcal{L})^K \times \text{CE}(b, \mathcal{L})^k$ . By Equation (12), we know that all conditions in  $\text{CCS}(b, \mathcal{L})$  and  $\text{CE}(b, \mathcal{L})$ , except for the norm-bound ( $\|\mathbf{z}\|_\infty < b$ ), evaluation ( $y_j = \overline{\mathcal{M}_j \mathbf{z}}(r)$ ), or CCS requirements ( $f(\overline{M_1 \mathbf{z}}, \dots, \overline{M_t \mathbf{z}}) \in \text{ZS}_{\log m}$ ), are satisfied. Thus, using notation from Lemma 7,  $(\text{pp}, \mathbf{s}, u_1, w_1) \notin \mathcal{R}_1$  implies that either:

1. there exists an  $i \in [K]$ ,  $f(\overline{M_1 \mathbf{z}_i}, \dots, \overline{M_t \mathbf{z}_i}) \notin \text{ZS}_{\log m}$ ,
2. OR there exists an  $i \in [K+k]$ ,  $\|\mathbf{z}_i\|_\infty \ge b$ ,
3. OR there exists an  $i \in [K+1, K+k]$ ,  $j \in [t]$ ,  $y_{i,j} \neq \overline{\mathcal{M}_j \mathbf{z}_i}(r)$ .

By Lemma 7, we must have

$$T(C) \neq \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C).$$

Let's focus on the second simulation of  $\Pi_{\text{CCS}}$  in step 4. Note, that the randomness used in the second simulation of the  $\Pi_{\text{CCS}}$  (extractor step 4) is fresh and independent of the first simulation of the  $\Pi_{\text{CCS}}$  (extractor step 3). Since  $(\text{pp}, \mathbf{s}, u'_2, w'_2) \in \mathcal{R}'_2$ , we must have the the prover's claimed evaluations in protocol step 3 are true. Thus, by the construction of the verifier's checks in protocol step 4, we must have that the sum-check evaluation claim  $v = Q(r')$  is true.

Recall that the witness from the first simulation,  $w_2$ , agrees with the witness from the second simulation,  $w'_2$ . Thus, in order for the sum-check verifier to have passed in the second simulation, either the adversary  $\mathcal{P}^*$

- succeeded in the sum-check protocol, despite  $T(C) \neq \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C)$  (in other words, violated the soundness of the sum-check protocol)
- OR the non-zero polynomial

$$P(C, \vec{A}) := T(C) - \sum_{\vec{x} \in \{0,1\}^{\log m}} Q(\vec{x}, \vec{A}, C)$$

evaluated to zero on random point  $(\gamma, \alpha) \in \mathbb{K}^{1+\log m}$ .

By the soundness error of the sum-check protocol (Definition 6), the first event occurs with probability at most  $\epsilon_{SC} := \max(u, 2b + 1, 2) \cdot \log m / |\mathbb{K}|$ , where  $u$  is the degree of  $f$ ,  $b$  is the norm bound, 2 comes from  $\text{Eval}(\vec{X})$ . By the Schwartz-Zippel lemma, the second event occurs with probability at most  $\epsilon_{SZ} := (2K + k) \max(\log m, ktd) / |\mathbb{K}|$ . Thus, by union bound,  $(\text{pp}, \text{s}, u_1, w_1) \notin \mathcal{R}_1$  with probability at most  $\text{negl}(\lambda) := \epsilon_{SC} + \epsilon_{SZ}$ .  $\square$

### D.5 Proofs for $\Pi_{RLC}$

**Lemma 9.** *The interactive reduction  $\Pi_{RLC} : \text{CE}(b, \mathcal{L})^{K+k} \to \text{CE}(B, \mathcal{L})$  is complete and public coin.*

*Proof. Completeness.* By definition of  $\text{CE}(b, \mathcal{L})$  (Definition 13), we must have the input tuples exactly satisfy the conditions in Theorem 5. Thus, we have that the output tuple satisfies all of the requirements of  $\text{CE}(B, \mathcal{L})$ , except for the requirement that  $\|z\|_\infty < B = b^k$ .

However, we show that this bound follows from the expansion factor  $T$  of  $\mathcal{C}$  chosen in Definition 14:

$$\begin{aligned} \|z\|_\infty &= \left\| \sum_{i=1}^{k+K} \rho_i z_i \right\|_\infty \le \sum_{i=1}^{k+K} \|\rho_i z_i\|_\infty \\ &\le \sum_{i=1}^{k+K} T \|z_i\|_\infty \le (k + K)T(b - 1) < B \end{aligned}$$

where the second inequality is from the expansion factor of  $\mathcal{C}$  being  $T$ , the third inequality is from the definition of  $\text{CE}(b, \mathcal{L})$ , which enforces a norm bound of  $b$ , and the last inequality is by assumption (Definition 14). Hence, the output tuple must belong to  $\text{CE}(B, \mathcal{L})$ .

**Public coin.** The verifier's randomness consists of challenges  $\rho_1, \dots, \rho_{k+K}$ , which are sampled uniformly at random from  $\mathcal{C}$  and sent to the prover.  $\square$

We prove the conditions of strong interactive reductions (Definition 10).

*Proof.* Consider an arbitrary expected-polynomial time adversary  $(\mathcal{A}, \mathcal{P}^*)$  for  $\Pi_{RLC}$  with success probability,  $\epsilon(\mathcal{A}, \mathcal{P}^*) \ge 1/\text{poly}(\lambda)$ . First, we can construct an adversary and verification function for Theorem 10,

$A_{(\text{pp}, \mathbf{s}, u_1, \text{st})}(\vec{c})$  :

1. Execute encoder  $(\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \mathbf{s})$ .
2. Simulate  $(u_2, w_2) \leftarrow \langle \mathcal{P}^*(\text{pk}, u_1, \text{st}), \mathcal{V}(\text{vk}, u_1) \rangle$  with verifier randomness  $\vec{c}$ .
3. Output  $w_2$

 $V_{(\text{pp}, \mathbf{s}, u_1, \text{st})}(\vec{c}, w_2) \to \{0, 1\}$  :

1. Execute encoder  $(\text{pk}, \text{vk}) \leftarrow \mathcal{K}(\text{pp}, \mathbf{s})$ .
2. Simulate  $(u_2, \cdot) \leftarrow \langle \mathcal{P}^*(\text{pk}, u_1, \text{st}), \mathcal{V}(\text{vk}, u_1) \rangle$  with verifier randomness  $\vec{c}$ .
3. Output accept if and only if  $(u_2, w_2) \in \text{CE}(B, \mathcal{L})$ .

Let  $E_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$  be the corresponding extractor from Theorem 10. We define  $E(\text{pp}, \mathbf{s}, u_1, \text{st})$  as the trivial algorithm that executes  $E_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$  by simulating calls to  $A_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$ . We construct an extractor for adversary  $(\mathcal{A}, \mathcal{P}^*)$  as follows:

$\mathcal{E}(\text{pp}, \mathbf{s}, u_1, \text{st})$  :

1.  $\text{result} \leftarrow E(\text{pp}, \mathbf{s}, u_1, \text{st})$ .
2. If  $u_1 = \perp$  or  $\text{result} = \perp$ , output  $\perp$ .
3. Parse  $(\vec{c}, w'), (\vec{c}_1, w'_1), \dots, (\vec{c}_{K+k}, w'_{K+k}) \leftarrow \text{result}$ .
4. Parse  $z \leftarrow w'$  and  $\rho_1, \dots, \rho_{K+k} \leftarrow \vec{c}$ .
5. For  $i \in [K+k]$ ,
  - (a) Parse  $z^{(i)} \leftarrow w'_i$  and  $\rho_1^{(i)}, \dots, \rho_{K+k}^{(i)} \leftarrow \vec{c}_i$ .
  - (b) Assign  $\mathbf{z}_i \leftarrow (\rho_i - \rho_i^{(i)})^{-1} \cdot (\mathbf{z} - \mathbf{z}^{(i)})$ .
6. Parse  $(c_i, x_i, r, \{y_{i,j}\}_{j \in [t]})_{i \in [K+k]} \leftarrow u_1$ .
7. Output  $w_1 := (z_i)_{i \in [K+k]}$  if and only if
$$(\mathbf{s}; c_i, x_i, r, \{y_{i,j}\}_{j \in [t]}; z_i)_{i \in [K+k]} \in \text{CE}(q/2, \mathcal{L})^{K+k}$$

*Extractor runtime.* By Theorem 10, we are guaranteed  $E_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$  makes in expectation at most  $(K+k)+1$  calls to  $A_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$ . Hence, our overall extractor  $\mathcal{E}$  runs in expected polynomial time.

*Extractor success probability.* By Theorem 10, we are guaranteed that  $E(\text{pp}, \mathbf{s}, u_1, \text{st})$  outputs  $(K+k)+1$  pairs  $(\vec{c}, w'), (\vec{c}_1, w'_1), \dots, (\vec{c}_{K+k}, w'_{K+k})$  such that

- $V_{(\text{pp}, \mathbf{s}, u_1, \text{st})}(\vec{c}, w') = 1$ ,
- for all  $i \in [K+k]$ ,  $V(\vec{c}_i, w'_i) = 1$ , and
- $(\vec{c}, \vec{c}_1, \dots, \vec{c}_{K+k}) \in \text{SS}(\mathcal{C}, K+k)$

with probability  $\epsilon^{V_{(\text{pp}, \mathbf{s}, u_1, \text{st})}(A_{(\text{pp}, \mathbf{s}, u_1, \text{st})}) - \frac{(K+k)+1}{|\mathcal{C}|}}$ . Since  $A_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$  and  $V_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$  simulate the interaction between  $\mathcal{P}^*$  and  $\mathcal{V}$  and checks if the output pair  $(u_2, w_2)$  belongs to  $\text{CE}(B, \mathcal{L})$ , we must have that

$$\epsilon^{V_{(\text{pp}, \mathbf{s}, u_1, \text{st})}(A_{(\text{pp}, \mathbf{s}, u_1, \text{st})}) - \frac{(K+k)+1}{|\mathcal{C}|}} = \epsilon(\mathcal{A}, \mathcal{P}^*) - \frac{(K+k)+1}{|\mathcal{C}|}. \quad (13)$$

Assume that this event above occurs. Since  $V_{(\text{pp}, \text{s}, u_1, \text{st})}(\vec{c}, w') = 1$  and  $V_{(\text{pp}, \text{s}, u_1, \text{st})}$  executes  $\Pi_{\text{RLC}}$ 's  $\mathcal{V}$  and outputs accept if and only if  $(u_2, w_2) \in \text{CE}(B, \mathcal{L})$ , we must have for  $\mathbf{x} := \sum_{i=1}^{K+k} \rho_i \mathbf{x}_i$  that

$$\left( \begin{array}{c} c := \sum_{i=1}^{K+k} \rho_i c_i, \\ \text{s}; \quad x, r, \quad ; z \\ \left\{ y_j := \sum_{i=1}^{K+k} \rho_i y_{i,j} \right\}_{j \in [t]} \end{array} \right) \in \text{CE}(B, \mathcal{L}) \quad (14)$$

where  $(c_i, x_i, r, \{y_{i,j}\}_j)_i$  are the instance elements in  $u_1$  (parsed in step 6) and  $z \leftarrow w'$  and  $(\rho_i)_i \leftarrow \vec{c}$  are the elements parsed in step 4.

For all  $i \in [K+k]$ , we will make a similar argument to the one directly above. Namely, since  $V(\vec{c}_i, w'_i) = 1$ , we must have for  $\mathbf{x}^{(i)} := \sum_{i=1}^{K+k} \rho_i^{(i)} \mathbf{x}_i$  that

$$\left( \begin{array}{c} c^{(i)} := \sum_{i=1}^{K+k} \rho_i^{(i)} c_i, \\ \text{s}; \quad x^{(i)}, r, \quad ; z^{(i)} \\ \left\{ y_j^{(i)} := \sum_{i=1}^{K+k} \rho_i^{(i)} y_{i,j} \right\}_{j \in [t]} \end{array} \right) \in \text{CE}(B, \mathcal{L}) \quad (15)$$

where  $(c_i, x_i, r, \{y_{i,j}\}_j)_i$  are in  $u_1$  and  $z^{(i)} \leftarrow w'_i$  and  $(\rho_j^{(i)})_j \leftarrow \vec{c}_i$  are the elements parsed in step 5a. By definition of  $\text{CE}(B, \mathcal{L})$  (Definition 13), we must have

$$c = \mathcal{L}(z), \quad c^{(i)} = \mathcal{L}(z^{(i)}), \quad \mathbf{x} = \mathcal{L}_{\text{in}}(z), \quad \mathbf{x}^{(i)} = \mathcal{L}_{\text{in}}(\mathbf{x}^{(i)}) \quad (16)$$

Since  $(\vec{c}, \vec{c}_1, \dots, \vec{c}_{K+k}) \in \text{SS}(\mathcal{C}, K+k)$ , we must have for all  $i \in [K+k]$  that

$$(\rho_1, \dots, \rho_{K+k}) \equiv_i (\rho_1^{(i)}, \dots, \rho_{K+k}^{(i)}) \quad (17)$$

which means the challenges differ only on index  $i$ . By definition of strong sampling set (Definition 17), we must have  $(\rho_i - \rho_i^{(i)})$  is invertible for all  $i \in [K+k]$ .

Thus, by Equation (16) and Equation (17), we have for all  $i \in [K+k]$ ,

$$\begin{aligned} c - c^{(i)} &= \mathcal{L}(z) - \mathcal{L}(z^{(i)}) \\ \mathbf{x} - \mathbf{x}^{(i)} &= \mathcal{L}_{\text{in}}(z) - \mathcal{L}_{\text{in}}(z^{(i)}) \\ \sum_{i=1}^{K+k} \rho_i c_i - \sum_{i=1}^{K+k} \rho_i^{(i)} c_i &= \mathcal{L}(z) - \mathcal{L}(z^{(i)}), \\ \sum_{i=1}^{K+k} \rho_i \mathbf{x}_i - \sum_{i=1}^{K+k} \rho_i^{(i)} \mathbf{x}_i &= \mathcal{L}_{\text{in}}(z) - \mathcal{L}_{\text{in}}(z^{(i)}) \end{aligned} \quad (18)$$

$$\begin{aligned} (\rho_i - \rho_i^{(i)}) \cdot c_i &= \mathcal{L}(z) - \mathcal{L}(z^{(i)}), \\ (\rho_i - \rho_i^{(i)}) \cdot \mathbf{x}_i &= \mathcal{L}_{\text{in}}(z) - \mathcal{L}_{\text{in}}(z^{(i)}) \end{aligned} \quad (19)$$

$$\begin{aligned} c_i &= \mathcal{L}\left((\rho_i - \rho_i^{(i)})^{-1} \cdot (z - z^{(i)})\right), \\ \mathbf{x}_i &= \mathcal{L}_{\text{in}}\left((\rho_i - \rho_i^{(i)})^{-1} \cdot (z - z^{(i)})\right) \end{aligned} \quad (20)$$

$$c_i = \mathcal{L}(z_i), \quad x_i = \mathcal{L}_{\text{in}}(z_i) \quad (21)$$

where equation (18) follows from (14), (15), and Equation (16). Equation (19) follows from the equivalence in Equation (17). Equation (20) follows from  $\mathcal{L}, \mathcal{L}_{\text{in}}$  being  $\mathcal{R}$ -module homomorphisms and  $\mathcal{C}$  being a strong sampling set (Definition 17) which because  $\rho_i \neq \rho_i^{(i)}$  (guaranteed by (17)) means  $\rho_i - \rho_i^{(i)}$  is invertible. Equation (21) is by construction (step 5b).

We make a similar argument for the evaluations. In particular, by the definition of  $\text{CE}(B, \mathcal{L})$  (Definition 13), Equation (14), and Equation (15), we must have that

$$y_j := \overline{\mathcal{M}_j z}(r), \quad y_j^{(i)} := \overline{\mathcal{M}_j z^{(i)}}(r) \quad (22)$$

Thus, we must have for all  $i \in [K+k]$  and  $j \in [t]$ ,

$$y_j - y_j^{(i)} = \overline{\mathcal{M}_j z}(r) - \overline{\mathcal{M}_j z^{(i)}}(r) \quad (23)$$

$$\sum_{i=1}^{K+k} \rho_i y_{i,j} - \sum_{i=1}^{K+k} \rho_i^{(i)} y_{i,j} = \overline{\mathcal{M}_j(z - z^{(i)})}(r) \quad (24)$$

$$(\rho_i - \rho_i^{(i)}) \cdot y_{i,j} = \overline{\mathcal{M}_j(z - z^{(i)})}(r) \quad (25)$$

$$y_{i,j} = \overline{\mathcal{M}_j\left((\rho_i - \rho_i^{(i)})^{-1} \cdot (z - z^{(i)})\right)}(r) \quad (26)$$

$$= \overline{\mathcal{M}_j z_i}(r) \quad (27)$$

where Equation (23) follows from Equation (22), Equation (24) follows from Equation (14) and Equation (15) and the linearity of multilinear evaluation, Equation (25) follows from the equivalence (17), and (26) follows from  $\mathcal{C}$  being a strong sampling set (Definition 17) which because  $\rho_i \neq \rho_i^{(i)}$  (guaranteed by (17)) means  $\rho_i - \rho_i^{(i)}$  is invertible.

Therefore, Equation (13), by Equation (20), and Equation (26), we must have with probability  $\epsilon(\mathcal{A}, \mathcal{P}^*) - ((K+k) + 1)/|\mathcal{C}|$ , the extractor outputs witness elements  $z_1, \dots, z_{K+k}$  such that

$$(\mathbf{s}; c_i, x_i, r, \{y_{i,j}\}_{j \in [t]}; z_i)_{i \in [K+k]} \in \text{CE}(q/2, \mathcal{L})^{K+k},$$

for the trivial norm bound of  $q/2$ , as any element in  $\mathbb{F}$  satisfies this bound.

Now, assume that  $\mathcal{A} := (\mathcal{B}, \mathcal{B}')$  such that

$$\Pr \left[ \begin{array}{l} u_1, u'_1 \neq \perp \\ \downarrow \\ \phi(u_1) = \phi(u'_1) \end{array} \middle| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\mathbf{s}, \text{st}^*) \leftarrow \mathcal{B}(\text{pp}) \\ (u_1, \text{st}) \leftarrow \mathcal{B}'(\text{st}^*) \\ (u'_1, \text{st}') \leftarrow \mathcal{B}'(\text{st}^*) \end{array} \right] = 1 \quad (28)$$

We will show that

$$\Pr \left[ \begin{array}{l} w_1, w'_1 \neq \perp \\ \wedge w_1 \neq w'_1 \end{array} \left| \begin{array}{l} \text{pp} \leftarrow \mathcal{G}(1^\lambda, \text{sz}) \\ (\mathbf{s}, \text{st}^*) \leftarrow \mathcal{B}(\text{pp}) \\ (u_1, \text{st}) \leftarrow \mathcal{B}'(\text{st}^*) \\ w_1 \leftarrow \mathcal{E}(\text{pp}, \mathbf{s}, u_1, \text{st}) \\ (u'_1, \text{st}') \leftarrow \mathcal{B}'(\text{st}^*) \\ w'_1 \leftarrow \mathcal{E}(\text{pp}, \mathbf{s}, u'_1, \text{st}') \end{array} \right. \right] \le \text{negl}(\lambda) \quad (29)$$

Assume that the event  $w_1, w'_1 \neq \perp \wedge w_1 \neq w'_1$  occurs. Since  $w_1, w'_1 \neq \perp$ , we have that  $u_1, u'_1 \neq \perp$  (otherwise, the extractor  $\mathcal{E}$  would have outputted  $\perp$ ).

1. By Equation (28), we must have that  $\phi(u_1) = \phi(u'_1)$ , which guarantees the instances share identical commitments  $(c_i)_{i \in [K+k]}$ .
2. Define  $(z_i)_{i \in [K+k]} = w_1$  and  $(z'_i)_{i \in [K+k]} = w'_1$ . Then,  $w_1 \neq w'_1$  implies that there exist an  $i \in [K+k]$  such that  $z_i \neq z'_i$ .

During the execution of  $\mathcal{E}(\text{pp}, \mathbf{s}, u_1, \text{st})$ , the call to algorithm  $E(\text{pp}, \mathbf{s}, u_1, \text{st})$  produces elements  $\rho_i, \rho_i^{(i)}, z, z^{(i)}$ . Similarly, during the execution of  $\mathcal{E}(\text{pp}, \mathbf{s}', u'_1, \text{st}')$ , the call to algorithm  $E(\text{pp}, \mathbf{s}', u'_1, \text{st}')$  produces elements  $\rho'_i, \rho'_i^{(i)'}, z', z^{(i)'}$ . These elements satisfy the following

$$z_i \neq z'_i \iff (\rho_i - \rho_i^{(i)})^{-1} \cdot (z - z^{(i)}) \neq (\rho'_i - \rho'_i^{(i)'})^{-1} \cdot (z' - z^{(i)'}) \quad (30)$$

$$\|z\|_\infty < B, \|z^{(i)}\|_\infty < B, \|z'\|_\infty < B, \|z^{(i)'}\|_\infty < B \quad (31)$$

Equation (30) follows from (Item 2) and by the construction of  $\mathcal{E}$ . Equation (31) follows from the construction of  $\mathcal{E}$ , which only outputs  $w_1, w'_1 \neq \perp$  when the internal extractor  $E$  (from Theorem 10) succeeds. In particular, the internal extractor  $E$  succeeding guarantees that the verification function  $V_{(\text{pp}, \mathbf{s}, u_1, \text{st})}$  accepts. This verification function checks that output tuples (corresponding to Equation (14) and Equation (15)) belong to  $\text{CE}(B, \mathcal{L})$ , which exactly checks the require norm bound on vectors  $z, z^{(i)}, z', z^{(i)'}$ . By Item 1 and (20), we must have

$$c_i = \mathcal{L}\left((\rho_i - \rho_i^{(i)})^{-1} \cdot (z - z^{(i)})\right) = \mathcal{L}\left((\rho'_i - \rho'_i^{(i)'})^{-1} \cdot (z' - z^{(i)'})\right)$$

Thus, since  $\mathcal{L}$  is a  $R$ -module homomorphism, we have

$$(\rho_i - \rho_i^{(i)}) \cdot c_i = \mathcal{L}(z - z^{(i)}) \wedge (\rho'_i - \rho'_i^{(i)'}) \cdot c_i = \mathcal{L}(z' - z^{(i)'}) \quad (32)$$

All together, by (30), (31), and (32), we have that  $(c_i, \Delta_1 = \rho_i - \rho_i^{(i)}, \Delta_2 = \rho'_i - \rho'_i^{(i)'}, z_1 = z - z^{(i)}, z_2 = z' - z^{(i)'})$  is a  $(2B, \mathcal{C})$ -relaxed binding collision (Definition 4).

By assumption (Definition 14),  $\mathcal{L}$  is a ring commitment scheme that satisfies  $(2B, \mathcal{C})$ -relaxed binding. Thus, the probability of the original event (Equation (29)) must be less than or equal to  $\text{negl}(\lambda)$ . Otherwise, we could construct a corresponding relaxed-binding adversary which executes the extractor  $\mathcal{E}$  twice to retrieve the corresponding elements for the  $2B$ -relaxed binding collision with probability  $\epsilon_{\text{rlx}}(B, \mathcal{C}) \ge \text{negl}(\lambda)$ .  $\square$

### D.6 $\Pi_{\text{DEC}}$ is a Reduction of Knowledge (Theorem 7)

*Proof. Completeness:* First, we show that the verifier’s checks in step 2 pass. Then, we will show that the output tuples belongs to  $\text{CE}(b, \mathcal{L})^k$ .

By the definition of  $\text{CE}(B, \mathcal{L})$ , we must have that  $\|z\|_\infty < B = b^k$  (Definition 14). Thus, by definition of  $\text{split}_b$ , we must have  $z = \sum_{i=1}^k b^{i-1} \cdot z_i$ . Therefore,

$$\begin{aligned} z &= \sum_{i=1}^k b^{i-1} \cdot z_i \\ z &= \sum_{i=1}^k b^{i-1} \cdot z_i \\ \mathcal{L}(z) &= \mathcal{L}(\sum_{i=1}^k b^{i-1} \cdot z_i), \\ c &= \sum_{i=1}^k b^{i-1} \cdot \mathcal{L}(z_i), \\ c &= \sum_{i=1}^k b^{i-1} \cdot c_i, \end{aligned} \tag{33}$$

Equation (34) follows directly from  $\mathcal{L}$  being a  $R$ -module homomorphism. Equation (35) follows by construction of  $c_i \leftarrow \mathcal{L}(z_i)$  in step 1. Starting from equation (33), we must have for all  $j \in [t]$ ,

$$\begin{aligned} z &= \sum_{i=1}^k b^{i-1} \cdot z_i \\ \overline{M_j} z &= \sum_{i=1}^k b^{i-1} \cdot \overline{M_j} z_i \\ \overline{M_j} z(r) &= \sum_{i=1}^k b^{i-1} \cdot \overline{M_j} z_i(r) \\ \overline{M_j} z(r) &= \sum_{i=1}^k b^{i-1} \cdot \overline{M_j} z(r) \end{aligned} \tag{36}$$

$$y_j = \sum_{i=1}^k b^{i-1} \cdot y_{i,j} \tag{37}$$

Equation (36) follows directly from the linearity of multilinear evaluation. Equation (37) follows by definition of  $\text{CE}(B, \mathcal{L})$  and by construction  $y_{i,j} \leftarrow \overline{M_j} z_i(r)$  in step 1. Thus, by (35) and (37), we have the verifier’s checks must pass.

Next, we show that the output tuple,  $(s; \{c_i, x_i, r, \{y_{i,j}\}_{j \in [t]}\}_{i \in [k]}; \{z_i\}_{i \in [k]})$ , belongs to  $\text{CE}(b, \mathcal{L})^k$ . By the definition of  $\text{split}_b$ , we must have that  $\|z_i\|_\infty < b$  for all  $i \in [k]$ . Since  $\mathcal{L}_{\text{in}}$  is the trivial  $\mathcal{R}$ -module homomorphism which projects the first  $n_{\text{R,in}}$  columns, we must have that, by construction in step 2, that  $\mathbf{x}_i = \mathcal{L}_{\text{in}}(z_i)$  for all  $i \in [k]$ . Thus, in total, we must have, along with the construction of  $(c_i, \{y_{i,j}\}_{j \in [t]})_{i \in [k]}$  in step 1, that the output tuples belong to  $\text{CE}(b, \mathcal{L})^k$ .

**Public coin:** The verifier uses no randomness in this protocol. Thus, the protocol is trivially public coin.

**Knowledge soundness:** Consider an arbitrary expected-polynomial time adversary  $(\mathcal{A}, \mathcal{P}^*)$  for  $\Pi_{\text{DEC}}$  with success probability,  $\epsilon(\mathcal{A}, \mathcal{P}^*) \ge 1/\text{poly}(\lambda)$ . We construct an extractor  $\mathcal{E}$  for  $\Pi_{\text{DEC}}$  as follows,

$\mathcal{E}(\mathbf{pp}, \mathbf{s}, u_1 := (c, x, r, (y_j)_{j \in [t]}, \mathbf{st})):$

1. Execute encoder  $(\mathbf{pk}, \mathbf{vk}) \leftarrow \mathcal{K}(\mathbf{pp}, \mathbf{s})$ .
2. Simulate  $(u_2, w_2) \leftarrow \langle \mathcal{P}^*(\mathbf{pk}, u_1, \mathbf{st}), \mathcal{V}(\mathbf{vk}, u_1) \rangle$ .
3. If  $u_2 = \perp$ , output  $\perp$ .
4. Parse  $(z_1, \dots, z_k) \leftarrow w_2$ .
5. Output  $w_1 := \sum_{i=1}^k b^{i-1} z_i$ .

**Extractor runtime:** The extractor runs in expected polynomial time, since it simulates only one execution between the adversary  $\mathcal{P}^*$  and verifier  $\mathcal{V}$ , which both run in expected polynomial time.

**Extractor success probability:** Assume that the simulated adversary  $(\mathcal{A}, \mathcal{P}^*)$  succeeds in convincing the verifier  $\mathcal{V}$  and the parties jointly output  $(\mathbf{s}, u_2, w_2) \in \text{CE}(b, \mathcal{L})^k$ ; note that this occurs with probability  $\epsilon(\mathcal{A}, \mathcal{P}^*)$ . Define

$$(c_i, x_i, r, (y_{i,j})_{j \in [t]})_{i \in [k]} := u_2 \text{ and } z_1, \dots, z_k := w_2.$$

By the definition of  $\text{CE}(b, \mathcal{L})$ , we have for all  $i \in [k]$  and  $j \in [t]$ ,

$$c_i := \mathcal{L}(z_i), \quad \mathbf{x}_i := \mathcal{L}_{\text{in}}(z_i), \quad \|z_i\|_{\infty} < b \quad \text{and} \quad y_{i,j} := \widehat{\mathcal{M}_j z_i}(r) \quad (38)$$

Since the adversary convinces the verifier, we must have that for all  $j \in [t]$ ,

$$c = \sum_{i=1}^k b^{i-1} \cdot c_i \quad \text{and} \quad y_j = \sum_{i=1}^k b^{i-1} \cdot y_{i,j} \quad (39)$$

By construction in step 2 (i.e. definition of  $\text{split}_b$ ), we also must have  $x = \sum_{i=1}^k b^{i-1} \cdot x_i$ . By defining  $z := \sum_{i=1}^k b^{i-1} z_i$ , observe that  $x = \sum_{i=1}^k b^{i-1} \cdot x_i$ , (38), and (39) satisfy the remaining conditions stated in Theorem 5. We must have  $c = \mathcal{L}(z)$ ,  $\mathbf{x} = \mathcal{L}_{\text{in}}(z)$ , and for all  $j \in [t]$ ,  $y_j := \widehat{\mathcal{M}_j z}(r)$ . Since in (38), we have for all  $i \in [k]$ ,  $\|z_i\|_{\infty} < b$ , we must also have  $\|z\|_{\infty} < B = b^k$ . These are exactly the conditions for  $(\mathbf{s}; u_1 := \{c, x, r, \{y_j\}_{j \in [t]}\}; w_1 := z)$  to belong to  $\text{CE}(B, \mathcal{L})$ . Therefore, since the adversary succeeds with probability  $\epsilon(\mathcal{A}, \mathcal{P}^*)$ , we must have by construction, that  $\mathcal{E}$  outputs a satisfying witness such that  $(\mathbf{s}, u_1, w_1) \in \text{CE}(B, \mathcal{L})$  with probability  $\epsilon(\mathcal{A}, \mathcal{P}^*)$ .  $\square$

### D.7 Finding choices of cyclotomic and fields

```

# [LS18, eprint 2017-523] pg 6
# m is the cyclotomic polynomial index
def tau(m):
    return m if (m % 2) != 0 else m / 2

# [LS18, eprint 2017-523] Thm 1.1, pg 4
# m is the cyclotomic polynomial index
# p is the prime
# z is any divisor of m
```

```

# This tests for the condition for thm 1.1 to hold
def thm1_1_cond(m, p, z):
    cond1 = (p % z) == 1
    cond2 = Mod(p,m).multiplicative_order() == m/z
    return cond1 and cond2

# [LS18, eprint 2017-523] Thm 1.1, pg 4
# p is the prime
# z is any divisor of m
# lInf bound for elements to be invertible
# given that m,p,z satisfy thm 1.1 cond
def thm1_1_inv_bound(p, z):
    return (1/s1(z)*p^(1/euler_phi(z))).n()

def thm1_1_num_factors(z):
    return euler_phi(z)

# Output divisors of m
def divisors(m):
    zs = list()
    for i in range(1,m+1):
        if m % i == 0:
            zs.append(i)
    return zs

# [LS18, eprint 2017-523] pg 6, pg 9
# We only consider prime power cyclotomics
# m is the cyclotomic polynomial index
def s1(m):
    return sqrt(tau(m))

# checks if cyclotomic index m is power of two
def is_pow2(m):
    return sum(m.digits(2)) == 1

# [MR09] lattice-based cryptography
# makes sure characteristic does not lead
# to trivial bound
def non_trivial(q, n, d, delta):
    return (q/2).n() >= (2^(2 * sqrt( n*d * log(q,2) * log(delta, 2)))).n()

# [AL21] eprint Prop 2. 2021/202
# for all u,v in R, |u*v| / |v| <= gamma*|u|
# outputs T = gamma * |u|
# assumes we are only testing prime powers
def expansion_factor(m, norm):
    if is_pow2(m):
        return euler_phi(m) * norm
    else:
        return 2 * euler_phi(m) * norm

```

```

# p is prime
# max_idx is max cyclotomic index
# outputs list of (m, z)
def candidates(p, min_idx=10, max_idx=200):
    # prime powers
    possible_indices = [i for i in range(min_idx, max_idx) if len(factor(i)) == 1]
    c = list()
    for m in possible_indices:
        zs = divisors(m)
        for z in zs:
            if thm1_1_cond(m, p, z):
                c.append((Integer(m), Integer(z)))
    return c

def pre_filter(q, cyclotomic_index, z, n, m, chals):
    chals_norm = max({abs(c) for c in chals})
    chals_max_diff = chals[-1] - chals[0]
    delta = 1.0045 # root hermite factor, chosen from [ESSLL19] eprint 2018/773
    phi = cyclotomic_polynomial(cyclotomic_index) # index cyclotomic polynomial
    d = phi.degree() # degree of cyclotomic

    # return non_trivial(q, n, d, delta) and chals_max_diff < thm1_1_inv_bound(q, z) and log(len(chals))
    # We remove non_trivial(...) because we use the lattice estimator for hardness
    return chals_max_diff < thm1_1_inv_bound(q, z) and log(len(chals))^d,2).n() >= 120

def info(q, cyclotomic_index, z, n, m, chals):
    chals_norm = max({abs(c) for c in chals})
    chals_max_diff = chals[-1] - chals[0]
    delta = 1.0045 # root hermite factor, chosen from [ESSLL19] eprint 2018/773
    phi = cyclotomic_polynomial(cyclotomic_index) # index cyclotomic polynomial
    d = phi.degree() # degree of cyclotomic
    T = expansion_factor(cyclotomic_index, chals_norm)

    # Bounds for MSIS to be hard
    # [MR09] lattice-based cryptography pg 6
    # [CMNW24] pg 38 eprint 2024/281
    MSIS_B_l2_bound = min(q, 2^(2 * sqrt(n*d) * log(q,2) * log(delta, 2)))
    MSIS_B_linf_bound = MSIS_B_l2_bound / sqrt(m*d)

    # We need MSIS infinity bound 8TB to be hard
    B = MSIS_B_linf_bound / (8*T)

    print("####")
    print("Cyclotomic idx:", cyclotomic_index)
    print("Cyclotomic Poly:", phi)
    print("z:", z)
    #print("Prime is non-trivial?", non_trivial(q, n, d, delta))
    print("Csmall norm is small enough?", chals_max_diff < thm1_1_inv_bound(q, z))
    print("Csmall large enough?", log(len(chals))^d,2).n() >= 120)

```

```

print("Degree of Cyclotomic:", d)
# print("log(B):", log(B, 2).n())
print("Expansion Factor T:", T)
print("Invertible Norm bound:", thm1_1_inv_bound(q, z))
print("log(|C_Small|):", log(len(chals)^d, 2).n())
print("Factors of Cyclotomic:", thm1_1_num_factors(z))
print()

def possible_settings(q, n, m, chals):
    for (cyclotomic_index, z) in candidates(q):
        if pre_filter(q, cyclotomic_index, z, n, m, chals):
            info(q, cyclotomic_index, z, n, m, chals)
        else:
            delta = 1.0045
            d = cyclotomic_polynomial(cyclotomic_index).degree()
            print("[Does not satisfy security requirements] index: {}, degree: {}, z: {}, non_trivial

# Primes:
GL = 2^64 - 2^32 + 1
AGL = GL - 32
print("#####")
print("AGL #####")
print("#####")
# MSIS settings
n = 13 # rows, kappa in latticefold
m = 2^26 # cols
# Small Challenge set
chals = [-1, 0, 1, 2]
possible_settings(AGL, n, m, chals)
print("#####")
print("M61 #####")
print("#####")
# MSIS settings
n = 16 # rows, kappa in latticefold
m = 2^22 # cols
# Small Challenge set
chals = [-2, -1, 0, 1, 2]
possible_settings(2^61-1, n, m, chals)
print("#####")
print("GL #####")
print("#####")
# MSIS settings
n = 16 # rows, kappa in latticefold
m = 2^24 # cols
# Small Challenge set
chals = [-2, -1, 0, 1, 2]
possible_settings(GL, n, m, chals)
print("#####")

```

### D.8 Lattice Estimator Script

```
from estimator import *
Logging.set_level(Logging.LEVEL0)

M61 = 2^61 -1
GL = 2^64 - 2^32 +1
AGL = GL - 32
b = 2

n = 15
d = 64
k = 13
K = 26
B = b^k
m = 2^33 / d

T = 128
q = AGL

n_sis = n*d
m_sis = m*d
B_12 = sqrt(m*d)*(8*T*B)

params = SIS.Parameters(n=n_sis, q=q, m=m_sis,length_bound=B_12, norm=2)
_ = SIS.estimate(params)
print((K+k)*T*(b-1) < B)

n = 18
d = 54
k = 14
K = 61
B = b^k
m = 2^30 / d

T=216
q = GL

n_sis = n*d
m_sis = m*d
B_12 = sqrt(m*d)*(8*T*B)

params = SIS.Parameters(n=n_sis, q=q, m=m_sis,length_bound=B_12, norm=2)
_ = SIS.estimate(params)
print((K+k)*T*(b-1) < B)

n = 18
d = 54
k = 14
K = 61
```

```
B = b^k
m = 2^28 / d

T = 216
q = M61

n_sis = n*d
m_sis = m*d
B_12 = sqrt(m*d)*(8*T*B)

params = SIS.Parameters(n=n_sis, q=q, m=m_sis,length_bound=B_12, norm=2)
_ = SIS.estimate(params)
print((K+k)*T*(b-1) < B)
```