## B Overview of Memory-Checking Arguments

### B.1 Merkle trees

One way to implement a memory-checking argument is via Merkle trees. This approach was first introduced to the literature on SNARKs in Pantry [BFR<sup>+</sup>13] and is still used today in so-called *incrementally verifiable computing* (IVC) schemes (see [BSCTV14] for an early example). Conceptually, the VM whose execution is being proved is modified as follows, so as to authenticate its own memory. The VM at all times tracks the root hash of a Merkle tree that has the contents of each of its memory cells at the leaves (let us say that the number of memory cells is  $N$ ). Every read operation returns not only the value stored in the appropriate memory cell, but also a Merkle authentication path that the machine checks for consistency with the stored root hash. Write operations are preceded by a read operation, which allows the VM to update the root hash in an authenticated manner.

The downside of the Merkle tree approach is that each read and write requires proving knowledge of a Merkle authentication path, which involves  $\log N$  many hash evaluations. This can be an effective approach if there are not many reads and writes, but is very expensive for the prover for executions involving many reads and writes.

### B.2 Re-ordering the execution trace

The rough idea of this approach to designing a memory-checking argument is to have the prover “re-order” the execution trace so that, rather than entries appearing in increasing order of timestep, they instead are grouped by the memory location read or written at that step, and within each group, entries are sorted by time. This is called a “memory-ordered” execution trace (see [Tha22, Section ] for an exposition). It is straightforward to design a quasilinear-size circuit that takes as input a memory-ordered execution trace, and confirms that the value returned by every read operation is indeed the value last written to the appropriate memory cell. zkVM projects taking this, or related, approaches to memory-checking include RISC Zero [BGtR23] and Cairo [GPR21].

The core of the memory-checking argument amounts to confirming that the memory-ordered execution trace is indeed a re-ordering (i.e., permutation) of the time-ordered execution trace. Some early works [BSCGT13] proposed to accomplish this using so-called *routing networks*, a complicated and expensive technique from the PCP literature. Later works [BCG<sup>+</sup>18, ZGK<sup>+</sup>18] proposed to instead use lightweight *permutation-invariant fingerprinting* techniques dating to the memory-checking literature from the late 1980s and early 1990s [Lip89, BEG<sup>+</sup>91]. The key idea in these techniques is to check whether two vectors  $a, b \in \mathbb{F}^N$  are permutations of each other (i.e., whether there exists a permutation  $\pi: \{1, \dots, N\} \to \{1, \dots, N\}$  such that  $a_i = b_{\pi(i)}$  for all  $i$ ) by having the verifier pick a random  $r \in \mathbb{F}$ , and checking that

$$\prod_{i=1}^{N} (r - a_i) = \prod_{i=1}^{N} (r - b_i). \quad (11)$$

If  $a$  and  $b$  are permutations, this check will pass with probability 1, while if they are not permutations, the check will pass with probability only  $m/|\mathbb{F}|$ . This technique is now pervasive in SNARK design, appearing in works such as Plonk [GWC19]. We refer to this as *permutation-invariant fingerprinting*.

1. Input: vectors  $a, b \in \mathbb{F}^N$ .
2. Goal: determine whether  $a$  and  $b$  are permutations of each other.
3. Pick a random  $r \in \mathbb{F}^N$ , and checks that

$$\prod_{i=1}^{N} (r - a_i) = \prod_{i=1}^{N} (r - b_i).$$

Figure 5: Permutation-invariant fingerprinting.

1. Input: vectors  $a, b \in \mathbb{F}^N$ .
2. Goal: determine whether  $a = b$ .
3. Pick a random  $r \in \mathbb{F}^N$ , and checks that

$$\sum_{i=1}^{N} a_i r^{i-1} = \prod_{i=1}^{N} b_i r^{i-1}.$$

Figure 6: Reed-Solomon fingerprinting. If  $a = b$  then the check passes with probability 1. If  $a \neq b$ , then the check passes with probability at most  $(N - 1)/|\mathbb{F}|$ .

We have described the checking procedure as interactive, since the verifier picks the random field element  $r$ , but the procedure can be rendered non-interactive via the Fiat-Shamir transformation. In any SNARK that uses permutation-checking, the vectors  $a$  and  $b$  will be committed by the prover, and  $r$  will be chosen by hashing those commitments (and any other messages sent by the prover earlier in the interactive protocol).

