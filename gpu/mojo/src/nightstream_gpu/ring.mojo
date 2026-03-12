from memory import UnsafePointer, alloc
from nightstream_gpu import field


comptime D_WIDTH = 54
comptime TMP_WIDTH = 107


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
    var tmp_words = alloc[UInt64](TMP_WIDTH)
    for i in range(TMP_WIDTH):
        tmp_words[i] = 0

    for i in range(D_WIDTH):
        var ai = lhs_words[i]
        for j in range(D_WIDTH):
            var term = field.fq_mul(ai, rhs_words[j])
            tmp_words[i + j] = field.fq_add(tmp_words[i + j], term)

    reduce_mod_phi_81_words(tmp_words)
    for i in range(D_WIDTH):
        out_words[i] = tmp_words[i]
    tmp_words.free()


fn rq_ct_words(words: UnsafePointer[UInt64]) -> UInt64:
    return words[0]


fn rq_mul_ct_words(lhs_words: UnsafePointer[UInt64], rhs_words: UnsafePointer[UInt64]) -> UInt64:
    var out_words = alloc[UInt64](D_WIDTH)
    rq_mul_words(lhs_words, rhs_words, out_words)
    var constant_term = out_words[0]
    out_words.free()
    return constant_term
