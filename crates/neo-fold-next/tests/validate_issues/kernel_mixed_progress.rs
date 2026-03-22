use neo_fold_next::chip8::kernel::{SimpleKernelProverInput, SimpleKernelPublicInput, SimpleKernelWitness};
use neo_fold_next::chip8::spec::{Chip8Program, Chip8State};
use neo_fold_next::chip8::trace::Chip8TraceBuilder;
use neo_transcript::{Poseidon2Transcript, Transcript};

use super::kernel_progress::{
    chip8_root_params, make_ajtai_module, prove_simple_kernel, verifier_input_from_public, verify_simple_kernel,
};

fn build_kernel_input(
    program: &Chip8Program,
    initial_state: &Chip8State,
    semantic_steps: usize,
    transcript_seed: &[u8],
) -> SimpleKernelProverInput {
    let execution =
        Chip8TraceBuilder::<()>::execute_program(program, initial_state, semantic_steps).expect("execution");

    let mut semantic_trace_rows = Vec::new();
    let mut semantic_aux_data = Vec::new();
    for step in execution {
        for row_trace in step.row_traces {
            semantic_trace_rows.push(row_trace.row);
            semantic_aux_data.push(row_trace.kernel_aux);
        }
    }

    SimpleKernelProverInput {
        public: SimpleKernelPublicInput {
            program_image: program.bytes.clone(),
            initial_pc_word: initial_state.pc / 2,
            initial_registers: initial_state.v,
            initial_i: initial_state.i,
            initial_ram: initial_state.memory.to_vec(),
            transcript_seed: transcript_seed.to_vec(),
        },
        witness: SimpleKernelWitness {
            semantic_trace_rows,
            semantic_aux_data,
        },
    }
}

#[test]
fn simple_kernel_accepts_mixed_ldimm_addimm_trace() {
    let program = Chip8Program::from_opcodes(&[
        0x6001, // LD V0, 0x01
        0x7002, // ADD V0, 0x02
    ]);
    let initial_state = Chip8State::with_program(&program).expect("initial state");
    let input = build_kernel_input(&program, &initial_state, 2, b"neo.fold.next/tests/mixed_ldimm_addimm");
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut prove_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/mixed_ldimm_addimm");
    let (proved_output, proof) =
        prove_simple_kernel(&input, &params, &log, &mut prove_transcript).expect("simple kernel proof");

    let verifier_input = verifier_input_from_public(&input.public);
    let mut verify_transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/mixed_ldimm_addimm");
    let verified_output =
        verify_simple_kernel(&verifier_input, &proof, &params, &log, &mut verify_transcript).expect("verify");

    assert_eq!(proof.meta_pub.semantic_rows, 2);
    assert_eq!(proved_output.prepared_steps.len(), 2);
    assert_eq!(verified_output.prepared_steps.len(), 2);
}
