//! Owns the WASM semantic kernel proof boundary above Stage 1/2/3.

mod openings;
mod types;

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_math::F;
use neo_params::NeoParams;
use neo_reductions::api::FoldingMode;
use neo_transcript::{Poseidon2Transcript, Transcript};

use super::builder::WasmTraceBuilder;
use super::ccs::WasmVmSpec;
use super::isa::WasmShoutOpcode;
use super::stage1::{
    build_stage1_summary, digest_pc_rom, prove_stage1_binary, prove_stage1_eqz, verify_stage1_binary,
    verify_stage1_eqz, Stage1BinaryProof,
};
use super::stage2::{build_stage2_summary, prove_stage2_stack, verify_stage2_stack};
use super::stage3::{build_stage3_summary, prove_stage3_boundaries, verify_stage3_boundaries};
use crate::proof::{FoldSchedule, PublicStep, StepInput};
use crate::prover::CommitmentMixers;
use crate::run::{prove_run, verify_run};
use crate::vm::VmSpec;
use openings::{build_kernel_opening_summary, verify_kernel_opening_summary};

pub use types::{
    WasmKernelError, WasmKernelOpeningSummary, WasmKernelOutput, WasmKernelPreparedStepSummary, WasmKernelProof,
    WasmKernelProverInput, WasmKernelPublicInput, WasmKernelRunProof, WasmKernelSelectedRowRef,
    WasmKernelStage1OpeningSummary, WasmKernelStage2OpeningSummary, WasmKernelStage3OpeningSummary,
    WasmKernelVerifierInput, WasmStage1ProofSet,
};

pub fn prove_simple_kernel<L>(
    input: &WasmKernelProverInput<'_>,
    log: &L,
) -> Result<(WasmKernelOutput, WasmKernelProof), WasmKernelError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
{
    let vm = WasmVmSpec::default();
    let builder = WasmTraceBuilder::new(log);
    let prepared_builds = builder
        .build_steps(&vm, input.trace)
        .map_err(|err| WasmKernelError::InvalidWitness(err.to_string()))?;
    let prepared_steps: Vec<StepInput> = prepared_builds
        .iter()
        .map(|step| step.prepared.clone())
        .collect();
    let public_steps: Vec<PublicStep> = prepared_steps.iter().map(StepInput::instance).collect();

    let mut transcript = new_wasm_kernel_transcript(&input.public.transcript_seed);

    let rom_digest = digest_pc_rom(&input.pc_rom);
    transcript.append_message(b"wasm/kernel/pc_rom_digest", &rom_digest);

    let stage1_summary = build_stage1_summary(input.trace);
    let stage1_eqz = prove_stage1_eqz(&stage1_summary, &mut transcript).map_err(WasmKernelError::Stage1)?;
    let stage1_binary = prove_stage1_binary_set(&stage1_summary, &mut transcript)?;

    let stage2_summary = build_stage2_summary(input.trace);
    let stage2 = prove_stage2_stack(&stage2_summary, &mut transcript).map_err(WasmKernelError::Stage2)?;

    let stage3_summary = build_stage3_summary(input.trace);
    let stage3 = prove_stage3_boundaries(&stage3_summary, &mut transcript).map_err(WasmKernelError::Stage3)?;

    if stage3.rows.len() != prepared_steps.len() {
        return Err(WasmKernelError::Bridge(format!(
            "wasm stage3 exported {} boundary rows for {} prepared steps",
            stage3.rows.len(),
            prepared_steps.len()
        )));
    }

    let mut proof = WasmKernelProof {
        stage1: WasmStage1ProofSet {
            eqz: stage1_eqz,
            binary: stage1_binary,
        },
        stage2,
        stage3,
        opening_summary: empty_opening_summary(),
    };
    let opening_summary = build_kernel_opening_summary(&proof, &prepared_steps);
    proof.opening_summary = opening_summary.clone();
    let output = WasmKernelOutput {
        prepared_steps,
        public_steps,
        opening_summary,
    };

    Ok((output, proof))
}

pub fn verify_simple_kernel<L>(
    input: &WasmKernelVerifierInput<'_>,
    log: &L,
    proof: &WasmKernelProof,
) -> Result<WasmKernelOutput, WasmKernelError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
{
    let vm = WasmVmSpec::default();
    let builder = WasmTraceBuilder::new(log);
    let prepared_builds = builder
        .build_steps(&vm, input.trace)
        .map_err(|err| WasmKernelError::InvalidWitness(err.to_string()))?;
    let prepared_steps: Vec<StepInput> = prepared_builds
        .iter()
        .map(|step| step.prepared.clone())
        .collect();
    let public_steps: Vec<PublicStep> = prepared_steps.iter().map(StepInput::instance).collect();

    let mut transcript = new_wasm_kernel_transcript(&input.public.transcript_seed);

    let rom_digest = digest_pc_rom(&input.pc_rom);
    transcript.append_message(b"wasm/kernel/pc_rom_digest", &rom_digest);

    let stage1_summary = build_stage1_summary(input.trace);
    verify_stage1_eqz(&stage1_summary, &proof.stage1.eqz, &mut transcript).map_err(WasmKernelError::Stage1)?;
    verify_stage1_binary_set(&stage1_summary, &proof.stage1.binary, &mut transcript)?;

    let stage2_summary = build_stage2_summary(input.trace);
    verify_stage2_stack(&stage2_summary, &proof.stage2, &mut transcript).map_err(WasmKernelError::Stage2)?;

    let stage3_summary = build_stage3_summary(input.trace);
    verify_stage3_boundaries(&stage3_summary, &proof.stage3, &mut transcript).map_err(WasmKernelError::Stage3)?;

    if proof.stage3.rows.len() != prepared_steps.len() {
        return Err(WasmKernelError::Bridge(format!(
            "wasm stage3 exported {} boundary rows for {} prepared steps",
            proof.stage3.rows.len(),
            prepared_steps.len()
        )));
    }

    verify_kernel_opening_summary(&proof.opening_summary, proof, &prepared_steps).map_err(WasmKernelError::Bridge)?;

    Ok(WasmKernelOutput {
        prepared_steps,
        public_steps,
        opening_summary: proof.opening_summary.clone(),
    })
}

