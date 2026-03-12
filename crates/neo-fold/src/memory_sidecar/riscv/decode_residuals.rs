use super::*;
use neo_memory::riscv::lookups::{RiscvOpcode, RiscvShoutTables};
use std::sync::OnceLock;

#[path = "decode_residuals_alu_branch.rs"]
mod decode_residuals_alu_branch;
#[path = "decode_residuals_virtual.rs"]
mod decode_residuals_virtual;

#[cfg(debug_assertions)]
pub(crate) use decode_residuals_alu_branch::decode_alu_branch_lookup_residuals;
pub(crate) use decode_residuals_alu_branch::decode_alu_branch_lookup_residuals_into;
use decode_residuals_alu_branch::decode_alu_branch_lookup_residuals_sink;

const DECODE_SELECTOR_RESIDUAL_COUNT: usize = 8;
const DECODE_BITNESS_RESIDUAL_COUNT: usize = 20;
const DECODE_ALU_BRANCH_RESIDUAL_COUNT: usize =
    DECODE_FIELDS_RESIDUAL_COUNT - DECODE_SELECTOR_RESIDUAL_COUNT - DECODE_BITNESS_RESIDUAL_COUNT;

#[derive(Clone, Copy, Debug)]
struct DecodeVirtualTableIds {
    add: u64,
    addw: u64,
    vmovsignw: u64,
    vmulw: u64,
    vdivw: u64,
    vdivuw: u64,
    vremw: u64,
    vremuw: u64,
    xor: u64,
    sub: u64,
    sltu: u64,
    eq: u64,
    sra: u64,
    sllw: u64,
    srlw: u64,
    mul: u64,
    mulh: u64,
    mulhu: u64,
    div: u64,
    divu: u64,
}

#[inline]
fn decode_virtual_table_ids() -> &'static DecodeVirtualTableIds {
    static IDS: OnceLock<DecodeVirtualTableIds> = OnceLock::new();
    IDS.get_or_init(|| {
        let tables = RiscvShoutTables::new(32);
        let id = |op| tables.opcode_to_id(op).0 as u64;
        DecodeVirtualTableIds {
            add: id(RiscvOpcode::Add),
            addw: id(RiscvOpcode::Addw),
            vmovsignw: id(RiscvOpcode::VirtualMovsignWord),
            vmulw: id(RiscvOpcode::VirtualMulWord),
            vdivw: id(RiscvOpcode::VirtualDivWord),
            vdivuw: id(RiscvOpcode::VirtualDivuWord),
            vremw: id(RiscvOpcode::VirtualRemWord),
            vremuw: id(RiscvOpcode::VirtualRemuWord),
            xor: id(RiscvOpcode::Xor),
            sub: id(RiscvOpcode::Sub),
            sltu: id(RiscvOpcode::Sltu),
            eq: id(RiscvOpcode::Eq),
            sra: id(RiscvOpcode::Sra),
            sllw: id(RiscvOpcode::Sllw),
            srlw: id(RiscvOpcode::Srlw),
            mul: id(RiscvOpcode::Mul),
            mulh: id(RiscvOpcode::Mulh),
            mulhu: id(RiscvOpcode::Mulhu),
            div: id(RiscvOpcode::Div),
            divu: id(RiscvOpcode::Divu),
        }
    })
}

#[derive(Clone, Copy, Debug)]
struct DecodeVirtualConstantsK {
    alu_table_weights: [K; 7],
    branch_base_10: K,
    branch_sub_5: K,
    movsign_rhs_word: K,
    movsign_rhs_exact: K,
    v0: K,
    v1: K,
    v2: K,
    two_pow_32: K,
    rv64_all_ones: K,
    add_table_id: K,
    addw_table_id: K,
    vmovsignw_table_id: K,
    vmulw_table_id: K,
    vdivw_table_id: K,
    vdivuw_table_id: K,
    vremw_table_id: K,
    vremuw_table_id: K,
    xor_table_id: K,
    sub_table_id: K,
    sltu_table_id: K,
    eq_table_id: K,
    sra_table_id: K,
    sllw_table_id: K,
    srlw_table_id: K,
    mul_table_id: K,
    mulh_table_id: K,
    mulhu_table_id: K,
    div_table_id: K,
    divu_table_id: K,
}

