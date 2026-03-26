//! Owns verifier-side bridge checks between the public RV64IM proof API and the private simple-kernel export.

use super::proof_api::Rv64imProof;
use super::proof_bridge::{
    kernel_claim_bundle_from_statement_and_kernel, kernel_proof_bundle_from_packaged,
    packaged_from_kernel_proof_bundle, proof_statement_from_kernel,
};
use super::{
    verify_packaged_simple_kernel, SimpleKernelError, SimpleKernelOutput, SimpleKernelPackagedProof,
    SimpleKernelPublicInput, SimpleKernelVerifierInput,
};

fn validate_public_claim_digests(proof: &Rv64imProof) -> Result<(), SimpleKernelError> {
    if proof.claim.accepted.statement.digest != proof.claim.accepted.statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof statement binding digest mismatch".into(),
        ));
    }
    if proof.claim.accepted.main_lane.digest != proof.claim.accepted.main_lane.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof main-lane binding digest mismatch".into(),
        ));
    }
    if proof.claim.accepted.terminal.digest != proof.claim.accepted.terminal.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof terminal binding digest mismatch".into(),
        ));
    }
    if proof.claim.accepted.digest != proof.claim.accepted.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof claim digest mismatch".into(),
        ));
    }
    if proof.claim.main_lane.binding.digest != proof.claim.main_lane.binding.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM main-lane claim binding digest mismatch".into(),
        ));
    }
    if proof.claim.main_lane.digest != proof.claim.main_lane.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM main-lane claim digest mismatch".into(),
        ));
    }
    if proof.claim.opening.stages.digest != proof.claim.opening.stages.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening stage-claim binding digest mismatch".into(),
        ));
    }
    if proof.claim.opening.terminal.digest != proof.claim.opening.terminal.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening terminal-claim binding digest mismatch".into(),
        ));
    }
    if proof.claim.opening.digest != proof.claim.opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening claim digest mismatch".into(),
        ));
    }
    if proof.claim.joint_opening.binding.digest != proof.claim.joint_opening.binding.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening claim binding digest mismatch".into(),
        ));
    }
    if proof.claim.joint_opening.digest != proof.claim.joint_opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening claim digest mismatch".into(),
        ));
    }
    if proof.claim.root0.stages.digest != proof.claim.root0.stages.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 stage-claim binding digest mismatch".into(),
        ));
    }
    if proof.claim.root0.terminal.digest != proof.claim.root0.terminal.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 terminal-claim binding digest mismatch".into(),
        ));
    }
    if proof.claim.root0.digest != proof.claim.root0.expected_digest() {
        return Err(SimpleKernelError::Bridge("RV64IM root0 claim digest mismatch".into()));
    }
    if proof.claim.digest != proof.claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel claim bundle digest mismatch".into(),
        ));
    }
    if proof.statement.digest != proof.statement.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM proof statement digest mismatch".into(),
        ));
    }
    Ok(())
}

