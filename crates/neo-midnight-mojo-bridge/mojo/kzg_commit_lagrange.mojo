from pathlib import Path
from sys import argv
from collections import List

from nmb.reader import Reader
from nmb.fq import Fq
from nmb.gpu.dispatch import cuda_available
from nmb.params_kzg import commit_lagrange, parse_params_kzg


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


fn main() raises:
    var args = argv()
    if len(args) != 4:
        print("Usage: mojo kzg_commit_lagrange.mojo <pkg.nmbp> <scalars.bin> <out_commitment.bin>")
        return

    var pkg_path = args[1]
    var scalars_path = args[2]
    var out_path = args[3]

    var pkg_bytes = Path(pkg_path).read_bytes()
    var params_bytes = read_nmbp_params_bytes(pkg_bytes)

    var use_cuda = cuda_available()
    var params = parse_params_kzg(params_bytes, use_cuda)
    var n: Int = params.n

    # Read scalars file: u32 count + count*32 bytes.
    var sb = Path(scalars_path).read_bytes()
    var sr = Reader(sb)
    var count = Int(sr.read_u32_le())
    if count != n:
        raise Error("unexpected scalar count")

    var evals = List[Fq]()
    for _ in range(n):
        evals.append(Fq.from_repr_le(sr.read_bytes(32)))

    if sr.remaining() != 0:
        raise Error("trailing bytes in scalars file")

    Path(out_path).write_bytes(commit_lagrange(params, evals, use_cuda))
