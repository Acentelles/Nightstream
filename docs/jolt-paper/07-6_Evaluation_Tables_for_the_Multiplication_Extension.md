## 6 Evaluation Tables for the Multiplication Extension

The M extension adds multiplication, division and remainder operations to the RISC-V ISA. These instructions are generally more complex than the base ones covered so far and involve new techniques in Jolt to handle - namely the addition of “virtual” registers and instructions.

### 6.1 Virtual Instructions and Virtual Registers

Jolt splits certain complex assembly instructions (such as MULH) into a sequence of instructions that are executed in the ZKVM in place of the original instruction. The CPU state transition guarantee that should hold for the original assembly instruction now holds after the entire sequence is executed. Note that the splitting of instructions is done in the assembly code during formatting and is independent of the input or even the rest of the program code.

To avoid jumbling with the base registers, Jolt introduces new “virtual” registers that virtual instructions use to store intermediate values. These registers have addresses outside the standard set of base registers but are otherwise read from and stored to identically. To ensure safety, the only time the “real” CPU state is changed is when the last virtual instruction of the sequence stores the final result in the “real” destination register of the original instruction.

**Reflecting the program counter.** It is common for programs to use the value stored in the PC register directly in program logic, such as through Jumps or the AUIPC instruction. In these cases, it may be required to maintain two program counters in the ZKVM. The first is the normal one used for keeping tracking of the next address in the VM including virtual instructions. The second is used for reflecting the true value of “real” PC and is not updated during virtual instructions. As the PC is a relatively small value to commit to, this incurs negligible overhead to the prover’s costs and the constraint system. For simplicity, we assume the standard one PC model in the rest of this paper’s discussion but incorporate the cost of a second PC in Section 8.

#### 6.1.1 ASSERT Instructions

Asserts are a type of virtual instruction that add circuit constraints on an instruction’s result. For example, an ASSERT-[COND] constraint uses the lookup table for the branch instruction B[COND] but additionally adds a constraint that the lookup must return 1. Assert instructions do not have a destination register. On top of the conditional checks seen in the Set-Less-Than and Branch instructions, Jolt supports the following assert instructions:

ASSERT-LT-ABS takes two  $W$ -bit two’s complement signed inputs and outputs  $|x| < |y|$ .

ASSERT-EQ-SIGNS takes two  $W$ -bit two’s complement signed inputs and outputs  $x_s == y_s$ .

| OP              | INDEX           | FULL MLE                                                      |
|-----------------|-----------------|---------------------------------------------------------------|
| ASSERT-LT-ABS   | $x \parallel y$ | $\text{LTU}(x_{<s}, y_{<s}) \quad // \text{ignore sign bits}$ |
| ASSERT-EQ-SIGNS | $x \parallel y$ | $\widetilde{\text{EQ}}(x_s, y_s)$                             |

#### 6.1.2 ADVICE and MOVE Instructions

ADVICE  $v$ : stores a special  $W$ -bit non-deterministic circuit input into virtual register  $v$ .

MOVE  $v_1, v_2$ : copies the value in register  $v_1$  into register  $v_2$  (either could be virtual).

The advice instruction allows the prover to store non-deterministic advice into virtual registers. The lookup query’s function here is to act as a range check on the advice and thus, uses the range check table. The “non-deterministic” part of these instructions is that their lookup’s query isn’t derived in the circuit (such as through registers, memory or `imm`) but comes from advice passed into the CPU step circuit. Thus, unlike the immediate `imm`, these values aren’t fixed in the assembly code and can be set by the prover at proving time. ADVICE has no source register or immediate and only specifies a destination register.

The MLEs of these instructions are identical to the that of the range checks.

| OP     | INDEX | MLE                                                          |
|--------|-------|--------------------------------------------------------------|
| ADVICE | $x$   | $\sum_{i=0}^{W-1} 2^i \cdot x_i \quad // \text{range check}$ |
| MOVE   | $x$   | $\sum_{i=0}^{W-1} 2^i \cdot x_i \quad // \text{range check}$ |

### 6.2 The M-Extension Tables

As before, for some new instructions, we give MLE-structured tables for each instruction and describe how it can be decomposed. For other new instructions, we provide the “virtual” sequence of previously-defined instructions that result in the same CPU state change.

#### 6.2.1 Unsigned or Lower Multiplication

