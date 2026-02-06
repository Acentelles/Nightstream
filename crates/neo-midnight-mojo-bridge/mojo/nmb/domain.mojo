from collections import List
from collections.optional import Optional
from sys import CompilationTarget

from gpu.host import DeviceContext

from nmb.fq import Fq
from nmb.gpu.fft_cuda import CUDA_FFT_IMPLEMENTED, best_fft_cuda_in_ctx


fn _reverse_bits(x: Int, bits: Int) -> Int:
    var v = x
    var y = 0
    for _ in range(bits):
        y = (y << 1) | (v & 1)
        v >>= 1
    return y


fn _best_fft_cpu(a_in: List[Fq], omega: Fq, k: Int) raises -> List[Fq]:
    var a = a_in.copy()
    var n = 1 << k
    if len(a) != n:
        raise Error("best_fft: bad length")

    # Bit-reversal permutation.
    for i in range(n):
        var j = _reverse_bits(i, k)
        if j > i:
            var tmp = a[i]
            a[i] = a[j]
            a[j] = tmp

    var m = 1
    for stage in range(k):
        var m2 = m * 2

        # w_m = omega^(n/m2) = omega^(2^(k-stage-1))
        var w_m = omega
        for _ in range(k - stage - 1):
            w_m = w_m.square()

        var w = Fq.one()
        for j in range(m):
            var i = j
            while i < n:
                var t = w.mul(a[i + m])
                var u = a[i]
                a[i] = u.add(t)
                a[i + m] = u.sub(t)
                i += m2
            w = w.mul(w_m)

        m = m2

    return a^


fn best_fft(
    a_in: List[Fq],
    omega: Fq,
    k: Int,
    use_cuda: Bool,
    ctx: Optional[DeviceContext],
) raises -> List[Fq]:
    if use_cuda and CUDA_FFT_IMPLEMENTED and k >= 16 and ctx:
        try:
            return best_fft_cuda_in_ctx(ctx.value(), a_in, omega, k)
        except _:
            pass
    return _best_fft_cpu(a_in, omega, k)


fn ifft(
    a_in: List[Fq],
    omega_inv: Fq,
    k: Int,
    divisor: Fq,
    use_cuda: Bool,
    ctx: Optional[DeviceContext],
) raises -> List[Fq]:
    var a = best_fft(a_in, omega_inv, k, use_cuda, ctx)
    for i in range(len(a)):
        a[i] = a[i].mul(divisor)
    return a^


