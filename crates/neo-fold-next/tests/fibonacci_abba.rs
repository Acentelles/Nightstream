//! Fibonacci folding test using ABBA commitments instead of Ajtai.
//! Run with: cargo test -p neo-fold-next --release --features abba --test fibonacci_abba
#![cfg(feature = "abba")]

use std::sync::Arc;

use neo_abba::{s_mul_add, scale_commitment_add_inplace, setup as abba_setup, AbbaSModule, Commitment};
use neo_ccs::{poly::SparsePoly, poly::Term, CcsClaim, CcsStructure, CcsWitness, Mat};
use neo_fold_next::proof::{FoldSchedule, StepInput};
use neo_fold_next::prover::CommitmentMixers;
use neo_fold_next::run::{prove_run, verify_run};
use neo_math::ring::Rq as RqEl;
use neo_math::{D, F};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use p3_field::PrimeCharacteristicRing;
use rand_chacha::rand_core::SeedableRng;
use rand_chacha::ChaCha8Rng;

fn fibonacci_trace_ccs(trace_len: usize) -> CcsStructure<F> {
    assert!(trace_len >= 3);
    assert!(trace_len <= D);

    let transitions = trace_len - 2;
    let mut m = Mat::zero(transitions, D, F::ZERO);
    for row in 0..transitions {
        m[(row, row)] = F::ONE;
        m[(row, row + 1)] = F::ONE;
        m[(row, row + 2)] = -F::ONE;
    }

    let f = SparsePoly::new(
        1,
        vec![Term {
            coeff: F::ONE,
            exps: vec![1],
        }],
    );
    CcsStructure::new(vec![m], f).expect("valid Fibonacci CCS")
}

fn rot_matrix_to_rq(mat: &Mat<F>) -> RqEl {
    use neo_math::ring::cf_inv;
    let mut coeffs = [F::ZERO; D];
    for i in 0..D {
        coeffs[i] = mat[(i, 0)];
    }
    cf_inv(coeffs)
}

fn abba_mixers() -> CommitmentMixers<fn(&[Mat<F>], &[Commitment]) -> Commitment, fn(&[Commitment], u32) -> Commitment> {
    fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Commitment]) -> Commitment {
        let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
        for (rho, c) in rhos.iter().zip(cs.iter()) {
            let rq = rot_matrix_to_rq(rho);
            s_mul_add(&mut acc, &rq, c);
        }
        acc
    }

    fn combine_b_pows(cs: &[Commitment], b: u32) -> Commitment {
        let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
        let base = F::from_u64(b as u64);
        let mut pow = F::ONE;
        for c in cs {
            scale_commitment_add_inplace(&mut acc, pow, c);
            pow *= base;
        }
        acc
    }

    CommitmentMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

fn make_abba_module(params: &NeoParams, witness_cols: usize) -> AbbaSModule {
    let mut rng = ChaCha8Rng::seed_from_u64(1337);
    let pp = abba_setup(&mut rng, D, params.kappa as usize, witness_cols).expect("ABBA setup");
    AbbaSModule::new(Arc::new(pp))
}

fn fibonacci_step(log: &AbbaSModule, label: &str, values: &[u64]) -> StepInput {
    assert!(values.len() <= D);

    let m_in = values.len();
    let mut z = vec![F::ZERO; D];
    for (idx, value) in values.iter().copied().enumerate() {
        z[idx] = F::from_u64(value);
    }

    let mut z_mat = Mat::zero(D, 1, F::ZERO);
    for (idx, value) in z.iter().copied().enumerate() {
        z_mat[(idx % D, idx / D)] = value;
    }

    let x = z[..m_in].to_vec();
    let w = z[m_in..].to_vec();
    StepInput {
        label: label.to_string(),
        mcs: CcsClaim {
            c: neo_ccs::traits::SModuleHomomorphism::commit(log, &z_mat),
            x,
            m_in,
        },
        witness: CcsWitness { w, Z: z_mat },
    }
}

#[test]
fn fibonacci_abba_two_traces() {
    let traces = vec![vec![1_u64, 1, 2, 3, 5, 8, 13], vec![2_u64, 3, 5, 8, 13, 21, 34]];
    let params = NeoParams::goldilocks_auto_r1cs_ccs(traces[0].len() - 2).expect("params");
    let ccs = fibonacci_trace_ccs(traces[0].len());
    let log = make_abba_module(&params, 1);

    let steps = traces
        .iter()
        .enumerate()
        .map(|(idx, values)| fibonacci_step(&log, &format!("fib_abba_{idx}"), values))
        .collect::<Vec<_>>();

    let proof = prove_run(
        FoldingMode::Optimized,
        FoldSchedule::RowsPerChunk(1),
        &params,
        &ccs,
        steps.clone(),
        &log,
        abba_mixers(),
    )
    .expect("ABBA prove run");

    assert_eq!(proof.chunks.len(), 2);
    assert_eq!(proof.final_main_claims.len(), params.k_rho as usize);

    let public_steps = steps
        .into_iter()
        .map(|step| step.public())
        .collect::<Vec<_>>();
    let verified = verify_run(
        FoldingMode::Optimized,
        &params,
        &ccs,
        &public_steps,
        &proof,
        abba_mixers(),
    )
    .expect("ABBA verify");
    assert_eq!(verified, proof.final_main_claims);

    println!("ABBA fibonacci: 2 traces, prove + verify OK");
}

