from collections import List

from nmb.blake2b import Blake2bState
from nmb.fq import Fq


comptime _PREFIX_CHALLENGE: UInt8 = 0
comptime _PREFIX_COMMON: UInt8 = 1


struct CircuitTranscript(Movable):
    var state: Blake2bState
    var proof: List[Byte]

    fn __init__(out self, var state: Blake2bState, var proof: List[Byte]):
        self.state = state^
        self.proof = proof^

    @staticmethod
    fn init() raises -> CircuitTranscript:
        var key = List[Byte]()
        for b in "Domain separator for transcript".as_bytes():
            key.append(Byte(UInt8(b)))

        var state = Blake2bState.init_keyed(key)
        var proof = List[Byte]()
        return CircuitTranscript(state^, proof^)

    fn _absorb_bytes(mut self, bytes: List[Byte]):
        self.state.update_u8(_PREFIX_COMMON)
        self.state.update(bytes)

    fn common_bytes(mut self, bytes: List[Byte]):
        self._absorb_bytes(bytes)

    fn write_bytes(mut self, bytes: List[Byte]):
        self._absorb_bytes(bytes)
        for b in bytes:
            self.proof.append(b)

    fn common_fq(mut self, x: Fq) raises:
        self.common_bytes(x.to_repr_le())

    fn write_fq(mut self, x: Fq) raises:
        self.write_bytes(x.to_repr_le())

    fn common_g1_bytes(mut self, g1_bytes: List[Byte]):
        self.common_bytes(g1_bytes)

    fn write_g1_bytes(mut self, g1_bytes: List[Byte]):
        self.write_bytes(g1_bytes)

    fn squeeze_challenge_fq(mut self) raises -> Fq:
        self.state.update_u8(_PREFIX_CHALLENGE)
        var h = self.state.digest()
        return Fq.from_uniform_bytes(h)

    fn finalize(var self) -> List[Byte]:
        var out = self.proof^
        self.proof = List[Byte]()
        return out^
