//! Owns the concrete CHIP-8 runtime builder and 24-column witness generation.
//!
//! Produces one CCS row per instruction, except Fx55 (StoreRegs) and Fx65
//! (LoadRegs) which micro-step into one row per register (burst mode).
//! PC is word-addressed throughout: program starts at word 0x100.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsWitness, Mat};
use neo_math::{D, F};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::kernel::KernelStepAux;
use crate::chip8::spec::{
    decode_opcode, Chip8DecodedStep, Chip8Opcode, Chip8Program, Chip8State, Chip8StepTrace, Chip8VmSpec,
    CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START, COL_BURST_LAST, COL_IS_BRANCH, COL_IS_JUMP, COL_IS_MEMOP, COL_I_NEXT,
    COL_I_REG, COL_KK, COL_LOOKUP_OUTPUT, COL_MEM_VALUE, COL_NNN_ADDR, COL_NNN_WORD, COL_ONE, COL_PC, COL_PC_NEXT,
    COL_PRESERVES_X, COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT, COL_REG_Y, COL_WRITES_LOOKUP_TO_X, COL_WRITES_MEM_TO_X,
    COL_WRITES_NNN_TO_I, COL_X_IDX, COL_Y_IDX, PUBLIC_INPUTS, WITNESS_WIDTH,
};
use crate::chip8::tables::{
    decode_to_output, flatten_alu_key, flatten_eq4_key, DecodeOutput, LookupKind, OperandSelector, RAM_SINK_ADDR,
    REG_SINK_ADDR,
};
use crate::proof::{
    BytecodeFetchRecord, RamAccessRecord, RegisterAccessRecord, RegisterBank, StepBuild, StepExtensionData, StepInput,
};
use crate::vm::VmSpec;
use crate::vm::VmTraceBuilder;

// ---------------------------------------------------------------------------
// Error
// ---------------------------------------------------------------------------

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Chip8BuildError {
    Program(String),
    Unsupported(String),
    StateMismatch(String),
}

impl core::fmt::Display for Chip8BuildError {
    fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
        match self {
            Self::Program(msg) | Self::Unsupported(msg) | Self::StateMismatch(msg) => f.write_str(msg),
        }
    }
}

impl std::error::Error for Chip8BuildError {}

// ---------------------------------------------------------------------------
// Execution step (one per logical instruction, pre-expansion)
// ---------------------------------------------------------------------------

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Chip8ExecutionStep {
    pub prev: Chip8State,
    pub next: Chip8State,
    pub trace: Chip8StepTrace,
}

// ---------------------------------------------------------------------------
// Word-address helpers
// ---------------------------------------------------------------------------

/// Convert a byte-addressed PC to a word address.
#[inline]
fn pc_to_word(byte_pc: u16) -> u16 {
    byte_pc / 2
}

// ---------------------------------------------------------------------------
// Trace builder
// ---------------------------------------------------------------------------

pub struct Chip8TraceBuilder<'a, L> {
    log: &'a L,
}

impl<'a, L> Chip8TraceBuilder<'a, L> {
    pub fn new(log: &'a L) -> Self {
        Self { log }
    }

    /// Execute the program for `step_count` logical instructions. Each
    /// instruction produces one `Chip8ExecutionStep` regardless of burst
    /// expansion (burst expansion happens at the CCS-row level).
    pub fn execute_program(
        program: &Chip8Program,
        initial_state: &Chip8State,
        step_count: usize,
    ) -> Result<Vec<Chip8ExecutionStep>, Chip8BuildError> {
        let mut state = initial_state.clone();
        let mut out = Vec::with_capacity(step_count);
        for _ in 0..step_count {
            let opcode = program
                .opcode_at(state.pc)
                .ok_or_else(|| Chip8BuildError::Program(format!("no opcode at pc 0x{:03x}", state.pc)))?;
            let next = execute_step(program, &state, opcode)?;
            out.push(Chip8ExecutionStep {
                prev: state.clone(),
                next: next.clone(),
                trace: Chip8StepTrace { opcode },
            });
            state = next;
        }
        Ok(out)
    }

