use neo_ccs::utils::tensor_point;
use neo_math::{ct, superneo_bar_block, Fq, Rq, D};
use p3_field::PrimeCharacteristicRing;
use serde::Deserialize;
use std::fs;
use std::path::PathBuf;

fn oracle_path(name: &str) -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../formal/superneo-lean/generated-oracles")
        .join(name)
}

fn load_json<T: for<'de> Deserialize<'de>>(name: &str) -> T {
    let path = oracle_path(name);
    let bytes = fs::read(path).expect("oracle fixture should exist");
    serde_json::from_slice(&bytes).expect("oracle fixture should parse")
}

fn fq_vec(values: &[u64]) -> Vec<Fq> {
    values.iter().copied().map(Fq::from_u64).collect()
}

fn fq_block(values: &[Fq]) -> [Fq; D] {
    values
        .to_vec()
        .try_into()
        .expect("oracle fixture must have exactly D coefficients")
}

fn field_mul_rows(matrix: &[Vec<Fq>], z: &[Fq]) -> Vec<Fq> {
    matrix
        .iter()
        .map(|row| {
            row.iter()
                .zip(z.iter())
                .fold(Fq::ZERO, |acc, (&a, &b)| acc + a * b)
        })
        .collect()
}

fn row_bar_mz_ring_exec(row: &[Fq], z: &[Fq]) -> Rq {
    let n_blocks = usize::min(row.len() / D, z.len() / D);
    let mut acc = Rq::zero();
    for j in 0..n_blocks {
        let row_block = fq_block(&row[j * D..(j + 1) * D]);
        let z_block = fq_block(&z[j * D..(j + 1) * D]);
        let row_ring = Rq(superneo_bar_block(row_block));
        let z_ring = Rq(z_block);
        acc = acc + row_ring.mul(&z_ring);
    }
    acc
}

fn bar_mz_ring_exec(matrix: &[Vec<Fq>], z: &[Fq]) -> Vec<Rq> {
    matrix
        .iter()
        .map(|row| row_bar_mz_ring_exec(row, z))
        .collect()
}

fn eval_ring_vector_exec(ys: &[Rq], weights: &[Fq]) -> Rq {
    if ys.len() != weights.len() {
        return Rq::zero();
    }
    let mut acc = Rq::zero();
    for (&weight, y) in weights.iter().zip(ys.iter()) {
        acc = acc + Rq(y.0.map(|coeff| weight * coeff));
    }
    acc
}

fn eval_bar_mz_at_ring_exec(matrix: &[Vec<Fq>], z: &[Fq], r: &[Fq]) -> Rq {
    let ys = bar_mz_ring_exec(matrix, z);
    let weights = tensor_point(r);
    eval_ring_vector_exec(&ys, &weights)
}

#[derive(Deserialize)]
struct MleTensorOracle {
    cases: Vec<MleTensorCase>,
}

#[derive(Deserialize)]
struct MleTensorCase {
    r: Vec<u64>,
    expected_tensor: Vec<u64>,
}

#[derive(Deserialize)]
struct MatrixEvalOracle {
    matrix_transform_case: MatrixTransformCase,
    eval_link_case: EvalLinkCase,
    eval_hom_case: EvalHomCase,
}

#[derive(Deserialize)]
struct MatrixTransformCase {
    matrix: Vec<Vec<u64>>,
    z: Vec<u64>,
    expected_mz: Vec<u64>,
    expected_ct_bar_mz: Vec<u64>,
}

#[derive(Deserialize)]
struct EvalLinkCase {
    matrix: Vec<Vec<u64>>,
    z: Vec<u64>,
    r: Vec<u64>,
    expected_y: Vec<u64>,
    expected_ct_y: u64,
}

#[derive(Deserialize)]
struct EvalHomCase {
    matrix: Vec<Vec<u64>>,
    z1: Vec<u64>,
    z2: Vec<u64>,
    r: Vec<u64>,
    rho1: u64,
    rho2: u64,
    expected_y1: Vec<u64>,
    expected_y2: Vec<u64>,
    expected_y_lin: Vec<u64>,
    expected_y_direct: Vec<u64>,
}

