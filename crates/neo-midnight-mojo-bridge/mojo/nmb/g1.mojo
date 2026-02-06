from collections import List

from nmb.fq import Fq
from nmb.fp import Fp


struct G1Affine(Copyable, ImplicitlyCopyable, Movable):
    var x: Fp
    var y: Fp
    var infinity: Bool

    fn __init__(out self, x: Fp, y: Fp, infinity: Bool):
        self.x = x
        self.y = y
        self.infinity = infinity

    fn __copyinit__(out self, existing: Self):
        self.x = existing.x
        self.y = existing.y
        self.infinity = existing.infinity

    @staticmethod
    fn identity() -> G1Affine:
        return G1Affine(Fp.zero(), Fp.zero(), True)


struct G1Jacobian(Copyable, ImplicitlyCopyable, Movable):
    var x: Fp
    var y: Fp
    var z: Fp

    fn __init__(out self, x: Fp, y: Fp, z: Fp):
        self.x = x
        self.y = y
        self.z = z

    fn __copyinit__(out self, existing: Self):
        self.x = existing.x
        self.y = existing.y
        self.z = existing.z

    @staticmethod
    fn identity() -> G1Jacobian:
        # Convention: Z=0 means infinity.
        return G1Jacobian(Fp.zero(), Fp.one(), Fp.zero())

    fn is_identity(self) -> Bool:
        return self.z.is_zero()

    @staticmethod
    fn from_affine(p: G1Affine) -> G1Jacobian:
        if p.infinity:
            return G1Jacobian.identity()
        return G1Jacobian(p.x, p.y, Fp.one())

    fn to_affine(self) -> G1Affine:
        if self.is_identity():
            return G1Affine.identity()
        var zinv = self.z.invert()
        var zinv2 = zinv.square()
        var zinv3 = zinv2.mul(zinv)
        var x = self.x.mul(zinv2)
        var y = self.y.mul(zinv3)
        return G1Affine(x, y, False)

    fn double(self) -> G1Jacobian:
        if self.is_identity():
            return self
        if self.y.is_zero():
            return G1Jacobian.identity()

        # dbl-2007-bl for a=0.
        var a = self.x.square()  # A
        var b = self.y.square()  # B
        var c = b.square()  # C

        var x_plus_b = self.x.add(b)
        var x_plus_b_sq = x_plus_b.square()
        var d_tmp = x_plus_b_sq.sub(a).sub(c)
        var d = d_tmp.add(d_tmp)  # 2*(...)

        var e = a.add(a).add(a)  # 3*A
        var f = e.square()

        var x3 = f.sub(d.add(d))
        var c8 = c.add(c).add(c).add(c).add(c).add(c).add(c).add(c)
        var y3 = e.mul(d.sub(x3)).sub(c8)  # -8*C
        var y1z1 = self.y.mul(self.z)
        var z3 = y1z1.add(y1z1)  # 2*Y1*Z1
        return G1Jacobian(x3, y3, z3)

    fn add_affine(self, q: G1Affine) -> G1Jacobian:
        if q.infinity:
            return self
        if self.is_identity():
            return G1Jacobian.from_affine(q)

        # madd-2007-bl for a=0.
        var z1z1 = self.z.square()
        var u2 = q.x.mul(z1z1)
        var s2 = q.y.mul(self.z.mul(z1z1))

        var h = u2.sub(self.x)
        var r_tmp = s2.sub(self.y)
        var r = r_tmp.add(r_tmp)  # 2*(S2 - Y1)

        if h.is_zero():
            if r.is_zero():
                return self.double()
            return G1Jacobian.identity()

        var hh = h.square()
        var i = hh.add(hh).add(hh).add(hh)  # 4*HH
        var j = h.mul(i)
        var v = self.x.mul(i)

        var x3 = r.square().sub(j).sub(v.add(v))
        var y1j2 = self.y.mul(j).add(self.y.mul(j))
        var y3 = r.mul(v.sub(x3)).sub(y1j2)
        var z3 = self.z.add(h).square().sub(z1z1).sub(hh)
        return G1Jacobian(x3, y3, z3)

    fn add(self, q: G1Jacobian) -> G1Jacobian:
        if q.is_identity():
            return self
        if self.is_identity():
            return q

        var z1z1 = self.z.square()
        var z2z2 = q.z.square()
        var u1 = self.x.mul(z2z2)
        var u2 = q.x.mul(z1z1)
        var s1 = self.y.mul(q.z.mul(z2z2))
        var s2 = q.y.mul(self.z.mul(z1z1))

        var h = u2.sub(u1)
        var r_tmp = s2.sub(s1)
        var r = r_tmp.add(r_tmp)

        if h.is_zero():
            if r.is_zero():
                return self.double()
            return G1Jacobian.identity()

        var hh = h.square()
        var i = hh.add(hh).add(hh).add(hh)
        var j = h.mul(i)
        var v = u1.mul(i)
        var x3 = r.square().sub(j).sub(v.add(v))
        var s1j2 = s1.mul(j).add(s1.mul(j))
        var y3 = r.mul(v.sub(x3)).sub(s1j2)
        var z3 = self.z.add(q.z).square().sub(z1z1).sub(z2z2).mul(h)
        return G1Jacobian(x3, y3, z3)

    fn mul_scalar(self, k: Fq) -> G1Jacobian:
        # Double-and-add, variable-time.
        var acc = G1Jacobian.identity()
        var base_aff = self.to_affine()
        var w = k.to_canonical_words()

        # Iterate bits from most significant to least.
        for bit_index in range(256):
            # 255..0
            var i = 255 - bit_index
            acc = acc.double()

            var word_index = i // 64
            var bit_in_word = i % 64

            var word: UInt64
            if word_index == 0:
                word = w.w0
            elif word_index == 1:
                word = w.w1
            elif word_index == 2:
                word = w.w2
            else:
                word = w.w3

            if ((word >> bit_in_word) & 1) != 0:
                acc = acc.add_affine(base_aff)

        return acc


