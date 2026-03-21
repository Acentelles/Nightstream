//! Owns exact row-local frame reconstruction from authenticated kernel rows.
//!
//! This module rebuilds the row-level machine-state chain that the Lean
//! execution digest and audit boundary quantify over. It does not own staged
//! theorem checks or export grouping; it only turns authenticated semantic rows
//! plus public initial state into exact per-row frames.

use neo_math::F;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::chip8::spec::{
    decode_opcode, Chip8DecodedStep, Chip8Program, Chip8State, CHIP8_MEMORY_BYTES, CHIP8_PROGRAM_START, COL_BURST_LAST,
    COL_IS_MEMOP, COL_I_NEXT, COL_I_REG, COL_MEM_VALUE, COL_PC, COL_PC_NEXT, COL_RAM_ADDR, COL_REG_X, COL_REG_X_NEXT,
    COL_REG_Y, COL_X_IDX, COL_Y_IDX, WITNESS_WIDTH,
};
use crate::chip8::tables::{build_rom_table, decode_to_output, flatten_alu_key, flatten_eq4_key, OperandSelector};

use super::{
    reconstruct_trace_rows_and_aux, KernelStepAux, SimpleKernelError, SimpleKernelProof, SimpleKernelPublicInput,
};

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct KernelFrameDecodeView {
    pub core: Chip8DecodedStep,
    pub opcode_word: u16,
    pub pc_word: u16,
    pub row_x_idx: u8,
    pub row_y_idx: u8,
    pub is_memop: bool,
    pub burst_last: bool,
    pub ram_addr: u16,
}

#[derive(Clone, Debug, PartialEq)]
pub struct KernelExactFrame {
    pub step_idx: usize,
    pub dec: KernelFrameDecodeView,
    pub pre: Chip8State,
    pub post: Chip8State,
    pub row: [F; WITNESS_WIDTH],
    pub kernel_aux: KernelStepAux,
}

impl KernelExactFrame {
    pub fn digest32(&self) -> [u8; 32] {
        let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/kernel_exact_frame");
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_exact_frame/meta",
            &[
                self.step_idx as u64,
                self.dec.opcode_word as u64,
                self.dec.pc_word as u64,
                self.dec.row_x_idx as u64,
                self.dec.row_y_idx as u64,
                self.dec.is_memop as u64,
                self.dec.burst_last as u64,
                self.dec.ram_addr as u64,
            ],
        );
        tr.append_u64s(
            b"neo.fold.next/chip8/kernel_exact_frame/core_decode",
            &[
                self.dec.core.opcode_id as u64,
                self.dec.core.x as u64,
                self.dec.core.y as u64,
                self.dec.core.kk as u64,
                self.dec.core.nnn as u64,
            ],
        );
        append_state(&mut tr, b"neo.fold.next/chip8/kernel_exact_frame/pre", &self.pre);
        append_state(&mut tr, b"neo.fold.next/chip8/kernel_exact_frame/post", &self.post);
        tr.append_fields_iter(
            b"neo.fold.next/chip8/kernel_exact_frame/row",
            self.row.len(),
            self.row.iter().copied(),
        );
        append_kernel_aux(&mut tr, &self.kernel_aux);
        tr.digest32()
    }
}

pub(crate) fn build_kernel_exact_frames(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
) -> Result<Vec<KernelExactFrame>, SimpleKernelError> {
    let program = Chip8Program {
        bytes: public.program_image.clone(),
        start_pc: CHIP8_PROGRAM_START,
    };
    let (semantic_rows, aux_data) = reconstruct_semantic_rows_and_aux(public, proof, &program)?;
    let mut current = initial_state_from_public(public)?;
    let mut frames = Vec::with_capacity(semantic_rows.len());

    for (step_idx, (row, kernel_aux)) in semantic_rows
        .into_iter()
        .zip(aux_data.into_iter())
        .enumerate()
    {
        let frame = build_exact_frame(step_idx, &program, &current, row, kernel_aux)?;
        current = frame.post.clone();
        frames.push(frame);
    }

    Ok(frames)
}

