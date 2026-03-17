from gpu.host import DeviceBuffer, DeviceContext, HostBuffer
from memory import UnsafePointer, alloc
from sys import has_accelerator


comptime DEVICE_API_CPU = 0
comptime DEVICE_API_METAL = 1
comptime DEVICE_API_CUDA = 2
comptime DEVICE_API_HIP = 3


fn device_api_name(api: UInt32) -> String:
    if api == UInt32(DEVICE_API_METAL):
        return "metal"
    if api == UInt32(DEVICE_API_CUDA):
        return "cuda"
    return "cpu"


fn accelerator_ready_for_api(api: UInt32, _device_id: UInt32) -> Bool:
    if api == UInt32(DEVICE_API_CPU):
        return False
    # Keep HIP out of the promoted production surface until it has real parity/perf coverage.
    if api == UInt32(DEVICE_API_HIP):
        return False
    if not has_accelerator():
        return False

    try:
        _ = DeviceContext(api=device_api_name(api))
        return True
    except:
        return False


struct SessionState(Movable):
    var api: UInt32
    var device_id: UInt32
    var accelerator_ctx: Optional[DeviceContext]
    var poseidon_host: Optional[HostBuffer[DType.uint64]]
    var poseidon_dev: Optional[DeviceBuffer[DType.uint64]]
    var poseidon_capacity_words: Int
    var poseidon_kernel_cache_addr: UInt64
    var sumcheck_points_host: Optional[HostBuffer[DType.uint64]]
    var sumcheck_points_dev: Optional[DeviceBuffer[DType.uint64]]
    var sumcheck_points_capacity_words: Int
    var sumcheck_partials_host: Optional[HostBuffer[DType.uint64]]
    var sumcheck_partials_dev: Optional[DeviceBuffer[DType.uint64]]
    var sumcheck_partials_capacity_words: Int
    var sumcheck_kernel_cache_addr: UInt64
    var ring_lhs_host: Optional[HostBuffer[DType.uint64]]
    var ring_lhs_dev: Optional[DeviceBuffer[DType.uint64]]
    var ring_rhs_host: Optional[HostBuffer[DType.uint64]]
    var ring_rhs_dev: Optional[DeviceBuffer[DType.uint64]]
    var ring_out_host: Optional[HostBuffer[DType.uint64]]
    var ring_out_dev: Optional[DeviceBuffer[DType.uint64]]
    var ring_capacity_words: Int
    var ring_out_capacity_words: Int
    var ring_meta_host: Optional[HostBuffer[DType.uint64]]
    var ring_meta_dev: Optional[DeviceBuffer[DType.uint64]]
    var ring_meta_capacity_words: Int
    var ring_kernel_cache_addr: UInt64
    var prepared_ring_lhs_host: Optional[HostBuffer[DType.uint64]]
    var prepared_ring_lhs_dev: Optional[DeviceBuffer[DType.uint64]]
    var prepared_ring_rhs_host: Optional[HostBuffer[DType.uint64]]
    var prepared_ring_rhs_dev: Optional[DeviceBuffer[DType.uint64]]
    var prepared_ring_out_host: Optional[HostBuffer[DType.uint64]]
    var prepared_ring_out_dev: Optional[DeviceBuffer[DType.uint64]]
    var prepared_ring_capacity_words: Int
    var prepared_ring_out_capacity_words: Int
    var prepared_ring_meta_host: Optional[HostBuffer[DType.uint64]]
    var prepared_ring_meta_dev: Optional[DeviceBuffer[DType.uint64]]
    var prepared_ring_meta_capacity_words: Int
    var prepared_ring_kind: UInt32
    var prepared_ring_pair_count: Int
    var prepared_ring_slot_count: Int
    var prepared_ring_generation: UInt64
    var superneo_a_host: Optional[HostBuffer[DType.uint64]]
    var superneo_a_dev: Optional[DeviceBuffer[DType.uint64]]
    var superneo_a_capacity_words: Int
    var superneo_b_host: Optional[HostBuffer[DType.uint64]]
    var superneo_b_dev: Optional[DeviceBuffer[DType.uint64]]
    var superneo_b_capacity_words: Int
    var superneo_out_host: Optional[HostBuffer[DType.uint64]]
    var superneo_out_dev: Optional[DeviceBuffer[DType.uint64]]
    var superneo_out_capacity_words: Int
    var superneo_kernel_cache_addr: UInt64
    var prepared_superneo_a_host: Optional[HostBuffer[DType.uint64]]
    var prepared_superneo_a_dev: Optional[DeviceBuffer[DType.uint64]]
    var prepared_superneo_a_capacity_words: Int
    var prepared_superneo_b_host: Optional[HostBuffer[DType.uint64]]
    var prepared_superneo_b_dev: Optional[DeviceBuffer[DType.uint64]]
    var prepared_superneo_b_capacity_words: Int
    var prepared_superneo_out_host: Optional[HostBuffer[DType.uint64]]
    var prepared_superneo_out_dev: Optional[DeviceBuffer[DType.uint64]]
    var prepared_superneo_out_capacity_words: Int
    var prepared_superneo_kind: UInt32
    var prepared_superneo_generation: UInt64

    fn __init__(out self, api: UInt32, device_id: UInt32):
        self.api = api
        self.device_id = device_id
        self.accelerator_ctx = Optional[DeviceContext]()
        self.poseidon_host = Optional[HostBuffer[DType.uint64]]()
        self.poseidon_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.poseidon_capacity_words = 0
        self.poseidon_kernel_cache_addr = 0
        self.sumcheck_points_host = Optional[HostBuffer[DType.uint64]]()
        self.sumcheck_points_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.sumcheck_points_capacity_words = 0
        self.sumcheck_partials_host = Optional[HostBuffer[DType.uint64]]()
        self.sumcheck_partials_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.sumcheck_partials_capacity_words = 0
        self.sumcheck_kernel_cache_addr = 0
        self.ring_lhs_host = Optional[HostBuffer[DType.uint64]]()
        self.ring_lhs_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.ring_rhs_host = Optional[HostBuffer[DType.uint64]]()
        self.ring_rhs_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.ring_out_host = Optional[HostBuffer[DType.uint64]]()
        self.ring_out_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.ring_capacity_words = 0
        self.ring_out_capacity_words = 0
        self.ring_meta_host = Optional[HostBuffer[DType.uint64]]()
        self.ring_meta_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.ring_meta_capacity_words = 0
        self.ring_kernel_cache_addr = 0
        self.prepared_ring_lhs_host = Optional[HostBuffer[DType.uint64]]()
        self.prepared_ring_lhs_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.prepared_ring_rhs_host = Optional[HostBuffer[DType.uint64]]()
        self.prepared_ring_rhs_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.prepared_ring_out_host = Optional[HostBuffer[DType.uint64]]()
        self.prepared_ring_out_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.prepared_ring_capacity_words = 0
        self.prepared_ring_out_capacity_words = 0
        self.prepared_ring_meta_host = Optional[HostBuffer[DType.uint64]]()
        self.prepared_ring_meta_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.prepared_ring_meta_capacity_words = 0
        self.prepared_ring_kind = 0
        self.prepared_ring_pair_count = 0
        self.prepared_ring_slot_count = 0
        self.prepared_ring_generation = 0
        self.superneo_a_host = Optional[HostBuffer[DType.uint64]]()
        self.superneo_a_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.superneo_a_capacity_words = 0
        self.superneo_b_host = Optional[HostBuffer[DType.uint64]]()
        self.superneo_b_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.superneo_b_capacity_words = 0
        self.superneo_out_host = Optional[HostBuffer[DType.uint64]]()
        self.superneo_out_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.superneo_out_capacity_words = 0
        self.superneo_kernel_cache_addr = 0
        self.prepared_superneo_a_host = Optional[HostBuffer[DType.uint64]]()
        self.prepared_superneo_a_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.prepared_superneo_a_capacity_words = 0
        self.prepared_superneo_b_host = Optional[HostBuffer[DType.uint64]]()
        self.prepared_superneo_b_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.prepared_superneo_b_capacity_words = 0
        self.prepared_superneo_out_host = Optional[HostBuffer[DType.uint64]]()
        self.prepared_superneo_out_dev = Optional[DeviceBuffer[DType.uint64]]()
        self.prepared_superneo_out_capacity_words = 0
        self.prepared_superneo_kind = 0
        self.prepared_superneo_generation = 0

        if api == UInt32(DEVICE_API_CPU) or not has_accelerator():
            return

        try:
            self.accelerator_ctx = Optional[DeviceContext](DeviceContext(api=device_api_name(api)))
        except:
            self.accelerator_ctx = Optional[DeviceContext]()

    fn accelerator_ready(self) -> Bool:
        if self.accelerator_ctx:
            return True
        return False

    fn ensure_poseidon_buffers(mut self, word_count: Int) raises:
        if not self.accelerator_ctx:
            raise Error("poseidon accelerator context unavailable")
        if (
            self.poseidon_capacity_words >= word_count
            and self.poseidon_host
            and self.poseidon_dev
        ):
            return

        var ctx = self.accelerator_ctx.value()
        self.poseidon_host = Optional[HostBuffer[DType.uint64]](
            ctx.enqueue_create_host_buffer[DType.uint64](word_count)
        )
        self.poseidon_dev = Optional[DeviceBuffer[DType.uint64]](
            ctx.enqueue_create_buffer[DType.uint64](word_count)
        )
        ctx.synchronize()
        self.poseidon_capacity_words = word_count

    fn ensure_sumcheck_buffers(
        mut self,
        point_word_count: Int,
        partial_word_count: Int,
    ) raises:
        if not self.accelerator_ctx:
            raise Error("sumcheck accelerator context unavailable")

        var ctx = self.accelerator_ctx.value()
        var grew = False
        if (
            self.sumcheck_points_capacity_words < point_word_count
            or not self.sumcheck_points_host
            or not self.sumcheck_points_dev
        ):
            self.sumcheck_points_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](point_word_count)
            )
            self.sumcheck_points_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](point_word_count)
            )
            self.sumcheck_points_capacity_words = point_word_count
            grew = True

        if (
            self.sumcheck_partials_capacity_words < partial_word_count
            or not self.sumcheck_partials_host
            or not self.sumcheck_partials_dev
        ):
            self.sumcheck_partials_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](partial_word_count)
            )
            self.sumcheck_partials_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](partial_word_count)
            )
            self.sumcheck_partials_capacity_words = partial_word_count
            grew = True

        if grew:
            ctx.synchronize()

    fn ensure_ring_buffers(mut self, word_count: Int, meta_word_count: Int = 0, out_word_count: Int = 0) raises:
        if not self.accelerator_ctx:
            raise Error("ring accelerator context unavailable")
        var requested_out_word_count = out_word_count
        if requested_out_word_count <= 0:
            requested_out_word_count = word_count
        var have_main = (
            self.ring_capacity_words >= word_count
            and self.ring_lhs_host
            and self.ring_lhs_dev
            and self.ring_rhs_host
            and self.ring_rhs_dev
        )
        var have_out = (
            self.ring_out_capacity_words >= requested_out_word_count
            and self.ring_out_host
            and self.ring_out_dev
        )
        var have_meta = (
            meta_word_count == 0
            or (
                self.ring_meta_capacity_words >= meta_word_count
                and self.ring_meta_host
                and self.ring_meta_dev
            )
        )
        if have_main and have_out and have_meta:
            return
        var ctx = self.accelerator_ctx.value()
        if not have_main:
            self.ring_lhs_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](word_count)
            )
            self.ring_lhs_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](word_count)
            )
            self.ring_rhs_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](word_count)
            )
            self.ring_rhs_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](word_count)
            )
            self.ring_capacity_words = word_count
        if not have_out:
            self.ring_out_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](requested_out_word_count)
            )
            self.ring_out_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](requested_out_word_count)
            )
            self.ring_out_capacity_words = requested_out_word_count
        if meta_word_count > 0 and not have_meta:
            self.ring_meta_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](meta_word_count)
            )
            self.ring_meta_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](meta_word_count)
            )
            self.ring_meta_capacity_words = meta_word_count
        ctx.synchronize()

    fn ensure_prepared_ring_buffers(mut self, word_count: Int, meta_word_count: Int, out_word_count: Int) raises:
        if not self.accelerator_ctx:
            raise Error("ring accelerator context unavailable")
        var ctx = self.accelerator_ctx.value()
        var grew = False
        if (
            self.prepared_ring_capacity_words < word_count
            or not self.prepared_ring_lhs_host
            or not self.prepared_ring_lhs_dev
            or not self.prepared_ring_rhs_host
            or not self.prepared_ring_rhs_dev
        ):
            self.prepared_ring_lhs_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](word_count)
            )
            self.prepared_ring_lhs_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](word_count)
            )
            self.prepared_ring_rhs_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](word_count)
            )
            self.prepared_ring_rhs_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](word_count)
            )
            self.prepared_ring_capacity_words = word_count
            grew = True
        if (
            self.prepared_ring_out_capacity_words < out_word_count
            or not self.prepared_ring_out_host
            or not self.prepared_ring_out_dev
        ):
            self.prepared_ring_out_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](out_word_count)
            )
            self.prepared_ring_out_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](out_word_count)
            )
            self.prepared_ring_out_capacity_words = out_word_count
            grew = True
        if meta_word_count > 0 and (
            self.prepared_ring_meta_capacity_words < meta_word_count
            or not self.prepared_ring_meta_host
            or not self.prepared_ring_meta_dev
        ):
            self.prepared_ring_meta_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](meta_word_count)
            )
            self.prepared_ring_meta_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](meta_word_count)
            )
            self.prepared_ring_meta_capacity_words = meta_word_count
            grew = True
        if grew:
            ctx.synchronize()

    fn ensure_superneo_buffers(mut self, a_word_count: Int, b_word_count: Int, out_word_count: Int) raises:
        if not self.accelerator_ctx:
            raise Error("superneo accelerator context unavailable")
        var ctx = self.accelerator_ctx.value()
        var grew = False
        if (
            self.superneo_a_capacity_words < a_word_count
            or not self.superneo_a_host
            or not self.superneo_a_dev
        ):
            self.superneo_a_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](a_word_count)
            )
            self.superneo_a_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](a_word_count)
            )
            self.superneo_a_capacity_words = a_word_count
            grew = True
        if (
            self.superneo_b_capacity_words < b_word_count
            or not self.superneo_b_host
            or not self.superneo_b_dev
        ):
            self.superneo_b_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](b_word_count)
            )
            self.superneo_b_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](b_word_count)
            )
            self.superneo_b_capacity_words = b_word_count
            grew = True
        if (
            self.superneo_out_capacity_words < out_word_count
            or not self.superneo_out_host
            or not self.superneo_out_dev
        ):
            self.superneo_out_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](out_word_count)
            )
            self.superneo_out_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](out_word_count)
            )
            self.superneo_out_capacity_words = out_word_count
            grew = True
        if grew:
            ctx.synchronize()

    fn ensure_prepared_superneo_buffers(mut self, a_word_count: Int, b_word_count: Int, out_word_count: Int) raises:
        if not self.accelerator_ctx:
            raise Error("superneo accelerator context unavailable")
        var ctx = self.accelerator_ctx.value()
        var grew = False
        if (
            self.prepared_superneo_a_capacity_words < a_word_count
            or not self.prepared_superneo_a_host
            or not self.prepared_superneo_a_dev
        ):
            self.prepared_superneo_a_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](a_word_count)
            )
            self.prepared_superneo_a_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](a_word_count)
            )
            self.prepared_superneo_a_capacity_words = a_word_count
            grew = True
        if (
            self.prepared_superneo_b_capacity_words < b_word_count
            or not self.prepared_superneo_b_host
            or not self.prepared_superneo_b_dev
        ):
            self.prepared_superneo_b_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](b_word_count)
            )
            self.prepared_superneo_b_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](b_word_count)
            )
            self.prepared_superneo_b_capacity_words = b_word_count
            grew = True
        if (
            self.prepared_superneo_out_capacity_words < out_word_count
            or not self.prepared_superneo_out_host
            or not self.prepared_superneo_out_dev
        ):
            self.prepared_superneo_out_host = Optional[HostBuffer[DType.uint64]](
                ctx.enqueue_create_host_buffer[DType.uint64](out_word_count)
            )
            self.prepared_superneo_out_dev = Optional[DeviceBuffer[DType.uint64]](
                ctx.enqueue_create_buffer[DType.uint64](out_word_count)
            )
            self.prepared_superneo_out_capacity_words = out_word_count
            grew = True
        if grew:
            ctx.synchronize()


fn session_api(session: UInt64) -> UInt32:
    if session <= 1:
        return UInt32(DEVICE_API_CPU)
    return session_state_ptr(session)[].api


fn session_prefers_gpu(session: UInt64) -> Bool:
    if session <= 1:
        return False
    return session_state_ptr(session)[].accelerator_ready()


fn session_state_ptr(session: UInt64) -> UnsafePointer[SessionState, MutAnyOrigin]:
    return UnsafePointer[SessionState, MutAnyOrigin](unsafe_from_address=Int(session))


fn allocate_session(api: UInt32, device_id: UInt32) -> UInt64:
    var ptr = alloc[SessionState](1)
    ptr.init_pointee_move(SessionState(api, device_id))
    return UInt64(Int(ptr))


fn free_session(session: UInt64):
    if session <= 1:
        return
    var ptr = session_state_ptr(session)
    ptr.destroy_pointee()
    ptr.free()
