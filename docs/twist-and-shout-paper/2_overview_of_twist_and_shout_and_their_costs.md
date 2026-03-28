## 2 Overview of **Twist** and **Shout** and their costs

<span id="page-6-1"></span>

### 2.1 Background

**zkVMs and Jolt.** The RISC-V instruction set architecture involves 32 registers. In each CPU cycle, at most two registers are read and one is written. The Jolt zkVM [AST24] forces an untrusted prover to correctly process reads and writes to registers (and random access memory) using an offline-memory-checking procedure called *Spice* [SAGL18]. Spice's application in Jolt currently accounts for about 20% of total prover time today, with most of this cost coming from registers (which are read and written nearly every CPU cycle, unlike RAM, which is accessed only via explicit load and store instructions).

On top of the cost of Spice for checking registers and RAM, another 25% of Jolt prover time is spent on Lasso [STW24], an offline-memory-checking procedure tailored to read-only memories. Jolt uses Lasso to ensure the prover correctly executes the appropriate primitive RISC-V instruction during each CPU cycle (Jolt turns primitive instruction execution into a handful of lookups into fixed tables of size about  $2^{16}$ ). So in total, the Jolt prover currently spends almost half of its time in offline-memory-checking procedures. We anticipate that the fraction of Jolt's prover costs will grow substantially over time, as other parts of the Jolt protocol continue to be optimized.

**Polynomial IOPs and polynomial commitments.** As with most SNARKs, Jolt consists of a *polynomial IOP* (PIOP), which can be combined with any polynomial commitment scheme (for multilinear polynomials, in the case of Jolt) to obtain a SNARK. A polynomial IOP is an interactive protocol where the prover is allowed to send one or more large polynomials to the verifier, but the verifier is only allowed to query those polynomials' evaluation at, say, a single randomly chosen point.

A polynomial commitment scheme is a cryptographic protocol specifically designed to transform any polynomial IOP into a succinct argument. Specifically, rather than having the polynomial IOP prover explicitly send large polynomials to the verifier, a polynomial commitment scheme allows a prover to succinctly commit to those polynomials, and later reveal only the evaluations of the polynomials that are queried by the verifier (along with *evaluation proofs*, which prove that the returned evaluations are indeed consistent with the committed polynomials). One can render the succinct argument non-interactive with the Fiat-Shamir transformation [FS86a].

Jolt uses multilinear polynomial commitment schemes based on elliptic curves, like HyperKZG [ZSC24] and Zeromorph [KT23]. The commitment to a polynomial of size  $n$  with these schemes consists of a single group element, and evaluation proofs consist of  $O(\log n)$  group elements.<sup>4</sup> In the future, Jolt plans to incorporate support for hashing-based commitment schemes over binary fields.

**Costs of elliptic-curve-based commitments.** When a polynomial IOP is combined with an elliptic curve commitment scheme (e.g., HyperKZG [ZSC24]), the vast majority of the work done by the prover consists of elliptic curve group operations and finite field operations (over the field  $\mathbb{F}$  used by the polynomial IOP, which is also the *scalar field* of an elliptic curve). For small memories, the method of one-hot addressing substantially lowers *both* the number of field operations over  $\mathbb{F}$  and the number of group operations performed by the prover.

There are two facts about elliptic curve commitments that the method of one-hot addressing takes heavy advantage of. The first is that committing to 0s is “free”. That is, when committing to a vector  $v \in \mathbb{F}^\ell$ , any  $i$  for which  $v_i = 0$  literally does not affect the commitment, and can just be “ignored” by the prover when computing the commitment to  $v$ . The number of committed 0s does influence some other prover costs arising in the protocol, especially the size of the commitment key, but it does not influence commitment time. Fortunately, the effect of the 0s on these other costs can be controlled, see Section 3.1 for details. Hence, in this informal overview it is both clearest and reasonably accurate to treat committed 0s as literally free for the prover. Second, *small* (but non-zero) values are cheap (but not free) to commit to. For example, any  $i$  such that  $v_i = 1$  costs the prover just one group operation when computing the commitment.

For simplicity, in this work we consider any value in  $\{0, 1, \dots, 2^{32} - 1\}$  to be “small”. We select the threshold of  $2^{32} - 1$  as the limit of smallness for convenience of accounting: most zkVMs today use 32-bit data types, and so registers store arbitrary elements of  $\{0, 1, \dots, 2^{32} - 1\}$ .<sup>5</sup> Since the prover has no choice but to commit to the values read from or written to registers, it is convenient to call these values small. But this is also a reasonable notion of smallness: at practical instance sizes, committing to a 32-bit value with an elliptic curve commitment scheme takes roughly two group operations via Pippenger’s bucketing algorithm<sup>6</sup>. This is much cheaper than committing to an arbitrary field element, which can require a dozen group operations or more.<sup>7</sup>

**Costs of hashing-based commitments over binary fields.** A nice property of hashing-based commitment schemes relative to curve-based ones is that the commitment key is small (often it simply specifies a cryptographic hash function), no matter the size of the vectors that need to be committed. However, hashing-based commitments have a major downside: committing to 0s is not free. This is a challenge because,

<span id="page-7-0"></span>

<sup>4</sup>If  $p$  is a  $v$ -variate multilinear polynomial, then its size is  $2^v$ . This is because  $p$  is uniquely described by  $2^v$  coefficients, or equivalently its evaluations over an interpolating set such as  $\{0, 1\}^v$ , which has size  $2^v$ .

<span id="page-7-2"></span><span id="page-7-1"></span>

<sup>5</sup>In this work, we use the terms *register* and *memory cell* interchangeably.

<span id="page-7-3"></span>

<sup>6</sup>See [EHB22, Section 4] for a clear overview of Pippenger’s algorithm and its costs

<sup>7</sup>For maximal precision of cost accounting it may be useful to distinguish the “smallness” of elements of, say,  $\{0, 1, \dots, 2^{16} - 1\}$  vs.  $\{2^{16}, \dots, 2^{32} - 1\}$ . The former take only about one group operation to commit to at practical instance sizes, while the latter require about two group operations. To simplify our cost accounting, we do not make this distinction in this paper. However, our findings would not be substantially changed if we did.

when **Twist** and **Shout** (say, with  $d = 1$ ) are applied to prove  $T$  memory operations into a memory of size  $K$ , the prover needs to commit to  $K \cdot T$  values, and we cannot tolerate  $\Theta(K \cdot T)$  prover time.

Fortunately, all of these  $K \cdot T$  values are known *a priori* to be in  $\{0, 1\}$ : not only are almost all of the values 0, the non-zeros are always equal to 1. There is one (recently-identified) subclass of hashing-based commitment schemes that make such known-to-be-in- $\{0, 1\}$  values sufficiently fast to commit to that **Twist** and **Shout** are useful when combined with such commitments. These are hashing-based commitment schemes for multilinear polynomials over *binary fields*, which allow the prover to “pack” 128 values into a single element of  $\text{GF}(2^{128})$ , and commit to the packed values with an appropriate multilinear commitment scheme defined over  $\text{GF}(2^{128})$ .<sup>8</sup> This packing technique results in a 128-fold reduction in the number of committed  $\text{GF}(2^{128})$  field elements, compared to the naive approach of assigning an entire  $\text{GF}(2^{128})$ -element to represent each committed value. Examples include Binius [DP23], FRI-Binius [DP24], and Blaze [BCF+24].

For tiny memories like the 32 registers in RISC-V,  $d = 1$  is fine: the means the prover commits to 32 bits per address, and four such addresses can be packed into a single  $\text{GF}(2^{128})$  field element before committing.<sup>9</sup>

As another attractive example, consider applying **Twist** with  $d = 4$  to a memory with  $K = 2^{20}$  cells (which corresponds to a zkVM with about 4 MBs of memory). Rather than committing to  $K$  values in  $\{0, 1\}$  per memory operation as in **Twist** with  $d = 1$ , with  $d = 4$  the **Twist** prover commits to only  $4 \cdot 2^5 = 128$  values in  $\{0, 1\}$ . These 128 values can all be packed into a single element of  $\text{GF}(2^{128})$  before committing with the above hashing-based commitment schemes. On the other hand, increments are not guaranteed to be in the set  $\{0, 1\}$  (although most increments will be 0s). Each increment is guaranteed to be an element of  $\text{GF}(2^{32})$ , so four increments can be packed into single element of  $\text{GF}(2^{128})$  before committing.

<span id="page-8-0"></span>

## 2.2 Formulation of the memory checking problem

**Motivation.** Most primitive RISC-V instructions read two registers (the “source registers” containing the inputs to the primitive instruction executed at that cycle) and writes to one register (the “destination register”) that stores the output of the primitive instruction. We denote the source registers  $\text{ra}_1$  and  $\text{ra}_2$  ( $\text{ra}$  is short for read address), and the destination register by  $\text{wa}$  (short for write address).

To force an untrusted prover to prove that it is reading and writing to registers correctly, RISC-V zkVMs demand that the prover commit to

- the register addresses  $\text{ra}_1$ ,  $\text{ra}_2$ , and  $\text{wa}$  each cycle.
- the values that the prover claims is returned by the reads to  $\text{ra}_1$  and  $\text{ra}_2$ ,
- the value that is written to  $\text{wa}$ .

The goal of the memory checking problem is to devise a succinct argument that lets the prover prove that indeed the value committed for every read operation is the value most recently written to the relevant register.

**Formulation for read/write memories.** Say there are  $K$  memory cells, which we will refer to as *registers* for short (for example, there are  $K = 32$  registers in RISC-V). In the case of read/write memory, let us assume that operations alternate between reads and writes.<sup>10</sup> Let  $T$  denote the *number of cycles* being checked. More specifically,  $T$  denotes the number of read operations in the case of read-only memory. For read/write memory, each cycle consists of a read followed by a write, so there are  $T$  reads and  $T$  writes (i.e.,  $2T$  memory operations in total).

<span id="page-8-1"></span>

<sup>8</sup>All hashing-based polynomial commitment schemes ultimately need to work over a field that is at least 128 bits in size to ensure adequate security.

<span id="page-8-2"></span>

<sup>9</sup>Committing to  $N$   $\text{GF}(2^{128})$  elements with these schemes involves  $\Theta(N)$  or  $\Theta(N \log N)$   $\text{GF}(2^{128})$  multiplications to apply the encoding procedure of an error-correcting code, followed by  $\Theta(N)$  cryptographic hash evaluations. Computing evaluation proofs for these schemes can be fairly expensive for the prover, due to various invocations of the sum-check protocol in order to relate the “packed” committed values to the unpacked values.

<span id="page-8-3"></span>

<sup>10</sup>In a zkVM for RISC-V like Jolt, there are two committed register read operations and one committed register write operation per CPU cycle. But since this paper is focused on memory-checking, we find it clearest to use the term cycle to refer to a single memory operation rather than, say, a sequence of two reads and one write.

The memory-checking problem begins with the prover sending commitments to four vectors: `raf`, `waf`, `rv` and `wv`. We denote the  $j$ ’th entry of these vectors with function notation, i.e., the  $j$ ’th entry of `raf` is `raf`( $j$ ).

The  $j$ ’th entries of `raf` and `waf` specify the address of the registers read and written in cycle  $j$ . In the context of zkVMs (and in typical offline-memory checking procedures like Spice), each register is indexed by one field element, and so `raf` and `waf` are also both in  $\mathbb{F}^T$ , with `raf`( $j$ ), `waf`( $j$ )  $\in \mathbb{F}$  specifying the register addresses read and written at cycle  $j$ . Here, any injective mapping from registers to field elements suffices for the indexing. In large prime-order fields, the  $K$  field elements used to address the registers can simply be  $\{0, 1, \dots, K-1\}$ ; for simplicity, this is the mapping we use throughout this manuscript. We use the letter  $f$  at the end of `raf` and `waf` to reflect that these are addresses specified via one field element per address. The  $j$ ’th entry of `rv` specifies the value returned by the  $j$ ’th read operation, and `wv` specifies the value written by the write operation. `rv` and `wv` are vectors in  $\mathbb{F}^T$  (i.e., registers store field elements).