struct EvaluationDomain:
    var n: Int
    var k: Int
    var extended_k: Int
    var use_cuda: Bool
    var gpu_ctx: Optional[DeviceContext]

    var omega: Fq
    var omega_inv: Fq
    var extended_omega: Fq
    var extended_omega_inv: Fq

    var g_coset: Fq
    var g_coset_inv: Fq

    var quotient_poly_degree: Int
    var ifft_divisor: Fq
    var extended_ifft_divisor: Fq
    var t_evaluations: List[Fq]

    fn __init__(out self, j: Int, k: Int, use_cuda: Bool = False) raises:
        if j < 1:
            raise Error("EvaluationDomain: j < 1")
        if k < 0 or k > Fq.s():
            raise Error("EvaluationDomain: k out of bounds")

        self.quotient_poly_degree = j - 1
        self.k = k
        self.n = 1 << k
        self.use_cuda = use_cuda
        self.gpu_ctx = Optional[DeviceContext]()
        if self.use_cuda and CUDA_FFT_IMPLEMENTED:
            try:
                var api = "cuda"
                @parameter
                if CompilationTarget.is_macos():
                    api = "metal"
                self.gpu_ctx = Optional[DeviceContext](DeviceContext(api=api))
            except _:
                self.use_cuda = False
                self.gpu_ctx = Optional[DeviceContext]()

        var extended_k = k
        while (1 << extended_k) < (self.n * self.quotient_poly_degree):
            extended_k += 1
        if extended_k > Fq.s():
            raise Error("EvaluationDomain: extended_k out of bounds")
        self.extended_k = extended_k

        var extended_omega = Fq.root_of_unity()
        for _ in range(extended_k, Fq.s()):
            extended_omega = extended_omega.square()
        self.extended_omega = extended_omega
        self.extended_omega_inv = extended_omega.invert()

        var omega = extended_omega
        for _ in range(k, extended_k):
            omega = omega.square()
        self.omega = omega
        self.omega_inv = omega.invert()

        self.g_coset = Fq.zeta()
        self.g_coset_inv = self.g_coset.square()

        self.ifft_divisor = (
            Fq.from_u64(UInt64(1) << UInt64(k)).invert()
        )
        self.extended_ifft_divisor = (
            Fq.from_u64(UInt64(1) << UInt64(extended_k)).invert()
        )

        var t_len = 1 << (extended_k - k)
        self.t_evaluations = List[Fq]()

        var n_u64 = UInt64(1) << UInt64(k)
        var exp0 = List[UInt64]()
        exp0.append(n_u64)
        var exp1 = List[UInt64]()
        exp1.append(n_u64)

        var orig = self.g_coset.pow(exp0)
        var step = extended_omega.pow(exp1)
        var cur = orig
        for _ in range(t_len):
            self.t_evaluations.append(cur.sub(Fq.one()).invert())
            cur = cur.mul(step)

    fn extended_len(self) -> Int:
        return 1 << self.extended_k

    fn lagrange_to_coeff(self, values: List[Fq]) raises -> List[Fq]:
        if len(values) != self.n:
            raise Error("lagrange_to_coeff: bad length")
        return ifft(values, self.omega_inv, self.k, self.ifft_divisor, self.use_cuda, self.gpu_ctx)

    fn coeff_to_lagrange(self, values: List[Fq]) raises -> List[Fq]:
        if len(values) != self.n:
            raise Error("coeff_to_lagrange: bad length")
        return best_fft(values, self.omega, self.k, self.use_cuda, self.gpu_ctx)

    fn coeff_to_extended(self, values_in: List[Fq]) raises -> List[Fq]:
        if len(values_in) != self.n:
            raise Error("coeff_to_extended: bad length")
        var values = values_in.copy()
        values = self._distribute_powers_zeta(values, True)

        # Pad to extended length with zeros.
        while len(values) < self.extended_len():
            values.append(Fq.zero())
        return best_fft(values, self.extended_omega, self.extended_k, self.use_cuda, self.gpu_ctx)

    fn extended_to_coeff(self, values: List[Fq]) raises -> List[Fq]:
        if len(values) != self.extended_len():
            raise Error("extended_to_coeff: bad length")
        var out = ifft(values, self.extended_omega_inv, self.extended_k, self.extended_ifft_divisor, self.use_cuda, self.gpu_ctx)
        out = self._distribute_powers_zeta(out, False)
        return out^

    fn extended_to_lagrange(self, values_in: List[Fq]) raises -> List[Fq]:
        if len(values_in) != self.extended_len():
            raise Error("extended_to_lagrange: bad length")
        var values = ifft(
            values_in, self.extended_omega_inv, self.extended_k, self.extended_ifft_divisor, self.use_cuda, self.gpu_ctx
        )
        while len(values) > self.n:
            _ = values.pop()
        values = self._distribute_powers_zeta(values, False)
        return best_fft(values, self.omega, self.k, self.use_cuda, self.gpu_ctx)

    fn divide_by_vanishing_poly(self, values_in: List[Fq]) raises -> List[Fq]:
        if len(values_in) != self.extended_len():
            raise Error("divide_by_vanishing_poly: bad length")
        var values = values_in.copy()
        var t_len = len(self.t_evaluations)
        for i in range(len(values)):
            values[i] = values[i].mul(self.t_evaluations[i % t_len])
        return values^

    fn rotate_omega(self, value: Fq, rotation: Int) -> Fq:
        if rotation == 0:
            return value
        var exp = List[UInt64]()
        if rotation > 0:
            exp.append(UInt64(rotation))
            return value.mul(self.omega.pow(exp))
        exp.append(UInt64(-rotation))
        return value.mul(self.omega_inv.pow(exp))

    fn _distribute_powers_zeta(self, a_in: List[Fq], into_coset: Bool) -> List[Fq]:
        var a = a_in.copy()
        var p1: Fq
        var p2: Fq
        if into_coset:
            p1 = self.g_coset
            p2 = self.g_coset_inv
        else:
            p1 = self.g_coset_inv
            p2 = self.g_coset

        for i in range(len(a)):
            var j = i % 3
            if j == 1:
                a[i] = a[i].mul(p1)
            elif j == 2:
                a[i] = a[i].mul(p2)
        return a^
