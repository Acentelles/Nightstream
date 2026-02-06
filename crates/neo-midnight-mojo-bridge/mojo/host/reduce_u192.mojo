@export("neo_midnight_bridge_reduce_u192_quotient72", ABI="C")
fn neo_midnight_bridge_reduce_u192_quotient72(
    t0: UInt64,
    t1: UInt64,
    t2: UInt64,
    out_q0: UnsafePointer[UInt32, MutAnyOrigin],
    out_q1: UnsafePointer[UInt32, MutAnyOrigin],
    out_q2: UnsafePointer[UInt32, MutAnyOrigin],
    out_r: UnsafePointer[UInt64, MutAnyOrigin],
) -> None:
    # Goldilocks prime: 2^64 - 2^32 + 1.
    var p: UInt64 = 0xFFFF_FFFF_0000_0001
    var p128: UInt128 = UInt128(p)

    # Long division of a 192-bit number by a 64-bit divisor, base 2^64.
    var rem: UInt128 = 0

    var dividend = (rem << 64) | UInt128(t2)
    _ = dividend / p128
    rem = dividend % p128

    dividend = (rem << 64) | UInt128(t1)
    var q1: UInt64 = UInt64(dividend / p128)
    rem = dividend % p128

    dividend = (rem << 64) | UInt128(t0)
    var q0: UInt64 = UInt64(dividend / p128)
    rem = dividend % p128

    # Quotient is expected to fit in 72 bits for our reductions; we only need its low 72 bits.
    var q_u128: UInt128 = UInt128(q0) | (UInt128(q1) << 64)
    var mask24: UInt128 = (UInt128(1) << 24) - 1

    out_q0.store(UInt32(q_u128 & mask24))
    out_q1.store(UInt32((q_u128 >> 24) & mask24))
    out_q2.store(UInt32((q_u128 >> 48) & mask24))
    out_r.store(UInt64(rem))

