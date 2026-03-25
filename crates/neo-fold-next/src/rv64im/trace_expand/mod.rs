//! Owns trace-time inline helper expansion for hard RV64IM opcodes.

mod divrem;
mod mul;

use super::execute::{mul_high_unsigned, mul_low, sign_extend_word32, ExecutedStep};
use super::isa::Rv64Opcode;
use super::lower::{Rv64ExpandedRow, Rv64TraceOpcode, Rv64TraceVirtualOpcode};

const TRACE_REGISTER_CAPACITY: usize = 64;
const ARCHITECTURAL_REGISTER_COUNT: u8 = 32;
const RESERVED_VIRTUAL_REGISTER_COUNT: u8 = 8;
const INLINE_SCRATCH_REGISTER_BASE: u8 = ARCHITECTURAL_REGISTER_COUNT + RESERVED_VIRTUAL_REGISTER_COUNT;
const INLINE_SCRATCH_REGISTER_COUNT: u8 = 8;
const WORD_MASK32: u64 = (1u64 << 32) - 1;

#[derive(Clone, Copy)]
struct TraceInstructionSpec {
    opcode: Rv64TraceOpcode,
    rd: u8,
    rs1: u8,
    rs2: u8,
    imm: i64,
    hint: Option<u64>,
}

struct InlineTracePlan {
    steps: Vec<TraceInstructionSpec>,
    effect_index: usize,
}

#[derive(Clone)]
struct TraceRegisterFile {
    values: [u64; TRACE_REGISTER_CAPACITY],
}

#[derive(Clone, Copy)]
struct ScratchRegisterAllocator {
    next: u8,
}

impl ScratchRegisterAllocator {
    fn new() -> Self {
        Self {
            next: INLINE_SCRATCH_REGISTER_BASE,
        }
    }

    fn alloc(&mut self) -> u8 {
        let reg = self.next;
        let limit = INLINE_SCRATCH_REGISTER_BASE + INLINE_SCRATCH_REGISTER_COUNT;
        assert!(
            reg < limit && reg < TRACE_REGISTER_CAPACITY as u8,
            "trace scratch register overflow"
        );
        self.next += 1;
        reg
    }
}

struct InlineInstrAssembler {
    scratch: ScratchRegisterAllocator,
    steps: Vec<TraceInstructionSpec>,
}

impl InlineInstrAssembler {
    fn new() -> Self {
        Self {
            scratch: ScratchRegisterAllocator::new(),
            steps: Vec::new(),
        }
    }

    fn scratch(&mut self) -> u8 {
        self.scratch.alloc()
    }

    fn push_real(&mut self, opcode: Rv64Opcode, rd: u8, rs1: u8, rs2: u8) {
        self.steps.push(TraceInstructionSpec {
            opcode: Rv64TraceOpcode::Real(opcode),
            rd,
            rs1,
            rs2,
            imm: 0,
            hint: None,
        });
    }

    fn push_real_imm(&mut self, opcode: Rv64Opcode, rd: u8, rs1: u8, imm: i64) {
        self.steps.push(TraceInstructionSpec {
            opcode: Rv64TraceOpcode::Real(opcode),
            rd,
            rs1,
            rs2: 0,
            imm,
            hint: None,
        });
    }

    fn push_virtual(&mut self, opcode: Rv64TraceVirtualOpcode, rd: u8, rs1: u8, rs2: u8, hint: Option<u64>) {
        self.steps.push(TraceInstructionSpec {
            opcode: Rv64TraceOpcode::Virtual(opcode),
            rd,
            rs1,
            rs2,
            imm: 0,
            hint,
        });
    }

    fn add(&mut self, rd: u8, rs1: u8, rs2: u8) {
        self.push_real(Rv64Opcode::Add, rd, rs1, rs2);
    }

    fn andi(&mut self, rd: u8, rs1: u8, imm: i64) {
        self.push_real_imm(Rv64Opcode::Andi, rd, rs1, imm);
    }

    fn mul(&mut self, rd: u8, rs1: u8, rs2: u8) {
        self.push_real(Rv64Opcode::Mul, rd, rs1, rs2);
    }

    fn mulhu(&mut self, rd: u8, rs1: u8, rs2: u8) {
        self.push_real(Rv64Opcode::Mulhu, rd, rs1, rs2);
    }

    fn sltu(&mut self, rd: u8, rs1: u8, rs2: u8) {
        self.push_real(Rv64Opcode::Sltu, rd, rs1, rs2);
    }