The following instructions take two  $W$ -bit operands  $x$  and  $y$ .

MUL returns the lower  $W$  bits of  $x \times y$  where the operands are treated as signed two’s complement numbers.

MULU returns the lower  $W$  bits of  $x \times y$  where the operands are treated as unsigned  $W$ -bit numbers.

MULHU returns the higher  $W$  bits of  $x \times y$  where the operands are treated as unsigned  $W$ -bit numbers.

Similar to ADD, Jolt performs the core multiplication operation in the circuit as computing  $z = x \times y$  costs just one constraint. The circuit then queries  $z$  in the lookup tables of the instructions, which have a row for every possible  $2W$ -bit  $z$  with the entry being the desired bits. Note that while MUL is a signed operation, performing unsigned multiplication returns the same lower bits.

| OP    | INDEX            | FULL TABLE MLE                                                  |
|-------|------------------|-----------------------------------------------------------------|
| MUL   | $z = x \times y$ | $\sum_{i=0}^{W-1} 2^i \cdot z_i \quad // \text{lower L bits}$   |
| MULU  | $z = x \times y$ | $\sum_{i=0}^{W-1} 2^i \cdot z_i \quad // \text{lower L bits}$   |
| MULHU | $z = x \times y$ | $\sum_{i=L}^{2W-1} 2^i \cdot z_i \quad // \text{higher L bits}$ |

**Decomposability.** These MLEs can be decomposed in a manner similar to the AND table and effectively like the tables for range checks.

#### 6.2.2 Signed and Higher MUL

MULH returns the higher  $W$  bits of  $x \times y$  where the operands are treated as signed two’s complement numbers.

MULHSU returns the higher  $W$  bits of  $x \times y$  where only  $x$  is signed but  $y$  is unsigned.

These instructions are more complicated than the others as they require signed multiplication which means the operands are sign-extended to  $2W$  bits before performing the multiplication. This leads to the result having  $4W$  and  $3W$  total bits in MULH and MULHSU, respectively. As this is too large to handle with a lookup query, we instead compute the desired bits in stages.

For a number  $x$ , let  $s_x$  be  $\sum_{i=0}^{W-1} 2^i x_s$  such that  $[s_x \parallel x]$  is the sign-extension of  $x$  to  $2W$  bits. The signed multiplication algorithm performs the following  $2W \times 2W$ -bit multiplication and returns the highest  $2W$  bits:  $[s_x \parallel x] \times [s_y \parallel y]$ . As the instructions above are only interested in the higher  $W$  bits of this result, we can represent the required bits as the *lower*  $W$  bits of the sum of the following three values each computed using only unsigned multiplication:

$$[\text{higher } W \text{ bits of } x \times y] + [\text{lower } W \text{ bits of } s_x \times y] + [\text{lower } W \text{ bits of } s_y \times x]$$

Given  $s_x, s_y$ , the above terms can be obtained using MULH, MULU instructions and the sum computed using ADD. To get  $s_x, s_y$ , we define a new instruction, MOVSIGN, which takes an  $W$ -bit input  $x$  and stores the  $W$ -bit number with  $x_s$  as all of its binary coefficients in the destination register.

| OP      | INPUT | FULL MLE                                                                          |
|---------|-------|-----------------------------------------------------------------------------------|
| MOVSIGN | $x$   | $\sum_{i=0}^{W-1} 2^i \cdot x_s \quad // \text{ place sign bit in all positions}$ |

**Decomposability.** This table can be **decomposed** naturally using one subtable function.

We can now split MULH, MULHSU into virtual instructions following the above procedure. We use  $r_x, r_y$  to denote the two operand registers. We use “v” to name virtual registers. (In actual formatted assembly code, these are replaced by a free numbered virtual register.)

