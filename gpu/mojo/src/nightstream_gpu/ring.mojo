from gpu.host import DeviceContext
from gpu import block_dim, block_idx, thread_idx
from memory import UnsafePointer, alloc
from nightstream_gpu import field, runtime


comptime D_WIDTH = 54
comptime TMP_WIDTH = 107
comptime GPU_BLOCK_SIZE = 64
comptime RQ_MUL_METAL_GPU_MIN_PAIRS = 1024
comptime RQ_MUL_CUDA_GPU_MIN_PAIRS = 64
comptime RQ_MUL_HIP_GPU_MIN_PAIRS = 64
comptime RQ_ACCUMULATE_METAL_GPU_MIN_PAIRS = 256
comptime RQ_ACCUMULATE_CUDA_GPU_MIN_PAIRS = 64
comptime RQ_ACCUMULATE_HIP_GPU_MIN_PAIRS = 64
comptime RQ_ACCUMULATE_GPU_MIN_SLOTS = 1
comptime DEVICE_API_CPU = 0
comptime DEVICE_API_METAL = 1
comptime DEVICE_API_CUDA = 2
comptime DEVICE_API_HIP = 3
comptime RqMulBatchKernelT = type_of(
    DeviceContext().compile_function[rq_mul_batch_gpu_kernel, rq_mul_batch_gpu_kernel_sig]()
)
comptime RqAccumulateBatchKernelT = type_of(
    DeviceContext().compile_function[
        rq_accumulate_batch_gpu_kernel, rq_accumulate_batch_gpu_kernel_sig
    ]()
)


fn scaffold_ready() -> Bool:
    return True


fn rq_zero_words(out_words: UnsafePointer[mut=True, UInt64]):
    for i in range(D_WIDTH):
        out_words[i] = 0


fn rq_copy_words(
    src_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    for i in range(D_WIDTH):
        out_words[i] = src_words[i]


fn rq_add_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    for i in range(D_WIDTH):
        out_words[i] = field.fq_add(lhs_words[i], rhs_words[i])


fn rq_sub_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    for i in range(D_WIDTH):
        out_words[i] = field.fq_sub(lhs_words[i], rhs_words[i])


fn reduce_mod_phi_81_words(tmp_words: UnsafePointer[mut=True, UInt64]):
    for i in range(TMP_WIDTH - 1, D_WIDTH - 1, -1):
        var t = tmp_words[i]
        tmp_words[i] = 0
        tmp_words[i - D_WIDTH] = field.fq_sub(tmp_words[i - D_WIDTH], t)

        var idx_27 = i - 27
        if idx_27 < D_WIDTH:
            tmp_words[idx_27] = field.fq_sub(tmp_words[idx_27], t)
        else:
            tmp_words[idx_27 - D_WIDTH] = field.fq_add(tmp_words[idx_27 - D_WIDTH], t)
            if idx_27 - 27 < D_WIDTH:
                tmp_words[idx_27 - 27] = field.fq_add(tmp_words[idx_27 - 27], t)


fn rq_mul_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    var tmp_words = InlineArray[UInt64, TMP_WIDTH](fill=0)

    for i in range(D_WIDTH):
        var ai = lhs_words[i]
        for j in range(D_WIDTH):
            var term = field.fq_mul(ai, rhs_words[j])
            tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)

    for i in range(TMP_WIDTH - 1, D_WIDTH - 1, -1):
        var t = tmp_words[i]
        tmp_words[i] = 0
        tmp_words[i - D_WIDTH] = field.fq_sub(tmp_words[i - D_WIDTH], t)

        var idx_27 = i - 27
        if idx_27 < D_WIDTH:
            tmp_words[idx_27] = field.fq_sub(tmp_words[idx_27], t)
        else:
            tmp_words[idx_27 - D_WIDTH] = field.fq_add(tmp_words[idx_27 - D_WIDTH], t)
            if idx_27 - 27 < D_WIDTH:
                tmp_words[idx_27 - 27] = field.fq_add(tmp_words[idx_27 - 27], t)
    for i in range(D_WIDTH):
        out_words[i] = tmp_words[i]


fn rq_mul_add_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    var tmp_words = InlineArray[UInt64, TMP_WIDTH](fill=0)

    for i in range(D_WIDTH):
        var ai = lhs_words[i]
        for j in range(D_WIDTH):
            var term = field.fq_mul(ai, rhs_words[j])
            tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)

    for i in range(TMP_WIDTH - 1, D_WIDTH - 1, -1):
        var t = tmp_words[i]
        tmp_words[i] = 0
        tmp_words[i - D_WIDTH] = field.fq_sub(tmp_words[i - D_WIDTH], t)

        var idx_27 = i - 27
        if idx_27 < D_WIDTH:
            tmp_words[idx_27] = field.fq_sub(tmp_words[idx_27], t)
        else:
            tmp_words[idx_27 - D_WIDTH] = field.fq_add(tmp_words[idx_27 - D_WIDTH], t)
            if idx_27 - 27 < D_WIDTH:
                tmp_words[idx_27 - 27] = field.fq_add(tmp_words[idx_27 - 27], t)
    for i in range(D_WIDTH):
        out_words[i] = field.fq_add(out_words[i], tmp_words[i])


