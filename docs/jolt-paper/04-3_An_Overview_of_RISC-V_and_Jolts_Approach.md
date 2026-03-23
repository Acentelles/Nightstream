## 3 An Overview of RISC-V and Jolt’s Approach

This section first provides a brief overview of the RISC-V instruction set architecture considered in this work. Our goal is to convey enough about the architecture that readers who have not previously encountered it can follow this paper. However, a complete specification is beyond the scope of this work, and can be found

at [And17].<sup>17</sup> We also stick to regular control flow and do not support external events and other unusual run-time conditions like exceptions, traps, interrupts and CSR registers.

Informally, the RISC-V ISA consists of a CPU and a read-write memory, collectively called the *machine*.

**Definition 3.1** (Machine State). *The machine state consists of  $(PC, \mathcal{R}, \mathcal{M})$ .  $\mathcal{R}$  denotes the 32 integer registers, each of  $W$  bits, where  $W$  is 32 or 64.  $\mathcal{M}$  is a linear read-write byte-addressable array consisting of a fixed number of total locations (such as  $2^{20}$ ) with each location storing 1 byte. The  $PC$ , also of  $W$  bits, is a separate register that stores the memory location of the instruction to be executed.*

Assembly programs consist of a sequence of instructions, each of which operate on the machine state. The instruction to be executed at a step is the one stored at the address pointed to by the  $PC$ . Unless specified by the instruction, the  $PC$  is advanced to the next memory location after executing the instruction. The RISC-V ISA specifies that all instructions are 32 bits long (i.e., 4 bytes), so advancing the  $PC$  to the next memory location entails incrementing  $PC$  by 4.

While RISC-V uses multiple formats to store instructions in memory, we can abstract away the details and represent all instructions in the following 5-tuple format.

**Definition 3.2** (5-tuple RISC-V Instruction Format). *Any RISC-V instruction can be written in the following format:  $[\text{opcode}, \text{rs1}, \text{rs2}, \text{rd}, \text{imm}]$ . That is, each instruction specifies an operation code uniquely identifying its function, at most two source registers  $\text{rs1}$ ,  $\text{rs2}$ , a destination register  $\text{rd}$ , and a constant value  $\text{imm}$  (standing for “immediate”) provided in the program code itself.*

Figure 1 provides a brief schematic of the CPU state change and instruction format. Operations read the source registers, perform some computation, and can do any or all of the following: read from memory, write to memory, store a value in  $\text{rd}$ , or update the  $PC$ . For example, the logical left-shift instruction “(SLL,  $\text{r5}$ ,  $\text{r8}$ ,  $\text{r2}$ , -)” reads the value stored in register #5, performs a logical left shift on the value by the length stored in register #8, and stores the result in register #2 (and does not involve any immediates).

As another example, the branch instruction “(BEQ,  $\text{r5}$ ,  $\text{r8}$ , -,  $\text{imm}$ )” sets  $PC$  to be  $PC + \text{imm}$  if the values stored in registers #5 and #8 are equal, or increments  $PC$  by 4, otherwise. (The destination register is not involved).

**Unsigned and signed data types.** For the RISC-V ISA, data in registers has no type. A register simply stores  $W$  bits. However, different instructions can be conceptualized as interpreting register values in different ways. Specifically, some instructions operate upon unsigned data types, while others operate over signed data types. All RISC-V instructions involving signed data types interpret the bits in a register as an integer via two’s complement representation.<sup>18</sup> For many instructions (such as ADD and SUB), the use of two’s complement has the consequence that the instruction operates identically regardless of whether or not the inputs are interpreted as signed or unsigned. See Appendix C for more information on two’s complement notation and arithmetic.

For some instructions, like multiplication MUL, and integer comparison, the desired input/output behavior differs depending on whether the inputs are interpreted as signed or unsigned. In these cases, there will be two different RISC-V instructions, one for each interpretation. For example, there are MUL and MULU instructions, with the former interpreting its inputs as signed, and the latter interpreting its inputs as unsigned. Similarly, there are two integer comparison operations, SLT and SLTU.

