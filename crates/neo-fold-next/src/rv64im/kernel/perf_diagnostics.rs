//! Owns compact performance-diagnostics records for the RV64IM kernel path.

#[derive(Clone, Copy, Debug, Default)]
pub struct ExactStageVectorBuildPerf {
    pub flatten_u64_words: usize,
    pub field_limb_width: usize,
    pub packed_rows: usize,
    pub packed_cols: usize,
    pub flatten_ms: f64,
    pub limb_encode_ms: f64,
    pub context_setup_ms: f64,
    pub ccs_encode_ms: f64,
    pub ajtai_commit_ms: f64,
    pub opening_manifest_ms: f64,
    pub opening_prove_ms: f64,
}

impl ExactStageVectorBuildPerf {
    pub fn total_ms(&self) -> f64 {
        self.flatten_ms
            + self.limb_encode_ms
            + self.context_setup_ms
            + self.ccs_encode_ms
            + self.ajtai_commit_ms
            + self.opening_manifest_ms
            + self.opening_prove_ms
    }
}

#[derive(Clone, Copy, Debug, Default)]
pub struct StageClaimBundleBuildPerf {
    pub stage1: ExactStageVectorBuildPerf,
    pub stage2: ExactStageVectorBuildPerf,
    pub stage3: ExactStageVectorBuildPerf,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct PackagedOpeningBuildPerf {
    pub selected_labels: usize,
    pub claim_words: usize,
    pub package_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct StagePackageBundleBuildPerf {
    pub stage1: PackagedOpeningBuildPerf,
    pub stage2: PackagedOpeningBuildPerf,
    pub stage3: PackagedOpeningBuildPerf,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct KernelOpeningBundleBuildPerf {
    pub bindings: PackagedOpeningBuildPerf,
    pub prepared_steps: PackagedOpeningBuildPerf,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct SimpleKernelBuildPerf {
    pub prepared_steps_ms: f64,
    pub public_steps_ms: f64,
    pub prepared_step_bindings_ms: f64,
    pub stage_claim_bundle: StageClaimBundleBuildPerf,
    pub stage_package_bundle: StagePackageBundleBuildPerf,
    pub kernel_opening_bundle: KernelOpeningBundleBuildPerf,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct StagePackageBundleVerifyPerf {
    pub stage1_ms: f64,
    pub stage2_ms: f64,
    pub stage3_ms: f64,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct KernelOpeningBundleVerifyPerf {
    pub claim_rebuild_ms: f64,
    pub bindings_ms: f64,
    pub prepared_steps_ms: f64,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct SimpleKernelVerifyPerf {
    pub expected_core_ms: f64,
    pub trace_match_ms: f64,
    pub stages_match_ms: f64,
    pub stage_claims_match_ms: f64,
    pub kernel_claims_match_ms: f64,
    pub stage_package_bundle: StagePackageBundleVerifyPerf,
    pub kernel_opening_bundle: KernelOpeningBundleVerifyPerf,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct PackagedSimpleKernelVerifyPerf {
    pub simple_kernel: SimpleKernelVerifyPerf,
    pub public_step_match_ms: f64,
    pub main_lane_verify_ms: f64,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct Rv64imProofProvePerf {
    pub simple_kernel: SimpleKernelBuildPerf,
    pub packaged_main_lane_ms: f64,
    pub public_export_ms: f64,
    pub total_ms: f64,
}

#[derive(Clone, Copy, Debug, Default)]
pub struct Rv64imPublicProofVerifyPerf {
    pub public_claim_digests_ms: f64,
    pub public_bundle_digests_ms: f64,
    pub public_bundle_bindings_ms: f64,
    pub packaged_rebuild_ms: f64,
    pub packaged_verify: PackagedSimpleKernelVerifyPerf,
    pub export_match_ms: f64,
    pub total_ms: f64,
}