#[inline]
fn k_u64(v: u64) -> K {
    K::from(F::from_u64(v))
}

#[inline]
fn decode_virtual_constants_k() -> &'static DecodeVirtualConstantsK {
    static CONSTS: OnceLock<DecodeVirtualConstantsK> = OnceLock::new();
    CONSTS.get_or_init(|| {
        let table_ids = decode_virtual_table_ids();
        let two_pow_32 = k_u64(1u64 << 32);
        DecodeVirtualConstantsK {
            alu_table_weights: [k_u64(3), k_u64(7), k_u64(5), k_u64(6), k_u64(1), k_u64(8), k_u64(2)],
            branch_base_10: k_u64(10),
            branch_sub_5: k_u64(5),
            movsign_rhs_word: k_u64(31),
            movsign_rhs_exact: k_u64(63),
            v0: k_u64(32),
            v1: k_u64(33),
            v2: k_u64(34),
            two_pow_32,
            rv64_all_ones: k_u64(u64::MAX),
            add_table_id: k_u64(table_ids.add),
            addw_table_id: k_u64(table_ids.addw),
            vmovsignw_table_id: k_u64(table_ids.vmovsignw),
            vmulw_table_id: k_u64(table_ids.vmulw),
            vdivw_table_id: k_u64(table_ids.vdivw),
            vdivuw_table_id: k_u64(table_ids.vdivuw),
            vremw_table_id: k_u64(table_ids.vremw),
            vremuw_table_id: k_u64(table_ids.vremuw),
            xor_table_id: k_u64(table_ids.xor),
            sub_table_id: k_u64(table_ids.sub),
            sltu_table_id: k_u64(table_ids.sltu),
            eq_table_id: k_u64(table_ids.eq),
            sra_table_id: k_u64(table_ids.sra),
            sllw_table_id: k_u64(table_ids.sllw),
            srlw_table_id: k_u64(table_ids.srlw),
            mul_table_id: k_u64(table_ids.mul),
            mulh_table_id: k_u64(table_ids.mulh),
            mulhu_table_id: k_u64(table_ids.mulhu),
            div_table_id: k_u64(table_ids.div),
            divu_table_id: k_u64(table_ids.divu),
        }
    })
}

#[derive(Clone, Copy, Debug)]
pub(crate) struct DecodeFieldsOpenings {
    pub rv64_exact_words: bool,
    pub active: K,
    pub halted: K,
    pub is_virtual: K,
    pub virtual_sequence_remaining: K,
    pub virtual_commit_from_prev: K,
    pub trace_rs1_addr: K,
    pub trace_rs2_addr: K,
    pub trace_rd_addr: K,
    pub rs1_val: K,
    pub rs2_val: K,
    pub rd_val: K,
    pub rs1_word: K,
    pub rs2_word: K,
    pub rd_word: K,
    pub shout_lhs_word: K,
    pub shout_lhs_hi: K,
    pub shout_rhs_word: K,
    pub shout_rhs_hi: K,
    pub shout_add_sub_key_word: K,
    pub shout_add_sub_key_hi: K,
    pub trace_rd_has_write: K,
    pub ram_addr: K,
    pub shout_has_lookup: K,
    pub shout_table_id: K,
    pub shout_val: K,
    pub shout_lhs: K,
    pub shout_rhs: K,
    pub shout_add_sub_key: K,
    pub decode_opcode: K,
    pub decode_rs1_addr: K,
    pub decode_rs2_addr: K,
    pub decode_rd_addr: K,
    pub rd_is_zero: K,
    pub decode_rd_has_write: K,
    pub ram_has_read: K,
    pub ram_has_write: K,
    pub opcode_flags: [K; 12],
    pub op_custom: K,
    pub funct3_is: [K; 8],
    pub funct3_bits: [K; 3],
    pub funct7_bits: [K; 7],
    pub imm_i: K,
    pub imm_s: K,
}

