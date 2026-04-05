//! Owns deterministic Stage-1 lowered-sequence semantics for accepted-proof verification.

use neo_transcript::{Poseidon2Transcript, Transcript};
use serde::{Deserialize, Serialize};

use crate::rv64im::isa::Rv64Opcode;
use crate::rv64im::lower::{Rv64TraceOpcode, Rv64TraceVirtualOpcode};
use crate::rv64im::trace_expand::{canonical_trace_plan, InlineTracePlan, TraceInstructionSpec};

use super::{sem_inputs_digest, stage1_row_digest, SemIn, Stage1RowBinding};

const TRACE_REGISTER_CAPACITY: usize = 64;

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct Stage1SemanticsProof {
    pub sem_inputs_digest: [u8; 32],
    pub row_bindings_digest: [u8; 32],
    pub sequence_count: u64,
    pub helper_row_count: u64,
    pub digest: [u8; 32],
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct ArchitecturalStepSemantics {
    next_pc: u64,
    alu_result: u64,
    effective_addr: Option<u64>,
    memory_before: Option<u64>,
    memory_after: Option<u64>,
    writes_rd: bool,
    writes_ram: bool,
    rd_after: u64,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
struct ExpectedStage1Row {
    trace_opcode: Option<Rv64Opcode>,
    trace_virtual_opcode: Option<Rv64TraceVirtualOpcode>,
    arch_rs1: u8,
    arch_rs1_value: u64,
    arch_rs2: u8,
    arch_rs2_value: u64,
    arch_rd: u8,
    arch_rd_before: u64,
    arch_imm: i64,
    rs1: u8,
    rs1_value: u64,
    rs2: u8,
    rs2_value: u64,
    rd: u8,
    rd_before: u64,
    rd_after: u64,
    imm: i64,
    alu_result: u64,
    effective_addr: Option<u64>,
    memory_before: Option<u64>,
    memory_after: Option<u64>,
    writes_rd: bool,
    writes_ram: bool,
    next_pc: u64,
    is_first_in_sequence: bool,
    virtual_sequence_remaining: Option<u16>,
    is_effect_row: bool,
    is_commit_row: bool,
    is_real: bool,
}

impl Stage1SemanticsProof {
    pub(crate) fn expected_digest(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage1_semantics_proof");
        tr.append_message(
            b"rv64im/stage1_semantics_proof/sem_inputs_digest",
            &self.sem_inputs_digest,
        );
        tr.append_message(
            b"rv64im/stage1_semantics_proof/row_bindings_digest",
            &self.row_bindings_digest,
        );
        tr.append_u64s(
            b"rv64im/stage1_semantics_proof/meta",
            &[self.sequence_count, self.helper_row_count],
        );
        tr.digest32()
    }
}

pub fn stage1_row_bindings_digest(rows: &[Stage1RowBinding]) -> [u8; 32] {
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/rv64im/stage1_rows_family");
    tr.append_u64s(b"rv64im/stage1_rows_family/len", &[rows.len() as u64]);
    for row in rows {
        tr.append_message(b"rv64im/stage1_rows_family/row_digest", &stage1_row_digest(row));
    }
    tr.digest32()
}

pub fn build_stage1_semantics_proof(sem_inputs: &[SemIn], rows: &[Stage1RowBinding]) -> Stage1SemanticsProof {
    let proof = Stage1SemanticsProof {
        sem_inputs_digest: sem_inputs_digest(sem_inputs),
        row_bindings_digest: stage1_row_bindings_digest(rows),
        sequence_count: sem_inputs
            .iter()
            .filter(|row| row.is_first_in_sequence)
            .count() as u64,
        helper_row_count: sem_inputs.iter().filter(|row| !row.is_effect_row).count() as u64,
        digest: [0; 32],
    };
    Stage1SemanticsProof {
        digest: proof.expected_digest(),
        ..proof
    }
}

pub fn verify_stage1_semantics(sem_inputs: &[SemIn], rows: &[Stage1RowBinding]) -> Result<(), String> {
    if sem_inputs.len() != rows.len() {
        return Err("stage1 semantic inputs and row bindings length mismatch".into());
    }
    let mut start = 0usize;
    while start < sem_inputs.len() {
        let step_index = sem_inputs[start].step_index;
        if !sem_inputs[start].is_first_in_sequence || sem_inputs[start].sequence_index != 0 {
            return Err(format!(
                "stage1 sequence must start at sequence index 0 for step {}",
                step_index
            ));
        }
        let mut end = start + 1;
        while end < sem_inputs.len() && sem_inputs[end].step_index == step_index {
            end += 1;
        }
        verify_sequence(&sem_inputs[start..end], &rows[start..end])?;
        start = end;
    }
    Ok(())
}

fn verify_sequence(sem_inputs: &[SemIn], rows: &[Stage1RowBinding]) -> Result<(), String> {
    let first = sem_inputs
        .first()
        .ok_or_else(|| "stage1 sequence cannot be empty".to_string())?;
    let architectural = expected_architectural_step(first)?;
    let expected_rows = expected_sequence_rows(first, architectural)?;
    if expected_rows.len() != sem_inputs.len() {
        return Err(format!(
            "stage1 sequence length mismatch for step {}: expected {}, got {}",
            first.step_index,
            expected_rows.len(),
            sem_inputs.len()
        ));
    }
    for ((input, row), expected) in sem_inputs.iter().zip(rows).zip(expected_rows) {
        verify_alignment(input, row)?;
        verify_expected_row(input, row, expected)?;
    }
    Ok(())
}

fn verify_alignment(input: &SemIn, row: &Stage1RowBinding) -> Result<(), String> {
    if row.trace_index != input.trace_index
        || row.step_index != input.step_index
        || row.sequence_index != input.sequence_index
        || row.fetch_pc != input.pc
        || row.opcode != input.opcode
        || row.trace_opcode != input.trace_opcode
        || row.trace_virtual_opcode != input.trace_virtual_opcode
        || row.family != input.family
        || row.effective_addr != input.effective_addr
        || row.writes_rd != input.writes_rd
        || row.rd != input.rd
        || row.rd_after != input.rd_after
        || row.is_first_in_sequence != input.is_first_in_sequence
        || row.virtual_sequence_remaining != input.virtual_sequence_remaining
        || row.is_effect_row != input.is_effect_row
        || row.is_commit_row != input.is_commit_row
        || row.is_real != input.is_real
    {
        return Err(format!(
            "stage1 row binding mismatch at trace index {}",
            input.trace_index
        ));
    }
    let preserves_x0 = row.rd == 0 || !row.writes_rd;
    if row.preserves_x0 != preserves_x0 {
        return Err(format!(
            "stage1 x0-preservation flag mismatch at trace index {}",
            input.trace_index
        ));
    }
    Ok(())
}

fn verify_expected_row(input: &SemIn, row: &Stage1RowBinding, expected: ExpectedStage1Row) -> Result<(), String> {
    if let Some(mismatch) = expected_row_mismatch(input, row, expected) {
        return Err(format!(
            "stage1 sequence semantics mismatch at trace index {}: {}",
            input.trace_index, mismatch
        ));
    }
    Ok(())
}

fn expected_row_mismatch(input: &SemIn, row: &Stage1RowBinding, expected: ExpectedStage1Row) -> Option<String> {
    macro_rules! mismatch {
        ($actual:expr, $expected:expr, $label:expr) => {
            if $actual != $expected {
                return Some(format!("{} expected {:?}, got {:?}", $label, $expected, $actual));
            }
        };
    }

    mismatch!(input.trace_opcode, expected.trace_opcode, "trace_opcode");
    mismatch!(
        input.trace_virtual_opcode,
        expected.trace_virtual_opcode,
        "trace_virtual_opcode"
    );
    mismatch!(input.arch_rs1, expected.arch_rs1, "arch_rs1");
    mismatch!(input.arch_rs1_value, expected.arch_rs1_value, "arch_rs1_value");
    mismatch!(input.arch_rs2, expected.arch_rs2, "arch_rs2");
    mismatch!(input.arch_rs2_value, expected.arch_rs2_value, "arch_rs2_value");
    mismatch!(input.arch_rd, expected.arch_rd, "arch_rd");
    mismatch!(input.arch_rd_before, expected.arch_rd_before, "arch_rd_before");
    mismatch!(input.arch_imm, expected.arch_imm, "arch_imm");
    mismatch!(input.rs1, expected.rs1, "rs1");
    mismatch!(input.rs1_value, expected.rs1_value, "rs1_value");
    mismatch!(input.rs2, expected.rs2, "rs2");
    mismatch!(input.rs2_value, expected.rs2_value, "rs2_value");
    mismatch!(input.rd, expected.rd, "rd");
    mismatch!(input.rd_before, expected.rd_before, "rd_before");
    mismatch!(input.rd_after, expected.rd_after, "rd_after");
    mismatch!(input.imm, expected.imm, "imm");
    mismatch!(input.effective_addr, expected.effective_addr, "effective_addr");
    mismatch!(input.memory_before, expected.memory_before, "memory_before");
    mismatch!(input.memory_after, expected.memory_after, "memory_after");
    mismatch!(input.writes_rd, expected.writes_rd, "writes_rd");
    mismatch!(input.writes_ram, expected.writes_ram, "writes_ram");
    mismatch!(
        input.is_first_in_sequence,
        expected.is_first_in_sequence,
        "is_first_in_sequence"
    );
    mismatch!(
        input.virtual_sequence_remaining,
        expected.virtual_sequence_remaining,
        "virtual_sequence_remaining"
    );
    mismatch!(input.is_effect_row, expected.is_effect_row, "is_effect_row");
    mismatch!(input.is_commit_row, expected.is_commit_row, "is_commit_row");
    mismatch!(input.is_real, expected.is_real, "is_real");
    mismatch!(row.next_pc, expected.next_pc, "next_pc");
    mismatch!(row.alu_result, expected.alu_result, "alu_result");
    mismatch!(row.effective_addr, expected.effective_addr, "row.effective_addr");
    mismatch!(row.writes_rd, expected.writes_rd, "row.writes_rd");
    mismatch!(row.rd, expected.rd, "row.rd");
    mismatch!(row.rd_after, expected.rd_after, "row.rd_after");
    mismatch!(
        row.is_first_in_sequence,
        expected.is_first_in_sequence,
        "row.is_first_in_sequence"
    );
    mismatch!(
        row.virtual_sequence_remaining,
        expected.virtual_sequence_remaining,
        "row.virtual_sequence_remaining"
    );
    mismatch!(row.is_effect_row, expected.is_effect_row, "row.is_effect_row");
    mismatch!(row.is_commit_row, expected.is_commit_row, "row.is_commit_row");
    mismatch!(row.is_real, expected.is_real, "row.is_real");
    None
}

fn expected_sequence_rows(
    first: &SemIn,
    architectural: ArchitecturalStepSemantics,
) -> Result<Vec<ExpectedStage1Row>, String> {
    if let Some(plan) = canonical_trace_plan(
        first.opcode,
        first.arch_rs1_value,
        first.arch_rs2_value,
        first.arch_rs1,
        first.arch_rs2,
        first.arch_rd,
    ) {
        expected_inline_rows(first, &plan, architectural)
    } else {
        Ok(vec![ExpectedStage1Row {
            trace_opcode: Some(first.opcode),
            trace_virtual_opcode: None,
            arch_rs1: first.arch_rs1,
            arch_rs1_value: first.arch_rs1_value,
            arch_rs2: first.arch_rs2,
            arch_rs2_value: first.arch_rs2_value,
            arch_rd: first.arch_rd,
            arch_rd_before: first.arch_rd_before,
            arch_imm: first.arch_imm,
            rs1: first.rs1,
            rs1_value: first.rs1_value,
            rs2: first.rs2,
            rs2_value: first.rs2_value,
            rd: first.rd,
            rd_before: first.rd_before,
            rd_after: architectural.rd_after,
            imm: first.imm,
            alu_result: architectural.alu_result,
            effective_addr: architectural.effective_addr,
            memory_before: architectural.memory_before,
            memory_after: architectural.memory_after,
            writes_rd: architectural.writes_rd,
            writes_ram: architectural.writes_ram,
            next_pc: architectural.next_pc,
            is_first_in_sequence: true,
            virtual_sequence_remaining: None,
            is_effect_row: true,
            is_commit_row: true,
            is_real: true,
        }])
    }
}

fn expected_inline_rows(
    first: &SemIn,
    plan: &InlineTracePlan,
    architectural: ArchitecturalStepSemantics,
) -> Result<Vec<ExpectedStage1Row>, String> {
    let mut regs = [0u64; TRACE_REGISTER_CAPACITY];
    seed_trace_registers(first, &mut regs)?;
    let mut out = Vec::with_capacity(plan.steps.len());
    let len = plan.steps.len();
    for (sequence_index, spec) in plan.steps.iter().copied().enumerate() {
        let rs1_value = read_trace_reg(&regs, spec.rs1);
        let rs2_value = read_trace_reg(&regs, spec.rs2);
        let rd_before = read_trace_reg(&regs, spec.rd);
        let alu_result = expected_trace_result(first.opcode, spec, rs1_value, rs2_value)?;
        let writes_rd = spec.rd != 0;
        if writes_rd {
            write_trace_reg(&mut regs, spec.rd, alu_result);
        }
        let remaining = (len - sequence_index - 1) as u16;
        out.push(ExpectedStage1Row {
            trace_opcode: match spec.opcode {
                Rv64TraceOpcode::Real(opcode) => Some(opcode),
                Rv64TraceOpcode::Virtual(_) => None,
            },
            trace_virtual_opcode: match spec.opcode {
                Rv64TraceOpcode::Real(_) => None,
                Rv64TraceOpcode::Virtual(opcode) => Some(opcode),
            },
            arch_rs1: first.arch_rs1,
            arch_rs1_value: first.arch_rs1_value,
            arch_rs2: first.arch_rs2,
            arch_rs2_value: first.arch_rs2_value,
            arch_rd: first.arch_rd,
            arch_rd_before: first.arch_rd_before,
            arch_imm: first.arch_imm,
            rs1: spec.rs1,
            rs1_value,
            rs2: spec.rs2,
            rs2_value,
            rd: spec.rd,
            rd_before,
            rd_after: read_trace_reg(&regs, spec.rd),
            imm: spec.imm,
            alu_result,
            effective_addr: None,
            memory_before: None,
            memory_after: None,
            writes_rd,
            writes_ram: false,
            next_pc: if remaining == 0 {
                architectural.next_pc
            } else {
                first.pc
            },
            is_first_in_sequence: sequence_index == 0,
            virtual_sequence_remaining: Some(remaining),
            is_effect_row: sequence_index == plan.effect_index,
            is_commit_row: remaining == 0,
            is_real: remaining == 0,
        });
    }
    Ok(out)
}

fn seed_trace_registers(first: &SemIn, regs: &mut [u64; TRACE_REGISTER_CAPACITY]) -> Result<(), String> {
    assign_role_value(regs, first.arch_rs1, first.arch_rs1_value, "arch_rs1")?;
    assign_role_value(regs, first.arch_rs2, first.arch_rs2_value, "arch_rs2")?;
    assign_role_value(regs, first.arch_rd, first.arch_rd_before, "arch_rd")?;
    regs[0] = 0;
    Ok(())
}

fn assign_role_value(regs: &mut [u64; TRACE_REGISTER_CAPACITY], reg: u8, value: u64, role: &str) -> Result<(), String> {
    if reg as usize >= TRACE_REGISTER_CAPACITY {
        return Err(format!("stage1 trace register {} out of range for role {}", reg, role));
    }
    if reg == 0 {
        if value != 0 {
            return Err(format!("stage1 x0 must remain zero for role {}", role));
        }
        regs[0] = 0;
        return Ok(());
    }
    let slot = &mut regs[reg as usize];
    if *slot != 0 && *slot != value {
        return Err(format!(
            "stage1 aliased register {} has inconsistent initial values for role {}",
            reg, role
        ));
    }
    *slot = value;
    Ok(())
}

fn read_trace_reg(regs: &[u64; TRACE_REGISTER_CAPACITY], reg: u8) -> u64 {
    regs.get(reg as usize).copied().unwrap_or(0)
}

fn write_trace_reg(regs: &mut [u64; TRACE_REGISTER_CAPACITY], reg: u8, value: u64) {
    if reg == 0 {
        regs[0] = 0;
        return;
    }
    if let Some(slot) = regs.get_mut(reg as usize) {
        *slot = value;
    }
    regs[0] = 0;
}

fn expected_trace_result(
    architectural_opcode: Rv64Opcode,
    spec: TraceInstructionSpec,
    rs1_value: u64,
    rs2_value: u64,
) -> Result<u64, String> {
    match spec.opcode {
        Rv64TraceOpcode::Real(Rv64Opcode::Addi) => Ok(rs1_value.wrapping_add(spec.imm as u64)),
        Rv64TraceOpcode::Real(Rv64Opcode::Add) => Ok(rs1_value.wrapping_add(rs2_value)),
        Rv64TraceOpcode::Real(Rv64Opcode::Sub) => Ok(rs1_value.wrapping_sub(rs2_value)),
        Rv64TraceOpcode::Real(Rv64Opcode::Andi) => Ok(rs1_value & spec.imm as u64),
        Rv64TraceOpcode::Real(Rv64Opcode::Xor) => Ok(rs1_value ^ rs2_value),
        Rv64TraceOpcode::Real(Rv64Opcode::Sltu) => Ok((rs1_value < rs2_value) as u64),
        Rv64TraceOpcode::Real(Rv64Opcode::Mul) => Ok(rs1_value.wrapping_mul(rs2_value)),
        Rv64TraceOpcode::Real(Rv64Opcode::Mulhu) => Ok((((rs1_value as u128) * (rs2_value as u128)) >> 64) as u64),
        Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Movsign) => Ok(sign_mask(rs1_value)),
        Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Move) => Ok(rs1_value),
        Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::SignExtendWord) => Ok(sign_extend_word32(rs1_value)),
        Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice)
        | Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::ChangeDivisor)
        | Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::AssertValidDiv0)
        | Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::AssertMulNoOverflow)
        | Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::AssertLte)
        | Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::AssertValidUnsignedRemainder)
        | Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::AssertSignedDivIdentity)
        | Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::AssertSignedRemainderBounds) => {
            expected_virtual_hint(architectural_opcode, spec, rs1_value, rs2_value)
        }
        other => Err(format!(
            "stage1 does not support trace opcode {:?} in semantic checking",
            other
        )),
    }
}

