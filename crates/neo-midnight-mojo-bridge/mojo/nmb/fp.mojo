from collections import List


struct U64x6(Copyable, ImplicitlyCopyable, Movable):
    var w0: UInt64
    var w1: UInt64
    var w2: UInt64
    var w3: UInt64
    var w4: UInt64
    var w5: UInt64

    fn __init__(
        out self,
        w0: UInt64,
        w1: UInt64,
        w2: UInt64,
        w3: UInt64,
        w4: UInt64,
        w5: UInt64,
    ):
        self.w0 = w0
        self.w1 = w1
        self.w2 = w2
        self.w3 = w3
        self.w4 = w4
        self.w5 = w5

    fn __copyinit__(out self, existing: Self):
        self.w0 = existing.w0
        self.w1 = existing.w1
        self.w2 = existing.w2
        self.w3 = existing.w3
        self.w4 = existing.w4
        self.w5 = existing.w5


struct Sub64(Copyable, ImplicitlyCopyable, Movable):
    var res: UInt64
    var borrow: UInt64

    fn __init__(out self, res: UInt64, borrow: UInt64):
        self.res = res
        self.borrow = borrow

    fn __copyinit__(out self, existing: Self):
        self.res = existing.res
        self.borrow = existing.borrow


struct Fp(Copyable, ImplicitlyCopyable, Movable):
    # Montgomery form, little-endian 64-bit limbs (blst_fp layout).
    var l0: UInt64
    var l1: UInt64
    var l2: UInt64
    var l3: UInt64
    var l4: UInt64
    var l5: UInt64

    fn __init__(
        out self,
        l0: UInt64,
        l1: UInt64,
        l2: UInt64,
        l3: UInt64,
        l4: UInt64,
        l5: UInt64,
    ):
        self.l0 = l0
        self.l1 = l1
        self.l2 = l2
        self.l3 = l3
        self.l4 = l4
        self.l5 = l5

    fn __copyinit__(out self, existing: Self):
        self.l0 = existing.l0
        self.l1 = existing.l1
        self.l2 = existing.l2
        self.l3 = existing.l3
        self.l4 = existing.l4
        self.l5 = existing.l5

    @staticmethod
    fn zero() -> Fp:
        return Fp(0, 0, 0, 0, 0, 0)

    @staticmethod
    fn one() -> Fp:
        # R = 2^384 mod p (represents 1 in Montgomery form).
        return Fp(
            0x7609_0000_0002_FFFD,
            0xEBF4_000B_C40C_0002,
            0x5F48_9857_53C7_58BA,
            0x77CE_5853_7052_5745,
            0x5C07_1A97_A256_EC6D,
            0x15F6_5EC3_FA80_E493,
        )

    fn is_zero(self) -> Bool:
        return (
            self.l0 == 0
            and self.l1 == 0
            and self.l2 == 0
            and self.l3 == 0
            and self.l4 == 0
            and self.l5 == 0
        )

    @staticmethod
    fn modulus_words() -> U64x6:
        # Little-endian modulus limbs (non-Montgomery).
        return U64x6(
            0xB9FE_FFFF_FFFF_AAAB,
            0x1EAB_FFFE_B153_FFFF,
            0x6730_D2A0_F6B0_F624,
            0x6477_4B84_F385_12BF,
            0x4B1B_A7B6_434B_ACD7,
            0x1A01_11EA_397F_E69A,
        )

    @staticmethod
    fn r2_words() -> U64x6:
        # R^2 = 2^(384*2) mod p, as raw limbs (non-Montgomery integer).
        return U64x6(
            0xF4DF_1F34_1C34_1746,
            0x0A76_E6A6_09D1_04F1,
            0x8DE5_476C_4C95_B6D5,
            0x67EB_88A9_939D_83C0,
            0x9A79_3E85_B519_952D,
            0x1198_8FE5_92CA_E3AA,
        )

    @staticmethod
    fn inv64() -> UInt64:
        # INV = -(p^{-1} mod 2^64) mod 2^64.
        return 0x89F3_FFFC_FFFC_FFFD

    @staticmethod
    fn from_canonical_words(c: U64x6) raises -> Fp:
        var m = Fp.modulus_words()
        if Fp._geq_u64x6(c, m):
            raise Error("Fp::from_canonical_words: non-canonical")

        var r2 = Fp.r2_words()
        var raw = Fp._mont_mul_raw(c, r2)
        return Fp(raw.w0, raw.w1, raw.w2, raw.w3, raw.w4, raw.w5)

    @staticmethod
    fn _sub64(a: UInt64, b: UInt64, borrow: UInt64) -> Sub64:
        var bb = UInt128(b) + UInt128(borrow)
        if UInt128(a) >= bb:
            return Sub64(a - UInt64(bb), 0)
        return Sub64(a - UInt64(bb), 1)

    @staticmethod
    fn _geq_u64x6(a: U64x6, b: U64x6) -> Bool:
        if a.w5 > b.w5:
            return True
        if a.w5 < b.w5:
            return False
        if a.w4 > b.w4:
            return True
        if a.w4 < b.w4:
            return False
        if a.w3 > b.w3:
            return True
        if a.w3 < b.w3:
            return False
        if a.w2 > b.w2:
            return True
        if a.w2 < b.w2:
            return False
        if a.w1 > b.w1:
            return True
        if a.w1 < b.w1:
            return False
        return a.w0 >= b.w0

    fn to_canonical_words(self) -> U64x6:
        return Fp._mont_mul_raw(
            U64x6(self.l0, self.l1, self.l2, self.l3, self.l4, self.l5),
            U64x6(1, 0, 0, 0, 0, 0),
        )

    fn to_bytes_be(self) -> List[Byte]:
        var c = self.to_canonical_words()
        var out = List[Byte]()
        var limb: UInt64

        limb = c.w5
        out.append(Byte(UInt8((limb >> 56) & 0xFF)))
        out.append(Byte(UInt8((limb >> 48) & 0xFF)))
        out.append(Byte(UInt8((limb >> 40) & 0xFF)))
        out.append(Byte(UInt8((limb >> 32) & 0xFF)))
        out.append(Byte(UInt8((limb >> 24) & 0xFF)))
        out.append(Byte(UInt8((limb >> 16) & 0xFF)))
        out.append(Byte(UInt8((limb >> 8) & 0xFF)))
        out.append(Byte(UInt8(limb & 0xFF)))

        limb = c.w4
        out.append(Byte(UInt8((limb >> 56) & 0xFF)))
        out.append(Byte(UInt8((limb >> 48) & 0xFF)))
        out.append(Byte(UInt8((limb >> 40) & 0xFF)))
        out.append(Byte(UInt8((limb >> 32) & 0xFF)))
        out.append(Byte(UInt8((limb >> 24) & 0xFF)))
        out.append(Byte(UInt8((limb >> 16) & 0xFF)))
        out.append(Byte(UInt8((limb >> 8) & 0xFF)))
        out.append(Byte(UInt8(limb & 0xFF)))

        limb = c.w3
        out.append(Byte(UInt8((limb >> 56) & 0xFF)))
        out.append(Byte(UInt8((limb >> 48) & 0xFF)))
        out.append(Byte(UInt8((limb >> 40) & 0xFF)))
        out.append(Byte(UInt8((limb >> 32) & 0xFF)))
        out.append(Byte(UInt8((limb >> 24) & 0xFF)))
        out.append(Byte(UInt8((limb >> 16) & 0xFF)))
        out.append(Byte(UInt8((limb >> 8) & 0xFF)))
        out.append(Byte(UInt8(limb & 0xFF)))

        limb = c.w2
        out.append(Byte(UInt8((limb >> 56) & 0xFF)))
        out.append(Byte(UInt8((limb >> 48) & 0xFF)))
        out.append(Byte(UInt8((limb >> 40) & 0xFF)))
        out.append(Byte(UInt8((limb >> 32) & 0xFF)))
        out.append(Byte(UInt8((limb >> 24) & 0xFF)))
        out.append(Byte(UInt8((limb >> 16) & 0xFF)))
        out.append(Byte(UInt8((limb >> 8) & 0xFF)))
        out.append(Byte(UInt8(limb & 0xFF)))

        limb = c.w1
        out.append(Byte(UInt8((limb >> 56) & 0xFF)))
        out.append(Byte(UInt8((limb >> 48) & 0xFF)))
        out.append(Byte(UInt8((limb >> 40) & 0xFF)))
        out.append(Byte(UInt8((limb >> 32) & 0xFF)))
        out.append(Byte(UInt8((limb >> 24) & 0xFF)))
        out.append(Byte(UInt8((limb >> 16) & 0xFF)))
        out.append(Byte(UInt8((limb >> 8) & 0xFF)))
        out.append(Byte(UInt8(limb & 0xFF)))

        limb = c.w0
        out.append(Byte(UInt8((limb >> 56) & 0xFF)))
        out.append(Byte(UInt8((limb >> 48) & 0xFF)))
        out.append(Byte(UInt8((limb >> 40) & 0xFF)))
        out.append(Byte(UInt8((limb >> 32) & 0xFF)))
        out.append(Byte(UInt8((limb >> 24) & 0xFF)))
        out.append(Byte(UInt8((limb >> 16) & 0xFF)))
        out.append(Byte(UInt8((limb >> 8) & 0xFF)))
        out.append(Byte(UInt8(limb & 0xFF)))

        return out^

    fn add(self, rhs: Fp) -> Fp:
        var m = Fp.modulus_words()
        var carry: UInt128 = 0

        var s0 = UInt128(self.l0) + UInt128(rhs.l0) + carry
        var r0 = UInt64(s0)
        carry = s0 >> 64

        var s1 = UInt128(self.l1) + UInt128(rhs.l1) + carry
        var r1 = UInt64(s1)
        carry = s1 >> 64

        var s2 = UInt128(self.l2) + UInt128(rhs.l2) + carry
        var r2 = UInt64(s2)
        carry = s2 >> 64

        var s3 = UInt128(self.l3) + UInt128(rhs.l3) + carry
        var r3 = UInt64(s3)
        carry = s3 >> 64

        var s4 = UInt128(self.l4) + UInt128(rhs.l4) + carry
        var r4 = UInt64(s4)
        carry = s4 >> 64

        var s5 = UInt128(self.l5) + UInt128(rhs.l5) + carry
        var r5 = UInt64(s5)
        carry = s5 >> 64

        var out = U64x6(r0, r1, r2, r3, r4, r5)
        if carry != 0 or Fp._geq_u64x6(out, m):
            var d0 = Fp._sub64(out.w0, m.w0, 0)
            var d1 = Fp._sub64(out.w1, m.w1, d0.borrow)
            var d2 = Fp._sub64(out.w2, m.w2, d1.borrow)
            var d3 = Fp._sub64(out.w3, m.w3, d2.borrow)
            var d4 = Fp._sub64(out.w4, m.w4, d3.borrow)
            var d5 = Fp._sub64(out.w5, m.w5, d4.borrow)
            out = U64x6(d0.res, d1.res, d2.res, d3.res, d4.res, d5.res)
        return Fp(out.w0, out.w1, out.w2, out.w3, out.w4, out.w5)

    fn sub(self, rhs: Fp) -> Fp:
        var m = Fp.modulus_words()
        var d0 = Fp._sub64(self.l0, rhs.l0, 0)
        var d1 = Fp._sub64(self.l1, rhs.l1, d0.borrow)
        var d2 = Fp._sub64(self.l2, rhs.l2, d1.borrow)
        var d3 = Fp._sub64(self.l3, rhs.l3, d2.borrow)
        var d4 = Fp._sub64(self.l4, rhs.l4, d3.borrow)
        var d5 = Fp._sub64(self.l5, rhs.l5, d4.borrow)

        var out = U64x6(d0.res, d1.res, d2.res, d3.res, d4.res, d5.res)
        if d5.borrow != 0:
            var carry: UInt128 = 0
            var s0 = UInt128(out.w0) + UInt128(m.w0) + carry
            out.w0 = UInt64(s0)
            carry = s0 >> 64
            var s1 = UInt128(out.w1) + UInt128(m.w1) + carry
            out.w1 = UInt64(s1)
            carry = s1 >> 64
            var s2 = UInt128(out.w2) + UInt128(m.w2) + carry
            out.w2 = UInt64(s2)
            carry = s2 >> 64
            var s3 = UInt128(out.w3) + UInt128(m.w3) + carry
            out.w3 = UInt64(s3)
            carry = s3 >> 64
            var s4 = UInt128(out.w4) + UInt128(m.w4) + carry
            out.w4 = UInt64(s4)
            carry = s4 >> 64
            var s5 = UInt128(out.w5) + UInt128(m.w5) + carry
            out.w5 = UInt64(s5)
        return Fp(out.w0, out.w1, out.w2, out.w3, out.w4, out.w5)

    fn neg(self) -> Fp:
        if self.is_zero():
            return self
        return Fp.zero().sub(self)

    fn mul(self, rhs: Fp) -> Fp:
        var out = Fp._mont_mul_raw(
            U64x6(self.l0, self.l1, self.l2, self.l3, self.l4, self.l5),
            U64x6(rhs.l0, rhs.l1, rhs.l2, rhs.l3, rhs.l4, rhs.l5),
        )
        return Fp(out.w0, out.w1, out.w2, out.w3, out.w4, out.w5)

    fn square(self) -> Fp:
        return self.mul(self)

    fn pow(self, exp_le_words: List[UInt64]) -> Fp:
        var acc = Fp.one()
        var base = self
        for w in exp_le_words:
            var word = w
            for _ in range(64):
                if (word & 1) != 0:
                    acc = acc.mul(base)
                word >>= 1
                base = base.square()
        return acc

    fn invert(self) -> Fp:
        # Fermat: a^(p-2). Slow but fine for correctness.
        var m = Fp.modulus_words()
        var e = List[UInt64]()
        e.append(m.w0 - 2)
        e.append(m.w1)
        e.append(m.w2)
        e.append(m.w3)
        e.append(m.w4)
        e.append(m.w5)
        return self.pow(e)

    @staticmethod
    fn _mont_mul_raw(a: U64x6, b: U64x6) -> U64x6:
        # Straightforward Montgomery multiplication using a 12-limb accumulator.
        var m = Fp.modulus_words()
        var inv = Fp.inv64()

        var aw = InlineArray[UInt64, 6](uninitialized=True)
        aw[0] = a.w0
        aw[1] = a.w1
        aw[2] = a.w2
        aw[3] = a.w3
        aw[4] = a.w4
        aw[5] = a.w5

        var bw = InlineArray[UInt64, 6](uninitialized=True)
        bw[0] = b.w0
        bw[1] = b.w1
        bw[2] = b.w2
        bw[3] = b.w3
        bw[4] = b.w4
        bw[5] = b.w5

        var mw = InlineArray[UInt64, 6](uninitialized=True)
        mw[0] = m.w0
        mw[1] = m.w1
        mw[2] = m.w2
        mw[3] = m.w3
        mw[4] = m.w4
        mw[5] = m.w5

        var t = InlineArray[UInt64, 12](uninitialized=True)
        for i in range(12):
            t[i] = 0

        # t += a*b
        for i in range(6):
            var carry: UInt128 = 0
            var bi = bw[i]
            for j in range(6):
                var uv = UInt128(t[i + j]) + UInt128(aw[j]) * UInt128(bi) + carry
                t[i + j] = UInt64(uv)
                carry = uv >> 64
            var k = i + 6
            var uv2 = UInt128(t[k]) + carry
            t[k] = UInt64(uv2)
            var carry2 = uv2 >> 64
            k += 1
            while carry2 != 0 and k < 12:
                uv2 = UInt128(t[k]) + carry2
                t[k] = UInt64(uv2)
                carry2 = uv2 >> 64
                k += 1

        # Montgomery reduction.
        for i in range(6):
            var m_i = UInt64(UInt128(t[i]) * UInt128(inv))
            var carry: UInt128 = 0
            for j in range(6):
                var uv = UInt128(t[i + j]) + UInt128(m_i) * UInt128(mw[j]) + carry
                t[i + j] = UInt64(uv)
                carry = uv >> 64
            var k = i + 6
            var uv2 = UInt128(t[k]) + carry
            t[k] = UInt64(uv2)
            var carry2 = uv2 >> 64
            k += 1
            while carry2 != 0 and k < 12:
                uv2 = UInt128(t[k]) + carry2
                t[k] = UInt64(uv2)
                carry2 = uv2 >> 64
                k += 1

        var out = U64x6(t[6], t[7], t[8], t[9], t[10], t[11])
        if Fp._geq_u64x6(out, m):
            var d0 = Fp._sub64(out.w0, m.w0, 0)
            var d1 = Fp._sub64(out.w1, m.w1, d0.borrow)
            var d2 = Fp._sub64(out.w2, m.w2, d1.borrow)
            var d3 = Fp._sub64(out.w3, m.w3, d2.borrow)
            var d4 = Fp._sub64(out.w4, m.w4, d3.borrow)
            var d5 = Fp._sub64(out.w5, m.w5, d4.borrow)
            out = U64x6(d0.res, d1.res, d2.res, d3.res, d4.res, d5.res)
        return out
