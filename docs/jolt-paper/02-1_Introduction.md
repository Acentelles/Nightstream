## 1 Introduction

A SNARK (Succinct non-interactive argument of knowledge) is a cryptographic protocol that lets an untrusted prover  $\mathcal{P}$  prove to a verifier  $\mathcal{V}$  that they know a witness  $w$  satisfying some property. A trivial proof is for  $\mathcal{P}$  to explicitly send  $w$  to  $\mathcal{V}$ , who can then directly check on its own that  $w$  satisfies the claimed property. We refer to this trivial verification procedure as *direct witness checking*. A SNARK achieves the same effect, but with better costs to the verifier. Specifically, the term *succinct* roughly means that the proof should be shorter than this trivial proof (i.e., the witness  $w$  itself), and verifying the proof should be much faster than direct witness checking.

As an example, the prover could be a cloud service provider running an expensive computation on behalf of its client who acts as the verifier. A SNARK gives the verifier confidence that the prover ran the computation honestly. Alternatively, in a blockchain setting, the witness could be a list of valid digital signatures authorizing several blockchain transactions. A SNARK can be used to prove that one *knows* the signatures, so that the signatures themselves do not have to be stored and verified by all blockchain nodes. Instead, only the SNARK needs to be stored and verified on-chain.

### 1.1 SNARKs for Virtual Machine abstractions

A popular approach to SNARK design today is to prove the correct execution of *computer programs*. This means that the prover proves that it correctly ran a specified computer program  $\Psi$  on a witness. In the example above,  $\Psi$  might take as input a list of blockchain transactions and associated digital signatures authorizing each of them, and verify that each of the signatures is valid.

---

\*New York University

†Microsoft Research

‡a16 crypto research and Georgetown University

Many projects today accomplish this via a CPU abstraction (in this context, also often called a *Virtual Machine (VM)*). Here, a VM abstraction entails fixing a set of *primitive instructions*, known as an instruction set architecture (ISA), analogous to assembly instructions in processor design. A full specification of the VM also includes the number of registers and the type of memory that is supported. The computer program that the prover proves it ran correctly must be specified in this assembly language.

To list a few examples, several so-called zkEVM projects seek to achieve “byte-code level compatibility” with the Ethereum Virtual Machine (EVM), which means that the set of primitive instructions is the 141 opcodes available on the EVM. Other zkEVMs do not aim for byte-code level compatibility, instead aiming to offer SNARKs for high-level smart contract languages such as Solidity (without first compiling the solidity to EVM bytecode).

Still other so-called zkVM projects take a similar approach but do not target the EVM instruction set, nor high-level languages like Solidity that are often compiled to EVM bytecode. These projects typically choose (or design) ISAs for their purported “SNARK-friendliness”, or for surrounding infrastructure and tooling, or for a combination thereof. For example, Cairo-VM is a very simple virtual machine designed specifically for compatibility with SNARK proving [GPR21, AGL<sup>+</sup>22]. The VM has 3 registers, memory that is read-only (each cell can only be written to once) and must be “continuous”, and the primitive instructions are roughly addition and multiplication over a finite field, jumps, and function calls.<sup>1</sup>

Another example is the RISC Zero project, which uses the RISC-V instruction set. RISC-V is popular in the computer architecture community, and comes with a rich ecosystem of compiler tooling to transform higher-level programs into RISC-V assembly. Other zkVM projects include Polygon Miden,<sup>2</sup> Valida,<sup>3</sup> and many others.

**Front-end, back-end paradigm.** SNARKs are built using protocols that perform certain probabilistic checks, so to apply SNARKs to program executions, one must express the execution of a program in a specific form that is amenable to probabilistic checking (e.g., as arithmetic circuits or generalizations thereof). Accordingly, most SNARKs consist of a so-called *front-end* and *back-end*: the front-end transforms a witness-checking computer program  $\Psi$  into an equivalent circuit-satisfiability instance, and the back-end allows the prover to establish that it knows a satisfying assignment to the circuit.

Typically, the circuit will “execute” each step of the compute program one at a time (with the help of untrusted “advice inputs”). Executing a step of the CPU conceptually involves two tasks: (1) identify which primitive instruction should be executed at this step, and (2) execute the instruction and update the CPU state appropriately. Existing front-ends implement these tasks by carefully devising gates or so-called constraints that implement each instruction. This is time-intensive and potentially error-prone. As we show in this work, it also leads to circuits that are substantially larger than necessary.

