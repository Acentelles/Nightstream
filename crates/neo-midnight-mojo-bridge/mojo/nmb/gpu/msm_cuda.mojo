from collections import List

from sys import CompilationTarget
from sys.param_env import env_get_bool

from gpu.host import DeviceBuffer, DeviceContext

from nmb.fq import Fq
from nmb.fp import Fp
from nmb.g1 import G1Affine, G1Jacobian


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
comptime CUDA_MSM_IMPLEMENTED: Bool = not CompilationTarget.is_macos() or ENABLE_METAL_GPU


fn msm_pippenger_cuda_bases_dev(
    ctx: DeviceContext,
    bases_xy: DeviceBuffer[DType.uint64],
    scalars: List[Fq],
) raises -> G1Jacobian:
    @parameter
    if CompilationTarget.is_macos() and not ENABLE_METAL_GPU:
        raise Error(
            "GPU MSM is disabled on macOS builds. Run with `-D NMB_ENABLE_METAL_GPU=true` to enable Metal."
        )
    else:
        from gpu import block_dim, block_idx, thread_idx
        from gpu.sync import barrier
        from memory import AddressSpace, stack_allocation

        # NOTE: Metal GPU codegen does not support `UInt128`. The `Fp`
        # implementation uses `UInt128`, so we provide GPU-safe field ops here
        # (64-bit limb arithmetic only) and avoid calling `Fp.{add,sub,mul}` in
        # kernels.
        comptime MOD0: UInt64 = UInt64(0xB9FE_FFFF_FFFF_AAAB)
        comptime MOD1: UInt64 = UInt64(0x1EAB_FFFE_B153_FFFF)
        comptime MOD2: UInt64 = UInt64(0x6730_D2A0_F6B0_F624)
        comptime MOD3: UInt64 = UInt64(0x6477_4B84_F385_12BF)
        comptime MOD4: UInt64 = UInt64(0x4B1B_A7B6_434B_ACD7)
        comptime MOD5: UInt64 = UInt64(0x1A01_11EA_397F_E69A)
        comptime INV64: UInt64 = UInt64(0x89F3_FFFC_FFFC_FFFD)

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
        fn _fp_ge_mod(x: Fp) -> Bool:
            if x.l5 > MOD5:
                return True
            if x.l5 < MOD5:
                return False
            if x.l4 > MOD4:
                return True
            if x.l4 < MOD4:
                return False
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
        fn _fp_sub_mod(x: Fp) -> Fp:
            # Assumes x >= modulus.
            var d0 = _sub_u64(x.l0, MOD0, UInt64(0))
            var d1 = _sub_u64(x.l1, MOD1, d0.hi)
            var d2 = _sub_u64(x.l2, MOD2, d1.hi)
            var d3 = _sub_u64(x.l3, MOD3, d2.hi)
            var d4 = _sub_u64(x.l4, MOD4, d3.hi)
            var d5 = _sub_u64(x.l5, MOD5, d4.hi)
            return Fp(d0.lo, d1.lo, d2.lo, d3.lo, d4.lo, d5.lo)

        @always_inline
        fn _fp_add_mod(a: Fp, b: Fp) -> Fp:
            var s0 = _add_u64(a.l0, b.l0, UInt64(0))
            var s1 = _add_u64(a.l1, b.l1, s0.hi)
            var s2 = _add_u64(a.l2, b.l2, s1.hi)
            var s3 = _add_u64(a.l3, b.l3, s2.hi)
            var s4 = _add_u64(a.l4, b.l4, s3.hi)
            var s5 = _add_u64(a.l5, b.l5, s4.hi)
            var out = Fp(s0.lo, s1.lo, s2.lo, s3.lo, s4.lo, s5.lo)
            if s5.hi != UInt64(0) or _fp_ge_mod(out):
                out = _fp_sub_mod(out)
            return out

        @always_inline
        fn _fp_sub_mod2(a: Fp, b: Fp) -> Fp:
            var d0 = _sub_u64(a.l0, b.l0, UInt64(0))
            var d1 = _sub_u64(a.l1, b.l1, d0.hi)
            var d2 = _sub_u64(a.l2, b.l2, d1.hi)
            var d3 = _sub_u64(a.l3, b.l3, d2.hi)
            var d4 = _sub_u64(a.l4, b.l4, d3.hi)
            var d5 = _sub_u64(a.l5, b.l5, d4.hi)
            var out = Fp(d0.lo, d1.lo, d2.lo, d3.lo, d4.lo, d5.lo)
            if d5.hi != UInt64(0):
                # Add modulus back.
                var s0 = _add_u64(out.l0, MOD0, UInt64(0))
                var s1 = _add_u64(out.l1, MOD1, s0.hi)
                var s2 = _add_u64(out.l2, MOD2, s1.hi)
                var s3 = _add_u64(out.l3, MOD3, s2.hi)
                var s4 = _add_u64(out.l4, MOD4, s3.hi)
                var s5 = _add_u64(out.l5, MOD5, s4.hi)
                out = Fp(s0.lo, s1.lo, s2.lo, s3.lo, s4.lo, s5.lo)
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
        fn _fp_mod_word(j: Int) -> UInt64:
            if j == 0:
                return MOD0
            if j == 1:
                return MOD1
            if j == 2:
                return MOD2
            if j == 3:
                return MOD3
            if j == 4:
                return MOD4
            return MOD5

        @no_inline
        fn _fp_mont_mul(a: Fp, b: Fp) -> Fp:
            # Straightforward Montgomery multiplication using a 12-limb accumulator.
            var aw = InlineArray[UInt64, 6](uninitialized=True)
            aw[0] = a.l0
            aw[1] = a.l1
            aw[2] = a.l2
            aw[3] = a.l3
            aw[4] = a.l4
            aw[5] = a.l5

            var bw = InlineArray[UInt64, 6](uninitialized=True)
            bw[0] = b.l0
            bw[1] = b.l1
            bw[2] = b.l2
            bw[3] = b.l3
            bw[4] = b.l4
            bw[5] = b.l5

            var t = InlineArray[UInt64, 12](uninitialized=True)
            for i in range(12):
                t[i] = 0

            # t += a*b
            for i in range(6):
                var carry: UInt64 = 0
                var bi = bw[i]
                for j in range(6):
                    var r = _mul_add(t[i + j], aw[j], bi, carry)
                    t[i + j] = r.lo
                    carry = r.hi
                var k = i + 6
                var s = _add_u64(t[k], carry, UInt64(0))
                t[k] = s.lo
                var carry2 = s.hi
                k += 1
                while carry2 != UInt64(0) and k < 12:
                    s = _add_u64(t[k], carry2, UInt64(0))
                    t[k] = s.lo
                    carry2 = s.hi
                    k += 1

            # Montgomery reduction.
            for i in range(6):
                var m_i = t[i] * INV64
                var carry: UInt64 = 0
                for j in range(6):
                    var r = _mul_add(t[i + j], m_i, _fp_mod_word(j), carry)
                    t[i + j] = r.lo
                    carry = r.hi
                var k = i + 6
                var s = _add_u64(t[k], carry, UInt64(0))
                t[k] = s.lo
                var carry2 = s.hi
                k += 1
                while carry2 != UInt64(0) and k < 12:
                    s = _add_u64(t[k], carry2, UInt64(0))
                    t[k] = s.lo
                    carry2 = s.hi
                    k += 1

            var out = Fp(t[6], t[7], t[8], t[9], t[10], t[11])
            if _fp_ge_mod(out):
                out = _fp_sub_mod(out)
            return out

        @always_inline
        fn _fp_square(a: Fp) -> Fp:
            return _fp_mont_mul(a, a)

        @always_inline
        fn _fp_is_zero(a: Fp) -> Bool:
            return a.l0 == 0 and a.l1 == 0 and a.l2 == 0 and a.l3 == 0 and a.l4 == 0 and a.l5 == 0

        @always_inline
        fn _g1_identity() -> G1Jacobian:
            # Convention: Z=0 means infinity.
            return G1Jacobian(Fp.zero(), Fp.one(), Fp.zero())

        @always_inline
        fn _g1_is_identity(p: G1Jacobian) -> Bool:
            return _fp_is_zero(p.z)

        @always_inline
        fn _g1_from_affine(x: Fp, y: Fp) -> G1Jacobian:
            return G1Jacobian(x, y, Fp.one())

        @no_inline
        fn _g1_double(p: G1Jacobian) -> G1Jacobian:
            if _g1_is_identity(p):
                return p
            if _fp_is_zero(p.y):
                return _g1_identity()

            # dbl-2007-bl for a=0.
            var a = _fp_square(p.x)  # A
            var b = _fp_square(p.y)  # B
            var c = _fp_square(b)  # C

            var x_plus_b = _fp_add_mod(p.x, b)
            var x_plus_b_sq = _fp_square(x_plus_b)
            var d_tmp = _fp_sub_mod2(_fp_sub_mod2(x_plus_b_sq, a), c)
            var d = _fp_add_mod(d_tmp, d_tmp)  # 2*(...)

            var e = _fp_add_mod(_fp_add_mod(a, a), a)  # 3*A
            var f = _fp_square(e)

            var x3 = _fp_sub_mod2(f, _fp_add_mod(d, d))
            var c2 = _fp_add_mod(c, c)
            var c4 = _fp_add_mod(c2, c2)
            var c8 = _fp_add_mod(c4, c4)
            var y3 = _fp_sub_mod2(_fp_mont_mul(e, _fp_sub_mod2(d, x3)), c8)
            var y1z1 = _fp_mont_mul(p.y, p.z)
            var z3 = _fp_add_mod(y1z1, y1z1)  # 2*Y1*Z1
            return G1Jacobian(x3, y3, z3)

        @no_inline
        fn _g1_add_affine(p: G1Jacobian, qx: Fp, qy: Fp) -> G1Jacobian:
            if _g1_is_identity(p):
                return _g1_from_affine(qx, qy)

            # madd-2007-bl for a=0.
            var z1z1 = _fp_square(p.z)
            var u2 = _fp_mont_mul(qx, z1z1)
            var s2 = _fp_mont_mul(qy, _fp_mont_mul(p.z, z1z1))

            var h = _fp_sub_mod2(u2, p.x)
            var r_tmp = _fp_sub_mod2(s2, p.y)
            var r = _fp_add_mod(r_tmp, r_tmp)

            if _fp_is_zero(h):
                if _fp_is_zero(r):
                    return _g1_double(p)
                return _g1_identity()

            var hh = _fp_square(h)
            var hh2 = _fp_add_mod(hh, hh)
            var i = _fp_add_mod(hh2, hh2)  # 4*HH
            var j = _fp_mont_mul(h, i)
            var v = _fp_mont_mul(p.x, i)

            var x3 = _fp_sub_mod2(_fp_sub_mod2(_fp_square(r), j), _fp_add_mod(v, v))
            var yj = _fp_mont_mul(p.y, j)
            var y1j2 = _fp_add_mod(yj, yj)
            var y3 = _fp_sub_mod2(_fp_mont_mul(r, _fp_sub_mod2(v, x3)), y1j2)
            var z3 = _fp_sub_mod2(_fp_sub_mod2(_fp_square(_fp_add_mod(p.z, h)), z1z1), hh)
            return G1Jacobian(x3, y3, z3)

        @no_inline
        fn _g1_add(p: G1Jacobian, q: G1Jacobian) -> G1Jacobian:
            if _g1_is_identity(q):
                return p
            if _g1_is_identity(p):
                return q

            var z1z1 = _fp_square(p.z)
            var z2z2 = _fp_square(q.z)
            var u1 = _fp_mont_mul(p.x, z2z2)
            var u2 = _fp_mont_mul(q.x, z1z1)
            var s1 = _fp_mont_mul(p.y, _fp_mont_mul(q.z, z2z2))
            var s2 = _fp_mont_mul(q.y, _fp_mont_mul(p.z, z1z1))

            var h = _fp_sub_mod2(u2, u1)
            var r_tmp = _fp_sub_mod2(s2, s1)
            var r = _fp_add_mod(r_tmp, r_tmp)

            if _fp_is_zero(h):
                if _fp_is_zero(r):
                    return _g1_double(p)
                return _g1_identity()

            var hh = _fp_square(h)
            var hh2 = _fp_add_mod(hh, hh)
            var i = _fp_add_mod(hh2, hh2)
            var j = _fp_mont_mul(h, i)
            var v = _fp_mont_mul(u1, i)
            var x3 = _fp_sub_mod2(_fp_sub_mod2(_fp_square(r), j), _fp_add_mod(v, v))
            var s1j = _fp_mont_mul(s1, j)
            var s1j2 = _fp_add_mod(s1j, s1j)
            var y3 = _fp_sub_mod2(_fp_mont_mul(r, _fp_sub_mod2(v, x3)), s1j2)
            var z3 = _fp_mont_mul(
                _fp_sub_mod2(_fp_sub_mod2(_fp_square(_fp_add_mod(p.z, q.z)), z1z1), z2z2),
                h,
            )
            return G1Jacobian(x3, y3, z3)

        @always_inline
        fn _load_fp(ptr: UnsafePointer[UInt64, MutAnyOrigin], off: Int) -> Fp:
            var v0 = ptr.load[width=4](UInt(off))
            var v1 = ptr.load[width=2](UInt(off + 4))
            return Fp(v0[0], v0[1], v0[2], v0[3], v1[0], v1[1])

        @always_inline
        fn _store_fp(ptr: UnsafePointer[UInt64, MutAnyOrigin], off: Int, x: Fp):
            ptr.store[width=4](UInt(off), SIMD[DType.uint64, 4](x.l0, x.l1, x.l2, x.l3))
            ptr.store[width=2](UInt(off + 4), SIMD[DType.uint64, 2](x.l4, x.l5))

        comptime BLOCK_SIZE: Int = 64
        comptime REDUCE_BLOCK_SIZE: Int = 64
        comptime W: Int = 7
        comptime BUCKET_COUNT: Int = 1 << W
        comptime NUM_WINDOWS: Int = (256 + W - 1) // W
        comptime MASK: UInt64 = UInt64(0x7F)  # W=7

        @always_inline
        fn _word_at(w0: UInt64, w1: UInt64, w2: UInt64, w3: UInt64, idx: Int) -> UInt64:
            if idx == 0:
                return w0
            if idx == 1:
                return w1
            if idx == 2:
                return w2
            if idx == 3:
                return w3
            return 0

        @always_inline
        fn _extract_window(w0: UInt64, w1: UInt64, w2: UInt64, w3: UInt64, bit_offset: Int) -> UInt8:
            var word_idx = bit_offset // 64
            var bit_in_word = bit_offset % 64
            var lo = _word_at(w0, w1, w2, w3, word_idx) >> UInt64(bit_in_word)
            if bit_in_word + W <= 64:
                return UInt8(lo & MASK)
            var hi = _word_at(w0, w1, w2, w3, word_idx + 1) << UInt64(64 - bit_in_word)
            return UInt8((lo | hi) & MASK)

        fn _msm_pippenger_block_kernel(
            bases_xy: UnsafePointer[UInt64, MutAnyOrigin],
            scalars_words: UnsafePointer[UInt64, MutAnyOrigin],
            out_xyz: UnsafePointer[UInt64, MutAnyOrigin],
            n: Int,
            num_windows: Int,
        ):
            var lane = Int(thread_idx.x)
            var block = Int(block_idx.x)
            var tid = lane + (block * BLOCK_SIZE)
            var block_size = Int(block_dim.x)

            var bases_sh = stack_allocation[
                BLOCK_SIZE * 12, DType.uint64, address_space = AddressSpace.SHARED
            ]()
            var digits_sh = stack_allocation[
                BLOCK_SIZE, DType.uint8, address_space = AddressSpace.SHARED
            ]()
            var buckets_sh = stack_allocation[
                BUCKET_COUNT * 18, DType.uint64, address_space = AddressSpace.SHARED
            ]()

            var w0: UInt64 = 0
            var w1: UInt64 = 0
            var w2: UInt64 = 0
            var w3: UInt64 = 0
            if tid < n:
                var b_off = tid * 12
                var x = _load_fp(bases_xy, b_off + 0)
                var y = _load_fp(bases_xy, b_off + 6)
                var base_sh = lane * 12
                bases_sh[base_sh + 0] = x.l0
                bases_sh[base_sh + 1] = x.l1
                bases_sh[base_sh + 2] = x.l2
                bases_sh[base_sh + 3] = x.l3
                bases_sh[base_sh + 4] = x.l4
                bases_sh[base_sh + 5] = x.l5
                bases_sh[base_sh + 6] = y.l0
                bases_sh[base_sh + 7] = y.l1
                bases_sh[base_sh + 8] = y.l2
                bases_sh[base_sh + 9] = y.l3
                bases_sh[base_sh + 10] = y.l4
                bases_sh[base_sh + 11] = y.l5

                var s_off = tid * 4
                var w = scalars_words.load[width=4](UInt(s_off))
                w0 = w[0]
                w1 = w[1]
                w2 = w[2]
                w3 = w[3]
            else:
                var base_sh = lane * 12
                for i in range(12):
                    bases_sh[base_sh + i] = 0

            barrier()

            var acc = _g1_identity()
            var wi: Int = 0
            while wi < num_windows:
                var window = (num_windows - 1) - wi
                var bit_offset = window * W

                digits_sh[lane] = (
                    _extract_window(w0, w1, w2, w3, bit_offset)
                    if tid < n
                    else UInt8(0)
                )
                barrier()

                var bid = lane
                while bid < BUCKET_COUNT:
                    var sum = _g1_identity()
                    if bid != 0:
                        for i in range(block_size):
                            if digits_sh[i] != UInt8(bid):
                                continue
                            var bo = i * 12
                            var x = Fp(
                                bases_sh[bo + 0],
                                bases_sh[bo + 1],
                                bases_sh[bo + 2],
                                bases_sh[bo + 3],
                                bases_sh[bo + 4],
                                bases_sh[bo + 5],
                            )
                            var y = Fp(
                                bases_sh[bo + 6],
                                bases_sh[bo + 7],
                                bases_sh[bo + 8],
                                bases_sh[bo + 9],
                                bases_sh[bo + 10],
                                bases_sh[bo + 11],
                            )
                            sum = _g1_add_affine(sum, x, y)

                    var so = bid * 18
                    buckets_sh[so + 0] = sum.x.l0
                    buckets_sh[so + 1] = sum.x.l1
                    buckets_sh[so + 2] = sum.x.l2
                    buckets_sh[so + 3] = sum.x.l3
                    buckets_sh[so + 4] = sum.x.l4
                    buckets_sh[so + 5] = sum.x.l5
                    buckets_sh[so + 6] = sum.y.l0
                    buckets_sh[so + 7] = sum.y.l1
                    buckets_sh[so + 8] = sum.y.l2
                    buckets_sh[so + 9] = sum.y.l3
                    buckets_sh[so + 10] = sum.y.l4
                    buckets_sh[so + 11] = sum.y.l5
                    buckets_sh[so + 12] = sum.z.l0
                    buckets_sh[so + 13] = sum.z.l1
                    buckets_sh[so + 14] = sum.z.l2
                    buckets_sh[so + 15] = sum.z.l3
                    buckets_sh[so + 16] = sum.z.l4
                    buckets_sh[so + 17] = sum.z.l5
                    bid += block_size

                barrier()

                if lane == 0:
                    var running = _g1_identity()
                    var win = _g1_identity()
                    for bj in range(BUCKET_COUNT - 1):
                        var b = (BUCKET_COUNT - 1) - bj
                        if b == 0:
                            break
                        var so = b * 18
                        var bx = Fp(
                            buckets_sh[so + 0],
                            buckets_sh[so + 1],
                            buckets_sh[so + 2],
                            buckets_sh[so + 3],
                            buckets_sh[so + 4],
                            buckets_sh[so + 5],
                        )
                        var by = Fp(
                            buckets_sh[so + 6],
                            buckets_sh[so + 7],
                            buckets_sh[so + 8],
                            buckets_sh[so + 9],
                            buckets_sh[so + 10],
                            buckets_sh[so + 11],
                        )
                        var bz = Fp(
                            buckets_sh[so + 12],
                            buckets_sh[so + 13],
                            buckets_sh[so + 14],
                            buckets_sh[so + 15],
                            buckets_sh[so + 16],
                            buckets_sh[so + 17],
                        )
                        running = _g1_add(running, G1Jacobian(bx, by, bz))
                        win = _g1_add(win, running)

                    for _ in range(W):
                        acc = _g1_double(acc)
                    acc = _g1_add(acc, win)

                barrier()

                wi += 1

            if lane == 0:
                var o_off = block * 18
                _store_fp(out_xyz, o_off + 0, acc.x)
                _store_fp(out_xyz, o_off + 6, acc.y)
                _store_fp(out_xyz, o_off + 12, acc.z)

        fn _reduce_partials_kernel(
            in_xyz: UnsafePointer[UInt64, MutAnyOrigin],
            out_xyz: UnsafePointer[UInt64, MutAnyOrigin],
            n_points: Int,
        ):
            var lane = Int(thread_idx.x)
            var block = Int(block_idx.x)
            var block_size = Int(block_dim.x)
            var start = block * block_size
            var idx = start + lane

            var partials_sh = stack_allocation[
                REDUCE_BLOCK_SIZE * 18, DType.uint64, address_space = AddressSpace.SHARED
            ]()

            var sum = _g1_identity()
            if idx < n_points:
                var off = idx * 18
                var x = _load_fp(in_xyz, off + 0)
                var y = _load_fp(in_xyz, off + 6)
                var z = _load_fp(in_xyz, off + 12)
                sum = G1Jacobian(x, y, z)

            var sh_off = lane * 18
            partials_sh[sh_off + 0] = sum.x.l0
            partials_sh[sh_off + 1] = sum.x.l1
            partials_sh[sh_off + 2] = sum.x.l2
            partials_sh[sh_off + 3] = sum.x.l3
            partials_sh[sh_off + 4] = sum.x.l4
            partials_sh[sh_off + 5] = sum.x.l5
            partials_sh[sh_off + 6] = sum.y.l0
            partials_sh[sh_off + 7] = sum.y.l1
            partials_sh[sh_off + 8] = sum.y.l2
            partials_sh[sh_off + 9] = sum.y.l3
            partials_sh[sh_off + 10] = sum.y.l4
            partials_sh[sh_off + 11] = sum.y.l5
            partials_sh[sh_off + 12] = sum.z.l0
            partials_sh[sh_off + 13] = sum.z.l1
            partials_sh[sh_off + 14] = sum.z.l2
            partials_sh[sh_off + 15] = sum.z.l3
            partials_sh[sh_off + 16] = sum.z.l4
            partials_sh[sh_off + 17] = sum.z.l5

            barrier()

            if lane == 0:
                var count = n_points - start
                if count > block_size:
                    count = block_size

                var acc = _g1_identity()
                for i in range(count):
                    var so = i * 18
                    var x = Fp(
                        partials_sh[so + 0],
                        partials_sh[so + 1],
                        partials_sh[so + 2],
                        partials_sh[so + 3],
                        partials_sh[so + 4],
                        partials_sh[so + 5],
                    )
                    var y = Fp(
                        partials_sh[so + 6],
                        partials_sh[so + 7],
                        partials_sh[so + 8],
                        partials_sh[so + 9],
                        partials_sh[so + 10],
                        partials_sh[so + 11],
                    )
                    var z = Fp(
                        partials_sh[so + 12],
                        partials_sh[so + 13],
                        partials_sh[so + 14],
                        partials_sh[so + 15],
                        partials_sh[so + 16],
                        partials_sh[so + 17],
                    )
                    acc = _g1_add(acc, G1Jacobian(x, y, z))

                var out_off = block * 18
                _store_fp(out_xyz, out_off + 0, acc.x)
                _store_fp(out_xyz, out_off + 6, acc.y)
                _store_fp(out_xyz, out_off + 12, acc.z)

        var n = len(scalars)
        if n == 0:
            return G1Jacobian.identity()

        if len(bases_xy) < (n * 12):
            raise Error("msm_pippenger_cuda_bases_dev: bases shorter than scalars")

        var scalars_host = ctx.enqueue_create_host_buffer[DType.uint64](n * 4)
        var threads = BLOCK_SIZE
        var blocks = (n + threads - 1) // threads
        ctx.synchronize()

        for i in range(n):
            # NOTE: `Fq` values are in Montgomery form internally (s*R mod r).
            # We avoid per-scalar Montgomery reduction by feeding the raw limbs
            # as the scalar integer, producing an MSM result scaled by R. We
            # correct with a single multiply by R^{-1} at the end.
            var s = scalars[i]
            var so = i * 4
            scalars_host[so + 0] = s.l0
            scalars_host[so + 1] = s.l1
            scalars_host[so + 2] = s.l2
            scalars_host[so + 3] = s.l3

        var scalars_dev = ctx.enqueue_create_buffer[DType.uint64](n * 4)
        var partials_dev = ctx.enqueue_create_buffer[DType.uint64](blocks * 18)
        scalars_dev.enqueue_copy_from(scalars_host.unsafe_ptr())

        ctx.enqueue_function_experimental[_msm_pippenger_block_kernel](
            bases_xy,
            scalars_dev,
            partials_dev,
            n,
            NUM_WINDOWS,
            grid_dim=blocks,
            block_dim=threads,
        )

        var reduced_dev = partials_dev
        var reduce_count = blocks
        while reduce_count > 1:
            var next_count = (reduce_count + REDUCE_BLOCK_SIZE - 1) // REDUCE_BLOCK_SIZE
            var next_dev = ctx.enqueue_create_buffer[DType.uint64](next_count * 18)
            ctx.enqueue_function_experimental[_reduce_partials_kernel](
                reduced_dev,
                next_dev,
                reduce_count,
                grid_dim=next_count,
                block_dim=REDUCE_BLOCK_SIZE,
            )
            reduced_dev = next_dev
            reduce_count = next_count

        var out_host = ctx.enqueue_create_host_buffer[DType.uint64](18)
        reduced_dev.enqueue_copy_to(out_host.unsafe_ptr())
        ctx.synchronize()

        var x = Fp(
            out_host[0],
            out_host[1],
            out_host[2],
            out_host[3],
            out_host[4],
            out_host[5],
        )
        var y = Fp(
            out_host[6],
            out_host[7],
            out_host[8],
            out_host[9],
            out_host[10],
            out_host[11],
        )
        var z = Fp(
            out_host[12],
            out_host[13],
            out_host[14],
            out_host[15],
            out_host[16],
            out_host[17],
        )
        var acc = G1Jacobian(x, y, z)

        # Undo the Montgomery factor: MSM computed with scalars (s*R) gives R*C.
        return acc.mul_scalar(Fq(1, 0, 0, 0))