#[derive(Clone, Copy, Debug)]
struct DecodeAluBranchResidualInputs {
    rv64_exact_words: bool,
    active: K,
    is_virtual: K,
    virtual_sequence_remaining: K,
    virtual_commit_from_prev: K,
    halted: K,
    shout_has_lookup: K,
    shout_lhs: K,
    shout_rhs: K,
    shout_add_sub_key: K,
    shout_table_id: K,
    decode_opcode: K,
    trace_rs1_addr: K,
    trace_rs2_addr: K,
    trace_rd_addr: K,
    decode_rs1_addr: K,
    decode_rs2_addr: K,
    decode_rd_addr: K,
    rs1_val: K,
    rs2_val: K,
    rs1_word: K,
    rs2_word: K,
    shout_lhs_word: K,
    shout_lhs_hi: K,
    shout_rhs_word: K,
    shout_rhs_hi: K,
    shout_add_sub_key_word: K,
    shout_add_sub_key_hi: K,
    trace_rd_has_write: K,
    decode_rd_has_write: K,
    rd_is_zero: K,
    rd_val: K,
    ram_has_read: K,
    ram_has_write: K,
    ram_addr: K,
    shout_val: K,
    funct3_bits: [K; 3],
    funct7_bits: [K; 7],
    opcode_flags: [K; 12],
    op_write_flags: [K; 6],
    funct3_is: [K; 8],
    alu_reg_table_delta: K,
    alu_imm_table_delta: K,
    alu_imm_shift_rhs_delta: K,
    rs2_decode_addr: K,
    imm_i: K,
    imm_s: K,
}

#[derive(Clone, Copy, Debug)]
struct DecodeVirtualResidualInputs {
    base: DecodeAluBranchResidualInputs,
    op_alu_reg: K,
    op_alu_reg_wide: K,
    op_alu_reg_base_only: K,
    add_table_id: K,
    add_sub_combined_key_mode: K,
    mul_combined_key_mode: K,
    add_key_delta: K,
    add_key_delta_lo: K,
    add_key_delta_hi: K,
    sub_key_delta: K,
    sub_key_delta_lo: K,
    sub_key_delta_hi: K,
    mul_key_delta: K,
    two_pow_32: K,
}

#[inline]
pub(crate) fn decode_fields_weighted_residual(openings: &DecodeFieldsOpenings, fields_weights: &[K]) -> K {
    decode_fields_weighted_residual_with_scratch(openings, fields_weights)
}

