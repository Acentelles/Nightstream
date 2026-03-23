//! Stage 2: Twist memory checking.
//!
//! Owns the stage-local module boundary. Shared math lives in `common.rs`, the
//! register and RAM subsystems live in `reg.rs` and `ram.rs`, and the public
//! prove/verify entrypoints live in `prove.rs` and `verify.rs`.

mod common;
mod proof;
mod prove;
mod ram;
mod reg;
mod transcript;
mod verify;

pub use self::proof::{
    AddressCorrectnessProof, CycleProductProof, Stage2LinkClaims, Stage2TwistProof, RAM_TWIST_POLY_IDS,
    REG_TWIST_POLY_IDS, STAGE2_LANE_OPEN_COLS,
};
pub use self::prove::prove_stage2;
pub use self::verify::verify_stage2;