The memory checking problem then demands that the prover establish that `rv`( $j$ ) equals `wv`( $j'$ ) where  $j' < j$  denotes the largest cycle number less than or equal to  $j$  such that `waf`( $j'$ ) = `raf`( $j$ ). If no such  $j'$  exists, then it is required that `rv`( $j$ ) = 0. Conceptually, this means that all registers are initialized to contain value 0, and every read to a register is required to return the value most recently written to that register.

It is also possible to demand that the contents of memory be initialized to a set of values that is not identically 0. In this case, either the vector of initial memory values (one value per cell) is committed by an honest party, or is simply public.<sup>11</sup>

**Read-only memories.** Our formulation of the memory-checking problem for read-only memories is identical to read/write memories, except that the contents of the memory cells are public (i.e., known to both the verifier and the prover) and each cycle involves only a read operation, rather than a read followed by a write. We sometimes refer to the contents of the read-only memory as the *lookup table*.<sup>12</sup>

**One-hot encoding of addresses.** Recall that in the above formulation of the memory-checking problem, each address is indexed by a single field element. This is how memory addresses are naturally specified in zkVM contexts. For example, in RISC-V, when performing a load or store from RAM, the relevant address is the value stored in the first source register, plus the “immediate” value for that instruction. Each zkVM register naturally stores a single field element, and the immediate value for any instruction is naturally represented by a single field element.

However, internal to the **Twist** and **Shout** proof systems, the register addresses must actually be specified via one-hot encoding. This means that within the **Twist** and **Shout** protocols, each address is a unit vector in  $\{0, 1\}^K \subseteq \mathbb{F}^K$ . Accordingly, we introduce two vectors `ra`, `wa`  $\in \mathbb{F}^{T \cdot K}$  that, for a sequence of  $T$  memory operations, specify all  $T$  memory addresses via one-hot encoding. We think of `ra` and `wa` as consisting of  $T$  rows each of length  $K$ . If the prover is honest, then the  $j$ ’th row of `ra`, denoted `ra`( $j$ ), specifies via one-hot encoding the register read at cycle  $j$ , and similarly for `wa`. So if register  $\ell$  is read at cycle  $j$ , then `ra`( $j$ ) is the  $\ell$ ’th unit vector  $e_\ell \in \{0, 1\}^K$ . We denote the  $k$ ’th entry of this vector by `ra`( $k, j$ ).

Because zkVMs naturally specify addresses via a single field element, when used within zkVMs, memory-checking arguments do need to give the verifier “access” to the vectors `raf` and `waf`, in which each address is specified via a single field element. In particular, the zkVM verifier needs to be able to evaluate the *multilinear extension polynomials* `raf` and `waf` at a random point. **Twist** and **Shout** support this. Even though `raf` and `waf` are *not* committed by the **Twist** and **Shout** provers (only `ra` and `wa` are), we still give a way for the verifier to evaluate `raf` and `waf` at a random point.

<span id="page-9-0"></span>

<sup>11</sup>In many applications, the initial contents of memory have a description that is much smaller than explicitly listing the value stored in each memory cell, and with some memory-checking arguments it is possible in these settings to avoid having the verifier spending time linear in the size of the memory to “process” the initial values [STW24, AST24].

<span id="page-9-1"></span>

<sup>12</sup>Many lookup arguments, including Arya [BCG<sup>+</sup>18], plookup [GW20b], Caulk [ZBK<sup>+</sup>22], and LogUp [Hab22], actually solve a different problem, which is sometimes referred to as *unindexed lookups* (in contrast to reads into read-only memory, which is sometimes referred to as *indexed lookups*) [STW24]. Unindexed lookup arguments ensure that a vector of committed values all reside *somewhere* in a read-only memory, but do not specify an address at which each value must reside. Unindexed lookup arguments can be transformed into indexed ones, though the transformation adds prover and verifier overheads. See [STW24] for details.

To use a term coined in work on Binius [DP23], **Twist** and **Shout** can be integrated into zkVMs by treating  $\tilde{\mathsf{raf}}$  and  $\tilde{\mathsf{waf}}$  as *virtual polynomials*: they are not explicitly committed by the prover, but can still be evaluated by the verifier at any point, by asking the prover to provide the requested evaluation and then prove that the evaluation is correct. This is done expressing the needed  $\tilde{\mathsf{raf}}$  and  $\tilde{\mathsf{waf}}$  evaluations in terms of  $\tilde{\mathsf{ra}}$  and  $\tilde{\mathsf{wa}}$ , and then applying the sum-check protocol to compute this expression. This effectively reduces the verifier's task of evaluating  $\tilde{\mathsf{raf}}$  and  $\tilde{\mathsf{waf}}$  at a point, to the task of evaluating  $\tilde{\mathsf{ra}}$  and  $\tilde{\mathsf{wa}}$  at a different point. These evaluations can be obtained directly from the commitments to  $\tilde{\mathsf{ra}}$  and  $\tilde{\mathsf{wa}}$ . See Section 4.1.2 for details.

**Can read-values be virtual too?** We formulated the memory-checking problem above to assume that the vector  $\mathbf{rv}$  of values returned by read operations are committed by the prover (or more precisely, their multilinear extension polynomial  $\tilde{\mathbf{rv}}$  is committed). However, the “correct” value of every read operation is fully determined by the write operations and the read-addresses (or, in the case of read-only memories, simply by the read-addresses  $\tilde{\mathbf{ra}}$ ). And in applications to zkVMs, the SNARK verifier only ever needs to evaluate  $\tilde{\mathbf{rv}}$  at a random point  $r$ .<sup>13</sup>

So, in principle,  $\tilde{\mathbf{rv}}$  need *not* be committed: as soon as the prover commits to  $\tilde{\mathbf{ra}}$  and to any polynomials specifying writes,  $\tilde{\mathbf{rv}}$  is *implicitly* specified as well, and all we need to ensure is that the verifier is able to evaluate  $\tilde{\mathbf{rv}}$  at a random point  $r$ . **Twist** and **Shout** directly give a protocol to accomplish this: from the verifier's perspective, **Twist** and **Shout** use the sum-check protocol to reduce the task of evaluating  $\tilde{\mathbf{rv}}(r)$  to the task of evaluating different polynomials that *are* committed by the prover.

Hence, unlike prior memory-checking arguments, **Twist** and **Shout** do allow the polynomial  $\tilde{\mathbf{rv}}$  to be virtual, rather than committed by the prover. Our prover cost estimates throughout this work reflect this.

**Relevant memory sizes.** In the motivating example of 32 RISC-V registers, the memory size  $K$  is tiny (32 cells), especially relative to the number of CPU cycles executed. Even simple computer programs often run for at least  $2^{30}$  CPU cycles in total, and real computer programs often run for  $2^{50}$  cycles or more.<sup>14</sup> Indeed, the clock rate of modern laptops allows for several billion CPU cycles to be executed per second, even by a single thread. Our results are strongest (and cleanest to understand) in this parameter regime where  $K \ll T$ , since then our the  $O(K + T)$  field operations incurred by the **Twist** and **Shout** provers is clearly dominated by the  $T$  term.

However, all possible relationships between  $K$  and  $T$  are also of interest. For example, L1 cache in real CPUs is often dozens of KBs, corresponding to  $K \approx 2^{13}$  memory cells, and L2 cache is an order of magnitude larger ( $K \approx 2^{16}$ ).<sup>15</sup> And many programs may only use MBs of main memory (RAM), while others can use GBs (translating to  $2^{30}$  memory cells or even more).

Less intuitively, in the case of read-only memories, we are also interested in the situation where  $K \approx 2^{64}$  is so big that the entire contents of the memory cannot possibly be materialized. This setting arises in Jolt, where primitive instruction execution is handled by performing lookups into the “evaluation table” of the primitive instruction, which has size  $2^{64}$ . These tables are highly structured, which ensures no one ever needs to materialize the entire gigantic memory. In other words, for “structured” read-only memories, one can achieve a prover runtime that is sublinear in  $K$ .

<span id="page-10-0"></span>

## 2.3 Prior work: Arguments via offline memory checking

Memory-checking procedures such as Spice [SAGL18] work by reducing the task of proving that all reads and writes were processed correctly, to the task of proving two related vectors  $a \in \mathbb{F}^\ell$  and  $b \in \mathbb{F}^\ell$  are permutations of each other. The precise value of  $\ell$  differs amongst different memory-checking procedures, but is typically  $O(T + K)$ . Confirming that  $a$  and  $b$  are permutations of each other is done via “Lipton’s trick” [Lip89, Lip90]:

<span id="page-10-1"></span>

<sup>13</sup>It is, of course, essential that the prover not be able to choose the polynomial  $\tilde{\mathbf{rv}}$  with knowledge of the point  $r$  at which the verifier will evaluate it.

<span id="page-10-2"></span>

<sup>14</sup>Though in zkVMs today, program executions are broken into “shards” consisting of only about  $2^{20}$  cycles each, with each shard proved semi-independently, in order to keep the prover space bounded. See Section 3.1.1 for additional details.

<span id="page-10-3"></span>

<sup>15</sup>Reads into L1 cache on real CPUs typically take just 1-4 clock cycles, while reads into L2 cache often take 5-20 cycles.

the verifier picks a random  $r \in \mathbb{F}$ , and confirms that

<span id="page-11-0"></span>
$$\prod_{i=1}^{\ell} (a_i - r) = \prod_{i=1}^{\ell} (b_i - r). \quad (1)$$

Equation (1) clearly holds if  $a$  and  $b$  are permutations of each other, and if they are not, it holds with probability at most  $\ell/|\mathbb{F}|$  over the random choice of  $r$ .

Appendix A provides a brief overview of how these transformations from checking read-write memories to checking permutations work.

Offline memory-checking procedures confirm that Equation (1) holds using a *grand product argument*: a SNARK for computing the product of many committed values. Many memory-checking procedures in the literature invoke grand product arguments that interpret the committed vectors as univariate polynomials, and prove that a certain divisibility relationship holds between the committed polynomials. These arguments can lead to excellent verifier costs (often with proofs consisting of only a constant number of group elements), but generally lead to slow provers.

The grand product arguments used by Spice as instantiated in Jolt (as with the method of one-hot addressing) interpret committed vectors as *multilinear polynomials* and invokes the sum-check protocol of Lund, Fortnow, Karloff, and Nisan [LFKN90]. There are several such grand product arguments one can choose from, offering various tradeoffs between prover time and verifier costs [Tha13, Set20, SL20]. Depending on which grand product argument it invokes, Spice can have proofs of size between  $O(\log^2 n)$  and  $O(\log n)$  field elements, where  $n$  is the number of memory operations proven. The bigger the proofs, the faster the Spice prover.

As described in Appendix A, there are only a handful of known approaches to offline memory-checking for read/write memory [SAGL18, ZGK+18]. For *read-only* memories there is somewhat more diversity in solutions. Memory-checking arguments for read-only memories are also known as *lookup arguments*, and examples include Arya [BCG+18], plookup [GW20b], cq [EFG22], Lasso [EFG22], LogUp [Hab22, PH23], and others. We give a brief overview of this body of work in Appendix A.

**Baselines for read/write memory: costs of Spice.** We refer to Appendix A for an overview of how Spice works. Here, we merely discuss its costs. On each read to memory, the Spice prover commits to 5 values. The first three of these are an address, value, and “timestamp”, while the remaining two arise during range checks that are performed on values derived from the timestamp. In the context of memory-checking within zkVMs like Jolt, all five of these values are “small”, and hence fast to commit to (see Section 3.1 and Footnote 7 for details).<sup>16</sup> (If proving more than  $2^{32}$  memory operations, the committed timestamps will not actually meet our threshold for “smallness”. But we will treat them as small for simplicity of accounting—this only leads to an underestimate of the speedups we achieve relative to Spice.)

On top of committing to these 5 values, each read contributes six additional terms contributed to various grand products (see Equation (1)), and proving these grand products requires work by the prover. (Additionally, irrespective of how many memory operations are processed, each memory cell contributes two committed values and two factors to the grand product).

Using the fastest known grand product argument, due to Thaler [Tha13]<sup>17</sup>, the prover can process these six factors per read with about six field multiplications each, so roughly 40 field operations in total. This grand product argument has proofs of size  $O(\log^2 n)$ . In total this means the Spice prover using Thaler’s grand product argument does  $40T + 40K$  field operations.

Setty and Lee, in a work called Quarks [SL20], describe an alternative that has proofs of size  $O(\log n)$  but has much higher prover costs. In particular, for computing a grand product over a vector of size  $n$ , the

<span id="page-11-1"></span>

<sup>16</sup>Whether we should count committed addresses and write-values towards the costs of the memory-checking procedure is debatable, since the addresses and write-values have to be committed simply to specify the memory-checking instance that Spice is applied to. We choose to count these two committed values towards prover costs. This accounting only has the effect of reducing our claimed factor speedups relative to prior work, since it increases the costs of all memory-checking arguments by the same absolute amount.

<span id="page-11-2"></span>

<sup>17</sup>Thaler’s grand product argument is a refinement of the GKR protocol [GKR15], and our cost accounting for it incorporates recent optimizations [Gru24, DT24].

prover has to commit to  $n$  partial products, which are going to be random field elements in our context. In the memory checking context, in addition to performing about 40 field operations per read operation as with Thaler's grand product argument, the prover in Quarks' has to commit to 6 *random* field elements per operation.<sup>18</sup> Committing to six random field elements is expensive, equivalent in cost to performing over 500 field operations. Quarks more generally describe a spectrum of grand product arguments that have prover time and proof size costs “in between” the above two extremes.

Writes to memory in Spice have similar costs to reads; the only difference is that rather than the Spice prover committing to 5 values, for each write it commits to 6 values.

The above describes Spice's costs in large prime-order fields. Prover costs are slightly higher for fields of small characteristic (e.g., binary fields), due to complications with how committed timestamps must be specified in these fields [DP23, Section 4.4]. This applies to prior lookup arguments as well.

**Baselines for read-only memory: Small or unstructured tables.** Lasso's prover [STW24] commits to  $3T + K$  small values in total, and performs about  $12T + 12K$  field operations within the grand product argument. Inspired by the use of Thaler's grand product argument [Tha13] in Spark [Set20] and Lasso [STW24], LogUpGKR [PH23] combines the LogUp lookup argument [Hab22] with GKR protocol. LogUpGKR's prover commits  $2T + K$  small values, which is slightly fewer than the  $3T$  committed by Lasso, at least when  $K \le T$ . But LogUpGKR's prover performs about twice as many field operations as Lasso's prover. This stems from LogUpGKR's use of a “grand sum of rational values” in place of a grand product: summing two rationals,  $a/b + c/d$ , requires three products, namely  $a \cdot d$ ,  $b \cdot c$ , and  $b \cdot d$ , to ultimately derive  $a/b + c/d = (ad + bc)/bd$ .

We state the costs of these baselines in Figures 1–3. For all baselines, we incorporate all of the most recent known optimizations to the prover in the GKR protocol and Thaler's grand product argument [DT24, Gru24]. Further, we assume that the multilinear extension of the table values is efficiently evaluable by the verifier (as is the case for all lookup tables in Jolt, see Footnote 11).

Other relevant baselines are FLI [GM24], a folding scheme for lookups, and Proofs for Deep Thought [BC24], a folding scheme for read/write memory. We discuss these schemes further in Section 2.4.2 below.

**Baselines for read-only memory: Gigantic, structured tables.** Lasso [STW24] gives two different approaches to performing lookups into gigantic, structured tables. By gigantic, we mean the table size  $K$  is on the order of  $T^C$  for some integer  $C \ge 2$ . One, called Generalized-Lasso, applies to any MLE-structured table but requires the prover to commit to  $c$  random field elements, which is generally a bottleneck for the prover. The other, called simply Lasso, applies to tables satisfying a natural decomposability property, which roughly means that one lookup into the giant table can be turned into  $O(C)$  lookups into “subtables” of size at most  $T^{1/C}$  (Lasso then applies a “base” lookup argument to prove validity of the  $O(C)$  subtable lookups). Lasso does not require the prover to commit to any random field elements. Other works have considering using different “base” lookup arguments within this approach [Dor24].

In order to prove that primitive instructions were correctly executed, Jolt applies Lasso to gigantic decomposable tables (namely, the entire evaluation table of the relevant primitive instruction). However, there are some overheads that come from the interaction of how zkVMs work with Lasso's use of decompositions. Specifically, the addresses of the subtable lookups have two “parts”, with one part coming from the first input to the primitive instruction, and the other coming from the second part. This forces inputs to be decomposed into smaller chunks than would otherwise be necessary.

For example, to compute the bitwise XOR of two 32-bit inputs  $x$  and  $y$ , Jolt currently splits  $x$  and  $y$  each into four 8-bit chunks, and uses one subtable lookup (into a subtable of size  $2^{16}$ ) to compute the bitwise XOR of each chunk of  $x$  with the corresponding chunk of  $y$ . So even though the subtable addresses are 16 bits,  $x$ 

<span id="page-12-0"></span>

<sup>18</sup>Two of these six random committed values are from Spice turning each read or write to memory into two separate operations. The other four are from range checks (done using Lasso) that Spice must do to implement appropriate updates to “timestamps” associated with each read and write to memory. See Appendix A for details. Given how expensive it is to commit to random values, when using Quarks as the grand product argument, a naive range check based on bit-decomposition would actually result in a faster prover than using Lasso. This would lower the Spice-with-Quarks-grand-product prover cost by a factor of about 2 compared to what is reported here, but it would not change the qualitative comparison to Twist.

| Read/write memory checker | Non-zero committed values  | Field multiplications             | Proof size    |
|---------------------------|----------------------------|-----------------------------------|---------------|
| Spice                     | $5R + 6W + 2K \approx 11T$ | $80T + 80K \approx 80T$           | $O(\log^2 T)$ |
| Twist ( $d = 1$ )         | $R + 3W = 4T$              | $(5 \log(K) + 16)T + O(K \log K)$ | $O(d \log T)$ |
| Twist ( $d = 2$ )         | $2R + 4W = 6T$             | $(5 \log(K) + 32)T + O(K)$        | $O(d \log T)$ |

<span id="page-13-0"></span>Figure 1: Prover costs for **Twist**: read/write memory checking for  $R = T$  reads and  $W = T$  writes ( $R+W = 2T$  memory operations in total). We report a worst-case bound on field multiplications for **Twist**. For  $d = 1$ , the **Twist** prover performs many fewer field operations if memory accesses are local. Roughly,  $2^i$ -local memory accesses (see Section 8.2.1 for a definition) cost only  $7i$  field multiplications rather than  $5 \log K$ . Appropriate values for  $d$  in **Twist** are discussed in Section 2.8. Reported **Twist** costs in this table include Booleanity-checking costs.

| Read-only memory checker | Non-zero committed values | Field multiplications | Proof size    |
|--------------------------|---------------------------|-----------------------|---------------|
| Lasso                    | $3T + \min\{K, T\}$       | $12T + 12K$           | $O(\log^2 T)$ |
| LogUpGKR                 | $2T + \min\{K, T\}$       | $21T + 21K$           | $O(\log^2 T)$ |
| Shout ( $d = 1$ )        | $T$                       | $4T + O(K \log K)$    | $O(d \log T)$ |
| Shout ( $d = 2$ )        | $2T$                      | $11T + O(K)$          | $O(d \log T)$ |

Figure 2: Prover costs for **Shout** (read-only memory checking for  $T$  reads, into a memory of size  $K$ ). All committed values are small. Appropriate values for  $d$  in **Shout** are discussed in Section 2.8. Reported costs for **Shout** are inclusive of field multiplications required to prove that committed addresses are valid one-hot encodings (including Booleanity-checking).

and  $y$  must each be decomposed into only 8-bit chunks. Furthermore, these committed 8-bit chunks must all be range-checked to confirm they are indeed field elements in  $\{0, 1, \dots, 2^8 - 1\}$ . As we will see, **Shout** avoids any explicit table decomposition, and hence also avoids the above overheads when used in the context of a zkVM such as Jolt.

<span id="page-13-1"></span>**Closet related work: Generalized-Lasso. Shout** can be viewed as a natural generalization or improvement of the Generalized-Lasso protocol from [STW24]. **Shout** with  $d = 1$  is in fact equivalent to Generalized-Lasso, except that **Shout** uses any standard (i.e., dense) polynomial commitment scheme to commit to the one-hot encodings of addresses, rather than the sparse polynomial commitment scheme Spark [Set20] invoked by Generalized-Lasso. **Shout** thereby avoids Generalized-Lasso's need to commit to random field elements (which comes from Spark). However, setting  $d = 1$  only works for very small lookup tables due to the constraints described in Section 1. At the other extreme, **Shout** with  $d = \log K$  (the largest meaningful value of  $d$ ) is roughly equivalent to combining Generalized-Lasso with a different sparse polynomial commitment scheme called “Spark-Naive” [Set20]. Setting  $d$  this large brings high costs—see Remark 1 for details.

From this standpoint, **Shout** can be viewed as an improvement in sparse polynomial commitment schemes rather than in lookup arguments. **Shout** effectively identifies a family of sparse polynomial commitment schemes, with all schemes in the family avoiding Spark's need to commit to random field elements. There is a different scheme for each value of  $d \ge 1$ , where committing to bigger, sparser polynomials calls for higher settings of  $d$ . **Shout** then simply combines Generalized-Lasso with this family of sparse polynomial commitment schemes. This perspective, of **Shout** as an advance in the speed of sparse polynomial commitment schemes is made explicit in Section 9.3.1 (as **Spartan++**, one of our SNARKs for non-uniform circuits, explicitly uses such a **Shout**-based sparse polynomial commitment, which we call **Spark++**).

## 2.4 Costs of **Twist** and **Shout**

As with offline memory-checking techniques such as Spice, **Twist** and **Shout** can be formulated as a polynomial IOPs for the memory-checking problem, and the PIOP can be turned into a SNARK by combining it with any suitable polynomial commitment scheme. Recall that **Twist** and **Shout** actually refer to a family of PIOPs

<span id="page-14-0"></span>

| Read-only memory checker | Non-zero committed values | Number of field multiplications | Proof size    |
|--------------------------|---------------------------|---------------------------------|---------------|
| Lasso                    | $\ge 16T$                 | $\ge 144T$                      | $O(\log^2 T)$ |
| Shout ( $d = 2$ )        | $2T$                      | $42T$                           | $O(d \log T)$ |
| Shout ( $d = 4$ )        | $4T$                      | $65T$                           | $O(d \log T)$ |
| Shout ( $d = 8$ )        | $8T$                      | $112T$                          | $O(d \log T)$ |

Figure 3: Prover costs for Shout when doing  $T$  lookups into an appropriately structured read-only memory of size  $K$  such that  $K^{1/C} = o(T)$  for integer  $C = 4$ . All committed values are small. Reported Shout costs are inclusive of field multiplications required to prove that committed addresses are valid one-hot encodings (including Booleanity-checking). For comparison, we report (optimistic estimates of) the costs of Lasso as used today in Jolt, whereby each lookup into the table of size  $K \approx 2^{64}$  is decomposed into between 4 and 10 lookups into “subtables” of size  $2^{16}$ , and where committing to the addresses for those subtables necessitates committing to 2 small values per subtable address and range-checking each such value.

<span id="page-14-1"></span>

| Memory checker     | Memory size               | Bits of Committed Data | Field multiplications | Proof size    |
|--------------------|---------------------------|------------------------|-----------------------|---------------|
| Lasso              | $K = 2^{64}$ (structured) | at least $928T$        | at least $194T$       | $O(\log^2 T)$ |
| Shout ( $d = 16$ ) | $K = 2^{64}$ (structured) | $256T$                 | $131T$                | $O(d \log T)$ |
| Spice              | $K = 32$                  | $421T$                 | $95T$                 | $O(\log^2 T)$ |
| Twist ( $d = 1$ )  | $K = 32$                  | $128T$                 | $35T$                 | $O(d \log T)$ |

Figure 4: Amount of committed data measured in bits for Twist and Shout vs. prior work for two important applications: the 32 read/write registers of the RISC-V instruction set, and lookups into structured tables of size  $2^{64}$  used for proving correct primitive instruction execution in Jolt [AST24]. Bits of committed data is the relevant measure of commitment costs when using binary-field hashing-based multilinear commitments like Binius [DP23, DP24] and Blaze [BCF $^{+}$ 24].  $T$  denotes the number of reads in the read-only case, and the number of alternating reads and writes in the read/write case ( $2T$  total memory operations). We assume values read or written are 32 bits as in RISC-V, and that timestamps used in Spice are up to 32 bits (which is roughly sufficient for values of  $T$  up to  $2^{30}$ ). For Twist and Shout, we omit the field multiplications needed to prove Booleanity, as the commitment schemes themselves ensure this. For prior work (Lasso and Spice), we incorporate the slightly larger prover costs these protocols incur in the setting of small-characteristic fields [DP23, Section 4.4].

parametrized by an integer parameter  $d > 0$  that helps control commitment key size (in the case of elliptic curve commitment schemes) or commitment time (in the case of hashing-based commitment schemes). The higher  $d$  is, the more non-zero values the Twist and Shout provers commit to, and the more field work the Twist and Shout provers do. With elliptic curves commitment schemes  $d$  will typically be between 1 and 4, and with hashing-based commitments  $d$  will typically be between 1 and 16. See Section 2.8 for details.

#### 2.4.1 Proof size and verifier costs

Twist and Shout avoid invoking a grand product argument. They inherently invokes the sum-check protocol a constant number of times, leading to proofs of size  $O(d \cdot (\log(T) + \log(K)))$ , where  $T$  is the number of memory operations and  $K$  the size of the memory. When combined with a commitment scheme that has logarithmic-size evaluation proofs such as HyperKZG, Zeromorph, or Dory, they yield SNARKs for memory-checking whose proofs consist of  $O(d(\log(T) + \log(K)))$  field and group elements. Via standard batching techniques, the verifier only needs to perform a single evaluation proof verification, which involves a constant number of MSMs of size  $O(\log(T) + \log(K))$  and a constant number of pairing evaluations.

#### 2.4.2 Prover time

**Commitment costs.** For read operations, both the Twist and Shout provers commit only to the address  $\mathbf{r}$  specified via ( $d$ -dimensional) one-hot encoding. These commitments are unavoidable, as the memory-checking problem formulation itself requires that the address to be committed. The *values* returned by any read operation, captured by the multilinear polynomial  $\tilde{\mathbf{v}}$ , need *not* be committed:  $\tilde{\mathbf{v}}$  is a virtual polynomial.

For write operations, the **Twist** prover commits to the address and the value written, plus a single additional “small” value (which we call the write *increment*, a notion we will define later).

**Field work.** We give a variety of algorithms for quickly implementing the prover in the various sum-check invocations throughout the **Twist** and **Shout** PIOPs. Which algorithm to use depends on various aspects including: is the number of memory operations  $T$  significantly bigger than the memory size  $K$ ? In the case of **Twist**, are reads and writes to memory local? Here, we provide a concise summary of the prover times we achieve in different contexts. We explicitly state Booleanity-checking costs in each regime (i.e., the cost of proving that various committed values lie in  $\{0, 1\}$ ), as Booleanity-checking can be omitted when using a commitment scheme like Binius [DP23, DP24] that itself enforces Booleanity of committed values.<sup>19</sup>

**Shout with  $K = o(T)$ .** We hide additive terms of  $O(K)$  and  $O(K^{1/d} \log K)$  in this summary. The core **Shout** PIOP with  $d = 1$  (Figure 5) costs  $T$  field multiplications for the prover (Section 6.1). The core **Shout** PIOP for  $d > 1$  (Figure 7) costs  $d^2 + 1$  field multiplications (Section 6.2). Booleanity-checking (Section 6.3) costs an additional  $3dT$  field multiplications (other parts of the one-hot-encoding checking PIOP in Figure 8) contribute only low-order costs for the prover). This translates to  $4T$  multiplications in total when  $d = 1$ ,  $12T$  multiplications when  $d = 2$ , and so forth.

**Shout for gigantic structured memories.** Let  $C = cd$  be a constant such that  $CK^{1/C} = o(T)$ .<sup>20</sup> Then the core **Shout** PIOP (Figure 5) combined with one-hot-encoding-checking costs at most  $(7C + d^2 + 3d + c + 2)T$  field multiplications. For example, when  $C = 4$  and  $d = 2$ , this translates to  $40T$  multiplications. Of these,  $(4C + 3d)T$  are due to Booleanity checking. See Section 7.5 for details.

In Appendix C, we describe a variation of **Shout** with prover work that has a linear rather than quadratic dependence on  $d$ . Specifically, the  $d^2T$  term in the prover time above is reduced to  $(8d - 7.5)T$ . This variant is more efficient for values of  $d$  that are greater than or equal to 8. Such values of  $d$  naturally arise for gigantic lookup tables when combining **Shout** with hashing-based commitment schemes, but not when using commitments based on elliptic curves.

**Twist costs.** Again we assume  $K = o(T)$  and  $K^{1/d} \log K = o(T)$  and hence suppress additive terms of  $O(K)$  and  $O(K^{1/d} \log K)$ . The core **Twist** PIOP (Figure 9) costs  $(5 \log(K) + 2d^2 + 4d + 4)/T$  field multiplications in the worst case (Section 8.3). However, when  $d = 1$ , this calls falls substantially for local memory accesses. Specifically, if the bulk of the memory accesses are  $2^i$ -local (meaning they access a cell that was previously accessed at most  $2^i$  cycles prior), then the  $5 \log K$  term falls to just  $7i$ . Booleanity-checking costs an additional  $6dT$  field multiplications (again, other parts of the one-hot-encoding checking PIOP are low-order costs).

**Comparing to prior works.** Figures 1–3 give precise comparisons of **Twist** and **Shout** to the previously fastest provers in the context of elliptic-curve-based commitment schemes. **Twist** and **Shout** generally improve on *both* field multiplications and commitment costs. This improvement holds even when **Twist** and **Shout** are configured to have significantly shorter proofs than the prior works.

Exactly how big a prover-time improvement is achieved by **Twist** and **Shout** depends on context. Fortunately, the biggest improvements are achieved in the two settings that are most central to the Jolt zkVM: lookups into gigantic structured tables (i.e., how Lasso is current used in Jolt to prove correct execution of primitive RISC-V instructions), and reads and writes into 32 RISC-V registers (two such reads and one such write occur in Jolt for nearly every cycle of the RISC-V CPU).

In the case of gigantic structured lookup tables, **Shout** improves up to  $8\times$  in commitment costs and up to about  $3\times$  in field multiplications relative to Lasso’s application in Jolt today. The largest improvements are achieved when **Shout** is applied with  $d = 2$ , which is appropriate if using Dory as the polynomial commitment scheme (see Section 2.8 for details). **Shout** actually achieves even bigger improvements for some lookup tables,

<span id="page-15-0"></span>

<sup>19</sup>Arguably, this merely pushes the field multiplication necessary for Booleanity-checking into the polynomial evaluation protocol of the polynomial commitment scheme, as that phase itself invokes the sum-check protocol [DP24].

<span id="page-15-1"></span>

<sup>20</sup> $C$  may be smaller than  $d$  when  $d$  is very large, e.g.,  $d = 16$ . Such settings of  $C$  and  $d$  naturally arise when using hashing-based commitments but typically not with elliptic curve commitments.

since the costs of prior work depend on how “nicely decomposable” the table is, and that varies for the lookup tables arising in Jolt.

In the case of 32 read/write registers, where  $d = 1$  is appropriate regardless of the commitment scheme used (again, see Section 2.8 for details), Twist improves over the commitment costs of Spice by about 3× and the field multiplications of Spice by a factor of 2.

For larger read/write memories, we expect Twist to achieve more modest but still significant speedups over prior work (while also achieving significantly reduced proof size).

Figure 4 compares Twist and Shout to prior works in the context of hashing-based commitment schemes. For small memories, both the commitment costs and field work of Twist improve by 2×-3×. For very large real-only memories (e.g., structured lookup tables of size  $2^{64}$  as arise in Jolt), Shout’s commitment costs improve at least 3× compared to prior work, while prover field work improves more modestly. Again, Shout achieves bigger improvements for some lookup tables.

<span id="page-16-0"></span>**Comparison of Shout to FLI.** Shout with  $c = 1$  has quite a bit in common with FLI [GM24]: They both represent addresses via one-hot encoding, commit to the one-hot encodings with curve-based commitments (at the cost of one group operation per address for the prover), and observe that given the one-hot encodings, the validity of the lookups can then easily be expressed via R1CS. Unlike Shout, FLI then directly applies a Nova-type folding scheme [KST22] to fold these R1CS instances. Shout instead applies the sum-check protocol to directly prove satisfaction of the R1CS.

Inspired by Lasso [STW24], FLI also considers lookups into giant, decomposable tables. In this context, our improvements over FLI are analogous to our improvements over Lasso: by avoiding table decompositions, Shout lowers the amount of committed data (see Section 2.3 for details).

Ideas from FLI offer one possible approach to combining Shout with folding. In a nutshell, Shout can be directly turned into a folding scheme using the NeutronNova framework [KS24b], achieving better efficiency. More generally, Section 2.9.3 discusses various approaches to combining both Twist and Shout (and zkVMs that use them) with folding techniques.

**Comparison of Twist to Proofs for Deep Thought.** Bünz and Chen [BC24] present an incremental verifiable computation (IVC) framework for read/write memory (while FLI targets read-only memory). Their solution involves techniques reminiscent of Twist’s use of increments. However, to check correctness of the increments they invoke Spice [SAGL18] and LogUp [Hab22]. The focus of Twist and Shout is precisely to eliminate the overheads of these prior memory-checking arguments. Hence, Bünz and Chen’s work can be viewed as targeting how to efficiently “link” the state of memory between adjacent shards in an instance of IVC, but they incur overheads similar to the baselines we consider and improve upon.

## 2.5 Overview of Shout

### 2.5.1 The sum-check protocol in a nutshell

Let  $g$  be an  $\ell$ -variate polynomial over field  $\mathbb{F}$ . From the verifier’s perspective, the sum-check protocol is an efficient reduction from the task of computing

$$\sum_{x \in \{0,1\}^{\ell}} g(x) \quad (2)$$

to the potentially easier task of evaluate  $g(r)$  for a  $r \in \mathbb{F}^{\ell}$  chosen at random by the verifier over the duration of the protocol. So long as  $g$  has constant degree in each of its variables, the proof length of the sum-check protocol is  $O(\ell)$  field elements, and the soundness error is  $O(\ell/|\mathbb{F}|)$ .

<span id="page-16-1"></span>

### 2.5.2 The Shout PIOP when $d = 1$

Shout is targeted at read-only memories. Let  $\text{Val}(k)$  denote the fixed value of register  $k$ . Shout with  $d = 1$  is a special case: to obtain the best possible prover costs, our protocol for  $d = 1$  deviates substantially from the

general case of  $d > 1$ .

As observed in Baloo [ZGK $^{+}$ 22] and Lasso [STW24], the lookups are all valid if and only if for every cycle  $j$ ,

<span id="page-17-0"></span>
$$\sum_{\text{registers } k} \mathbf{ra}(k, j) \mathbf{Val}(k) = \mathbf{rv}(j). \quad (3)$$

Indeed, since  $\mathbf{ra}(k, j) = 1$  for the register  $k$  that was read at cycle  $j$  (and  $\mathbf{ra}(k', j) = 0$  for all other registers  $k' \neq k$ ), Equation (3) holds if and only if  $\mathbf{rv}(j)$  equals  $\mathbf{Val}(k)$ . To check that these constraints are satisfied, the verifier picks a random  $r_{\text{cycle}} \in \mathbb{F}^{\log T}$ , and the sum-check protocol is applied to confirm that:

<span id="page-17-1"></span>
$$\tilde{\mathbf{rv}}(r_{\text{cycle}}) = \sum_{k \in \{0, 1\}^{\log K}} \tilde{\mathbf{ra}}(k, r_{\text{cycle}}) \cdot \tilde{\mathbf{Val}}(k). \quad (4)$$

Here,  $\tilde{\mathbf{ra}}$ ,  $\tilde{\mathbf{rv}}$ , and  $\tilde{\mathbf{Val}}$  are the *multilinear extension polynomials* of the vectors  $\mathbf{ra}$ ,  $\mathbf{rv}$ , and  $\mathbf{Val}$  respectively,

Indeed, the right hand side of Equation (4) is a multilinear polynomial in  $r'$  and this polynomial agrees with  $\tilde{\mathbf{rv}}$  at all  $r' \in \{0, 1\}^{\log T}$  if and only if all constraints from Expression (7) are satisfied. Hence, the right hand side and left hand side of Equation (8) are equal as formal polynomials if and only if all constraints are satisfied. By the Schwartz-Zippel lemma, up to soundness error  $\log(T)/|\mathbb{F}|$ , checking that Equation (8) holds at a randomly chosen  $r' \in \mathbb{F}^{\log T}$  is equivalent to checking all constraints are satisfied.

At the end of the sum-check protocol, the verifier has to evaluate  $\tilde{\mathbf{ra}}(r_{\text{address}}, r_{\text{cycle}})$ ,  $\tilde{\mathbf{Val}}(r_{\text{address}})$ . for random values  $r_{\text{address}} \in \mathbb{F}^{\log K}$  and  $r_{\text{cycle}} \in \mathbb{F}^{\log T}$  chosen by the verifier. The verifier can obtain the  $\tilde{\mathbf{ra}}(r_{\text{address}}, r_{\text{cycle}})$  evaluation from the commitment to that polynomial. For many lookup tables (including all arising in the Jolt zkVM [AST24]), the verifier can evaluate  $\tilde{\mathbf{Val}}(r_{\text{address}})$  on its own in  $O(\log K)$  time. Following Lasso [STW24], we call such tables *MLE-structured*. For non-MLE-structured tables,  $\mathbf{Val}$  can be committed in advance by an honest party, and the verifier can force the prover to provide the necessary evaluation of  $\mathbf{Val}$ .

This is the entire core **Shout PIOP** for  $d = 1$ . It is essentially just the Generalized-Lasso protocol from [STW24], but without using the Spark sparse polynomial commitment scheme to commit to the  $\tilde{\mathbf{ra}}$  polynomial. Avoiding Spark is important, as Spark requires committing to several random values per lookup, which is a prover bottleneck both concretely and asymptotically.

The core **Shout PIOP** sketched above assumes all committed addresses are valid one-hot encodings of values in  $\{0, 1, \dots, K - 1\}$ . In Section 4.1.2, we give a separate PIOP for confirming this is the case. This PIOP amounts to identifying a straightforward (very large, but sparse) constraint system capturing correctness of one-hot encodings, and showing that the satisfaction of all constraints can be proved in time proportional to the sparsity of the constraint system rather than the size.

### 2.5.3 The **Shout PIOP** when $d > 1$

**A more expensive but generalizable protocol for  $d = 1$ .** The  $d = 1$  case is special because only when  $d = 1$  is the right hand side of Equation (4) multilinear in  $r_{\text{cycle}}$ . This allowed us to avoid a sum over  $j \in \{0, 1\}^{\log T}$  on the right hand side of Equation (4). Before covering the  $d > 1$  case, we give a slightly different PIOP for the  $d = 1$  case that *does* sum over  $j \in \{0, 1\}^{\log T}$ . This PIOP is less efficient than the one in Section 2.5.2, but generalizes straightforwardly to  $d > 1$ .

Recall from Equation (3) that checking that all reads are correct is equivalent to confirming that for all cycles  $j$ , the following constraint is satisfied:

$$\sum_{\text{registers } k} \mathbf{ra}(k, j) \mathbf{Val}(k) = \mathbf{rv}(j).$$

To check that this, the verifier can pick a random  $r' \in \mathbb{F}^{\log T}$  and apply the sum-check protocol to confirm that:

<span id="page-18-0"></span>
$$\tilde{\mathbf{v}}(r') = \sum_{k \in \{0,1\}^{\log K}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}(r', j) \cdot \tilde{\mathbf{a}}(k, j) \cdot \tilde{\mathbf{V}}(k). \quad (5)$$

Here,  $\tilde{\mathbf{a}}$ ,  $\tilde{\mathbf{v}}$ , and  $\tilde{\mathbf{V}}$  are the multilinear extension polynomials of the vectors  $\mathbf{a}$ ,  $\mathbf{v}$ , and  $\mathbf{V}$  respectively, while  $\tilde{\mathbf{e}}$  is the multilinear extension of a standard function known as the equality function (see Section 3.2 for details).

At the end of the sum-check protocol, the verifier has to evaluate  $\tilde{\mathbf{e}}(r', r_{\text{cycle}})$ ,  $\tilde{\mathbf{a}}(r_{\text{address}}, r_{\text{cycle}})$ ,  $\tilde{\mathbf{V}}(r_{\text{address}})$  for random values  $r_{\text{address}} \in \mathbb{F}^{\log K}$  and  $r', r_{\text{cycle}} \in \mathbb{F}^{\log T}$  chosen by the verifier over the course of the protocol. The verifier can compute the  $\tilde{\mathbf{e}}$  evaluations on its own in  $O(\log K + \log T)$  time, and the remaining evaluations are obtained exactly as in Section 2.5.2.

Obtaining a fast prover in this application of the sum-check protocol is a challenge that did not arise in the simpler application of Section 2.5.2. The issue is that the sum in Equation (5) is over  $K \cdot T$  terms, so naively implemented, the prover in this application of sum-check would perform  $O(KT)$  field operations. This would make Shout more expensive than prior lookup arguments, except for very small memories (say,  $K \le 10$  or so).

Fortunately, Equation (5) is a *very* special application of sum-check. For example,  $\tilde{\mathbf{a}}(k, j)$  is sparse: only  $T$  out of  $KT$  of its evaluations are non-zero over the domain  $\{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ . And there's additional structure on top of that, such as the fact that  $\tilde{\mathbf{V}}$  depends only on  $k$  and not on  $j$ . Leveraging all of this structure, one can implement the sum-check prover with just  $O(K) + 5T$  field operations (up to low-order terms).

**Shout for  $d > 1$ .** Fix an integer  $d > 1$  and let  $N = K^{1/d}$ . We view the memory of size  $K$  as a  $d$ -dimensional cube of length  $N$  in each dimension, indexing the cube by  $[N]^d$  where  $[N] = \{0, 1, \dots, N-1\}$ . As in Section 2.2 for a sequence of  $T$  reads into memory, let  $\mathbf{r}(j) \in [K] \subseteq \mathbb{F}$  denote the address read by the  $j$ 'th memory operation, with the address specified as a single field element. Reinterpret  $\mathbf{r}(j)$  as an element of  $[N]^d$  using the natural bijection between  $[K]$  and  $[N]^d$ , and for  $i = 1, \dots, c$ , let  $\mathbf{r}_i(\cdot, j)$  denote the one-hot encoding of the  $i$ 'th coordinate of  $\mathbf{r}(j)$ , i.e.,  $\mathbf{r}_i(k, j)$  equals 1 if the  $i$ 'th coordinate of  $\mathbf{r}(j)$  equals  $k$ , and equals 0 for all other  $k \in [N]$ . We call this the  *$d$ -dimensional one-hot encoding* of  $\mathbf{r}(j)$ .

The Shout prover commits to the  $d$  multilinear extension polynomials  $\tilde{\mathbf{a}}_1, \dots, \tilde{\mathbf{a}}_d$ . This entails committing to  $dN$  field elements per cycle, of which exactly  $d$  per cycle are 1, and the rest of 0.

Because only  $dN = dK^{1/d}$  rather than  $K$  field elements are committed, the size of the commitment key (when using a polynomial commitment scheme like HyperKZG) falls from  $K$  group elements to  $dN$  group elements. For example, by setting  $d = 2$ , a HyperKZG commitment key of size  $2 \cdot 2^{20}$  suffices to prove  $2^{20}$  reads into a memory of size  $K = 2^{20}$ , and this commitment key is under 100 MBs in size. This can be reduced even further at the cost of a small increase in verifier costs via standard batching techniques (see Section 3.1.1).

Then the Shout PIOP applies the sum-check protocol to compute the following variation of Equation (5):

<span id="page-18-1"></span>
$$\tilde{\mathbf{v}}(r') = \sum_{k=(k_1, \dots, k_d) \in \{0,1\}^{\log N}, j \in \{0,1\}^{\log T}} \tilde{\mathbf{e}}(r', j) \cdot \left( \prod_{\ell=1}^{d} \tilde{\mathbf{a}}_{\ell}(k_{\ell}, j) \right) \cdot \tilde{\mathbf{V}}(k). \quad (6)$$

The right hand side of Equation (6) has degree three in each variable of  $k$  exactly as in Equation (5), but the degree in each variable of  $j$  increases from 3 in Equation (5) to  $2 + d$ . This degree increase raises the prover's time to  $O(K + d^2 \cdot T)$ . In Appendix C, we give a variation of Shout that reduces the prover's runtime dependence of  $d$  from quadratic to linear. It comes with worse constant factors, and hence concretely offers an improvement only for  $d \ge 8$ . We suspect that additional improvements for large values of  $d$  are possible.

**Shout for gigantic, structured tables.** In fact, for "structured" tables (including all of those arising in the Jolt zkVM), we can invoke the sparse-dense sum-check protocol [STW24, Appendix G] to nearly remove the dependence on  $K$ . If  $K$  is very large (i.e.,  $K \approx T^C$  for  $C > 1$ ) the sum-check prover can in fact be implemented in time  $O(CK^{1/C} + CT) = O(CT)$ . We further explain how to generalize the sparse-dense sum-check protocol to achieve a similar time bound for proving that all committed addresses are correct one-hot encodings of values in  $\{0, 1, \dots, K-1\}$ .

<span id="page-19-0"></span>**Remark 1 (The relationship between Shout and Generalized-Lasso).** Shout with  $d = \log K$  (the largest possible value of  $d$ ) is roughly equivalent to running the Generalized-Lasso protocol of [STW24], but using "Spark-naive" [Set20, Section 7.1] instead of Spark [Set20, Section 7.2] as the sparse polynomial commitment scheme to commit to the one-hot encodings of addresses (see also [STW24, Appendix D] for an overview of Spark-naive).

Indeed, Spark-naive commits to the binary representation of each address (i.e., the index of each non-zero entry of the sparse vector being committed). This is very similar to what Shout does when  $d = \log K$ .

What's going on is that Shout has the prover commit to addresses using the one-hot encoding of the digits of the address when represented in base  $K^{1/d}$ . Spark-naive represents addresses in base-2 (i.e., binary), which matches the base used by Shout when  $d = \log K$ . Prior works like Spark-naive do not use one-hot encodings. However, the standard encoding and one-hot encoding of a value almost coincide for base-2: in both cases each bit in the binary representation of an address is represented in the encoding with one or two bits.

Setting  $d$  in Shout to its maximum value of  $\log K$  minimizes the number of committed bits for the prover, leading to the fastest possible commitment computation when using a binary-field hashing-based commitment scheme like Binius [DP23, DP24]. However, the downsides of taking  $d$  this big outweigh the advantages: the prover time "outside of committing" is superlinear (i.e., at least  $O(T \log K)$  field multiplications) and the proof size is somewhat big (i.e.,  $O(\log^2(K) + \log(T) \log(K))$  field elements).

The fastest prover in Shout (as well as short proofs) is obtained by taking  $d$  to be as small as possible, subject to the appropriate constraints.

## 2.6 Overview of Twist

Recall that there are  $2T$  memory operations, which alternate between reads and writes (say, with the first operation being a read). It is convenient to number both the read-cycles and the write-cycles from 0 up to  $T$ .

**A first attempt.** We first explain a somewhat naive approach to memory-checking, which has high costs, before explaining how to lower the costs.

Recall the memory has size  $K$ , and let  $[K] = \{0, \dots, K-1\}$ . We can have the prover commit to the value,  $\text{Val}(k, j)$  of every register  $k \in [K]$  for every cycle  $j \in [T]$ . We do have to find a way to ensure that the committed values are actually correct, i.e., that the committed value  $\text{Val}(k, j)$  is indeed the value most recently written to register  $k$  when cycle  $j$  is executed. We address how to do this later in our overview.

Once the  $\text{Val}(k, j)$  values are committed and confirmed to be correct, one can force  $\text{rv}_j$  to equal the value stored in cell  $\text{ra}_j$  at cycle  $j$  by confirming that

<span id="page-19-1"></span>
$$\sum_{k \in [K]} \text{ra}(k, j) \cdot \text{Val}(k, j) = \text{rv}(j) \text{ for all cycles } j \in [T]. \quad (7)$$

If register  $k$  is the (unique) register read at cycle  $j$ , then  $\text{ra}(k, j) = 1$  and  $\text{ra}(k', j) = 0$  for all  $k' \neq k$  with  $k' \in \{0, 1\}^{\log K}$ , and Equation (7) is therefore satisfied if and only if  $\text{rv}(j) = \text{Val}(k, j)$ , i.e., the value returned by the read at cycle  $j$  equals the value stored in register  $k$  at that cycle. To check that these constraints are satisfied, the verifier picks a random  $r' \in \mathbb{F}^{\log T}$ , and the sum-check protocol is applied to confirm that:

<span id="page-19-2"></span>
$$\tilde{\text{rv}}(r') = \sum_{(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}} \tilde{\text{eq}}(r', j) \cdot \tilde{\text{ra}}(k, j) \cdot \tilde{\text{Val}}(k, j). \quad (8)$$

Indeed, the right hand side is multilinear in  $r'$  and agrees with the left hand side at all  $r' \in \{0, 1\}^{\log T}$  if and only if Equation (7) is satisfied. Hence, the right hand side and left hand side are equivalent as formal polynomials if and only if Equation (7) is satisfied, and up to soundness error  $\log(T)/|\mathbb{F}|$  it suffices to check equality at a single random point  $r' \in \mathbb{F}^{\log T}$ .

We call this invocation of sum-check the *read-checking sum-check*. It is very similar to the core Shout PIOP (Section 2.5.2). It is not quite as structured as the sum-check instance arising in Shout, but we are nonetheless able to show how to implement the prover in  $O(K + T \log K)$  time, an exponential improvement in the dependence on  $K$  compared to a naive  $O(KT)$ -time prover implementation. We do this by leveraging two properties. First, that  $\text{ra}(k, j)$  is sparse: only  $T$  out of  $kT$  of its entries are non-zero. Second, that when moving from cycle  $j$  to  $j + 1$ , only one entry of  $\text{Val}(k, j)$  changes (namely, the register written at cycle  $j$ ).

At the end of the read-checking sum-check, the verifier needs to evaluate  $\tilde{\text{rv}}$  at a random point  $r_{\text{cycle}} \in \mathbb{F}^{\log T}$ ,  $\tilde{\text{Val}}$  at a random point  $(r_{\text{address}}, r_{\text{cycle}}) \in \mathbb{F}^{\log K} \times \mathbb{F}^{\log T}$ , and  $\tilde{\text{eq}}$  at  $(r', r_{\text{cycle}}) \in \mathbb{F}^{\log T} \times \mathbb{F}^{\log T}$ . The  $\tilde{\text{eq}}$  evaluation can be computed by the verifier directly in  $O(\log T)$  time. The verifier can obtain the evaluations of  $\tilde{\text{rv}}$  and  $\tilde{\text{Val}}$  from the commitments to these polynomials.

The key performance issue with the above proposal is the cost of committing to the vector  $\text{Val}(k, j)$  (or more precisely, its multilinear extension  $\tilde{\text{Val}}$ ). This vector specifies all register values at all cycles means committing to  $K$  non-zero values per cycle. Even for very small memories like  $K = 32$ , this alone is more expensive than Spice, which commits to only 7 small values per read and 8 per write.

**Enter increments: virtual polynomials to the rescue.** To avoid this, we use an idea implicit in many works involving the sum-check protocol, and explicit in Binius, which refers to the notion of “virtual polynomials” [DP23]. These are polynomials that are *not* committed by the prover, but that the verifier can “pretend” are committed. We already discussed virtual polynomials in Section 2.2, in the context of evaluating the multilinear polynomials  $\tilde{\text{raf}}$  and  $\tilde{\text{waf}}$  (which specify addresses via a single field element rather than one-hot encoding).

In more detail, if the sum-check protocol is applied to a polynomial derived from  $p$ , then at the end of the sum-check protocol the verifier has to evaluate  $p$  at a random point  $r$ . If  $p$  were committed with a polynomial commitment scheme, then  $p(r)$  could be provided by the prover along with a proof that the provided evaluation is correct.

However, if  $p$  is expensive to commit to directly, the prover will not want to commit to  $p$ . The idea of virtual polynomials is to have the prover commit to  $p$  *indirectly* as follows. Suppose there is some alternative  $\ell$ -variate polynomial  $q$  that is cheaper to commit to than  $p$ . Moreover for any input  $r$  to  $p$ , there is some polynomial  $g_r$  (which depends on  $r$ ) such that the following two properties hold: (1)  $p(r) = \sum_{x \in \{0, 1\}^{\ell}} g_r(x)$ , and (2) For any point  $r'$ , the verifier can quickly derive  $g_r(r')$  from  $q(r')$ .

Then when the verifier needs to evaluate  $p(r)$ , it can simply apply the sum-check protocol to  $g_r$ , at the end of which the verifier needs to evaluate  $g_r(r')$  for a random point  $r'$ . And by (2) above, for this, it suffices for the verifier to learn  $q(r')$ . Since  $q$  was committed by the prover, the prover can provide this evaluation directly.

In the case of Twist, the polynomial  $p(k, j) = \tilde{\text{Val}}(k, j)$  is expensive to commit to directly, since it requires committing to  $K$  non-zero values per cycle  $j$ . Instead, let us define the polynomial  $q(k, j) = \tilde{\text{Inc}}(k, j)$  as the (multilinear extension of) the *increments* of  $\text{Val}$ . Here, we define the increment of register  $k$  at cycle  $j \in [T]$  to be the difference between the register’s value at cycle  $j$  vs. cycle  $j - 1$ . In other words,

<span id="page-20-0"></span>
$$\text{Inc}(k, j) := \text{Val}(k, j + 1) - \text{Val}(k, j) = \text{wa}(k, j) \cdot (\text{wv}(k, j) - \text{Val}(k, j)). \quad (9)$$

Here, the final equality holds by the following reasoning. If register  $k$  is not written at cycle  $j$ , then  $\text{wa}(k, j) = 0$ , and that forces  $\text{Inc}(k, j)$  to 0 per the right hand side of Equation (9). While if register  $k$  is written at cycle  $j$ , then  $\text{wa}(k, j) = 1$ , and the right hand side of Equation (9) forces  $\text{Inc}(j)$  to be the difference between  $\text{wa}(k, j)$ , i.e., the value written at cycle  $j$ , and  $\text{Val}(k, j)$ , the value stored at that cell at the start of the cycle.

The key point is that, since only one register is written per cycle  $j$ ,  $\widetilde{\text{Inc}}(k, j)$  is non-zero for only one register  $k$ . Moreover, since registers contain 32-bit values, the one non-zero increment at each cycle  $j$  is “small” (i.e., in  $\{-2^{32} - 1, \dots, 2^{32} - 1\}$ ), and hence fast to commit to. This makes  $\widetilde{\text{Inc}}$  roughly  $K$  times cheaper to commit to than  $\widetilde{\text{Val}}$ .

**Giving the verifier query-access to  $\widetilde{\text{Val}}$ .** But now we run into the key issue arising from the use of virtual polynomials: recall that at the end of the zero-check for correctness of read operations, the verifier has to evaluate  $\widetilde{\text{Val}}(r_{\text{address}}, r_{\text{cycle}})$  for a random point

$$(r_{\text{address}}, r_{\text{cycle}}) \in \mathbb{F}^{\log K} \times \mathbb{F}^{\log T}. \quad (10)$$

Since  $\widetilde{\text{Val}}$  is not committed directly, it is not obvious how the verifier can obtain this evaluation. The way to do it is to apply the sum-check protocol to the following equation:

<span id="page-21-0"></span>
$$\widetilde{\text{Val}}(r_{\text{address}}, r_{\text{cycle}}) = \sum_{j' \in \{0, 1\}^{\log T}} \widetilde{\text{Inc}}(r_{\text{address}}, j') \cdot \widetilde{\text{LT}}(j', r_{\text{cycle}}). \quad (11)$$

We call this the  $\widetilde{\text{Val}}$ -evaluation sum-check. Here,  $\widetilde{\text{LT}}$  is the multilinear extension of the function the so-called *less-than* function, which takes as input two binary strings  $j', j \in \{0, 1\}^{\log T}$  and outputs 1 if and only if the integer represented by  $j'$  is *strictly* less than the integer represented by  $j$ . One can check that Equation (11) holds because the right hand side is multilinear in the variables of  $r_{\text{address}}$  and  $r_{\text{cycle}}$ , and agrees with the right hand side whenever  $(r_{\text{address}}, r_{\text{cycle}}) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}$ , owing to the fact that the value of any register  $k$  at time  $j$  is the sum of the increments for that register at all cycles  $j' < j$ .

At the end of the  $\widetilde{\text{Val}}$ -evaluation sum-check, the verifier needs to evaluate  $\widetilde{\text{Inc}}$  at a random point and  $\widetilde{\text{LT}}$  at a random point. The former evaluation can come from the commitment to  $\widetilde{\text{Inc}}$ , while the latter the verifier can perform on its own in time  $O(\log T)$  (see Section 3.2 for details).

**The remaining issue.** We have deferred until now discussion of how to ensure that each value  $\text{Val}(k, j)$  is the actual value stored in register  $k$  at cycle  $j$ . Given that  $\text{Val}(k, j)$  is in fact implicitly specified by  $\text{Inc}(k, j)$  per Equation (11), this problem manifests as ensuring that the committed polynomial  $\text{Inc}$  indeed equals (the multilinear extension of) the *correct increments*, per the definition in Equation (9).

To check this, we apply the zero-check PIOP once again, to confirm that indeed for all  $k \in \{0, 1\}^{\log K}$  and  $j \in \{0, 1\}^{\log T}$ ,

$$\text{Inc}(k, j) = \text{wa}(k, j) \cdot (\text{wv}(j) - \text{Val}(k, j)).$$

This involves the verifier picking a random  $r' \in \mathbb{F}^{\log K}$  and  $r'' \in \mathbb{F}^{\log T}$  and applying the sum-check protocol to confirm that

<span id="page-21-1"></span>
$$\widetilde{\text{Inc}}(r', r'') = \sum_{(k, j) \in \{0, 1\}^{\log K} \times \{0, 1\}^{\log T}} \widetilde{\text{eq}}(r', k) \cdot \widetilde{\text{eq}}(r'', j') \cdot \left(\widetilde{\text{wa}}(k, j)(\widetilde{\text{wv}}(j) - \widetilde{\text{Val}}(k, j))\right). \quad (12)$$

We call this the *write-checking sum-check*.

At the end of the write-checking sum-check, the verifier needs to evaluate each of  $\widetilde{\text{Inc}}$ ,  $\widetilde{\text{wa}}$ ,  $\widetilde{\text{wv}}$ , and  $\widetilde{\text{Val}}$  each at a random point. Since  $\widetilde{\text{Inc}}$ ,  $\widetilde{\text{wa}}$  and  $\widetilde{\text{wv}}$  are committed by the prover already, the required evaluations of these polynomials can be obtained directly from the prover. The evaluation of  $\widetilde{\text{Val}}$  can be obtained via another invocation of the  $\widetilde{\text{Val}}$ -evaluation sum-check. In fact, by running the read-checking and write-checking sum-check instances in parallel, we can ensure only one evaluation of  $\widetilde{\text{Val}}$  is needed, and hence we only need to run the  $\widetilde{\text{Val}}$ -evaluation once.

**Summary of the protocol.** Twist had to address three issues:

- How to “implicitly commit” to  $\tilde{\text{Val}}$  given that explicitly committing to  $\tilde{\text{Val}}$  would be expensive (requiring  $K$  committed non-zero values per cycle).
- How to confirm that  $\tilde{\text{Val}}$  actually assigns the correct value to each register at each cycle, given the committed sequence of write operations specified by  $\tilde{\text{wa}}$ , and  $\tilde{\text{wv}}$ . In other words, how to make sure the prover processed all the writes correctly.
- How to ensure that each read operation (specified by the committed polynomial  $\tilde{\text{ra}}$  and the virtual polynomial  $\tilde{\text{rv}}$ ) returns the correct value. In other words, how to make sure the reads were processed correctly.

The first issue was addressed by committing to the *increments*  $\tilde{\text{Inc}}$  rather than to  $\tilde{\text{Val}}$ . Committing to  $\tilde{\text{Inc}}$  is cheap because  $\tilde{\text{Inc}}$  is sparse and its non-zero entries are small.

The second issue (checking writes) was addressed via the write-checking sum-check (Equation (12)).

The third issue (checking reads, and giving the verifier query access to the virtual polynomial  $\tilde{\text{rv}}$ ) was addressed by the read-checking sum-check (Equation (8)).

At the end of the read-checking and writing-checking sum-checks, the verifier has to evaluate  $\tilde{\text{Val}}$  at a random point. This is addressed via the  $\tilde{\text{Val}}$ -evaluation sum-check (Equation (11)). This equation expresses the necessary  $\tilde{\text{Val}}$  evaluations in terms of  $\tilde{\text{Inc}}$  as per Equation (11).

## 2.7 Other benefits and implications

**Improved soundness error.** Offline memory-checking techniques introduce soundness error at least  $(T + K)/|\mathbb{F}|$  where  $T$  is the number of memory operations proven and  $K$  is the size of the memory, thanks to the grand product in Equation (1) introducing a univariate polynomial in the random field element  $r$ , of degree  $\Theta(T + K)$ . Meanwhile, the method of one-hot addressing has soundness error of only  $\log(TK)/|\mathbb{F}|$ .

This difference is not important when working over 256-bit prime order fields, as required by most standard elliptic curves. However, there may be contexts where it is relevant. For example, consider elliptic curves defined over extensions of 64-bit prime fields and targeted at a security level of 128 bits [SSS22]. To keep as much of the prover’s work as possible over a relatively small subfield (thereby keeping the field operations relatively fast), SNARK designers will want to choose the value  $r$  from Equation (1) at random from a 128-bit subfield (i.e., a degree-2 extension of the 64-bit base field). However, if the memory size  $K$  is, say, one billion, this will lead to only at most 98 bits of security, due to the soundness error of at least  $2^{30}/2^{128} = 2^{-98}$ . Processing a trillion cycles (equivalent to a couple of minutes of single-threaded compute on a modern laptop), at least without invoking SNARK recursion, would lead to an even lower security level, of  $2^{-88}$ . The method of one-hot addressing, by contrast, achieves over 120 bits of security in these settings.

**Benefiting from small memories and locality.** Modern CPUs can make random accesses to a large memory. But they also have smaller, faster memories. At the extreme end are *registers*, which are very fast memory cells directly accessible to the processor. In contrast, offline memory checking techniques are not substantially more efficient when applied to small memories. That is, the cost of proving  $T$  reads and writes into a memory of size  $K$  is roughly  $O(T + K)$  committed values and field operations, and hence this cost is about the same for all  $K \le T$ . In other words, zkVM provers do not currently enjoy the benefits of small, fast memories like registers or caches, the way actual CPUs do. The cost profile of Twist matches that of actual CPUs much more closely. For starters, the smaller the memory, the smaller the parameter  $d$  can be in both *Twist* and *Shout*, and the smaller  $d$  is, the lower the commitment costs and prover field multiplications in both *Twist* and *Shout*. Furthermore, the *Twist* prover (appropriately implemented, see Section 8 for details) performs many fewer field multiplications for *local* memory accesses—reads and writes to memory cells that were recently read from or written to.

The closer the prover cost profile of zkVMs matches that of actual CPUs, the more likely it is that existing compilers (optimized for actual CPUs rather than SNARK provers) lead to fast zkVM proving. In other words,

Twist and Shout offer a strong counterpoint to a prevailing belief that it is better for zkVM performance to design “SNARK-friendly” VMs, rather than using mature toolchains for existing VMs like RISC-V that were not designed with SNARK proving in mind.

<span id="page-23-0"></span>

## 2.8 Appropriate settings of $d$

**How to set  $d$  when using elliptic curve commitments.** When applying Twist and Shout with an elliptic curve commitment scheme, there are multiple tools at the protocol designer’s disposal to control commitment key size. One is the precise choice of polynomial commit scheme. For example, Dory has square-root sized commitment key, while HyperKZG is linear-sized commitment key. So using Dory rather than HyperKZG helps to control commitment key size. Of course, the choice of Dory comes with its own costs, such as concretely larger polynomial evaluation proofs and the need to do (in addition to MSMs) a multi-pairing of size  $\sqrt{n}$  when committing to a polynomial of size  $n$ .

Another tool is the ability to reduce commitment key size by any desired factor  $k$  at the cost of increasing commitment size from one group element to  $k$  (see Section 3.1.1 for details).

As a separate and complementary tool, we also introduced the parameter  $d$  to Twist and Shout themselves. If one uses parameter  $d$  with Dory as the commitment, the commitment key size is  $\Theta((K^{1/d} \cdot T)^{1/2})$  when proving  $T$  accesses to a memory of size  $K$ . If one uses parameter  $d$  and HyperKZG as the commitment, the commitment key size is  $\Theta(K^{1/d} \cdot T)$ .

Generally speaking, for commitment schemes based on elliptic curves, one wants to set  $d$  as small as possible subject to the constraint that the commitment key is not too large for the prover to generate and store (the key must be big enough to commit to  $d$  vectors of length  $N = K^{1/d}$ ).

**How to set  $d$  when using hashing-based commitments.** For commitment schemes based on hashing over binary fields like Binius, one also wants to set  $d$  as small as possible, but subject to a very different constraint. Since 0s are not free to commit to with hashing-based schemes, the key constraint is ensuring that committing is sufficiently fast. The larger  $d$  is, the faster it is to commit to addresses in Twist and Shout with a binary-field hashing-based commitment scheme, but the more work the prover does in the sum-check protocol (and the larger the proof size). Hence, with hashing-based commitment schemes,  $d$  should be chosen large enough that committing to addresses in Twist and Shout is not the prover bottleneck, but no larger.

For illustration, we now discuss how one can set  $d$  in various applications covering the gamut of memory sizes, from tiny to large.

**Application 1:**  $K = 32$ ,  $T = 2^{20}$ . Recall that zkVMs today break CPU executions into “shards” consisting of roughly  $2^{19}$  cycles each. Also, the RISC-V ISA has 32 registers, with each cycle reading two registers and writing to one. Hence, one important application is to  $K = 32$  with  $T \approx 2^{21}$ . In this case, setting  $d = 1$  in Twist and using HyperKZG leads to a commitment key (powers-of-tau SRS) containing  $32 \cdot 2^{21} = 2^{26}$  group elements. This is smaller than some powers-of-tau SRSes that have already been generated (which have contained up to  $2^{29}$  powers of tau<sup>21</sup>), though it does require GBs of prover storage. Per Section 3.1.1, one can further lower SRS size, say to  $2^{21}$ , by increasing the size of the commitment from one group element to  $2^5 = 32$  group elements. Or one could keep the commitment size at one group element, but use  $d = 2$ , obtaining an SRS size of only about  $2^{11}$  group elements.

With a hashing-based commitment scheme over  $\text{GF}(2^{128})$  like Binius or FRI-Binius [DP23, BCF<sup>+</sup>24] or Blaze [BCF<sup>+</sup>24], the key issue to address is not commitment key size, but rather the time cost of committing to each address (as 0s are not free to commit to with these schemes). For this application, the memory is sufficiently tiny that one can set  $d = 1$  and maintain small commitment costs. This requires the prover to commit to 32 values in  $\{0, 1\}$  per address. Four such addresses could be packed into a single  $\text{GF}(2^{128})$  before committing.

<span id="page-23-1"></span>

<sup>21</sup>See for example <https://github.com/privacy-scaling-explorations/perpetualpowersoftau>.

**Application 2:**  $K = 2^{20}$ ,  $T = 2^{20}$ . This captures VMs with several MBs of main memory (alternatively, it captures typical L2 or even L3 cache sizes on modern CPUs). With HyperKZG, one cannot take  $d = 1$ , as this would lead to an SRS of size  $K T = 2^{40}$ . However, setting  $d = 4$  is feasible, leading to an SRS size of  $K^{1/d} \cdot T = 2^{25}$  with address commitments consisting of  $d = 4$  group elements. As above, this SRS size can be driven lower with a further increase in commitment size. Using Dory instead of HyperKZG, one can take  $d = 1$ , leading to a commitment key of size  $2 \cdot \sqrt{K T} = 2^{21}$  group elements in a pairing-friendly group ( $2^{20}$  from  $\mathbb{G}_1$  and  $2^{20}$  from  $\mathbb{G}_2$ ).

As discussed in Section 1,  $d = 4$  is also a reasonable setting in this application if using a hashing-based multilinear commitment scheme over  $\text{GF}(2^{128})$ , such as Binius or FRI-Binius [DP23, BCF $^{+24}$ ] or Blaze [BCF $^{+24}$ ]. Then each address is specified by  $d K^{1/d} = 4 \cdot 2^{20/4} = 2^7 = 128$  bits, which can all be packed into a single  $\text{GF}(2^{128})$  field element before committing.

**Application 3:**  $K = 2^{30}$ ,  $T = 2^{32}$ . We anticipate that techniques for controlling prover space without invoking SNARK recursion [NT25] will eventually enable efficient non-recursive proving of  $T = 2^{30}$  or more RISC-V cycles.  $K = 2^{30}$  corresponds to giving the VM about 4 GBs of main memory (RAM).

Applying Twist to prove  $T = 2^{32}$  memory accesses is incompatible with commitment schemes like HyperKZG requiring a linear-size SRS. But with Dory, one could set  $d = 2$  and obtain a commitment key of size  $2 \cdot \sqrt{K^{1/d} \cdot T} \approx 2^{26}$  group elements. This could be further lowered per Section 3.1.1 at the cost of increasing the size of the commitments.

**Application 4:**  $K = 2^{64}$ ,  $T = 2^{20}$  (structured read-only memory). This captures “primitive instruction execution” lookups in Jolt. With HyperKZG, one could set  $d = 8$  and have address commitments consist of  $4c = 32$  group elements. This would lead to an SRS with  $K^{1/d}/4 \cdot T = 2^{26}$  group elements, which is significantly smaller than some powers-of-tau SRSes that have been generated today. With Dory, setting  $d = 4$  would lead to a (transparently generated) commitment key of size just  $2 \sqrt{K^{1/d} \cdot T} = 2 \cdot 2^{18} = 2^{19}$ . One could even take  $d = 2$ , which would give a commitment key of size  $2^{27}$ , and this key size could be further reduced at the cost of larger commitments per Section 3.1.1.

If using a hashing-based commitment scheme over  $\text{GF}(2^{128})$ , a reasonable setting of  $d$  is 16. Then the number of bits in each committed address is  $d \cdot K^{1/d} = 16 \cdot 2^{64/16} = 256$  bits. These can be packed into two  $\text{GF}(2^{128})$  field elements before committing.

## 2.9 Additional discussion

### 2.9.1 Pros and cons of Dory

Dory is an especially attractive choice of polynomial commitment scheme for combination with Twist and Shout. This is primarily because it is a curve-based commitment scheme with a sublinear-size commitment key, and this helps keep the parameter  $d$  in Twist and Shout small (which in turn ensures very few committed values, and minimal field work for the prover). Implementations of Dory exist<sup>22</sup>, but Dory has not seen wide deployment to date. We briefly discuss the downsides of Dory that are the likely reasons it hasn't been widely deployed, and argue that these aspects of Dory do not preclude its use in contexts where its cost profile is particularly valuable. We believe Twist and Shout offer the most compelling such context to date.

One potential downside of Dory is that when committing to a polynomial of size  $N$ , computing the commitments involves (in addition to  $\sqrt{N}$  multi-exponentiations of size  $\sqrt{N}$ , which is roughly equivalent in cost to other elliptic curve commitment schemes like KZG or HyperKZG, Bulletproofs/IPA, etc.), a multi-pairing of size  $\sqrt{N}$ . For small values of  $N$  the multi-pairing can be a prover bottleneck. But for moderate-to-large values of  $N$ , this will not be the case. Indeed, a pairing evaluation is equivalent in cost to at most about 4000 group operations, and multi-pairings also benefit from a “Pippenger’s speedup” meaning a multi-pairing of size  $\sqrt{N}$  is actually a factor of  $\text{pip} \approx (1/2) \log(N)$  faster than  $\sqrt{N}$  independent pairings.

<span id="page-24-0"></span>

<sup>22</sup><https://github.com/yacovm/DualDory>

This means that if **Shout** is applied (even with  $d = 1$ ) to, say,  $T \ge 2^{22}$  memory operations, the multi-pairing will not be a prover bottleneck, as the multi-pairing will be equivalent in cost to  $4000 \cdot \sqrt{T}/\text{pip} \ll 2^{22}$  group operations, while the MSMs involved in the commitment will cost this much or more. Furthermore, for any  $t > 1$ , Dory can be configured so the multi-pairing is only of size  $\sqrt{N}/t$ , at the cost of increasing the commitment key size to  $t\sqrt{N}$ .

Another aspect of Dory that may be construed as a downside is that its proofs consists of  $6 \log N$  elements of the target group of a pairing-friendly group, translating to roughly a dozen KBs. This is still much smaller than the proof size of hashing-based commitment schemes like FRI. And proof size can be reduced via SNARK composition.

A final potential downside of Dory is verifier *time*: verifying Dory evaluation proofs requires (logarithmically many) scalar multiplications in the target group of a pairing-friendly elliptic curve, and these can be slow, as, naively implemented, target group operations are about 6 times slower than  $G_1$  operations. If this indeed turns out to be a significant verifier cost, there are multiple possible mitigations. First, as with proof size, verifier time can be reduced via SNARK composition. Second, even short of SNARK composition, one could outsource the target group operations to the prover using, say, data parallel variants of the GKR protocol [GKR15, Tha13]. Third, there has been recent progress on speeding up target-group operations in BLS12-381, at least on high-end consumer CPUs.<sup>23</sup> Such techniques could keep Dory's verification time from becoming problematic even in the absence of SNARK composition or outsourcing verification.

We expect the benefits of Dory in the context of **Twist** and **Shout** (especially controlling commitment key size while keeping  $d$  small) to outweigh any downsides.

Section 9.2.3 contains yet more discussion of Dory's costs and how it works.

### 2.9.2 **Twist** and **Shout** design philosophy

The design of **Twist** and **Shout** reflects a philosophy that leverages the unique strengths of the sum-check protocol to achieve high prover performance. Below, we highlight key aspects of this approach and its broader implications for SNARK design.

**Barely paying for zeros: a superpower of sum-check (and elliptic curve commitments).** The method of one-hot addressing leans heavily on the ability of elliptic-curve commitment schemes to commit to 0-values for “free” (i.e., committing to a vector incurs prover costs proportional to its *sparsity*, i.e., number of non-zeros, not its length). The method also works well with hashing-based commitments over binary fields such as Binius [DP23, DP24], since such schemes ensure that it is cheap to commit to values known a priori to reside in  $\{0, 1\}$ . Importantly, these commitment schemes “pack” many small values into a single field element, and later use the sum-check protocol to relate the packed field elements to unpacked ones.

Indeed, committing very quickly to 0s (or small values in general) is not enough on its own to get a fast SNARK prover. Also essential is the ability of the sum-check protocol to allow the prover to avoid paying *field operations* to process 0-values. This appears difficult or impossible to achieve with polynomial IOPs based on univariate polynomials. This is because the number of non-zero evaluations of various “quotient polynomials” arising in polynomial IOPs based on univariate polynomials grows with the degree of the polynomials regardless of how sparse they are. These non-zero quotient evaluations increase prover work. This prover cost is in addition to 0s contributing significantly to commitment time for popular univariate hashing-based polynomial commitments like FRI [BBHR18].

**Twist** and **Shout** are new examples in a growing body of work showing that the “free 0s” cost profile of elliptic-curve-based commitments opens up a rich design space enabling highly performative SNARKs. This body of work offers a strong counterpoint to the widespread view that SNARKs using elliptic curves—due to their use of 256-bit fields—are less performative than alternatives that rely only on hashing-based commitment schemes.

<span id="page-25-0"></span>

<sup>23</sup><https://github.com/mratsim/constantine/pull/485>

Indeed, the Jolt RISC-V zkVM implementation<sup>24</sup> already extensively leverages this property of elliptic curves (even without yet incorporating **Twist** and **Shout**). For example, Jolt forces the prover to evaluate primitive instructions correctly by performing lookups into “subtables” of size  $2^{16}$ . There are over a dozen subtables used across all primitive instructions, but each instruction only accesses a handful of the subtables. This is loosely analogous to how RISC-V has 32 registers but each cycle only two are read and one is written. The way Jolt handles the subtable lookups today is analogous to how **Twist** and **Shout** handle registers: For each cycle, the Jolt prover commits to a vector of binary flags indicating for each subtable whether or not it is actually accessed at that cycle. If not, the Jolt prover is free to commit to only 0s for all values “capturing” the lookup into that subtable for that cycle. This is analogous to how **Twist** and **Shout** commit to a 0 for each register that is not accessed in a given cycle (and on writes, **Twist**, additionally commits to a 0-increment for each register that is not accessed).

Similar techniques leveraging “free 0s” have also recently been exploited in Nebula [AS24], a collection of techniques for efficiently applying folding schemes in a zkVM context.

**Going fully multilinear.** The technical ethos underlying our work is that SNARKs based on the sum-check protocol and multilinear polynomials, rather than univariate polynomials (and establishing quotient relationships between them), are best for prover speed. In sum-check-based zkVMs like Jolt, there is one place today where univariate polynomials still arise: permutation-checking via Lipton’s trick (see Equation (1)), which is the central component of offline memory-checking procedures and other key SNARK components. This entails treating the two vectors to be permutation-checked as the roots of a univariate polynomial and evaluating that polynomial at a random point via a grand product argument. **Twist** and **Shout** replace this source of “univariate-ness” with the sum-check protocol, eliminating grand product arguments completely.

<span id="page-26-1"></span>

### 2.9.3 Integrating Jolt (with **Twist** and **Shout**) with folding schemes

As described in the Jolt paper [AST24] and implemented in code as of this writing, Jolt is a “monolithic” SNARK, meaning that it produces a proof of execution of a fixed number of CPU cycles at once. We now discuss how to extend Jolt to prove *any* number of CPU cycles. Here, we assume that Jolt is instantiated with an additively homomorphic commitment scheme such as HyperKZG [ZSC24] or Zeromorph [KT23].

We focus on a simple approach, which we refer to as “naive folding”, that composes Jolt (with **Twist** and **Shout**) with a folding scheme such as Nova [KST22]. There are alternatives to “naive folding”, which are more efficient but require additional design and engineering: distill reductions in protocols such as **Twist** and **Shout** and directly construct folding schemes for virtual machine executions, offering a folding-centric route to constructing zkVMs (see NeutronNova [KS24b] and Nebula [AS24] for more details).

**Details of naive folding.** We restrict our attention to Nova here because using a more advanced folding scheme than Nova does not immediately provide significant benefits for naive folding. However, the description applies if we replace Nova with another similar scheme.

Recall that Nova [KS24b] is a proof system (also called an IVC scheme) that proves incremental computations of the form  $y = F^{(\ell)}(x)$ , where  $F$  is a possibly non-deterministic polynomial time computation,  $x$  is the initial input, and  $y$  is the output after  $\ell > 0$  iterations. The proof is produced in an incremental fashion: the prover takes as input a proof of  $i$  iterations of  $F$  and updates it to produce a proof of  $i+1$  iterations of  $F$ . Crucially, the prover’s work, the proof size, and the verifier’s work do not grow with the number of iterations executed. Internally, Nova is built using a simple primitive called a folding scheme, which reduces the task of checking two NP instances of certain size  $n$  to the task of checking a single NP instance of size  $n$ .

Suppose that Jolt is modified to prove a certain pre-determined number of CPU cycles  $n$  starting from a given register and memory state  $S$  and ending with a given register and memory state  $S'$ . Then given a program that executes for  $N$  CPU cycles (without loss of generality, assume that  $N$  is a multiple of  $n$ ), we can break the execution of the program into  $\ell = N/n$  “shards”, and have Jolt produce  $\ell$  separate proofs, one per shard. Each proof attests to the correct execution of the CPU for  $n$  cycles transitioning state from

<span id="page-26-0"></span>

<sup>24</sup>https://github.com/a16z/jolt

 $S$  to  $S'$ . When using *Twist*, this requires committing to the state of memory and registers at the end of shard, which requires time linear in memory size for each shard to prove that  $S'$  is consistent with committed increments. Note that approaches such as Nebula [AS24] do not incur this  $O(M)$  costs for each shard, where  $M$  is the size of memory and register state. They only incur this cost at the end of  $N$  cycles. Obtaining a similar performance profile with *Twist* remains open.

We then write a function  $F$  in Nova that verifies a single Jolt proof.  $F$  also needs to ensure that the register state and memory state are consistent from shard-to-shard. This can be done by making  $F$  output commitments to memory and register state, which are provided as part of Jolt's proof of a shard. Furthermore,  $F$  can then check that the starting state of a Jolt proof (for shard  $i$  where  $i > 1$ ) is consistent with the ending state of prior shard  $i - 1$  by comparing commitments provided at shard  $i$  (as part of Jolt proof for shard  $i$ ) with outputs provided by  $F$  at shard  $i - 1$ . In Nova, the output of a shard is automatically fed as input to the next shard. We could then have the prover feed the  $\ell$  Jolt proofs it produced to  $\ell$  sequential steps of Nova's IVC scheme. This produces a single Nova proof attesting to the correct execution of  $\ell$  shards of the program's execution, which in turn proves the correct execution of  $N$  CPU cycles.

The upshot is that this composition of Jolt with Nova allows it scale to prove any number of CPU cycles while benefiting from the prover-memory-efficiency properties of Nova. Note that we only need to fix a value of  $n$  and we do not need to fix a particular value for  $N$ . In other words, with this design, the prover can pause its VM and resume it at any time to execute additional cycles.

**An optimization to defer polynomial evaluation arguments.** Recall that a Jolt proof consists of three components: (1) multilinear polynomial commitments, (2) sum-check proofs, and (3) polynomial evaluation arguments to prove the evaluation of committed polynomials at a random point chosen over the course of the sum-check protocol. In the description above,  $F$  verifies both the sum-check proofs and polynomial evaluation proofs arising from “monolithic” Jolt. We now discuss an optimization that allow the Jolt prover to defer producing polynomial evaluation proofs. This optimization is particularly attractive because polynomial evaluation arguments are particularly expensive for the prover. For example, with HyperKZG and Zeromorph, for a polynomial of size  $m$  (i.e., a multilinear polynomial with  $\log m$  variables) the prover must compute several MSMs of size  $m$  and the scalars in the MSMs are random. Furthermore, with Shout and Twist, the committed polynomials are slightly superlinear in size. For example, they are of size  $m = T \cdot K^{1/d}$ , where  $T$  is the number of CPU cycles proven in a shard,  $K$  is the size of memory, and  $d$  is a parameter. So, it is important to avoid proving evaluations of those polynomials for every shard.

Instead of producing a polynomial evaluation proof, the Jolt prover outputs an instance-witness pair (and the Jolt verifier outputs an instance) in the  $R_{\text{polyeval}}$  relation [KS24a, Definition 21]. In a nutshell, an instance in this relation is of the form  $u = (C, x, y)$  and a witness is a polynomial  $w = P$ . A witness is satisfying if  $P$  is a multilinear polynomial,  $C$  is a commitment to  $P$ , and that  $P(x) = y$ .

These instances can be folded using a small variant of HyperNova's multi-folding scheme, which we now sketch. The “running” instance is a single instance in the  $R_{\text{polyeval}}$  relation and the “incoming” instances (which are produced via a Jolt proof) are rerandomized so that they all share the same evaluation point. This is analogous to how HyperNova rerandomizes running instances in its multi-folding scheme for CCS by running the sum-check protocol. Once all the instances share the same evaluation point, all instances can be folded into a single instance with a simple random linear combination.

With this folding scheme in place,  $F$  would simply fold instance-witness pairs in  $R_{\text{polyeval}}$  (present in a Jolt proof) into a running instance. This requires representing HyperNova's folding scheme verifier in  $F$ , which involves verifying a sum-check proof and taking a weighted sum of  $k$  commitments, where  $k$  is the number of instance-witness pairs folded per Jolt proof. The prover does incur  $O(m) = O(T \cdot K^{1/d})$  field operations in the folding scheme. This is tolerable in our setting as long as we set  $d$  sufficiently large to ensure that the cost contribution from this component is smaller than the cost to generate a Jolt proof of a shard. For example, with  $K = 2^{30}$  memory cells (representing several GBs of memory), we can set  $d = 4$  or  $d = 8$ .

With this optimization, Jolt+Nova's IVC proof includes a Nova proof and a single instance-witness pair  $(u, w)$  in  $R_{\text{polyeval}}$ . In addition to verifying Nova's IVC proof, the Jolt+Nova verifier will have to verify the validity of that instance-witness pair. Alternatively, the prover can replace the instance-witness pair  $(u, w)$ 

with  $(u, \pi)$ , where  $\pi$  is a polynomial evaluation argument proving the knowledge of a witness satisfying  $u$  and the verifier would validate  $\pi$  in addition to validating a Nova proof.
