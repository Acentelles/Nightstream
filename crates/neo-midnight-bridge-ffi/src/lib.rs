use blake2b_simd::State as TranscriptHash;
use midnight_curves::Bls12;
use midnight_proofs::dev::cost_model::circuit_model;
use midnight_proofs::poly::kzg::params::ParamsKZG;
use neo_math::KExtensions;
use neo_midnight_bridge::k_field::{host_sumcheck_round_claim, KRepr};
use neo_midnight_bridge::relations::{PiCcsSumcheckInstance, PiCcsSumcheckRelation, PiCcsSumcheckWitness};
use rand::SeedableRng;
use rand_chacha::ChaCha20Rng;

fn write_null(out_ptr: *mut *mut u8, out_len: *mut usize) {
    if !out_ptr.is_null() {
        // SAFETY: caller promised `out_ptr` is valid when non-null.
        unsafe { *out_ptr = core::ptr::null_mut() };
    }
    if !out_len.is_null() {
        // SAFETY: caller promised `out_len` is valid when non-null.
        unsafe { *out_len = 0 };
    }
}

fn write_allocated_bytes(out_ptr: *mut *mut u8, out_len: *mut usize, bytes: Vec<u8>) -> i32 {
    if out_ptr.is_null() || out_len.is_null() {
        return 1;
    }

    let boxed = bytes.into_boxed_slice();
    let len = boxed.len();
    let ptr = Box::into_raw(boxed) as *mut u8;

    // SAFETY: caller provided valid pointers for outputs.
    unsafe {
        *out_ptr = ptr;
        *out_len = len;
    }
    0
}

fn k_to_repr(k: &neo_math::K) -> KRepr {
    let (c0, c1) = k.to_limbs_u64();
    KRepr { c0, c1 }
}

