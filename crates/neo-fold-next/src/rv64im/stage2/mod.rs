//! Owns Stage 2 register/RAM/Twist summaries for the RV64IM parity slice.

mod proof;

pub use proof::{
    build_stage2_summary, RamAccessKind, RamEvent, RegisterReadEvent, RegisterReadRole, RegisterWriteEvent,
    Stage2Summary, TwistLinkEvent,
};
