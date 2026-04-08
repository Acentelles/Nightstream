#![allow(dead_code)]

use neo_fold_next::chip8::kernel::{
    prove_simple_kernel, verify_simple_kernel, KernelStepAux, SimpleKernelError, SimpleKernelOutput, SimpleKernelProof,
    SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelVerifierInput, SimpleKernelWitness,
};
use neo_fold_next::chip8::spec::{
    Chip8Program, COL_BURST_LAST, COL_IS_JUMP, COL_IS_MEMOP, COL_LOOKUP_OUTPUT, COL_NNN_ADDR, COL_NNN_WORD, COL_PC,
    COL_PC_NEXT, COL_PRESERVES_X, COL_X_IDX, WITNESS_WIDTH,
};
use neo_fold_next::chip8::tables::{RAM_SINK_ADDR, REG_SINK_ADDR};
use neo_math::F;
use p3_field::PrimeCharacteristicRing;

fn make_row(pc: u64, pc_next: u64, x_idx: u64, is_memop: bool, burst_last: bool) -> [F; WITNESS_WIDTH] {
    let mut row = [F::ZERO; WITNESS_WIDTH];
    row[COL_PC] = F::from_u64(pc);
    row[COL_PC_NEXT] = F::from_u64(pc_next);
    row[COL_X_IDX] = F::from_u64(x_idx);
    row[COL_IS_MEMOP] = if is_memop { F::ONE } else { F::ZERO };
    row[COL_BURST_LAST] = if burst_last { F::ONE } else { F::ZERO };
    row
}

fn make_jump_row(pc_next: u64) -> [F; WITNESS_WIDTH] {
    let mut row = make_row(0x100, pc_next, 0, false, false);
    row[COL_NNN_ADDR] = F::from_u64(0x200);
    row[COL_NNN_WORD] = F::from_u64(0x100);
    row[COL_PRESERVES_X] = F::ONE;
    row[COL_IS_JUMP] = F::ONE;
    row[COL_LOOKUP_OUTPUT] = F::ZERO;
    row
}

fn make_jump_aux() -> KernelStepAux {
    KernelStepAux {
        fetch_addr: 0x100,
        decode_addr: 0x1200,
        alu_key: 0,
        eq4_key: 0,
        reg_ra_x_addr: 0,
        reg_ra_y_addr: REG_SINK_ADDR,
        reg_ra_i_addr: 16,
        reg_wa_addr: REG_SINK_ADDR,
        ram_ra_addr: RAM_SINK_ADDR,
        ram_wa_addr: RAM_SINK_ADDR,
        reg_inc: F::ZERO,
        ram_inc: F::ZERO,
        uses_y: false,
        reads_ram: false,
        writes_ram: false,
    }
}

pub fn build_jump_kernel_input(semantic_rows: usize) -> SimpleKernelProverInput {
    let program = Chip8Program::from_opcodes(&[0x1200]);
    let word_count = program.bytes.len() / 2;
    let pad_pc_word = 0x100 + word_count as u64;
    let padded_rows = semantic_rows.next_power_of_two();
    let mut semantic_trace_rows = Vec::with_capacity(semantic_rows);
    for row_idx in 0..semantic_rows {
        let pc_next = if row_idx + 1 == semantic_rows {
            if semantic_rows == padded_rows {
                0x100
            } else {
                pad_pc_word
            }
        } else {
            0x100
        };
        semantic_trace_rows.push(make_jump_row(pc_next));
    }
    SimpleKernelProverInput {
        public: SimpleKernelPublicInput {
            program_image: program.bytes.clone(),
            initial_pc_word: 0x100,
            initial_registers: [0; 16],
            initial_i: 0,
            initial_ram: vec![0; 4096],
            transcript_seed: Vec::new(),
        },
        witness: SimpleKernelWitness {
            semantic_trace_rows,
            semantic_aux_data: vec![make_jump_aux(); semantic_rows],
        },
    }
}

pub fn verifier_input_from_public(public: &SimpleKernelPublicInput) -> SimpleKernelVerifierInput {
    SimpleKernelVerifierInput {
        public: SimpleKernelPublicInput {
            program_image: public.program_image.clone(),
            initial_pc_word: public.initial_pc_word,
            initial_registers: public.initial_registers,
            initial_i: public.initial_i,
            initial_ram: public.initial_ram.clone(),
            transcript_seed: public.transcript_seed.clone(),
        },
    }
}

pub fn run_native_kernel(
    input: &SimpleKernelProverInput,
) -> Result<(SimpleKernelOutput, SimpleKernelProof), SimpleKernelError> {
    prove_simple_kernel(input)
}

pub fn rerun_native_kernel(
    input: &SimpleKernelVerifierInput,
    proof: &SimpleKernelProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    verify_simple_kernel(input, proof)
}