fn msm_pippenger_cuda(bases: List[G1Affine], scalars: List[Fq]) raises -> G1Jacobian:
    @parameter
    if CompilationTarget.is_macos() and not ENABLE_METAL_GPU:
        raise Error(
            "GPU MSM is disabled on macOS builds. Run with `-D NMB_ENABLE_METAL_GPU=true` to enable Metal."
        )
    else:
        var n = len(scalars)
        if n == 0:
            return G1Jacobian.identity()
        if len(bases) < n:
            raise Error("msm_pippenger_cuda: bases shorter than scalars")

        var api = "cuda"
        @parameter
        if CompilationTarget.is_macos():
            api = "metal"

        with DeviceContext(api=api) as ctx:
            var bases_host = ctx.enqueue_create_host_buffer[DType.uint64](n * 12)
            ctx.synchronize()

            for i in range(n):
                var b = bases[i]
                var bo = i * 12
                bases_host[bo + 0] = b.x.l0
                bases_host[bo + 1] = b.x.l1
                bases_host[bo + 2] = b.x.l2
                bases_host[bo + 3] = b.x.l3
                bases_host[bo + 4] = b.x.l4
                bases_host[bo + 5] = b.x.l5
                bases_host[bo + 6] = b.y.l0
                bases_host[bo + 7] = b.y.l1
                bases_host[bo + 8] = b.y.l2
                bases_host[bo + 9] = b.y.l3
                bases_host[bo + 10] = b.y.l4
                bases_host[bo + 11] = b.y.l5

            var bases_dev = ctx.enqueue_create_buffer[DType.uint64](n * 12)
            bases_dev.enqueue_copy_from(bases_host.unsafe_ptr())

            return msm_pippenger_cuda_bases_dev(ctx, bases_dev, scalars)
