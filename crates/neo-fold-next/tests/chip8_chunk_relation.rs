#[path = "support/chip8.rs"]
mod chip8_support;

use neo_ajtai::AjtaiSModule;
use neo_ajtai::Commitment;
use neo_ccs::CeClaim;
use neo_fold_next::chip8::kernel::{chip8_simple_root_params, prove_simple_kernel, CHIP8_BRIDGE_FOLD_SCHEDULE};
use neo_fold_next::chip8::spec::WITNESS_WIDTH;
use neo_fold_next::chip8::{
    Chip8VmSpec, CHIP8_CCS_ELL_D, CHIP8_CCS_ELL_M, CHIP8_CCS_ELL_N, CHIP8_CCS_FE_ROUNDS, CHIP8_CCS_NC_ROUNDS,
    CHIP8_CCS_OUTPUT_SLOTS, CHIP8_CCS_ROUND_COEFFS, CHIP8_CCS_SUMCHECK_DEGREE_BOUND,
};
use neo_fold_next::proof::{partition_step_inputs, ChunkInput};
use neo_fold_next::vm::VmSpec;
use neo_fold_next::witness_layout::commit_cols_for_full_width;
use neo_math::D;
use neo_reductions::engines::utils::{build_dims_and_policy, shared_me_input_r};
use neo_reductions::optimized_engine::{
    optimized_prove_with_cache_and_perf, optimized_replay_outputs_with_cache_and_perf,
    optimized_replay_terminal_state_with_cache_and_perf, optimized_replay_witness_with_cache_and_perf,
    rhs_terminal_identity_fe_with_k_mcs, rhs_terminal_identity_nc, OptimizedStructureCache,
};
use neo_reductions::paper_exact_engine::q_eval_at_ext_point_fe_paper_exact_with_inputs;
use neo_transcript::{Poseidon2Transcript, Transcript};

fn append_chunk_transcript(tr: &mut Poseidon2Transcript, chunk: &ChunkInput) {
    if chunk.steps.len() == 1 {
        tr.append_u64s(b"neo.fold.next/step_index", &[chunk.start_index as u64]);
        return;
    }

    tr.append_u64s(
        b"neo.fold.next/chunk_meta",
        &[chunk.start_index as u64, chunk.steps.len() as u64],
    );
}

