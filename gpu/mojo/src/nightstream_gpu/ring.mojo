from gpu.host import DeviceContext
from gpu import block_dim, block_idx, thread_idx
from memory import UnsafePointer, alloc, stack_allocation, AddressSpace
from nightstream_gpu import field, runtime
from sys import has_accelerator
from std.gpu.sync import barrier


comptime D_WIDTH = 54
comptime TMP_WIDTH = 107
comptime GPU_BLOCK_SIZE = 64
comptime CUDA_RING_ACCUMULATE_LANES = 4
comptime CUDA_RING_ACCUMULATE_BLOCK_SIZE = D_WIDTH * CUDA_RING_ACCUMULATE_LANES
comptime RQ_CUDA_SPARSE_MAX_NONZERO = 8
comptime RQ_MUL_METAL_GPU_MIN_PAIRS = 1024
comptime RQ_MUL_CUDA_GPU_MIN_PAIRS = 16
comptime RQ_MUL_HIP_GPU_MIN_PAIRS = 64
comptime RQ_ACCUMULATE_METAL_GPU_MIN_PAIRS = 256
comptime RQ_ACCUMULATE_CUDA_GPU_MIN_PAIRS = 16
comptime RQ_ACCUMULATE_HIP_GPU_MIN_PAIRS = 64
comptime RQ_ACCUMULATE_GPU_MIN_SLOTS = 1
comptime DEVICE_API_CPU = 0
comptime DEVICE_API_METAL = 1
comptime DEVICE_API_CUDA = 2
comptime DEVICE_API_HIP = 3
comptime STATUS_OK = 0
comptime STATUS_INVALID_INPUT = -2
comptime STATUS_INVALID_HANDLE = -3
comptime STATUS_STALE_HANDLE = -4
comptime STATUS_OUT_LEN = -5
comptime PREPARED_RING_KIND_NONE = UInt32(0)
comptime PREPARED_RING_KIND_MUL = UInt32(1)
comptime PREPARED_RING_KIND_ACCUMULATE = UInt32(2)


struct PreparedRqBatchState(Movable):
    var session: UInt64
    var generation: UInt64
    var kind: UInt32
    var pair_count: Int
    var slot_count: Int
    var lhs_words: UnsafePointer[UInt64, MutAnyOrigin]
    var rhs_words: UnsafePointer[UInt64, MutAnyOrigin]
    var meta_words: UnsafePointer[UInt64, MutAnyOrigin]
    var out_words: UnsafePointer[UInt64, MutAnyOrigin]

    fn __init__(
        out self,
        session: UInt64,
        generation: UInt64,
        kind: UInt32,
        pair_count: Int,
        slot_count: Int,
        meta_word_count: Int,
    ):
        self.session = session
        self.generation = generation
        self.kind = kind
        self.pair_count = pair_count
        self.slot_count = slot_count
        self.lhs_words = alloc[UInt64](pair_count * D_WIDTH)
        self.rhs_words = alloc[UInt64](pair_count * D_WIDTH)
        var meta_capacity = 1
        if meta_word_count > 0:
            meta_capacity = meta_word_count
        self.meta_words = alloc[UInt64](meta_capacity)
        var out_items = slot_count
        if kind == PREPARED_RING_KIND_MUL:
            out_items = pair_count
        self.out_words = alloc[UInt64](out_items * D_WIDTH)

    fn __del__(deinit self):
        self.lhs_words.free()
        self.rhs_words.free()
        self.meta_words.free()
        self.out_words.free()


fn prepared_rq_batch_ptr(handle: UInt64) -> UnsafePointer[PreparedRqBatchState, MutAnyOrigin]:
    return UnsafePointer[PreparedRqBatchState, MutAnyOrigin](unsafe_from_address=Int(handle))


fn next_prepared_generation(current: UInt64) -> UInt64:
    var generation = current + 1
    if generation == 0:
        generation = 1
    return generation