### B.3 Memory-checking via permutation-checking, without re-ordering

Spartan [Set20], Spice [SAGL18], and descendants including our companion paper Lasso [STW23] build on the memory-checking work of Blum et al. [BEG<sup>+</sup>91] to obtain memory-checking arguments that do not reorder the execution trace.

**Overview of the Lasso lookup argument.** To illustrate the approach, we begin with a brief overview of (the simplest variant of) the Lasso lookup argument from our companion paper [STW23], which has prover commitment costs linear in the table size. Here, let us consider a VM that is given read-only access to lookup table  $T$ . To render the VM’s reads more easily checkable, let us modify the VM’s reading procedure as follows.

- For each memory cell  $j = 1, \dots, N$  maintain a counter  $e_j$ , which is supposed to track how many times cell  $j$  has been read.
- Every time a read operation to cell  $b_i$  returns a (value, count) pair  $(a, e)$ , have the VM write the tuple  $(a, e + 1)$  to cell  $b_i$ . That is, the VM follows every read operation by writing the returned value back to the cell that was just read, incrementing the returned counter value by 1.
- When all the reads are done, the VM makes one final pass over memory. This final set of  $N$  reads are not paired with write operations.

Let  $\text{RS}$  (short for *read-set*) be the vector of all (cell, value, count) tuples returned by the memory across all read operations. Let  $\text{WS}$  (short for *write-set*) be the vector of all (cell, value, count) tuples across all write operations.  $\text{WS}$  includes the  $N$  writes to initialize memory, i.e., the tuples  $(j, T[j], 0) : j = 1, \dots, N$ . Prior

works [BEG<sup>+</sup>91, Set20, STW23] establish the following lemma, whose proof we omit for brevity.

**Lemma 2.** **RS** and **WS** are permutations of each other if and only if the result of every read operation to each cell  $j$  indeed returns the  $(\text{value}, \text{count})$  pair last written to that cell. Here, **RS** and **WS** are permutations of each other if they are equal as multisets of  $(\text{cell}, \text{value}, \text{count})$  tuples.

With this lemma in hand, one can obtain an (indexed) lookup argument as follows. Recall that in an indexed lookup argument, the prover has committed to two vectors  $a, b \in \mathbb{F}^m$ , and wishes to prove that  $a_i = T[b_i]$  for all  $i$ . View  $a$  as the vector of all values returned by the read operations of the modified VM above, and  $b$  as the vector specifying the cell targeted by each read operation. The prover next commits to the vector  $c \in \mathbb{F}^{m+N}$ , whose  $i$ ’th entry is purported to be the count returned by the  $i$ ’th read operation.

If the prover chooses  $c$  honestly, then by Lemma 2, **RS** and **WS** are permutations of each other. Conversely, by the same lemma, if **RS** and **WS** are permutations of each other, then each read operation returned the correct value, and hence  $a_i = T[b_i]$  for all  $i = 1, \dots, m$ . So it suffices for the lookup argument prover to prove that **RS** and **WS** are permutations of each other.

To this end, first Reed-Solomon fingerprint each  $(\text{cell}, \text{value}, \text{count})$  tuple. That is, the verifier picks a random  $\gamma \in \mathbb{F}$  and sends  $\gamma$  to the prover. The prover then replaces all tuples  $(b, a, c)$  in **RS** or **WS** with  $b + \gamma a + \gamma^2 c$ .

This reduces **RS** and **WS** from vectors of  $N + m$  triples of field elements, to vectors **RS**' and **WS**' in  $\mathbb{F}^{N+m}$ . If there are no “collisions” (two distinct tuples with matching fingerprints) then **RS**' and **WS**' are permutations of each other if and only if **RS** and **WS** are. Clearly, the probability of a collision is at most  $(N + m)^2/|\mathbb{F}|$  (a more careful analysis can bound the soundness error by at most  $2(N + m)/|\mathbb{F}|$ ).

Hence, up to the above soundness error, checking whether **RS** and **WS** are permutations of each other is equivalent to checking whether **RS**' and **WS**' are permutations.

This latter check is done via permutation-invariant fingerprint (Figure 5).

In summary, in the indexed lookup argument, the prover first commits to the vector  $c \in \mathbb{F}^{m+N}$  purported to be the counts returned by the read operations specified by the vectors  $a, b \in \mathbb{F}^m$ . (More precisely, the prover commits to the multilinear extension  $\tilde{c}$  of  $c$ , using any multilinear polynomial commitment scheme).