fn expected_virtual_hint(
    architectural_opcode: Rv64Opcode,
    spec: TraceInstructionSpec,
    rs1_value: u64,
    rs2_value: u64,
) -> Result<u64, String> {
    let expected = match (architectural_opcode, spec.opcode) {
        (Rv64Opcode::Div, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::ChangeDivisor))
        | (Rv64Opcode::Rem, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::ChangeDivisor)) => {
            divrem_signed64_values(rs1_value, rs2_value).0
        }
        (Rv64Opcode::Divw, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::ChangeDivisor))
        | (Rv64Opcode::Remw, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::ChangeDivisor)) => {
            divrem_signed32_values(rs1_value, rs2_value).0
        }
        (Rv64Opcode::Div, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice))
        | (Rv64Opcode::Rem, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice)) => {
            divrem_signed64_values(rs1_value, rs2_value).1
        }
        (Rv64Opcode::Divu, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice))
        | (Rv64Opcode::Remu, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice)) => {
            divrem_unsigned64_quotient(rs1_value, rs2_value)
        }
        (Rv64Opcode::Divw, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice))
        | (Rv64Opcode::Remw, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice)) => {
            divrem_signed32_values(rs1_value, rs2_value).1
        }
        (Rv64Opcode::Divuw, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice))
        | (Rv64Opcode::Remuw, Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Advice)) => {
            divrem_unsigned32_quotient(rs1_value, rs2_value)
        }
        _ => {
            return Err(format!(
                "stage1 does not expect {:?} for architectural opcode {:?}",
                spec.opcode, architectural_opcode
            ))
        }
    };
    if spec.hint != Some(expected) {
        return Err(format!(
            "stage1 helper hint mismatch for architectural opcode {:?}: expected {:016x}, got {:?}",
            architectural_opcode, expected, spec.hint
        ));
    }
    Ok(expected)
}

