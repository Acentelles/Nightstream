from memory import UnsafePointer, alloc
from nightstream_gpu import field, ring


comptime D_WIDTH = 54
comptime BLOCK_WORDS = 54
comptime MATRIX_WORDS = D_WIDTH * D_WIDTH


fn scaffold_ready() -> Bool:
    return True


fn superneo_bar_block_from_matrix_words(
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
