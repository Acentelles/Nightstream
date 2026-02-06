from collections import List
from pathlib import Path
from sys import argv

import plonk_prove_from_snapshot
from nmb.fq import Fq
from nmb.params_kzg import parse_params_kzg


comptime GOLDILOCKS_P_U64: UInt64 = UInt64(0xFFFF_FFFF_0000_0001)


fn parse_u64_dec(s: String) raises -> UInt64:
    if len(s) == 0:
        raise Error("parse_u64_dec: empty")
    var acc: UInt128 = 0
    for i in range(len(s)):
        var ch = s[i]
        if ch == "_":
            continue
        var d = Int(ch)
        if d < 0 or d > 9:
            raise Error("parse_u64_dec: invalid digit")
        acc = (acc * 10) + UInt128(d)
        if acc > UInt128(0xFFFF_FFFF_FFFF_FFFF):
            raise Error("parse_u64_dec: overflow")
    return UInt64(acc)


fn fq_two_pow_64() -> Fq:
    var x = Fq.one()
    for _ in range(64):
        x = x.add(x)
    return x


fn fq_from_u128(x: UInt128, two_pow_64: Fq) -> Fq:
    var lo = UInt64(x & UInt128(0xFFFF_FFFF_FFFF_FFFF))
    var hi = UInt64(x >> 64)
    return Fq.from_u64(lo).add(Fq.from_u64(hi).mul(two_pow_64))


fn fill_decompose_core_cols_used_1(
    mut advice_cols: List[List[Fq]],
    base_row: Int,
    value_u64: UInt64,
    limb_sizes: List[Int],
) raises:
    var acc: UInt128 = UInt128(value_u64)
    var shift: Int = 0
    var coeff: UInt128 = 1
    for i in range(len(limb_sizes)):
        var limb_bits = limb_sizes[i]
        if limb_bits <= 0 or limb_bits > 64:
            raise Error("fill_decompose_core_cols_used_1: invalid limb_bits")
        var mask: UInt64 = UInt64(0xFFFF_FFFF_FFFF_FFFF) if limb_bits == 64 else (UInt64(1) << limb_bits) - 1
        var limb = (value_u64 >> shift) & mask

        advice_cols[0][base_row + i] = Fq.from_u64(UInt64(acc))
        advice_cols[1][base_row + i] = Fq.from_u64(limb)

        acc = acc - (coeff * UInt128(limb))
        shift += limb_bits
        coeff = coeff << limb_bits


fn fill_assert_lower_than_goldilocks(
    mut advice_cols: List[List[Fq]],
    base_row: Int,
    v_u64: UInt64,
    diff_u64: UInt64,
) raises:
    # Matches midnight-circuits:
    # NativeGadget::assert_lower_than_fixed with bound=Goldilocks p.
    # - b := (v < 2^63)
    # - shifted = v - (p - 2^63)  (field subtraction)
    # - y = select(b, v, shifted)
    # - assert y < 2^63 via assign_less_than_pow2 (decompose_core)
    var two_pow_63: UInt64 = UInt64(1) << 63
    var b = v_u64 < two_pow_63

    var b_fq = Fq.one() if b else Fq.zero()
    var v_fq = Fq.from_u64(v_u64)
    var diff_fq = Fq.from_u64(diff_u64)
    var shifted_fq = v_fq.sub(diff_fq)
    var y_u64 = v_u64 if b else (v_u64 - diff_u64)
    var y_fq = Fq.from_u64(y_u64)

    # Row 0: assign b bit (col0, col1).
    advice_cols[0][base_row + 0] = b_fq
    advice_cols[1][base_row + 0] = b_fq

    # Row 1: shifted = v + (-diff) (linear_combination).
    advice_cols[0][base_row + 1] = shifted_fq
    advice_cols[1][base_row + 1] = v_fq

    # Row 2: y = b*v + (1-b)*shifted (select).
    advice_cols[0][base_row + 2] = b_fq
    advice_cols[1][base_row + 2] = v_fq
    advice_cols[2][base_row + 2] = shifted_fq
    advice_cols[4][base_row + 2] = y_fq

    # Rows 3..10: decompose_core for y < 2^63.
    #
    # With a single pow2range advice column, midnight-circuits uses
    # limb_sizes = [7, 8, 8, 8, 8, 8, 8, 8] for bit_length=63.
    var limb_sizes = List[Int]()
    limb_sizes.append(7)
    for _ in range(7):
        limb_sizes.append(8)
    fill_decompose_core_cols_used_1(advice_cols, base_row + 3, y_u64, limb_sizes)


