use super::*;

/// Optional verifier-side linking constraints across adjacent shard steps.
#[derive(Clone, Debug)]
pub struct StepLinkingConfig {
    /// Equalities on adjacent steps: require `steps[i].x[prev_idx] == steps[i+1].x[next_idx]`.
    pub prev_next_equalities: Vec<(usize, usize)>,
}

impl StepLinkingConfig {
    pub fn new(prev_next_equalities: Vec<(usize, usize)>) -> Self {
        Self { prev_next_equalities }
    }
}

pub fn check_step_linking(steps: &[StepInstanceBundle<Cmt, F, K>], cfg: &StepLinkingConfig) -> Result<(), PiCcsError> {
    if steps.len() <= 1 || cfg.prev_next_equalities.is_empty() {
        return Ok(());
    }
    for (i, (prev, next)) in steps.iter().zip(steps.iter().skip(1)).enumerate() {
        let prev_x = &prev.mcs_inst.x;
        let next_x = &next.mcs_inst.x;
        for &(prev_idx, next_idx) in &cfg.prev_next_equalities {
            if prev_idx >= prev_x.len() || next_idx >= next_x.len() {
                return Err(PiCcsError::InvalidInput(format!(
                    "step linking index out of range at boundary {i}: prev_x.len()={}, next_x.len()={}, pair=({prev_idx},{next_idx})",
                    prev_x.len(),
                    next_x.len(),
                )));
            }
            if prev_x[prev_idx] != next_x[next_idx] {
                return Err(PiCcsError::ProtocolError(format!(
                    "step linking failed at boundary {i}: prev_x[{prev_idx}] != next_x[{next_idx}]",
                )));
            }
        }
    }
    Ok(())
}