    fn sub(&mut self, rd: u8, rs1: u8, rs2: u8) {
        self.push_real(Rv64Opcode::Sub, rd, rs1, rs2);
    }

    fn xor(&mut self, rd: u8, rs1: u8, rs2: u8) {
        self.push_real(Rv64Opcode::Xor, rd, rs1, rs2);
    }

    fn advice(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(Rv64TraceVirtualOpcode::Advice, rd, rs1, rs2, Some(hint));
    }

    fn assert_lte(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(Rv64TraceVirtualOpcode::AssertLte, rd, rs1, rs2, Some(hint));
    }

    fn assert_mul_no_overflow(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(Rv64TraceVirtualOpcode::AssertMulNoOverflow, rd, rs1, rs2, Some(hint));
    }

    fn assert_signed_div_identity(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(
            Rv64TraceVirtualOpcode::AssertSignedDivIdentity,
            rd,
            rs1,
            rs2,
            Some(hint),
        );
    }

    fn assert_signed_remainder_bounds(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(
            Rv64TraceVirtualOpcode::AssertSignedRemainderBounds,
            rd,
            rs1,
            rs2,
            Some(hint),
        );
    }

    fn assert_valid_div0(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(Rv64TraceVirtualOpcode::AssertValidDiv0, rd, rs1, rs2, Some(hint));
    }

    fn assert_valid_unsigned_remainder(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(
            Rv64TraceVirtualOpcode::AssertValidUnsignedRemainder,
            rd,
            rs1,
            rs2,
            Some(hint),
        );
    }

    fn change_divisor(&mut self, rd: u8, rs1: u8, rs2: u8, hint: u64) {
        self.push_virtual(Rv64TraceVirtualOpcode::ChangeDivisor, rd, rs1, rs2, Some(hint));
    }

    fn movsign(&mut self, rd: u8, rs1: u8) {
        self.push_virtual(Rv64TraceVirtualOpcode::Movsign, rd, rs1, 0, None);
    }

    fn move_result(&mut self, rd: u8, rs1: u8, hint: u64) {
        self.push_virtual(Rv64TraceVirtualOpcode::Move, rd, rs1, 0, Some(hint));
    }

    fn sign_extend_word(&mut self, rd: u8, rs1: u8, hint: Option<u64>) {
        self.push_virtual(Rv64TraceVirtualOpcode::SignExtendWord, rd, rs1, 0, hint);
    }

    fn finish(self) -> Vec<TraceInstructionSpec> {
        self.steps
    }

    fn finalize_inline(self) -> InlineTracePlan {
        let effect_index = self
            .steps
            .len()
            .checked_sub(1)
            .expect("inline sequence should not be empty");
        InlineTracePlan {
            steps: self.steps,
            effect_index,
        }
    }
}

impl TraceRegisterFile {
    fn from_step(step: &ExecutedStep) -> Self {
        let mut values = [0u64; TRACE_REGISTER_CAPACITY];
        values[..step.prev.regs.len()].copy_from_slice(&step.prev.regs);
        Self { values }
    }

    fn read(&self, reg: u8) -> u64 {
        self.values.get(reg as usize).copied().unwrap_or(0)
    }

    fn write(&mut self, reg: u8, value: u64) {
        if reg == 0 {
            self.values[0] = 0;
            return;
        }
        if let Some(slot) = self.values.get_mut(reg as usize) {
            *slot = value;
        }
        self.values[0] = 0;
    }
}

fn sign_mask(value: u64) -> u64 {
    if (value as i64) < 0 {
        u64::MAX
    } else {
        0
    }
}