fn reconstruct_semantic_rows_and_aux(
    public: &SimpleKernelPublicInput,
    proof: &SimpleKernelProof,
    program: &Chip8Program,
) -> Result<(Vec<[F; WITNESS_WIDTH]>, Vec<KernelStepAux>), SimpleKernelError> {
    let pad_pc_word = proof.meta_pub.pad_pc_word;
    let rom_table = build_rom_table(program, pad_pc_word);
    let (trace_rows, aux_data) = reconstruct_trace_rows_and_aux(
        &proof.stage3.row_bindings,
        proof.meta_pub.semantic_rows,
        proof.meta_pub.padded_trace_length,
        proof.meta_pub.cycle_bits,
        pad_pc_word,
        &rom_table,
        &public.initial_ram,
    )?;
    Ok((
        trace_rows[..proof.meta_pub.semantic_rows].to_vec(),
        aux_data[..proof.meta_pub.semantic_rows].to_vec(),
    ))
}

fn initial_state_from_public(public: &SimpleKernelPublicInput) -> Result<Chip8State, SimpleKernelError> {
    if public.initial_ram.len() != CHIP8_MEMORY_BYTES {
        return Err(SimpleKernelError::InvalidWitness(format!(
            "initial RAM length {} != expected {}",
            public.initial_ram.len(),
            CHIP8_MEMORY_BYTES
        )));
    }
    let pc = public
        .initial_pc_word
        .checked_mul(2)
        .ok_or_else(|| SimpleKernelError::InvalidProgram("initial_pc_word overflows byte PC".into()))?;
    let mut memory = [0u8; CHIP8_MEMORY_BYTES];
    memory.copy_from_slice(&public.initial_ram);
    Ok(Chip8State {
        pc,
        i: public.initial_i,
        v: public.initial_registers,
        memory,
    })
}

fn build_exact_frame(
    step_idx: usize,
    program: &Chip8Program,
    pre: &Chip8State,
    row: [F; WITNESS_WIDTH],
    kernel_aux: KernelStepAux,
) -> Result<KernelExactFrame, SimpleKernelError> {
    let pc_word = decode_u16(row[COL_PC], &format!("exact frame {step_idx} PC"))?;
    let expected_pc_word = pre.pc / 2;
    if pc_word != expected_pc_word {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} row PC {pc_word} != current state PC word {expected_pc_word}"
        )));
    }

    let opcode_word = program
        .opcode_at(pre.pc)
        .ok_or_else(|| SimpleKernelError::InvalidProgram(format!("no opcode at byte pc 0x{:03x}", pre.pc)))?;
    let core = decode_opcode(opcode_word)
        .map_err(|err| SimpleKernelError::InvalidProgram(format!("opcode decode failed: {err}")))?;
    let decode = decode_to_output(opcode_word);
    let row_x_idx = decode_u8(row[COL_X_IDX], &format!("exact frame {step_idx} X_IDX"))?;
    let row_y_idx = decode_u8(row[COL_Y_IDX], &format!("exact frame {step_idx} Y_IDX"))?;
    let burst_last = decode_bool(row[COL_BURST_LAST], &format!("exact frame {step_idx} BURST_LAST"))?;
    let ram_addr = decode_u16(row[COL_RAM_ADDR], &format!("exact frame {step_idx} RAM_ADDR"))?;

    if row_x_idx as usize >= pre.v.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} X_IDX {row_x_idx} escapes V register bank"
        )));
    }
    if decode.uses_y && row_y_idx as usize >= pre.v.len() {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} Y_IDX {row_y_idx} escapes V register bank"
        )));
    }

    expect_row_pre_state(
        step_idx,
        pre,
        &row,
        opcode_word,
        &core,
        row_x_idx,
        row_y_idx,
        burst_last,
        ram_addr,
    )?;
    let post = apply_row_transition(step_idx, pre, &row, &core, row_x_idx, burst_last, ram_addr)?;
    let expected_aux = expected_kernel_aux(pre, &row, row_x_idx, row_y_idx, ram_addr, opcode_word)?;
    if kernel_aux != expected_aux {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} kernel aux mismatch"
        )));
    }

    Ok(KernelExactFrame {
        step_idx,
        dec: KernelFrameDecodeView {
            core,
            opcode_word,
            pc_word,
            row_x_idx,
            row_y_idx,
            is_memop: decode.is_memop,
            burst_last,
            ram_addr,
        },
        pre: pre.clone(),
        post,
        row,
        kernel_aux,
    })
}