    /// Build all CCS rows for a program. Fx55/Fx65 expand into multiple rows.
    pub fn build_program(
        &self,
        vm: &Chip8VmSpec,
        program: &Chip8Program,
        initial_state: &Chip8State,
        step_count: usize,
    ) -> Result<Vec<StepBuild>, Chip8BuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let execution = Self::execute_program(program, initial_state, step_count)?;
        let mut out = Vec::new();
        for step in &execution {
            let rows = self.build_rows(vm, program, &step.prev, &step.next, &step.trace)?;
            out.extend(rows);
        }
        Ok(out)
    }

    /// Build one or more CCS rows for a single instruction.
    /// Normal instructions produce 1 row. Fx55/Fx65 produce (x+1) rows.
    fn build_rows(
        &self,
        vm: &Chip8VmSpec,
        _program: &Chip8Program,
        prev: &Chip8State,
        next: &Chip8State,
        trace: &Chip8StepTrace,
    ) -> Result<Vec<StepBuild>, Chip8BuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let decoded = decode_opcode(trace.opcode).map_err(Chip8BuildError::Unsupported)?;
        let dec_out = decode_to_output(trace.opcode);

        match decoded.opcode_id {
            Chip8Opcode::StoreRegs | Chip8Opcode::LoadRegs => {
                self.build_burst_rows(vm, prev, next, trace, &decoded, &dec_out)
            }
            _ => {
                let build = self.build_single_row(vm, prev, next, trace, &decoded, &dec_out, None)?;
                Ok(vec![build])
            }
        }
    }

    /// Build CCS rows for a burst instruction (Fx55/Fx65).
    fn build_burst_rows(
        &self,
        vm: &Chip8VmSpec,
        prev: &Chip8State,
        next: &Chip8State,
        trace: &Chip8StepTrace,
        decoded: &Chip8DecodedStep,
        dec_out: &DecodeOutput,
    ) -> Result<Vec<StepBuild>, Chip8BuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let x_bound = decoded.x as usize;
        let mut rows = Vec::with_capacity(x_bound + 1);
        for burst_index in 0..=x_bound {
            let info = BurstInfo {
                burst_index: burst_index as u8,
                x_bound: decoded.x,
            };
            let build = self.build_single_row(vm, prev, next, trace, decoded, dec_out, Some(info))?;
            rows.push(build);
        }
        Ok(rows)
    }

    /// Build exactly one CCS row (24 columns).
    fn build_single_row(
        &self,
        vm: &Chip8VmSpec,
        prev: &Chip8State,
        next: &Chip8State,
        trace: &Chip8StepTrace,
        decoded: &Chip8DecodedStep,
        dec_out: &DecodeOutput,
        burst: Option<BurstInfo>,
    ) -> Result<StepBuild, Chip8BuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let pc_word = pc_to_word(prev.pc);
        let pc_next_word = pc_to_word(next.pc);

        // For burst rows, determine the effective register index and burst flags.
        let (x_idx, burst_last) = match burst {
            Some(bi) => (bi.burst_index, bi.burst_index == bi.x_bound),
            None => (effective_x_idx(dec_out, decoded), false),
        };
        let y_idx = if burst.is_some() {
            0
        } else if dec_out.uses_y {
            decoded.y
        } else {
            0
        };

        // Resolve register values at the effective index.
        let reg_x_val = prev.v[x_idx as usize];
        let reg_y_val = if dec_out.uses_y { prev.v[decoded.y as usize] } else { 0 };

        // reg_x_next: the post-step value of V[x_idx].
        let reg_x_next_val = next.v[x_idx as usize];

        // Compute LOOKUP_OUTPUT based on LookupKind.
        let lookup_output = compute_lookup_output(dec_out, reg_x_val, reg_y_val, decoded.kk);

        // Compute MEM_VALUE for burst rows.
        let mem_value = if burst.is_some() {
            let ram_addr = prev.i as usize + x_idx as usize;
            if decoded.opcode_id == Chip8Opcode::StoreRegs {
                prev.v[x_idx as usize]
            } else {
                // LoadRegs: value loaded from RAM
                prev.memory[ram_addr]
            }
        } else {
            0u8
        };

        // RAM address for memop rows.
        let ram_addr_val = if dec_out.is_memop && burst.is_some() {
            prev.i as u16 + x_idx as u16
        } else {
            0u16
        };

        // PC_NEXT: only advances on last burst row (or on non-burst rows).
        let effective_pc_next = if let Some(bi) = burst {
            if bi.burst_index == bi.x_bound {
                pc_next_word
            } else {
                pc_word // same PC for non-last burst rows
            }
        } else {
            pc_next_word
        };

        // Fill the 24-column witness.
        let mut z = vec![F::ZERO; WITNESS_WIDTH];
        z[COL_ONE] = F::ONE;
        z[COL_PC] = F::from_u64(pc_word as u64);
        z[COL_PC_NEXT] = F::from_u64(effective_pc_next as u64);
        z[COL_REG_X] = F::from_u64(reg_x_val as u64);
        z[COL_REG_Y] = F::from_u64(reg_y_val as u64);
        z[COL_REG_X_NEXT] = F::from_u64(reg_x_next_val as u64);
        z[COL_I_REG] = F::from_u64(prev.i as u64);
        z[COL_I_NEXT] = F::from_u64(next.i as u64);
        z[COL_KK] = F::from_u64(decoded.kk as u64);
        z[COL_NNN_ADDR] = F::from_u64(dec_out.nnn_addr_dec as u64);
        z[COL_NNN_WORD] = F::from_u64(dec_out.nnn_word_dec as u64);
        z[COL_MEM_VALUE] = F::from_u64(mem_value as u64);
        z[COL_LOOKUP_OUTPUT] = F::from_u64(lookup_output as u64);
        z[COL_WRITES_LOOKUP_TO_X] = fbool(dec_out.writes_lookup_to_x);
        z[COL_WRITES_MEM_TO_X] = fbool(dec_out.writes_mem_to_x);
        z[COL_PRESERVES_X] = fbool(dec_out.preserves_x);
        z[COL_WRITES_NNN_TO_I] = fbool(dec_out.writes_nnn_to_i);
        z[COL_IS_JUMP] = fbool(dec_out.is_jump);
        z[COL_IS_BRANCH] = fbool(dec_out.is_branch);
        z[COL_IS_MEMOP] = fbool(dec_out.is_memop);
        z[COL_X_IDX] = F::from_u64(x_idx as u64);
        z[COL_Y_IDX] = F::from_u64(y_idx as u64);
        z[COL_BURST_LAST] = fbool(burst_last);
        z[COL_RAM_ADDR] = F::from_u64(ram_addr_val as u64);

        // Build auxiliary data.
        let lhs = resolve_operand(dec_out.lhs_selector, reg_x_val, reg_y_val, decoded.kk);
        let rhs = resolve_operand(dec_out.rhs_selector, reg_x_val, reg_y_val, decoded.kk);
        let alu_key = flatten_alu_key(dec_out.lookup_kind, lhs, rhs);
        let eq4_key = flatten_eq4_key(x_idx, dec_out.x_bound);

        let (reg_ra_x_addr, reg_ra_y_addr, reg_wa_addr) = if let Some(_) = burst {
            let wa = if dec_out.is_load { x_idx as usize } else { REG_SINK_ADDR };
            (x_idx as usize, REG_SINK_ADDR, wa)
        } else {
            let ra_x = x_idx as usize;
            let ra_y = if dec_out.uses_y {
                decoded.y as usize
            } else {
                REG_SINK_ADDR
            };
            let wa = if dec_out.writes_lookup_to_x || dec_out.writes_mem_to_x {
                decoded.x as usize
            } else if dec_out.writes_nnn_to_i {
                16
            } else {
                REG_SINK_ADDR
            };
            (ra_x, ra_y, wa)
        };

        let reg_ra_i_addr = 16usize; // I register is always at index 16
        let (ram_ra_addr, ram_wa_addr) = if dec_out.is_memop && burst.is_some() {
            let addr = ram_addr_val as usize;
            if dec_out.reads_ram {
                (addr, RAM_SINK_ADDR)
            } else {
                (RAM_SINK_ADDR, addr)
            }
        } else {
            (RAM_SINK_ADDR, RAM_SINK_ADDR)
        };

        let reg_inc = if let Some(_) = burst {
            if dec_out.is_load {
                field_delta_u8(reg_x_next_val, reg_x_val)
            } else {
                F::ZERO
            }
        } else if dec_out.writes_lookup_to_x || dec_out.writes_mem_to_x {
            field_delta_u8(reg_x_next_val, reg_x_val)
        } else if dec_out.writes_nnn_to_i {
            field_delta_u16(next.i, prev.i)
        } else {
            F::ZERO
        };
        let ram_inc = if let Some(_) = burst {
            if dec_out.is_store {
                field_delta_u8(next.memory[ram_addr_val as usize], prev.memory[ram_addr_val as usize])
            } else {
                F::ZERO
            }
        } else {
            F::ZERO
        };

        let aux = KernelStepAux {
            fetch_addr: pc_word as usize,
            decode_addr: trace.opcode,
            alu_key,
            eq4_key,
            reg_ra_x_addr,
            reg_ra_y_addr,
            reg_ra_i_addr,
            reg_wa_addr,
            ram_ra_addr,
            ram_wa_addr,
            reg_inc,
            ram_inc,
            uses_y: dec_out.uses_y,
            reads_ram: dec_out.reads_ram,
            writes_ram: dec_out.writes_ram,
        };

        // Pack into row-major matrix and build the step.
        let z_mat = pack_row_major(&z);
        let x_pub = z[..PUBLIC_INPUTS].to_vec();
        let w = z[PUBLIC_INPUTS..].to_vec();

        let burst_label = burst
            .map(|bi| format!("[{}/{}]", bi.burst_index, bi.x_bound))
            .unwrap_or_default();

        let prepared = StepInput {
            label: format!("chip8@w{:03x}:0x{:04x}{}", pc_word, trace.opcode, burst_label),
            mcs: CcsClaim {
                c: self.log.commit(&z_mat),
                x: x_pub,
                m_in: vm.core_ccs_spec().m_in,
            },
            witness: CcsWitness { w, Z: z_mat },
            deferred_extensions: decoded.opcode_id.family_requirements().to_vec(),
        };

        let extension_data = build_row_extension_data(decoded, dec_out, prev, next, trace, burst);

        Ok(StepBuild {
            public_step: prepared.instance(),
            prepared,
            extension_data,
            kernel_aux: Some(aux),
        })
    }
}

