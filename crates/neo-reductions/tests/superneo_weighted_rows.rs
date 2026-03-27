use neo_ccs::{matrix::Mat, poly::SparsePoly, CcsStructure};
use neo_math::KExtensions;
use neo_math::{D, F, K};
use neo_reductions::superneo_eval::{build_superneo_eval_cache, SuperneoZBlocks};
use p3_field::PrimeCharacteristicRing;

fn k(re: u64, im: u64) -> K {
    K::from_coeffs([F::from_u64(re), F::from_u64(im)])
}

#[test]
fn compiled_weighted_rows_match_direct_weighted_row_projection_for_real_witnesses() {
    let rows = 32usize;
    let cols = 2 * D;

    let mut m0 = Mat::zero(rows, cols, F::ZERO);
    let mut m1 = Mat::zero(rows, cols, F::ZERO);
    for r in 0..rows {
        for c in 0..cols {
            if ((r * 13) + (c * 7)) % 19 == 0 {
                m0[(r, c)] = F::from_u64(((r + 2 * c) % 23 + 1) as u64);
            }
            if ((r * 5) + (c * 11)) % 29 == 0 {
                m1[(r, c)] = F::from_u64(((3 * r + c) % 31 + 1) as u64);
            }
        }
    }

    let s = CcsStructure::new(vec![m0, m1], SparsePoly::new(2, vec![])).expect("valid CCS");
    let cache = build_superneo_eval_cache(&s).expect("cache should build for D-compatible width");
    let weights = core::array::from_fn(|i| k((100 + i) as u64, (200 + 3 * i) as u64));
    let weighted = cache.build_weighted_matrix_caches(&weights);

    let z: Vec<K> = (0..cols).map(|i| k((11 * i + 1) as u64, 0)).collect();
    let z_blocks = SuperneoZBlocks::from_z(&z);
    for (j, compiled) in weighted.iter().enumerate() {
        let mat = cache.matrix(j).expect("matrix cache exists");
        for row in 0..rows {
            let direct = mat.row_dot_ring_weighted_with_blocks(row, &z_blocks, &weights);
            let optimized = compiled.row_dot_real_with_blocks(row, &z_blocks);
            assert_eq!(optimized, direct, "matrix {j} row {row}");
        }
    }
}
