use neo_gpu::{DeviceApi, FlatRq, MojoSession};
use neo_math::F;
use p3_field::{PrimeCharacteristicRing, PrimeField64};

use crate::PiCcsError;

#[derive(Clone, Debug, Default)]
pub(crate) struct RqAccumulateSchedule {
    target_slots: usize,
    slot_offsets: Vec<u64>,
    lhs: Vec<FlatRq>,
    rhs: Vec<FlatRq>,
    next_slot: usize,
}

impl RqAccumulateSchedule {
    pub(crate) fn new(slot_count: usize) -> Self {
        let mut slot_offsets = Vec::with_capacity(slot_count.saturating_add(1));
        slot_offsets.push(0);
        Self {
            target_slots: slot_count,
            slot_offsets,
            lhs: Vec::new(),
            rhs: Vec::new(),
            next_slot: 0,
        }
    }

    #[inline]
    pub(crate) fn slot_count(&self) -> usize {
        self.target_slots
    }

    #[inline]
    pub(crate) fn pair_count(&self) -> usize {
        self.lhs.len()
    }

    #[inline]
    pub(crate) fn is_empty(&self) -> bool {
        self.lhs.is_empty()
    }

    pub(crate) fn push_slot_pairs<I>(&mut self, slot_idx: usize, pairs: I)
    where
        I: IntoIterator<Item = (FlatRq, FlatRq)>,
    {
        debug_assert_eq!(slot_idx, self.next_slot);
        for (lhs, rhs) in pairs {
            self.lhs.push(lhs);
            self.rhs.push(rhs);
        }
        self.slot_offsets.push(self.lhs.len() as u64);
        self.next_slot += 1;
    }

    pub(crate) fn finish(mut self) -> Self {
        while self.next_slot < self.target_slots {
            self.slot_offsets.push(self.lhs.len() as u64);
            self.next_slot += 1;
        }
        self
    }

    #[inline]
    pub(crate) fn zero_output(&self) -> Vec<FlatRq> {
        vec![FlatRq { coeffs: [0u64; 54] }; self.slot_count()]
    }

    #[inline]
    pub(crate) fn lhs(&self) -> &[FlatRq] {
        self.lhs.as_slice()
    }

    #[inline]
    pub(crate) fn rhs(&self) -> &[FlatRq] {
        self.rhs.as_slice()
    }

    #[inline]
    pub(crate) fn slot_offsets(&self) -> &[u64] {
        self.slot_offsets.as_slice()
    }
}

fn fused_rq_accumulate_min_slots(api: DeviceApi) -> usize {
    match api {
        DeviceApi::Cuda | DeviceApi::Metal => 1,
        DeviceApi::Cpu | DeviceApi::Auto => usize::MAX,
    }
}

fn should_use_fused_rq_accumulate(session: &MojoSession, slot_count: usize, pair_count: usize) -> bool {
    pair_count >= slot_count && slot_count >= fused_rq_accumulate_min_slots(session.device_api())
}

fn should_use_prepared_rq_accumulate(session: &MojoSession, slot_count: usize, pair_count: usize) -> bool {
    session.device_api() == DeviceApi::Cuda
        && session.supports_rq_prepared_api()
        && pair_count >= slot_count
        && pair_count >= 16
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

fn compact_active_slots(schedule: &RqAccumulateSchedule) -> Option<(Vec<usize>, RqAccumulateSchedule)> {
    if schedule.slot_count() == 0 || schedule.pair_count() >= schedule.slot_count() {
        return None;
    }
    let slot_offsets = schedule.slot_offsets();
    let active_slot_count = slot_offsets
        .windows(2)
        .filter(|window| window[0] != window[1])
        .count();
    if active_slot_count == 0 || active_slot_count == schedule.slot_count() {
        return None;
    }

    let mut active_slots = Vec::with_capacity(active_slot_count);
    let mut compact = RqAccumulateSchedule::new(active_slot_count);
    for slot_idx in 0..schedule.slot_count() {
        let start = slot_offsets[slot_idx] as usize;
        let end = slot_offsets[slot_idx + 1] as usize;
        if start == end {
            continue;
        }
        active_slots.push(slot_idx);
        compact.push_slot_pairs(
            active_slots.len() - 1,
            schedule.lhs()[start..end]
                .iter()
                .copied()
                .zip(schedule.rhs()[start..end].iter().copied()),
        );
    }
    Some((active_slots, compact.finish()))
}

fn execute_schedule_with_backend(
    session: &MojoSession,
    schedule: &RqAccumulateSchedule,
) -> Result<Vec<FlatRq>, PiCcsError> {
    if should_use_prepared_rq_accumulate(session, schedule.slot_count(), schedule.pair_count()) {
        let prepared = session
            .prepare_rq_accumulate_batch_u64x54(schedule.lhs(), schedule.rhs(), schedule.slot_offsets())
            .map_err(|err| PiCcsError::ProtocolError(format!("Mojo rq_accumulate_batch_prepare failed: {err}")))?;
        prepared
            .execute()
            .map_err(|err| PiCcsError::ProtocolError(format!("Mojo rq_prepared_execute failed: {err}")))?;
        return prepared
            .read()
            .map_err(|err| PiCcsError::ProtocolError(format!("Mojo rq_prepared_read failed: {err}")));
    }
    rq_accumulate_with_backend(session, schedule.lhs(), schedule.rhs(), schedule.slot_offsets())
}

pub(crate) fn rq_accumulate_schedule_with_backend(
    session: &MojoSession,
    schedule: &RqAccumulateSchedule,
) -> Result<Vec<FlatRq>, PiCcsError> {
    if schedule.slot_count() == 0 {
        return Ok(Vec::new());
    }
    if schedule.is_empty() {
        return Ok(schedule.zero_output());
    }
    if let Some((active_slots, compact)) = compact_active_slots(schedule) {
        let compact_out = execute_schedule_with_backend(session, &compact)?;
        let mut out = schedule.zero_output();
        for (compact_idx, slot_idx) in active_slots.into_iter().enumerate() {
            out[slot_idx] = compact_out[compact_idx];
        }
        return Ok(out);
    }
    execute_schedule_with_backend(session, schedule)
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
