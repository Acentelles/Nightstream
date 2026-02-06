#![cfg(feature = "build-mojo")]

use neo_midnight_mojo_bridge::reduce_u192_quotient72;

const GOLDILOCKS_P_U64: u64 = 0xFFFF_FFFF_0000_0001;

fn mul_u128_u64_to_u192(x: u128, y: u64) -> [u64; 3] {
    let x0 = x as u64;
    let x1 = (x >> 64) as u64;

    let prod0 = (x0 as u128) * (y as u128);
    let prod1 = (x1 as u128) * (y as u128);

    let l0 = prod0 as u64;
    let carry0 = (prod0 >> 64) as u64;

    let prod1_lo = prod1 as u64;
    let prod1_hi = (prod1 >> 64) as u64;

    let mid = (carry0 as u128) + (prod1_lo as u128);
    let l1 = mid as u64;
    let carry1 = (mid >> 64) as u64;

    let l2 = prod1_hi + carry1;
    [l0, l1, l2]
}

fn add_u64_to_u192(mut limbs: [u64; 3], x: u64) -> [u64; 3] {
    let (l0, c0) = limbs[0].overflowing_add(x);
    limbs[0] = l0;
    if c0 {
        let (l1, c1) = limbs[1].overflowing_add(1);
        limbs[1] = l1;
        if c1 {
            limbs[2] = limbs[2].wrapping_add(1);
        }
    }
    limbs
}

fn q24_limbs_from_q72(q: u128) -> (u32, u32, u32) {
    let mask24 = (1u128 << 24) - 1;
    (
        (q & mask24) as u32,
        ((q >> 24) & mask24) as u32,
        ((q >> 48) & mask24) as u32,
    )
}

fn next_u64(state: &mut u64) -> u64 {
    // LCG: cheap + deterministic.
    *state = state.wrapping_mul(6364136223846793005).wrapping_add(1);
    *state
}

#[test]
fn reduce_u192_quotient72_matches_constructed_q_and_r() {
    let mut state: u64 = 0xC001_D00D_1234_5678;

    // A few edge cases.
    let edge_cases: &[(u128, u64)] = &[
        (0, 0),
        (0, GOLDILOCKS_P_U64 - 1),
        ((1u128 << 24) - 1, 0),
        ((1u128 << 48) - 1, 0),
        ((1u128 << 72) - 1, 0),
        ((1u128 << 72) - 1, GOLDILOCKS_P_U64 - 1),
    ];
    for &(q72, r) in edge_cases {
        let t = add_u64_to_u192(mul_u128_u64_to_u192(q72, GOLDILOCKS_P_U64), r);
        let out = reduce_u192_quotient72(t);
        let (q0, q1, q2) = q24_limbs_from_q72(q72);
        assert_eq!((out.q0, out.q1, out.q2, out.r), (q0, q1, q2, r));
    }

    // Randomized coverage (q < 2^72 by construction).
    let q72_mask = (1u128 << 72) - 1;
    for _ in 0..10_000 {
        let lo = next_u64(&mut state) as u128;
        let hi = next_u64(&mut state) as u128;
        let q72 = ((hi << 64) | lo) & q72_mask;
        let r = next_u64(&mut state) % GOLDILOCKS_P_U64;

        let t = add_u64_to_u192(mul_u128_u64_to_u192(q72, GOLDILOCKS_P_U64), r);
        let out = reduce_u192_quotient72(t);
        let (q0, q1, q2) = q24_limbs_from_q72(q72);
        assert_eq!((out.q0, out.q1, out.q2, out.r), (q0, q1, q2, r));
    }
}

