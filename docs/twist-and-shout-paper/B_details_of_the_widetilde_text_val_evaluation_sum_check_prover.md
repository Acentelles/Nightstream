## B Details of the $\widetilde{\text{Val}}$ -evaluation sum-check prover

### B.1 Computing the Less-Than evaluation table

In the  $\widetilde{\text{Val}}$ -evaluation sum-check in Twist (Figure 9), the prover needs to compute  $\widetilde{\text{LT}}(j', r)$  for all  $j' \in \{0, 1\}^{\log T}$  for  $r = r_{\text{cycle}} \in \mathbb{F}^{\log T}$ . Here,  $\widetilde{\text{LT}}$  is the multilinear extension of the  $\text{LT}(x, y)$  function defined in Section 3.2, which indicates whether or not  $x$  is the binary representation of an integer that is strictly less than (the integer with binary representation given by)  $y$ .

We explain here how the prover can do this with only  $T$  field multiplications. We use simple, explicit expressions for  $\widetilde{\text{LT}}$  given in [STW24].

Let  $x = (x_1, \dots, x_{\log T})$  and  $y = (y_1, \dots, y_{\log T})$ . If  $x$  and  $y$  are binary representations of integers between 0 and  $T - 1$ , we think of  $x_{\log T}$  and  $y_{\log T}$  as the “low-order bit” of the two binary representations, and  $x_1$  and  $y_1$  as the high order bit.

For  $i = 2, \dots, \log T$ , let  $x_{>i} = (x_{i+1}, \dots, x_{\log T})$  and  $x_{\ge i} = (x_i, \dots, x_{\log T})$ . Define

<span id="page-86-0"></span>
$$\widetilde{\text{LT}}_i(x, y) = (1 - x_i) \cdot y_i \cdot \widetilde{\text{eq}}(x_{>i}, y_{>i}). \quad (86)$$

It is easy to see that

<span id="page-86-1"></span>
$$\widetilde{\text{LT}}(x, y) = \sum_{i=1}^{\log T} \widetilde{\text{LT}}_i(x, y). \quad (87)$$

Note that  $\text{LT}_i$  does not depend on the first (i.e., low-order)  $i - 1$  bits of  $x$ . Accordingly, while Equation (86) expresses  $\text{LT}_i$  as a function of all  $\log T$  bits of  $x$  and  $y$ , we can equivalently think of  $\text{LT}_i$  as a function only of the last  $\log(T) - (i - 1)$  bits of  $x$  and  $y$ . We will follow this convention henceforth.

Suppose the prover has already computed a table  $E_i$  defined as follows:

<span id="page-87-1"></span>
$$E_i \text{ stores all } T/2^i \text{ evaluations of } \tilde{\text{eq}}(j'_{>i}, r_{>i}) \text{ as } j'_{>i} \text{ ranges over } \{0, 1\}^{\log(T)-i}. \quad (88)$$

Suppose further that the prover has also already computed a table  $D_i$  of size  $T/2^{i-1}$  such that for all  $x \in \{0, 1\}^{\log(T)-(i-1)}$ ,

<span id="page-87-0"></span>
$$D_i[x] = \sum_{\ell=i}^{\log T} \tilde{\text{LT}}_\ell(x, r_{\ge \ell}). \quad (89)$$

Via standard observations [VSBW13] (see Lemma 1), the tables  $E_{\log(T)-1}, \dots, E_1$  can all be computed with  $T/2$  field multiplications in total. Furthermore, given table  $E_i$ , the table  $D_i$  (which recall has size  $2 \cdot T/2^i$ ) can be computed with just  $T/2^i$  field multiplications. To see this, observe that the following holds.

Let  $x = (x_i, \dots, x_{\log T}) \in \{0, 1\}^{\log(T)-(i-1)}$  and let  $x_{>i} = (x_{i+1}, \dots, x_{\log T})$ . Then:

- If  $x_i = 1$ ,  $D_i[x] = D_{i+1}[x_{>i}]$ . This is because

$$\tilde{\text{LT}}_i(x, r_{\ge i}) = (1 - x_i) \cdot r_i \cdot \tilde{\text{eq}}(x_{>i}, r_{>i}) = 0.$$

- If  $x_i = 0$  then  $D_i[x] = D_{i+1}[x_{>i}] + r_i \cdot E_i[x_{>i}]$ .

The table  $D_1$  is exactly the table we want, containing all  $T$  evaluations of  $\tilde{\text{LT}}(j', r)$  as  $j'$  ranges over  $\{0, 1\}^{\log T}$ . As explained above,  $D_1$  can be computed with  $3T/2$  multiplications in total.  $T/2$  of these are devoted to computing all of the  $E_i$  tables, and an additional  $T$  multiplications are devoted to computing all of the  $D_i$  tables.

## B.2 Optimizing the $\tilde{\text{Val}}$ -evaluation sum-check prover further

Consider using the sum-check protocol to compute

$$\sum_{x \in \{0, 1\}^m} \tilde{\text{LT}}(r', x) \cdot g(x).$$

In Twist we are interested in the case where  $g$  is multilinear, i.e., where  $g$  has degree  $d = 1$  in each variable, so let us restrict our discussion to that case. We assume that an array storing all evaluations of  $g$  over  $\{0, 1\}^m$  is already computed prior to the start of the prover algorithm (i.e., our accounting in this section does not charge the prover to compute such an array. In Twist, it will cost  $2K$  field operations per Section 8.1).

Let  $(r_1, \dots, r_{i-1})$  denotes the randomness chosen by the sum-check verifier in rounds  $1, \dots, i-1$ . Then

$$\begin{aligned}s_i(c) &= \sum_{x' \in \{0,1\}^{m-i}} \widetilde{\text{LT}}(r', r_1, \dots, r_{i-1}, c, x') \cdot g(r_1, \dots, r_{i-1}, c, x') \\&= \sum_{x' \in \{0,1\}^{m-i}} \left( \sum_{j=1}^{m} (1 - r'_j) \cdot r_j \cdot \widetilde{\text{eq}}(r'_{>j}, (r_1, \dots, r_{i-1}, c, x')_{>j}) \right) \cdot g(r_1, \dots, r_{i-1}, c, x') \\&= \left( \sum_{x' \in \{0,1\}^{m-i}} \left( \sum_{j=1}^{i-1} (1 - r'_j) \cdot r_j \cdot \widetilde{\text{eq}}(r'_{>j}, r_{j+1}, \dots, r_{i-1}, c, x') \right) \cdot g(r_1, \dots, r_{i-1}, c, x') \right) \\&\quad + \left( \sum_{x' \in \{0,1\}^{m-i}} (1 - r_i) \cdot c \cdot \widetilde{\text{eq}}(r'_{>i}, x') \cdot g(r_1, \dots, r_{i-1}, c, x') \right) \\&\quad + \left( \sum_{x' \in \{0,1\}^{m-i}} \left( \sum_{j=i+1}^{m} (1 - r'_j) \cdot x'_{j-i} \cdot \widetilde{\text{eq}}(r'_{>j}, r_{j+1}, \dots, r_{i-1}, c, x') \right) \cdot g(r_1, \dots, r_{i-1}, c, x') \right) \\&= \left( \sum_{x' \in \{0,1\}^{m-i}} \left( \sum_{j=1}^{i-1} (1 - r'_j) \cdot r_j \cdot \widetilde{\text{eq}}(r'_{>j}, r_{j+1}, \dots, r_{i-1}, c, x') \right) \cdot g(r_1, \dots, r_{i-1}, c, x') \right) \tag{90} \\&\quad + \left( \sum_{x' \in \{0,1\}^{m-i}} (1 - r_i) \cdot c \cdot \widetilde{\text{eq}}(r'_{>i}, x') \cdot g(r_1, \dots, r_{i-1}, c, x') \right) \tag{91} \\&\quad + \left( \sum_{x' \in \{0,1\}^{m-i}} D_{i+1}[x'] \cdot g(r_1, \dots, r_{i-1}, c, x') \right). \tag{92}\end{aligned}$$