fn g1_compress(p: G1Affine) -> List[Byte]:
    # IETF BLS12-381 G1 compressed format (48 bytes).
    var out = List[Byte]()
    for _ in range(48):
        out.append(Byte(0))

    if p.infinity:
        out[0] = Byte(0xC0)  # compression + infinity
        return out^

    var xb = p.x.to_bytes_be()
    # Clear high 3 bits, then set compression flag.
    xb[0] = Byte(UInt8(UInt8(xb[0]) & 0x1F))
    xb[0] = Byte(UInt8(UInt8(xb[0]) | 0x80))

    # Determine sign bit from y.
    var y = p.y.to_canonical_words()
    var m = Fp.modulus_words()

    # Compute neg_y = p - y in canonical limbs.
    var ny0: UInt64
    var ny1: UInt64
    var ny2: UInt64
    var ny3: UInt64
    var ny4: UInt64
    var ny5: UInt64
    var borrow: UInt64
    var s0 = Fp._sub64(m.w0, y.w0, 0)
    ny0 = s0.res
    borrow = s0.borrow
    var s1 = Fp._sub64(m.w1, y.w1, borrow)
    ny1 = s1.res
    borrow = s1.borrow
    var s2 = Fp._sub64(m.w2, y.w2, borrow)
    ny2 = s2.res
    borrow = s2.borrow
    var s3 = Fp._sub64(m.w3, y.w3, borrow)
    ny3 = s3.res
    borrow = s3.borrow
    var s4 = Fp._sub64(m.w4, y.w4, borrow)
    ny4 = s4.res
    borrow = s4.borrow
    var s5 = Fp._sub64(m.w5, y.w5, borrow)
    ny5 = s5.res

    var y_is_largest = (
        (y.w5 > ny5)
        or (y.w5 == ny5 and y.w4 > ny4)
        or (y.w5 == ny5 and y.w4 == ny4 and y.w3 > ny3)
        or (y.w5 == ny5 and y.w4 == ny4 and y.w3 == ny3 and y.w2 > ny2)
        or (y.w5 == ny5 and y.w4 == ny4 and y.w3 == ny3 and y.w2 == ny2 and y.w1 > ny1)
        or (y.w5 == ny5 and y.w4 == ny4 and y.w3 == ny3 and y.w2 == ny2 and y.w1 == ny1 and y.w0 > ny0)
    )
    if y_is_largest:
        xb[0] = Byte(UInt8(UInt8(xb[0]) | 0x20))

    # Copy x bytes.
    for i in range(48):
        out[i] = xb[i]
    return out^
