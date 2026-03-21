use neo_fold_next::chip8::spec::WITNESS_WIDTH;
use neo_math::F;
use neo_memory::ajtai::decode_vector_for_ccs_m;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use super::kernel_progress::{build_jump_kernel_input, chip8_root_params, make_ajtai_module, prove_simple_kernel};

#[test]
fn simple_kernel_root_encode_matches_canonical_semantic_row() {
    let input = build_jump_kernel_input(2);
    let params = chip8_root_params();
    let log = make_ajtai_module(&params);

    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/tests/simple_kernel_root_encode");
    let (output, _proof) = prove_simple_kernel(&input, &params, &log, &mut transcript).expect("simple kernel proof");

    let mut expected_row = input.witness.semantic_trace_rows[0];
    expected_row[0] = F::ONE;
    let prepared = &output.prepared_steps[0];

    assert_eq!(prepared.witness.w, expected_row[1..].to_vec());
    assert_eq!(prepared.witness.w.len(), WITNESS_WIDTH - 1);

    let decoded = decode_vector_for_ccs_m(&params, WITNESS_WIDTH, &prepared.witness.Z).expect("decode root witness");
    assert_eq!(decoded, expected_row.to_vec());
}
