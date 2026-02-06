from collections import List

from sys import CompilationTarget
from sys.param_env import env_get_bool

from gpu.host import DeviceContext

from nmb.fq import Fq


struct U64x2(Copyable, ImplicitlyCopyable, Movable):
    var lo: UInt64
    var hi: UInt64

    fn __init__(out self, lo: UInt64, hi: UInt64):
        self.lo = lo
        self.hi = hi

    fn __copyinit__(out self, existing: Self):
        self.lo = existing.lo
        self.hi = existing.hi


comptime ENABLE_METAL_GPU: Bool = env_get_bool["NMB_ENABLE_METAL_GPU", False]()
comptime CUDA_FFT_IMPLEMENTED: Bool = not CompilationTarget.is_macos() or ENABLE_METAL_GPU


fn best_fft_cuda_in_ctx(ctx: DeviceContext, a_in: List[Fq], omega: Fq, k: Int) raises -> List[Fq]:
    @parameter
    if CompilationTarget.is_macos() and not ENABLE_METAL_GPU:
        raise Error(
            "GPU FFT is disabled on macOS builds. Run with `-D NMB_ENABLE_METAL_GPU=true` to enable Metal."
        )
    else:
        from gpu import block_dim, block_idx, thread_idx

        # NOTE: Metal GPU codegen does not support `UInt128`. The field
        # implementation in `nmb/fq.mojo` uses `UInt128`, so we provide
        # GPU-safe add/sub/mul here (64-bit limb arithmetic only) and avoid
        # calling `Fq.{add,sub,mul}` inside kernels.
        comptime MOD0: UInt64 = UInt64(0xFFFF_FFFF_0000_0001)
        comptime MOD1: UInt64 = UInt64(0x53BD_A402_FFFE_5BFE)
        comptime MOD2: UInt64 = UInt64(0x3339_D808_09A1_D805)
        comptime MOD3: UInt64 = UInt64(0x73ED_A753_299D_7D48)
        comptime INV64: UInt64 = UInt64(0xFFFF_FFFE_FFFF_FFFF)

        @always_inline
        fn _add_u64(a: UInt64, b: UInt64, carry: UInt64) -> U64x2:
            var tmp = a + b
            var c0 = UInt64(1) if tmp < a else UInt64(0)
            var res = tmp + carry
            var c1 = UInt64(1) if res < tmp else UInt64(0)
            return U64x2(res, c0 + c1)

        @always_inline
        fn _add3_u64(a: UInt64, b: UInt64, c: UInt64) -> U64x2:
            # Returns (sum, carry_low) where carry_low ∈ {0,1,2}.
            var tmp = a + b
            var c0 = UInt64(1) if tmp < a else UInt64(0)
            var res = tmp + c
            var c1 = UInt64(1) if res < tmp else UInt64(0)
            return U64x2(res, c0 + c1)

        @always_inline
        fn _sub_u64(a: UInt64, b: UInt64, borrow: UInt64) -> U64x2:
            var tmp = a - b
            var b0 = UInt64(1) if a < b else UInt64(0)
            var res = tmp - borrow
            var b1 = UInt64(1) if tmp < borrow else UInt64(0)
            return U64x2(res, b0 + b1)

        @always_inline
        fn _ge_mod(x: Fq) -> Bool:
            if x.l3 > MOD3:
                return True
            if x.l3 < MOD3:
                return False
            if x.l2 > MOD2:
                return True
            if x.l2 < MOD2:
                return False
            if x.l1 > MOD1:
                return True
            if x.l1 < MOD1:
                return False
            return x.l0 >= MOD0

        @always_inline
        fn _sub_mod(x: Fq) -> Fq:
            # Assumes x >= modulus.
            var d0 = _sub_u64(x.l0, MOD0, UInt64(0))
            var d1 = _sub_u64(x.l1, MOD1, d0.hi)
            var d2 = _sub_u64(x.l2, MOD2, d1.hi)
            var d3 = _sub_u64(x.l3, MOD3, d2.hi)
            return Fq(d0.lo, d1.lo, d2.lo, d3.lo)

        @always_inline
        fn _add_mod(a: Fq, b: Fq) -> Fq:
            var s0 = _add_u64(a.l0, b.l0, UInt64(0))
            var s1 = _add_u64(a.l1, b.l1, s0.hi)
            var s2 = _add_u64(a.l2, b.l2, s1.hi)
            var s3 = _add_u64(a.l3, b.l3, s2.hi)
            var out = Fq(s0.lo, s1.lo, s2.lo, s3.lo)
            if s3.hi != UInt64(0) or _ge_mod(out):
                out = _sub_mod(out)
            return out

        @always_inline
        fn _sub_mod2(a: Fq, b: Fq) -> Fq:
            var d0 = _sub_u64(a.l0, b.l0, UInt64(0))
            var d1 = _sub_u64(a.l1, b.l1, d0.hi)
            var d2 = _sub_u64(a.l2, b.l2, d1.hi)
            var d3 = _sub_u64(a.l3, b.l3, d2.hi)
            var out = Fq(d0.lo, d1.lo, d2.lo, d3.lo)
            if d3.hi != UInt64(0):
                # Add modulus back.
                var s0 = _add_u64(out.l0, MOD0, UInt64(0))
                var s1 = _add_u64(out.l1, MOD1, s0.hi)
                var s2 = _add_u64(out.l2, MOD2, s1.hi)
                var s3 = _add_u64(out.l3, MOD3, s2.hi)
                out = Fq(s0.lo, s1.lo, s2.lo, s3.lo)
            return out

        @always_inline
        fn _mul64(a: UInt64, b: UInt64) -> U64x2:
            # 64x64 -> 128 using 32-bit pieces (no UInt128).
            var a0 = UInt32(a & UInt64(0xFFFF_FFFF))
            var a1 = UInt32(a >> 32)
            var b0 = UInt32(b & UInt64(0xFFFF_FFFF))
            var b1 = UInt32(b >> 32)

            var p0 = UInt64(a0) * UInt64(b0)
            var p1 = UInt64(a0) * UInt64(b1)
            var p2 = UInt64(a1) * UInt64(b0)
            var p3 = UInt64(a1) * UInt64(b1)

            var mid = p1 + p2
            var carry_mid = UInt64(1) if mid < p1 else UInt64(0)

            var mid_lo = mid << 32
            var mid_hi = mid >> 32

            var lo = p0 + mid_lo
            var carry_lo = UInt64(1) if lo < p0 else UInt64(0)

            var hi = p3 + mid_hi
            hi = hi + (carry_mid << 32)
            hi = hi + carry_lo

            return U64x2(lo, hi)

        @always_inline
        fn _mul_add(t: UInt64, a: UInt64, b: UInt64, carry: UInt64) -> U64x2:
            var prod = _mul64(a, b)
            var sum = _add3_u64(t, prod.lo, carry)
            return U64x2(sum.lo, prod.hi + sum.hi)

        @always_inline
        fn _mont_mul(a: Fq, b: Fq) -> Fq:
            # Coarsely Integrated Operand Scanning Montgomery multiplication (4 limbs).
            var t0: UInt64 = 0
            var t1: UInt64 = 0
            var t2: UInt64 = 0
            var t3: UInt64 = 0
            var t4: UInt64 = 0

            var carry: UInt64
            var m_i: UInt64

            # b.l0
            carry = 0
            var r0 = _mul_add(t0, a.l0, b.l0, carry)
            t0 = r0.lo
            carry = r0.hi
            var r1 = _mul_add(t1, a.l1, b.l0, carry)
            t1 = r1.lo
            carry = r1.hi
            var r2 = _mul_add(t2, a.l2, b.l0, carry)
            t2 = r2.lo
            carry = r2.hi
            var r3 = _mul_add(t3, a.l3, b.l0, carry)
            t3 = r3.lo
            carry = r3.hi
            t4 = t4 + carry  # keep low; matches CPU implementation

            m_i = t0 * INV64
            carry = 0
            var rr0 = _mul_add(t0, m_i, MOD0, carry)
            # discard low limb
            carry = rr0.hi
            var rr1 = _mul_add(t1, m_i, MOD1, carry)
            t1 = rr1.lo
            carry = rr1.hi
            var rr2 = _mul_add(t2, m_i, MOD2, carry)
            t2 = rr2.lo
            carry = rr2.hi
            var rr3 = _mul_add(t3, m_i, MOD3, carry)
            t3 = rr3.lo
            carry = rr3.hi
            var add_t4 = _add_u64(t4, carry, UInt64(0))
            t4 = add_t4.lo
            carry = add_t4.hi

            t0 = t1
            t1 = t2
            t2 = t3
            t3 = t4
            t4 = carry

            # b.l1
            carry = 0
            r0 = _mul_add(t0, a.l0, b.l1, carry)
            t0 = r0.lo
            carry = r0.hi
            r1 = _mul_add(t1, a.l1, b.l1, carry)
            t1 = r1.lo
            carry = r1.hi
            r2 = _mul_add(t2, a.l2, b.l1, carry)
            t2 = r2.lo
            carry = r2.hi
            r3 = _mul_add(t3, a.l3, b.l1, carry)
            t3 = r3.lo
            carry = r3.hi
            t4 = t4 + carry

            m_i = t0 * INV64
            carry = 0
            rr0 = _mul_add(t0, m_i, MOD0, carry)
            carry = rr0.hi
            rr1 = _mul_add(t1, m_i, MOD1, carry)
            t1 = rr1.lo
            carry = rr1.hi
            rr2 = _mul_add(t2, m_i, MOD2, carry)
            t2 = rr2.lo
            carry = rr2.hi
            rr3 = _mul_add(t3, m_i, MOD3, carry)
            t3 = rr3.lo
            carry = rr3.hi
            add_t4 = _add_u64(t4, carry, UInt64(0))
            t4 = add_t4.lo
            carry = add_t4.hi

            t0 = t1
            t1 = t2
            t2 = t3
            t3 = t4
            t4 = carry

            # b.l2
            carry = 0
            r0 = _mul_add(t0, a.l0, b.l2, carry)
            t0 = r0.lo
            carry = r0.hi
            r1 = _mul_add(t1, a.l1, b.l2, carry)
            t1 = r1.lo
            carry = r1.hi
            r2 = _mul_add(t2, a.l2, b.l2, carry)
            t2 = r2.lo
            carry = r2.hi
            r3 = _mul_add(t3, a.l3, b.l2, carry)
            t3 = r3.lo
            carry = r3.hi
            t4 = t4 + carry

            m_i = t0 * INV64
            carry = 0
            rr0 = _mul_add(t0, m_i, MOD0, carry)
            carry = rr0.hi
            rr1 = _mul_add(t1, m_i, MOD1, carry)
            t1 = rr1.lo
            carry = rr1.hi
            rr2 = _mul_add(t2, m_i, MOD2, carry)
            t2 = rr2.lo
            carry = rr2.hi
            rr3 = _mul_add(t3, m_i, MOD3, carry)
            t3 = rr3.lo
            carry = rr3.hi
            add_t4 = _add_u64(t4, carry, UInt64(0))
            t4 = add_t4.lo
            carry = add_t4.hi

            t0 = t1
            t1 = t2
            t2 = t3
            t3 = t4
            t4 = carry

            # b.l3
            carry = 0
            r0 = _mul_add(t0, a.l0, b.l3, carry)
            t0 = r0.lo
            carry = r0.hi
            r1 = _mul_add(t1, a.l1, b.l3, carry)
            t1 = r1.lo
            carry = r1.hi
            r2 = _mul_add(t2, a.l2, b.l3, carry)
            t2 = r2.lo
            carry = r2.hi
            r3 = _mul_add(t3, a.l3, b.l3, carry)
            t3 = r3.lo
            carry = r3.hi
            t4 = t4 + carry

            m_i = t0 * INV64
            carry = 0
            rr0 = _mul_add(t0, m_i, MOD0, carry)
            carry = rr0.hi
            rr1 = _mul_add(t1, m_i, MOD1, carry)
            t1 = rr1.lo
            carry = rr1.hi
            rr2 = _mul_add(t2, m_i, MOD2, carry)
            t2 = rr2.lo
            carry = rr2.hi
            rr3 = _mul_add(t3, m_i, MOD3, carry)
            t3 = rr3.lo
            carry = rr3.hi
            add_t4 = _add_u64(t4, carry, UInt64(0))
            t4 = add_t4.lo
            carry = add_t4.hi

            t0 = t1
            t1 = t2
            t2 = t3
            t3 = t4
            t4 = carry

            var out = Fq(t0, t1, t2, t3)
            if t4 != UInt64(0) or _ge_mod(out):
                out = _sub_mod(out)
            return out

        @always_inline
        fn _reverse_bits(x: Int, bits: Int) -> Int:
            var v = x
            var y = 0
            for _ in range(bits):
                y = (y << 1) | (v & 1)
                v >>= 1
            return y

        @always_inline
        fn _load_fq(ptr: UnsafePointer[UInt64, MutAnyOrigin], idx: Int) -> Fq:
            var v = ptr.load[width=4](UInt(idx * 4))
            return Fq(v[0], v[1], v[2], v[3])

        @always_inline
        fn _store_fq(ptr: UnsafePointer[UInt64, MutAnyOrigin], idx: Int, x: Fq):
            ptr.store[width=4](
                UInt(idx * 4), SIMD[DType.uint64, 4](x.l0, x.l1, x.l2, x.l3)
            )

        fn _bitrev_kernel(
            inp: UnsafePointer[UInt64, MutAnyOrigin],
            dst: UnsafePointer[UInt64, MutAnyOrigin],
            n: Int,
            k: Int,
        ):
            var tid = Int(thread_idx.x + block_idx.x * block_dim.x)
            if tid >= n:
                return
            var rev = _reverse_bits(tid, k)
            var v = inp.load[width=4](UInt(tid * 4))
            dst.store[width=4](UInt(rev * 4), v)

        fn _fft_stage_kernel(
            a: UnsafePointer[UInt64, MutAnyOrigin],
            tw: UnsafePointer[UInt64, MutAnyOrigin],
            n: Int,
            m: Int,
            tw_off: Int,
        ):
            var tid = Int(thread_idx.x + block_idx.x * block_dim.x)
            var half = n // 2
            if tid >= half:
                return

            var j = tid % m
            var group = tid // m
            var base = group * (m * 2) + j

            var idx1 = base
            var idx2 = base + m

            var u = _load_fq(a, idx1)
            var v = _load_fq(a, idx2)
            var w = _load_fq(tw, tw_off + j)
            var t = _mont_mul(w, v)

            _store_fq(a, idx1, _add_mod(u, t))
            _store_fq(a, idx2, _sub_mod2(u, t))

        var n = 1 << k
        if len(a_in) != n:
            raise Error("best_fft_cuda: bad length")

        var in_host = ctx.enqueue_create_host_buffer[DType.uint64](n * 4)
        var out_host = ctx.enqueue_create_host_buffer[DType.uint64](n * 4)
        ctx.synchronize()

        for i in range(n):
            var v = a_in[i]
            var off = i * 4
            in_host[off + 0] = v.l0
            in_host[off + 1] = v.l1
            in_host[off + 2] = v.l2
            in_host[off + 3] = v.l3

        var buf_a = ctx.enqueue_create_buffer[DType.uint64](n * 4)
        var buf_b = ctx.enqueue_create_buffer[DType.uint64](n * 4)
        buf_a.enqueue_copy_from(in_host.unsafe_ptr())

        var threads = 256
        var blocks = (n + threads - 1) // threads
        ctx.enqueue_function_experimental[_bitrev_kernel](
            buf_a,
            buf_b,
            n,
            k,
            grid_dim=blocks,
            block_dim=threads,
        )

        var tmp = buf_a
        buf_a = buf_b
        buf_b = tmp

        # Precompute all stage twiddles on CPU once and upload once:
        # stage 0 has m=1 twiddles, stage 1 has m=2, ..., stage k-1 has m=n/2.
        var total_tw = n - 1
        var tw_host_all = ctx.enqueue_create_host_buffer[DType.uint64](total_tw * 4)
        ctx.synchronize()
        var tw_idx = 0
        var m_tw = 1
        for stage in range(k):
            # w_m = omega^(2^(k-stage-1)).
            var w_m = omega
            for _ in range(k - stage - 1):
                w_m = w_m.square()

            var w = Fq.one()
            for j in range(m_tw):
                var off = (tw_idx + j) * 4
                tw_host_all[off + 0] = w.l0
                tw_host_all[off + 1] = w.l1
                tw_host_all[off + 2] = w.l2
                tw_host_all[off + 3] = w.l3
                w = w.mul(w_m)

            tw_idx += m_tw
            m_tw = m_tw * 2

        if tw_idx != total_tw:
            raise Error("best_fft_cuda: twiddle precompute length mismatch")

        var tw_dev_all = ctx.enqueue_create_buffer[DType.uint64](total_tw * 4)
        tw_dev_all.enqueue_copy_from(tw_host_all.unsafe_ptr())

        var m = 1
        var tw_off = 0
        for _ in range(k):
            var half = n // 2
            var blocks2 = (half + threads - 1) // threads
            ctx.enqueue_function_experimental[_fft_stage_kernel](
                buf_a,
                tw_dev_all,
                n,
                m,
                tw_off,
                grid_dim=blocks2,
                block_dim=threads,
            )

            tw_off += m
            m = m * 2

        buf_a.enqueue_copy_to(out_host.unsafe_ptr())
        ctx.synchronize()

        var out = List[Fq]()
        for i in range(n):
            var off = i * 4
            out.append(
                Fq(
                    out_host[off + 0],
                    out_host[off + 1],
                    out_host[off + 2],
                    out_host[off + 3],
                )
            )
        return out^


fn best_fft_cuda(a_in: List[Fq], omega: Fq, k: Int) raises -> List[Fq]:
    @parameter
    if CompilationTarget.is_macos() and not ENABLE_METAL_GPU:
        raise Error(
            "GPU FFT is disabled on macOS builds. Run with `-D NMB_ENABLE_METAL_GPU=true` to enable Metal."
        )
    else:
        var api = "cuda"
        @parameter
        if CompilationTarget.is_macos():
            api = "metal"

        with DeviceContext(api=api) as ctx:
            return best_fft_cuda_in_ctx(ctx, a_in, omega, k)
