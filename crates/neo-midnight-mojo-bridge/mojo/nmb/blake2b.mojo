from collections import List


comptime _IV: InlineArray[UInt64, 8] = [
    0x6A09_E667_F3BC_C908,
    0xBB67_AE85_84CA_A73B,
    0x3C6E_F372_FE94_F82B,
    0xA54F_F53A_5F1D_36F1,
    0x510E_527F_ADE6_82D1,
    0x9B05_688C_2B3E_6C1F,
    0x1F83_D9AB_FB41_BD6B,
    0x5BE0_CD19_137E_2179,
]

# Sigma table (12 rounds × 16 message word indices).
comptime _SIGMA: InlineArray[UInt8, 192] = [
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3,
    11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4,
    7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8,
    9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13,
    2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9,
    12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11,
    13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10,
    6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5,
    10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0,
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3,
]


@always_inline
fn _rotr64(x: UInt64, n: UInt8) -> UInt64:
    var nn: UInt64 = UInt64(n)
    return (x >> nn) | (x << (UInt64(64) - nn))


@always_inline
fn _load_u64_le(block: InlineArray[UInt8, 128], off: Int) -> UInt64:
    return (
        UInt64(block[off + 0])
        | (UInt64(block[off + 1]) << 8)
        | (UInt64(block[off + 2]) << 16)
        | (UInt64(block[off + 3]) << 24)
        | (UInt64(block[off + 4]) << 32)
        | (UInt64(block[off + 5]) << 40)
        | (UInt64(block[off + 6]) << 48)
        | (UInt64(block[off + 7]) << 56)
    )


@always_inline
fn _g(
    mut v: InlineArray[UInt64, 16],
    a: Int,
    b: Int,
    c: Int,
    d: Int,
    x: UInt64,
    y: UInt64,
):
    v[a] = v[a] + v[b] + x
    v[d] = _rotr64(v[d] ^ v[a], 32)
    v[c] = v[c] + v[d]
    v[b] = _rotr64(v[b] ^ v[c], 24)
    v[a] = v[a] + v[b] + y
    v[d] = _rotr64(v[d] ^ v[a], 16)
    v[c] = v[c] + v[d]
    v[b] = _rotr64(v[b] ^ v[c], 63)


fn _compress(
    mut h: InlineArray[UInt64, 8],
    block: InlineArray[UInt8, 128],
    t0: UInt64,
    t1: UInt64,
    f0: UInt64,
    f1: UInt64,
) -> InlineArray[UInt64, 8]:
    var m = InlineArray[UInt64, 16](uninitialized=True)
    for i in range(16):
        m[i] = _load_u64_le(block, i * 8)

    var v = InlineArray[UInt64, 16](uninitialized=True)
    for i in range(8):
        v[i] = h[i]
        v[i + 8] = _IV[i]

    v[12] = v[12] ^ t0
    v[13] = v[13] ^ t1
    v[14] = v[14] ^ f0
    v[15] = v[15] ^ f1

    for r in range(12):
        var off = r * 16

        _g(v, 0, 4, 8, 12, m[Int(_SIGMA[off + 0])], m[Int(_SIGMA[off + 1])])
        _g(v, 1, 5, 9, 13, m[Int(_SIGMA[off + 2])], m[Int(_SIGMA[off + 3])])
        _g(v, 2, 6, 10, 14, m[Int(_SIGMA[off + 4])], m[Int(_SIGMA[off + 5])])
        _g(v, 3, 7, 11, 15, m[Int(_SIGMA[off + 6])], m[Int(_SIGMA[off + 7])])

        _g(v, 0, 5, 10, 15, m[Int(_SIGMA[off + 8])], m[Int(_SIGMA[off + 9])])
        _g(v, 1, 6, 11, 12, m[Int(_SIGMA[off + 10])], m[Int(_SIGMA[off + 11])])
        _g(v, 2, 7, 8, 13, m[Int(_SIGMA[off + 12])], m[Int(_SIGMA[off + 13])])
        _g(v, 3, 4, 9, 14, m[Int(_SIGMA[off + 14])], m[Int(_SIGMA[off + 15])])

    for i in range(8):
        h[i] = h[i] ^ v[i] ^ v[i + 8]
    return h


