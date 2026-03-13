from memory import UnsafePointer
from nightstream_gpu import field, poseidon, ring, runtime, sumcheck, superneo


comptime DEVICE_API_CPU = 0
comptime DEVICE_API_METAL = 1
comptime DEVICE_API_CUDA = 2
comptime DEVICE_API_HIP = 3
comptime STATUS_OK = 0
comptime STATUS_UNAVAILABLE = -1
comptime PROBE_AVAILABLE = UInt32(1 << 0)
comptime PROBE_ACCELERATOR_READY = UInt32(1 << 1)
comptime PROBE_POSEIDON2 = UInt32(1 << 2)
comptime PROBE_POSEIDON2_BATCH = UInt32(1 << 3)
comptime PROBE_SPLIT_NC = UInt32(1 << 4)
comptime PROBE_RQ_MUL = UInt32(1 << 5)
comptime PROBE_SUPERNEO = UInt32(1 << 6)
comptime PROBE_CPU_DIRECT = UInt32(1 << 7)
fn request_word(req_addr: UInt) -> UInt64:
    var req_words = UnsafePointer[UInt64](unchecked_downcast_value=Int(req_addr))
    return req_words[0]


fn accelerator_requested(req_word: UInt64) -> Bool:
    return unpack_api(req_word) != UInt32(DEVICE_API_CPU)


fn device_api_available(req_word: UInt64) -> Bool:
    if not accelerator_requested(req_word):
        return True

    return runtime.accelerator_ready_for_api(unpack_api(req_word), unpack_device_id(req_word))


fn unpack_api(req_word: UInt64) -> UInt32:
    return UInt32(req_word & UInt64(0xFFFF_FFFF))


fn unpack_device_id(req_word: UInt64) -> UInt32:
    return UInt32(req_word >> 32)


fn probe_capability_bits(req_word: UInt64) -> UInt32:
    var api = unpack_api(req_word)
    var device_id = unpack_device_id(req_word)
    var accelerator_ready = runtime.accelerator_ready_for_api(api, device_id)
    var supports_cpu_direct = (
        poseidon.scaffold_ready()
        or sumcheck.scaffold_ready()
        or ring.scaffold_ready()
        or superneo.scaffold_ready()
    )
    var available = supports_cpu_direct
    if api != UInt32(DEVICE_API_CPU):
        available = accelerator_ready

    var bits = UInt32(0)
    if available:
        bits |= PROBE_AVAILABLE
    if accelerator_ready:
        bits |= PROBE_ACCELERATOR_READY
    if poseidon.scaffold_ready():
        bits |= PROBE_POSEIDON2
        bits |= PROBE_POSEIDON2_BATCH
    if sumcheck.scaffold_ready():
        bits |= PROBE_SPLIT_NC
    if ring.scaffold_ready():
        bits |= PROBE_RQ_MUL
    if superneo.scaffold_ready():
        bits |= PROBE_SUPERNEO
    if supports_cpu_direct:
        bits |= PROBE_CPU_DIRECT
    return bits


fn pack_probe_response(status: Int32, capability_bits: UInt32) -> UInt64:
    return UInt64(UInt32(status)) | (UInt64(capability_bits) << 32)


fn abi_version() -> UInt32:
    return 1


fn device_probe(
    req_addr: UInt,
    out_words: UnsafePointer[mut=True, UInt64],
) -> Int32:
    var req_word = request_word(req_addr)
    out_words[0] = pack_probe_response(Int32(STATUS_OK), probe_capability_bits(req_word))
    return STATUS_OK


fn session_open(
    req_addr: UInt,
    handle_ptr: UnsafePointer[mut=True, UInt64],
) -> Int32:
    var req_word = request_word(req_addr)
    var api = unpack_api(req_word)
    var device_id = unpack_device_id(req_word)
    if not device_api_available(req_word):
        handle_ptr[0] = 0
        return STATUS_UNAVAILABLE

    handle_ptr[0] = runtime.allocate_session(api, device_id)
    return STATUS_OK


fn session_close(session: UInt) -> Int32:
    poseidon.destroy_session_cache(UInt64(session))
    ring.destroy_session_cache(UInt64(session))
    superneo.destroy_session_cache(UInt64(session))
    sumcheck.destroy_session_cache(UInt64(session))
    runtime.free_session(UInt64(session))
    return STATUS_OK


fn fe_create(
    session: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    out_handle: UnsafePointer[mut=True, UInt64],
) -> Int32:
    return sumcheck.fe_create(session, snapshot_words, snapshot_len, out_handle)


