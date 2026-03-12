from memory import UnsafePointer
from nightstream_gpu import ffi, sumcheck


@export("nightstream_gpu_abi_version", ABI="C")
fn nightstream_gpu_abi_version() -> UInt32:
    return ffi.abi_version()


@export("nightstream_gpu_device_probe", ABI="C")
fn nightstream_gpu_device_probe(req_addr: UInt, out_words: UnsafePointer[UInt64, MutAnyOrigin]) -> Int32:
    return ffi.device_probe(req_addr, out_words)


@export("nightstream_gpu_session_open", ABI="C")
fn nightstream_gpu_session_open(req_addr: UInt, handle_ptr: UnsafePointer[UInt64, MutAnyOrigin]) -> Int32:
    return ffi.session_open(req_addr, handle_ptr)


@export("nightstream_gpu_session_close", ABI="C")
fn nightstream_gpu_session_close(session: UInt) -> Int32:
    return ffi.session_close(session)


@export("nightstream_gpu_fe_create", ABI="C")
fn nightstream_gpu_fe_create(
    session: UInt64,
    snapshot_words: UnsafePointer[UInt64, MutAnyOrigin],
    snapshot_len: UInt64,
    out_handle: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.fe_create(session, snapshot_words, snapshot_len, out_handle)


@export("nightstream_gpu_fe_destroy", ABI="C")
fn nightstream_gpu_fe_destroy(session: UInt, evaluator: UInt) -> Int32:
    return ffi.fe_destroy(session, evaluator)


@export("nightstream_gpu_fe_evals_at", ABI="C")
fn nightstream_gpu_fe_evals_at(
    session: UInt64,
    evaluator: UInt64,
    snapshot_words: UnsafePointer[UInt64, MutAnyOrigin],
    snapshot_len: UInt64,
    points_words: UnsafePointer[UInt64, MutAnyOrigin],
    points_len: UInt64,
    out_ptr: UnsafePointer[UInt64, MutAnyOrigin],
    out_len: UInt,
) -> Int32:
    return ffi.fe_evals_at(session, evaluator, snapshot_words, snapshot_len, points_words, points_len, out_ptr, out_len)


@export("nightstream_gpu_fe_fold", ABI="C")
fn nightstream_gpu_fe_fold(session: UInt, evaluator: UInt, challenge_re: UInt64, challenge_im: UInt64) -> Int32:
    return ffi.fe_fold(session, evaluator, sumcheck.KVal(challenge_re, challenge_im))


@export("nightstream_gpu_nc_create", ABI="C")
fn nightstream_gpu_nc_create(
    session: UInt64,
    snapshot_words: UnsafePointer[UInt64, MutAnyOrigin],
    snapshot_len: UInt64,
    out_handle: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.nc_create(session, snapshot_words, snapshot_len, out_handle)


@export("nightstream_gpu_nc_destroy", ABI="C")
fn nightstream_gpu_nc_destroy(session: UInt, evaluator: UInt) -> Int32:
    return ffi.nc_destroy(session, evaluator)


@export("nightstream_gpu_nc_evals_at", ABI="C")
fn nightstream_gpu_nc_evals_at(
    session: UInt64,
    evaluator: UInt64,
    snapshot_words: UnsafePointer[UInt64, MutAnyOrigin],
    snapshot_len: UInt64,
    points_words: UnsafePointer[UInt64, MutAnyOrigin],
    points_len: UInt64,
    out_ptr: UnsafePointer[UInt64, MutAnyOrigin],
    out_len: UInt,
) -> Int32:
    return ffi.nc_evals_at(session, evaluator, snapshot_words, snapshot_len, points_words, points_len, out_ptr, out_len)


@export("nightstream_gpu_nc_fold", ABI="C")
fn nightstream_gpu_nc_fold(session: UInt, evaluator: UInt, challenge_re: UInt64, challenge_im: UInt64) -> Int32:
    return ffi.nc_fold(session, evaluator, sumcheck.KVal(challenge_re, challenge_im))


@export("nightstream_gpu_debug_snapshot_head", ABI="C")
fn nightstream_gpu_debug_snapshot_head(
    session: UInt64,
    snapshot_words: UnsafePointer[UInt64, MutAnyOrigin],
    snapshot_len: UInt64,
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_len: UInt32,
) -> Int32:
    return ffi.debug_snapshot_head(session, snapshot_words, snapshot_len, out_words, out_len)


@export("nightstream_gpu_poseidon2_permute_u64x8", ABI="C")
fn nightstream_gpu_poseidon2_permute_u64x8(
    session: UInt,
    state: UnsafePointer[UInt64, MutAnyOrigin],
    width: UInt32,
) -> Int32:
    return ffi.poseidon2_permute_u64x8(session, state, width)


@export("nightstream_gpu_poseidon2_permute_batch_u64x8", ABI="C")
fn nightstream_gpu_poseidon2_permute_batch_u64x8(
    session: UInt,
    state_words: UnsafePointer[UInt64, MutAnyOrigin],
    num_states: UInt32,
    width: UInt32,
) -> Int32:
    return ffi.poseidon2_permute_batch_u64x8(session, state_words, num_states, width)


@export("nightstream_gpu_rq_mul_u64x54", ABI="C")
fn nightstream_gpu_rq_mul_u64x54(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    rhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.rq_mul_u64x54(session, lhs_words, rhs_words, out_words)


@export("nightstream_gpu_rq_mul_batch_u64x54", ABI="C")
fn nightstream_gpu_rq_mul_batch_u64x54(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    rhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    pair_count: UInt64,
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.rq_mul_batch_u64x54(session, lhs_words, rhs_words, pair_count, out_words)


@export("nightstream_gpu_rq_accumulate_batch_u64x54", ABI="C")
fn nightstream_gpu_rq_accumulate_batch_u64x54(
    session: UInt64,
    lhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    rhs_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_offsets_words: UnsafePointer[UInt64, MutAnyOrigin],
    slot_count: UInt64,
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.rq_accumulate_batch_u64x54(
        session, lhs_words, rhs_words, slot_offsets_words, slot_count, out_words
    )


@export("nightstream_gpu_rq_ct_u64x54", ABI="C")
fn nightstream_gpu_rq_ct_u64x54(
    words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.rq_ct_u64x54(words, out_words)


@export("nightstream_gpu_superneo_bar_block_u64x54", ABI="C")
fn nightstream_gpu_superneo_bar_block_u64x54(
    matrix_words: UnsafePointer[UInt64, MutAnyOrigin],
    block_words: UnsafePointer[UInt64, MutAnyOrigin],
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.superneo_bar_block_u64x54(matrix_words, block_words, out_words)


@export("nightstream_gpu_superneo_row_dot_blocks", ABI="C")
fn nightstream_gpu_superneo_row_dot_blocks(
    bar_blocks_words: UnsafePointer[UInt64, MutAnyOrigin],
    num_blocks: UInt64,
    z_words: UnsafePointer[UInt64, MutAnyOrigin],
    z_len: UInt64,
    out_words: UnsafePointer[UInt64, MutAnyOrigin],
) -> Int32:
    return ffi.superneo_row_dot_blocks(bar_blocks_words, num_blocks, z_words, z_len, out_words)
