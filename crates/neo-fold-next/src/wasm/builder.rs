//! Owns packaging normalized WASM rows into `StepBuild`.

use neo_ajtai::Commitment;
use neo_ccs::traits::SModuleHomomorphism;
use neo_ccs::{CcsClaim, CcsWitness, Mat};
use neo_math::{D, F};
use p3_field::PrimeCharacteristicRing;

use crate::proof::StepInput;
use crate::step_build::{BytecodeFetchRecord, ShoutLookupRecord, StepBuild, StepExtensionData};
use crate::vm::{VmSpec, VmTraceBuilder};

use super::ccs::WasmVmSpec;
use super::ir::{WasmBoundaryState, WasmBuildError, WasmStepTrace};
use super::layout::{
    selector_col, COL_AUX0, COL_AUX1, COL_HALTED, COL_LOCALS_FBP, COL_LOCAL_INDEX, COL_LOCAL_VALUE, COL_ONE,
    COL_OPCODE_CODE, COL_PC_AFTER, COL_PC_BEFORE, COL_READ0_ADDR, COL_READ0_VALUE, COL_READ1_ADDR, COL_READ1_VALUE,
    COL_READ2_ADDR, COL_READ2_VALUE, COL_SHOUT_ENABLED, COL_SHOUT_ID, COL_SHOUT_VALUE, COL_SP_AFTER, COL_SP_BEFORE,
    COL_STACK_READS, COL_STACK_WRITES, COL_WRITE1_ADDR, COL_WRITE1_VALUE, PUBLIC_INPUTS, WITNESS_WIDTH,
};
use super::lower::{normalize_source, WasmTraceSource};
use super::tables::lookup_payload;

pub struct WasmTraceBuilder<'a, L> {
    log: &'a L,
}

impl<'a, L> WasmTraceBuilder<'a, L> {
    pub fn new(log: &'a L) -> Self {
        Self { log }
    }

    pub fn build_trace_source(
        &self,
        vm: &WasmVmSpec,
        source: &impl WasmTraceSource,
    ) -> Result<Vec<StepBuild>, WasmBuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let steps = normalize_source(source)?;
        self.build_steps(vm, &steps)
    }

    pub fn build_ir(&self, vm: &WasmVmSpec, steps: &[WasmStepTrace]) -> Result<Vec<StepBuild>, WasmBuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        self.build_steps(vm, steps)
    }

    pub fn build_steps(&self, vm: &WasmVmSpec, steps: &[WasmStepTrace]) -> Result<Vec<StepBuild>, WasmBuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        steps
            .iter()
            .map(|step| {
                let prev = WasmBoundaryState {
                    pc: step.pc_before,
                    sp: step.sp_before,
                    halted: false,
                };
                let next = WasmBoundaryState {
                    pc: step.pc_after,
                    sp: step.sp_after,
                    halted: step.halted,
                };
                self.build_step(vm, &(), &prev, &next, step)
            })
            .collect()
    }

    fn build_step_from_trace(&self, vm: &WasmVmSpec, trace: &WasmStepTrace) -> Result<StepBuild, WasmBuildError>
    where
        L: SModuleHomomorphism<F, Commitment> + Sync,
    {
        let row = build_row(trace);
        let z_mat = pack_row_major(&row);
        let x_pub = row[..PUBLIC_INPUTS].to_vec();
        let w = row[PUBLIC_INPUTS..].to_vec();
        let prepared = StepInput {
            label: format!("wasm@pc:{:04x}:{}", trace.pc_before, trace.info.name),
            mcs: CcsClaim {
                c: self.log.commit(&z_mat),
                x: x_pub,
                m_in: vm.core_ccs_spec().m_in,
            },
            witness: CcsWitness { w, Z: z_mat },
        };

        let extension_data = StepExtensionData {
            bytecode_fetch: Some(BytecodeFetchRecord {
                pc: u16::try_from(trace.pc_before).unwrap_or(u16::MAX),
                opcode: trace.opcode_code,
            }),
            shout_lookup: lookup_payload(trace).map(|payload| ShoutLookupRecord {
                shout_id: payload.shout_id,
                input0: payload.input0,
                input1: payload.input1,
                output: payload.output,
            }),
            ..StepExtensionData::default()
        };

        Ok(StepBuild {
            public_step: prepared.instance(),
            prepared,
            extension_data,
            kernel_aux: None,
        })
    }
}

