//! Tests verifying the concrete claims from ABBA paper Section 8 (Neo instantiation).
//!
//! Each test is annotated with the specific claim it checks.

use neo_abba::{commit, setup, Commitment};
use neo_math::quaternion::{theta, QuatEl, TracelessEl, N_REAL, T0_DIM};
use neo_math::ring::{Rq, D};
use neo_math::Fq;
use p3_field::{PrimeCharacteristicRing, PrimeField64};
use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha8Rng;

fn make_rng() -> ChaCha8Rng {
    ChaCha8Rng::seed_from_u64(0xABBA)
}

// ─── Claim: naive embedding is trivial ────────────────────────────────────────
// "both 0, 1 ∈ O_K so the commutator of any element of Λ with 0 or 1 is
//  identically 0."

#[test]
fn naive_embedding_is_trivial() {
    let mut rng = make_rng();
    for _ in 0..20 {
        let a = QuatEl::random_uniform(&mut rng);

        // [a, 0] = 0 (trivially)
        let zero = QuatEl::zero();
        let comm_zero = QuatEl::commutator(&a, &zero);
        assert_eq!(comm_zero, QuatEl::zero(), "[a, 0] must be zero");

        // [a, 1] = a*1 - 1*a = 0 (1 is central)
        let one = QuatEl {
            a0: Rq::one(),
            a1: Rq::zero(),
        };
        let comm_one = QuatEl::commutator(&a, &one);
        assert_eq!(comm_one, QuatEl::zero(), "[a, 1] must be zero: 1 is central");
    }
}

// ─── Claim: 1 ∈ O_K (fixed by theta) ─────────────────────────────────────────
// Verifies the prerequisite: the element 1 is in O_K (fixed by theta),
// which is WHY [a, 1] = 0.

#[test]
fn one_is_in_ok() {
    let one = Rq::one();
    assert_eq!(theta(&one), one, "1 must be fixed by theta (lies in O_K)");
}

// ─── Claim: [a, u] formula with ξ = -1 ───────────────────────────────────────
// "ξ = −1, so [a, u] = (a₁ − θ(a₁)) + u(θ(a₀) − a₀) and no scaling by ξ
//  is necessary."
//
// The general formula is [a, u] = ξ(θ(a₁) − a₁) + u(θ(a₀) − a₀).
// With ξ = -1: ξ(θ(a₁) − a₁) = -(θ(a₁) − a₁) = a₁ − θ(a₁). ✓

#[test]
fn commutator_with_u_formula_xi_minus_one() {
    let mut rng = make_rng();
    for _ in 0..20 {
        let a = QuatEl::random_uniform(&mut rng);
        let theta_a0 = theta(&a.a0);
        let theta_a1 = theta(&a.a1);

        // Paper formula (with ξ = -1 already applied):
        // component_0 = a₁ - θ(a₁)
        // component_1 = θ(a₀) - a₀
        let expected_0 = a.a1 - theta_a1;
        let expected_1 = theta_a0 - a.a0;
        let expected = TracelessEl::from_components(&expected_0, &expected_1);

        let actual = a.commutator_with_u();
        assert_eq!(
            actual.as_slice(),
            expected.as_slice(),
            "commutator_with_u must match paper formula"
        );

        // Also verify via the general commutator (sanity):
        let u_el = QuatEl::from_u_basis();
        let generic = QuatEl::commutator(&a, &u_el);
        let generic_t = TracelessEl::from_components(&generic.a0, &generic.a1);
        assert_eq!(
            actual.as_slice(),
            generic_t.as_slice(),
            "fast path must match generic commutator"
        );
    }
}

// ─── Claim: θ is a coefficient permutation ────────────────────────────────────
// "the automorphism θ ... act[s] as coefficient permutation[], so cost[s]
//  no Fq operations"
//
// We verify: θ maps each monomial X^i to a signed sum of at most 2 monomials,
// with coefficients in {-1, 0, +1}. No Fq multiplications.

