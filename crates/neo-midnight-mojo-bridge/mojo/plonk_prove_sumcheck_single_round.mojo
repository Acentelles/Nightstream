from collections import List
from pathlib import Path
from sys import argv

import plonk_prove_from_snapshot
import plonk_prove_goldilocks_mul as gl_helpers
from nmb.fq import Fq
from nmb.params_kzg import parse_params_kzg


comptime GOLDILOCKS_P_U64: UInt64 = UInt64(0xFFFF_FFFF_0000_0001)
comptime K_DELTA_U64: UInt64 = UInt64(7)


struct KRepr(Copyable, ImplicitlyCopyable, Movable):
    var c0: UInt64
    var c1: UInt64

    fn __init__(out self, c0: UInt64, c1: UInt64):
        self.c0 = c0
        self.c1 = c1


struct U192(Copyable, ImplicitlyCopyable, Movable):
    var t0: UInt64
    var t1: UInt64
    var t2: UInt64

    fn __init__(out self, t0: UInt64, t1: UInt64, t2: UInt64):
        self.t0 = t0
        self.t1 = t1
        self.t2 = t2


struct Quotient72(Copyable, ImplicitlyCopyable, Movable):
    var q0: UInt32
    var q1: UInt32
    var q2: UInt32
    var r: UInt64

    fn __init__(out self, q0: UInt32, q1: UInt32, q2: UInt32, r: UInt64):
        self.q0 = q0
        self.q1 = q1
        self.q2 = q2
        self.r = r


struct CarrySum(Copyable, ImplicitlyCopyable, Movable):
    var carry: Bool
    var v: UInt64

    fn __init__(out self, carry: Bool, v: UInt64):
        self.carry = carry
        self.v = v


struct RowAndFq(Copyable, ImplicitlyCopyable, Movable):
    var row: Int
    var v: Fq

    fn __init__(out self, row: Int, v: Fq):
        self.row = row
        self.v = v


struct RowAndU64(Copyable, ImplicitlyCopyable, Movable):
    var row: Int
    var v: UInt64

    fn __init__(out self, row: Int, v: UInt64):
        self.row = row
        self.v = v


struct RowAndK(Copyable, ImplicitlyCopyable, Movable):
    var row: Int
    var c0: UInt64
    var c1: UInt64

    fn __init__(out self, row: Int, c0: UInt64, c1: UInt64):
        self.row = row
        self.c0 = c0
        self.c1 = c1


fn u192_from_u128(x: UInt128) -> U192:
    var lo: UInt64 = UInt64(x & UInt128(0xFFFF_FFFF_FFFF_FFFF))
    var hi: UInt64 = UInt64(x >> 64)
    return U192(lo, hi, UInt64(0))


fn u192_add(a: U192, b: U192) raises -> U192:
    var sum0: UInt128 = UInt128(a.t0) + UInt128(b.t0)
    var out0: UInt64 = UInt64(sum0 & UInt128(0xFFFF_FFFF_FFFF_FFFF))
    var carry0: UInt128 = sum0 >> 64

    var sum1: UInt128 = UInt128(a.t1) + UInt128(b.t1) + carry0
    var out1: UInt64 = UInt64(sum1 & UInt128(0xFFFF_FFFF_FFFF_FFFF))
    var carry1: UInt128 = sum1 >> 64

    var sum2: UInt128 = UInt128(a.t2) + UInt128(b.t2) + carry1
    if sum2 >> 64 != 0:
        raise Error("u192_add: overflow")
    var out2: UInt64 = UInt64(sum2)
    return U192(out0, out1, out2)


