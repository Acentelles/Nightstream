from pathlib import Path
from sys import argv
from collections import List

from nmb.reader import Reader
from nmb.fq import Fq
from nmb.params_kzg import commit_coeff, parse_params_kzg
from nmb.transcript import CircuitTranscript


comptime _POLY_SIZE: Int = 16


fn read_nmbp_params_bytes(pkg_bytes: List[Byte]) raises -> List[Byte]:
    var r = Reader(pkg_bytes)
    r.expect_magic(78, 77, 66, 80)  # NMBP
    _ = r.read_u32_le()  # version
    _ = r.read_u32_le()  # relation_kind
    var params_json_len = r.read_u32_le()
    r.skip(Int(params_json_len))
    _ = r.read_u32_le()  # k
    _ = r.read_u32_le()  # n

    var params_len = r.read_u32_le()
    return r.read_bytes(Int(params_len))


fn eval_polynomial(poly: List[Fq], point: Fq) -> Fq:
    var acc = Fq.zero()
    for i in range(len(poly)):
        var j = (len(poly) - 1) - i
        acc = acc.mul(point).add(poly[j])
    return acc


fn kate_division(poly: List[Fq], point: Fq) -> List[Fq]:
    # Returns quotient of poly / (X - point), discarding remainder.
    var b = point.neg()
    if len(poly) < 2:
        return List[Fq]()

    var q = List[Fq]()
    for _ in range(len(poly) - 1):
        q.append(Fq.zero())

    var tmp = Fq.zero()
    for i in range(len(q)):
        var qi = (len(q) - 1) - i
        var ri = (len(poly) - 1) - i
        var lead = poly[ri].sub(tmp)
        q[qi] = lead
        tmp = lead.mul(b)
    return q^


fn poly_add(a: List[Fq], b: List[Fq]) -> List[Fq]:
    var out = List[Fq]()
    var n = len(a)
    for i in range(n):
        out.append(a[i].add(b[i]))
    return out^


fn poly_scale(poly: List[Fq], s: Fq) -> List[Fq]:
    var out = List[Fq]()
    for v in poly:
        out.append(v.mul(s))
    return out^


fn main() raises:
    var args = argv()
    if len(args) != 3:
        print("Usage: mojo kzg_gwc_roundtrip.mojo <pkg.nmbp> <out_proof.bin>")
        return

    var pkg_path = args[1]
    var out_path = args[2]

    var pkg_bytes = Path(pkg_path).read_bytes()
    var params_bytes = read_nmbp_params_bytes(pkg_bytes)
    var params = parse_params_kzg(params_bytes)

    # Three low-degree polynomials (degree < 16) to keep the reference MSM cheap.
    var ax = List[Fq]()
    var bx = List[Fq]()
    var cx = List[Fq]()
    for _ in range(_POLY_SIZE):
        ax.append(Fq.zero())
        bx.append(Fq.zero())
        cx.append(Fq.zero())

    ax[0] = Fq.from_u64(10)
    ax[1] = Fq.from_u64(11)
    bx[0] = Fq.from_u64(100)
    bx[1] = Fq.from_u64(101)
    cx[0] = Fq.from_u64(200)
    cx[1] = Fq.from_u64(201)

    var transcript = CircuitTranscript.init()

    var a = commit_coeff(params, ax)
    var b = commit_coeff(params, bx)
    var c = commit_coeff(params, cx)

    transcript.write_g1_bytes(a)
    transcript.write_g1_bytes(b)
    transcript.write_g1_bytes(c)

    var x = transcript.squeeze_challenge_fq()
    var y = transcript.squeeze_challenge_fq()

    transcript.write_fq(eval_polynomial(ax, x))
    transcript.write_fq(eval_polynomial(bx, x))
    transcript.write_fq(eval_polynomial(cx, y))

    # GWC multi-open (as in midnight-proofs KZG multi_open).
    var x1 = transcript.squeeze_challenge_fq()
    var x2 = transcript.squeeze_challenge_fq()

    var q0 = poly_add(ax, poly_scale(bx, x1))
    var q1 = cx.copy()

    var f0 = kate_division(q0, x)
    var f1 = kate_division(q1, y)

    # f = f0 + x2*f1
    var f = poly_add(f0, poly_scale(f1, x2))
    # Pad to match the coefficient vector size used by q0/q1.
    f.append(Fq.zero())
    var f_com = commit_coeff(params, f)
    transcript.write_g1_bytes(f_com)

    var x3 = transcript.squeeze_challenge_fq()
    transcript.write_fq(eval_polynomial(q0, x3))
    transcript.write_fq(eval_polynomial(q1, x3))

    var x4 = transcript.squeeze_challenge_fq()
    var x4_2 = x4.square()

    var final_poly = poly_add(poly_add(q0, poly_scale(q1, x4)), poly_scale(f, x4_2))
    var v = eval_polynomial(final_poly, x3)

    # pi = commit( (final_poly - v) / (X - x3) )
    var final_minus_v = final_poly.copy()
    final_minus_v[0] = final_minus_v[0].sub(v)
    var pi_poly = kate_division(final_minus_v, x3)
    var pi = commit_coeff(params, pi_poly)
    transcript.write_g1_bytes(pi)

    Path(out_path).write_bytes(transcript^.finalize())