struct Blake2bState(Movable):
    # BLAKE2b state (64-byte digest only).
    var h: InlineArray[UInt64, 8]
    var t0: UInt64
    var t1: UInt64
    var buf: InlineArray[UInt8, 128]
    var buf_len: Int

    fn __init__(out self, h: InlineArray[UInt64, 8], t0: UInt64, t1: UInt64):
        self.h = h
        self.t0 = t0
        self.t1 = t1
        self.buf = InlineArray[UInt8, 128](fill=0)
        self.buf_len = 0

    @staticmethod
    fn init_keyed(key: List[Byte]) raises -> Blake2bState:
        if len(key) > 64:
            raise Error("Blake2bState: key too long")

        var h = InlineArray[UInt64, 8](uninitialized=True)
        for i in range(8):
            h[i] = _IV[i]

        # Parameter block (only word0 differs from zero for our use).
        # digest_len=64, key_len, fanout=1, depth=1.
        var p0: UInt64 = UInt64(64) | (UInt64(len(key)) << 8) | (UInt64(1) << 16) | (UInt64(1) << 24)
        h[0] = h[0] ^ p0

        var st = Blake2bState(h, 0, 0)

        if len(key) != 0:
            var block = List[Byte]()
            for b in key:
                block.append(b)
            for _ in range(128 - len(key)):
                block.append(Byte(0))
            st.update(block)

        return st^

    fn update(mut self, input: List[Byte]):
        var i: Int = 0
        while i < len(input):
            if self.buf_len == 128:
                # Compress full buffer (not final).
                var new_t0 = self.t0 + 128
                if new_t0 < self.t0:
                    self.t1 = self.t1 + 1
                self.t0 = new_t0
                self.h = _compress(self.h, self.buf, self.t0, self.t1, 0, 0)
                self.buf_len = 0

            var take = 128 - self.buf_len
            var remaining = len(input) - i
            if remaining < take:
                take = remaining

            for j in range(take):
                self.buf[self.buf_len + j] = UInt8(input[i + j])
            self.buf_len += take
            i += take

    fn update_u8(mut self, b: UInt8):
        var tmp = List[Byte]()
        tmp.append(Byte(b))
        self.update(tmp)

    fn digest(self) -> List[Byte]:
        # Finalize on a clone of the state, leaving `self` unchanged.
        var h = InlineArray[UInt64, 8](uninitialized=True)
        for i in range(8):
            h[i] = self.h[i]

        var t0 = self.t0
        var t1 = self.t1

        var buf = InlineArray[UInt8, 128](fill=0)
        for i in range(self.buf_len):
            buf[i] = self.buf[i]

        var new_t0 = t0 + UInt64(self.buf_len)
        if new_t0 < t0:
            t1 = t1 + 1
        t0 = new_t0

        # f0 = all-ones indicates final block.
        h = _compress(h, buf, t0, t1, 0xFFFF_FFFF_FFFF_FFFF, 0)

        var out = List[Byte]()
        for i in range(8):
            var w = h[i]
            out.append(Byte(UInt8(w & 0xFF)))
            out.append(Byte(UInt8((w >> 8) & 0xFF)))
            out.append(Byte(UInt8((w >> 16) & 0xFF)))
            out.append(Byte(UInt8((w >> 24) & 0xFF)))
            out.append(Byte(UInt8((w >> 32) & 0xFF)))
            out.append(Byte(UInt8((w >> 40) & 0xFF)))
            out.append(Byte(UInt8((w >> 48) & 0xFF)))
            out.append(Byte(UInt8((w >> 56) & 0xFF)))
        return out^
