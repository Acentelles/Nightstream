## Abstract

A memory checking argument enables a prover to prove to a verifier that it is correctly processing reads and writes to memory. They are used widely in modern SNARKs, especially in zkVMs, where the prover proves the correct execution of a CPU including the correctness of memory operations.

We describe a new approach for memory checking, which we call the *method of one-hot addressing and increments*. We instantiate this method via two different families of protocols, called **Twist** and **Shout**. **Twist** supports read/write memories, while **Shout** targets read-only memories (also known as lookup arguments). Both **Shout** and **Twist** have logarithmic verifier costs. Unlike prior works, these protocols do not invoke “grand product” or “grand sum” arguments.

**Twist** and **Shout** significantly improve the prover costs of prior works across the full range of realistic memory sizes, from tiny memories (e.g., 32 registers as in RISC-V), to memories that are so large they cannot be explicitly materialized (e.g., structured lookup tables of size  $2^{64}$  or larger, which arise in Lasso and the Jolt zkVM). Detailed cost analysis shows that **Twist** and **Shout** are well over 10× times cheaper for the prover than state-of-the-art memory-checking procedures configured to have logarithmic proof length. Prior memory-checking procedures can also be configured to have larger proofs. Even then, we estimate that **Twist** and **Shout** are at least 2–4× faster for the prover in key applications.

Finally, using **Shout**, we provide two fast-prover SNARKs for non-uniform constraint systems, both of which achieve minimal commitment costs (the prover commits *only* to the witness): (1) **SpeedySpartan** applies to Plonkish constraints, substantially improving the previous state-of-the-art protocol, BabySpartan; and (2) **Spartan++** applies to CCS (a generalization of Plonkish and R1CS), improving prover times over the previous state-of-the-art protocol, Spartan, by 6×.

\*Microsoft Research

†a16 crypto research and Georgetown University

# Contents

| <b>1</b> | <b>Introduction</b>                                                                | <b>4</b>  |
|----------|------------------------------------------------------------------------------------|-----------|
| <b>2</b> | <b>Overview of <b>Twist</b> and <b>Shout</b> and their costs</b>                   | <b>7</b>  |
| 2.1      | Background                                                                         | 7         |
| 2.2      | Formulation of the memory checking problem                                         | 9         |
| 2.3      | Prior work: Arguments via offline memory checking                                  | 11        |
| 2.4      | Costs of <b>Twist</b> and <b>Shout</b>                                             | 14        |
| 2.5      | Overview of <b>Shout</b>                                                           | 17        |
| 2.6      | Overview of <b>Twist</b>                                                           | 20        |
| 2.7      | Other benefits and implications                                                    | 23        |
| 2.8      | Appropriate settings of $d$                                                        | 24        |
| 2.9      | Additional discussion                                                              | 25        |
| <b>3</b> | <b>Technical preliminaries</b>                                                     | <b>29</b> |
| 3.1      | Prover costs in elliptic-curve-based SNARKs                                        | 29        |
| 3.2      | Multilinear extensions                                                             | 32        |
| 3.3      | The sum-check protocol                                                             | 34        |
| 3.4      | SNARKs and commitment schemes                                                      | 36        |
| 3.5      | Polynomial IOPs and polynomial commitments                                         | 37        |
| 3.6      | Zero-check PIOP                                                                    | 37        |
| 3.7      | One-hot encodings                                                                  | 39        |
| <b>4</b> | <b>The <b>Shout</b> PIOP</b>                                                       | <b>39</b> |
| 4.1      | A special case: $d = 1$                                                            | 39        |
| 4.2      | <b>Shout</b> for general $d$                                                       | 42        |
| <b>5</b> | <b>The <b>Twist</b> PIOP</b>                                                       | <b>45</b> |
| <b>6</b> | <b>Fast <b>Shout</b> prover implementation (small memories)</b>                    | <b>49</b> |
| 6.1      | Core <b>Shout</b> prover for $d = 1$                                               | 49        |
| 6.2      | Core <b>Shout</b> prover (general $d$ , small memories)                            | 49        |
| 6.3      | Booleanity-checking and one-hot-encoding-checking                                  | 52        |
| 6.4      | Cost summary for the combined <b>Shout</b> prover                                  | 56        |
| <b>7</b> | <b>Fast <b>Shout</b> prover for large, structured memories</b>                     | <b>56</b> |
| 7.1      | Sparse-dense sum-check protocol                                                    | 57        |
| 7.2      | Extension to the Booleanity-checking sum-check when $K^{1/d} \gg T$                | 58        |
| 7.3      | <b>Shout</b> 's read-checking sum-check                                            | 63        |
| 7.4      | The $\text{raf}$ -evaluation sum-check and Hamming-weight-one check when $K \gg T$ | 63        |
| 7.5      | Cost summary for <b>Shout</b> when $K \gg T$                                       | 64        |
| <b>8</b> | <b>Fast <b>Twist</b> prover implementation</b>                                     | <b>64</b> |
| 8.1      | $\tilde{\text{Val}}$ -evaluation sum-check                                         | 64        |
| 8.2      | Read-checking and write-checking sum-checks                                        | 65        |
| 8.3      | Cost summary                                                                       | 72        |
| <b>9</b> | <b>Faster SNARKs for non-uniform computation</b>                                   | <b>72</b> |
| 9.1      | Overview                                                                           | 72        |
| 9.2      | Details of <b>SpeedySpartan</b>                                                    | 73        |
| 9.3      | Details of <b>Spartan++</b>                                                        | 79        |
| <b>A</b> | <b>Overview of offline memory-checking protocols</b>                               | <b>85</b> |

| B | Details of the Val f -evaluation sum-check prover                    | 87 |
|---|----------------------------------------------------------------------|----|
|   | B.1<br>Computing the Less-Than evaluation table<br>                  | 87 |
|   | B.2<br>Optimizing the Val f -evaluation sum-check prover further<br> | 88 |
| C | A Shout variation with a linear prover dependence on d               | 90 |
|   | C.1<br>Fast prover implementation<br>                                | 91 |

<span id="page-3-0"></span>