impl<'a, L> VmTraceBuilder<WasmVmSpec> for WasmTraceBuilder<'a, L>
where
    L: SModuleHomomorphism<F, Commitment> + Sync,
{
    type Program = ();
    type MachineState = WasmBoundaryState;
    type StepTrace = WasmStepTrace;
    type Error = WasmBuildError;

    fn build_step(
        &self,
        vm: &WasmVmSpec,
        _program: &Self::Program,
        prev: &Self::MachineState,
        next: &Self::MachineState,
        trace: &Self::StepTrace,
    ) -> Result<StepBuild, Self::Error> {
        if prev.pc != trace.pc_before || prev.sp != trace.sp_before {
            return Err(WasmBuildError::StateMismatch(format!(
                "WASM prev boundary mismatch: expected pc={} sp={}, got pc={} sp={}",
                trace.pc_before, trace.sp_before, prev.pc, prev.sp
            )));
        }
        if next.pc != trace.pc_after || next.sp != trace.sp_after || next.halted != trace.halted {
            return Err(WasmBuildError::StateMismatch(format!(
                "WASM next boundary mismatch: expected pc={} sp={} halted={}, got pc={} sp={} halted={}",
                trace.pc_after, trace.sp_after, trace.halted, next.pc, next.sp, next.halted
            )));
        }
        self.build_step_from_trace(vm, trace)
    }
}

pub fn build_row(trace: &WasmStepTrace) -> Vec<F> {
    let mut row = vec![F::ZERO; WITNESS_WIDTH];
    row[COL_ONE] = F::ONE;
    row[COL_OPCODE_CODE] = F::from_u64(u64::from(trace.opcode_code));
    row[COL_PC_BEFORE] = F::from_u64(trace.pc_before);
    row[COL_PC_AFTER] = F::from_u64(trace.pc_after);
    row[COL_SP_BEFORE] = F::from_u64(trace.sp_before);
    row[COL_SP_AFTER] = F::from_u64(trace.sp_after);
    row[COL_HALTED] = if trace.halted { F::ONE } else { F::ZERO };
    row[COL_STACK_READS] = F::from_u64(u64::from(trace.info.stack_reads));
    row[COL_STACK_WRITES] = F::from_u64(u64::from(trace.info.stack_writes));
    row[COL_SHOUT_ENABLED] = if trace.info.uses_shout { F::ONE } else { F::ZERO };

    if let Some(col) = selector_col(trace.opcode) {
        row[col] = F::ONE;
    }
    if let Some(read) = trace.stack_read0 {
        row[COL_READ0_ADDR] = F::from_u64(read.addr);
        row[COL_READ0_VALUE] = F::from_u64(u64::from(read.value));
    }
    if let Some(read) = trace.stack_read1 {
        row[COL_READ1_ADDR] = F::from_u64(read.addr);
        row[COL_READ1_VALUE] = F::from_u64(u64::from(read.value));
    }
    if let Some(read) = trace.stack_read2 {
        row[COL_READ2_ADDR] = F::from_u64(read.addr);
        row[COL_READ2_VALUE] = F::from_u64(u64::from(read.value));
    }
    if let Some(write) = trace.stack_write1 {
        row[COL_WRITE1_ADDR] = F::from_u64(write.addr);
        row[COL_WRITE1_VALUE] = F::from_u64(u64::from(write.value));
    }
    if let Some(shout) = trace.info.shout_opcode {
        row[COL_SHOUT_ID] = F::from_u64(u64::from(shout.to_shout_id()));
        row[COL_SHOUT_VALUE] = F::from_u64(trace.stack_write1.map(|w| u64::from(w.value)).unwrap_or(0));
    }
    if matches!(
        trace.opcode,
        super::isa::WasmOpcode::LocalGet | super::isa::WasmOpcode::LocalSet | super::isa::WasmOpcode::LocalTee
    ) {
        row[COL_LOCALS_FBP] = F::from_u64(trace.locals_fbp);
        if let Some(idx) = trace.local_index {
            row[COL_LOCAL_INDEX] = F::from_u64(u64::from(idx));
        }
        let local_value = trace
            .local_read_value
            .or(trace.local_write_value)
            .unwrap_or(0);
        row[COL_LOCAL_VALUE] = F::from_u64(u64::from(local_value));
    }
    if matches!(trace.opcode, super::isa::WasmOpcode::Select) {
        let read0 = trace.stack_read0.map(|lane| lane.value).unwrap_or(0);
        let read1 = trace.stack_read1.map(|lane| lane.value).unwrap_or(0);
        let write1 = trace.stack_write1.map(|lane| lane.value).unwrap_or(0);
        row[COL_AUX0] = signed_u32_delta(write1, read1);
        row[COL_AUX1] = signed_u32_delta(read0, read1);
    }
    row
}

fn signed_u32_delta(lhs: u32, rhs: u32) -> F {
    if lhs >= rhs {
        F::from_u64(u64::from(lhs - rhs))
    } else {
        -F::from_u64(u64::from(rhs - lhs))
    }
}

fn pack_row_major(z: &[F]) -> Mat<F> {
    let cols = z.len().div_ceil(D);
    let mut out = Mat::zero(D, cols, F::ZERO);
    for (idx, value) in z.iter().copied().enumerate() {
        out[(idx % D, idx / D)] = value;
    }
    out
}
