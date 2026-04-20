//! Φ_128 ABBA over Baby Bear (q = 2^31 - 2^27 + 1) to verify field-independence.
//!
//! Baby Bear is a 31-bit prime with 128 | q-1 (since q-1 = 2^27 * 15),
//! so Φ_128 splits completely and the quaternion CRT works.

#![allow(dead_code)]

use p3_baby_bear::BabyBear as Fb;
use p3_field::PrimeCharacteristicRing;
use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha8Rng;

const DK: usize = 32; // dim(O_K) = φ(64) = 32
const T0_DIM: usize = 48; // 16 + 32

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct RqBB([Fb; DK]);

impl RqBB {
    fn zero() -> Self {
        Self([Fb::ZERO; DK])
    }
    fn add(self, rhs: Self) -> Self {
        let mut out = [Fb::ZERO; DK];
        for i in 0..DK {
            out[i] = self.0[i] + rhs.0[i];
        }
        Self(out)
    }
    fn sub(self, rhs: Self) -> Self {
        let mut out = [Fb::ZERO; DK];
        for i in 0..DK {
            out[i] = self.0[i] - rhs.0[i];
        }
        Self(out)
    }
    fn neg(self) -> Self {
        Self::zero().sub(self)
    }
    fn mul(self, rhs: Self) -> Self {
        let mut tmp = [Fb::ZERO; 2 * DK - 1];
        for i in 0..DK {
            for j in 0..DK {
                tmp[i + j] += self.0[i] * rhs.0[j];
            }
        }
        let mut out = [Fb::ZERO; DK];
        for i in 0..DK {
            out[i] = tmp[i];
        }
        for i in DK..(2 * DK - 1) {
            out[i - DK] -= tmp[i];
        }
        Self(out)
    }
    fn mul_by_monomial(self, j: usize) -> Self {
        if j == 0 {
            return self;
        }
        let mut out = [Fb::ZERO; DK];
        for i in 0..DK {
            let d = i + j;
            if d < DK {
                out[d] += self.0[i];
            } else {
                out[d - DK] -= self.0[i];
            }
        }
        Self(out)
    }
    fn random(rng: &mut impl Rng) -> Self {
        Self(core::array::from_fn(|_| Fb::from_u64(rng.random_range(0..u32::MAX as u64))))
    }
}

