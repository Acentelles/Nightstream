//! Stage 2: WASM stack-memory ownership and replay checking.

mod proof;
mod prove;
mod transcript;
mod verify;

pub use proof::{
    build_stage2_summary, Stage2FamilyClaim, Stage2StackAccessFamily, Stage2StackProof, Stage2StackRowBinding,
    Stage2Summary,
};
pub use prove::prove_stage2_stack;
pub use verify::verify_stage2_stack;