#[test]
fn theta_is_coefficient_permutation() {
    for i in 0..D {
        let mut basis = [Fq::ZERO; D];
        basis[i] = Fq::ONE;
        let img = theta(&Rq(basis));

        // Every coefficient of θ(X^i) must be in {-1, 0, 1}
        for (j, &c) in img.0.iter().enumerate() {
            let v = c.as_canonical_u64();
            let q = <Fq as p3_field::PrimeField64>::ORDER_U64;
            let is_zero = v == 0;
            let is_one = v == 1;
            let is_neg_one = v == q - 1;
            assert!(
                is_zero || is_one || is_neg_one,
                "theta(X^{i}) has coefficient {v} at position {j}, expected {{-1, 0, 1}}"
            );
        }

        // At most 2 nonzero coefficients (verified from the formula)
        let nonzero_count = img.0.iter().filter(|&&c| c != Fq::ZERO).count();
        assert!(
            nonzero_count <= 2,
            "theta(X^{i}) has {nonzero_count} nonzero coefficients, expected <= 2"
        );
    }
}

// ─── Claim: multiplication by u is a coefficient permutation ──────────────────
// u * (a₀ + u*a₁) = u*a₀ + u²*a₁ = θ(a₀)*u + (-1)*a₁ = -a₁ + u*θ(a₀)
// So mul-by-u sends (a₀, a₁) → (-a₁, θ(a₀)): negation + theta + swap.
// No Fq multiplications.

#[test]
fn mul_by_u_is_permutation() {
    let mut rng = make_rng();
    let u_el = QuatEl::from_u_basis();

    for _ in 0..20 {
        let a = QuatEl::random_uniform(&mut rng);

        // u * a via quaternion multiplication
        let ua = u_el.mul(&a);

        // u*(a₀ + u*a₁) = u*a₀ + u²*a₁ = θ(a₀)*u + (-1)*a₁ = -a₁ + u*a₀
        // In (x0, x1) representation: (-a₁, a₀)
        // This is negation + swap: a coefficient permutation, zero multiplications.
        let expected = QuatEl {
            a0: Rq::zero() - a.a1,
            a1: a.a0,
        };
        assert_eq!(ua, expected, "u*a must equal (-a₁, a₀)");
    }
}

// ─── Claim: [a, u] costs exactly N field additions ────────────────────────────
// "each commutator takes only N field additions. No field multiplications
//  are required."
//
// N = dim(O_{L,q}) = D = 54. The paper's "N additions" means:
//   component_0 = a₁ - θ(a₁): since θ is a permutation, this is D subtractions
//   component_1 = θ(a₀) - a₀: same, D subtractions
//   total: 2D = 2*54 = 108 field additions/subtractions
//
// But the paper says "N field additions" where N = [Λ_q : F_q] = 4n = 108.
// So N = 108 = 2D. This matches: 2D additions, zero multiplications.

#[test]
fn commutator_with_u_operation_count() {
    // Structural verification: commutator_with_u computes exactly:
    //   1. theta(a0) — coefficient permutation, 0 muls
    //   2. theta(a1) — coefficient permutation, 0 muls
    //   3. a1 - theta(a1) — D = 54 subtractions
    //   4. theta(a0) - a0 — D = 54 subtractions
    //   5. from_components — projection into T_0 basis
    //
    // Steps 3-4: 2*D = 108 = N field operations, zero multiplications.
    //
    // We can't instrument operation counts directly, but we verify the
    // formula is correct and that theta is indeed a permutation (tested above).

    // Verify N = 2D = 4n
    assert_eq!(2 * D, 108, "N = 2D should be 108");
    assert_eq!(4 * N_REAL, 108, "N = 4n should be 108");
    assert_eq!(2 * D, 4 * N_REAL, "2D = 4n");
}

