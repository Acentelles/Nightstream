from collections import List
from pathlib import Path
from sys import argv

import plonk_prove_from_snapshot
from nmb.g1 import G1Affine
from nmb.params_kzg import ParamsKZGParsed, parse_params_kzg


fn main() raises:
    var args = argv()
    if len(args) < 4 or (len(args) - 1) % 3 != 0:
        print(
            "Usage: mojo plonk_prove_many_from_snapshot.mojo",
            " <pkg1.nmbp> <snapshot1.nmbws> <out1.bin>",
            " [<pkg2.nmbp> <snapshot2.nmbws> <out2.bin> ...]",
        )
        return

    # Single-entry cache (good enough if callers group jobs by `k`).
    var cached_k: Int = -1
    var cached_params = ParamsKZGParsed(0, 0, List[G1Affine](), List[G1Affine]())

    var use_cuda = plonk_prove_from_snapshot.cuda_available()

    var job_count = (len(args) - 1) // 3
    for job_idx in range(job_count):
        var base = 1 + (job_idx * 3)
        var pkg_path = args[base + 0]
        var ws_path = args[base + 1]
        var out_path = args[base + 2]

        var pkg_bytes = Path(pkg_path).read_bytes()
        var ws_bytes = Path(ws_path).read_bytes()

        var pkg = plonk_prove_from_snapshot.read_nmbp_v3(pkg_bytes)
        var ws = plonk_prove_from_snapshot.read_nmbws_v2(ws_bytes)

        if cached_k != pkg.k:
            cached_params = parse_params_kzg(pkg.params_bytes, use_cuda)
            cached_k = pkg.k

        var proof = plonk_prove_from_snapshot.prove_from_snapshot_parsed(pkg, ws, cached_params, use_cuda)
        Path(out_path).write_bytes(proof)