fn u192_from_mul_u128_u64(x: UInt128, m: UInt64) -> U192:
    # Computes x*m (x is up to 128 bits, m is up to 64 bits) returning low 192 bits.
    var x_lo: UInt64 = UInt64(x & UInt128(0xFFFF_FFFF_FFFF_FFFF))
    var x_hi: UInt64 = UInt64(x >> 64)
    var prod_lo: UInt128 = UInt128(x_lo) * UInt128(m)
    var prod_hi: UInt128 = UInt128(x_hi) * UInt128(m)
    var limb0: UInt64 = UInt64(prod_lo & UInt128(0xFFFF_FFFF_FFFF_FFFF))
    var carry0: UInt128 = prod_lo >> 64
    var mid: UInt128 = prod_hi + carry0
    var limb1: UInt64 = UInt64(mid & UInt128(0xFFFF_FFFF_FFFF_FFFF))
    var limb2: UInt64 = UInt64(mid >> 64)
    return U192(limb0, limb1, limb2)


fn reduce_u192_quotient72(t: U192) raises -> Quotient72:
    # Goldilocks prime: 2^64 - 2^32 + 1.
    var p: UInt64 = GOLDILOCKS_P_U64
    var p128: UInt128 = UInt128(p)

    # Long division of a 192-bit number by a 64-bit divisor, base 2^64.
    var rem: UInt128 = 0

    var dividend: UInt128 = (rem << 64) | UInt128(t.t2)
    var q2_hi: UInt128 = dividend / p128
    if q2_hi != 0:
        raise Error("reduce_u192_quotient72: quotient does not fit in 128 bits")
    rem = dividend % p128

    dividend = (rem << 64) | UInt128(t.t1)
    var q1: UInt64 = UInt64(dividend / p128)
    rem = dividend % p128

    dividend = (rem << 64) | UInt128(t.t0)
    var q0: UInt64 = UInt64(dividend / p128)
    rem = dividend % p128

    # Quotient is expected to fit in 72 bits for our reductions; we only need its low 72 bits.
    var q_u128: UInt128 = UInt128(q0) | (UInt128(q1) << 64)
    if (q_u128 >> 72) != 0:
        raise Error("reduce_u192_quotient72: quotient does not fit in 72 bits")
    var mask24: UInt128 = (UInt128(1) << 24) - 1

    var out_q0: UInt32 = UInt32(q_u128 & mask24)
    var out_q1: UInt32 = UInt32((q_u128 >> 24) & mask24)
    var out_q2: UInt32 = UInt32((q_u128 >> 48) & mask24)
    var out_r: UInt64 = UInt64(rem)
    return Quotient72(out_q0, out_q1, out_q2, out_r)


fn fill_native_assign(mut advice_cols: List[List[Fq]], row: Int, v: Fq) raises -> Int:
    advice_cols[0][row] = v
    return row + 1


fn fill_native_assign_bit(mut advice_cols: List[List[Fq]], row: Int, b: Bool) raises -> RowAndFq:
    var v = Fq.one() if b else Fq.zero()
    advice_cols[0][row] = v
    advice_cols[1][row] = v
    return RowAndFq(row + 1, v)


fn fill_native_lc(mut advice_cols: List[List[Fq]], row: Int, result: Fq, terms: List[Fq]) raises -> Int:
    if len(terms) == 0 or len(terms) > 4:
        raise Error("fill_native_lc: expected 1..=4 terms")
    advice_cols[0][row] = result
    for i in range(len(terms)):
        advice_cols[i + 1][row] = terms[i]
    return row + 1


fn fill_native_mul(mut advice_cols: List[List[Fq]], row: Int, x: Fq, y: Fq, res: Fq) raises -> Int:
    advice_cols[0][row] = x
    advice_cols[1][row] = y
    advice_cols[2][row] = x
    advice_cols[4][row] = res
    return row + 1


fn fill_native_select(mut advice_cols: List[List[Fq]], row: Int, cond: Fq, x: Fq, y: Fq, res: Fq) raises -> Int:
    advice_cols[0][row] = cond
    advice_cols[1][row] = x
    advice_cols[2][row] = y
    advice_cols[4][row] = res
    return row + 1


