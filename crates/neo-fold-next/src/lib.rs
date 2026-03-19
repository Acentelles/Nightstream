//! Multi-VM proving architecture for `neo-fold-next`.
//!
//! Ownership map:
//! - `prover`, `verifier`: real `Π_CCS -> Π_RLC -> Π_DEC` kernel
//! - `run`: session-level prove/verify driver
//! - `vm`: static VM architecture contracts
//! - `frontends`: runtime trace/session builders
//! - `families`: batch extension-family proving
//! - `stages`: staged proving skeletons and planner
//! - `bridge`: staged-to-backend export boundary
//! - `pipeline`: top-level orchestration
//! - `proof`: typed proof and frontend artifacts
//! - `time_opening`, `finalize`: final boundary owners

pub mod bridge;
pub mod chip8;
pub mod families;
pub mod finalize;
pub mod pipeline;
pub mod proof;
pub mod prover;
pub mod run;
pub mod stages;
pub mod time_opening;
pub mod verifier;
pub mod vm;
