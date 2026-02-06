from nmb.fp import Fp, U64x6
from nmb.g1 import G1Affine
from nmb.reader import Reader


fn read_g1_uncompressed(mut r: Reader) raises -> G1Affine:
    # IETF uncompressed format (96 bytes), big-endian.
    var x5 = r.read_u64_be()
    if (x5 & 0x8000_0000_0000_0000) != 0:
        raise Error("expected uncompressed G1")
    if (x5 & 0x4000_0000_0000_0000) != 0:
        r.skip(88)
        return G1Affine.identity()

    x5 = x5 & 0x1FFF_FFFF_FFFF_FFFF
    var x4 = r.read_u64_be()
    var x3 = r.read_u64_be()
    var x2 = r.read_u64_be()
    var x1 = r.read_u64_be()
    var x0 = r.read_u64_be()

    var y5 = r.read_u64_be() & 0x1FFF_FFFF_FFFF_FFFF
    var y4 = r.read_u64_be()
    var y3 = r.read_u64_be()
    var y2 = r.read_u64_be()
    var y1 = r.read_u64_be()
    var y0 = r.read_u64_be()

    var x = Fp.from_canonical_words(U64x6(x0, x1, x2, x3, x4, x5))
    var y = Fp.from_canonical_words(U64x6(y0, y1, y2, y3, y4, y5))
    return G1Affine(x, y, False)

