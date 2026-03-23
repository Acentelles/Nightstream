## 4 Analyzing MLE-structure and Decomposability

This section illustrates the process of designing MLE-structured tables and decomposing them as per Definition 2.6 required by `Lasso`. We first establish notation and then design the tables for three important functions that are used as building blocks for the tables of many RISC-V instructions: equality, less than, and shifts.

### 4.1 Notation

**Associating field elements with bit-vectors and vice versa.** Let  $z$  be a field element in  $\{0, 1, \dots, 2^W - 1\} \subset \mathbb{F}$ . We denote the binary representation of  $z$  as  $\text{bin}(z) = [z_{W-1}, \dots, z_0] \in \{0, 1\}^W$ . Here,  $z_0$  is the least significant bit (LSB), while  $z_{W-1}$  is the most significant bit (MSB). That is,  $z = \sum_{i=0}^{W-1} 2^i z_i$ . We refer to the “sign-bit” of  $z$  as  $z_s = z_{W-1}$ .

We use  $z_{<i}$  to refer to the subsequence  $[z_{i-1}, \dots, z_0]$ . Analogously,  $z_{>i}$  refers to the subsequence  $[z_{W-1}, \dots, z_{i+1}]$ . Similarly, given a vector  $z = [z_{W-1}, \dots, z_0] \in \{0, 1\}^W$ , we denote the associated field element as  $\text{int}(z) = \sum_{i=0}^{W-1} 2^i \cdot z_i$ .

**Remark 1.** In the above paragraphs, we used an italicized  $z$  to denote both a field element in  $\{0, \dots, 2^W - 1\}$  and a vector in  $\{0, 1\}^W$ . Throughout the paper, which of the two sets any variable  $z$  resides in will be clear from context.

**Concatenation of bit vectors.** Given two bit vectors  $x, y \in \{0, 1\}^W$ , we use  $x \parallel y$  to refer to the number whose binary representation is the concatenation  $[x_{W-1}, \dots, x_0 \parallel y_{W-1}, \dots, y_0]$ . Under this definition, it holds that  $\text{int}(x \parallel y) = \text{int}(x) \cdot 2^W + \text{int}(y)$ .

**Decomposing bit vectors into chunks.** For a constant  $c$ , and any  $x \in \{0, 1\}^L$ , we divide the bits of input  $x$  naturally into chunks

$$x = [x_{W-1} \dots x_0] = X_{c-1} \parallel \dots \parallel X_2 \parallel X_0, \quad (3)$$

with each  $X_i \in \{0, 1\}^{W/c}$ .

Throughout the following description of tables and decompositions, we assume  $c$  divides  $W$  for simplicity. However, this is not necessary. In fact, it is more efficient in practice to set  $c = 3$  for  $W = 32$  and  $c = 6$  for  $W = 64$ , resulting in some chunks being length 10 and others being length 11.

### 4.2 Three instructive functions and associated lookup tables

Let field  $\mathbb{F}$  be a prime order field of size at least  $2^W$  (for concreteness, let us fix  $W$  to be 64). Let  $x$  and  $y$  denote field elements that are guaranteed to be in the set  $\{0, 1, \dots, 2^W - 1\}$ .

#### 4.2.1 The Equality function

**MLE-structured.** The equality function  $\text{EQ}$  takes as inputs two vectors  $x, y \in \{0, 1\}^W$  of identical length and outputs 1 if they are equal, and 0 otherwise. We will use a subscript to clarify the number of bits in each input to  $\text{EQ}$ , e.g.,  $\text{EQ}_W$  denotes the equality function defined over domain  $\{0, 1\}^W \times \{0, 1\}^W$ . It is easily confirmed that the multilinear extension of  $\text{EQ}_W$  is as follow:

$$\widetilde{\text{EQ}}_W(x, y) = \prod_{j=0}^{W-1} (x_j y_j + (1 - x_j)(1 - y_j)). \quad (4)$$

Indeed, the right hand side is clearly a multilinear polynomial in  $x$  and  $y$ , and if  $x, y \in \{0, 1\}^W$ , it equals 1 if and only if  $x = y$ . Hence, the right hand side must equal the unique multilinear extension of the equality function. Clearly, it can be evaluated at any point  $(x, y) \in \mathbb{F}^W \times \mathbb{F}^W$  with  $O(W)$  field operations.

