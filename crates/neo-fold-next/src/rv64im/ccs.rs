//! Owns the RV64IM protocol ids plus the exact 38-field root main-lane CCS embedding.

use neo_ccs::CcsStructure;
use neo_math::F;
use p3_field::PrimeCharacteristicRing;

use crate::rv64im::isa::Rv64Opcode;
use crate::rv64im::lower::Rv64ExpandedRow;
use crate::vm::r1cs_builder::R1csBuilder;

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

pub const RV64IM_ROOT_ROW_WIDTH: usize = 38;
pub const RV64IM_ROOT_PUBLIC_INPUTS: usize = 1;

const COL_ONE: usize = 0;
const COL_PC_LO: usize = 1;
const COL_PC_HI: usize = 2;
const COL_PC_NEXT_LO: usize = 3;
const COL_PC_NEXT_HI: usize = 4;
const COL_RS1_LO: usize = 5;
const COL_RS1_HI: usize = 6;
const COL_RS2_LO: usize = 7;
const COL_RS2_HI: usize = 8;
const COL_RD_NEXT_LO: usize = 9;
const COL_RD_NEXT_HI: usize = 10;
const COL_IMM_LO: usize = 11;
const COL_IMM_HI: usize = 12;
const COL_ALU_OUT_LO: usize = 13;
const COL_ALU_OUT_HI: usize = 14;
const COL_STEP_PC_LO: usize = 15;
const COL_STEP_PC_HI: usize = 16;
const COL_JUMP_TARGET_LO: usize = 17;
const COL_JUMP_TARGET_HI: usize = 18;
const COL_MEM_ADDR_LO: usize = 19;
const COL_MEM_ADDR_HI: usize = 20;
const COL_MEM_VAL_LO: usize = 21;
const COL_MEM_VAL_HI: usize = 22;
const COL_RD_IDX: usize = 23;
const COL_RS1_IDX: usize = 24;
const COL_RS2_IDX: usize = 25;
const COL_WRITES_ALU_TO_RD: usize = 26;
const COL_WRITES_MEM_TO_RD: usize = 27;
const COL_PRESERVES_RD: usize = 28;
const COL_IS_JAL: usize = 29;
const COL_IS_JALR: usize = 30;
const COL_IS_BRANCH: usize = 31;
const COL_BRANCH_TAKEN: usize = 32;
const COL_BRANCH_TAKEN_MUX: usize = 33;
const COL_IS_LOAD: usize = 34;
const COL_IS_STORE: usize = 35;
const COL_USES_RS2: usize = 36;
const COL_ADVANCE_ARCH_PC: usize = 37;

fn split_u64(value: u64) -> (u64, u64) {
    (value as u32 as u64, (value >> 32) as u32 as u64)
}

fn encode_u64(row: &mut [F; RV64IM_ROOT_ROW_WIDTH], lo_idx: usize, hi_idx: usize, value: u64) {
    let (lo, hi) = split_u64(value);
    row[lo_idx] = F::from_u64(lo);
    row[hi_idx] = F::from_u64(hi);
}

fn bool_field(value: bool) -> F {
    if value {
        F::ONE
    } else {
        F::ZERO
    }
}

fn is_real_branch(opcode: Rv64Opcode) -> bool {
    matches!(
        opcode,
        Rv64Opcode::Beq | Rv64Opcode::Bne | Rv64Opcode::Blt | Rv64Opcode::Bge | Rv64Opcode::Bltu | Rv64Opcode::Bgeu
    )
}

fn is_real_load(opcode: Rv64Opcode) -> bool {
    matches!(
        opcode,
        Rv64Opcode::Lb
            | Rv64Opcode::Lbu
            | Rv64Opcode::Lh
            | Rv64Opcode::Lhu
            | Rv64Opcode::Lw
            | Rv64Opcode::Lwu
            | Rv64Opcode::Ld
    )
}

fn is_real_store(opcode: Rv64Opcode) -> bool {
    matches!(
        opcode,
        Rv64Opcode::Sb | Rv64Opcode::Sh | Rv64Opcode::Sw | Rv64Opcode::Sd
    )
}

