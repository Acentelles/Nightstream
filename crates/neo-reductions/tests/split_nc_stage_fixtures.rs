use std::ffi::OsString;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::Arc;

use neo_ccs::{CcsStructure, CcsWitness, Mat, SparsePoly, Term};
use neo_gpu::{connect, DeviceApi, FlatK, MojoBackendConfig, MojoSession};
use neo_math::{from_complex, KExtensions, D, F, K};
use neo_params::NeoParams;
use neo_reductions::engines::optimized_engine::oracle::{NcOracle, OptimizedOracle, SparseCache};
use neo_reductions::engines::utils::build_dims_and_policy;
use neo_reductions::sumcheck::RoundOracle;
use neo_reductions::test_exports::{
    fe_row_snapshot_bytes_for_testing, fe_row_snapshot_cur_len_for_testing, fe_row_snapshot_has_eval_gate_for_testing,
    nc_col_snapshot_bytes_for_testing, nc_col_snapshot_cur_len_for_testing, nc_col_snapshot_num_tables_for_testing,
};
use neo_reductions::Challenges;
use p3_field::PrimeCharacteristicRing;

fn k(re: u64, im: u64) -> K {
    from_complex(F::from_u64(re), F::from_u64(im))
}

fn dense_mat<Ff: PrimeCharacteristicRing + Copy>(rows: usize, cols: usize, seed: u64) -> Mat<Ff> {
    let mut data = Vec::with_capacity(rows * cols);
    for r in 0..rows {
        for c in 0..cols {
            let value = if (r + 2 * c) % 5 == 0 {
                Ff::from_u64(seed + (r as u64) * 17 + (c as u64) * 23 + 1)
            } else {
                Ff::ZERO
            };
            data.push(value);
        }
    }
    Mat::from_row_major(rows, cols, data)
}

fn z_witness(seed: u64, m: usize) -> Mat<F> {
    assert!(m.is_multiple_of(D));
    let cols = m / D;
    let mut data = Vec::with_capacity(D * cols);
    for rho in 0..D {
        for blk in 0..cols {
            let c = blk * D + rho;
            data.push(F::from_u64(seed + (rho as u64) * 19 + (c as u64) * 29));
        }
    }
    Mat::from_row_major(D, cols, data)
}

struct OracleFixture {
    params: NeoParams,
    s: CcsStructure<F>,
    mcs_witnesses: Vec<CcsWitness<F>>,
    me_witnesses: Vec<Mat<F>>,
    ch: Challenges,
    r_inputs: Option<Vec<K>>,
    ell_d: usize,
    ell_n: usize,
    ell_m: usize,
    d_sc: usize,
    sparse: Arc<SparseCache<F>>,
}

fn build_fixture(include_me: bool, include_r_inputs: bool) -> OracleFixture {
    let n = D;
    let m = D;
    let params = NeoParams::goldilocks_auto_r1cs_ccs(n).expect("params");
    let matrices = vec![
        Mat::<F>::identity(n),
        dense_mat::<F>(n, m, 10),
        dense_mat::<F>(n, m, 20),
        dense_mat::<F>(n, m, 30),
    ];
    let f = SparsePoly::new(
        4,
        vec![
            Term {
                coeff: F::ONE,
                exps: vec![0, 1, 1, 0],
            },
            Term {
                coeff: -F::ONE,
                exps: vec![0, 0, 0, 1],
            },
        ],
    );
    let s = CcsStructure::new(matrices, f).expect("ccs");
    let dims = build_dims_and_policy(&params, &s).expect("dims");

    let mcs_witnesses = vec![
        CcsWitness {
            w: vec![],
            Z: z_witness(100, m),
        },
        CcsWitness {
            w: vec![],
            Z: z_witness(200, m),
        },
    ];
    let me_witnesses = if include_me {
        vec![z_witness(300, m)]
    } else {
        Vec::new()
    };
    let ch = Challenges {
        alpha: (0..dims.ell_d)
            .map(|i| k(1_000 + i as u64, 2_000 + i as u64))
            .collect(),
        beta_a: (0..dims.ell_d)
            .map(|i| k(3_000 + i as u64, 4_000 + i as u64))
            .collect(),
        beta_r: (0..dims.ell_n)
            .map(|i| k(5_000 + i as u64, 6_000 + i as u64))
            .collect(),
        beta_m: (0..dims.ell_m)
            .map(|i| k(7_000 + i as u64, 8_000 + i as u64))
            .collect(),
        gamma: k(9_999, 11_111),
    };
    let r_inputs = include_r_inputs.then(|| {
        (0..dims.ell_n)
            .map(|i| k(12_000 + i as u64, 13_000 + i as u64))
            .collect::<Vec<_>>()
    });

    let sparse = Arc::new(SparseCache::build(&s));

    OracleFixture {
        params,
        s,
        mcs_witnesses,
        me_witnesses,
        ch,
        r_inputs,
        ell_d: dims.ell_d,
        ell_n: dims.ell_n,
        ell_m: dims.ell_m,
        d_sc: dims.d_sc,
        sparse,
    }
}

