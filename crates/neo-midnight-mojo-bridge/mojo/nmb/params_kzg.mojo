from collections import List
from collections.optional import Optional
from sys import CompilationTarget

from gpu.host import DeviceBuffer, DeviceContext

from nmb.fq import Fq
from nmb.g1 import G1Affine, g1_compress
from nmb.g1_serde import read_g1_uncompressed
from nmb.gpu.msm_cuda import CUDA_MSM_IMPLEMENTED, msm_pippenger_cuda, msm_pippenger_cuda_bases_dev
from nmb.msm import msm_pippenger_prefix
from nmb.reader import Reader


struct ParamsKZGParsed(Movable):
    var k: Int
    var n: Int
    var g: List[G1Affine]
    var g_lagrange: List[G1Affine]
    var gpu_ctx: Optional[DeviceContext]
    var g_dev_xy: Optional[DeviceBuffer[DType.uint64]]
    var g_lagrange_dev_xy: Optional[DeviceBuffer[DType.uint64]]

    fn __init__(out self, k: Int, n: Int, var g: List[G1Affine], var g_lagrange: List[G1Affine]):
        self.k = k
        self.n = n
        self.g = g^
        self.g_lagrange = g_lagrange^
        self.gpu_ctx = Optional[DeviceContext]()
        self.g_dev_xy = Optional[DeviceBuffer[DType.uint64]]()
        self.g_lagrange_dev_xy = Optional[DeviceBuffer[DType.uint64]]()


fn _upload_g1_affine_xy(ctx: DeviceContext, bases: List[G1Affine]) raises -> DeviceBuffer[DType.uint64]:
    var n = len(bases)
    var host = ctx.enqueue_create_host_buffer[DType.uint64](n * 12)
    ctx.synchronize()

    for i in range(n):
        var b = bases[i]
        var bo = i * 12
        host[bo + 0] = b.x.l0
        host[bo + 1] = b.x.l1
        host[bo + 2] = b.x.l2
        host[bo + 3] = b.x.l3
        host[bo + 4] = b.x.l4
        host[bo + 5] = b.x.l5
        host[bo + 6] = b.y.l0
        host[bo + 7] = b.y.l1
        host[bo + 8] = b.y.l2
        host[bo + 9] = b.y.l3
        host[bo + 10] = b.y.l4
        host[bo + 11] = b.y.l5

    var dev = ctx.enqueue_create_buffer[DType.uint64](n * 12)
    dev.enqueue_copy_from(host.unsafe_ptr())
    ctx.synchronize()  # Ensure host buffer stays valid for the async copy.
    return dev


fn parse_params_kzg(params_bytes: List[Byte], use_cuda: Bool = False) raises -> ParamsKZGParsed:
    var r = Reader(params_bytes)
    var k = Int(r.read_u32_le())
    var n = 1 << k

    var g = List[G1Affine]()
    for _ in range(n):
        g.append(read_g1_uncompressed(r))

    var g_lagrange = List[G1Affine]()
    for _ in range(n):
        g_lagrange.append(read_g1_uncompressed(r))

    var out = ParamsKZGParsed(k, n, g^, g_lagrange^)

    if use_cuda and CUDA_MSM_IMPLEMENTED:
        try:
            var api = "cuda"
            @parameter
            if CompilationTarget.is_macos():
                api = "metal"
            var ctx = DeviceContext(api=api)

            out.g_dev_xy = Optional[DeviceBuffer[DType.uint64]](_upload_g1_affine_xy(ctx, out.g))
            out.g_lagrange_dev_xy = Optional[DeviceBuffer[DType.uint64]](_upload_g1_affine_xy(ctx, out.g_lagrange))
            out.gpu_ctx = Optional[DeviceContext](ctx)
        except _:
            out.gpu_ctx = Optional[DeviceContext]()
            out.g_dev_xy = Optional[DeviceBuffer[DType.uint64]]()
            out.g_lagrange_dev_xy = Optional[DeviceBuffer[DType.uint64]]()

    return out^


fn _msm_maybe_cuda(
    bases: List[G1Affine],
    bases_dev_xy: Optional[DeviceBuffer[DType.uint64]],
    gpu_ctx: Optional[DeviceContext],
    scalars: List[Fq],
    use_cuda: Bool,
) raises -> List[Byte]:
    if use_cuda and CUDA_MSM_IMPLEMENTED and len(scalars) >= 1024:
        try:
            if gpu_ctx and bases_dev_xy:
                return g1_compress(
                    msm_pippenger_cuda_bases_dev(gpu_ctx.value(), bases_dev_xy.value(), scalars).to_affine()
                )
            return g1_compress(msm_pippenger_cuda(bases, scalars).to_affine())
        except _:
            pass
    return g1_compress(msm_pippenger_prefix(bases, scalars).to_affine())


fn commit_coeff(params: ParamsKZGParsed, scalars: List[Fq], use_cuda: Bool = False) raises -> List[Byte]:
    if len(scalars) > params.n:
        raise Error("commit_coeff: polynomial too large for params")
    return _msm_maybe_cuda(params.g, params.g_dev_xy, params.gpu_ctx, scalars, use_cuda)


fn commit_lagrange(params: ParamsKZGParsed, evals: List[Fq], use_cuda: Bool = False) raises -> List[Byte]:
    if len(evals) != params.n:
        raise Error("commit_lagrange: unexpected eval len")
    return _msm_maybe_cuda(params.g_lagrange, params.g_lagrange_dev_xy, params.gpu_ctx, evals, use_cuda)
