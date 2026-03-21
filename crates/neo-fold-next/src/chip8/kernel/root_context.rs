//! Owns the canonical Ajtai/root context fixed by the CHIP-8 simple-kernel boundary.

use neo_ajtai::{set_global_pp_seeded, AjtaiSModule};
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsWitness, Mat};
use neo_math::D;
use neo_math::F;
use neo_memory::ajtai::{commit_cols_for_ccs_m, encode_vector_for_ccs_m};
use neo_params::NeoParams;
use neo_transcript::{Poseidon2Transcript, Transcript};
use p3_field::PrimeCharacteristicRing;

use crate::chip8::spec::WITNESS_WIDTH;
use crate::proof::StepInput;

use super::{KernelExactFrame, SimpleKernelError};

const CHIP8_SIMPLE_ROOT_PP_SEED: [u8; 32] = [
    0x09, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
];
const CHIP8_SIMPLE_ROOT_K_RHO: u32 = 16;
const CHIP8_SIMPLE_ROOT_B: u64 = 1 << 16;

pub(crate) struct SimpleKernelRootContext {
    params: NeoParams,
    log: AjtaiSModule,
}

impl SimpleKernelRootContext {
    pub(crate) fn new() -> Result<Self, SimpleKernelError> {
        let params = chip8_simple_root_params();
        let m = commit_cols_for_ccs_m(WITNESS_WIDTH);
        set_global_pp_seeded(D, params.kappa as usize, m, CHIP8_SIMPLE_ROOT_PP_SEED).map_err(|err| {
            SimpleKernelError::BridgeFailed(format!("canonical CHIP-8 root seed setup failed: {err}"))
        })?;
        Ok(Self {
            params,
            log: AjtaiSModule::from_global_for_dims(D, m).map_err(|err| {
                SimpleKernelError::BridgeFailed(format!("canonical CHIP-8 root module failed: {err}"))
            })?,
        })
    }

    pub(crate) fn params(&self) -> &NeoParams {
        &self.params
    }

    pub(crate) fn log(&self) -> &AjtaiSModule {
        &self.log
    }
}

pub fn chip8_simple_root_params() -> NeoParams {
    let mut params = NeoParams::goldilocks_auto_r1cs_ccs(WITNESS_WIDTH).expect("valid CHIP-8 root params");
    params.k_rho = CHIP8_SIMPLE_ROOT_K_RHO;
    params.B = CHIP8_SIMPLE_ROOT_B;
    params
}

pub(crate) fn chip8_simple_root_context_id() -> [u8; 32] {
    let params = chip8_simple_root_params();
    let mut tr = Poseidon2Transcript::new(b"neo.fold.next/chip8/root_context");
    tr.append_u64s(
        b"neo.fold.next/chip8/root_context/values",
        &[
            params.q,
            params.eta as u64,
            params.d as u64,
            params.kappa as u64,
            params.m,
            params.b as u64,
            params.k_rho as u64,
            params.B,
            params.T as u64,
            params.s as u64,
            params.lambda as u64,
            WITNESS_WIDTH as u64,
            commit_cols_for_ccs_m(WITNESS_WIDTH) as u64,
        ],
    );
    tr.append_message(b"neo.fold.next/chip8/root_context/seed", &CHIP8_SIMPLE_ROOT_PP_SEED);
    tr.digest32()
}

pub(crate) fn root_encode_semantic_row(
    root_context: &SimpleKernelRootContext,
    semantic_row: &[F; WITNESS_WIDTH],
) -> Result<(Vec<F>, Mat<F>), SimpleKernelError> {
    let witness = semantic_row[1..].to_vec();
    let packed = encode_vector_for_ccs_m(root_context.params(), WITNESS_WIDTH, semantic_row)
        .map_err(SimpleKernelError::BridgeFailed)?;
    Ok((witness, packed))
}

pub(crate) fn build_prepared_step_from_semantic_row(
    root_context: &SimpleKernelRootContext,
    row_index: usize,
    semantic_row: &[F; WITNESS_WIDTH],
) -> Result<StepInput, SimpleKernelError> {
    if semantic_row[0] != F::ONE {
        return Err(SimpleKernelError::BridgeFailed(format!(
            "semantic row {row_index} must have ONE = 1"
        )));
    }
    let (witness, z_mat) = root_encode_semantic_row(root_context, semantic_row)?;
    Ok(StepInput {
        label: format!("chip8/simple/{row_index}"),
        mcs: CcsClaim {
            c: root_context.log().commit(&z_mat),
            x: vec![F::ONE],
            m_in: 1,
        },
        witness: CcsWitness { w: witness, Z: z_mat },
    })
}

pub(crate) fn build_prepared_steps_from_frames(
    frames: &[KernelExactFrame],
) -> Result<Vec<StepInput>, SimpleKernelError> {
    let root_context = SimpleKernelRootContext::new()?;
    frames
        .iter()
        .map(|frame| build_prepared_step_from_semantic_row(&root_context, frame.step_idx, &frame.row))
        .collect()
}