fn probe_points(seed_re: u64, seed_im: u64) -> Vec<K> {
    vec![K::ZERO, K::ONE, k(seed_re, seed_im), k(seed_re + 17, seed_im + 19)]
}

fn flat_points(points: &[K]) -> Vec<FlatK> {
    points
        .iter()
        .map(|x| {
            let (re, im) = x.to_limbs_u64();
            FlatK { re, im }
        })
        .collect()
}

fn ext_points(points: &[FlatK]) -> Vec<K> {
    points.iter().map(|x| k(x.re, x.im)).collect()
}

fn mock_library_name() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "libmock_mojo_gpu.dylib"
    }
    #[cfg(target_os = "linux")]
    {
        "libmock_mojo_gpu.so"
    }
    #[cfg(target_os = "windows")]
    {
        "mock_mojo_gpu.dll"
    }
}

fn build_mock_library() -> &'static Path {
    static LIB_PATH: std::sync::OnceLock<PathBuf> = std::sync::OnceLock::new();
    LIB_PATH.get_or_init(|| {
        let manifest = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("neo-gpu")
            .join("tests")
            .join("support")
            .join("mock-mojo-gpu")
            .join("Cargo.toml");
        let cargo = std::env::var("CARGO").unwrap_or_else(|_| "cargo".to_string());
        let status = Command::new(cargo)
            .arg("build")
            .arg("--release")
            .arg("--manifest-path")
            .arg(&manifest)
            .status()
            .expect("spawn cargo build for mock mojo gpu");
        assert!(status.success(), "mock mojo gpu build failed");

        manifest
            .parent()
            .expect("mock manifest parent")
            .join("target")
            .join("release")
            .join(mock_library_name())
            .canonicalize()
            .expect("canonical mock mojo gpu library path")
    })
}

fn real_mojo_library_name() -> &'static str {
    #[cfg(target_os = "macos")]
    {
        "libnightstream_mojo_gpu.dylib"
    }
    #[cfg(target_os = "linux")]
    {
        "libnightstream_mojo_gpu.so"
    }
    #[cfg(target_os = "windows")]
    {
        "nightstream_mojo_gpu.dll"
    }
}

fn pixi_bin() -> OsString {
    if let Some(home) = std::env::var_os("HOME") {
        let candidate = PathBuf::from(home).join(".pixi").join("bin").join("pixi");
        if candidate.is_file() {
            return candidate.into_os_string();
        }
    }
    OsString::from("pixi")
}

fn build_real_mojo_library() -> &'static Path {
    static LIB_PATH: std::sync::OnceLock<PathBuf> = std::sync::OnceLock::new();
    LIB_PATH.get_or_init(|| {
        let project_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("..")
            .join("..")
            .join("gpu")
            .join("mojo");
        let output_dir = project_dir.join("build");
        let output = output_dir.join(real_mojo_library_name());
        std::fs::create_dir_all(&output_dir).expect("create mojo build directory");

        let status = Command::new(pixi_bin())
            .arg("run")
            .arg("mojo")
            .arg("build")
            .arg("--emit")
            .arg("shared-lib")
            .arg("src/lib.mojo")
            .arg("-o")
            .arg(&output)
            .current_dir(&project_dir)
            .status()
            .expect("spawn mojo build");
        assert!(status.success(), "real mojo gpu build failed");

        output
            .canonicalize()
            .expect("canonical real mojo gpu library path")
    })
}

fn mock_cpu_session() -> MojoSession {
    connect(&MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_mock_library()))
        .expect("connect mock mojo session")
}

fn real_cpu_session() -> MojoSession {
    connect(&MojoBackendConfig::new(DeviceApi::Cpu).with_library_path(build_real_mojo_library()))
        .expect("connect real mojo session")
}

fn direct_fe_eval(session: &MojoSession, snapshot: &[u8], points: &[K]) -> Vec<K> {
    let flat = flat_points(points);
    let evaluator = session
        .create_fe_evaluator(snapshot)
        .expect("create direct FE evaluator");
    ext_points(&evaluator.evals_at(&flat).expect("direct FE evals"))
}