fn upload_prepared_rq_batch(
    session_state: UnsafePointer[runtime.SessionState, MutAnyOrigin],
    batch: UnsafePointer[PreparedRqBatchState, MutAnyOrigin],
) raises:
    ref state = session_state[]
    ref prepared = batch[]
    var meta_word_count = 0
    if prepared.kind == PREPARED_RING_KIND_ACCUMULATE:
        meta_word_count = prepared.slot_count + 1
    var out_items = prepared.slot_count
    if prepared.kind == PREPARED_RING_KIND_MUL:
        out_items = prepared.pair_count
    var out_word_count = out_items * D_WIDTH
    if prepared.kind == PREPARED_RING_KIND_ACCUMULATE and state.api == UInt32(DEVICE_API_CUDA):
        out_word_count = rq_accumulate_cuda_final_word_count(prepared.slot_count) + rq_accumulate_cuda_temp_word_count(
            prepared.pair_count, prepared.slot_count
        )
    state.ensure_prepared_ring_buffers(prepared.pair_count * D_WIDTH, meta_word_count, out_word_count)
    var ctx = state.accelerator_ctx.value()
    var lhs_host = state.prepared_ring_lhs_host.value()
    var lhs_dev = state.prepared_ring_lhs_dev.value()
    var rhs_host = state.prepared_ring_rhs_host.value()
    var rhs_dev = state.prepared_ring_rhs_dev.value()
    for idx in range(prepared.pair_count * D_WIDTH):
        lhs_host[idx] = prepared.lhs_words[idx]
        rhs_host[idx] = prepared.rhs_words[idx]
    if meta_word_count > 0:
        var meta_host = state.prepared_ring_meta_host.value()
        for idx in range(meta_word_count):
            meta_host[idx] = prepared.meta_words[idx]
    ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
    ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
    if meta_word_count > 0:
        var meta_dev = state.prepared_ring_meta_dev.value()
        var meta_host = state.prepared_ring_meta_host.value()
        ctx.enqueue_copy(src_buf=meta_host, dst_buf=meta_dev)
    state.prepared_ring_kind = prepared.kind
    state.prepared_ring_pair_count = prepared.pair_count
    state.prepared_ring_slot_count = prepared.slot_count
    state.prepared_ring_generation = prepared.generation


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


fn rq_nonzero_count_words(words: UnsafePointer[UInt64]) -> Int:
    var count = 0
    for i in range(D_WIDTH):
        if words[i] != 0:
            count += 1
    return count


fn rq_scalar_coeff_words(words: UnsafePointer[UInt64]) -> UInt64:
    var scalar = words[0]
    for i in range(1, D_WIDTH):
        if words[i] != 0:
            return 0
    return scalar