fn theta_bb(a: &RqBB) -> RqBB {
    let mut out = [Fb::ZERO; DK];
    for i in 0..DK {
        if a.0[i] == Fb::ZERO {
            continue;
        }
        let prod = 31 * i;
        let q = prod / DK;
        let r = prod % DK;
        let sign = if (i + q) % 2 == 0 {
            Fb::ONE
        } else {
            Fb::ZERO - Fb::ONE
        };
        out[r] += sign * a.0[i];
    }
    RqBB(out)
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct QuatBB {
    a0: RqBB,
    a1: RqBB,
}

impl QuatBB {
    fn zero() -> Self {
        Self {
            a0: RqBB::zero(),
            a1: RqBB::zero(),
        }
    }
    fn random(rng: &mut impl Rng) -> Self {
        Self {
            a0: RqBB::random(rng),
            a1: RqBB::random(rng),
        }
    }
    fn mul(&self, rhs: &Self) -> Self {
        let ta0 = theta_bb(&self.a0);
        let ta1 = theta_bb(&self.a1);
        Self {
            a0: self.a0.mul(rhs.a0).sub(ta1.mul(rhs.a1)),
            a1: self.a1.mul(rhs.a0).add(ta0.mul(rhs.a1)),
        }
    }
    fn commutator(a: &Self, b: &Self) -> Self {
        let ab = a.mul(b);
        let ba = b.mul(a);
        Self {
            a0: ab.a0.sub(ba.a0),
            a1: ab.a1.sub(ba.a1),
        }
    }
    fn commutator_with_u(&self) -> (RqBB, RqBB) {
        let ta0 = theta_bb(&self.a0);
        let ta1 = theta_bb(&self.a1);
        (self.a1.sub(ta1), ta0.sub(self.a0))
    }
    fn commutator_sparse(&self, bits: &[usize]) -> (RqBB, RqBB) {
        if bits.is_empty() {
            return (RqBB::zero(), RqBB::zero());
        }
        let ta0 = theta_bb(&self.a0);
        let ta1 = theta_bb(&self.a1);
        let diff = ta0.sub(self.a0);
        let mut comp0 = RqBB::zero();
        let mut comp1 = RqBB::zero();
        for &t in bits {
            comp1 = comp1.add(diff.mul_by_monomial(t));
            let prod = 31 * t;
            let q = prod / DK;
            let r = prod % DK;
            let a1t = if (t + q) % 2 == 1 {
                self.a1.mul_by_monomial(r).neg()
            } else {
                self.a1.mul_by_monomial(r)
            };
            let ta1t = ta1.mul_by_monomial(t);
            comp0 = comp0.add(a1t).sub(ta1t);
        }
        (comp0, comp1)
    }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

#[test]
fn babybear_theta_involution() {
    let mut rng = ChaCha8Rng::seed_from_u64(0xBB);
    for _ in 0..20 {
        let a = RqBB::random(&mut rng);
        assert_eq!(theta_bb(&theta_bb(&a)), a, "θ² = id over BabyBear");
    }
}

#[test]
fn babybear_commutator_traceless() {
    let mut rng = ChaCha8Rng::seed_from_u64(0xBB);
    for _ in 0..20 {
        let a = QuatBB::random(&mut rng);
        let b = QuatBB::random(&mut rng);
        let comm = QuatBB::commutator(&a, &b);
        let trace = comm.a0.add(theta_bb(&comm.a0));
        assert_eq!(trace, RqBB::zero(), "[a,b] must be traceless over BabyBear");
    }
}

#[test]
fn babybear_sparse_matches_generic() {
    let mut rng = ChaCha8Rng::seed_from_u64(0xBB);
    for _ in 0..10 {
        let a = QuatBB::random(&mut rng);
        let n_bits = rng.random_range(3..=15usize);
        let mut bits: Vec<usize> = (0..n_bits).map(|_| rng.random_range(0..DK)).collect();
        bits.sort();
        bits.dedup();

        let mut z = [Fb::ZERO; DK];
        for &t in &bits {
            z[t] = Fb::ONE;
        }
        let b = QuatBB {
            a0: RqBB::zero(),
            a1: RqBB(z),
        };
        let generic = QuatBB::commutator(&a, &b);
        let (s0, s1) = a.commutator_sparse(&bits);
        assert_eq!(s0, generic.a0, "sparse matches generic (comp0) over BabyBear");
        assert_eq!(s1, generic.a1, "sparse matches generic (comp1) over BabyBear");
    }
}

#[test]
fn babybear_commitment_linearity() {
    let mut rng = ChaCha8Rng::seed_from_u64(0xBB);
    let kappa = 4;
    let m = 8;

    let pp: Vec<Vec<QuatBB>> = (0..kappa)
        .map(|_| (0..m).map(|_| QuatBB::random(&mut rng)).collect())
        .collect();

    let commit = |pp: &Vec<Vec<QuatBB>>, z: &[Fb]| -> Vec<(RqBB, RqBB)> {
        let mut out = vec![(RqBB::zero(), RqBB::zero()); kappa];
        for i in 0..kappa {
            for j in 0..m {
                let col = &z[j * DK..(j + 1) * DK];
                let all_zero = col.iter().all(|&v| v == Fb::ZERO);
                if all_zero {
                    continue;
                }
                let all_binary = col.iter().all(|&v| v == Fb::ZERO || v == Fb::ONE);
                if all_binary {
                    let bits: Vec<usize> = col
                        .iter()
                        .enumerate()
                        .filter(|(_, &v)| v != Fb::ZERO)
                        .map(|(t, _)| t)
                        .collect();
                    let (c0, c1) = pp[i][j].commutator_sparse(&bits);
                    out[i].0 = out[i].0.add(c0);
                    out[i].1 = out[i].1.add(c1);
                } else {
                    let mut zc = [Fb::ZERO; DK];
                    zc.copy_from_slice(col);
                    let b = QuatBB {
                        a0: RqBB::zero(),
                        a1: RqBB(zc),
                    };
                    let comm = QuatBB::commutator(&pp[i][j], &b);
                    out[i].0 = out[i].0.add(comm.a0);
                    out[i].1 = out[i].1.add(comm.a1);
                }
            }
        }
        out
    };

    let n = DK * m;
    let z1: Vec<Fb> = (0..n)
        .map(|i| if i % 3 == 0 { Fb::ONE } else { Fb::ZERO })
        .collect();
    let z2: Vec<Fb> = (0..n)
        .map(|i| if i % 5 == 0 { Fb::ONE } else { Fb::ZERO })
        .collect();

    let c1 = commit(&pp, &z1);
    let c2 = commit(&pp, &z2);
    let z_sum: Vec<Fb> = z1.iter().zip(&z2).map(|(&a, &b)| a + b).collect();
    let c_sum = commit(&pp, &z_sum);

    for i in 0..kappa {
        let s0 = c1[i].0.add(c2[i].0);
        let s1 = c1[i].1.add(c2[i].1);
        assert_eq!(s0, c_sum[i].0, "linearity comp0 at κ={i} over BabyBear");
        assert_eq!(s1, c_sum[i].1, "linearity comp1 at κ={i} over BabyBear");
    }
}

#[test]
fn babybear_25_percent_reduction() {
    let kappa = 16;
    let ajtai = kappa * 64; // D_L = 64
    let abba = kappa * T0_DIM; // 48
    assert_eq!(abba * 4, ajtai * 3, "ABBA = 3/4 Ajtai over BabyBear too");
    println!(
        "BabyBear Φ_128: Ajtai={ajtai} elems, ABBA={abba} elems, ratio={:.2}",
        abba as f64 / ajtai as f64
    );
}

#[test]
fn babybear_simulated_folding() {
    use std::time::Instant;

    let mut rng = ChaCha8Rng::seed_from_u64(0xBB);
    let kappa = 16;
    let m = 16;
    let n_steps = 5;
    let density = 0.5;
    let n_bits = DK * m;

    let pp: Vec<Vec<QuatBB>> = (0..kappa)
        .map(|_| (0..m).map(|_| QuatBB::random(&mut rng)).collect())
        .collect();

    let witnesses: Vec<Vec<Fb>> = (0..n_steps)
        .map(|_| {
            (0..n_bits)
                .map(|_| {
                    if rng.random_bool(density) {
                        Fb::ONE
                    } else {
                        Fb::ZERO
                    }
                })
                .collect()
        })
        .collect();

    let fold = || {
        let mut acc = vec![(RqBB::zero(), RqBB::zero()); kappa];
        let rho_raw = RqBB::random(&mut ChaCha8Rng::seed_from_u64(999));
        let rho = rho_raw.add(theta_bb(&rho_raw)); // O_K projection

        for w in &witnesses {
            let mut step_c = vec![(RqBB::zero(), RqBB::zero()); kappa];
            for i in 0..kappa {
                for j in 0..m {
                    let col = &w[j * DK..(j + 1) * DK];
                    let bits: Vec<usize> = col
                        .iter()
                        .enumerate()
                        .filter(|(_, &v)| v != Fb::ZERO)
                        .map(|(t, _)| t)
                        .collect();
                    if bits.is_empty() {
                        continue;
                    }
                    let (c0, c1) = pp[i][j].commutator_sparse(&bits);
                    step_c[i].0 = step_c[i].0.add(c0);
                    step_c[i].1 = step_c[i].1.add(c1);
                }
            }
            for i in 0..kappa {
                acc[i].0 = acc[i].0.add(rho.mul(step_c[i].0));
                acc[i].1 = acc[i].1.add(rho.mul(step_c[i].1));
            }
        }
        acc
    };

    for _ in 0..3 {
        let _ = fold();
    }
    let n_iters = 30;
    let start = Instant::now();
    for _ in 0..n_iters {
        let _ = fold();
    }
    let us = start.elapsed().as_micros() / n_iters as u128;

    println!(
        "BabyBear Φ_128: {n_steps} steps, m={m}, κ={kappa}, 50% density: {:.2} ms | commit={} Fq (25% smaller)",
        us as f64 / 1000.0,
        kappa * T0_DIM
    );
}

// ─── Ajtai over Baby Bear for comparison ─────────────────────────────────────

const DL: usize = 64; // dim(O_L) = φ(128) for Ajtai

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
struct RqL([Fb; DL]);

impl RqL {
    fn zero() -> Self { Self([Fb::ZERO; DL]) }
    fn add(self, rhs: Self) -> Self {
        let mut out = [Fb::ZERO; DL];
        for i in 0..DL { out[i] = self.0[i] + rhs.0[i]; }
        Self(out)
    }
    fn mul(self, rhs: Self) -> Self {
        let mut tmp = [Fb::ZERO; 2 * DL - 1];
        for i in 0..DL { for j in 0..DL { tmp[i + j] += self.0[i] * rhs.0[j]; } }
        let mut out = [Fb::ZERO; DL];
        for i in 0..DL { out[i] = tmp[i]; }
        for i in DL..(2 * DL - 1) { out[i - DL] -= tmp[i]; }
        Self(out)
    }
    fn mul_by_monomial(self, j: usize) -> Self {
        if j == 0 { return self; }
        let mut out = [Fb::ZERO; DL];
        for i in 0..DL {
            let d = i + j;
            if d < DL { out[d] += self.0[i]; } else { out[d - DL] -= self.0[i]; }
        }
        Self(out)
    }
    fn random(rng: &mut impl Rng) -> Self {
        Self(core::array::from_fn(|_| Fb::from_u64(rng.random_range(0..u32::MAX as u64))))
    }
}

fn ajtai_commit_bb(pp: &[Vec<RqL>], z: &[Fb], kappa: usize, m: usize) -> Vec<RqL> {
    let mut out = vec![RqL::zero(); kappa];
    for i in 0..kappa {
        for j in 0..m {
            let col = &z[j * DL..(j + 1) * DL];
            for (t, &zv) in col.iter().enumerate() {
                if zv != Fb::ZERO { out[i] = out[i].add(pp[i][j].mul_by_monomial(t)); }
            }
        }
    }
    out
}

#[test]
fn babybear_ajtai_vs_abba_bench() {
    use std::time::Instant;

    let mut rng = ChaCha8Rng::seed_from_u64(0xBB);
    let kappa = 16;
    let density = 0.5;

    println!("\n╔═══════════════════════════════════════════════════════════════╗");
    println!("║  Baby Bear Φ_128: ABBA vs Ajtai (commit + s_mul folding)    ║");
    println!("╠═══════════════════════════════════════════════════════════════╣");
    println!("║  {:>10} {:>10} {:>10} {:>8} {:>8} {:>10}  ║", "Config", "Ajtai", "ABBA", "Ratio", "A_size", "AB_size");

    for &(n_steps, m_per_step) in &[(2, 16), (5, 16), (10, 16), (5, 32)] {
        let total_bits = DL * m_per_step;
        let m_ajtai = m_per_step;
        let m_abba = m_per_step * 2; // ABBA packs DK=32 bits/col vs DL=64

        let ajtai_pp: Vec<Vec<RqL>> = (0..kappa)
            .map(|_| (0..m_ajtai).map(|_| RqL::random(&mut rng)).collect())
            .collect();
        let abba_raw: Vec<Vec<QuatBB>> = (0..kappa)
            .map(|_| (0..m_abba).map(|_| QuatBB::random(&mut rng)).collect())
            .collect();

        let mut rng_w = ChaCha8Rng::seed_from_u64(500);
        let ajtai_witnesses: Vec<Vec<Fb>> = (0..n_steps)
            .map(|_| (0..total_bits).map(|_| if rng_w.random_bool(density) { Fb::ONE } else { Fb::ZERO }).collect())
            .collect();
        let mut rng_w2 = ChaCha8Rng::seed_from_u64(600);
        let abba_witnesses: Vec<Vec<Fb>> = (0..n_steps)
            .map(|_| (0..total_bits).map(|_| if rng_w2.random_bool(density) { Fb::ONE } else { Fb::ZERO }).collect())
            .collect();

        let n_iters = 30;

        // Ajtai fold
        let ajtai_fold = || {
            let mut acc = vec![RqL::zero(); kappa];
            let rho = RqL::random(&mut ChaCha8Rng::seed_from_u64(999));
            for w in &ajtai_witnesses {
                let c = ajtai_commit_bb(&ajtai_pp, w, kappa, m_ajtai);
                for i in 0..kappa { acc[i] = acc[i].add(rho.mul(c[i])); }
            }
            acc
        };
        for _ in 0..3 { let _ = ajtai_fold(); }
        let start = Instant::now();
        for _ in 0..n_iters { let _ = ajtai_fold(); }
        let ajtai_us = start.elapsed().as_micros() / n_iters as u128;

        // ABBA fold
        let abba_fold = || {
            let mut acc = vec![(RqBB::zero(), RqBB::zero()); kappa];
            let r = RqBB::random(&mut ChaCha8Rng::seed_from_u64(999));
            let rho = r.add(theta_bb(&r));
            for w in &abba_witnesses {
                let mut step_c = vec![(RqBB::zero(), RqBB::zero()); kappa];
                for i in 0..kappa {
                    for j in 0..m_abba {
                        let col = &w[j * DK..(j + 1) * DK];
                        let bits: Vec<usize> = col.iter().enumerate()
                            .filter(|(_, &v)| v != Fb::ZERO).map(|(t, _)| t).collect();
                        if bits.is_empty() { continue; }
                        let (c0, c1) = pp_sparse_commit(&abba_raw[i][j], &bits);
                        step_c[i].0 = step_c[i].0.add(c0);
                        step_c[i].1 = step_c[i].1.add(c1);
                    }
                }
                for i in 0..kappa {
                    acc[i].0 = acc[i].0.add(rho.mul(step_c[i].0));
                    acc[i].1 = acc[i].1.add(rho.mul(step_c[i].1));
                }
            }
            acc
        };
        for _ in 0..3 { let _ = abba_fold(); }
        let start = Instant::now();
        for _ in 0..n_iters { let _ = abba_fold(); }
        let abba_us = start.elapsed().as_micros() / n_iters as u128;

        println!(
            "║  {:>2}x{:<2} ({:>4}b) {:>7.2}ms {:>7.2}ms {:>6.2}x {:>6} {:>8}  ║",
            n_steps, m_per_step, total_bits,
            ajtai_us as f64 / 1000.0, abba_us as f64 / 1000.0,
            abba_us as f64 / ajtai_us as f64,
            kappa * DL, kappa * T0_DIM
        );
    }
    println!("║  Commitment: Ajtai={} Fq, ABBA={} Fq (25% smaller)         ║", kappa * DL, kappa * T0_DIM);
    println!("╚═══════════════════════════════════════════════════════════════╝");
}

fn pp_sparse_commit(q: &QuatBB, bits: &[usize]) -> (RqBB, RqBB) {
    q.commutator_sparse(bits)
}
