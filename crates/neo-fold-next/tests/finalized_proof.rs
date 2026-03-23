use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsStructure, CcsWitness, Mat, SparsePoly};
use neo_fold_next::proof::StepInput;
use neo_fold_next::prover::CommitmentMixers;
use neo_fold_next::run::{prove_and_package, verify_packaged};
use neo_math::{D, F};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use p3_field::PrimeCharacteristicRing;

struct ToyModule;

impl SModuleHomomorphism<F, Commitment> for ToyModule {
    fn commit(&self, z: &Mat<F>) -> Commitment {
        let mut out = Commitment::zeros(z.rows(), 1);
        for r in 0..z.rows() {
            let mut acc = F::ZERO;
            for c in 0..z.cols() {
                acc += z[(r, c)];
            }
            out.data[r] = acc;
        }
        out
    }

    fn project_x(&self, z: &Mat<F>, min: usize) -> Mat<F> {
        let cols = min.min(z.cols());
        let mut out = Mat::zero(z.rows(), cols, F::ZERO);
        for r in 0..z.rows() {
            for c in 0..cols {
                out[(r, c)] = z[(r, c)];
            }
        }
        out
    }
}

fn identity_ccs(n: usize) -> CcsStructure<F> {
    CcsStructure::new(vec![Mat::identity(n)], SparsePoly::new(1, vec![])).expect("valid CCS")
}

fn add_commitments(lhs: &Commitment, rhs: &Commitment) -> Commitment {
    let mut out = lhs.clone();
    out.add_inplace(rhs);
    out
}

fn scale_commitment_by_rho(rho: &Mat<F>, c: &Commitment) -> Commitment {
    let mut out = Commitment::zeros(c.d, c.kappa);
    for col in 0..c.kappa {
        for r in 0..c.d {
            let mut acc = F::ZERO;
            for k in 0..c.d {
                acc += rho[(r, k)] * c.col(col)[k];
            }
            out.col_mut(col)[r] = acc;
        }
    }
    out
}

fn mix_rhos_commits(rhos: &[Mat<F>], cs: &[Commitment]) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    for (rho, c) in rhos.iter().zip(cs.iter()) {
        acc = add_commitments(&acc, &scale_commitment_by_rho(rho, c));
    }
    acc
}

fn combine_b_pows(cs: &[Commitment], b: u32) -> Commitment {
    let mut acc = Commitment::zeros(cs[0].d, cs[0].kappa);
    let mut pow = F::ONE;
    let base = F::from_u64(b as u64);
    for c in cs {
        let mut term = c.clone();
        for value in &mut term.data {
            *value *= pow;
        }
        acc = add_commitments(&acc, &term);
        pow *= base;
    }
    acc
}

fn mixers() -> CommitmentMixers<fn(&[Mat<F>], &[Commitment]) -> Commitment, fn(&[Commitment], u32) -> Commitment> {
    CommitmentMixers {
        mix_rhos_commits,
        combine_b_pows,
    }
}

fn make_step(log: &ToyModule, seed: u64, label: &str) -> StepInput {
    let m = D;
    let m_in = 2usize;
    let mut z = vec![F::ZERO; m];
    for (idx, value) in z.iter_mut().enumerate() {
        *value = match (seed as usize + idx * 17) % 3 {
            0 => -F::ONE,
            1 => F::ZERO,
            _ => F::ONE,
        };
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
            c: log.commit(&z_mat),
            x,
            m_in,
        },
        witness: CcsWitness { w, Z: z_mat },
    }
}

#[test]
fn packaged_proof_packages_the_real_spine() {
    let params = NeoParams::goldilocks_auto_r1cs_ccs(D).expect("params");
    let ccs = identity_ccs(D);
    let log = ToyModule;
    let steps = vec![make_step(&log, 7, "step0"), make_step(&log, 29, "step1")];

    let packaged =
        prove_and_package(FoldingMode::Optimized, &params, &ccs, steps, &log, mixers()).expect("prove packaged run");

    assert_eq!(packaged.statement.steps.len(), 2);
    assert_eq!(packaged.proof.session.steps.len(), 2);
    assert_eq!(
        packaged.proof.session.steps[0].dec.children.len(),
        params.k_rho as usize
    );
    assert_eq!(
        packaged.proof.session.steps[1].ccs_outputs.len(),
        (params.k_rho as usize) + 1
    );
    assert_eq!(packaged.statement.final_main_claims.len(), params.k_rho as usize);

    let verified =
        verify_packaged(FoldingMode::Optimized, &params, &ccs, &packaged, mixers()).expect("verify packaged");
    assert_eq!(verified, packaged.statement.final_main_claims);
}

#[test]
fn packaged_proof_rejects_tampered_statement() {
    let params = NeoParams::goldilocks_auto_r1cs_ccs(D).expect("params");
    let ccs = identity_ccs(D);
    let log = ToyModule;
    let steps = vec![make_step(&log, 13, "step0"), make_step(&log, 31, "step1")];

    let mut packaged =
        prove_and_package(FoldingMode::Optimized, &params, &ccs, steps, &log, mixers()).expect("prove packaged run");

    packaged.statement.final_main_claims[0].ct[0] += neo_math::K::ONE;

    let err = verify_packaged(FoldingMode::Optimized, &params, &ccs, &packaged, mixers())
        .expect_err("tampered packaged proof must fail");
    assert!(format!("{err}").contains("final statement digest"));
}
