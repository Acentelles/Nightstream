from pathlib import Path
from sys import argv
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


fn inspect_nmbp(path: String) raises:
    var bytes = Path(path).read_bytes()
    var r = Reader(bytes)
    r.expect_magic(78, 77, 66, 80)  # NMBP

    var ver = r.read_u32_le()
    var relation_kind = r.read_u32_le()
    var params_len = r.read_u32_le()
    r.skip(Int(params_len))
    var k = r.read_u32_le()
    var n = r.read_u32_le()

    var params_bytes_len = r.read_u32_le()
    r.skip(Int(params_bytes_len))
    var vk_len = r.read_u32_le()
    r.skip(Int(vk_len))
    r.skip(32)  # vk_transcript_repr
    var pk_len = r.read_u32_le()
    r.skip(Int(pk_len))
    var cs_len = r.read_u32_le()
    r.skip(Int(cs_len))

    if r.remaining() != 0:
        raise Error("trailing bytes in NMBP")

    print(
        "NMBP v",
        ver,
        " relation_kind=",
        relation_kind,
        " k=",
        k,
        " n=",
        n,
        " cs_len=",
        cs_len,
    )


fn inspect_nmbws(path: String) raises:
    var bytes = Path(path).read_bytes()
    var r = Reader(bytes)
    r.expect_magic(78, 77, 66, 87)  # NMBW

    var ver = r.read_u32_le()
    var k = r.read_u32_le()
    var n = r.read_u32_le()
    var usable_rows = r.read_u32_le()

    var inst_cols = r.read_u32_le()
    for _ in range(Int(inst_cols)):
        if ver >= 2:
            _ = r.read_u32_le()  # provided_len
        var col_len = r.read_u32_le()
        r.skip(Int(col_len) * 32)

    var adv_cols = r.read_u32_le()
    for _ in range(Int(adv_cols)):
        var col_len = r.read_u32_le()
        r.skip(Int(col_len) * 32)

    if r.remaining() != 0:
        raise Error("trailing bytes in NMBW")

    print(
        "NMBW v",
        ver,
        " k=",
        k,
        " n=",
        n,
        " usable_rows=",
        usable_rows,
        " inst_cols=",
        inst_cols,
        " adv_cols=",
        adv_cols,
    )


fn main() raises:
    var args = argv()
    if len(args) != 3:
        print("Usage: mojo inspect.mojo <pkg.nmbp> <snapshot.nmbws>")
        return

    inspect_nmbp(args[1])
    inspect_nmbws(args[2])
