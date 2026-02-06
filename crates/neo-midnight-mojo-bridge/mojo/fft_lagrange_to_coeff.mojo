from pathlib import Path
from sys import argv
from collections import List

from nmb.domain import EvaluationDomain
from nmb.fq import Fq
from nmb.gpu.dispatch import cuda_available
from nmb.reader import Reader


fn main() raises:
    var args = argv()
    if len(args) != 3:
        print("Usage: mojo fft_lagrange_to_coeff.mojo <in_lagrange.bin> <out_coeff.bin>")
        return

    var in_path = args[1]
    var out_path = args[2]

    var input_bytes = Path(in_path).read_bytes()
    var r = Reader(input_bytes)
    var count = Int(r.read_u32_le())
    if count <= 0:
        raise Error("count <= 0")

    # Derive k from count (= 2^k).
    var k = 0
    var tmp = count
    while tmp > 1:
        if (tmp & 1) != 0:
            raise Error("count must be a power of two")
        tmp >>= 1
        k += 1

    var values = List[Fq]()
    for _ in range(count):
        var repr = r.read_bytes(32)
        values.append(Fq.from_repr_le(repr))
    if r.remaining() != 0:
        raise Error("trailing bytes in input")

    # Use the common j=3 quotient setup used by many PLONK circuits.
    var domain = EvaluationDomain(3, k, cuda_available())
    var coeffs = domain.lagrange_to_coeff(values)

    var out = List[Byte]()
    var count_u32: UInt32 = UInt32(count)
    var mask: UInt32 = UInt32(0xFF)
    out.append(Byte(UInt8(count_u32 & mask)))
    out.append(Byte(UInt8((count_u32 >> 8) & mask)))
    out.append(Byte(UInt8((count_u32 >> 16) & mask)))
    out.append(Byte(UInt8((count_u32 >> 24) & mask)))
    for coeff in coeffs:
        var repr = coeff.to_repr_le()
        for b in repr:
            out.append(b)
    Path(out_path).write_bytes(out)