fn prove_goldilocks_mul(pkg_bytes: List[Byte], x_u64: UInt64, y_u64: UInt64, z_u64: UInt64) raises -> List[Byte]:
    # Compute quotient witness k and check z if provided.
    var p_u128 = UInt128(GOLDILOCKS_P_U64)
    var prod_u128 = UInt128(x_u64) * UInt128(y_u64)
    var k_u64 = UInt64(prod_u128 / p_u128)
    var r_u64 = UInt64(prod_u128 % p_u128)
    if z_u64 != r_u64:
        raise Error("invalid instance: z != x*y mod p")

    var pkg = plonk_prove_from_snapshot.read_nmbp_v3(pkg_bytes)
    var parsed = plonk_prove_from_snapshot.parse_cs(pkg.cs_bytes)
    var usable_rows = pkg.n - (parsed.cs.blinding_factors + 1)

    var use_cuda = plonk_prove_from_snapshot.cuda_available()
    var params = parse_params_kzg(pkg.params_bytes, use_cuda)

    # Build instance columns (committed instances empty + public instance).
    var instance_provided_lens = List[Int]()
    instance_provided_lens.append(0)
    instance_provided_lens.append(3)

    var instance_cols = List[List[Fq]]()
    var inst0 = List[Fq]()
    var inst1 = List[Fq]()
    for i in range(pkg.n):
        inst0.append(Fq.zero())
        if i == 0:
            inst1.append(Fq.from_u64(x_u64))
        elif i == 1:
            inst1.append(Fq.from_u64(y_u64))
        elif i == 2:
            inst1.append(Fq.from_u64(z_u64))
        else:
            inst1.append(Fq.zero())
    instance_cols.append(inst0^)
    instance_cols.append(inst1^)

    # Build advice columns (native chip uses 5 advice columns).
    var advice_cols = List[List[Fq]]()
    for _ in range(parsed.cs.num_advice):
        var col = List[Fq]()
        for _ in range(pkg.n):
            col.append(Fq.zero())
        advice_cols.append(col^)

    # Assign public inputs (native assign uses advice col 0).
    advice_cols[0][0] = Fq.from_u64(x_u64)
    advice_cols[0][1] = Fq.from_u64(y_u64)
    advice_cols[0][2] = Fq.from_u64(z_u64)

    # Canonicality checks: assert_lower_than_fixed(v, p).
    var diff_u64: UInt64 = GOLDILOCKS_P_U64 - (UInt64(1) << 63)
    var row = 3
    fill_assert_lower_than_goldilocks(advice_cols, row, x_u64, diff_u64)
    row += 11
    fill_assert_lower_than_goldilocks(advice_cols, row, y_u64, diff_u64)
    row += 11
    fill_assert_lower_than_goldilocks(advice_cols, row, z_u64, diff_u64)
    row += 11

    # Assign quotient k (native assign).
    advice_cols[0][row] = Fq.from_u64(k_u64)
    row += 1

    # assert_u64(k): decompose_fixed_limb_size(bit_length=64, limb_size=8).
    var limb_sizes_k = List[Int]()
    for _ in range(8):
        limb_sizes_k.append(8)
    fill_decompose_core_cols_used_1(advice_cols, row, k_u64, limb_sizes_k)
    row += 8

    # lhs = x * y (native mul -> add_and_double_mul).
    var two_pow_64 = fq_two_pow_64()
    var prod_fq = fq_from_u128(prod_u128, two_pow_64)
    advice_cols[0][row] = Fq.from_u64(x_u64)
    advice_cols[1][row] = Fq.from_u64(y_u64)
    advice_cols[2][row] = Fq.from_u64(x_u64)
    advice_cols[4][row] = prod_fq
    row += 1

    # rhs = z + p*k (native linear_combination).
    advice_cols[0][row] = prod_fq
    advice_cols[1][row] = Fq.from_u64(z_u64)
    advice_cols[2][row] = Fq.from_u64(k_u64)

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
    if len(args) != 6:
        print(
            "Usage: mojo plonk_prove_goldilocks_mul.mojo",
            " <pkg.nmbp> <x_u64_dec> <y_u64_dec> <z_u64_dec> <out_proof.bin>",
        )
        return

    var pkg_path = args[1]
    var x_u64 = parse_u64_dec(args[2])
    var y_u64 = parse_u64_dec(args[3])
    var z_u64 = parse_u64_dec(args[4])
    var out_path = args[5]

    var proof = prove_goldilocks_mul(Path(pkg_path).read_bytes(), x_u64, y_u64, z_u64)
    Path(out_path).write_bytes(proof)
