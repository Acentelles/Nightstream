from collections import List

from nmb.fq import Fq, U64x4
from nmb.g1 import G1Affine, G1Jacobian


fn choose_window_size(n: Int) -> Int:
    if n <= 32:
        return 4
    if n <= 256:
        return 6
    if n <= 1024:
        return 8
    if n <= 4096:
        return 10
    if n <= 16384:
        return 12
    return 13


fn _word_at(words: U64x4, idx: Int) -> UInt64:
    if idx == 0:
        return words.w0
    if idx == 1:
        return words.w1
    if idx == 2:
        return words.w2
    if idx == 3:
        return words.w3
    return 0


fn _extract_window(words: U64x4, bit_offset: Int, width: Int) -> Int:
    if width <= 0:
        return 0
    var mask = (UInt64(1) << UInt64(width)) - 1

    var word_idx = bit_offset // 64
    var bit_in_word = bit_offset % 64

    var lo = _word_at(words, word_idx) >> UInt64(bit_in_word)
    if bit_in_word + width <= 64:
        return Int(lo & mask)

    var hi = _word_at(words, word_idx + 1) << UInt64(64 - bit_in_word)
    return Int((lo | hi) & mask)


fn msm_pippenger_prefix(bases: List[G1Affine], scalars: List[Fq]) raises -> G1Jacobian:
    var n = len(scalars)
    if n == 0:
        return G1Jacobian.identity()
    if len(bases) < n:
        raise Error("msm: bases shorter than scalars")

    var w = choose_window_size(n)
    var num_windows = (256 + w - 1) // w
    var bucket_count = 1 << w

    # NOTE: `Fq` values are in Montgomery form internally (s*R mod r). We use
    # raw limbs as scalar integers (yielding an MSM result scaled by R) and
    # correct with a single multiply by R^{-1} at the end.
    var scalar_words = List[U64x4]()
    for i in range(n):
        var s = scalars[i]
        if s.is_zero():
            scalar_words.append(U64x4(0, 0, 0, 0))
        else:
            scalar_words.append(U64x4(s.l0, s.l1, s.l2, s.l3))

    var buckets = List[G1Jacobian]()
    for _ in range(bucket_count):
        buckets.append(G1Jacobian.identity())

    var acc = G1Jacobian.identity()
    for wi in range(num_windows):
        var window = (num_windows - 1) - wi

        for _ in range(w):
            acc = acc.double()

        for i in range(bucket_count):
            buckets[i] = G1Jacobian.identity()

        var bit_offset = window * w
        for i in range(n):
            var digit = _extract_window(scalar_words[i], bit_offset, w)
            if digit == 0:
                continue
            var base = bases[i]
            if base.infinity:
                continue
            buckets[digit] = buckets[digit].add_affine(base)

        var running = G1Jacobian.identity()
        for j in range(bucket_count - 1):
            var idx = (bucket_count - 1) - j
            if idx == 0:
                break
            running = running.add(buckets[idx])
            acc = acc.add(running)

    # Undo the Montgomery factor: MSM computed with scalars (s*R) gives R*C.
    return acc.mul_scalar(Fq(1, 0, 0, 0))