fn fill_assert_u64(mut advice_cols: List[List[Fq]], row: Int, v_u64: UInt64) raises -> Int:
    var limb_sizes = List[Int]()
    for _ in range(8):
        limb_sizes.append(8)
    gl_helpers.fill_decompose_core_cols_used_1(advice_cols, row, v_u64, limb_sizes)
    return row + 8


fn fill_alloc_gl_private(mut advice_cols: List[List[Fq]], row_in: Int, v_u64: UInt64) raises -> Int:
    var row = row_in
    # std.assign
    row = fill_native_assign(advice_cols, row, Fq.from_u64(v_u64))
    # assert_u64: assigned_to_le_bytes(Some(8))
    row = fill_assert_u64(advice_cols, row, v_u64)
    # assert_canonical_goldilocks: assert_lower_than_fixed(bound=p)
    var diff_u64: UInt64 = GOLDILOCKS_P_U64 - (UInt64(1) << 63)
    gl_helpers.fill_assert_lower_than_goldilocks(advice_cols, row, v_u64, diff_u64)
    row += 11
    return row


fn fill_alloc_k_private(
    mut advice_cols: List[List[Fq]],
    row_in: Int,
    c0: UInt64,
    c1: UInt64,
) raises -> Int:
    if c0 >= GOLDILOCKS_P_U64 or c1 >= GOLDILOCKS_P_U64:
        raise Error("alloc_k_private: non-canonical Goldilocks coordinate")
    var row = row_in
    row = fill_alloc_gl_private(advice_cols, row, c0)
    row = fill_alloc_gl_private(advice_cols, row, c1)
    return row


fn gl_add_mod(x: UInt64, y: UInt64) -> CarrySum:
    var p_u128 = UInt128(GOLDILOCKS_P_U64)
    var s: UInt128 = UInt128(x) + UInt128(y)
    var carry = s >= p_u128
    var out = UInt64(s - p_u128) if carry else UInt64(s)
    return CarrySum(carry, out)


fn fill_gl_add_mod_var(mut advice_cols: List[List[Fq]], row_in: Int, x: UInt64, y: UInt64) raises -> RowAndU64:
    var row = row_in
    var cs = gl_add_mod(x, y)
    var carry = cs.carry
    var sum_mod = cs.v

    var bit_out = fill_native_assign_bit(advice_cols, row, carry)
    var row_after_bit: Int = bit_out.row
    var carry_fq: Fq = bit_out.v

    # linear_combination: x + y - p*carry
    var sum_fq = Fq.from_u64(sum_mod)
    var terms = List[Fq]()
    terms.append(Fq.from_u64(x))
    terms.append(Fq.from_u64(y))
    terms.append(carry_fq)
    row = fill_native_lc(advice_cols, row_after_bit, sum_fq, terms)
    row = fill_assert_u64(advice_cols, row, sum_mod)
    var diff_u64: UInt64 = GOLDILOCKS_P_U64 - (UInt64(1) << 63)
    gl_helpers.fill_assert_lower_than_goldilocks(advice_cols, row, sum_mod, diff_u64)
    row += 11
    return RowAndU64(row, sum_mod)