/// Proves the Pi-CCS sumcheck relation for the Poseidon2 batch_40 test-export JSON (UTF-8 bytes).
///
/// This mirrors `crates/neo-midnight-bridge/tests/pi_ccs_sumcheck_poseidon2_batch_40.rs` but
/// returns the raw proof bytes.
///
/// On success returns 0 and sets `(*out_ptr, *out_len)` to an allocated proof buffer.
/// On failure returns non-zero and sets `(*err_ptr, *err_len)` to an allocated UTF-8 error.
/// Buffers must be freed with `neo_midnight_bridge_free_bytes`.
#[no_mangle]
pub extern "C" fn neo_midnight_bridge_prove_pi_ccs_sumcheck_poseidon2_batch_40_json(
    json_ptr: *const u8,
    json_len: usize,
    out_ptr: *mut *mut u8,
    out_len: *mut usize,
    err_ptr: *mut *mut u8,
    err_len: *mut usize,
) -> i32 {
    if out_ptr.is_null() || out_len.is_null() || err_ptr.is_null() || err_len.is_null() {
        return 1;
    }

    write_null(out_ptr, out_len);
    write_null(err_ptr, err_len);

    if json_ptr.is_null() {
        let _ = write_allocated_bytes(
            err_ptr,
            err_len,
            b"null json_ptr passed to neo_midnight_bridge_prove_pi_ccs_sumcheck_poseidon2_batch_40_json".to_vec(),
        );
        return 2;
    }

    let json_bytes = unsafe { core::slice::from_raw_parts(json_ptr, json_len) };
    let json = match core::str::from_utf8(json_bytes) {
        Ok(s) => s,
        Err(e) => {
            let _ = write_allocated_bytes(err_ptr, err_len, format!("input is not valid UTF-8: {e}").into_bytes());
            return 3;
        }
    };

    let export = match neo_fold::test_export::parse_test_export_json(json) {
        Ok(e) => e,
        Err(e) => {
            let _ = write_allocated_bytes(err_ptr, err_len, format!("parse error: {e}").into_bytes());
            return 4;
        }
    };

    let target_folding_steps: usize = 2;
    let mut session = match neo_fold::test_export::TestExportSession::new_from_circuit_json(json) {
        Ok(s) => s,
        Err(e) => {
            let _ = write_allocated_bytes(err_ptr, err_len, format!("session init error: {e}").into_bytes());
            return 5;
        }
    };
    for i in 0..target_folding_steps {
        let z = &export.witness[i % export.witness.len()];
        if let Err(e) = session.add_step_witness_u64(z) {
            let _ = write_allocated_bytes(err_ptr, err_len, format!("add_step_witness_u64 error: {e}").into_bytes());
            return 6;
        }
    }

    let (fold_run, _step_ms) = match session.fold_and_prove_with_step_timings() {
        Ok(v) => v,
        Err(e) => {
            let _ = write_allocated_bytes(err_ptr, err_len, format!("fold_and_prove error: {e}").into_bytes());
            return 7;
        }
    };
    if !session.verify(&fold_run).unwrap_or(false) {
        let _ = write_allocated_bytes(err_ptr, err_len, b"neo-fold verify failed".to_vec());
        return 8;
    }

    let pi = &fold_run.steps[0].fold.ccs_proof;
    let n_rounds = pi.sumcheck_rounds.len();
    if n_rounds == 0 {
        let _ = write_allocated_bytes(err_ptr, err_len, b"expected at least one sumcheck round".to_vec());
        return 9;
    }
    let poly_len = pi.sumcheck_rounds[0].len();
    if poly_len == 0 {
        let _ = write_allocated_bytes(err_ptr, err_len, b"expected non-empty round polynomial".to_vec());
        return 10;
    }
    if !pi.sumcheck_rounds.iter().all(|r| r.len() == poly_len) {
        let _ = write_allocated_bytes(err_ptr, err_len, b"expected uniform polynomial length".to_vec());
        return 11;
    }
    if pi.sumcheck_challenges.len() != n_rounds {
        let _ = write_allocated_bytes(err_ptr, err_len, b"expected one challenge per round".to_vec());
        return 12;
    }

    let rounds_repr: Vec<Vec<KRepr>> = pi
        .sumcheck_rounds
        .iter()
        .map(|round| round.iter().map(k_to_repr).collect())
        .collect();
    let initial_sum = pi
        .sc_initial_sum
        .as_ref()
        .map(k_to_repr)
        .unwrap_or_else(|| host_sumcheck_round_claim(&rounds_repr[0]));
    let final_sum = k_to_repr(&pi.sumcheck_final);
    let challenges: Vec<KRepr> = pi.sumcheck_challenges.iter().map(k_to_repr).collect();

    let instance = PiCcsSumcheckInstance {
        bundle_digest: [0u128; 2],
        initial_sum,
        final_sum,
        challenges,
    };
    let witness = PiCcsSumcheckWitness { rounds: rounds_repr };
    let rel = PiCcsSumcheckRelation { n_rounds, poly_len };

    // Use deterministic test-only KZG params (same as the Rust test).
    let circuit = midnight_zk_stdlib::MidnightCircuit::from_relation(&rel);
    let model = circuit_model::<_, 48, 32>(&circuit);
    let k: u32 = model.k;
    let params: ParamsKZG<Bls12> = ParamsKZG::unsafe_setup(k, ChaCha20Rng::from_seed([21u8; 32]));

    let vk = midnight_zk_stdlib::setup_vk(&params, &rel);
    let pk = midnight_zk_stdlib::setup_pk(&rel, &vk);
    let proof = match midnight_zk_stdlib::prove::<_, TranscriptHash>(
        &params,
        &pk,
        &rel,
        &instance,
        witness,
        ChaCha20Rng::from_seed([22u8; 32]),
    ) {
        Ok(p) => p,
        Err(e) => {
            let _ = write_allocated_bytes(err_ptr, err_len, format!("prove error: {e}").into_bytes());
            return 13;
        }
    };

    // Optional safety check: verify.
    let params_v = params.verifier_params();
    if let Err(e) =
        midnight_zk_stdlib::verify::<PiCcsSumcheckRelation, TranscriptHash>(&params_v, &vk, &instance, None, &proof)
    {
        let _ = write_allocated_bytes(err_ptr, err_len, format!("verify error: {e}").into_bytes());
        return 14;
    }

    write_allocated_bytes(out_ptr, out_len, proof)
}

/// Free a buffer previously allocated by this crate.
#[no_mangle]
pub extern "C" fn neo_midnight_bridge_free_bytes(ptr: *mut u8, len: usize) {
    if ptr.is_null() {
        return;
    }

    // SAFETY:
    // - The buffer was allocated by Rust (via `Box<[u8]>`) and leaked with `Box::into_raw`.
    // - `len` must be exactly the original length.
    unsafe {
        let slice = core::ptr::slice_from_raw_parts_mut(ptr, len);
        drop(Box::from_raw(slice));
    }
}
