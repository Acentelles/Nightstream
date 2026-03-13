from gpu.host import DeviceBuffer, DeviceContext, HostBuffer
from gpu import block_dim, block_idx, thread_idx
from memory import UnsafePointer, alloc
from nightstream_gpu import field, runtime


comptime SPLIT_NC_SNAPSHOT_MAGIC = UInt64(0x4E53504C49544E43)
comptime SPLIT_NC_SNAPSHOT_VERSION = UInt64(1)
comptime SPLIT_NC_FE_ROW_V1 = UInt64(1)
comptime SPLIT_NC_NC_COL_V1 = UInt64(2)
comptime FE_HEADER_WORDS = 16
comptime NC_HEADER_WORDS = 13
comptime D_WIDTH = 54
comptime SUMCHECK_GPU_BLOCK_SIZE = 64
comptime SUMCHECK_GPU_MIN_TASKS = 256
comptime SUMCHECK_PAIR_GROUP = 128
comptime DEVICE_API_CPU = 0
comptime DEVICE_API_METAL = 1
comptime DEVICE_API_CUDA = 2
comptime DEVICE_API_HIP = 3
comptime FePartialKernelT = type_of(
    DeviceContext().compile_function[fe_partial_group_gpu_kernel, fe_partial_group_gpu_kernel_sig]()
)
comptime NcPartialKernelT = type_of(
    DeviceContext().compile_function[nc_partial_group_gpu_kernel, nc_partial_group_gpu_kernel_sig]()
)


struct KVal(Copyable, ImplicitlyCopyable, Movable):
    var re: UInt64
    var im: UInt64

    fn __init__(out self, re: UInt64, im: UInt64):
        self.re = re
        self.im = im

    fn __copyinit__(out self, existing: Self):
        self.re = existing.re
        self.im = existing.im


fn scaffold_ready() -> Bool:
    return True


fn k_zero() -> KVal:
    return KVal(0, 0)


fn k_one() -> KVal:
    return KVal(1, 0)


fn k_is_zero(x: KVal) -> Bool:
    return x.re == 0 and x.im == 0


fn k_canonicalize(x: KVal) -> KVal:
    return KVal(field.fq_canonicalize(x.re), field.fq_canonicalize(x.im))


fn k_add(a: KVal, b: KVal) -> KVal:
    var lhs = k_canonicalize(a)
    var rhs = k_canonicalize(b)
    return KVal(field.fq_add(lhs.re, rhs.re), field.fq_add(lhs.im, rhs.im))


fn k_sub(a: KVal, b: KVal) -> KVal:
    var lhs = k_canonicalize(a)
    var rhs = k_canonicalize(b)
    return KVal(field.fq_sub(lhs.re, rhs.re), field.fq_sub(lhs.im, rhs.im))


fn k_mul(a: KVal, b: KVal) -> KVal:
    var lhs = k_canonicalize(a)
    var rhs = k_canonicalize(b)
    var ac = field.fq_mul(lhs.re, rhs.re)
    var bd = field.fq_mul(lhs.im, rhs.im)
    var ad = field.fq_mul(lhs.re, rhs.im)
    var bc = field.fq_mul(lhs.im, rhs.re)
    var delta_bd = field.fq_mul(UInt64(7), bd)
    return KVal(field.fq_add(ac, delta_bd), field.fq_add(ad, bc))


fn k_pow_small(x: KVal, exp: UInt64) -> KVal:
    if exp == 0:
        return k_one()
    var acc = x
    for _ in range(Int(exp - 1)):
        acc = k_mul(acc, x)
    return acc


fn k_interp(lo: KVal, hi: KVal, x: KVal, one_minus: KVal) -> KVal:
    return k_add(k_mul(k_canonicalize(one_minus), k_canonicalize(lo)), k_mul(k_canonicalize(x), k_canonicalize(hi)))


fn k_store(words: UnsafePointer[mut=True, UInt64], word_idx: Int, value: KVal):
    var canonical = k_canonicalize(value)
    words[word_idx] = canonical.re
    words[word_idx + 1] = canonical.im


fn k_load(words: UnsafePointer[UInt64], word_idx: Int) -> KVal:
    return k_canonicalize(KVal(words[word_idx], words[word_idx + 1]))


fn session_prefers_gpu(session: UInt64) -> Bool:
    if not runtime.session_prefers_gpu(session):
        return False
    var api = runtime.session_api(session)
    return api == UInt32(DEVICE_API_METAL) or api == UInt32(DEVICE_API_CUDA)


fn grid_dim_for(num_tasks: Int) -> Int:
    return (num_tasks + SUMCHECK_GPU_BLOCK_SIZE - 1) // SUMCHECK_GPU_BLOCK_SIZE


fn read_snapshot_word(snapshot_ptr: UnsafePointer[UInt64], word_idx: Int) -> UInt64:
    return snapshot_ptr[word_idx]


fn read_snapshot_k(snapshot_ptr: UnsafePointer[UInt64], word_idx: Int) -> KVal:
    return k_canonicalize(KVal(
        read_snapshot_word(snapshot_ptr, word_idx),
        read_snapshot_word(snapshot_ptr, word_idx + 1),
    ))


fn load_point(points_ptr: UnsafePointer[UInt64], point_idx: Int) -> KVal:
    return k_canonicalize(KVal(points_ptr[point_idx * 2], points_ptr[point_idx * 2 + 1]))


fn store_out(out_ptr: UnsafePointer[mut=True, UInt64], point_idx: Int, value: KVal):
    out_ptr[point_idx * 2] = value.re
    out_ptr[point_idx * 2 + 1] = value.im


fn snapshot_kind(snapshot_ptr: UnsafePointer[UInt64], snapshot_len: Int) -> UInt64:
    var normalized_len = snapshot_len
    if normalized_len < 24 or normalized_len % 8 != 0:
        normalized_len = normalized_len * 8
    if normalized_len < 24 or normalized_len % 8 != 0:
        return UInt64(0)
    if read_snapshot_word(snapshot_ptr, 0) != SPLIT_NC_SNAPSHOT_MAGIC:
        return UInt64(0)
    if read_snapshot_word(snapshot_ptr, 1) != SPLIT_NC_SNAPSHOT_VERSION:
        return UInt64(0)
    return read_snapshot_word(snapshot_ptr, 2)