**Pros and cons of the zkVM paradigm.** One major benefit of zkVMs that use pre-existing ISAs is that they can exploit extant compiler infrastructure and tooling. This applies, for example, to the RISC-V and EVM instruction set, and leads to a developer-friendly toolchain without building the infrastructure from scratch. One can directly invoke existing compilers that transform witness-checking programs written in high-level languages down to assembly code for the ISA, and benefit from prior audits or other verification efforts of these compilers.

Another benefit of zkVMs is that a single circuit can suffice for running all programs up to a certain time bound, whereas alternative approaches may require re-running a front-end for every program (see the discussion in Section 1.6 of other front-end approaches). Finally, frontends for VM abstractions output circuits with repeated

---

<sup>1</sup>The Cairo toolchain allows programmers to write programs in a higher-level language called Cairo 1.0, and these programs are compiled into primitive instructions for the Cairo-VM. Even the high-level language only exposes write-once (also known as immutable) memory to the programmer and does not offer signed integer data types. See <https://www.cairo-lang.org/> for information on the high-level language and [GPR21, AGL<sup>+</sup>22] and <https://github.com/lambdaclass/cairo-vm> for information on the Virtual Machine.

<sup>2</sup><https://polygon.technology/polygon-miden>

<sup>3</sup><https://github.com/valida-xyz/valida-compiler/issues/2>

structure. For a given circuit size, backends targeting circuits with repeated structure [Set20, BSBHR19, WTS<sup>+</sup>18] can be much faster than backends that do not leverage repeated structure [CHM<sup>+</sup>20, GWC19, Gro16].

However, zkVMs also have downsides that render them inappropriate for some applications. First, circuits implementing a VM abstraction are often much larger than circuits that do not. This means that zkVM provers are often much slower end-to-end than SNARK provers that do not impose upon themselves a VM abstraction.

For example, implementing certain important operations in a zkVM (e.g., cryptographic operations such as Keccak hashing or ECDSA signature verification) is extremely expensive—e.g., ECDSA signature verification takes up to 100 microseconds to verify on real CPUs, which translates to millions of RISC-V instructions.<sup>4</sup> This is why zkVM projects contain so-called gadgets or built-ins, which are hand-optimized circuits and lookup tables computing specific functionalities.

A second downside is that, in order to expose a high-level programming language to developers, zkVMs require a compiler that transforms such high-level computer programs into assembly code for the VM. These compilers represent a large attack surface. Any bug in the compiler can render the system insecure: proving that one correctly ran assembly code does not guarantee knowledge of a valid witness if the assembly code fails to correctly implement the intended witness-checking procedure.

**The conventional wisdom on zkVMs.** The prevailing viewpoint today is that simpler VMs can be turned into circuits with fewer gates per step of the VM. This is most apparent in the design of particularly simple and ostensibly SNARK-friendly VMs such as the Cairo-VM. However, this comes at a cost, because primitive operations that are standard in real-world CPUs require many primitive instructions to implement on the simple VM.

In part to minimize the overheads in implementing standard operations on such limited VMs, many projects have designed domain specific languages (DSLs) that are exposed to the programmer who writes the witness-checking program. The proliferation of DSLs places a burden on the programmer, who is responsible both for learning the DSL and writing correct programs in it (with catastrophic security consequences if a program is incorrect).

Moreover, existing zkVMs remain expensive for the prover, even for very simple ISAs. For example, the prover for Cairo-VM programs described in [GPR21, AGL<sup>+</sup>22] cryptographically commits to 51 field elements per step of the Cairo-VM. This means that a single primitive instruction for the Cairo-VM may cause the prover to execute millions of instructions on real CPUs. This severely limits the applicability of SNARKs for VM abstractions, to applications involving only very simple witness-checking procedures.

### 1.2 Jolt: A new paradigm for zkVM design

In this work, we introduce a new paradigm in zkVM design. The result is zkVMs with much faster provers, as well as substantially improved auditability and extensibility (i.e., a simple workflow for adding additional primitive instructions to the VM). Our techniques are general. As a concrete example, we instantiate them for the RISC-V instruction set (with multiplication extension [And17]), a popular open-source ISA developed by the computer architecture community without SNARKs in mind.

