//! Owns Stage 3 continuity summaries for the RV64IM parity slice.

mod proof;

pub use proof::{build_stage3_summary, ContinuityEvent, Stage3Summary};
pub(crate) use proof::{continuity_event_digest, continuity_event_words};
