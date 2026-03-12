//! Shared shard-level helper logic that is reused across the prove and verify
//! phases, without owning the phases themselves.
//!
//! This module owns:
//! - CCS oracle dispatch wrappers
//! - time-column commitment helpers
//! - joint-opening decomposition parameter derivation
//! - sharded helper submodules for step linking, commitment mixers, ME claim
//!   normalization, RLC arithmetic, and transcript binding

use super::*;
use p3_field::PrimeField64;

#[path = "core_utils/commit_mixers.rs"]
mod commit_mixers;
#[path = "core_utils/dec_stream.rs"]
mod dec_stream;
#[path = "core_utils/me_claims.rs"]
mod me_claims;
#[path = "core_utils/oracle_dispatch.rs"]
mod oracle_dispatch;
#[path = "core_utils/rlc_math.rs"]
mod rlc_math;
#[path = "core_utils/step_linking.rs"]
mod step_linking;
#[path = "core_utils/time_columns.rs"]
mod time_columns;
#[path = "core_utils/transcript_binding.rs"]
mod transcript_binding;

// ============================================================================
// Utilities
// ============================================================================

pub use crate::memory_sidecar::memory::absorb_step_memory;
pub use commit_mixers::CommitMixers;
pub use step_linking::{check_step_linking, StepLinkingConfig};

pub(crate) use dec_stream::dec_stream_no_witness;
pub(crate) use me_claims::*;
pub(crate) use oracle_dispatch::CcsOracleDispatch;
pub(crate) use rlc_math::*;
pub(crate) use time_columns::*;
pub(crate) use transcript_binding::*;
