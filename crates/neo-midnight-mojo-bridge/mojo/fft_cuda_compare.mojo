from collections import List
from sys import CompilationTarget

from nmb.domain import _best_fft_cpu
from nmb.fq import Fq
from nmb.gpu.dispatch import cuda_available
from nmb.gpu.fft_cuda import CUDA_FFT_IMPLEMENTED, best_fft_cuda


fn fq_eq(a: Fq, b: Fq) -> Bool:
    return a.l0 == b.l0 and a.l1 == b.l1 and a.l2 == b.l2 and a.l3 == b.l3


fn main() raises:
    if not CUDA_FFT_IMPLEMENTED:
        print("skip: gpu fft not enabled")
        return
    if not cuda_available():
        print("skip: gpu not available")
        return

    var k = 16
    var n = 1 << k

    var omega = Fq.root_of_unity()
    for _ in range(k, Fq.s()):
        omega = omega.square()

    var a = List[Fq]()
    for i in range(n):
        a.append(Fq.from_u64(UInt64(i)))

    var cpu = _best_fft_cpu(a, omega, k)
    var gpu = best_fft_cuda(a, omega, k)
    if len(cpu) != len(gpu):
        raise Error("length mismatch")

    for i in range(n):
        if not fq_eq(cpu[i], gpu[i]):
            raise Error("mismatch")

    print("ok")