fn snapshot_status(snapshot_ptr: UnsafePointer[UInt64], snapshot_len: Int, expected_kind: UInt64) -> Int32:
    var normalized_len = snapshot_len
    if normalized_len < 24 or normalized_len % 8 != 0:
        normalized_len = normalized_len * 8
    if normalized_len < 24 or normalized_len % 8 != 0:
        return -10
    if read_snapshot_word(snapshot_ptr, 0) != SPLIT_NC_SNAPSHOT_MAGIC:
        return -11
    if read_snapshot_word(snapshot_ptr, 1) != SPLIT_NC_SNAPSHOT_VERSION:
        return -12
    if read_snapshot_word(snapshot_ptr, 2) != expected_kind:
        return -13
    var snapshot_word_count = normalized_len // 8
    if expected_kind == SPLIT_NC_FE_ROW_V1:
        return validate_fe_snapshot_layout(snapshot_ptr, snapshot_word_count)
    if expected_kind == SPLIT_NC_NC_COL_V1:
        return validate_nc_snapshot_layout(snapshot_ptr, snapshot_word_count)
    return 0


fn normalized_snapshot_len_bytes(snapshot_len: Int) -> Int:
    var normalized_len = snapshot_len
    if normalized_len < 24 or normalized_len % 8 != 0:
        normalized_len = normalized_len * 8
    return normalized_len


fn normalized_snapshot_word_count(snapshot_len: Int) -> Int:
    return normalized_snapshot_len_bytes(snapshot_len) // 8


fn checked_mul_words(lhs: Int, rhs: Int, limit: Int) -> Int:
    if lhs < 0 or rhs < 0:
        return -1
    if lhs == 0 or rhs == 0:
        return 0
    if lhs > limit // rhs:
        return -1
    return lhs * rhs


fn checked_add_words(offset: Int, count: Int, limit: Int) -> Int:
    if offset < 0 or count < 0:
        return -1
    if offset > limit:
        return -1
    if count > limit - offset:
        return -1
    return offset + count


fn validate_fe_snapshot_layout(snapshot_ptr: UnsafePointer[UInt64], snapshot_word_count: Int) -> Int32:
    if snapshot_word_count < FE_HEADER_WORDS:
        return -10

    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    var eq_beta_len = Int(read_snapshot_word(snapshot_ptr, 6))
    var eq_r_inputs_len = Int(read_snapshot_word(snapshot_ptr, 7))
    var gamma_pow_len = Int(read_snapshot_word(snapshot_ptr, 8))
    var term_count = Int(read_snapshot_word(snapshot_ptr, 9))
    var num_mcs = Int(read_snapshot_word(snapshot_ptr, 10))
    var num_vars = Int(read_snapshot_word(snapshot_ptr, 11))
    var table_len = Int(read_snapshot_word(snapshot_ptr, 12))
    var eval_len = Int(read_snapshot_word(snapshot_ptr, 13))

    if cur_len < 0 or cur_len % 2 != 0:
        return -14
    if eq_beta_len < cur_len:
        return -14
    if eq_r_inputs_len > 0 and eq_r_inputs_len < cur_len:
        return -14
    if table_len < cur_len:
        return -14
    if eval_len > 0 and eval_len < cur_len:
        return -14

    var eq_beta_words = checked_mul_words(eq_beta_len, 2, snapshot_word_count)
    if eq_beta_words < 0:
        return -14
    var eq_beta_end = checked_add_words(FE_HEADER_WORDS, eq_beta_words, snapshot_word_count)
    if eq_beta_end < 0:
        return -14

    var eq_r_inputs_words = checked_mul_words(eq_r_inputs_len, 2, snapshot_word_count)
    if eq_r_inputs_words < 0:
        return -14
    var eq_r_inputs_end = checked_add_words(eq_beta_end, eq_r_inputs_words, snapshot_word_count)
    if eq_r_inputs_end < 0:
        return -14

    var gamma_pow_words = checked_mul_words(gamma_pow_len, 2, snapshot_word_count)
    if gamma_pow_words < 0:
        return -14
    var terms_off = checked_add_words(eq_r_inputs_end, gamma_pow_words, snapshot_word_count)
    if terms_off < 0:
        return -14

    for _ in range(term_count):
        if checked_add_words(terms_off, 3, snapshot_word_count) < 0:
            return -14
        var vars_len = Int(read_snapshot_word(snapshot_ptr, terms_off + 2))
        if vars_len < 0:
            return -14
        var entry_words = checked_mul_words(vars_len, 2, snapshot_word_count)
        if entry_words < 0:
            return -14
        var entry_off = terms_off + 3
        var next_terms_off = checked_add_words(entry_off, entry_words, snapshot_word_count)
        if next_terms_off < 0:
            return -14
        for var_idx in range(vars_len):
            var var_pos = Int(read_snapshot_word(snapshot_ptr, entry_off + var_idx * 2))
            if var_pos < 0 or var_pos >= num_vars:
                return -14
        terms_off = next_terms_off

    var table_count = checked_mul_words(num_mcs, num_vars, snapshot_word_count)
    if table_count < 0:
        return -14
    var table_entries = checked_mul_words(table_count, table_len, snapshot_word_count)
    if table_entries < 0:
        return -14
    var table_words = checked_mul_words(table_entries, 2, snapshot_word_count)
    if table_words < 0:
        return -14
    var tables_end = checked_add_words(terms_off, table_words, snapshot_word_count)
    if tables_end < 0:
        return -14

    var eval_words = checked_mul_words(eval_len, 2, snapshot_word_count)
    if eval_words < 0:
        return -14
    if checked_add_words(tables_end, eval_words, snapshot_word_count) < 0:
        return -14

    return 0