Our results upend the conventional wisdom that simpler instruction sets necessarily lead to smaller circuits and associated faster provers. First, our prover is faster per step of the VM than existing SNARK provers for much simpler VMs. Second, the complexity of our prover primarily depends on the size (i.e., number of bits) of the inputs to each instruction. This holds so long as all of the primitive instructions satisfy a natural notion of structure, called *decomposability*. Roughly speaking, decomposability means that one can evaluate the instruction on a given pair of inputs  $(x, y)$  by breaking  $x$  and  $y$  up into smaller chunks, evaluating a small number of functions of each chunk, and combining the results. A primary contribution of our work is to show that decomposability is satisfied by all instructions in the RISC-V instruction set.

<sup>4</sup>See <https://github.com/riscv/riscv/tree/v0.16.0/examples/ecdsa>.

**Lookup arguments and Lasso.** In a lookup argument, there is a predetermined “table”  $T$  of size  $N$ , meaning that  $T \in \mathbb{F}^N$ . An (*unindexed*) lookup argument allows the prover to commit to any vector  $a \in \mathbb{F}^m$  and prove that every entry of  $a$  resides somewhere in the table. That is, for every  $i \in \{1, \dots, m\}$ , there exists some  $k$  such that  $a_i = T[k]$ . In an *indexed* lookup argument, the prover commits not only to  $a \in \mathbb{F}^m$ , but also a vector  $b \in \mathbb{F}^m$ , and the prover proves that for every  $i$ ,  $a_i = T[b_i]$ . In this setting, we call  $a$  the vector of *lookups* and  $b$  the vector of associated *indices*.

In a companion paper, we describe a new lookup argument called **Lasso** (which applies to both indexed and unindexed lookups). One distinguishing feature of **Lasso** is that it applies even to tables that are far too large for anyone to materialize in full, so long as the table satisfies the *decomposability* condition mentioned earlier.

**Jolt.** Say  $\mathcal{P}$  claims to have run a certain computer program for  $m$  steps, and that the program is written in the assembly language for a VM. Today, front-ends produce a circuit that, for each step of the computation: (1) identifies what instruction to execute at that step, and then (2) executes that instruction.

**Lasso** lets one replace Step 2 with a single lookup. For each instruction, the table stores the entire evaluation table of the instruction. If instruction  $f$  operates on two 64-bit inputs, the table stores  $f(x, y)$  for every pair of inputs  $(x, y) \in \{0, 1\}^{64} \times \{0, 1\}^{64}$ . This table has size  $2^{128}$ . In this work, we show that all RISC-V instructions are decomposable.

### 1.3 Costs of Jolt

#### 1.3.1 Background and context

**Polynomial commitments and MSMs.** A central component of most SNARKs is a cryptographic protocol called a *polynomial commitment scheme* (see Definition 2.2). Such a scheme allows an untrusted prover to succinctly commit to a polynomial  $p$  and later reveal an evaluation  $p(r)$  for a point  $r$  chosen by the verifier (the prover will also return a *proof* that the claimed evaluation is indeed equal to the committed polynomial’s evaluation at  $r$ ). In **Jolt**, as with most SNARKs, the bottleneck for the prover is the polynomial commitment scheme.

Many popular polynomial commitments are based on multi-exponentiations (also known as multi-scalar multiplications, or MSMs). This means that the commitment to a polynomial  $p$  (with  $n$  coefficients  $c_0, \dots, c_{n-1}$  over an appropriate basis) is

$$\prod_{i=0}^{n-1} g_i^{c_i},$$

for some public generators  $g_1, \dots, g_n$  of a multiplicative group  $\mathbb{G}$ . Examples include KZG [KZG10], Bulletproofs/IPA [BCC<sup>+</sup>16, BBB<sup>+</sup>18], Hyrax [WTS<sup>+</sup>18], and Dory [Lee21].<sup>5</sup>

The naive MSM algorithm performs  $n$  group exponentiations and  $n$  group multiplications (note that each group exponentiation is about  $400\times$  slower than a group multiplication). But Pippenger’s MSM algorithm saves a factor of about  $\log(n)$  relative to the naive algorithm. This factor can be well over  $10\times$  in practice.

