from collections import List
from pathlib import Path
from sys import argv

import plonk_prove_from_snapshot
from nmb.fq import Fq
from nmb.g1 import G1Affine, g1_compress
from nmb.gpu.dispatch import cuda_available
from nmb.gpu.msm_cuda import CUDA_MSM_IMPLEMENTED, msm_pippenger_cuda
from nmb.msm import msm_pippenger_prefix
from nmb.params_kzg import parse_params_kzg


fn main() raises:
    if not CUDA_MSM_IMPLEMENTED:
        print("skip: gpu msm not enabled")
        return
    if not cuda_available():
        print("skip: gpu not available")
        return

    var args = argv()
    if len(args) != 2:
        print("Usage: mojo msm_cuda_compare.mojo <pkg.nmbp>")
        return

    var pkg_bytes = Path(args[1]).read_bytes()
    var pkg = plonk_prove_from_snapshot.read_nmbp_v3(pkg_bytes)
    var params = parse_params_kzg(pkg.params_bytes)

    # Keep this small; it is a correctness scaffold, not a benchmark.
    var n_test = 256
    if n_test > params.n:
        n_test = params.n

    var bases = List[G1Affine]()
    var scalars = List[Fq]()
    for i in range(n_test):
        bases.append(params.g_lagrange[i])
        scalars.append(Fq.from_u64(UInt64(i + 1)))

    var cpu = g1_compress(msm_pippenger_prefix(bases, scalars).to_affine())
    var gpu = g1_compress(msm_pippenger_cuda(bases, scalars).to_affine())

    if len(cpu) != len(gpu):
        raise Error("msm_cuda_compare: compressed length mismatch")
    for i in range(len(cpu)):
        if cpu[i] != gpu[i]:
            raise Error("msm_cuda_compare: mismatch")

    print("ok: msm cuda matches cpu for n=", n_test)