The verifier then confirms that **RS** is a permutation of **WS** by picking two random field elements  $\gamma, \alpha$ , and ensuring that the following two quantities are equal:

$$\prod_{i=0}^{m-1} (\alpha - (b_i + \gamma \cdot a_i + \gamma^2 \cdot c_i)) \prod_{i=0}^{N-1} (\alpha - (i + \gamma \cdot T[i] + \gamma^2 \cdot c_{m+i})) \quad (12)$$

and

$$\left( \prod_{i=0}^{N-1} (\alpha - (i + \gamma \cdot T[i])) \right) \cdot \left( \prod_{i=0}^{m-1} (\alpha - (b_i + \gamma \cdot a_i + \gamma^2 \cdot (c_i + 1))) \right). \quad (13)$$

Here, Expressions (12) and (13) are the permutation-invariant fingerprints of **RS**' and **WS**' respectively.

**Lasso** forces the prover to correctly compute these two expressions using any grand product argument. Specifically, it **Lasso** suggests to use either a highly optimized variant of the GKR-protocol [GKR08] due to Thaler [Tha13], which avoids any additional commitment costs for the prover, or a variant with shorter proofs but slightly higher commitment costs [SL20]. At the end of these grand product arguments, the verifier needs to evaluate each of  $\tilde{T}, \tilde{a}, \tilde{b}$ , and  $\tilde{c}$  at a randomly chosen point. The evaluations of  $\tilde{a}, \tilde{b}$ , and  $\tilde{c}$  can be obtained from the polynomial commitment scheme used to commit to each of these polynomials. For MLE-structured tables, the evaluation of  $\tilde{T}$  can be computed by the verifier with only  $O(\log N)$  field operations.

The above argument protocol is implicit in **Spark**, the sparse polynomial commitment scheme given in **Spartan** [Set20]. However, **Spark**’s security analysis assumed that (the commitment to the) vector  $c$  of purported counts is computed by an honest party. This sufficed for **Spartan**’s application, but not for giving a lookup argument. Our companion paper **Lasso** shows that the lookup argument is secure even if  $c$  is committed by a malicious party.

**How Lasso handles large tables.** If the lookup table is too large to justify paying a commitment cost linear in the table size, but the table is decomposable (Definition 2.6), Lasso will automatically decompose any lookup into the large table into  $c$  lookups into smaller tables, and collate the results into the result of the lookup into the large table. The simple variant of Lasso described above (with prover costs linear in table size) is applied to each subtable. See our companion paper [STW23] for details.

**Overview of Spice’s memory-checking argument.** In (the variant of) the Lasso lookup argument described above, every read operation is followed by a write that increments the count returned by the read by one. When supporting read/write memory as required in a memory-checking argument, incrementing counts by one is not sufficient to ensure security. This is because in the memory-checking setting, the machine that is reading from, and writing to, memory may write a value to memory that differs from the value returned by the most recent read operation. This gives an attacker more flexibility than a Lasso attacker has. In particular, if one tries to apply Lasso in the memory-checking setting, an attacker can potentially answer reads “out of order”, meaning answering a read at time  $i$  with a value that won’t be written until time  $j > i$ .

To prevent this type of attack, Spice updates counts in a different way (which is, unfortunately, more expensive to implement in the context of memory-checking arguments). Specifically, in Spice’s memory-checking argument, the machine is modified to maintain a timestamp  $\text{ts}$ . As in Lasso, every write is preceded by a read. If the read operation returns a count  $c$ , the count that is written is not  $c + 1$  as in Lasso, but rather  $\max\{c, \text{ts}\} + 1$ . The machine then updates the timestamp to  $\max\{c, \text{ts}\} + 1$ .

In Spice itself,  $\max\{c, \text{ts}\}$  is computed by having the prover provide the bit decomposition of  $c$  and  $\text{ts}$  as untrusted advice. In Jolt, we instead compute  $\max\{c, \text{ts}\}$  with a single lookup, into the evaluation table of the max function. Note that if the prover is honest,  $c$  and  $\text{ts}$  are always between 0 and the number of steps  $m$  that the machine is running for. This ensures that we can use a lookup table of size roughly  $m^2$ .
