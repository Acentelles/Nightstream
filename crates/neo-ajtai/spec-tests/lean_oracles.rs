use neo_ajtai::{assert_range_b, decomp_b_row_major, DecompStyle};
use p3_field::PrimeCharacteristicRing;
use p3_goldilocks::Goldilocks as Fq;
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

fn base_pow(base: u32, exp: usize) -> Fq {
    let mut acc = Fq::ONE;
    let b = Fq::from_u64(base as u64);
    for _ in 0..exp {
        acc *= b;
    }
    acc
}

#[derive(Deserialize)]
struct DecompOracle {
    cases: Vec<DecompCase>,
}

#[derive(Deserialize)]
struct DecompCase {
    input: Vec<u64>,
    base: u32,
    k: usize,
    expected_digits_row_major: Vec<Vec<u64>>,
    expected_recomposed: Vec<u64>,
}

#[test]
fn lean_decomp_oracles_match_neo_ajtai() {
    let oracle: DecompOracle = load_json("decomp_v1.json");

    for case in oracle.cases {
        let input = fq_vec(&case.input);
        let expected_digits: Vec<Vec<Fq>> = case
            .expected_digits_row_major
            .iter()
            .map(|row| fq_vec(row))
            .collect();
        let expected_recomposed = fq_vec(&case.expected_recomposed);

        let digits = decomp_b_row_major(&input, case.base, case.k, DecompStyle::Balanced);
        assert_eq!(digits.len(), case.k * input.len());
        assert_range_b(&digits, case.base).expect("digits must satisfy the NC bound");

        let got_rows: Vec<Vec<Fq>> = digits
            .chunks_exact(input.len())
            .map(|row| row.to_vec())
            .collect();
        assert_eq!(got_rows, expected_digits);

        let mut recomposed = vec![Fq::ZERO; input.len()];
        for row in 0..case.k {
            let weight = base_pow(case.base, row);
            for col in 0..input.len() {
                recomposed[col] += digits[row * input.len() + col] * weight;
            }
        }

        assert_eq!(recomposed, expected_recomposed);
        assert_eq!(recomposed, input);
    }
}
