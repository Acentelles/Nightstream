from collections import List
from pathlib import Path
from sys import argv

from nmb.reader import Reader


fn u32_le_bytes(v: UInt32) -> List[Byte]:
    var out = List[Byte]()
    var mask: UInt32 = UInt32(0xFF)
    out.append(Byte(UInt8(v & mask)))
    out.append(Byte(UInt8((v >> 8) & mask)))
    out.append(Byte(UInt8((v >> 16) & mask)))
    out.append(Byte(UInt8((v >> 24) & mask)))
    return out^


fn skip_string(mut r: Reader) raises:
    var n = Int(r.read_u32_le())
    r.skip(n)


fn skip_expr(mut r: Reader) raises:
    var tag = r.read_u8()

    # Encoding matches `neo-midnight-bridge-artifacts/src/nmbp.rs::write_expr`.
    if tag == 0:  # Constant
        r.skip(32)
    elif tag == 1:  # Selector
        r.skip(4)  # index
        r.skip(1)  # is_simple
    elif tag == 2:  # Fixed
        r.skip(4)  # col
        r.skip(4)  # rot i32
    elif tag == 3:  # Advice
        r.skip(4)  # col
        r.skip(4)  # rot i32
        r.skip(1)  # phase
    elif tag == 4:  # Instance
        r.skip(4)  # col
        r.skip(4)  # rot i32
    elif tag == 5:  # Challenge
        r.skip(4)  # index
        r.skip(1)  # phase
    elif tag == 6:  # Negated
        skip_expr(r)
    elif tag == 7:  # Sum
        skip_expr(r)
        skip_expr(r)
    elif tag == 8:  # Product
        skip_expr(r)
        skip_expr(r)
    elif tag == 9:  # Scaled
        skip_expr(r)
        r.skip(32)  # scalar
    else:
        raise Error("skip_expr: invalid tag")