fn execute_trace_instruction(spec: TraceInstructionSpec, regs: &mut TraceRegisterFile) -> (u64, u64, u64, u64, u64) {
    let rs1_value = regs.read(spec.rs1);
    let rs2_value = regs.read(spec.rs2);
    let rd_before = regs.read(spec.rd);
    let (result, writes_rd) = match spec.opcode {
        Rv64TraceOpcode::Real(Rv64Opcode::Addi) => (rs1_value.wrapping_add(spec.imm as u64), true),
        Rv64TraceOpcode::Real(Rv64Opcode::Add) => (rs1_value.wrapping_add(rs2_value), true),
        Rv64TraceOpcode::Real(Rv64Opcode::Sub) => (rs1_value.wrapping_sub(rs2_value), true),
        Rv64TraceOpcode::Real(Rv64Opcode::Andi) => (rs1_value & spec.imm as u64, true),
        Rv64TraceOpcode::Real(Rv64Opcode::Xor) => (rs1_value ^ rs2_value, true),
        Rv64TraceOpcode::Real(Rv64Opcode::Sltu) => ((rs1_value < rs2_value) as u64, true),
        Rv64TraceOpcode::Real(Rv64Opcode::Mul) => (mul_low(rs1_value, rs2_value), true),
        Rv64TraceOpcode::Real(Rv64Opcode::Mulhu) => (mul_high_unsigned(rs1_value, rs2_value), true),
        Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::Movsign) => (sign_mask(rs1_value), true),
        Rv64TraceOpcode::Virtual(
            Rv64TraceVirtualOpcode::Advice
            | Rv64TraceVirtualOpcode::ChangeDivisor
            | Rv64TraceVirtualOpcode::AssertValidDiv0
            | Rv64TraceVirtualOpcode::AssertMulNoOverflow
            | Rv64TraceVirtualOpcode::AssertLte
            | Rv64TraceVirtualOpcode::AssertValidUnsignedRemainder
            | Rv64TraceVirtualOpcode::AssertSignedDivIdentity
            | Rv64TraceVirtualOpcode::AssertSignedRemainderBounds
            | Rv64TraceVirtualOpcode::Move,
        ) => (spec.hint.expect("trace virtual hint"), true),
        Rv64TraceOpcode::Virtual(Rv64TraceVirtualOpcode::SignExtendWord) => (sign_extend_word32(rs1_value), true),
        other => panic!("unsupported RV64 trace instruction lowering for {other:?}"),
    };
    if writes_rd {
        regs.write(spec.rd, result);
    }
    let rd_after = regs.read(spec.rd);
    (rs1_value, rs2_value, rd_before, rd_after, result)
}

fn inline_rows(step: &ExecutedStep, trace_index_start: usize, plan: &InlineTracePlan) -> Vec<Rv64ExpandedRow> {
    let mut regs = TraceRegisterFile::from_step(step);
    let mut rows = Vec::with_capacity(plan.steps.len());
    let len = plan.steps.len();
    for (sequence_index, spec) in plan.steps.iter().copied().enumerate() {
        let (rs1_value, rs2_value, rd_before, rd_after, alu_result) = execute_trace_instruction(spec, &mut regs);
        let remaining = (len - sequence_index - 1) as u16;
        let is_real = remaining == 0;
        let is_effect_row = sequence_index == plan.effect_index;
        let is_commit_row = remaining == 0;
        rows.push(Rv64ExpandedRow {
            trace_index: trace_index_start + sequence_index,
            step_index: step.step_index,
            sequence_index,
            pc: step.prev.pc,
            next_pc: if is_real { step.next.pc } else { step.prev.pc },
            word: step.word,
            opcode: step.decoded.opcode,
            trace_opcode: match spec.opcode {
                Rv64TraceOpcode::Real(opcode) => Some(opcode),
                Rv64TraceOpcode::Virtual(_) => None,
            },
            trace_virtual_opcode: match spec.opcode {
                Rv64TraceOpcode::Real(_) => None,
                Rv64TraceOpcode::Virtual(opcode) => Some(opcode),
            },
            family: step.family,
            rs1: spec.rs1,
            rs1_value,
            rs2: spec.rs2,
            rs2_value,
            rd: spec.rd,
            rd_before,
            rd_after,
            imm: spec.imm,
            alu_result,
            effective_addr: None,
            memory_before: None,
            memory_after: None,
            writes_rd: spec.rd != 0,
            writes_ram: false,
            halted: is_real && step.next.halted,
            is_first_in_sequence: sequence_index == 0,
            virtual_sequence_remaining: Some(remaining),
            is_effect_row,
            is_commit_row,
            is_real,
        });
    }
    debug_assert_eq!(
        rows.get(plan.effect_index).map(|row| row.alu_result),
        Some(step.alu_result),
        "inline effect result must match architectural result"
    );
    debug_assert_eq!(
        rows.get(plan.effect_index).map(|row| row.rd_after),
        Some(step.next.read_reg(step.decoded.rd)),
        "inline effect register write must match architectural result"
    );
    rows
}

pub(crate) fn lower_inline_rows(step: &ExecutedStep, trace_index_start: usize) -> Option<Vec<Rv64ExpandedRow>> {
    mul::multiply_sequence(step)
        .or_else(|| divrem::divrem_sequence(step))
        .map(|plan| inline_rows(step, trace_index_start, &plan))
}