// ---------------------------------------------------------------------------
// VmTraceBuilder impl
// ---------------------------------------------------------------------------

impl<'a, L> VmTraceBuilder<Chip8VmSpec> for Chip8TraceBuilder<'a, L>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
{
    type Program = Chip8Program;
    type MachineState = Chip8State;
    type StepTrace = Chip8StepTrace;
    type Error = Chip8BuildError;

    fn build_step(
        &self,
        vm: &Chip8VmSpec,
        program: &Self::Program,
        prev: &Self::MachineState,
        next: &Self::MachineState,
        trace: &Self::StepTrace,
    ) -> Result<StepBuild, Self::Error> {
        // For the trait interface, return only the first row. Callers needing
        // burst expansion should use `build_rows` or `build_program` directly.
        let rows = self.build_rows(vm, program, prev, next, trace)?;
        rows.into_iter()
            .next()
            .ok_or_else(|| Chip8BuildError::Program("no rows produced".into()))
    }
}

// ---------------------------------------------------------------------------
// Execution
// ---------------------------------------------------------------------------

pub fn execute_step(program: &Chip8Program, prev: &Chip8State, opcode: u16) -> Result<Chip8State, Chip8BuildError> {
    let decoded = decode_opcode(opcode).map_err(Chip8BuildError::Unsupported)?;
    let mut next = prev.clone();
    match decoded.opcode_id {
        Chip8Opcode::LdImm => {
            next.v[decoded.x as usize] = decoded.kk;
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::AddImm => {
            next.v[decoded.x as usize] = prev.v[decoded.x as usize].wrapping_add(decoded.kk);
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::Mov => {
            next.v[decoded.x as usize] = prev.v[decoded.y as usize];
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::AddReg => {
            next.v[decoded.x as usize] = prev.v[decoded.x as usize].wrapping_add(prev.v[decoded.y as usize]);
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::SkipEqImm => {
            next.pc = prev.pc + if prev.v[decoded.x as usize] == decoded.kk { 4 } else { 2 };
        }
        Chip8Opcode::Jump => {
            next.pc = decoded.nnn;
        }
        Chip8Opcode::LdI => {
            next.i = decoded.nnn;
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::StoreRegs => {
            let base = prev.i as usize;
            let count = decoded.x as usize + 1;
            if base + count > CHIP8_MEMORY_BYTES {
                return Err(Chip8BuildError::Program(format!(
                    "STORE exceeds RAM bounds at I=0x{:03x}, count={count}",
                    prev.i
                )));
            }
            for idx in 0..count {
                next.memory[base + idx] = prev.v[idx];
            }
            next.pc = prev.pc + 2;
        }
        Chip8Opcode::LoadRegs => {
            let base = prev.i as usize;
            let count = decoded.x as usize + 1;
            if base + count > CHIP8_MEMORY_BYTES {
                return Err(Chip8BuildError::Program(format!(
                    "LOAD exceeds RAM bounds at I=0x{:03x}, count={count}",
                    prev.i
                )));
            }
            for idx in 0..count {
                next.v[idx] = prev.memory[base + idx];
            }
            next.pc = prev.pc + 2;
        }
    }
    if next.pc < CHIP8_PROGRAM_START && next.pc as usize + 1 >= program.bytes.len() {
        return Err(Chip8BuildError::Program(format!(
            "next pc 0x{:03x} escapes loaded program",
            next.pc
        )));
    }
    Ok(next)
}

// ---------------------------------------------------------------------------
// Extension data (per CCS row)
// ---------------------------------------------------------------------------

fn build_row_extension_data(
    decoded: &Chip8DecodedStep,
    dec_out: &DecodeOutput,
    prev: &Chip8State,
    next: &Chip8State,
    trace: &Chip8StepTrace,
    burst: Option<BurstInfo>,
) -> StepExtensionData {
    let mut out = StepExtensionData {
        bytecode_fetch: Some(BytecodeFetchRecord {
            pc: prev.pc,
            opcode: trace.opcode,
        }),
        ..StepExtensionData::default()
    };

    if let Some(bi) = burst {
        // Burst row: one register + one RAM access per row.
        let idx = bi.burst_index as usize;
        let ram_addr = prev.i as u16 + bi.burst_index as u16;
        if dec_out.is_store {
            out.register_reads.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: bi.burst_index,
                value: prev.v[idx] as u16,
            });
            out.ram_writes.push(RamAccessRecord {
                addr: ram_addr,
                value: prev.v[idx],
            });
        } else {
            // LoadRegs
            out.ram_reads.push(RamAccessRecord {
                addr: ram_addr,
                value: prev.memory[ram_addr as usize],
            });
            out.register_writes.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: bi.burst_index,
                value: next.v[idx] as u16,
            });
        }
        return out;
    }

    // Non-burst instructions.
    let x = decoded.x as usize;
    let y = decoded.y as usize;
    match decoded.opcode_id {
        Chip8Opcode::LdImm => {
            out.register_writes.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.x,
                value: next.v[x] as u16,
            });
        }
        Chip8Opcode::AddImm => {
            out.register_reads.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.x,
                value: prev.v[x] as u16,
            });
            out.register_writes.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.x,
                value: next.v[x] as u16,
            });
        }
        Chip8Opcode::Mov => {
            out.register_reads.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.y,
                value: prev.v[y] as u16,
            });
            out.register_writes.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.x,
                value: next.v[x] as u16,
            });
        }
        Chip8Opcode::AddReg => {
            out.register_reads.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.x,
                value: prev.v[x] as u16,
            });
            out.register_reads.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.y,
                value: prev.v[y] as u16,
            });
            out.register_writes.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.x,
                value: next.v[x] as u16,
            });
        }
        Chip8Opcode::SkipEqImm => {
            out.register_reads.push(RegisterAccessRecord {
                bank: RegisterBank::V,
                index: decoded.x,
                value: prev.v[x] as u16,
            });
        }
        Chip8Opcode::Jump => {}
        Chip8Opcode::LdI => {
            out.register_writes.push(RegisterAccessRecord {
                bank: RegisterBank::I,
                index: 0,
                value: next.i,
            });
        }
        // StoreRegs/LoadRegs are handled in burst path above.
        Chip8Opcode::StoreRegs | Chip8Opcode::LoadRegs => unreachable!(),
    }
    out
}