#[inline]
pub(crate) fn decode_fields_weighted_residual_with_scratch(openings: &DecodeFieldsOpenings, fields_weights: &[K]) -> K {
    debug_assert_eq!(
        fields_weights.len(),
        DECODE_FIELDS_RESIDUAL_COUNT,
        "decode/fields weight length mismatch: expected {}, got {}",
        DECODE_FIELDS_RESIDUAL_COUNT,
        fields_weights.len()
    );

    let rd_keep = K::ONE - openings.rd_is_zero;
    let op_write_flags = [
        openings.opcode_flags[0] * rd_keep,
        openings.opcode_flags[1] * rd_keep,
        openings.opcode_flags[2] * rd_keep,
        openings.opcode_flags[3] * rd_keep,
        openings.opcode_flags[7] * rd_keep,
        openings.opcode_flags[8] * rd_keep,
    ];
    let alu_reg_table_delta = decode_alu_reg_table_delta_from_bits(openings.funct7_bits, openings.funct3_is);
    let alu_imm_table_delta = openings.funct7_bits[5] * openings.funct3_is[5];
    let alu_imm_shift_rhs_delta =
        (openings.funct3_is[1] + openings.funct3_is[5]) * (openings.decode_rs2_addr - openings.imm_i);

    let selector_residuals = decode_selector_residuals(
        openings.active,
        openings.decode_opcode,
        openings.opcode_flags,
        openings.op_custom,
        openings.funct3_is,
        openings.funct3_bits,
        openings.opcode_flags[11],
    );
    let bitness_residuals = decode_bitness_residuals(openings.opcode_flags, openings.funct3_is);
    let mut weighted = K::ZERO;
    let mut w_idx = 0usize;
    for r in selector_residuals {
        weighted += fields_weights[w_idx] * r;
        w_idx += 1;
    }
    for r in bitness_residuals {
        weighted += fields_weights[w_idx] * r;
        w_idx += 1;
    }
    let mut alu_branch_sink = WeightedResidualSink::new(&fields_weights[w_idx..]);
    let inputs = DecodeAluBranchResidualInputs {
        rv64_exact_words: openings.rv64_exact_words,
        active: openings.active,
        is_virtual: openings.is_virtual,
        virtual_sequence_remaining: openings.virtual_sequence_remaining,
        virtual_commit_from_prev: openings.virtual_commit_from_prev,
        halted: openings.halted,
        shout_has_lookup: openings.shout_has_lookup,
        shout_lhs: openings.shout_lhs,
        shout_rhs: openings.shout_rhs,
        shout_add_sub_key: openings.shout_add_sub_key,
        shout_table_id: openings.shout_table_id,
        decode_opcode: openings.decode_opcode,
        trace_rs1_addr: openings.trace_rs1_addr,
        trace_rs2_addr: openings.trace_rs2_addr,
        trace_rd_addr: openings.trace_rd_addr,
        decode_rs1_addr: openings.decode_rs1_addr,
        decode_rs2_addr: openings.decode_rs2_addr,
        decode_rd_addr: openings.decode_rd_addr,
        rs1_val: openings.rs1_val,
        rs2_val: openings.rs2_val,
        rs1_word: openings.rs1_word,
        rs2_word: openings.rs2_word,
        shout_lhs_word: openings.shout_lhs_word,
        shout_lhs_hi: openings.shout_lhs_hi,
        shout_rhs_word: openings.shout_rhs_word,
        shout_rhs_hi: openings.shout_rhs_hi,
        shout_add_sub_key_word: openings.shout_add_sub_key_word,
        shout_add_sub_key_hi: openings.shout_add_sub_key_hi,
        trace_rd_has_write: openings.trace_rd_has_write,
        decode_rd_has_write: openings.decode_rd_has_write,
        rd_is_zero: openings.rd_is_zero,
        rd_val: openings.rd_val,
        ram_has_read: openings.ram_has_read,
        ram_has_write: openings.ram_has_write,
        ram_addr: openings.ram_addr,
        shout_val: openings.shout_val,
        funct3_bits: openings.funct3_bits,
        funct7_bits: openings.funct7_bits,
        opcode_flags: openings.opcode_flags,
        op_write_flags,
        funct3_is: openings.funct3_is,
        alu_reg_table_delta,
        alu_imm_table_delta,
        alu_imm_shift_rhs_delta,
        rs2_decode_addr: openings.decode_rs2_addr,
        imm_i: openings.imm_i,
        imm_s: openings.imm_s,
    };
    decode_alu_branch_lookup_residuals_sink(&inputs, &mut alu_branch_sink);
    weighted += alu_branch_sink.finish();
    w_idx += alu_branch_sink.len();
    debug_assert_eq!(
        w_idx,
        fields_weights.len(),
        "decode/fields residual packing mismatch: consumed {}, weights {}",
        w_idx,
        fields_weights.len()
    );
    weighted
}

trait DecodeResidualSink {
    fn push(&mut self, value: K);
    fn len(&self) -> usize;
}

impl DecodeResidualSink for Vec<K> {
    #[inline]
    fn push(&mut self, value: K) {
        Vec::push(self, value);
    }

    #[inline]
    fn len(&self) -> usize {
        Vec::len(self)
    }
}

struct WeightedResidualSink<'a> {
    weights: &'a [K],
    len: usize,
    weighted: K,
}

impl<'a> WeightedResidualSink<'a> {
    #[inline]
    fn new(weights: &'a [K]) -> Self {
        Self {
            weights,
            len: 0,
            weighted: K::ZERO,
        }
    }

