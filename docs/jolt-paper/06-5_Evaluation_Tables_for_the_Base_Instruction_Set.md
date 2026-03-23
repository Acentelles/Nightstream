## 5 Evaluation Tables for the Base Instruction Set

We now consider each of the RISC-V instructions one at a time, and analyze the MLE-structure and the decomposability of their evaluation tables. Conceptually, Jolt’s “one giant lookup table” is obtained by simply concatenating each of the evaluation tables for all instructions (see Section 7.3). For most instructions, we first present an MLE-structured table and describe how it can be decomposed into subtables, as required by Lasso.

### 5.1 Logical instructions

Each instruction performs the corresponding operation bitwise over the  $W$  bits of  $x$  and  $y$  and stores the  $W$ -bit result in **rd**. The lookup tables here have a row for each possible  $x \parallel y$  with the entry being the desired output to be stored in **rd**.

| OP  | INDEX                                            | FULL MLE                                                                 |
|-----|--------------------------------------------------|--------------------------------------------------------------------------|
| AND | $x \parallel y \in \{0, 1\}^W \times \{0, 1\}^W$ | $\sum_{i=0}^{W-1} 2^i \cdot (x_i \cdot y_i)$                             |
| OR  | $x \parallel y \in \{0, 1\}^W \times \{0, 1\}^W$ | $\sum_{i=0}^{W-1} 2^i \cdot (x_i + y_i - x_i \cdot y_i)$                 |
| XOR | $x \parallel y \in \{0, 1\}^W \times \{0, 1\}^W$ | $\sum_{i=0}^{W-1} 2^i \cdot (x_i \cdot (1 - y_i) + y_i \cdot (1 - x_i))$ |

**Decomposition.** These MLEs can further be decomposed in the natural way, requiring only one subtable per instruction. For example, a bitwise AND on two  $W$ -bit inputs can be decomposed into  $c$  bitwise ANDs, each on two  $(W/c)$ -bit inputs. That is, if  $D_0, \dots, D_{c-1} \in \{0, 1\}^{W/c}$  denote the results of these “smaller” bitwise AND operations, with  $C_i = \text{AND}_{W/c}(X_i, Y_i)$  then the result of the  $W$ -bit operation is simpler  $\sum_{i=0}^{c-1} 2^{(W/c) \cdot i} D_i$ . The decompositions for OR and XOR follow analogously.

### 5.2 Arithmetic instructions

**Addition.** For  $x, y \in \{0, 1\}^W$ ,  $\text{ADD}(x, y)$  returns the lowest  $W$  bits of (the binary representation of) the sum  $\text{int}(x) + \text{int}(y)$ . We need not specify whether the inputs to these instructions are signed versus unsigned because in RISC-V, signed data types are represented via two’s complements. When the inputs and outputs are viewed as strings in  $\{0, 1\}^W$ , the behavior of ADD and SUB is identical for signed data types as for unsigned ones.

As finite field addition costs just one constraint in R1CS, we cheaply compute  $z = x + y$  in the circuit, where here, addition is performed over finite field  $\mathbb{F}$ . However, this sum can be  $W + 1$  bits long, i.e.,  $z$  can be any field element in  $\{0, \dots, 2^{W+1} - 2\}$ . The prescribed behavior for the RISC-V instruction ADD in this event is for the “overflow bit” to be ignored.

To this end, the lookup table for the ADD instructions contains an entry for all possible  $(W + 1)$ -bit vectors  $z \in \{0, 1\}^{W+1}$ , with each  $z$ ’s entry equal to the field element  $\sum_{i=0}^{W-1} 2^i \cdot z_i$  equal to  $\text{int}(z_{<W})$ . Note that this lookup table has size only  $2^{W+1}$ , which is less than the tables of size  $2^{2W}$  that we identify for most RISC-V instructions.

**Subtraction.** Due to RISC-V’s use of two’s complement representation of signed data types, subtraction can be performed using addition. Specifically,  $\text{SUB}(x, y)$  outputs the same  $W$ -bit string as

$$\text{ADD}(x, \text{bin}(2^W - \text{int}(y))).$$

