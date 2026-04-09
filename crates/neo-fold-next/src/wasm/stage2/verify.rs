//! Owns verifier-side replay for the stronger WASM Stage 2 slice.

use neo_math::{from_complex, KExtensions, K};
use neo_transcript::Transcript;
use p3_field::PrimeCharacteristicRing;

use super::proof::{Stage2StackProof, Stage2Summary};
use super::prove::{linkage_batch, replay_stack_rows, Stage2ReplayArtifacts};
use super::transcript::{append_stage2_family_claims, append_stage2_rows};

pub fn verify_stage2_stack<Tr: Transcript>(
    summary: &Stage2Summary,
    proof: &Stage2StackProof,
    transcript: &mut Tr,
) -> Result<(), String> {
    if proof.rows != summary.rows {
        return Err("wasm stage2 stack row binding mismatch".into());
    }

    append_stage2_rows(transcript, &proof.rows);
    let alpha = sample_k(transcript, b"wasm/stage2/stack/mix");
    let Stage2ReplayArtifacts {
        batched_read_claim,
        family_claims,
        value_from_inc_claim,
        linkage_batch_value: _,
        final_slots,
    } = replay_stack_rows(&proof.rows, alpha)?;

    if proof.batched_read_claim != batched_read_claim {
        return Err("wasm stage2 stack batched claim mismatch".into());
    }
    if proof.batched_read_claim != K::ZERO {
        return Err("wasm stage2 stack replay batch failed".into());
    }
    if proof.family_claims != family_claims {
        return Err("wasm stage2 family-claim mismatch".into());
    }

    append_stage2_family_claims(transcript, &proof.family_claims);
    transcript.append_fields(
        b"wasm/stage2/value_from_inc_claim",
        &proof.value_from_inc_claim.as_coeffs(),
    );
    if proof.value_from_inc_claim != value_from_inc_claim {
        return Err("wasm stage2 value-from-inc claim mismatch".into());
    }

    let expected_gamma = sample_k(transcript, b"wasm/stage2/gamma_twist_link");
    if proof.gamma_twist_link != expected_gamma {
        return Err("wasm stage2 gamma_twist_link mismatch".into());
    }
    let expected_linkage = linkage_batch(&proof.family_claims, proof.value_from_inc_claim, proof.gamma_twist_link);
    if proof.linkage_batch_value != expected_linkage {
        return Err("wasm stage2 linkage batch mismatch".into());
    }
    if proof.linkage_batch_value != K::ZERO {
        return Err("wasm stage2 linkage batch failed".into());
    }
    if proof.final_slots != final_slots {
        return Err("wasm stage2 final stack snapshot mismatch".into());
    }

    Ok(())
}

fn sample_k<Tr: Transcript>(tr: &mut Tr, label: &'static [u8]) -> K {
    let c0 = tr.challenge_field(label);
    let c1 = tr.challenge_field(label);
    from_complex(c0, c1)
}
