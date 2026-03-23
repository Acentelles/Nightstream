## 8 Fast **Twist** prover implementation

Recall from Figure 9 that the core **Twist** PIOP consists of three sum-check invocations: the read-checking sum-check, the write-checking sum-check, and the  $\tilde{\text{Val}}$ -evaluation sum-check.

### 8.1 $\tilde{\text{Val}}$ -evaluation sum-check

Let us start by considering the  $\tilde{\text{Val}}$ -evaluation sum-check, as it is the simplest. This invocation applies the sum-check protocol to compute:

$$\sum_{j' \in \{0, 1\}^{\log T}} \tilde{\text{Inc}}(r_{\text{address}}, j') \cdot \tilde{\text{LT}}(j', r_{\text{cycle}}).$$

We explain in Appendix B that, with  $3T/2$  field multiplications, the prover can compute a table storing all evaluations of  $\tilde{\text{LT}}(j', r_{\text{cycle}})$  as  $j'$  ranges over  $\{0, 1\}^{\log T}$ . Similarly, (but more straightforwardly) with  $2K$  field multiplications, the prover can compute a table storing all  $\tilde{\text{Inc}}(r_{\text{address}}, j')$  evaluations. To do this, one first builds a size- $K$  table storing all  $\tilde{\text{eq}}(r_{\text{address}}, k)$  evaluations for  $k \in \{0, 1\}^{\log K}$ , which requires  $K$  field

<span id="page-63-0"></span>

<sup>33</sup>Here, we avoid  $T$  multiplications by setting  $r' = r_{\text{cycle}}$  within the Booleanity-checking sum-check, and thereby reusing a table of  $\tilde{\text{eq}}$  evaluations between the first bullet and this bullet, same as in Section 6.3.

multiplications (see Lemma 1). Given this table, each  $\widetilde{\text{Inc}}(r_{\text{address}}, j')$  evaluation is simply the product of an increment with an entry of the size- $K$  table.

Given the above two tables, the standard linear-time sum-check prover algorithm (Section 3.3) performs  $4T$  additional field multiplications. Hence, total prover time in a straightforward implementation of the  $\widetilde{\text{Val}}$ -evaluation sum-check is  $2K + 5.5 \cdot T$  field multiplications. In Appendix B.2, we explain how to lower this to  $2K + 4T$  field multiplications.

## 8.2 Read-checking and write-checking sum-checks

Achieving a fast prover in the read-checking and write-checking sum-checks requires new techniques. Let us begin by focusing on the read-checking sum-check, which in the case  $d = 1$  confirms that  $\widetilde{\text{V}}(r')$  equals:

<span id="page-64-0"></span>
$$\sum_{(k,j) \in \{0,1\}^{\log K} \times \{0,1\}^{\log T}} \widetilde{\text{eq}}(r', j) \cdot \widetilde{\text{ra}}(k, j) \cdot \widetilde{\text{Val}}(k, j). \quad (69)$$

### 8.2.1 Overview

We give two different prover algorithms. One, which we present in Section 8.2.5, achieves  $O(T \log(K) + K + d^2 T)$  prover time. The other, which we call our “local algorithm”, has a worse dependence on  $d$  (though the same worst-case runtime when  $d = 1$ ) but the following major advantage. Call a memory operation  $2^i$ -local if it accesses for a memory cell that was previously accessed within the last  $2^i$  cycles. For our local algorithm, any  $2^i$ -local memory access only contributes  $O(i)$  field operations to the prover’s work. This is potentially much less than the worst-case bound of  $O(\log K)$  field operations per memory operation. Due to the potentially poor concrete runtime when  $d > 1$ , we restrict our description of the local algorithm to the  $d = 1$  case (though the generalization to  $d > 1$  is straightforward).

The main difference between our two prover algorithms is as follows. In our local algorithm, we bind the  $\log T$  variables of the cycle  $j$  first, starting with the “low-order” bit  $j_1$  of  $j$  and proceeding towards the high-order bit  $j_{\log T}$ . Intuitively, this allows the prover to benefit from local memory accesses during the first  $\log K$  rounds of sum-check because round  $i$  “coalesces” the values at any given register  $k$  across a contiguous chunk of  $2^i$  time steps. So, if fewer than  $2^i$  distinct registers were read or written during these  $2^i$  time steps, then the prover does less than  $2^i$  work to process those time steps in round  $i$ . This leads to less than  $T$  total prover work in round  $i$ , resulting in a prover time that is less than  $T \log K$  across those  $\log K$  rounds. After round  $\log K$ , there are only  $T$  terms to be summed, and the standard linear-time sum-check achieves  $O(T)$  total time for those rounds (as opposed to  $O(T)$  time per round).

The other algorithm binds the  $\log(K)$  variables of the register address  $k$  first, rather than the  $\log T$  variables of  $j$ .

### 8.2.2 Details of the local algorithm for read-checking

Consider the standard linear-time sum-check prover implementation (Section 3.3). Our local-algorithm prover can be viewed as simply running this standard procedure, but optimized for the specific structure of this sum-check instance. Recall that for the local algorithm, we restrict our attention to the case that  $d = 1$ .

**Tracking increments instead of values.** Naively implemented, the standard algorithm requires  $K \cdot T$  space, with the bottleneck being storing all  $K \cdot T$  evaluations of  $\widetilde{\text{Val}}(k, j)$  for  $k \in \{0, 1\}^{\log K}$  and  $j \in \{0, 1\}^{\log T}$ . However, we can avoid this by exploiting the same observation that leads to fast commitments: rather than explicitly storing all  $\widetilde{\text{Val}}(k, j)$  values for  $(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ , the prover can instead just store, for each  $j \in \{0, 1\}^{\log T}$ , the unique register  $k$  that was written at cycle  $j$ , and the non-zero increment  $\text{Inc}(k, j)$  (see Definition 9).

Under this definition, for all  $k \in \{0, 1\}^{\log K}$  and  $j \in \{0, 1\}^{\log T}$ ,

<span id="page-65-0"></span>
$$\widetilde{\text{Val}}(k, j) = \sum_{j' < j} \widetilde{\text{Inc}}(k, j'), \quad (70)$$

where  $j' < j$  is shorthand for  $\text{LT}(j', j) = 1$ , i.e., for  $j'$  being the binary representation of an integer  $\text{int}(j')$  that is strictly less than  $\text{int}(j)$ . Note that Equation (70) is *not* an equality of formal polynomials, but rather an equality that holds pointwise at all  $(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ . Nonetheless, Equation (70) implies that for any  $r_1, \dots, r_i \in \mathbb{F}$  and any  $j \in \{0, 1\}^{\log(T) - i}$ ,

<span id="page-65-1"></span>
$$\widetilde{\text{Val}}(k, r_1, \dots, r_i, j) = \sum_{j' \in \{0, 1\}^{\log T}} \widetilde{\text{Inc}}(k, r_1, \dots, r_i, j) \cdot \widetilde{\text{LT}}(j', r_1, \dots, r_i, j). \quad (71)$$

Indeed, the right hand side of Equation (71) is a multilinear polynomial in the  $\log(K) + \log(T)$  variables  $(k, r_1, \dots, r_i, j)$ , and by Equation (70) and the definition of  $\text{LT}$ , the right hand side and left hand side agree whenever  $(k, r_1, \dots, r_i, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ .

**Simplifying Expression (71).** Break the  $T$  cycles  $j \in \{0, 1\}^{\log T}$  into  $T/2^i$  “chunks” each of size  $2^i$ . For each  $j \in \{0, 1\}^{\log(T) - i}$ , chunk  $j$  refers to the collection of all cycles in  $\{0, 1\}^{\log T}$  whose last  $\log(T) - i$  bits equal  $j$ , i.e., all cycles of the form  $(\hat{j}, j)$  for some  $\hat{j} \in \{0, 1\}^i$ .

We say that chunk  $\bar{j}$  is strictly less than chunk  $j$  (denoted  $\bar{j} < j$ ) if  $\widetilde{\text{LT}}(\bar{j}, j) = 0$ , i.e., if  $\bar{j}$  is the binary representation of an integer strictly less than the integer represented by  $j$ . Similarly, we say that chunk  $\bar{j}$  is strictly greater than chunk  $j$  (denoted  $\bar{j} > j$ ) if  $\bar{j}$  is the binary representation of an integer strictly greater than  $j$ .

If  $j', j'' \in \{0, 1\}^{\log T}$  are respectively in chunks  $\bar{j}$  and  $j$  such that  $\bar{j} < j$ , then  $\widetilde{\text{LT}}(j'', j') = 1$ . Meanwhile, if  $\bar{j} > j$  then  $\widetilde{\text{LT}}(j', j'') = 0$ .

Let  $j^* = (0^i, j)$  denote the first cycle in chunk  $j$ , where  $0^i$  denotes the all-zeros vector of length  $i$ . Then a cycle  $j' \in \{0, 1\}^{\log T}$  is in a chunk  $\bar{j} < j$  if and only if  $j' < j^*$ . Combining this with the preceding paragraph and Fact 3.1, we conclude that:

$$\begin{aligned} \widetilde{\text{Val}}(k, r_1, \dots, r_i, j) &= \left( \sum_{j' \in \{0, 1\}^{\log T} : j' < j^*} \widetilde{\text{Val}}(k, r_1, \dots, r_i, j) \right) + \sum_{\hat{j} \in \{0, 1\}^i, j'' = (\hat{j}, j)} \widetilde{\text{Inc}}(k, j'') \cdot \widetilde{\text{LT}}(j'', r_1, \dots, r_i, j) \\ &= \widetilde{\text{Val}}(k, j^*) + \sum_{\hat{j} \in \{0, 1\}^i, j'' = (\hat{j}, j)} \widetilde{\text{Inc}}(k, j'') \cdot \widetilde{\text{LT}}(j'', r_1, \dots, r_i, j). \end{aligned}$$

It follows from the definition of  $\widetilde{\text{LT}}$  (Equation (87)) that for any  $j'' = (\hat{j}, j)$ ,  $\widetilde{\text{LT}}(j'', r_1, \dots, r_i, j) = \widetilde{\text{LT}}(\hat{j}, r_1, \dots, r_i)$ . Hence, we conclude that

<span id="page-65-2"></span>
$$\widetilde{\text{Val}}(k, r_1, \dots, r_i, j) = \widetilde{\text{Val}}(k, j^*) + \sum_{\hat{j} \in \{0, 1\}^i : j'' = (\hat{j}, j)} \widetilde{\text{Inc}}(k, j'') \cdot \widetilde{\text{LT}}(\hat{j}, r_1, \dots, r_i). \quad (72)$$

**Ensuring the prover runs in  $O(T)$  time per round.** Since there is only one non-zero increment per cycle, the following fact follows easily from Fact 3.1.

<span id="page-65-3"></span>**Fact 8.1.** For any fixed  $j'' \in \{0, 1\}^{\log(T) - i}$ , there at most  $2^i$  registers  $k \in \{0, 1\}^{\log K}$  for which

$$\widetilde{\text{Inc}}(k, r_1, \dots, r_i, j'') \neq 0.$$

In round  $i$ , for fixed  $j' \in \{0, 1\}^{\log(T) - (i-1)}$ , let us refer to the vector

$$\left\{ \widetilde{\text{Val}}(k, r_1, \dots, r_{i-1}, j') : k \in \{0, 1\}^{\log K} \right\}$$

as row  $j'$  of  $\widetilde{\text{Val}}$  in round  $i$ . The prover will proceed iteratively through the rows in lexicographic order, starting with row  $0^{\log(T)-i}$  and proceeding to row  $1^{\log(T)-i}$ .

Per the above, the prover can maintain an array  $I$  that in round  $i$  stores the following values:

<span id="page-66-2"></span>
$$I \text{ in round } i \text{ stores all non-zero evaluations of the form } \widetilde{\text{Inc}}(k, r_1, \dots, r_i, j'') \text{ for } j'' \in \{0, 1\}^{\log(T)-i}. \quad (73)$$

Given these increments, Equation (72) ensures that when processing row  $j'$ , the prover can indeed store in its memory all  $K$  values  $\widetilde{\text{Val}}(k, r_1, \dots, r_i, j')$  as  $k$  ranges over  $\{0, 1\}^{\log K}$ . By Fact 8.1, updating the array  $I$  round over round requires at most  $T$  multiplications for each round  $i = 1, \dots, \log K$ . For a given row  $j'$ , the prover also has to compute the size- $2^i$  sum in Expression (72) for each of the (at most)  $2^i$  values of  $k$  for which  $\widetilde{\text{ra}}(k, r_1, \dots, r_i, j') \neq 0$ . This can be done with only  $2^i$  multiplications per row, using the fact that for any  $\hat{j} \in \{0, 1\}^{i-1}$  and  $b \in \{0, 1\}$ ,

$$\widetilde{\text{LT}}(\hat{j}, b, r_1, \dots, r_i) = \widetilde{\text{eq}}(b, r_i) \cdot \widetilde{\text{LT}}(\hat{j}, r_1, \dots, r_{i-1}) + (1-b)r_i.$$

In summary, for the first  $\log(K)$  rounds of the read-checking sum-check, with  $2T$  multiplications per round, the prover can ensure that in each round  $i$ , it can iterate over rows  $j'$  one-by-one and when processing row  $j'$  ensure that it has in its memory the  $K$  values

$$\widetilde{\text{Val}}(k, r_1, \dots, r_{i-1}, j') : k \in \{0, 1\}^{\log K}. \quad (74)$$

**Computing other necessary arrays and worst-case cost accounting.** Via standard techniques (see Lemma 1), with  $K$  field multiplications across all of the first  $\log K$  rounds, the prover can maintain at each round  $i$  an array  $A$  storing all evaluations  $\widetilde{\text{eq}}(x, r_1, \dots, r_i)$  as  $x$  ranges over  $\{0, 1\}^i$ . Since only one register is read per cycle, at the end of round  $i$ , each row  $j''$  of  $\widetilde{\text{ra}}(\cdot, r_1, \dots, r_i, j'')$  has at most  $2^i$  non-zero entries, and each such entry is an entry of this array (this holds because  $\widetilde{\text{ra}}(k, j) \in \{0, 1\}$  for all  $(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ , and is similar to Equation (46), which considered the case where  $m$  “register variables” rather than  $i$  “cycle variables” were bound to random field elements).

Similarly, with standard techniques, the prover can across all rounds  $i$  maintain an array storing all evaluations  $\widetilde{\text{eq}}(r', r_1, \dots, r_i, j'')$  as  $j''$  ranges over  $\{0, 1\}^{\log(T)-i}$ . This costs  $2T$  field multiplications in total ( $T$  to build the size- $T$  array at the start of the protocol, and  $T$  more to bind it round-over-round over the course of the protocol). These are the arrays (along with  $I$ ) needed to run the standard linear-time sum-check proving algorithm described in Section 3.3. However, a significant optimization is possible to avoid these  $2T$  field multiplications, and more significantly, to also save one field multiplication per relevant evaluation point  $c$  for each of the first  $\log K$  rounds.

**An optimization.** The optimizations of Dao and Thaler [DT24] can be adapted to speed up the prover further.

Specifically, assuming  $K = o(T)$  so  $\sqrt{KT} = o(T)$ , the prover builds two different arrays of size at most  $\sqrt{KT}$ , defined as follows. Let  $r'_L = (r'_1, \dots, r'_{(\log(K)+\log(T))/2})$  and  $r'_R = (r'_{(\log(K)+\log(T))/2+1}, \dots, r'_{\log T})$ . The first array  $E$ , at the end of round  $i$ , stores the following values:

<span id="page-66-0"></span>
$$E \text{ stores } \widetilde{\text{eq}}(r'_L, r_1, \dots, r_i, j'') \text{ as } j'' \text{ ranges over } \{0, 1\}^{(\log(K)+\log(T))/2-i}. \quad (75)$$

Intuitively,  $E(j'')$  captures the contribution of the “left part”  $j''$  of a cycle index  $j = (j'', j''') \in \{0, 1\}^{\log(T)-i}$  to the value  $\widetilde{\text{eq}}(r', r_1, \dots, r_i, j)$ .

The second array  $E'$ , in round  $i$ , stores the following values

<span id="page-66-1"></span>
$$E' \text{ stores } A(x) \cdot \widetilde{\text{eq}}(r'_R, j''') \text{ as } x \text{ ranges over } \{0, 1\}^i \text{ and } j''' \text{ ranges over } \{0, 1\}^{\log(T)/2-\log(K)/2}. \quad (76)$$

This array captures the *combination* (i.e., product) of the contribution of  $j'''$  to  $\widetilde{\text{eq}}(r', r_1, \dots, r_i, j)$  and the value  $\widetilde{\text{ra}}(k, j)$  if  $\widetilde{\text{ra}}(k, r_1, \dots, r_i, j) \neq 0$ , namely  $\widetilde{\text{eq}}(r_1, \dots, r_{i-1}, k_1, \dots, k_{i-1})$ .

For each index  $j'' \in \{0, 1\}^{(\log(K) + \log(T))/2 - i}$ , the prover maintains an “aggregated value”  $\text{agg}_{j''}$ , initialized to 0. When the prover in round  $i$  wants to compute its prescribed message  $s_i(c)$ , it sums over all

$$(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log(T) - i}$$

such that

$$\tilde{r}\tilde{a}(k, r_1, \dots, r_{i-1}, c, j) \neq 0.$$

Recall that for each row  $j \in \{0, 1\}^{\log(T) - i}$ , there are at most  $2^i$  such values of  $k$ .

For each such pair  $(k, j)$ , write  $j = (j'', c, j''')$  with  $j'' \in \{0, 1\}^{(\log(K) + \log(T))/2 - (i-1)}$  and  $j''' \in \{0, 1\}^{\log(T)/2 - \log(K)/2}$ . The prover uses a constant number of lookups into the arrays  $E'$  and  $I$ , followed by a single field multiplication, to compute

$$\tilde{e}\tilde{q}(r'_R, j''') \cdot \tilde{e}\tilde{q}(r_1, \dots, r_{i-1}, c, k_1, \dots, k_{i-1}, k_i) \cdot \tilde{\text{Val}}(k, r_1, \dots, r_{i-1}, c, j),$$

and adds the result to  $\text{agg}_{j''}$ . This ensures that when all relevant pairs  $(j, k)$  have been processed, the following holds:

$$s_i(c) = \sum_{j'' \in \{0, 1\}^{(\log(K) + \log(T))/2 - i}} \text{agg}_{j''} \cdot \tilde{e}\tilde{q}(c, r'_i) \cdot E[j''].$$

**Worst-case cost accounting.** In total, maintaining the arrays  $E$  (Expression (75)) and  $E'$  (Expression (76)) across the first  $\log K$  rounds requires  $O(\sqrt{KT}) = o(T)$  field multiplications. Maintaining the array  $I$  (Expression (73)) costs at most  $2^i \cdot (T/2^i) = T$  multiplications per round, as there are  $T/2^i$  rows in round  $i$  and computing one row given the previous row requires at most  $2^i$  multiplications. This yields a total of  $T \log K$  multiplications to maintain the array  $I$  over the first  $\log K$  rounds. Translating the values in the array  $I$  into necessary evaluations of  $\tilde{\text{Val}}$  costs another  $T$  multiplications per round. We call these (at most)  $2T \log K$  field multiplications *write-induced multiplications*.

Given these arrays, the prover in round  $i = 1, \dots, \log K$  performs at most  $(T/2^i) \cdot 2^i + O(\sqrt{TK}) = T + o(T)$  field multiplications for each of the relevant evaluation points  $s_i(c)$ . Since  $d = 1$ , there are two evaluations points, namely  $c \in \{0, 2\}$ . This means there are  $3 \log(K)T + o(T)$  field multiplications, which we call *read-induced multiplications*.

In total, this means the first  $\log K$  rounds of the sum-check protocol applied to Expression (69) incur at most the following number of field multiplications when  $d = 1$ :

$$4 \log(K)T + o(T).$$

After round  $\log K$ , the number of terms being summed has fallen from  $KT$  down to  $T$ , and the standard linear-time sum-check proving algorithm (appropriately optimized [DT24, Gru24]) requires at most  $6T$  total field multiplications to implement all subsequent rounds. In fact, when  $K = o(T)$ , this falls to roughly  $5T$  due to binding of the  $E$  array taking much less than  $T$  field operations, as in each round  $i$ , there are two different algorithms the prover can choose between to bind  $E$ , one taking time  $2^i$ , which leverages that at the start of the protocol  $E$  contains only values in  $\{0, 1\}$ , and the other taking time  $T \cdot K/2^i$ .

Hence, in total, for small memories the number of prover field multiplications when  $d = 1$  is upper bounded by roughly:

$$(4 \log(K) + 6)T + o(T).$$

### 8.2.3 A refined time bound for local memory accesses

The dominant term in the (worst-case) time bound for our main prover algorithm is  $4 \log(K)T$  field multiplications. This comes from performing 4 multiplications per cycle for each of the first  $\log K$  rounds. One of these four multiplications is *write-induced*: it comes from updating the array  $I$  that stores  $\text{Inc}$  evaluations: there are only  $T/2^i$  “rows” of such evaluations stored in round  $i$ , but computing one row given the previous row can require  $2^i$  field multiplications. This means that every write operation, in the worst case, contributes one field multiplication per round, for each of the first  $\log K$  rounds.

The other (at most) three field multiplications per cycle per round are read-induced. In round  $i+1$ , one of these three comes from translating values in  $I$  into relevant evaluations of the form  $\tilde{\text{Val}}(k, r_1, \dots, r_i, j)$  for  $j \in \{0, 1\}^{\log(T)-i}$ . This costs one multiplication per distinct register  $k$  that is actually read during cycles of the form  $(j'', j)$  with  $j'' \in \{0, 1\}^i$ , and there are  $2^i$  such registers in the worst case. The other two read-induced multiplications per cycle in round  $i+1$  occur as follows. Each of the  $T/2^i$  rows of  $E$  at the end of round  $i$  has at most  $2^i$  distinct values, which means round  $(i+1)$  incurs at most  $2^i \cdot (T/2^i)$  field multiplications per evaluation point  $c \in \{0, 2\}$ . This means that every read operation, in the worst case, contributes two field multiplications per round for the first  $\log K$  rounds.

**Refined cost analysis for write-induced operations.** At the end of round  $i$ , updating the array  $I$  requires at most  $2^i$  field multiplications. However, a tighter bound holds. For any  $j' \in \{0, 1\}^{\log(T)-i}$  consider cycles between  $\text{int}(j') \cdot 2^i$  and  $(\text{int}(j') + 1) \cdot 2^i$ . These are the cycles whose high-order  $\log(T) - i$  bits equal  $j'$ . If at most  $Z$  distinct registers were written during these cycles, then in round  $i$ , computing row  $j'$  of  $I$  from the preceding row requires only  $Z$  field multiplications. In particular, if there were  $D$  duplicate writes during these cycles (meaning a write to a register that was already written during these cycles) then  $Z$  equals  $2^i - D$ .

**Refined cost analysis for read-induced operations.** Similarly, if there were  $D$  “duplicate reads” during these cycles, then the number of field multiplications in round  $i$  due to read operations performed during these cycles falls from a worst-case bound of  $2 \cdot 2^i$  to  $2 \cdot (2^i - D)$ .

In summary, if a write operation is made to a register that was written  $2^i$  cycles previously, then that write operation does not increase the number of distinct write operations in its chunk of write cycles in any round after round  $i$ . Hence, it only contributes  $i$  total multiplications to the prover’s work across all rounds (vs. a worst-case bound of  $\log K$  multiplications).

Similarly, if a read operation is made to a register that was read  $2^i$  cycles previously, then that read operation only contributes  $3i$  total multiplications to the prover’s work across all rounds (vs. a worst-case bound of  $3 \log K$  multiplications).

#### 8.2.4 Write-checking sum-check via the local algorithm

Recall from Equation (34) that the write-checking sum-check is applied to compute

$$\sum_{\substack{k=(k_1, \dots, k_d) \in \{0, 1\}^{\log(K)/d}, j \in \{0, 1\}^{\log T}}} \tilde{\text{eq}}(r, k) \cdot \tilde{\text{eq}}(r', j) \cdot \left( \left( \prod_{i=1}^{d} \tilde{\text{wa}}_i(k_i, j) \right) \cdot (\tilde{\text{wv}}(j) - \tilde{\text{Val}}(k, j)) \right). \quad (77)$$

Let us focus on the case  $d = 1$ . We begin by considering a slightly simpler expression:

<span id="page-68-1"></span><span id="page-68-0"></span>
$$\sum_{\substack{k=(k_1, \dots, k_d) \in \{0, 1\}^{\log(K)/d}, j \in \{0, 1\}^{\log T}}} \tilde{\text{eq}}(r, k) \cdot \tilde{\text{eq}}(r', j) \cdot \tilde{\text{wa}}(k, j) \cdot \tilde{\text{Val}}(k, j). \quad (78)$$

The sum-check invocation computing Expression (78) is almost identical to the one in the read-checking sum-check, with the main difference being the  $\tilde{\text{eq}}(r, k)$  factor appearing in each term of the sum. If  $K^2 = o(T)$ , this factor can be handled with no major modifications to the read-checking sum-check nor any significant increase in prover cost, and if  $K = o(T)$  incorporating this factor increases prover costs by at most  $T$  multiplications. Furthermore, since the sum-check for Expression (78) is run in parallel with the read-checking sum-check, the work to maintain the array  $I$  capturing evaluations of  $\tilde{\text{Val}}$  can be reused within both the read-checking and writing-checking sum-check.

To apply the sum-check protocol to Expression (77) instead of the simpler Expression (78), simply run the prover for Expression (78), but every time the prover processes a value  $\tilde{\text{Val}}(k, r_1, \dots, r_i, j)$ , replace this with  $\tilde{\text{Val}}(k, r_1, \dots, r_i, j) - \tilde{\text{wv}}(r_1, \dots, r_i, j)$ .

<span id="page-69-0"></span>

### 8.2.5 Alternative algorithm for read-checking and write-checking

We describe an alternative prover implementation for the read-checking sum-check in Twist that performs  $O(T)$  field operations for each of the first  $\log K$  rounds. Standard linear-time sum-check prover algorithms implement the final  $\log T$  rounds with roughly  $d^2 T$  field multiplications (see Section 6.2.2 for details).

Let us begin with the read-checking sum-check. Recall that for general  $d > 1$ , the read-checking sum-check within Twist is used to confirm that:

$$\tilde{v}(r') = \sum_{k=(k_1, \dots, k_d) \in \{0,1\}^{\log(K)/d}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{eq}}(r', j) \cdot \left( \prod_{i=1}^{d} \tilde{\mathbf{ra}}_i(k_i, j) \right) \cdot \tilde{\mathbf{Val}}(k, j).$$

We describe the algorithm as if it is sequential, but it is easy to see that a  $(T/K)$ -fold parallel speedup is achievable with at most a constant-factor increase in total prover work, by processing in parallel  $\Theta(T/K)$  “chunks” of operations consisting of  $\Theta(K)$  cycles in each.<sup>34</sup>

Our algorithm is essentially just the standard linear-time sum-check proving algorithm (Section 3.3), but optimized to leverage the specific structure of this particular sum-check instance. Specifically, before round one, the prover computes  $d+2$  arrays, say  $B$ ,  $C$ , and  $A_1, \dots, A_d$ .  $B$  has size  $T$ ,  $C$  has size  $K \cdot T$ , and  $A_1, \dots, A_d$  have size  $K^{1/d} \cdot T$ . As we will see, the prover need not ever explicitly materialize  $C$  or  $A_1, \dots, A_d$  in their entirety, due to their structure in this particular sum-check instance. But for now let us consider a naive implementation of the standard algorithm, despite its unacceptably large runtime.

 $B$  initially stores all evaluations of  $\tilde{\mathbf{eq}}(r', j)$  as  $j$  ranges over  $\{0,1\}^{\log T}$ .  $B$  can be computed with  $T$  multiplications via standard techniques (Lemma 1).  $C$  initially stores  $\tilde{\mathbf{Val}}(k, j)$  for all  $(k, j) \in \{0,1\}^{\log K} \times \{0,1\}^{\log T}$ . And  $A_\ell$  stores  $\tilde{\mathbf{ra}}_\ell(k_\ell, j)$  for all  $k_\ell \in \{0,1\}^{\log(K)/d}$  and  $j \in \{0,1\}^{\log T}$ . By applying the binding procedure described in Section 3.3, the prover ensures that at the end of each round  $\ell \le \log(K)$ ,  $C$  has size  $(K \cdot T)/2^\ell$  and  $C[k', j] = \tilde{\mathbf{Val}}(r_1, \dots, r_i, k', j)$  for all  $(k', j) \in \{0,1\}^{\log(K)-i} \times \{0,1\}^{\log T}$ . Similarly, at the end of each round  $i \le \log(K)/d$ ,  $A_1[k', j] = \tilde{\mathbf{ra}}_1(r_1, \dots, r_i, k', j)$  for all  $k' \in \{0,1\}^{\log(K)/d-i}$  and  $j \in \{0,1\}^{\log T}$ , and similarly  $A_\ell$  halves in size during each of rounds  $(\ell-1) \cdot \log(K)/d + 1, \dots, \ell \log(K/d)$ .

The above naive implementation of the standard linear-time algorithm is extremely wasteful because it ignores the following structure in the arrays  $C$  and  $A_1, \dots, A_d$ .

- At the end of any given round  $i$ , for fixed  $j \in \{0,1\}^{\log T}$ , let us refer to all entries of  $C$  of the form  $C[k', j]$  for some  $k' \in \{0,1\}^{\log(K)-i}$  as the  $j$ th row of  $C$ . Then any two adjacent rows differ in at most one entry. This is because at most one address gets written in each cycle.
- At the end of any given round  $i$ , any given row of  $A_\ell$  has exactly one non-zero entry (see Equation (46) for details).

**Avoiding spending  $K^{1/d} \cdot T$  time and space processing  $A_\ell$ .** Per the second bullet, our prover will store, for each row of  $A_\ell$ , merely the index  $k$  of the non-zero entry in that row, and the associated value of that entry. In fact, it's not even necessary to store that value: in round  $(\ell-1) \cdot \log(K)/d + i$ , there are only  $2^i$  distinct values in the array  $A_\ell$  (see Equation (46) for what those values are), so the prover merely needs to store a lookup table of size  $2^i$  storing those values and that lookup table can be shared amongst all the rows. The first  $i$  bits of the index  $k$  of the non-zero entry in a given row specify the appropriate index in the lookup table storing the associated non-zero value.

**Avoiding spending  $K T$  time and space processing  $C$ .** Per the first bullet, the prover will not explicitly store  $C$ . Rather, in each round  $i+1$ , the prover will iteratively generate each row of  $C$  and “process” that row’s contributions to the prescribe round- $i$  message.

<span id="page-69-1"></span>

<sup>34</sup>Bigger parallel speedups are possible at the cost of increased total prover work. Also, sharding described in Section 3.1.1 provides additional opportunities for parallelism beyond whatever parallelism is available when processing a single shard.

In more detail, via repeated application of Fact 3.1, one easily derives that for any  $k' \in \{0, 1\}^{\log(K)-i}$  and any  $j \in \{0, 1\}^{\log T}$ ,

<span id="page-70-0"></span>
$$C[k', j] = \sum_{k'' \in \{0, 1\}^i} \tilde{\text{Val}}(k'', k', j) \cdot \tilde{\text{eq}}(k'', r_1, \dots, r_i). \quad (79)$$

Suppose that  $k = (k'', k') \in \{0, 1\}^i \times \{0, 1\}^{\log(K)-i}$  is the (binary representation of) the address written at cycle  $k$ . Let  $\text{next}(j)$  be the binary representation of the “next” row, i.e., of  $\text{int}(j) + 1$ . Then by Equation (79), for any  $k''' \neq k'$ ,  $C[k''', j] = C[k''', \text{next}(j)]$ . That is, the only column that differs between rows  $j$  and  $\text{next}(j)$  is column  $k'$  (i.e.,  $k'$  is the column whose trailing  $\log(K) - i$  bits equal those of the binary representation of the register that was written at cycle  $j$ ).

Moreover, recall from the Twist PIOP that the *increment*  $\text{Inc}(k, j)$  is the difference between the value stored at register  $k$  at cycle  $j+1$  vs. cycle  $j$ . Then if  $k = (k'', k')$  is the cell written at cycle  $j$ ,

<span id="page-70-1"></span>
$$C[k', (j)] - C[k', j] = \text{Inc}(k, j) \cdot \tilde{\text{eq}}(k'', r_1, \dots, r_i). \quad (80)$$

And via standard techniques (see Lemma 1) the prover can, with  $K$  field operations across all of the first  $\log K$  rounds, build an array that in round  $i$  stores all values of the form  $\tilde{\text{eq}}(k'', r_1, \dots, r_i)$  as  $k''$  ranges over  $\{0, 1\}^i$ .

Hence, putting all of the above together, the prover can, in each round  $i = 1, \dots, \log K$  of the read-checking sum-check, iterate one-by-one over all cycles  $j \in \{0, 1\}^{\log T}$ , and ensure at all times that it has in its memory the  $j$ 'th row of  $C$ , i.e.,  $C[k', j]$  as  $k'$  ranges over  $\{0, 1\}^{\log(K)-i+1}$ . By Equation (80), the total number of field multiplications needed to accomplish this is  $T$  per round.

**Total prover costs.** To get through the first  $\log K$  rounds of the read-checking sum-check, the prover incurs the following costs.

- $T$  field multiplications to build the array  $B$  of  $\tilde{\text{eq}}(r', j)$  evaluations.
- $O(dK^{1/d})$  multiplications to maintain the arrays  $A_1, \dots, A_d$ .
- $T \log K + O(K)$  to maintain the array  $C$  throughout.
- If one directly applies the standard linear-time sum-check prover, then given the above arrays, the prover incurs 4 field multiplications per row  $j \in \{0, 1\}^{\log T}$  per round. Here, 4 comes from there being two relevant evaluation points  $c \in \{0, 2\}$  in each of these rounds, and two multiplications needed for each of them (one to multiply an entry of  $C$  by an evaluation of the relevant array  $A_c$  for that round, and another to multiply the result by the  $\tilde{\text{eq}}(r', j)$  value for that row  $j$ ).

However, the optimization adapted from [DT24] that applied to the local algorithm also applies here. Roughly, this entails replacing the array  $B$  and the arrays  $A_1, \dots, A_d$  with  $2d \sqrt{KT}$ -sized arrays (two per  $A_i$ ). This eliminates the  $T$  multiplications needed to build  $B$  and one of the two multiplications per evaluation point  $c$ .

Hence, if  $K = o(T)$ , the first  $\log K$  rounds of Twist's read-checking sum-check require  $3 \log(K)T + o(T)$  field multiplications of the prover. The last  $\log T$  rounds require  $(d^2 + 2d + 1)T$  field multiplications via the standard linear-time sum-check algorithm (Section 3.3), appropriately optimized [DT24, Gru24].

**Write-checking sum-check.** As with the local algorithm, implementing the write-checking sum-check prover is similar to the read-checking case. The situation is actually nicer in the case of the alternative algorithm, since for the alternative algorithm both the read-checking and write-checking sum-checks bind the  $\log K$  variables of  $k$  before the  $\log T$  variables of  $j$ . If  $K = o(T)$ , this ensures that the total number of prover multiplications incurred to implement the write-checking sum-check (on top of the work the prover does in the read-checking sum-check) is at most

$$(2 \log(K) + d^2 + 2d + 2)T.$$

### 8.3 Cost summary

**Local algorithm for  $d = 1$ .** If  $K = o(T)$ , then using the local proving algorithm, the entire core Twist PIOP with  $d = 1$  can be implemented with the following number of field multiplications, up to low-order terms:

- $4T$  from the  $\tilde{\text{Val}}$ -evaluation sum-check.
- $(4 \log(K) + 6)T$  from the read-checking sum-check.
- An additional  $(3 \log(K) + 5)T$  from the write-checking sum-check.

This is at most  $(7 \log(K) + 15)T$  field operations to process  $T$  reads and  $T$  writes. For  $K = 32 = 2^5$ , this is  $50T$  field multiplications. For  $K = 2^{20}$ , it is  $155 \cdot T$ .

However, the costs benefit significantly from locality. For large memories, the dominant term by far is the  $7 \log(K)T$  field operations,  $4 \log K$  of which can be attributed to each write and  $3 \log K$  to each read. If a write operation is  $2^i$ -local, then  $4 \log K$  falls to  $4i$  and similarly if a read operation is  $2^i$ -local, then  $3 \log K$  falls to  $3i$ .

Checking correctness of one-hot encodings (Figure 8) for all  $2T$  committed addresses must be done in addition to the above costs. Per Section 6.3, this costs  $6dT + O(dK^{1/d})$  field multiplications (up to low-order terms, all of this extra cost is coming from Booleanity-checking).

**The alternative algorithm.** The alternative algorithm has similar (in fact, slightly better) costs in the worst-case to the local algorithm when  $d = 1$ , but generalizes more nicely to  $d > 1$  because it binds the variables of  $k$  before the variables of  $j$ , and the degree in the variables of  $k$  is independent of  $d$  for all of the polynomials that the sum-check protocol is applied to within Twist. Specifically, the costs are:

- $4T$  from the  $\tilde{\text{Val}}$ -evaluation sum-check.
- $(3 \log(K) + d^2 + 2d + 1)T$  from the read-checking sum-check.
- An additional  $(2 \log(K) + d^2 + 2d + 2)T$  from the write-checking sum-check.

In total, this is at most  $(5 \log(K) + 2d^2 + 4d + 4)T$  field multiplications. For  $d = 1$ , this is

$$(5 \log(K) + 10)T,$$

slightly improving the worst-case bound of  $(5 \log(K) + 19)T$ .
