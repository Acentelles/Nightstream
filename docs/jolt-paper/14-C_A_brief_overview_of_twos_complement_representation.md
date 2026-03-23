## C A brief overview of two’s complement representation

An *unsigned  $L$ -bit data type* refers to a value  $z \in \{0, 1, \dots, 2^L - 1\}$ . A *signed  $L$ -bit data type* (in twos-complement format) refers to a value  $z \in \{-2^{L-1}, \dots, 2^{L-1} - 1\}$ . The twos-complement representation  $[z_{L-1}, \dots, z_0] \in \{0, 1\}^L$  of  $z$  is the unique vector such that

$$z = -z_{L-1} \cdot 2^{L-1} + \sum_{i=0}^{L-2} 2^i z_i. \quad (14)$$

For clarity, when discussing instructions interpreting their inputs as signed data types represented in twos-complement format (e.g., Section 5.3), we refer to  $z_{L-1}$  as the sign bit of  $z$ , and denote this by  $z_s$ . We use  $z_{<s}$  to refer to  $[z_{L-2}, \dots, z_0] \in \{0, 1\}^{L-1}$ .

As discussed in Section 3, the use of two’s complement allows instructions to operate identically regardless of whether or not the inputs are interpreted as signed or unsigned. For example, consider the ADD instruction when  $L = 3$ .

When adding three-bit unsigned integers 3 and 4, the addition operation proceeds as follows:

$$3 \text{ (i.e., 011)} + 4 \text{ (i.e., 100)} = 7 \text{ (i.e., 111)}.$$

Here, in parenthesis we have provided the binary representations of 3, 4, and 7 when interpreted as unsigned data types in two’s-complement format.

When adding three-bit signed integers 3 and  $-4$ , the addition operation proceeds as follows:

$$3 \text{ (i.e., 011)} + -4 \text{ (i.e., 100)} = -1 \text{ (i.e., 111)}.$$

Again, in parentheses we have provided the binary representations of 3 and  $-4$  when interpreted as signed data types in two's complement format.

The above example demonstrates that, when using two's complement binary representations, the input/output behavior of the addition operation is independent of whether the inputs are interpreted as signed or unsigned.