fn rq_mul_batch_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    pair_count: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
):
    var pair_count_int = Int(pair_count)
    if pair_count_int <= 0:
        return
    if not session_prefers_gpu(session) or pair_count_int < rq_mul_gpu_min_pairs_for_api(runtime.session_api(session)):
        rq_mul_batch_cpu_words(lhs_words, rhs_words, pair_count_int, out_words)
        return
    try:
        rq_mul_batch_gpu_words(session, lhs_words, rhs_words, pair_count_int, out_words)
    except:
        rq_mul_batch_cpu_words(lhs_words, rhs_words, pair_count_int, out_words)


fn rq_ct_words(words: UnsafePointer[UInt64]) -> UInt64:
    return words[0]


fn rq_mul_ct_words(lhs_words: UnsafePointer[UInt64], rhs_words: UnsafePointer[UInt64]) -> UInt64:
    var tmp_words = InlineArray[UInt64, TMP_WIDTH](fill=0)

    for i in range(D_WIDTH):
        var ai = lhs_words[i]
        for j in range(D_WIDTH):
            var term = field.fq_mul(ai, rhs_words[j])
            tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)

    for i in range(TMP_WIDTH - 1, D_WIDTH - 1, -1):
        var t = tmp_words[i]
        tmp_words[i] = 0
        tmp_words[i - D_WIDTH] = field.fq_sub(tmp_words[i - D_WIDTH], t)

        var idx_27 = i - 27
        if idx_27 < D_WIDTH:
            tmp_words[idx_27] = field.fq_sub(tmp_words[idx_27], t)
        else:
            tmp_words[idx_27 - D_WIDTH] = field.fq_add(tmp_words[idx_27 - D_WIDTH], t)
            if idx_27 - 27 < D_WIDTH:
                tmp_words[idx_27 - 27] = field.fq_add(tmp_words[idx_27 - 27], t)

    return tmp_words[0]


fn rq_mul_batch_cpu_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    pair_count: Int,
    out_words: UnsafePointer[mut=True, UInt64],
):
    for pair_idx in range(pair_count):
        var offset = pair_idx * D_WIDTH
        rq_mul_words(lhs_words + offset, rhs_words + offset, out_words + offset)


fn rq_mul_batch_gpu_kernel(
    lhs_words: UnsafePointer[mut=True, UInt64],
    rhs_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
    pair_count: Int,
):
    var pair_idx = Int(block_idx.x * block_dim.x + thread_idx.x)
    if pair_idx < pair_count:
        var offset = pair_idx * D_WIDTH
        rq_mul_words(lhs_words + offset, rhs_words + offset, out_words + offset)


fn rq_mul_batch_gpu_kernel_sig(
    lhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    rhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
    pair_count: Int,
):
    pass


fn rq_accumulate_batch_cpu_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    slot_offsets_words: UnsafePointer[UInt64],
    slot_count: Int,
    out_words: UnsafePointer[mut=True, UInt64],
):
    for slot_idx in range(slot_count):
        var out_off = slot_idx * D_WIDTH
        rq_zero_words(out_words + out_off)
        var start = Int(slot_offsets_words[slot_idx])
        var end = Int(slot_offsets_words[slot_idx + 1])
        for pair_idx in range(start, end):
            var pair_off = pair_idx * D_WIDTH
            rq_mul_add_words(lhs_words + pair_off, rhs_words + pair_off, out_words + out_off)


fn rq_accumulate_batch_gpu_kernel(
    lhs_words: UnsafePointer[mut=True, UInt64],
    rhs_words: UnsafePointer[mut=True, UInt64],
    slot_offsets_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
    slot_count: Int,
):
    var slot_idx = Int(block_idx.x * block_dim.x + thread_idx.x)
    if slot_idx < slot_count:
        var out_off = slot_idx * D_WIDTH
        rq_zero_words(out_words + out_off)
        var start = Int(slot_offsets_words[slot_idx])
        var end = Int(slot_offsets_words[slot_idx + 1])
        for pair_idx in range(start, end):
            var pair_off = pair_idx * D_WIDTH
            rq_mul_add_words(lhs_words + pair_off, rhs_words + pair_off, out_words + out_off)