fn validate_public_bundle_digests(proof: &Rv64imProof) -> Result<(), SimpleKernelError> {
    if proof.kernel.trace.shape.digest != proof.kernel.trace.shape.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM trace shape bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.trace.digest != proof.kernel.trace.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM trace proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.stages.summary.digest != proof.kernel.stages.summary.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-witness summary bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.stages.digest != proof.kernel.stages.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-witness proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.stage_claims.summary.digest != proof.kernel.stage_claims.summary.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-claim digest bundle mismatch".into(),
        ));
    }
    if proof.kernel.stage_claims.digest != proof.kernel.stage_claims.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-claim proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.stage_packages.summary.digest != proof.kernel.stage_packages.summary.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-package digest bundle mismatch".into(),
        ));
    }
    if proof.kernel.stage_packages.digest != proof.kernel.stage_packages.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-package proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.kernel_opening.digest != proof.kernel.kernel_opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.kernel_claims.digest != proof.kernel.kernel_claims.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-claim proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.main_lane.binding.digest != proof.kernel.main_lane.binding.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM main-lane proof binding digest mismatch".into(),
        ));
    }
    if proof.kernel.main_lane.digest != proof.kernel.main_lane.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM main-lane proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.claim.digest != proof.kernel.joint_opening.claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof claim digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.bindings.digest != proof.kernel.joint_opening.bindings.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening binding bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.bindings.main_lane.digest
        != proof
            .kernel
            .joint_opening
            .bindings
            .main_lane
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening main-lane binding digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.bindings.main_lane.proof.digest
        != proof
            .kernel
            .joint_opening
            .bindings
            .main_lane
            .proof
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening nested main-lane proof binding digest mismatch".into(),
        ));
    }
    if proof
        .kernel
        .joint_opening
        .bindings
        .kernel_opening
        .opening
        .digest
        != proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .opening
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening kernel-opening bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.bindings.statement.digest
        != proof
            .kernel
            .joint_opening
            .bindings
            .statement
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening statement binding digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.bindings.kernel_opening.digest
        != proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening kernel-opening binding digest mismatch".into(),
        ));
    }
    if proof
        .kernel
        .joint_opening
        .bindings
        .kernel_opening
        .opening
        .digest
        != proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .opening
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening nested kernel-opening binding digest mismatch".into(),
        ));
    }
    if proof.kernel.joint_opening.digest != proof.kernel.joint_opening.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.claim.digest != proof.kernel.root0_commitment.claim.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment claim digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.bindings.digest != proof.kernel.root0_commitment.bindings.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment binding bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.bindings.stages.claims.digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .stages
            .claims
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 stage-claim summary digest mismatch".into(),
        ));
    }
    if proof
        .kernel
        .root0_commitment
        .bindings
        .stages
        .packages
        .digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .stages
            .packages
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 stage-package summary digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.bindings.stages.digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .stages
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 stage binding digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.bindings.kernel.bundles.digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 kernel bundle binding digest mismatch".into(),
        ));
    }
    if proof
        .kernel
        .root0_commitment
        .bindings
        .kernel
        .bundles
        .opening
        .digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .opening
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 kernel opening binding digest mismatch".into(),
        ));
    }
    if proof
        .kernel
        .root0_commitment
        .bindings
        .kernel
        .bundles
        .claims
        .digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .claims
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 kernel claim summary digest mismatch".into(),
        ));
    }
    if proof
        .kernel
        .root0_commitment
        .bindings
        .kernel
        .bundles
        .claims
        .terminal
        .digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .claims
            .terminal
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 kernel terminal digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.bindings.kernel.digest
        != proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .expected_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 kernel binding digest mismatch".into(),
        ));
    }
    if proof.kernel.root0_commitment.digest != proof.kernel.root0_commitment.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment bundle digest mismatch".into(),
        ));
    }
    if proof.kernel.digest != proof.kernel.expected_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel proof bundle digest mismatch".into(),
        ));
    }
    Ok(())
}