**Decomposability.** To determine whether two  $W$ -bit inputs  $x, y \in \{0, 1\}^W$  are equal, one can decompose  $x$  and  $y$  into  $c$  chunks of length  $W/c$ , compute equality of each chunk, and multiply the results together.

Let  $x = [X_{c-1}, \dots, X_0]$  and  $y = [Y_{c-1}, \dots, Y_0]$  denote the decomposition of  $x$  and  $y$  into  $c$  chunks each, as per Equation (3). Let  $\text{EQ}_W$  denote the “big” table of size  $N = 2^{2W}$  indexed by pairs  $(x, y)$  with  $x, y \in \{0, 1\}^W$ , such that  $\text{EQ}_W[x \parallel y] = \widetilde{\text{EQ}}_W(x, y)$ . Let  $\text{EQ}_{W/c}$  denote the “small” table of size  $N^{2W/c}$  indexed by pairs  $(X, Y)$  of chunks  $X, Y \in \{0, 1\}^{W/c}$ , such that  $\text{EQ}_{W/c}[X \parallel Y] = 1$  if  $X = Y$  and  $\text{EQ}_{W/c}[X \parallel Y] = 0$  otherwise. The table below asserts that evaluating the equality function on  $x$  and  $y$  is equivalent to evaluating the equality function on each chunk  $X_i \parallel Y_i$  and multiplying the results.

| CHUNKS                    | SUBTABLES                                                                    | FULL TABLE                                                                 |
|---------------------------|------------------------------------------------------------------------------|----------------------------------------------------------------------------|
| $C_i = X_i \parallel Y_i$ | $\text{EQ}_{W/c}[X_i \parallel Y_i] = \widetilde{\text{EQ}}_{W/c}(X_i, Y_i)$ | $\text{EQ}_W[x, y] = \prod_{i=0}^{c-1} \text{EQ}_{W/c}[X_i \parallel Y_i]$ |

The (lone) subtable  $\text{EQ}_{W/c}$  is MLE-structured by Equation (4).

#### 4.2.2 Less Than comparison

**MLE-structured.** The comparison of two unsigned data types  $x, y \in \{0, 1, \dots, 2^{W-1}\}$  is involved in many instructions. For example, SLTU outputs 1 if  $x < y$  and 0 otherwise, where the inequality interprets  $x$  and  $y$  as integers in the natural way. Note that the inequality computed here is strict. Consider the following  $2W$ -variate multilinear polynomial (L TU below stands for “less than unsigned”):

$$\widetilde{\text{LTU}}_i(x, y) = (1 - x_i) \cdot y_i \cdot \widetilde{\text{EQ}}_{W-i-1}(x_{>i}, y_{>i}). \quad (5)$$

Clearly, this polynomial satisfies the following two properties:

- (1) Suppose  $x \ge y$ . Then  $\widetilde{\text{LTU}}_i(x, y) = 0$  for all  $i$ .
- (2) Suppose  $x < y$ . Let  $k$  be the first index (starting from the MSB of  $x$  and  $y$ ) such that  $x_k = 0$  and  $y_k = 1$ . Then  $\widetilde{\text{LTU}}_k(x, y) = 1$  and  $\widetilde{\text{LTU}}_i(x, y) = 0$  for all  $i \neq k$ .

Based on the above properties, it is easy to check that

$$\widetilde{\text{LTU}}(x, y) = \sum_{i=0}^{W-1} \widetilde{\text{LTU}}_i(x, y). \quad (6)$$

Indeed, the right hand side is clearly multilinear, and by the two properties above, it equals  $\widetilde{\text{LTU}}(x, y)$  whenever  $x, y \in \{0, 1\}^W$ . It is not difficult to see that the right hand side of Equation (6) can be evaluated at any point  $(x, y) \in \mathbb{F}^W \times \mathbb{F}^W$  with  $O(W)$  field operations as the set  $\{\widetilde{\text{EQ}}_{W-i}(x_{>i}, y_{>i})\}_{i=0}^{W-1}$  can be computed in  $O(W)$  total steps using the recurrence relation