fn rq_mul_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    var lhs_scalar = rq_scalar_coeff_words(lhs_words)
    if lhs_scalar != 0 or rq_nonzero_count_words(lhs_words) == 0:
        for i in range(D_WIDTH):
            out_words[i] = field.fq_mul(lhs_scalar, rhs_words[i])
        return
    var rhs_scalar = rq_scalar_coeff_words(rhs_words)
    if rhs_scalar != 0 or rq_nonzero_count_words(rhs_words) == 0:
        for i in range(D_WIDTH):
            out_words[i] = field.fq_mul(lhs_words[i], rhs_scalar)
        return
    var tmp_words = InlineArray[UInt64, TMP_WIDTH](fill=0)
    var lhs_nz = rq_nonzero_count_words(lhs_words)
    var rhs_nz = rq_nonzero_count_words(rhs_words)
    if lhs_nz <= rhs_nz:
        for i in range(D_WIDTH):
            var ai = lhs_words[i]
            if ai == 0:
                continue
            for j in range(D_WIDTH):
                var bj = rhs_words[j]
                if bj == 0:
                    continue
                var term = field.fq_mul(ai, bj)
                tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)
    else:
        for j in range(D_WIDTH):
            var bj = rhs_words[j]
            if bj == 0:
                continue
            for i in range(D_WIDTH):
                var ai = lhs_words[i]
                if ai == 0:
                    continue
                var term = field.fq_mul(ai, bj)
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
    var lhs_scalar = rq_scalar_coeff_words(lhs_words)
    if lhs_scalar != 0 or rq_nonzero_count_words(lhs_words) == 0:
        for i in range(D_WIDTH):
            out_words[i] = field.fq_add(out_words[i], field.fq_mul(lhs_scalar, rhs_words[i]))
        return
    var rhs_scalar = rq_scalar_coeff_words(rhs_words)
    if rhs_scalar != 0 or rq_nonzero_count_words(rhs_words) == 0:
        for i in range(D_WIDTH):
            out_words[i] = field.fq_add(out_words[i], field.fq_mul(lhs_words[i], rhs_scalar))
        return
    var tmp_words = InlineArray[UInt64, TMP_WIDTH](fill=0)
    var lhs_nz = rq_nonzero_count_words(lhs_words)
    var rhs_nz = rq_nonzero_count_words(rhs_words)
    if lhs_nz <= rhs_nz:
        for i in range(D_WIDTH):
            var ai = lhs_words[i]
            if ai == 0:
                continue
            for j in range(D_WIDTH):
                var bj = rhs_words[j]
                if bj == 0:
                    continue
                var term = field.fq_mul(ai, bj)
                tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)
    else:
        for j in range(D_WIDTH):
            var bj = rhs_words[j]
            if bj == 0:
                continue
            for i in range(D_WIDTH):
                var ai = lhs_words[i]
                if ai == 0:
                    continue
                var term = field.fq_mul(ai, bj)
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
    var lhs_scalar = rq_scalar_coeff_words(lhs_words)
    if lhs_scalar != 0 or rq_nonzero_count_words(lhs_words) == 0:
        return field.fq_mul(lhs_scalar, rhs_words[0])
    var rhs_scalar = rq_scalar_coeff_words(rhs_words)
    if rhs_scalar != 0 or rq_nonzero_count_words(rhs_words) == 0:
        return field.fq_mul(lhs_words[0], rhs_scalar)
    var tmp_words = InlineArray[UInt64, TMP_WIDTH](fill=0)
    var lhs_nz = rq_nonzero_count_words(lhs_words)
    var rhs_nz = rq_nonzero_count_words(rhs_words)
    if lhs_nz <= rhs_nz:
        for i in range(D_WIDTH):
            var ai = lhs_words[i]
            if ai == 0:
                continue
            for j in range(D_WIDTH):
                var bj = rhs_words[j]
                if bj == 0:
                    continue
                var term = field.fq_mul(ai, bj)
                tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)
    else:
        for j in range(D_WIDTH):
            var bj = rhs_words[j]
            if bj == 0:
                continue
            for i in range(D_WIDTH):
                var ai = lhs_words[i]
                if ai == 0:
                    continue
                var term = field.fq_mul(ai, bj)
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


fn rq_convolution_degree_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    degree: Int,
) -> UInt64:
    var start = 0
    if degree >= D_WIDTH:
        start = degree - (D_WIDTH - 1)
    var end = degree
    if end >= D_WIDTH:
        end = D_WIDTH - 1
    var acc = UInt64(0)
    for i in range(start, end + 1):
        acc = field.fq_add(acc, field.fq_mul(lhs_words[i], rhs_words[degree - i]))
    return acc


fn rq_mul_output_coeff_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    coeff_idx: Int,
) -> UInt64:
    var acc = rq_convolution_degree_words(lhs_words, rhs_words, coeff_idx)
    if coeff_idx <= 26:
        acc = field.fq_sub(acc, rq_convolution_degree_words(lhs_words, rhs_words, coeff_idx + 54))
    if coeff_idx >= 27:
        acc = field.fq_sub(acc, rq_convolution_degree_words(lhs_words, rhs_words, coeff_idx + 27))
    if coeff_idx <= 25:
        acc = field.fq_add(acc, rq_convolution_degree_words(lhs_words, rhs_words, coeff_idx + 81))
    return acc


fn rq_mul_output_coeff_sparse_lhs_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    coeff_idx: Int,
) -> UInt64:
    var acc = UInt64(0)
    for i in range(D_WIDTH):
        var ai = lhs_words[i]
        if ai == 0:
            continue
        var j0 = coeff_idx - i
        if j0 >= 0 and j0 < D_WIDTH:
            acc = field.fq_add(acc, field.fq_mul(ai, rhs_words[j0]))
        if coeff_idx <= 26:
            var j1 = coeff_idx + 54 - i
            if j1 >= 0 and j1 < D_WIDTH:
                acc = field.fq_sub(acc, field.fq_mul(ai, rhs_words[j1]))
        if coeff_idx >= 27:
            var j2 = coeff_idx + 27 - i
            if j2 >= 0 and j2 < D_WIDTH:
                acc = field.fq_sub(acc, field.fq_mul(ai, rhs_words[j2]))
        if coeff_idx <= 25:
            var j3 = coeff_idx + 81 - i
            if j3 >= 0 and j3 < D_WIDTH:
                acc = field.fq_add(acc, field.fq_mul(ai, rhs_words[j3]))
    return acc