**Working over large fields, but committing to small elements.** If all exponents appearing in the multi-exponentiation are “small”, one can save another factor of  $10\times$  relative to applying Pippenger’s algorithm to an MSM involving random exponents. This is analogous to how computing  $g_i^{2^{16}}$  is  $10\times$  faster than computing  $g_i^{2^{160}}$ : the first requires 16 squaring operations, while the second requires 160 such operations.

In other words, if one is promised that all field elements (i.e., exponents) to be committed via an MSM are in the set  $\{0, 1, \dots, K\} \subset \mathbb{F}$ , the number of group operations required to compute the MSM depend only on  $K$  and not on the size of  $\mathbb{F}$ .<sup>6</sup>

<sup>5</sup>In Hyrax and Dory, the prover does  $\sqrt{n}$  MSMs each of size  $\sqrt{n}$ .

<sup>6</sup>Of course, the cost of each group operation depends on the size of the group’s base field, which is closely related to that of the scalar field  $\mathbb{F}$ . However, the *number* of group operations to compute the MSM depends only on  $K$ , not on  $\mathbb{F}$ .

Quantitatively, if all exponents are upper bounded by some value  $K$ , with  $K \ll n$ , then Pippenger’s algorithm only needs (about) one group *operation* per term in the multi-exponentiation. More generally, with any MSM-based commitment scheme, Pippenger’s algorithm allows the prover to commit to roughly  $k \cdot \log(n)$ -bit field elements (meaning field elements in  $\{0, 1, \dots, n\}$ ) with only  $k$  group *operations* per committed field element. So for size- $n$  MSMs, one can commit to  $\log(n)$  bits with a *single* group operation.

**Polynomial evaluation proofs.** In any SNARK, the prover not only has to commit to one or more polynomials, but also reveal to the verifier an evaluation of the committed polynomials at a point of the verifier’s choosing. This requires the prover to compute a so-called evaluation proof, which establishes that the returned evaluation is indeed consistent with the committed polynomial. For some polynomial commitment schemes, such as Bulletproofs/IPA [BCC<sup>+</sup>16, BBB<sup>+</sup>18], evaluation proofs are quite slow and this cost can bottleneck the prover. However, for others, evaluation proof computation is a low-order cost [WTS<sup>+</sup>18, BBHR18, Lee21]. Moreover, evaluation proofs exhibit excellent batching properties, whereby the prover can commit to many polynomials and only produce a single evaluation proof across all of them [BGH19, Lee21, KST22, BDFG20]. So in many contexts, computing opening proofs is not a bottleneck even when a scheme such as Bulletproofs/IPA is employed. For these reasons, our accounting in this work ignores the cost of polynomial evaluation proofs.

#### 1.3.2 Costs of Jolt

**Prover costs.** For RISC-V instructions on 64-bit data types (with the multiply extension), Jolt’s  $\mathcal{P}$  commits to under 60 field elements per step of the RISC-V CPU. Only six of those field elements are larger than  $2^{25}$ , and none of them are larger than  $2^{64}$ . With MSM-based polynomial commitment, the Jolt prover costs are roughly that of committing to 6 arbitrary (256-bit) field elements per CPU step.

One caveat is that we handle six RISC-V instructions (all in the multiplication extension) via several “pseudoinstructions”. For example, we handle the division with remainder instruction by having  $\mathcal{P}$  provide the quotient and remainder as untrusted advice, and they are checked for correctness by applying multiplication and addition instructions. Another caveat is that some load and store instructions have modestly higher costs than those listed above. Conversely, many instructions (those involving addition, subtraction, shifts, jumps, loads, and stores) can be handled with *fewer than* five committed 256-bit field elements.

**Comparison of prover costs to prior works.** A detailed experimental comparison of Jolt to existing zkVMs will have to wait until a full implementation is complete, but some crude comparisons to prior works are illustrative. Recall that, when using an MSM-based multilinear polynomial commitment scheme (such as multilinear analogs of KZG, like Zeromorph [KT23]) we estimate the cost of the Jolt prover as being roughly that of committing to five arbitrary 256-bit field elements per step of the RISC-V CPU.