fn fill_gl_sum_mod_var(mut advice_cols: List[List[Fq]], row_in: Int, terms: List[UInt64]) raises -> RowAndU64:
    var row = row_in
    if len(terms) == 0:
        raise Error("gl_sum_mod_var: empty terms")

    # Sum in outer field via native linear combinations and adds.
    var partials = List[Fq]()
    var sum_assigned: Fq

    var i = 0
    while i < len(terms):
        var chunk_len = 4
        if i + chunk_len > len(terms):
            chunk_len = len(terms) - i
        if chunk_len == 1:
            partials.append(Fq.from_u64(terms[i]))
        else:
            var chunk_terms = List[Fq]()
            var chunk_sum_fq = Fq.zero()
            for j in range(chunk_len):
                var v = Fq.from_u64(terms[i + j])
                chunk_terms.append(v)
                chunk_sum_fq = chunk_sum_fq.add(v)
            row = fill_native_lc(advice_cols, row, chunk_sum_fq, chunk_terms)
            partials.append(chunk_sum_fq)
        i += chunk_len

    sum_assigned = partials[0]
    for j in range(1, len(partials)):
        var next_sum = sum_assigned.add(partials[j])
        var add_terms = List[Fq]()
        add_terms.append(sum_assigned)
        add_terms.append(partials[j])
        row = fill_native_lc(advice_cols, row, next_sum, add_terms)
        sum_assigned = next_sum

    # Host-side quotient and remainder: sum = r + q*p, with q < terms.len().
    var sum_u128: UInt128 = 0
    for t in terms:
        sum_u128 = sum_u128 + UInt128(t)
    var p_u128 = UInt128(GOLDILOCKS_P_U64)
    var q_u64 = UInt64(sum_u128 / p_u128)
    var r_u64 = UInt64(sum_u128 % p_u128)

    # Assign q as a byte when possible (matches Rust).
    var max_q: UInt64 = UInt64(len(terms) - 1)
    if max_q > UInt64(0xFF):
        raise Error("gl_sum_mod_var: q limb too large (byte-path only implemented)")
    var q_fq = Fq.from_u64(q_u64)
    advice_cols[0][row] = q_fq
    advice_cols[1][row] = q_fq
    row += 1

    # Allocate canonical remainder.
    row = fill_native_assign(advice_cols, row, Fq.from_u64(r_u64))
    row = fill_assert_u64(advice_cols, row, r_u64)
    var diff_u64: UInt64 = GOLDILOCKS_P_U64 - (UInt64(1) << 63)
    gl_helpers.fill_assert_lower_than_goldilocks(advice_cols, row, r_u64, diff_u64)
    row += 11

    # Enforce: sum_assigned == r + p*q.
    var rhs_terms = List[Fq]()
    rhs_terms.append(Fq.from_u64(r_u64))
    rhs_terms.append(q_fq)
    row = fill_native_lc(advice_cols, row, sum_assigned, rhs_terms)
    return RowAndU64(row, r_u64)


fn fill_gl_reduce_mod_p_quotient72(
    mut advice_cols: List[List[Fq]],
    row_in: Int,
    t_fq: Fq,
    t_u192: U192,
) raises -> RowAndU64:
    var row = row_in
    var qr = reduce_u192_quotient72(t_u192)
    var q0_u64: UInt64 = UInt64(qr.q0)
    var q1_u64: UInt64 = UInt64(qr.q1)
    var q2_u64: UInt64 = UInt64(qr.q2)
    var r_u64: UInt64 = qr.r

    # Assign q0,q1,q2.
    row = fill_native_assign(advice_cols, row, Fq.from_u64(q0_u64))
    row = fill_native_assign(advice_cols, row, Fq.from_u64(q1_u64))
    row = fill_native_assign(advice_cols, row, Fq.from_u64(q2_u64))

    # Range-check quotient limbs to 24 bits each: assigned_to_le_bytes(Some(3)).
    var limb_sizes_24 = List[Int]()
    for _ in range(3):
        limb_sizes_24.append(8)
    gl_helpers.fill_decompose_core_cols_used_1(advice_cols, row, q0_u64, limb_sizes_24)
    row += 3
    gl_helpers.fill_decompose_core_cols_used_1(advice_cols, row, q1_u64, limb_sizes_24)
    row += 3
    gl_helpers.fill_decompose_core_cols_used_1(advice_cols, row, q2_u64, limb_sizes_24)
    row += 3

    # Allocate canonical remainder.
    row = fill_native_assign(advice_cols, row, Fq.from_u64(r_u64))
    row = fill_assert_u64(advice_cols, row, r_u64)
    var diff_u64: UInt64 = GOLDILOCKS_P_U64 - (UInt64(1) << 63)
    gl_helpers.fill_assert_lower_than_goldilocks(advice_cols, row, r_u64, diff_u64)
    row += 11

    # Enforce: t == r + p*q0 + p*2^24*q1 + p*2^48*q2.
    var rhs_terms = List[Fq]()
    rhs_terms.append(Fq.from_u64(r_u64))
    rhs_terms.append(Fq.from_u64(q0_u64))
    rhs_terms.append(Fq.from_u64(q1_u64))
    rhs_terms.append(Fq.from_u64(q2_u64))
    row = fill_native_lc(advice_cols, row, t_fq, rhs_terms)
    return RowAndU64(row, r_u64)


