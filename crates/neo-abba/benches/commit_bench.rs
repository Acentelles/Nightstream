//! Benchmark: ABBA (column-based) vs Ajtai for Neo with b=2.
//!
//! Both schemes use m keys per kappa-row. The witness Z has d*m binary
//! elements. Ajtai uses ring multiplication (rot_step); ABBA uses sparse
//! commutators (zero Fq multiplications for binary inputs).

use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion, Throughput};
use neo_math::ring::D;
use neo_math::Fq;
use p3_field::PrimeCharacteristicRing;
use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha8Rng;

const KAPPA: usize = 16;

fn binary_witness(n: usize, density: f64, seed: u64) -> Vec<Fq> {
    let mut rng = ChaCha8Rng::seed_from_u64(seed);
    (0..n)
        .map(|_| if rng.random_bool(density) { Fq::ONE } else { Fq::ZERO })
        .collect()
}

/// Sweep over witness sizes with 50% density.
fn bench_commit_vs_m(c: &mut Criterion) {
    let mut group = c.benchmark_group("b2_commit_vs_m");
    let density = 0.5;

    for &m in &[64, 256, 1024] {
        let d = D;
        let n_bits = d * m;
        let z = binary_witness(n_bits, density, 100);

        let mut rng = ChaCha8Rng::seed_from_u64(42);
        let ajtai_pp = neo_ajtai::setup(&mut rng, d, KAPPA, m).unwrap();

        let mut rng2 = ChaCha8Rng::seed_from_u64(43);
        let abba_pp = neo_abba::setup(&mut rng2, d, KAPPA, m).unwrap();

        group.throughput(Throughput::Elements(n_bits as u64));

        group.bench_with_input(BenchmarkId::new("ajtai", m), &m, |b, _| {
            b.iter(|| neo_ajtai::commit(&ajtai_pp, &z));
        });

        group.bench_with_input(BenchmarkId::new("abba", m), &m, |b, _| {
            b.iter(|| neo_abba::commit(&abba_pp, &z));
        });
    }
    group.finish();
}

/// Sweep over density at fixed m.
fn bench_commit_vs_density(c: &mut Criterion) {
    let mut group = c.benchmark_group("b2_commit_vs_density");
    let m = 256;
    let d = D;
    let n_bits = d * m;

    let mut rng = ChaCha8Rng::seed_from_u64(42);
    let ajtai_pp = neo_ajtai::setup(&mut rng, d, KAPPA, m).unwrap();

    let mut rng2 = ChaCha8Rng::seed_from_u64(43);
    let abba_pp = neo_abba::setup(&mut rng2, d, KAPPA, m).unwrap();

    for &density_pct in &[10, 25, 50, 75, 100] {
        let density = density_pct as f64 / 100.0;
        let z = binary_witness(n_bits, density, 200 + density_pct);

        group.throughput(Throughput::Elements(n_bits as u64));

        group.bench_with_input(BenchmarkId::new("ajtai", density_pct), &density_pct, |b, _| {
            b.iter(|| neo_ajtai::commit(&ajtai_pp, &z));
        });

        group.bench_with_input(BenchmarkId::new("abba", density_pct), &density_pct, |b, _| {
            b.iter(|| neo_abba::commit(&abba_pp, &z));
        });
    }
    group.finish();
}

fn bench_s_mul(c: &mut Criterion) {
    let mut group = c.benchmark_group("b2_s_mul");
    let d = D;
    let m = 256;
    let n_bits = d * m;
    let z = binary_witness(n_bits, 0.5, 300);

    let mut rng = ChaCha8Rng::seed_from_u64(42);
    let ajtai_pp = neo_ajtai::setup(&mut rng, d, KAPPA, m).unwrap();
    let ajtai_c = neo_ajtai::commit(&ajtai_pp, &z);
    let rho = neo_math::ring::Rq::random_uniform(&mut rng);

    let mut rng2 = ChaCha8Rng::seed_from_u64(43);
    let abba_pp = neo_abba::setup(&mut rng2, d, KAPPA, m).unwrap();
    let abba_c = neo_abba::commit(&abba_pp, &z);
    let alpha = rho + neo_math::quaternion::theta(&rho);

    group.bench_function("ajtai", |b| {
        b.iter(|| neo_ajtai::s_mul(&rho, &ajtai_c));
    });
    group.bench_function("abba", |b| {
        b.iter(|| neo_abba::s_mul(&alpha, &abba_c));
    });
    group.finish();
}

fn bench_sizes(c: &mut Criterion) {
    let mut group = c.benchmark_group("b2_sizes");
    let d = D;

    for &m in &[256, 1024, 4096] {
        let n_bits = d * m;
        let z = binary_witness(n_bits, 0.5, 400);

        let mut rng = ChaCha8Rng::seed_from_u64(42);
        let ajtai_pp = neo_ajtai::setup(&mut rng, d, KAPPA, m).unwrap();
        let ajtai_c = neo_ajtai::commit(&ajtai_pp, &z);

        let mut rng2 = ChaCha8Rng::seed_from_u64(43);
        let abba_pp = neo_abba::setup(&mut rng2, d, KAPPA, m).unwrap();
        let abba_c = neo_abba::commit(&abba_pp, &z);

        println!("\n=== b=2, m={m}, kappa={KAPPA}, d={d} ===");
        println!(
            "  Commitment: Ajtai={} Fq, ABBA={} Fq, ratio={:.2}x",
            ajtai_c.data.len(),
            abba_c.data.len(),
            abba_c.data.len() as f64 / ajtai_c.data.len() as f64
        );
        println!("  PP keys/row: Ajtai={m} Rq, ABBA={m} QuatEl");
        let ajtai_pp_bytes = KAPPA * m * d * 8;
        let abba_pp_bytes = KAPPA * m * 2 * d * 8;
        println!(
            "  PP size: Ajtai={:.1} MB, ABBA={:.1} MB, ratio={:.1}x",
            ajtai_pp_bytes as f64 / 1e6,
            abba_pp_bytes as f64 / 1e6,
            abba_pp_bytes as f64 / ajtai_pp_bytes as f64
        );
    }

    group.bench_function("print_sizes", |b| b.iter(|| {}));
    group.finish();
}

criterion_group!(
    benches,
    bench_commit_vs_m,
    bench_commit_vs_density,
    bench_s_mul,
    bench_sizes,
);
criterion_main!(benches);