Let  $z$  be an  $W$ -bit data type with constituent bits  $[z_{W-1}, \dots, z_0]$  such that  $z = \sum_{i=0}^{W-1} 2^i \cdot z_i$ . When discussing instructions interpreting their  $W$ -bit inputs as signed data types represented in two’s-complement format (e.g., Section 5.3), we refer to  $z_{W-1}$  as the sign bit of  $z$ , and denote this by  $z_s$ . (Concretely, the sign bit of a 64-bit register value  $z$  will be  $z_s = z_{63}$ .) We use  $z_{<s}$  to refer to  $[z_{W-2}, \dots, z_0] \in \{0, 1\}^{W-1}$ .

<sup>17</sup>Another helpful resource for interested readers is Lectures 5-8 at [https://inst.eecs.berkeley.edu/~cs61c/resources/su18\\_lec/](https://inst.eecs.berkeley.edu/~cs61c/resources/su18_lec/).

<sup>18</sup>See [https://en.wikipedia.org/wiki/Two%27s\\_complement](https://en.wikipedia.org/wiki/Two%27s_complement) for an overview of how two’s complement maps bit vectors in  $\{0, 1\}^L$  to integers in  $\{-2^L, \dots, 2^L - 1\}$  and vice versa.

![Diagram of CPU state transition. State i contains Registers, PC, and Memory. An instruction consisting of opcode, rs1, rs2, rd, and imm transforms it into State i+1 with updated Registers, PC, and Memory.](4801720824e4b5e2361a5564f91cfb70_img.jpg)

```

graph LR
    subgraph State_i [CPU State i]
        direction TB
        subgraph Regs_PC [ ]
            direction LR
            R[Regs] --- P[PC]
        end
        M[Memory]
    end

    State_i -- "instr = (opcode, rs1, rs2, rd, imm)" --> State_i_plus_1

    subgraph State_i_plus_1 [CPU State i + 1]
        direction TB
        subgraph Regs_PC_prime [ ]
            direction LR
            Rp[Regs'] --- Pp[PC']
        end
        Mp[Memory']
    end
  
```

Diagram of CPU state transition. State i contains Registers, PC, and Memory. An instruction consisting of opcode, rs1, rs2, rd, and imm transforms it into State i+1 with updated Registers, PC, and Memory.

(a) The CPU state and instruction formats.

#### CPU Step Transition:

1. Read the instruction at location PC in Program Code.  
Parse instruction as [opcode, rs1, rs2, rd, imm].
2. Read the  $W$ -bit values stored in registers `rs1, rs2`.
3. If required, write to or read from memory.  
*The value written and memory location accessed are derived from the values stored in `rs1, rs2, imm`.*
4. Perform the instruction’s function on the values read from registers and `imm` to get `result`.  
*Examples of functions are arithmetic, logical and comparison operations.*
5. Store `result` to register `rd`.  
*Only a few instructions, like STOREs, do not involve `rd`.*
6. Update PC.  
*PC is usually incremented by 4, but instructions like jumps and branches update PC in other ways.*

(b) The broad stages of a CPU step transition.

Figure 1: A model of RISC-V’s CPU state and transition function. Note that the transition function is deterministic and all information required, such as the location of memory accessed, is derived from the CPU state and `instr`.

**Sign and Zero Extensions.** A “sign-extension” of an  $L$ -bit value  $z$  to  $W$  bits (where  $L < W$ ) is the  $W$ -bit value  $z_{\text{sign-ext}}$  with bits  $[z_s, \dots, z_s, z_{L-1}, \dots, z_0]$ . That is, the sign bit of  $z$  is replicated to fill the higher-order bits of  $z$  until it reaches length  $W$ . A “zero-extension” is when, instead of the sign bit, the 0 bit is used. This results in  $W$ -bit  $z_{\text{zero-ext}}$  with bits  $[0, \dots, 0, z_{L-1}, \dots, z_0]$ .

### 3.1 Performing instruction logic using lookups

As described in Section 2.3, the Jolt paradigm avoids the complexity of implementing each instruction’s logic as constraints by encapsulating instruction execution into a lookup table. Specifically, we identify an “evaluation table” for each operation  $\text{opcode}$ ,  $T_{\text{opcode}}[x \parallel y] = r$ , that contains the required result for all possible inputs  $x, y$ . Jolt combines the tables for all instructions into one table and thus makes only one lookup query per step to this table as  $T_{\text{risc-v}}[\text{opcode} \parallel x \parallel y] = r$  (see Section 7 for details). Given a processor and instruction set, this table is fixed and independent of the program or inputs. The key contribution of Jolt is to design these enormous tables with a certain structure (see Definition 2.6) that allows for efficient lookup arguments using Lasso.

**Preparing operands and the lookup query.** The main responsibility of the constraint system is to prepare the appropriate operands  $x, y$  at each step before the lookup. This is efficient to do as the operands only come from the set {value in `rs1`, value in `rs2`, `imm`, `PC`}. This means, for example, that the instructions

ADD and ADDI are expressed by the same lookup table as they only differ in whether the second operand comes from register `rs2` or is `imm`, respectively. With the operands prepared, the lookup query is then committed to by the prover and fed to the lookup argument for verification. The query is of the form `opcode`  $\parallel$  `z` where `z` is generally `x`  $\parallel$  `y` or  $(x + y)$  or  $(x \times y)$ , making it either  $2 \cdot W$  or  $W + 1$  bits in length. The prover provides as advice the claimed entry, `result`, in the lookup table corresponding to the query.

The trace of all lookup queries and entries is sent to `Lasso`. As described in Definition 2.6, `Lasso` requires the query to be split into “chunks” which are fed into different subtables. The prover provides these chunks as advice, which are  $c$  in number for some small constant  $c$ , and hence approximately  $W/c$  or  $2W/c$  bits long, depending on the structure of `z`. The constraint system must verify that the chunks correctly constitute `z`, but need not perform any range checks as the `Lasso` algorithm itself later implicitly enforces these on the chunks.

![Diagram illustrating the proof of CPU execution correctness. The diagram is divided into two main sections: 'Per-step Proof Statement' and 'Final Proof'. The 'Per-step Proof Statement' section shows a sequence of steps for CPU state i: Read instruction, Read source registers, Read/write to memory, Construct lookup query, and Update register, PC, leading to CPU State (i+1). Each step involves interactions with Program Code, Regs, Memory, and a LOOKUP TABLE. The 'Final Proof' section shows the verification steps: Offline Memory Checking (using Read/write transcript for Program Code, Regs, Memory), LASSO (using Lookups transcript), and R1CS (using Full transcript).](724c7777b608e53be38b12b6fb3c43bc_img.jpg)

The diagram illustrates the process of proving CPU execution correctness. It is divided into two main sections: **Per-step Proof Statement** and **Final Proof**.

**Per-step Proof Statement** (left side, enclosed in a dashed box):

- CPU State  $i$**  (start state)
- Read instruction**: Interaction with **Program Code** (exchanges **PC** and **instr**).
- Read source registers**: Interaction with **Regs** (exchanges **rs1, rs2** and **v1, v2**).
- Read/write to memory**: Interaction with **Memory** (exchanges **loc/v** and **val**).
- Construct lookup query**: Interaction with **LOOKUP TABLE** (exchanges **opcode, x, y** and **result**).
- Update register, PC**: Interaction with **Regs** (exchanges **rd, result**) and **Program Code** (exchanges **next PC**).
- CPU State  $(i + 1)$**  (end state)

**Final Proof** (right side):

- Read/write transcript for Program Code, Regs, Memory** → **Offline Memory Checking**: Ensures correctness of all memory operations.
- Lookups transcript** → **LASSO**: Ensures correctness of lookups.
- Full transcript** → **R1CS**: Constraints ensure correctness of the execution trace, assuming all lookups and memory operations are correct.

Diagram illustrating the proof of CPU execution correctness. The diagram is divided into two main sections: 'Per-step Proof Statement' and 'Final Proof'. The 'Per-step Proof Statement' section shows a sequence of steps for CPU state i: Read instruction, Read source registers, Read/write to memory, Construct lookup query, and Update register, PC, leading to CPU State (i+1). Each step involves interactions with Program Code, Regs, Memory, and a LOOKUP TABLE. The 'Final Proof' section shows the verification steps: Offline Memory Checking (using Read/write transcript for Program Code, Regs, Memory), LASSO (using Lookups transcript), and R1CS (using Full transcript).

Figure 2: Proving the correctness of CPU execution using offline memory checking (Section 3.2) and lookups (Section 3.1).

### 3.2 Using Memory-Checking

The machine state transition involves reading from and writing to three conceptually separate parts of memory: (1) the program code, (2) the registers and (3) the random access memory. As discussed in Section 2.4, the most efficient way to enforce correct reads and writes is by using the offline memory checking techniques. Unlike other operations, loads and stores do not involve lookups to a large table to perform their core function.

As is standard in zkVM design, `Jolt` conceptualizes the memory-checking procedure as a black box that guarantees correctness of all the memory reads and writes required by the CPU execution, and hence the proof proceeds assuming these operations are correct. For example, suppose a value  $v$  was written to location  $k$  at step  $t$  of the CPU’s execution. Later, when location  $k$  needs to be read, the prover sends as advice  $(v', t')$  claiming that the most recent write to location  $k$  was done at step  $t'$  and the value written was  $v'$ . All of these read and write  $(k, v, t)$  tuples are committed to during the execution of `Jolt` and later fed to the memory-checking argument, which will only pass if every read was consistent with the latest write. The main job of the constraint system here is to prevent any cheating by enforcing range checks on the time values provided by the prover ( $t'$  in the above example). These are done efficiently using `Lasso`. See Appendix B.3 for more details.

**Supporting byte-addressable memory.** RISC-V requires that memory be byte-addressable (as opposed to word-addressable). A load or store operation may read up to  $W/8$  (which equals four and eight for 32-bit and 64-bit processors, respectively) bytes in a given instruction. Thus, when writing a  $W$ -bit value  $v$ , the prover must provide its byte-decomposition  $[v_1 \dots v_{W/8}]$  as each byte is stored in a separate address in memory. Jolt enforces range-checks on the provided bytes through lookups performed using `Lasso`. See Appendix A.2 for more details.

Furthermore, certain load instructions also require the values read from memory to be sign-extended to  $W$  total bits before stored in the register. This requires only a short lookup query using the highest order byte to a small table to obtain the sign bit.

### 3.3 Formatting assembly code

Before the proof starts, the assembly code is formatted into the 5-tuple form of Definition 3.2: (`opcode`, `rs1`, `rs2`, `rd`, `imm`). Additionally, each instruction also comes with 14 one-bit “flags” `opflags`[14] that guide the constraint system. For example, `opflag`[5] is 1 for only Jump instructions, and `opflags`[7] is 1 if and only if the lookup’s result is to be stored in `rd`. Note that these flags are fixed for any given instruction. See Appendix A.1 for a list of all the flags used in Jolt. Load and store instructions (that is, those involving memory) involve additional flags of their own.

In RISC-V, instructions may need to sign-extend or zero-extend `imm` to  $W$  bits. This is a deterministic choice that depends only on the instruction (and is independent of the rest of the program or inputs). Thus, when formatting the instruction to the 5-tuple format, the immediate is appropriately extended to  $W$  bits.

Putting this together, before the proof starts, the prover and verifier convert the RISC-V assembly code and store it in a manner accessible to the constraint system. For the purposes of memory-checking, program code is in a different address-space than regular random-access memory. It is read-only and is initialized as follows: the original instruction at location `PC` is converted to the form (`opcode`, `rs1`, `rs2`, `rd`, `imm`, `opflags`[14]) and the elements of this tuple are respectively stored at locations  $[6 \cdot \text{PC}, \dots, 6 \cdot \text{PC} + 5]$ . The constraint system performs six memory-checking reads per CPU step to obtain these entries. As the program code is read-only, the prover simply commits to the elements of the tuple and only one extra timestamp that we know to be less than  $T$ , the number of steps up to that point in the program (see Appendix B.3 for more details).
