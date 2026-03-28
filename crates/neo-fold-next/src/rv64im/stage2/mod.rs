//! Owns Stage 2 register/RAM/Twist summaries for the RV64IM parity slice.

mod proof;

pub use proof::{
    build_stage2_summary, RamAccessKind, RamEvent, RegisterReadEvent, RegisterReadRole, RegisterWriteEvent,
    Stage2Summary, TwistLinkEvent,
};
pub(crate) use proof::{
    ram_event_digest, ram_event_words, register_read_event_digest, register_read_words, register_write_event_digest,
    register_write_words, twist_link_event_digest, twist_link_words,
};