Plonk [GWC19] is a popular backend that can prove statements about certain generalizations of arithmetic circuit satisfiability. When Plonk is applied to an arithmetic circuit (i.e., consisting of addition and multiplication gates of fan-in two), the Plonk prover commits to 11 field elements per gate of the circuit, and 7 of these 11 field elements are random. Thus, the Jolt prover costs are roughly equivalent to applying the Plonk backend to an arithmetic circuit with only about one gate per step of the RISC-V CPU.

A more apt comparison is to the RISC Zero project<sup>7</sup>, which currently targets the RISC-V ISA on 32-bit data types (with the multiplication extension). A direct comparison is complicated, in part because RISC Zero uses FRI as its (univariate) polynomial commitment scheme, which is based on FFTs and Merkle-hashing, avoiding the use of elliptic curve groups. Jolt can use related polynomial commitment schemes (Jolt can use any commitment scheme for multilinear polynomials). However, we choose to focus on elliptic-curve-based schemes, because Jolt’s property of having the prover commit only to elements in  $\{0, \dots, b\}$  for some  $b \ll |\mathbb{F}|$  benefits those commitment schemes more than hashing-based ones.<sup>8</sup> Still, a crude comparison can be made by comparing how many field elements the RISC Zero prover commits to, vs. the Jolt prover.

<sup>7</sup><https://www.risczero.com/>

<sup>8</sup>This property would also benefit hashing-based commitment schemes that operate over an extension field of a relatively small base field, owing to all committed elements in Lasso being in the base field.

The RISC Zero prover commits to at least 275 31-bit field elements per CPU step [Tom23]. This is roughly equivalent to committing to about  $275 \cdot 32/256 \approx 34$  different 256-bit field elements per CPU step: at least on small instances, the prover bottleneck is Merkle-hashing the result of various FFTs [Tom23], and one can hash 8 different 31-bit field elements with the same cost as hashing one 256-bit field element.

A final comparison point is to the SNARK for the Cairo-VM described in the Cairo whitepaper [GPR21]. The prover in that SNARK commits to about 50 field elements per step of the Cairo Virtual Machine, using FRI as the polynomial commitment scheme. StarkWare currently works over a 251-bit field.<sup>9</sup> This field size may be larger than necessary (it is chosen to match the field used by certain ECDSA signatures), but the provided arithmetization of Cairo-VM *requires* a field of size at least  $2^{63}$ . So the commitment costs for the prover are at least equivalent to committing to  $50 \cdot 64/256 \approx 13$  256-bit field elements.<sup>10</sup> Jolt’s prover costs per CPU compare favorably to this, despite the RISC-V instruction set being vastly more complicated than the Cairo-VM (and with the Cairo-VM instruction set specifically designed to be ostensibly “SNARK-friendly”).

**Verifier costs of Jolt.** For RISC-V programs running for at most  $T$  steps, the dominant costs for the Jolt verifier are performing  $O(\log(T) \log \log(T))$  hash evaluations and field operations,<sup>11</sup> plus checking one evaluation proof from the chosen polynomial commitment scheme (when applied to a multilinear polynomial over at most  $O(\log T)$  variables).

Verifier costs can be further reduced, and the SNARK rendered zero-knowledge, via composition with a zero-knowledge SNARK with smaller proof size. For example, see the recent work Testudo for a related approach (Testudo instantiates Spartan [Set20] with a variant of PST polynomial commitments [PST13] (an analog of KZG commitments [KZG10] for multilinear rather than univariate polynomials) and composes this with Groth16 [Gro16]).

### 1.4 The lookup singularity

In a research forum post in 2022, Barry Whitehat articulated a goal of designing front-ends that produce circuits that *only* perform lookups [Whi]. Whitehat terms this the *lookup singularity* and sketches how achieving this would help address a key issue (the potential for security bugs, and difficulty of auditability) that must be addressed for long-term and large-scale adoption of SNARKs. Circuits that only perform lookups (and the lookup arguments that enable them) should be much simpler to understand and formally verify than circuits consisting of many gates that are often hand-optimized.

Whitehat’s post acknowledges that current lookup arguments are expensive, but predicts that lookup arguments will get more performative with time. Arguably, Jolt realizes the vision of the lookup singularity. The bulk of the prover work in Jolt lies in the lookup argument, Lasso. The Jolt front-end does output some constraints that effectively implement the task of the RISC-V CPU figuring out, at each step of the computation, which instruction to execute. These constraints are simple and easily captured in R1CS.

