//! Owns the top-level compatibility pipeline used before the real stage bridge lands.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::Mat;
use neo_math::{F, K};
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_reductions::error::PiCcsError;

use crate::bridge::{export_compat_steps, BridgeOutput, BridgePublicView};
use crate::chip8::spec::{Chip8Program, Chip8State, Chip8VmSpec};
use crate::chip8::trace::Chip8TraceBuilder;
use crate::families::{prove_chip8_extensions, session_step_points, verify_chip8_extensions, LoweredVmPlan};
use crate::finalize::{package_full_session_proof, verify_finalized_session};
use crate::proof::{PackagedProof, RunProof, StepBuild};
use crate::prover::CommitmentMixers;
use crate::run::{prove_steps, verify_steps};
use crate::stages::{planner::plan_vm, ChunkModel, StagePlan};
use crate::time_opening::{main_lane_opening_claims, prove_time_opening, verify_time_opening};
use crate::vm::VmSpec;

#[derive(Clone, Debug)]
pub struct CompatibilityArtifacts {
    pub lowered_plan: LoweredVmPlan,
    pub stage_plan: StagePlan,
    pub bridge_view: BridgePublicView,
    pub proof: PackagedProof,
}

pub fn prove_chip8_program<L, MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    vm: &Chip8VmSpec,
    program: &Chip8Program,
    initial_state: &Chip8State,
    step_count: usize,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<CompatibilityArtifacts, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let lowered_plan = crate::families::compiler::lower_vm_spec(vm);
    let stage_plan = plan_vm(&lowered_plan, ChunkModel::CompatibilityPerCpuStep);
    let builder = Chip8TraceBuilder::new(log);
    let step_builds = builder
        .build_program(vm, program, initial_state, step_count)
        .map_err(|err| PiCcsError::InvalidInput(err.to_string()))?;
    prove_compat_step_builds(
        mode,
        params,
        vm,
        program,
        initial_state,
        lowered_plan,
        stage_plan,
        step_builds,
        log,
        mixers,
    )
}

pub fn verify_chip8_program<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    vm: &Chip8VmSpec,
    program: &Chip8Program,
    initial_state: &Chip8State,
    step_count: usize,
    proof: &PackagedProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<neo_ccs::CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let execution = Chip8TraceBuilder::<()>::execute_program(program, initial_state, step_count)
        .map_err(|err| PiCcsError::InvalidInput(err.to_string()))?;
    let mut acc = crate::proof::SessionExtensionAccumulator::default();
    for step in &execution {
        for row in crate::chip8::trace::build_row_extension_trace(step) {
            acc.push(row);
        }
    }
    let step_points = session_step_points(&proof.proof.session)?;

    verify_chip8_extensions(program, initial_state, &acc, &step_points, &proof.proof.extensions)?;
    let main_lane_claims = main_lane_opening_claims(&proof.proof.session)?;
    verify_time_opening(
        &main_lane_claims,
        &proof.proof.extensions.opening_claims,
        &proof.proof.time_opening,
    )?;
    verify_finalized_session(mode, params, &vm.core_ccs_spec().structure, proof, mixers)
}

fn prove_compat_step_builds<L, MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    vm: &Chip8VmSpec,
    program: &Chip8Program,
    initial_state: &Chip8State,
    lowered_plan: LoweredVmPlan,
    stage_plan: StagePlan,
    step_builds: Vec<StepBuild>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<CompatibilityArtifacts, PiCcsError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let bridge = export_compat_steps(step_builds);
    let session = prove_steps(
        mode,
        params,
        &vm.core_ccs_spec().structure,
        bridge.prepared_steps.clone(),
        log,
        mixers,
    )?;
    let step_points = session_step_points(&session)?;
    let extensions = prove_chip8_extensions(program, initial_state, &bridge.session_extensions, &step_points)?;
    let main_lane_claims = main_lane_opening_claims(&session)?;
    let time_opening = Some(prove_time_opening(&main_lane_claims, &extensions.opening_claims)?);
    let proof = package_full_session_proof(bridge.public_steps.clone(), session, extensions, time_opening)?;

    Ok(CompatibilityArtifacts {
        lowered_plan,
        stage_plan,
        bridge_view: bridge.public_bridge_view,
        proof,
    })
}

pub fn verify_compat_session<MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    vm: &Chip8VmSpec,
    bridge: &BridgeOutput,
    proof: &RunProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<Vec<neo_ccs::CeClaim<Commitment, F, K>>, PiCcsError>
where
    MR: Fn(&[Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    verify_steps(
        mode,
        params,
        &vm.core_ccs_spec().structure,
        bridge.public_steps.clone(),
        proof,
        mixers,
    )
}