fn expected_architectural_step(input: &SemIn) -> Result<ArchitecturalStepSemantics, String> {
    let next_pc_default = input.pc.wrapping_add(4);
    let arch_rs1_value = input.arch_rs1_value;
    let arch_rs2_value = input.arch_rs2_value;
    let arch_rd = input.arch_rd;
    let arch_rd_before = input.arch_rd_before;
    let arch_imm = input.arch_imm;
    match input.opcode {
        Rv64Opcode::Addi => Ok(reg_write(
            next_pc_default,
            arch_rs1_value.wrapping_add(arch_imm as u64),
            arch_rd,
        )),
        Rv64Opcode::Addiw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(arch_rs1_value.wrapping_add(arch_imm as u64)),
            arch_rd,
        )),
        Rv64Opcode::Add => Ok(reg_write(
            next_pc_default,
            arch_rs1_value.wrapping_add(arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Addw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(arch_rs1_value.wrapping_add(arch_rs2_value)),
            arch_rd,
        )),
        Rv64Opcode::Sub => Ok(reg_write(
            next_pc_default,
            arch_rs1_value.wrapping_sub(arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Subw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(arch_rs1_value.wrapping_sub(arch_rs2_value)),
            arch_rd,
        )),
        Rv64Opcode::Andi => Ok(reg_write(next_pc_default, arch_rs1_value & arch_imm as u64, arch_rd)),
        Rv64Opcode::And => Ok(reg_write(next_pc_default, arch_rs1_value & arch_rs2_value, arch_rd)),
        Rv64Opcode::Ori => Ok(reg_write(next_pc_default, arch_rs1_value | arch_imm as u64, arch_rd)),
        Rv64Opcode::Or => Ok(reg_write(next_pc_default, arch_rs1_value | arch_rs2_value, arch_rd)),
        Rv64Opcode::Xori => Ok(reg_write(next_pc_default, arch_rs1_value ^ arch_imm as u64, arch_rd)),
        Rv64Opcode::Xor => Ok(reg_write(next_pc_default, arch_rs1_value ^ arch_rs2_value, arch_rd)),
        Rv64Opcode::Slti => Ok(reg_write(
            next_pc_default,
            signed_lt(arch_rs1_value, arch_imm as u64) as u64,
            arch_rd,
        )),
        Rv64Opcode::Slt => Ok(reg_write(
            next_pc_default,
            signed_lt(arch_rs1_value, arch_rs2_value) as u64,
            arch_rd,
        )),
        Rv64Opcode::Sltiu => Ok(reg_write(
            next_pc_default,
            (arch_rs1_value < arch_imm as u64) as u64,
            arch_rd,
        )),
        Rv64Opcode::Sltu => Ok(reg_write(
            next_pc_default,
            (arch_rs1_value < arch_rs2_value) as u64,
            arch_rd,
        )),
        Rv64Opcode::Slli => Ok(reg_write(
            next_pc_default,
            arch_rs1_value << shift_imm(arch_imm),
            arch_rd,
        )),
        Rv64Opcode::Slliw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(((arch_rs1_value as u32) << shift_imm_word(arch_imm)) as u64),
            arch_rd,
        )),
        Rv64Opcode::Sll => Ok(reg_write(
            next_pc_default,
            arch_rs1_value << shift_reg(arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Sllw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(((arch_rs1_value as u32) << shift_reg_word(arch_rs2_value)) as u64),
            arch_rd,
        )),
        Rv64Opcode::Srli => Ok(reg_write(
            next_pc_default,
            arch_rs1_value >> shift_imm(arch_imm),
            arch_rd,
        )),
        Rv64Opcode::Srliw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(((arch_rs1_value as u32) >> shift_imm_word(arch_imm)) as u64),
            arch_rd,
        )),
        Rv64Opcode::Srl => Ok(reg_write(
            next_pc_default,
            arch_rs1_value >> shift_reg(arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Srlw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(((arch_rs1_value as u32) >> shift_reg_word(arch_rs2_value)) as u64),
            arch_rd,
        )),
        Rv64Opcode::Srai => Ok(reg_write(
            next_pc_default,
            ((arch_rs1_value as i64) >> shift_imm(arch_imm)) as u64,
            arch_rd,
        )),
        Rv64Opcode::Sraiw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(((arch_rs1_value as u32 as i32) >> shift_imm_word(arch_imm)) as u64),
            arch_rd,
        )),
        Rv64Opcode::Sra => Ok(reg_write(
            next_pc_default,
            ((arch_rs1_value as i64) >> shift_reg(arch_rs2_value)) as u64,
            arch_rd,
        )),
        Rv64Opcode::Sraw => Ok(reg_write(
            next_pc_default,
            sign_extend_word32(((arch_rs1_value as u32 as i32) >> shift_reg_word(arch_rs2_value)) as u64),
            arch_rd,
        )),
        Rv64Opcode::Lui => Ok(reg_write(next_pc_default, arch_imm as u64, arch_rd)),
        Rv64Opcode::Auipc => Ok(reg_write(
            next_pc_default,
            input.pc.wrapping_add(arch_imm as u64),
            arch_rd,
        )),
        Rv64Opcode::Fence => Ok(no_reg_write(next_pc_default, 0, arch_rd_before)),
        Rv64Opcode::Mul => Ok(reg_write(
            next_pc_default,
            arch_rs1_value.wrapping_mul(arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Mulh => Ok(reg_write(
            next_pc_default,
            mul_high_signed(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Mulhsu => Ok(reg_write(
            next_pc_default,
            mul_high_signed_unsigned(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Mulhu => Ok(reg_write(
            next_pc_default,
            (((arch_rs1_value as u128) * (arch_rs2_value as u128)) >> 64) as u64,
            arch_rd,
        )),
        Rv64Opcode::Mulw => Ok(reg_write(
            next_pc_default,
            mulw_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Div => Ok(reg_write(
            next_pc_default,
            div_signed_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Divu => Ok(reg_write(
            next_pc_default,
            divrem_unsigned64_quotient(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Rem => Ok(reg_write(
            next_pc_default,
            rem_signed_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Remu => Ok(reg_write(
            next_pc_default,
            rem_unsigned_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Divw => Ok(reg_write(
            next_pc_default,
            divw_signed_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Divuw => Ok(reg_write(
            next_pc_default,
            divw_unsigned_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Remw => Ok(reg_write(
            next_pc_default,
            remw_signed_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Remuw => Ok(reg_write(
            next_pc_default,
            remw_unsigned_result(arch_rs1_value, arch_rs2_value),
            arch_rd,
        )),
        Rv64Opcode::Lb
        | Rv64Opcode::Lbu
        | Rv64Opcode::Lh
        | Rv64Opcode::Lhu
        | Rv64Opcode::Lw
        | Rv64Opcode::Lwu
        | Rv64Opcode::Sb
        | Rv64Opcode::Sh
        | Rv64Opcode::Sw => expected_narrow_memory(input, next_pc_default),
        Rv64Opcode::Ld => expected_ld(input, next_pc_default),
        Rv64Opcode::Sd => expected_sd(input, next_pc_default),
        Rv64Opcode::Jal => Ok(reg_write(
            input.pc.wrapping_add(arch_imm as u64),
            input.pc.wrapping_add(4),
            arch_rd,
        )),
        Rv64Opcode::Jalr => {
            let target = arch_rs1_value.wrapping_add(arch_imm as u64) & !1;
            if target % 4 != 0 {
                return Err(format!("stage1 JALR target 0x{target:016x} is not 4-byte aligned"));
            }
            Ok(reg_write(target, input.pc.wrapping_add(4), arch_rd))
        }
        Rv64Opcode::Beq => expected_branch(input, arch_rs1_value == arch_rs2_value),
        Rv64Opcode::Bne => expected_branch(input, arch_rs1_value != arch_rs2_value),
        Rv64Opcode::Blt => expected_branch(input, signed_lt(arch_rs1_value, arch_rs2_value)),
        Rv64Opcode::Bge => expected_branch(input, !signed_lt(arch_rs1_value, arch_rs2_value)),
        Rv64Opcode::Bltu => expected_branch(input, arch_rs1_value < arch_rs2_value),
        Rv64Opcode::Bgeu => expected_branch(input, arch_rs1_value >= arch_rs2_value),
        Rv64Opcode::Ecall => Ok(no_reg_write(next_pc_default, 0, arch_rd_before)),
    }
}

fn reg_write(next_pc: u64, alu_result: u64, rd: u8) -> ArchitecturalStepSemantics {
    ArchitecturalStepSemantics {
        next_pc,
        alu_result,
        effective_addr: None,
        memory_before: None,
        memory_after: None,
        writes_rd: rd != 0,
        writes_ram: false,
        rd_after: if rd == 0 { 0 } else { alu_result },
    }
}

fn no_reg_write(next_pc: u64, alu_result: u64, rd_before: u64) -> ArchitecturalStepSemantics {
    ArchitecturalStepSemantics {
        next_pc,
        alu_result,
        effective_addr: None,
        memory_before: None,
        memory_after: None,
        writes_rd: false,
        writes_ram: false,
        rd_after: rd_before,
    }
}

fn expected_narrow_memory(input: &SemIn, next_pc: u64) -> Result<ArchitecturalStepSemantics, String> {
    let (size_bytes, signed, writes_ram) = narrow_access_spec(input.opcode)
        .ok_or_else(|| format!("stage1 missing narrow access spec for {:?}", input.opcode))?;
    let addr = input.rs1_value.wrapping_add(input.imm as u64);
    let (_, byte_offset) = narrow_backing_addr(addr, size_bytes, input.opcode)?;
    let backing_word = input
        .memory_before
        .ok_or_else(|| format!("stage1 row {} is missing memory_before", input.trace_index))?;
    if writes_ram {
        let blended = blend_narrow(backing_word, byte_offset, size_bytes, input.rs2_value);
        Ok(ArchitecturalStepSemantics {
            next_pc,
            alu_result: blended,
            effective_addr: Some(addr),
            memory_before: Some(backing_word),
            memory_after: Some(blended),
            writes_rd: false,
            writes_ram: true,
            rd_after: input.rd_before,
        })
    } else {
        let value = extract_narrow(backing_word, byte_offset, size_bytes, signed);
        Ok(ArchitecturalStepSemantics {
            next_pc,
            alu_result: value,
            effective_addr: Some(addr),
            memory_before: Some(backing_word),
            memory_after: Some(backing_word),
            writes_rd: input.rd != 0,
            writes_ram: false,
            rd_after: if input.rd == 0 { 0 } else { value },
        })
    }
}

fn expected_ld(input: &SemIn, next_pc: u64) -> Result<ArchitecturalStepSemantics, String> {
    let addr = input.rs1_value.wrapping_add(input.imm as u64);
    if addr % 8 != 0 {
        return Err(format!(
            "stage1 LD effective address 0x{addr:016x} is not 8-byte aligned"
        ));
    }
    let value = input
        .memory_before
        .ok_or_else(|| format!("stage1 LD row {} is missing memory_before", input.trace_index))?;
    Ok(ArchitecturalStepSemantics {
        next_pc,
        alu_result: value,
        effective_addr: Some(addr),
        memory_before: Some(value),
        memory_after: Some(value),
        writes_rd: input.rd != 0,
        writes_ram: false,
        rd_after: if input.rd == 0 { 0 } else { value },
    })
}

fn expected_sd(input: &SemIn, next_pc: u64) -> Result<ArchitecturalStepSemantics, String> {
    let addr = input.rs1_value.wrapping_add(input.imm as u64);
    if addr % 8 != 0 {
        return Err(format!(
            "stage1 SD effective address 0x{addr:016x} is not 8-byte aligned"
        ));
    }
    let before = input
        .memory_before
        .ok_or_else(|| format!("stage1 SD row {} is missing memory_before", input.trace_index))?;
    Ok(ArchitecturalStepSemantics {
        next_pc,
        alu_result: input.rs2_value,
        effective_addr: Some(addr),
        memory_before: Some(before),
        memory_after: Some(input.rs2_value),
        writes_rd: false,
        writes_ram: true,
        rd_after: input.rd_before,
    })
}

fn expected_branch(input: &SemIn, taken: bool) -> Result<ArchitecturalStepSemantics, String> {
    let next_pc = if taken {
        let target = input.pc.wrapping_add(input.imm as u64);
        if target % 4 != 0 {
            return Err(format!(
                "stage1 branch target 0x{target:016x} is not 4-byte aligned for {:?}",
                input.opcode
            ));
        }
        target
    } else {
        input.pc.wrapping_add(4)
    };
    Ok(ArchitecturalStepSemantics {
        next_pc,
        alu_result: taken as u64,
        effective_addr: None,
        memory_before: None,
        memory_after: None,
        writes_rd: false,
        writes_ram: false,
        rd_after: input.rd_before,
    })
}

fn sign_mask(value: u64) -> u64 {
    if (value as i64) < 0 {
        u64::MAX
    } else {
        0
    }
}

fn sign_extend_word32(value: u64) -> u64 {
    (value as u32 as i32 as i64) as u64
}

fn signed_lt(lhs: u64, rhs: u64) -> bool {
    (lhs as i64) < (rhs as i64)
}

fn shift_imm(imm: i64) -> u32 {
    (imm as u64 & 0x3f) as u32
}

fn shift_imm_word(imm: i64) -> u32 {
    (imm as u64 & 0x1f) as u32
}

fn shift_reg(rs2_value: u64) -> u32 {
    (rs2_value & 0x3f) as u32
}

fn shift_reg_word(rs2_value: u64) -> u32 {
    (rs2_value & 0x1f) as u32
}

fn mulw_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as i32 as i64;
    let rhs_word = rhs as u32 as i32 as i64;
    sign_extend_word32(lhs_word.wrapping_mul(rhs_word) as u64)
}

fn mul_high_signed(lhs: u64, rhs: u64) -> u64 {
    let product = (lhs as i64 as i128) * (rhs as i64 as i128);
    ((product as u128) >> 64) as u64
}

fn mul_high_signed_unsigned(lhs: u64, rhs: u64) -> u64 {
    let product = (lhs as i64 as i128) * (rhs as i128);
    ((product as u128) >> 64) as u64
}

fn div_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_signed = lhs as i64;
    let rhs_signed = rhs as i64;
    if rhs_signed == 0 {
        u64::MAX
    } else if lhs_signed == i64::MIN && rhs_signed == -1 {
        lhs_signed as u64
    } else {
        (lhs_signed / rhs_signed) as u64
    }
}

fn rem_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_signed = lhs as i64;
    let rhs_signed = rhs as i64;
    if rhs_signed == 0 {
        lhs
    } else if lhs_signed == i64::MIN && rhs_signed == -1 {
        0
    } else {
        (lhs_signed % rhs_signed) as u64
    }
}

fn divw_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as i32;
    let rhs_word = rhs as u32 as i32;
    if rhs_word == 0 {
        u64::MAX
    } else if lhs_word == i32::MIN && rhs_word == -1 {
        sign_extend_word32(lhs_word as u32 as u64)
    } else {
        sign_extend_word32((lhs_word / rhs_word) as u32 as u64)
    }
}

fn remw_signed_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as i32;
    let rhs_word = rhs as u32 as i32;
    if rhs_word == 0 {
        sign_extend_word32(lhs_word as u32 as u64)
    } else if lhs_word == i32::MIN && rhs_word == -1 {
        0
    } else {
        sign_extend_word32((lhs_word % rhs_word) as u32 as u64)
    }
}

fn divw_unsigned_result(lhs: u64, rhs: u64) -> u64 {
    sign_extend_word32(divrem_unsigned32_quotient(lhs, rhs))
}

fn remw_unsigned_result(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as u64;
    let rhs_word = rhs as u32 as u64;
    if rhs_word == 0 {
        sign_extend_word32(lhs_word)
    } else {
        sign_extend_word32(lhs_word % rhs_word)
    }
}

fn rem_unsigned_result(lhs: u64, rhs: u64) -> u64 {
    if rhs == 0 {
        lhs
    } else {
        lhs % rhs
    }
}

fn divrem_signed64_values(lhs: u64, rhs: u64) -> (u64, u64) {
    let dividend = lhs as i64;
    let divisor = rhs as i64;
    let overflow = dividend == i64::MIN && divisor == -1;
    let effective_divisor = if overflow { 1 } else { divisor };
    let quotient = if divisor == 0 {
        -1
    } else if overflow {
        dividend
    } else {
        dividend / divisor
    };
    (effective_divisor as u64, quotient as u64)
}

fn divrem_signed32_values(lhs: u64, rhs: u64) -> (u64, u64) {
    let dividend = lhs as u32 as i32;
    let divisor = rhs as u32 as i32;
    let overflow = dividend == i32::MIN && divisor == -1;
    let effective_divisor = if overflow { 1 } else { divisor };
    let quotient = if divisor == 0 {
        -1
    } else if overflow {
        dividend
    } else {
        dividend / divisor
    };
    (effective_divisor as u64, quotient as u64)
}

fn divrem_unsigned64_quotient(lhs: u64, rhs: u64) -> u64 {
    if rhs == 0 {
        u64::MAX
    } else {
        lhs / rhs
    }
}

fn divrem_unsigned32_quotient(lhs: u64, rhs: u64) -> u64 {
    let lhs_word = lhs as u32 as u64;
    let rhs_word = rhs as u32 as u64;
    if rhs_word == 0 {
        u32::MAX as u64
    } else {
        lhs_word / rhs_word
    }
}

fn narrow_access_spec(opcode: Rv64Opcode) -> Option<(u32, bool, bool)> {
    match opcode {
        Rv64Opcode::Lb => Some((1, true, false)),
        Rv64Opcode::Lbu => Some((1, false, false)),
        Rv64Opcode::Lh => Some((2, true, false)),
        Rv64Opcode::Lhu => Some((2, false, false)),
        Rv64Opcode::Lw => Some((4, true, false)),
        Rv64Opcode::Lwu => Some((4, false, false)),
        Rv64Opcode::Sb => Some((1, false, true)),
        Rv64Opcode::Sh => Some((2, false, true)),
        Rv64Opcode::Sw => Some((4, false, true)),
        _ => None,
    }
}

fn narrow_backing_addr(addr: u64, size_bytes: u32, opcode: Rv64Opcode) -> Result<(u64, u32), String> {
    if addr % size_bytes as u64 != 0 {
        return Err(format!(
            "{opcode:?} effective address 0x{addr:016x} is not naturally aligned for {size_bytes} bytes"
        ));
    }
    let byte_offset = (addr & 0x7) as u32;
    if byte_offset + size_bytes > 8 {
        return Err(format!(
            "{opcode:?} effective address 0x{addr:016x} crosses an 8-byte backing word"
        ));
    }
    Ok((addr & !0x7, byte_offset))
}

fn extract_narrow(word: u64, byte_offset: u32, size_bytes: u32, signed: bool) -> u64 {
    let bits = size_bytes * 8;
    let mask = if bits == 64 { u64::MAX } else { (1u64 << bits) - 1 };
    let raw = (word >> (byte_offset * 8)) & mask;
    if signed {
        (((raw << (64 - bits)) as i64) >> (64 - bits)) as u64
    } else {
        raw
    }
}

fn blend_narrow(word: u64, byte_offset: u32, size_bytes: u32, value: u64) -> u64 {
    let bits = size_bytes * 8;
    let field_mask = if bits == 64 { u64::MAX } else { (1u64 << bits) - 1 };
    let shifted_mask = field_mask << (byte_offset * 8);
    let shifted_value = (value & field_mask) << (byte_offset * 8);
    (word & !shifted_mask) | shifted_value
}