fn fill_k_mul_mod_var(
    mut advice_cols: List[List[Fq]],
    row_in: Int,
    a0: UInt64,
    a1: UInt64,
    b0: UInt64,
    b1: UInt64,
    two_pow_64: Fq,
) raises -> RowAndK:
    var row = row_in
    # a0b0, a1b1, a0b1, a1b0 in outer field (exact).
    var a0_fq = Fq.from_u64(a0)
    var a1_fq = Fq.from_u64(a1)
    var b0_fq = Fq.from_u64(b0)
    var b1_fq = Fq.from_u64(b1)

    var prod00_u128: UInt128 = UInt128(a0) * UInt128(b0)
    var prod11_u128: UInt128 = UInt128(a1) * UInt128(b1)
    var prod01_u128: UInt128 = UInt128(a0) * UInt128(b1)
    var prod10_u128: UInt128 = UInt128(a1) * UInt128(b0)

    var a0b0_fq = gl_helpers.fq_from_u128(prod00_u128, two_pow_64)
    var a1b1_fq = gl_helpers.fq_from_u128(prod11_u128, two_pow_64)
    var a0b1_fq = gl_helpers.fq_from_u128(prod01_u128, two_pow_64)
    var a1b0_fq = gl_helpers.fq_from_u128(prod10_u128, two_pow_64)

    row = fill_native_mul(advice_cols, row, a0_fq, b0_fq, a0b0_fq)
    row = fill_native_mul(advice_cols, row, a1_fq, b1_fq, a1b1_fq)
    row = fill_native_mul(advice_cols, row, a0_fq, b1_fq, a0b1_fq)
    row = fill_native_mul(advice_cols, row, a1_fq, b0_fq, a1b0_fq)

    # delta_a1b1 = delta * a1b1 (mul_by_constant).
    var delta_fq = Fq.from_u64(K_DELTA_U64)
    var delta_a1b1_fq = a1b1_fq.mul(delta_fq)
    var mul_const_terms = List[Fq]()
    mul_const_terms.append(a1b1_fq)
    row = fill_native_lc(advice_cols, row, delta_a1b1_fq, mul_const_terms)

    # t0 = a0b0 + delta_a1b1; t1 = a0b1 + a1b0 (outer field).
    var t0_fq = a0b0_fq.add(delta_a1b1_fq)
    var add_terms0 = List[Fq]()
    add_terms0.append(a0b0_fq)
    add_terms0.append(delta_a1b1_fq)
    row = fill_native_lc(advice_cols, row, t0_fq, add_terms0)
    var t1_fq = a0b1_fq.add(a1b0_fq)
    var add_terms1 = List[Fq]()
    add_terms1.append(a0b1_fq)
    add_terms1.append(a1b0_fq)
    row = fill_native_lc(advice_cols, row, t1_fq, add_terms1)

    # Host-side U192 for quotient72 reductions.
    var t0_u192 = u192_add(u192_from_u128(prod00_u128), u192_from_mul_u128_u64(prod11_u128, K_DELTA_U64))
    var t1_u192 = u192_add(u192_from_u128(prod01_u128), u192_from_u128(prod10_u128))

    var red0 = fill_gl_reduce_mod_p_quotient72(advice_cols, row, t0_fq, t0_u192)
    row = red0.row
    var out0: UInt64 = red0.v

    var red1 = fill_gl_reduce_mod_p_quotient72(advice_cols, row, t1_fq, t1_u192)
    row = red1.row
    var out1: UInt64 = red1.v
    return RowAndK(row, out0, out1)