### 1.5 Technical details: CPU instructions as structured polynomials

Lasso is most efficient when applied to lookup tables satisfying a property called *decomposability*. Intuitively, this refers to tables  $t$  such that one lookup into  $t$  of size  $N$  can be answered with a small number (say, about  $c$ ) of lookups into much smaller tables  $t_1, \dots, t_\ell$ , each of size  $N^{1/c}$ . Furthermore, if a certain polynomial  $\tilde{t}_i$  associated with each  $t_i$  can be evaluated at any desired point  $r$  using, say,  $O(\log(N)/c)$  field operations,<sup>12</sup> then no one needs to cryptographically commit to any of the tables (neither to  $t$  itself, nor to  $t_1, \dots, t_\ell$ ).

<sup>9</sup>See, for example, [https://github.com/starkware-libs/starkex-contracts/blob/master/audit/EVM\\_STARK\\_Verifier\\_v4.0\\_Audit\\_Report.pdf](https://github.com/starkware-libs/starkex-contracts/blob/master/audit/EVM_STARK_Verifier_v4.0_Audit_Report.pdf).

<sup>10</sup>Furthermore, in order to control proof size, StarkWare currently uses a “FRI blowup factor” of 16, compared to RISC Zero’s choice of 4. This adds at least an extra factor of 4 to the prover time per field element committed, relative to RISC Zero’s.

<sup>11</sup>As described in Appendix B.3, Lasso can use any so-called *grand product argument*. The  $O(\log(T) \log \log(T))$  verifier cost are due to the choice of grand product argument from [SL20, Section 6]. Other choices of lookup argument offer different tradeoffs between commitment costs for the prover, versus proof size and verifier time.

<sup>12</sup>The Lasso verifier has to evaluate  $\tilde{t}_i$  at a random point  $r$  on its own, so we need this computation to be fast enough that we are satisfied with the resulting verifier runtime. For all tables arising in Jolt, the verifier can compute all necessary  $\tilde{t}_i$  polynomial evaluations in  $O(\log(N))$  total field operations.

Specifically,  $\tilde{t}_i$  can be any so-called *low-degree extension* polynomial of  $t_i$ . In Jolt, we will exclusively work with a specific low-degree extension of  $t_i$ , called the *multilinear extension*, and denoted  $\tilde{t}_i$ .

Hence, to take full advantage of Lasso, we must show two things:

- The evaluation table  $t$  of each RISC-V instruction has is decomposable in the above sense. That is, one lookup into  $t$ , which has size  $N$ , can be answered with a small number of lookups into much smaller tables  $t_1, \dots, t_\ell$ , each of size  $N^{1/c}$ . For most RISC-V instructions,  $\ell$  equals one or two, and about  $c$  lookups are performed into each table.
- For each of the small tables  $t_i$ , the multilinear extension  $\tilde{t}_i$  is evalutable at any point, using just  $O(\log(N)/c)$  field operations.

Establishing the above is the main technical contribution of our work. It turns out to be quite straightforward for certain instructions (e.g., bitwise AND), but more complicated for others (e.g., bitwise shifts, comparisons).

**Decomposable instructions.** Suppose that table  $t$  contains all evaluations of some primitive instruction  $f: \{0, 1\}^n \to \mathbb{F}$ . Decomposability of the table  $t$  is equivalent to the following property of  $f$ : for any  $n$ -bit input  $x$  to  $f$ ,  $x$  can be decomposed into  $c$  “chunks”,  $X_0, \dots, X_{c-1}$ , each of size  $n/c$ , and such that there following holds. There are  $\ell$  functions  $f_0, \dots, f_{\ell-1}$  such that  $f(x)$  can be derived in a relatively simple manner from  $f_i(x_j)$  as  $i$  ranges over  $0, \dots, \ell-1$  and  $j$  ranges over  $0, \dots, c-1$ . Then the evaluation table  $t$  of  $f$  is decomposable: one lookup into  $t$  can be answered with  $c$  total lookups into  $\ell \cdot c$  lookups into the evaluation tables of  $f_0, \dots, f_{\ell-1}$ .

Bitwise AND is a clean example by which to convey intuition for why the evaluation tables of RISC-V instructions are decomposable. Suppose we have two field elements  $a$  and  $b$  in  $\mathbb{F}$ , both in  $\{0, \dots, 2^{64} - 1\}$ . We refer to  $a$  and  $b$  as 64-bit field elements (we clarify here that “64 bits” does *not* refer to the size of the *field*  $\mathbb{F}$ , which may, for example, be a 256-bit field. Rather to the fact that  $a$  and  $b$  are both in the much smaller set  $\{0, \dots, 2^{64} - 1\} \subset \mathbb{F}$ , no matter how large  $\mathbb{F}$  may be).

Our goal is to determine the 64-bit field element  $c$  whose binary representation is given by the bitwise AND of the binary representations of  $a$  and  $b$ . That is, if  $a = \sum_{i=0}^{63} 2^i \cdot a_i$  and  $b = \sum_{i=0}^{63} 2^i \cdot b_i$  for  $(a_0, \dots, a_{63}) \in \{0, 1\}^{64}$  and  $(b_0, \dots, b_{63}) \in \{0, 1\}^{64}$ , then  $c = \sum_{i=0}^{63} 2^i \cdot a_i \cdot b_i$ .

One way to compute  $c$  is as follows. Break  $a$  and  $b$  into 8 chunks of 8 bits each compute the bitwise AND of each chunk, and concatenate the results to obtain  $c$ . Equivalently, we can express

$$c = \sum_{i=0}^{7} 2^{8 \cdot i} \cdot \text{AND}(a'_i, b'_i), \quad (1)$$

where each  $a'_i, b'_i \in \{0, \dots, 2^8 - 1\}$  is such that  $a = \sum_{i=0}^{7} 2^{8 \cdot i} \cdot a'_i$  and  $b = \sum_{i=0}^{7} 2^{8 \cdot i} \cdot b'_i$ . These  $a'_i$ 's and  $b'_i$ 's represent the decomposition of  $a$  and  $b$  into 8-bit limbs.<sup>13</sup>

In this way, one lookup into the evaluation table of bitwise-AND, which has size  $2^{128}$ , can be answered by the prover providing  $a'_1, \dots, a'_8, b'_1, \dots, b'_8 \in \{0, \dots, 2^8 - 1\}$  as untrusted advice, and performing 8 lookups into the size- $2^{16}$  table  $t_1$  containing all evaluations of bitwise-AND over pairs of 8-bit inputs. The results of these 8 lookups can easily be collated into the result of the original lookup, via Equation (1). No party has to commit to the size- $2^{16}$  table  $t_1$  because for any input  $(r'_0, \dots, r'_7, r''_0, \dots, r''_7) \in \mathbb{F}^{16}$ ,

$$\tilde{t}_1(r'_0, \dots, r'_7, r''_0, \dots, r''_7) = \sum_{i=0}^{15} 2^i \cdot r'_i \cdot r''_i,$$

which can be evaluated directly by the verifier with only 32 field operations.

<sup>13</sup>Just as “digits” refers a base-10 decomposition of an integer or field element, “limbs” refer to a decomposition into a different base, in this case base 8.

**Challenges for other instructions.** One may initially expect that correct execution of RISC-V operations capturing 64-bit addition and multiplication would be easy prove, because large prime-order fields come with addition and multiplication operations that behave like integer addition and multiplication until the result of the operation overflows the field characteristic. Unfortunately, the RISC-V instructions capturing addition and multiplication have specified behavior upon overflow that differs from that of field addition and multiplication. Resolving this discrepancy is one key challenge that we overcome.

### 1.6 Other front-end approaches

As with other zkVM projects, Jolt produces a so-called *universal circuit*, meaning one circuit works for all RISC-V programs running up to some time bound  $T$ . This has the benefit that the circuit-generation process only needs to be run once.

Other front-end approaches do not implement a Virtual Machine abstraction (i.e., they do not produce circuits that repeatedly execute the transition function of a specific ISA). These approaches typically output a different circuit for every computer program, such as Buffet [WSR<sup>+</sup>15], Bellman, Circom, Zokrates, Noir, etc. The circuits produced by these approaches can also be made smaller and proved faster using our techniques, though we leave this to future work.