fn rq_accumulate_batch_gpu_kernel_sig(
    lhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    rhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_offsets_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_count: Int,
):
    pass


struct RingGpuCache(Movable):
    var batch_kernel: RqMulBatchKernelT
    var accumulate_kernel: RqAccumulateBatchKernelT

    fn __init__(out self, ctx: DeviceContext) raises:
        self.batch_kernel = ctx.compile_function[
            rq_mul_batch_gpu_kernel, rq_mul_batch_gpu_kernel_sig
        ]()
        self.accumulate_kernel = ctx.compile_function[
            rq_accumulate_batch_gpu_kernel, rq_accumulate_batch_gpu_kernel_sig
        ]()


fn ring_gpu_cache_ptr(session: UInt64) -> UnsafePointer[RingGpuCache, MutAnyOrigin]:
    var addr = runtime.session_state_ptr(session)[].ring_kernel_cache_addr
    return UnsafePointer[RingGpuCache, MutAnyOrigin](unsafe_from_address=Int(addr))


fn ensure_ring_gpu_cache(session: UInt64) raises:
    ref session_state = runtime.session_state_ptr(session)[]
    if session_state.ring_kernel_cache_addr != 0:
        return

    var ptr = alloc[RingGpuCache](1)
    ptr.init_pointee_move(RingGpuCache(session_state.accelerator_ctx.value()))
    session_state.ring_kernel_cache_addr = UInt64(Int(ptr))


fn destroy_session_cache(session: UInt64):
    if session <= 1:
        return
    ref session_state = runtime.session_state_ptr(session)[]
    if session_state.ring_kernel_cache_addr == 0:
        return

    var ptr = ring_gpu_cache_ptr(session)
    ptr.destroy_pointee()
    ptr.free()
    session_state.ring_kernel_cache_addr = 0


fn rq_mul_batch_gpu_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    pair_count: Int,
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    var word_count = pair_count * D_WIDTH
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    session_state.ensure_ring_buffers(word_count)
    ensure_ring_gpu_cache(session)
    var ctx = session_state.accelerator_ctx.value()
    var lhs_host = session_state.ring_lhs_host.value()
    var lhs_dev = session_state.ring_lhs_dev.value()
    var rhs_host = session_state.ring_rhs_host.value()
    var rhs_dev = session_state.ring_rhs_dev.value()
    var out_host = session_state.ring_out_host.value()
    var out_dev = session_state.ring_out_dev.value()
    ref cache = ring_gpu_cache_ptr(session)[]

    for idx in range(word_count):
        lhs_host[idx] = lhs_words[idx]
        rhs_host[idx] = rhs_words[idx]

    ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
    ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
    ctx.enqueue_function(
        cache.batch_kernel,
        lhs_dev.unsafe_ptr(),
        rhs_dev.unsafe_ptr(),
        out_dev.unsafe_ptr(),
        pair_count,
        grid_dim=(pair_count + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
        block_dim=GPU_BLOCK_SIZE,
    )
    ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
    ctx.synchronize()

    for idx in range(word_count):
        out_words[idx] = out_host[idx]


fn rq_accumulate_batch_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    slot_offsets_words: UnsafePointer[UInt64],
    slot_count: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
):
    var slot_count_int = Int(slot_count)
    if slot_count_int <= 0:
        return
    var pair_count_int = Int(slot_offsets_words[slot_count_int])
    if pair_count_int <= 0:
        for slot_idx in range(slot_count_int):
            rq_zero_words(out_words + slot_idx * D_WIDTH)
        return
    if (
        not session_prefers_gpu(session)
        or pair_count_int < rq_accumulate_gpu_min_pairs_for_api(runtime.session_api(session))
    ):
        rq_accumulate_batch_cpu_words(lhs_words, rhs_words, slot_offsets_words, slot_count_int, out_words)
        return
    try:
        rq_accumulate_batch_gpu_words(
            session,
            lhs_words,
            rhs_words,
            slot_offsets_words,
            pair_count_int,
            slot_count_int,
            out_words,
        )
    except:
        rq_accumulate_batch_cpu_words(lhs_words, rhs_words, slot_offsets_words, slot_count_int, out_words)