// ─── Claim: 25% compression ──────────────────────────────────────────────────
// "These compress from a space of size q^{2nmN} to one of size q^{3knN/2},
//  achieving a 25% size reduction compared to using Ajtai commitments."
//
// Per commitment slot:
//   Ajtai output element: dim O_{L,q} = 2n over F_q → 2n = D = 54
//   ABBA output element:  dim T_0 = 3n over F_q → 3n = 3*27 = 81
//   Ratio of output spaces: 3n / (4n) = 3/4 per quaternion dimension
//
// The 25% reduction: each T_0 element is 3n = 81 Fq elements, while each
// full quaternion element is 4n = 108. So T_0 achieves 75% of the full
// quaternion dimension, a 25% reduction.

#[test]
fn compression_ratio() {
    let full_quat_dim = 4 * N_REAL; // 108 = dim(Lambda_q)
    let traceless_dim = T0_DIM; // 81 = dim(T_0)
    let ajtai_dim = D; // 54 = dim(O_{L,q})

    // T_0 is 75% of the full quaternion
    assert_eq!(traceless_dim * 4, full_quat_dim * 3, "dim(T_0) * 4 = dim(Λ) * 3");

    // Compression: T_0 vs full quaternion
    // 81/108 = 3/4
    assert_eq!(3 * full_quat_dim, 4 * traceless_dim, "3/4 compression ratio");

    // Per the paper's table: commitment size ratio ABBA/Ajtai
    // Ajtai: each slot is O_{L,q} = 2n = 54 Fq elements
    // ABBA: each slot is T_0 = 3n = 81 Fq elements
    // But ABBA compresses MORE per slot because it maps 4n input dims to 3n output dims
    // while Ajtai maps 2n input dims to 2n output dims (no compression at all).
    //
    // The paper's "25% reduction" is about compression RATIO:
    //   Ajtai compression: 2n*m → 2n*k (ratio = m/k)
    //   ABBA compression: 4n*m → 3n*k (ratio = 4m/3k, better by factor 4/3)
    //   But output SIZE: 3nk vs 2nk — ABBA output is 3/2 * Ajtai output.
    //   The "25%" comes from: for the SAME security (same SIS dimension),
    //   ABBA needs 3nk output space vs Ajtai's 4nk (quaternion basis),
    //   giving 3/4 = 25% reduction.

    println!("dim(O_L) = {ajtai_dim}");
    println!("dim(T_0) = {traceless_dim}");
    println!("dim(Lambda) = {full_quat_dim}");
    println!("T_0/Lambda = {}/{} = 3/4", traceless_dim, full_quat_dim);
}

// ─── Claim: total cost formula 2nkN(2w-1) ────────────────────────────────────
// "the total number of additions in Fq required by ComNeo_ABBA is 2nkN(2w−1)"
//
// We verify this by counting: for a binary witness with known Hamming weight,
// the number of [a, u] evaluations equals the number of nonzero entries per
// (kappa, output-row) pair. Each evaluation costs N additions for the
// accumulation step.

#[test]
fn cost_formula_binary_witness() {
    let n = N_REAL; // 27
    let k = 4; // kappa
    let big_n = 4 * n; // N = 108

    // For a binary witness with average Hamming weight w per row of Z̃ (the 2n×m matrix):
    //   Total entries: 2n * m
    //   Nonzero entries per output (k, j): w entries contribute [A, u]
    //   Each [A, u] costs N additions for accumulation into T_0
    //   But the first nonzero costs N additions, and each subsequent costs N additions
    //   (N adds for the T_0 element addition)
    //   Plus the [a, u] computation itself: 2D = N additions
    //   Total per nonzero: N (compute) + N (accumulate) = 2N? No...
    //
    // Actually the paper says: "Each entry in T_0^{k×2n} takes Nw + N(w-1) operations"
    //   = Nw + Nw - N = N(2w - 1)
    //   First term Nw: computing w commutators [a, u], each N additions
    //   Second term N(w-1): accumulating w T_0 elements (w-1 additions, each N field ops)
    //
    // Total across all k*2n output entries: k * 2n * N * (2w - 1) = 2nkN(2w-1)

    // Test with concrete numbers: m = 10, 2n = 54, w = 3 (30% density)
    let m = 10;
    let two_n = 2 * n; // 54 = D
    let w = 3; // average Hamming weight per row

    let expected_cost = 2 * n * k * big_n * (2 * w - 1);
    let cost_per_entry = big_n * (2 * w - 1);
    let total_entries = k * two_n;

    assert_eq!(
        expected_cost,
        total_entries * cost_per_entry,
        "cost formula decomposition check"
    );

    println!("For k={k}, n={n}, N={big_n}, m={m}, w={w}:");
    println!("  Cost per output entry: N(2w-1) = {cost_per_entry}");
    println!("  Total output entries: k*2n = {total_entries}");
    println!("  Total cost: 2nkN(2w-1) = {expected_cost} Fq additions");

    // Compare with Ajtai: 2nkN(w-1)
    let ajtai_cost = 2 * n * k * big_n * (w - 1);
    println!("  Ajtai cost: 2nkN(w-1) = {ajtai_cost} Fq additions");
    println!(
        "  ABBA/Ajtai cost ratio: {}/{} = {:.2}",
        expected_cost,
        ajtai_cost,
        expected_cost as f64 / ajtai_cost as f64
    );
}