fn rq_mul_output_coeff_sparse_rhs_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    coeff_idx: Int,
) -> UInt64:
    var acc = UInt64(0)
    for j in range(D_WIDTH):
        var bj = rhs_words[j]
        if bj == 0:
            continue
        var i0 = coeff_idx - j
        if i0 >= 0 and i0 < D_WIDTH:
            acc = field.fq_add(acc, field.fq_mul(lhs_words[i0], bj))
        if coeff_idx <= 26:
            var i1 = coeff_idx + 54 - j
            if i1 >= 0 and i1 < D_WIDTH:
                acc = field.fq_sub(acc, field.fq_mul(lhs_words[i1], bj))
        if coeff_idx >= 27:
            var i2 = coeff_idx + 27 - j
            if i2 >= 0 and i2 < D_WIDTH:
                acc = field.fq_sub(acc, field.fq_mul(lhs_words[i2], bj))
        if coeff_idx <= 25:
            var i3 = coeff_idx + 81 - j
            if i3 >= 0 and i3 < D_WIDTH:
                acc = field.fq_add(acc, field.fq_mul(lhs_words[i3], bj))
    return acc


fn rq_mul_output_coeff_cuda_words(
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    coeff_idx: Int,
) -> UInt64:
    var lhs_nz = rq_nonzero_count_words(lhs_words)
    var lhs_scalar = rq_scalar_coeff_words(lhs_words)
    if lhs_scalar != 0 or lhs_nz == 0:
        return field.fq_mul(lhs_scalar, rhs_words[coeff_idx])
    var rhs_nz = rq_nonzero_count_words(rhs_words)
    var rhs_scalar = rq_scalar_coeff_words(rhs_words)
    if rhs_scalar != 0 or rhs_nz == 0:
        return field.fq_mul(lhs_words[coeff_idx], rhs_scalar)
    if lhs_nz <= rhs_nz and lhs_nz <= RQ_CUDA_SPARSE_MAX_NONZERO:
        return rq_mul_output_coeff_sparse_lhs_words(lhs_words, rhs_words, coeff_idx)
    if rhs_nz < lhs_nz and rhs_nz <= RQ_CUDA_SPARSE_MAX_NONZERO:
        return rq_mul_output_coeff_sparse_rhs_words(lhs_words, rhs_words, coeff_idx)
    return rq_mul_output_coeff_words(lhs_words, rhs_words, coeff_idx)


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


fn rq_mul_batch_cuda_coeff_kernel(
    lhs_words: UnsafePointer[mut=True, UInt64],
    rhs_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
    pair_count: Int,
):
    var pair_idx = Int(block_idx.x)
    var coeff_idx = Int(thread_idx.x)
    if pair_idx >= pair_count or coeff_idx >= D_WIDTH:
        return
    var offset = pair_idx * D_WIDTH
    out_words[offset + coeff_idx] = rq_mul_output_coeff_cuda_words(lhs_words + offset, rhs_words + offset, coeff_idx)


