use std::fmt::Write as _;
use std::fs;
use std::path::PathBuf;

#[path = "../../../../../crates/neo-fold/tests/common/setup.rs"]
mod common_setup;
#[path = "../neo_fold_artifacts.rs"]
mod neo_fold_artifacts;

use neo_math::{ct, Fq as F, D};
use p3_field::{PrimeCharacteristicRing, PrimeField64};

fn f_u64(x: F) -> u64 {
    x.as_canonical_u64()
}

fn fmt_nat_array(vals: &[u64]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, v) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        let _ = write!(s, "{v}");
    }
    s.push(']');
    s
}

fn fmt_nat_array2(vals: &[Vec<u64>]) -> String {
    let mut s = String::new();
    s.push_str("#[");
    for (i, row) in vals.iter().enumerate() {
        if i != 0 {
            s.push_str(", ");
        }
        s.push_str(&fmt_nat_array(row));
    }
    s.push(']');
    s
}

fn zero_coeffs() -> Vec<u64> {
    vec![0; D]
}

fn unit_coeffs() -> Vec<u64> {
    let mut out = zero_coeffs();
    out[0] = 1;
    out
}

fn single_row_matrix() -> Vec<Vec<u64>> {
    vec![unit_coeffs()]
}

fn main() {
    let carrier_left = unit_coeffs();
    let carrier_right = zero_coeffs();
    let cset = vec![zero_coeffs()];
    let samples = vec![unit_coeffs()];
    let matrix = single_row_matrix();
    let r = vec![0u64];
    let q_vals = vec![7u64, 11u64];
    let xs = vec![0u64, 1u64];
    let ys = vec![0u64, 1u64];
    let coeffs = vec![0u64, 1u64];
    let x_eval = 2u64;
    let expected_eval = 2u64;
    let transcript_challenges = vec![0u64];
    let transcript_round_polys = vec![vec![0u64, 1u64]];
    let split_scalar = 1u64;
    let k_split = 1u64;
    let sampling_bound = 1u64;
    let rho1 = 1u64;
    let rho2 = 0u64;
    let message_length = 1u64;
    let tampered_expected_eval = expected_eval + 1;

    let inv_delta_ct = ct(&neo_math::cf_inv({
        let mut block = [F::ZERO; D];
        block[0] = F::ONE;
        block
    }));
    assert_eq!(f_u64(inv_delta_ct), 1);

    let mut out = String::new();
    out.push_str("import SuperNeo.Generated.ProtocolArtifactsCases\n\n");
    out.push_str("namespace SuperNeo.Generated\n\n");

    out.push_str("def protocolArtifactCases : Array ProtocolArtifactCase := #[\n");
    let _ = writeln!(
        out,
        "  {{ matrix := {}, r := {}, rho1 := {}, rho2 := {}, splitScalar := {}, kSplit := {}, samplingBound := {}, carrierLeft := {}, carrierRight := {}, cset := {}, samples := {}, xs := {}, ys := {}, qVals := {}, coeffs := {}, xEval := {}, expectedEval := {}, transcriptChallenges := {}, transcriptRoundPolys := {} }},",
        fmt_nat_array2(&matrix),
        fmt_nat_array(&r),
        rho1,
        rho2,
        split_scalar,
        k_split,
        sampling_bound,
        fmt_nat_array(&carrier_left),
        fmt_nat_array(&carrier_right),
        fmt_nat_array2(&cset),
        fmt_nat_array2(&samples),
        fmt_nat_array(&xs),
        fmt_nat_array(&ys),
        fmt_nat_array(&q_vals),
        fmt_nat_array(&coeffs),
        x_eval,
        expected_eval,
        fmt_nat_array(&transcript_challenges),
        fmt_nat_array2(&transcript_round_polys)
    );
    let _ = writeln!(
        out,
        "  {{ matrix := {}, r := {}, rho1 := {}, rho2 := {}, splitScalar := {}, kSplit := {}, samplingBound := {}, carrierLeft := {}, carrierRight := {}, cset := {}, samples := {}, xs := {}, ys := {}, qVals := {}, coeffs := {}, xEval := {}, expectedEval := {}, transcriptChallenges := {}, transcriptRoundPolys := {} }},",
        fmt_nat_array2(&matrix),
        fmt_nat_array(&r),
        rho1,
        rho2,
        split_scalar,
        k_split,
        sampling_bound,
        fmt_nat_array(&carrier_left),
        fmt_nat_array(&carrier_right),
        fmt_nat_array2(&cset),
        fmt_nat_array2(&samples),
        fmt_nat_array(&xs),
        fmt_nat_array(&ys),
        fmt_nat_array(&q_vals),
        fmt_nat_array(&coeffs),
        x_eval,
        tampered_expected_eval,
        fmt_nat_array(&transcript_challenges),
        fmt_nat_array2(&transcript_round_polys)
    );
    out.push_str("]\n\n");

    out.push_str("def finalProtocolArtifactCases : Array FinalProtocolArtifactCase := #[\n");
    let _ = writeln!(
        out,
        "  {{ messageLength := {}, protocol := protocolArtifactCases[0]! }},",
        message_length
    );
    out.push_str("]\n\n");

    out.push_str("end SuperNeo.Generated\n");

    let out_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("SuperNeo")
        .join("Generated")
        .join("ProtocolArtifacts.lean");
    fs::write(&out_path, out).expect("write protocol artifacts");
    println!("wrote {}", out_path.display());

    neo_fold_artifacts::export_neo_fold_artifacts();
}
