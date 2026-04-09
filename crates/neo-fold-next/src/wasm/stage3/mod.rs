//! Owns the first WASM Stage 3 continuity and bridge slice.

mod proof;
mod prove;
mod transcript;
mod verify;

pub use proof::{build_stage3_summary, Stage3BoundaryProof, Stage3BoundaryRowBinding, Stage3BoundarySummary};
pub use prove::prove_stage3_boundaries;
pub use verify::verify_stage3_boundaries;