/// Build extension data for a full execution step (used by the verifier
/// pipeline which does not expand bursts into rows).
pub fn build_extension_trace(step: &Chip8ExecutionStep) -> StepExtensionData {
    let mut rows = build_row_extension_trace(step);
    if rows.len() == 1 {
        return rows.pop().expect("single-row trace");
    }

    let mut combined = StepExtensionData {
        bytecode_fetch: Some(BytecodeFetchRecord {
            pc: step.prev.pc,
            opcode: step.trace.opcode,
        }),
        ..StepExtensionData::default()
    };
    for row_ext in rows {
        combined.register_reads.extend(row_ext.register_reads);
        combined.register_writes.extend(row_ext.register_writes);
        combined.ram_reads.extend(row_ext.ram_reads);
        combined.ram_writes.extend(row_ext.ram_writes);
    }
    combined
}

/// Build per-row extension data for a full execution step.
pub fn build_row_extension_trace(step: &Chip8ExecutionStep) -> Vec<StepExtensionData> {
    let decoded = decode_opcode(step.trace.opcode).expect("execute_program only emits supported opcodes");
    let dec_out = decode_to_output(step.trace.opcode);

    match decoded.opcode_id {
        Chip8Opcode::StoreRegs | Chip8Opcode::LoadRegs => {
            let mut rows = Vec::with_capacity(decoded.x as usize + 1);
            for burst_index in 0..=decoded.x {
                let bi = BurstInfo {
                    burst_index,
                    x_bound: decoded.x,
                };
                rows.push(build_row_extension_data(
                    &decoded,
                    &dec_out,
                    &step.prev,
                    &step.next,
                    &step.trace,
                    Some(bi),
                ));
            }
            rows
        }
        _ => vec![build_row_extension_data(
            &decoded,
            &dec_out,
            &step.prev,
            &step.next,
            &step.trace,
            None,
        )],
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#[derive(Clone, Copy, Debug)]
struct BurstInfo {
    burst_index: u8,
    x_bound: u8,
}

#[inline]
fn effective_x_idx(dec_out: &DecodeOutput, decoded: &Chip8DecodedStep) -> u8 {
    if dec_out.writes_lookup_to_x || dec_out.writes_mem_to_x || dec_out.is_branch || dec_out.is_memop {
        decoded.x
    } else {
        0
    }
}

#[inline]
fn fbool(v: bool) -> F {
    if v {
        F::ONE
    } else {
        F::ZERO
    }
}

fn compute_lookup_output(dec_out: &DecodeOutput, reg_x: u8, reg_y: u8, kk: u8) -> u16 {
    let lhs = resolve_operand(dec_out.lhs_selector, reg_x, reg_y, kk);
    let rhs = resolve_operand(dec_out.rhs_selector, reg_x, reg_y, kk);
    match dec_out.lookup_kind {
        LookupKind::Identity => lhs as u16,
        LookupKind::Add8Lo => (lhs as u16 + rhs as u16) % 256,
        LookupKind::Equal8 => {
            if lhs == rhs {
                1
            } else {
                0
            }
        }
        LookupKind::NoLookup => 0,
    }
}

fn resolve_operand(sel: OperandSelector, reg_x: u8, reg_y: u8, kk: u8) -> u8 {
    match sel {
        OperandSelector::RegX => reg_x,
        OperandSelector::RegY => reg_y,
        OperandSelector::Kk => kk,
        OperandSelector::Zero => 0,
    }
}

#[inline]
fn field_delta_u8(next: u8, prev: u8) -> F {
    F::from_u64(next as u64) - F::from_u64(prev as u64)
}

#[inline]
fn field_delta_u16(next: u16, prev: u16) -> F {
    F::from_u64(next as u64) - F::from_u64(prev as u64)
}

fn pack_row_major(z: &[F]) -> Mat<F> {
    let cols = z.len().div_ceil(D);
    let mut out = Mat::zero(D, cols, F::ZERO);
    for (idx, value) in z.iter().copied().enumerate() {
        out[(idx % D, idx / D)] = value;
    }
    out
}
