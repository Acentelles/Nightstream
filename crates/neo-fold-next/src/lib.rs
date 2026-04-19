#![cfg_attr(feature = "abba", allow(dead_code))]
//! Owns the active Rust proving path for `neo-fold-next`.
//!
//! Ownership:
//! - `prover`, `verifier`: generic `Π_CCS -> Π_RLC -> Π_DEC`
//! - `run`: session orchestration
//! - `proof`: generic session proof boundary
//! - `opening`: shared opening-claim and time-opening summary boundary
//! - `step_build`: frontend-produced step packaging and extension records
//! - `time_opening`, `finalize`: final opening and packaged-proof boundaries
//! - `witness_layout`: shared local packed witness layout helpers
//! - `vm`: static VM contracts
//! - `chip8`: current VM frontend and staged kernel

#[cfg(not(feature = "abba"))]
pub mod chip8;
pub mod chunk_relation;
pub mod decider;
pub mod finalize;
#[cfg(not(feature = "abba"))]
pub mod nightstream;
pub mod opening;
pub mod proof;
pub mod prover;
pub mod run;
#[cfg(not(feature = "abba"))]
pub mod rv64im;
pub mod step_build;
pub mod time_opening;
pub mod verifier;
pub mod vm;
pub mod witness_layout;