fn real_opcode_uses_rs2(opcode: Rv64Opcode) -> bool {
    matches!(
        opcode,
        Rv64Opcode::Add
            | Rv64Opcode::Addw
            | Rv64Opcode::Sub
            | Rv64Opcode::Subw
            | Rv64Opcode::And
            | Rv64Opcode::Or
            | Rv64Opcode::Xor
            | Rv64Opcode::Slt
            | Rv64Opcode::Sltu
            | Rv64Opcode::Sll
            | Rv64Opcode::Srl
            | Rv64Opcode::Sra
            | Rv64Opcode::Sllw
            | Rv64Opcode::Srlw
            | Rv64Opcode::Sraw
            | Rv64Opcode::Mul
            | Rv64Opcode::Mulh
            | Rv64Opcode::Mulhsu
            | Rv64Opcode::Mulhu
            | Rv64Opcode::Mulw
            | Rv64Opcode::Div
            | Rv64Opcode::Divu
            | Rv64Opcode::Rem
            | Rv64Opcode::Remu
            | Rv64Opcode::Divw
            | Rv64Opcode::Divuw
            | Rv64Opcode::Remw
            | Rv64Opcode::Remuw
            | Rv64Opcode::Sb
            | Rv64Opcode::Sh
            | Rv64Opcode::Sw
            | Rv64Opcode::Sd
            | Rv64Opcode::Beq
            | Rv64Opcode::Bne
            | Rv64Opcode::Blt
            | Rv64Opcode::Bge
            | Rv64Opcode::Bltu
            | Rv64Opcode::Bgeu
    )
}

fn narrow_store_value(opcode: Rv64Opcode, rs2_value: u64) -> u64 {
    match opcode {
        Rv64Opcode::Sb => rs2_value & 0xff,
        Rv64Opcode::Sh => rs2_value & 0xffff,
        Rv64Opcode::Sw => rs2_value & 0xffff_ffff,
        Rv64Opcode::Sd => rs2_value,
        _ => 0,
    }
}

fn sign_extend_bits(raw: u64, bits: u32) -> u64 {
    (((raw << (64 - bits)) as i64) >> (64 - bits)) as u64
}

fn narrow_load_value(row: &Rv64ExpandedRow, opcode: Rv64Opcode) -> u64 {
    let value = row.memory_before.unwrap_or(0);
    let addr = row.effective_addr.unwrap_or(0);
    let byte_offset = (addr & 0x7) as u32;
    match opcode {
        Rv64Opcode::Lb => sign_extend_bits((value >> (byte_offset * 8)) & 0xff, 8),
        Rv64Opcode::Lbu => (value >> (byte_offset * 8)) & 0xff,
        Rv64Opcode::Lh => sign_extend_bits((value >> (byte_offset * 8)) & 0xffff, 16),
        Rv64Opcode::Lhu => (value >> (byte_offset * 8)) & 0xffff,
        Rv64Opcode::Lw => sign_extend_bits((value >> (byte_offset * 8)) & 0xffff_ffff, 32),
        Rv64Opcode::Lwu => (value >> (byte_offset * 8)) & 0xffff_ffff,
        _ => row.rd_after,
    }
}

fn memory_transfer_value(row: &Rv64ExpandedRow, opcode: Option<Rv64Opcode>) -> u64 {
    match opcode {
        Some(real) if is_real_load(real) => {
            if matches!(real, Rv64Opcode::Ld) {
                row.memory_before.unwrap_or(0)
            } else {
                narrow_load_value(row, real)
            }
        }
        Some(real) if is_real_store(real) => narrow_store_value(real, row.rs2_value),
        _ => 0,
    }
}