fn prove_sumcheck_single_round_args(pkg_bytes: List[Byte], n_coeffs: Int, raw_args: List[String]) raises -> List[Byte]:
    if n_coeffs <= 0:
        raise Error("n_coeffs must be > 0")
    if len(raw_args) != 2 * n_coeffs + 6:
        raise Error("prove_sumcheck_single_round_args: wrong number of args")

    var coeffs = List[KRepr]()
    var off = 0
    for _ in range(n_coeffs):
        var c0 = gl_helpers.parse_u64_dec(raw_args[off + 0])
        var c1 = gl_helpers.parse_u64_dec(raw_args[off + 1])
        coeffs.append(KRepr(c0, c1))
        off += 2

    var challenge0 = gl_helpers.parse_u64_dec(raw_args[off + 0])
    var challenge1 = gl_helpers.parse_u64_dec(raw_args[off + 1])
    off += 2
    var claimed0 = gl_helpers.parse_u64_dec(raw_args[off + 0])
    var claimed1 = gl_helpers.parse_u64_dec(raw_args[off + 1])
    off += 2
    var next0 = gl_helpers.parse_u64_dec(raw_args[off + 0])
    var next1 = gl_helpers.parse_u64_dec(raw_args[off + 1])

    return prove_sumcheck_single_round(
        pkg_bytes,
        coeffs,
        KRepr(challenge0, challenge1),
        KRepr(claimed0, claimed1),
        KRepr(next0, next1),
    )


fn prove_sumcheck_single_round(
    pkg_bytes: List[Byte],
    coeffs: List[KRepr],
    challenge: KRepr,
    claimed_sum: KRepr,
    next_sum: KRepr,
) raises -> List[Byte]:
    if len(coeffs) == 0:
        raise Error("n_coeffs must be > 0")

    var pkg = plonk_prove_from_snapshot.read_nmbp_v3(pkg_bytes)
    var parsed = plonk_prove_from_snapshot.parse_cs(pkg.cs_bytes)
    var usable_rows = pkg.n - (parsed.cs.blinding_factors + 1)
    var use_cuda = plonk_prove_from_snapshot.cuda_available()
    var params = parse_params_kzg(pkg.params_bytes, use_cuda)

    var instance_provided_lens = List[Int]()
    instance_provided_lens.append(0)
    instance_provided_lens.append(0)

    var instance_cols = List[List[Fq]]()
    for _ in range(2):
        var col = List[Fq]()
        for _ in range(pkg.n):
            col.append(Fq.zero())
        instance_cols.append(col^)

    var advice_cols = List[List[Fq]]()
    for _ in range(parsed.cs.num_advice):
        var col = List[Fq]()
        for _ in range(pkg.n):
            col.append(Fq.zero())
        advice_cols.append(col^)

    var row: Int = 0

    # Allocate coefficients + round values as private witnesses.
    for c in coeffs:
        row = fill_alloc_k_private(advice_cols, row, c.c0, c.c1)
    row = fill_alloc_k_private(advice_cols, row, challenge.c0, challenge.c1)
    row = fill_alloc_k_private(advice_cols, row, claimed_sum.c0, claimed_sum.c1)
    row = fill_alloc_k_private(advice_cols, row, next_sum.c0, next_sum.c1)

    # sumcheck_round_check: sum(coeffs) + coeff0 == claimed_sum.
    var terms0 = List[UInt64]()
    var terms1 = List[UInt64]()
    for c in coeffs:
        terms0.append(c.c0)
        terms1.append(c.c1)
    terms0.append(coeffs[0].c0)
    terms1.append(coeffs[0].c1)

    var sum0_out = fill_gl_sum_mod_var(advice_cols, row, terms0)
    row = sum0_out.row
    var sum0: UInt64 = sum0_out.v

    var sum1_out = fill_gl_sum_mod_var(advice_cols, row, terms1)
    row = sum1_out.row
    var sum1: UInt64 = sum1_out.v
    if sum0 != claimed_sum.c0 or sum1 != claimed_sum.c1:
        raise Error("claimed_sum mismatch for provided coeffs")

    # sumcheck_eval_horner: evaluate polynomial at challenge.
    var two_pow_64 = gl_helpers.fq_two_pow_64()
    var acc0 = coeffs[len(coeffs) - 1].c0
    var acc1 = coeffs[len(coeffs) - 1].c1

    for i in range(len(coeffs) - 1):
        var idx = len(coeffs) - 2 - i
        var c0 = coeffs[idx].c0
        var c1 = coeffs[idx].c1

        var tmp_out = fill_k_mul_mod_var(
            advice_cols,
            row,
            acc0,
            acc1,
            challenge.c0,
            challenge.c1,
            two_pow_64,
        )
        row = tmp_out.row
        var tmp0: UInt64 = tmp_out.c0
        var tmp1: UInt64 = tmp_out.c1

        var add0_out = fill_gl_add_mod_var(advice_cols, row, tmp0, c0)
        row = add0_out.row
        acc0 = add0_out.v

        var add1_out = fill_gl_add_mod_var(advice_cols, row, tmp1, c1)
        row = add1_out.row
        acc1 = add1_out.v

    if acc0 != next_sum.c0 or acc1 != next_sum.c1:
        raise Error("next_sum mismatch for provided coeffs/challenge")

    if row > usable_rows:
        raise Error("witness generation exceeded usable_rows")

    var ws = plonk_prove_from_snapshot.NmbwsV2(
        pkg.k,
        pkg.n,
        usable_rows,
        instance_provided_lens^,
        instance_cols^,
        advice_cols^,
    )

    return plonk_prove_from_snapshot.prove_from_snapshot_parsed(
        pkg, ws, params, use_cuda
    )


