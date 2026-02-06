from pathlib import Path
from sys import argv
from collections import List

import plonk_prove_from_snapshot
import plonk_prove_goldilocks_mul
import plonk_prove_sumcheck_single_round


fn usage():
    print("Usage:")
    print("  mojo prove.mojo snapshot <pkg.nmbp> <snapshot.nmbws> <out_proof.bin>")
    print("  mojo prove.mojo goldilocks_mul <pkg.nmbp> <x_u64_dec> <y_u64_dec> <z_u64_dec> <out_proof.bin>")
    print(
        "  mojo prove.mojo sumcheck_single_round <pkg.nmbp> <n_coeffs>",
        " <c0_0> <c0_1> ... <c{n-1}_0> <c{n-1}_1>",
        " <challenge_0> <challenge_1>",
        " <claimed_sum_0> <claimed_sum_1>",
        " <next_sum_0> <next_sum_1>",
        " <out_proof.bin>",
    )


fn main() raises:
    var args = argv()
    if len(args) < 2:
        usage()
        return

    var mode = args[1]
    if mode == "snapshot":
        if len(args) != 5:
            usage()
            return
        var proof = plonk_prove_from_snapshot.prove_from_snapshot_bytes(
            Path(args[2]).read_bytes(),
            Path(args[3]).read_bytes(),
        )
        Path(args[4]).write_bytes(proof)
        return

    if mode == "goldilocks_mul":
        if len(args) != 7:
            usage()
            return
        var pkg_bytes = Path(args[2]).read_bytes()
        var x = plonk_prove_goldilocks_mul.parse_u64_dec(args[3])
        var y = plonk_prove_goldilocks_mul.parse_u64_dec(args[4])
        var z = plonk_prove_goldilocks_mul.parse_u64_dec(args[5])
        var proof = plonk_prove_goldilocks_mul.prove_goldilocks_mul(pkg_bytes, x, y, z)
        Path(args[6]).write_bytes(proof)
        return

    if mode == "sumcheck_single_round":
        if len(args) < 5:
            usage()
            return
        var pkg_path = args[2]
        var n_coeffs = Int(plonk_prove_goldilocks_mul.parse_u64_dec(args[3]))
        var expected = 2 * n_coeffs + 11
        if len(args) != expected:
            usage()
            return
        var raw = List[String]()
        for i in range(4, len(args) - 1):
            raw.append(args[i])
        var proof = plonk_prove_sumcheck_single_round.prove_sumcheck_single_round_args(
            Path(pkg_path).read_bytes(), n_coeffs, raw
        )
        Path(args[len(args) - 1]).write_bytes(proof)
        return

    usage()