fn direct_nc_eval(session: &MojoSession, snapshot: &[u8], points: &[K]) -> Vec<K> {
    let flat = flat_points(points);
    let evaluator = session
        .create_nc_evaluator(snapshot)
        .expect("create direct NC evaluator");
    ext_points(&evaluator.evals_at(&flat).expect("direct NC evals"))
}

#[test]
fn fe_chunk_snapshot_fixture_matches_cpu_reference() {
    let fixture = build_fixture(false, false);
    let mut oracle = OptimizedOracle::new_with_sparse(
        &fixture.s,
        &fixture.params,
        &fixture.mcs_witnesses,
        &fixture.me_witnesses,
        fixture.ch,
        fixture.ell_d,
        fixture.ell_n,
        fixture.d_sc,
        None,
        fixture.sparse,
    );
    assert!(!fe_row_snapshot_has_eval_gate_for_testing(&oracle));
    let snapshot = fe_row_snapshot_bytes_for_testing(&oracle);
    let points = probe_points(101, 202);
    assert_eq!(
        oracle.evals_at(&points),
        direct_fe_eval(&mock_cpu_session(), &snapshot, &points)
    );
}

#[test]
fn fe_aggregate_snapshot_fixture_matches_cpu_reference() {
    let fixture = build_fixture(true, true);
    let mut oracle = OptimizedOracle::new_with_sparse(
        &fixture.s,
        &fixture.params,
        &fixture.mcs_witnesses,
        &fixture.me_witnesses,
        fixture.ch,
        fixture.ell_d,
        fixture.ell_n,
        fixture.d_sc,
        fixture.r_inputs.as_deref(),
        fixture.sparse,
    );
    assert!(fe_row_snapshot_has_eval_gate_for_testing(&oracle));
    let snapshot = fe_row_snapshot_bytes_for_testing(&oracle);
    let points = probe_points(303, 404);
    assert_eq!(
        oracle.evals_at(&points),
        direct_fe_eval(&mock_cpu_session(), &snapshot, &points)
    );
}

#[test]
fn fe_terminal_snapshot_fixture_matches_cpu_reference() {
    let fixture = build_fixture(true, true);
    let mut oracle = OptimizedOracle::new_with_sparse(
        &fixture.s,
        &fixture.params,
        &fixture.mcs_witnesses,
        &fixture.me_witnesses,
        fixture.ch,
        fixture.ell_d,
        fixture.ell_n,
        fixture.d_sc,
        fixture.r_inputs.as_deref(),
        fixture.sparse,
    );
    for round in 0..(fixture.ell_n - 1) {
        oracle.fold(k(500 + round as u64, 700 + round as u64));
    }
    assert_eq!(fe_row_snapshot_cur_len_for_testing(&oracle), 2);
    let snapshot = fe_row_snapshot_bytes_for_testing(&oracle);
    let points = probe_points(505, 606);
    assert_eq!(
        oracle.evals_at(&points),
        direct_fe_eval(&mock_cpu_session(), &snapshot, &points)
    );
}

#[test]
fn nc_chunk_snapshot_fixture_matches_cpu_reference() {
    let fixture = build_fixture(false, false);
    let mut oracle = NcOracle::new(
        &fixture.s,
        &fixture.params,
        &fixture.mcs_witnesses,
        &fixture.me_witnesses,
        fixture.ch,
        fixture.ell_d,
        fixture.ell_m,
        fixture.d_sc,
    );
    assert_eq!(
        nc_col_snapshot_num_tables_for_testing(&oracle),
        fixture.mcs_witnesses.len()
    );
    let snapshot = nc_col_snapshot_bytes_for_testing(&oracle);
    let points = probe_points(707, 808);
    assert_eq!(
        oracle.evals_at(&points),
        direct_nc_eval(&mock_cpu_session(), &snapshot, &points)
    );
}

#[test]
fn nc_aggregate_snapshot_fixture_matches_cpu_reference() {
    let fixture = build_fixture(true, true);
    let mut oracle = NcOracle::new(
        &fixture.s,
        &fixture.params,
        &fixture.mcs_witnesses,
        &fixture.me_witnesses,
        fixture.ch,
        fixture.ell_d,
        fixture.ell_m,
        fixture.d_sc,
    );
    assert_eq!(
        nc_col_snapshot_num_tables_for_testing(&oracle),
        fixture.mcs_witnesses.len() + fixture.me_witnesses.len()
    );
    let snapshot = nc_col_snapshot_bytes_for_testing(&oracle);
    let points = probe_points(909, 1_010);
    assert_eq!(
        oracle.evals_at(&points),
        direct_nc_eval(&mock_cpu_session(), &snapshot, &points)
    );
}