pub fn semantic_row_from_execution_row(row: &Rv64ExpandedRow) -> [F; RV64IM_ROOT_ROW_WIDTH] {
    let mut out = [F::ZERO; RV64IM_ROOT_ROW_WIDTH];
    let real_opcode = row.trace_opcode;
    let is_load = real_opcode.is_some_and(is_real_load);
    let is_store = real_opcode.is_some_and(is_real_store);
    let writes_mem_to_rd = is_load && row.writes_rd;
    let writes_alu_to_rd = row.writes_rd && !writes_mem_to_rd;
    let preserves_rd = !writes_alu_to_rd && !writes_mem_to_rd;
    let is_jal = real_opcode == Some(Rv64Opcode::Jal);
    let is_jalr = real_opcode == Some(Rv64Opcode::Jalr);
    let is_branch = real_opcode.is_some_and(is_real_branch);
    let step_pc = row.pc.wrapping_add(4);
    let branch_taken = is_branch && row.next_pc != step_pc;
    let branch_taken_mux = is_branch && branch_taken;
    let jump_target = if is_jal || is_jalr || branch_taken_mux {
        row.next_pc
    } else {
        0
    };
    let mem_addr = if is_load || is_store {
        row.effective_addr.unwrap_or(0)
    } else {
        0
    };
    let mem_val = memory_transfer_value(row, real_opcode);
    let rd_next = if writes_alu_to_rd || writes_mem_to_rd {
        row.rd_after
    } else {
        0
    };
    let uses_rs2 = match real_opcode {
        Some(opcode) => real_opcode_uses_rs2(opcode),
        None => row.rs2 != 0,
    };

    out[COL_ONE] = F::ONE;
    encode_u64(&mut out, COL_PC_LO, COL_PC_HI, row.pc);
    encode_u64(&mut out, COL_PC_NEXT_LO, COL_PC_NEXT_HI, row.next_pc);
    encode_u64(&mut out, COL_RS1_LO, COL_RS1_HI, row.rs1_value);
    encode_u64(&mut out, COL_RS2_LO, COL_RS2_HI, row.rs2_value);
    encode_u64(&mut out, COL_RD_NEXT_LO, COL_RD_NEXT_HI, rd_next);
    encode_u64(&mut out, COL_IMM_LO, COL_IMM_HI, row.imm as u64);
    encode_u64(&mut out, COL_ALU_OUT_LO, COL_ALU_OUT_HI, row.alu_result);
    encode_u64(&mut out, COL_STEP_PC_LO, COL_STEP_PC_HI, step_pc);
    encode_u64(&mut out, COL_JUMP_TARGET_LO, COL_JUMP_TARGET_HI, jump_target);
    encode_u64(&mut out, COL_MEM_ADDR_LO, COL_MEM_ADDR_HI, mem_addr);
    encode_u64(&mut out, COL_MEM_VAL_LO, COL_MEM_VAL_HI, mem_val);
    out[COL_RD_IDX] = F::from_u64(row.rd as u64);
    out[COL_RS1_IDX] = F::from_u64(row.rs1 as u64);
    out[COL_RS2_IDX] = F::from_u64(row.rs2 as u64);
    out[COL_WRITES_ALU_TO_RD] = bool_field(writes_alu_to_rd);
    out[COL_WRITES_MEM_TO_RD] = bool_field(writes_mem_to_rd);
    out[COL_PRESERVES_RD] = bool_field(preserves_rd);
    out[COL_IS_JAL] = bool_field(is_jal);
    out[COL_IS_JALR] = bool_field(is_jalr);
    out[COL_IS_BRANCH] = bool_field(is_branch);
    out[COL_BRANCH_TAKEN] = bool_field(branch_taken);
    out[COL_BRANCH_TAKEN_MUX] = bool_field(branch_taken_mux);
    out[COL_IS_LOAD] = bool_field(is_load);
    out[COL_IS_STORE] = bool_field(is_store);
    out[COL_USES_RS2] = bool_field(uses_rs2);
    out[COL_ADVANCE_ARCH_PC] = bool_field(row.is_commit_row);
    out
}