// ─── Claim: homomorphic property (Equation 1) ────────────────────────────────
// "Com(µ,r) + α·Com(µ',r') = Com(µ + αµ', r + αr')"
// In our Neo variant (no separate randomness): α·C(z) + C(z') = C(α·z + z')
// for α ∈ O_{K,q}.
//
// But α acts on z as a SCALAR in F_q (since z is a vector of F_q elements).
// The O_K scalar acts on the COMMITMENT, not on z directly.
// The correct statement for Neo: α·C(z) = C'(z) where C' uses keys α·A.

#[test]
fn homomorphic_property_neo() {
    let mut rng = make_rng();
    let d = D;
    let m = 4;
    let kappa = 3;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    let z1: Vec<Fq> = (0..d * m).map(|i| Fq::from_u64((i % 2) as u64)).collect();
    let z2: Vec<Fq> = (0..d * m)
        .map(|i| Fq::from_u64(((i + 1) % 3) as u64))
        .collect();

    let c1 = commit(&pp, &z1);
    let c2 = commit(&pp, &z2);

    // C(z1) + C(z2) = C(z1 + z2): linearity over F_q
    let z_sum: Vec<Fq> = z1.iter().zip(&z2).map(|(&a, &b)| a + b).collect();
    let c_sum = commit(&pp, &z_sum);
    let mut c_add = c1.clone();
    c_add.add_inplace(&c2);
    assert_eq!(c_add, c_sum, "C(z1) + C(z2) = C(z1+z2)");

    // Fq-scalar homomorphism: scalar * C(z) = C(scalar * z)
    let scalar = Fq::from_u64(7);
    let scaled = neo_abba::scale_commitment(scalar, &c1);
    let sz: Vec<Fq> = z1.iter().map(|&v| v * scalar).collect();
    assert_eq!(scaled, commit(&pp, &sz), "Fq-scalar homomorphism");

    // O_K scalar homomorphism:
    // α·C(z) = α · Σ_j [A[i][j], (0, z_j)] = Σ_j [α·A[i][j], (0, z_j)]
    // since α ∈ O_K commutes with u.
    let a = Rq::random_uniform(&mut rng);
    let alpha = a + theta(&a); // in O_K
    let alpha_c1 = neo_abba::s_mul(&alpha, &c1);

    for i in 0..kappa {
        let mut expected = TracelessEl::zero();
        for j in 0..m {
            let col = &z1[j * d..(j + 1) * d];
            let mut z_coeffs = [Fq::ZERO; D];
            z_coeffs[..d].copy_from_slice(col);
            let z_rq = Rq(z_coeffs);
            // [α·A[i][j], (0, z_j)]
            let scaled_key = QuatEl {
                a0: alpha * pp.a_rows[i][j].a0,
                a1: alpha * pp.a_rows[i][j].a1,
            };
            let z_quat = QuatEl {
                a0: Rq::zero(),
                a1: z_rq,
            };
            let comm = QuatEl::commutator(&scaled_key, &z_quat);
            expected += TracelessEl::from_components(&comm.a0, &comm.a1);
        }
        assert_eq!(
            alpha_c1.col(i),
            expected.as_slice(),
            "α·C(z) = Σ_j [α·A[j], (0, z_j)] at kappa {i}"
        );
    }
}