    #[inline]
    fn finish(&self) -> K {
        debug_assert_eq!(
            self.len,
            self.weights.len(),
            "decode/fields weighted alu_branch packing mismatch: consumed {}, weights {}",
            self.len,
            self.weights.len()
        );
        self.weighted
    }
}

impl DecodeResidualSink for WeightedResidualSink<'_> {
    #[inline]
    fn push(&mut self, value: K) {
        debug_assert!(
            self.len < self.weights.len(),
            "decode/fields weighted alu_branch residual count overflow: expected <= {}, got {}",
            self.weights.len(),
            self.len + 1
        );
        self.weighted += self.weights[self.len] * value;
        self.len += 1;
    }

    #[inline]
    fn len(&self) -> usize {
        self.len
    }
}

const DECODE_STAGE_GATE_TABLE_CAP: usize = 21; // supports max_remaining up to 19 (plus sentinel)

#[inline]
fn decode_build_stage_gate_table(
    remaining: K,
    max_remaining: usize,
    gates: &mut [K; DECODE_STAGE_GATE_TABLE_CAP],
) -> K {
    debug_assert!(max_remaining + 1 < DECODE_STAGE_GATE_TABLE_CAP);

    let mut prefix = [K::ONE; DECODE_STAGE_GATE_TABLE_CAP];
    let mut suffix = [K::ONE; DECODE_STAGE_GATE_TABLE_CAP];

    for r in 1..=max_remaining {
        prefix[r] = prefix[r - 1] * (remaining - K::from(F::from_u64(r as u64)));
    }
    suffix[max_remaining + 1] = K::ONE;
    for r in (1..=max_remaining).rev() {
        suffix[r] = suffix[r + 1] * (remaining - K::from(F::from_u64(r as u64)));
    }
    for r in 1..=max_remaining {
        gates[r] = prefix[r - 1] * suffix[r + 1];
    }

    prefix[max_remaining]
}

#[derive(Clone, Copy, Debug)]
struct VirtualStageRow {
    remaining: u64,
    rs1: K,
    rs2: K,
    rd_has_write: K,
    rd_addr: K,
    has_lookup: K,
    table_id: K,
    lhs: K,
    rhs: K,
    rd_val: K,
    extra: Option<K>,
}

#[inline]
fn push_virtual_stage_row<S: DecodeResidualSink>(residuals: &mut S, gate: K, row: VirtualStageRow) {
    residuals.push(gate * row.rs1);
    residuals.push(gate * row.rs2);
    residuals.push(gate * row.rd_has_write);
    residuals.push(gate * row.rd_addr);
    residuals.push(gate * row.has_lookup);
    residuals.push(gate * row.table_id);
    residuals.push(gate * row.lhs);
    residuals.push(gate * row.rhs);
    residuals.push(gate * row.rd_val);
    if let Some(extra) = row.extra {
        residuals.push(gate * extra);
    }
}

#[derive(Clone, Copy, Debug)]
struct VirtualStageSparseRow {
    remaining: u64,
    rs1: K,
    rs2: K,
    rd_has_write: K,
    rd_addr: Option<K>,
    has_lookup: K,
    table_id: Option<K>,
    lhs: Option<K>,
    rhs: Option<K>,
    rd_val: Option<K>,
    extra: Option<K>,
}

#[inline]
fn push_virtual_stage_sparse_row<S: DecodeResidualSink>(residuals: &mut S, gate: K, row: VirtualStageSparseRow) {
    residuals.push(gate * row.rs1);
    residuals.push(gate * row.rs2);
    residuals.push(gate * row.rd_has_write);
    if let Some(rd_addr) = row.rd_addr {
        residuals.push(gate * rd_addr);
    }
    residuals.push(gate * row.has_lookup);
    if let Some(table_id) = row.table_id {
        residuals.push(gate * table_id);
    }
    if let Some(lhs) = row.lhs {
        residuals.push(gate * lhs);
    }
    if let Some(rhs) = row.rhs {
        residuals.push(gate * rhs);
    }
    if let Some(rd_val) = row.rd_val {
        residuals.push(gate * rd_val);
    }
    if let Some(extra) = row.extra {
        residuals.push(gate * extra);
    }
}
