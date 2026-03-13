from gpu.host import DeviceContext
from gpu import block_dim, block_idx, thread_idx
from memory import UnsafePointer, alloc
from nightstream_gpu import field, ring, runtime


comptime D_WIDTH = 54
comptime BLOCK_WORDS = 54
comptime MATRIX_WORDS = D_WIDTH * D_WIDTH
comptime GPU_BLOCK_SIZE = 64
comptime DEVICE_API_CPU = 0
comptime DEVICE_API_METAL = 1
comptime DEVICE_API_CUDA = 2
comptime DEVICE_API_HIP = 3
comptime SuperneoBarBlockKernelT = type_of(
    DeviceContext().compile_function[
        superneo_bar_block_gpu_kernel, superneo_bar_block_gpu_kernel_sig
    ]()
)


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


struct SuperneoGpuCache(Movable):
    var bar_block_kernel: SuperneoBarBlockKernelT

    fn __init__(out self, ctx: DeviceContext) raises:
        self.bar_block_kernel = ctx.compile_function[
            superneo_bar_block_gpu_kernel, superneo_bar_block_gpu_kernel_sig
        ]()


fn superneo_gpu_cache_ptr(session: UInt64) -> UnsafePointer[SuperneoGpuCache, MutAnyOrigin]:
    var addr = runtime.session_state_ptr(session)[].superneo_kernel_cache_addr
    return UnsafePointer[SuperneoGpuCache, MutAnyOrigin](unsafe_from_address=Int(addr))


fn ensure_superneo_gpu_cache(session: UInt64) raises:
    ref session_state = runtime.session_state_ptr(session)[]
    if session_state.superneo_kernel_cache_addr != 0:
        return

    var ptr = alloc[SuperneoGpuCache](1)
    ptr.init_pointee_move(SuperneoGpuCache(session_state.accelerator_ctx.value()))
    session_state.superneo_kernel_cache_addr = UInt64(Int(ptr))


fn destroy_session_cache(session: UInt64):
    if session <= 1:
        return
    ref session_state = runtime.session_state_ptr(session)[]
    if session_state.superneo_kernel_cache_addr == 0:
        return

    var ptr = superneo_gpu_cache_ptr(session)
    ptr.destroy_pointee()
    ptr.free()
    session_state.superneo_kernel_cache_addr = 0


fn superneo_bar_block_gpu_words(
    session: UInt64,
    matrix_words: UnsafePointer[UInt64],
    block_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
) raises:
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    session_state.ensure_superneo_buffers(MATRIX_WORDS, BLOCK_WORDS, BLOCK_WORDS)
    ensure_superneo_gpu_cache(session)
    var ctx = session_state.accelerator_ctx.value()
    var a_host = session_state.superneo_a_host.value()
    var a_dev = session_state.superneo_a_dev.value()
    var b_host = session_state.superneo_b_host.value()
    var b_dev = session_state.superneo_b_dev.value()
    var out_host = session_state.superneo_out_host.value()
    var out_dev = session_state.superneo_out_dev.value()
    ref cache = superneo_gpu_cache_ptr(session)[]

    for idx in range(MATRIX_WORDS):
        a_host[idx] = matrix_words[idx]
    for idx in range(BLOCK_WORDS):
        b_host[idx] = block_words[idx]

    ctx.enqueue_copy(src_buf=a_host, dst_buf=a_dev)
    ctx.enqueue_copy(src_buf=b_host, dst_buf=b_dev)
    ctx.enqueue_function(
        cache.bar_block_kernel,
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
    var pair_word_count = num_blocks * BLOCK_WORDS
    var z_re_words = alloc[UInt64](pair_word_count)
    var z_im_words = alloc[UInt64](pair_word_count)
    var slot_offsets_words = alloc[UInt64](2)
    var sum_re_words = alloc[UInt64](BLOCK_WORDS)
    var sum_im_words = alloc[UInt64](BLOCK_WORDS)
    for blk in range(num_blocks):
        var block_off = blk * BLOCK_WORDS
        load_z_channel_block_words(z_words, z_len, blk, False, z_re_words + block_off)
        load_z_channel_block_words(z_words, z_len, blk, True, z_im_words + block_off)
    slot_offsets_words[0] = 0
    slot_offsets_words[1] = UInt64(num_blocks)
    ring.rq_accumulate_batch_words(
        session,
        bar_blocks_words,
        z_re_words,
        slot_offsets_words,
        UInt64(1),
        sum_re_words,
    )
    ring.rq_accumulate_batch_words(
        session,
        bar_blocks_words,
        z_im_words,
        slot_offsets_words,
        UInt64(1),
        sum_im_words,
    )
    out_words[0] = ring.rq_ct_words(sum_re_words)
    out_words[1] = ring.rq_ct_words(sum_im_words)
    z_re_words.free()
    z_im_words.free()
    slot_offsets_words.free()
    sum_re_words.free()
    sum_im_words.free()


fn session_prefers_gpu(session: UInt64) -> Bool:
    var api = runtime.session_api(session)
    if api == UInt32(DEVICE_API_CPU):
        return False
    return runtime.session_prefers_gpu(session) and (
        api == UInt32(DEVICE_API_METAL) or api == UInt32(DEVICE_API_CUDA)
    )
