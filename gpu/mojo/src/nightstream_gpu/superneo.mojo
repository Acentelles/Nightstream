from gpu.host import DeviceContext
from gpu import block_dim, block_idx, thread_idx
from memory import UnsafePointer, alloc
from nightstream_gpu import field, ring, runtime
from sys import has_accelerator


comptime D_WIDTH = 54
comptime BLOCK_WORDS = 54
comptime MATRIX_WORDS = D_WIDTH * D_WIDTH
comptime GPU_BLOCK_SIZE = 64
comptime DEVICE_API_CPU = 0
comptime DEVICE_API_METAL = 1
comptime DEVICE_API_CUDA = 2
comptime DEVICE_API_HIP = 3


fn scaffold_ready() -> Bool:
    return True


fn superneo_bar_block_from_matrix_words(
    session: UInt64,
    matrix_words: UnsafePointer[UInt64],
    block_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    if not session_prefers_gpu(session):
        superneo_bar_block_cpu_words(matrix_words, block_words, out_words)
        return
    try:
        superneo_bar_block_gpu_words(session, matrix_words, block_words, out_words)
    except:
        superneo_bar_block_cpu_words(matrix_words, block_words, out_words)


fn superneo_bar_block_cpu_words(
    matrix_words: UnsafePointer[UInt64],
    block_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    for row in range(D_WIDTH):
        var acc = UInt64(0)
        var row_off = row * D_WIDTH
        for col in range(D_WIDTH):
            var term = field.fq_mul(matrix_words[row_off + col], block_words[col])
            acc = field.fq_add(acc, term)
        out_words[row] = acc


fn load_z_channel_block_words(
    z_words: UnsafePointer[UInt64],
    z_len: Int,
    block_idx: Int,
    imag_channel: Bool,
    out_words: UnsafePointer[mut=True, UInt64],
):
    var base = block_idx * D_WIDTH
    for i in range(D_WIDTH):
        var z_idx = base + i
        if z_idx < z_len:
            var channel_off = z_idx * 2
            if imag_channel:
                out_words[i] = z_words[channel_off + 1]
            else:
                out_words[i] = z_words[channel_off]
        else:
            out_words[i] = 0


fn superneo_row_dot_blocks_words(
    session: UInt64,
    bar_blocks_words: UnsafePointer[UInt64],
    num_blocks: UInt64,
    z_words: UnsafePointer[UInt64],
    z_len: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
):
    var num_blocks_int = Int(num_blocks)
    if num_blocks_int <= 0:
        out_words[0] = 0
        out_words[1] = 0
        return
    if not session_prefers_gpu(session):
        superneo_row_dot_blocks_cpu_words(bar_blocks_words, num_blocks, z_words, z_len, out_words)
        return
    try:
        superneo_row_dot_blocks_gpu_words(session, bar_blocks_words, num_blocks_int, z_words, Int(z_len), out_words)
    except:
        superneo_row_dot_blocks_cpu_words(bar_blocks_words, num_blocks, z_words, z_len, out_words)


fn superneo_row_dot_blocks_cpu_words(
    bar_blocks_words: UnsafePointer[UInt64],
    num_blocks: UInt64,
    z_words: UnsafePointer[UInt64],
    z_len: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
):
    var bar_block = alloc[UInt64](D_WIDTH)
    var z_re_block = alloc[UInt64](D_WIDTH)
    var z_im_block = alloc[UInt64](D_WIDTH)
    var acc_re = UInt64(0)
    var acc_im = UInt64(0)
    var z_len_int = Int(z_len)

    for blk in range(Int(num_blocks)):
        var block_off = blk * BLOCK_WORDS
        for i in range(D_WIDTH):
            bar_block[i] = bar_blocks_words[block_off + i]
        load_z_channel_block_words(z_words, z_len_int, blk, False, z_re_block)
        load_z_channel_block_words(z_words, z_len_int, blk, True, z_im_block)
        acc_re = field.fq_add(acc_re, ring.rq_mul_ct_words(bar_block, z_re_block))
        acc_im = field.fq_add(acc_im, ring.rq_mul_ct_words(bar_block, z_im_block))

    out_words[0] = acc_re
    out_words[1] = acc_im
    bar_block.free()
    z_re_block.free()
    z_im_block.free()


fn z_channel_word(
    z_words: UnsafePointer[UInt64],
    z_len: Int,
    z_idx: Int,
    imag_channel: Bool,
) -> UInt64:
    if z_idx >= z_len:
        return 0
    var channel_off = z_idx * 2
    if imag_channel:
        return z_words[channel_off + 1]
    return z_words[channel_off]


fn rq_mul_ct_z_channel_words(
    lhs_words: UnsafePointer[UInt64],
    z_words: UnsafePointer[UInt64],
    z_len: Int,
    block_idx: Int,
    imag_channel: Bool,
) -> UInt64:
    var tmp_words = InlineArray[UInt64, 107](fill=0)
    var block_base = block_idx * D_WIDTH

    for i in range(D_WIDTH):
        var ai = lhs_words[i]
        for j in range(D_WIDTH):
            var rhs_word = z_channel_word(z_words, z_len, block_base + j, imag_channel)
            var term = field.fq_mul(ai, rhs_word)
            tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)

    for i in range(106, D_WIDTH - 1, -1):
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


fn superneo_bar_block_gpu_kernel(
    matrix_words: UnsafePointer[mut=True, UInt64],
    block_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
):
    var row = Int(block_idx.x * block_dim.x + thread_idx.x)
    if row >= D_WIDTH:
        return
    var acc = UInt64(0)
    var row_off = row * D_WIDTH
    for col in range(D_WIDTH):
        var term = field.fq_mul(matrix_words[row_off + col], block_words[col])
        acc = field.fq_add(acc, term)
    out_words[row] = acc


fn superneo_bar_block_gpu_kernel_sig(
    matrix_words: UnsafePointer[UInt64, MutAnyOrigin],
    block_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
):
    pass


fn superneo_row_dot_blocks_gpu_kernel(
    bar_blocks_words: UnsafePointer[mut=True, UInt64],
    z_words: UnsafePointer[mut=True, UInt64],
    z_len: Int,
    partial_words: UnsafePointer[mut=True, UInt64],
    num_blocks: Int,
):
    var blk = Int(block_idx.x * block_dim.x + thread_idx.x)
    if blk >= num_blocks:
        return
    var block_off = blk * BLOCK_WORDS
    partial_words[blk * 2] = rq_mul_ct_z_channel_words(bar_blocks_words + block_off, z_words, z_len, blk, False)
    partial_words[blk * 2 + 1] = rq_mul_ct_z_channel_words(bar_blocks_words + block_off, z_words, z_len, blk, True)


fn superneo_row_dot_blocks_gpu_kernel_sig(
    bar_blocks_words: UnsafePointer[UInt64, MutAnyOrigin],
    z_words: UnsafePointer[UInt64, MutAnyOrigin],
    z_len: Int,
    partial_words: UnsafePointer[UInt64, MutAnyOrigin],
    num_blocks: Int,
):
    pass


fn superneo_row_dot_blocks_reduce_gpu_kernel(
    partial_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
    num_blocks: Int,
):
    if Int(block_idx.x * block_dim.x + thread_idx.x) != 0:
        return

    var acc_re = UInt64(0)
    var acc_im = UInt64(0)
    for blk in range(num_blocks):
        acc_re = field.fq_add(acc_re, partial_words[blk * 2])
        acc_im = field.fq_add(acc_im, partial_words[blk * 2 + 1])
    out_words[0] = acc_re
    out_words[1] = acc_im


fn superneo_row_dot_blocks_reduce_gpu_kernel_sig(
    partial_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
    num_blocks: Int,
):
    pass


fn superneo_row_dot_blocks_dual_gpu_kernel(
    packed_bar_blocks_words: UnsafePointer[mut=True, UInt64],
    z_words: UnsafePointer[mut=True, UInt64],
    z_len: Int,
    partial_words: UnsafePointer[mut=True, UInt64],
    num_blocks: Int,
):
    var blk = Int(block_idx.x * block_dim.x + thread_idx.x)
    if blk >= num_blocks:
        return
    var block_off = blk * BLOCK_WORDS
    partial_words[blk * 4] = rq_mul_ct_z_channel_words(
        packed_bar_blocks_words + block_off, z_words, z_len, blk, False
    )
    partial_words[blk * 4 + 1] = rq_mul_ct_z_channel_words(
        packed_bar_blocks_words + block_off, z_words, z_len, blk, True
    )
    partial_words[blk * 4 + 2] = rq_mul_ct_z_channel_words(
        packed_bar_blocks_words + num_blocks * BLOCK_WORDS + block_off, z_words, z_len, blk, False
    )
    partial_words[blk * 4 + 3] = rq_mul_ct_z_channel_words(
        packed_bar_blocks_words + num_blocks * BLOCK_WORDS + block_off, z_words, z_len, blk, True
    )


fn superneo_row_dot_blocks_dual_gpu_kernel_sig(
    packed_bar_blocks_words: UnsafePointer[UInt64, MutAnyOrigin],
    z_words: UnsafePointer[UInt64, MutAnyOrigin],
    z_len: Int,
    partial_words: UnsafePointer[UInt64, MutAnyOrigin],
    num_blocks: Int,
):
    pass


fn superneo_row_dot_blocks_dual_reduce_gpu_kernel(
    partial_words: UnsafePointer[mut=True, UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
    num_blocks: Int,
):
    if Int(block_idx.x * block_dim.x + thread_idx.x) != 0:
        return

    var acc_re_re = UInt64(0)
    var acc_re_im = UInt64(0)
    var acc_im_re = UInt64(0)
    var acc_im_im = UInt64(0)
    for blk in range(num_blocks):
        var off = blk * 4
        acc_re_re = field.fq_add(acc_re_re, partial_words[off])
        acc_re_im = field.fq_add(acc_re_im, partial_words[off + 1])
        acc_im_re = field.fq_add(acc_im_re, partial_words[off + 2])
        acc_im_im = field.fq_add(acc_im_im, partial_words[off + 3])
    out_words[0] = acc_re_re
    out_words[1] = acc_re_im
    out_words[2] = acc_im_re
    out_words[3] = acc_im_im


fn superneo_row_dot_blocks_dual_reduce_gpu_kernel_sig(
    partial_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
    num_blocks: Int,
):
    pass


fn destroy_session_cache(session: UInt64):
    if session <= 1:
        return
    runtime.session_state_ptr(session)[].superneo_kernel_cache_addr = 0


fn superneo_bar_block_gpu_words(
    session: UInt64,
    matrix_words: UnsafePointer[UInt64],
    block_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    if not has_accelerator():
        raise Error("superneo accelerator unavailable at compile time")
    else:
        var session_ptr = runtime.session_state_ptr(session)
        ref session_state = session_ptr[]
        session_state.ensure_superneo_buffers(MATRIX_WORDS, BLOCK_WORDS, BLOCK_WORDS)
        var ctx = session_state.accelerator_ctx.value()
        var a_host = session_state.superneo_a_host.value()
        var a_dev = session_state.superneo_a_dev.value()
        var b_host = session_state.superneo_b_host.value()
        var b_dev = session_state.superneo_b_dev.value()
        var out_host = session_state.superneo_out_host.value()
        var out_dev = session_state.superneo_out_dev.value()

        for idx in range(MATRIX_WORDS):
            a_host[idx] = matrix_words[idx]
        for idx in range(BLOCK_WORDS):
            b_host[idx] = block_words[idx]

        ctx.enqueue_copy(src_buf=a_host, dst_buf=a_dev)
        ctx.enqueue_copy(src_buf=b_host, dst_buf=b_dev)
        ctx.enqueue_function[
            superneo_bar_block_gpu_kernel, superneo_bar_block_gpu_kernel_sig
        ](
            a_dev.unsafe_ptr(),
            b_dev.unsafe_ptr(),
            out_dev.unsafe_ptr(),
            grid_dim=(D_WIDTH + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
            block_dim=GPU_BLOCK_SIZE,
        )
        ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
        ctx.synchronize()

        for idx in range(BLOCK_WORDS):
            out_words[idx] = out_host[idx]


fn superneo_row_dot_blocks_gpu_words(
    session: UInt64,
    bar_blocks_words: UnsafePointer[UInt64],
    num_blocks: Int,
    z_words: UnsafePointer[UInt64],
    z_len: Int,
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    if not has_accelerator():
        raise Error("superneo accelerator unavailable at compile time")
    else:
        var bar_word_count = num_blocks * BLOCK_WORDS
        var z_word_count = z_len * 2
        var out_word_count = 2
        var partial_word_count = num_blocks * 2
        if partial_word_count > out_word_count:
            out_word_count = partial_word_count
        var session_ptr = runtime.session_state_ptr(session)
        ref session_state = session_ptr[]
        session_state.ensure_superneo_buffers(bar_word_count, z_word_count, out_word_count)
        var ctx = session_state.accelerator_ctx.value()
        var a_host = session_state.superneo_a_host.value()
        var a_dev = session_state.superneo_a_dev.value()
        var b_host = session_state.superneo_b_host.value()
        var b_dev = session_state.superneo_b_dev.value()
        var out_host = session_state.superneo_out_host.value()
        var out_dev = session_state.superneo_out_dev.value()

        for idx in range(bar_word_count):
            a_host[idx] = bar_blocks_words[idx]
        for idx in range(z_word_count):
            b_host[idx] = z_words[idx]

        ctx.enqueue_copy(src_buf=a_host, dst_buf=a_dev)
        ctx.enqueue_copy(src_buf=b_host, dst_buf=b_dev)
        ctx.enqueue_function[
            superneo_row_dot_blocks_gpu_kernel, superneo_row_dot_blocks_gpu_kernel_sig
        ](
            a_dev.unsafe_ptr(),
            b_dev.unsafe_ptr(),
            z_len,
            out_dev.unsafe_ptr(),
            num_blocks,
            grid_dim=(num_blocks + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
            block_dim=GPU_BLOCK_SIZE,
        )
        ctx.enqueue_function[
            superneo_row_dot_blocks_reduce_gpu_kernel, superneo_row_dot_blocks_reduce_gpu_kernel_sig
        ](
            out_dev.unsafe_ptr(),
            out_dev.unsafe_ptr(),
            num_blocks,
            grid_dim=1,
            block_dim=1,
        )
        ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
        ctx.synchronize()

        out_words[0] = out_host[0]
        out_words[1] = out_host[1]


fn superneo_row_dot_blocks_dual_words(
    session: UInt64,
    re_bar_blocks_words: UnsafePointer[UInt64],
    im_bar_blocks_words: UnsafePointer[UInt64],
    num_blocks: UInt64,
    z_words: UnsafePointer[UInt64],
    z_len: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
):
    var num_blocks_int = Int(num_blocks)
    if num_blocks_int <= 0:
        for idx in range(4):
            out_words[idx] = 0
        return
    if not session_prefers_gpu(session):
        superneo_row_dot_blocks_words(session, re_bar_blocks_words, num_blocks, z_words, z_len, out_words)
        superneo_row_dot_blocks_words(session, im_bar_blocks_words, num_blocks, z_words, z_len, out_words + 2)
        return
    try:
        superneo_row_dot_blocks_dual_gpu_words(
            session,
            re_bar_blocks_words,
            im_bar_blocks_words,
            num_blocks_int,
            z_words,
            Int(z_len),
            out_words,
        )
    except:
        superneo_row_dot_blocks_words(session, re_bar_blocks_words, num_blocks, z_words, z_len, out_words)
        superneo_row_dot_blocks_words(session, im_bar_blocks_words, num_blocks, z_words, z_len, out_words + 2)


fn superneo_row_dot_blocks_dual_gpu_words(
    session: UInt64,
    re_bar_blocks_words: UnsafePointer[UInt64],
    im_bar_blocks_words: UnsafePointer[UInt64],
    num_blocks: Int,
    z_words: UnsafePointer[UInt64],
    z_len: Int,
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    if not has_accelerator():
        raise Error("superneo accelerator unavailable at compile time")
    else:
        var bar_word_count = num_blocks * BLOCK_WORDS
        var packed_bar_word_count = bar_word_count * 2
        var z_word_count = z_len * 2
        var out_word_count = num_blocks * 4
        if out_word_count < 4:
            out_word_count = 4
        var session_ptr = runtime.session_state_ptr(session)
        ref session_state = session_ptr[]
        session_state.ensure_superneo_buffers(packed_bar_word_count, z_word_count, out_word_count)
        var ctx = session_state.accelerator_ctx.value()
        var a_host = session_state.superneo_a_host.value()
        var a_dev = session_state.superneo_a_dev.value()
        var b_host = session_state.superneo_b_host.value()
        var b_dev = session_state.superneo_b_dev.value()
        var out_host = session_state.superneo_out_host.value()
        var out_dev = session_state.superneo_out_dev.value()

        for idx in range(bar_word_count):
            a_host[idx] = re_bar_blocks_words[idx]
            a_host[bar_word_count + idx] = im_bar_blocks_words[idx]
        for idx in range(z_word_count):
            b_host[idx] = z_words[idx]

        ctx.enqueue_copy(src_buf=a_host, dst_buf=a_dev)
        ctx.enqueue_copy(src_buf=b_host, dst_buf=b_dev)
        ctx.enqueue_function[
            superneo_row_dot_blocks_dual_gpu_kernel, superneo_row_dot_blocks_dual_gpu_kernel_sig
        ](
            a_dev.unsafe_ptr(),
            b_dev.unsafe_ptr(),
            z_len,
            out_dev.unsafe_ptr(),
            num_blocks,
            grid_dim=(num_blocks + GPU_BLOCK_SIZE - 1) // GPU_BLOCK_SIZE,
            block_dim=GPU_BLOCK_SIZE,
        )
        ctx.enqueue_function[
            superneo_row_dot_blocks_dual_reduce_gpu_kernel, superneo_row_dot_blocks_dual_reduce_gpu_kernel_sig
        ](
            out_dev.unsafe_ptr(),
            out_dev.unsafe_ptr(),
            num_blocks,
            grid_dim=1,
            block_dim=1,
        )
        ctx.enqueue_copy(src_buf=out_dev, dst_buf=out_host)
        ctx.synchronize()
        for idx in range(4):
            out_words[idx] = out_host[idx]


fn session_prefers_gpu(session: UInt64) -> Bool:
    var api = runtime.session_api(session)
    if api == UInt32(DEVICE_API_CPU):
        return False
    return runtime.session_prefers_gpu(session) and (
        api == UInt32(DEVICE_API_METAL) or api == UInt32(DEVICE_API_CUDA)
    )