fn rq_mul_batch_cuda_coeff_kernel_sig(
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


fn rq_accumulate_reduce_pairs_gpu_kernel(
    pair_words: UnsafePointer[mut=True, UInt64],
    slot_offsets_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
    slot_count: Int,
):
    var slot_idx = Int(block_idx.x)
    var coeff_idx = Int(thread_idx.x)
    if slot_idx >= slot_count or coeff_idx >= D_WIDTH:
        return
    var start = Int(slot_offsets_words[slot_idx])
    var end = Int(slot_offsets_words[slot_idx + 1])
    var acc = UInt64(0)
    for pair_idx in range(start, end):
        acc = field.fq_add(acc, pair_words[pair_idx * D_WIDTH + coeff_idx])
    out_words[slot_idx * D_WIDTH + coeff_idx] = acc


fn rq_accumulate_reduce_pairs_gpu_kernel_sig(
    pair_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_offsets_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_count: Int,
):
    pass


fn rq_accumulate_direct_cuda_kernel(
    lhs_words: UnsafePointer[mut=True, UInt64],
    rhs_words: UnsafePointer[mut=True, UInt64],
    slot_offsets_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
    slot_count: Int,
):
    var slot_idx = Int(block_idx.x)
    var tid = Int(thread_idx.x)
    var coeff_idx = tid % D_WIDTH
    var lane_idx = tid // D_WIDTH
    if slot_idx >= slot_count or tid >= CUDA_RING_ACCUMULATE_BLOCK_SIZE:
        return
    var start = Int(slot_offsets_words[slot_idx])
    var end = Int(slot_offsets_words[slot_idx + 1])
    var partials = stack_allocation[
        CUDA_RING_ACCUMULATE_BLOCK_SIZE,
        Scalar[DType.uint64],
        address_space=AddressSpace.SHARED,
    ]()
    var acc = UInt64(0)
    for pair_idx in range(start + lane_idx, end, CUDA_RING_ACCUMULATE_LANES):
        var pair_off = pair_idx * D_WIDTH
        acc = field.fq_add(
            acc,
            rq_mul_output_coeff_cuda_words(lhs_words + pair_off, rhs_words + pair_off, coeff_idx),
        )
    partials[tid] = acc
    barrier()
    if lane_idx == 0:
        for reduce_lane in range(1, CUDA_RING_ACCUMULATE_LANES):
            acc = field.fq_add(acc, partials[reduce_lane * D_WIDTH + coeff_idx])
        out_words[slot_idx * D_WIDTH + coeff_idx] = acc


fn rq_accumulate_direct_cuda_kernel_sig(
    lhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    rhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_offsets_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_count: Int,
):
    pass


fn destroy_session_cache(session: UInt64):
    if session <= 1:
        return
    runtime.session_state_ptr(session)[].ring_kernel_cache_addr = 0


fn rq_accumulate_cuda_temp_word_count(pair_count: Int, slot_count: Int) -> Int:
    _ = pair_count
    _ = slot_count
    return 0


fn rq_accumulate_cuda_final_word_count(slot_count: Int) -> Int:
    return slot_count * D_WIDTH


fn rq_mul_batch_gpu_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    pair_count: Int,
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    if not has_accelerator():
        raise Error("ring accelerator unavailable at compile time")
    else:
        var api = runtime.session_api(session)
        var word_count = pair_count * D_WIDTH
        var session_ptr = runtime.session_state_ptr(session)
        ref session_state = session_ptr[]
        session_state.ensure_ring_buffers(word_count)
        var ctx = session_state.accelerator_ctx.value()
        var lhs_host = session_state.ring_lhs_host.value()
        var lhs_dev = session_state.ring_lhs_dev.value()
        var rhs_host = session_state.ring_rhs_host.value()
        var rhs_dev = session_state.ring_rhs_dev.value()
        var out_host = session_state.ring_out_host.value()
        var out_dev = session_state.ring_out_dev.value()

        for idx in range(word_count):
            lhs_host[idx] = lhs_words[idx]
            rhs_host[idx] = rhs_words[idx]

        ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
        ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
        if api == UInt32(DEVICE_API_CUDA):
            ctx.enqueue_function[
                rq_mul_batch_cuda_coeff_kernel, rq_mul_batch_cuda_coeff_kernel_sig
            ](
                lhs_dev.unsafe_ptr(),
                rhs_dev.unsafe_ptr(),
                out_dev.unsafe_ptr(),
                pair_count,
                grid_dim=pair_count,
                block_dim=GPU_BLOCK_SIZE,
            )
        else:
            ctx.enqueue_function[
                rq_mul_batch_gpu_kernel, rq_mul_batch_gpu_kernel_sig
            ](
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
    if not has_accelerator():
        raise Error("ring accelerator unavailable at compile time")
    else:
        var api = runtime.session_api(session)
        if api == UInt32(DEVICE_API_CUDA):
            rq_accumulate_batch_gpu_cuda_words(
                session,
                lhs_words,
                rhs_words,
                slot_offsets_words,
                pair_count,
                slot_count,
                out_words,
            )
            return
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
        var ctx = session_state.accelerator_ctx.value()
        var lhs_host = session_state.ring_lhs_host.value()
        var lhs_dev = session_state.ring_lhs_dev.value()
        var rhs_host = session_state.ring_rhs_host.value()
        var rhs_dev = session_state.ring_rhs_dev.value()
        var out_host = session_state.ring_out_host.value()
        var out_dev = session_state.ring_out_dev.value()
        var meta_host = session_state.ring_meta_host.value()
        var meta_dev = session_state.ring_meta_dev.value()

        for idx in range(word_count):
            lhs_host[idx] = lhs_words[idx]
            rhs_host[idx] = rhs_words[idx]
        for idx in range(meta_word_count):
            meta_host[idx] = slot_offsets_words[idx]

        ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
        ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
        ctx.enqueue_copy(src_buf=meta_host, dst_buf=meta_dev)
        ctx.enqueue_function[
            rq_accumulate_batch_gpu_kernel, rq_accumulate_batch_gpu_kernel_sig
        ](
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


fn rq_accumulate_batch_gpu_cuda_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    slot_offsets_words: UnsafePointer[UInt64],
    pair_count: Int,
    slot_count: Int,
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    if not has_accelerator():
        raise Error("ring accelerator unavailable at compile time")
    else:
        var word_count = pair_count * D_WIDTH
        var final_word_count = rq_accumulate_cuda_final_word_count(slot_count)
        var meta_word_count = slot_count + 1
        var session_ptr = runtime.session_state_ptr(session)
        ref session_state = session_ptr[]
        session_state.ensure_ring_buffers(word_count, meta_word_count, final_word_count)
        var ctx = session_state.accelerator_ctx.value()
        var lhs_host = session_state.ring_lhs_host.value()
        var lhs_dev = session_state.ring_lhs_dev.value()
        var rhs_host = session_state.ring_rhs_host.value()
        var rhs_dev = session_state.ring_rhs_dev.value()
        var out_host = session_state.ring_out_host.value()
        var out_dev = session_state.ring_out_dev.value()
        var meta_host = session_state.ring_meta_host.value()
        var meta_dev = session_state.ring_meta_dev.value()

        for idx in range(word_count):
            lhs_host[idx] = lhs_words[idx]
            rhs_host[idx] = rhs_words[idx]
        for idx in range(meta_word_count):
            meta_host[idx] = slot_offsets_words[idx]

        ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
        ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
        ctx.enqueue_copy(src_buf=meta_host, dst_buf=meta_dev)
        ctx.enqueue_function[
            rq_accumulate_direct_cuda_kernel, rq_accumulate_direct_cuda_kernel_sig
        ](
            lhs_dev.unsafe_ptr(),
            rhs_dev.unsafe_ptr(),
            meta_dev.unsafe_ptr(),
            out_dev.unsafe_ptr(),
            slot_count,
            grid_dim=slot_count,
            block_dim=CUDA_RING_ACCUMULATE_BLOCK_SIZE,
        )
        ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
        ctx.synchronize()

        for idx in range(final_word_count):
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
    if not has_accelerator():
        raise Error("ring accelerator unavailable at compile time")
    else:
        var word_count = pair_count * D_WIDTH
        var session_ptr = runtime.session_state_ptr(session)
        ref session_state = session_ptr[]
        session_state.ensure_ring_buffers(word_count)
        var ctx = session_state.accelerator_ctx.value()
        var lhs_host = session_state.ring_lhs_host.value()
        var lhs_dev = session_state.ring_lhs_dev.value()
        var rhs_host = session_state.ring_rhs_host.value()
        var rhs_dev = session_state.ring_rhs_dev.value()
        var out_host = session_state.ring_out_host.value()
        var out_dev = session_state.ring_out_dev.value()

        for idx in range(word_count):
            lhs_host[idx] = lhs_words[idx]
            rhs_host[idx] = rhs_words[idx]

        ctx.enqueue_copy(src_buf=lhs_host, dst_buf=lhs_dev)
        ctx.enqueue_copy(src_buf=rhs_host, dst_buf=rhs_dev)
        ctx.enqueue_function[
            rq_mul_batch_gpu_kernel, rq_mul_batch_gpu_kernel_sig
        ](
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


fn rq_mul_batch_prepare_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    pair_count: UInt64,
    out_handle: UnsafePointer[mut=True, UInt64],
) -> Int32:
    if pair_count == 0:
        return STATUS_INVALID_INPUT
    var pair_count_int = Int(pair_count)
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    var generation = next_prepared_generation(session_state.prepared_ring_generation)
    var ptr = alloc[PreparedRqBatchState](1)
    ptr.init_pointee_move(
        PreparedRqBatchState(
            session,
            generation,
            PREPARED_RING_KIND_MUL,
            pair_count_int,
            0,
            0,
        )
    )
    for idx in range(pair_count_int * D_WIDTH):
        ptr[].lhs_words[idx] = lhs_words[idx]
        ptr[].rhs_words[idx] = rhs_words[idx]
    if session_prefers_gpu(session):
        try:
            upload_prepared_rq_batch(session_ptr, ptr)
        except:
            ptr.destroy_pointee()
            ptr.free()
            return STATUS_INVALID_INPUT
    else:
        session_state.prepared_ring_kind = PREPARED_RING_KIND_MUL
        session_state.prepared_ring_pair_count = pair_count_int
        session_state.prepared_ring_slot_count = 0
        session_state.prepared_ring_generation = generation
    out_handle[0] = UInt64(Int(ptr))
    return STATUS_OK


fn rq_accumulate_batch_prepare_words(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    slot_offsets_words: UnsafePointer[UInt64],
    slot_count: UInt64,
    out_handle: UnsafePointer[mut=True, UInt64],
) -> Int32:
    if slot_count == 0:
        return STATUS_INVALID_INPUT
    var slot_count_int = Int(slot_count)
    var pair_count_int = Int(slot_offsets_words[slot_count_int])
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    var generation = next_prepared_generation(session_state.prepared_ring_generation)
    var ptr = alloc[PreparedRqBatchState](1)
    ptr.init_pointee_move(
        PreparedRqBatchState(
            session,
            generation,
            PREPARED_RING_KIND_ACCUMULATE,
            pair_count_int,
            slot_count_int,
            slot_count_int + 1,
        )
    )
    for idx in range(pair_count_int * D_WIDTH):
        ptr[].lhs_words[idx] = lhs_words[idx]
        ptr[].rhs_words[idx] = rhs_words[idx]
    for idx in range(slot_count_int + 1):
        ptr[].meta_words[idx] = slot_offsets_words[idx]
    if session_prefers_gpu(session):
        try:
            upload_prepared_rq_batch(session_ptr, ptr)
        except:
            ptr.destroy_pointee()
            ptr.free()
            return STATUS_INVALID_INPUT
    else:
        session_state.prepared_ring_kind = PREPARED_RING_KIND_ACCUMULATE
        session_state.prepared_ring_pair_count = pair_count_int
        session_state.prepared_ring_slot_count = slot_count_int
        session_state.prepared_ring_generation = generation
    out_handle[0] = UInt64(Int(ptr))
    return STATUS_OK


fn rq_prepared_execute_words(session: UInt64, handle: UInt64) -> Int32:
    if handle == 0:
        return STATUS_INVALID_HANDLE
    var batch_ptr = prepared_rq_batch_ptr(handle)
    ref batch = batch_ptr[]
    if batch.session != session:
        return STATUS_INVALID_HANDLE
    if not session_prefers_gpu(session):
        if batch.kind == PREPARED_RING_KIND_MUL:
            rq_mul_batch_cpu_words(batch.lhs_words, batch.rhs_words, batch.pair_count, batch.out_words)
        elif batch.kind == PREPARED_RING_KIND_ACCUMULATE:
            rq_accumulate_batch_cpu_words(
                batch.lhs_words,
                batch.rhs_words,
                batch.meta_words,
                batch.slot_count,
                batch.out_words,
            )
        else:
            return STATUS_INVALID_HANDLE
        return STATUS_OK
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    if session_state.prepared_ring_generation != batch.generation or session_state.prepared_ring_kind != batch.kind:
        return STATUS_STALE_HANDLE
    try:
        var ctx = session_state.accelerator_ctx.value()
        var lhs_dev = session_state.prepared_ring_lhs_dev.value()
        var rhs_dev = session_state.prepared_ring_rhs_dev.value()
        var out_dev = session_state.prepared_ring_out_dev.value()
        if batch.kind == PREPARED_RING_KIND_MUL:
            if runtime.session_api(session) == UInt32(DEVICE_API_CUDA):
                ctx.enqueue_function[
                    rq_mul_batch_cuda_coeff_kernel, rq_mul_batch_cuda_coeff_kernel_sig
                ](
                    lhs_dev.unsafe_ptr(),
                    rhs_dev.unsafe_ptr(),
                    out_dev.unsafe_ptr(),
                    batch.pair_count,
                    grid_dim=batch.pair_count,
                    block_dim=GPU_BLOCK_SIZE,
                )
            else:
                ctx.enqueue_function[
                    rq_mul_batch_gpu_kernel, rq_mul_batch_gpu_kernel_sig
                ](
                    lhs_dev.unsafe_ptr(),
                    rhs_dev.unsafe_ptr(),
                    out_dev.unsafe_ptr(),
                    batch.pair_count,
                    grid_dim=(batch.pair_count + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
                    block_dim=GPU_BLOCK_SIZE,
                )
        elif batch.kind == PREPARED_RING_KIND_ACCUMULATE:
            var meta_dev = session_state.prepared_ring_meta_dev.value()
            if runtime.session_api(session) == UInt32(DEVICE_API_CUDA):
                ctx.enqueue_function[
                    rq_accumulate_direct_cuda_kernel, rq_accumulate_direct_cuda_kernel_sig
                ](
                    lhs_dev.unsafe_ptr(),
                    rhs_dev.unsafe_ptr(),
                    meta_dev.unsafe_ptr(),
                    out_dev.unsafe_ptr(),
                    batch.slot_count,
                    grid_dim=batch.slot_count,
                    block_dim=CUDA_RING_ACCUMULATE_BLOCK_SIZE,
                )
            else:
                ctx.enqueue_function[
                    rq_accumulate_batch_gpu_kernel, rq_accumulate_batch_gpu_kernel_sig
                ](
                    lhs_dev.unsafe_ptr(),
                    rhs_dev.unsafe_ptr(),
                    meta_dev.unsafe_ptr(),
                    out_dev.unsafe_ptr(),
                    batch.slot_count,
                    grid_dim=(batch.slot_count + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
                    block_dim=GPU_BLOCK_SIZE,
                )
        else:
            return STATUS_INVALID_HANDLE
    except:
        return STATUS_INVALID_INPUT
    return STATUS_OK


fn rq_prepared_read_words(
    session: UInt64,
    handle: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
    out_len: UInt64,
) -> Int32:
    if handle == 0:
        return STATUS_INVALID_HANDLE
    var batch_ptr = prepared_rq_batch_ptr(handle)
    ref batch = batch_ptr[]
    if batch.session != session:
        return STATUS_INVALID_HANDLE
    var expected_items = batch.slot_count
    if batch.kind == PREPARED_RING_KIND_MUL:
        expected_items = batch.pair_count
    var expected_words = expected_items * D_WIDTH
    if Int(out_len) < expected_words:
        return STATUS_OUT_LEN
    if not session_prefers_gpu(session):
        for idx in range(expected_words):
            out_words[idx] = batch.out_words[idx]
        return STATUS_OK
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    if session_state.prepared_ring_generation != batch.generation or session_state.prepared_ring_kind != batch.kind:
        return STATUS_STALE_HANDLE
    try:
        var ctx = session_state.accelerator_ctx.value()
        var out_host = session_state.prepared_ring_out_host.value()
        var out_dev = session_state.prepared_ring_out_dev.value()
        ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
        ctx.synchronize()
        for idx in range(expected_words):
            out_words[idx] = out_host[idx]
    except:
        return STATUS_INVALID_INPUT
    return STATUS_OK


fn rq_prepared_destroy_words(_session: UInt64, handle: UInt64) -> Int32:
    if handle == 0:
        return STATUS_INVALID_HANDLE
    var ptr = prepared_rq_batch_ptr(handle)
    ptr.destroy_pointee()
    ptr.free()
    return STATUS_OK
