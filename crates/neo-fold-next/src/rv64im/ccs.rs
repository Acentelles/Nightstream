//! Owns the RV64IM parity-slice protocol ids and transcript labels.

pub const RV64IM_PARITY_TRANSCRIPT_APP_LABEL: &[u8] = b"neo.fold.next/rv64im/parity_kernel_v1";
pub const RV64IM_PARITY_TRANSCRIPT_SEED_LABEL: &[u8] = b"rv64im/kernel/transcript_seed";
pub const RV64IM_PARITY_CASE_NAME_LABEL: &[u8] = b"rv64im/kernel/case_name";
pub const RV64IM_PARITY_PROGRAM_WORDS_LABEL: &[u8] = b"rv64im/kernel/program_words";
pub const RV64IM_PARITY_INITIAL_REGS_LABEL: &[u8] = b"rv64im/kernel/initial_regs";
pub const RV64IM_PARITY_INITIAL_MEMORY_LABEL: &[u8] = b"rv64im/kernel/initial_memory";
pub const RV64IM_PARITY_ROOT0_DIGEST_LABEL: &[u8] = b"rv64im/kernel/root0_digest";
pub const RV64IM_PARITY_STAGE1_DIGEST_LABEL: &[u8] = b"rv64im/kernel/stage1_digest";
pub const RV64IM_PARITY_STAGE2_DIGEST_LABEL: &[u8] = b"rv64im/kernel/stage2_digest";
pub const RV64IM_PARITY_STAGE3_DIGEST_LABEL: &[u8] = b"rv64im/kernel/stage3_digest";
pub const RV64IM_PARITY_EXECUTION_DIGEST_LABEL: &[u8] = b"rv64im/kernel/execution_digest";
pub const RV64IM_PARITY_FINAL_STATE_DIGEST_LABEL: &[u8] = b"rv64im/kernel/final_state_digest";
pub const RV64IM_PARITY_STAGE1_MIX_LABEL: &[u8] = b"rv64im/stage1/row_mix";
pub const RV64IM_PARITY_STAGE2_REG_MIX_LABEL: &[u8] = b"rv64im/stage2/reg_mix";
pub const RV64IM_PARITY_STAGE2_RAM_MIX_LABEL: &[u8] = b"rv64im/stage2/ram_mix";
pub const RV64IM_PARITY_STAGE3_CONTINUITY_MIX_LABEL: &[u8] = b"rv64im/stage3/continuity_mix";
pub const RV64IM_PARITY_KERNEL_FINAL_MIX_LABEL: &[u8] = b"rv64im/kernel/final_mix";
