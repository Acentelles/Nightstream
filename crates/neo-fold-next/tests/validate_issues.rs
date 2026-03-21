#[path = "validate_issues/chip8_trace_semantics.rs"]
mod chip8_trace_semantics;

#[path = "validate_issues/kernel_progress.rs"]
mod kernel_progress;

#[path = "validate_issues/kernel_opening_refinement.rs"]
mod kernel_opening_refinement;

#[path = "validate_issues/kernel_semantic_evidence.rs"]
mod kernel_semantic_evidence;

#[path = "validate_issues/kernel_row_projection.rs"]
mod kernel_row_projection;

#[path = "validate_issues/kernel_root_encode.rs"]
mod kernel_root_encode;

#[path = "validate_issues/kernel_meta_pub.rs"]
mod kernel_meta_pub;

#[path = "validate_issues/kernel_bridge_binding.rs"]
mod kernel_bridge_binding;

#[path = "validate_issues/kernel_fold_bucket.rs"]
mod kernel_fold_bucket;

#[path = "validate_issues/kernel_execution_digest.rs"]
mod kernel_execution_digest;

#[path = "validate_issues/kernel_stage3_digest.rs"]
mod kernel_stage3_digest;

#[path = "validate_issues/kernel_staged_execution_digest.rs"]
mod kernel_staged_execution_digest;

#[path = "validate_issues/stage2_val_from_inc.rs"]
mod stage2_val_from_inc;

#[path = "validate_issues/verifier_fail_closed.rs"]
mod verifier_fail_closed;