fn expect_row_pre_state(
    step_idx: usize,
    pre: &Chip8State,
    row: &[F; WITNESS_WIDTH],
    opcode_word: u16,
    core: &Chip8DecodedStep,
    row_x_idx: u8,
    row_y_idx: u8,
    burst_last: bool,
    ram_addr: u16,
) -> Result<(), SimpleKernelError> {
    let decode = decode_to_output(opcode_word);
    let row_is_memop = decode_bool(row[COL_IS_MEMOP], &format!("exact frame {step_idx} IS_MEMOP"))?;
    if row_is_memop != decode.is_memop {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} IS_MEMOP {row_is_memop} != decoded {}",
            decode.is_memop
        )));
    }
    let reg_x = decode_u8(row[COL_REG_X], &format!("exact frame {step_idx} REG_X"))?;
    if reg_x != pre.v[row_x_idx as usize] {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} REG_X {reg_x} != pre-state V{row_x_idx} {}",
            pre.v[row_x_idx as usize]
        )));
    }
    if decode.uses_y {
        let reg_y = decode_u8(row[COL_REG_Y], &format!("exact frame {step_idx} REG_Y"))?;
        if reg_y != pre.v[row_y_idx as usize] {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} REG_Y {reg_y} != pre-state V{row_y_idx} {}",
                pre.v[row_y_idx as usize]
            )));
        }
    } else if row[COL_REG_Y] != F::ZERO {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} REG_Y must be zero for non-Y opcode"
        )));
    }

    let i_reg = decode_u16(row[COL_I_REG], &format!("exact frame {step_idx} I_REG"))?;
    if i_reg != pre.i {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "exact frame {step_idx} I_REG {i_reg} != pre-state I {}",
            pre.i
        )));
    }

    let mem_value = decode_u8(row[COL_MEM_VALUE], &format!("exact frame {step_idx} MEM_VALUE"))?;
    if decode.is_memop {
        let expected_ram_addr = pre.i + row_x_idx as u16;
        if ram_addr != expected_ram_addr {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} RAM_ADDR {ram_addr} != expected {expected_ram_addr}"
            )));
        }
        let expected_mem_value = match core.opcode_id {
            crate::chip8::spec::Chip8Opcode::StoreRegs => pre.v[row_x_idx as usize],
            crate::chip8::spec::Chip8Opcode::LoadRegs => pre.memory[ram_addr as usize],
            _ => {
                return Err(SimpleKernelError::BridgeFailed(format!(
                    "exact frame {step_idx} marked memop for non-memory opcode"
                )))
            }
        };
        if mem_value != expected_mem_value {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} MEM_VALUE {mem_value} != expected {expected_mem_value}"
            )));
        }
        let expected_burst_last = row_x_idx == decode.x_bound;
        if burst_last != expected_burst_last {
            return Err(SimpleKernelError::BridgeFailed(format!(
                "exact frame {step_idx} BURST_LAST {burst_last} != expected {expected_burst_last}"
            )));
        }
    }

    Ok(())
}