pub fn prove_kernel_run<L, MR, MB>(
    mode: FoldingMode,
    schedule: FoldSchedule,
    params: &NeoParams,
    input: &WasmKernelProverInput<'_>,
    log: &L,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<(WasmKernelOutput, WasmKernelRunProof), WasmKernelError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[neo_ccs::Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let vm = WasmVmSpec::default();
    let (output, kernel) = prove_simple_kernel(input, log)?;
    let main_run = prove_run(
        mode,
        schedule,
        params,
        &vm.core_ccs_spec().structure,
        output.prepared_steps.clone(),
        log,
        mixers,
    )
    .map_err(|err| WasmKernelError::Bridge(err.to_string()))?;
    Ok((output, WasmKernelRunProof { kernel, main_run }))
}

pub fn verify_kernel_run<L, MR, MB>(
    mode: FoldingMode,
    params: &NeoParams,
    input: &WasmKernelVerifierInput<'_>,
    log: &L,
    proof: &WasmKernelRunProof,
    mixers: CommitmentMixers<MR, MB>,
) -> Result<WasmKernelOutput, WasmKernelError>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
    MR: Fn(&[neo_ccs::Mat<F>], &[Commitment]) -> Commitment + Clone + Copy,
    MB: Fn(&[Commitment], u32) -> Commitment + Clone + Copy,
{
    let vm = WasmVmSpec::default();
    let output = verify_simple_kernel(input, log, &proof.kernel)?;
    verify_run(
        mode,
        params,
        &vm.core_ccs_spec().structure,
        &output.public_steps,
        &proof.main_run,
        mixers,
    )
    .map_err(|err| WasmKernelError::Bridge(err.to_string()))?;
    Ok(output)
}

fn prove_stage1_binary_set(
    summary: &super::stage1::Stage1Summary,
    transcript: &mut Poseidon2Transcript,
) -> Result<Vec<Stage1BinaryProof>, WasmKernelError> {
    WasmShoutOpcode::all()
        .into_iter()
        .filter(|channel| !matches!(channel, WasmShoutOpcode::I32Eqz))
        .map(|channel| prove_stage1_binary(summary, channel, transcript).map_err(WasmKernelError::Stage1))
        .collect()
}

fn verify_stage1_binary_set(
    summary: &super::stage1::Stage1Summary,
    proofs: &[Stage1BinaryProof],
    transcript: &mut Poseidon2Transcript,
) -> Result<(), WasmKernelError> {
    let expected_channels: Vec<WasmShoutOpcode> = WasmShoutOpcode::all()
        .into_iter()
        .filter(|channel| !matches!(channel, WasmShoutOpcode::I32Eqz))
        .collect();
    if proofs.len() != expected_channels.len() {
        return Err(WasmKernelError::Stage1(format!(
            "wasm stage1 binary proof count {} != expected {}",
            proofs.len(),
            expected_channels.len()
        )));
    }
    for (proof, expected_channel) in proofs.iter().zip(expected_channels) {
        if proof.channel != expected_channel {
            return Err(WasmKernelError::Stage1(format!(
                "wasm stage1 binary proof channel {} != expected {}",
                proof.channel.name(),
                expected_channel.name()
            )));
        }
        verify_stage1_binary(summary, proof, transcript).map_err(WasmKernelError::Stage1)?;
    }
    Ok(())
}

fn new_wasm_kernel_transcript(seed: &[u8]) -> Poseidon2Transcript {
    let mut transcript = Poseidon2Transcript::new(b"neo.fold.next/wasm/kernel");
    transcript.append_u64s(b"neo.fold.next/wasm/kernel_seed_len", &[seed.len() as u64]);
    transcript.append_message(b"neo.fold.next/wasm/kernel_seed", seed);
    transcript
}

fn empty_opening_summary() -> WasmKernelOpeningSummary {
    WasmKernelOpeningSummary {
        stage1: WasmKernelStage1OpeningSummary {
            rows_digest: [0u8; 32],
            eqz_row_count: 0,
            binary_channel_count: 0,
            row_count: 0,
            first_row: None,
            last_row: None,
            digest: [0u8; 32],
        },
        stage2: WasmKernelStage2OpeningSummary {
            rows_digest: [0u8; 32],
            family_claims_digest: [0u8; 32],
            row_count: 0,
            family_count: 0,
            final_slot_count: 0,
            first_row: None,
            last_row: None,
            digest: [0u8; 32],
        },
        stage3: WasmKernelStage3OpeningSummary {
            rows_digest: [0u8; 32],
            row_count: 0,
            has_final_boundary: false,
            first_row: None,
            last_row: None,
            digest: [0u8; 32],
        },
        prepared_steps: WasmKernelPreparedStepSummary {
            steps_digest: [0u8; 32],
            step_count: 0,
            first_step: None,
            last_step: None,
            digest: [0u8; 32],
        },
        digest: [0u8; 32],
    }
}