fn rq_accumulate_batch_gpu_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    slot_offsets_words: UnsafePointer[UInt64],
    pair_count: Int,
    slot_count: Int,
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    if slot_count < RQ_ACCUMULATE_GPU_MIN_SLOTS:
        rq_accumulate_batch_gpu_host_reduce_words(
            session, lhs_words, rhs_words, slot_offsets_words, pair_count, slot_count, out_words
        )
        return
    var word_count = pair_count * D_WIDTH
    var out_word_count = slot_count * D_WIDTH
    var meta_word_count = slot_count + 1
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    session_state.ensure_ring_buffers(word_count, meta_word_count)
    ensure_ring_gpu_cache(session)
    var ctx = session_state.accelerator_ctx.value()
    var lhs_host = session_state.ring_lhs_host.value()
    var lhs_dev = session_state.ring_lhs_dev.value()
    var rhs_host = session_state.ring_rhs_host.value()
    var rhs_dev = session_state.ring_rhs_dev.value()
    var out_host = session_state.ring_out_host.value()
    var out_dev = session_state.ring_out_dev.value()
    var meta_host = session_state.ring_meta_host.value()
    var meta_dev = session_state.ring_meta_dev.value()
    ref cache = ring_gpu_cache_ptr(session)[]

    for idx in range(word_count):
        lhs_host[idx] = lhs_words[idx]
        rhs_host[idx] = rhs_words[idx]
    for idx in range(meta_word_count):
        meta_host[idx] = slot_offsets_words[idx]

    ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
    ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
    ctx.enqueue_copy(src_buf=meta_host, dst_buf=meta_dev)
    ctx.enqueue_function(
        cache.accumulate_kernel,
        lhs_dev.unsafe_ptr(),
        rhs_dev.unsafe_ptr(),
        meta_dev.unsafe_ptr(),
        out_dev.unsafe_ptr(),
        slot_count,
        grid_dim=(slot_count + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
        block_dim=GPU_BLOCK_SIZE,
    )
    ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
    ctx.synchronize()

    for idx in range(out_word_count):
        out_words[idx] = out_host[idx]


fn rq_accumulate_batch_gpu_host_reduce_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    slot_offsets_words: UnsafePointer[UInt64],
    pair_count: Int,
    slot_count: Int,
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    var word_count = pair_count * D_WIDTH
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    session_state.ensure_ring_buffers(word_count)
    ensure_ring_gpu_cache(session)
    var ctx = session_state.accelerator_ctx.value()
    var lhs_host = session_state.ring_lhs_host.value()
    var lhs_dev = session_state.ring_lhs_dev.value()
    var rhs_host = session_state.ring_rhs_host.value()
    var rhs_dev = session_state.ring_rhs_dev.value()
    var out_host = session_state.ring_out_host.value()
    var out_dev = session_state.ring_out_dev.value()
    ref cache = ring_gpu_cache_ptr(session)[]

    for idx in range(word_count):
        lhs_host[idx] = lhs_words[idx]
        rhs_host[idx] = rhs_words[idx]

    ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
    ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
    ctx.enqueue_function(
        cache.batch_kernel,
        lhs_dev.unsafe_ptr(),
        rhs_dev.unsafe_ptr(),
        out_dev.unsafe_ptr(),
        pair_count,
        grid_dim=(pair_count + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
        block_dim=GPU_BLOCK_SIZE,
    )
    ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
    ctx.synchronize()

    for slot_idx in range(slot_count):
        var out_off = slot_idx * D_WIDTH
        rq_zero_words(out_words + out_off)
        var start = Int(slot_offsets_words[slot_idx])
        var end = Int(slot_offsets_words[slot_idx + 1])
        for pair_idx in range(start, end):
            var pair_off = pair_idx * D_WIDTH
            rq_add_words(out_words + out_off, out_host.unsafe_ptr() + pair_off, out_words + out_off)


fn rq_mul_gpu_min_pairs_for_api(api: UInt32) -> Int:
    if api == UInt32(DEVICE_API_METAL):
        return RQ_MUL_METAL_GPU_MIN_PAIRS
    if api == UInt32(DEVICE_API_CUDA):
        return RQ_MUL_CUDA_GPU_MIN_PAIRS
    if api == UInt32(DEVICE_API_HIP):
        return RQ_MUL_HIP_GPU_MIN_PAIRS
    return 1 << 30


fn rq_accumulate_gpu_min_pairs_for_api(api: UInt32) -> Int:
    if api == UInt32(DEVICE_API_METAL):
        return RQ_ACCUMULATE_METAL_GPU_MIN_PAIRS
    if api == UInt32(DEVICE_API_CUDA):
        return RQ_ACCUMULATE_CUDA_GPU_MIN_PAIRS
    if api == UInt32(DEVICE_API_HIP):
        return RQ_ACCUMULATE_HIP_GPU_MIN_PAIRS
    return 1 << 30


fn session_prefers_gpu(session: UInt64) -> Bool:
    var api = runtime.session_api(session)
    if api == UInt32(DEVICE_API_CPU):
        return False
    return runtime.session_prefers_gpu(session) and (
        api == UInt32(DEVICE_API_METAL) or api == UInt32(DEVICE_API_CUDA)
    )