#[test]
fn nc_terminal_snapshot_fixture_matches_cpu_reference() {
    let fixture = build_fixture(true, true);
    let mut oracle = NcOracle::new(
        &fixture.s,
        &fixture.params,
        &fixture.mcs_witnesses,
        &fixture.me_witnesses,
        fixture.ch,
        fixture.ell_d,
        fixture.ell_m,
        fixture.d_sc,
    );
    for round in 0..(fixture.ell_m - 1) {
        oracle.fold(k(1_100 + round as u64, 1_300 + round as u64));
    }
    assert_eq!(nc_col_snapshot_cur_len_for_testing(&oracle), 2);
    let snapshot = nc_col_snapshot_bytes_for_testing(&oracle);
    let points = probe_points(1_111, 1_212);
    assert_eq!(
        oracle.evals_at(&points),
        direct_nc_eval(&mock_cpu_session(), &snapshot, &points)
    );
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_fe_stage_fixture_vectors_match_cpu_reference() {
    let session = real_cpu_session();

    let chunk = build_fixture(false, false);
    let mut chunk_oracle = OptimizedOracle::new_with_sparse(
        &chunk.s,
        &chunk.params,
        &chunk.mcs_witnesses,
        &chunk.me_witnesses,
        chunk.ch,
        chunk.ell_d,
        chunk.ell_n,
        chunk.d_sc,
        None,
        chunk.sparse,
    );
    let chunk_points = probe_points(1_401, 1_402);
    assert_eq!(
        chunk_oracle.evals_at(&chunk_points),
        direct_fe_eval(
            &session,
            &fe_row_snapshot_bytes_for_testing(&chunk_oracle),
            &chunk_points
        )
    );

    let aggregate = build_fixture(true, true);
    let mut aggregate_oracle = OptimizedOracle::new_with_sparse(
        &aggregate.s,
        &aggregate.params,
        &aggregate.mcs_witnesses,
        &aggregate.me_witnesses,
        aggregate.ch,
        aggregate.ell_d,
        aggregate.ell_n,
        aggregate.d_sc,
        aggregate.r_inputs.as_deref(),
        aggregate.sparse,
    );
    for round in 0..(aggregate.ell_n - 1) {
        aggregate_oracle.fold(k(1_500 + round as u64, 1_700 + round as u64));
    }
    let terminal_points = probe_points(1_403, 1_404);
    assert_eq!(
        aggregate_oracle.evals_at(&terminal_points),
        direct_fe_eval(
            &session,
            &fe_row_snapshot_bytes_for_testing(&aggregate_oracle),
            &terminal_points,
        )
    );
}

#[test]
#[ignore = "requires local Mojo toolchain"]
fn real_mojo_nc_stage_fixture_vectors_match_cpu_reference() {
    let session = real_cpu_session();

    let chunk = build_fixture(false, false);
    let mut chunk_oracle = NcOracle::new(
        &chunk.s,
        &chunk.params,
        &chunk.mcs_witnesses,
        &chunk.me_witnesses,
        chunk.ch,
        chunk.ell_d,
        chunk.ell_m,
        chunk.d_sc,
    );
    let chunk_points = probe_points(1_601, 1_602);
    assert_eq!(
        chunk_oracle.evals_at(&chunk_points),
        direct_nc_eval(
            &session,
            &nc_col_snapshot_bytes_for_testing(&chunk_oracle),
            &chunk_points
        )
    );

    let aggregate = build_fixture(true, true);
    let mut aggregate_oracle = NcOracle::new(
        &aggregate.s,
        &aggregate.params,
        &aggregate.mcs_witnesses,
        &aggregate.me_witnesses,
        aggregate.ch,
        aggregate.ell_d,
        aggregate.ell_m,
        aggregate.d_sc,
    );
    for round in 0..(aggregate.ell_m - 1) {
        aggregate_oracle.fold(k(1_800 + round as u64, 1_900 + round as u64));
    }
    let terminal_points = probe_points(1_603, 1_604);
    assert_eq!(
        aggregate_oracle.evals_at(&terminal_points),
        direct_nc_eval(
            &session,
            &nc_col_snapshot_bytes_for_testing(&aggregate_oracle),
            &terminal_points,
        )
    );
}
