from collections import List


struct Reader:
    var data: List[Byte]
    var pos: Int

    fn __init__(out self, bytes: List[Byte]):
        self.data = bytes.copy()
        self.pos = 0

    fn remaining(self) -> Int:
        return len(self.data) - self.pos

    fn read_u8(mut self) raises -> UInt8:
        if self.pos + 1 > len(self.data):
            raise Error("unexpected EOF")
        var b = UInt8(self.data[self.pos])
        self.pos += 1
        return b

    fn read_u32_le(mut self) raises -> UInt32:
        if self.pos + 4 > len(self.data):
            raise Error("unexpected EOF")
        var b0: UInt32 = UInt32(self.data[self.pos + 0])
        var b1: UInt32 = UInt32(self.data[self.pos + 1])
        var b2: UInt32 = UInt32(self.data[self.pos + 2])
        var b3: UInt32 = UInt32(self.data[self.pos + 3])
        self.pos += 4
        return b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)

    fn read_u32_be(mut self) raises -> UInt32:
        if self.pos + 4 > len(self.data):
            raise Error("unexpected EOF")
        var b0: UInt32 = UInt32(self.data[self.pos + 0])
        var b1: UInt32 = UInt32(self.data[self.pos + 1])
        var b2: UInt32 = UInt32(self.data[self.pos + 2])
        var b3: UInt32 = UInt32(self.data[self.pos + 3])
        self.pos += 4
        return (b0 << 24) | (b1 << 16) | (b2 << 8) | b3

    fn read_u64_le(mut self) raises -> UInt64:
        if self.pos + 8 > len(self.data):
            raise Error("unexpected EOF")
        var b0: UInt64 = UInt64(self.data[self.pos + 0])
        var b1: UInt64 = UInt64(self.data[self.pos + 1])
        var b2: UInt64 = UInt64(self.data[self.pos + 2])
        var b3: UInt64 = UInt64(self.data[self.pos + 3])
        var b4: UInt64 = UInt64(self.data[self.pos + 4])
        var b5: UInt64 = UInt64(self.data[self.pos + 5])
        var b6: UInt64 = UInt64(self.data[self.pos + 6])
        var b7: UInt64 = UInt64(self.data[self.pos + 7])
        self.pos += 8
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

    fn read_u64_be(mut self) raises -> UInt64:
        if self.pos + 8 > len(self.data):
            raise Error("unexpected EOF")
        var b0: UInt64 = UInt64(self.data[self.pos + 0])
        var b1: UInt64 = UInt64(self.data[self.pos + 1])
        var b2: UInt64 = UInt64(self.data[self.pos + 2])
        var b3: UInt64 = UInt64(self.data[self.pos + 3])
        var b4: UInt64 = UInt64(self.data[self.pos + 4])
        var b5: UInt64 = UInt64(self.data[self.pos + 5])
        var b6: UInt64 = UInt64(self.data[self.pos + 6])
        var b7: UInt64 = UInt64(self.data[self.pos + 7])
        self.pos += 8
        return (
            (b0 << 56)
            | (b1 << 48)
            | (b2 << 40)
            | (b3 << 32)
            | (b4 << 24)
            | (b5 << 16)
            | (b6 << 8)
            | b7
        )

    fn read_bytes(mut self, n: Int) raises -> List[Byte]:
        if n < 0:
            raise Error("read_bytes: negative")
        if self.pos + n > len(self.data):
            raise Error("unexpected EOF")
        var out = List[Byte]()
        for i in range(n):
            out.append(self.data[self.pos + i])
        self.pos += n
        return out^

    fn skip(mut self, n: Int) raises:
        if n < 0:
            raise Error("skip: negative")
        if self.pos + n > len(self.data):
            raise Error("unexpected EOF")
        self.pos += n

    fn expect_magic(mut self, m0: UInt8, m1: UInt8, m2: UInt8, m3: UInt8) raises:
        var a = self.read_u8()
        var b = self.read_u8()
        var c = self.read_u8()
        var d = self.read_u8()
        if a != m0 or b != m1 or c != m2 or d != m3:
            raise Error("bad magic")