fn validate_public_bundle_bindings(proof: &Rv64imProof) -> Result<(), SimpleKernelError> {
    if proof.kernel.kernel_opening.opening_digest != proof.kernel.kernel_opening.opening.digest
        || proof.kernel.kernel_opening.bindings.claim_digest != proof.kernel.kernel_opening.opening.claim.digest
        || proof.kernel.kernel_opening.bindings.bindings_digest != proof.kernel.kernel_opening.opening.bindings.digest
        || proof.kernel.kernel_opening.bindings.prepared_steps_digest
            != proof.kernel.kernel_opening.opening.prepared_steps.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening proof bundle fields do not match opening bundle".into(),
        ));
    }
    if proof.kernel.trace.manifest != proof.kernel.trace.trace.manifest
        || proof.kernel.trace.shape.execution_row_count != proof.kernel.trace.trace.execution_rows.len() as u64
        || proof.kernel.trace.shape.real_row_count
            != proof
                .kernel
                .trace
                .trace
                .execution_rows
                .iter()
                .filter(|row| row.is_real)
                .count() as u64
        || proof.kernel.trace.shape.effect_row_count
            != proof
                .kernel
                .trace
                .trace
                .execution_rows
                .iter()
                .filter(|row| row.is_effect_row)
                .count() as u64
        || proof.kernel.trace.shape.commit_row_count
            != proof
                .kernel
                .trace
                .trace
                .execution_rows
                .iter()
                .filter(|row| row.is_commit_row)
                .count() as u64
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM trace proof bundle fields do not match the private trace witness".into(),
        ));
    }
    if proof.kernel.stages.summary.stage1_row_count != proof.kernel.stages.stages.stage1.rows.len() as u64
        || proof.kernel.stages.summary.stage2_register_read_count
            != proof.kernel.stages.stages.stage2.register_reads.len() as u64
        || proof.kernel.stages.summary.stage2_register_write_count
            != proof.kernel.stages.stages.stage2.register_writes.len() as u64
        || proof.kernel.stages.summary.stage2_ram_event_count
            != proof.kernel.stages.stages.stage2.ram_events.len() as u64
        || proof.kernel.stages.summary.stage2_twist_link_count
            != proof.kernel.stages.stages.stage2.twist_links.len() as u64
        || proof.kernel.stages.summary.stage3_continuity_count
            != proof.kernel.stages.stages.stage3.continuity.len() as u64
        || proof.kernel.stages.summary.stage3_halted != proof.kernel.stages.stages.stage3.halted
        || proof.kernel.stages.summary.transcript_event_count
            != proof.kernel.stages.stages.transcript.events.len() as u64
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-witness proof bundle fields do not match the private stage witness bundle".into(),
        ));
    }
    if proof.kernel.stage_claims.summary.claim_bundle_digest != proof.kernel.stage_claims.claims.digest
        || proof.kernel.stage_claims.summary.stage1_digest != proof.kernel.stage_claims.claims.stage1.commitment.digest
        || proof.kernel.stage_claims.summary.stage2_digest != proof.kernel.stage_claims.claims.stage2.commitment.digest
        || proof.kernel.stage_claims.summary.stage3_digest != proof.kernel.stage_claims.claims.stage3.commitment.digest
        || proof.kernel.stage_claims.summary.transcript_digest
            != proof
                .kernel
                .stage_claims
                .claims
                .transcript
                .commitment
                .digest
        || proof.kernel.stage_claims.summary.execution_digest != proof.kernel.stage_claims.claims.execution_digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-claim proof bundle fields do not match stage claims".into(),
        ));
    }
    if proof.kernel.stage_packages.summary.package_bundle_digest != proof.kernel.stage_packages.packages.digest
        || proof.kernel.stage_packages.summary.stage1_digest != proof.kernel.stage_packages.packages.stage1.digest
        || proof.kernel.stage_packages.summary.stage2_digest != proof.kernel.stage_packages.packages.stage2.digest
        || proof.kernel.stage_packages.summary.stage3_digest != proof.kernel.stage_packages.packages.stage3.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-package proof bundle fields do not match stage packages".into(),
        ));
    }
    if proof.kernel.kernel_claims.prepared_step_bindings_digest()
        != proof
            .kernel
            .kernel_claims
            .claims
            .prepared_step_bindings
            .digest
        || proof.kernel.kernel_claims.root0_digest() != proof.kernel.kernel_claims.claims.kernel.root0_digest
        || proof.kernel.kernel_claims.execution_digest() != proof.kernel.kernel_claims.claims.kernel.execution_digest
        || proof.kernel.kernel_claims.final_state_digest()
            != proof.kernel.kernel_claims.claims.kernel.final_state_digest
        || proof.kernel.kernel_claims.transcript_final_digest()
            != proof
                .kernel
                .kernel_claims
                .claims
                .kernel
                .transcript_final_digest
        || proof.kernel.kernel_claims.final_pc() != proof.kernel.kernel_claims.claims.kernel.final_pc
        || proof.kernel.kernel_claims.halted() != proof.kernel.kernel_claims.claims.kernel.halted
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-claim proof bundle fields do not match kernel claims".into(),
        ));
    }
    if proof.claim.joint_opening.binding.proof_statement_digest != proof.statement.digest
        || proof.claim.joint_opening.binding.main_lane_claim_digest != proof.claim.main_lane.digest
        || proof
            .claim
            .joint_opening
            .binding
            .kernel_opening_claim_digest
            != proof.claim.opening.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening claim does not bind the expected public claims".into(),
        ));
    }
    if proof.claim.accepted.statement.proof_statement_digest != proof.statement.digest
        || proof.claim.accepted.statement.kernel_opening_digest != proof.kernel.kernel_opening.opening_digest
        || proof.claim.accepted.main_lane.main_lane_statement_digest != proof.kernel.main_lane.statement_digest()
        || proof.claim.accepted.main_lane.main_lane_proof_digest != proof.kernel.main_lane.proof_digest()
        || proof.claim.accepted.terminal.final_state_digest != proof.kernel.kernel_claims.final_state_digest()
        || proof.claim.accepted.terminal.public_step_count != proof.statement.public_step_count
        || proof.claim.accepted.terminal.final_pc != proof.statement.final_pc
        || proof.claim.accepted.terminal.halted != proof.statement.halted
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM accepted proof claim does not bind the expected public statement and proof digests".into(),
        ));
    }
    if proof.claim.main_lane.binding.statement_digest != proof.kernel.main_lane.statement_digest()
        || proof.claim.main_lane.binding.proof_digest != proof.kernel.main_lane.proof_digest()
        || proof.claim.main_lane.binding.public_step_count != proof.kernel.main_lane.public_step_count()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM main-lane claim does not bind the expected public main-lane proof bundle".into(),
        ));
    }
    if proof.claim.opening.stages.stage_claims_digest != proof.kernel.stage_claims.summary.claim_bundle_digest
        || proof.claim.opening.stages.stage_packages_digest != proof.kernel.stage_packages.summary.package_bundle_digest
        || proof.claim.opening.stages.kernel_opening_digest != proof.kernel.kernel_opening.opening_digest
        || proof.claim.opening.terminal.prepared_step_bindings_digest
            != proof.kernel.kernel_claims.prepared_step_bindings_digest()
        || proof.claim.opening.terminal.execution_digest != proof.kernel.kernel_claims.execution_digest()
        || proof.claim.opening.terminal.transcript_final_digest != proof.kernel.kernel_claims.transcript_final_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel-opening claim does not bind the expected stage and kernel terminal digests".into(),
        ));
    }
    if proof.claim.root0.stages.stage1_digest != proof.kernel.kernel_claims.claims.kernel.stage1_digest
        || proof.claim.root0.stages.stage2_digest != proof.kernel.kernel_claims.claims.kernel.stage2_digest
        || proof.claim.root0.stages.stage3_digest != proof.kernel.kernel_claims.claims.kernel.stage3_digest
        || proof.claim.root0.terminal.root0_digest != proof.kernel.kernel_claims.root0_digest()
        || proof.claim.root0.terminal.execution_digest != proof.kernel.kernel_claims.execution_digest()
        || proof.claim.root0.terminal.final_state_digest != proof.kernel.kernel_claims.final_state_digest()
        || proof.claim.root0.terminal.transcript_final_digest != proof.kernel.kernel_claims.transcript_final_digest()
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 claim does not bind the expected stage and kernel terminal digests".into(),
        ));
    }
    if proof
        .kernel
        .joint_opening
        .bindings
        .statement
        .statement_digest
        != proof.statement.digest
        || proof
            .kernel
            .joint_opening
            .bindings
            .statement
            .public_step_count
            != proof.kernel.main_lane.public_step_count()
        || proof.kernel.joint_opening.bindings.main_lane.bundle_digest != proof.kernel.main_lane.digest
        || proof
            .kernel
            .joint_opening
            .bindings
            .main_lane
            .proof
            .statement_digest
            != proof.kernel.main_lane.statement_digest()
        || proof
            .kernel
            .joint_opening
            .bindings
            .main_lane
            .proof
            .proof_digest
            != proof.kernel.main_lane.proof_digest()
        || proof
            .kernel
            .joint_opening
            .bindings
            .main_lane
            .proof
            .public_step_count
            != proof.kernel.main_lane.public_step_count()
        || proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .bundle_digest
            != proof.kernel.kernel_opening.digest
        || proof
            .kernel
            .joint_opening
            .bindings
            .kernel_opening
            .opening
            .digest
            != proof.kernel.kernel_opening.bindings.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof bundle fields do not match the proof statement and bound proof bundles".into(),
        ));
    }
    if proof.kernel.root0_commitment.bindings.stages.claims.digest != proof.kernel.stage_claims.summary.digest
        || proof
            .kernel
            .root0_commitment
            .bindings
            .stages
            .packages
            .digest
            != proof.kernel.stage_packages.summary.digest
        || proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .opening
            .digest
            != proof.kernel.kernel_opening.bindings.digest
        || proof
            .kernel
            .root0_commitment
            .bindings
            .kernel
            .bundles
            .claims
            .digest
            != proof.kernel.kernel_claims.summary.digest
    {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment bundle does not bind the expected proof bundles".into(),
        ));
    }
    if proof.kernel.root0_commitment.claim.terminal.root0_digest != proof.kernel.kernel_claims.root0_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment claim does not match the kernel-claim proof bundle".into(),
        ));
    }
    if proof.kernel.trace.execution_digest != proof.kernel.kernel_claims.execution_digest() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM trace proof bundle execution digest does not match the kernel-claim proof bundle".into(),
        ));
    }
    if proof.kernel.stages.summary.stage1_row_count != proof.kernel.trace.shape.execution_row_count {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-witness proof bundle stage1 count does not match the trace row count".into(),
        ));
    }
    if proof.kernel.stages.summary.stage3_continuity_count != proof.kernel.trace.shape.real_row_count {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-witness proof bundle continuity count does not match the real trace row count".into(),
        ));
    }
    if proof.kernel.stages.summary.stage3_halted != proof.kernel.kernel_claims.halted() {
        return Err(SimpleKernelError::Bridge(
            "RV64IM stage-witness proof bundle halted flag does not match the kernel-claim proof bundle".into(),
        ));
    }
    Ok(())
}