Here, the first equality invokes Expressions (86) and (87) for  $\widetilde{\text{LT}}$  and  $\widetilde{\text{LT}}_i$ . The final equality invokes the definition of  $D_{i+1}$  (Equation (89)), using the shorthand

<span id="page-88-2"></span><span id="page-88-1"></span><span id="page-88-0"></span>
$$D_{i+1}[c, x'] = (1 - c) \cdot D_{i+1}[0, x'] + c \cdot D_{i+1}[1, x'].$$

Call Expression (90) (i.e., the first sum the final expression)  $A(c)$ , the second sum (i.e., Expression (91))  $B(c)$  and and the third sum (i.e., Expression (92))  $C(c)$ .

Turning our attention to  $A(c) + B(c)$ , for each  $1 \le j \le i$ , let

$$Q_{j,i}(c) = (1 - r'_j) \cdot r_j \cdot \prod_{z=j+1}^{i-1} \widetilde{\text{eq}}(r'_{j+1}, \dots, r'_{i-1}, r_{j+1}, \dots, r_{i-1}) \cdot \widetilde{\text{eq}}(r'_i, c).$$

The prover can, with a constant number of field multiplications per round, maintain the quantity  $Q_{i,c} := \left(\sum_{j=1}^{i} Q_{j,i}(c)\right)$ .

Observe that

$$A(c) + B(c) = \left( \sum_{j=1}^{i} Q_{j,i}(c) \right) \sum_{x' \in \{0,1\}^{m-i}} \widetilde{\text{eq}}(r'_{>i}, x') \cdot g(r_1, \dots, r_{i-1}, c, x').$$

Define

$$A'(c) = \sum_{x' \in \{0,1\}^{m-i}} \widetilde{\text{eq}}(r'_{>i}, x') \cdot g(r_1, \dots, r_{i-1}, c, x') = \sum_{x' \in \{0,1\}^{m-i}} E_i[x'] \cdot g(r_1, \dots, r_{i-1}, c, x'),$$