fn validate_nc_snapshot_layout(snapshot_ptr: UnsafePointer[UInt64], snapshot_word_count: Int) -> Int32:
    if snapshot_word_count < NC_HEADER_WORDS:
        return -10

    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    var eq_beta_len = Int(read_snapshot_word(snapshot_ptr, 6))
    var num_tables = Int(read_snapshot_word(snapshot_ptr, 7))
    var table_len = Int(read_snapshot_word(snapshot_ptr, 8))
    var d_width = Int(read_snapshot_word(snapshot_ptr, 9))
    var weights_tables = Int(read_snapshot_word(snapshot_ptr, 10))
    var weights_width = Int(read_snapshot_word(snapshot_ptr, 11))
    var range_len = Int(read_snapshot_word(snapshot_ptr, 12))

    if cur_len < 0 or cur_len % 2 != 0:
        return -14
    if eq_beta_len < cur_len or table_len < cur_len:
        return -14
    if weights_tables < num_tables or weights_width < d_width:
        return -14

    var eq_beta_words = checked_mul_words(eq_beta_len, 2, snapshot_word_count)
    if eq_beta_words < 0:
        return -14
    var digits_off = checked_add_words(NC_HEADER_WORDS, eq_beta_words, snapshot_word_count)
    if digits_off < 0:
        return -14

    var digit_tables = checked_mul_words(num_tables, table_len, snapshot_word_count)
    if digit_tables < 0:
        return -14
    var digit_rows = checked_mul_words(digit_tables, d_width, snapshot_word_count)
    if digit_rows < 0:
        return -14
    var digit_words = checked_mul_words(digit_rows, 2, snapshot_word_count)
    if digit_words < 0:
        return -14
    var weights_off = checked_add_words(digits_off, digit_words, snapshot_word_count)
    if weights_off < 0:
        return -14

    var weights_entries = checked_mul_words(weights_tables, weights_width, snapshot_word_count)
    if weights_entries < 0:
        return -14
    var weights_words = checked_mul_words(weights_entries, 2, snapshot_word_count)
    if weights_words < 0:
        return -14
    var range_off = checked_add_words(weights_off, weights_words, snapshot_word_count)
    if range_off < 0:
        return -14

    var range_words = checked_mul_words(range_len, 2, snapshot_word_count)
    if range_words < 0:
        return -14
    if checked_add_words(range_off, range_words, snapshot_word_count) < 0:
        return -14

    return 0


fn write_snapshot_word(
    snapshot_ptr: UnsafePointer[mut=True, UInt64],
    word_idx: Int,
    value: UInt64,
):
    snapshot_ptr[word_idx] = value


fn write_snapshot_k(
    snapshot_ptr: UnsafePointer[mut=True, UInt64],
    word_idx: Int,
    value: KVal,
):
    snapshot_ptr[word_idx] = value.re
    snapshot_ptr[word_idx + 1] = value.im


fn fold_k_table_in_place(
    snapshot_ptr: UnsafePointer[mut=True, UInt64],
    word_offset: Int,
    len: Int,
    challenge: KVal,
):
    var half = len // 2
    var one_minus = k_sub(k_one(), challenge)
    for i in range(half):
        var lo = k_load(snapshot_ptr, word_offset + (2 * i) * 2)
        var hi = k_load(snapshot_ptr, word_offset + ((2 * i + 1) * 2))
        write_snapshot_k(
            snapshot_ptr,
            word_offset + i * 2,
            k_interp(lo, hi, challenge, one_minus),
        )


