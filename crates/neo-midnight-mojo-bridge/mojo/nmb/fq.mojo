from collections import List


struct U64x4(Copyable, ImplicitlyCopyable, Movable):
    var w0: UInt64
    var w1: UInt64
    var w2: UInt64
    var w3: UInt64

    fn __init__(out self, w0: UInt64, w1: UInt64, w2: UInt64, w3: UInt64):
        self.w0 = w0
        self.w1 = w1
        self.w2 = w2
        self.w3 = w3

    fn __copyinit__(out self, existing: Self):
        self.w0 = existing.w0
        self.w1 = existing.w1
        self.w2 = existing.w2
        self.w3 = existing.w3


struct Sub64(Copyable, ImplicitlyCopyable, Movable):
    var res: UInt64
    var borrow: UInt64

    fn __init__(out self, res: UInt64, borrow: UInt64):
        self.res = res
        self.borrow = borrow

    fn __copyinit__(out self, existing: Self):
        self.res = existing.res
        self.borrow = existing.borrow


struct Fq(Copyable, ImplicitlyCopyable, Movable):
    # Montgomery form, little-endian 64-bit limbs (blst_fr layout).
    var l0: UInt64
    var l1: UInt64
    var l2: UInt64
    var l3: UInt64

    fn __init__(out self, l0: UInt64, l1: UInt64, l2: UInt64, l3: UInt64):
        self.l0 = l0
        self.l1 = l1
        self.l2 = l2
        self.l3 = l3

    fn __copyinit__(out self, existing: Self):
        self.l0 = existing.l0
        self.l1 = existing.l1
        self.l2 = existing.l2
        self.l3 = existing.l3

    @staticmethod
    fn zero() -> Fq:
        return Fq(0, 0, 0, 0)

    @staticmethod
    fn one() -> Fq:
        # R = 2^256 mod q (represents 1 in Montgomery form).
        return Fq(
            0x0000_0001_FFFF_FFFE,
            0x5884_B7FA_0003_4802,
            0x998C_4FEF_ECBC_4FF5,
            0x1824_B159_ACC5_056F,
        )

    @staticmethod
    fn s() -> Int:
        # Two-adicity of the BLS12-381 scalar field.
        return 32

    @staticmethod
    fn root_of_unity() -> Fq:
        # 2^S root of unity in little-endian Montgomery form (midnight-curves Fq::ROOT_OF_UNITY).
        return Fq(
            0xB9B5_8D8C_5F0E_466A,
            0x5B1B_4C80_1819_D7EC,
            0x0AF5_3AE3_52A3_1E64,
            0x5BF3_ADDA_19E9_B27B,
        )

    @staticmethod
    fn zeta() -> Fq:
        # Montgomery form of the third root of unity (midnight-curves Fq::ZETA).
        return Fq(
            0x92D9_090B_0930_11D2,
            0xFC9C_BD71_9D6A_A073,
            0xC1F1_4EF0_CD65_A1A6,
            0x017F_6D35_E72F_CDEB,
        )

    @staticmethod
    fn delta() -> Fq:
        # Generator^{2^s} where t * 2^s + 1 = q with t odd (midnight-curves Fq::DELTA).
        return Fq(
            0x70E3_10D3_D146_F96A,
            0x4B64_C089_19E2_99E6,
            0x51E1_1418_6A8B_970D,
            0x6185_D066_27C0_67CB,
        )

    fn is_zero(self) -> Bool:
        return self.l0 == 0 and self.l1 == 0 and self.l2 == 0 and self.l3 == 0

    @staticmethod
    fn modulus_words() -> U64x4:
        # Little-endian modulus limbs (non-Montgomery).
        return U64x4(
            0xFFFF_FFFF_0000_0001,
            0x53BD_A402_FFFE_5BFE,
            0x3339_D808_09A1_D805,
            0x73ED_A753_299D_7D48,
        )

    @staticmethod
    fn r2_words() -> U64x4:
        # R^2 = 2^512 mod q, as raw limbs (non-Montgomery integer).
        return U64x4(
            0xC999_E990_F3F2_9C6D,
            0x2B6C_EDCB_8792_5C23,
            0x05D3_1496_7254_398F,
            0x0748_D9D9_9F59_FF11,
        )

    @staticmethod
    fn r3_words() -> U64x4:
        # R^3 = 2^768 mod q, as raw limbs (non-Montgomery integer).
        return U64x4(
            0xC62C_1807_439B_73AF,
            0x1B3E_0D18_8CF0_6990,
            0x73D1_3C71_C7B5_F418,
            0x6E2A_5BB9_C8DB_33E9,
        )

    @staticmethod
    fn inv64() -> UInt64:
        # INV = -(q^{-1} mod 2^64) mod 2^64.
        return 0xFFFF_FFFE_FFFF_FFFF

    @staticmethod
    fn _sub64(a: UInt64, b: UInt64, borrow: UInt64) -> Sub64:
        var bb = UInt128(b) + UInt128(borrow)
        if UInt128(a) >= bb:
            return Sub64(a - UInt64(bb), 0)
        return Sub64(a - UInt64(bb), 1)

    @staticmethod
    fn _geq_u64x4(a: U64x4, b: U64x4) -> Bool:
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

    @staticmethod
    fn _parse_u64_le(bytes: List[Byte], off: Int) raises -> UInt64:
        if off < 0 or off + 8 > len(bytes):
            raise Error("u64 parse OOB")
        var b0: UInt64 = UInt64(bytes[off + 0])
        var b1: UInt64 = UInt64(bytes[off + 1])
        var b2: UInt64 = UInt64(bytes[off + 2])
        var b3: UInt64 = UInt64(bytes[off + 3])
        var b4: UInt64 = UInt64(bytes[off + 4])
        var b5: UInt64 = UInt64(bytes[off + 5])
        var b6: UInt64 = UInt64(bytes[off + 6])
        var b7: UInt64 = UInt64(bytes[off + 7])
        return (
            b0
            | (b1 << 8)
            | (b2 << 16)
            | (b3 << 24)
            | (b4 << 32)
            | (b5 << 40)
            | (b6 << 48)
            | (b7 << 56)
        )

    @staticmethod
    fn from_repr_le(bytes: List[Byte]) raises -> Fq:
        if len(bytes) != 32:
            raise Error("Fq::from_repr_le: expected 32 bytes")
        var c = U64x4(
            Fq._parse_u64_le(bytes, 0),
            Fq._parse_u64_le(bytes, 8),
            Fq._parse_u64_le(bytes, 16),
            Fq._parse_u64_le(bytes, 24),
        )
        var m = Fq.modulus_words()
        if Fq._geq_u64x4(c, m):
            raise Error("Fq::from_repr_le: non-canonical")

        var r2 = Fq.r2_words()
        var raw = Fq._mont_mul_raw(c, r2)
        return Fq(raw.w0, raw.w1, raw.w2, raw.w3)

    @staticmethod
    fn from_raw_bytes_le(bytes: List[Byte]) raises -> Fq:
        # Reads an element from its internal Montgomery representation (raw limbs).
        # This matches midnight-curves' `SerdeObject::write_raw` encoding.
        if len(bytes) != 32:
            raise Error("Fq::from_raw_bytes_le: expected 32 bytes")
        return Fq(
            Fq._parse_u64_le(bytes, 0),
            Fq._parse_u64_le(bytes, 8),
            Fq._parse_u64_le(bytes, 16),
            Fq._parse_u64_le(bytes, 24),
        )

    @staticmethod
    fn from_u64(x: UInt64) -> Fq:
        var c = U64x4(x, 0, 0, 0)
        var r2 = Fq.r2_words()
        var raw = Fq._mont_mul_raw(c, r2)
        return Fq(raw.w0, raw.w1, raw.w2, raw.w3)

    @staticmethod
    fn from_uniform_bytes(bytes: List[Byte]) raises -> Fq:
        if len(bytes) != 64:
            raise Error("Fq::from_uniform_bytes: expected 64 bytes")

        var a0 = Fq(
            Fq._parse_u64_le(bytes, 0),
            Fq._parse_u64_le(bytes, 8),
            Fq._parse_u64_le(bytes, 16),
            Fq._parse_u64_le(bytes, 24),
        )
        var a1 = Fq(
            Fq._parse_u64_le(bytes, 32),
            Fq._parse_u64_le(bytes, 40),
            Fq._parse_u64_le(bytes, 48),
            Fq._parse_u64_le(bytes, 56),
        )

        var r2 = Fq.r2_words()
        var r3 = Fq.r3_words()
        var r2f = Fq(r2.w0, r2.w1, r2.w2, r2.w3)
        var r3f = Fq(r3.w0, r3.w1, r3.w2, r3.w3)
        return a0.mul(r2f).add(a1.mul(r3f))

    fn to_repr_le(self) -> List[Byte]:
        var c = self.to_canonical_words()
        var out = List[Byte]()
        var v: UInt64

        v = c.w0
        out.append(Byte(UInt8(v & 0xFF)))
        out.append(Byte(UInt8((v >> 8) & 0xFF)))
        out.append(Byte(UInt8((v >> 16) & 0xFF)))
        out.append(Byte(UInt8((v >> 24) & 0xFF)))
        out.append(Byte(UInt8((v >> 32) & 0xFF)))
        out.append(Byte(UInt8((v >> 40) & 0xFF)))
        out.append(Byte(UInt8((v >> 48) & 0xFF)))
        out.append(Byte(UInt8((v >> 56) & 0xFF)))

        v = c.w1
        out.append(Byte(UInt8(v & 0xFF)))
        out.append(Byte(UInt8((v >> 8) & 0xFF)))
        out.append(Byte(UInt8((v >> 16) & 0xFF)))
        out.append(Byte(UInt8((v >> 24) & 0xFF)))
        out.append(Byte(UInt8((v >> 32) & 0xFF)))
        out.append(Byte(UInt8((v >> 40) & 0xFF)))
        out.append(Byte(UInt8((v >> 48) & 0xFF)))
        out.append(Byte(UInt8((v >> 56) & 0xFF)))

        v = c.w2
        out.append(Byte(UInt8(v & 0xFF)))
        out.append(Byte(UInt8((v >> 8) & 0xFF)))
        out.append(Byte(UInt8((v >> 16) & 0xFF)))
        out.append(Byte(UInt8((v >> 24) & 0xFF)))
        out.append(Byte(UInt8((v >> 32) & 0xFF)))
        out.append(Byte(UInt8((v >> 40) & 0xFF)))
        out.append(Byte(UInt8((v >> 48) & 0xFF)))
        out.append(Byte(UInt8((v >> 56) & 0xFF)))

        v = c.w3
        out.append(Byte(UInt8(v & 0xFF)))
        out.append(Byte(UInt8((v >> 8) & 0xFF)))
        out.append(Byte(UInt8((v >> 16) & 0xFF)))
        out.append(Byte(UInt8((v >> 24) & 0xFF)))
        out.append(Byte(UInt8((v >> 32) & 0xFF)))
        out.append(Byte(UInt8((v >> 40) & 0xFF)))
        out.append(Byte(UInt8((v >> 48) & 0xFF)))
        out.append(Byte(UInt8((v >> 56) & 0xFF)))

        return out^

    fn to_canonical_words(self) -> U64x4:
        return Fq._mont_mul_raw(U64x4(self.l0, self.l1, self.l2, self.l3), U64x4(1, 0, 0, 0))

    fn add(self, rhs: Fq) -> Fq:
        var m = Fq.modulus_words()
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

        var out = U64x4(r0, r1, r2, r3)
        if carry != 0 or Fq._geq_u64x4(out, m):
            var d0 = Fq._sub64(out.w0, m.w0, 0)
            var d1 = Fq._sub64(out.w1, m.w1, d0.borrow)
            var d2 = Fq._sub64(out.w2, m.w2, d1.borrow)
            var d3 = Fq._sub64(out.w3, m.w3, d2.borrow)
            out = U64x4(d0.res, d1.res, d2.res, d3.res)
        return Fq(out.w0, out.w1, out.w2, out.w3)

    fn sub(self, rhs: Fq) -> Fq:
        var m = Fq.modulus_words()
        var d0 = Fq._sub64(self.l0, rhs.l0, 0)
        var d1 = Fq._sub64(self.l1, rhs.l1, d0.borrow)
        var d2 = Fq._sub64(self.l2, rhs.l2, d1.borrow)
        var d3 = Fq._sub64(self.l3, rhs.l3, d2.borrow)

        var out = U64x4(d0.res, d1.res, d2.res, d3.res)
        if d3.borrow != 0:
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
        return Fq(out.w0, out.w1, out.w2, out.w3)

    fn neg(self) -> Fq:
        if self.is_zero():
            return self
        return Fq.zero().sub(self)

    fn mul(self, rhs: Fq) -> Fq:
        var out = Fq._mont_mul_raw(U64x4(self.l0, self.l1, self.l2, self.l3), U64x4(rhs.l0, rhs.l1, rhs.l2, rhs.l3))
        return Fq(out.w0, out.w1, out.w2, out.w3)

    fn square(self) -> Fq:
        return self.mul(self)

    fn pow(self, exp_le_words: List[UInt64]) -> Fq:
        var acc = Fq.one()
        var base = self
        for w in exp_le_words:
            var word = w
            for _ in range(64):
                if (word & 1) != 0:
                    acc = acc.mul(base)
                word >>= 1
                base = base.square()
        return acc

    fn invert(self) -> Fq:
        # Fermat: a^(q-2). Slow but fine for correctness.
        var m = Fq.modulus_words()
        var e = List[UInt64]()
        e.append(m.w0 - 2)
        e.append(m.w1)
        e.append(m.w2)
        e.append(m.w3)
        return self.pow(e)

    @staticmethod
    fn _mont_mul_raw(a: U64x4, b: U64x4) -> U64x4:
        # Coarsely Integrated Operand Scanning Montgomery multiplication (4 limbs).
        var m = Fq.modulus_words()
        var inv = Fq.inv64()

        var t0: UInt64 = 0
        var t1: UInt64 = 0
        var t2: UInt64 = 0
        var t3: UInt64 = 0
        var t4: UInt64 = 0

        var carry: UInt128
        var uv: UInt128
        var m_i: UInt64

        # b.w0
        carry = 0
        uv = UInt128(t0) + UInt128(a.w0) * UInt128(b.w0) + carry
        t0 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(a.w1) * UInt128(b.w0) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(a.w2) * UInt128(b.w0) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(a.w3) * UInt128(b.w0) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)

        m_i = UInt64(UInt128(t0) * UInt128(inv))
        carry = 0
        uv = UInt128(t0) + UInt128(m_i) * UInt128(m.w0) + carry
        _ = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(m_i) * UInt128(m.w1) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(m_i) * UInt128(m.w2) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(m_i) * UInt128(m.w3) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)
        carry = uv >> 64

        t0 = t1
        t1 = t2
        t2 = t3
        t3 = t4
        t4 = UInt64(carry)

        # b.w1
        carry = 0
        uv = UInt128(t0) + UInt128(a.w0) * UInt128(b.w1) + carry
        t0 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(a.w1) * UInt128(b.w1) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(a.w2) * UInt128(b.w1) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(a.w3) * UInt128(b.w1) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)

        m_i = UInt64(UInt128(t0) * UInt128(inv))
        carry = 0
        uv = UInt128(t0) + UInt128(m_i) * UInt128(m.w0) + carry
        _ = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(m_i) * UInt128(m.w1) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(m_i) * UInt128(m.w2) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(m_i) * UInt128(m.w3) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)
        carry = uv >> 64

        t0 = t1
        t1 = t2
        t2 = t3
        t3 = t4
        t4 = UInt64(carry)

        # b.w2
        carry = 0
        uv = UInt128(t0) + UInt128(a.w0) * UInt128(b.w2) + carry
        t0 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(a.w1) * UInt128(b.w2) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(a.w2) * UInt128(b.w2) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(a.w3) * UInt128(b.w2) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)

        m_i = UInt64(UInt128(t0) * UInt128(inv))
        carry = 0
        uv = UInt128(t0) + UInt128(m_i) * UInt128(m.w0) + carry
        _ = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(m_i) * UInt128(m.w1) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(m_i) * UInt128(m.w2) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(m_i) * UInt128(m.w3) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)
        carry = uv >> 64

        t0 = t1
        t1 = t2
        t2 = t3
        t3 = t4
        t4 = UInt64(carry)

        # b.w3
        carry = 0
        uv = UInt128(t0) + UInt128(a.w0) * UInt128(b.w3) + carry
        t0 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(a.w1) * UInt128(b.w3) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(a.w2) * UInt128(b.w3) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(a.w3) * UInt128(b.w3) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)

        m_i = UInt64(UInt128(t0) * UInt128(inv))
        carry = 0
        uv = UInt128(t0) + UInt128(m_i) * UInt128(m.w0) + carry
        _ = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t1) + UInt128(m_i) * UInt128(m.w1) + carry
        t1 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t2) + UInt128(m_i) * UInt128(m.w2) + carry
        t2 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t3) + UInt128(m_i) * UInt128(m.w3) + carry
        t3 = UInt64(uv)
        carry = uv >> 64
        uv = UInt128(t4) + carry
        t4 = UInt64(uv)
        carry = uv >> 64

        t0 = t1
        t1 = t2
        t2 = t3
        t3 = t4
        t4 = UInt64(carry)

        var out = U64x4(t0, t1, t2, t3)
        if t4 != 0 or Fq._geq_u64x4(out, m):
            var d0 = Fq._sub64(out.w0, m.w0, 0)
            var d1 = Fq._sub64(out.w1, m.w1, d0.borrow)
            var d2 = Fq._sub64(out.w2, m.w2, d1.borrow)
            var d3 = Fq._sub64(out.w3, m.w3, d2.borrow)
            out = U64x4(d0.res, d1.res, d2.res, d3.res)
        return out