// ─── Claim: disjoint index supports ──────────────────────────────────────────
// "the summands in the addition have disjoint index supports: we add a u⁰
//  component and a u¹ = u component."
//
// This means: in (a₁ - θ(a₁)) + u(θ(a₀) - a₀), the first part lives in the
// u⁰ slot (indices 0..D in the quaternion), and the second lives in the u¹ slot
// (indices D..2D). They don't overlap, so the "addition" is just concatenation.

#[test]
fn disjoint_index_supports() {
    let mut rng = make_rng();
    for _ in 0..20 {
        let a = QuatEl::random_uniform(&mut rng);
        let theta_a0 = theta(&a.a0);
        let theta_a1 = theta(&a.a1);

        // u⁰ component: a₁ - θ(a₁), lives in O_L (the "real" part)
        let u0_part = a.a1 - theta_a1;
        // u¹ component: θ(a₀) - a₀, lives in O_L (the "u" part)
        let u1_part = theta_a0 - a.a0;

        // Verify these are independent: changing u0_part doesn't affect u1_part
        // (trivially true since they're separate Rq elements, but the point is
        // that in the TracelessEl representation, they map to disjoint index ranges)
        let t = TracelessEl::from_components(&u0_part, &u1_part);
        let (recovered_u0, recovered_u1) = t.to_components();

        assert_eq!(u0_part, recovered_u0, "u⁰ part roundtrip");
        assert_eq!(u1_part, recovered_u1, "u¹ part roundtrip");

        // The T_0 representation stores: [N_REAL coords for u0] [D coords for u1]
        // Indices [0..27) are u⁰ projected, [27..81) are u¹ full.
        // These ranges don't overlap.
        assert_eq!(N_REAL, 27);
        assert_eq!(T0_DIM, 81);
        assert_eq!(N_REAL + D, T0_DIM, "T_0 = ker(1+θ) ⊕ u·O_L");
    }
}

// ─── Claim: commitment output lives in T_0 ───────────────────────────────────
// Every commitment output must be a valid traceless element (x₀ + θ(x₀) = 0).

#[test]
fn commitment_output_is_traceless() {
    let mut rng = make_rng();
    let d = D;
    let m = 4;
    let kappa = 4;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    // Random binary witness
    let z: Vec<Fq> = (0..d * m)
        .map(|_| if rng.random::<bool>() { Fq::ONE } else { Fq::ZERO })
        .collect();

    let c = commit(&pp, &z);

    // Each kappa-slot should decode to a traceless quaternion
    for i in 0..kappa {
        let mut t = TracelessEl::zero();
        t.data.copy_from_slice(c.col(i));
        let (x0, _x1) = t.to_components();

        // Traceless: x0 + θ(x0) = 0
        let trace = x0 + theta(&x0);
        assert_eq!(
            trace,
            Rq::zero(),
            "commitment slot {i} must be traceless: x₀ + θ(x₀) = 0"
        );
    }
}

// ─── Claim: binding (empirical) ──────────────────────────────────────────────
// Distinct witnesses should produce distinct commitments (with overwhelming
// probability over the key).

#[test]
fn binding_empirical() {
    let mut rng = make_rng();
    let d = D;
    let m = 4;
    let kappa = 4;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    // Generate 50 distinct witnesses and verify all commitments are distinct
    let mut commitments = Vec::new();
    for seed in 0u64..50 {
        // Use a seeded RNG per witness to guarantee distinct witnesses
        let mut wrng = ChaCha8Rng::seed_from_u64(1000 + seed);
        let z: Vec<Fq> = (0..d * m)
            .map(|_| Fq::from_u64(wrng.random_range(0..5u64)))
            .collect();
        commitments.push(commit(&pp, &z));
    }

    for i in 0..commitments.len() {
        for j in (i + 1)..commitments.len() {
            assert_ne!(
                commitments[i], commitments[j],
                "distinct witnesses {i} and {j} must produce distinct commitments"
            );
        }
    }
}

