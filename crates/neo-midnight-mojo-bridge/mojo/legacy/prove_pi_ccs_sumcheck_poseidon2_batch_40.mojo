from pathlib import Path
from sys import argv
from sys.ffi import OwnedDLHandle


fn main() raises:
    var args = argv()
    if len(args) != 3:
        print(
            "Usage: mojo prove_pi_ccs_sumcheck_poseidon2_batch_40.mojo <path-to-libneo_midnight_bridge_ffi.dylib> <path-to-poseidon2_ic_circuit_batch_40.json>"
        )
        return

    var dylib_path = args[1]
    var json_path = args[2]

    var json_bytes = Path(json_path).read_bytes()
    var json_ptr = json_bytes.unsafe_ptr()
    var json_len = len(json_bytes)

    var out_ptr = UnsafePointer[Byte, MutAnyOrigin]()
    var out_len: Int = 0
    var err_ptr = UnsafePointer[Byte, MutAnyOrigin]()
    var err_len: Int = 0

    var lib = OwnedDLHandle(dylib_path)
    var rc: Int32 = lib.call[
        "neo_midnight_bridge_prove_pi_ccs_sumcheck_poseidon2_batch_40_json",
        Int32,
    ](
        json_ptr,
        json_len,
        Pointer(to=out_ptr),
        Pointer(to=out_len),
        Pointer(to=err_ptr),
        Pointer(to=err_len),
    )

    if rc != 0:
        var err_span = Span[Byte](ptr=err_ptr, length=err_len)
        var err_msg = String(bytes=err_span)
        print("Rust prover failed (rc=", rc, "): ", err_msg)
        lib.call["neo_midnight_bridge_free_bytes", NoneType](err_ptr, err_len)
        return

    print("Proof bytes: ", out_len)
    lib.call["neo_midnight_bridge_free_bytes", NoneType](out_ptr, out_len)