#[test]
fn fibonacci_abba_ten_steps() {
    let trace_len = 7usize;
    let traces = (1_u64..=10)
        .map(|seed| {
            let mut t = Vec::with_capacity(trace_len);
            t.push(seed);
            t.push(seed + 1);
            while t.len() < trace_len {
                t.push(t[t.len() - 2] + t[t.len() - 1]);
            }
            t
        })
        .collect::<Vec<_>>();
    let params = NeoParams::goldilocks_auto_r1cs_ccs(trace_len - 2).expect("params");
    let ccs = fibonacci_trace_ccs(trace_len);
    let log = make_abba_module(&params, 1);

    let steps = traces
        .iter()
        .enumerate()
        .map(|(idx, values)| fibonacci_step(&log, &format!("fib_abba_{idx}"), values))
        .collect::<Vec<_>>();

    let proof = prove_run(
        FoldingMode::Optimized,
        FoldSchedule::RowsPerChunk(1),
        &params,
        &ccs,
        steps.clone(),
        &log,
        abba_mixers(),
    )
    .expect("ABBA prove 10 steps");

    assert_eq!(proof.chunks.len(), 10);

    let public_steps = steps
        .into_iter()
        .map(|step| step.public())
        .collect::<Vec<_>>();
    let verified = verify_run(
        FoldingMode::Optimized,
        &params,
        &ccs,
        &public_steps,
        &proof,
        abba_mixers(),
    )
    .expect("ABBA verify 10 steps");
    assert_eq!(verified, proof.final_main_claims);

    println!("ABBA fibonacci: 10 steps, prove + verify OK");
}

#[test]
fn fibonacci_abba_metrics() {
    use std::time::Instant;

    for &(n_steps, transitions_per_chunk, k_rho) in &[
        (2usize, 5usize, 12u32),
        (5, 5, 12),
        (10, 5, 12),
        (5, 10, 13),
    ] {
        let trace_len = transitions_per_chunk + 2;
        let traces: Vec<Vec<u64>> = (1..=n_steps as u64)
            .map(|seed| {
                let mut t = vec![seed, seed + 1];
                while t.len() < trace_len {
                    t.push(t[t.len() - 2] + t[t.len() - 1]);
                }
                t
            })
            .collect();

        let mut params = NeoParams::goldilocks_auto_r1cs_ccs(transitions_per_chunk).expect("params");
        params.k_rho = k_rho;
        params.B = 1u64.checked_shl(k_rho).expect("B fits");
        let ccs = fibonacci_trace_ccs(trace_len);
        let log = make_abba_module(&params, 1);

        let steps: Vec<StepInput> = traces
            .iter()
            .enumerate()
            .map(|(idx, values)| fibonacci_step(&log, &format!("abba_m_{idx}"), values))
            .collect();
        let public_steps: Vec<_> = steps.iter().map(|s| s.public()).collect();

        // Prove
        let prove_start = Instant::now();
        let proof = prove_run(
            FoldingMode::Optimized,
            FoldSchedule::RowsPerChunk(1),
            &params,
            &ccs,
            steps.clone(),
            &log,
            abba_mixers(),
        )
        .expect("ABBA prove");
        let prove_ms = prove_start.elapsed().as_secs_f64() * 1000.0;

        // Verify
        let verify_start = Instant::now();
        let _verified = verify_run(
            FoldingMode::Optimized,
            &params,
            &ccs,
            &public_steps,
            &proof,
            abba_mixers(),
        )
        .expect("ABBA verify");
        let verify_ms = verify_start.elapsed().as_secs_f64() * 1000.0;

        let proof_bytes = bincode::serialize(&proof).expect("serialize").len();

        println!(
            "ABBA_metrics steps={} trans/chunk={} k_rho={} prove_ms={:.3} verify_ms={:.3} proof_bytes={} claims={}",
            n_steps, transitions_per_chunk, k_rho, prove_ms, verify_ms, proof_bytes,
            proof.final_main_claims.len()
        );
    }
}