fn validate_export_match(
    proof: &Rv64imProof,
    kernel: &SimpleKernelOutput,
    packaged: &SimpleKernelPackagedProof,
) -> Result<(), SimpleKernelError> {
    let expected_statement = proof_statement_from_kernel(kernel, packaged);
    if proof.statement != expected_statement {
        return Err(SimpleKernelError::Bridge(
            "RV64IM proof statement does not match kernel export".into(),
        ));
    }
    let expected_claim = kernel_claim_bundle_from_statement_and_kernel(&proof.statement, packaged);
    if proof.claim != expected_claim {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel claim bundle does not match packaged proof export".into(),
        ));
    }
    let expected_bundle = kernel_proof_bundle_from_packaged(packaged);
    if proof.kernel.digest != expected_bundle.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM kernel proof bundle does not match packaged proof export".into(),
        ));
    }
    if proof.kernel.joint_opening.digest != expected_bundle.joint_opening.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM joint-opening proof bundle does not match packaged proof export".into(),
        ));
    }
    if proof.kernel.root0_commitment.digest != expected_bundle.root0_commitment.digest {
        return Err(SimpleKernelError::Bridge(
            "RV64IM root0 commitment bundle does not match packaged proof export".into(),
        ));
    }
    Ok(())
}

pub(super) fn verify_kernel_output_from_public_proof(
    input: &SimpleKernelPublicInput,
    proof: &Rv64imProof,
) -> Result<SimpleKernelOutput, SimpleKernelError> {
    validate_public_claim_digests(proof)?;
    validate_public_bundle_digests(proof)?;
    validate_public_bundle_bindings(proof)?;

    let packaged = packaged_from_kernel_proof_bundle(&proof.kernel);
    let verifier = SimpleKernelVerifierInput { public: input.clone() };
    let kernel = verify_packaged_simple_kernel(&verifier, &packaged)?;
    validate_export_match(proof, &kernel, &packaged)?;
    Ok(kernel)
}