where recall that  $E_i$  is defined in Equation (88). Then for any point  $c$ ,

$$s_i(c) = \left( \sum_{j=1}^{i-1} Q_{j,i}(c) \right) A'(c) + C(c). \quad (93)$$

The sum-check prover needs to evaluate  $s_i$  at  $c \in \{0, 2\}$ . The prover will store all the intermediate arrays  $D_m, D_{m-1}, \dots$  and  $E_m, E_{m-1}, \dots, E_1$  en route to building  $D_1$  per Section B.1. (As we will see momentarily, ultimately the prover does not even need the array  $D_1$ ). Then per the standard linear-time sum-check proving algorithm (Section 3.3), the prover can compute

$$C(c) = \sum_{x' \in \{0,1\}^{m-i}} D_{i+1}[x'] \cdot g(r_1, \dots, r_{i-1}, c, x'),$$

and

$$A'(c) = Q_{i,c} \cdot \sum_{x' \in \{0,1\}^{m-i}} E_i[x'] \cdot g(r_1, \dots, r_{i-1}, c, x'),$$

with  $2^{m-i}$  field multiplications each.

In total, across the entire protocol, the prover spends  $T/2$  multiplications to build the arrays  $E_m, \dots, E_1$ ,  $T/2$  additional multiplications to build the arrays  $D_m, \dots, D_2$ ,  $T$  multiplications to bind the array storing evaluations of  $g$ ,  $T$  multiplications to compute  $C(0)$  and  $C(2)$  across all rounds  $i$  given these arrays, and  $T$  to compute  $A'(0)$  and  $A'(2)$  across all rounds. This is  $4T$  multiplications in total.