$$\widetilde{\text{EQ}}_{W-i-1}(x_{>i}, y_{>i}) = \widetilde{\text{EQ}}_{W-i-2}(x_{>(i+1)}, y_{>(i+1)}) \cdot \widetilde{\text{EQ}}(x_i, y_i). \quad (7)$$

See [Tha22, Figure 3.3] for a depiction of this procedure.

**Decomposing  $\widetilde{\text{LTU}}$ .** A similar reasoning to the derivation of Equation (6) reveals the following. As usual, break  $x$  and  $y$  into  $c$  chunks,  $X_{c-1} \parallel \dots \parallel X_0$  and  $Y_{c-1} \parallel \dots \parallel Y_0$ . Let  $\text{LTU}_{W/c}[X_i \parallel Y_i] = \widetilde{\text{LTU}}_{W/c}(X_i, Y_i)$  denote the subtable with entry 1 if  $X_i < Y_i$  when interpreted as unsigned ( $W/c$ )-bit data types, and 0 otherwise. Then

$$\text{LTU}_W[x \parallel y] = \sum_{i=0}^{c-1} \text{LTU}_{W/c}[X_i \parallel Y_i] \cdot \text{EQ}_{W/c}[X_{>i} \parallel Y_{>i}] = \sum_{i=0}^{c-1} (\text{LTU}_{W/c}[X_i \parallel Y_i] \cdot \prod_{j$$

Thus, evaluating  $\text{LTU}(x, y)$  can be done by evaluating  $\text{LTU}_{W/c}$  and  $\text{EQ}_{W/c}$  on each chunk  $(X_i, Y_i)$  ( $\text{EQ}_{W/c}$  need not be evaluated on the lowest-order chunk  $(X_c, Y_c)$ ). This is summarized in the table below.

| CHUNKS                              | SUBTABLES                                                                 | FULL TABLE                                                                                          |
|-------------------------------------|---------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| $\mathcal{C}_i = X_i \parallel Y_i$ | $\text{LTU}_{W/c}[X_i \parallel Y_i], \text{EQ}_{W/c}[X_i \parallel Y_i]$ | $\text{LTU}_W[x \parallel y] = \sum_{i=0}^{c-1} \text{LTU}_{W/c}[X_i \parallel Y_i] \cdot \prod_{j$ |

The two subtables  $\text{LTU}$  and  $\text{EQ}$  are MLE-structured by Equations (4) and (6).

#### 4.2.3 Shift Left Logical

**MLE-structured.** SLL takes an  $W$ -bit integer  $x$  and a  $\log(W)$ -bit integer  $y$ , and shifts the binary representation of  $x$  to the left by length  $y$ . Bits shifted beyond the MSB of  $x$  are ignored, and the vacated lower bits are filled with zeros.<sup>19</sup> For a constant  $k$ , let

$$\widetilde{\text{SLL}}_k(x) = \sum_{j=k}^{W-1} 2^j \cdot x_{j-k}. \quad (8)$$

<sup>19</sup>For  $L = 32$ -bit data types, the RISC-V manual says that the “shift amount is encoded in the lower  $5 = \log(W)$  bits”.

It is straightforward to check that the right hand side of Equation (8) is multilinear (in fact, linear) function in  $x$ , and that when evaluated at  $x \in \{0, 1\}^W$ , it outputs the unsigned  $W$ -bit data type whose binary representation is the same as that of the output of the SLL instruction on inputs  $x$  and  $k$ ,  $\text{SLL}(x, k)$ .

Now consider

$$\widetilde{\text{SLL}}(x, y) = \sum_{k \in \{0, 1\}^{\log W}} \widetilde{\text{eq}}(y, k) \cdot \widetilde{\text{SLL}}_k(x). \quad (9)$$

It is straightforward to check that the right hand side of Equation (9) is multilinear in  $(x, y)$ , and that, when evaluated at  $x \in \{0, 1\}^W \times \{0, 1\}^{\log W}$ , it outputs the unsigned  $W$ -bit data type  $\text{SLL}(x, y)$ .

**Decomposability.** We split the value to be shifted,  $x$ , into  $c$  chunks,  $X_1, \dots, X_c$ , each consisting of  $W' = W/c$  bits.  $y$  has only one chunk,  $Y_0$ , consisting of the lowest order  $\log W$  bits. As explained below, we decompose a lookup into the evaluation table of SLL into a lookup into  $c$  different subtables, each of size  $2^{W'+\log W}$ . For  $W = 64$ , a reasonable setting of  $c$  would be 4 (instead of the usual  $c = 6$  for most other instructions), ensuring that  $2^{W'+\log W} = 2^{20}$ .

Conceptually, each chunk  $X_i$  of  $X$  needs to determine how many of its input bits goes “out of range” after the shift of length  $y$ . By out of range, we mean that shifting  $x$  left by  $y$  bits causes those bits to overflow the MSB of  $x$  and hence not contribute to the output of the instruction.

For chunks  $i = 0, \dots, (c-1)$  and shift length  $k \in \{0, 1\}^{\log W}$ , define:

$$m_{i,k} = \min\{W', \max\{0, (\text{int}(k) + W' \cdot (i+1)) - W\}\}$$

Here,  $m_{i,k}$  equals the number of bits from the  $i$ 'th chunk that go out of range. Let  $m'_{i,k} = W' - m_{i,k} - 1$  denote the index of the highest-order bit within the  $i$ 'th chunk that does *not* go out of range. Then the evaluation table of SLL decomposes into  $c$  smaller tables  $\text{SLL}_0, \dots, \text{SLL}_{c-1}$  as follows.

| CHUNKS                    | SUBTABLES                                                                                                                                                                    | FULL TABLE                                                                                          |
|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| $C_i = X_i \parallel Y_0$ | $\text{SLL}_i[X_i \parallel Y_0] = \sum_{k \in \{0, 1\}^{\log W}} \widetilde{\text{EQ}}(Y_0, k) \cdot \left( \sum_{j=0}^{m_{i,k}} 2^{j+\text{int}(k)} \cdot X_{i,j} \right)$ | $\text{SLL}[x \parallel y] = \sum_{i=0}^{c-1} 2^{i \cdot W'} \cdot \text{SLL}_i[X_i \parallel Y_c]$ |

Note that each  $\text{SLL}_i$  can be evaluated at any input  $(x, y) \in \mathbb{F}^{W'} \times \mathbb{F}^{\log W}$  in  $O(W')$  field operations. Indeed, the set  $\{\widetilde{\text{EQ}}(Y_0, k)\}_{k \in \{0, 1\}^{\log W}}$  can be computed in  $O(W)$  field operations via the recurrence in Equation (7). Similarly, the set  $\{2^{j+\text{int}(k)}\}_{i \in \{0, \dots, c-1\}, k \in \{0, 1\}^{\log W}}$  can be computed with  $O(W)$  field operations. It follows that  $\text{SLL}_0(x \parallel y), \dots, \text{SLL}_{c-1}(x \parallel y)$  can be evaluated in  $O(W)$  field operations in total.

### 4.3 The Cost of a Lookup

We briefly state the costs incurred by the prover when making a lookup query. As usual, this is analyzed in terms of the bit-lengths of the elements to be committed to. Most lookup queries require separating  $x \parallel y \in \{0, 1\}^{2W}$  into  $c$  chunks which are then sent to  $c$  subtables within Lasso. This involves the Jolt prover committing to  $3c$  elements: (1)  $c$  are the chunks themselves, which are of  $2W/c$  bits, (2)  $c$  are the entries in the subtables involved, which are up to  $W/c$  bits long, (3)  $c$  elements are “access counts” for the subtables, which can go up to  $T$ , the current step count.

With the parameter settings  $(W = 32, c = 3)$  and  $(W = 64, c = 6)$ , the first two bit-lengths involved are  $2W/c \approx 22$  and  $W/c \approx 11$ . Many instructions (such as SLL), involve smaller lookup queries of closer to  $W$  bits and can be split into fewer chunks, leading to a proportional reduction in the number of elements committed to in each group.

An interesting case is that of the LTU subtable, which uses  $c$  chunks but involves  $2c$  total subtables (recall that each chunk is sent to both LTU and EQ). This involves committing to  $c$  extra elements in both

groups (2) and (3) above. While most instructions do not incur this extra cost, we report costs for this instruction in Section 8, as it captures the worst-case scenario (excluding instructions that are not handled directly, but are rather transformed into a short sequence of other instructions, such as division, see Section 6.1).