fn apply_fe_snapshot_fold_in_place(
    snapshot_ptr: UnsafePointer[mut=True, UInt64],
    snapshot_word_count: Int,
    challenge: KVal,
) -> Int32:
    var status = validate_fe_snapshot_layout(snapshot_ptr, snapshot_word_count)
    if status != 0:
        return status

    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    if cur_len < 2:
        return 0
    var eq_beta_len = Int(read_snapshot_word(snapshot_ptr, 6))
    var eq_r_inputs_len = Int(read_snapshot_word(snapshot_ptr, 7))
    var gamma_pow_len = Int(read_snapshot_word(snapshot_ptr, 8))
    var term_count = Int(read_snapshot_word(snapshot_ptr, 9))
    var num_mcs = Int(read_snapshot_word(snapshot_ptr, 10))
    var num_vars = Int(read_snapshot_word(snapshot_ptr, 11))
    var table_len = Int(read_snapshot_word(snapshot_ptr, 12))
    var eval_len = Int(read_snapshot_word(snapshot_ptr, 13))

    var eq_beta_off = FE_HEADER_WORDS
    var eq_r_inputs_off = eq_beta_off + (eq_beta_len * 2)
    var gamma_pow_off = eq_r_inputs_off + (eq_r_inputs_len * 2)
    var terms_off = gamma_pow_off + (gamma_pow_len * 2)
    for _ in range(term_count):
        var vars_len = Int(read_snapshot_word(snapshot_ptr, terms_off + 2))
        terms_off = terms_off + 3 + (vars_len * 2)
    var tables_off = terms_off
    var eval_off = tables_off + (num_mcs * num_vars * table_len * 2)

    fold_k_table_in_place(snapshot_ptr, eq_beta_off, cur_len, challenge)
    if eq_r_inputs_len > 0:
        fold_k_table_in_place(snapshot_ptr, eq_r_inputs_off, cur_len, challenge)
    for table_idx in range(num_mcs * num_vars):
        fold_k_table_in_place(
            snapshot_ptr,
            tables_off + table_idx * table_len * 2,
            cur_len,
            challenge,
        )
    if eval_len > 0:
        fold_k_table_in_place(snapshot_ptr, eval_off, cur_len, challenge)
    write_snapshot_word(snapshot_ptr, 5, UInt64(cur_len // 2))
    return 0


fn apply_nc_snapshot_fold_in_place(
    snapshot_ptr: UnsafePointer[mut=True, UInt64],
    snapshot_word_count: Int,
    challenge: KVal,
) -> Int32:
    var status = validate_nc_snapshot_layout(snapshot_ptr, snapshot_word_count)
    if status != 0:
        return status

    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    if cur_len < 2:
        return 0
    var eq_beta_len = Int(read_snapshot_word(snapshot_ptr, 6))
    var num_tables = Int(read_snapshot_word(snapshot_ptr, 7))
    var table_len = Int(read_snapshot_word(snapshot_ptr, 8))
    var d_width = Int(read_snapshot_word(snapshot_ptr, 9))

    var eq_beta_off = NC_HEADER_WORDS
    var digits_off = eq_beta_off + (eq_beta_len * 2)
    var one_minus = k_sub(k_one(), challenge)

    fold_k_table_in_place(snapshot_ptr, eq_beta_off, cur_len, challenge)
    for table_idx in range(num_tables):
        for rho in range(d_width):
            for i in range(cur_len // 2):
                var lo = k_load(
                    snapshot_ptr,
                    digits_off + ((table_idx * table_len + (2 * i)) * d_width + rho) * 2,
                )
                var hi = k_load(
                    snapshot_ptr,
                    digits_off + ((table_idx * table_len + (2 * i + 1)) * d_width + rho) * 2,
                )
                write_snapshot_k(
                    snapshot_ptr,
                    digits_off + ((table_idx * table_len + i) * d_width + rho) * 2,
                    k_interp(lo, hi, challenge, one_minus),
                )
    write_snapshot_word(snapshot_ptr, 5, UInt64(cur_len // 2))
    return 0


fn fe_terms_offset(snapshot_ptr: UnsafePointer[UInt64]) -> Int:
    var eq_beta_len = Int(read_snapshot_word(snapshot_ptr, 6))
    var eq_r_inputs_len = Int(read_snapshot_word(snapshot_ptr, 7))
    var gamma_pow_len = Int(read_snapshot_word(snapshot_ptr, 8))
    return FE_HEADER_WORDS + ((eq_beta_len + eq_r_inputs_len + gamma_pow_len) * 2)


fn fe_tables_offset(snapshot_ptr: UnsafePointer[UInt64]) -> Int:
    var term_count = Int(read_snapshot_word(snapshot_ptr, 9))
    var offset = fe_terms_offset(snapshot_ptr)
    for _ in range(term_count):
        var vars_len = Int(read_snapshot_word(snapshot_ptr, offset + 2))
        offset = offset + 3 + (vars_len * 2)
    return offset


fn fe_eval_one(snapshot_ptr: UnsafePointer[UInt64], x: KVal) -> KVal:
    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    var tail_len = cur_len // 2
    var total = k_zero()
    for t in range(tail_len):
        total = k_add(total, fe_eval_pair(snapshot_ptr, x, t))
    return total


fn fe_eval_pair(snapshot_ptr: UnsafePointer[UInt64], x: KVal, t: Int) -> KVal:
    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    var eq_beta_len = Int(read_snapshot_word(snapshot_ptr, 6))
    var eq_r_inputs_len = Int(read_snapshot_word(snapshot_ptr, 7))
    var gamma_pow_len = Int(read_snapshot_word(snapshot_ptr, 8))
    var term_count = Int(read_snapshot_word(snapshot_ptr, 9))
    var num_mcs = Int(read_snapshot_word(snapshot_ptr, 10))
    var num_vars = Int(read_snapshot_word(snapshot_ptr, 11))
    var table_len = Int(read_snapshot_word(snapshot_ptr, 12))
    var eval_len = Int(read_snapshot_word(snapshot_ptr, 13))
    var gamma_to_k = read_snapshot_k(snapshot_ptr, 14)

    var eq_beta_off = FE_HEADER_WORDS
    var eq_r_inputs_off = eq_beta_off + (eq_beta_len * 2)
    var gamma_pow_off = eq_r_inputs_off + (eq_r_inputs_len * 2)
    var tables_off = fe_tables_offset(snapshot_ptr)
    var eval_off = tables_off + (num_mcs * num_vars * table_len * 2)

    var one_minus = k_sub(k_one(), x)
    if t >= cur_len // 2:
        return k_zero()
    var pair_idx = 2 * t
    var eq_beta = k_interp(
        read_snapshot_k(snapshot_ptr, eq_beta_off + (pair_idx * 2)),
        read_snapshot_k(snapshot_ptr, eq_beta_off + ((pair_idx + 1) * 2)),
        x,
        one_minus,
    )
    var f_prime = k_zero()

    for mcs_idx in range(num_mcs):
        var f_i = k_zero()
        var term_off = gamma_pow_off + (gamma_pow_len * 2)
        for _ in range(term_count):
            var acc = read_snapshot_k(snapshot_ptr, term_off)
            var vars_len = Int(read_snapshot_word(snapshot_ptr, term_off + 2))
            var entry_off = term_off + 3
            for _ in range(vars_len):
                var var_pos = Int(read_snapshot_word(snapshot_ptr, entry_off))
                var exp = read_snapshot_word(snapshot_ptr, entry_off + 1)
                var table_off = tables_off + (((mcs_idx * num_vars + var_pos) * table_len + pair_idx) * 2)
                var xi = k_interp(
                    read_snapshot_k(snapshot_ptr, table_off),
                    read_snapshot_k(snapshot_ptr, table_off + 2),
                    x,
                    one_minus,
                )
                acc = k_mul(acc, k_pow_small(xi, exp))
                entry_off = entry_off + 2
            f_i = k_add(f_i, acc)
            term_off = entry_off

        var gamma = k_one()
        if mcs_idx < gamma_pow_len:
            gamma = read_snapshot_k(snapshot_ptr, gamma_pow_off + (mcs_idx * 2))
        f_prime = k_add(f_prime, k_mul(gamma, f_i))

    var acc = k_mul(eq_beta, f_prime)
    if eq_r_inputs_len > 0 and eval_len > 0:
        var eq_r = k_interp(
            read_snapshot_k(snapshot_ptr, eq_r_inputs_off + (pair_idx * 2)),
            read_snapshot_k(snapshot_ptr, eq_r_inputs_off + ((pair_idx + 1) * 2)),
            x,
            one_minus,
        )
        if not k_is_zero(eq_r):
            var eval_val = k_interp(
                read_snapshot_k(snapshot_ptr, eval_off + (pair_idx * 2)),
                read_snapshot_k(snapshot_ptr, eval_off + ((pair_idx + 1) * 2)),
                x,
                one_minus,
            )
            acc = k_add(acc, k_mul(eq_r, k_mul(gamma_to_k, eval_val)))
    return acc


fn range_product_cached(snapshot_ptr: UnsafePointer[UInt64], range_off: Int, range_len: Int, y: KVal) -> KVal:
    if range_len == 0:
        return y
    var y2 = k_mul(y, y)
    var prod = y
    for idx in range(range_len):
        prod = k_mul(prod, k_sub(y2, read_snapshot_k(snapshot_ptr, range_off + (idx * 2))))
    return prod


fn nc_eval_one(snapshot_ptr: UnsafePointer[UInt64], x: KVal) -> KVal:
    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    var tail_len = cur_len // 2
    var total = k_zero()
    for t in range(tail_len):
        total = k_add(total, nc_eval_pair(snapshot_ptr, x, t))
    return total


fn nc_eval_pair(snapshot_ptr: UnsafePointer[UInt64], x: KVal, t: Int) -> KVal:
    var cur_len = Int(read_snapshot_word(snapshot_ptr, 5))
    var eq_beta_len = Int(read_snapshot_word(snapshot_ptr, 6))
    var num_tables = Int(read_snapshot_word(snapshot_ptr, 7))
    var table_len = Int(read_snapshot_word(snapshot_ptr, 8))
    var d_width = Int(read_snapshot_word(snapshot_ptr, 9))
    var weights_tables = Int(read_snapshot_word(snapshot_ptr, 10))
    var weights_width = Int(read_snapshot_word(snapshot_ptr, 11))
    var range_len = Int(read_snapshot_word(snapshot_ptr, 12))

    var eq_beta_off = NC_HEADER_WORDS
    var digits_off = eq_beta_off + (eq_beta_len * 2)
    var weights_off = digits_off + (num_tables * table_len * d_width * 2)
    var range_off = weights_off + (weights_tables * weights_width * 2)

    var one_minus = k_sub(k_one(), x)
    if t >= cur_len // 2:
        return k_zero()
    var pair_idx = 2 * t
    var eq_beta = k_interp(
        read_snapshot_k(snapshot_ptr, eq_beta_off + (pair_idx * 2)),
        read_snapshot_k(snapshot_ptr, eq_beta_off + ((pair_idx + 1) * 2)),
        x,
        one_minus,
    )
    var nc_sum = k_zero()

    for table_idx in range(num_tables):
        for rho in range(d_width):
            var lo_off = digits_off + (((table_idx * table_len + pair_idx) * d_width + rho) * 2)
            var hi_off = digits_off + (((table_idx * table_len + pair_idx + 1) * d_width + rho) * 2)
            var y = k_interp(
                read_snapshot_k(snapshot_ptr, lo_off),
                read_snapshot_k(snapshot_ptr, hi_off),
                x,
                one_minus,
            )
            var weight = read_snapshot_k(snapshot_ptr, weights_off + ((table_idx * weights_width + rho) * 2))
            nc_sum = k_add(
                nc_sum,
                k_mul(weight, range_product_cached(snapshot_ptr, range_off, range_len, y)),
            )

    return k_mul(eq_beta, nc_sum)


fn fe_partial_group_gpu_kernel(
    snapshot_words: UnsafePointer[mut=True, UInt64],
    points_words: UnsafePointer[mut=True, UInt64],
    partial_words: UnsafePointer[mut=True, UInt64],
    points_len: Int,
):
    var cur_len = Int(read_snapshot_word(snapshot_words, 5))
    var tail_len = cur_len // 2
    var groups_per_point = (tail_len + SUMCHECK_PAIR_GROUP - 1) // SUMCHECK_PAIR_GROUP
    var task_idx = Int(block_idx.x * block_dim.x + thread_idx.x)
    var total_tasks = points_len * groups_per_point
    if task_idx >= total_tasks:
        return
    var point_idx = task_idx // groups_per_point
    var group_idx = task_idx % groups_per_point
    var pair_start = group_idx * SUMCHECK_PAIR_GROUP
    var pair_end = pair_start + SUMCHECK_PAIR_GROUP
    if pair_end > tail_len:
        pair_end = tail_len
    var point = load_point(points_words, point_idx)
    var acc = k_zero()
    for pair_idx in range(pair_start, pair_end):
        acc = k_add(acc, fe_eval_pair(snapshot_words, point, pair_idx))
    k_store(partial_words, task_idx * 2, acc)


fn nc_partial_group_gpu_kernel(
    snapshot_words: UnsafePointer[mut=True, UInt64],
    points_words: UnsafePointer[mut=True, UInt64],
    partial_words: UnsafePointer[mut=True, UInt64],
    points_len: Int,
):
    var cur_len = Int(read_snapshot_word(snapshot_words, 5))
    var tail_len = cur_len // 2
    var groups_per_point = (tail_len + SUMCHECK_PAIR_GROUP - 1) // SUMCHECK_PAIR_GROUP
    var task_idx = Int(block_idx.x * block_dim.x + thread_idx.x)
    var total_tasks = points_len * groups_per_point
    if task_idx >= total_tasks:
        return
    var point_idx = task_idx // groups_per_point
    var group_idx = task_idx % groups_per_point
    var pair_start = group_idx * SUMCHECK_PAIR_GROUP
    var pair_end = pair_start + SUMCHECK_PAIR_GROUP
    if pair_end > tail_len:
        pair_end = tail_len
    var point = load_point(points_words, point_idx)
    var acc = k_zero()
    for pair_idx in range(pair_start, pair_end):
        acc = k_add(acc, nc_eval_pair(snapshot_words, point, pair_idx))
    k_store(partial_words, task_idx * 2, acc)


fn fe_partial_group_gpu_kernel_sig(
    snapshot_words: UnsafePointer[UInt64, MutAnyOrigin],
    points_words: UnsafePointer[UInt64, MutAnyOrigin],
    partial_words: UnsafePointer[UInt64, MutAnyOrigin],
    points_len: Int,
):
    pass


fn nc_partial_group_gpu_kernel_sig(
    snapshot_words: UnsafePointer[UInt64, MutAnyOrigin],
    points_words: UnsafePointer[UInt64, MutAnyOrigin],
    partial_words: UnsafePointer[UInt64, MutAnyOrigin],
    points_len: Int,
):
    pass


struct SumcheckGpuCache(Movable):
    var fe_kernel: FePartialKernelT
    var nc_kernel: NcPartialKernelT

    fn __init__(out self, ctx: DeviceContext) raises:
        self.fe_kernel = ctx.compile_function[
            fe_partial_group_gpu_kernel, fe_partial_group_gpu_kernel_sig
        ]()
        self.nc_kernel = ctx.compile_function[
            nc_partial_group_gpu_kernel, nc_partial_group_gpu_kernel_sig
        ]()


fn sumcheck_gpu_cache_ptr(session: UInt64) -> UnsafePointer[SumcheckGpuCache, MutAnyOrigin]:
    var addr = runtime.session_state_ptr(session)[].sumcheck_kernel_cache_addr
    return UnsafePointer[SumcheckGpuCache, MutAnyOrigin](unsafe_from_address=Int(addr))


fn ensure_sumcheck_gpu_cache(session: UInt64) raises:
    ref session_state = runtime.session_state_ptr(session)[]
    if session_state.sumcheck_kernel_cache_addr != 0:
        return

    var ptr = alloc[SumcheckGpuCache](1)
    ptr.init_pointee_move(SumcheckGpuCache(session_state.accelerator_ctx.value()))
    session_state.sumcheck_kernel_cache_addr = UInt64(Int(ptr))


fn destroy_session_cache(session: UInt64):
    if session <= 1:
        return
    ref session_state = runtime.session_state_ptr(session)[]
    if session_state.sumcheck_kernel_cache_addr == 0:
        return

    var ptr = sumcheck_gpu_cache_ptr(session)
    ptr.destroy_pointee()
    ptr.free()
    session_state.sumcheck_kernel_cache_addr = 0


struct FeEvaluatorState(Movable):
    var snapshot_words: UnsafePointer[UInt64, MutAnyOrigin]
    var snapshot_word_count: Int
    var snapshot_host: Optional[HostBuffer[DType.uint64]]
    var snapshot_dev: Optional[DeviceBuffer[DType.uint64]]
    var snapshot_uploaded: Bool
    var snapshot_dirty: Bool

    fn __init__(
        out self,
        snapshot_src: UnsafePointer[UInt64],
        snapshot_len: Int,
    ):
        self.snapshot_word_count = normalized_snapshot_word_count(snapshot_len)
        self.snapshot_words = alloc[UInt64](self.snapshot_word_count)
        self.snapshot_host = Optional[HostBuffer[DType.uint64]]()
        self.snapshot_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.snapshot_uploaded = False
        self.snapshot_dirty = True
        for idx in range(self.snapshot_word_count):
            self.snapshot_words[idx] = snapshot_src[idx]

    fn __del__(deinit self):
        self.snapshot_words.free()


struct NcEvaluatorState(Movable):
    var snapshot_words: UnsafePointer[UInt64, MutAnyOrigin]
    var snapshot_word_count: Int
    var snapshot_host: Optional[HostBuffer[DType.uint64]]
    var snapshot_dev: Optional[DeviceBuffer[DType.uint64]]
    var snapshot_uploaded: Bool
    var snapshot_dirty: Bool

    fn __init__(
        out self,
        snapshot_src: UnsafePointer[UInt64],
        snapshot_len: Int,
    ):
        self.snapshot_word_count = normalized_snapshot_word_count(snapshot_len)
        self.snapshot_words = alloc[UInt64](self.snapshot_word_count)
        self.snapshot_host = Optional[HostBuffer[DType.uint64]]()
        self.snapshot_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.snapshot_uploaded = False
        self.snapshot_dirty = True
        for idx in range(self.snapshot_word_count):
            self.snapshot_words[idx] = snapshot_src[idx]

    fn __del__(deinit self):
        self.snapshot_words.free()


fn fe_evaluator_ptr(handle: UInt64) -> UnsafePointer[FeEvaluatorState, MutAnyOrigin]:
    return UnsafePointer[FeEvaluatorState, MutAnyOrigin](unsafe_from_address=Int(handle))


fn nc_evaluator_ptr(handle: UInt64) -> UnsafePointer[NcEvaluatorState, MutAnyOrigin]:
    return UnsafePointer[NcEvaluatorState, MutAnyOrigin](unsafe_from_address=Int(handle))


fn reduce_partials_host(
    partial_words: UnsafePointer[mut=True, UInt64],
    points_len: Int,
    groups_per_point: Int,
    out_ptr: UnsafePointer[mut=True, UInt64],
):
    for point_idx in range(points_len):
        var acc = k_zero()
        for group_idx in range(groups_per_point):
            acc = k_add(acc, k_load(partial_words, (point_idx * groups_per_point + group_idx) * 2))
        store_out(out_ptr, point_idx, acc)


fn ensure_fe_snapshot_uploaded(session: UInt64, evaluator: UnsafePointer[FeEvaluatorState, MutAnyOrigin]) raises:
    ref session_state = runtime.session_state_ptr(session)[]
    var ctx = session_state.accelerator_ctx.value()
    if not evaluator[].snapshot_host or not evaluator[].snapshot_dev:
        evaluator[].snapshot_host = Optional[HostBuffer[DType.uint64]](
            ctx.enqueue_create_host_buffer[DType.uint64](evaluator[].snapshot_word_count)
        )
        evaluator[].snapshot_dev = Optional[DeviceBuffer[DType.uint64]](
            ctx.enqueue_create_buffer[DType.uint64](evaluator[].snapshot_word_count)
        )
        ctx.synchronize()
        evaluator[].snapshot_uploaded = False
        evaluator[].snapshot_dirty = True

    if evaluator[].snapshot_uploaded and not evaluator[].snapshot_dirty:
        return

    var host_snapshot = evaluator[].snapshot_host.value()
    var dev_snapshot = evaluator[].snapshot_dev.value()
    for idx in range(evaluator[].snapshot_word_count):
        host_snapshot[idx] = evaluator[].snapshot_words[idx]
    ctx.enqueue_copy(src_buf=host_snapshot, dst_buf=dev_snapshot)
    ctx.synchronize()
    evaluator[].snapshot_uploaded = True
    evaluator[].snapshot_dirty = False


fn ensure_nc_snapshot_uploaded(session: UInt64, evaluator: UnsafePointer[NcEvaluatorState, MutAnyOrigin]) raises:
    ref session_state = runtime.session_state_ptr(session)[]
    var ctx = session_state.accelerator_ctx.value()
    if not evaluator[].snapshot_host or not evaluator[].snapshot_dev:
        evaluator[].snapshot_host = Optional[HostBuffer[DType.uint64]](
            ctx.enqueue_create_host_buffer[DType.uint64](evaluator[].snapshot_word_count)
        )
        evaluator[].snapshot_dev = Optional[DeviceBuffer[DType.uint64]](
            ctx.enqueue_create_buffer[DType.uint64](evaluator[].snapshot_word_count)
        )
        ctx.synchronize()
        evaluator[].snapshot_uploaded = False
        evaluator[].snapshot_dirty = True

    if evaluator[].snapshot_uploaded and not evaluator[].snapshot_dirty:
        return

    var host_snapshot = evaluator[].snapshot_host.value()
    var dev_snapshot = evaluator[].snapshot_dev.value()
    for idx in range(evaluator[].snapshot_word_count):
        host_snapshot[idx] = evaluator[].snapshot_words[idx]
    ctx.enqueue_copy(src_buf=host_snapshot, dst_buf=dev_snapshot)
    ctx.synchronize()
    evaluator[].snapshot_uploaded = True
    evaluator[].snapshot_dirty = False


fn fe_evals_at_gpu(
    session: UInt64,
    evaluator: UnsafePointer[FeEvaluatorState, MutAnyOrigin],
    points_words: UnsafePointer[mut=True, UInt64],
    points_len: UInt64,
    out_ptr: UnsafePointer[mut=True, UInt64],
) raises:
    var point_count = Int(UInt(points_len))
    var tail_len = Int(read_snapshot_word(evaluator[].snapshot_words, 5)) // 2
    var groups_per_point = (tail_len + SUMCHECK_PAIR_GROUP - 1) // SUMCHECK_PAIR_GROUP
    var partial_word_count = point_count * groups_per_point * 2
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    session_state.ensure_sumcheck_buffers(point_count * 2, partial_word_count)
    ensure_sumcheck_gpu_cache(session)
    ensure_fe_snapshot_uploaded(session, evaluator)
    var ctx = session_state.accelerator_ctx.value()
    var host_points = session_state.sumcheck_points_host.value()
    var host_partials = session_state.sumcheck_partials_host.value()
    var dev_points = session_state.sumcheck_points_dev.value()
    var dev_partials = session_state.sumcheck_partials_dev.value()
    var dev_snapshot = evaluator[].snapshot_dev.value()
    ref cache = sumcheck_gpu_cache_ptr(session)[]

    for idx in range(point_count * 2):
        host_points[idx] = points_words[idx]

    ctx.enqueue_copy(src_buf=host_points, dst_buf=dev_points)
    ctx.enqueue_function(
        cache.fe_kernel,
        dev_snapshot.unsafe_ptr(),
        dev_points.unsafe_ptr(),
        dev_partials.unsafe_ptr(),
        point_count,
        grid_dim=grid_dim_for(point_count * groups_per_point),
        block_dim=SUMCHECK_GPU_BLOCK_SIZE,
    )
    ctx.enqueue_copy(src_buf=dev_partials, dst_buf=host_partials)
    ctx.synchronize()
    reduce_partials_host(host_partials.unsafe_ptr(), point_count, groups_per_point, out_ptr)


fn nc_evals_at_gpu(
    session: UInt64,
    evaluator: UnsafePointer[NcEvaluatorState, MutAnyOrigin],
    points_words: UnsafePointer[mut=True, UInt64],
    points_len: UInt64,
    out_ptr: UnsafePointer[mut=True, UInt64],
) raises:
    var point_count = Int(UInt(points_len))
    var tail_len = Int(read_snapshot_word(evaluator[].snapshot_words, 5)) // 2
    var groups_per_point = (tail_len + SUMCHECK_PAIR_GROUP - 1) // SUMCHECK_PAIR_GROUP
    var partial_word_count = point_count * groups_per_point * 2
    var session_ptr = runtime.session_state_ptr(session)
    ref session_state = session_ptr[]
    session_state.ensure_sumcheck_buffers(point_count * 2, partial_word_count)
    ensure_sumcheck_gpu_cache(session)
    ensure_nc_snapshot_uploaded(session, evaluator)
    var ctx = session_state.accelerator_ctx.value()
    var host_points = session_state.sumcheck_points_host.value()
    var host_partials = session_state.sumcheck_partials_host.value()
    var dev_points = session_state.sumcheck_points_dev.value()
    var dev_partials = session_state.sumcheck_partials_dev.value()
    var dev_snapshot = evaluator[].snapshot_dev.value()
    ref cache = sumcheck_gpu_cache_ptr(session)[]

    for idx in range(point_count * 2):
        host_points[idx] = points_words[idx]

    ctx.enqueue_copy(src_buf=host_points, dst_buf=dev_points)
    ctx.enqueue_function(
        cache.nc_kernel,
        dev_snapshot.unsafe_ptr(),
        dev_points.unsafe_ptr(),
        dev_partials.unsafe_ptr(),
        point_count,
        grid_dim=grid_dim_for(point_count * groups_per_point),
        block_dim=SUMCHECK_GPU_BLOCK_SIZE,
    )
    ctx.enqueue_copy(src_buf=dev_partials, dst_buf=host_partials)
    ctx.synchronize()
    reduce_partials_host(host_partials.unsafe_ptr(), point_count, groups_per_point, out_ptr)


fn fe_create(
    _session: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    out_handle: UnsafePointer[mut=True, UInt64],
) -> Int32:
    var status = snapshot_status(snapshot_words, Int(UInt(snapshot_len)), SPLIT_NC_FE_ROW_V1)
    if status != 0:
        return status
    var ptr = alloc[FeEvaluatorState](1)
    ptr.init_pointee_move(FeEvaluatorState(snapshot_words, Int(UInt(snapshot_len))))
    out_handle[0] = UInt64(Int(ptr))
    return 0


fn fe_destroy(_session: UInt, _evaluator: UInt) -> Int32:
    if _evaluator == 0:
        return -2
    var ptr = fe_evaluator_ptr(UInt64(_evaluator))
    ptr.destroy_pointee()
    ptr.free()
    return 0


fn fe_evals_at(
    _session: UInt64,
    _evaluator: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    points_words: UnsafePointer[mut=True, UInt64],
    points_len: UInt64,
    out_ptr: UnsafePointer[mut=True, UInt64],
    out_len: UInt,
) -> Int32:
    var status = snapshot_status(snapshot_words, Int(UInt(snapshot_len)), SPLIT_NC_FE_ROW_V1)
    if status != 0:
        return status
    if out_len < UInt(points_len):
        return -2
    if _evaluator == 0:
        return -3
    var point_count = Int(UInt(points_len))
    var evaluator_ptr = fe_evaluator_ptr(_evaluator)
    var eval_snapshot = evaluator_ptr[].snapshot_words
    var tail_len = Int(read_snapshot_word(eval_snapshot, 5)) // 2
    var total_tasks = point_count * tail_len
    if session_prefers_gpu(_session) and total_tasks >= SUMCHECK_GPU_MIN_TASKS:
        try:
            fe_evals_at_gpu(
                _session,
                evaluator_ptr,
                points_words,
                points_len,
                out_ptr,
            )
            return 0
        except:
            pass
    for idx in range(Int(UInt(points_len))):
        store_out(out_ptr, idx, fe_eval_one(eval_snapshot, load_point(points_words, idx)))
    return 0


fn fe_fold(_session: UInt, _evaluator: UInt, _challenge: KVal) -> Int32:
    if _evaluator == 0:
        return -2
    ref evaluator = fe_evaluator_ptr(UInt64(_evaluator))[]
    var status = apply_fe_snapshot_fold_in_place(
        evaluator.snapshot_words,
        evaluator.snapshot_word_count,
        _challenge,
    )
    if status == 0:
        evaluator.snapshot_dirty = True
    return status


fn nc_create(
    _session: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    out_handle: UnsafePointer[mut=True, UInt64],
) -> Int32:
    var status = snapshot_status(snapshot_words, Int(UInt(snapshot_len)), SPLIT_NC_NC_COL_V1)
    if status != 0:
        return status
    var ptr = alloc[NcEvaluatorState](1)
    ptr.init_pointee_move(NcEvaluatorState(snapshot_words, Int(UInt(snapshot_len))))
    out_handle[0] = UInt64(Int(ptr))
    return 0


fn nc_destroy(_session: UInt, _evaluator: UInt) -> Int32:
    if _evaluator == 0:
        return -2
    var ptr = nc_evaluator_ptr(UInt64(_evaluator))
    ptr.destroy_pointee()
    ptr.free()
    return 0


fn nc_evals_at(
    _session: UInt64,
    _evaluator: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    points_words: UnsafePointer[mut=True, UInt64],
    points_len: UInt64,
    out_ptr: UnsafePointer[mut=True, UInt64],
    out_len: UInt,
) -> Int32:
    var status = snapshot_status(snapshot_words, Int(UInt(snapshot_len)), SPLIT_NC_NC_COL_V1)
    if status != 0:
        return status
    if out_len < UInt(points_len):
        return -2
    if _evaluator == 0:
        return -3
    var point_count = Int(UInt(points_len))
    var evaluator_ptr = nc_evaluator_ptr(_evaluator)
    var eval_snapshot = evaluator_ptr[].snapshot_words
    var tail_len = Int(read_snapshot_word(eval_snapshot, 5)) // 2
    var total_tasks = point_count * tail_len
    if session_prefers_gpu(_session) and total_tasks >= SUMCHECK_GPU_MIN_TASKS:
        try:
            nc_evals_at_gpu(
                _session,
                evaluator_ptr,
                points_words,
                points_len,
                out_ptr,
            )
            return 0
        except:
            pass
    for idx in range(Int(UInt(points_len))):
        store_out(out_ptr, idx, nc_eval_one(eval_snapshot, load_point(points_words, idx)))
    return 0


fn nc_fold(_session: UInt, _evaluator: UInt, _challenge: KVal) -> Int32:
    if _evaluator == 0:
        return -2
    ref evaluator = nc_evaluator_ptr(UInt64(_evaluator))[]
    var status = apply_nc_snapshot_fold_in_place(
        evaluator.snapshot_words,
        evaluator.snapshot_word_count,
        _challenge,
    )
    if status == 0:
        evaluator.snapshot_dirty = True
    return status


fn debug_snapshot_head(
    session: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
    out_len: UInt32,
) -> Int32:
    if out_len < 3:
        return -2
    out_words[0] = session
    out_words[1] = UInt64(Int(snapshot_words))
    out_words[2] = snapshot_len
    if snapshot_len < 8:
        return 0
    var max_words = Int(UInt(out_len)) - 3
    var snapshot_word_count = Int(UInt(snapshot_len)) // 8
    if max_words > snapshot_word_count:
        max_words = snapshot_word_count
    for idx in range(max_words):
        out_words[idx + 3] = snapshot_words[idx]
    return 0
