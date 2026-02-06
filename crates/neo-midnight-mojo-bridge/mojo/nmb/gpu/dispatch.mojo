from sys import CompilationTarget
from sys.param_env import env_get_bool


comptime ENABLE_METAL_GPU: Bool = env_get_bool["NMB_ENABLE_METAL_GPU", False]()


fn cuda_available() -> Bool:
    # NOTE: This function name is historical: on macOS it checks for Metal,
    # elsewhere it checks for CUDA. Callers treat this as a generic "GPU
    # available" signal.
    @parameter
    if CompilationTarget.is_macos() and not ENABLE_METAL_GPU:
        # Avoid triggering Metal toolchain checks (metallib/Xcode) unless we
        # explicitly opt into Metal GPU builds.
        return False
    else:
        from gpu.host import DeviceContext

        try:
            var api = "cuda"
            @parameter
            if CompilationTarget.is_macos():
                api = "metal"
            with DeviceContext(api=api) as ctx:
                ctx.synchronize()
            return True
        except _:
            return False
