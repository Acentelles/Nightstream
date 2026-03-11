use neo_math::balanced::{to_balanced_i128, within_nc_bound};
use neo_math::{cf, cf_inv, ct, superneo_bar_block, superneo_bar_vec, Fq, Rq, D};
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
    let bytes = fs::read(&path).unwrap_or_else(|err| {
        panic!(
            "oracle fixture should exist at {} (run `cd formal/superneo-lean && lake exe export-oracles`): {err}",
            path.display()
        )
    });
    serde_json::from_slice(&bytes).expect("oracle fixture should parse")
}

fn fq_vec(values: &[u64]) -> Vec<Fq> {
    values.iter().copied().map(Fq::from_u64).collect()
}

fn fq_array(values: &[u64]) -> [Fq; D] {
    fq_vec(values)
        .try_into()
        .expect("oracle fixture must have exactly D coefficients")
}

fn fq_block(values: &[Fq]) -> [Fq; D] {
    values
        .to_vec()
        .try_into()
        .expect("oracle fixture must have exactly D coefficients")
}

fn centered_norm(coeffs: &[Fq; D]) -> u64 {
    coeffs
        .iter()
        .map(|value| to_balanced_i128(*value).unsigned_abs() as u64)
        .max()
        .unwrap_or(0)
}

#[derive(Deserialize)]
struct RingCtOracle {
    cases: Vec<RingCtCase>,
}

#[derive(Deserialize)]
struct RingCtCase {
    a: Vec<u64>,
    b: Vec<u64>,
    expected_product: Vec<u64>,
    expected_ct_bar_dot: u64,
    expected_dot: u64,
}

#[derive(Deserialize)]
struct CoeffMapsOracle {
    cases: Vec<CoeffMapsCase>,
}

#[derive(Deserialize)]
struct CoeffMapsCase {
    coeffs: Vec<u64>,
    expected_roundtrip: Vec<u64>,
    expected_ct: u64,
}

#[derive(Deserialize)]
struct EmbeddingBarOracle {
    vector_case: EmbeddingBarVectorCase,
    matrix_case: EmbeddingBarMatrixCase,
}

#[derive(Deserialize)]
struct EmbeddingBarVectorCase {
    input: Vec<u64>,
    expected_blocks: Vec<Vec<u64>>,
    expected_bar_lift: Vec<u64>,
}

#[derive(Deserialize)]
struct EmbeddingBarMatrixCase {
    input: Vec<Vec<u64>>,
    expected_blocks: Vec<Vec<Vec<u64>>>,
    expected_bar_lift: Vec<Vec<u64>>,
}

#[derive(Deserialize)]
struct InvertibilityOracle {
    cases: Vec<InvertibilityCase>,
}

#[derive(Deserialize)]
struct InvertibilityCase {
    coeffs: Vec<u64>,
    bound: u32,
    expected_shape: bool,
    expected_weak_window: bool,
    expected_strict_window: bool,
    expected_norm: u64,
}

#[test]
fn lean_ring_ct_oracles_match_neo_math() {
    let oracle: RingCtOracle = load_json("ring_ct_v1.json");

    for case in oracle.cases {
        let a = Rq(fq_array(&case.a));
        let b = Rq(fq_array(&case.b));
        let expected_product = fq_array(&case.expected_product);
        let expected_ct_bar_dot = Fq::from_u64(case.expected_ct_bar_dot);
        let expected_dot = Fq::from_u64(case.expected_dot);

        let got_product = a.mul(&b);
        let got_ct_bar_dot = ct(&cf_inv(superneo_bar_block(a.0)).mul(&cf_inv(b.0)));
        let got_dot =
            a.0.iter()
                .zip(b.0.iter())
                .fold(Fq::ZERO, |acc, (&x, &y)| acc + x * y);

        assert_eq!(got_product.0, expected_product);
        assert_eq!(got_ct_bar_dot, expected_ct_bar_dot);
        assert_eq!(got_dot, expected_dot);
        assert_eq!(got_ct_bar_dot, got_dot);
    }
}

#[test]
fn lean_coeff_map_oracles_match_neo_math() {
    let oracle: CoeffMapsOracle = load_json("coeff_maps_v1.json");

    for case in oracle.cases {
        let coeffs = fq_array(&case.coeffs);
        let expected_roundtrip = fq_array(&case.expected_roundtrip);
        let expected_ct = Fq::from_u64(case.expected_ct);

        let roundtrip = cf(cf_inv(coeffs));
        assert_eq!(roundtrip, expected_roundtrip);
        assert_eq!(ct(&cf_inv(coeffs)), expected_ct);
    }
}

#[test]
fn lean_embedding_bar_oracles_match_neo_math() {
    let oracle: EmbeddingBarOracle = load_json("embedding_bar_v1.json");

    let vector_input = fq_vec(&oracle.vector_case.input);
    let expected_blocks: Vec<[Fq; D]> = oracle
        .vector_case
        .expected_blocks
        .iter()
        .map(|block| fq_array(block))
        .collect();
    let expected_bar_lift = fq_vec(&oracle.vector_case.expected_bar_lift);
    let got_blocks: Vec<[Fq; D]> = vector_input.chunks_exact(D).map(fq_block).collect();
    let got_bar_lift = superneo_bar_vec(&vector_input);
    assert_eq!(got_blocks, expected_blocks);
    assert_eq!(got_bar_lift, expected_bar_lift);

    let matrix_input: Vec<Vec<Fq>> = oracle
        .matrix_case
        .input
        .iter()
        .map(|row| fq_vec(row))
        .collect();
    let expected_matrix_blocks: Vec<Vec<[Fq; D]>> = oracle
        .matrix_case
        .expected_blocks
        .iter()
        .map(|row| row.iter().map(|block| fq_array(block)).collect())
        .collect();
    let expected_matrix_bar_lift: Vec<Vec<Fq>> = oracle
        .matrix_case
        .expected_bar_lift
        .iter()
        .map(|row| fq_vec(row))
        .collect();
    let got_matrix_blocks: Vec<Vec<[Fq; D]>> = matrix_input
        .iter()
        .map(|row| row.chunks_exact(D).map(fq_block).collect())
        .collect();
    let got_matrix_bar_lift: Vec<Vec<Fq>> = matrix_input
        .iter()
        .map(|row| superneo_bar_vec(row))
        .collect();
    assert_eq!(got_matrix_blocks, expected_matrix_blocks);
    assert_eq!(got_matrix_bar_lift, expected_matrix_bar_lift);
}

#[test]
fn lean_invertibility_oracles_match_runtime_windows() {
    let oracle: InvertibilityOracle = load_json("invertibility_v1.json");

    for case in oracle.cases {
        let coeffs = fq_array(&case.coeffs);
        let got_shape = coeffs.len() == D;
        let got_weak_window = coeffs
            .iter()
            .all(|coeff| within_nc_bound(*coeff, case.bound));
        let got_strict_window = got_weak_window && coeffs.iter().any(|coeff| *coeff != Fq::ZERO);
        let got_norm = centered_norm(&coeffs);

        assert_eq!(got_shape, case.expected_shape);
        assert_eq!(got_weak_window, case.expected_weak_window);
        assert_eq!(got_strict_window, case.expected_strict_window);
        assert_eq!(got_norm, case.expected_norm);
    }
}