| Original                   | Virtual Sequence (OPCODE, rs1, rs2, imm, rd)                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| MULH $r_x, r_y, \text{rd}$ | 1. MOVSIGN $r_x, -, -, v_{s_x} \quad // \text{ store } s_x \text{ in a virtual register}$<br>2. MOVSIGN $r_y, -, -, v_{s_y} \quad // \text{ store } s_y$<br>3. MULHU $r_x, r_y, -, v_0 \quad // \text{ get higher bits of } x \times y$<br>4. MULU $v_{s_x}, r_y, -, v_1 \quad // \text{ get lower bits of } s_x \times y$<br>5. MULU $v_{s_y}, r_x, -, v_2 \quad // \text{ get lower bits of } s_y \times x$<br>6. ADD $v_0, v_1, -, v_3$<br>7. ADD $\text{rd}, v_2, -, \text{rd}$ |
| MULH $r_x, r_y, \text{rd}$ | 1. MOVSIGN $r_x, -, -, v_{s_x}$<br>2. MULHU $r_x, r_y, -, v_1$<br>3. MULU $v_{s_x}, v_y, -, v_2$<br>4. ADD $v_1, v_2, -, \text{rd}$                                                                                                                                                                                                                                                                                                                                                 |

The correctness of the output can be seen by inspection as the steps follow the natural binary multiplication algorithm. It can also be seen that the “real” CPU state is only modified in the final steps of each sequence, when the result is stored into  $\text{rd}$ .

### 6.3 Division and Remainder

In RISC-V, division and remainder operations take two  $W$ -bit values read from registers. In Jolt, for both operations, the prover provides as non-deterministic advice the quotient  $q$  and remainder  $r$  using the ADVICE instruction introduced in Section 6.1.2. The correctness of this advice is verified using a sequence of virtual

instructions, as shown below. As both DIV and REM instructions perform the same checks, they have nearly identical virtual instructions with only the last instruction differing based on the desired value ( $q$  or  $r$ ).

**Unsigned versions.** In unsigned division, both operands  $x, y$  and quotient  $q$  and remainder  $r$  are all treated as unsigned  $W$ -bit numbers. DIVU/REMU require  $x$  to be equal to  $q \times y + r$  such that  $r < y$  and  $q \times y \le x$ .

| Original            | Virtual Sequence (OPCODE, rs1, rs2, imm, rd)                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DIVU $r_x, r_y, rd$ | 1. ADVICE $-, -, -, v_q$ // store non-deterministic advice $q$ into $v_q$<br>2. ADVICE $-, -, -, v_r$ // store non-deterministic advice $r$ into $v_r$<br>3. MULU $v_q, r_y, -, v_{qy}$ // compute $q \times y$<br>4. ASSERT.LTU $v_r, r_y, -, -$ // verify that $r < y$<br>5. ASSERT.LTE $v_{qy}, r_x, -, -$ // assert $q \times y \le x$<br>6. ADD $v_{qy}, v_r, -, v_0$ // compute $q \times y + r$<br>7. ASSERT.EQ $v_0, r_x, -, -$<br>8. MOVE $v_q, -, -, rd$ // store $q$ in $rd$ |
| REMU $r_x, r_y, rd$ | 1-7. same as above<br>8. MOVE $v_r, -, -, rd$ // store $r$ in $rd$                                                                                                                                                                                                                                                                                                                                                                                                                      |

**Signed versions.** In signed division, both operands  $x, y$  and quotient  $q$  and remainder  $r$  are all treated as signed 2's complement  $W$ -bit numbers.

DIVU/REMU requires  $x = q \times y + r$  such that  $|r| < |y|$  and  $r, y$  have the same sign.

| Original           | Virtual Sequence                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| DIV $r_x, r_y, rd$ | 1. ADVICE $-, -, -, v_q$ // store non-deterministic advice $q$ into $v_q$<br>2. ADVICE $-, -, -, v_r$ // store non-deterministic advice $r$ into $v_r$<br>3. ASSERT_LT_ABS $v_r, r_y, -, -$ // verify that $ r  <  y $<br>4. ASSERT_EQ_SIGNS $v_r, r_y, -, -$ // require $r$ to have the sign of $y$<br>5. MUL $v_q, r_y, -, v_{qy}$ // compute $q \times y$<br>6. ADD $v_{qy}, v_r, -, v_0$ // compute $q \times y + r$<br>7. ASSERT_EQ $v_0, r_x, -, -$<br>8. MOVE $v_q, -, -, rd$ // store $q$ in $rd$ |
| REM $r_x, r_y, rd$ | 1-7. same as above<br>8. MOVE $v_r, -, -, rd$ // store $r$ in $rd$                                                                                                                                                                                                                                                                                                                                                                                                                                        |

As with the splitting of the multiplication instructions, the correctness of the output can be seen by inspection as the steps follow the straightforward verification of division. Also, the real CPU state is only modified in the final steps.