fn apply_row_transition(
    step_idx: usize,
    pre: &Chip8State,
    row: &[F; WITNESS_WIDTH],
    core: &Chip8DecodedStep,
    row_x_idx: u8,
    _burst_last: bool,
    ram_addr: u16,
) -> Result<Chip8State, SimpleKernelError> {
    let mut post = pre.clone();
    let pc_next_word = decode_u16(row[COL_PC_NEXT], &format!("exact frame {step_idx} PC_NEXT"))?;
    post.pc = pc_next_word
        .checked_mul(2)
        .ok_or_else(|| SimpleKernelError::BridgeFailed(format!("exact frame {step_idx} PC_NEXT overflows byte PC")))?;
    post.i = decode_u16(row[COL_I_NEXT], &format!("exact frame {step_idx} I_NEXT"))?;

    let reg_x_next = decode_u8(row[COL_REG_X_NEXT], &format!("exact frame {step_idx} REG_X_NEXT"))?;
    match core.opcode_id {
        crate::chip8::spec::Chip8Opcode::LdImm
        | crate::chip8::spec::Chip8Opcode::AddImm
        | crate::chip8::spec::Chip8Opcode::Mov
        | crate::chip8::spec::Chip8Opcode::AddReg => {
            post.v[row_x_idx as usize] = reg_x_next;
        }
        crate::chip8::spec::Chip8Opcode::LoadRegs => {
            post.v[row_x_idx as usize] = reg_x_next;
        }
        crate::chip8::spec::Chip8Opcode::StoreRegs => {
            let mem_value = decode_u8(row[COL_MEM_VALUE], &format!("exact frame {step_idx} MEM_VALUE"))?;
            post.memory[ram_addr as usize] = mem_value;
        }
        crate::chip8::spec::Chip8Opcode::SkipEqImm
        | crate::chip8::spec::Chip8Opcode::Jump
        | crate::chip8::spec::Chip8Opcode::LdI => {}
    }

    Ok(post)
}

fn expected_kernel_aux(
    pre: &Chip8State,
    row: &[F; WITNESS_WIDTH],
    row_x_idx: u8,
    row_y_idx: u8,
    ram_addr: u16,
    opcode_word: u16,
) -> Result<KernelStepAux, SimpleKernelError> {
    let decode = decode_to_output(opcode_word);
    let reg_x = decode_u8(row[COL_REG_X], "kernel exact frame REG_X")?;
    let reg_y = decode_u8(row[COL_REG_Y], "kernel exact frame REG_Y")?;
    let mem_value = decode_u8(row[COL_MEM_VALUE], "kernel exact frame MEM_VALUE")?;
    let reg_ra_y_addr = if decode.is_memop {
        crate::chip8::tables::REG_SINK_ADDR
    } else if decode.uses_y {
        row_y_idx as usize
    } else {
        crate::chip8::tables::REG_SINK_ADDR
    };
    let reg_wa_addr = if decode.is_memop {
        if decode.is_load {
            row_x_idx as usize
        } else {
            crate::chip8::tables::REG_SINK_ADDR
        }
    } else if decode.writes_lookup_to_x || decode.writes_mem_to_x {
        row_x_idx as usize
    } else if decode.writes_nnn_to_i {
        16
    } else {
        crate::chip8::tables::REG_SINK_ADDR
    };
    let (ram_ra_addr, ram_wa_addr) = if decode.is_memop {
        if decode.reads_ram {
            (ram_addr as usize, crate::chip8::tables::RAM_SINK_ADDR)
        } else {
            (crate::chip8::tables::RAM_SINK_ADDR, ram_addr as usize)
        }
    } else {
        (crate::chip8::tables::RAM_SINK_ADDR, crate::chip8::tables::RAM_SINK_ADDR)
    };
    let reg_inc = if decode.is_memop {
        if decode.is_load {
            row[COL_REG_X_NEXT] - row[COL_REG_X]
        } else {
            F::ZERO
        }
    } else if decode.writes_lookup_to_x || decode.writes_mem_to_x {
        row[COL_REG_X_NEXT] - row[COL_REG_X]
    } else if decode.writes_nnn_to_i {
        row[COL_I_NEXT] - row[COL_I_REG]
    } else {
        F::ZERO
    };
    let ram_inc = if decode.is_memop && decode.is_store {
        F::from_u64(mem_value as u64) - F::from_u64(pre.memory[ram_addr as usize] as u64)
    } else {
        F::ZERO
    };

    Ok(KernelStepAux {
        fetch_addr: (pre.pc / 2) as usize,
        decode_addr: opcode_word,
        alu_key: flatten_alu_key(
            decode.lookup_kind,
            operand_from_row_selector(decode.lhs_selector, reg_x, reg_y, decode.kk_dec),
            operand_from_row_selector(decode.rhs_selector, reg_x, reg_y, decode.kk_dec),
        ),
        eq4_key: flatten_eq4_key(row_x_idx, decode.x_bound),
        reg_ra_x_addr: row_x_idx as usize,
        reg_ra_y_addr,
        reg_ra_i_addr: 16,
        reg_wa_addr,
        ram_ra_addr,
        ram_wa_addr,
        reg_inc,
        ram_inc,
        uses_y: decode.uses_y,
        reads_ram: decode.reads_ram,
        writes_ram: decode.writes_ram,
    })
}