fn fe_destroy(_session: UInt, _evaluator: UInt) -> Int32:
    return sumcheck.fe_destroy(_session, _evaluator)


fn fe_evals_at(
    session: UInt64,
    evaluator: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    points_words: UnsafePointer[mut=True, UInt64],
    points_len: UInt64,
    out_ptr: UnsafePointer[mut=True, UInt64],
    out_len: UInt,
) -> Int32:
    return sumcheck.fe_evals_at(session, evaluator, snapshot_words, snapshot_len, points_words, points_len, out_ptr, out_len)


fn fe_fold(session: UInt, evaluator: UInt, challenge: sumcheck.KVal) -> Int32:
    return sumcheck.fe_fold(session, evaluator, challenge)


fn nc_create(
    session: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    out_handle: UnsafePointer[mut=True, UInt64],
) -> Int32:
    return sumcheck.nc_create(session, snapshot_words, snapshot_len, out_handle)


fn nc_destroy(_session: UInt, _evaluator: UInt) -> Int32:
    return sumcheck.nc_destroy(_session, _evaluator)


fn nc_evals_at(
    session: UInt64,
    evaluator: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    points_words: UnsafePointer[mut=True, UInt64],
    points_len: UInt64,
    out_ptr: UnsafePointer[mut=True, UInt64],
    out_len: UInt,
) -> Int32:
    return sumcheck.nc_evals_at(session, evaluator, snapshot_words, snapshot_len, points_words, points_len, out_ptr, out_len)


fn nc_fold(session: UInt, evaluator: UInt, challenge: sumcheck.KVal) -> Int32:
    return sumcheck.nc_fold(session, evaluator, challenge)


fn scaffold_sanity() -> Bool:
    return (
        field.scaffold_ready()
        and ring.scaffold_ready()
        and superneo.scaffold_ready()
        and sumcheck.scaffold_ready()
        and poseidon.scaffold_ready()
    )


fn debug_snapshot_head(
    session: UInt64,
    snapshot_words: UnsafePointer[mut=True, UInt64],
    snapshot_len: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
    out_len: UInt32,
) -> Int32:
    return sumcheck.debug_snapshot_head(session, snapshot_words, snapshot_len, out_words, out_len)


fn poseidon2_permute_u64x8(
    session: UInt,
    state: UnsafePointer[mut=True, UInt64],
    width: UInt32,
) -> Int32:
    return poseidon.poseidon2_permute_u64x8(session, state, width)


fn poseidon2_permute_batch_u64x8(
    session: UInt,
    state_words: UnsafePointer[mut=True, UInt64],
    num_states: UInt32,
    width: UInt32,
) -> Int32:
    return poseidon.poseidon2_permute_batch_u64x8(session, state_words, num_states, width)


fn rq_mul_u64x54(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
) -> Int32:
    _ = session
    ring.rq_mul_words(lhs_words, rhs_words, out_words)
    return STATUS_OK


fn rq_mul_batch_u64x54(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    pair_count: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
) -> Int32:
    ring.rq_mul_batch_words(session, lhs_words, rhs_words, pair_count, out_words)
    return STATUS_OK


fn rq_accumulate_batch_u64x54(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64],
    rhs_words: UnsafePointer[UInt64],
    slot_offsets_words: UnsafePointer[UInt64],
    slot_count: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
) -> Int32:
    ring.rq_accumulate_batch_words(session, lhs_words, rhs_words, slot_offsets_words, slot_count, out_words)
    return STATUS_OK


fn rq_ct_u64x54(
    words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
) -> Int32:
    out_words[0] = ring.rq_ct_words(words)
    return STATUS_OK


fn superneo_bar_block_u64x54(
    session: UInt64,
    matrix_words: UnsafePointer[UInt64],
    block_words: UnsafePointer[UInt64],
    out_words: UnsafePointer[mut=True, UInt64],
) -> Int32:
    superneo.superneo_bar_block_from_matrix_words(session, matrix_words, block_words, out_words)
    return STATUS_OK


fn superneo_row_dot_blocks(
    session: UInt64,
    bar_blocks_words: UnsafePointer[UInt64],
    num_blocks: UInt64,
    z_words: UnsafePointer[UInt64],
    z_len: UInt64,
    out_words: UnsafePointer[mut=True, UInt64],
) -> Int32:
    superneo.superneo_row_dot_blocks_words(session, bar_blocks_words, num_blocks, z_words, z_len, out_words)
    return STATUS_OK