pub fn rv64im_root_main_lane_ccs() -> Result<CcsStructure<F>, String> {
    let mut b = R1csBuilder::new(RV64IM_ROOT_ROW_WIDTH, COL_ONE)?;

    for &col in &[
        COL_WRITES_ALU_TO_RD,
        COL_WRITES_MEM_TO_RD,
        COL_PRESERVES_RD,
        COL_IS_JAL,
        COL_IS_JALR,
        COL_IS_BRANCH,
        COL_BRANCH_TAKEN,
        COL_IS_LOAD,
        COL_IS_STORE,
        COL_USES_RS2,
        COL_ADVANCE_ARCH_PC,
    ] {
        b.push_boolean(col);
    }

    b.push_row(
        [(COL_IS_BRANCH, F::ONE)],
        [(COL_BRANCH_TAKEN, F::ONE)],
        [(COL_BRANCH_TAKEN_MUX, F::ONE)],
    );
    b.push_linear_zero(
        [
            (COL_WRITES_ALU_TO_RD, F::ONE),
            (COL_WRITES_MEM_TO_RD, F::ONE),
            (COL_PRESERVES_RD, F::ONE),
            (COL_ONE, -F::ONE),
        ]
        .into_iter(),
    );
    b.push_row(
        [(COL_WRITES_ALU_TO_RD, F::ONE)],
        [(COL_RD_NEXT_LO, F::ONE), (COL_ALU_OUT_LO, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_WRITES_ALU_TO_RD, F::ONE)],
        [(COL_RD_NEXT_HI, F::ONE), (COL_ALU_OUT_HI, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_WRITES_MEM_TO_RD, F::ONE)],
        [(COL_RD_NEXT_LO, F::ONE), (COL_MEM_VAL_LO, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_WRITES_MEM_TO_RD, F::ONE)],
        [(COL_RD_NEXT_HI, F::ONE), (COL_MEM_VAL_HI, -F::ONE)],
        [],
    );
    b.push_row([(COL_PRESERVES_RD, F::ONE)], [(COL_RD_NEXT_LO, F::ONE)], []);
    b.push_row([(COL_PRESERVES_RD, F::ONE)], [(COL_RD_NEXT_HI, F::ONE)], []);
    b.push_row(
        [
            (COL_IS_JAL, F::ONE),
            (COL_IS_JALR, F::ONE),
            (COL_BRANCH_TAKEN_MUX, F::ONE),
        ],
        [(COL_PC_NEXT_LO, F::ONE), (COL_JUMP_TARGET_LO, -F::ONE)],
        [],
    );
    b.push_row(
        [
            (COL_IS_JAL, F::ONE),
            (COL_IS_JALR, F::ONE),
            (COL_BRANCH_TAKEN_MUX, F::ONE),
        ],
        [(COL_PC_NEXT_HI, F::ONE), (COL_JUMP_TARGET_HI, -F::ONE)],
        [],
    );
    b.push_row(
        [
            (COL_ADVANCE_ARCH_PC, F::ONE),
            (COL_IS_JAL, -F::ONE),
            (COL_IS_JALR, -F::ONE),
            (COL_BRANCH_TAKEN_MUX, -F::ONE),
        ],
        [(COL_PC_NEXT_LO, F::ONE), (COL_STEP_PC_LO, -F::ONE)],
        [],
    );
    b.push_row(
        [
            (COL_ADVANCE_ARCH_PC, F::ONE),
            (COL_IS_JAL, -F::ONE),
            (COL_IS_JALR, -F::ONE),
            (COL_BRANCH_TAKEN_MUX, -F::ONE),
        ],
        [(COL_PC_NEXT_HI, F::ONE), (COL_STEP_PC_HI, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_ONE, F::ONE), (COL_ADVANCE_ARCH_PC, -F::ONE)],
        [(COL_PC_NEXT_LO, F::ONE), (COL_PC_LO, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_ONE, F::ONE), (COL_ADVANCE_ARCH_PC, -F::ONE)],
        [(COL_PC_NEXT_HI, F::ONE), (COL_PC_HI, -F::ONE)],
        [],
    );
    b.push_row(
        [(COL_ONE, F::ONE), (COL_IS_LOAD, -F::ONE), (COL_IS_STORE, -F::ONE)],
        [(COL_MEM_ADDR_LO, F::ONE)],
        [],
    );
    b.push_row(
        [(COL_ONE, F::ONE), (COL_IS_LOAD, -F::ONE), (COL_IS_STORE, -F::ONE)],
        [(COL_MEM_ADDR_HI, F::ONE)],
        [],
    );
    b.push_row(
        [(COL_ONE, F::ONE), (COL_IS_LOAD, -F::ONE), (COL_IS_STORE, -F::ONE)],
        [(COL_MEM_VAL_LO, F::ONE)],
        [],
    );
    b.push_row(
        [(COL_ONE, F::ONE), (COL_IS_LOAD, -F::ONE), (COL_IS_STORE, -F::ONE)],
        [(COL_MEM_VAL_HI, F::ONE)],
        [],
    );

    Ok(b.build()?)
}