#[test]
fn chip8_first_chunk_replay_terminal_fe_identity_matches_witness_q() {
    let input = chip8_support::build_jump_kernel_input(4);
    let (output, _proof) = prove_simple_kernel(&input).expect("prove simple kernel");

    let vm = Chip8VmSpec::default();
    let structure = &vm.core_ccs_spec().structure;
    let params = chip8_simple_root_params();
    let cache = OptimizedStructureCache::build(structure).expect("optimized structure cache");
    let log = AjtaiSModule::from_global_for_dims(D, commit_cols_for_full_width(WITNESS_WIDTH))
        .expect("Ajtai log from CHIP-8 root context");

    let chunks = partition_step_inputs(CHIP8_BRIDGE_FOLD_SCHEDULE, output.prepared_steps.clone())
        .expect("partition step inputs");
    let chunk = chunks.first().expect("first chunk");
    let fresh_claims = chunk
        .steps
        .iter()
        .map(|step| step.mcs.clone())
        .collect::<Vec<_>>();
    let fresh_witnesses = chunk
        .steps
        .iter()
        .map(|step| step.witness.clone())
        .collect::<Vec<_>>();
    let me_inputs = Vec::<CeClaim<Commitment, neo_math::F, neo_math::K>>::new();
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/session");
    append_chunk_transcript(&mut tr, chunk);
    let state = optimized_replay_terminal_state_with_cache_and_perf(
        &mut tr,
        &params,
        structure,
        &fresh_claims,
        &fresh_witnesses,
        &me_inputs,
        &[],
        &log,
        &cache,
    )
    .expect("optimized replay terminal state");
    let mut tr_outputs = Poseidon2Transcript::new(b"neo.fold.next/session");
    append_chunk_transcript(&mut tr_outputs, chunk);
    let outputs = optimized_replay_outputs_with_cache_and_perf(
        &mut tr_outputs,
        &params,
        structure,
        &fresh_claims,
        &fresh_witnesses,
        &me_inputs,
        &[],
        &log,
        &cache,
    )
    .expect("optimized replay outputs");

    let r_inputs = shared_me_input_r(&me_inputs, state.row_chals.len()).expect("shared ME input r");
    let (lhs_fe, _) = q_eval_at_ext_point_fe_paper_exact_with_inputs(
        structure,
        &params,
        &fresh_witnesses,
        &[],
        &state.alpha_prime,
        &state.row_chals,
        &state.challenges_public,
        r_inputs,
    );
    let rhs_fe = rhs_terminal_identity_fe_with_k_mcs(
        structure,
        &params,
        &state.challenges_public,
        &state.row_chals,
        &state.alpha_prime,
        &state.me_outputs,
        fresh_claims.len(),
        r_inputs,
    );

    assert_eq!(lhs_fe, rhs_fe);
    assert_eq!(state.sumcheck_final, rhs_fe);
    let rhs_nc = rhs_terminal_identity_nc(
        &params,
        &state.challenges_public,
        &state.s_col,
        &state.alpha_prime_nc,
        &state.me_outputs,
    );
    assert_eq!(state.sumcheck_final_nc, rhs_nc);
    assert_eq!(outputs.me_outputs, state.me_outputs);
    assert_eq!(outputs.fold_digest, state.fold_digest);

    let mut tr_prove = Poseidon2Transcript::new(b"neo.fold.next/session");
    append_chunk_transcript(&mut tr_prove, chunk);
    let (prove_outputs, proof, _perf) = optimized_prove_with_cache_and_perf(
        &mut tr_prove,
        &params,
        structure,
        &fresh_claims,
        &fresh_witnesses,
        &me_inputs,
        &[],
        &log,
        &cache,
    )
    .expect("optimized prove with perf");
    let proof_digest: [u8; 32] = proof
        .header_digest
        .as_slice()
        .try_into()
        .expect("32-byte header digest");
    let mut replay_fe_chals = state.row_chals.clone();
    replay_fe_chals.extend(state.alpha_prime.clone());
    let mut replay_nc_chals = state.s_col.clone();
    replay_nc_chals.extend(state.alpha_prime_nc.clone());

    assert_eq!(prove_outputs, state.me_outputs);
    assert_eq!(proof_digest, state.fold_digest);
    assert_eq!(proof.challenges_public.alpha, state.challenges_public.alpha);
    assert_eq!(proof.challenges_public.beta_a, state.challenges_public.beta_a);
    assert_eq!(proof.challenges_public.beta_r, state.challenges_public.beta_r);
    assert_eq!(proof.challenges_public.beta_m, state.challenges_public.beta_m);
    assert_eq!(proof.challenges_public.gamma, state.challenges_public.gamma);
    assert_eq!(proof.sumcheck_challenges, replay_fe_chals);
    assert_eq!(proof.sumcheck_challenges_nc, replay_nc_chals);
    assert_eq!(proof.sumcheck_final, state.sumcheck_final);
    assert_eq!(proof.sumcheck_final_nc, state.sumcheck_final_nc);

    let mut tr_replay_witness = Poseidon2Transcript::new(b"neo.fold.next/session");
    append_chunk_transcript(&mut tr_replay_witness, chunk);
    let replay_witness_outputs = optimized_replay_witness_with_cache_and_perf(
        &mut tr_replay_witness,
        &params,
        structure,
        &fresh_claims,
        &fresh_witnesses,
        &me_inputs,
        &[],
        &log,
        &cache,
    )
    .expect("optimized replay witness");

    assert_eq!(replay_witness_outputs.me_outputs, prove_outputs);
    assert_eq!(replay_witness_outputs.replay_proof.header_digest, proof_digest);
    assert_eq!(
        replay_witness_outputs.replay_proof.sumcheck_rounds,
        proof.sumcheck_rounds
    );
    assert_eq!(
        replay_witness_outputs.replay_proof.sumcheck_rounds_nc,
        proof.sumcheck_rounds_nc
    );
}

#[test]
fn chip8_replay_shape_constants_match_live_ccs_dims() {
    let vm = Chip8VmSpec::default();
    let structure = &vm.core_ccs_spec().structure;
    let params = chip8_simple_root_params();
    let dims = build_dims_and_policy(&params, structure).expect("CHIP-8 dims");

    assert_eq!(dims.ell_d, CHIP8_CCS_ELL_D);
    assert_eq!(dims.ell_n, CHIP8_CCS_ELL_N);
    assert_eq!(dims.ell_m, CHIP8_CCS_ELL_M);
    assert_eq!(dims.d_sc, CHIP8_CCS_SUMCHECK_DEGREE_BOUND);
    assert_eq!(CHIP8_CCS_FE_ROUNDS, dims.ell_d + dims.ell_n);
    assert_eq!(CHIP8_CCS_NC_ROUNDS, dims.ell_d + dims.ell_m);
    assert_eq!(CHIP8_CCS_ROUND_COEFFS, dims.d_sc + 1);
    assert_eq!(CHIP8_CCS_OUTPUT_SLOTS, 18);
}