#[test]
fn lean_mle_tensor_oracles_match_tensor_point() {
    let oracle: MleTensorOracle = load_json("mle_tensor_v1.json");

    for case in oracle.cases {
        let r = fq_vec(&case.r);
        let expected = fq_vec(&case.expected_tensor);
        assert_eq!(tensor_point(&r), expected);
    }
}

#[test]
fn lean_matrix_eval_oracles_match_ccs_math() {
    let oracle: MatrixEvalOracle = load_json("matrix_eval_v1.json");

    let matrix_transform_matrix: Vec<Vec<Fq>> = oracle
        .matrix_transform_case
        .matrix
        .iter()
        .map(|row| fq_vec(row))
        .collect();
    let matrix_transform_z = fq_vec(&oracle.matrix_transform_case.z);
    let expected_mz = fq_vec(&oracle.matrix_transform_case.expected_mz);
    let expected_ct_bar_mz = fq_vec(&oracle.matrix_transform_case.expected_ct_bar_mz);
    let got_mz = field_mul_rows(&matrix_transform_matrix, &matrix_transform_z);
    let got_ct_bar_mz: Vec<Fq> = matrix_transform_matrix
        .iter()
        .map(|row| ct(&row_bar_mz_ring_exec(row, &matrix_transform_z)))
        .collect();
    assert_eq!(got_mz, expected_mz);
    assert_eq!(got_ct_bar_mz, expected_ct_bar_mz);

    let eval_link_matrix: Vec<Vec<Fq>> = oracle.eval_link_case.matrix.iter().map(|row| fq_vec(row)).collect();
    let eval_link_z = fq_vec(&oracle.eval_link_case.z);
    let eval_link_r = fq_vec(&oracle.eval_link_case.r);
    let expected_y = fq_vec(&oracle.eval_link_case.expected_y);
    let got_y = eval_bar_mz_at_ring_exec(&eval_link_matrix, &eval_link_z, &eval_link_r);
    assert_eq!(got_y.0.to_vec(), expected_y);
    assert_eq!(ct(&got_y), Fq::from_u64(oracle.eval_link_case.expected_ct_y));

    let eval_hom_matrix: Vec<Vec<Fq>> = oracle.eval_hom_case.matrix.iter().map(|row| fq_vec(row)).collect();
    let z1 = fq_vec(&oracle.eval_hom_case.z1);
    let z2 = fq_vec(&oracle.eval_hom_case.z2);
    let r = fq_vec(&oracle.eval_hom_case.r);
    let rho1 = Fq::from_u64(oracle.eval_hom_case.rho1);
    let rho2 = Fq::from_u64(oracle.eval_hom_case.rho2);
    let expected_y1 = fq_vec(&oracle.eval_hom_case.expected_y1);
    let expected_y2 = fq_vec(&oracle.eval_hom_case.expected_y2);
    let expected_y_lin = fq_vec(&oracle.eval_hom_case.expected_y_lin);
    let expected_y_direct = fq_vec(&oracle.eval_hom_case.expected_y_direct);
    let y1 = eval_bar_mz_at_ring_exec(&eval_hom_matrix, &z1, &r);
    let y2 = eval_bar_mz_at_ring_exec(&eval_hom_matrix, &z2, &r);
    let y_lin = y1 + Rq(y2.0.map(|coeff| rho2 * coeff)) + Rq(y1.0.map(|coeff| (rho1 - Fq::ONE) * coeff));
    let z_direct: Vec<Fq> = z1
        .iter()
        .zip(z2.iter())
        .map(|(&a, &b)| rho1 * a + rho2 * b)
        .collect();
    let y_direct = eval_bar_mz_at_ring_exec(&eval_hom_matrix, &z_direct, &r);
    assert_eq!(y1.0.to_vec(), expected_y1);
    assert_eq!(y2.0.to_vec(), expected_y2);
    assert_eq!(y_lin.0.to_vec(), expected_y_lin);
    assert_eq!(y_direct.0.to_vec(), expected_y_direct);
    assert_eq!(y_lin, y_direct);
}