In words, subtracting  $y$  from  $x$  is equivalent to adding the two’s complement of  $y$  to  $x$ .<sup>20</sup>

| OP                 | INDEX                                              | FULL MLE                   |
|--------------------|----------------------------------------------------|----------------------------|
| $\text{ADD}(x, y)$ | $z = \text{bin}(x + y) \in \{0, 1\}^{W+1}$         | $\sum_{i=0}^{W-1} 2^i z_i$ |
| $\text{SUB}(x, y)$ | $z = \text{bin}(x + (2^W - y)) \in \{0, 1\}^{W+1}$ | $\sum_{i=0}^{W-1} 2^i z_i$ |

**Decomposition.** The decomposition of the above lookup table is simple (and essentially equivalent to the case of range checks considered in our companion paper on Lasso [STW23]).

### 5.3 Set Less Than

$\text{SLTU}$  and  $\text{SLT}$  return 1 if  $x < y$  and 0 otherwise, where  $x, y$  are unsigned and two’s complement signed  $W$ -bit numbers, respectively.

The tables for  $\text{SLTU}$  is equivalent to  $\text{LTU}$  derived in Section 4.2.2. For  $\text{SLT}$ , we must additionally take into consideration the sign bits of the two numbers and resort to a comparison of the remaining bits only when the sign bits are the same.

| OP            | INDEX           | FULL MLE                                                                                                                      |
|---------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------|
| $\text{SLTU}$ | $x \parallel y$ | See Section 4.2.2                                                                                                             |
| $\text{SLT}$  | $x \parallel y$ | $\widetilde{\text{LTS}} = x_s \cdot (1 - y_s) + \widetilde{\text{EQ}}(x_s, y_s) \cdot \widetilde{\text{LTU}}(x_{<s}, y_{<s})$ |

**Decomposition.** The decomposition of  $\text{SLTU}$  was discussed in Section 4.2.2 and requires two subtables of size  $2^{W/c}$ . The decomposition of  $\text{SLT}$  uses the same decomposition (applied to  $x_{<s}, y_{<s}$ , which has  $W - 1$  rather than  $W$  bits), but additionally devotes more two subtables to compute the  $x_s(1 - y_s)$  and  $\widetilde{\text{EQ}}(x_s, y_s)$  terms. This brings the total to four types of subtables and  $2c + 1$  total subtables used for  $\text{SLT}$ .

### 5.4 Shifts

$\text{SLL}(x, y)$  (Shift Left Logical),  $\text{SRL}(x, y)$  (Shift Right Logical) and  $\text{SRA}(x, y)$  (Shift Right Arithmetic) are the three shift operations. All shift operations take a  $W$ -bit input  $x$ , shift it by a length defined by the lowest  $\log W$  bits of  $y$  and return  $W$ -bit values. Bits shifted beyond the MSB or LSB are ignored. In logical shifts, vacated bits are filled by zeros, and in arithmetic shifts, the vacated bits are filled by the sign bit of the original input  $x$ .

The MLE-structured table for  $\text{SLL}$  and its decomposition were presented in Section 4.2.3. The tables for  $\text{SRL}$  and  $\text{SRA}$  are presented below. Let  $W' = W/c$ . For chunks  $i = 0, \dots, (c - 1)$  and shift length  $k \in \{0, 1\}^{\log W}$ , define:

$$m_{i,k}^r = \max\{0, \min\{16, \text{int}(k) - W' \cdot i\}\}.$$

<sup>20</sup>In a system implementing arithmetic on  $W$ -bit unsigned data types, the quantity  $2^W$  cannot be represented. Hence, the two’s complement of  $y$  needs to be computed in two steps, as  $(2^W - 1 - y) + 1$ , with the expression in parenthesis computed first, and then one added to the result. See [https://en.wikipedia.org/wiki/Two%27s\\_complement](https://en.wikipedia.org/wiki/Two%27s_complement) for details. In Jolt, the quantity  $2^W - \text{int}(y)$  will be computed directly in the field  $\mathbb{F}$ , which we assume to have characteristic more than  $2^W$ . Hence, the quantity  $2^W$  can be represented, and the two’s complement of  $y$  is (the binary representation of) the field element  $2^W - y$ .

Here,  $m_{i,k}^r$  equals the number of bits from the  $i$ 'th chunk that go out of range (that is, to the “right” of bit 0). Note that  $m_{i,k}^r$  is also the index of the lowest-order bit within the  $i$ 'th chunk that does *not* go out of range. That is,  $i$ 'th chunk  $X_i$  will have subsequence  $[X_{i,0}, X_{i,m_{i,k}^r-1}]$  go out of range and the remaining values will now be present in indices  $[W' \cdot (i - 1) - \text{int}(k) + m_{i,k}^r, \dots, W' \cdot (i - 1) - \text{int}(k) + W' - 1]$  of the final output. The evaluation table of SLL decomposes into  $c$  smaller tables  $\text{SLL}_0, \dots, \text{SLL}_{c-1}$  as follows.

| CHUNKS                              | SUBTABLES                                                                                                                                                                                           | FULL TABLE                                                                 |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|
| $\mathcal{C}_i = X_i \parallel Y_0$ | $\text{SRL}_i[X_i \parallel Y_0] = \sum_{k \in \{0,1\}^{\log W}} \widetilde{\text{EQ}}(Y_0, k) \cdot \left( \sum_{j=m_{i,k}^r}^{W'-1} 2^{W' \cdot (i-1) - \text{int}(k) + j} \cdot X_{i,j} \right)$ | $\text{SRL}[x \parallel y] = \sum_{i=0}^{c-1} \text{SRL}_i[\mathcal{C}_i]$ |

The SRA instruction uses an extra subtable to perform sign extension. This subtable takes as its input chunk  $\mathcal{C}_c = x_s \parallel Y_0$ , where  $x_s$  is the sign bit of the input.

| CHUNKS                                                                                         | SUBTABLES                                                                                                                                                                                                      | FULL TABLE                                                               |
|------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| $i \in [0, c-1]: \mathcal{C}_i = X_i \parallel Y_0$<br>and $\mathcal{C}_c = x_s \parallel Y_0$ | For $i \in [0, c-1]$ , $\text{SRA}_i[\mathcal{C}_i] = \text{SRL}_i[\mathcal{C}_i]$<br>and $\text{SRA}_c(x_s \parallel Y_0) = \sum_{i=W-\text{int}(k)}^{W-1} \widetilde{\text{EQ}}(Y_0, k) \cdot 2^i \cdot x_s$ | $\text{SRA}[x \parallel y] = \sum_{i=0}^{c} \text{SRA}_i[\mathcal{C}_i]$ |

### 5.5 Immediate Loads

AUIPC( $x, y$ ) takes the 20-bit immediate (operand  $y$  here), adds it to PC (operand  $x$  here) and stores the output in the destination register  $\text{rd}$ , but does *not* change the PC. LUI takes the 20-bit immediate (operand  $y$ , here) and loads it into the upper 20 bits of the destination register  $\text{rd}$ .

In both of these instructions, the 20-bit immediate is formatted (see Section 3.3) into a  $W$ -bit value with the 20 significant bits stored in the *higher positions* of  $\text{imm}$  in program code (as opposed to the lower positions, as done for all other instructions). With this pre-processing, AUIPC can be treated identically to ADD with the two operands being PC and  $\text{imm}$ .

As the above pre-processing does most of the work, the only task for LUI in the circuit is to store the given  $\text{imm}$  as provided into  $\text{rd}$ . This does not require a lookup table.

| OP    | INDEX       | FULL MLE                                                    |
|-------|-------------|-------------------------------------------------------------|
| AUIPC | $z = x + y$ | $\sum_{i=0}^{W-1} 2^i z_i \quad // \text{identical to ADD}$ |

**Decomposability.** This table can be decomposed just like the table for ADD.

### 5.6 Jumps

JAL sets  $\text{PC} \leftarrow \text{PC} + \text{imm}$  and stores the address of the memory location after this new PC (obtained by incrementing it by 4) into  $\text{rd}$ . JALR similarly sets PC to be the sum  $\text{PC} + \text{imm}$  but with the LSB set to 0. It sets  $\text{rd}$  to be memory location after this new PC.

For both jump instructions, the sum  $z \leftarrow \text{PC} + \text{imm} + 4$  is calculated using constraints. The lookup table for JAL is identical to that of ADD and returns the lower  $W$  bits of  $z$ . The table for JALR does the same but then sets the LSB to 0, as well. In both instructions, PC is set to be the lookup’s result minus 4. This subtraction is performed with constraints. If it results in an underflow the memory-checking will fail when reading PC in the next step.

| OP   | INDEX           | FULL MLE                   |
|------|-----------------|----------------------------|
| JAL  | $z = x + y + 4$ | $\sum_{i=0}^{W-1} 2^i z_i$ |
| JALR | $z = x + y + 4$ | $\sum_{i=1}^{W-1} 2^i z_i$ |

**Decomposability.** These tables can be decomposed just like the table for ADD. Note that the lookup queries here are also  $W + 1$  bits long.

### 5.7 Branches

The B[COND] instructions set  $PC \leftarrow PC + \text{imm}$  if  $\text{COND}(x, y) = \text{true}$ . If false, they resort to the default change in PC.

The new PC is computed using only constraints and not with a lookup (as the lookups here are used to test the branching condition). When  $\text{imm}$  is positive, the sum ( $PC + \text{imm}$ ) obtained is correct as is. However, when  $\text{imm}$  is negative, we must perform ( $PC - \text{imm}$ ) directly without using two's complement subtraction (as that might result in an overflow). To choose which to perform, the sign of  $\text{imm}$  is stored in the program code itself during formatting as one of the `opflags` discussed in Section 3.3. If this subtraction results in an underflow the memory-checking algorithm will fail when reading PC in the next step.

Now, the lookup is used to perform the comparisons to decide whether to use this new shifted PC or not. The MLE for doing both signed and unsigned strict less than comparisons were discussed in Section 4.2.2 and used in SLT/SLTU. We use the same MLEs here, along with the  $\widetilde{\text{EQ}}$  MLE.

| OP   | INDEX           | FULL MLE                                                 |
|------|-----------------|----------------------------------------------------------|
| BEQ  | $x \parallel y$ | $1 - \widetilde{\text{EQ}}(x, y)$                        |
| BNE  | $x \parallel y$ | $\widetilde{\text{EQ}}(x, y)$                            |
| BLTU | $x \parallel y$ | $\widetilde{\text{LTU}}(x, y) // \text{as used in SLTU}$ |
| BLT  | $x \parallel y$ | $\widetilde{\text{LTS}}(x, y) // \text{as used in SLT}$  |
| BGEU | $x \parallel y$ | $1 - \widetilde{\text{LTU}}(x, y)$                       |
| BGE  | $x \parallel y$ | $1 - \widetilde{\text{LTS}}(x, y)$                       |

**Decomposability.** These MLE-structured tables can be decomposed with the same techniques used for the EQ, LTU and LTS tables.

### 5.8 Memory Loads and Stores

RISC-V uses a byte-addressable memory system that can be accessed by only the following variants of the load and store instructions:

- LD reads a 64-bit value from memory and stores it into `rd`. `L[W/H/B]` are similar, but they read only the lowest 32/16/8 bits of the value in memory and store it sign-extended to  $W$  bits into `rd`. `L[W/H/B]U` are identical to their signed counterparts but do not perform any sign-extension.
- SD takes a 64-bit operand,  $y$ , and stores it into a specified memory location. `S[W/H/B]` store only the lowest 32/16/8 bits of the operand (without any sign-extension).

These operations are performed using offline memory-checking techniques, as discussed in Section 3.2. They thus do not require a large lookup table and can be handled efficiently using just constraints and simple

range checks in Lasso. Note that the memory location involved in these operations is obtained as the sum of the value in `rs1` and `imm`, calculated using constraints just like in the Branch instructions (see Section 5.7).