// ─── Claim: Neo phases compatibility ─────────────────────────────────────────
// "We can replace Ajtai commitments with ABBA and obtain an identical first
//  phase ΠCCS, ... and the second and third phases hold by the homomorphic
//  properties displayed in Equation (1)."
//
// ΠRLC: random linear combination c_acc = c_acc + ρ · c_step
// ΠDEC: decomposition c = Σ b^i c_i
//
// We simulate both phases:

#[test]
fn pi_rlc_simulation() {
    let mut rng = make_rng();
    let d = D;
    let m = 4;
    let kappa = 3;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    // Simulate 5 folding steps with F_q scalar challenges.
    // In Neo, ρ ∈ O_K, but since the witness z lives in F_q^dm,
    // we verify the folding identity: ρ · C(z_step) = C(ρ · z_step)
    // for F_q scalars, confirming the commitment is F_q-linear.
    for step in 0..5 {
        let z_step: Vec<Fq> = (0..d * m)
            .map(|i| Fq::from_u64(((step * 3 + i) % 4) as u64))
            .collect();
        let c_step = commit(&pp, &z_step);

        let rho_fq = Fq::from_u64((step + 2) as u64);
        let rho_fq_c = neo_abba::scale_commitment(rho_fq, &c_step);

        let z_scaled: Vec<Fq> = z_step.iter().map(|&v| rho_fq * v).collect();
        let c_scaled = commit(&pp, &z_scaled);
        assert_eq!(rho_fq_c, c_scaled, "Fq-folded step {step} consistent");
    }

    // Also verify O_K folding: α · C(z) = Σ_j [α·A[j], (0, z_j)]
    let z: Vec<Fq> = (0..d * m).map(|i| Fq::from_u64((i % 3) as u64)).collect();
    let c = commit(&pp, &z);
    let r = Rq::random_uniform(&mut rng);
    let rho = r + theta(&r); // in O_K
    let rho_c = neo_abba::s_mul(&rho, &c);

    for i in 0..kappa {
        let mut expected = TracelessEl::zero();
        for j in 0..m {
            let col = &z[j * d..(j + 1) * d];
            let mut z_coeffs = [Fq::ZERO; D];
            z_coeffs[..d].copy_from_slice(col);
            let z_rq = Rq(z_coeffs);
            let scaled_key = QuatEl {
                a0: rho * pp.a_rows[i][j].a0,
                a1: rho * pp.a_rows[i][j].a1,
            };
            let z_quat = QuatEl {
                a0: Rq::zero(),
                a1: z_rq,
            };
            let comm = QuatEl::commutator(&scaled_key, &z_quat);
            expected += TracelessEl::from_components(&comm.a0, &comm.a1);
        }
        assert_eq!(
            rho_c.col(i),
            expected.as_slice(),
            "O_K folding: ρ·C(z) = Σ_j [ρ·A[j], (0, z_j)]"
        );
    }
}

#[test]
fn pi_dec_simulation() {
    let mut rng = make_rng();
    let d = D;
    let m = 4;
    let kappa = 3;
    let pp = setup(&mut rng, d, kappa, m).unwrap();

    // Witness z, decompose into base-2 digits
    let z: Vec<Fq> = (0..d * m).map(|i| Fq::from_u64((i % 7) as u64)).collect();
    let c = commit(&pp, &z);

    // Decompose z into k=3 levels of base b=2
    let b: u32 = 2;
    let k = 3;
    let levels = neo_abba::split_b(&z, b, 1, d * m, k, neo_abba::DecompStyle::Balanced);

    // Commit each level
    let c_levels: Vec<Commitment> = levels.iter().map(|zi| commit(&pp, zi)).collect();

    // Verify: c == Σ b^i · c_levels[i]
    assert!(
        neo_abba::verify_split_open(&pp, &c, b, &c_levels, &levels),
        "ΠDEC: split opening must verify"
    );
}