fn operand_from_row_selector(selector: OperandSelector, reg_x: u8, reg_y: u8, kk: u8) -> u8 {
    match selector {
        OperandSelector::RegX => reg_x,
        OperandSelector::RegY => reg_y,
        OperandSelector::Kk => kk,
        OperandSelector::Zero => 0,
    }
}

fn append_state(tr: &mut Poseidon2Transcript, label: &'static [u8], state: &Chip8State) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_exact_frame/state_meta",
        &[
            state.pc as u64,
            state.i as u64,
            state.v.len() as u64,
            state.memory.len() as u64,
        ],
    );
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_exact_frame/state_registers",
        &state
            .v
            .iter()
            .map(|&value| value as u64)
            .collect::<Vec<_>>(),
    );
    tr.append_u64s(
        label,
        &state
            .memory
            .iter()
            .map(|&value| value as u64)
            .collect::<Vec<_>>(),
    );
}

fn append_kernel_aux(tr: &mut Poseidon2Transcript, aux: &KernelStepAux) {
    tr.append_u64s(
        b"neo.fold.next/chip8/kernel_exact_frame/kernel_aux_meta",
        &[
            aux.fetch_addr as u64,
            aux.decode_addr as u64,
            aux.alu_key as u64,
            aux.eq4_key as u64,
            aux.reg_ra_x_addr as u64,
            aux.reg_ra_y_addr as u64,
            aux.reg_ra_i_addr as u64,
            aux.reg_wa_addr as u64,
            aux.ram_ra_addr as u64,
            aux.ram_wa_addr as u64,
            aux.uses_y as u64,
            aux.reads_ram as u64,
            aux.writes_ram as u64,
        ],
    );
    tr.append_fields(
        b"neo.fold.next/chip8/kernel_exact_frame/kernel_aux_reg_inc",
        &[aux.reg_inc],
    );
    tr.append_fields(
        b"neo.fold.next/chip8/kernel_exact_frame/kernel_aux_ram_inc",
        &[aux.ram_inc],
    );
}

fn decode_u8(value: F, label: &str) -> Result<u8, SimpleKernelError> {
    let word = value.as_canonical_u64();
    u8::try_from(word).map_err(|_| SimpleKernelError::BridgeFailed(format!("{label} {word} does not fit in u8")))
}

fn decode_u16(value: F, label: &str) -> Result<u16, SimpleKernelError> {
    let word = value.as_canonical_u64();
    u16::try_from(word).map_err(|_| SimpleKernelError::BridgeFailed(format!("{label} {word} does not fit in u16")))
}

fn decode_bool(value: F, label: &str) -> Result<bool, SimpleKernelError> {
    let word = value.as_canonical_u64();
    match word {
        0 => Ok(false),
        1 => Ok(true),
        _ => Err(SimpleKernelError::BridgeFailed(format!(
            "{label} {word} is not boolean"
        ))),
    }
}