fn main() raises:
    var args = argv()
    if len(args) < 5:
        print(
            "Usage: mojo plonk_prove_sumcheck_single_round.mojo <pkg.nmbp> <n_coeffs>",
            " <c0_0> <c0_1> ... <c{n-1}_0> <c{n-1}_1>",
            " <challenge_0> <challenge_1>",
            " <claimed_sum_0> <claimed_sum_1>",
            " <next_sum_0> <next_sum_1>",
            " <out_proof.bin>",
        )
        return

    var pkg_path = args[1]
    var n_coeffs = Int(gl_helpers.parse_u64_dec(args[2]))
    if n_coeffs <= 0:
        raise Error("n_coeffs must be > 0")

    var expected = 2 * n_coeffs + 10
    if len(args) != expected:
        raise Error("wrong number of args for n_coeffs")

    var coeffs = List[KRepr]()
    var off = 3
    for _ in range(n_coeffs):
        var c0 = gl_helpers.parse_u64_dec(args[off + 0])
        var c1 = gl_helpers.parse_u64_dec(args[off + 1])
        coeffs.append(KRepr(c0, c1))
        off += 2

    var challenge0 = gl_helpers.parse_u64_dec(args[off + 0])
    var challenge1 = gl_helpers.parse_u64_dec(args[off + 1])
    off += 2
    var claimed0 = gl_helpers.parse_u64_dec(args[off + 0])
    var claimed1 = gl_helpers.parse_u64_dec(args[off + 1])
    off += 2
    var next0 = gl_helpers.parse_u64_dec(args[off + 0])
    var next1 = gl_helpers.parse_u64_dec(args[off + 1])
    off += 2
    var out_path = args[off]

    var proof = prove_sumcheck_single_round(
        Path(pkg_path).read_bytes(),
        coeffs,
        KRepr(challenge0, challenge1),
        KRepr(claimed0, claimed1),
        KRepr(next0, next1),
    )
    Path(out_path).write_bytes(proof)
