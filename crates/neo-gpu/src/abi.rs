pub const ABI_VERSION: u32 = 1;

#[cfg(not(target_arch = "wasm32"))]
pub const ABI_VERSION_SYMBOL: &[u8] = b"nightstream_gpu_abi_version\0";
#[cfg(not(target_arch = "wasm32"))]
pub const DEVICE_PROBE_SYMBOL: &[u8] = b"nightstream_gpu_device_probe\0";
#[cfg(not(target_arch = "wasm32"))]
pub const SESSION_OPEN_SYMBOL: &[u8] = b"nightstream_gpu_session_open\0";
#[cfg(not(target_arch = "wasm32"))]
pub const SESSION_CLOSE_SYMBOL: &[u8] = b"nightstream_gpu_session_close\0";
#[cfg(not(target_arch = "wasm32"))]
pub const FE_CREATE_SYMBOL: &[u8] = b"nightstream_gpu_fe_create\0";
#[cfg(not(target_arch = "wasm32"))]
pub const FE_DESTROY_SYMBOL: &[u8] = b"nightstream_gpu_fe_destroy\0";
#[cfg(not(target_arch = "wasm32"))]
pub const FE_EVALS_AT_SYMBOL: &[u8] = b"nightstream_gpu_fe_evals_at\0";
#[cfg(not(target_arch = "wasm32"))]
pub const FE_FOLD_SYMBOL: &[u8] = b"nightstream_gpu_fe_fold\0";
#[cfg(not(target_arch = "wasm32"))]
pub const NC_CREATE_SYMBOL: &[u8] = b"nightstream_gpu_nc_create\0";
#[cfg(not(target_arch = "wasm32"))]
pub const NC_DESTROY_SYMBOL: &[u8] = b"nightstream_gpu_nc_destroy\0";
#[cfg(not(target_arch = "wasm32"))]
pub const NC_EVALS_AT_SYMBOL: &[u8] = b"nightstream_gpu_nc_evals_at\0";
#[cfg(not(target_arch = "wasm32"))]
pub const NC_FOLD_SYMBOL: &[u8] = b"nightstream_gpu_nc_fold\0";
#[cfg(not(target_arch = "wasm32"))]
pub const POSEIDON2_PERMUTE_SYMBOL: &[u8] = b"nightstream_gpu_poseidon2_permute_u64x8\0";
#[cfg(not(target_arch = "wasm32"))]
pub const POSEIDON2_PERMUTE_BATCH_SYMBOL: &[u8] = b"nightstream_gpu_poseidon2_permute_batch_u64x8\0";
#[cfg(not(target_arch = "wasm32"))]
pub const RQ_MUL_SYMBOL: &[u8] = b"nightstream_gpu_rq_mul_u64x54\0";
#[cfg(not(target_arch = "wasm32"))]
pub const RQ_MUL_BATCH_SYMBOL: &[u8] = b"nightstream_gpu_rq_mul_batch_u64x54\0";
#[cfg(not(target_arch = "wasm32"))]
pub const RQ_ACCUMULATE_BATCH_SYMBOL: &[u8] = b"nightstream_gpu_rq_accumulate_batch_u64x54\0";
#[cfg(not(target_arch = "wasm32"))]
pub const RQ_CT_SYMBOL: &[u8] = b"nightstream_gpu_rq_ct_u64x54\0";
#[cfg(not(target_arch = "wasm32"))]
pub const SUPERNEO_BAR_BLOCK_SYMBOL: &[u8] = b"nightstream_gpu_superneo_bar_block_u64x54\0";
#[cfg(not(target_arch = "wasm32"))]
pub const SUPERNEO_ROW_DOT_BLOCKS_SYMBOL: &[u8] = b"nightstream_gpu_superneo_row_dot_blocks\0";
#[cfg(not(target_arch = "wasm32"))]
pub const SUPERNEO_ROW_DOT_BLOCKS_DUAL_SYMBOL: &[u8] = b"nightstream_gpu_superneo_row_dot_blocks_dual\0";
pub const POSEIDON2_STATE_WIDTH: usize = 8;
pub const DEVICE_PROBE_AVAILABLE_FLAG: u32 = 1 << 0;
pub const DEVICE_PROBE_ACCELERATOR_READY_FLAG: u32 = 1 << 1;
pub const DEVICE_PROBE_POSEIDON2_FLAG: u32 = 1 << 2;
pub const DEVICE_PROBE_POSEIDON2_BATCH_FLAG: u32 = 1 << 3;
pub const DEVICE_PROBE_SPLIT_NC_FLAG: u32 = 1 << 4;
pub const DEVICE_PROBE_RQ_MUL_FLAG: u32 = 1 << 5;
pub const DEVICE_PROBE_SUPERNEO_FLAG: u32 = 1 << 6;
pub const DEVICE_PROBE_CPU_DIRECT_FLAG: u32 = 1 << 7;

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct FlatFq {
    pub limb: u64,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct FlatK {
    pub re: u64,
    pub im: u64,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct FlatRq {
    pub coeffs: [u64; 54],
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct DeviceRequest {
    pub api: u32,
    pub device_id: u32,
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct DeviceResponse {
    pub status: i32,
    pub available: i32,
}

impl DeviceResponse {
    #[inline]
    pub const fn capability_bits(self) -> u32 {
        self.available as u32
    }

    #[inline]
    pub const fn is_available(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_AVAILABLE_FLAG != 0
    }

    #[inline]
    pub const fn accelerator_ready(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_ACCELERATOR_READY_FLAG != 0
    }

    #[inline]
    pub const fn supports_poseidon2(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_POSEIDON2_FLAG != 0
    }

    #[inline]
    pub const fn supports_poseidon2_batch(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_POSEIDON2_BATCH_FLAG != 0
    }

    #[inline]
    pub const fn supports_split_nc(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_SPLIT_NC_FLAG != 0
    }

    #[inline]
    pub const fn supports_rq_mul(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_RQ_MUL_FLAG != 0
    }

    #[inline]
    pub const fn supports_superneo(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_SUPERNEO_FLAG != 0
    }

    #[inline]
    pub const fn supports_cpu_direct(self) -> bool {
        self.capability_bits() & DEVICE_PROBE_CPU_DIRECT_FLAG != 0
    }
}

#[repr(C)]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct SessionRequest {
    pub api: u32,
    pub device_id: u32,
}
