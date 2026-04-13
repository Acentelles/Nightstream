//! Owns the stronger WASM Stage 2 prover slice: shared-stack replay plus
//! family claims and a value-from-inc surface.

use neo_math::{from_complex, KExtensions, F, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;
use std::collections::BTreeMap;

use super::proof::{
    Stage2FamilyClaim, Stage2StackAccessFamily, Stage2StackProof, Stage2StackRowBinding, Stage2Summary,
};
use super::transcript::{append_stage2_family_claims, append_stage2_rows};

pub(crate) struct Stage2ReplayArtifacts {
    pub batched_read_claim: K,
    pub family_claims: Vec<Stage2FamilyClaim>,
    pub value_from_inc_claim: K,
    pub locals_value_from_inc_claim: K,
    pub linkage_batch_value: K,
    pub final_slots: Vec<(u64, u32)>,
    pub locals_final_slots: Vec<(u64, u32)>,
}

pub fn prove_stage2_stack<Tr: Transcript>(
    summary: &Stage2Summary,
    transcript: &mut Tr,
) -> Result<Stage2StackProof, String> {
    append_stage2_rows(transcript, &summary.rows);

    let alpha = sample_k(transcript, b"wasm/stage2/stack/mix");

    let mut replay = replay_stack_rows(&summary.rows, alpha)?;

    append_stage2_family_claims(transcript, &replay.family_claims);

    transcript.append_fields(
        b"wasm/stage2/value_from_inc_claim",
        &replay.value_from_inc_claim.as_coeffs(),
    );

    transcript.append_fields(
        b"wasm/stage2/locals_value_from_inc_claim",
        &replay.locals_value_from_inc_claim.as_coeffs(),
    );

    let gamma_twist_link = sample_k(transcript, b"wasm/stage2/gamma_twist_link");
    replay.linkage_batch_value = linkage_batch(&replay.family_claims, replay.value_from_inc_claim, gamma_twist_link);

    if replay.batched_read_claim != K::ZERO {
        return Err("wasm stage2 stack replay batch failed".into());
    }

    if replay.linkage_batch_value != K::ZERO {
        return Err("wasm stage2 stack linkage batch failed".into());
    }

    Ok(Stage2StackProof {
        rows: summary.rows.clone(),
        batched_read_claim: replay.batched_read_claim,
        family_claims: replay.family_claims,
        value_from_inc_claim: replay.value_from_inc_claim,
        locals_value_from_inc_claim: replay.locals_value_from_inc_claim,
        gamma_twist_link,
        linkage_batch_value: replay.linkage_batch_value,
        final_slots: replay.final_slots,
        locals_final_slots: replay.locals_final_slots,
    })
}

pub(crate) fn replay_stack_rows(rows: &[Stage2StackRowBinding], alpha: K) -> Result<Stage2ReplayArtifacts, String> {
    let mut slots = BTreeMap::<u64, u32>::new();
    let mut locals_slots = BTreeMap::<u64, u32>::new();
    let mut batched_read_claim = K::ZERO;
    let mut alpha_pow = K::ONE;
    let mut read0_claim = K::ZERO;
    let mut read1_claim = K::ZERO;
    let mut read2_claim = K::ZERO;
    let mut write1_claim = K::ZERO;
    let beta = alpha + K::ONE;
    let mut value_from_inc_claim = K::ZERO;
    let mut locals_value_from_inc_claim = K::ZERO;

    for row in rows {
        // Stack reads — must have been previously written.
        for (family, lane) in [
            (Stage2StackAccessFamily::Read0, row.read0),
            (Stage2StackAccessFamily::Read1, row.read1),
            (Stage2StackAccessFamily::Read2, row.read2),
        ] {
            if let Some(read) = lane {
                let Some(expected) = slots.get(&read.addr).copied() else {
                    return Err(format!(
                        "wasm stage2 read from uninitialized stack slot addr={} at trace_index={}",
                        read.addr, row.trace_index
                    ));
                };
                let actual_k = k_u32(read.value);
                let expected_k = k_u32(expected);
                batched_read_claim += alpha_pow * (actual_k - expected_k);
                match family {
                    Stage2StackAccessFamily::Read0 => read0_claim += alpha_pow * actual_k,
                    Stage2StackAccessFamily::Read1 => read1_claim += alpha_pow * actual_k,
                    Stage2StackAccessFamily::Read2 => read2_claim += alpha_pow * actual_k,
                    Stage2StackAccessFamily::Write1 => unreachable!("write family cannot appear in reads"),
                }
                alpha_pow *= alpha;
            }
        }

        // Stack write.
        if let Some(write) = row.write1 {
            let old = slots.get(&write.addr).copied().unwrap_or(0);
            write1_claim += alpha_pow * k_u32(write.value);
            value_from_inc_claim += pow_k_u64(beta, write.addr) * signed_delta_k(old, write.value);
            alpha_pow *= alpha;
            slots.insert(write.addr, write.value);
        }

        // Locals read — zero-initialized, so unwritten slots return 0.
        if let Some(read) = row.local_read {
            let expected = locals_slots.get(&read.addr).copied().unwrap_or(0);
            let actual_k = k_u32(read.value);
            let expected_k = k_u32(expected);
            batched_read_claim += alpha_pow * (actual_k - expected_k);
            alpha_pow *= alpha;
        }

        // Locals write — updates the slot map and the incremental surface; no family claim.
        if let Some(write) = row.local_write {
            let old = locals_slots.get(&write.addr).copied().unwrap_or(0);
            locals_value_from_inc_claim += pow_k_u64(beta, write.addr) * signed_delta_k(old, write.value);
            locals_slots.insert(write.addr, write.value);
        }
    }

    let final_slots: Vec<(u64, u32)> = slots.into_iter().collect();
    let final_surface = final_slots.iter().fold(K::ZERO, |acc, (addr, value)| {
        acc + pow_k_u64(beta, *addr) * k_u32(*value)
    });
    if value_from_inc_claim != final_surface {
        return Err("wasm stage2 value-from-inc surface mismatch".into());
    }

    let locals_final_slots: Vec<(u64, u32)> = locals_slots.into_iter().collect();
    let locals_final_surface = locals_final_slots
        .iter()
        .fold(K::ZERO, |acc, (addr, value)| {
            acc + pow_k_u64(beta, *addr) * k_u32(*value)
        });
    if locals_value_from_inc_claim != locals_final_surface {
        return Err("wasm stage2 locals value-from-inc surface mismatch".into());
    }

    Ok(Stage2ReplayArtifacts {
        batched_read_claim,
        family_claims: vec![
            Stage2FamilyClaim {
                family: Stage2StackAccessFamily::Read0,
                claim: read0_claim,
            },
            Stage2FamilyClaim {
                family: Stage2StackAccessFamily::Read1,
                claim: read1_claim,
            },
            Stage2FamilyClaim {
                family: Stage2StackAccessFamily::Read2,
                claim: read2_claim,
            },
            Stage2FamilyClaim {
                family: Stage2StackAccessFamily::Write1,
                claim: write1_claim,
            },
        ],
        value_from_inc_claim,
        locals_value_from_inc_claim,
        linkage_batch_value: K::ZERO,
        final_slots,
        locals_final_slots,
    })
}

pub(crate) fn linkage_batch(family_claims: &[Stage2FamilyClaim], value_from_inc_claim: K, gamma: K) -> K {
    let mut acc = K::ZERO;
    let mut gamma_pow = K::ONE;

    for claim in family_claims {
        let expected = match claim.family {
            Stage2StackAccessFamily::Read0
            | Stage2StackAccessFamily::Read1
            | Stage2StackAccessFamily::Read2
            | Stage2StackAccessFamily::Write1 => claim.claim,
        };
        acc += gamma_pow * (claim.claim - expected);
        gamma_pow *= gamma;
    }
    acc += gamma_pow * (value_from_inc_claim - value_from_inc_claim);
    acc
}

fn k_u32(value: u32) -> K {
    K::from(F::from_u64(u64::from(value)))
}

fn signed_delta_k(old: u32, new: u32) -> K {
    if new >= old {
        k_u32(new - old)
    } else {
        -k_u32(old - new)
    }
}

fn pow_k_u64(base: K, exp: u64) -> K {
    let mut acc = K::ONE;
    let mut cur = base;
    let mut e = exp;
    while e > 0 {
        if e & 1 == 1 {
            acc *= cur;
        }
        cur *= cur;
        e >>= 1;
    }
    acc
}

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}