fn main() raises:
    var args = argv()
    if len(args) != 3:
        print("Usage: mojo keyinfo.mojo <pkg.nmbp> <out_keyinfo.bin>")
        return

    var pkg_path = args[1]
    var out_path = args[2]

    var pkg_bytes = Path(pkg_path).read_bytes()
    var r = Reader(pkg_bytes)
    r.expect_magic(78, 77, 66, 80)  # NMBP

    var pkg_ver = r.read_u32_le()
    _ = r.read_u32_le()  # relation_kind
    var params_json_len = r.read_u32_le()
    r.skip(Int(params_json_len))
    var pkg_k = r.read_u32_le()
    var pkg_n = r.read_u32_le()

    var params_len = r.read_u32_le()
    r.skip(Int(params_len))

    var vk_len = r.read_u32_le()
    var vk_bytes = r.read_bytes(Int(vk_len))

    r.skip(32)  # vk_transcript_repr

    var pk_len = r.read_u32_le()
    var pk_bytes = r.read_bytes(Int(pk_len))

    var cs_len = r.read_u32_le()
    var cs_bytes = r.read_bytes(Int(cs_len))

    if r.remaining() != 0:
        raise Error("trailing bytes in NMBP")

    # Parse constraint system header + permutation columns count.
    var cs = Reader(cs_bytes)
    var cs_fixed = cs.read_u32_le()
    var cs_advice = cs.read_u32_le()
    var cs_instance = cs.read_u32_le()
    _ = cs.read_u32_le()  # selectors
    _ = cs.read_u32_le()  # challenges

    var cs_blinding = cs.read_u32_le()
    var cs_degree = cs.read_u32_le()

    var advice_phases_len = cs.read_u32_le()
    cs.skip(Int(advice_phases_len))
    var challenge_phases_len = cs.read_u32_le()
    cs.skip(Int(challenge_phases_len))

    _ = cs.read_u32_le()  # unblinded advice columns (count), currently 0

    var gates_len = Int(cs.read_u32_le())
    for _ in range(gates_len):
        skip_string(cs)  # gate name
        var polys_len = Int(cs.read_u32_le())
        for _ in range(polys_len):
            skip_string(cs)  # constraint name
            skip_expr(cs)

    var fixed_q_len = Int(cs.read_u32_le())
    for _ in range(fixed_q_len):
        _ = cs.read_u32_le()  # col
        _ = cs.read_u32_le()  # rot (i32)

    var advice_q_len = Int(cs.read_u32_le())
    for _ in range(advice_q_len):
        _ = cs.read_u32_le()  # col
        _ = cs.read_u8()  # phase
        _ = cs.read_u32_le()  # rot (i32)

    var inst_q_len = Int(cs.read_u32_le())
    for _ in range(inst_q_len):
        _ = cs.read_u32_le()  # col
        _ = cs.read_u32_le()  # rot (i32)

    var perm_cols = Int(cs.read_u32_le())
    for _ in range(perm_cols):
        var col_ty = cs.read_u8()
        _ = cs.read_u32_le()  # index
        if col_ty == 1:
            _ = cs.read_u8()  # phase

    # Parse vk bytes in raw/uncompressed format.
    var vk = Reader(vk_bytes)
    _ = vk.read_u8()  # version byte
    var vk_k = vk.read_u8()
    var vk_fixed_count = Int(vk.read_u32_le())
    vk.skip(vk_fixed_count * 96)
    vk.skip(perm_cols * 96)
    if vk.remaining() != 0:
        raise Error("trailing bytes in vk_bytes")

    # Parse pk bytes in raw/uncompressed format.
    var pk = Reader(pk_bytes)
    _ = pk.read_u8()  # version byte
    var pk_k = pk.read_u8()
    var pk_fixed_count = Int(pk.read_u32_le())
    pk.skip(pk_fixed_count * 96)
    pk.skip(perm_cols * 96)

    # fixed_values: polynomial slice, big-endian u32 lengths.
    var fixed_values_polys = pk.read_u32_be()
    var fixed_values_poly_len: UInt32 = 0
    for i in range(Int(fixed_values_polys)):
        var poly_len = pk.read_u32_be()
        if i == 0:
            fixed_values_poly_len = poly_len
        pk.skip(Int(poly_len) * 32)

    # permutation proving key: polynomial slice.
    var perm_polys = pk.read_u32_be()
    var perm_poly_len: UInt32 = 0
    for i in range(Int(perm_polys)):
        var poly_len = pk.read_u32_be()
        if i == 0:
            perm_poly_len = poly_len
        pk.skip(Int(poly_len) * 32)

    if pk.remaining() != 0:
        raise Error("trailing bytes in pk_bytes")

    # Emit a compact binary output for Rust tests.
    var out = List[Byte]()
    out.append(Byte(78))  # N
    out.append(Byte(77))  # M
    out.append(Byte(66))  # B
    out.append(Byte(73))  # I

    for b in u32_le_bytes(UInt32(1)):  # version
        out.append(b)

    for b in u32_le_bytes(pkg_ver):
        out.append(b)
    for b in u32_le_bytes(pkg_k):
        out.append(b)
    for b in u32_le_bytes(pkg_n):
        out.append(b)

    for b in u32_le_bytes(cs_fixed):
        out.append(b)
    for b in u32_le_bytes(cs_advice):
        out.append(b)
    for b in u32_le_bytes(cs_instance):
        out.append(b)
    for b in u32_le_bytes(cs_blinding):
        out.append(b)
    for b in u32_le_bytes(cs_degree):
        out.append(b)
    for b in u32_le_bytes(UInt32(perm_cols)):
        out.append(b)

    for b in u32_le_bytes(UInt32(vk_k)):
        out.append(b)
    for b in u32_le_bytes(UInt32(pk_k)):
        out.append(b)
    for b in u32_le_bytes(UInt32(vk_fixed_count)):
        out.append(b)
    for b in u32_le_bytes(UInt32(pk_fixed_count)):
        out.append(b)

    for b in u32_le_bytes(fixed_values_polys):
        out.append(b)
    for b in u32_le_bytes(fixed_values_poly_len):
        out.append(b)
    for b in u32_le_bytes(perm_polys):
        out.append(b)
    for b in u32_le_bytes(perm_poly_len):
        out.append(b)

    Path(out_path).write_bytes(out)

