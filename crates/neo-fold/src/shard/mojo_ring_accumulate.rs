use neo_gpu::{DeviceApi, FlatRq, MojoSession};
use neo_math::F;
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::PiCcsError;

fn fused_rq_accumulate_min_slots(api: DeviceApi) -> usize {
    match api {
        DeviceApi::Cuda | DeviceApi::Hip => 32,
        DeviceApi::Metal => 64,
        DeviceApi::Cpu | DeviceApi::Auto => usize::MAX,
    }
}

fn should_use_fused_rq_accumulate(session: &MojoSession, slot_count: usize, pair_count: usize) -> bool {
    pair_count >= slot_count.saturating_mul(4)
        && slot_count >= fused_rq_accumulate_min_slots(session.device_api())
}

fn accumulate_products_into_slots(products: &[FlatRq], slot_offsets: &[u64]) -> Vec<FlatRq> {
    let slot_count = slot_offsets.len().saturating_sub(1);
    let mut out = vec![FlatRq { coeffs: [0u64; 54] }; slot_count];
    for slot_idx in 0..slot_count {
        let start = slot_offsets[slot_idx] as usize;
        let end = slot_offsets[slot_idx + 1] as usize;
        let acc = &mut out[slot_idx];
        for product in &products[start..end] {
            for (dst, src) in acc.coeffs.iter_mut().zip(product.coeffs.iter().copied()) {
                *dst = (F::from_u64(*dst) + F::from_u64(src)).as_canonical_u64();
            }
        }
    }
    out
}

pub(crate) fn rq_accumulate_with_backend(
    session: &MojoSession,
    lhs: &[FlatRq],
    rhs: &[FlatRq],
    slot_offsets: &[u64],
) -> Result<Vec<FlatRq>, PiCcsError> {
    let slot_count = slot_offsets.len().saturating_sub(1);
    if lhs.is_empty() || slot_count == 0 {
        return Ok(vec![FlatRq { coeffs: [0u64; 54] }; slot_count]);
    }
    if should_use_fused_rq_accumulate(session, slot_count, lhs.len()) {
        return session
            .rq_accumulate_batch_u64x54(lhs, rhs, slot_offsets)
            .map_err(|err| PiCcsError::ProtocolError(format!("Mojo rq_accumulate_batch failed: {err}")));
    }

    let products = session
        .rq_mul_batch_u64x54(lhs, rhs)
        .map_err(|err| PiCcsError::ProtocolError(format!("Mojo rq_mul_batch failed: {err}")))?;
    Ok(accumulate_products_into_slots(&products, slot_offsets))
}
